"""mitmproxy addon: confine requests carrying the GitHub placeholder to one repository.

Runs before ``inject.py``, which swaps the placeholder only on requests this
addon approved. ``GITHUB_REPO`` (``owner/name``, or empty for no repository)
names the repository; anything not explicitly allowed is denied with the
response GitHub itself gives for that surface.
"""

import base64
import json
import os
import re
import ssl
import urllib.request
from pathlib import Path
from urllib.parse import parse_qs, unquote

import certifi
from mitmproxy import http

PLACEHOLDER = "proxy-secret-github"
APPROVED = "github-policy-approved"

API_HOST = "api.github.com"
UPLOADS_HOST = "uploads.github.com"
GIT_HOST = "github.com"


def _resolve(repo: str) -> tuple[set[str], str | None]:
    if not repo:
        return set(), None
    request = urllib.request.Request(
        f"https://{API_HOST}/repos/{repo}",
        headers={
            "Authorization": f"Bearer {Path('/run/secrets/github').read_text().strip()}",
            "Accept": "application/vnd.github+json",
        },
    )
    # urllib follows the 301 GitHub answers for a renamed repository.
    context = ssl.create_default_context(cafile=certifi.where())
    with urllib.request.urlopen(request, timeout=30, context=context) as response:
        info = json.load(response)
    return {repo.lower(), info["full_name"].lower()}, str(info["id"])


REPO_NAMES, REPO_ID = _resolve(os.environ["GITHUB_REPO"])

ACCOUNT_READS = {(), ("user",), ("rate_limit",), ("meta",)}

# First segments under a repository that are denied for every method, reads included.
REPO_DENIED = {
    "hooks",
    "keys",
    "collaborators",
    "invitations",
    "transfer",
    "environments",
    "rulesets",
    "rules",
    "pages",
    "secret-scanning",
    "dependabot",
    "codespaces",
    "interaction-limits",
    "dispatches",
    "forks",
    "generate",
}
ACTIONS_DENIED = {
    "secrets",
    "variables",
    "organization-secrets",
    "organization-variables",
    "permissions",
    "runners",
    "oidc",
}

# Writes under a repository, as (method, pattern) with ``*`` matching one segment.
REPO_WRITES = [
    (method, tuple(pattern.split("/")))
    for method, pattern in [
        ("POST", "pulls"),
        ("PATCH", "pulls/*"),
        ("PUT", "pulls/*/merge"),
        ("PUT", "pulls/*/update-branch"),
        ("POST", "pulls/*/comments"),
        ("POST", "pulls/*/comments/*/replies"),
        ("PATCH", "pulls/comments/*"),
        ("DELETE", "pulls/comments/*"),
        ("POST", "pulls/comments/*/reactions"),
        ("DELETE", "pulls/comments/*/reactions/*"),
        ("POST", "pulls/*/reviews"),
        ("PUT", "pulls/*/reviews/*"),
        ("DELETE", "pulls/*/reviews/*"),
        ("POST", "pulls/*/reviews/*/events"),
        ("PUT", "pulls/*/reviews/*/dismissals"),
        ("POST", "pulls/*/requested_reviewers"),
        ("DELETE", "pulls/*/requested_reviewers"),
        ("POST", "issues"),
        ("PATCH", "issues/*"),
        ("POST", "issues/*/comments"),
        ("PATCH", "issues/comments/*"),
        ("DELETE", "issues/comments/*"),
        ("POST", "issues/comments/*/reactions"),
        ("DELETE", "issues/comments/*/reactions/*"),
        ("POST", "issues/*/reactions"),
        ("DELETE", "issues/*/reactions/*"),
        ("POST", "issues/*/labels"),
        ("PUT", "issues/*/labels"),
        ("DELETE", "issues/*/labels"),
        ("DELETE", "issues/*/labels/*"),
        ("POST", "issues/*/assignees"),
        ("DELETE", "issues/*/assignees"),
        ("PUT", "issues/*/lock"),
        ("DELETE", "issues/*/lock"),
        ("POST", "commits/*/comments"),
        ("PATCH", "comments/*"),
        ("DELETE", "comments/*"),
        ("POST", "labels"),
        ("PATCH", "labels/*"),
        ("DELETE", "labels/*"),
        ("POST", "releases"),
        ("POST", "releases/generate-notes"),
        ("PATCH", "releases/*"),
        ("DELETE", "releases/*"),
        ("PATCH", "releases/assets/*"),
        ("DELETE", "releases/assets/*"),
        ("POST", "actions/runs/*/rerun"),
        ("POST", "actions/runs/*/rerun-failed-jobs"),
        ("POST", "actions/runs/*/cancel"),
        ("POST", "actions/jobs/*/rerun"),
    ]
]
UPLOAD_WRITES = [("POST", ("releases", "*", "assets"))]

METHOD_OVERRIDE_HEADERS = ("x-http-method-override", "x-http-method", "x-method-override")


def _rest_denied() -> http.Response:
    return http.Response.make(
        403,
        json.dumps(
            {
                "message": "Resource not accessible by personal access token",
                "documentation_url": "https://docs.github.com/rest",
                "status": "403",
            }
        ),
        {"Content-Type": "application/json; charset=utf-8"},
    )


def _graphql_denied() -> http.Response:
    return http.Response.make(
        200,
        json.dumps(
            {
                "data": None,
                "errors": [{"type": "FORBIDDEN", "message": "Resource not accessible by personal access token"}],
            }
        ),
        {"Content-Type": "application/json; charset=utf-8"},
    )


def _git_not_found() -> http.Response:
    return http.Response.make(404, "Repository not found.\n", {"Content-Type": "text/plain"})


def _git_push_denied(owner: str, name: str) -> http.Response:
    return http.Response.make(403, f"Permission to {owner}/{name}.git denied.\n", {"Content-Type": "text/plain"})


def _authenticated(flow: http.HTTPFlow) -> bool:
    for value in flow.request.headers.get_all("Authorization"):
        if value.startswith("Basic "):
            value = base64.b64decode(value[len("Basic ") :]).decode()
        if PLACEHOLDER in value:
            return True
    return False


def _segments(path: str) -> tuple[str, ...] | None:
    """The decoded, lowercased path segments, or None for a path GitHub might route differently from how it reads here."""
    decoded = unquote(path.split("?", 1)[0], errors="strict")
    if not decoded.startswith("/") or re.search(r"[%\\\x00-\x1f\x7f]", decoded):
        return None
    if decoded == "/":
        return ()
    segments = tuple(decoded[1:].lower().split("/"))
    if any(s in ("", ".", "..") for s in segments):
        return None
    return segments


def _matches(pattern: tuple[str, ...], segments: tuple[str, ...]) -> bool:
    return len(pattern) == len(segments) and all(p in ("*", s) for p, s in zip(pattern, segments))


def _split_repo(segments: tuple[str, ...]) -> tuple[bool, tuple[str, ...]] | None:
    """For a /repos/<owner>/<name>/… or /repositories/<id>/… path: whether it is the
    assigned repository, and the segments after it."""
    if len(segments) >= 3 and segments[0] == "repos":
        return f"{segments[1]}/{segments[2]}" in REPO_NAMES, segments[3:]
    if len(segments) >= 2 and segments[0] == "repositories":
        return segments[1] == REPO_ID, segments[2:]
    return None


def _repo_operation_allowed(method: str, rest: tuple[str, ...]) -> bool:
    if rest and rest[0] in REPO_DENIED:
        return False
    if rest[:1] == ("actions",) and rest[1:2] and rest[1] in ACTIONS_DENIED:
        return False
    if rest[:1] == ("branches",) and "protection" in rest:
        return False
    if method == "GET":
        return True
    return any(method == m and _matches(p, rest) for m, p in REPO_WRITES)


def _api(method: str, segments: tuple[str, ...]) -> http.Response | None:
    if method == "GET" and segments in ACCOUNT_READS:
        return None
    repo = _split_repo(segments)
    if repo is None:
        return _rest_denied()
    assigned, rest = repo
    if assigned and _repo_operation_allowed(method, rest):
        return None
    return _rest_denied()


def _uploads(method: str, segments: tuple[str, ...]) -> http.Response | None:
    repo = _split_repo(segments)
    if repo is None:
        return _rest_denied()
    assigned, rest = repo
    if assigned and any(method == m and _matches(p, rest) for m, p in UPLOAD_WRITES):
        return None
    return _rest_denied()


def _git(flow: http.HTTPFlow, method: str, segments: tuple[str, ...]) -> http.Response | None:
    if len(segments) < 3:
        return _git_not_found()
    owner, name, rest = segments[0], segments[1].removesuffix(".git"), segments[2:]
    query = parse_qs(flow.request.path.partition("?")[2])
    receive = rest == ("git-receive-pack",) or (
        rest == ("info", "refs") and query.get("service") == ["git-receive-pack"]
    )
    allowed = (
        (method == "GET" and rest == ("info", "refs") and query.get("service") in (["git-upload-pack"], ["git-receive-pack"]))
        or (method == "POST" and rest in (("git-upload-pack",), ("git-receive-pack",)))
        or (method == "POST" and rest == ("info", "lfs", "objects", "batch"))
        or rest[:3] == ("info", "lfs", "locks")
    )
    if not allowed:
        return _git_not_found()
    if f"{owner}/{name}" in REPO_NAMES:
        return None
    return _git_push_denied(owner, name) if receive else _git_not_found()


def _check(flow: http.HTTPFlow) -> http.Response | None:
    request = flow.request
    host = request.host
    method = "GET" if request.method == "HEAD" else request.method
    segments = _segments(request.path)
    if host == GIT_HOST:
        return _git_not_found() if segments is None else _git(flow, method, segments)
    if segments is None:
        return _rest_denied()
    if segments[:1] == ("graphql",):
        return _graphql_denied()
    if (
        any(h in request.headers for h in METHOD_OVERRIDE_HEADERS)
        or "_method" in parse_qs(request.path.partition("?")[2])
        or request.headers.get("Content-Type", "").lower().startswith(("application/x-www-form-urlencoded", "multipart/"))
    ):
        return _rest_denied()
    if host == API_HOST:
        return _api(method, segments)
    return _uploads(method, segments)


def requestheaders(flow: http.HTTPFlow) -> None:
    if flow.request.scheme != "https" or flow.request.host not in (API_HOST, UPLOADS_HOST, GIT_HOST):
        return
    if not _authenticated(flow):
        return
    denial = _check(flow)
    if denial is not None:
        flow.response = denial
        return
    flow.metadata[APPROVED] = True
    # Approval rests on headers alone, so bodies (push packs, release assets) stream through.
    flow.request.stream = True

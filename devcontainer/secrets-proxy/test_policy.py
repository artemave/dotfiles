"""Policy tests: requests as mitmproxy parses them, run through both addons in proxy order.

Run with mitmproxy and pytest installed: ``GITHUB_REPO= pytest devcontainer/secrets-proxy``.
"""

import base64
import json

import pytest
from mitmproxy.test import tflow, tutils

import github_policy
import inject

TOKEN = "ghp_realtoken"


@pytest.fixture(autouse=True)
def assigned_repo(monkeypatch, tmp_path):
    monkeypatch.setattr(github_policy, "REPO_NAMES", {"acme/allowed", "acme/allowed-old"})
    monkeypatch.setattr(github_policy, "REPO_ID", "1001")
    (tmp_path / "github").write_text(TOKEN + "\n")
    monkeypatch.setattr(inject, "SECRETS_DIR", tmp_path)


def send(method, host, path, auth="token proxy-secret-github", headers=(), host_header=None, sni=None):
    request = tutils.treq(
        method=method.encode(),
        scheme=b"https",
        host=host,
        port=443,
        authority=b"",
        path=path.encode(),
        headers=[(b"Host", (host_header or host).encode()), *((k.encode(), v.encode()) for k, v in headers)],
        content=b"",
    )
    if auth:
        request.headers["Authorization"] = auth
    flow = tflow.tflow(req=request)
    flow.client_conn.sni = sni or host
    github_policy.requestheaders(flow)
    inject.requestheaders(flow)
    return flow


def forwarded_with_token(flow):
    assert flow.response is None, flow.response and flow.response.text
    assert TOKEN in _auth(flow)
    return True


def _auth(flow):
    value = flow.request.headers["Authorization"]
    return base64.b64decode(value[6:]).decode() if value.startswith("Basic ") else value


def rest_denied(flow):
    assert flow.response.status_code == 403
    assert flow.response.json() == {
        "message": "Resource not accessible by personal access token",
        "documentation_url": "https://docs.github.com/rest",
        "status": "403",
    }
    return True


def basic(user, password):
    return "Basic " + base64.b64encode(f"{user}:{password}".encode()).decode()


GIT_AUTH = basic("x-access-token", "proxy-secret-github")


@pytest.mark.parametrize(
    "method,path",
    [
        ("GET", "/repos/acme/allowed"),
        ("GET", "/repos/ACME/Allowed/pulls/3"),
        ("GET", "/repos/acme/allowed/pulls/3/comments?per_page=100"),
        ("GET", "/repos/acme/allowed/contents/src%2Fmain.py"),
        ("GET", "/repos/acme/allowed-old/issues"),
        ("HEAD", "/repos/acme/allowed/actions/runs"),
        ("GET", "/repositories/1001/pulls"),
        ("POST", "/repos/acme/allowed/pulls"),
        ("PATCH", "/repos/acme/allowed/pulls/3"),
        ("PUT", "/repos/acme/allowed/pulls/3/merge"),
        ("POST", "/repos/acme/allowed/pulls/3/reviews"),
        ("POST", "/repos/acme/allowed/pulls/3/reviews/9/events"),
        ("POST", "/repos/acme/allowed/pulls/3/comments/5/replies"),
        ("POST", "/repos/acme/allowed/issues"),
        ("POST", "/repos/acme/allowed/issues/3/comments"),
        ("PATCH", "/repos/acme/allowed/issues/comments/77"),
        ("DELETE", "/repos/acme/allowed/issues/3/labels/good%20first%20issue"),
        ("POST", "/repos/acme/allowed/labels"),
        ("POST", "/repos/acme/allowed/releases"),
        ("POST", "/repos/acme/allowed/actions/runs/42/rerun-failed-jobs"),
        ("POST", "/repos/acme/allowed/actions/runs/42/cancel"),
        ("POST", "/repositories/1001/issues"),
        ("GET", "/"),
        ("GET", "/user"),
        ("GET", "/rate_limit"),
    ],
)
def test_api_allowed(method, path):
    assert forwarded_with_token(send(method, "api.github.com", path))


@pytest.mark.parametrize(
    "method,path",
    [
        ("GET", "/repos/acme/forbidden"),
        ("GET", "/repos/acme/forbidden/pulls"),
        ("POST", "/repos/acme/forbidden/issues"),
        ("GET", "/repositories/1002"),
        ("GET", "/repositories/1002/contents/README.md"),
        ("GET", "/repositories/01001/pulls"),
        ("GET", "/search/code?q=secret"),
        ("GET", "/search/repositories?q=user:acme"),
        ("GET", "/user/repos"),
        ("GET", "/orgs/acme/repos"),
        ("GET", "/users/acme/repos"),
        ("GET", "/notifications"),
        ("GET", "/gists"),
        ("POST", "/gists"),
        ("POST", "/user/repos"),
        ("GET", "/user/keys"),
        ("PATCH", "/repos/acme/allowed"),
        ("DELETE", "/repos/acme/allowed"),
        ("POST", "/repos/acme/allowed/transfer"),
        ("GET", "/repos/acme/allowed/hooks"),
        ("GET", "/repos/acme/allowed/HOOKS"),
        ("POST", "/repos/acme/allowed/hooks"),
        ("POST", "/repos/acme/allowed/keys"),
        ("PUT", "/repos/acme/allowed/collaborators/mallory"),
        ("GET", "/repos/acme/allowed/actions/secrets"),
        ("PUT", "/repos/acme/allowed/actions/secrets/X"),
        ("GET", "/repos/acme/allowed/actions/variables"),
        ("GET", "/repos/acme/allowed/environments/prod/secrets"),
        ("GET", "/repos/acme/allowed/dependabot/secrets"),
        ("PUT", "/repos/acme/allowed/branches/main/protection"),
        ("GET", "/repos/acme/allowed/branches/main/protection"),
        ("POST", "/repos/acme/allowed/rulesets"),
        ("POST", "/repos/acme/allowed/pages"),
        ("PUT", "/repos/acme/allowed/actions/permissions"),
        ("POST", "/repos/acme/allowed/actions/runners/registration-token"),
        ("GET", "/repos/acme/allowed/secret-scanning/alerts"),
        ("POST", "/repos/acme/allowed/dispatches"),
        ("POST", "/repos/acme/allowed/actions/workflows/ci.yml/dispatches"),
        ("POST", "/repos/acme/allowed/forks"),
        ("PUT", "/repos/acme/allowed/contents/x.txt"),
        ("DELETE", "/repos/acme/allowed/git/refs/heads/main"),
        ("OPTIONS", "/repos/acme/allowed"),
        ("GET", "/repos/acme/allowed/../forbidden"),
        ("GET", "/repos/acme/allowed/%2E%2E/forbidden"),
        ("GET", "/repos/acme/allowed/issues/..%2F..%2F..%2Fforbidden%2Fhooks"),
        ("GET", "/repos/acme%2Fforbidden/x/pulls"),
        ("GET", "/repos//acme/allowed"),
        ("GET", "/repos/acme/allowed/contents/%252e%252e"),
        ("GET", "/repos/acme/allowed\\..\\forbidden"),
        ("GET", "/repos/acme/allowed/%0a"),
    ],
)
def test_api_denied(method, path):
    flow = send(method, "api.github.com", path)
    assert rest_denied(flow)
    assert "proxy-secret-github" in flow.request.headers["Authorization"]


@pytest.mark.parametrize(
    "headers",
    [
        [("X-HTTP-Method-Override", "DELETE")],
        [("X-Method-Override", "PATCH")],
        [("Content-Type", "application/x-www-form-urlencoded")],
        [("Content-Type", "multipart/form-data; boundary=x")],
        [("Content-Type", "Application/X-WWW-Form-Urlencoded")],
    ],
)
def test_method_override_denied(headers):
    assert rest_denied(send("POST", "api.github.com", "/repos/acme/allowed/issues", headers=headers))


def test_method_override_query_denied():
    assert rest_denied(send("POST", "api.github.com", "/repos/acme/allowed/issues?_method=DELETE"))


@pytest.mark.parametrize(
    "method,path",
    [("POST", "/graphql"), ("GET", "/graphql?query=%7Bviewer%7Blogin%7D%7D"), ("POST", "/GraphQL"), ("POST", "/graphql/")],
)
def test_graphql_denied(method, path):
    flow = send(method, "api.github.com", path)
    if path.endswith("/"):
        assert rest_denied(flow)
        return
    assert flow.response.status_code == 200
    assert flow.response.json() == {
        "data": None,
        "errors": [{"type": "FORBIDDEN", "message": "Resource not accessible by personal access token"}],
    }


def test_uploads():
    assert forwarded_with_token(send("POST", "uploads.github.com", "/repos/acme/allowed/releases/7/assets?name=a.zip"))
    assert forwarded_with_token(send("POST", "uploads.github.com", "/repositories/1001/releases/7/assets?name=a.zip"))
    assert rest_denied(send("POST", "uploads.github.com", "/repos/acme/forbidden/releases/7/assets?name=a.zip"))
    assert rest_denied(send("POST", "uploads.github.com", "/repos/acme/allowed/issues"))


@pytest.mark.parametrize(
    "method,path",
    [
        ("GET", "/acme/allowed.git/info/refs?service=git-upload-pack"),
        ("GET", "/acme/allowed/info/refs?service=git-upload-pack"),
        ("GET", "/Acme/Allowed.git/info/refs?service=git-receive-pack"),
        ("POST", "/acme/allowed.git/git-upload-pack"),
        ("POST", "/acme/allowed.git/git-receive-pack"),
        ("POST", "/acme/allowed.git/info/lfs/objects/batch"),
        ("POST", "/acme/allowed.git/info/lfs/locks/verify"),
        ("GET", "/acme/allowed-old.git/info/refs?service=git-upload-pack"),
    ],
)
def test_git_allowed(method, path):
    flow = send(method, "github.com", path, auth=GIT_AUTH)
    assert forwarded_with_token(flow)
    assert flow.request.stream


@pytest.mark.parametrize(
    "method,path",
    [
        ("GET", "/acme/forbidden.git/info/refs?service=git-upload-pack"),
        ("POST", "/acme/forbidden.git/git-upload-pack"),
        ("POST", "/acme/forbidden.git/info/lfs/objects/batch"),
        ("GET", "/acme/allowed.wiki.git/info/refs?service=git-upload-pack"),
        ("GET", "/acme/allowed.git/info/refs"),
        ("GET", "/acme/allowed.git/HEAD"),
        ("GET", "/acme/allowed/archive/main.zip"),
        ("GET", "/acme/allowed/../forbidden.git/info/refs?service=git-upload-pack"),
        ("GET", "/settings/tokens"),
        ("POST", "/api/graphql"),
    ],
)
def test_git_read_denied(method, path):
    flow = send(method, "github.com", path, auth=GIT_AUTH)
    assert flow.response.status_code == 404
    assert flow.response.text == "Repository not found.\n"


@pytest.mark.parametrize(
    "method,path",
    [
        ("GET", "/acme/forbidden.git/info/refs?service=git-receive-pack"),
        ("POST", "/acme/forbidden.git/git-receive-pack"),
    ],
)
def test_git_push_denied(method, path):
    flow = send(method, "github.com", path, auth=GIT_AUTH)
    assert flow.response.status_code == 403
    assert flow.response.text == "Permission to acme/forbidden.git denied.\n"


def test_unauthenticated_requests_pass_untouched():
    for host, path in [("api.github.com", "/repos/acme/forbidden"), ("github.com", "/acme/forbidden.git/info/refs"), ("api.github.com", "/graphql")]:
        flow = send("GET", host, path, auth=None)
        assert flow.response is None
        assert "Authorization" not in flow.request.headers


def test_placeholder_outside_authorization_is_not_substituted():
    flow = send("GET", "api.github.com", "/repos/acme/forbidden", auth=None, headers=[("X-Token", "proxy-secret-github")])
    assert flow.response is None
    assert flow.request.headers["X-Token"] == "proxy-secret-github"


@pytest.mark.parametrize(
    "kwargs",
    [
        {"host_header": "github.com"},
        {"sni": "github.com"},
        {"host_header": "evil.example"},
    ],
)
def test_spoofed_destination_gets_no_token(kwargs):
    flow = send("GET", "api.github.com", "/repos/acme/allowed", **kwargs)
    assert flow.response.status_code == 421
    assert TOKEN not in flow.request.headers["Authorization"]


def test_host_header_alone_does_not_pick_the_secret():
    flow = send("GET", "203.0.113.7", "/repos/acme/allowed", host_header="api.github.com", sni="api.github.com")
    assert flow.response is None
    assert flow.request.headers["Authorization"] == "token proxy-secret-github"


def test_unapproved_policed_request_gets_no_token():
    request = tutils.treq(scheme=b"https", host="api.github.com", port=443, authority=b"", path=b"/user", headers=[(b"Host", b"api.github.com")])
    request.headers["Authorization"] = "token proxy-secret-github"
    flow = tflow.tflow(req=request)
    flow.client_conn.sni = "api.github.com"
    inject.requestheaders(flow)
    assert flow.response.status_code == 502
    assert TOKEN not in flow.request.headers["Authorization"]


def test_no_assigned_repo_denies_every_repo(monkeypatch):
    monkeypatch.setattr(github_policy, "REPO_NAMES", set())
    monkeypatch.setattr(github_policy, "REPO_ID", None)
    assert rest_denied(send("GET", "api.github.com", "/repos/acme/allowed"))
    assert send("GET", "github.com", "/acme/allowed.git/info/refs?service=git-upload-pack", auth=GIT_AUTH).response.status_code == 404
    assert forwarded_with_token(send("GET", "api.github.com", "/user"))


def test_denial_bodies_are_json():
    assert json.loads(send("GET", "api.github.com", "/gists").response.content)["status"] == "403"

"""mitmproxy addon: swap placeholder secrets in the Authorization header for real ones.

The devcontainer only ever holds ``proxy-secret-<name>`` placeholders. Only
the hosts listed for a secret are TLS-intercepted; every other connection is
tunnelled untouched, so a placeholder sent anywhere else stays a placeholder
and clients need to trust the proxy's CA for these hosts only.
"""

import base64
from pathlib import Path

from mitmproxy import http, tls
from mitmproxy.net.http import url

SECRETS_DIR = Path("/run/secrets")

# A leading dot matches any subdomain.
HOSTS = {
    "openai": ("api.openai.com",),
    "claude": ("api.anthropic.com",),
    "github": ("api.github.com", "uploads.github.com", "github.com"),
    "atlassian": (".atlassian.net", "api.atlassian.com"),
}

# Swapped only on requests that the secret's policy addon, loaded before this
# one, marked with ``flow.metadata["<name>-policy-approved"]``.
POLICED = {"github"}


def _secrets_for(host: str) -> list[str]:
    return [
        name
        for name, patterns in HOSTS.items()
        if any(host == p or (p.startswith(".") and host.endswith(p)) for p in patterns)
    ]


def tls_clienthello(data: tls.ClientHelloData) -> None:
    host = data.client_hello.sni or data.context.server.address[0]
    if not _secrets_for(host):
        data.ignore_connection = True


def _decoded(value: str) -> str:
    # git and acli put the token in the password half of Basic auth.
    if value.startswith("Basic "):
        return base64.b64decode(value[len("Basic ") :]).decode()
    return value


def _substitute(value: str, placeholder: str, secret: str) -> str:
    if value.startswith("Basic "):
        return "Basic " + base64.b64encode(_decoded(value).replace(placeholder, secret).encode()).decode()
    return value.replace(placeholder, secret)


def _refuse(flow: http.HTTPFlow, status: int, message: str) -> None:
    flow.request.stream = False
    flow.response = http.Response.make(status, f"secrets-proxy: {message}\n")


def requestheaders(flow: http.HTTPFlow) -> None:
    if flow.request.scheme != "https" or flow.response is not None:
        return
    # request.host is where the request goes; the Host header and SNI are only
    # what the client claims, so a secret is sent only when all three agree.
    host = flow.request.host
    values = flow.request.headers.get_all("Authorization")
    for name in _secrets_for(host):
        placeholder = f"proxy-secret-{name}"
        if not any(placeholder in _decoded(v) for v in values):
            continue
        host_header = flow.request.host_header
        if host_header is None or url.parse_authority(host_header, check=False)[0] != host or flow.client_conn.sni != host:
            _refuse(flow, 421, f"Host header and TLS SNI must both name {host}")
            return
        if name in POLICED and not flow.metadata.get(f"{name}-policy-approved"):
            _refuse(flow, 502, f"no '{name}' policy approved this request")
            return
        secret_file = SECRETS_DIR / name
        if not secret_file.exists():
            _refuse(flow, 502, f"no '{name}' secret on the host (see refresh-secrets)")
            return
        secret = secret_file.read_text().strip()
        flow.request.headers.set_all("Authorization", [_substitute(v, placeholder, secret) for v in values])
        values = flow.request.headers.get_all("Authorization")

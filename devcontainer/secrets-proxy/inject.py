"""mitmproxy addon: swap placeholder secrets in request headers for real ones.

The devcontainer only ever holds ``proxy-secret-<name>`` placeholders. Only
the hosts listed for a secret are TLS-intercepted; every other connection is
tunnelled untouched, so a placeholder sent anywhere else stays a placeholder
and clients need to trust the proxy's CA for these hosts only.
"""

import base64
from pathlib import Path

from mitmproxy import http, tls

SECRETS_DIR = Path("/run/secrets")

# A leading dot matches any subdomain.
HOSTS = {
    "openai": ("api.openai.com",),
    "claude": ("api.anthropic.com",),
    "github": ("api.github.com", "uploads.github.com", "github.com"),
    "atlassian": (".atlassian.net", "api.atlassian.com"),
}


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


def request(flow: http.HTTPFlow) -> None:
    if flow.request.scheme != "https":
        return
    for name in _secrets_for(flow.request.pretty_host):
        placeholder = f"proxy-secret-{name}"
        for key in set(flow.request.headers.keys()):
            values = flow.request.headers.get_all(key)
            if not any(placeholder in _decoded(v) for v in values):
                continue
            secret_file = SECRETS_DIR / name
            if not secret_file.exists():
                flow.response = http.Response.make(
                    502, f"secrets-proxy: no '{name}' secret on the host (see refresh-secrets)\n"
                )
                return
            secret = secret_file.read_text().strip()
            flow.request.headers.set_all(key, [_substitute(v, placeholder, secret) for v in values])

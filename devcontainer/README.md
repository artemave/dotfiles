# devcontainer

## GitHub access

A devcontainer never holds the GitHub token. It sends the `proxy-secret-github` placeholder, and its own `secrets-proxy` (mitmproxy) swaps in the host's `gh auth token` only for requests that `secrets-proxy/github_policy.py` approves. The policy allows exactly one repository: the one the checkout's `origin` points at on the host when `up` (or a `dc up` wrapper) runs, shown as `secrets-proxy: github access → owner/name`. A checkout without a GitHub `origin` gets none. Changing `origin` takes effect on the next `up`.

Requests without the placeholder pass through untouched, so public clones and public API reads work for any repository.

For requests with the placeholder:

| Surface | Allowed | Denied with |
| --- | --- | --- |
| Git over HTTPS (`github.com`) | `info/refs`, `git-upload-pack`, `git-receive-pack` and LFS batch/locks for the assigned repo | `404 Repository not found.`, or `403 Permission to owner/repo.git denied.` for a push |
| REST (`api.github.com`) | Reads under `/repos/<owner>/<name>` and `/repositories/<id>`; writes to pulls, issues, comments, reviews, labels, releases and Actions run reruns/cancels; `GET /`, `/user`, `/rate_limit`, `/meta` | `403 Resource not accessible by personal access token` |
| Release uploads (`uploads.github.com`) | Assets for the assigned repo's releases | REST 403 |
| GraphQL | nothing | `200` with a `FORBIDDEN` error |

Even for the assigned repository, every method is denied on hooks, deploy keys, collaborators, invitations, transfer, environments, rulesets, branch protection, Pages, secrets and variables (Actions, Dependabot, Codespaces), secret-scanning alerts, Actions permissions/runners/OIDC, repository dispatches and forks; repository settings (`PATCH`) and deletion are refused too.

The token's own scopes still apply on top. Without the `workflow` scope GitHub rejects pushes that touch `.github/workflows/*`; with it, a pushed workflow could read the repository's Actions secrets. Check with `gh auth status` and drop it with `gh auth refresh --remove-scopes workflow`.

### Unsupported

Everything `gh` does over GraphQL: `gh pr …` (except `gh pr diff`), `gh issue …`, `gh repo view`, draft → ready, auto-merge, resolving review threads, Projects v2 and Discussions. Triggering workflows (`gh workflow run`) and deleting branches through the API are denied. Agents in the container get `agent-instructions.md` (as `/etc/claude-code/CLAUDE.md` and Codex `developer_instructions`) with the `gh api` equivalents.

The container has no SSH agent; `git@github.com:` and `ssh://git@github.com/` remotes are rewritten to HTTPS.

### Host git on shared checkouts

The workspace `.git` is writable from inside the container, so it can carry hooks or config (`core.fsmonitor`, `credential.helper`, `url.*.insteadOf`, filter drivers, aliases, …) that would run with the host's credentials. `up` records each checkout with `register-checkout`, and `bin/git` (ahead of `/usr/bin/git` on the host `PATH`) runs git there with hooks disabled, refusing to run at all while `.git/config` sets anything beyond repository, remote and branch settings. It names the offending keys; inspect and remove them with `/usr/bin/git config --file <checkout>/.git/config --unset <key>`, or use git inside the container.

### Tests

```sh
GITHUB_REPO= pytest devcontainer/secrets-proxy   # needs mitmproxy and pytest
```

#!/usr/bin/env bash
set -euo pipefail

# Create a container-local Claude config from the host file (mounted read-only).
# Strip only the most host-specific fields while keeping auth/session state.
if [[ -f /home/dev/.claude.json.host ]]; then
  jq 'del(.projects, .githubRepoPaths)' /home/dev/.claude.json.host > /home/dev/.claude.json.tmp
  mv /home/dev/.claude.json.tmp /home/dev/.claude.json
  chmod 600 /home/dev/.claude.json
fi

if [[ -f /home/dev/.claude/.credentials.json.host && ! -f /home/dev/.claude/.credentials.json ]]; then
  mkdir -p /home/dev/.claude
  cp /home/dev/.claude/.credentials.json.host /home/dev/.claude/.credentials.json
  chmod 600 /home/dev/.claude/.credentials.json
fi

for f in ./.exrc ./.nvim.lua ./.nvimrc; do
  [[ -f $f ]] && nvim --headless --clean "$f" -c "trust" -c "qa"
done

# Signal the container as ready *after* all pre-exec setup completes. Compose
# healthcheck reads this file; `podman-compose up --wait` blocks on healthy.
# Without this, `podman-compose up -d` returns as soon as PID 1 is alive —
# concurrent with this entrypoint — and downstream consumers (hop's editor
# launch, etc.) can race ahead before the trust file / claude config / etc.
# are in place.
touch /tmp/devcontainer-ready

exec "$@"

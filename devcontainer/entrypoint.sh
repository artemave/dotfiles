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

# The host profile is in use by the host Firefox; copy it once (minus site storage and lock files) instead of sharing it.
# tar exits 1 when files change mid-read, which a live profile always does.
host_profile=(/home/dev/.firefox.host/*.dev-edition-default)
if [[ -d ${host_profile[0]} && ! -d /home/dev/.mozilla/firefox/dev-edition-default ]]; then
  mkdir -p /home/dev/.mozilla/firefox/dev-edition-default
  { tar -C "${host_profile[0]}" --exclude=./storage --exclude=./lock --exclude=./.parentlock -cf - . || [[ $? -eq 1 ]]; } \
    | tar -C /home/dev/.mozilla/firefox/dev-edition-default -xf -
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

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

exec "$@"

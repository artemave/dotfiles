#!/bin/bash

# Tracks sway window focus events and maintains a history file.
# Each line is a container ID, most recent first.

HISTORY_FILE=/tmp/sway_focus_history

: > "$HISTORY_FILE"

swaymsg -m -t subscribe '["window"]' | while read -r line; do
  con_id=$(echo "$line" | jq -r 'select(.change == "focus") | .container.id // empty' 2>/dev/null)
  [ -z "$con_id" ] && continue

  head_id=$(head -1 "$HISTORY_FILE" 2>/dev/null)
  if [ "$con_id" != "$head_id" ]; then
    { echo "$con_id"; head -19 "$HISTORY_FILE" 2>/dev/null; } > "${HISTORY_FILE}.tmp"
    mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
  fi
done

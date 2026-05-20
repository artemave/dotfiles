#!/bin/bash

# Tracks sway window focus events and maintains a history file.
# Each line is a container ID, most recent first.
# Debounce: only records a window if it was focused for at least 1 second,
# so rapid cycling (left, left, left) doesn't pollute history.

PIDFILE=/tmp/sway_focus_history_daemon.pid

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  kill "$(cat "$PIDFILE")"
fi
echo $$ > "$PIDFILE"

HISTORY_FILE=/tmp/sway_focus_history

: > "$HISTORY_FILE"

last_con_id=""
last_time=0

record_focus() {
  local con_id="$1"
  head_id=$(head -1 "$HISTORY_FILE" 2>/dev/null)
  if [ "$con_id" != "$head_id" ]; then
    { echo "$con_id"; head -19 "$HISTORY_FILE" 2>/dev/null; } > "${HISTORY_FILE}.tmp"
    mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
  fi
}

swaymsg -m -t subscribe '["window"]' | while read -r line; do
  con_id=$(echo "$line" | jq -r 'select(.change == "focus") | .container.id // empty' 2>/dev/null)
  [ -z "$con_id" ] && continue

  now=$(date +%s)

  if [ -n "$last_con_id" ] && [ $((now - last_time)) -ge 1 ]; then
    record_focus "$last_con_id"
  fi

  last_con_id="$con_id"
  last_time=$now
done

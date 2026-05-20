#!/bin/bash

HISTORY_FILE=/tmp/sway_focus_history

# Check for urgent windows first
urgent=$(swaymsg -t get_tree | jq -r '[.. | select(.urgent? == true and .pid? > 0)] | .[0].id // empty')

if [ -n "$urgent" ]; then
  swaymsg "[con_id=$urgent]" focus
  exit 0
fi

# Get all current window IDs for validation
current_ids=$(swaymsg -t get_tree | jq -r '[.. | select(.pid? > 0) | .id] | .[]')
focused_id=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true and .pid? > 0) | .id')

# Record current window immediately so it's in history even if the daemon's
# debounce timer hasn't fired yet
if [ -n "$focused_id" ]; then
  head_id=$(head -1 "$HISTORY_FILE" 2>/dev/null)
  if [ "$focused_id" != "$head_id" ]; then
    { echo "$focused_id"; head -19 "$HISTORY_FILE" 2>/dev/null; } > "${HISTORY_FILE}.tmp"
    mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
  fi
fi

# Walk focus history, skip the current window, find the first ID that still exists
while read -r con_id; do
  [ "$con_id" = "$focused_id" ] && continue
  if echo "$current_ids" | grep -qx "$con_id"; then
    swaymsg "[con_id=$con_id]" focus
    exit 0
  fi
done < "$HISTORY_FILE"

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

# Walk focus history, skip the current window, find the first ID that still exists
while read -r con_id; do
  [ "$con_id" = "$focused_id" ] && continue
  if echo "$current_ids" | grep -qx "$con_id"; then
    swaymsg "[con_id=$con_id]" focus
    exit 0
  fi
done < "$HISTORY_FILE"

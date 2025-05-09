#!/usr/bin/env bash

if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
  swaymsg -t get_inputs | jq -r '.[] | select(.type == "keyboard") | .xkb_active_layout_name[:2]' | head -n1
else
  $SCRIPT_DIR/kbdd_layout
fi

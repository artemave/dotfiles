#!/bin/bash

# Kill existing swaybg processes
pkill swaybg

# Set random wallpaper on all connected outputs
for output in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
  IMG=$(find ~/Pictures/Wallpaper -type f | shuf -n 1)
  swaybg -o "$output" -i "$IMG" -m fill &
done

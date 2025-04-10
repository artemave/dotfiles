#!/usr/bin/env bash

scale=$1

# Original position values
original_x=920
original_y=2160

# Compute scaled positions
new_x=$(echo "$original_x / $scale" | bc)
new_y=$(echo "$original_y / $scale" | bc)

# Apply to Sway
swaymsg "output eDP-1 pos $new_x $new_y"

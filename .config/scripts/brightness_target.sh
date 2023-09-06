#!/bin/bash

function brightness_target() {
  res='amdgpu_bl1'
  r="([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)"

  cursor_x=$(xdotool getmouselocation --shell | grep 'X=' | awk -F 'X=' '{print $2}')
  cursor_y=$(xdotool getmouselocation --shell | grep 'Y=' | awk -F 'Y=' '{print $2}')

  screen_infos=$(xrandr | grep -E "$r")

  while read -r line; do
    screen_name=$(echo "$line" | cut -d ' ' -f1)

    if [[ $line =~ $r ]]; then
      width="${BASH_REMATCH[1]}"
      height="${BASH_REMATCH[2]}"
      x_offset="${BASH_REMATCH[3]}"
      y_offset="${BASH_REMATCH[4]}"

      if [[ $cursor_x -ge $x_offset && $cursor_x -le $(($x_offset + $width)) && $cursor_y -ge $y_offset && $cursor_y -le $(($y_offset + $height)) ]]; then
        if [[ 'eDP' != "$screen_name" ]]; then
          res='ddcci12'
        fi
      fi
    fi
  done <<< "$screen_infos"

  echo "$res"
}

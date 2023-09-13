#!/bin/bash

function brightness_target() {
  res=eDP
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
        res="$screen_name"
      fi
    fi
  done <<< $screen_infos

  echo $res
}

t=$(brightness_target)

if [[ 'eDP' == $t ]]; then
  brightnessctl s $1
else
  if [[ "$1" =~ ^\+ ]]; then
    sign=+
    value=${1:1:2}
  else
    sign=-
    value=${1:0:2}
  fi

  # 4 HDMI
  # 12 DP1
  # 13 DP2
  for i in 4 12 13; do
    ddcutil setvcp 10 $sign $value --bus $i --sleep-multiplier .1 &
  done

  wait
fi

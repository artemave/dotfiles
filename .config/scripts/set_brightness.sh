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

get_i2c_bus() {
  local display="$1"

  if [ -z "$display" ]; then
    echo "Error: Display name required" >&2
    return 1
  fi

  # Find the line with the display, then work backwards to find its I2C bus
  local context=$(ddcutil detect 2>/dev/null | grep -B5 -A1 "card[0-9]*-${display}$")
  local bus=$(echo "$context" | grep "I2C bus:" | tail -n1 | sed -n 's/.*i2c-\([0-9]\+\).*/\1/p')

  if [ -z "$bus" ]; then
    echo "Error: Display '$display' not found" >&2
    return 1
  fi

  echo "$bus"
}

if [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
  t=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
else
  t=$(brightness_target)
fi

if [[ $t =~ ^eDP ]]; then
  brightnessctl s $1
else
  if [[ "$1" =~ ^\+ ]]; then
    sign=+
    value=${1:1:2}
  else
    sign=-
    value=${1:0:2}
  fi

  # use ddcutil detect to get this magic numbers
  # Get the I2C bus number based on the display name
  case "$t" in
    HDMI*)
      bus=4
      ;;
    DP1)
      bus=12
      ;;
    DP2)
      bus=13
      ;;
    DP-1) # t14s gen6
      bus=14
      ;;
    DP-2) # t14s gen6
      bus=15
      ;;
    *) # Default case - try to get the bus for the current display
      bus=$(get_i2c_bus "$t")
      ;;
  esac

  ddcutil setvcp 10 $sign $value --bus $bus --sleep-multiplier .1 &

  wait
fi

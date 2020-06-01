#!/usr/bin/env bash

# Only exported variables can be used within the timer's command.
export PRIMARY_DISPLAY="$(xrandr | awk '/ primary/{print $1}')"

xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 300 'i3lock --color=4c7899 --ignore-empty-password --show-failed-attempts --nofork' '' \
  --timer 600 'systemctl suspend' ''

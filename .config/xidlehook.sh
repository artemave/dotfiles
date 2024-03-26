#!/usr/bin/env bash

~/projects/xidlehook/target/release/xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 300 'i3lock --color=4c7899 --show-failed-attempts --nofork' '' \
  --timer 600 'systemctl suspend' ''

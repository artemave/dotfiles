#!/bin/bash
# swayidle daemon: dims outputs after inactivity, suspends a shut lid, locks
# before sleep. Run as a plain script (not inline in sway config) so its
# 'command' arguments only ever pass through one shell — sway's own config
# parser plus swayidle's per-command sh -c was enough nested quoting to let
# `output * dpms off` glob-expand against $HOME and get rejected by sway.
#
# Restarted by the loop below rather than relied on to just keep running, so
# a crash (or anything else that kills it) doesn't leave the screen
# permanently awake until the next sway reload. Started with plain `exec`
# (see call site), so a reload can't stack a second copy of this loop.
while true; do
  swayidle \
    timeout 300  'swaymsg "output * dpms off"' \
    resume       'swaymsg "output * dpms on"' \
    timeout 300  '~/.config/scripts/suspend-if-lid-closed.sh' \
    before-sleep 'pgrep -x hyprlock > /dev/null || hyprlock'
  sleep 1
done

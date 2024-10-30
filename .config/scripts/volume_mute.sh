#!/usr/bin/env bash

pactl set-sink-mute 0 toggle

volume_status=$(pactl get-sink-mute 0 | cut -d ' ' -f2)
if [ 'no' == "$volume_status" ]; then
  brightnessctl -d platform::mute s 0
else
  brightnessctl -d platform::mute s 1
fi

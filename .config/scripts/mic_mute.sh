#!/usr/bin/env bash

pactl set-source-mute @DEFAULT_SOURCE@ toggle

mic_status=$(pactl get-source-mute @DEFAULT_SOURCE@ | cut -d ' ' -f2)
if [ 'no' == "$mic_status" ]; then
  brightnessctl -d platform::micmute s 0
else
  brightnessctl -d platform::micmute s 1
fi

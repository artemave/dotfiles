#!/usr/bin/env bash

# copied from https://github.com/Anachron/i3blocks/blob/master/blocks/brightness

curBrightness=$(xbacklight -get)
percent=$(echo "scale=0;${curBrightness}" | bc -l)
percent=${percent%.*}

echo "${percent}%"
echo "${percent}%"

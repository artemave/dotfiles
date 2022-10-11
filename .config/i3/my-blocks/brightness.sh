#!/usr/bin/env bash

# copied from https://github.com/Anachron/i3blocks/blob/master/blocks/brightness

curBrightness=$(brightnessctl get)
percent=$(echo "scale=0;($curBrightness*100/255)" | bc -l)
percent=${percent%.*}

echo "${percent}%"
echo "${percent}%"

#!/bin/bash

source "$(dirname "$0")/brightness_target.sh"

t=$(brightness_target)
brightnessctl -d "$t" s "$1"

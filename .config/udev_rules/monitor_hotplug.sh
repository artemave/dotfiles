#!/usr/bin/env bash

set -e
# set -x

# /etc/udev/rules.d/98-monitor-hotplug.rules
# KERNEL=="card0*", SUBSYSTEM=="drm", ACTION=="change", RUN+="/bin/bash /home/artem/.config/udev_rules/monitor_hotplug.sh"

displaynums=`ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##'`
displaynums=(${displaynums})
export DISPLAY=":${displaynums[0]}"

# from https://wiki.archlinux.org/index.php/Acpid#Laptop_Monitor_Power_Off
export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')

DP1=$(</sys/class/drm/card0/card0-DP-1/status )
DP2=$(</sys/class/drm/card0/card0-DP-2/status )
HDMI=$(</sys/class/drm/card0/card0-HDMI-A-1/status )

if [ "connected" == "$DP1" ]; then
  /usr/bin/xrandr --output DP1 --above eDP1 --auto
  feh --randomize --bg-fill ~/Pictures/Wallpaper/*
  /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "DP1 plugged in"
elif [ "connected" == "$DP2" ]; then
  /usr/bin/xrandr --output DP2 --above eDP1 --auto
  feh --randomize --bg-fill ~/Pictures/Wallpaper/*
  /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "DP2 plugged in"
elif [ "connected" == "$HDMI" ]; then
  /usr/bin/xrandr --output HDMI1 --above eDP1 --auto
  feh --randomize --bg-fill ~/Pictures/Wallpaper/*
  /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "HDMI plugged in"
else
  /usr/bin/xrandr --output DP1 --off
  /usr/bin/xrandr --output DP2 --off
  /usr/bin/xrandr --output HDMI1 --off
  feh --randomize --bg-fill ~/Pictures/Wallpaper/*
  /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "External monitor disconnected"
fi

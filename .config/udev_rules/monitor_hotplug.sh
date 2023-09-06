#!/usr/bin/env bash

set -e
# set -x

# For brightnessctl add these udev rules:
# /etc/udev/rules.d/90-brightnessctl.rules
# ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
# ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
# ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chgrp input /sys/class/leds/%k/brightness"
# ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chmod g+w /sys/class/leds/%k/brightness"

# /etc/udev/rules.d/98-monitor-hotplug.rules
# KERNEL=="card0*", SUBSYSTEM=="drm", ACTION=="change", RUN+="/bin/bash /home/artem/.config/udev_rules/monitor_hotplug.sh"

displaynums=`ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##'`
displaynums=(${displaynums})
export DISPLAY=":${displaynums[0]}"

# from https://wiki.archlinux.org/index.php/Acpid#Laptop_Monitor_Power_Off
export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n 's/.*-auth //; s/ -[^ ].*//; p')

/usr/local/bin/autorandr --change
feh --randomize --bg-fill /home/artem/Pictures/Wallpaper/*

# DP1=$(</sys/class/drm/card0/card0-DP-1/status )
# DP2=$(</sys/class/drm/card0/card0-DP-2/status )
# HDMI=$(</sys/class/drm/card0/card0-HDMI-A-1/status )

# if [ "connected" == "$DP1" ]; then
#   /usr/bin/xrandr --output DisplayPort-0 --above eDP --auto
#   feh --randomize --bg-fill /home/artem/Pictures/Wallpaper/*
#   /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "DP1 plugged in"
# elif [ "connected" == "$DP2" ]; then
#   /usr/bin/xrandr --output DisplayPort-1 --above eDP --auto
#   feh --randomize --bg-fill /home/artem/Pictures/Wallpaper/*
#   /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "DP2 plugged in"
# elif [ "connected" == "$HDMI" ]; then
#   /usr/bin/xrandr --output HDMI-A-0 --above eDP --auto
#   # https://itectec.com/ubuntu/ubuntu-is-it-possible-to-have-different-dpi-configurations-for-two-different-screens/
#   # /usr/bin/xrandr --output HDMI1 --scale 1.5x1.5 --pos 0x0 --fb 3840x3600 --auto
#   # /usr/bin/xrandr --output eDP1 --scale 1x1 --pos 0x2160 --auto
#   feh --randomize --bg-fill /home/artem/Pictures/Wallpaper/*
#   /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "HDMI plugged in"
# else
#   /usr/bin/xrandr --output DisplayPort-0 --off
#   /usr/bin/xrandr --output DisplayPort-1 --off
#   /usr/bin/xrandr --output HDMI-A-0 --off
#   feh --randomize --bg-fill /home/artem/Pictures/Wallpaper/*
#   /usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "External monitor disconnected"
# fi

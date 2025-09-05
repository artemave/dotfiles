#!/bin/bash
case $1 in
  pre)
    logger "[sleep-hook] Stopping network services to prevent suspend hang"

    systemctl stop wpa_supplicant systemd-resolved || true
    systemctl stop NetworkManager || true

    sleep 3

    if pgrep NetworkManager > /dev/null; then
      logger "[sleep-hook] NetworkManager did not stop cleanly. Killing it."
      nmcli radio wifi off
      sleep 1
      pkill -9 NetworkManager
      pkill -9 wpa_supplicant
    fi

    logger "[sleep-hook] Dumping D-state processes"
    ps -eo pid,state,cmd | awk '$2 ~ /^D$/ { print "[sleep-hook] D-state: " $0; system("readlink /proc/" $1 "/exe 2>/dev/null") }' | logger
    ;;
  post)
    logger "[sleep-hook] Restarting network services after resume"
    nmcli radio wifi on
    systemctl restart NetworkManager
    ;;
esac

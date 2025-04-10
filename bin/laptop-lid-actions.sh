#!/usr/bin/env bash

# rule is here: /etc/acpi/events/laptop-lid
#
# file contains:
#
# event=button/lid.*
# action=/usr/bin/systemctl suspend
#
# sudo systemctl restart acpid

# Below is some old craft and I don't remember what it's for

# action=/home/artem/bin/laptop-lid-actions.sh
# if grep -q closed /proc/acpi/button/lid/LID/state; then
#   # close action
#   bluetooth off
# # else
#   # # open action
#   # sleep 1
#   # bluetooth on
# fi

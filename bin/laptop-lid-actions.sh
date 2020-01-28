#!/bin/bash

# rule is here: /etc/acpi/events/laptop-lid
#
# file contains:
#
# event=button/lid.*
# action=/home/artem/bin/laptop-lid-actions.sh
#
# sudo service acpi restart

if grep -q closed /proc/acpi/button/lid/LID/state; then
  # close action
  bluetooth off
else
  # open action
  sleep 1
  bluetooth on
fi

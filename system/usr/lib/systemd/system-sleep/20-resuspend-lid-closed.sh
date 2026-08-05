#!/bin/bash
# Go back to sleep after a wake nobody asked for.
#
# What suspends this laptop is a lid close, and a lid closes only once. Anything
# that wakes the machine while the lid stays shut — unplugging the charger,
# unplugging the external screen, a USB4 hotplug, all of which are wake sources
# here — leaves it awake on the lock screen, on battery, indefinitely: logind
# gets no second lid event to act on, and swayidle only blanks the outputs.
#
# So a minute after every resume: if the lid is still shut and the screen is
# still locked, nobody is using this machine, and it goes back to sleep. The
# hyprlock check is what keeps a deliberate wake alive — wake the machine with
# an external keyboard while docked with the lid shut, and unlocking inside that
# minute cancels the re-suspend.
case $1 in
  post)
    # Deferred, because suspending from inside systemd-suspend.service's own
    # post hook would deadlock.
    systemd-run --on-active=60 "$0" resuspend-check
    ;;
  resuspend-check)
    # logind's view of the switch (SW_LID), rather than /proc/acpi/button/lid,
    # which on plenty of hardware only refreshes on its own schedule.
    lid=$(busctl get-property org.freedesktop.login1 /org/freedesktop/login1 \
            org.freedesktop.login1.Manager LidClosed)

    if [[ $lid == "b true" ]] && pgrep -x hyprlock > /dev/null; then
      logger "[sleep-hook] Awake for a minute with the lid shut and still locked. Suspending again."
      systemctl suspend
    fi
    ;;
esac

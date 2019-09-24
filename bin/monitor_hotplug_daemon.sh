#!/usr/bin/env sh

# copied from https://www.reddit.com/r/i3wm/comments/6txwcz/light_desktop_environment_to_use_i3_on/dlp9wtj?utm_source=share&utm_medium=web2x
#
# Credit to gurkensalat
# https://faq.i3wm.org/question/6421/conditional-monitor-cofiguration.1.html
#

#########################

statefile="`mktemp`"

quit() {
  rm "$statefile"
  exit 1
}
trap quit INT TERM

getstate() {
  state="`xrandr -q | wc -l`"
}
savestate() {
  echo "$state" > "$statefile"
}
getstate
savestate

xev -root -event randr | grep --line-buffered XRROutputChangeNotifyEvent | \
  while IFS= read -r line; do
    getstate
    old="`cat "$statefile"`"
    if [ "$state" -ne "$old" ]; then
      ~/.config/udev_rules/monitor_hotplug.sh
    fi
    savestate
  done

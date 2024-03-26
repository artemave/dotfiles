#!/usr/bin/bash
#
# Usage: gfm.sh FILE.md
#

gh api  \
 --method POST   \
 -H "Accept: application/vnd.github+json"   \
 -H "X-GitHub-Api-Version: 2022-11-28"   \
  /markdown   \
  -f text="$(cat $1)" > /tmp/gfm.html

xdg-open /tmp/gfm.html

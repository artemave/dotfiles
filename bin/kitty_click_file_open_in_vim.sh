#!/usr/bin/env bash

set -e

# notify-send --urgency=low -t 5000 "tmux -> vim" "pwd: $(pwd)"

if [ "$(uname)" == "Linux" ]; then
  tmux=tmux
else
  tmux=/usr/local/bin/tmux
fi

wd=$($tmux display-message -p -F "#{pane_current_path}" -t0)
cd $wd

IFS=: read file line <<< $1

if [[ ! -f "$file" ]]; then
  if [[ ! -f "./$file" ]]; then
    if command -v notify-send &> /dev/null; then
      notify-send --urgency=low -t 5000 "tmux -> vim" "File not found: $file"
    fi
  fi
else
  $tmux select-window -t vim
  $tmux send-keys Escape
  if [ -z "$line" ]; then
    $tmux send-keys ":e $file"
  else
    $tmux send-keys ":e +$line $file"
  fi
  $tmux send-keys Enter
  $tmux send-keys zz
fi

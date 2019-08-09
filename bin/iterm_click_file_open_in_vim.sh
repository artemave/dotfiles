#!/usr/bin/env bash

set -e

# notify-send --urgency=low -t 5000 "tmux -> vim" "File: $1, line: $2"

if [ "$(uname)" == "Linux" ]; then
  tmux=tmux
else
  tmux=/usr/local/bin/tmux
fi

if [[ ! -f "$1" ]]; then
  if [[ ! -f "./$1" ]]; then
    if command -v notify-send &> /dev/null; then
      notify-send --urgency=low -t 5000 "tmux -> vim" "File not found: $1"
    fi
  fi
else
  $tmux select-window -t vim
  $tmux send-keys Escape
  if [ -z "$2" ]; then
    $tmux send-keys ":e $1"
  else
    $tmux send-keys ":e +$2 $1"
  fi
  $tmux send-keys Enter
  $tmux send-keys zz
fi

# Setup fzf function
# ------------------
unalias fzf 2> /dev/null
fzf() {
  /usr/bin/ruby --disable-gems /Users/artem/.fzf/fzf "$@"
}
export -f fzf > /dev/null

# Auto-completion
# ---------------
[[ $- =~ i ]] && source /Users/artem/.fzf/fzf-completion.bash

# Key bindings
# ------------
__fsel() {
  find * -path '*/\.*' -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | fzf -m | while read item; do
    printf '%q ' "$item"
  done
  echo
}

if [[ $- =~ i ]]; then

__fsel_tmux() {
  local height
  height=${FZF_TMUX_HEIGHT:-40%}
  if [[ $height =~ %$ ]]; then
    height="-p ${height%\%}"
  else
    height="-l $height"
  fi
  tmux split-window $height "bash -c 'source ~/.fzf.bash; tmux send-keys -t $TMUX_PANE \"\$(__fsel)\"'"
}

__fcd() {
  local dir
  dir=$(find ${1:-*} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) && printf 'cd %q' "$dir"
}

__use_tmux=0
[ -n "$TMUX_PANE" -a ${FZF_TMUX:-1} -ne 0 -a ${LINES:-40} -gt 15 ] && __use_tmux=1

if [ -z "$(set -o | grep '^vi.*on')" ]; then
  # Required to refresh the prompt after fzf
  bind '"\er": redraw-current-line'

  # CTRL-T - Paste the selected file path into the command line
  if [ $__use_tmux -eq 1 ]; then
    bind '"\C-t": " \C-u \C-a\C-k$(__fsel_tmux)\e\C-e\C-y\C-a\C-d\C-y\ey\C-h"'
  else
    bind '"\C-t": " \C-u \C-a\C-k$(__fsel)\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
  fi

  # CTRL-R - Paste the selected command from history into the command line
  bind '"\C-r": " \C-e\C-u$(HISTTIMEFORMAT= history | fzf +s | sed \"s/ *[0-9]* *//\")\e\C-e\er"'

  # ALT-C - cd into the selected directory
  bind '"\ec": " \C-e\C-u$(__fcd)\e\C-e\er\C-m"'
else
  bind '"\C-x\C-e": shell-expand-line'
  bind '"\C-x\C-r": redraw-current-line'

  # CTRL-T - Paste the selected file path into the command line
  # - FIXME: Selected items are attached to the end regardless of cursor position
  if [ $__use_tmux -eq 1 ]; then
    bind '"\C-t": "\e$a \eddi$(__fsel_tmux)\C-x\C-e\e0P$xa"'
  else
    bind '"\C-t": "\e$a \eddi$(__fsel)\C-x\C-e\e0Px$a \C-x\C-r\exa "'
  fi

  # CTRL-R - Paste the selected command from history into the command line
  bind '"\C-r": "\eddi$(HISTTIMEFORMAT= history | fzf +s | sed \"s/ *[0-9]* *//\")\C-x\C-e\e$a\C-x\C-r"'

  # ALT-C - cd into the selected directory
  bind '"\ec": "\eddi$(__fcd)\C-x\C-e\C-x\C-r\C-m"'
fi

unset __use_tmux

fi

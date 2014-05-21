HISTFILE=~/.histfile
HISTSIZE=SAVEHIST=10000
setopt incappendhistory extendedhistory

setopt autocd
setopt nomatch
setopt notify
setopt extended_glob
setopt equals
setopt MULTIOS # pipe to multiple outputs.
setopt AUTOPUSHD
setopt PUSHDMINUS
setopt PUSHDSILENT
setopt PUSHDTOHOME
setopt CDABLEVARS
setopt NOCLOBBER # prevents accidentally overwriting an existing file.
setopt SH_WORD_SPLIT # var are split into words when passed.
setopt NOMATCH # If a pattern for filename has no matches = error.
setopt PRINT_EXIT_VALUE
setopt LONG_LIST_JOBS
autoload -U zmv
bindkey '^R' history-incremental-search-backward

# COMPLETION
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit

setopt completealiases
zstyle ':completion:*:killall:*' command 'ps -u $USER -o cmd'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:warnings' format 'No matches for: %B%d%b'
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
setopt completeinword

# show waiting dots.
expand-or-complete-with-dots() {
  echo -n "\e[1;34m.....\e[0m"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

setopt interactivecomments # pound sign in interactive prompt

# Display CPU usage stats for commands taking more than 10 seconds
REPORTTIME=10

autoload -U colors && colors
autoload -Uz vcs_info

zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo " %{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
function rbenv_prompt_info() {
  local ruby_version
  ruby_version=$(rbenv version 2> /dev/null) || return
  echo "‹$ruby_version" | sed 's/[ \t].*$/›/'
}

setopt prompt_subst
PROMPT='%(!.%F{red}.%F{green})%n:%~%F{yellow}$(vcs_info_wrapper)%{%F{blue}%}$(rbenv_prompt_info)%{${reset_color}%}
%F{yellow}%% %f'

function zle-line-init zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# VI MODE
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode

# override stupid ubuntu defaults for viins mode
[[ -z "$terminfo[cuu1]" ]] || bindkey -M viins "$terminfo[cuu1]" up-line-or-history
[[ -z "$terminfo[kcuu1]" ]] || bindkey -M viins "$terminfo[kcuu1]" up-line-or-history
[[ -z "$terminfo[kcud1]" ]] || bindkey -M viins "$terminfo[kcud1]" down-line-or-history
# ncurses fogyatekos
[[ "$terminfo[kcuu1]" == "O"* ]] && bindkey -M viins "${terminfo[kcuu1]/O/[}" up-line-or-history
[[ "$terminfo[kcud1]" == "O"* ]] && bindkey -M viins "${terminfo[kcud1]/O/[}" down-line-or-history

# Alt-S inserts "sudo " at the start of line.
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

# particularly useful to undo glob expansion
bindkey '^_' undo

source ~/projects/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

source ~/.common_shrc

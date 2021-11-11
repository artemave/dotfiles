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
setopt HIST_FIND_NO_DUPS
autoload -U zmv
bindkey '^R' history-incremental-search-backward

# COMPLETION
fpath=(~/.zsh/completion/src $fpath)

autoload -Uz compinit && compinit -i

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

setopt interactivecomments # pound sign in interactive prompt

# Display CPU usage stats for commands taking more than 10 seconds
REPORTTIME=10

autoload -U colors && colors

preexec() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  # for timing commands
  timer=$(($(print -P %D{%s%6.})/1000))
}

autoload -Uz vcs_info

PROMPT_GREEN='%F{green}'
PROMPT_YELLOW='%F{yellow}'
PROMPT_CYAN='%F{cyan}'
PROMPT_BLUE='%F{blue}'
PROMPT_RED='%F{red}'

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr " %F{green}+"
zstyle ':vcs_info:*' unstagedstr " %F{yellow}#"
zstyle ':vcs_info:*' formats "%F{blue}{%F{cyan}%b%u%c%F{blue}} "
zstyle ':vcs_info:*' actionformats "%F{blue}{%F{cyan}%b %F{red}%a%u%c%F{blue}} "

# zstyle ':vcs_info:*' actionformats \
#     '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
# zstyle ':vcs_info:*' formats       \
#     '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo " %{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}

function rbenv_prompt_info() {
  [ -f ./Gemfile ] || return
  local ruby_version
  ruby_version=$(ruby -v 2> /dev/null) || return
  ruby_version=$(echo $ruby_version | sed 's/ruby \([^ ]*\).*/\1/')
  echo "‹%F{196}♦️$ruby_version%f›"
}

node_prompt_info() {
  [ -f ./package.json ] || return
  local node_version
  node_version=$(node -v 2> /dev/null) || return
  echo "‹%F{082}⬢$node_version%f›"
}

function vi_mode() {
  echo "${${KEYMAP/vicmd/NORMAL}/(main|viins)/INSERT}"
}

setopt prompt_subst

precmd() {
  # for Terminal current directory support
  print -Pn "\e]2; %~/ \a"

  vcs_info

  if [[ -n $SSH_TTY ]]
  then
    local DISPLAY_HOST="%F{yellow}$(hostname) "
  else
    local DISPLAY_HOST=
  fi

  # for timing commands
  if [ $timer ]; then
    local now=$(($(print -P %D{%s%6.})/1000))
    elapsed=$(($now-$timer))
    # elapsed=$(duration $(($now-$timer)))
    PROMPT="%(!.%F{red}.%F{green})%~ %F{blue}+${elapsed}ms%F{red}%(?.. [%?])%f$(vcs_info_wrapper)$(rbenv_prompt_info)$(node_prompt_info)
[%F{cyan}$(vi_mode)%f] %F{yellow}%% %f"
    unset elapsed
    unset timer
  else
    PROMPT='%(!.%F{red}.%F{green})%~%F{red}%(?.. [%?])%f$(vcs_info_wrapper)$(rbenv_prompt_info)$(node_prompt_info)
[%F{cyan}$(vi_mode)%f] %F{yellow}%% %f'
  fi
}

function zle-line-init zle-keymap-select {
  zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# override stupid ubuntu defaults for viins mode
[[ -z "$terminfo[cuu1]" ]] || bindkey -M viins "$terminfo[cuu1]" up-line-or-history
[[ -z "$terminfo[kcuu1]" ]] || bindkey -M viins "$terminfo[kcuu1]" up-line-or-history
[[ -z "$terminfo[kcud1]" ]] || bindkey -M viins "$terminfo[kcud1]" down-line-or-history
# ncurses fogyatekos
[[ "$terminfo[kcuu1]" == "O"* ]] && bindkey -M viins "${terminfo[kcuu1]/O/[}" up-line-or-history
[[ "$terminfo[kcud1]" == "O"* ]] && bindkey -M viins "${terminfo[kcud1]/O/[}" down-line-or-history

[[ $EMACS = t ]] && unsetopt zle

# VI MODE
bindkey -v
bindkey -M viins 'kj' vi-cmd-mode

# particularly useful to undo glob expansion
bindkey '^_' undo

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word

# this is now here as opposed to .zlogin because `zplug` inserting `/bin` in the PATH which breaks coreutils (ls, etc)

# ubuntu does not start login shell
if [[ -z $COMMON_ENV_LOADED ]]; then
  source ~/.common_env
fi
source ~/.common_shrc

# place this after nvm initialization!
autoload -U add-zsh-hook
# load-nvmrc() {
#   if command -v nvm > /dev/null; then
#     local node_version="$(nvm version)"
#     local nvmrc_path="$(nvm_find_nvmrc)"

#     if [ -n "$nvmrc_path" ]; then
#       local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

#       if [ "$nvmrc_node_version" = "N/A" ]; then
#         nvm install
#       elif [ "$nvmrc_node_version" != "$node_version" ]; then
#         nvm use --delete-prefix
#       fi
#     elif [ "$node_version" != "$(nvm version default)" ]; then
#       echo "Reverting to nvm default version"
#       nvm use --delete-prefix default
#     fi
#   fi
# }
# add-zsh-hook chpwd load-nvmrc

# export NVM_DIR="$HOME/.nvm"
# function load_nvm() {
#   [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
#   [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
# }
# load_nvm

if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
  # failed attempt to fix emacs <-> direnv integration
  # autoload -U add-zsh-hook

  # hook_function() {
  #   eval "$(direnv hook zsh)"
  # }
  # add-zsh-hook preexec hook_function
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/artem/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/artem/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/artem/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/artem/google-cloud-sdk/completion.zsh.inc'; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###-tns-completion-start-###
if [ -f /home/artem/.tnsrc ]; then 
    source /home/artem/.tnsrc 
fi
###-tns-completion-end-###

if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
eval "$(pyenv init -)"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# This should be the last thing because it duplicates PATH entries
source ~/.zsh/zplug/init.zsh
# zplug denysdovhan/spaceship-prompt, use:spaceship.zsh, from:github, as:theme

zplug 'kevinywlui/zlong_alert.zsh'
zlong_ignore_cmds='vim ssh heroku nvim tail man less'

zplug 'zdharma/fast-syntax-highlighting', defer:2

if ! zplug check --verbose; then
  zplug install
fi
zplug load --verbose

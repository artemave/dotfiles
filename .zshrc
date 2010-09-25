# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd nomatch notify extendedglob
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/artem/.zshrc'

zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion::complete:*' use-cache 1

autoload -Uz compinit
compinit
# End of lines added by compinstall

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

if [[ -s /home/artem/.rvm/scripts/rvm ]] ; then source /home/artem/.rvm/scripts/rvm ; fi

autoload -U colors && colors

case $USER in
  "root") PS_COLOR=%{$fg[red]%};;
  *) PS_COLOR=%{$fg[green]%};;
esac

parsegitbranch() {
    git branch &>/dev/null;
    if [ $? -eq 0 ]; then
        echo " ($(git branch 2> /dev/null | grep '^*' |sed s/\*\ //))";
    fi
}

PS1="%{$PS_COLOR%}%n:%~%{$fg[yellow]%}$(parsegitbranch)%% %{$reset_color%}"

function cabalinst() {
    cabal install "$@"
    chmod -R go+rX /usr/local/share/cabal/packages
}

function take() {
  mkdir $1
  cd $1
}


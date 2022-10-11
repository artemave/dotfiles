#!/bin/bash
set -ex
# set -x

dotfiles=( \
  .bash_profile \
  .editorconfig \
  .bashrc \
  .common_env \
  .common_shrc \
  .editrc \
  .gemrc \
  .gitconfig \
  .gitignore \
  .gitmessage \
  .inputrc \
  .spacemacs \
  .tmux-osx.conf \
  .tmux.conf \
  .zlogin \
  .zshenv \
  .zshrc \
  .ideavimrc \
  .vifm \
  .vimrc \
  .vim \
  .plugins.vim \
  .xsessionrc \
  .Xdefaults \
  .Xresources \
  .Xmodmap \
  bin \
)

rbenv_plugins=(\
  sstephenson/ruby-build \
  tpope/rbenv-ctags \
  sstephenson/rbenv-default-gems \
  tpope/rbenv-aliases \
  rkh/rbenv-update \
  sstephenson/rbenv-gem-rehash)

function fail() {
  echo "$1\n"
  exit 1
}

projects_dir=$HOME/projects

command -v git &> /dev/null || fail "Install git first"

case $1 in
  -dots)
    for file in ${dotfiles[@]}; do
      ln -f -s "$(pwd)/$file" ~/
    done

    mkdir -p $HOME/.config
    for dir in $(pwd)/.config/* $(pwd)/.config/.*; do
      if [[ "$dir" =~ \.$ ]]; then
        continue
      fi

      if [[ -d $dir ]]; then
        target_dir=~/.config/$(basename $dir)/
        mkdir -p $target_dir
        for file in $dir/*; do
          ln -f -s $file $target_dir
        done
      else
        ln -f -s $dir ~/.config
      fi
    done

    if [[ ! -d ~/.config/i3blocks-contrib ]]; then
      git clone https://github.com/vivien/i3blocks-contrib.git ~/.config/i3blocks-contrib
    fi

    mkdir -p $projects_dir

    if [[ ! -d $HOME/.zsh/completion ]]; then
      git clone https://github.com/zsh-users/zsh-completions.git $HOME/.zsh/completion
    fi

    if [[ ! -d $HOME/.zsh/zplug ]]; then
      git clone https://github.com/zplug/zplug $HOME/.zsh/zplug
    fi

    if [[ ! -d ~/.fzf ]]; then
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      yes | ~/.fzf/install
    fi
    ;;

  -tmux)
    command -v tmux &> /dev/null || fail "Install tmux first"

    tpm_home=~/.tmux/plugins/tpm
    if [ ! -d $tpm_home ]; then
      git clone https://github.com/tmux-plugins/tpm $tpm_home
    fi

    tmux new -d -s temp

    ~/.tmux/plugins/tpm/tpm

    $tpm_home/scripts/install_plugins.sh >/dev/null 2>&1

    tmux kill-session -t temp
    ;;

  -rbenv)
    if [ ! -d ~/.rbenv ]; then
      git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    else
      [ -d ~/.rbenv/.git ] && git -C ~/.rbenv pull
    fi

    for plugin in ${rbenv_plugins[@]}; do
      plugin_name=$(echo $plugin | sed -E 's#[^/]*/(.*)#\1#')

      if [ ! -d ~/.rbenv/plugins/$plugin_name ]; then
        git clone https://github.com/${plugin}.git ~/.rbenv/plugins/$plugin_name
      else
        git -C ~/.rbenv/plugins/$plugin_name pull
      fi
    done

    ln -f -s "$(pwd)/rbenv/default-gems" ~/.rbenv/
    ;;

  *)
    $0 -dots
    ;;
esac

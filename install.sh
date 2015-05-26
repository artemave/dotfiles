#!/bin/sh
set -e

dotfiles=(.zshrc .zshenv .zlogin .bashrc .bash_profile .common_env .common_shrc .ctags \
  .editrc .inputrc .tmux.conf .gemrc .gitconfig .gitignore .spacemacs bin)

vimfiles=(.vimrc .vim .bundles.vim)

rbenv_plugins=(\
  sstephenson/ruby-build \
  tpope/rbenv-ctags \
  sstephenson/rbenv-default-gems \
  tpope/rbenv-aliases \
  sstephenson/rbenv-vars \
  sstephenson/rbenv-gem-rehash)

function fail() {
  echo "$1\n"
  exit 1
}

command -v git &> /dev/null || fail "Install git first"

case $1 in
  -dots)
    for file in ${dotfiles[@]}; do
      ln -f -s "$(pwd)/$file" ~/
    done
    ;;

  -tmux)
    command -v tmux &> /dev/null || fail "Install tmux first"

    tpm_home=~/.tmux/plugins/tpm
    if [ ! -d $tpm_home ]; then
      git clone https://github.com/tmux-plugins/tpm $tpm_home
    fi

    tmux -d -s temp

    ~/.tmux/plugins/tpm/tpm

    $tpm_home/scripts/install_plugins.sh >/dev/null 2>&1

    tmux kill-session -t temp
    ;;

  -vim)
    for file in ${vimfiles[@]}; do
      ln -f -s "$(pwd)/$file" ~/
    done

    bundle_home=~/.vim/bundle/Vundle.vim
    if [ ! -d $bundle_home ]; then
      git clone https://github.com/gmarik/Vundle.vim.git $bundle_home
    fi
    vim --noplugin -u ~/.bundles.vim +BundleInstall +qa
    ;;

  -rbenv)
    if [ ! -d ~/.rbenv ]; then
      git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
    else
      [ -d ~/.rbenv/.git ] && git -C ~/.rbenv pull
    fi

    for plugin in ${rbenv_plugins[@]}; do
      plugin_name=$(echo $plugin | sed -E 's#[^/]*/(.*)#\1#')

      if [ ! -d ~/.rbenv/plugins/$plugin_name ]; then
        git clone git://github.com/${plugin}.git ~/.rbenv/plugins/$plugin_name
      else
        git -C ~/.rbenv/plugins/$plugin_name pull
      fi
    done

    ln -f -s "$(pwd)/rbenv/default-gems" ~/.rbenv/
    ln -f -s "$(pwd)/vars" ~/.rbenv/
    ;;

  -git)
    if [ -z "$2" ] || [ -z "$3" ]; then
      fail "usage:\n./install.sh -git USERNAME EMAIL"
    fi
    git config --global --add alias.local 'log @{u}..'
    git config --global core.excludesfile ~/.gitignore
    git config --global user.name $2
    git config --global user.email $3
    ;;

  *)
    $0 -dots && $0 -vim && $0 -tmux && $0 -rbenv
    ;;
esac

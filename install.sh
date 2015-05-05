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

case $1 in
  -dots)
    for file in ${dotfiles[@]}; do
      ln -f -s "$(pwd)/$file" ~/
    done
    ;;

  -vim)
    command -v git &> /dev/null || fail "Install git first"
    bundle_home=~/.vim/bundle

    for file in ${vimfiles[@]}; do
      ln -f -s "$(pwd)/$file" ~/
    done

    if [ ! -d $bundle_home ]; then
      git clone http://github.com/gmarik/vundle.git $bundle_home
    fi
    vim --noplugin -u ~/.bundles.vim +BundleInstall +qa
    ;;

  -rbenv)
    command -v git &> /dev/null || fail "Install git first"

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
    command -v git &> /dev/null || fail "Install git first"

    if [ -z "$2" ] || [ -z "$3" ]; then
      fail "usage:\n./install.sh -git USERNAME EMAIL"
    fi
    git config --global core.excludesfile ~/.gitignore
    git config --global user.name $2
    git config --global user.email $3
    ;;

  *)
    echo "Install what? -dots, -vim, -rbenv or -git USERNAME EMAIL?\n"
    ;;
esac

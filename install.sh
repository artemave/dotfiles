#!/bin/bash
set -e
# set -x

dotfiles=( \
  .bash_profile \
  .editorconfig \
  .bashrc \
  .eslintrc \
  .common_env \
  .common_shrc \
  .ctags \
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
  bin \
)

vimfiles=(.vimrc .vim .bundles.vim)

rbenv_plugins=(\
  sstephenson/ruby-build \
  tpope/rbenv-ctags \
  sstephenson/rbenv-default-gems \
  tpope/rbenv-aliases \
  sstephenson/rbenv-vars \
  jf/rbenv-gemset \
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

    if [[ ! -d $projects_dir ]]; then
      mkdir $projects_dir
    fi

    mkdir -p $HOME/.zsh/completion

    if [[ ! -d $projects_dir/zsh-syntax-highlighting ]]; then
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $projects_dir/zsh-syntax-highlighting
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

  -vim)
    for file in ${vimfiles[@]}; do
      ln -f -s "$(pwd)/$file" ~/
    done

    bundle_home=~/.vim/bundle
    if [ ! -d $bundle_home ]; then
      git clone https://github.com/gmarik/Vundle.vim.git $bundle_home/Vundle.vim
    fi
    vim --noplugin -u ~/.bundles.vim +BundleInstall +qa

    if [ -d $bundle_home/vimproc.vim ]; then
      cd $bundle_home/vimproc.vim && make && cd -
    fi
    if [ -d $bundle_home/tern_for_vim ]; then
      if command -v git &> /dev/null; then
        cd $bundle_home/tern_for_vim && npm i && cd -
      else
        echo "Install npm and run '$bundle_home/tern_for_vim && npm i && cd -'\n"
      fi
    fi
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

  *)
    $0 -dots && $0 -vim && $0 -tmux && $0 -rbenv
    ;;
esac

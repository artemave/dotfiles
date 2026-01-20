#!/bin/bash
set -ex
# set -x

dotfiles=( \
  .aider.conf.yml \
  .bash_profile \
  .profile \
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
  AGENTS.md \
  CLAUDE.md \
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

function fail() {
  echo "$1\n"
  exit 1
}

projects_dir=$HOME/projects

command -v git &> /dev/null || fail "Install git first"
command -v mise &> /dev/null || fail "Install mise first"

case $1 in
  -dots)

    if [[ $(uname) == "Linux" ]]; then
      if ! python3 -m pip list | grep i3ipc > /dev/null; then
        python3 -m pip install --user --upgrade i3ipc
      fi
    fi

    if ! python3 -m pip list | grep pynvim > /dev/null; then
      python3 -m pip install --user --upgrade pynvim
    fi

    for file in "${dotfiles[@]}"; do
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

    mkdir -p ~/.ssh
    for file in $(pwd)/.ssh/*; do
      ln -f -s $file ~/.ssh
    done

    if [[ ! -d ~/.config/i3blocks-contrib ]]; then
      git clone https://github.com/vivien/i3blocks-contrib.git ~/.config/i3blocks-contrib
    fi

    mkdir -p $projects_dir

    if [[ ! -d $HOME/.zsh/completion ]]; then
      git clone https://github.com/zsh-users/zsh-completions.git $HOME/.zsh/completion
    fi

    zsh_plugins_dir="$HOME/.zsh/plugins"
    mkdir -p "$zsh_plugins_dir"

    if [[ ! -d $zsh_plugins_dir/zsh-autosuggestions ]]; then
      git clone https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_plugins_dir/zsh-autosuggestions"
    fi

    if [[ ! -d $zsh_plugins_dir/fast-syntax-highlighting ]]; then
      git clone https://github.com/zdharma/fast-syntax-highlighting.git "$zsh_plugins_dir/fast-syntax-highlighting"
    fi

    if [[ ! -d $zsh_plugins_dir/zlong_alert ]]; then
      git clone https://github.com/kevinywlui/zlong_alert.zsh.git "$zsh_plugins_dir/zlong_alert"
    fi

    if [[ ! -d $zsh_plugins_dir/zsh-ai-cmd ]]; then
      git clone https://github.com/kylesnowschwartz/zsh-ai-cmd.git "$zsh_plugins_dir/zsh-ai-cmd"
    fi

    if [[ ! -d ~/.fzf ]]; then
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      yes | ~/.fzf/install
    fi

    if [[ ! -d ~/.tmux/plugins/tpm ]]; then
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi

    if [[ ! -d ~/.local/share/applications ]]; then
      mkdir -p ~/.local/share/applications
    fi

    for file in ./applications/*; do
      ln -f -s "$(pwd)/$file" ~/.local/share/applications/
    done

    if [[ ! -d ~/.local/share/mime/packages ]]; then
      mkdir -p ~/.local/share/mime/packages
    fi

    for file in ./mime/*; do
      ln -f -s "$(pwd)/$file" ~/.local/share/mime/packages/
    done

    mkdir -p ~/.claude
    for file in claude/*; do
      ln -f -s "$(pwd)/$file" ~/.claude/
    done

    if command -v npm &> /dev/null; then
      agent_browser_skill_dir="$(npm root -g)/agent-browser/skills/agent-browser"
      if [[ -d "$agent_browser_skill_dir" ]]; then
        mkdir -p ~/.claude/skills ~/.codex/skills
        if [[ ! -d ~/.claude/skills/agent-browser ]]; then
          cp -r "$agent_browser_skill_dir" ~/.claude/skills/
        fi
        if [[ ! -d ~/.codex/skills/agent-browser ]]; then
          cp -r "$agent_browser_skill_dir" ~/.codex/skills/
        fi
      fi
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

  -nvim)
    command -v nvim &> /dev/null || fail "Install neovim first"

    nvim --headless "+Lazy sync" "+MasonToolsInstallSync" +qa
    ;;

  *)
    $0 -dots
    ;;
esac

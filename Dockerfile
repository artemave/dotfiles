# syntax=docker/dockerfile:1.5
FROM fedora:42

RUN dnf -y install \
  ca-certificates \
  curl \
  direnv \
  file \
  git \
  htop \
  jq \
  less \
  openssh-clients \
  ncdu \
  procps-ng \
  pkgconf-pkg-config \
  nodejs \
  npm \
  python3 \
  python3-pip \
  ripgrep \
  bat \
  zsh \
  neovim \
  tmux \
  gh \
  xdg-utils \
  sudo \
  chromium \
  lsof \
  ncurses-term \
  gcc \
  gcc-c++ \
  make \
  openssl-devel \
  glibc-langpack-en \
  glib2 \
  fd \
  tig \
  && dnf clean all

ENV MISE_INSTALL_PATH=/usr/local/bin/mise
RUN curl -fsSL https://mise.jdx.dev/install.sh | bash

RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin

RUN if ! getent group 1000 >/dev/null; then groupadd --gid 1000 dev; fi \
  && useradd --uid 1000 --gid 1000 --create-home --shell /usr/bin/zsh dev

RUN echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
  && chmod 0440 /etc/sudoers.d/dev

RUN npm install -g @anthropic-ai/claude-code @openai/codex agent-browser beads-ui

USER dev
ENV HOME=/home/dev
WORKDIR /workspace

RUN NONINTERACTIVE=1 /bin/bash -lc "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN /bin/bash -lc "eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\" && brew install difftastic mergiraf steveyegge/beads/bd"

COPY --chown=dev:dev scripts/devcontainer/entrypoint.sh /home/dev/devcontainer-entrypoint
RUN chmod +x /home/dev/devcontainer-entrypoint

ENV ZPLUG_PIPE_FIX=true
ENV TERM="tmux-256color"

COPY --from=dotfiles --chown=dev:dev / /home/dev/dotfiles
RUN PIP_BREAK_SYSTEM_PACKAGES=1 /bin/bash -lc "cd /home/dev/dotfiles && bash ./install.sh -dots && bash ./install.sh -tmux && bash ./install.sh -nvim"

RUN /bin/bash -lc "agent-browser install --with-deps"

RUN /bin/bash -lc "printf '%s\n' \"alias claude='claude --dangerously-skip-permissions'\" \"alias codex='codex --dangerously-bypass-approvals-and-sandbox'\" > /home/dev/.local_env"

ENTRYPOINT ["/home/dev/devcontainer-entrypoint"]
CMD ["zsh"]

# syntax=docker/dockerfile:1.5
FROM fedora:44

# Keep downloaded rpms so the dnf cache mounts below (here, in agent-browser's deps
# and in child images) have something to reuse.
RUN echo "keepcache=1" >> /etc/dnf/dnf.conf

RUN --mount=type=cache,id=dev-base-dnf,target=/var/cache/libdnf5,sharing=locked \
  dnf -y install \
  ca-certificates \
  curl \
  dnf-plugins-core \
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
  gh \
  xdg-utils \
  sudo \
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
  libatomic \
  tree \
  imv \
  awscli2 \
  ImageMagick \
  psmisc \
  man \
  tar \
  xz \
  gtk3 \
  dbus-glib \
  alsa-lib \
  libXt \
  libnotify \
  mesa-libEGL \
  mesa-dri-drivers \
  dejavu-fonts-all \
  liberation-fonts

ENV MISE_INSTALL_PATH=/usr/local/bin/mise
RUN curl -fsSL https://mise.jdx.dev/install.sh | bash

RUN curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin

RUN curl -fsSL "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US" \
      | tar -xJ -C /opt \
  && mv /opt/firefox /opt/firefox-devedition \
  && ln -s /opt/firefox-devedition/firefox /usr/local/bin/firefox-devedition \
  && ln -s /opt/firefox-devedition/firefox /usr/local/bin/firefox

COPY --from=dotfiles devcontainer/firefox-devedition.desktop /usr/share/applications/firefox-devedition.desktop

RUN if ! getent group 1000 >/dev/null; then groupadd --gid 1000 dev; fi \
  && useradd --uid 1000 --gid 1000 --create-home --shell /usr/bin/zsh dev

RUN echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
  && chmod 0440 /etc/sudoers.d/dev

USER dev
ENV HOME=/home/dev
WORKDIR /workspace

# Cache mounts create missing parents as root; pre-create so dev keeps ownership.
RUN mkdir -p /home/dev/.cache

RUN NONINTERACTIVE=1 /bin/bash -lc "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN --mount=type=cache,id=dev-base-brew,target=/home/dev/.cache/Homebrew,uid=1000,gid=1000,sharing=locked \
    /bin/bash -lc "eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\" && brew install -y neovim difftastic mergiraf aws-vault"
ENV PATH=${PATH}:/home/linuxbrew/.linuxbrew/bin

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN --mount=type=cache,id=dev-base-npm,target=/root/.npm,sharing=locked \
    sudo npm install -g @openai/codex agent-browser skills @bitwarden/cli

RUN --mount=type=cache,id=dev-base-dnf,target=/var/cache/libdnf5,sharing=locked \
    /bin/bash -lc "agent-browser install --with-deps"

RUN npx skills add vercel-labs/agent-browser

COPY --from=dotfiles --chown=dev:dev / /home/dev/dotfiles
RUN PIP_BREAK_SYSTEM_PACKAGES=1 /bin/bash -lc "cd /home/dev/dotfiles && bash ./install.sh -dots"

RUN xdg-mime default firefox-devedition.desktop \
      text/html \
      application/xhtml+xml \
      x-scheme-handler/http \
      x-scheme-handler/https \
      x-scheme-handler/about \
      x-scheme-handler/unknown

RUN xdg-mime default imv.desktop \
      image/png \
      image/jpeg \
      image/gif \
      image/webp \
      image/bmp \
      image/tiff \
      image/svg+xml \
      image/avif \
      image/heic

RUN bw config server https://vault.bitwarden.eu

COPY --from=dotfiles --chown=dev:dev devcontainer/entrypoint.sh /home/dev/devcontainer-entrypoint
RUN chmod +x /home/dev/devcontainer-entrypoint

ENTRYPOINT ["/home/dev/devcontainer-entrypoint"]
CMD ["zsh"]

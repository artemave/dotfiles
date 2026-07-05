# dotfiles
.zshrc, .vimrc, etc.

## Install

```sh
git clone https://github.com/artemave/dotfiles.git
cd myrcs
./install.sh # everything

# or just vim
./install.sh -vim # -tmux -rbenv -dots

# root-owned system config (PAM, systemd units, sleep hooks) — needs sudo
./install.sh -system
```

`-system` mirrors everything under `system/` to its absolute path (e.g.
`system/etc/pam.d/swaylock` → `/etc/pam.d/swaylock`), copying only files whose
content changed. It's kept separate from the default run so `./install.sh`
never needs sudo.

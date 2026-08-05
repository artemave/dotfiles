# dotfiles
.zshrc, .vimrc, etc.

## Install

```sh
git clone https://github.com/artemave/dotfiles.git
cd myrcs
./install.sh # everything

# or just vim
./install.sh -vim # -tmux -rbenv -dots

# hyprlock + root-owned system config (PAM, systemd units, sleep hooks) — needs sudo
./install.sh -system
```

`-system` installs hyprlock (screen locker, from the lionheartp/Hyprland COPR)
and mirrors everything under `system/` to its absolute path (e.g.
`system/etc/pam.d/hyprlock` → `/etc/pam.d/hyprlock`), copying only files whose
content changed. It's kept separate from the default run so `./install.sh`
never needs sudo.

Among those files are two sleep hooks: `10-network-reset.sh` (stops the network
before suspend, which this machine hangs without) and
`20-resuspend-lid-closed.sh` (a minute after a resume, suspends again if the lid
is still shut and the screen still locked — otherwise anything that wakes the
machine mid-sleep, an unplugged charger or screen, leaves it awake indefinitely,
since logind only suspends on an actual lid *switch* event).

Lid policy lives in `etc/systemd/logind.conf.d/10-lid.conf`: suspend on close,
docked or not. It replaces an acpid rule that used to do the docked half of
that. If `/etc/acpi/events/laptop-lid` still exists, delete it — its
`event=button/lid.*` matches lid *open* as well as close, so opening the lid
suspended the machine a few seconds later:

```sh
sudo rm /etc/acpi/events/laptop-lid && sudo systemctl restart acpid
```

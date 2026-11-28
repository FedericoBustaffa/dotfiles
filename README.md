# Dotfiles

Dotfiles for Arch Linux configuration, including Hyprland and Neovim.

## TODO

Planning to add more features to make the configuration less dependent on random
third-party components.

## Dotfiles sync

For a checkout at `~/dotfiles`, enable sync from a running Hyprland session:

```sh
systemctl --user enable --now "$HOME/dotfiles/scripts/dotfiles-sync.service"
```

The service fetches `origin/master` at desktop login and fast-forwards a clean
checkout. At logout, shutdown, or reboot it commits tracked edits and pushes to
GitHub. Review and stage new files yourself before they can be included. The
service needs non-interactive GitHub SSH access. If the push fails (for example,
when offline or if branches diverge), your commit stays local; reconcile any
divergence and run `~/dotfiles/scripts/dotsync.sh` to retry. No force-pushes.

Check logs with `journalctl --user -u dotfiles-sync.service`.

## Quickshell

- Bar
  - System
  - Workspaces
  - Clock
  - Calendar
  - Notification
  - Package updates
  - Volume and audio
  - Bluetooth
  - Network
  - Power profiles
  - Battery
  - Power menu
- Network
- Bluetooth
- Notification
- Power profiles
- Volume
- Brightness
- Backlight
- Power menu
- Lock screen

## Neovim

- Better
- Debugger

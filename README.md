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

## Display settings

Open **Super+Space → `> Display settings`**, or run
`python ~/dotfiles/scripts/display-settings.py`. Drag displays to snap them
edge-to-edge, select a resolution and scale, then apply and confirm the layout.
Unconfirmed changes revert automatically.

`~/.config/hypr/monitors.lua` is machine-local and ignored by Git. Fresh
checkouts use Hyprland's automatic display layout until you save one. **Before
pulling the migration on another computer**, back up its existing `monitors.lua`
outside the checkout (Git removes the formerly tracked copy when updating),
then restore it to `~/.config/hypr/monitors.lua` after pulling and running Stow.

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

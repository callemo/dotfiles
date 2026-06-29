# OpenBSD

`./install` sources `install_openbsd.sh` when `uname` reports OpenBSD. This is
local laptop setup, not a portable OpenBSD installer.

## What it changes

- `/etc/wsconsctl.conf` — disables touchpad tapping and reverses scroll for
  `wsmouse0`.
- `/etc/hotplug/attach` — reverses scroll for late-attached `wsmouseN` devices.
- `/etc/hotplug/detach` — installed as a no-op to remove stale local detach actions.
- `hotplugd` — enables and starts it so the attach hook runs.
- `~/.tmux.conf.local` — copies tmux selections through `xsel`; OpenBSD xterm
  lacks OSC 52.
- `~/.icons/default/index.theme` and `~/.config/gtk-3.0/settings.ini` — use the
  Adwaita cursor at size 32.
- Wallpaper — checks for `xwallpaper` and `openbsd-backgrounds`.
- `~/.vimrc.local` — adds `/usr/local/share/vim/vimfiles` and copies Vim yanks
  through `xsel`.

## Mouse scrolling

OpenBSD's `wsconsctl.conf` runs only at boot. It sets:

```sh
mouse.tp.tapping=0
mouse.reverse_scrolling=1
```

`mouse.reverse_scrolling` without a number applies to `/dev/wsmouse0`.
A USB mouse attached after boot may appear as `wsmouse1`, `wsmouse2`, and so
on, so the installed attach hook includes this rule:

```sh
case "$2" in
wsmouse[0-9]*)
	/sbin/wsconsctl "mouse${2#wsmouse}.reverse_scrolling=1" >/dev/null 2>&1
	;;
esac
```

For `wsmouse2`, it runs:

```sh
/sbin/wsconsctl mouse2.reverse_scrolling=1
```

`wsconsctl` owns wheel direction. Do not also swap X buttons `4` and `5`; that
would reverse the wheel twice.

## Desk display

The ThinkPad T490 BIOS uses Thunderbolt security level **No Security** for the
HP Thunderbolt Dock G4. In restrictive DisplayPort/USB-only mode, the dock gave
partial USB/display behavior and did not charge. In No Security mode, OpenBSD
sees AC power and the external display.

Full Thunderbolt mode can panic OpenBSD on hot-unplug. Treat the dock as a desk
station: connect before boot or while stationary, and suspend/shutdown before
undocking.

Display switching is manual. Use FVWM's display shortcut:

```text
Ctrl-Win-Delete
```

or run:

```sh
~/dotfiles/fvwm/display toggle
```

`fvwm/display` owns the FVWM restart: non-`sync` actions restart FVWM
automatically; `sync` does not restart, so FVWM `StartFunction` and
`RestartFunction` do not loop. There is no automatic display action in
`hotplugd`.

## Packages

The script does not install packages. If these are missing, it logs what to
install:

```sh
doas pkg_add xsel xwallpaper openbsd-backgrounds
```

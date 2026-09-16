# T490

This directory contains the unprivileged desktop configuration for
`t490.home.arpa`. The root installer links its `dot.*` files only when the
hostname is `t490` or begins with `t490.`. It then runs `setup.sh`.
This repository does not manage system files, services, or package installation.

## Desktop

BIOS settings for the HP Thunderbolt Dock G4, under **Config > Thunderbolt (TM) 3**:

| Setting | Value |
| --- | --- |
| Thunderbolt BIOS Assist Mode | Enabled |
| Wake by Thunderbolt(TM) 3 | Disabled |
| Security Level | Display Port and USB |

The X session runs FVWM with the Gruvbox Material palette. `fvwm/display`
switches between the panel and desk display. `Ctrl-Win-Delete` calls it from
FVWM.

GTK 2, 3, and 4 use the packaged Yaru warty-brown dark theme when available.
They share Gruvbox text colors.

Feh opens images. Mousepad opens prose. MuPDF GL opens PDF, EPUB, XPS, and CBZ
files. The setup script changes only the desktop entry at
`~/.local/share/applications/mupdf.desktop`. It does not manage or delete
files elsewhere in the XDG data tree.

Thunar manages the bookmarks and custom actions that this repository controls.
Space previews Markdown through `t490/bin/md-preview`.
**Open Terminal Here** runs `t490/bin/xterm-here`.
Edit the files in this directory, not their links under `~/.config`.

## Clipboard overrides

The shared Tmux and Vim configurations load managed host fragments from:

```text
~/.config/tmux/host.conf
~/.config/vim/host.vim
```

They then load `~/.tmux.conf.local` and `~/.vimrc.local`.
The operator controls files ending in `.local`. The installers never create
or edit them. These files load last when present. Their settings override
earlier settings.

The Tmux fragment sets the existing copy bindings to use `xsel -ib`.
The Vim fragment adds the packaged OpenBSD runtime and sends yanked text
through xsel. Other hosts keep OSC 52.

## User state

`setup.sh` updates only these named user settings:

- GTK appearance
- MIME defaults
- Thunar's sidebar and Space accelerator
- The GTK file chooser size
- The MuPDF desktop entry

The script reports missing optional programs instead of changing packages.

Expected commands include `feh`, `gsettings`, `lowdown`, `mousepad`,
`mupdf-gl`, `picom`, `thunar`, `update-desktop-database`, `xdg-mime`,
`xfconf-query`, `xsel`, and `xwallpaper`.

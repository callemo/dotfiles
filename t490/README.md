# T490

This directory owns the unprivileged desktop configuration for
`t490.home.arpa`. The root installer links its `dot.*` files only when the
hostname is `t490` or begins with `t490.`, then runs `setup.sh`. System files,
services, and package installation remain outside this repository.

## Desktop

The X session runs FVWM with the Gruvbox Material palette. `fvwm/display`
switches between the panel and desk display; `Ctrl-Win-Delete` calls it from
FVWM. The HP Thunderbolt Dock G4 works with BIOS Thunderbolt security set to
**No Security**, but OpenBSD can panic if the dock is unplugged while running.
Connect it before use and suspend or shut down before undocking.

GTK 2, 3, and 4 use the packaged Yaru warty-brown dark theme when available,
with shared Gruvbox text colors. Feh opens images. Mousepad opens prose. MuPDF
GL opens PDF, EPUB, XPS, and CBZ files. The setup script changes only the
specific desktop entry at `~/.local/share/applications/mupdf.desktop`; it does
not own or prune the surrounding XDG data tree.

Thunar owns the managed bookmarks and custom actions. Space previews Markdown
through `t490/bin/md-preview`. **Open Terminal Here** runs
`t490/bin/xterm-here`. Edit the files in this directory, not their links under
`~/.config`.

## Clipboard overrides

The shared Tmux and Vim configurations load managed host fragments from:

```text
~/.config/tmux/host.conf
~/.config/vim/host.vim
```

They then load `~/.tmux.conf.local` and `~/.vimrc.local`. Files ending in
`.local` belong to the operator; the installers never create or edit them.
When present, those files load last and take precedence.

The Tmux fragment selects `xsel -ib` as the existing copy bindings' command.
The Vim fragment adds the packaged OpenBSD runtime and sends yanks through
xsel. Other hosts retain OSC 52.

## User state

`setup.sh` updates only named user settings: GTK appearance, MIME defaults,
Thunar's sidebar and Space accelerator, the GTK file chooser size, and the
MuPDF desktop entry. Missing optional programs produce diagnostics rather than
package changes.

Expected commands include `feh`, `gsettings`, `lowdown`, `mousepad`,
`mupdf-gl`, `picom`, `thunar`, `update-desktop-database`, `xdg-mime`,
`xfconf-query`, `xsel`, and `xwallpaper`.

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

The display profiles keep each screen at its native resolution:

| Profile | Font DPI | Qt scale | XTerm Spleen size |
| --- | --- | --- | --- |
| Laptop panel | 144 | 1.6 | 24 pixels |
| External display | 156 | 2.0 | 32 pixels |

Qt keeps its font DPI at 96 and scales the interface separately.
The external profile uses DejaVu Sans 12 for GTK and Spleen 32 for FVWM menus and the pager.
Both fonts have a lowercase x-height of 14 pixels at these sizes.
Forms keep proportional Helvetica labels and buttons, with fixed-width Courier Bold input fields.
The external form sizes are 26 and 32 pixels; the panel keeps 20 and 25 pixels.
`fvwm/form-fonts` loads these fonts before form items so button sizes match their labels.

The status font and vertical padding set the toolbar height.
The external toolbar is 48 pixels high, with a 288-pixel-wide pager.
The pager keeps its 6:1 width-to-height ratio on both displays.

`fvwm/profile` supplies the shared sizes for the display, toolbar, and browser.
Reopen applications after switching profiles to use the new settings.

### Browser text

`setup.sh` links `t490/bin/chrome` to `~/bin/chrome`.
The launcher scales Chromium to 1.75 externally and 1.5 on the panel.
The device scale enlarges both the browser interface and webpages.
The launcher never changes font preferences or page zoom.
Chromium uses its normal font defaults: 16 proportional and 13 fixed-width, with 100% default page zoom.
Saved site zooms remain under user control.

Exit Chromium fully before reopening it to apply the profile.
Website fonts, explicit CSS sizes, and saved zooms can differ from interface text.

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

## Display tone and keyboard backlight

`Ctrl-Win-N` and the Nightlight menu entry run `/usr/local/ws/bin/nightlight`.
`dot.xsession` runs it at login. The program is a system program from the
workstation installer, which also runs it after resume from `/etc/apm/resume`.
That installer documents the hourly schedule.

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
- The display-aware Chromium launcher at `~/bin/chrome`

The script reports missing optional programs instead of changing packages.

Expected commands include `feh`, `gsettings`, `lowdown`, `mousepad`,
`mupdf-gl`, `thunar`, `update-desktop-database`, `xdg-mime`,
`xfconf-query`, `xsel`, and `xwallpaper`.

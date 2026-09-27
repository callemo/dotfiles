# Tmux quick guide

This guide covers [`dot.tmux.conf`](dot.tmux.conf). Think of a **pane** as an
FVWM window and a **tmux window** as an FVWM workspace. A **session** holds
several tmux windows. Panes tile; they do not float or move to screen edges.

Press `Ctrl-B`, release it, then press the next key. `H/J/K/L` means
`Shift-h/j/k/l`. Direction keys use `h/j/k/l` for left/down/up/right.

## Try it

1. Press `Ctrl-B %` to split the window into side-by-side panes.
2. Press `Ctrl-B h`, then `Ctrl-B l`, to move between them.
3. Press `Ctrl-B H` or `Ctrl-B L` to resize a pane by five cells.
4. Press `Ctrl-B x`, then `y`, to close the active pane.

## Panes

| Keys | Action |
| --- | --- |
| `Ctrl-B h/j/k/l` | Select the pane left/down/up/right. |
| `Ctrl-B H/J/K/L` | Resize the pane left/down/up/right by five cells. |
| `Ctrl-B Tab` / `Ctrl-B Shift-Tab` | Select the next/previous pane by number, not focus order. |
| `Ctrl-B "` | Split into panes stacked top and bottom. |
| `Ctrl-B %` | Split into panes side by side. |
| `Ctrl-B q` | Show pane numbers. |
| `Ctrl-B x` | Kill the active pane, after confirmation. |
| `Ctrl-B z` | Zoom or unzoom the active pane. |

New panes start in the current pane's directory. `Ctrl-J/K` still navigates
panes without a prefix. In Vim, those keys move through Vim windows and cross
to another tmux pane at the edge.

## Windows

| Keys | Action |
| --- | --- |
| `Ctrl-B c` | Create a window in the current pane's directory. |
| `Ctrl-B /` | Pick a window from a list, like FVWM's `Win-/`. |
| `Ctrl-B w` | Kill the whole window and all its panes, after confirmation. |
| `Alt-1` through `Alt-9` | Select a numbered window without a prefix. |
| `Alt-Left/Right` | Select the previous/next numbered window without a prefix. |
| `Alt-Shift-Left/Right` | Swap the window with its neighbor and follow it. |
| `Ctrl-B n/p` | Select the next/previous numbered window. |

`Alt-Left/Right` and `Ctrl-J/K` are deliberate exceptions to the prefix
pattern. Tmux windows start at number 1. `Ctrl-B w` no longer opens the window
list; use `Ctrl-B /` instead.

## Sessions and help

| Keys | Action |
| --- | --- |
| `Ctrl-B C` | Create a session in the current pane's directory. |
| `Ctrl-B P/N` | Switch to the previous/next session. |
| `Ctrl-B Q` | Kill the whole session, after confirmation. |
| `Ctrl-B ?` | Show all key bindings. |

`Ctrl-B q` now shows pane numbers, as in default tmux. To reload the config,
run `tmux source-file ~/.tmux.conf` in a shell. The three kill shortcuts,
`Ctrl-B x`, `Ctrl-B w`, and `Ctrl-B Q`, all ask before closing anything.

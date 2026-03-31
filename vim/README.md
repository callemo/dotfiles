```
VIMRC(1)              Unix Programmer's Manual              VIMRC(1)

NAME
     dot.vimrc -- personal editor configuration

SYNOPSIS
     vim

DESCRIPTION
     Dot.vimrc configures Vim 9.1 as a text processing environment.
     It requires vim9script; on older versions a guard loads minimal
     settings and exits.  No plugins are required for core operation.

     Four autoload modules supply all custom logic:

     plumb    Route text to the appropriate handler.  Given a word
              or selection, try in order: URL, wiki link, file:line,
              file, directory, text search.  URLs open in the system
              browser; files reuse existing windows; text searches
              set the / register.

     exec     Run external commands.  Cmd runs a shell command
              asynchronously, collecting output in a +Errors scratch
              buffer.  Lint and Fmt dispatch to per-filetype linters
              and formatters.  Rg greps with ripgrep(1).  Fts does
              full-text search via fts(1).  Toc populates the
              location list with lines matching a pattern.  Tmux
              sends lines to a tmux pane.  Yank copies text to the
              system clipboard via OSC 52.

     view     Manage windows and buffers.  Next and Prev cycle focus
              across Vim windows and tmux panes.  Dir reads a
              directory into a scratch buffer.  Close quits the last
              window or wipes the buffer.  Sort orders windows by
              name.  Selection returns the visual selection.  Trim
              strips trailing whitespace on write.

     plugins  Lazy loaders for optional packages.  Go loads vim-go
              on first encounter with a .go file.

COMMANDS
     :Cmd cmd              Run cmd; pipe range as stdin.
     :Send [target]        Send line or selection to tmux pane.
     :Lint [filetype]      Run linter.
     :Fmt [filetype]       Run formatter; range filters.
     :Rg args              Grep to location list.
     :Fts query            Full-text search to location list.
     :Toc [pattern]        Outline to location list.
     :Sort                 Sort windows by buffer name.
     :B /regex/[D]         List or delete matching buffers.

KEY BINDINGS
  Leader (space)
     !         Prompt for Cmd.
     .         lcd to file's directory.
     ;         Send to tmux.
     CR        Plumb word under cursor.
     B         Toggle directory browser.
     F         Copy relative path to clipboard.
     N         New split in file's directory.
     Q         Force-close buffer.
     f         Format.
     l         Lint.
     q         Close buffer.
     z         Zoom window.

  Visual
     !         Execute selection.
     ;         Send selection to tmux.
     CR        Plumb selection.
     *         Literal search for selection.

  Brackets
     ]a [a     Next/previous argument.
     ]b [b     Next/previous buffer.
     ]l [l     Next/previous location.
     ]q [q     Next/previous quickfix.
     ]t [t     Next/previous tab.

  Toggles (yo)
     b         Background.
     h         Hlsearch.
     i         Ignorecase.
     l         List.
     n         Number.
     p         Paste.
     r         Relativenumber.
     s         Spell.
     w         Wrap.

  Control
     C-j       Next window or tmux pane.
     C-k       Previous window or tmux pane.
     C-l       Clear search, matches, redraw.
     C-p       Fuzzy finder.

  Mouse
     Middle    Execute word under cursor.
     Right     Plumb word under cursor.
     2-Left    Statusline: close.  Body: select word.
     C-Left    Statusline: zoom.

     In visual mode, middle and right act on the selection.

  Terminal
     C-j       Next (handed off from terminal).
     C-k       Previous (handed off from terminal).
     C-r       Paste register.

  Dir buffer
     CR        Plumb entry.
     Middle    Execute entry.
     Right     Plumb entry.
     -         Up one directory.
     <leader>R Rename entry.
     <leader>D Delete entry.

FILES
     dot.vimrc              Main configuration.
     vim/autoload/plumb.vim Routing and dispatch.
     vim/autoload/exec.vim  External commands.
     vim/autoload/view.vim  Windows and buffers.
     vim/autoload/plugins.vim  Lazy plugin loading.
     ~/.vimrc.local         Host-local overrides, sourced last.
     ~/.vim/pack/default/   Native packages.

SEE ALSO
     vim(1), tmux(1), fts(1), fzf(1), rg(1)

DIAGNOSTICS
     Cmd prints "name: exit code" on completion.  A nonzero exit
     or nonempty output opens the +Errors buffer.

     Lint and Fmt report missing executables to the error line.

BUGS
     The version guard degrades silently on Vim 8 and below.

     Plumb cannot follow symlinks that resolve outside the working
     directory without an absolute path.

     Yank shells out to base64(1).
```

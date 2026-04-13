NAME             vimrc -- personal editor configuration

SYNOPSIS         vim

DESCRIPTION      Dot.vimrc configures Vim 9.1 as a text processing environment.
                 It requires vim9script. No plugins are required for core operation.

                 Four autoload modules supply all custom logic:

                 plumb
                      Route text to the appropriate handler. Given a word
                      or selection, try in order: URL, wiki link, file:line,
                      file, directory, text search. URLs open in the system
                      browser.

                 exec
                      Run external commands. Cmd runs a shell command
                      asynchronously. Lint and Fmt dispatch to per-filetype
                      linters and formatters. Rg greps. Fts does full-text search.
                      Toc populates the location list. Tmux sends lines to
                      a tmux pane. Yank copies text via OSC 52.

                 view
                      Manage windows and buffers. Expand selects the
                      structural block at the cursor. Next and Prev cycle
                      focus across Vim windows and tmux panes. Dir reads
                      a directory into a scratch buffer. Close quits the
                      last window. Sort orders windows by name. Selection
                      returns the visual selection. Trim strips trailing
                      whitespace.

                 plugins
                      Lazy loaders for optional packages.

                 Commands have a simple and regular structure:

                 :Cmd cmd
                      Run cmd; pipe address as stdin.
                 :Send [target]
                      Send line or selection to tmux pane.
                 :Lint [filetype]
                      Run linter.
                 :Fmt [filetype]
                      Run formatter.
                 :Rg args
                      Grep to location list.
                 :Fts query
                      Full-text search to location list.
                 :Toc [pattern]
                      Outline to location list.
                 :Sort
                      Sort windows by buffer name.
                 :B /regex/[D]
                      List or delete matching buffers.

                 Key bindings are as follows:

                 Leader (space)
                      ! Prompt for Cmd.
                      . lcd to file's directory.
                      ; Send to tmux.
                      CR Plumb.
                      B Toggle directory browser.
                      N New split in file's directory.
                      y Copy relative path.
                      Y Copy absolute path.
                      Q Force-close buffer.
                      f Format.
                      l Lint.
                      q Close buffer.
                      z Zoom window.

                 Visual
                      <leader>! Execute selection.
                      <leader>; Send selection to tmux.
                      <leader>CR Plumb selection.
                      * Literal search for selection.

                 Brackets
                      ]a [a Next/previous argument.
                      ]b [b Next/previous buffer.
                      ]l [l Next/previous location.
                      ]q [q Next/previous quickfix.
                      ]t [t Next/previous tab.

                 Toggles (yo)
                      b Background. h Hlsearch. i Ignorecase.
                      l List. n Number. p Paste.
                      r Relativenumber. s Spell. w Wrap.

                 Control
                      C-j Next window/tmux pane.
                      C-k Previous window/tmux pane.
                      C-l Clear search, redraw.

FILES            /tmp/Errors temporary
                 dot.vimrc is used to implement the configuration.

OWNER            cgj

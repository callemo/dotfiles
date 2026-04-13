NAME             vimrc -- text editor configuration

SYNOPSIS         vim

DESCRIPTION      Vimrc configures Vim 9.1 as an interactive text editor.
                 Plain files display as text; directories display as
                 lists of their components, with subdirectory names
                 suffixed by a slash.

              Mouse
                 The behavior of each mouse button is as follows.

                 Button 1 selects text. Double-clicking on a bracket or
                 quote selects contents between delimiters; otherwise
                 selects the word. Double-clicking the status line closes
                 the window. Ctrl-click zooms the window.

                 Button 2 executes the selected text or word under cursor
                 as a shell command. Output appears in an Errors buffer.
                 On the active window's status line, zooms the window.

                 Button 3 locates or acquires the file described by the
                 indicated text. If the text is a URL, open the browser.
                 If the text is a wiki link ([[name]]), open it. If the
                 text names an existing file, open it. If the text is a
                 file name followed by a colon and line number (file.c:27),
                 open the file and go to that line. In a quickfix buffer,
                 jump to the entry under cursor. Otherwise search for the
                 text in the current buffer.

              Directory context
                 Each window's buffer names a directory: explicitly if the
                 window holds a directory; implicitly if it holds a file.
                 This directory provides context for interpreting relative
                 file names.

              Directory buffers
                 In directory buffers, additional bindings apply:

                      CR       Open file or descend into directory
                      -        Go up one directory level
                      r        Rename item under cursor (leader)
                      d        Delete item under cursor (leader)

              Commands
                 Commands have a simple and regular structure: a command
                 name, possibly followed by arguments. Some commands are
                 built-ins executed directly by vimrc:

                 Dump Write the state of vim to the file name, if specified,
                      or $PWD/vim.dump by default. Tab pages, windows,
                      cursor positions, and unsaved buffer contents are
                      recorded. Unlike Acme, which runs one instance per
                      namespace, vim runs per-terminal, so we dump in the
                      working directory.

                 Load Restore the state of vim from a file (default
                      $PWD/vim.dump) created by the Dump command.

                 Toc  Populate location list with an outline of the current
                      buffer. Patterns are per-filetype.

                 Sort Arrange windows in the tab from top to bottom in
                      lexicographical order based on their names.

                 Cmd  Run a shell command. Addressed lines become stdin;
                      output replaces them or appears in Errors.

                 Fmt  Run per-filetype formatter on buffer.

                 Lint Run per-filetype linter; output to Errors buffer.

                 Rg   Grep; output to location list.

                 Fts  Full-text search; output to location list.

                 Send Send line or selection to a tmux pane.

                 B    List buffers matching regex; with trailing D, delete
                      them.

              Keybindings
                 Leader is space. Bindings:

                      !        Prompt for shell command
                      CR       Plumb word or selection
                      space    Expand selection to structural block
                      .        Change local directory to file's directory
                      ;        Send line to tmux pane
                      B        Toggle directory browser
                      D        Dump session state
                      N        New file in current file's directory
                      f        Format buffer
                      l        Lint buffer
                      q        Close buffer
                      Q        Force-close buffer
                      y        Yank relative path to clipboard
                      Y        Yank absolute path to clipboard
                      z        Zoom window

                 In visual mode, ! executes selection, ; sends selection
                 to tmux, CR plumbs selection, and * searches for selection.

                 Brackets navigate:

                      ]a [a    Next/previous argument
                      ]b [b    Next/previous buffer
                      ]l [l    Next/previous location
                      ]q [q    Next/previous quickfix
                      ]t [t    Next/previous tab

                 Toggles (yo prefix):

                      b  Background     h  Hlsearch      i  Ignorecase
                      l  List           n  Number        p  Paste
                      r  Relativenumber s  Spell         w  Wrap

                 Control keys:

                      C-j  Next window or tmux pane
                      C-k  Previous window or tmux pane
                      C-l  Clear search, redraw
                      C-p  FZF file finder
                      +    Grow window height

FILES            $PWD/vim.dump
                      default file for Dump and Load

SEE ALSO         acme(1)

OWNER            cgj

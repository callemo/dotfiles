```
VIMRC(1)              Unix Programmer's Manual              VIMRC(1)

NAME
     dot.vimrc -- personal editor configuration

SYNOPSIS
     vim

DESCRIPTION
     Dot.vimrc configures Vim 9.1 as a compiled, strictly typed
     text processing environment.  It requires no plugins for
     core operation.  On Vim versions lacking vim9script support,
     a version guard loads minimal settings and exits.

     The architecture follows three principles: data dominates,
     the keyboard and mouse are peer frontends over shared
     functions, and all custom logic compiles to bytecode at
     startup via def.

  Execution
     Cmd cmd                Run cmd asynchronously through the
                            shell.  Output and errors collect in
                            a scratch buffer named +Errors.  When
                            a range is given, the selected lines
                            are piped as standard input.

     Send [target]          Send the current line or visual
                            selection to a tmux pane.  Target is
                            remembered per window.

     Lint [filetype]        Run the linter registered for the
                            current filetype.

     Fmt [filetype]         Run the formatter registered for the
                            current filetype.  A visual range
                            filters through the formatter.

  Navigation
     Plumb wdir attr data   Route data to the appropriate handler.
                            Tries, in order: URL, wiki link,
                            file:line, file, directory, text
                            search.  URLs open in the system
                            browser.  Files reuse existing windows.
                            Text searches set the / register.

     Rg args                Grep with ripgrep, results to the
                            location list.

     Fts query              Full-text search via fts(1), results
                            to the location list.

     Oln [pattern]          Populate the location list with lines
                            matching pattern (default: markdown
                            headings).

  Buffers
     Dir path [replace]     Read a directory into a scratch buffer
                            using ls -aF.  If replace is true, the
                            current buffer is reused.

     B /regex/[D]           List buffers matching regex.  Append D
                            to wipeout matched buffers.

     Sort                   Sort visible windows by buffer name.

  Focus
     FocusNext              Cycle focus to the next Vim window.
                            At the last window, hand off to the
                            next tmux pane.

     FocusPrev              Cycle focus to the previous Vim window.
                            At the first window, hand off to the
                            previous tmux pane.

  Data Extraction
     GetVisualText          Return the visual selection as a string.

     DirEntry               Return the current line stripped of
                            ls -F suffixes.

     SetVisualSearch        Set the / register to a literal match
                            of the visual selection.

KEY BINDINGS
  Leader (space)
     !         Prompt for a command and execute via Cmd.
     .         Set the local directory to the file's directory.
     ;         Send current line or selection to tmux.
     CR        Plumb the word under cursor.
     B         Toggle directory buffer.
     F         Copy relative file path to clipboard.
     Q         Force-close buffer.
     f         Format file.
     l         Lint file.
     q         Close buffer.
     z         Zoom current window.

  Visual
     !         Execute selection via Cmd.
     ;         Send selection to tmux.
     CR        Plumb the visual selection.
     *         Search for the visual selection literally.

  Brackets
     ]a [a     Next/previous argument.
     ]b [b     Next/previous buffer.
     ]l [l     Next/previous location.
     ]q [q     Next/previous quickfix.
     ]t [t     Next/previous tab.

  Toggles (yo)
     b         Background light/dark.
     h         Highlight search.
     i         Ignore case.
     l         List mode.
     n         Line numbers.
     p         Paste mode.
     r         Relative numbers.
     s         Spell check.
     w         Line wrap.

  Control
     C-j       FocusNext.
     C-k       FocusPrev.
     C-l       Clear search, matches, and redraw.
     C-p       Fuzzy file finder.

  Mouse
     Middle    Execute word under cursor via Cmd.
     Right     Plumb word under cursor.
     2-Left    Double-click statusline closes window;
               double-click body selects word.
     C-Left    Control-click statusline zooms window.

     In visual mode, middle and right operate on the
     selection instead of the word under cursor.

  Terminal
     C-j       FocusNext (handed off from terminal mode).
     C-k       FocusPrev (handed off from terminal mode).
     C-r       Paste register into terminal.

  Dir Buffer
     CR        Plumb the entry.
     Middle    Execute the entry via Cmd.
     Right     Plumb the entry.
     -         Go up one directory.

FILES
     dot.vimrc              Main configuration (vim9script).
     ~/.vimrc.local         Host-local overrides, sourced last.
     ~/.vim/pack/default/   Native package directory.

SEE ALSO
     vim(1), tmux(1), fts(1), fzf(1), rg(1)

DIAGNOSTICS
     Cmd prints "name: exit code" on job completion.  When the
     exit code is nonzero or output is nonempty, the +Errors
     buffer is opened in a split.

     Lint and Fmt report missing executables to the error line.

BUGS
     The version guard silently degrades to set nocompatible
     on Vim 8 and below.  No warning is issued.

     Plumb cannot follow symlinks that resolve outside the
     working directory without an absolute path.

     OscYank shells out to base64(1) and will fail if it is
     not in PATH.
```

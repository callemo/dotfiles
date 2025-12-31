# Dotfiles

This is a collection of configuration files and small utilities for Unix systems.
The tools here follow the old Unix tradition: each program does one thing and does it well.

## What's Here

The repository contains two kinds of things: configuration files for editors and shells,
and a set of small command-line utilities. The configuration files live in the root
directory as `dot.*` files that get symlinked to your home directory by the install script.
The utilities live in `bin/` and handle common text processing tasks.

Most of the utilities are filters—they read from standard input and write to standard output,
so you can combine them with pipes. This makes them composable in the Unix tradition.

## Installation

Run `./install` to symlink configuration files and install vim plugins.
The script won't overwrite existing files.

To use the utilities, add `bin/` to your PATH or source `init.sh`:

```sh
source ~/dotfiles/init.sh
```

## Some Useful Tools

**snip** expands code templates for shell scripts, Go programs, Python functions, and more.

**fts** provides full-text search for notes and documents using SQLite's FTS5 engine.

**tabfmt** formats tabular data into aligned columns. **tabmd** outputs Markdown tables.

**csvtab** converts CSV to tab-separated format, handling quoted fields correctly.

**noco** strips ANSI color codes from text.

**pareto** adds percentage and cumulative percentage columns for Pareto analysis.

**urlencode** and **urldecode** handle percent-encoding, with line-by-line mode.

**camel** and **snake** convert between camelCase and snake_case.

**rgsub** performs recursive search and replace using regular expressions.

**template** does text substitution with placeholders like `{{1}}` and `{{2}}`.

**n** manages notes with wiki-style linking and tagging.

**md** processes Markdown files with Pikchr diagram support.

**dt** displays current date/time in ISO 8601 format (with flags for UTC, basic, week formats).

**pomodoro** is a Pomodoro timer (8 cycles of 25-minute work with 5-minute breaks).

The git utilities (**gst**, **gd**, **glog**, **grlog**) are shortcuts for common git operations.

## Text Processing Philosophy

These tools embrace the Unix pipe model. Instead of building monolithic programs
that try to do everything, each utility solves one problem well. You combine them
to solve larger problems.

For example, to convert a CSV file to a nicely formatted Markdown table:

```
csvtab < data.csv | tabmd
```

Or to search for a pattern in your notes and format the results:

```
fts "search term" | tabfmt
```

## Configuration Files

The repository includes dotfiles for various tools. Run `./install` to symlink them to your home directory.

| File                   | Purpose                                                       |
| ---------------------- | ------------------------------------------------------------- |
| **dot.vimrc**          | Vim configuration - sensible defaults, no plugins required    |
| **dot.tmux.conf**      | Tmux configuration - vi mode keys, mouse support, status line |
| **dot.Xdefaults**      | X configuration                                               |
| **dot.xsession**       | X session startup script                                      |
| **dot.fvwmrc**         | FVWM window manager configuration                             |
| **dot.alacritty.toml** | Alacritty terminal emulator configuration                     |
| **dot.nexrc**          | Nex/vi editor configuration                                   |
| **dot.ripgreprc**      | ripgrep default settings                                      |
| **dot.perltidyrc**     | Perl::Tidy code formatter configuration                       |
| **dot.prettierrc**     | Prettier code formatter settings                              |
| **dot.pylintrc**       | Pylint Python linter configuration                            |

The install script also sets up:

- **lib/** → **~/lib** - Contains plumbing rules and auxiliary files
- Global Git excludesfile pointing to `.gitignore`

## Vim Plugins

**vim/get** installs plugins from GitHub to `~/.vim/pack/default/start/`.
Use the `-o` flag for optional plugins that load with `:packadd`.

## The Acme Connection

The `acme/` directory contains utilities for the Acme text editor. Acme is a different
kind of editor—it treats text editing as part of a larger programming environment.
The tools here extend Acme with automatic formatting, go-to-definition, and other
programmer conveniences.

**afmt** formats code using language-specific formatters (goimports, black, rustfmt, prettier, perltidy).

**agopls** starts acme-lsp with gopls. **decl** jumps to definition. **uses** finds references.
**rename** renames symbols.

**ind** and **unind** indent/unindent text. **quote** prefixes lines with `> `.
**untab** converts tabs to spaces. **areload** reloads a window from disk.

These scripts communicate with Acme via the Plan 9 filesystem protocol (9p).

## Tests

Run `./test` to exercise the utilities. The test script runs each tool against
known inputs and compares the output to expected results. It's not fancy, but it catches regressions.

## Design Notes

The utilities here favor simplicity over features. They handle the common cases well
and let you combine them for the uncommon ones. Error messages are brief and to the point.
Options follow the traditional Unix style with single letters and minimal configuration.

Most tools are written in shell script or Python, chosen for clarity rather than performance.
They're meant to be read and modified. If you need something slightly different,
fork the code and change it.

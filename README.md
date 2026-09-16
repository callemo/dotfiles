# Dotfiles

These are my dotfiles and small Unix tools.

They are not a product. I do not try to make them portable, complete, or easy
for strangers to install. Copy whatever helps. Ignore the rest.

The goal is radical simplicity: plain files, small programs, pipes, text, and
systems you can understand without a framework.

## Install

```sh
./install
```

The installer links `dot.*` files into `$HOME` and files under `dot.config/`
into `~/.config/`. It adds `init.sh` to shell rc files and installs Vim
plugins with `vim/get`.

Host overrides under `t490/` link only on t490. An unprivileged hook then
applies its named desktop settings. Managed host fragments load before the
operator's `.tmux.conf.local` and `.vimrc.local` files. The installer never
edits those files.

### X11 fonts

    doas pkg_add spleen

xterm loads Spleen's 12x24 bitmap through Xft. DejaVu Sans Mono, from
base X11, is the only fallback. Characters in neither font appear as boxes.
ToolStatus uses the core X font path. `dot.xsession` adds this path at login.
Log in again after you install the fonts.

## Structure

- `dot.*`: configuration files linked into `$HOME`
- `dot.config/`: configuration files linked into `~/.config/`
- `bin/`: small commands, mostly filters
- `acme/`: Acme helpers over 9p
- `vim/`: Vim runtime files and plugin installer
- `lib/`: plumbing rules and support files
- `t490/`: unprivileged T490 desktop files and host overrides
- `testdata/`: fixtures

`init.sh` puts the usual local paths first and sets a few shell defaults.
The T490 XTerm, FVWM, and GTK configuration uses a Gruvbox Material palette.
Terminal programs use its ANSI colors where possible. See `t490/README.md`
for the desktop settings that this repository manages.

## Tools

The tools in `bin/` format tables, convert CSV, search notes, expand snippets,
strip ANSI escapes, encode URLs, rewrite text, and wrap common git commands.

Most read stdin and write stdout:

```sh
csvtab <data.csv | tabmd
fts 'search term' | tabfmt
```

I use these tools every day:

- `n` manages notes, tags, wiki links, and backlinks.
- `snip` expands code templates.
- `fts` searches text with SQLite FTS5.
- `rgsub` rewrites directory trees with regular expressions.
- `tabfmt`, `tabmd`, and `csvtab` format tabular text.
- `md` processes Markdown with Pikchr diagrams.
- `pp` preprocesses plain text with small `#pp:` directives.

I keep the other tools small enough to read before use.

## Vim and Acme

Vim is the main editor here. I aim to keep its configuration readable.
`dot.vimrc` contains Vim declarations. Autoload files define behavior.
Vim loads plugins only when needed.

Acme scripts live in `acme/`. They communicate with Acme through 9p to format
code, jump to definitions, find uses, rename symbols, indent text, and reload windows.

## Tests

```sh
./test
```

The tests use plain shell, Python `unittest`, and headless Vim. They detect
the regressions I care about.

## Design

Prefer a file to a database.
Prefer a script to a service.
Prefer a pipe to an API.
Prefer a convention to configuration.

Keep programs small enough to discard and clear enough to copy.
Split a tool when it becomes too complex.
Simplify a system when it needs a story to explain it.

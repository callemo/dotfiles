# Dotfiles

These are my dotfiles and small Unix tools.

They are not a product. I do not try to make them portable, complete, or easy
for strangers to install. Copy whatever helps. Ignore the rest.

The point is radical simplicity: plain files, small programs, pipes, text, and
systems you can understand without a framework.

## Install

```sh
./install
```

The installer links `dot.*` files into `$HOME`, links files under `dot.config/`
into `~/.config/`, wires `init.sh` into shell rc files, and installs Vim
plugins with `vim/get`.

On OpenBSD, `./install` also runs local setup; see `openbsd.md`.

## Shape

- `dot.*` — config files linked into `$HOME`
- `dot.config/` — config files linked into `~/.config/`
- `bin/` — small commands, mostly filters
- `acme/` — Acme helpers over 9p
- `vim/` — Vim runtime files and plugin installer
- `lib/` — plumbing rules and support files
- `testdata/` — fixtures

`init.sh` puts the usual local paths first and sets a few shell defaults.

## Tools

The tools in `bin/` do ordinary jobs: format tables, convert CSV, search notes,
expand snippets, strip ANSI escapes, encode URLs, rewrite text, and wrap common
git commands.

Most read stdin and write stdout:

```sh
csvtab <data.csv | tabmd
fts 'search term' | tabfmt
```

The important tools are the ones I use every day:

- `n` manages notes, tags, wiki links, and backlinks.
- `snip` expands code templates.
- `fts` searches text with SQLite FTS5.
- `rgsub` rewrites trees with regular expressions.
- `tabfmt`, `tabmd`, and `csvtab` shape tabular text.
- `md` processes Markdown with Pikchr diagrams.
- `pp` preprocesses plain text with small `#pp:` directives.

The rest are deliberately small enough to read before using.

## Vim and Acme

Vim is the main editor here. The config aims to stay readable: Vim declarations
in `dot.vimrc`, behavior in autoload files, plugins loaded only when needed.

Acme scripts live in `acme/`. They format code, jump to definitions, find uses,
rename symbols, indent text, and reload windows by talking to Acme through 9p.

## Tests

```sh
./test
```

The tests are plain shell, Python `unittest`, and headless Vim. They catch the
regressions I care about.

## Design

Prefer a file to a database, a script to a service, a pipe to an API, and a
convention to configuration.

Programs should be small enough to throw away and clear enough to copy. When a
tool grows clever, split it. When a system needs a story, simplify it.

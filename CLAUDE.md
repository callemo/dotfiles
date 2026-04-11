# CLAUDE.md

## Commands
```sh
./test                           # Run full test suite
python3 -m unittest test_snip.py # Run snippet unit tests only
./install                        # Symlink dotfiles to home directory
```

## Style
- K&R flat logic — early exit/continue over nested if/else; `||`/`&&` guards for single-action checks
- Tabs, not spaces (shell and vim)
- Naming: short, verb-first, no redundancy with namespace
- Commit messages: terse, like the Go authors

## Shell Scripts
- `bin/overwrite` exists — do not inline an overwrite function, use it from PATH
- `fileline pattern line file` — 3-arg helper delegating to `bin/overwrite`
- Vim plugin loop uses heredoc for stdin; commands inside must redirect `</dev/null`
- `dot.config/` in `install`: contents mirrored into `~/.config/` individually, not symlinked as a dir
- `dot.*` files are symlinked to `~/.*` by `./install` (e.g. `dot.vimrc` → `~/.vimrc`)

## Vim (`dot.vimrc`)
Requires Vim 9.1+ (patch 1-10 minimum for `getregion()`). Tested on 9.1.1706.
Four autoload modules: `plumb` (routing), `exec` (commands), `view` (windows/buffers), `plugins` (lazy loaders). vimrc is declarations only — no `def`/`enddef` except `g:Err`.
- Acme model: middle-click executes the "dot" (selection or word AS the command) — selection is never stdin to another command
- `view#Click2`: double-click on/near a bracket or quote selects contents between delimiters (`vi`, not `va`) — Acme excludes delimiters; verified against `plan9port/src/cmd/acme/text.c:textdoubleclick()`
- `exec.Cmd`: always `/bin/sh -c cmd` — matches Acme's `rc -c` model, no `&shell`
- `exec.Cmd` without range: `in_io: null` (no stdin, like Acme)
- `exec.Cmd` with range: buffer lines are stdin (`:%Cmd sort` pipes lines to `sort`)
- `view#Scratch()` is the shared scratch-buffer factory — `exec.vim` calls it via legacy syntax to avoid circular import
- Dir buffers are `buftype=nofile` — editable scratch, no `nomodifiable`
- Autocmd bodies must use `call` for autoload functions (direct-call causes E1091)
- Ranged ex-commands in `def` need `:` prefix (`:%s/...` not `%s/...` — E1050)
- Option strings (`set tabline=`) use legacy `module#Func()` syntax (global scope eval)
- Terminal `<c-w>:` mappings use legacy `call module#Func()` syntax
- Circular imports avoided via legacy `module#Func()` (plumb→view uses `view#Dir()`)
- `test.vim` needs `runtime autoload/module.vim` before `exists()` checks

## Snippet System (`bin/snip`)
Python code generator using `IndentBuilder`; snippets registered via `@snippet` decorator. Categories: sh*, go*, awk*, py*, n*.

## Acme (`acme/`)
Scripts talk to Acme via 9p (`9p read/write acme/$winid/{body,data,ctl,addr}`). Key env vars: `$winid`, `$samfile`.

## Notes (`bin/n`)
- `tag` accepts multiple tags as AND query (`n tag business safari`)
- `xref` rewrites `References:` frontmatter from reverse links; uses `$NROOT` as default dir

## Testing
- Always run `./test`; do not invoke `test.sh` directly
- Update `test.exp` if changing expected output format
- Fixtures go under `testdata/`

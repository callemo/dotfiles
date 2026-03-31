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

## Vim (`dot.vimrc`)
Four autoload modules: `plumb` (routing), `exec` (commands), `view` (windows/buffers), `plugins` (lazy loaders). vimrc is declarations only — no `def`/`enddef` except `g:Err`.
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

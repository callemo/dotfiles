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
- `dot.config/` in `install`: contents mirrored into `~/.config/` individually, not symlinked as a dir
- `dot.*` files are symlinked to `~/.*` by `./install` (e.g. `dot.vimrc` → `~/.vimrc`)

## Vim (`dot.vimrc`)
Requires Vim 9.1+. Tested on 9.1.1706.
Autoload modules: `plumb` (routing), `exec` (commands), `view` (windows/buffers), `text` (text ops), `plugins` (lazy loaders). vimrc is declarations only — no `def`/`enddef` except `g:Err`.
- Acme model: middle-click executes the "dot" (selection or word AS the command) — selection is never stdin to another command
- `view#Click2`: double-click on/near a bracket or quote selects contents between delimiters (`vi`, not `va`) — Acme excludes delimiters; verified against `plan9port/src/cmd/acme/text.c:textdoubleclick()`
- `text#Selection`: yanks via register `z` (saved/restored with `getreginfo`/`setreg`), branches on `mode()` — when called from `<Cmd>` in `xnoremap` we are still in visual mode, so yank live; otherwise `gv` reselects. Avoid `getregion()` — it landed at patch 9.1.0040 and not all 9.1 builds carry it. `noautocmd` suppresses `TextYankPost`/OSC 52.
- Dir buffers are `buftype=nofile` — Acme-style scratch, editable, NO auto-refresh on `BufEnter` (the autocmd skips `&filetype ==# 'dir'`). Manual refresh: `R` in the buffer, or `-`/`<leader>r`/`<leader>d` which re-call `view#Dir()`. Initial `:e foo/` still loads via `BufReadCmd`.
- `exec.Cmd`: always `/bin/sh -c cmd` — matches Acme's `rc -c` model, no `&shell`
- `exec.Cmd` without range: `in_io: null` (no stdin, like Acme)
- `exec.Cmd` with range: buffer lines are stdin (`:%Cmd sort` pipes lines to `sort`)
- `view#Scratch()` is the shared scratch-buffer factory — `exec.vim` calls it via legacy syntax to avoid circular import
- Autocmd bodies must use `call` for autoload functions (direct-call causes E1091)
- Vim9 `def` compiles lazily — `exists('*x')` only checks declaration. Test by *calling*; for visual-mode functions drive `xnoremap <buffer> <F2> <Cmd>…<CR>` + `feedkeys("v…\<F2>\<Esc>", 'x')` (mode is `v` inside, so `gv` has nothing to restore)
- Debug headless vim: `vim -Nu NONE -n -V1/tmp/vlog -es -S test.vim </dev/null` then grep the log
- `test.vim` needs `runtime autoload/module.vim` before `exists()` checks
- `vim.dump` is in the global gitignore (`~/.gitignore`)

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

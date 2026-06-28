# Agent instructions

## Commands
- `./test`: full suite; always use it, never `test.sh`.
- `python3 -m unittest test_snip.py`: snippet tests.
- `./install`: link dotfiles home.

## Style
- K&R flat logic: early exit/continue; avoid nested `if/else`; use `||`/`&&` guards for one-action checks.
- Tabs in shell/Vim. Names short, verb-first, no namespace echo. Commits terse, Go-style.

## Shell/install
- Use `bin/overwrite` from PATH; never inline overwrite.
- `fileline pattern line file`: 3 args; delegates to `bin/overwrite`.
- `install`: mirror each `dot.config/*` into `~/.config/` (no `dot.config/` symlink); symlink `dot.*` -> `~/.*` (`dot.vimrc` -> `~/.vimrc`).

## Vim (`dot.vimrc`)
Vim 9.1+; tested 9.1.1706. Autoload: `plumb` routes, `exec` commands, `view` windows/buffers, `text` text ops, `plugins` lazy loads. Declarations only; no `def`/`enddef` except `g:Err`.
- Acme: middle-click runs dot (selection or word) as command; selection never becomes stdin.
- `view#Click2`: double-click on/near bracket/quote selects inside delimiters (`vi`, not `va`); Acme excludes delimiters; see `plan9port/src/cmd/acme/text.c:textdoubleclick()`.
- `text#Selection`: yank via `z` register; save/restore with `getreginfo`/`setreg`; branch on `mode()`. From `<Cmd>` in `xnoremap`, mode stays visual: yank live; else `gv` reselects. Avoid `getregion()` (patch 9.1.0040; missing in some 9.1 builds). `noautocmd` suppresses `TextYankPost`/OSC 52.
- Dir buffers: `buftype=nofile`, Acme scratch, editable, no `BufEnter` auto-refresh (autocmd skips `&filetype ==# 'dir'`). Refresh with `R`, or `-`/`<leader>r`/`<leader>d` (re-call `view#Dir()`). Initial `:e foo/` still uses `BufReadCmd`.
- `exec.Cmd`: always `/bin/sh -c cmd` (Acme `rc -c`; ignore `&shell`). No range: `in_io: null` (no stdin). Range: range lines -> stdin (`:%Cmd sort` pipes all lines to `sort`).
- `view#Scratch()`: shared scratch-buffer factory; `exec.vim` uses legacy syntax to avoid circular import.
- Autocmd bodies must `call` autoload functions; direct calls cause E1091.
- Vim9 `def` compiles lazily; `exists('*x')` sees declarations only. Test by calling. Visual tests: `xnoremap <buffer> <F2> <Cmd>…<CR>` + `feedkeys("v…\<F2>\<Esc>", 'x')`; mode is `v` inside, so `gv` has nothing to restore.
- Debug headless: `vim -Nu NONE -n -V1/tmp/vlog -es -S test.vim </dev/null`; grep log.
- `test.vim`: `runtime autoload/module.vim` before `exists()`.
- `vim.dump`: global gitignore (`~/.gitignore`).

## Snippets (`bin/snip`)
Python generator using `IndentBuilder`; snippets use `@snippet`; categories `sh*`, `go*`, `awk*`, `py*`, `n*`.

## Acme (`acme/`)
Scripts use 9p (`9p read/write acme/$winid/{body,data,ctl,addr}`); env: `$winid`, `$samfile`.

## Notes (`bin/n`)
- `tag`: multiple tags form AND query (`n tag business safari`).
- `xref`: rewrite `References:` frontmatter from reverse links; default dir `$NROOT`.

## Testing
- Update `test.exp` if expected output format changes.
- Put fixtures in `testdata/`.

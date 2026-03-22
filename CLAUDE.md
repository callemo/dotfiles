# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository containing shell configuration files, utility scripts, and text editor configurations following Unix conventions. Designed to work across different Unix-like systems.

## Common Development Commands

### Testing
```sh
./test                        # Run full test suite (unit tests + integration tests)
python3 -m unittest test_snip.py  # Run only snippet system unit tests
diff -u test.exp test.out     # Verify test output after running ./test
```

### Installation
```sh
./install                      # Symlink dotfiles to home directory
./vim/get <github_url>        # Install vim plugin from GitHub
./vim/get -o <github_url>     # Install optional vim plugin (to ~/.vim/pack/default/opt)
```

## Architecture and Code Organization

### Directory Structure
- `bin/` - Command-line utilities (filters and tools)
- `acme/` - Acme editor integration scripts
- `vim/` - Vim configuration and plugin manager
- `lib/` - Configuration files (plumbing rules, etc.)
- `dot.*` - Dotfiles symlinked to `~/.*` by install script

### Key Architectural Patterns

#### Snippet System (`bin/snip`)
Python code generator using `IndentBuilder`; snippets registered via `@snippet` decorator in `SNIPPETS` dict. Categories: shell (sh*), Go (go*), AWK (awk*), Python (py*), notes (n*).

#### Acme Integration (`acme/`)
Scripts talk to Acme via 9p (`9p read/write acme/$winid/{body,data,ctl,addr}`). Key env vars: `$winid`, `$samfile`. Pattern in `acme/afmt`: save position → format → restore.

#### Filter Pattern (Text Processing Tools)
All text utilities follow consistent filter architecture:
- Read from stdin, write to stdout (composable via pipes)
- Options via `getopts` with consistent flags (-F, -d, -h)
- Usage info extracted from header comments via `sed -En '2,/^[^#]/ s/^# //p'`
- Examples: `tabfmt`, `csvtab`, `urlencode`, `noco`, `template`

#### Vim Plugin Management (`vim/get`)
Minimal plugin manager using vim8 native package system:
- Plugins cloned to `~/.vim/pack/default/start/` (auto-loaded)
- Optional plugins go to `~/.vim/pack/default/opt/` (manual load via `:packadd`)
- Uses shallow clone (`--depth 1`) to minimize disk usage
- Auto-generates helptags after installation

#### Full-Text Search (`bin/fts`)
SQLite FTS5-based search for markdown and text files:
- Database: `fts.db` in current directory (project-scoped, not global)
- Porter stemming tokenizer with prefix indexing (2, 3, 4 characters)
- Index rebuild: `-i` flag (finds all .txt and .md files in current tree)
- Near search: `-n` flag wraps query in `NEAR($q, 100)` for paragraph-level matches
- Output: TSV format (file path, snippet with 10 words context)

#### Preprocessor (`bin/pp`)
AWK-based minimal C-style preprocessor:
- Directives: `#pp:ifdef S`, `#pp:ifndef S`, `#pp:endif`, `#pp:include F`
- Symbols defined via `-Dsymbol` flags (membership only, no values)
- Detects circular includes; reads stdin if no files given

#### Notes Tool (`bin/n`)
- `tag` accepts multiple tags and treats them as an AND query (for example, `n tag business safari`)
- `xref` sub-command (or standalone `bin/xref [dir]`) rewrites `References:` frontmatter from reverse links; normalizes `[[Z/R/...]]` and `[[Z/R/n/...]]` targets; uses `$NROOT` env var as default dir

### Shell Script Conventions
- POSIX compliance preferred (works across bash, zsh, ksh)
- Error handling: `log()` writes to stderr, `fatal()` exits with error
- Help text: embedded in comments at top of file, extracted via sed pattern
- Working directory: scripts use `cd "${0%/*}"` or absolute paths to avoid dependency on pwd
- PATH management: `init.sh` uses `_pathinsert()` to prepend dirs to PATH without duplicates
- Indentation: tabs only (no spaces) in all shell scripts
- Style: K&R flat logic — early exit/continue over nested if/else; `||`/`&&` guards for single-action checks
- `fileline pattern line file` — 3-arg helper (ERE pattern to match/replace, exact line to write, target file); delegates to `bin/overwrite` for atomic rewrites; matches style in `~/code/devops/*/lib.sh`
- `bin/overwrite` exists — do not inline an overwrite function in scripts, use it from PATH
- Vim plugin loop uses heredoc for stdin; commands inside must redirect `</dev/null` or git will consume heredoc lines
- `dot.config/` special case in `install`: contents mirrored into `~/.config/` tree individually, not symlinked as a dir
- Project Claude settings: `.claude/settings.local.json` (gitignored; hooks, extra dirs, personal overrides)

### Testing Strategy
The `./test` script follows a two-phase approach:
1. **Unit tests first**: Runs Python unittest suite for `snip` tool
2. **Integration tests**: Runs utilities with known inputs, captures output to `test.out`
3. **Verification**: Compares `test.out` against `test.exp` using `diff -u`

When modifying utilities:
- Always run `./test`; do not invoke `test.sh` directly
- Store reusable integration fixtures under `testdata/` and keep `test.sh` focused on orchestration
- Update `test.exp` if changing expected output format
- Integration tests are inline in `./test` script (not separate files)
- Test coverage focuses on common cases and edge conditions (empty input, special chars)

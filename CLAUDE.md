# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository containing shell configuration files, utility scripts, and text editor configurations following Unix conventions. Designed to work across different Unix-like systems.

## Common Development Commands

### Testing
```bash
./test                        # Run full test suite (unit tests + integration tests)
python3 -m unittest test_snip.py  # Run only snippet system unit tests
diff -u test.exp test.out     # Verify test output after running ./test
```

### Installation
```bash
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
Python-based code generation system using the `IndentBuilder` class:
- Snippets registered in `SNIPPETS` dictionary mapping names to generator functions
- Generator functions receive `IndentBuilder` instance and args list
- `IndentBuilder` maintains indentation level and builds output via `write()`, `indent()`, `dedent()`
- Template categories: shell (sh*), Go (go*), AWK (awk*), Python (py*), notes (n*)
- Adding new snippets: define function with `@snippet` decorator (or manually add to SNIPPETS dict)

#### Acme Integration (`acme/`)
Scripts communicate with Acme via Plan 9 filesystem protocol (9p):
- `9p read acme/$winid/body` - read window content
- `9p write acme/$winid/data` - replace window content
- `9p write acme/$winid/ctl` - send control commands (mark, nomark, dot=addr, show)
- `9p rdwr acme/$winid/addr` - get/set cursor position
- Key pattern in `acme/afmt`: save position → format code → restore position
- Scripts use environment variables: `$winid` (window ID), `$samfile` (filename)

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

### Shell Script Conventions
- POSIX compliance preferred (works across bash, zsh, ksh)
- Error handling: `log()` writes to stderr, `fatal()` exits with error
- Help text: embedded in comments at top of file, extracted via sed pattern
- Working directory: scripts use `cd "${0%/*}"` or absolute paths to avoid dependency on pwd
- PATH management: `init.sh` uses `_merge_path()` to avoid duplicates

### Testing Strategy
The `./test` script follows a two-phase approach:
1. **Unit tests first**: Runs Python unittest suite for `snip` tool
2. **Integration tests**: Runs utilities with known inputs, captures output to `test.out`
3. **Verification**: Compares `test.out` against `test.exp` using `diff -u`

When modifying utilities:
- Update `test.exp` if changing expected output format
- Integration tests are inline in `./test` script (not separate files)
- Test coverage focuses on common cases and edge conditions (empty input, special chars)
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing shell configuration files, utility scripts, text editor configurations, and tools for development. The repository follows Unix conventions and is designed to work across different Unix-like systems.

## Common Development Commands

### Installation and Setup
```bash
./install                      # Install dotfiles by symlinking to home directory
```

### Testing
```bash
./test                        # Run comprehensive test suite for all utilities
python3 -m unittest test_snip.py  # Run unit tests for snippet system
```

### Vim Plugin Management
```bash
./vim/get <github_url>        # Install vim plugin from GitHub
./vim/get -o <github_url>     # Install optional vim plugin
```

## Architecture and Code Organization

### Directory Structure
- `bin/` - Utility scripts and command-line tools
- `acme/` - Scripts for the Acme editor integration
- `vim/` - Vim configuration and plugin management
- `lib/` - Configuration files (plumbing rules, etc.)
- `dot.*` - Dotfiles that get symlinked to home directory as `.*`

### Key Components

#### Text Processing and Development Tools
- `bin/snip` (Python) - Advanced code snippet expansion system with 50+ templates for shell, Go, AWK, Python, and note-taking
- `bin/fts` - Full-text search engine using SQLite FTS5 for markdown and text files
- `bin/fsg` - File system grep utility
- `bin/tabfmt`, `bin/tabmd` - Table formatting utilities for TSV and Markdown
- `bin/urlencode`, `bin/urldecode` - URL encoding/decoding with line-by-line support

#### Development Environment
- `dot.vimrc` - Comprehensive Vim configuration optimized for programming
- `init.sh` - Shell initialization script supporting bash, zsh, and ksh
- `acme/afmt` - Automatic code formatter supporting Go, Python, Perl, Rust, and Prettier-compatible files

#### Configuration Management
- `install` script uses symlinks to manage dotfile installation
- Modular design allows selective installation of components
- Environment setup through `init.sh` handles PATH management and shell-specific configuration

### Snippet System Architecture
The `bin/snip` tool provides a sophisticated code generation system:
- Template-based expansion using `IndentBuilder` class for proper indentation
- Language-specific templates: shell scripts (sh*), Go (go*), AWK (awk*), Python (py*), note-taking (n*)
- Comprehensive test coverage with both unit tests and CLI integration tests
- Extensible design allows adding new snippet types

### Text Processing Pipeline
- `fts` provides full-text indexing and search capabilities
- `tabfmt` family handles structured data formatting
- URL encoding tools support both single-string and line-by-line processing
- Integration with system utilities through consistent Unix pipe patterns

## Development Patterns

### Shell Script Conventions
- POSIX compliance preferred over bash-specific features
- Consistent error handling patterns using `log()` and `fatal()` functions
- Option parsing using `getopts` with standardized help output
- File processing follows filter pattern (read stdin, process, write stdout)

### Testing Strategy
- Comprehensive test suite in `./test` covers all major utilities
- Python tools include both unit tests and integration tests
- Expected output comparison for deterministic tools
- Error condition testing for robust failure handling

### Code Organization
- Single-purpose utilities following Unix philosophy
- Consistent naming conventions (verb-noun pattern for most tools)
- Self-documenting code with usage information in script headers
- Configuration through environment variables and standard file locations
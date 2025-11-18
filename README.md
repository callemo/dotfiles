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

Run `./install` to symlink the configuration files to your home directory. 
The script won't overwrite existing files.

To use the utilities, add the `bin/` directory to your PATH, or source `init.sh` 
from your shell's startup file.

## Some Useful Tools

**snip** expands code templates. Give it a snippet name and it generates boilerplate 
for shell scripts, Go programs, Python functions, and more. It knows about proper 
indentation and follows the conventions of each language.

**fts** provides full-text search for your notes and documents using SQLite's FTS5 engine. 
It indexes markdown and text files and lets you search them quickly.

**tabfmt** formats tabular data into aligned columns. Give it tab-separated values 
and it makes them readable. **tabmd** does the same but outputs Markdown tables.

**urlencode** and **urldecode** handle percent-encoding. They work line-by-line, 
so you can process entire files through them.

**template** does simple text substitution. You write a template with placeholders 
like `{{1}}` and `{{2}}`, then feed it tab-separated data to fill them in.

The git utilities (**gst**, **gd**, **glog**, etc.) are shortcuts for common git operations. 
They save typing and provide consistent output formatting.

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

## The Acme Connection

The `acme/` directory contains utilities for the Acme text editor. Acme is a different 
kind of editor—it treats text editing as part of a larger programming environment. 
The tools here extend Acme with automatic formatting, go-to-definition, and other 
programmer conveniences.

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
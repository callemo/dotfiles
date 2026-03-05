"""Python snippet expansions."""


def _expand_pyargs(builder, args):
    """Python argparse. [optstring] - Generate argument parser from option string."""
    optstring = args[0] if args else "abc:"

    builder.write("parser = argparse.ArgumentParser()")

    last = len(optstring) - 1
    for i, v in enumerate(optstring):
        if v == ":":
            continue
        if i < last and optstring[i + 1] == ":":
            builder.write(
                f'parser.add_argument("-{v}", help="{v} option that requires an argument")'
            )
        else:
            builder.write(
                f'parser.add_argument("-{v}", action="store_true", help="Enable {v} option")'
            )

    builder.write("args = parser.parse_args()")


def _expand_pyfilter(builder, args):
    """Python command line filter."""
    builder.write("#!/usr/bin/env python3")
    builder.write('"""Command line filter."""')
    builder.write("import argparse")
    builder.write("import fileinput")
    builder.write("import os")
    builder.write("import sys")
    builder.write("")
    builder.write("def main():")
    builder.indent()
    builder.write("parser = argparse.ArgumentParser()")
    builder.write('parser.add_argument("files", nargs="*")')
    builder.write("args = parser.parse_args()")
    builder.write("with fileinput.input(files=args.files) as f:")
    builder.indent()
    builder.write("for line in f:")
    builder.indent()
    builder.write('print(line, end="")')
    builder.dedent()
    builder.dedent()
    builder.dedent()
    builder.write("")
    builder.write("try:")
    builder.indent()
    builder.write("main()")
    builder.write("sys.stdout.flush()")
    builder.dedent()
    builder.write("except (BrokenPipeError, KeyboardInterrupt):")
    builder.indent()
    builder.write("os.dup2(os.open(os.devnull, os.O_WRONLY), sys.stdout.fileno())")
    builder.dedent()


def _expand_pydir(builder, _args):
    """Python program directory."""
    builder.write("progdir = os.path.realpath(os.path.dirname(__file__))")


SNIPPETS = {
    "pyargs": _expand_pyargs,
    "pydir": _expand_pydir,
    "pyfilter": _expand_pyfilter,
}

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


def _expand_pyfilter(builder, _args):
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


def _expand_pytest(builder, _args):
    """Python unittest file."""
    builder.write("#!/usr/bin/env python3")
    builder.write('"""Unit tests."""')
    builder.write("import unittest")
    builder.write("")
    builder.write("")
    builder.write("class TestMain(unittest.TestCase):")
    builder.indent()
    builder.write("def test_example(self):")
    builder.indent()
    builder.write("self.assertEqual(1, 1)")
    builder.dedent()
    builder.dedent()
    builder.write("")
    builder.write("")
    builder.write('if __name__ == "__main__":')
    builder.indent()
    builder.write("unittest.main()")
    builder.dedent()


def _expand_pycsv(builder, args):
    """Python CSV filter. [delimiter] - TSV by default."""
    delim = args[0] if args else r"\t"
    builder.write("#!/usr/bin/env python3")
    builder.write('"""CSV/TSV filter."""')
    builder.write("import csv")
    builder.write("import os")
    builder.write("import sys")
    builder.write("")
    builder.write("def main():")
    builder.indent()
    builder.write(f'reader = csv.reader(sys.stdin, delimiter={repr(delim)})')
    builder.write("for row in reader:")
    builder.indent()
    builder.write("print(row)")
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


SNIPPETS = {
    "pyargs": _expand_pyargs,
    "pycsv": _expand_pycsv,
    "pydir": _expand_pydir,
    "pyfilter": _expand_pyfilter,
    "pytest": _expand_pytest,
}

"""Python snippet expansions."""

from .args import ident, options, params


def py(builder, args):
    """[program] Python text filter with argparse and diagnostics. [opts]

    usage: snip py [opts]

    arguments:
      opts  Option letters; default: none. A letter adds a boolean flag;
            a colon after it adds a string option. For example, vn: adds
            -v and -n value. A leading colon is ignored. h is built in.

    Flags default to False, strings to empty. Use args.v and args.n in filter.
    Options only set fields; edit filter to give them meaning.
    No files, or -, reads stdin. Use -- before filenames starting with -.
    Data goes to stdout; diagnostics go to stderr. Input and output use UTF-8
    without newline conversion. warn reports an error; die reports and exits.
    Broken pipes terminate quietly; other I/O errors exit 1. Stdlib only.

    examples:
      snip py
      snip py vn:
    """
    spec, = params(args, "")
    program(builder, options(spec))


def pycsv(builder, args):
    """[program] Python CSV/TSV filter with options and diagnostics. [opts delimiter]

    usage: snip pycsv [opts [delimiter]]

    arguments:
      opts       Option letters; default: none. A letter adds a boolean flag;
                 a colon after it adds a string option. For example, vn: adds
                 -v and -n value. A leading colon is ignored. h and d are built in.
      delimiter  Default field delimiter; default: tab. \\t also means tab.

    Flags default to False, strings to empty. Use args.v and args.n in filter;
    edit filter to give them meaning. -d changes args.delimiter at run time.
    No files, or -, reads stdin. Use -- before filenames starting with -.
    Double quote, CR, LF and NUL are not valid delimiters. Uses CSV quoting,
    preserves embedded newlines, and writes records with the same delimiter.
    warn and die report errors on stderr. Input and output use UTF-8.

    examples:
      snip pycsv
      snip pycsv '' ','
      snip pycsv vn: ','
    """
    spec, delim = params(args, "", "\t")
    opts = options(spec, reserved="hd")
    if delim == r"\t":
        delim = "\t"
    if len(delim) != 1 or delim in '\"\r\n\0':
        raise ValueError("delimiter must be one character other than double quote, CR, LF or NUL")
    program(builder, opts, delim)


def program(builder, opts, delim=None):
    extra = ", args" if opts or delim is not None else ""
    builder.block('''#!/usr/bin/env python3
"""Filter input to standard output."""

import argparse
''')
    if delim is not None:
        builder.write("import csv")
    builder.block(r'''import os
import signal
import sys

prog = os.path.basename(sys.argv[0])


def warn(message):
	print(f"{prog}: {message}", file=sys.stderr)


def die(message):
	warn(message)
	sys.exit(1)
''')
    builder.write("")
    builder.write("")
    if delim is None:
        builder.write(f"def filter(src, dst{extra}):")
        builder.block('''	for line in src:
		dst.write(line)
''')
    else:
        builder.block(r'''def delimiter(s):
	if s == r"\t":
		s = "\t"
	if len(s) != 1 or s in '\"\r\n\0':
		raise argparse.ArgumentTypeError("expected one character other than double quote, CR, LF or NUL")
	return s


def filter(src, dst, args):
	reader = csv.reader(src, delimiter=args.delimiter, strict=True)
	writer = csv.writer(dst, delimiter=args.delimiter, lineterminator="\n")
	for row in reader:
		writer.writerow(row)
''')
    builder.write("")
    builder.write("")
    builder.block('''def main():
	parser = argparse.ArgumentParser(description=__doc__, allow_abbrev=False)
''')
    builder.indent()
    for name, value in opts:
        default = 'default=""' if value else 'action="store_true"'
        desc = f"value for -{name}" if value else f"flag -{name}"
        builder.write(f'parser.add_argument("-{name}", {default}, help="{desc}")')
    if delim is not None:
        builder.write(f'parser.add_argument("-d", "--delimiter", type=delimiter, default={delim!r},')
        builder.write('                    help="field delimiter (default: %(default)r)")')
    builder.block('''parser.add_argument("files", metavar="file", nargs="*", help="input files; - or no files reads stdin")
args = parser.parse_args()
''')
    if delim is not None:
        builder.write("csv.field_size_limit(sys.maxsize)")
    builder.block('''files = args.files or ["-"]
if "-" in files:
	sys.stdin.reconfigure(encoding="utf-8", newline="")
sys.stdout.reconfigure(encoding="utf-8", newline="")
try:
	for name in files:
		if name == "-":
''')
    builder.indent().indent().indent()
    builder.write(f"filter(sys.stdin, sys.stdout{extra})")
    builder.dedent()
    builder.write("else:")
    builder.indent()
    builder.write('with open(name, encoding="utf-8", newline="") as f:')
    builder.indent()
    builder.write(f"filter(f, sys.stdout{extra})")
    builder.dedent().dedent().dedent().dedent()
    builder.block('''finally:
	sys.stdout.flush()
''')
    builder.dedent()
    builder.write("")
    builder.write("")
    builder.block('''if __name__ == "__main__":
	signal.signal(signal.SIGPIPE, signal.SIG_DFL)
	try:
		main()
''')
    builder.indent()
    errors = "OSError, UnicodeError, csv.Error" if delim is not None else "OSError, UnicodeError"
    builder.write(f"except ({errors}) as err:")
    builder.block('''	with open(os.devnull, "w") as f:
		os.dup2(f.fileno(), sys.stdout.fileno())
	die(err)
except KeyboardInterrupt:
	sys.exit(130)
''')
    builder.dedent()


def pyt(builder, args):
    """[program] Python unittest file. [Name method]

    usage: snip pyt [Name [method]]

    arguments:
      Name    Test class name; default: Main. Adds Test unless already present.
      method  Test method name; default: example. Adds test_ unless present.

    Names must be ASCII identifiers. The test skips until you replace its
    body. Run the file directly, or use python3 -m unittest to discover it.

    examples:
      snip pyt
      snip pyt Parser read
    """
    name, method = params(args, "Main", "example")
    if not ident(name) or not ident(method):
        raise ValueError("Name and method must be Python identifiers")
    if not name.startswith("Test"):
        name = "Test" + name[:1].upper() + name[1:]
    if not method.startswith("test_"):
        method = "test_" + method
    builder.block('''#!/usr/bin/env python3
"""Unit tests."""

import unittest
''')
    builder.write("")
    builder.write("")
    builder.write(f"class {name}(unittest.TestCase):")
    builder.indent().write(f"def {method}(self):").dedent()
    builder.block('''		self.skipTest("add a test")


if __name__ == "__main__":
	unittest.main()
''')


SNIPPETS = {"py": py, "pycsv": pycsv, "pyt": pyt}

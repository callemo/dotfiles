"""Shell snippet expansions."""


def _expand_shlog(builder, _args):
    """Shell logging."""
    builder.write('prog=${0##*/}')
    builder.write('log() { printf "%s: %s\\n" "$prog" "$*" >&2; }')
    builder.write('fatal() { log "$@"; exit 1; }')


def _expand_shopts(builder, args):
    """Shell getopts. [optstring] - Generate getopt parsing for shell scripts."""
    optstring = args[0] if args else ":abc:"
    if optstring[0] != ":":
        optstring = ":" + optstring

    builder.write("usage() {")
    builder.indent()
    builder.write("sed -n '2,/^[^#]/p' \"$0\" | sed 's/^# *//' >&2")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write(f"while getopts '{optstring}' opt")
    builder.write("do")
    builder.indent()
    builder.write("case $opt in")

    last = len(optstring) - 1
    for i, v in enumerate(optstring):
        if v == ":":
            continue
        if i < last and optstring[i + 1] == ":":
            builder.write(f"{v})")
            builder.indent()
            builder.write(f"{v}arg=$OPTARG")
            builder.dedent()
            builder.write(";;")
        else:
            builder.write(f"{v})")
            builder.indent()
            builder.write(f"{v}flag=1")
            builder.dedent()
            builder.write(";;")

    builder.write(r"\?)")
    builder.indent()
    builder.write("usage")
    builder.write("exit 2")
    builder.dedent()
    builder.write(";;")
    builder.write("esac")
    builder.dedent()
    builder.write("done")
    builder.write("shift $(expr $OPTIND - 1)")


def _expand_shdir(builder, _args):
    """Shell program directory."""
    builder.write('progdir="$(cd "$(dirname "$0")" && pwd)"')


def _expand_shcase(builder, args):
    """Shell case. [case1 case2...] - Generate shell case statement with cases."""
    # Default cases if none provided
    cases = args if args else ["option1", "option2", "option3"]

    builder.write("case $1 in")
    for arg in cases:
        builder.write(f"{arg})")
        builder.indent()
        builder.write(f"# handle {arg}")
        builder.dedent()
        builder.write(";;")

    builder.write("*)")
    builder.indent()
    builder.write("usage")
    builder.write("exit 2")
    builder.dedent()
    builder.write(";;")
    builder.write("esac")


def _expand_shscript(builder, _args):
    """Shell script structure following Unix Programming Environment style.

    Modernized with POSIX getopts.
    """
    builder.write("#!/bin/sh")
    builder.write("# Description of what this script does")
    builder.write("")
    builder.write("PATH=/bin:/usr/bin")
    builder.write("export PATH")
    builder.write("")
    builder.write('prog=${0##*/}')
    builder.write("")
    builder.write("usage() {")
    builder.indent()
    builder.write("printf 'usage: %s [options] files\\n' \"$prog\" >&2")
    builder.write("exit 1")
    builder.dedent()
    builder.write("}")
    builder.write("")
    builder.write("# parse options")
    builder.write("while getopts ':h' opt")
    builder.write("do")
    builder.indent()
    builder.write("case $opt in")
    builder.write("h)")
    builder.indent()
    builder.write("usage")
    builder.dedent()
    builder.write(";;")
    builder.write(r"?\)")
    builder.indent()
    builder.write("usage")
    builder.dedent()
    builder.write(";;")
    builder.write("esac")
    builder.dedent()
    builder.write("done")
    builder.write("shift $(expr $OPTIND - 1)")
    builder.write("")
    builder.write("# main processing")
    builder.write("if [ $# -eq 0 ]")
    builder.write("then")
    builder.indent()
    builder.write("usage")
    builder.dedent()
    builder.write("fi")
    builder.write("")
    builder.write("for file")
    builder.write("do")
    builder.indent()
    builder.write("if [ ! -f \"$file\" ]")
    builder.write("then")
    builder.indent()
    builder.write("printf '%s: %s: no such file\\n' \"$prog\" \"$file\" >&2")
    builder.write("continue")
    builder.dedent()
    builder.write("fi")
    builder.write("# process file")
    builder.dedent()
    builder.write("done")


SNIPPETS = {
    "shcase": _expand_shcase,
    "shdir": _expand_shdir,
    "shlog": _expand_shlog,
    "shopts": _expand_shopts,
    "shscript": _expand_shscript,
}

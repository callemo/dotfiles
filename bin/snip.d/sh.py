"""Shell snippet expansions."""

from .args import options, params, synopsis


def sh(builder, args):
    """[program] POSIX shell filter with options and diagnostics. [opts]

    usage: snip sh [opts]

    arguments:
      opts  Option letters; default: none. A letter adds a boolean flag;
            a colon after it adds a string option. For example, vn: adds
            -v and -n value. A leading colon is ignored. h is built in.

    Flags default to 0, strings to empty. Use $v and $n in filter.
    Options only set variables; edit filter to give them meaning.
    No files, or -, reads stdin. Put options before files; -- ends parsing.
    Data goes to stdout; diagnostics go to stderr. warn reports an error;
    die reports and exits. Output redirection belongs to the calling shell.

    examples:
      snip sh
      snip sh vn:
    """
    spec, = params(args, "")
    opts = options(spec)
    usage = synopsis([("h", False), *opts])
    optstring = "h" + "".join(name + (":" if value else "") for name, value in opts)
    builder.block(r'''#!/bin/sh

prog=${0##*/}
warn() { printf '%s: %s\n' "$prog" "$*" >&2; }
die() { warn "$@"; exit 1; }
''')
    builder.write(f'''usage() {{ printf 'usage: %s {usage} [file ...]\\n' "$prog"; }}''')
    builder.write("")
    builder.block('''filter() {
	cat
}
''')
    builder.write("")
    for name, value in opts:
        builder.write(f'{name}=""' if value else f"{name}=0")
    builder.write(f"while getopts ':{optstring}' opt")
    builder.block('''do
	case $opt in
	h) usage; exit 0 ;;
''')
    builder.indent()
    for name, value in opts:
        builder.write(f'{name}) {name}=$OPTARG ;;' if value else f'{name}) {name}=1 ;;')
    builder.dedent()
    builder.block(r'''	:) warn "-$OPTARG needs an argument"; usage >&2; exit 2 ;;
	\?) warn "unknown option: -$OPTARG"; usage >&2; exit 2 ;;
	esac
done
shift $((OPTIND - 1))

[ "$#" -gt 0 ] || set -- -
for file
do
	if [ "$file" = - ]; then
		filter
	else
		filter < "$file"
	fi || exit "$?"
done
''')


SNIPPETS = {"sh": sh}

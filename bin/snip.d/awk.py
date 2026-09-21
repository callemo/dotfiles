"""AWK snippet expansions."""

from .args import options, params


def awk(builder, args):
    """[program] AWK record filter with native options and diagnostics. [opts]

    usage: snip awk [opts]

    arguments:
      opts  Option letters; default: none. A letter adds a boolean variable;
            a colon after it adds a string variable. For example, vn: adds
            v and n. A leading colon is ignored. h is reserved for help.

    Flags default to 0, strings to empty. Set them with AWK's native options:
    -v v=1 -v n=value. Use v and n in the record action; options alone do not
    transform input. -F sets the separator; -v help=1 prints help.
    No files, or -, reads stdin. Use ./ before filenames starting with - or
    containing =. AWK adds a newline to each record, including the last.
    warn and die report errors through cat >&2, without needing /dev/stderr.

    examples:
      snip awk
      snip awk vn:
    """
    spec, = params(args, "")
    opts = options(spec)
    builder.block('''#!/usr/bin/awk -f

BEGIN {
	if (help) {
		usage()
		exit
	}
''')
    builder.indent()
    for name, value in opts:
        if not value:
            builder.write(f'if ({name} == "") {name} = 0')
    builder.dedent()
    builder.block(r'''}

{
	print
}

function usage() {
	printf "usage: %s -f script [-F separator] [-v name=value] [file ...]\n", ARGV[0]
	print "Use -v help=1 for help; - or no files reads stdin."
''')
    builder.indent()
    for name, value in opts:
        default = "empty" if value else "0"
        arg = "value" if value else "1"
        builder.write(f'print "  -v {name}={arg} (default: {default})"')
    builder.dedent()
    builder.block(r'''}

function warn(message) {
	printf "%s: %s\n", ARGV[0], message | "cat >&2"
	close("cat >&2")
}

function die(message) {
	warn(message)
	exit 1
}
''')


SNIPPETS = {"awk": awk}

"""Perl snippet expansions."""

import re

from .args import ident, options, params, synopsis


def pl(builder, args):
    """[program] Perl text filter with Getopt::Long and diagnostics. [opts]

    usage: snip pl [opts]

    arguments:
      opts  Option letters; default: none. A letter adds a boolean flag;
            a colon after it adds a string option. For example, vn: adds
            -v and -n value. A leading colon is ignored. h is built in.

    Flags default to 0, strings to empty. Use $opt->{v} and $opt->{n} in filter.
    Options only set fields; edit filter to give them meaning.
    No files, or -, reads stdin. Put options before files; -- ends parsing.
    Data goes to stdout; warn and die write diagnostics to stderr.
    Uses core Perl modules and three-argument open, not magic diamond opens.

    examples:
      snip pl
      snip pl vn:
    """
    spec, = params(args, "")
    opts = options(spec)
    usage = synopsis([("h", False), *opts])
    optarg = ", \\%opt" if opts else ""
    optparam = ", $opt" if opts else ""
    builder.block(r'''#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename qw(basename);
use Getopt::Long qw(GetOptions :config require_order no_auto_abbrev no_ignore_case);

my $prog = basename($0);
my $help;
''')
    if opts:
        builder.write("my %opt = (")
        builder.indent()
        for name, value in opts:
            default = "''" if value else "0"
            builder.write(f"{name} => {default},")
        builder.dedent().write(");")
        builder.write("GetOptions(")
        builder.indent().write(r"'h|help' => \$help,")
        for name, value in opts:
            key = name + ("=s" if value else "")
            builder.write(f"'{key}' => \\$opt{{{name}}},")
        builder.dedent().write(") or usage(2);")
    else:
        builder.write(r"GetOptions('h|help' => \$help) or usage(2);")
    builder.block(r'''usage(0) if $help;

for my $name (@ARGV ? @ARGV : ('-')) {
	my $in;
	if ($name eq '-') {
		$in = \*STDIN;
	} else {
		open $in, '<', $name or die "$prog: $name: $!\n";
	}
''')
    builder.indent().write(f"filter($in, \\*STDOUT, $name{optarg});").dedent()
    builder.block(r'''	if ($name ne '-') {
		close $in or die "$prog: $name: $!\n";
	}
}
close STDOUT or die "$prog: stdout: $!\n";

sub usage {
	my ($status) = @_;
	my $out = $status ? \*STDERR : \*STDOUT;
''')
    builder.indent().write(f'print {{$out}} "usage: $prog {usage} [file ...]\\n";').dedent()
    builder.block(r'''	print {$out} "Read stdin when no files are given or a file is -.\n";
	exit $status;
}

sub filter {
''')
    builder.indent().write(f"my ($in, $out, $name{optparam}) = @_;").dedent()
    builder.block(r'''	while (1) {
		$! = 0;
		my $line = <$in>;
		if (!defined $line) {
			die "$prog: $name: $!\n" if $!;
			last;
		}
		print {$out} $line or die "$prog: write: $!\n";
	}
}
''')


def plmod(builder, args):
    """[file] Perl module with an optional export and a small class. [Name func Class]

    usage: snip plmod [Name [func [Class]]]

    arguments:
      Name   Package name; default: Example. Nested names are allowed.
      func   Exported function and object method; default: process.
      Class  Class suffix within Name; default: Filter. No :: in this suffix.

    Save Text::Filter in Text/Filter.pm on Perl's @INC. Loading Name defines
    Name::Class. Import func explicitly with use Name qw(func), or call it as
    a method on Name::Class->new. Both initially return their input unchanged.
    Names must be ASCII identifiers; func cannot replace new, import or Perl
    lifecycle hooks. Uses only core Perl and a traditional blessed hash.

    examples:
      snip plmod
      snip plmod Text::Filter clean Reader
    """
    name, func, cls = params(args, "Example", "process", "Filter")
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_][A-Za-z0-9_]*)*", name):
        raise ValueError("expected a Perl package name")
    reserved = {
        "new", "import", "unimport", "BEGIN", "END", "CHECK", "INIT", "UNITCHECK",
        "DESTROY", "AUTOLOAD", "CLONE", "CLONE_SKIP", "VERSION", "can", "isa", "DOES",
    }
    if not ident(func) or func in reserved:
        raise ValueError("func must be an ordinary Perl function name, not a constructor or hook")
    if not ident(cls):
        raise ValueError("Class must be a single Perl identifier")
    builder.write(f"package {name};")
    builder.block('''use strict;
use warnings;
use Exporter 'import';
''')
    builder.write("")
    builder.write(f"our @EXPORT_OK = qw({func});")
    builder.write("")
    builder.write(f"sub {func} {{")
    builder.block('''	my ($text) = @_;
	return $text;
}
''')
    builder.write("")
    builder.write(f"package {name}::{cls};")
    builder.write("")
    builder.block(r'''sub new {
	my ($class, %args) = @_;
	return bless \%args, $class;
}
''')
    builder.write("")
    builder.write(f"sub {func} {{")
    builder.indent().write("my ($self, $text) = @_;")
    builder.write(f"return {name}::{func}($text);").dedent()
    builder.block('''}

1;
''')


SNIPPETS = {"pl": pl, "plmod": plmod}

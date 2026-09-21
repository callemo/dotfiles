"""Go snippet expansions."""

import json

from .args import ident, options, params, synopsis


def go(builder, args):
    """[program] Go stream filter with flags and diagnostics. [opts]

    usage: snip go [opts]

    arguments:
      opts  Option letters; default: none. A letter adds a boolean flag;
            a colon after it adds a string option. For example, vn: adds
            -v and -n value. A leading colon is ignored. h is built in.

    Flags default to false, strings to empty. Use opt.v and opt.n in filter.
    Options only set fields; replace io.Copy to give them meaning.
    No files, or -, reads stdin. Put options before files; -- ends parsing.
    Data goes to stdout. flag and log write diagnostics to stderr.
    log.Print reports an error; log.Fatal reports and exits.

    examples:
      snip go
      snip go vn:
    """
    spec, = params(args, "")
    opts = options(spec)
    usage = synopsis([("h", False), *opts])
    optarg = ", opt" if opts else ""
    optparam = ", opt options" if opts else ""
    builder.block(r'''package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
)
''')
    if opts:
        builder.write("")
        builder.write("type options struct {")
        builder.indent()
        for name, value in opts:
            builder.write(f"{name} {'string' if value else 'bool'}")
        builder.dedent().write("}")
    builder.write("")
    builder.block(r'''func main() {
	prog := filepath.Base(os.Args[0])
	log.SetFlags(0)
	log.SetPrefix(prog + ": ")
	flag.Usage = func() {
''')
    builder.indent().indent()
    builder.write(f'fmt.Fprintf(flag.CommandLine.Output(), "usage: %s {usage} [file ...]\\n", prog)')
    builder.dedent().dedent()
    builder.block('''		fmt.Fprintln(flag.CommandLine.Output(), "Read stdin when no files are given or a file is -.")
		flag.PrintDefaults()
	}
''')
    builder.indent()
    if opts:
        builder.write("var opt options")
    for name, value in opts:
        kind, default = ("String", '""') if value else ("Bool", "false")
        desc = f"value for -{name}" if value else f"flag -{name}"
        builder.write(f'flag.{kind}Var(&opt.{name}, "{name}", {default}, "{desc}")')
    builder.dedent()
    builder.block('''	flag.Parse()
	files := flag.Args()
	if len(files) == 0 {
		files = []string{"-"}
	}
	for _, name := range files {
''')
    builder.indent().indent()
    builder.write(f"if err := filterfile(name, os.Stdout{optarg}); err != nil {{")
    builder.dedent().dedent()
    builder.block('''
			log.Fatal(err)
		}
	}
}
''')
    builder.write("")
    builder.write(f"func filterfile(name string, out io.Writer{optparam}) error {{")
    builder.indent()
    builder.write('if name == "-" {')
    builder.indent().write(f"return filter(os.Stdin, out{optarg})").dedent()
    builder.write("}")
    builder.dedent()
    builder.block('''
	in, err := os.Open(name)
	if err != nil {
		return err
	}
	defer in.Close()
''')
    builder.indent().write(f"return filter(in, out{optarg})").dedent()
    builder.write("}")
    builder.write("")
    builder.write(f"func filter(in io.Reader, out io.Writer{optparam}) error {{")
    builder.block('''	_, err := io.Copy(out, in)
	return err
}
''')


def got(builder, args):
    """[fragment] Table test; needs testing, comparable result. [Func RetType ParamTypes...]

    usage: snip got [Func [RetType [ParamType ...]]]

    arguments:
      Func       Local function name (ASCII identifier); default: Add.
      RetType    Single comparable return type; default: int.
      ParamType  Go type of each function parameter, in order.

    With no arguments, uses Add(int, int) int. With Func but no ParamType,
    the generated call has no arguments. Add cases to the empty table to
    enable the test. Does not define the function under test.

    examples:
      snip got
      snip got Sum int int int
      snip got Ready bool
      snip got Count int '[]string'
    """
    name = funcname(args[0] if args else "Add")
    rettype = args[1] if len(args) > 1 else "int"
    types = args[2:] if args else ["int", "int"]
    if any(not typ.strip() for typ in [rettype, *types]):
        raise ValueError("types must not be empty")
    params = [f"a{i}" for i in range(len(types))]
    values = ", ".join(f"tc.{p}" for p in params)

    suffix = name[:1].upper() + name[1:]
    builder.write(f"func Test{suffix}(t *testing.T) {{")
    builder.indent()
    builder.write("tests := []struct {")
    builder.indent()
    builder.write("name string")
    for p, typ in zip(params, types):
        builder.write(f"{p} {typ}")
    builder.write(f"want {rettype}")
    builder.dedent()
    builder.write("}{")
    builder.indent()
    builder.write("// TODO: add cases.")
    builder.dedent()
    builder.write("}")
    builder.write("if len(tests) == 0 {")
    builder.indent()
    builder.write('t.Skip("add test cases")')
    builder.dedent()
    builder.write("}")
    builder.write("for _, tc := range tests {")
    builder.indent()
    builder.write("t.Run(tc.name, func(t *testing.T) {")
    builder.indent()
    builder.write(f"got := {name}({values})")
    builder.write("if got != tc.want {")
    builder.indent()
    verbs = ", ".join(["%#v"] * len(types))
    message = f"{name}({verbs}) = %#v, want %#v"
    values = f"{values}, " if values else ""
    builder.write(f"t.Errorf({quote(message)}, {values}got, tc.want)")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("})")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")


def gotbm(builder, args):
    """[fragment] Benchmark; needs testing, Go 1.24+. [Func args...]

    usage: snip gotbm [Func [arg ...]]

    arguments:
      Func  Local function name (ASCII identifier); default: Add.
      arg   Go expression for each call argument, not a type.

    With no arguments, benchmarks Add(1, 2). With only Func, calls Func().
    Uses b.Loop. Quote expressions that contain spaces or Go string literals.

    examples:
      snip gotbm Add 1 2
      snip gotbm Answer
      snip gotbm Count '[]string{"a", "b"}'
    """
    name = funcname(args[0] if args else "Add")
    values = args[1:] if args else ["1", "2"]
    if any(not value.strip() for value in values):
        raise ValueError("call arguments must not be empty")
    suffix = name[:1].upper() + name[1:]
    builder.write(f"func Benchmark{suffix}(b *testing.B) {{")
    builder.indent()
    builder.write("for b.Loop() {")
    builder.indent()
    builder.write(f"{name}({', '.join(values)})")
    builder.dedent()
    builder.write("}")
    builder.dedent()
    builder.write("}")


def gotex(builder, args):
    """[fragment] Example test; needs fmt. [Func output args...]

    usage: snip gotex [Func output [arg ...]]

    arguments:
      Func    Local function name (ASCII identifier).
      output  Expected text from fmt.Println, not a Go expression.
      arg     Go expression for each call argument, not a type.

    With no arguments, calls Add(1, 2) and expects 3. Otherwise, Func and
    output are required. With no arg, calls Func(). Quote output containing
    spaces or newlines; quote Go string literals so their quotes survive.

    examples:
      snip gotex
      snip gotex Answer 42
      snip gotex Echo hello '"hello"'
    """
    args = args or ["Add", "3", "1", "2"]
    if len(args) < 2:
        raise ValueError("supply Func, expected output, then call arguments")
    name, expected, *values = args
    name = funcname(name)
    if any(not value.strip() for value in values):
        raise ValueError("call arguments must not be empty")
    suffix = "_" + name if name[:1].islower() else name
    builder.write(f"func Example{suffix}() {{")
    builder.indent()
    builder.write(f"fmt.Println({name}({', '.join(values)}))")
    builder.write("// Output:")
    for line in expected.splitlines():
        builder.write(f"// {line}")
    builder.dedent()
    builder.write("}")


def funcname(name):
    keywords = {
        "break", "case", "chan", "const", "continue", "default", "defer", "else",
        "fallthrough", "for", "func", "go", "goto", "if", "import", "interface",
        "map", "package", "range", "return", "select", "struct", "switch", "type", "var",
    }
    if not ident(name) or name in {"_", "init"} or name in keywords:
        raise ValueError("Func must be a simple Go function name")
    return name


def quote(text):
    return json.dumps(text, ensure_ascii=False)


SNIPPETS = {
    "go": go,
    "got": got,
    "gotbm": gotbm,
    "gotex": gotex,
}

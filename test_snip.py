#!/usr/bin/env python3
"""Tests for snip and its generated programs."""

import csv
import datetime
import importlib.machinery
import importlib.util
import io
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from unittest.mock import patch


def loadscript(path):
    loader = importlib.machinery.SourceFileLoader("snip", path)
    spec = importlib.util.spec_from_file_location("snip", path, loader=loader)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


root = os.path.dirname(os.path.abspath(__file__))
script = os.path.join(root, "bin", "snip")
snip = loadscript(script)
snippets = snip.load(os.path.join(root, "bin", "snip.d"))
goenv = dict(os.environ, GOTOOLCHAIN="local", GOWORK="off", GOPROXY="off")


def text(name, *args, tab="\t"):
    return snip.expand(snippets[name], list(args), tab)


class TestIndentBuilder(unittest.TestCase):
    def test_empty(self):
        self.assertEqual(snip.IndentBuilder().text(), "")

    def test_indentation(self):
        for tab in ("\t", "  ", "", "> "):
            with self.subTest(tab=tab):
                out = snip.IndentBuilder(tab)
                out.write("top").indent().write("one").indent().write("two")
                out.write("").dedent().write("one").dedent().write("top")
                self.assertEqual(
                    out.text(), f"top\n{tab}one\n{tab * 2}two\n\n{tab}one\ntop"
                )

    def test_block(self):
        for tab in ("\t", "  ", "", "> "):
            with self.subTest(tab=tab):
                out = snip.IndentBuilder(tab)
                out.indent().block("\nfirst\n\tsecond\n\n\t\tthird\tvalue\n")
                out.write("last").dedent()
                self.assertEqual(out.text(),
                                 f"{tab}first\n{tab * 2}second\n\n{tab * 3}third\tvalue\n{tab}last")
                self.assertEqual(out.level, 0)
        self.assertEqual(snip.IndentBuilder().block("").text(), "")

    def test_dedent_error(self):
        out = snip.IndentBuilder()
        out.write("top")
        with self.assertRaisesRegex(
            IndentationError, "^Cannot dedent past level 0 at line 1$"
        ):
            out.dedent()
        self.assertEqual(out.level, 0)
        self.assertEqual(out.text(), "top")


class TestExpansion(unittest.TestCase):
    def test_return_value(self):
        for result, expected in ((None, "written"), ("", ""), ("text", "text")):
            with self.subTest(result=result):
                def snippet(out, args):
                    out.write("written")
                    return result

                self.assertEqual(snip.expand(snippet), expected)

    def test_arguments_and_indent(self):
        def snippet(out, args):
            out.indent().write(" ".join(args))

        self.assertEqual(snip.expand(snippet, ["a", "b"], "  "), "  a b")

    def test_fresh_default_arguments(self):
        def snippet(out, args):
            args.append("a")
            out.write(" ".join(args))

        self.assertEqual(snip.expand(snippet), "a")
        self.assertEqual(snip.expand(snippet), "a")


class TestListing(unittest.TestCase):
    def test_sorted_and_aligned(self):
        def bare(out, args):
            pass

        output = io.StringIO()
        with redirect_stdout(output):
            snip.listing({"z": bare, "pyt": snippets["pyt"]})
        self.assertEqual(
            output.getvalue(),
            "\nAvailable snippets:\n  pyt - [program] Python unittest file. [Name method]\n"
            "  z   - \n",
        )

    def test_empty(self):
        output = io.StringIO()
        with redirect_stdout(output):
            snip.listing({})
        self.assertEqual(output.getvalue(), "")


class Files(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = directory.name

    def put(self, name, source):
        path = os.path.join(self.root, name)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            f.write(source)
        return path

    def runprog(self, argv, data="", **kwargs):
        return subprocess.run(
            argv, input=data, capture_output=True, text=True,
            cwd=self.root, timeout=120, check=False, **kwargs,
        )

    def succeeds(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class TestLoading(Files):
    def test_sorted_modules(self):
        self.put("z.py", 'SNIPPETS = {"z": "last", "shared": "last"}\n')
        self.put("a.py", 'SNIPPETS = {"a": "first", "shared": "first"}\n')
        self.put("helper.py", 'value = "no snippets"\n')
        self.put("ignored.txt", "not Python\n")
        expected = {"a": "first", "z": "last", "shared": "last"}
        loaded = snip.load(self.root)
        self.assertEqual(loaded, expected)
        loaded["stale"] = "discard"
        self.assertEqual(snip.load(self.root), expected)

    def test_relative_imports(self):
        self.put("_shared.py", 'value = "first"\n')
        source = 'from ._shared import value\nSNIPPETS = {"value": value}\n'
        self.put("a.py", source)
        self.assertEqual(snip.load(self.root), {"value": "first"})
        self.put("other/a.py", source)
        other = os.path.join(self.root, "other")
        with self.assertRaises(ModuleNotFoundError):
            snip.load(other)
        self.put("other/_shared.py", 'value = "second"\n')
        self.assertEqual(snip.load(other), {"value": "second"})
        self.assertEqual(snip.load(self.root), {"value": "first"})

    def test_empty_or_missing_directory(self):
        for path in (self.root, os.path.join(self.root, "missing")):
            with self.subTest(path=path):
                self.assertEqual(snip.load(path), {})

    def test_broken_module(self):
        self.put("broken.py", "def broken(\n")
        with self.assertRaises(SyntaxError):
            snip.load(self.root)

    def test_import_does_not_load_snippets(self):
        path = shutil.copyfile(script, os.path.join(self.root, "snip"))
        os.mkdir(os.path.join(self.root, "snip.d"))
        self.put("snip.d/broken.py", "def broken(\n")
        module = loadscript(path)
        self.assertTrue(callable(module.main))


class TestCatalog(unittest.TestCase):
    def test_names(self):
        self.assertEqual(set(snippets), {
            "awk", "go", "got", "gotbm", "gotex", "nfile", "nmeta",
            "pl", "plmod", "py", "pycsv", "pyt", "sh",
        })

    def test_descriptions(self):
        for name, func in snippets.items():
            with self.subTest(name=name):
                summary = func.__doc__.partition("\n")[0]
                self.assertRegex(summary, r"^\[(program|fragment|file|text)\] .+$")

    def test_argument_help(self):
        for name in snippets:
            with self.subTest(name=name):
                doc = snippets[name].__doc__
                self.assertIn(f"usage: snip {name} [", doc)
                self.assertIn("arguments:", doc)
                self.assertRegex(doc, r"default|With no arguments")
                self.assertIn("examples:", doc)
                self.assertIn(f"snip {name} ", doc.partition("examples:")[2])

    def test_invalid_options(self):
        for name in ("sh", "awk", "go", "pl", "py", "pycsv"):
            for opts in ("h", "vh", "h:", "vv", "v:v", "v::", "::", "-v", "v n:", "1", "é", "v\n", "a'b"):
                with self.subTest(name=name, opts=opts), self.assertRaises(ValueError):
                    text(name, opts)
        for opts in ("d", "d:", "vd:"):
            with self.subTest(opts=opts), self.assertRaises(ValueError):
                text("pycsv", opts)

    def test_parameter_defaults(self):
        for name in ("sh", "awk", "go", "pl", "py", "pycsv"):
            for spec in ("", ":"):
                with self.subTest(name=name, spec=spec):
                    self.assertEqual(text(name, spec), text(name))
            self.assertEqual(text(name, "vn:"), text(name, ":vn:"))
        self.assertEqual(text("pycsv", "", r"\t"), text("pycsv"))
        self.assertEqual(text("plmod", "Example", "process", "Filter"), text("plmod"))
        self.assertEqual(text("pyt", "TestMain", "test_example"), text("pyt"))

    def test_extra_arguments(self):
        for name, args in (
            ("sh", ["v", "extra"]), ("awk", ["v", "extra"]),
            ("pl", ["v", "extra"]), ("go", ["v", "extra"]), ("py", ["v", "extra"]),
            ("pycsv", ["v", ",", "extra"]), ("pyt", ["Parser", "read", "extra"]),
            ("plmod", ["Example", "process", "Filter", "extra"]),
        ):
            with self.subTest(name=name, args=args), self.assertRaises(ValueError):
                text(name, *args)

    def test_invalid_names(self):
        for name in ("got", "gotbm", "gotex"):
            for func in ("", "_", "init", "go", "a-b", "F()", "pkg.F", "F\n", "1Bad"):
                with self.subTest(name=name, func=func), self.assertRaises(ValueError):
                    text(name, func, "int")
        for args in (["F", ""], ["F", "int", " "]):
            with self.subTest(args=args), self.assertRaises(ValueError):
                text("got", *args)
        for name in ("gotbm", "gotex"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                text(name, "F", "42", "")
        for args in ([""], ["bad-name"], ["Main", "bad name"], ["Main", ""]):
            with self.subTest(args=args), self.assertRaises(ValueError):
                text("pyt", *args)
        for func in ("", "bad-name", "new", "import", "unimport", "BEGIN", "DESTROY", "CLONE", "can"):
            with self.subTest(func=func), self.assertRaises(ValueError):
                text("plmod", "Example", func)
        for cls in ("", "bad-name", "Name::Class", "Class\n"):
            with self.subTest(cls=cls), self.assertRaises(ValueError):
                text("plmod", "Example", "process", cls)

    def test_test_scaffold(self):
        code = text("got")
        self.assertTrue(code.startswith("func TestAdd(t *testing.T) {"))
        self.assertNotIn("func Add(", code)
        self.assertNotIn("Benchmark", code)
        self.assertNotIn("Example", code)
        self.assertIn('t.Skip("add test cases")', code)


class TestFilters(Files):
    def setUp(self):
        super().setUp()
        self.commands = {}
        for name, cmd in (
            ("sh", ["sh"]), ("awk", ["awk", "-f"]), ("pl", ["perl"]),
            ("py", [sys.executable]), ("pycsv", [sys.executable]),
        ):
            path = self.put(f"filter.{name}", text(name))
            self.commands[name] = [*cmd, path]
        path = self.put("filter.go", text("go"))
        binary = os.path.join(self.root, "filter-go")
        if shutil.which("go"):
            self.succeeds(self.runprog(["go", "build", "-o", binary, path], env=goenv))
        self.commands["go"] = [binary]

    def command(self, name):
        cmd = self.commands[name]
        if not shutil.which(cmd[0]):
            self.skipTest(f"{name} runtime not installed")
        return cmd

    def test_inputs(self):
        self.put("first", "first\n")
        self.put("last", "last\n")
        self.put("-dash", "dash\n")
        self.put("two words", "space\n")
        self.put("|echo should-not-run", "literal\n")
        for name in self.commands:
            for args, data, expected in (
                ([], "", ""), ([], "stdin\n", "stdin\n"), (["-"], "stdin\n", "stdin\n"),
                (["first", "last"], "ignored\n", "first\nlast\n"),
                (["first", "-", "last"], "stdin\n", "first\nstdin\nlast\n"),
                (["-", "-"], "stdin\n", "stdin\n"),
                (["--", "-dash"], "", "dash\n"),
                (["two words"], "", "space\n"),
                (["|echo should-not-run"], "", "literal\n"),
            ):
                with self.subTest(name=name, args=args):
                    result = self.runprog([*self.command(name), *args], data)
                    self.succeeds(result)
                    self.assertEqual((result.stdout, result.stderr), (expected, ""))

    def test_files_without_stdin(self):
        self.put("first", "first\n")
        for name in self.commands:
            with self.subTest(name=name):
                result = self.runprog([
                    "sh", "-c", 'exec 0<&-; exec "$@"', "sh", *self.command(name), "first",
                ])
                self.succeeds(result)
                self.assertEqual((result.stdout, result.stderr), ("first\n", ""))

    def test_long_and_unterminated_lines(self):
        data = "x" * 200000 + "\ty\n\nlast"
        for name in self.commands:
            with self.subTest(name=name):
                result = self.runprog(self.command(name), data)
                self.succeeds(result)
                expected = data + "\n" if name in ("awk", "pycsv") else data
                self.assertEqual((result.stdout, result.stderr), (expected, ""))

    def test_crlf(self):
        data = b"a\tb\r\nc\td\r\n"
        path = os.path.join(self.root, "data")
        with open(path, "wb") as f:
            f.write(data)
        for name in self.commands:
            for args, stdin in (([], data), ([path], b"")):
                with self.subTest(name=name, args=args):
                    result = subprocess.run(
                        [*self.command(name), *args], input=stdin,
                        capture_output=True, timeout=10, check=False,
                    )
                    expected = data.replace(b"\r\n", b"\n") if name == "pycsv" else data
                    self.assertEqual((result.returncode, result.stderr), (0, b""))
                    self.assertEqual(result.stdout, expected)

    def test_help(self):
        for name in self.commands:
            with self.subTest(name=name):
                args = ["-v", "help=1"] if name == "awk" else ["-h"]
                result = self.runprog([*self.command(name), *args, "missing"], "not output\n")
                self.succeeds(result)
                self.assertIn("usage:", result.stdout + result.stderr)
                self.assertIn("file", result.stdout + result.stderr)
                self.assertNotIn("not output", result.stdout + result.stderr)

    def test_option_errors(self):
        for name in self.commands:
            with self.subTest(name=name):
                args = ["-v"] if name == "awk" else ["-Z"]
                result = self.runprog([*self.command(name), *args])
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, "")
                self.assertTrue(result.stderr)

    def test_input_errors(self):
        self.put("first", "first\n")
        for name in self.commands:
            cases = [(["missing"], ""), (["first", "missing"], "first\n")]
            # Some AWKs treat a directory as empty input.
            if name != "awk":
                cases.append((["."], ""))
            for args, expected in cases:
                with self.subTest(name=name, args=args):
                    result = self.runprog([*self.command(name), *args])
                    self.assertNotEqual(result.returncode, 0)
                    self.assertEqual(result.stdout, expected)
                    self.assertTrue(result.stderr)
                    if args[-1] == "missing":
                        self.assertIn("missing", result.stderr)
                    self.assertNotIn("Traceback", result.stderr)

    @unittest.skipUnless(os.path.exists("/dev/full"), "/dev/full not available")
    def test_write_errors(self):
        for name in self.commands:
            for data in (b"one\n", b"x\n" * 100000):
                with self.subTest(name=name, size=len(data)), open("/dev/full", "wb") as out:
                    result = subprocess.run(
                        self.command(name), input=data, stdout=out, stderr=subprocess.PIPE,
                        timeout=10, check=False,
                    )
                    self.assertNotEqual(result.returncode, 0)
                    self.assertTrue(result.stderr)
                    self.assertNotIn(b"Traceback", result.stderr)
                    self.assertNotIn(b"Exception ignored", result.stderr)

    def test_broken_pipe(self):
        for name in self.commands:
            with self.subTest(name=name):
                cmd = self.command(name)
                readfd, writefd = os.pipe()
                os.close(readfd)
                try:
                    result = subprocess.run(
                        cmd, input=b"x\ty\n" * 100000, stdout=writefd,
                        stderr=subprocess.PIPE, timeout=10, check=False,
                    )
                finally:
                    os.close(writefd)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stderr, b"")


class TestOptions(Files):
    def program(self, name, spec="vn:", bindings=False):
        commands = {
            "sh": ["sh"], "awk": ["awk", "-f"], "pl": ["perl"],
            "py": [sys.executable], "pycsv": [sys.executable], "go": ["go"],
        }
        cmd = commands[name]
        if not shutil.which(cmd[0]):
            self.skipTest(f"{name} runtime not installed")
        code = text(name, spec)
        if bindings:
            pyhead = "def filter(src, dst, args):\n"
            perlhead = "\tmy ($in, $out, $name, $opt) = @_;\n"
            changes = {
                "sh": ("\tcat\n", '\tprintf "%s|%s\\n" "$v" "$n"\n\tcat\n'),
                "awk": ("\tprint\n", '\tprintf "%d|%s\\n", v, n\n\tprint\n'),
                "pl": (perlhead, perlhead + '\tprint {$out} "$opt->{v}|$opt->{n}\\n";\n'),
                "py": (pyhead, pyhead + '\tdst.write(f"{int(args.v)}|{args.n}\\n")\n'),
                "pycsv": (pyhead, pyhead + '\tdst.write(f"{int(args.v)}|{args.n}\\n")\n'),
                "go": ("\t_, err := io.Copy(out, in)\n", '''\tv := 0
\tif opt.v { v = 1 }
\tif _, err := fmt.Fprintf(out, "%d|%s\\n", v, opt.n); err != nil { return err }
\t_, err := io.Copy(out, in)
'''),
            }
            old, new = changes[name]
            self.assertEqual(code.count(old), 1)
            code = code.replace(old, new)
        path = self.put(f"filter.{name}", code)
        if name == "go":
            binary = os.path.join(self.root, "filter-go")
            self.succeeds(self.runprog(["go", "build", "-o", binary, path], env=goenv))
            return [binary]
        return [*cmd, path]

    def test_bindings(self):
        self.put("data", "data\n")
        for name in ("sh", "awk", "pl", "py", "pycsv", "go"):
            with self.subTest(name=name):
                cmd = self.program(name, bindings=True)
                for flag, value in ((False, ""), (True, "two words"), (True, ""), (False, '100% \'"; $()')):
                    with self.subTest(flag=flag, value=value):
                        if name == "awk":
                            args = ["-v", f"v={int(flag)}", "-v", f"n={value}"]
                        else:
                            args = ["-n", value] + (["-v"] if flag else [])
                        for files in ([], ["data"]):
                            with self.subTest(files=files):
                                result = self.runprog([*cmd, *args, *files], "data\n")
                                self.succeeds(result)
                                self.assertEqual((result.stdout, result.stderr), (f"{int(flag)}|{value}\ndata\n", ""))
                result = self.runprog(cmd, "data\n")
                self.succeeds(result)
                self.assertEqual((result.stdout, result.stderr), ("0|\ndata\n", ""))

    def test_case_and_last_value(self):
        for name in ("sh", "awk", "pl", "py", "pycsv", "go"):
            with self.subTest(name=name):
                cmd = self.program(name, "vVn:", bindings=True)
                if name == "awk":
                    args = ["-v", "V=1", "-v", "n=one", "-v", "n=two"]
                else:
                    args = ["-V", "-n", "one", "-n", "two"]
                result = self.runprog([*cmd, *args], "data\n")
                self.succeeds(result)
                self.assertEqual((result.stdout, result.stderr), ("0|two\ndata\n", ""))

    def test_configured_filters(self):
        self.put("first", "first\n")
        self.put("-last", "last\n")
        for name in ("sh", "awk", "pl", "py", "pycsv", "go"):
            with self.subTest(name=name):
                cmd = self.program(name)
                flags = ["-v", "v=1", "-v", "n=text"] if name == "awk" else ["-v", "-n", "text"]
                result = self.runprog([*cmd, *flags, "--", "first", "-", "-last"], "stdin\n")
                self.succeeds(result)
                self.assertEqual((result.stdout, result.stderr), ("first\nstdin\nlast\n", ""))
                flags = ["-v", "help=1"] if name == "awk" else ["-h"]
                result = self.runprog([*cmd, *flags])
                self.succeeds(result)
                output = result.stdout + result.stderr
                for flag in (("-v v=1", "-v n=value") if name == "awk" else ("-v", "-n")):
                    self.assertIn(flag, output)

    def test_runtime_errors(self):
        for name in ("sh", "pl", "py", "pycsv", "go"):
            with self.subTest(name=name):
                cmd = self.program(name)
                for args in (["-n"], ["-Z"]):
                    with self.subTest(args=args):
                        result = self.runprog([*cmd, *args])
                        self.assertEqual((result.returncode, result.stdout), (2, ""))
                        self.assertTrue(result.stderr)


class TestPython(Files):
    def test_indentation(self):
        for name in ("py", "pycsv", "pyt"):
            with self.subTest(name=name):
                path = self.put("filter.py", text(name, tab="    "))
                result = self.runprog([sys.executable, path], "first\nlast\n")
                self.succeeds(result)

    def test_imports_do_not_run(self):
        for name in ("py", "pycsv", "pyt"):
            with self.subTest(name=name):
                path = self.put(f"{name}.py", text(name))
                result = self.runprog([
                    sys.executable, "-c",
                    "import runpy, sys; runpy.run_path(sys.argv[1])", path,
                ], "a\tb\n")
                self.succeeds(result)
                self.assertEqual((result.stdout, result.stderr), ("", ""))

    def test_csv_roundtrip(self):
        rows = [["name", "value"], ["café", "one\r\ntwo"], ['a"b', "x,y\tz"]]
        for delim in ("\t", ",", ";", "\\", "é", "'"):
            for runtime in (False, True):
                with self.subTest(delim=delim, runtime=runtime):
                    source = io.StringIO(newline="")
                    csv.writer(source, delimiter=delim).writerows(rows)
                    path = self.put("filter.py", text("pycsv") if runtime else text("pycsv", "", delim))
                    args = ["-d", delim] if runtime else []
                    result = subprocess.run(
                        [sys.executable, path, *args], input=source.getvalue().encode(),
                        capture_output=True, timeout=10, check=False,
                    )
                    self.assertEqual((result.returncode, result.stderr), (0, b""))
                    actual = csv.reader(io.StringIO(result.stdout.decode(), newline=""), delimiter=delim)
                    self.assertEqual(list(actual), rows)

    def test_csv_errors(self):
        path = self.put("filter.py", text("pycsv"))
        for delim in ("", "xx", '"', "\n", "\r", "\0"):
            with self.subTest(delim=delim):
                with self.assertRaises(ValueError):
                    text("pycsv", "", delim)
                if delim != "\0":
                    result = self.runprog([sys.executable, path, "-d", delim])
                    self.assertEqual((result.returncode, result.stdout), (2, ""))
                    self.assertIn("delimiter", result.stderr)
        result = self.runprog([sys.executable, path], '"unclosed\n')
        self.assertEqual((result.returncode, result.stdout), (1, ""))
        self.assertIn("unexpected end of data", result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        result = self.runprog([sys.executable, path, "-d", r"\t"], "a\tb\n")
        self.succeeds(result)
        self.assertEqual(result.stdout, "a\tb\n")

    def test_diagnostics(self):
        path = self.put("filter.py", text("py"))
        result = self.runprog([
            sys.executable, "-c",
            "import runpy, sys; m = runpy.run_path(sys.argv[1]); "
            "m['warn']('first'); m['die']('100% failed')", path,
        ])
        self.assertEqual((result.returncode, result.stdout), (1, ""))
        self.assertEqual(result.stderr, "filter.py: first\nfilter.py: 100% failed\n")

    def test_unittest(self):
        for args, name, method in (
            ([], "TestMain", "test_example"),
            (["Parser", "read"], "TestParser", "test_read"),
            (["TestParser", "test_read"], "TestParser", "test_read"),
        ):
            with self.subTest(args=args):
                path = self.put("test_unit.py", text("pyt", *args))
                result = self.runprog([sys.executable, "-m", "unittest", "-v", path])
                self.succeeds(result)
                self.assertIn("OK (skipped=1)", result.stderr)
                self.assertIn(name + "." + method, result.stderr)


class TestShell(Files):
    def test_input_error_is_reported_once(self):
        path = self.put("filter.sh", text("sh"))
        result = self.runprog(["sh", path, "missing"])
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertEqual(len(result.stderr.splitlines()), 1)
        self.assertIn("missing", result.stderr)

    def test_diagnostics(self):
        code = text("sh").replace("\tcat\n", '\twarn first\n\tdie "100% failed"\n')
        path = self.put("filter.sh", code)
        result = self.runprog(["sh", path])
        self.assertEqual((result.returncode, result.stdout), (1, ""))
        self.assertEqual(result.stderr, "filter.sh: first\nfilter.sh: 100% failed\n")


@unittest.skipUnless(shutil.which("awk"), "awk not installed")
class TestAwk(Files):
    def test_native_options(self):
        code = text("awk").replace("\tprint\n", '\tprint prefix $2\n')
        path = self.put("filter.awk", code)
        result = self.runprog(["awk", "-F", ":", "-v", "prefix=x", "-f", path], "a:b\n")
        self.succeeds(result)
        self.assertEqual((result.stdout, result.stderr), ("xb\n", ""))

    def test_diagnostics(self):
        code = text("awk").replace("\tprint\n", '\twarn("first")\n\tdie("100% failed")\n')
        path = self.put("filter.awk", code)
        result = self.runprog(["awk", "-f", path], "line\n")
        self.assertEqual((result.returncode, result.stdout), (1, ""))
        self.assertEqual(result.stderr, "awk: first\nawk: 100% failed\n")


@unittest.skipUnless(shutil.which("perl"), "Perl not installed")
class TestPerl(Files):
    def test_module(self):
        for name, func, cls in (("Example", "process", "Filter"), ("Text::Filter", "clean", "Reader")):
            with self.subTest(name=name, func=func, cls=cls):
                path = self.put(name.replace("::", "/") + ".pm", text("plmod", name, func, cls))
                self.succeeds(self.runprog(["perl", "-c", path]))
                code = f'''use strict;
use warnings;
use {name} qw({func});
print {func}("function\\n");
my $obj = {name}::{cls}->new(label => "one");
my $other = {name}::{cls}->new(label => "two");
die "class" unless ref($obj) eq "{name}::{cls}";
die "state" unless $obj->{{label}} eq "one" && $other->{{label}} eq "two";
print $obj->{func}("method\\n");
'''
                result = self.runprog(["perl", "-I", self.root, "-e", code])
                self.succeeds(result)
                self.assertEqual((result.stdout, result.stderr), ("function\nmethod\n", ""))
                result = self.runprog(["perl", "-I", self.root, f"-M{name}", "-e", f'die "exported" if defined &{func}'])
                self.succeeds(result)
                self.assertEqual((result.stdout, result.stderr), ("", ""))

    def test_read_error_names_input(self):
        path = self.put("filter.pl", text("pl"))
        self.put("first", "first\n")
        os.mkdir(os.path.join(self.root, "bad-input"))
        result = self.runprog(["perl", path, "first", "bad-input"])
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "first\n")
        self.assertTrue(result.stderr.startswith("filter.pl: bad-input: "))

    def test_invalid_package(self):
        for name in ("", "a-b", "X;exit", "Foo/Bar", "Foo::", "1Bad", "Foo\n"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                text("plmod", name)

    def test_long_help(self):
        path = self.put("filter.pl", text("pl"))
        result = self.runprog(["perl", path, "--help"])
        self.succeeds(result)
        self.assertIn("usage: filter.pl", result.stdout)
        self.assertEqual(result.stderr, "")


@unittest.skipUnless(shutil.which("go"), "Go not installed")
class TestGo(Files):
    def test_main_format(self):
        for spec in ("", "vn:", "vVn:"):
            with self.subTest(spec=spec):
                code = text("go", spec) + "\n"
                result = self.runprog(["gofmt"], code)
                self.succeeds(result)
                self.assertEqual(result.stdout, code)

    def test_tests(self):
        self.put("go.mod", "module example.com/snip\n\ngo 1.24\n")
        code = '''package snip
import ("fmt"; "testing")
func Add(a, b int) int { return a + b }
func Echo(s string) string { return s }
func Answer() int { return 42 }
func Count(s []string) int { return len(s) }
func Mixed(s string, n int) string { return fmt.Sprintf("%s%d", s, n) }
func Empty() int { return 0 }
func inc(n int) int { return n + 1 }
'''
        for name, rettype, types, row in (
            ("Add", "int", ["int", "int"], '{name: "sum", a0: 1, a1: 2, want: 3},'),
            ("Echo", "string", ["string"], '{name: "text", a0: "hello", want: "hello"},'),
            ("Answer", "int", [], '{name: "answer", want: 42},'),
            ("Count", "int", ["[]string"], '{name: "slice", a0: []string{"x"}, want: 1},'),
            ("Mixed", "string", ["string", "int"], '{name: "mixed", a0: "x", a1: 2, want: "x2"},'),
            ("inc", "int", ["int"], '{name: "increment", a0: 1, want: 2},'),
        ):
            code += text("got", name, rettype, *types).replace("// TODO: add cases.", row) + "\n"
        code += text("got", "Empty", "int") + "\n"
        code += text("gotbm") + "\n"
        code += text("gotbm", "Answer") + "\n"
        code += text("gotbm", "inc", "1") + "\n"
        code += text("gotbm", "Count", '[]string{"a", "b"}') + "\n"
        code += text("gotex") + "\n"
        code += text("gotex", "Answer", "42") + "\n"
        code += text("gotex", "inc", "2", "1") + "\n"
        code += text("gotex", "Echo", "one\ntwo", '"one\\ntwo"') + "\n"
        self.put("snip_test.go", code)
        result = self.runprog(["go", "test", "-v", "-count=1", "-bench=.", "-benchtime=1x", "."], env=goenv)
        self.succeeds(result)
        for name in ("TestAdd/sum", "TestEcho/text", "TestAnswer/answer", "TestCount/slice",
                     "TestMixed/mixed", "TestInc/increment", "ExampleAdd", "ExampleAnswer",
                     "ExampleEcho", "Example_inc"):
            self.assertIn("--- PASS: " + name, result.stdout)
        self.assertIn("--- SKIP: TestEmpty", result.stdout)
        self.assertIn("BenchmarkCount", result.stdout)
        self.assertIn("BenchmarkInc", result.stdout)

        self.put("snip_test.go", code.replace('a0: 1, a1: 2, want: 3', 'a0: 1, a1: 2, want: 4'))
        result = self.runprog(["go", "test", "-run=TestAdd/sum", "."], env=goenv)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("Add(1, 2) = 3, want 4", result.stdout)


class TestNotes(unittest.TestCase):
    def setUp(self):
        moment = datetime.datetime(2024, 1, 2, 3, 4, 5)
        clock = patch("datetime.datetime")
        self.addCleanup(clock.stop)
        clock.start().today.return_value = moment

    def test_filename(self):
        for args, expected in (
            ([], "202401020304.txt"),
            (["Hello", "World!"], "202401020304-hello_world.txt"),
            (["!?"], "202401020304.txt"),
        ):
            with self.subTest(args=args):
                self.assertEqual(text("nfile", *args), expected)

    def test_metadata(self):
        self.assertEqual(
            text("nmeta", "ignored", "title:Chosen", "words", "tags:one:two", "unknown:value"),
            "---\nDate: 2024-01-02T03:04:05\nTitle: Chosen\nTags: one:two\n"
            "References: \nISBN: \nURL: \nAuthor: \nYear: \nMonth: \n---\n\n# Chosen\n",
        )

    def test_metadata_without_title(self):
        self.assertEqual(
            text("nmeta"),
            "---\nDate: 2024-01-02T03:04:05\nTitle: \nTags: \nReferences: \n"
            "ISBN: \nURL: \nAuthor: \nYear: \nMonth: \n---\n",
        )

    def test_case_insensitive_keys(self):
        for urlkey, isbnkey in (("url", "isbn"), ("URL", "ISBN"), ("Url", "Isbn")):
            with self.subTest(urlkey=urlkey):
                code = text("nmeta", f"{urlkey}:https://example.org", f"{isbnkey}:0123456789")
                self.assertIn("\nURL: https://example.org\n", code)
                self.assertIn("\nISBN: 0123456789\n", code)


class TestMain(unittest.TestCase):
    def runmain(self, args):
        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            status = snip.main(args)
        return status, out.getvalue(), err.getvalue()

    def test_listing(self):
        for args in ([], ["-l"], ["--list"], ["-l", "unknown"]):
            with self.subTest(args=args):
                status, out, err = self.runmain(args)
                self.assertEqual((status, err), (0, ""))
                self.assertTrue(out.startswith("\nAvailable snippets:\n"))
                self.assertEqual(len(out.splitlines()), len(snippets) + 2)
                self.assertNotIn("examples:", out)
                for name in snippets:
                    self.assertIn(f"  {name}", out)

    def test_command_help(self):
        for flag in ("-h", "--help"):
            with self.subTest(flag=flag):
                with patch.object(snip, "load") as load:
                    status, out, err = self.runmain([flag])
                load.assert_not_called()
                self.assertEqual((status, err), (0, ""))
                self.assertIn("Expand text snippets.", out)
                self.assertIn("SNIPPET -h", out)
                self.assertIn("--tab", out)

    def test_snippet_help(self):
        for name in snippets:
            for flag in ("-h", "--help"):
                with self.subTest(name=name, flag=flag):
                    status, out, err = self.runmain([name, flag])
                    self.assertEqual((status, err), (0, ""))
                    self.assertTrue(out.startswith(f"usage: snip {name}"))
                    self.assertIn(snippets[name].__doc__.partition("\n")[0], out)
                    self.assertNotIn("Available snippets:", out)

    def test_help_with_arguments(self):
        for args in (
            ["got", "-h", "Func"], ["gotex", "Func", "--help"],
            ["-t", "  ", "got", "-h"], ["-l", "got", "--help"], ["--help", "got"],
        ):
            with self.subTest(args=args):
                status, out, err = self.runmain(args)
                self.assertEqual((status, err), (0, ""))
                self.assertTrue(out.startswith("usage: snip got"))
                self.assertIn("arguments:", out)
                self.assertNotIn("Available snippets:", out)

    def test_literal_help_arguments(self):
        status, out, err = self.runmain(["gotex", "--", "Echo", "-h", '"-h"'])
        self.assertEqual((status, err), (0, ""))
        self.assertEqual(out, text("gotex", "Echo", "-h", '"-h"') + "\n")
        status, out, err = self.runmain(["--tab=--help", "got"])
        self.assertEqual((status, err), (0, ""))
        self.assertEqual(out, text("got", tab="--help") + "\n")

    def test_unknown_snippet(self):
        status, out, err = self.runmain(["unknown"])
        self.assertEqual((status, err), (1, "Unknown snippet: unknown\n"))
        self.assertIn("Available snippets:", out)

    def test_expansion(self):
        for tab in ("\t", "  ", ""):
            with self.subTest(tab=tab):
                status, out, err = self.runmain(["-t", tab, "got", "Answer", "int"])
                self.assertEqual((status, err), (0, ""))
                self.assertEqual(out, text("got", "Answer", "int", tab=tab) + "\n")

    def test_invalid_arguments(self):
        for args in (
            ["pycsv", "", "xx"], ["pycsv", '"'], ["gotex", "F"], ["plmod", "a-b"],
            ["plmod", "A", "B", "C", "extra"], ["pyt", "bad-name"], ["sh", "h"],
        ):
            with self.subTest(args=args):
                status, out, err = self.runmain(args)
                self.assertEqual((status, out), (2, ""))
                self.assertTrue(err.startswith("snip: " + args[0] + ":"))


class TestCLI(Files):
    def test_catalog(self):
        for name in sorted(snippets):
            with self.subTest(name=name):
                result = self.runprog([script, name])
                self.assertEqual((result.returncode, result.stderr), (0, ""))
                self.assertTrue(result.stdout.endswith("\n"))
                self.assertNotEqual(result.stdout, "\n")

    def test_unknown_snippet(self):
        for name in ("unknown", "gocli", "gost", "pyargs", "shlog", "awkarray"):
            for args in ([name], [name, "-h"], [name, "--help"]):
                with self.subTest(args=args):
                    result = self.runprog([script, *args])
                    self.assertEqual(result.returncode, 1)
                    self.assertEqual(result.stderr, f"Unknown snippet: {name}\n")
                    self.assertIn("Available snippets:", result.stdout)

    def test_snippet_help(self):
        for flag in ("-h", "--help"):
            with self.subTest(flag=flag):
                result = self.runprog([script, "got", flag])
                self.assertEqual((result.returncode, result.stderr), (0, ""))
                self.assertTrue(result.stdout.startswith("usage: snip got [Func"))
                self.assertIn("Single comparable return type; default: int.", result.stdout)
                self.assertIn("With no arguments, uses Add(int, int) int.", result.stdout)
                self.assertIn("snip got Ready bool", result.stdout)
                self.assertNotIn("func Test", result.stdout)

    def test_help_examples(self):
        for func in snippets.values():
            for line in func.__doc__.splitlines():
                line = line.strip()
                if not line.startswith("snip "):
                    continue
                with self.subTest(example=line):
                    name, *args = shlex.split(line)[1:]
                    result = self.runprog([script, name, *args])
                    self.succeeds(result)
                    self.assertEqual(result.stderr, "")
                    self.assertTrue(result.stdout)
                    if args[:1] == ["--"]:
                        args = args[1:]
                    if name not in ("nfile", "nmeta"):
                        self.assertEqual(result.stdout, text(name, *args) + "\n")

    def test_symlink_from_another_directory(self):
        path = os.path.join(self.root, "snip")
        os.symlink(script, path)
        result = self.runprog([path, "sh"])
        self.assertEqual((result.returncode, result.stderr), (0, ""))
        self.assertEqual(result.stdout, text("sh") + "\n")

    def test_note_tags(self):
        self.put("note.txt", text("nmeta", "tags:#one #two"))
        env = dict(os.environ, NROOT=self.root)
        result = self.runprog([os.path.join(root, "bin", "n"), "tag", "one", "two"], env=env)
        self.succeeds(result)
        self.assertEqual(result.stdout, os.path.join(self.root, "note.txt") + "\n")


if __name__ == "__main__":
    unittest.main()

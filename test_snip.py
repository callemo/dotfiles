#!/usr/bin/env python3
"""Unit tests for the snippet program."""

import importlib.util
import io
import os
import subprocess
import sys
import unittest
from unittest.mock import patch

# Import snip module via importlib (extensionless script)
_loader = importlib.machinery.SourceFileLoader(
    "snip", os.path.join(os.path.dirname(__file__) or ".", "bin", "snip")
)
_spec = importlib.util.spec_from_loader("snip", _loader)
snip = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(snip)

IndentBuilder = snip.IndentBuilder
expand_snippet = snip.expand_snippet
main = snip.main
SNIPPETS = snip.SNIPPETS


class TestIndentBuilder(unittest.TestCase):
    def setUp(self):
        self.builder = IndentBuilder()

    def test_write(self):
        self.builder.write("test")
        self.assertEqual(self.builder.text(), "test")

    def test_indent(self):
        self.builder.write("test")
        self.builder.indent()
        self.builder.write("indented")
        self.assertEqual(self.builder.text(), "test\n\tindented")

    def test_dedent(self):
        self.builder.write("test")
        self.builder.indent()
        self.builder.write("indented")
        self.builder.dedent()
        self.builder.write("not indented")
        self.assertEqual(self.builder.text(), "test\n\tindented\nnot indented")

    def test_dedent_error(self):
        with self.assertRaises(IndentationError):
            self.builder.dedent()

    def test_custom_tab(self):
        builder = IndentBuilder("  ")
        builder.write("test")
        builder.indent()
        builder.write("indented")
        self.assertEqual(builder.text(), "test\n  indented")

    def test_blank_line_no_trailing_whitespace(self):
        """write('') at indent > 0 should not produce trailing whitespace."""
        builder = IndentBuilder()
        builder.indent()
        builder.write("")
        self.assertEqual(builder.lines[-1], "")


class TestSnippetExpansion(unittest.TestCase):
    def test_expand_snippet(self):
        def test_snippet(builder, _args):
            builder.write("test")
            return "result"

        result = expand_snippet(test_snippet)
        self.assertEqual(result, "result")

    def test_expand_snippet_none(self):
        def test_snippet(builder, _args):
            builder.write("test")

        result = expand_snippet(test_snippet)
        self.assertEqual(result, "test")


class TestMain(unittest.TestCase):
    def setUp(self):
        self.old_argv = sys.argv

    def tearDown(self):
        sys.argv = self.old_argv

    @patch('sys.stderr', new_callable=io.StringIO)
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_list_snippets(self, mock_stdout, _mock_stderr):
        sys.argv = ["snip", "-l"]
        main()
        output = mock_stdout.getvalue()
        self.assertIn("Available snippets:", output)
        for name in SNIPPETS:
            self.assertIn(name, output)

    @patch('sys.stderr', new_callable=io.StringIO)
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_unknown_snippet(self, mock_stdout, mock_stderr):
        sys.argv = ["snip", "unknown"]
        main()
        self.assertIn("Unknown snippet", mock_stderr.getvalue())
        self.assertIn("Available snippets:", mock_stdout.getvalue())

    @patch('sys.stderr', new_callable=io.StringIO)
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_help(self, mock_stdout, _mock_stderr):
        sys.argv = ["snip"]
        main()
        output = mock_stdout.getvalue()
        self.assertIn("Available snippets:", output)

    @patch('sys.stderr', new_callable=io.StringIO)
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_snippet_expansion(self, mock_stdout, _mock_stderr):
        sys.argv = ["snip", "shlog"]
        main()
        output = mock_stdout.getvalue()
        self.assertIn("prog=", output)
        self.assertIn("log()", output)
        self.assertIn("fatal()", output)


class TestSnippets(unittest.TestCase):
    def test_shlog(self):
        builder = IndentBuilder()
        SNIPPETS["shlog"](builder, [])
        result = builder.text()
        self.assertIn("prog=", result)
        self.assertIn("log()", result)
        self.assertIn("fatal()", result)

    def test_shopts(self):
        builder = IndentBuilder()
        SNIPPETS["shopts"](builder, [":abc"])
        result = builder.text()
        self.assertIn("getopts", result)
        self.assertIn("case", result)
        self.assertIn("shift", result)

    def test_shscript_unknown_opt_case(self):
        """shscript must emit \\?) not ?\\) for unknown option case."""
        builder = IndentBuilder()
        SNIPPETS["shscript"](builder, [])
        result = builder.text()
        self.assertIn(r"\?)", result)
        self.assertNotIn(r"?\)", result)

    def test_gostruct(self):
        builder = IndentBuilder()
        SNIPPETS["gostruct"](builder, ["User", "Name", "string", "Age", "int"])
        result = builder.text()
        self.assertIn("type User struct", result)
        self.assertIn("Name string", result)
        self.assertIn("Age int", result)
        self.assertIn("func NewUser", result)

    def test_nfile_no_title(self):
        """nfile with no args should not produce a trailing dash."""
        builder = IndentBuilder()
        result = SNIPPETS["nfile"](builder, [])
        self.assertTrue(result.endswith(".txt"))
        self.assertNotIn("-.txt", result)

    def test_nfile_with_title(self):
        """nfile with args should include the title."""
        builder = IndentBuilder()
        result = SNIPPETS["nfile"](builder, ["hello", "world"])
        self.assertIn("-hello_world", result)
        self.assertTrue(result.endswith(".txt"))


class TestCLI(unittest.TestCase):
    """Integration tests for the command-line interface."""

    def setUp(self):
        self.script_path = os.path.join(
            os.path.dirname(__file__), 'bin', 'snip'
        )

    def run_snip(self, args):
        """Run the snip command with given arguments and return (stdout, stderr, returncode)."""
        cmd = [self.script_path] + args
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        return result.stdout, result.stderr, result.returncode

    def test_list_snippets(self):
        """Test listing all available snippets."""
        stdout, stderr, returncode = self.run_snip(['-l'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('Available snippets:', stdout)
        for name in SNIPPETS:
            self.assertIn(name, stdout)

    def test_help(self):
        """Test help output."""
        stdout, stderr, returncode = self.run_snip([])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('Available snippets:', stdout)

    def test_unknown_snippet(self):
        """Test handling of unknown snippet."""
        stdout, stderr, returncode = self.run_snip(['unknown_snippet'])
        self.assertEqual(returncode, 1)
        self.assertIn('Unknown snippet', stderr)
        self.assertIn('Available snippets:', stdout)

    def test_shlog_snippet(self):
        """Test expanding the shlog snippet."""
        stdout, stderr, returncode = self.run_snip(['shlog'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('prog=', stdout)
        self.assertIn('log()', stdout)
        self.assertIn('fatal()', stdout)

    def test_shopts_snippet(self):
        """Test expanding the shopts snippet with custom options."""
        stdout, stderr, returncode = self.run_snip(['shopts', ':abc'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('getopts', stdout)
        self.assertIn('case', stdout)
        self.assertIn('shift', stdout)

    def test_gostruct_snippet(self):
        """Test expanding the gostruct snippet with custom fields."""
        stdout, stderr, returncode = self.run_snip(
            ['gostruct', 'User', 'Name', 'string', 'Age', 'int'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('type User struct', stdout)
        self.assertIn('Name string', stdout)
        self.assertIn('Age int', stdout)
        self.assertIn('func NewUser', stdout)

    def test_custom_tab(self):
        """Test custom tab character."""
        stdout, stderr, returncode = self.run_snip(['-t', '  ', 'shlog'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('log()', stdout)

    def test_invalid_tab(self):
        """Test invalid tab character."""
        _stdout, stderr, returncode = self.run_snip(['-t', '', 'shlog'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')

    def test_multiple_args(self):
        """Test passing multiple arguments to a snippet."""
        stdout, stderr, returncode = self.run_snip(
            ['gostruct', 'User', 'Name', 'string', 'Age', 'int',
             'Email', 'string'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('Name string', stdout)
        self.assertIn('Age int', stdout)
        self.assertIn('Email string', stdout)

    def test_empty_args(self):
        """Test passing empty arguments to a snippet."""
        stdout, stderr, returncode = self.run_snip(['gostruct'])
        self.assertEqual(returncode, 0)
        self.assertEqual(stderr, '')
        self.assertIn('type User struct', stdout)


if __name__ == "__main__":
    unittest.main()

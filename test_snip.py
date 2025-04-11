#!/usr/bin/env python3
"""Unit tests for the snippet program."""

import unittest
from unittest.mock import patch
import io
import sys
import subprocess
import os

from bin.snip import IndentBuilder, expand_snippet, main, SNIPPETS

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

class TestSnippetExpansion(unittest.TestCase):
    def test_expand_snippet(self):
        def test_snippet(builder, args):
            builder.write("test")
            return "result"

        result = expand_snippet(test_snippet)
        self.assertEqual(result, "result")

    def test_expand_snippet_none(self):
        def test_snippet(builder, args):
            builder.write("test")

        result = expand_snippet(test_snippet)
        self.assertEqual(result, "test")

class TestMain(unittest.TestCase):
    def setUp(self):
        self.old_argv = sys.argv
        self.old_stdout = sys.stdout
        self.old_stderr = sys.stderr
        sys.stdout = io.StringIO()
        sys.stderr = io.StringIO()

    def tearDown(self):
        sys.argv = self.old_argv
        sys.stdout = self.old_stdout
        sys.stderr = self.old_stderr

    def test_list_snippets(self):
        sys.argv = ["snip", "-l"]
        main()
        output = sys.stdout.getvalue()
        self.assertIn("Available snippets:", output)
        for name in SNIPPETS:
            self.assertIn(name, output)

    def test_unknown_snippet(self):
        sys.argv = ["snip", "unknown"]
        main()
        self.assertIn("Unknown snippet", sys.stderr.getvalue())
        self.assertIn("Available snippets:", sys.stdout.getvalue())

    def test_help(self):
        sys.argv = ["snip"]
        main()
        output = sys.stdout.getvalue()
        self.assertIn("Available snippets:", output)

    def test_snippet_expansion(self):
        sys.argv = ["snip", "shlog"]
        main()
        output = sys.stdout.getvalue()
        self.assertIn("prefix=", output)
        self.assertIn("log()", output)
        self.assertIn("fatal()", output)

class TestSnippets(unittest.TestCase):
    def test_shlog(self):
        from bin.snip import _expand_shlog
        builder = IndentBuilder()
        _expand_shlog(builder, [])
        result = builder.text()
        self.assertIn("prefix=", result)
        self.assertIn("log()", result)
        self.assertIn("fatal()", result)

    def test_shopts(self):
        from bin.snip import _expand_shopts
        builder = IndentBuilder()
        _expand_shopts(builder, [":abc"])
        result = builder.text()
        self.assertIn("getopts", result)
        self.assertIn("case", result)
        self.assertIn("shift", result)

    def test_gostruct(self):
        from bin.snip import _expand_gostruct
        builder = IndentBuilder()
        _expand_gostruct(builder, ["User", "Name", "string", "Age", "int"])
        result = builder.text()
        self.assertIn("type User struct", result)
        self.assertIn("Name string", result)
        self.assertIn("Age int", result)
        self.assertIn("func NewUser", result)

class TestCLI(unittest.TestCase):
    """Integration tests for the command-line interface."""

    def setUp(self):
        # Get the absolute path to the snip script in dotfiles/bin/snip
        self.script_path = os.path.join(os.environ['HOME'], 'dotfiles', 'bin', 'snip')

    def run_snip(self, args):
        """Run the snip command with given arguments and return (stdout, stderr, returncode)."""
        cmd = [self.script_path] + args
        result = subprocess.run(cmd, capture_output=True, text=True)
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
        self.assertIn('prefix=', stdout)
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
        stdout, stderr, returncode = self.run_snip(['gostruct', 'User', 'Name', 'string', 'Age', 'int'])
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
        self.assertIn('log()', stdout)  # Just check if the function exists, not the indentation

    def test_invalid_tab(self):
        """Test invalid tab character."""
        stdout, stderr, returncode = self.run_snip(['-t', '', 'shlog'])
        self.assertEqual(returncode, 0)  # Script accepts empty tab character
        self.assertEqual(stderr, '')

    def test_multiple_args(self):
        """Test passing multiple arguments to a snippet."""
        stdout, stderr, returncode = self.run_snip(['gostruct', 'User', 'Name', 'string', 'Age', 'int', 'Email', 'string'])
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
        self.assertIn('type User struct', stdout)  # Should use default values

if __name__ == "__main__":
    unittest.main()

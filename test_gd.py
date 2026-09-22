"""Output tests for gd, including Delta's terminal-only rendering."""

import errno
import os
from pathlib import Path
import pty
import re
import select
import shutil
import subprocess
import tempfile
import unittest


script = str(Path(__file__).resolve().parent / "bin" / "gd")


class TestGd(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        self.env = {
            "PATH": os.environ["PATH"],
            "HOME": tmp.name,
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": os.devnull,
            "TERM": "xterm",
            "LC_ALL": "C",
            "PAGER": "cat",
            "DELTA_PAGER": "cat",
        }
        self.git("init", "-q")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.invalid")
        self.git("config", "core.pager", "cat")
        self.git("config", "delta.paging", "never")
        self.git("config", "delta.width", "80")
        self.git("config", "delta.side-by-side", "true")
        self.file = self.root / "file.txt"
        self.file.write_text("old value\n")
        self.git("add", "file.txt")
        self.git("commit", "-qm", "initial")
        self.file.write_text("new value\n")

    def runprog(self, *args):
        return subprocess.check_output(
            args, cwd=self.root, env=self.env, text=True, timeout=10,
        )

    def git(self, *args):
        return self.runprog("git", *args)

    def terminal(self, *args):
        master, slave = pty.openpty()
        chunks = []
        with os.fdopen(master, "rb", buffering=0) as out:
            try:
                proc = subprocess.Popen(
                    [script, *args], cwd=self.root, env=self.env,
                    stdin=subprocess.DEVNULL, stdout=slave, stderr=slave,
                )
            finally:
                os.close(slave)
            with proc:
                while True:
                    if not select.select([out], [], [], 10)[0]:
                        proc.kill()
                        self.fail("gd terminal output timed out")
                    try:
                        chunk = out.read(4096)
                    except OSError as e:
                        if e.errno != errno.EIO:
                            raise
                        break
                    if not chunk:
                        break
                    chunks.append(chunk)
                text = b"".join(chunks).decode().replace("\r\n", "\n")
                self.assertEqual(proc.wait(timeout=10), 0, text)
        return re.sub(r"\x1b\[[0-9;]*m", "", text)

    def layout(self, single, *args):
        if not shutil.which("delta"):
            self.skipTest("delta not found")
        text = self.terminal(*args)
        rows = [
            ("old value" in line, "new value" in line)
            for line in text.splitlines()
            if "old value" in line or "new value" in line
        ]
        expected = [(True, False), (False, True)] if single else [(True, True)]
        self.assertEqual(rows, expected, text)

    def test_default(self):
        expected = self.git("diff", "--histogram")
        self.assertEqual(self.terminal(), expected)
        self.assertEqual(self.runprog(script), expected)

    def test_layout(self):
        self.layout(True, "-v")
        for args in (
            ("-2",), ("-2", "-v"), ("-v", "-2"), ("-2", "-2"),
            ("-v2",), ("-2v",), ("-v2v",),
        ):
            with self.subTest(args=args):
                self.layout(False, *args)
        self.git("config", "core.pager", "delta")
        self.layout(True)
        self.layout(False, "-2")
        self.git("config", "delta.side-by-side", "false")
        self.layout(True)
        self.layout(False, "-2")

    def test_grouped(self):
        self.layout(False, "-v2")
        self.assertEqual(self.terminal("-v2"), self.terminal("-v", "-2"))
        self.git("add", "file.txt")
        self.file.write_text("unstaged value\n")
        expected = self.terminal("-s", "-v", "-2")
        for opt in ("-sv2", "-s2v", "-vs2", "-v2s", "-2sv", "-2vs", "-s2"):
            with self.subTest(opt=opt):
                self.assertEqual(self.terminal(opt), expected)

    def test_staged(self):
        self.git("add", "file.txt")
        self.file.write_text("unstaged value\n")
        for args in (("-s",), ("-s", "-v"), ("-sv",), ("-vs",)):
            with self.subTest(args=args):
                self.layout(True, *args)
                self.layout(False, "-2", *args)
                self.layout(False, *args, "-2")

    def test_commits(self):
        old = self.git("rev-parse", "HEAD").strip()
        self.git("commit", "-qam", "change")
        sha = self.git("rev-parse", "HEAD").strip()
        for args in ((sha,), (sha[:8],), (old, sha)):
            with self.subTest(args=args):
                self.layout(True, *args)
                self.layout(True, "-v", *args)
                self.layout(False, "-2", *args)
                self.layout(False, "-v2", *args)

    def test_git_arguments(self):
        self.layout(False, "-2", "--", "file.txt")
        self.layout(False, "-2", "--no-color", "--", "file.txt")
        self.layout(False, "-v2", "--no-color", "--", "file.txt")
        for args in ((), ("--stat",), ("--", "file.txt")):
            with self.subTest(args=args):
                expected = self.git("diff", "--histogram", *args)
                self.assertEqual(self.runprog(script, "-2", *args), expected)
        self.git("mv", "file.txt", "./-2")
        self.assertEqual(
            self.runprog(script, "--", "-2"),
            self.git("diff", "--histogram", "--", "-2"),
        )
        self.layout(False, "-2", "--", "-2")

    def test_parsing_boundary(self):
        for args in (
            ("--stat",), ("-U0",), ("-R",), ("--", "file.txt"),
            ("--stat", "-s"), ("HEAD", "-s"), ("-1",), ("-vR",),
        ):
            with self.subTest(args=args):
                expected = subprocess.run(
                    ["git", "diff", "--histogram", *args],
                    cwd=self.root, env=self.env, capture_output=True, timeout=10,
                )
                actual = subprocess.run(
                    [script, "-v2", *args],
                    cwd=self.root, env=self.env, capture_output=True, timeout=10,
                )
                self.assertEqual(actual.returncode, expected.returncode)
                self.assertEqual(actual.stdout, expected.stdout)
                self.assertEqual(actual.stderr, expected.stderr)
        name = self.git("rev-parse", "--short", "HEAD").strip()
        self.git("mv", "file.txt", name)
        self.assertEqual(
            self.runprog(script, "-v2", "--", name),
            self.git("diff", "--histogram", "--", name),
        )
        self.git("mv", name, "./-v2")
        self.layout(False, "-v2", "--", "-v2")

    def test_help(self):
        text = self.terminal("-h")
        self.assertIn("[-2]", text)
        self.assertIn("single-column by default", text)
        self.assertNotIn("[-1]", text)
        self.assertEqual(self.terminal("-v2h"), text)


if __name__ == "__main__":
    unittest.main()

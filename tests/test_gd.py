"""Smoke test for gd."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


script = Path(__file__).resolve().parents[1] / "bin" / "gd"


class TestGd(unittest.TestCase):
    def test_diff(self):
        with tempfile.TemporaryDirectory() as root:
            env = {
                "PATH": os.environ["PATH"],
                "HOME": root,
                "GIT_CONFIG_NOSYSTEM": "1",
                "GIT_CONFIG_GLOBAL": os.devnull,
                "GIT_PAGER": "cat",
            }

            def run(*args):
                return subprocess.check_output(
                    args, cwd=root, env=env, text=True, timeout=10,
                )

            run("git", "init", "-q")
            path = Path(root) / "file.txt"
            path.write_text("old value\n")
            run("git", "add", "file.txt")
            path.write_text("new value\n")

            expected = run("git", "diff", "--histogram")
            self.assertIn("+new value", expected)
            self.assertEqual(run(script), expected)


if __name__ == "__main__":
    unittest.main()

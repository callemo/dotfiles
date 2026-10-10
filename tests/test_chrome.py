"""Check Chromium's display settings without starting the browser."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


repo = Path(__file__).resolve().parents[1]


class TestChrome(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.config = self.root / ".config/chromium"
        self.prefs = self.config / "Default/Preferences"
        self.prefs.parent.mkdir(parents=True)
        self.data = {
            "partition": {
                "per_host_zoom_levels": {"x": {"example.com": 1}},
                "default_zoom_level": {"xOTHER": 0.5},
            },
            "unrelated": "keep",
            "webkit": {"webprefs": {"minimum_font_size": 6}},
        }
        self.prefs.write_text(json.dumps(self.data))
        profile = self.root / "t490/fvwm/profile"
        profile.parent.mkdir(parents=True)
        shutil.copy2(repo / "t490/fvwm/profile", profile)
        mock = self.root / "xrandr"
        mock.write_text('''#!/bin/sh
printf '%s\\n' "$DISPLAYS"
''')
        mock.chmod(0o755)
        launcher = self.root / "system-chrome"
        launcher.write_text('''#!/bin/sh
printf '%s\\n' "$@"
''')
        launcher.chmod(0o755)
        self.script = self.root / "chrome"
        source = (repo / "t490/bin/chrome").read_text()
        self.script.write_text(source.replace("exec /usr/local/bin/chrome",
                                              f'exec "{launcher}"'))
        self.env = {
            **os.environ,
            "HOME": str(self.root),
            "DOTFILES": str(self.root),
            "XDG_CONFIG_HOME": str(self.root / ".config"),
            "PATH": f"{self.root}:{os.environ['PATH']}",
            "DISPLAYS": "DP-1 connected primary 3840x2160+0+0",
        }

    def launch(self):
        return subprocess.check_output(
            ["sh", str(self.script), "--incognito", "https://example.com/a b"],
            env=self.env, text=True, timeout=10,
        )

    def test_external_scale_preserves_preferences(self):
        before = self.prefs.read_bytes()
        output = self.launch()
        self.assertEqual(self.prefs.read_bytes(), before)
        self.assertEqual(output, "--force-device-scale-factor=1.75\n"
                         "--incognito\nhttps://example.com/a b\n")

    def test_internal_scale_preserves_preferences(self):
        before = self.prefs.read_bytes()
        self.launch()
        self.env["DISPLAYS"] = "eDP-1 connected primary 1920x1080+0+0"
        output = self.launch()
        self.assertEqual(self.prefs.read_bytes(), before)
        self.assertIn("--force-device-scale-factor=1.5\n", output)

    def test_running_browser_keeps_preferences_untouched(self):
        (self.config / "SingletonLock").symlink_to(f"t490-{os.getpid()}")
        before = self.prefs.read_bytes()
        self.launch()
        self.assertEqual(self.prefs.read_bytes(), before)

    def test_first_launch_without_preferences(self):
        self.prefs.unlink()
        self.assertIn("--force-device-scale-factor=1.75\n", self.launch())
        self.assertFalse(self.prefs.exists())


if __name__ == "__main__":
    unittest.main()

"""Check display scaling without changing the X session."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


repo = Path(__file__).resolve().parents[1]
script = repo / "t490" / "fvwm" / "display"


class TestDisplay(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for path in ("t490/fvwm/profile", "lib/install", "bin/overwrite"):
            dst = self.root / path
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(repo / path, dst)
        self.resources = self.root / "resources"
        self.commands = self.root / "commands"
        self.env = {
            **os.environ,
            "HOME": str(self.root),
            "DOTFILES": str(self.root),
            "XDG_CACHE_HOME": str(self.root),
            "FVWM_LOG": str(self.root / "fvwm.log"),
            "RESOURCES": str(self.resources),
            "COMMANDS": str(self.commands),
            "PATH": f"{self.root}:{os.environ['PATH']}",
        }
        mock = self.root / "mock"
        mock.write_text('''#!/bin/sh
name=${0##*/}
printf '%s %s\\n' "$name" "$*" >>"$COMMANDS"
case $name in
uname) echo OpenBSD ;;
xrandr)
    if [ $# -eq 0 ] || [ "$1" = --current ]; then
        printf '%s\\n' "$DISPLAYS"
    fi ;;
xdpyinfo) echo '  dimensions:    3840x2160 pixels' ;;
xrdb) cat >>"$RESOURCES" ;;
esac
exit 0
''')
        mock.chmod(0o755)
        for name in ("uname", "xrandr", "xrdb", "xsetroot", "xinput", "xdpyinfo"):
            (self.root / name).symlink_to(mock)

    def sync(self, external):
        if external:
            self.env["DISPLAYS"] = """eDP-1 connected
   1920x1080 60.01 +
DP-1 connected primary 3840x2160+0+0
   3840x2160 60.00*+
"""
        else:
            self.env["DISPLAYS"] = """eDP-1 connected primary 1920x1080+0+0
   1920x1080 60.01*+
DP-1 connected
   3840x2160 60.00 +
"""
        self.resources.write_text("")
        self.commands.write_text("")
        return subprocess.check_output(
            ["sh", str(script), "sync", "fvwm", "no"],
            env=self.env, text=True, stderr=subprocess.PIPE, timeout=10,
        )

    def check_profile(self, external, dpi, cursor, qt, pixels):
        output = self.sync(external)
        self.assertEqual(self.resources.read_text(), (
            f"Xft.dpi: {dpi}\n"
            f"Xcursor.size: {cursor}\n"
            f"XTerm*faceName: Spleen:pixelsize={pixels}:antialias=false,"
            f"DejaVu Sans Mono:pixelsize={pixels}:antialias=false\n"
            f"XTerm*font: spleen-{pixels // 2}x{pixels}\n"
            f"ToolStatus*font: spleen-{pixels // 2}x{pixels}\n"
            f"ToolStatus*internalBorder: {8 if external else 3}\n"
        ))
        self.assertIn(f"SetEnv XCURSOR_SIZE {cursor}\n", output)
        self.assertIn("SetEnv QT_FONT_DPI 96\n", output)
        self.assertIn(f"SetEnv QT_SCALE_FACTOR {qt}\n", output)
        font = ("spleen-16x32" if external else
                "-adobe-helvetica-medium-r-normal--20-140-100-100-p-100-iso10646-1")
        self.assertIn(f'DefaultFont "{font}"\n', output)
        self.assertIn(f'*FvwmPagerFont {font}\n', output)
        self.assertNotIn('*LogOutFont', output)
        self.assertNotIn('*RunCmdFont', output)
        self.assertNotIn('*RunCmdButtonFont', output)
        self.assertNotIn('*RunCmdInputFont', output)
        self.assertIn(f'*FvwmPagerGeometry {288 if external else 180}x'
                      f'{48 if external else 30}+0+0\n', output)
        gtkfont = "DejaVu Sans 12" if external else "Sans 10"
        for version in (3, 4):
            settings = self.root / f".config/gtk-{version}.0/settings.ini"
            self.assertEqual(settings.read_text(),
                             f"[Settings]\ngtk-font-name={gtkfont}\n")
        self.assertEqual((self.root / ".gtkrc-2.0").read_text(),
                         f'gtk-font-name="{gtkfont}"\n')
        commands = self.commands.read_text().splitlines()
        self.assertIn(f"xrandr --dpi {dpi}", commands)
        self.assertFalse(any("--mode" in line or "--off" in line
                             for line in commands))

    def test_external_profile(self):
        self.check_profile(True, 156, 30, "2.0", 32)

    def test_internal_profile_restores_defaults(self):
        self.check_profile(True, 156, 30, "2.0", 32)
        self.check_profile(False, 144, 32, "1.6", 24)

    def test_form_fonts_precede_items(self):
        config = (repo / "t490/dot.fvwmrc").read_text()
        hook = "PipeRead '$HOME/dotfiles/t490/fvwm/form-fonts'"
        for external in (True, False):
            output = self.sync(external)
            fonts = subprocess.check_output(
                ["sh", str(repo / "t490/fvwm/form-fonts")], env=self.env,
                text=True, timeout=10,
            )
            expanded = config.replace(hook, fonts)
            formfont = ("-adobe-helvetica-medium-r-normal--26-*-100-100-p-*-iso10646-1"
                        if external else
                        "-adobe-helvetica-medium-r-normal--20-140-100-100-p-100-iso10646-1")
            inputfont = ("-adobe-courier-bold-r-normal--32-*-100-100-m-*-iso10646-1"
                         if external else
                         "-adobe-courier-bold-r-normal--25-180-100-100-m-150-iso10646-1")
            for form in ("LogOut", "RunCmd"):
                for suffix in ("Font", "ButtonFont"):
                    command = f'*{form}{suffix}'
                    self.assertEqual(expanded.count(command), 1)
                    self.assertIn(f'{command} {formfont}\n', expanded)
                    self.assertLess(expanded.index(command),
                                    expanded.index(f'*{form}Line'))
                self.assertNotIn(f'*{form}ButtonFont', output)
            self.assertEqual(expanded.count('*RunCmdInputFont'), 1)
            self.assertIn(f'*RunCmdInputFont {inputfont}\n', expanded)
            self.assertLess(expanded.index('*RunCmdInputFont'),
                            expanded.index('*RunCmdInput '))

    def test_toolbar_tracks_status_height(self):
        for external, height, pager, status in ((True, 48, 144, 240),
                                              (False, 30, 90, 177)):
            self.sync(external)
            output = subprocess.check_output(
                ["sh", str(repo / "t490/fvwm/bar")], env=self.env,
                text=True, timeout=10,
            )
            self.assertIn(f"*ToolBarGeometry 3840x{height}+0+0\n", output)
            self.assertIn(f"*ToolBar({pager}x1+0+0,", output)
            self.assertIn(f"*ToolBar({status}x1-0+0,", output)
            self.assertEqual(pager * 2 / height, 6)


if __name__ == "__main__":
    unittest.main()

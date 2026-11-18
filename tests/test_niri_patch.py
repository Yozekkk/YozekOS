"""Validate targeted YozekOS Settings edits against the installed Niri parser."""
import copy
import importlib.machinery
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
NIRI_CONFIG = Path.home() / ".config/niri/config.kdl"
SETTINGS = Path.home() / ".config/yozekos/hypr.json"
SCRIPT = ROOT / "yozekos/bin/rice-niri"


@unittest.skipUnless(NIRI_CONFIG.is_file() and SETTINGS.is_file(), "Niri session config is unavailable")
class NiriPatchTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="yozekos-niri-test-")
        self.addCleanup(self.temp.cleanup)
        loader = importlib.machinery.SourceFileLoader("yozekos_niri_patch_test", str(SCRIPT))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        self.module = importlib.util.module_from_spec(spec)
        loader.exec_module(self.module)
        self.module.NIRI = self.temp.name
        self.module.OUT = str(Path(self.temp.name) / "config.kdl")
        self.module.PATCH_BACKUP = str(Path(self.temp.name) / "last-good.kdl")
        self.module.LOG = str(Path(self.temp.name) / "log")
        self.original = NIRI_CONFIG.read_text()
        Path(self.module.OUT).write_text(self.original)
        self.before = json.loads(SETTINGS.read_text())

    def change(self, group, key, value):
        after = copy.deepcopy(self.before)
        after.setdefault(group, {})[key] = value
        self.assertTrue(self.module.patch_handwritten(self.before, after))
        self.assertTrue(Path(self.module.PATCH_BACKUP).is_file())
        return Path(self.module.OUT).read_text()

    def test_supported_controls_validate(self):
        cases = [
            ("opts", "general.gaps_in", 5),
            ("opts", "general.border_size", 3),
            ("opts", "decoration.rounding", 12),
            ("opts", "decoration.shadow.enabled", True),
            ("opts", "decoration.blur.enabled", False),
            ("opts", "decoration.active_opacity", 0.9),
            ("anim", "style", "expressive"),
            ("kbd", "options", "grp:alt_shift_toggle"),
            ("monitors", "eDP-1", {"mode": "1920x1080@165.000", "position": "1280x0",
                                      "scale": 1.25, "transform": 0, "disabled": False}),
        ]
        for group, key, value in cases:
            with self.subTest(group=group, key=key):
                Path(self.module.OUT).write_text(self.original)
                self.change(group, key, value)

    def test_invalid_monitor_mode_preserves_config(self):
        after = copy.deepcopy(self.before)
        after["monitors"]["eDP-1"] = {"mode": "invalid", "position": "1280x0", "scale": 1.25}
        with self.assertRaises(ValueError):
            self.module.patch_handwritten(self.before, after)
        self.assertEqual(Path(self.module.OUT).read_text(), self.original)

    def test_custom_bind_and_autostart_validate(self):
        after = copy.deepcopy(self.before)
        after["binds"] = [{"keys": "SUPER + ALT + P", "cmd": "true"}]
        after["autostart"] = ["true"]
        self.assertTrue(self.module.patch_handwritten(self.before, after))
        self.assertIn("YozekOS custom binds begin", Path(self.module.OUT).read_text())

    def test_window_rules_validate(self):
        rule = {"on": True, "by": "class", "match": "^yozekos-test-only$", "name": "Test",
                "float": True, "pin": False, "w": 0, "h": 0, "ws": "", "silent": False,
                "opacity": 1.0, "fullscreen": False, "maximize": False}
        self.assertTrue(self.module.patch_rules({"gaming": {"on": False}, "rules": [rule]}))
        result = Path(self.module.OUT).read_text()
        self.assertIn("YozekOS window-rules begin", result)
        self.assertIn("yozekos-test-only", result)

    def test_cursor_change_validates(self):
        self.assertTrue(self.module.patch_cursor())
        result = Path(self.module.OUT).read_text()
        self.assertIn("xcursor-theme", result)
        self.assertIn("xcursor-size", result)

    def test_border_palette_validates(self):
        palette_dir = Path(self.temp.name) / "palette"
        palette_dir.mkdir()
        (palette_dir / "border-colors.txt").write_text("#87b9ee\n#436178\n")
        self.module.HYPR = str(palette_dir)
        self.assertTrue(self.module.patch_border_colors())
        self.assertIn('active-color "#87b9ee"', Path(self.module.OUT).read_text())

    def test_terminal_and_files_binding_validate(self):
        self.assertTrue(self.module.patch_app_binding("terminal"))
        self.assertTrue(self.module.patch_app_binding("files"))
        result = Path(self.module.OUT).read_text()
        self.assertIn('Mod+Return { spawn "' + self.module.BIN + '/rice-term"; }', result)
        self.assertIn('Mod+E { spawn "' + self.module.BIN + '/rice-files"; }', result)


if __name__ == "__main__":
    unittest.main()

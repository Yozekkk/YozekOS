"""Regression checks for the Niri multi-monitor recorder and shared capture settings."""

import json
import os
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
HOTCORNER = ROOT / "yozekos/bin/rice-hotcorner"
CAPTURE = ROOT / "yozekos/bin/yozekos-capture-settings"


class RecordingTest(unittest.TestCase):
    def test_output_selection_and_cross_monitor_rejection(self):
        function = runpy.run_path(str(HOTCORNER))["recording_output"]
        outputs = {
            "HDMI-A-2": {"logical": {"x": 0, "y": 0, "width": 1280, "height": 720}},
            "eDP-1": {"logical": {"x": 1280, "y": 0, "width": 1536, "height": 864}},
        }

        def fake_niri(cmd, timeout=3):
            if cmd[-1] == "outputs":
                return 0, json.dumps(outputs)
            return 0, json.dumps({"name": "eDP-1"})

        function.__globals__["q"] = fake_niri
        self.assertEqual(function(), "eDP-1")
        self.assertEqual(function("100,100 300x200"), "HDMI-A-2")
        self.assertEqual(function("1400,100 300x200"), "eDP-1")
        self.assertIsNone(function("1200,100 300x200"))

    def test_frame_rate_changes_the_real_recorder(self):
        with tempfile.TemporaryDirectory() as home:
            env = dict(os.environ, HOME=home)
            subprocess.run([sys.executable, str(CAPTURE), "set", "recordFps", "45"],
                           env=env, check=True, capture_output=True)
            capture = json.loads((Path(home) / ".config/yozekos/capture.json").read_text())
            recorder = json.loads((Path(home) / ".config/rice/hotcorner.json").read_text())
            self.assertEqual(capture["recordFps"], 45)
            self.assertEqual(recorder["rec_fps"], 45)
            invalid = subprocess.run([sys.executable, str(CAPTURE), "set", "recordFps", "180"],
                                     env=env, capture_output=True)
            self.assertNotEqual(invalid.returncode, 0)
            still_45 = json.loads((Path(home) / ".config/rice/hotcorner.json").read_text())
            self.assertEqual(still_45["rec_fps"], 45)


if __name__ == "__main__":
    unittest.main()

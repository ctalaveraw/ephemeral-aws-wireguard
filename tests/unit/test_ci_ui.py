"""Copy/adaptation of ARM platform ANSI color behavior regression tests."""
import os
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEMO = 'source scripts/ci/ui.sh; ci_ui_init; ci_ui_banner TEST; ci_ui_stage GATES; ci_ui_pass example; ci_ui_finish Complete'


class CIUITests(unittest.TestCase):
    def output(self, color='auto', no_color=False):
        env = dict(os.environ, CI_COLOR=color)
        env.pop('NO_COLOR', None)
        if no_color:
            env['NO_COLOR'] = '1'
        return subprocess.run(['bash', '-c', DEMO], cwd=ROOT, env=env,
                              text=True, capture_output=True, check=True).stdout

    def test_plain_when_not_tty(self):
        self.assertNotIn('\x1b[', self.output())

    def test_force_color(self):
        self.assertIn('\x1b[', self.output('always'))

    def test_no_color_overrides(self):
        self.assertNotIn('\x1b[', self.output('always', no_color=True))

    def test_plain_and_success_summary(self):
        output = self.output('never')
        self.assertIn('SUCCESS', output)
        self.assertNotIn('\x1b[', output)

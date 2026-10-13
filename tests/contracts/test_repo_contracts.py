"""Portable security and source-contract tests. No live credentials."""
import subprocess
import unittest
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]


class RepoContracts(unittest.TestCase):
    def test_git_has_no_private_state_or_keys(self):
        paths = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
        forbidden = ('.tfstate', '.tfplan', '.pem', '.agekey', '.vault-pass')
        for path in filter(None, paths):
            self.assertFalse(path.endswith(forbidden), f'Secret/state path tracked: {path}')
            self.assertNotIn('/.terraform/', '/' + path, f'Terraform cache tracked: {path}')
            self.assertNotIn('/secrets/', '/' + path, f'Secrets directory tracked: {path}')
            self.assertNotEqual(Path(path).name, '.env', f'Runtime env tracked: {path}')
            self.assertNotEqual(Path(path).name, 'site.local.yaml', f'Local site config tracked: {path}')

    def test_public_ci_has_no_deploy_authority(self):
        path = ROOT / '.github/workflows/validate.yml'
        workflow = yaml.safe_load(path.read_text())
        self.assertEqual(workflow.get('permissions'), {'contents': 'read'})
        text = path.read_text().lower()
        for denied in ('terraform apply', 'terraform destroy', 'aws-actions/configure-aws-credentials',
                       'id-token: write', 'pull_request_target:', 'secrets.'):
            self.assertNotIn(denied, text, f'CI acquired prohibited ability: {denied}')

    def test_terraform_lockfile_must_not_be_ignored(self):
        ignore = (ROOT / '.gitignore').read_text()
        self.assertNotIn('.terraform.lock.hcl\n', ignore)
        self.assertIn('*.tfstate', ignore)
        self.assertIn('config/site.local.yaml', ignore)

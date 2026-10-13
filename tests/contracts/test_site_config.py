"""Safe examples, bad network scopes and deployment sentinel rejection."""
import copy
import json
import unittest
from pathlib import Path

import yaml

from src.bastionctl.config import ConfigError, validate_config

ROOT = Path(__file__).resolve().parents[2]


class ConfigContracts(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.example = yaml.safe_load((ROOT / 'config/site.example.yaml').read_text())
        cls.schema = json.loads((ROOT / 'config/schema.json').read_text())

    def test_example_is_syntactically_valid(self):
        validate_config(self.example, self.schema)

    def test_example_cannot_be_used_to_deploy(self):
        with self.assertRaises(ConfigError):
            validate_config(self.example, self.schema, for_deploy=True)

    def test_open_ssh_ssh_source_rejected(self):
        changed = copy.deepcopy(self.example)
        changed['ssh']['operator_cidr'] = '0.0.0.0/0'
        with self.assertRaises(ConfigError):
            validate_config(changed, self.schema)

    def test_default_route_rejected(self):
        changed = copy.deepcopy(self.example)
        changed['home']['route_cidrs'] = ['0.0.0.0/0']
        with self.assertRaises(ConfigError):
            validate_config(changed, self.schema)

    def test_broad_ssh_destination_denied(self):
        changed = copy.deepcopy(self.example)
        changed['home']['allowed_ssh_targets'] = ['10.0.0.0/8']
        with self.assertRaises(ConfigError):
            validate_config(changed, self.schema)

    def test_destination_outside_route_denied(self):
        changed = copy.deepcopy(self.example)
        changed['home']['allowed_ssh_targets'] = ['10.0.4.50/32']
        with self.assertRaises(ConfigError):
            validate_config(changed, self.schema)

    def test_secret_field_denied_by_schema(self):
        changed = copy.deepcopy(self.example)
        changed['aws']['secret_access_key'] = 'NOT_A_REAL_KEY'
        with self.assertRaises(ConfigError):
            validate_config(changed, self.schema)

    def test_broad_session_ttl_rejected(self):
        changed = copy.deepcopy(self.example)
        changed['session']['max_hours'] = 1000
        with self.assertRaises(ConfigError):
            validate_config(changed, self.schema)

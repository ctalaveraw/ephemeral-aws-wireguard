"""Static security boundaries for the SSH-only EC2 MVP.

These checks are P-tier source contracts, NOT proof of AWS permissions,
successful SSH connectivity, correct cost or Terraform destroy.
"""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TF = ROOT / "infrastructure/terraform"


class MVPTerraformContracts(unittest.TestCase):
    def test_account_guard_required(self):
        provider = (TF / "versions.tf").read_text()
        self.assertIn("allowed_account_ids = [var.expected_account_id]", provider)

    def test_explicit_ssh_cidr_and_no_world_inbound(self):
        code = (TF / "main.tf").read_text()
        self.assertIn("cidr_ipv4         = var.operator_ssh_cidr", code)
        self.assertIn('to_port           = 22', code)
        self.assertNotIn('cidr_ipv4         = "0.0.0.0/0"', code.split('resource "aws_vpc_security_group_ingress_rule"')[1].split('resource "aws_vpc_security_group_egress_rule"')[0])
        inputs = (TF / "variables.tf").read_text()
        self.assertIn('endswith(var.operator_ssh_cidr, "/32")', inputs)

    def test_instance_hardening_and_no_iam_credentials(self):
        code = (TF / "main.tf").read_text()
        self.assertIn('http_tokens                 = "required"', code)
        self.assertIn('delete_on_termination = true', code)
        self.assertIn('encrypted             = true', code)
        for unsafe in ("private_key", "user_data", "access_key", "secret_key"):
            self.assertNotIn(unsafe, code)

    def test_no_paid_nat_or_static_eip(self):
        code = (TF / "main.tf").read_text()
        for expensive in ('resource "aws_nat_gateway"', 'resource "aws_eip"', 'resource "aws_lb"'):
            self.assertNotIn(expensive, code)

    def test_local_state_and_sensitive_tfvars_ignored(self):
        files = (ROOT / ".gitignore").read_text()
        self.assertIn("*.tfvars", files)
        self.assertIn("*.tfstate", files)
        self.assertTrue((TF / "terraform.tfvars.example").exists())


if __name__ == "__main__":
    unittest.main()

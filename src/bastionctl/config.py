"""Pure configuration validation; does not contact AWS or the home network."""
import ipaddress
import json
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator


class ConfigError(ValueError):
    """Invalid configuration; refuse deployment."""


def validate_config(data: dict, schema: dict, *, for_deploy: bool = False) -> None:
    """Check structure and high-impact network/identity constraints."""
    issues = sorted(Draft202012Validator(schema).iter_errors(data), key=str)
    if issues:
        raise ConfigError(f"Schema validation failed: {issues[0].message}")

    def network(value: str) -> ipaddress.IPv4Network:
        try:
            parsed = ipaddress.ip_network(value, strict=False)
        except ValueError as exc:
            raise ConfigError(f"Invalid CIDR: {value}") from exc
        if not isinstance(parsed, ipaddress.IPv4Network):
            raise ConfigError('MVP supports IPv4 only')
        return parsed

    ssh_source = network(data['ssh']['operator_cidr'])
    # RFC 5737 documentation addresses are allowed only for non-deploy examples.
    if (ssh_source.prefixlen != 32 or not ssh_source.is_global) and (
        for_deploy or str(ssh_source) != '203.0.113.10/32'
    ):
        raise ConfigError('SSH operator source must be a public IPv4 /32')

    tunnel_address = network(data['home']['vpn_bastion_address'])
    if tunnel_address.prefixlen != 32 or tunnel_address.is_global:
        raise ConfigError('Bastion tunnel address must be a private IPv4 /32')
    routes = [network(item) for item in data['home']['route_cidrs']]
    for cidr in routes:
        if cidr.prefixlen == 0:
            raise ConfigError('Default route 0.0.0.0/0 is forbidden in MVP')
        if not cidr.is_private:
            raise ConfigError('Home routes must use private IPv4 ranges')
    for item in data['home']['allowed_ssh_targets']:
        target = network(item)
        if target.prefixlen != 32 or not target.is_private:
            raise ConfigError('Approved SSH destinations must be private IPv4 /32 hosts')
        if not any(target.subnet_of(route) for route in routes):
            raise ConfigError('Approved SSH host must fall within a declared tunnel route')
    if for_deploy:
        if data['aws']['expected_account_id'] == '000000000000':
            raise ConfigError('Replace placeholder AWS account ID before deployment')
        if data['home']['endpoint'].endswith('.invalid'):
            raise ConfigError('Replace example home endpoint before deployment')


def read_config(source: Path, schema_path: Path, *, for_deploy: bool = False) -> dict:
    data = yaml.safe_load(source.read_text())
    schema = json.loads(schema_path.read_text())
    validate_config(data, schema, for_deploy=for_deploy)
    return data

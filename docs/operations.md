# Operations contract (proposed)

Start from an operator-owned workstation with temporary AWS IAM Identity Center credentials. GitHub CI validates but cannot deploy. A future `bastionctl` obtains a session lock and uses an approved Git revision; no deployment from an arbitrary untrusted PR.

## Planned CLI

- `bastionctl preflight`: branch/revision, AWS caller/account/region and state ownership checks, local secrets available, DDNS reachable.
- `bastionctl plan`: Terraform bootstrap/session changes to be approved explicitly; no secret values displayed.
- `bastionctl up`: terraform apply -> obtain trusted SSH host key -> Ansible converge -> WG handshake -> allow/deny tests -> session record.
- `bastionctl status`: compare declared session state with actual AWS resources and WireGuard reachability.
- `bastionctl down`: fail closed home access, terraform destroy, independent cloud-resource inventory, record unresolved leftovers.
- `bastionctl verify-destroy`: detect session-tagged EC2/EBS/ENI/EIP/SG/VPC/IAM residuals and no reachable home peer.

**Not implemented in Sprint 00.** No script provided here may be used as an infrastructure apply command.

## Local configuration

`config/site.example.yaml` contains *nonsecret* placeholders and is schema validated. A developer copies and edits `config/site.local.yaml` (ignored), but the example AWS account ID and reserved home hostname deliberately cause deployment validation to fail. AWS identity flows through named CLI profile/session, not a permanent access key written to disk. Home DDNS Cloudflare token is never copied from OpenWrt. See [ADR-0004](adr/0004-configuration-and-secrets.md).

## Session duration

Four-hour default maximum, eventually enforced through a trusted controller and/or instance-side fallback **as an alert/stop, not Terraform teardown proof**. AWS alarm/budget notifications are defense in depth and not absolute spending caps. Stale Terraform lock recovery needs human evidence and must not be automated away.

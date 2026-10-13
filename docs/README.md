# Documentation index

- [Adaptation/provenance from ARM homelab platform](PROVENANCE.md)
- [Project architecture and Mermaid map](architecture.md)
- [Threat model](threat-model.md)
- [Roadmap / milestones](roadmap.md)
- [Acceptance backlog](backlog.md)
- [Design gates](planning/design-gates.md)
- [Evidence ledger](evidence/engineering-evidence.md)
- [Operations model](operations.md)
- [Recovery model](recovery.md)
- [Portable CI runbook](runbooks/validation.md)
- [Session runbook](runbooks/session-lifecycle.md)
- [Sprint 00 — repository foundation](sprints/00-repository-foundation.md)
- [Sprint 01 — AWS account bootstrap](sprints/01-account-bootstrap.md)
- [Sprint 02 — Terraform session infrastructure](sprints/02-session-infrastructure.md)
- [Sprint 03 — Ansible/WireGuard routing](sprints/03-ansible-wireguard.md)
- [Sprint 04 — lifecycle/teardown acceptance](sprints/04-lifecycle-and-failure-testing.md)
- [Sprint 05 — CI identity and optional remote operation](sprints/05-trusted-automation.md)

## Architecture decision records

- [ADR-0001: One resource owner, approval boundary](adr/0001-single-owner-trust-boundaries.md)
- [ADR-0002: Two Terraform roots and persistent state](adr/0002-bootstrap-and-state.md)
- [ADR-0003: EC2 as WG client, OpenWrt as server](adr/0003-wireguard-network-model.md)
- [ADR-0004: Four configuration/secret classes](adr/0004-configuration-and-secrets.md)
- [ADR-0005: Approved local orchestration, unprivileged CI](adr/0005-orchestration-and-ci.md)
- [ADR-0006: Revocation vs destruction](adr/0006-destruction-and-expiry.md)

**Current vs target:** these documents define proposed behavior. Do not call the architecture deployed until the relevant sprint evidence records live H-tier verification.

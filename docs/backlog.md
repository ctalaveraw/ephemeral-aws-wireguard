# Backlog — checkboxes are evidence gated

## Sprint 00: project delivery system (active)

- [ ] BAST-001: GitHub `main` initialized; protection reviewed; first CI workflow passes.
- [ ] BAST-002: Architecture diagram, threat model, repo docs, ADRs and acceptance matrix committed.
- [ ] BAST-003: Pinned bootstrap converges dependencies and second run works.
- [ ] BAST-004: Portable validation runs Bash/ShellCheck, Python, YAML/actionlint, Ansible syntax and config tests.
- [ ] BAST-005: Negative tests deny broad SSH sources, default VPN routes, secret config fields, PR deploy permissions.
- [ ] BAST-006: No private keys/state/local site config tracked; no AWS provisioning attempted.

## Sprint 01: empty account bootstrap (planned)

- [ ] BAST-010: Human IAM/root account/MFA setup and non-root temporary operator identity evidenced.
- [ ] BAST-011: Terraform bootstrap S3 state encryption/versioning/lockfile; migration/lock/recovery test.
- [ ] BAST-012: Narrow provisioning/cleanup IAM with account and region preflight, denial tests.
- [ ] BAST-013: Bootstrap recovery guide and explicit persistent resource inventory.

## Sprint 02: disposable AWS infrastructure (planned)

- [ ] BAST-020: Per-session VPC/subnet/IGW/routes/SG/IAM profile/EC2 encrypted EBS provision.
- [ ] BAST-021: Port 22 single operator /32; no 0/0, no public WG listener; IMDSv2.
- [ ] BAST-022: SSM reachability (optional fallback), SSH host-key verification.
- [ ] BAST-023: Terraform destroy plus independently zero session-tagged AWS resource inventory.

## Sprint 03: Ansible/WireGuard (planned)

- [ ] BAST-030: Pinned Ansible roles, SSH/wg/host firewall baseline, idempotence.
- [ ] BAST-031: Pre-enrolled WG identity securely transported; peer handshake established.
- [ ] BAST-032: Home LAN allowed SSH and blocked lateral movement validated.
- [ ] BAST-033: No WireGuard private keys in Git/Terraform/userdata/logs.

## Sprint 04: lifecycle/failure tests (planned)

- [ ] BAST-040: Approved, locked session orchestration with error recovery and telemetry.
- [ ] BAST-041: `down`/`verify-destroy` independently assert no leftover AWS assets.
- [ ] BAST-042: Revocation vs pre-enrolled residual trust explicitly signaled.
- [ ] BAST-043: Fresh second-session bootstrap, interruption, billing/cost/TTL negative tests.

## Sprint 05+: optional integration (evaluate)

- [ ] BAST-050: OIDC/workflow approval model; PR runners stay credential-free.
- [ ] BAST-051: Dynamic home WG peer enrollment from an independent trusted path.
- [ ] BAST-052: Automated expiry beyond instance termination and verified cleanup.

Reference objective mapping: ARM platform AWS-001 hybrid access, AWS-002 networking, AWS-003 IAM/security, AWS-004 CI/CD. Those tickets are cross-references, not substitute evidence in this repository.

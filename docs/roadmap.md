# Roadmap — disposable, reproducible hybrid administrative access

**Status: Sprint 00 drafted, uncommitted.** Gates use P = portable CI, S = isolated simulation, H = real AWS/home site. **Only H can prove a real tunnel or cloud teardown.** Each implementation PR must update current-state docs and sprint evidence; historical sprint records are append-only.

## M0 — Repository / trust foundation (Sprint 00)

Source control, docs index, architecture/mermaid, threat model, ADRs, backlog, CI/bootstrap/validation, sample config schema and negative tests. **No AWS API or LAN change.** Exit: first GitHub commit, CI green, local replay and safe secret/state ignore checks.

## M1 — Empty AWS account bootstrap (Sprint 01)

Human secures AWS root/MFA and establishes temporary administrative identity. Terraform bootstrap root initializes then migrates encrypted versioned state to S3 with lockfile, IAM roles, minimum billing safeguards. State bootstrap recovery and backend destruction boundary. No EC2 yet. Exit: wrong-account refusal, state lock, independent access and documented account recovery.

## M2 — Disposable AWS infrastructure (Sprint 02)

Terraform session VPC/subnet/IGW/routes/SG/EC2/instance profile/encrypted root EBS. Inbound TCP/22 /32 only, egress home endpoint plus necessary bootstrap/SSM egress, IMDSv2, no static AWS credentials, no inbound WG. Exit: clean create/destroy/recreate, SSH identity established and independent residual-resource inspection.

## M3 — Ansible + WireGuard + home trust (Sprint 03)

Ansible configures AMI baseline, Linux hardening, WG client, SSH, firewalls, systemd and host verification. MVP uses pre-enrolled home peer (encrypted independent secret; residual trust documented). EC2 tunnels outbound through existing DDNS to OpenWrt. One approved LAN SSH target succeeds; denied target/VLAN fails. Ansible second pass `changed=0`. SSH host-key trust checked through independent authenticated means.

## M4 — Operator CLI / revocation / verified destruction (Sprint 04)

CLI preflight/plan/up/status/down/verify-destroy and session state machine, interrupted deployment recovery and resource inventory proof. Explicit distinction: inaccessible AWS instance vs destroyed Terraform resources vs revoked home peer. Fail-closed on identity mismatch. Metrics: time-to-ready, time-to-revoke, time-to-zero-residuals, costs. No fabricated TTL guarantee.

## M5 — Trusted automation and hardening (Sprint 05+)

Optional GitHub OIDC + environment approvals + constrained trusted workflow and IAM, if needed. Add per-session WG peer enrollment/revocation with separately trusted home control-plane path to permit restart while remote. Independently evaluate scheduled cleanup/expiry controller and emergency access. Existing PR validation remains credential-free.

## Definitions of done

Portable green does not equal AWS H-pass. A milestone closes only with source code, negative tests, approved PR, applicable real-site evidence, actual resource identity and cost report, updated runbooks and proven cleanup. Keep separate repo with references to arm-homelab-platform AWS-001..004; never pull ARM platform deployment authority into this project.

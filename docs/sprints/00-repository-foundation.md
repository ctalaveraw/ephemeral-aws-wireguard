# Sprint 00 — Repo foundation and portable verification

Status: Draft prepared for initial commit; **not** a completed sprint.

## Problem

An empty AWS account and an existing external home WireGuard endpoint need an independently recoverable, least-privilege implementation path. A Git repository alone does not prove cloud resources can be created or destroyed safely.

## Deliverables proposed

- GitHub canonical repo, scope/roadmap/backlog, architecture Mermaid diagrams and ADRs.
- CI bootstrap adapted from ARM platform with pinned Python tools, consistent ANSI status display and git-tracked source discovery.
- Read-only GitHub Actions: shell/Python/YAML/actionlint, Ansible syntax and config/CI negative contracts.
- Terraform fmt/init-without-backend/validate automatically activates when `.tf` files are introduced; no AWS credentials involved.
- Deliberately fail-closed Ansible placeholders until Sprint 03.
- Explicit nonsecret site config schema and deployment-sentinel restrictions.

## Verification required before close

- [ ] Initial local files merged safely; no earlier docs overwritten.
- [ ] `git add -A`; check `git diff --cached --stat` and `git diff --cached --check`.
- [ ] `bash scripts/ci/bootstrap.sh` exits zero; second execution converges.
- [ ] `bash scripts/ci/validate.sh` exits zero; current test suite has actual nonzero negative cases.
- [ ] No key/state files tracked; example config cannot be used for deployment.
- [ ] GitHub hosted PR/main checks succeed; source recovery from clean clone works.
- [ ] No live AWS or router change was made by Sprint 00.

## Deferred / explicitly not implemented

Terraform AWS account/VPC resources, host configuration, home dynamic peer enrollment, billing ceiling, live access and AWS resource cleanup. Closing Sprint 00 shall not mark any of those delivered.

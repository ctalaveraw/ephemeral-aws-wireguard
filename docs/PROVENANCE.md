# Implementation provenance

This project deliberately adapts the following implementation patterns from
[`arm-homelab-platform`](https://github.com/ctalaveraw/arm-homelab-platform)
`main` at `fd4e7d8a5443c982f9337954a0eeded252f80cd9`:

- `scripts/ci/ui.sh`: source-derived banner, staged console status, ANSI/NO_COLOR contract.
- `scripts/ci/bootstrap.sh`: converge pinned Python dependencies *every run*, even if venv exists.
- `scripts/ci/validate.sh`: `set -Eeuo pipefail`, useful failure stages, tracked-file discovery,
  Bash/ShellCheck/Python/Ruff/YAML/yamllint/actionlint, Ansible syntax and regression gates.
- `.github/workflows/platform-ci.yml`: read-only validation job and checkout credential policy.
- `docs/adr/`, `docs/sprints/`, `docs/roadmap.md`, `docs/backlog.md`, and evidence ledger: historical
  record, explicit negative tests, portable vs hardware/site evidence tiers and safe sequencing.

**Not copied:** Docker Compose storage guards, ARM hardware state, Kubernetes/Flux manifests,
OCI publication and image identity; those are irrelevant to a disposable AWS VM.

**New checks:** Terraform `fmt` and provider-aware `validate` (when `.tf` files appear),
account/site config schema, route and SSH CIDR negatives, secret/state track protection,
and CI credentialless/deployment-free policy. No live cloud API gates in public PR CI.

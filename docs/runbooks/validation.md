# Portable validation runbook

Run from the repository on your machine:

```bash
git add -A
bash scripts/ci/bootstrap.sh
bash scripts/ci/validate.sh
```

The first `git add -A` is deliberate because validators discover tracked (including staged) files via Git. Review `git diff --cached --name-status` before committing; never stage private keys, Terraform state or site.local.yaml. The security tests deny tracked secret/state paths.

For human-readable success styling: `CI_COLOR=always bash scripts/ci/validate.sh`. Default auto selects plain output in non-TTY CI, and `NO_COLOR` overrides.

Gates: bash -n and ShellCheck, all tracked Python AST and YAML/JSON parsing, Ruff, yamllint, actionlint, JSON Schema and negative configuration tests, Ansible playbook syntax, and when `.tf` exists Terraform fmt, offline-backend init and validate. Terraform initialization may download public providers but has no AWS credentials and cannot create resources.

**Fail-fast:** nonzero means do not commit/push as successful. Skipped checks are labeled SKIP, never PASS. CI is portable (P tier): it cannot prove live WireGuard or AWS destroy.

#!/usr/bin/env bash
# Reuses ARM platform stage/UI, git tracked-file discovery and fail-fast behavior.
# P = portable evidence only; NEVER terraform apply/destroy or contact AWS here.
set -Eeuo pipefail
on_error() {
    local rc=$1 line=$2
    trap - ERR
    printf '\nFAIL repository validation (exit %s, line %s).\n' "$rc" "$line" >&2
    exit "$rc"
}
trap 'on_error "$?" "$LINENO"' ERR
repo=$(git rev-parse --show-toplevel)
cd "$repo"
# shellcheck source=scripts/ci/ui.sh
source scripts/ci/ui.sh
ci_ui_init
ci_ui_banner 'REPOSITORY VALIDATION'
printf 'Repository   : %s\n' "$repo"
printf 'Git HEAD     : %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unborn)"
if [[ -x .ci-venv/bin/python ]]; then
    PY=.ci-venv/bin/python
    RUFF=.ci-venv/bin/ruff
    YAML=.ci-venv/bin/yamllint
    ACTION=.ci-venv/bin/actionlint
    ANSIBLE=.ci-venv/bin/ansible-playbook
else
    PY=python3 RUFF=ruff YAML=yamllint ACTION=actionlint ANSIBLE=ansible-playbook
fi
for exe in "$PY" "$RUFF" "$YAML" "$ACTION" "$ANSIBLE"; do
    command -v "$exe" >/dev/null 2>&1 || { ci_ui_fail "Missing $exe; run bootstrap first"; exit 1; }
done
ci_ui_stage 'SHELL SYNTAX / SHELLCHECK'
mapfile -d '' shells < <(git ls-files -z '*.sh')
if (( ${#shells[@]} )); then
    bash -n "${shells[@]}"
    ci_ui_pass 'Bash syntax' "${#shells[@]} scripts"
    if command -v shellcheck >/dev/null 2>&1; then
        shellcheck "${shells[@]}"
        ci_ui_pass 'ShellCheck' "${#shells[@]} scripts"
    elif [[ "${CI:-false}" == true ]]; then
        ci_ui_fail 'Missing ShellCheck in CI'; exit 1
    else
        ci_ui_warn 'ShellCheck skipped locally (not installed)'
    fi
else
    ci_ui_note 'SKIP: no tracked Bash scripts'
fi
ci_ui_stage 'PYTHON + YAML + JSON PARSE'
"$PY" - <<'PY_PARSE_EWG'
import ast
import json
import subprocess
from pathlib import Path
import yaml
tracked = [Path(p) for p in subprocess.check_output(['git','ls-files','-z']).decode().split('\0') if p]
counts = dict(py=0, yaml=0, json=0)
for path in tracked:
    if path.suffix == '.py':
        ast.parse(path.read_text(), filename=str(path)); counts['py'] += 1
    elif path.suffix in {'.yml','.yaml'}:
        with path.open() as stream: list(yaml.safe_load_all(stream))
        counts['yaml'] += 1
    elif path.suffix == '.json':
        json.loads(path.read_text()); counts['json'] += 1
print('  Parsed:', ', '.join(f'{k}={v}' for k,v in counts.items()))
PY_PARSE_EWG
ci_ui_pass 'Parser checks'
ci_ui_stage 'PYTHON RUFF'
mapfile -d '' pys < <(git ls-files -z '*.py')
if (( ${#pys[@]} )); then
    "$RUFF" check "${pys[@]}"
    ci_ui_pass 'Ruff' "${#pys[@]} files"
else ci_ui_note 'SKIP: no Python files'; fi
ci_ui_stage 'YAML LINT / ACTIONLINT'
mapfile -d '' yamls < <(git ls-files -z '*.yml' '*.yaml')
if (( ${#yamls[@]} )); then
    "$YAML" -c .yamllint.yml "${yamls[@]}"
    ci_ui_pass 'yamllint' "${#yamls[@]} files"
else ci_ui_note 'SKIP: no YAML'; fi
mapfile -d '' workflows < <(git ls-files -z '.github/workflows/*.yml' '.github/workflows/*.yaml')
if (( ${#workflows[@]} )); then
    "$ACTION" "${workflows[@]}"
    ci_ui_pass 'actionlint' "${#workflows[@]} workflow(s)"
else ci_ui_note 'SKIP: no workflows'; fi
ci_ui_stage 'REPOSITORY SECURITY / CONFIGURATION CONTRACTS'
"$PY" -m unittest discover -s tests -p 'test_*.py' -v
ci_ui_pass 'Unit and negative contract tests'
ci_ui_stage 'ANSIBLE PLAYBOOK SYNTAX'
mapfile -d '' playbooks < <(git ls-files -z 'ansible/playbooks/*.yml' 'ansible/playbooks/*.yaml')
if (( ${#playbooks[@]} )); then
    for playbook in "${playbooks[@]}"; do
        "$ANSIBLE" -i ansible/inventory/ci.ini --syntax-check "$playbook" >/dev/null
        ci_ui_pass 'Ansible syntax' "$playbook"
    done
else ci_ui_note 'SKIP: no tracked Ansible playbooks'; fi
ci_ui_stage 'TERRAFORM FORMAT / OFFLINE PLAN VALIDATION'
mapfile -d '' tf_files < <(git ls-files -z '*.tf')
if (( ${#tf_files[@]} )); then
    command -v terraform >/dev/null 2>&1 || { ci_ui_fail 'Terraform required when .tf files are tracked'; exit 1; }
    terraform fmt -check -recursive
    ci_ui_pass 'Terraform fmt' "${#tf_files[@]} files"
    for component in bootstrap/terraform infrastructure/terraform; do
        if compgen -G "$component/*.tf" >/dev/null; then
            (cd "$component" && TF_IN_AUTOMATION=true terraform init -backend=false -input=false -lockfile=readonly)
            (cd "$component" && terraform validate -no-color)
            ci_ui_pass 'Terraform validate' "$component"
        fi
    done
else
    ci_ui_note 'SKIP: Terraform roots contain no code yet (Sprint 01/02)'
fi
ci_ui_finish 'Portable gates passed (no AWS or LAN changes performed)'

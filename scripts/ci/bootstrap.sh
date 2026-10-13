#!/usr/bin/env bash
# Based on ARM platform dependency-convergence bootstrap, scoped to this repo.
set -Eeuo pipefail
on_error() {
    local rc=$1 line=$2
    trap - ERR
    printf '\nFAIL CI bootstrap (exit %s, line %s). Review the output above.\n' "$rc" "$line" >&2
    exit "$rc"
}
trap 'on_error "$?" "$LINENO"' ERR
repo=$(git rev-parse --show-toplevel)
cd "$repo"
# shellcheck source=scripts/ci/ui.sh
source scripts/ci/ui.sh
ci_ui_init
ci_ui_banner 'DEPENDENCY BOOTSTRAP'
printf 'Repository : %s\n' "$repo"
printf 'Git HEAD   : %s\n' "$(git rev-parse --short HEAD 2>/dev/null || echo unborn)"
command -v python3 >/dev/null 2>&1 || { ci_ui_fail 'python3 missing'; exit 1; }
ci_ui_stage 'REPOSITORY VIRTUAL ENVIRONMENT'
if [[ ! -x .ci-venv/bin/python ]]; then
    python3 -m venv .ci-venv
    ci_ui_note 'Created .ci-venv'
else
    ci_ui_note 'Reusing .ci-venv'
fi
ci_ui_stage 'PINNED STATIC VALIDATION TOOLS'
.ci-venv/bin/python -m pip install --disable-pip-version-check \
    'ansible-core==2.21.4' 'PyYAML>=6,<7' 'ruff==0.16.10' \
    'yamllint==1.38.0' 'actionlint-py==1.7.12.25' 'jsonschema==4.25.1'
ci_ui_pass 'Python tools installed or converged'
ci_ui_stage 'SHELLCHECK'
if command -v shellcheck >/dev/null 2>&1; then
    ci_ui_pass 'ShellCheck available'
elif [[ "${CI:-false}" == true ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq shellcheck
    command -v shellcheck >/dev/null 2>&1
    ci_ui_pass 'ShellCheck installed'
else
    ci_ui_warn 'ShellCheck missing locally; required in GitHub CI'
fi
ci_ui_stage 'EXECUTABLES'
for exe in python ansible-playbook ruff yamllint actionlint; do
    [[ -x ".ci-venv/bin/$exe" ]] || { ci_ui_fail "Missing $exe"; exit 1; }
    ci_ui_pass "$exe"
done
if command -v terraform >/dev/null 2>&1; then
    ci_ui_note "$(terraform version -json | .ci-venv/bin/python -c 'import sys,json; print(json.load(sys.stdin)["terraform_version"])') Terraform"
else
    ci_ui_warn 'Terraform not installed locally; mandatory when .tf files are introduced'
fi
ci_ui_finish 'Bootstrap toolchain ready'

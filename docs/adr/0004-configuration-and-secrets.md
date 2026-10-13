# ADR-0004: Classified configuration and independent secret recovery

Status: Accepted as **target design** (not live implementation)
Date: 2026-10-13

## Context

We need reproducible, independently operable remote SSH access into the home network, with no continuously running AWS bastion and no CI/cluster administrator credentials in public workflows.

## Decision

Version controlled public topology defaults, ignored site-specific nonsecret YAML, temporary AWS SSO credentials and encrypted WG/SSH/bootstrap recovery identities are separate classes. Config schema must refuse broad routes and secrets fields. No WG private key in Terraform state, EC2 userdata, PR CI, logs or Git. Home Cloudflare API token stays on router.

## Consequences and trade-offs

Additional enrollment ceremony but defensible recovery and audit. Evidence: negative leak tests and state examination; code reviews are not proof of actual secrecy.

## Verification required

Plan, source checks, explicitly denied failure cases, and actual AWS/home state must be recorded in the future implementing sprint. No deployment claims are implied by accepting this target architecture.

# ADR-0002: Separate persistent AWS bootstrap and ephemeral Terraform session roots

Status: Accepted as **target design** (not live implementation)
Date: 2026-10-13

## Context

We need reproducible, independently operable remote SSH access into the home network, with no continuously running AWS bastion and no CI/cluster administrator credentials in public workflows.

## Decision

Account root MFA and temporary human AWS login are external prerequisites. Bootstrap Terraform uses carefully controlled local state initially, migrates to versioned encrypted private S3 with native lockfile, and remains across sessions. Session Terraform uses a separate state key and destroy scope. Commit provider lockfiles; never commit state.

## Consequences and trade-offs

A bare AWS account can be prepared without circular self-provisioning. Cost: permanent bucket/IAM and state recovery procedure. Evidence: lock contention, wrong-account denial, destruction excludes bootstrap.

## Verification required

Plan, source checks, explicitly denied failure cases, and actual AWS/home state must be recorded in the future implementing sprint. No deployment claims are implied by accepting this target architecture.

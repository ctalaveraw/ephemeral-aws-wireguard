# ADR-0005: Approved local orchestration and credentialless pull request CI

Status: Accepted as **target design** (not live implementation)
Date: 2026-10-13

## Context

We need reproducible, independently operable remote SSH access into the home network, with no continuously running AWS bastion and no CI/cluster administrator credentials in public workflows.

## Decision

A trusted operator CLI coordinates Terraform/Ansible and approval after protected Git review; GitHub Actions only lints, validates and simulates. Remote deployment via OIDC requires separate ADR/approval-controlled environment and no privilege for PR jobs.

## Consequences and trade-offs

Preserves separation of concerns. Evidence: CI permissions test, local identity pin and interruption recovery.

## Verification required

Plan, source checks, explicitly denied failure cases, and actual AWS/home state must be recorded in the future implementing sprint. No deployment claims are implied by accepting this target architecture.

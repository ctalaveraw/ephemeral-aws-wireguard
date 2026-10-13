# ADR-0006: Distinguish network revocation, AWS destruction and independent verification

Status: Accepted as **target design** (not live implementation)
Date: 2026-10-13

## Context

We need reproducible, independently operable remote SSH access into the home network, with no continuously running AWS bastion and no CI/cluster administrator credentials in public workflows.

## Decision

`down` separately attempts home peer denial, Terraform session resource destruction and AWS-resource residual inventory. The MVP pre-enrolled WG peer retains narrowly scoped trust between sessions; no pretend per-session revocation. EC2 TTL termination is a fallback, not complete stack cleanup. Report incomplete steps as failures.

## Consequences and trade-offs

Easier to reason about failures, but a stale peer risk remains until independent dynamic enrollment exists. Evidence: kill midway, missed EC2, leftover EBS/ENI, separate account backend and home peer checks.

## Verification required

Plan, source checks, explicitly denied failure cases, and actual AWS/home state must be recorded in the future implementing sprint. No deployment claims are implied by accepting this target architecture.

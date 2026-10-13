# ADR-0001: Single authoritative resource owner and independent execution trust

Status: Accepted as **target design** (not live implementation)
Date: 2026-10-13

## Context

We need reproducible, independently operable remote SSH access into the home network, with no continuously running AWS bastion and no CI/cluster administrator credentials in public workflows.

## Decision

Terraform is the sole owner of AWS declarative resources; Ansible converges EC2 and specifically approved home peer settings; the local session CLI coordinates, never independently rewrites owner-managed resources. Public GitHub CI has read-only source access and does not receive deployment credentials.

## Consequences and trade-offs

Reduced drift and privilege coupling; cost is explicit orchestration and recovery logic. Evidence: deny PR deploy, detect wrong owners, idempotence and resource inventory.

## Verification required

Plan, source checks, explicitly denied failure cases, and actual AWS/home state must be recorded in the future implementing sprint. No deployment claims are implied by accepting this target architecture.

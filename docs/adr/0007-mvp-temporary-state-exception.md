# ADR-0007: Accelerate disposable EC2 MVP before baseline ownership exists

Status: Accepted as **temporary exception / code proposal**; no live deployment evidence.
Date: 2026-11-25

## Context

AWS Organizations and Identity Center member-account CLI access were established manually, but the independently owned `aws-automated-account-baseline` project remains empty. Delaying all workload practice until a Control Tower/AFT landing zone is built increases learning friction. The operator requested a functioning, disposable SSH EC2 MVP first.

## Decision

Build only a Terraform-owned SSH-only EC2 session stack in the existing member account, using temporary SSO credentials and a **local, Git-ignored Terraform state file on an encrypted operator workstation**. Do not create persistent IAM/state resources or touch organization accounts in the bastion root. Provider `allowed_account_ids` rejects the wrong account. The entire session must be destroyed before state is migrated or disposed of. A direct SSH public key is allowed; private key material remains on the operator workstation. No GitHub PR workflow receives AWS credentials.

## Consequences

This is less resilient than a protected versioned S3 backend; losing local state can leave paid resources orphaned. Until the baseline supplies an approved backend/role, the operator MUST retain local state, explicitly supervise apply/destroy and independently query resource inventories. Use a single session; avoid concurrent operators. There is no auto-expiry or safe declaration of cost-free service.

## Exit / convergence with baseline

After the baseline project provides an independently governed backend, IAM execution role and account handoff, **plan a reviewed migration** with state backup, locking, identity checks and rollback. Do not allow both repos to own the same state bucket or IAM role. Add Ansible and WireGuard only after SSH-only MVP's real create, connect, destroy and inventory acceptance.

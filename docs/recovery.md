# Recovery and destroy-first playbook (proposed)

## Resource classifications

- **Persistent account layer:** protected S3 Terraform state/versioning/lockfiles, narrow IAM/billing security. Exists when no bastion is active.
- **Disposable session:** EC2/EBS/VPC/subnet/SG/route table/IGW/instance profile and its enrolled temporary WireGuard identity, when dynamic enrollment exists.
- **Independent protected material:** operator SSH keys and home/router recovery secret; not Terraform-owned and not in Git.

## Required order for `down`

1. Identify exact session ID, AWS identity, region, bootstrap/session state lock.
2. Disable/revoke home session access **if an independent home control channel is available**. If using pre-enrolled MVP peer, document residual dormant trust and enforce narrow firewall rules; no misleading 'revoked' success.
3. Terraform destroy only the session root, never account bootstrap state; preserve debugging information on failure.
4. Query AWS for session-owned resources independently; verify no session resources and no ongoing billable session assets.
5. Record evidence (IDs, times, result), redact private addresses if sharing publicly, and handle state discrepancy manually.

A timed EC2 shutdown or automatic instance termination cannot guarantee the VPC, security group, IAM profile, logs or remote Terraform state are deleted. Verify independently.

## Failure cases to test in Sprint 04

- Terraform apply stops halfway; down still works.
- Ansible fails before peer enrollment; remaining AWS resources are destroyed.
- Wrong AWS account blocks commands before changing anything.
- Destroy reports partial failure and session tag inventory still identifies leftovers.
- EC2 abruptly disappears but EBS/EIP/state resources remain and are identified.
- Home becomes unreachable; peer revocation is reported unverified, not falsely PASS.
- Second deployment reproduces functionality with new EC2 instance and verified SSH host key.

No recovery time guarantees are claimed before these tests run.

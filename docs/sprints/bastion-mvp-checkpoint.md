# Bastion MVP pairing checklist

Branch: `feat/mvp-ec2-ssh`. Run commands from `infrastructure/terraform` on the workstation holding the saved plan and local state. [Deployment runbook](../../infrastructure/terraform/README.md).

- [x] Operator signed in to the terraform member account via SSO and verified the assumed role.
- [x] Terraform initialized, validated, and saved mvp.tfplan. First plan reported 10 additions, zero changes, zero deletions.
- [x] AWS provider v6.74.0 lock file committed at f38de36.
- [x] Review saved plan locally with `terraform show mvp.tfplan`. Confirm account, operator /32 on inbound TCP 22, expected instance and encrypted root disk.
- [x] Recovery apply completed: 3 added, 0 changed, 2 destroyed. The t4g.nano is running in us-east-1a with 3/3 checks passed.
- [ ] Verify SSH host fingerprint through authenticated EC2 console output. Connect as ec2-user, check whoami, and check denied access from a separate source.
- [ ] Destroy from the same checkout. Verify empty Terraform state and independently check session resources in AWS. Record residuals or confirmed cleanup and cost evidence.
- [ ] Align .terraform-version and CI CLI pin with 1.17.2 and verify CI.

Latest operator evidence: recovery apply succeeded. SSH to the public IPv4 timed out before authentication. Compare the workstation egress address with the live TCP/22 ingress rule. The session is live and teardown remains pending. If the thread changes, refresh branch HEAD, read this checklist, and ask whether an apply or destroy happened after the checkpoint before issuing a mutating command.

Keep this milestone SSH-only. WireGuard to the home target and independent expiry are later milestones. The operator owns manual teardown during this run. Never attach private keys, raw state, or saved plan files to the handoff.

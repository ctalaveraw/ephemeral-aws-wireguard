# MVP SSH bastion — Terraform root

**Scope:** One disposable Amazon Linux 2023 ARM64 EC2 VM, public SSH from a single /32, and dedicated VPC networking. No Ansible, WireGuard, Control Tower, AFT, SSM instance role, permanent EIP, NAT Gateway, or load balancer.

**Temporary state exception:** This root uses LOCAL Terraform state, **only** on a trusted full-disk-encrypted workstation. Never run this from GitHub Actions. Do not delete/move the state file until all AWS resources are destroyed and independently checked. The separate baseline repository will eventually own the protected remote state backend and execution-role contract. See ADR-0007.

## Local setup (no AWS changes)

1. Confirm AWS CLI profile uses the intended member account, *not* organization management.
2. Create an Ed25519 SSH identity locally if you do not already have one. NEVER put the private key in Terraform or Git.
3. `cp terraform.tfvars.example terraform.tfvars` and fill account ID, single public IPv4 /32 and SSH PUBLIC key. The `.tfvars` file is ignored.
4. `export AWS_PROFILE=tf-bootstrap` (or use your own profile); `aws sso login --profile "$AWS_PROFILE"`.
5. Verify identity with `aws sts get-caller-identity` in your private terminal.
6. Run `terraform init`; **commit the generated `.terraform.lock.hcl`** while keeping state and real `.tfvars` ignored.
7. Run `terraform fmt -check`, `terraform validate`, and `terraform plan -out=mvp.tfplan`. Inspect the entire plan. Do not apply without operator approval.

## Approved creation (creates billable resources)

```bash
cd infrastructure/terraform
terraform apply mvp.tfplan
terraform output
```

Use `aws ec2 get-console-output` or another authenticated, independent source to establish the instance's SSH host key identity before accepting it. Never use `StrictHostKeyChecking=no` for convenience. The operating system default username is `ec2-user`.

## Approved destruction (required after experiment)

```bash
terraform destroy
```

Review the destroy plan and confirm it applies to the **MVP session root**, not the organization baseline. Independently inspect the EC2 instance, VPC, EBS volumes, network interfaces, security groups, key pair, and public-IP usage with AWS CLI in the expected account and region. A successful `destroy` is not the same as an independent residual-resource inventory.

## Costs

Expect EC2 Linux on-demand compute, one public IPv4 address and an 8 GiB gp3 volume to accrue charges while active. No Free Tier eligibility is assumed for an AWS Organizations member account. This MVP adds no NAT Gateway or load balancer. The S3 backend is deliberately postponed.

## Not proven by this root

There is no automatic four-hour expiry, WireGuard, peer revocation, SSH certificate trust, remote state protection, or automatic teardown after machine failure. Those are separate acceptance gates.

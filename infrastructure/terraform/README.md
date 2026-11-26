# MVP SSH bastion — Terraform root

**Scope:** One disposable Amazon Linux 2023 ARM64 EC2 VM, public SSH from a single /32, and dedicated VPC networking. No Ansible, WireGuard, Control Tower, AFT, SSM instance role, permanent EIP, NAT Gateway, or load balancer.

**Temporary state exception:** This root uses LOCAL Terraform state, **only** on a trusted full-disk-encrypted workstation. Never run this from GitHub Actions. Do not delete/move the state file until all AWS resources are destroyed and independently checked. The separate baseline repository will eventually own the protected remote state backend and execution-role contract. See ADR-0007.

## Local setup (no AWS changes)

Start with Git, AWS CLI v2, OpenSSH and Terraform CLI 1.17.2. The member account must have an IAM Identity Center user or group assigned a deployment permission set. For a fresh workstation, run `aws configure sso`, enter the access portal URL and its primary Region, choose the workload account and assigned role, and name the profile `tf-bootstrap`.

```bash
git clone --branch feat/mvp-ec2-ssh https://github.com/ctalaveraw/ephemeral-aws-wireguard.git
cd ephemeral-aws-wireguard/infrastructure/terraform
export AWS_PROFILE=tf-bootstrap AWS_REGION=us-east-1
aws sso login --profile "$AWS_PROFILE"
aws sts get-caller-identity
terraform version
```

Compare the account with the workload account ID in Organizations. All remaining commands run from this Terraform directory.

For a new SSH identity, choose an unused path under `~/.ssh` and run `ssh-keygen -t ed25519 -f ~/.ssh/bastion-lab`. You can also use an existing key. Copy `terraform.tfvars.example` to `terraform.tfvars` and replace the account ID, example operator IP with your public IPv4 plus /32, and example public key with the single line from the .pub file. Keep the matching private key on the workstation.

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=mvp.tfplan
```

Review the account, SSH ingress /32, instance type and encrypted root disk. A first plan at revision e8d9773 produced 10 additions, zero changes and zero deletions. Keep saved plans, state, private keys and real tfvars out of Git. A public SSH key is expected in the plan. On the first run, review and commit the generated provider lock file with `git add -- .terraform.lock.hcl`. Subsequent checkouts use that file during init.

## Approved creation (creates billable resources)

```bash
terraform apply mvp.tfplan
terraform output
```

Use `aws ec2 get-console-output` or another authenticated, independent source to establish the instance's SSH host key identity before accepting it. Never use `StrictHostKeyChecking=no` for convenience. The operating system default username is `ec2-user`.

After checking the host fingerprint against the EC2 console output, connect with `ssh -o IdentitiesOnly=yes -i ~/.ssh/bastion-lab "$(terraform output -raw ssh_target)"`. Substitute your private key path. Run `whoami` to verify the login, then `exit` to return to the workstation.

## Approved destruction (required after experiment)

```bash
terraform destroy
```

Review the destroy plan and confirm it applies to the **MVP session root**, not the organization baseline. Independently inspect the EC2 instance, VPC, EBS volumes, network interfaces, security groups, key pair, and public-IP usage with AWS CLI in the expected account and region. A successful `destroy` is not the same as an independent residual-resource inventory.

## Costs

Expect EC2 Linux on-demand compute, one public IPv4 address and an 8 GiB gp3 volume to accrue charges while active. No Free Tier eligibility is assumed for an AWS Organizations member account. This MVP adds no NAT Gateway or load balancer. The S3 backend is deliberately postponed.

## Not proven by this root

There is no automatic four-hour expiry, WireGuard, peer revocation, SSH certificate trust, remote state protection, or automatic teardown after machine failure. Those are separate acceptance gates.

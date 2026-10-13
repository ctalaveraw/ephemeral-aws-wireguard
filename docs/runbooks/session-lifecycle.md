# Session runbook — planned, intentionally not executable

Prerequisites: separate non-root AWS temporary credentials, exact account/region, protected state backend, reviewed source commit, approved /32 operator IP, trusted SSH host-key acquisition, independent WG private identity and reachable home DDNS endpoint. Full instructions are postponed until code exists.

1. Preflight the correct AWS account, backend ownership, lock, cost/resource ceiling and site config.
2. Review `terraform plan` and explicit resource set before approval.
3. Create AWS session stack; verify EC2/SSH metadata through authenticated AWS interface.
4. Apply Ansible host baseline twice, expect second unchanged.
5. Prove WG handshake from bastion to OpenWrt and SSH permitted host via ProxyJump without copying home SSH private key to AWS.
6. Prove forbidden LAN/VLAN destination denied before increasing allowed scope.
7. Tear down: revoke access where supported, destroy session Terraform state, independently inventory AWS residuals, report home peer residual trust.
8. Recreate from clean conditions and record measured time/cost.

**Abort:** wrong AWS account, unsecured SSH source, secret in tfstate or userdata, unknown host key, unexpectedly wide routes, unreachable home endpoint or incomplete cleanup. Do not weaken controls to get a green script.

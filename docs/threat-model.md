# Threat model — ephemeral AWS bastion

**Status:** Baseline assumptions; security properties require negative tests at the specified stage.

## Assets and trust boundaries

- Protected account administrator and short-lived session deployer permissions.
- Stateful Terraform backend, lock, audit, cloud resource inventory.
- SSH operator identity and **verified** EC2 SSH host key, independent of ephemeral IPv4.
- WireGuard private identity, home peer enrollment mechanism, OpenWrt firewall allowlist.
- Home LAN hosts and VLAN isolation, which AWS must not bypass.
- Independent operator secret store, CI runner with no AWS credentials.

## Adversaries / failure events

1. Untrusted pull request attempts to run AWS apply, read cloud credentials, or exfiltrate key material.
2. Public EC2 IP is scanned for SSH; an unwanted client attempts password/root login.
3. Compromised EC2 uses its valid WireGuard tunnel to pivot laterally into the LAN.
4. Operator's WAN IP changes and broad SSH ingress is enabled to 'fix' access.
5. Home WG peer remains trusted after AWS teardown; stolen private key reconnects later.
6. Interrupted Terraform apply/destroy leaves costly IAM, EBS, EIP, or networking resources.
7. Session expiry stops EC2 while backend/networking remains (auto-expiry is NOT full teardown).
8. Secret accidentally lands in Terraform plan/state, Git, user data, logs or Actions artifacts.
9. A missing route causes SSH lockout, or broad AllowedIPs steals AWS management traffic.

## Required mitigations and evidence

| Threat | Preventive control | Test/evidence milestone |
|---|---|---|
| PR privileges | `contents: read`, no AWS OIDC/secrets on PR CI | S0 automated tests |
| SSH attack | /32 SG, keys only, no root/password; optional SSM | S2 AWS resource introspection + denied source |
| Bastion compromise | dedicated WireGuard peer, home firewall per target/VLAN | S3 authorized SSH succeeds, denied lateral movement |
| Credential leakage | independent encrypted secrets, safe injection, no Terraform secrets | S3 source + state scan, negative tests |
| Account confusion | exact account and region assertions before plan/apply | S1/S2 wrong-account fail |
| Cost orphan | destructive inventory by session tags + post-destroy AWS queries | S4 partial failure/recovery simulation |
| Long-lived home trust | distinguish persistent MVP enrollment from per-session revocation | S4/S5 remote-restart proof |
| Reused IP SSH trust | host-key verification through authenticated AWS/SSM metadata | S3 negative host-key case |

## Explicit nonclaims

No claim of secure inter-VLAN access, live AWS least privilege, SSH hardened state, automatic TTL destruction, or VPN peer revocation until verified. Threat-model controls are not evidence of runtime enforcement.

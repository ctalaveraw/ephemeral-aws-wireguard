# Accepted target design gates — Sprint 00 proposals

| Gate | Decision | Forbidden shortcut | Proof |
|---|---|---|---|
| DG-01 | GitHub is reviewed declarative source | Merge triggers automatic AWS apply | CI test/PR settings |
| DG-02 | Terraform owns AWS; Ansible host; CLI orchestration | Two tools simultaneously own same resource | Architecture/plan boundaries |
| DG-03 | Persistent account bootstrap vs ephemeral session states | `down` destroys backend or strands lock | Bootstrap/destroy evidence |
| DG-04 | OpenWrt is WG server; AWS is outbound client | Public WG port on AWS or EC2 full-tunnel | Routing/firewall tests |
| DG-05 | Current SSH /32 and verified host key | Password SSH, `StrictHostKeyChecking=no`, wide 22 ingress | Negative tests |
| DG-06 | No secrets in Terraform state/userdata/repo | Pass WG private key through tfvar/GitHub secret | Code/state artifact scans |
| DG-07 | CI read-only, noncredentialed P tier | Deploy on PR or generic push | Actions permission test |
| DG-08 | `down` distinct revoke, destroy, verify | EC2 stopped means stack destroyed | AWS inventories and VPN denial |
| DG-09 | WireGuard pre-enrolled MVP peer is residual trust | Declare peer revoked without home channel | Threat model and H-tier test |
| DG-10 | Accumulate staged evidence, not imagined success | A successful formatter proves live VPN | Sprint docs/evidence ledger |

Design gates may be modified only with a documented ADR/PR. Local operator runtime configuration is not a hidden secondary source of architecture authority; it is a separately validated site parameterization.

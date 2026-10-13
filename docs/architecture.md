# Architecture — Source, Provisioning, Runtime, Destruction

**Status:** Designed, not deployed. Existing home endpoint and DDNS were reported operational; all AWS stages unimplemented.

## Data and control planes

```mermaid
flowchart TB
    OP["Operator machine<br/>local SSO / encrypted key store"]
    GH["GitHub<br/>protected main and PR CI"]
    CI["Static / portable checks<br/>NO AWS permissions"]
    ORCH["Future bastionctl<br/>approval + session identity"]
    subgraph ACCOUNT["Persistent AWS account bootstrap — Sprint 01"]
      IAM["Least privilege bootstrap and session IAM"]
      S3["S3 state backend<br/>versioned / encrypted / lockfiles"]
      BUDGET["Cost guardrails"]
    end
    subgraph SESSION["Disposable AWS session — Sprint 02+"]
      VPC["VPC / public subnet / IGW / routes / SG"]
      EC2["EC2 bastion<br/>SSH / outbound WG"]
      EBS["Encrypted root EBS<br/>delete on termination"]
      VPC --> EC2
      EC2 --- EBS
    end
    subgraph HOME["Persistent home, existing"]
      ROUTER["OpenWrt<br/>WG listener + DDNS"]
      POLICY["VLAN firewall<br/>least allowed destinations"]
      HOSTS["R5C / Pis / Proxmox / approved hosts"]
      ROUTER --> POLICY --> HOSTS
    end
    GH --> CI
    GH -->|"reviewed source"| ORCH
    OP -->|"explicit up/down"| ORCH
    OP -->|"SSH / ProxyJump"| EC2
    ORCH -->|"Terraform"| VPC
    ORCH -->|"Ansible"| EC2
    ORCH -->|"approved peer enrollment"| ROUTER
    IAM --> VPC
    ORCH --> S3
    EC2 -->|"WireGuard initiated outbound"| ROUTER
    BUDGET -.->|"warning, not deletion guarantee"| EC2
```

## Network routing decision

- AWS bastion has inbound TCP/22 restricted to a current public IPv4 /32; there is no inbound WireGuard listener on EC2.
- EC2 connects to the existing DDNS-managed home WireGuard endpoint over outbound UDP.
- OpenWrt authenticates a dedicated client peer and routes only allowed LAN/VLAN destinations. Firewall policy—not AllowedIPs alone—enforces LAN access. The MVP uses specific approved SSH destinations before expanding to any VLAN.
- SSH ProxyJump uses the **operator's destination keys on the operator device**. No agent forwarding or SSH private-key copying to EC2 is required.
- Home DDNS/Cloudflare tokens remain on the home router; they are never injected into AWS.

## AWS identity and ownership

The initial account requires human account/root MFA and an independent temporary administrator/Identity Center login. Terraform cannot create the identity used to authenticate before that identity exists. Persistent bootstrap and disposable sessions use different states and scopes. State is sensitive, even if module inputs are public.

## Control and failure path

```mermaid
flowchart TD
    START["Operator: up"] --> PREFLIGHT{"Account/region, keys, state lock<br/>and clean session pass?"}
    PREFLIGHT -->|"no"| STOP["FAIL CLOSED"]
    PREFLIGHT -->|"yes"| PLAN["Terraform plan / review"]
    PLAN --> APPROVE{"Explicit approval?"}
    APPROVE -->|"no"| STOP
    APPROVE -->|"yes"| TF["Terraform apply session resources"]
    TF --> AN["Ansible host converge"]
    AN --> WG["WireGuard handshake + approved SSH"]
    WG --> ACCEPT{"Allowed succeeds / denied fails?"}
    ACCEPT -->|"no"| RECOVER["Stop access and recover / tear down"]
    ACCEPT -->|"yes"| READY["Session ready"]
    READY --> DOWN["Operator: down"]
    RECOVER --> DOWN
    DOWN --> REVOKE["Block/revoke home session peer"]
    REVOKE --> DESTROY["Terraform destroy"]
    DESTROY --> VERIFY["Independent AWS inventory + denied access"]
    VERIFY -->|"residuals"| RECOVER
    VERIFY -->|"zero session resources"| DONE["Session closed"]
```

## Resource ownership contract

See [ADR-0001](adr/0001-single-owner-trust-boundaries.md). No competing Terraform/Ansible router edits; no automatic GitHub push-to-production; no dependence on the ARM R5C, Gitea, Kubernetes, or OpenBao to rebuild the bastion.

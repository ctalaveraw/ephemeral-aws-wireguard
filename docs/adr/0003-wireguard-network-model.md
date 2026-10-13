# ADR-0003: EC2 initiates WireGuard to existing OpenWrt listener

Status: Accepted as **target design** (not live implementation)
Date: 2026-10-13

## Context

We need reproducible, independently operable remote SSH access into the home network, with no continuously running AWS bastion and no CI/cluster administrator credentials in public workflows.

## Decision

Home OpenWrt WireGuard/DDNS remain persistent. EC2 exposes restricted public SSH only, initiates outbound WG, and routes approved home destinations. Use SSH ProxyJump so destination private keys remain on the operator machine. Home router firewall is the authorization enforcement point; AllowedIPs alone does not grant access.

## Consequences and trade-offs

No AWS WG listener, simpler remote start. Home WAN UDP endpoint must remain reachable. Evidence: valid handshake, permitted SSH, denied lateral traffic; no broad SSH SG.

## Verification required

Plan, source checks, explicitly denied failure cases, and actual AWS/home state must be recorded in the future implementing sprint. No deployment claims are implied by accepting this target architecture.

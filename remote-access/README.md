# Remote Access Documentation

## Purpose

This directory contains the documentation for the original Azure lab remote-access implementation based on `WireGuardVM1`.

Together, the documents follow the existing VM from its initial Azure deployment and early use as an SSH jumpbox through its completed configuration and validation as a functional WireGuard VPN gateway. In this documentation set, **end to end** refers to that documented build-and-validation sequence. It does not mean that every possible operational or lifecycle procedure has been documented.

## Documentation Set and Reading Order

1. [WireGuard VM Initial Deployment and Jumpbox Configuration](wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
   
   Records the original Azure VM deployment, network placement, NIC forwarding setting, NSG state, initial Linux preparation, and the limitations of the environment at that stage. Although the VM was intended to become a VPN gateway, the evidence available at this point proved an SSH jumpbox workflow—not a completed workstation-to-VNet VPN path.

2. [Jumpbox Administration Workflow](jumpbox-administration-workflow.md)
   
   Documents the validated administrative path from the local workstation to the public SSH endpoint on `WireGuardVM1`, followed by access from the jumpbox to private Azure resources. It also records internal reachability and forward private-DNS validation performed from `WireGuardVM1`.

3. [WireGuard VPN Server Linux Setup and Configuration](wireguard-vpn-server-linux-setup-and-configuration.md)
   
   Records the Linux-side installation and configuration performed on the existing `WireGuardVM1`, including WireGuard installation, key creation, IPv4 forwarding, the `wg0` interface, forwarding and NAT rules, and `systemd` service management. This work prepared the server but did not, by itself, prove a complete external VPN connection.

4. [WireGuard VPN Server Completion and One-Hop Administration](wireguard-vpn-server-completion-and-one-hop-access.md)
   
   Records the later completion and validation of the existing deployment, including the Windows peer, Azure UDP access, tunnel routing, server forwarding, NAT, handshake and connectivity checks, and direct one-hop administration of private Azure VMs from the workstation.

## What the Documentation Establishes

For the existing `WireGuardVM1`, the combined records establish the following sequence:

1. The Azure VM and its supporting network configuration were deployed.
2. Public SSH access to `WireGuardVM1` was available for administration.
3. `WireGuardVM1` was validated as an SSH jumpbox for reaching private resources.
4. WireGuard and its Linux routing components were installed and configured.
5. The incomplete portions of the original VPN implementation were identified and corrected.
6. The Windows workstation established an authenticated WireGuard tunnel.
7. Traffic was routed through `WireGuardVM1` to the Azure private network.
8. Direct workstation-to-VM reachability and one-hop administration were validated without an interactive SSH session on the gateway.

The completed access path is:

```text
Windows workstation
    -> authenticated WireGuard tunnel
    -> WireGuardVM1 VPN gateway/router
    -> private Azure virtual machines
```

## Important Historical Distinction

The initial deployment must not be described as a completed VPN server merely because WireGuard was installed, `wg0` existed, or the service started successfully. At that stage, the retained evidence proved host preparation and jumpbox-based internal access. It did not yet prove the required external UDP path, a complete client/server peer relationship, an active handshake, correct client routes, or direct workstation-to-private-VM connectivity.

Those missing elements were completed and validated later, as recorded in the completion and one-hop administration document.

## Scope Boundary

This documentation set provides an evidence-backed record of how the existing `WireGuardVM1` progressed from initial deployment to a working VPN gateway. It is not currently a complete operations manual or disaster-recovery package.

The following subjects remain outside the documented end-to-end sequence and may warrant separate runbooks:

- Rebuilding the entire solution from zero through a single automated deployment process.
- Backup and disaster recovery for the VPN server and its configuration.
- WireGuard server-key or client-key rotation.
- Adding, removing, revoking, and auditing future VPN clients.
- Routine patching and maintenance procedures.
- Monitoring, alerting, log retention, and service-health checks.
- Configuration drift detection and periodic security review.
- High availability or gateway failover.
- Recovery from lost credentials, keys, or administrative access.

These omissions do not invalidate the completed implementation. They define the difference between a documented, validated build and a mature operational service with full lifecycle coverage.

## Batch-Deployment WireGuard Scope

The later batch-deployed WireGuard implementation is separate from the original `WireGuardVM1` documentation set. It may use the original environment as a reference or comparison, but it should not be treated as fully documented by the four records listed above.

The batch-deployed implementation should have its own deployment and validation record identifying:

- The resources created by the batch deployment.
- The exact deployment mechanism and configuration inputs.
- Differences from the original `WireGuardVM1` implementation.
- Server and client configuration results.
- Tunnel, routing, DNS, and one-hop access validation.
- Known limitations and remaining operational work.

Keeping the two implementations distinct prevents evidence from the original server from being incorrectly presented as proof of the batch-deployed server's state.

## Evidence Convention

Each document links to the screenshots relevant to its claims. Some evidence is shared across workflows and may be sourced from another folder under `screenshots/remote-access`. The link path identifies the actual evidence source; a document's subject folder should not be assumed to contain every screenshot referenced by that document.

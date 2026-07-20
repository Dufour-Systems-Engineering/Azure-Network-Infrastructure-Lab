# WireGuard VM Initial Deployment and Jumpbox Configuration

## Overview

This document records the initial deployment state and validated administrative use of `WireGuardVM1` in the original Azure lab environment. The VM was deployed with the intended future role of a WireGuard VPN gateway, and its Linux operating system was substantially prepared for that role. At this stage, however, the validated remote-access method was an SSH jumpbox workflow rather than direct workstation access through a functioning WireGuard tunnel.

The validated path was:

```text
Local Windows workstation
    -> public SSH connection
    -> WireGuardVM1
    -> private SSH or network request
    -> internal Azure resource
```

The initial Linux installation and configuration are documented in [WireGuard VPN Server Linux Setup and Configuration](wireguard-vpn-server-linux-setup-and-configuration.md). The later correction and validation of the actual VPN path are documented in [WireGuard VPN Server Completion and One-Hop Administration](wireguard-vpn-server-completion-and-one-hop-access.md).

## Purpose

The initial implementation created a controlled remote-administration entry point that reduced dependence on Azure Bastion and avoided public management interfaces on internal lab systems.

At this stage, `WireGuardVM1` provided:

- A dedicated Ubuntu VM in the remote-access subnet.
- Public SSH access restricted through `WireGuardNSG1`.
- Private network reachability from the VM to internal Azure resources.
- A platform on which WireGuard, Linux forwarding, and NAT were prepared.
- A reusable jumpbox for validation, maintenance, and troubleshooting.

This document does not claim that direct workstation-to-VNet VPN access was operational during the initial stage.

## Prerequisites

The initial deployment depended on:

- Azure subscription access sufficient to manage the VM and its network resources.
- Existing `TestVNet1` network infrastructure.
- The `DMZ-Subnet` remote-access subnet.
- `WireGuardNSG1`.
- A public IP address or DNS name assigned to `WireGuardVM1`.
- A valid SSH identity or credential for the VM.
- Internal NSG rules permitting required traffic from the VNet or jumpbox path.
- An administrator workstation with an SSH client.

The following items were intended for the later VPN role but were not all operationally confirmed during this stage:

- Azure NIC IP forwarding.
- Linux IPv4 forwarding.
- WireGuard listening on UDP `51820`.
- A matching server and Windows peer-key relationship.
- Correct split-tunnel routes on the Windows peer.
- An inbound UDP `51820` NSG rule.

Later inspection confirmed that the UDP `51820` rule had been documented but had not actually been added to `WireGuardNSG1`.

## Deployment Procedure

### 1. Deploy WireGuardVM1

`WireGuardVM1` was deployed as an Ubuntu virtual machine in the dedicated remote-access subnet.

The retained environment records identify:

- Virtual machine: `WireGuardVM1`
- Virtual network: `TestVNet1`
- Subnet: `DMZ-Subnet`
- Private IP: `10.0.0.36`
- Network security group: `WireGuardNSG1`
- Network interface: `wireguardvm1997`

The VM was given a public endpoint so the administrator could establish the initial SSH connection.

See Evidence:

- [WireGuard VM overview](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/01-wireguard-vm-overview.png)
- [WireGuard VM overview bottom properties](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/02-wireguard-vm-overview-bottom.png)

### 2. Confirm Network Placement

The VM was confirmed in `DMZ-Subnet` rather than an internal client or server subnet. This separated the public-facing administrative entry point from the private workloads it was used to manage.

See Evidence:

- [WireGuard network settings](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/03-wireguard-network-settings.png)
- [Azure NIC IP forwarding](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/04-wireguard-ip-forwarding.png)

### 3. Configure Administrative SSH Access

`WireGuardNSG1` permitted TCP `22` from the administrator's recorded public address. This enabled direct SSH to `WireGuardVM1` while avoiding public SSH exposure on the internal VMs.

See Evidence: [WireGuard NSG rules](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/05-wireguard-nsg-rules.png)

### 4. Prepare the Linux Host for Its Intended VPN Role

WireGuard packages, key material, Linux IPv4 forwarding, the `wg0` interface, forwarding rules, NAT masquerading, and the `wg-quick@wg0` service were configured on the VM.

Those Linux-side steps are maintained separately in [WireGuard VPN Server Linux Setup and Configuration](wireguard-vpn-server-linux-setup-and-configuration.md). They prepared the host for its later VPN role but did not, by themselves, establish a complete external tunnel.

See Evidence:

- [WireGuard installation validation](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/06-wireguard-installation-validation.png)
- [WireGuard service status](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/07-wireguard-service-status.png)
- [WireGuard interface status](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/08-wireguard-interface-status.png)
- [WireGuard listening port](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/09-wireguard-listening-port.png)
- [Initial WireGuard server configuration](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/10-wireguard-server-configuration.png)

## Configuration Procedure

### Jumpbox Administrative Role

The initial validated use of `WireGuardVM1` was an interactive SSH jumpbox:

1. Start `WireGuardVM1` if it is stopped or deallocated.
2. Ensure the TCP `22` NSG rule permits the administrator's current public IP.
3. Open an SSH session to the VM's public endpoint.
4. From `WireGuardVM1`, reach internal systems by private IP address.
5. End the sessions and deallocate `WireGuardVM1` when administration is complete.

### Initial WireGuard State

The Linux host contained the following substantial preparation:

- WireGuard and `iptables-persistent` installed.
- Server keys stored under `/etc/wireguard`.
- `wg0` assigned `10.6.0.1/24`.
- Linux IPv4 forwarding enabled.
- Forwarding and NAT commands defined in `wg0.conf`.
- `wg-quick@wg0` enabled through `systemd`.
- Azure NIC IP forwarding enabled.

The initial records did not conclusively establish a usable VPN path because:

- UDP `51820` was not yet permitted by `WireGuardNSG1`.
- The server and Windows peer-key relationship required correction.
- The Windows peer routes required correction.
- No retained evidence proved a current handshake and direct one-hop administration.

### Optional SSH Convenience Function

A PowerShell profile function was later used to shorten the public SSH command to `WireGuardVM1`:

```powershell
function wgssh {
    ssh -i "<PATH_TO_PRIVATE_KEY>" <ADMIN_USER>@<WIREGUARD_PUBLIC_IP_OR_DNS>
}
```

This function simplified the jumpbox login only. It did not create a WireGuard tunnel or provide private workstation routing.

See Evidence:

- [PowerShell profile quick-connect function](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/13-powershell-profile-quick-connect-function.png)
- [PowerShell quick-connect login validation](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/14-wireguard-quick-connect-login-validation.png)

## Verification

### Public SSH Access to WireGuardVM1

The administrator successfully connected from the local workstation to `WireGuardVM1` through its public endpoint.

This validated:

```text
Local workstation -> WireGuardVM1
```

See Evidence: [WireGuard VM public SSH login](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/11-vpn-gateway-login.png)

### Private Access from the Jumpbox

From the active shell on `WireGuardVM1`, the administrator reached an internal Azure system through its private address.

This validated:

```text
WireGuardVM1 -> internal Azure resources
```

See Evidence: [Private IP SSH validation](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/12-private-ip-ssh-validation.png)

### What Was Not Yet Validated

The initial evidence did not validate:

- An inbound WireGuard connection from the Windows workstation.
- A current WireGuard handshake.
- Workstation reachability to `10.6.0.1`.
- Workstation reachability to Azure private IP addresses through the tunnel.
- Direct one-hop SSH from the workstation to internal Azure VMs.

Those results were obtained later and are documented in the completion record.

## Common Issues

### Initial Documentation Overstated the VPN State

Earlier documentation described `WireGuardVM1` as an operational VPN gateway before the required UDP rule, peer configuration, client routes, and one-hop validation had been confirmed.

The corrected interpretation is that the VM was prepared for a VPN role but was operationally validated only as an SSH jumpbox at this stage.

### Public SSH Works but the VPN Does Not

Public SSH and WireGuard use different network paths and authentication systems. Successful SSH to TCP `22` does not prove that UDP `51820`, WireGuard peer authentication, or split-tunnel routing works.

### Jumpbox Tests Are Misidentified as Workstation Tests

Commands issued after signing in to `WireGuardVM1` originate from that VM. They prove jumpbox-to-resource reachability, not direct workstation-to-resource VPN reachability.

### WireGuard and SSH Keys Are Confused

WireGuard keys authenticate tunnel peers. SSH keys authenticate Linux user sessions. They are not interchangeable.

## Lessons Learned

- Intended architecture must be distinguished from validated implementation.
- Installing and enabling WireGuard on Linux does not complete the Azure network path.
- Public SSH success does not prove VPN success.
- Evidence must identify the system from which each network test originated.
- Retaining the earlier jumpbox stage provides useful engineering history when its limitations are stated accurately.
- Later direct inspection should control when it contradicts an earlier generalized summary.

## Related Documents

- [WireGuard VPN Server Linux Setup and Configuration](wireguard-vpn-server-linux-setup-and-configuration.md)
- [Jumpbox Administration Workflow](jumpbox-administration-workflow.md)
- [WireGuard VPN Server Completion and One-Hop Administration](wireguard-vpn-server-completion-and-one-hop-access.md)
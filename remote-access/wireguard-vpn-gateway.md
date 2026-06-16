# WireGuard VPN Gateway

## Overview

A dedicated Ubuntu Linux virtual machine was deployed as a secure remote-access gateway for the Azure lab environment. WireGuard was selected as the VPN solution due to its lightweight design, strong cryptographic defaults, and straightforward configuration model.

The gateway provides secure administrative access to Azure resources that do not expose public management interfaces. After connecting to the WireGuard VPN, administrators can establish SSH sessions to internal systems using private IP addresses, eliminating the need for direct internet exposure of lab workloads.

---

## Purpose

The original lab design relied on Azure Bastion for remote administration. While functional, Bastion introduced ongoing costs and provided capabilities beyond the requirements of the environment.

The WireGuard VPN gateway was implemented to:

* Replace Azure Bastion with a lower-cost remote access solution.
* Provide secure encrypted access to private Azure resources.
* Eliminate public management access to internal Linux servers.
* Enable administration through private IP addressing.
* Simulate remote-access patterns commonly used in production environments.
* Provide a reusable administrative access point for recurring lab maintenance.

---

## Prerequisites

Before deployment, the following requirements were met:

* Azure subscription with contributor permissions.
* Existing virtual network infrastructure.
* Dedicated DMZ subnet for internet-facing services.
* Ubuntu Linux virtual machine.
* Public IP address assigned to the VPN gateway.
* SSH administrative access to the VM.
* Azure Network Security Group permitting management access.
* WireGuard client software installed on administrator workstations.
* SSH key pair available for gateway authentication.
* PowerShell available on the administrator workstation for optional quick-connect configuration.

---

## Deployment Procedure

### 1. Deploy Gateway Virtual Machine

A dedicated Ubuntu Linux virtual machine was deployed within the DMZ subnet.

Configuration included:

* Ubuntu Server 24.04 LTS
* Standard B1s VM size
* Dedicated public IP address
* Static private IP address
* WireGuard-specific Network Security Group

Validation confirmed the VM was operational and assigned to the appropriate subnet.

*See Evidence:* `01-wireguard-vm-overview-top.png`

*See Evidence:* `02-wireguard-vm-overview-bottom.png`

---

### 2. Configure Network Interface

The gateway network interface was configured with:

* Public IP address for VPN connectivity.
* Static private IP address for internal communications.
* IP forwarding enabled.

IP forwarding allows the gateway to route traffic between VPN clients and Azure resources.

*See Evidence:* `03-wireguard-network-settings.png`

*See Evidence:* `04-wireguard-ip-forwarding.png`

---

### 3. Configure Network Security Rules

A dedicated Network Security Group was assigned to the gateway.

Inbound rules were configured to permit administrative access while maintaining a restricted attack surface.

The gateway required inbound access for WireGuard VPN traffic and administrative SSH access from approved administrator source IP addresses.

*See Evidence:* `05-wireguard-nsg-rules.png`

---

## Configuration Procedure

### 1. Install WireGuard

WireGuard packages were installed using the Ubuntu package repository.

Installation validation confirmed:

* WireGuard package installation.
* WireGuard tools installation.
* Service availability.

*See Evidence:* `06-wireguard-installation-validation.png`

---

### 2. Create WireGuard Configuration

A WireGuard configuration file was created containing:

* VPN interface address.
* Listening port.
* NAT and forwarding rules.
* Peer configuration entries.

The configuration established the foundation for encrypted VPN connectivity between administrators and Azure resources.

*See Evidence:* `10-wireguard-server-configuration.png`

---

### 3. Enable WireGuard Service

The WireGuard service was started and configured for automatic startup during system boot.

Verification confirmed:

* Service enabled.
* Service started successfully.
* Configuration applied without errors.

*See Evidence:* `07-wireguard-service-status.png`

---

### 4. Validate Interface Creation

After service startup, the VPN interface was created successfully.

Validation confirmed:

* WireGuard interface availability.
* Listening port assignment.
* Active tunnel configuration.

*See Evidence:* `08-wireguard-interface-status.png`

*See Evidence:* `09-wireguard-listening-port.png`

---

### 5. Configure PowerShell Quick-Connect Function

A PowerShell quick-connect function was configured on the administrator workstation to simplify recurring SSH access to the WireGuard gateway.

Instead of manually typing the full SSH command each time, the workstation profile was updated with a custom `wgssh` function.

Example function format:

```powershell
function wgssh {
    ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>
}
```

This function uses the SSH private key and gateway public IP address to open an administrative session to the WireGuard VM.

The PowerShell profile was checked and created if needed before making the function persistent:

```powershell
Test-Path $PROFILE
```

```powershell
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}
```

The profile was then opened for editing:

```powershell
notepad $PROFILE
```

After the function was saved to the profile, new PowerShell sessions could connect to the gateway by running:

```powershell
wgssh
```

This configuration was added after the original WireGuard deployment to reduce repetitive command entry during recurring lab administration.

*See Evidence:* `13-powershell-profile-quick-connect-function.png`

---

## Verification

Validation testing confirmed the gateway was functioning as intended.

### VPN Gateway Access

Administrative connectivity to the WireGuard gateway was verified using SSH over the internet-facing public IP address.

*See Evidence:* `11-vpn-gateway-login.png`

---

### Internal Resource Access

After connecting through the VPN gateway, administrative access to internal Azure resources was verified using private IP addressing.

Successful SSH connectivity confirmed that traffic was correctly routed through the WireGuard tunnel.

*See Evidence:* `12-private-ip-ssh-validation.png`

---

### PowerShell Quick-Connect Validation

The PowerShell quick-connect workflow was validated from the administrator workstation.

Validation confirmed:

* The `wgssh` function existed in the PowerShell session.
* The function pointed to the WireGuard gateway SSH command.
* The PowerShell profile file existed or was created successfully.
* Running `wgssh` initiated SSH access to the WireGuard gateway.
* Successful login reached the Ubuntu shell on `WireGuardVM1`.
* The gateway reported the expected private IP address on `eth0`.

During validation, an initial SSH attempt timed out while access conditions were not yet ready. After the gateway was available and access was permitted, the same quick-connect function successfully opened an SSH session.

*See Evidence:* `14-wireguard-quick-connect-login-validation.png`

---

## Common Issues

### WireGuard Service Fails to Start

Possible causes include:

* Configuration syntax errors.
* Invalid key pairs.
* Missing interface definitions.
* Incorrect file permissions.

Review service logs using:

```bash
sudo systemctl status wg-quick@wg0
```

---

### VPN Clients Cannot Reach Internal Resources

Possible causes include:

* IP forwarding disabled.
* Missing NAT rules.
* Network Security Group restrictions.
* Incorrect client routing configuration.

Verify:

* IP forwarding configuration.
* WireGuard tunnel status.
* NSG rules.
* Azure subnet routing.

---

### SSH Connectivity Fails

Possible causes include:

* VM powered off.
* Incorrect NSG rules.
* Incorrect private IP address.
* WireGuard tunnel disconnected.
* Current administrator public IP not permitted by the SSH rule.
* Incorrect SSH key path or username.

Confirm both VPN connectivity and VM availability before troubleshooting application-level access.

---

### PowerShell Quick-Connect Function Does Not Work

Possible causes include:

* The function was not saved to the PowerShell profile.
* PowerShell was not restarted after editing the profile.
* The SSH key path changed.
* The username or gateway IP address was entered incorrectly.
* The WireGuard gateway VM was stopped.
* SSH access was blocked by the Network Security Group.
* The administrator source IP changed and no longer matched the SSH rule.

Verify:

```powershell
Get-Command wgssh
```

```powershell
Test-Path $PROFILE
```

Also confirm:

* The profile contains the `wgssh` function.
* The gateway VM is running.
* The SSH NSG rule permits the current administrator source IP.
* The SSH private key still exists at the configured path.

---

## Lessons Learned

* WireGuard provides a cost-effective alternative to Azure Bastion for small environments.
* Enabling IP forwarding is required for successful VPN routing.
* Separating VPN infrastructure into a dedicated DMZ subnet simplifies network management.
* Validation testing should include both VPN connectivity and internal resource access.
* Private-only management significantly reduces the exposed attack surface of Azure virtual machines.
* A PowerShell profile function can simplify recurring gateway access by reducing a full SSH command to a short reusable command.
* Quick-connect functions are useful for lab administration, but published documentation should use placeholders for private key paths, usernames, and public IP addresses.
* SSH access still depends on the VM power state, NSG rules, and current administrator source IP.

---

## Related Documents

* [WireGuard Command Reference](../command-codex/system-specific/wireguard.md)
* [Bash/Linux Command Reference](../command-codex/bash-linux/bash-linux.md)
* [PowerShell Command Reference](../command-codex/powershell/powershell.md)
* [Bash Syntax Reference](../command-codex/syntax/bash-syntax.md)
* [PowerShell Syntax Reference](../command-codex/syntax/powershell-syntax.md)

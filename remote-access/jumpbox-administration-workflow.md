# Jumpbox Administration Workflow

## Overview

This document explains how `WireGuardVM1` is used as the administrative jumpbox for the Azure Network Infrastructure Lab.

`WireGuardVM1` provides a controlled remote access point into the private Azure lab network without relying on Azure Bastion. The administrator first connects to `WireGuardVM1`, then uses that VM as the access point for reaching internal lab systems by private IP address or private DNS name.

This document does not rebuild the WireGuard VPN gateway. The VPN gateway deployment, WireGuard service configuration, and tunnel setup are covered in the WireGuard VPN Gateway documentation. This document focuses on the administrative workflow after the gateway exists.

The validated access pattern for this document is:

```text
Admin workstation → SSH to WireGuardVM1 → SSH/ping internal Azure resources from WireGuardVM1
```

Internal pings and private DNS tests shown in this document are performed from `WireGuardVM1`. They prove jumpbox-to-internal-resource reachability, not direct laptop-to-VNet ping access.

## Purpose

The purpose of this workflow is to provide a repeatable method for remotely administering private Azure VMs while controlling cost and limiting public exposure.

The jumpbox workflow supports:

* Secure administrative entry into `TestVNet1`.
* Private IP access to internal Linux VMs.
* Private DNS access to internal Linux VMs.
* Reduced dependence on Azure Bastion.
* Cost control by starting `WireGuardVM1` only when needed.
* Dynamic SSH access updates when the local public IP changes.
* Centralized access path for validation, troubleshooting, and maintenance.

## Prerequisites

The following items must already exist before using this workflow:

* Resource group: `TestGroup1`
* VNet: `TestVNet1`
* WireGuard VM: `WireGuardVM1`
* WireGuard subnet: `DMZ-Subnet`
* WireGuard VM private IP: `10.0.0.36`
* WireGuard VM public IP or DNS name: `<WIREGUARD_PUBLIC_IP_OR_DNS>`
* NSG: `WireGuardNSG1`
* WireGuard UDP inbound rule: allow UDP `51820`
* SSH inbound rule: allow TCP `22` from the current admin public IP
* Azure CLI installed on the admin workstation
* Azure CLI authenticated with access to the lab subscription
* SSH client installed on the admin workstation
* Valid SSH key or credential for `WireGuardVM1`
* Internal VM NSG rules allowing management traffic from the VNet or jumpbox path

The WireGuard VM must also have:

* WireGuard installed and configured.
* `wg-quick@wg0` enabled or available to start.
* Linux IP forwarding enabled.
* Azure NIC IP forwarding enabled.
* Correct route table behavior for return traffic from internal subnets.
* Private DNS integration configured if hostname-based access is used.

Running `az login` authenticates the workstation to Azure Resource Manager. It does not place the workstation inside `TestVNet1` and does not create private network reachability by itself.

## Deployment Procedure

### 1. Confirm WireGuardVM1 Exists

Open the Azure portal and browse to:

```text
Azure Portal → Virtual machines → WireGuardVM1 → Overview
```

Confirm that `WireGuardVM1` exists in `TestGroup1`, is assigned to the expected region, and is associated with the expected network resources.

*See Evidence:* [WireGuard VM overview](../screenshots/remote-access/jumpbox-administration-workflow/01-wireguard-vm-overview.png)

The lower portion of the VM overview confirms the VM size, disk details, and auto-shutdown configuration used for cost control.

*See Evidence:* [WireGuard VM overview bottom properties](../screenshots/remote-access/jumpbox-administration-workflow/02-wireguard-vm-overview-bottom.png)

### 2. Confirm Network Placement

Open the network settings for `WireGuardVM1` and confirm the VM is attached to the expected subnet, private IP address, and network security group.

Confirmed network placement:

```text
Virtual network: TestVNet1
Subnet: DMZ-Subnet
Private IP address: 10.0.0.36
Network security group: WireGuardNSG1
```

This confirms that `WireGuardVM1` is placed in the dedicated remote-access subnet instead of the internal server or client subnets.

*See Evidence:* [WireGuard network settings](../screenshots/remote-access/jumpbox-administration-workflow/03-wireguard-network-settings.png)

### 3. Confirm Azure NIC IP Forwarding

Open the network interface attached to `WireGuardVM1` and confirm that IP forwarding is enabled.

Azure-side IP forwarding is required because the VM is being used as a routing point between WireGuard traffic and internal Azure private network paths.

*See Evidence:* [WireGuard IP forwarding enabled](../screenshots/remote-access/jumpbox-administration-workflow/04-wireguard-ip-forwarding.png)

### 4. Confirm NSG Administrative Access Rule

Open `WireGuardNSG1` and review the inbound security rules.

The SSH rule allows administrative access to `WireGuardVM1` through TCP port `22`. The rule should be restricted to the current trusted administrative source IP instead of being left open broadly.

*See Evidence:* [WireGuard NSG rules](../screenshots/remote-access/jumpbox-administration-workflow/05-wireguard-nsg-rules.png)

### 5. Authenticate to Azure CLI

From the admin workstation, authenticate to Azure CLI:

```powershell
az login
```

Confirm the correct subscription is selected before starting, stopping, or validating VM state.

### 6. Start WireGuardVM1 if Needed

If the jumpbox is stopped or deallocated, start it before connecting:

```powershell
az vm start --resource-group TestGroup1 --name WireGuardVM1
```

After the VM starts, verify the power state if needed:

```powershell
az vm show --resource-group TestGroup1 --name WireGuardVM1 --show-details --query powerState --output tsv
```

Expected result:

```text
VM running
```

### 7. Update SSH NSG Rule for Current Public IP

The admin workstation may receive a different public IP from the ISP over time. If the SSH NSG rule still points to an old public IP, direct SSH to `WireGuardVM1` can fail.

Update the SSH rule with the current public IP before connecting:

```bash
curl -s ifconfig.me | xargs -I {} az network nsg rule update \
  --resource-group TestGroup1 \
  --nsg-name WireGuardNSG1 \
  --name SSH \
  --source-address-prefixes {}
```

This command fetches the current public IP and updates the SSH inbound rule in `WireGuardNSG1`.

### 8. Connect to WireGuardVM1 by SSH

Connect to the jumpbox using SSH:

```powershell
ssh -i "<PATH_TO_PRIVATE_KEY>" <ADMIN_USER>@<WIREGUARD_PUBLIC_IP_OR_DNS>
```

Example placeholder:

```powershell
ssh -i "C:\Path\To\WireGuardVM1_key.pem" <ADMIN_USER>@<WIREGUARD_PUBLIC_IP_OR_DNS>
```

Do not store real key paths, usernames, public IP addresses, or private keys in published documentation.

*See Evidence:* [VPN gateway login](../screenshots/remote-access/jumpbox-administration-workflow/11-vpn-gateway-login.png)

## Configuration Procedure

### WireGuardVM1 Role

`WireGuardVM1` functions as the remote administration entry point for the lab.

It provides:

* Public-facing access point for controlled SSH access.
* WireGuard gateway functionality for VPN use cases.
* Private network path into `TestVNet1`.
* A controlled alternative to Azure Bastion.

### Network Placement

`WireGuardVM1` is placed in the DMZ subnet.

```text
VNet: TestVNet1
Subnet: DMZ-Subnet
Jumpbox private IP: 10.0.0.36
Tunnel network: 10.6.0.0/24
Internal VNet range: 10.0.0.0/24
```

*See Evidence:* [WireGuard network settings](../screenshots/remote-access/jumpbox-administration-workflow/03-wireguard-network-settings.png)

### Required Azure Settings

`WireGuardVM1` requires the following Azure-side settings:

```text
NIC IP forwarding: Enabled
NSG inbound UDP 51820: Allowed
NSG inbound TCP 22: Allowed from current admin public IP
Route table: Internal return traffic routes back through WireGuardVM1 where required
```

*See Evidence:* [WireGuard IP forwarding enabled](../screenshots/remote-access/jumpbox-administration-workflow/04-wireguard-ip-forwarding.png)

*See Evidence:* [WireGuard NSG rules](../screenshots/remote-access/jumpbox-administration-workflow/05-wireguard-nsg-rules.png)

### Required Linux Settings

`WireGuardVM1` requires Linux IP forwarding.

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wg.conf
sudo sysctl --system
```

The WireGuard service should be available through systemd:

```bash
sudo systemctl status wg-quick@wg0
```

### Validate WireGuard Installation

After logging into `WireGuardVM1`, confirm WireGuard and WireGuard tools are installed:

```bash
dpkg -l | grep wireguard
```

or:

```bash
apt list --installed | grep wireguard
```

*See Evidence:* [WireGuard installation validation](../screenshots/remote-access/jumpbox-administration-workflow/06-wireguard-installation-validation.png)

### Validate WireGuard Service State

Confirm the WireGuard service is enabled and active:

```bash
sudo systemctl status wg-quick@wg0
```

*See Evidence:* [WireGuard service status](../screenshots/remote-access/jumpbox-administration-workflow/07-wireguard-service-status.png)

### Validate WireGuard Interface

Confirm the WireGuard interface exists:

```bash
sudo wg
```

The output should show interface `wg0` and the configured listening port.

*See Evidence:* [WireGuard interface status](../screenshots/remote-access/jumpbox-administration-workflow/08-wireguard-interface-status.png)

### Validate WireGuard Listening Port

Confirm the VM is listening on WireGuard’s UDP port:

```bash
sudo ss -uulpn
```

The output should show WireGuard listening on port `51820`.

*See Evidence:* [WireGuard listening port](../screenshots/remote-access/jumpbox-administration-workflow/09-wireguard-listening-port.png)

### Validate WireGuard Server Configuration

Review the WireGuard server configuration:

```bash
sudo cat /etc/wireguard/wg0.conf
```

The configuration should show:

```text
Interface address: 10.6.0.1/24
Listen port: 51820
Peer AllowedIPs: 10.6.0.2/32
Forwarding/NAT rules
```

Sensitive key material must remain redacted in screenshots and documentation.

*See Evidence:* [WireGuard server configuration](../screenshots/remote-access/jumpbox-administration-workflow/10-wireguard-server-configuration.png)

### Client Split-Tunnel Configuration

The admin workstation can use split-tunnel routing for lab access when the WireGuard client is being used for direct VPN access.

Example split-tunnel peer configuration:

```ini
[Peer]
AllowedIPs = 10.0.0.0/24
```

This routes Azure lab traffic through the WireGuard tunnel while leaving normal internet traffic on the local network.

This document does not rely on laptop-originated ping evidence. The verified workflow for this article is jumpbox-based administration:

```text
Admin workstation → SSH to WireGuardVM1 → internal administration from WireGuardVM1
```

### Optional PowerShell Quick-Connect Function

A local PowerShell helper function can be used to reduce repetitive typing when connecting to `WireGuardVM1`.

Example function format:

```powershell
function wgssh {
    ssh -i "<PATH_TO_PRIVATE_KEY>" <ADMIN_USER>@<WIREGUARD_PUBLIC_IP_OR_DNS>
}
```

This function is an administrative convenience only. It does not replace the underlying SSH, NSG, or VM state requirements.

*See Evidence:* [PowerShell profile quick-connect function](../screenshots/remote-access/jumpbox-administration-workflow/13-powershell-profile-quick-connect-function.png)

The quick-connect function was validated by successfully opening an SSH session to `WireGuardVM1`.

*See Evidence:* [WireGuard quick-connect login validation](../screenshots/remote-access/jumpbox-administration-workflow/14-wireguard-quick-connect-login-validation.png)

### Optional Quick-Access Batch File

A Windows batch file was drafted to combine the start, NSG update, SSH connection, and shutdown sequence.

Because this workflow was not validated end-to-end, it should be documented as a future administrative convenience, not as the primary confirmed access method.

Example placeholder structure:

```bat
@echo off
az vm start --resource-group TestGroup1 --name WireGuardVM1
timeout /t 40
curl -s ifconfig.me | xargs -I {} az network nsg rule update --resource-group TestGroup1 --nsg-name WireGuardNSG1 --name SSH --source-address-prefixes {}
ssh <ADMIN_USER>@<WIREGUARD_PUBLIC_IP_OR_DNS>
az vm deallocate --resource-group TestGroup1 --name WireGuardVM1
```

This script should not be treated as production-ready until it has been tested and confirmed.

## Verification

### Verify WireGuardVM1 Power State

Verify the power state of `WireGuardVM1`:

```powershell
az vm show `
  --resource-group TestGroup1 `
  --name WireGuardVM1 `
  --show-details `
  --query powerState `
  --output tsv
```

Expected result while using the jumpbox:

```text
VM running
```

*See Evidence:* [WireGuard VM overview](../screenshots/remote-access/jumpbox-administration-workflow/01-wireguard-vm-overview.png)

### Verify Jumpbox SSH Access

The admin workstation successfully established an SSH session to `WireGuardVM1`.

This validates the first stage of the workflow:

```text
Admin workstation → WireGuardVM1
```

*See Evidence:* [VPN gateway login](../screenshots/remote-access/jumpbox-administration-workflow/11-vpn-gateway-login.png)

### Verify Private IP SSH from Jumpbox to Internal VM

From an active SSH session on `WireGuardVM1`, the administrator successfully opened an SSH session to `TestLinuxServer1`.

This validates the second stage of the workflow:

```text
WireGuardVM1 → internal Azure VM
```

The connection uses the internal private network path rather than public exposure of the internal server.

*See Evidence:* [Private IP SSH validation](../screenshots/remote-access/jumpbox-administration-workflow/12-private-ip-ssh-validation.png)

### Verify Internal Network Reachability from Jumpbox

Internal reachability was tested from `WireGuardVM1` using a Bash loop that pinged multiple private IP addresses in the lab.

Example command:

```bash
for i in 4 21 22 23 24 25 26 27; do
  ping -c 2 -W 2 "10.0.0.$i" >/dev/null && echo "10.0.0.$i reachable" || echo "10.0.0.$i unreachable"
done
```

A labeled version was also used for clearer evidence:

```bash
for host in \
"TestLinuxServer1 10.0.0.4" \
"TestClientVM1 10.0.0.21" \
"TestClientVM2 10.0.0.22" \
"TestClientVM3 10.0.0.23" \
"TestClientVM4 10.0.0.24" \
"TestClientVM5 10.0.0.25" \
"TestClientVM6 10.0.0.26" \
"NetMonVM1 10.0.0.27"; do
  name=$(echo "$host" | awk '{print $1}')
  ip=$(echo "$host" | awk '{print $2}')
  ping -c 2 -W 2 "$ip" >/dev/null && echo "$name ($ip): reachable" || echo "$name ($ip): unreachable"
done
```

This validation proves reachability from the jumpbox to internal lab systems. It does not prove direct laptop-to-VNet ping access.

The screenshot shows successful reachability to `TestLinuxServer1` and the active client VM private IP addresses. `NetMonVM1` was unreachable during this capture, so this screenshot is used as evidence of jumpbox-to-active-system reachability rather than full-network availability.

*See Evidence:* [Internal network reachability from jumpbox](../screenshots/remote-access/jumpbox-administration-workflow/15-internal-network-reachability-from-jumpbox.png)

### Verify Private DNS Access from Jumpbox

Private DNS was validated from `WireGuardVM1` by resolving `testlinuxserver1.vnet-dns.lab` to `10.0.0.4`.

The server was then accessed by hostname:

```bash
ssh <ADMIN_USER>@testlinuxserver1.vnet-dns.lab
```

The login banner confirmed that the connection originated from `10.0.0.36`, which is the private IP address of `WireGuardVM1`.

This proves that hostname-based internal administration works from the jumpbox.

*See Evidence:* [Private DNS validation from jumpbox](../screenshots/remote-access/jumpbox-administration-workflow/16-private-dns-validation-from-jumpbox.png)

### Verify Shutdown or Deallocation

After the administrative session was completed, `WireGuardVM1` was deallocated to stop compute charges.

Deallocate the VM:

```powershell
az vm deallocate --resource-group TestGroup1 --name WireGuardVM1
```

Verify the power state:

```powershell
az vm show --resource-group TestGroup1 --name WireGuardVM1 --show-details --query powerState --output tsv
```

Expected output:

```text
VM deallocated
```

*See Evidence:* [WireGuard VM deallocated verification](../screenshots/remote-access/jumpbox-administration-workflow/17-wireguard-vm-deallocated-verification.png)

## Common Issues

### SSH Fails After Working Previously

Cause:

The local ISP may assign a new public IP address. The NSG SSH rule may still allow the old public IP.

Fix:

Update the SSH NSG rule with the current public IP.

```bash
curl -s ifconfig.me | xargs -I {} az network nsg rule update \
  --resource-group TestGroup1 \
  --nsg-name WireGuardNSG1 \
  --name SSH \
  --source-address-prefixes {}
```

### Azure CLI Login Does Not Mean Private Network Access

Cause:

Azure CLI authentication only provides management-plane access to Azure Resource Manager. It does not place the local workstation inside the Azure VNet.

Fix:

Use SSH, WireGuard routing, or another valid network path for private network access. Do not treat `az login` as evidence of network-level connectivity.

### Ping Evidence Can Be Misread

Cause:

Pings issued after SSHing into `WireGuardVM1` originate from `WireGuardVM1`, not from the local laptop.

Fix:

Describe ping evidence accurately. In this document, internal ping validation proves:

```text
WireGuardVM1 → internal Azure systems
```

It does not prove:

```text
Laptop → internal Azure systems
```

### WireGuard Connects but Internal VMs Are Not Reachable

Possible causes:

* Azure NIC IP forwarding is disabled on `WireGuardVM1`.
* Linux IP forwarding is not enabled.
* Return route from internal subnets is missing.
* Client `AllowedIPs` does not include the internal VNet range.
* Internal NSG rules do not allow the traffic.
* Target VMs are stopped or deallocated.
* Target VMs block ICMP or SSH locally.

Fix:

Check IP forwarding, route table association, client `AllowedIPs`, NSG rules, VM power state, and target host firewall behavior.

### DNS Names Do Not Resolve

Possible causes:

* Private DNS zone is not linked to the VNet.
* Auto-registration did not populate the records.
* The VM was stopped when DNS auto-registration was expected.
* The client is not using the correct DNS path.
* The hostname being queried does not match the record.

Fix:

Validate the private DNS zone link, confirm records exist, and test private IP access directly before troubleshooting DNS.

### VM Was Stopped Instead of Deallocated

Stopping the VM from inside the OS may not fully release compute billing.

Fix:

Use Azure deallocation when the jumpbox is no longer needed.

```powershell
az vm deallocate --resource-group TestGroup1 --name WireGuardVM1
```

Confirm the final state:

```powershell
az vm show --resource-group TestGroup1 --name WireGuardVM1 --show-details --query powerState --output tsv
```

Expected output:

```text
VM deallocated
```

### Batch File Does Not Complete as Expected

The quick-access batch file was drafted as an administrative convenience but should not be treated as the confirmed workflow until tested.

Possible issues:

* Azure CLI is not authenticated.
* SSH session exits unexpectedly.
* Public IP fetch fails.
* NSG rule update fails.
* VM boot delay is longer than expected.
* Script stops the VM instead of deallocating it.

Fix:

Run each command manually first, then test the batch file only after the manual sequence is confirmed.

## Lessons Learned

`WireGuardVM1` provided a lower-cost alternative to Azure Bastion for this lab while still allowing private access to internal VMs.

Dynamic home IP assignment created recurring SSH access issues. Updating the NSG source address before connecting became a required administrative step.

WireGuard access depends on both Linux configuration and Azure networking configuration. Linux IP forwarding alone is not enough; Azure NIC IP forwarding and routing behavior must also be correct.

Private DNS improves usability after the private network path is working. Private IP connectivity should be validated first, then hostname-based access can be validated through the private DNS zone.

The evidence for this workflow must be described precisely. Pings and SSH commands issued from `WireGuardVM1` validate jumpbox-to-internal-resource access. They do not validate direct laptop-to-VNet ping access.

The jumpbox should be deallocated after use to support the lab’s cost-control model.

The PowerShell quick-connect function improves repeated access, but it is only a convenience wrapper around the validated SSH path.

## Related Documents

* [WireGuard VPN Gateway](./wireguard-vpn-gateway.md)
* [Command Codex - WireGuard](../command-codex/system-specific/wireguard.md)
* [Command Codex - Azure CLI](../command-codex/azure-cli/azure-cli.md)
* [Command Codex - Bash/Linux](../command-codex/bash-linux/bash-linux.md)
* [Cost Control Operations](../operations/cost-control-operations.md)
* [VM Lifecycle Management](../operations/vm-lifecycle-management.md)
* [Private DNS Implementation](../network/private-dns-implementation.md)
* [NSG/ASG Implementation](../network/nsg-asg-implementation.md)

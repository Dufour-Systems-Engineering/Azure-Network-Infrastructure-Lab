# Jumpbox Administration Workflow

## Overview

This document records the validated SSH jumpbox workflow used with `WireGuardVM1` before direct one-hop VPN administration was completed.

The validated path was:

```text
Local Windows workstation
    -> public SSH connection
    -> WireGuardVM1
    -> private SSH, ping, or DNS request
    -> internal Azure resource
```

This workflow did not require the local workstation to establish a functioning WireGuard tunnel. Internal tests performed after signing in to `WireGuardVM1` originated from the jumpbox and must not be presented as direct workstation-to-VNet evidence.

The workflow remains available as an alternate or fallback administrative path. The later primary one-hop VPN workflow is documented in [WireGuard VPN Server Completion and One-Hop Administration](wireguard-vpn-server-completion-and-one-hop-access.md).

## Purpose

The jumpbox workflow provided a repeatable method for administering private Azure resources while limiting public management exposure.

It supported:

- A single controlled public SSH entry point.
- Private IP administration of internal Linux VMs.
- Private DNS testing from inside `TestVNet1`.
- Reachability validation from the remote-access subnet.
- Reduced dependence on Azure Bastion.
- Cost control by starting the VM only when required and deallocating it afterward.

## Prerequisites

The workflow requires:

- Resource group: `TestGroup1`
- VNet: `TestVNet1`
- Jumpbox: `WireGuardVM1`
- Subnet: `DMZ-Subnet`
- Jumpbox private IP: `10.0.0.36`
- NSG: `WireGuardNSG1`
- A public IP address or DNS name for `WireGuardVM1`
- TCP `22` allowed from the administrator's current public IP
- Azure CLI authenticated to the correct subscription when CLI lifecycle commands are used
- An SSH client on the administrator workstation
- A valid SSH identity or credential for `WireGuardVM1`
- Internal NSG and host-firewall rules permitting the required traffic from the jumpbox path
- Private DNS integration when hostname-based access is required

This jumpbox workflow does not require:

- An inbound UDP `51820` rule.
- A WireGuard handshake.
- A Windows WireGuard peer configuration.
- WireGuard `AllowedIPs` routes on the workstation.
- A route from the workstation into the Azure VNet.

Running `az login` provides Azure management-plane authentication. It does not place the workstation inside `TestVNet1` or create private network reachability.

## Deployment Procedure

### 1. Confirm WireGuardVM1 Exists

Confirm that `WireGuardVM1` exists in `TestGroup1` and is associated with the intended network resources.

See Evidence: [WireGuard VM overview](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/01-wireguard-vm-overview.png)

### 2. Confirm Network Placement

Confirm the following placement:

```text
Virtual network: TestVNet1
Subnet: DMZ-Subnet
Private IP: 10.0.0.36
Network security group: WireGuardNSG1
```

See Evidence: [WireGuard network settings](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/03-wireguard-network-settings.png)

### 3. Confirm the SSH NSG Rule

Confirm that `WireGuardNSG1` allows inbound TCP `22` from the current trusted administrator address. The internal VMs do not require their own public SSH endpoints for this workflow.

See Evidence: [WireGuard NSG rules](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/05-wireguard-nsg-rules.png)

### 4. Authenticate to Azure CLI

When Azure CLI is used to manage the VM lifecycle, authenticate and confirm the correct subscription:

```powershell
az login
```

### 5. Start WireGuardVM1

Start the VM if it is stopped or deallocated:

```powershell
az vm start --resource-group TestGroup1 --name WireGuardVM1
```

Verify its power state:

```powershell
az vm show --resource-group TestGroup1 --name WireGuardVM1 --show-details --query powerState --output tsv
```

Expected result:

```text
VM running
```

### 6. Update the SSH Source Address if Necessary

If the administrator's public address has changed, update the existing SSH rule before connecting. The retained workflow used:

```bash
curl -s ifconfig.me | xargs -I {} az network nsg rule update \
  --resource-group TestGroup1 \
  --nsg-name WireGuardNSG1 \
  --name SSH \
  --source-address-prefixes {}
```

### 7. Connect to the Jumpbox

Open an SSH session to the public endpoint:

```powershell
ssh -i "<PATH_TO_PRIVATE_KEY>" <ADMIN_USER>@<WIREGUARD_PUBLIC_IP_OR_DNS>
```

See Evidence: [Jumpbox SSH login](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/11-vpn-gateway-login.png)

## Configuration Procedure

### Administer an Internal VM by Private IP

From the active shell on `WireGuardVM1`, connect to an internal VM:

```bash
ssh <INTERNAL_ADMIN_USER>@<INTERNAL_PRIVATE_IP>
```

The internal connection traverses the Azure VNet and does not require a public IP on the target VM.

### Validate Internal Reachability

The retained workflow used a labeled loop from `WireGuardVM1` to test multiple private addresses:

```bash
for host in \
"TestLinuxServer1 10.0.0.4" \
"TestClientVM1 10.0.0.21" \
"TestClientVM2 10.0.0.22" \
"TestClientVM3 10.0.0.23" \
"TestClientVM4 10.0.0.24" \
"TestClientVM5 10.0.0.25" \
"TestClientVM6 10.0.0.26"; do
  name=$(echo "$host" | awk '{print $1}')
  ip=$(echo "$host" | awk '{print $2}')
  ping -c 2 -W 2 "$ip" >/dev/null && echo "$name ($ip): reachable" || echo "$name ($ip): unreachable"
done
```

The earlier document listed `NetMonVM1` at `10.0.0.27`. The later confirmed environment records `NetMonVM1` at `10.0.0.132`, so the obsolete address is not retained in the current command example.

### Validate Private DNS

The private DNS zone `vnet-dns.lab` contained forward A records for the six client VMs, `TestLinuxServer1`, `NetMonVM1`, and `WireGuardVM1`. The record inventory was reviewed in the Azure portal before testing.

The complete forward-resolution and reachability test was run from `WireGuardVM1` using each system's fully qualified private DNS name:

```bash
for host in \
testclientvm1.vnet-dns.lab \
testclientvm2.vnet-dns.lab \
testclientvm3.vnet-dns.lab \
testclientvm4.vnet-dns.lab \
testclientvm5.vnet-dns.lab \
testclientvm6.vnet-dns.lab \
testlinuxserver1.vnet-dns.lab \
netmonvm1.vnet-dns.lab \
wireguardvm1.vnet-dns.lab; do
  getent hosts "$host"
  ping -c 2 "$host"
done
```

`getent hosts` returned the expected private IP for every FQDN, and each corresponding ping completed with zero packet loss. This validates forward private-DNS resolution and IP reachability from `WireGuardVM1` for all nine systems.

See Evidence:

- [Private DNS A records verified in Azure portal](../screenshots/remote-access/jumpbox-administration-workflow/18-private-dns-a-records-verified-in-portal.png)
- [Private DNS FQDN validation for client VMs 1 through 4](../screenshots/remote-access/jumpbox-administration-workflow/19-private-dns-fqdn-validation-clients-1-through-4.png)
- [Private DNS FQDN validation for client VMs 5 through 6 and infrastructure VMs](../screenshots/remote-access/jumpbox-administration-workflow/20-private-dns-fqdn-validation-clients-5-through-6-and-infrastructure-vms.png)

These tests originated from `WireGuardVM1`. They do not establish private-DNS resolution from the local workstation. The test also validates forward A-record resolution only; reverse PTR lookup validation remains outside this workflow.

### Optional PowerShell Quick-Connect Function

The following convenience function shortens the public SSH command:

```powershell
function wgssh {
    ssh -i "<PATH_TO_PRIVATE_KEY>" <ADMIN_USER>@<WIREGUARD_PUBLIC_IP_OR_DNS>
}
```

This helper opens the jumpbox session only. It does not activate WireGuard or establish private workstation routing.

See Evidence: [PowerShell quick-connect function](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/13-powershell-profile-quick-connect-function.png)

### End the Workflow and Deallocate the VM

After exiting all SSH sessions, deallocate the VM:

```powershell
az vm deallocate --resource-group TestGroup1 --name WireGuardVM1
```

Verify the final state:

```powershell
az vm show --resource-group TestGroup1 --name WireGuardVM1 --show-details --query powerState --output tsv
```

Expected result:

```text
VM deallocated
```

## Verification

### Verify Public SSH to WireGuardVM1

The local workstation successfully opened an SSH session to the public endpoint on `WireGuardVM1`.

See Evidence: [Jumpbox SSH login](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/11-vpn-gateway-login.png)

### Verify Private SSH from the Jumpbox

From `WireGuardVM1`, the administrator successfully opened an SSH session to `TestLinuxServer1` through its private address.

See Evidence: [Private IP SSH from jumpbox](../screenshots/remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration/12-private-ip-ssh-validation.png)

### Verify Reachability from the Jumpbox

The retained reachability evidence shows successful tests from `WireGuardVM1` to `TestLinuxServer1` and all six client VMs. The historical `NetMonVM1` address `10.0.0.27` was unreachable during that capture. This evidence does not prove direct laptop-to-VNet access.

See Evidence: [Internal reachability from jumpbox](../screenshots/remote-access/jumpbox-administration-workflow/15-internal-network-reachability-from-jumpbox.png)

### Verify Private DNS from the Jumpbox

Forward private-DNS resolution was validated from `WireGuardVM1` for the complete documented inventory:

| FQDN | Expected private IP | Result |
| --- | --- | --- |
| `testclientvm1.vnet-dns.lab` | `10.0.0.21` | Resolved and reachable |
| `testclientvm2.vnet-dns.lab` | `10.0.0.22` | Resolved and reachable |
| `testclientvm3.vnet-dns.lab` | `10.0.0.23` | Resolved and reachable |
| `testclientvm4.vnet-dns.lab` | `10.0.0.24` | Resolved and reachable |
| `testclientvm5.vnet-dns.lab` | `10.0.0.25` | Resolved and reachable |
| `testclientvm6.vnet-dns.lab` | `10.0.0.26` | Resolved and reachable |
| `testlinuxserver1.vnet-dns.lab` | `10.0.0.4` | Resolved and reachable |
| `netmonvm1.vnet-dns.lab` | `10.0.0.132` | Resolved and reachable |
| `wireguardvm1.vnet-dns.lab` | `10.0.0.36` | Resolved and reachable |

The earlier evidence also shows hostname-based SSH from `WireGuardVM1` to `testlinuxserver1.vnet-dns.lab`.

See Evidence:

- [Earlier private DNS SSH validation from jumpbox](../screenshots/remote-access/jumpbox-administration-workflow/16-private-dns-validation-from-jumpbox.png)
- [Private DNS A records verified in Azure portal](../screenshots/remote-access/jumpbox-administration-workflow/18-private-dns-a-records-verified-in-portal.png)
- [Private DNS FQDN validation for client VMs 1 through 4](../screenshots/remote-access/jumpbox-administration-workflow/19-private-dns-fqdn-validation-clients-1-through-4.png)
- [Private DNS FQDN validation for client VMs 5 through 6 and infrastructure VMs](../screenshots/remote-access/jumpbox-administration-workflow/20-private-dns-fqdn-validation-clients-5-through-6-and-infrastructure-vms.png)

### Verify Deallocation

The VM was deallocated after the administrative session to support the lab's cost-control model.

See Evidence: [WireGuard VM deallocated](../screenshots/remote-access/jumpbox-administration-workflow/17-wireguard-vm-deallocated-verification.png)

## Common Issues

### SSH Stops Working After the Administrator Address Changes

The SSH rule may still permit an older ISP-assigned address. Update the rule with the current address and retry the public SSH connection.

### Azure CLI Login Is Mistaken for Network Access

Azure CLI authentication permits management-plane operations. It does not create a data-plane route into the VNet.

### Jumpbox Ping Evidence Is Misread

Pings issued after signing in to `WireGuardVM1` originate from `10.0.0.36`. They prove jumpbox-to-resource reachability, not workstation-to-resource reachability.

### VPN Requirements Are Applied to the Jumpbox Workflow

The SSH jumpbox method works independently of WireGuard peer authentication. Troubleshoot TCP `22`, the SSH credential, VM power state, and private Azure reachability before investigating VPN-specific settings.

### Private DNS Does Not Resolve

Confirm the private DNS zone link and A record, then test the target by private IP to separate a DNS problem from a general network problem. Use the full `vnet-dns.lab` name when validating this private zone; an unqualified hostname may resolve through Azure's platform-provided internal DNS suffix instead.

### The VM Is Stopped but Still Allocated

Stopping the operating system may not release Azure compute allocation. Use `az vm deallocate` and confirm `VM deallocated` when the workflow is complete.

## Lessons Learned

- The jumpbox path was a valid administrative workflow even though the intended VPN path remained incomplete.
- Public SSH, WireGuard transport, and internal private access are separate stages that require separate validation.
- Test origin must be recorded so jumpbox evidence is not misrepresented as workstation VPN evidence.
- A dynamic administrator address requires maintenance of the restricted SSH rule.
- Private DNS improves usability only after the underlying private network path works.
- Private-zone validation should use the complete `vnet-dns.lab` FQDN so Azure platform DNS is not mistaken for the custom private zone.
- Deallocation is required to support the intended cost-control workflow.

## Related Documents

- [WireGuard VM Initial Deployment and Jumpbox Configuration](wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
- [WireGuard VPN Server Linux Setup and Configuration](wireguard-vpn-server-linux-setup-and-configuration.md)
- [WireGuard VPN Server Completion and One-Hop Administration](wireguard-vpn-server-completion-and-one-hop-access.md)
- [Cost Control Operations](../operations/cost-control-operations.md)

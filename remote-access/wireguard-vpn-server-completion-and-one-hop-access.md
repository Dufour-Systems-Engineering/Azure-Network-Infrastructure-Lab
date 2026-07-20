# WireGuard VPN Server Completion and One-Hop Administration

## Overview

This document records the completion and validation of `WireGuardVM1` as the remote-access VPN gateway for the original Azure lab environment. The completed design allows the local Windows workstation to establish a WireGuard tunnel and then connect directly to Azure virtual machines by private IP address.

The validated administration path is:

```text
Local Windows workstation
    -> WireGuard tunnel
    -> WireGuardVM1 VPN gateway/router
    -> Azure VM private IP
```

This replaces the earlier operational dependence on an interactive jumpbox workflow. `WireGuardVM1` remains available for direct SSH administration, but an administrator no longer needs to sign in to it before reaching another private VM.

## Purpose

The purpose of this work was to finish the existing WireGuard deployment as it was intended to operate and prove one-hop administration across the lab environment.

The completion work addressed three gaps in the previous configuration:

- The WireGuard UDP `51820` rule had been documented but was not present on `WireGuardNSG1`.
- The Windows WireGuard peer configuration did not contain the correct peer-key relationship or split-tunnel routes.
- Direct workstation-to-private-VM administration through the VPN had not been conclusively validated.

The original WireGuard package installation, server key generation, Linux forwarding configuration, NAT configuration, and Azure NIC IP-forwarding setting were already present. They were inspected and validated as prerequisites rather than recreated.

## Completed Design

### Azure network

- VNet: `TestVNet1`
- VNet address space routed through the tunnel: `10.0.0.0/24`
- WireGuard subnet: `DMZ-Subnet`
- WireGuard subnet prefix: `10.0.0.32/29`
- WireGuard VM: `WireGuardVM1`
- WireGuard VM private IP: `10.0.0.36`
- WireGuard NIC: `wireguardvm1997`
- WireGuard NSG: `WireGuardNSG1`

### WireGuard tunnel

- Server tunnel address: `10.6.0.1/24`
- Windows peer address: `10.6.0.2/32`
- Transport: UDP `51820`
- Server peer route: `10.6.0.2/32`
- Windows peer routes: `10.6.0.0/24, 10.0.0.0/24`
- Persistent keepalive: `25` seconds

The Windows peer uses split tunneling. Only the WireGuard tunnel subnet and Azure VNet address space are routed through the VPN. Unrelated workstation traffic continues to use the workstation's normal network path.

## Previously Implemented Server State

`WireGuardVM1` already had the following components before the completion session:

- WireGuard and `iptables-persistent` installed.
- Server keys generated under `/etc/wireguard`.
- The `wg0` interface assigned `10.6.0.1/24`.
- Linux IPv4 forwarding enabled.
- Forwarding and NAT masquerade commands defined in `/etc/wireguard/wg0.conf`.
- The `wg-quick@wg0` service configured for system startup.
- Azure NIC IP forwarding enabled on `wireguardvm1997`.

The final inspected server configuration was represented by the following sanitized structure:

```ini
[Interface]
Address = 10.6.0.1/24
PrivateKey = <SERVER-WIREGUARD-PRIVATE-KEY>
ListenPort = 51820

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <WINDOWS-WIREGUARD-PUBLIC-KEY>
AllowedIPs = 10.6.0.2/32
```

The configuration performs two related functions:

- The `FORWARD` rule permits traffic arriving through `wg0` to be forwarded by the Linux host.
- The `MASQUERADE` rule translates tunnel-client traffic as it exits through `eth0`, allowing internal Azure VMs to return traffic through `WireGuardVM1` without a separate Azure route table for the WireGuard client subnet.

The existing NAT rule is functional but broad because it does not limit the source with `-s 10.6.0.0/24`. Source scoping is a possible hardening improvement and was not required for the validated result.

## Complete the Azure Network Path

### Confirm Azure NIC IP forwarding

Azure IP forwarding was confirmed as enabled on `wireguardvm1997`. This setting permits the NIC to process forwarded traffic whose source or destination is not the NIC's own assigned address.

The Azure setting complements Linux IPv4 forwarding. Both layers must permit forwarding for `WireGuardVM1` to operate as a router.

See Evidence: [Azure WireGuard NIC IP forwarding enabled](../screenshots/remote-access/vpn-one-hop-administration-workflow/01-azure-wireguard-nic-ip-forwarding-enabled.png)

### Add the missing WireGuard NSG rule

The previous documentation described UDP `51820` as allowed, but inspection showed that the required custom inbound rule had not been implemented. An inbound rule was added to `WireGuardNSG1` with the following confirmed state:

- Priority: `110`
- Destination port: `51820`
- Protocol: `UDP`
- Source: `Any`
- Destination: `Any`
- Action: `Allow`

The source remains `Any` so the workstation can establish the VPN from changing external networks. This is the implemented state and represents a deliberate availability tradeoff. WireGuard peer authentication still requires the correct cryptographic keys, but the exposed UDP service should be reviewed during future hardening.

The existing TCP `22` administration rule remained restricted to the recorded administrator address.

See Evidence: [WireGuard NSG UDP 51820 rule](../screenshots/remote-access/vpn-one-hop-administration-workflow/02-azure-wireguard-nsg-udp-51820-rule.png)

## Correct the WireGuard Peer Configuration

### Peer-key relationship

The server and Windows peer initially used the wrong public-key relationship. WireGuard requires each system's interface to retain its own private key while its peer block identifies the other system by public key.

The corrected relationship is:

```text
WireGuardVM1 [Interface] -> WireGuardVM1 private key
WireGuardVM1 [Peer]      -> Windows workstation public key

Windows [Interface]      -> Windows workstation private key
Windows [Peer]           -> WireGuardVM1 public key
```

WireGuard keys authenticate the VPN peers. They are separate from the SSH key used later to authenticate Linux administrative sessions.

### Server peer

The Windows workstation was defined on `WireGuardVM1` as a single tunnel peer:

```ini
[Peer]
PublicKey = <WINDOWS-WIREGUARD-PUBLIC-KEY>
AllowedIPs = 10.6.0.2/32
```

On the server, `AllowedIPs = 10.6.0.2/32` associates the Windows peer with its single WireGuard tunnel address.

### Windows peer

The final Windows tunnel configuration was represented by the following sanitized structure:

```ini
[Interface]
PrivateKey = <WINDOWS-WIREGUARD-PRIVATE-KEY>
Address = 10.6.0.2/32

[Peer]
PublicKey = <SERVER-WIREGUARD-PUBLIC-KEY>
AllowedIPs = 10.6.0.0/24, 10.0.0.0/24
Endpoint = <WIREGUARD-VM-PUBLIC-IP>:51820
PersistentKeepalive = 25
```

The two `AllowedIPs` values have distinct purposes:

- `10.6.0.0/24` routes the WireGuard tunnel network through the VPN.
- `10.0.0.0/24` routes the Azure VNet through the VPN.

The earlier Windows value, `0.0.0.0/32`, did not route either required network through the tunnel. The corrected split-tunnel routes enabled access to both the server tunnel address and the private Azure VM addresses.

### Reload the active interface

Saving `/etc/wireguard/wg0.conf` did not automatically update the running `wg0` interface. The service was restarted after correcting the peer configuration:

```bash
sudo systemctl restart wg-quick@wg0
```

The Windows tunnel was then deactivated and reactivated. This loaded the corrected server peer state and produced a current handshake with bidirectional transfer.

See Evidence: [WireGuard tunnel active with recent handshake](../screenshots/remote-access/vpn-one-hop-administration-workflow/03-wireguard-tunnel-active-handshake.png)

## Validate the VPN and Private Network Path

### Validate the tunnel interface

The workstation successfully reached the WireGuard server address at `10.6.0.1`:

```powershell
ping 10.6.0.1
```

The result returned four replies with zero packet loss. This confirmed that the workstation could traverse the authenticated tunnel and reach the server-side `wg0` interface.

See Evidence: [WireGuard server tunnel ping success](../screenshots/remote-access/vpn-one-hop-administration-workflow/04-wireguard-server-tunnel-ping-success.png)

### Validate private-network reachability

PowerShell `Test-Connection` was used to validate the full target inventory through the active tunnel:

```powershell
$reachable = Test-Connection -ComputerName $_.Value -Count 2 -Quiet
```

The validation returned `True` for the tunnel interface, `WireGuardVM1`, all six client VMs, `NetMonVM1`, and `TestLinuxServer1`.

This test establishes IP reachability. SSH authentication was validated separately.

See Evidence: [VPN private-network reachability test](../screenshots/remote-access/vpn-one-hop-administration-workflow/05-vpn-private-network-reachability-test.png)

## Configure One-Hop SSH Authentication

### Reuse the existing administrative identity

The Azure portal-downloaded PEM identity already authenticated access to `WireGuardVM1`. Its public half was derived locally without exposing or copying the private key:

```powershell
ssh-keygen -y -f "<path-to-WireGuardVM1_key.pem>"
```

- `-y` reads the private OpenSSH key and prints its matching public key.
- `-f` identifies the private-key file to read.

Only the resulting public key was installed on additional Azure VMs. The PEM private key remained on the Windows workstation.

### Inspect and update the client systems

The `.ssh` directory and `authorized_keys` file were inspected before modification. On the inspected client, the directory used mode `700`, `authorized_keys` used mode `600`, and the file was empty.

See Evidence: [Client VM authorized_keys before configuration](../screenshots/remote-access/vpn-one-hop-administration-workflow/06-client-vm-ssh-authorized-keys-before-configuration.png)

The derived public key was added to `/home/david/.ssh/authorized_keys` on:

- `TestClientVM1`
- `TestClientVM2`
- `TestClientVM3`
- `TestClientVM4`
- `TestClientVM5`
- `TestClientVM6`
- `NetMonVM1`

The existing administrative session was kept open until a separate local PowerShell session successfully authenticated with the PEM identity. This avoided terminating the only working access path before the replacement authentication method was tested.

### Preserve separate server authentication

`TestLinuxServer1` was intentionally left as an authentication exception. It uses the case-sensitive account name `David`, and its existing `/home/David/.ssh/authorized_keys` content was preserved.

The shared PEM identity did not authenticate the server during this session. Direct one-hop access still succeeded through password fallback. Retaining the existing server identity avoids casually extending the shared client key to the lab's more sensitive server system and preserves some administrative separation between general-purpose clients and the server.

This exception affects SSH authentication only. Network reachability to `TestLinuxServer1` through the WireGuard tunnel was successfully established.

## One-Hop SSH Validation

The completed design was validated from local Windows PowerShell with the VPN active. Each SSH command targeted the VM's Azure private IP directly:

```powershell
ssh -i "<path-to-WireGuardVM1_key.pem>" david@<private-ip>
```

No interactive SSH session on `WireGuardVM1` was used as an intermediate hop.

| Target | Private IP | SSH account | Result |
| --- | --- | --- | --- |
| `TestClientVM1` | `10.0.0.21` | `david` | Direct PEM authentication succeeded |
| `TestClientVM2` | `10.0.0.22` | `david` | Direct PEM authentication succeeded |
| `TestClientVM3` | `10.0.0.23` | `david` | Direct PEM authentication succeeded |
| `TestClientVM4` | `10.0.0.24` | `david` | Direct PEM authentication succeeded |
| `TestClientVM5` | `10.0.0.25` | `david` | Direct PEM authentication succeeded |
| `TestClientVM6` | `10.0.0.26` | `david` | Direct PEM authentication succeeded |
| `NetMonVM1` | `10.0.0.132` | `david` | Direct PEM authentication succeeded |
| `TestLinuxServer1` | `10.0.0.4` | `David` | Direct connection succeeded with password fallback |

See Evidence:

- [Direct SSH to TestClientVM1](../screenshots/remote-access/vpn-one-hop-administration-workflow/07-direct-ssh-testclientvm1-success.png)
- [Direct SSH to TestClientVM2](../screenshots/remote-access/vpn-one-hop-administration-workflow/08-direct-ssh-testclientvm2-success.png)
- [Direct SSH to TestClientVM3](../screenshots/remote-access/vpn-one-hop-administration-workflow/09-direct-ssh-testclientvm3-success.png)
- [Direct SSH to TestClientVM4](../screenshots/remote-access/vpn-one-hop-administration-workflow/10-direct-ssh-testclientvm4-success.png)
- [Direct SSH to TestClientVM5](../screenshots/remote-access/vpn-one-hop-administration-workflow/11-direct-ssh-testclientvm5-success.png)
- [Direct SSH to TestClientVM6](../screenshots/remote-access/vpn-one-hop-administration-workflow/12-direct-ssh-testclientvm6-success.png)
- [Direct SSH to NetMonVM1](../screenshots/remote-access/vpn-one-hop-administration-workflow/13-direct-ssh-netmonvm1-success.png)
- [Direct SSH to TestLinuxServer1 with password fallback](../screenshots/remote-access/vpn-one-hop-administration-workflow/14-direct-ssh-testlinuxserver1-password-fallback.png)

## Troubleshooting and Corrections

### Tunnel transmitted traffic without a handshake

The Windows application initially displayed transmitted traffic but no latest handshake. The server peer contained the wrong public key, and the saved configuration had not been loaded into the live interface.

The Windows public key was placed in the server's `[Peer]` block, the server public key was placed in the Windows `[Peer]` block, `wg-quick@wg0` was restarted, and the Windows tunnel was reactivated. A current handshake and bidirectional transfer then appeared.

### Tunnel interface ping timed out

The initial ping to `10.6.0.1` timed out while the incorrect peer and routing state remained active. After correcting `AllowedIPs` and reloading both sides of the tunnel, the same test returned four replies with zero packet loss.

### WireGuard and SSH keys were confused

The server's `server.pub` file contains the WireGuard public key used for VPN peer authentication. It is not an SSH public key and cannot authorize Linux SSH sessions.

The correct SSH public key was derived from the existing PEM identity with `ssh-keygen -y` and installed only in the applicable Linux users' `authorized_keys` files.

### TestLinuxServer1 used different credentials

The lowercase `david` account did not authenticate on `TestLinuxServer1`. The correct account was the case-sensitive `David` user. The shared PEM identity was not installed, and the successful one-hop session used the server's existing password authentication.

## Final Validation

| Validation | Confirmed result |
| --- | --- |
| Azure NIC IP forwarding | Enabled on `wireguardvm1997` |
| Ubuntu IPv4 forwarding | `/proc/sys/net/ipv4/ip_forward` returned `1` |
| WireGuard service startup | `wg-quick@wg0` returned `enabled` |
| WireGuard service state | `wg-quick@wg0` returned `active` |
| UDP `51820` exposure | Allow rule present on `WireGuardNSG1` at priority `110` |
| WireGuard peer authentication | Recent handshake and bidirectional transfer displayed |
| Tunnel reachability | `10.6.0.1` returned four replies with zero packet loss |
| Private-network reachability | Every listed target returned `True` |
| Client VM administration | Six direct PEM-authenticated SSH sessions succeeded |
| Network monitoring VM administration | Direct PEM-authenticated SSH session succeeded |
| Server administration path | Direct one-hop connection succeeded with retained password authentication |

## Final Result

`WireGuardVM1` now operates as the functional VPN gateway for the original Azure lab environment. The Windows workstation establishes an authenticated split tunnel, routes the WireGuard and Azure private address spaces through `WireGuardVM1`, and reaches the tested Azure VMs directly by private IP.

The completed workflow proves that Azure private VMs can be administered in one hop without exposing each VM through a public IP and without first opening an interactive shell on the WireGuard VM. Shared key-based SSH was validated for the six client VMs and `NetMonVM1`, while `TestLinuxServer1` retained a separate authentication boundary.

## Security and Maintenance Notes

- WireGuard and SSH use independent key pairs for different authentication purposes.
- Private WireGuard and SSH keys must remain outside repository documentation and evidence intended for publication.
- The UDP `51820` NSG rule currently accepts traffic from `Any` source to support changing workstation networks.
- The NAT masquerade rule may later be restricted to source `10.6.0.0/24` as a hardening improvement.
- `TestLinuxServer1` remains intentionally excluded from the shared SSH public-key deployment.
- Changes to `/etc/wireguard/wg0.conf` require the live interface to be reloaded, such as by restarting `wg-quick@wg0`.
- The current WireGuard configuration should be backed up securely outside the repository with private-key material protected appropriately.

## Related Documents

- [WireGuard VM Initial Deployment and Jumpbox Configuration](wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
- [WireGuard VPN Server Linux Setup and Configuration](wireguard-vpn-server-linux-setup-and-configuration.md)
- [Jumpbox Administration Workflow](jumpbox-administration-workflow.md)

These documents record the initial Linux preparation and the earlier SSH jumpbox workflow. This completion document remains the authoritative record for the corrected peer configuration, implemented UDP `51820` rule, active handshake, and successful one-hop administration.
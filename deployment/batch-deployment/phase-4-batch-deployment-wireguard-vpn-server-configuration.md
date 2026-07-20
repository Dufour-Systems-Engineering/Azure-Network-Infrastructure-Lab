# Batch Deployment Phase 4 — WireGuard VPN Server Configuration

## Overview

Phase 4 converted the Central US `BatchWireGuardVM1` resource deployed in Phase 3 into a functioning WireGuard VPN gateway and administrative jumpbox. The work was performed inside the Ubuntu guest and on the local Windows administrator workstation. It included installing WireGuard and firewall-persistence packages, creating the server key pair, enabling Linux IPv4 forwarding, defining the `wg0` interface, configuring source NAT, registering the Windows client as a peer, and validating the resulting tunnel.

The configured gateway used Azure private address `10.10.0.40`, WireGuard tunnel address `10.66.0.1/24`, UDP port `51820`, and Linux outbound interface `eth0`. The Windows client used tunnel address `10.66.0.2/32`. Split-tunnel routes allowed the workstation to reach both the WireGuard network `10.66.0.0/24` and the Azure client subnet `10.10.0.0/24` without directing unrelated workstation traffic through the VPN.

The completed configuration produced an active WireGuard service, a listening UDP socket, a successful peer handshake, bidirectional tunnel traffic, reachability to the WireGuard server address, and direct one-hop access from the local workstation to all six private client virtual machines at `10.10.0.5` through `10.10.0.10`.

This phase covers WireGuard server and workstation-client configuration plus functional access validation. It does not cover redeploying or deleting the Azure client virtual machines, targeted teardown, or post-test resource cleanup. Those activities belong to Phase 5.

The evidence set was reconstructed into implementation order because screenshots were added to the original guide after the work was performed. Sensitive values—including private keys, public endpoints, source addresses, subscription identifiers, and account information—must remain redacted in published evidence. Any private key exposed during the original troubleshooting process must be treated as compromised and rotated before reuse.

## Purpose

The purpose of Phase 4 was to establish secure remote administrative access to the private batch client subnet through the dedicated WireGuard gateway.

The implementation was designed to:

- Install and configure WireGuard on the Phase 3 Ubuntu gateway VM.
- Protect server key material through restrictive directory and file permissions.
- Use the dedicated `10.66.0.0/24` tunnel address space rather than reusing the earlier West US lab range.
- Enable Linux kernel IPv4 forwarding so traffic could pass between `wg0` and `eth0`.
- Apply source NAT for traffic leaving the WireGuard network through the Azure-facing interface.
- Start the `wg-quick@wg0` service immediately and enable it at system startup.
- Restrict the server peer route to the Windows client tunnel address `10.66.0.2/32`.
- Limit the Windows client tunnel routes to the VPN and Azure private subnets.
- Confirm a WireGuard handshake and packet transfer from the Windows application.
- Validate ICMP reachability to the tunnel endpoint and all six private client addresses.
- Validate SSH access to all six client VMs without assigning them public IP addresses.
- Preserve configuration errors, corrections, and final verification as engineering evidence.

## Prerequisites

The following resources and tools were required before Phase 4 configuration began:

- The completed Phase 3 deployment in `BatchTestResGroup2` in Central US.
- Ubuntu 22.04.5 LTS running on `BatchWireGuardVM1`.
- The WireGuard VM private IP address `10.10.0.40` in `BatchWireGuardSN1`.
- A Standard public IP address associated with the WireGuard VM NIC.
- Azure NIC IP forwarding enabled on `BatchWireGuardVM1-nic`.
- An NSG rule allowing inbound UDP `51820` to the WireGuard subnet.
- An NSG rule restricting inbound TCP `22` to the administrator source address.
- SSH access from the administrator workstation to the WireGuard VM.
- Windows PowerShell, OpenSSH, and the official WireGuard for Windows application.
- The private SSH key corresponding to the public key deployed to the batch VMs.
- The six Phase 2 client VMs running on the private client subnet.
- A screenshot set with sensitive values redacted before publication.

The inherited Azure configuration was:

| Resource | Configuration |
| --- | --- |
| Resource group | `BatchTestResGroup2` |
| Deployment region | `centralus` |
| Virtual network | `BatchTestVNet1` — `10.10.0.0/24` |
| Client subnet | `BatchClientSN1` — `10.10.0.0/28` |
| WireGuard subnet | `BatchWireGuardSN1` — `10.10.0.32/28` |
| WireGuard VM | `BatchWireGuardVM1` |
| WireGuard VM private IP | `10.10.0.40` |
| WireGuard NIC | `BatchWireGuardVM1-nic` |
| WireGuard NSG | `BatchWireGuardNSG1` |
| Tunnel ingress | UDP `51820` |
| Administrative ingress | TCP `22`, restricted to the administrator source address |

The Phase 4 tunnel plan was:

| Setting | Value |
| --- | --- |
| WireGuard network | `10.66.0.0/24` |
| Server tunnel address | `10.66.0.1/24` |
| Windows client tunnel address | `10.66.0.2/32` |
| Server listen port | `51820/UDP` |
| Azure-facing Linux interface | `eth0` |
| Client-routed networks | `10.66.0.0/24`, `10.10.0.0/24` |
| Keepalive interval | 25 seconds |

## Deployment Procedure

### 1. Confirm the Azure gateway properties and security rules

The Phase 3 VM was reviewed before guest configuration. The Azure portal showed `BatchWireGuardVM1` in Central US with private address `10.10.0.40`, a public IP association, and the expected Linux VM properties.

The network view confirmed the WireGuard NIC, disabled accelerated networking for the selected VM size, the administrator-restricted SSH rule, and the UDP `51820` WireGuard ingress rule. Azure NIC IP forwarding was inherited from the Phase 3 Bicep deployment.

*See Evidence:* [WireGuard VM properties](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/01-wireguard-vm-properties.png)

*See Evidence:* [WireGuard VM network and NSG rules](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/02-wireguard-vm-network-and-nsg-rules.png)

### 2. Create and verify the workstation SSH alias

The Windows OpenSSH configuration was prepared so the gateway could be reached through a stable host alias without repeatedly entering the full username and endpoint. The `.ssh` directory and `config` file were created or normalized on the administrator workstation.

The alias was then tested with SSH. Initial attempts failed while the file name and alias resolution were being corrected; the final `ssh lab-server` connection successfully opened an Ubuntu session on `BatchWireGuardVM1`.

*See Evidence:* [Create WireGuard VM SSH alias](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/03-create-wireguard-vm-ssh-alias.png)

*See Evidence:* [Verify WireGuard VM SSH access](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/04-verify-wireguard-vm-ssh-access.png)

### 3. Install firewall-persistence support

The package inventory was refreshed and `iptables-persistent` was installed. Its dependency, `netfilter-persistent`, added the systemd integration used to restore saved firewall rules during startup.

During package configuration, the current IPv4 rules were accepted for storage in `/etc/iptables/rules.v4`. This captured the rules present at installation time. The evidence does not prove that a separate `netfilter-persistent save` operation was run after the final WireGuard NAT rule was added, so final-rule persistence is not claimed here.

```bash
sudo apt-get install iptables-persistent
```

*See Evidence:* [Install iptables-persistent](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/05-install-iptables-persistent.png)

*See Evidence:* [Save current IPv4 firewall rules](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/06-save-current-ipv4-firewall-rules.png)

### 4. Install WireGuard

WireGuard and `wireguard-tools` were installed from the Ubuntu repositories. The package output confirmed successful installation without requiring a kernel or service restart.

```bash
sudo apt install wireguard
```

*See Evidence:* [Install WireGuard packages](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/07-install-wireguard-packages.png)

### 5. Create the server key pair securely

The WireGuard directory was created with root-only traversal and modification permissions. A restrictive process umask was applied before generating the private key. The private key file was set to mode `600`, while the derived public key file was made readable without granting write access to non-root users.

```bash
sudo mkdir -p /etc/wireguard
sudo chmod 700 /etc/wireguard
umask 077
wg genkey | sudo tee /etc/wireguard/server.key >/dev/null
sudo chmod 600 /etc/wireguard/server.key
sudo cat /etc/wireguard/server.key | wg pubkey | sudo tee /etc/wireguard/server.pub >/dev/null
sudo chmod 644 /etc/wireguard/server.pub
```

Private-key values are intentionally omitted. Only the public key should be transferred to the client configuration.

*See Evidence:* [Generate WireGuard server key pair](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/08-generate-wireguard-server-keypair.png)

### 6. Enable persistent IPv4 forwarding

Linux IPv4 forwarding was enabled through a dedicated sysctl configuration file and applied to the running system.

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wg.conf
sudo sysctl --system
```

An initial command used the misspelled path `/etc/systectl.d/99-wg.conf` and failed because the directory did not exist. The corrected path was `/etc/sysctl.d/99-wg.conf`. The final `sysctl --system` output showed `net.ipv4.ip_forward = 1`.

*See Evidence:* [Enable IPv4 forwarding](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/09-enable-ipv4-forwarding.png)

### 7. Configure the WireGuard server interface

The `/etc/wireguard/wg0.conf` file defined the server tunnel address, listen port, private key, and NAT hooks. The publication-safe form is:

```ini
[Interface]
Address = 10.66.0.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>

PostUp = iptables -t nat -A POSTROUTING -s 10.66.0.0/24 -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s 10.66.0.0/24 -o eth0 -j MASQUERADE
```

The `eth0` name refers to the primary network interface inside the Linux guest, not the Azure NIC resource name. The post-configuration system record showed the default route through `eth0`, the VM address `10.10.0.40`, and the WireGuard route through `wg0`.

The `PostUp` rule applies source NAT to traffic originating from `10.66.0.0/24` as it leaves through `eth0`. The matching `PostDown` rule removes that rule when the interface is stopped.

*See Evidence:* [Configure WireGuard wg0 interface](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/10-configure-wireguard-wg0-interface.png)

### 8. Start, troubleshoot, and enable the WireGuard service

The first `wg-quick@wg0` start failed. Service and journal output were used to isolate the configuration problem. The file initially contained invalid section syntax; WireGuard requires bracketed section headers such as `[Interface]` and `[Peer]`.

After correcting the file, the interface was restarted and enabled for system startup.

```bash
sudo systemctl enable --now wg-quick@wg0
sudo systemctl restart wg-quick@wg0
systemctl status wg-quick@wg0
```

The final service state was `active (exited)`, which is expected for `wg-quick`: the helper creates and configures the interface, then exits successfully while the kernel interface remains active. Socket inspection confirmed UDP `51820` listening on IPv4 and IPv6 wildcard addresses.

```bash
sudo ss -uulpn | grep 51820 || true
```

*See Evidence:* [Troubleshoot initial WireGuard service start](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/11-troubleshoot-initial-wireguard-service-start.png)

*See Evidence:* [Verify WireGuard service and UDP listener](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/12-verify-wireguard-service-and-udp-listener.png)

### 9. Create the Windows client and register its peer

A new tunnel was created in the Windows WireGuard application. The application generated the client key pair locally. The client public key was then registered on the server with the single client tunnel address:

```bash
sudo wg set wg0 peer <WINDOWS_CLIENT_PUBLIC_KEY> allowed-ips 10.66.0.2/32
sudo wg
```

An initial command used the invalid subcommand `wg se`; the corrected command used `wg set`. The resulting `wg` output showed the client peer and `allowed ips: 10.66.0.2/32`.

The publication-safe client configuration was:

```ini
[Interface]
PrivateKey = <WINDOWS_CLIENT_PRIVATE_KEY>
Address = 10.66.0.2/32

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
AllowedIPs = 10.66.0.0/24, 10.10.0.0/24
Endpoint = <SERVER_PUBLIC_ENDPOINT>:51820
PersistentKeepalive = 25
```

The server public key—not the client public key—belongs in the client `[Peer]` block. The client `AllowedIPs` entries create routes to the WireGuard network and the Azure private VNet without making the VPN the workstation's default route.

*See Evidence:* [Correct and add WireGuard client peer](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/13-correct-and-add-wireguard-client-peer.png)

*See Evidence:* [Verify WireGuard client peer](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/14-verify-wireguard-client-peer.png)

### 10. Verify the interface and establish the Windows tunnel

The server interface was verified with:

```bash
ip -br addr show wg0
```

The output showed `wg0` with `10.66.0.1/24`. The corrected Windows tunnel was activated and showed client address `10.66.0.2/32`, the configured server peer, a recent handshake, and transferred bytes.

*See Evidence:* [Verify WireGuard interface address](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/15-verify-wireguard-interface-address.png)

*See Evidence:* [Verify active Windows WireGuard tunnel](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/16-verify-active-windows-wireguard-tunnel.png)

*See Evidence:* [Verify WireGuard handshake and transfer](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/17-verify-wireguard-handshake-and-transfer.png)

### 11. Validate tunnel and private-subnet reachability

Initial pings to `10.66.0.1` failed while the peer key and client route entries were incomplete. After the server public key and `AllowedIPs` values were corrected, the tunnel endpoint returned four replies with no packet loss.

PowerShell `Test-Connection` was then used against the server tunnel address and the six private client VM addresses. The final target set returned `True` for the expected reachable systems.

```powershell
$targets = "10.66.0.1", "10.10.0.5", "10.10.0.6", "10.10.0.7", "10.10.0.8", "10.10.0.9", "10.10.0.10"

$targets | ForEach-Object {
    [pscustomobject]@{
        Target    = $_
        Reachable = Test-Connection -ComputerName $_ -Count 2 -Quiet
    }
}
```

*See Evidence:* [Verify tunnel address connectivity](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/18-verify-tunnel-address-connectivity.png)

*See Evidence:* [Verify private subnet reachability](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/19-verify-private-subnet-reachability.png)

### 12. Verify SSH access to all six private client VMs

Each client VM was reached directly through its private address while the WireGuard tunnel was active. The first attempt used the wrong local username and then the wrong authentication context. The successful form specified the deployed Linux administrator username and the matching private key:

```powershell
ssh -i "<PRIVATE_SSH_KEY_PATH>" david@10.10.0.5
```

The same method was validated for `10.10.0.6` through `10.10.0.10`. The Ubuntu login banners and hostnames confirmed sessions on `BatchTestClientVM1` through `BatchTestClientVM6`.

This is the Phase 4 endpoint: the workstation reached the six private VMs in one hop over the WireGuard tunnel. VM deallocation, targeted deletion, and teardown remain outside this phase.

*See Evidence:* [Verify SSH access to client VM1](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/20-verify-ssh-access-client-vm1.png)

*See Evidence:* [Verify SSH access to client VM2](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/21-verify-ssh-access-client-vm2.png)

*See Evidence:* [Verify SSH access to client VM3](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/22-verify-ssh-access-client-vm3.png)

*See Evidence:* [Verify SSH access to client VM4](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/23-verify-ssh-access-client-vm4.png)

*See Evidence:* [Verify SSH access to client VM5](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/24-verify-ssh-access-client-vm5.png)

*See Evidence:* [Verify SSH access to client VM6](../../screenshots/deployment/batch-deployment-phase-four-wireguard-server-conf/25-verify-ssh-access-client-vm6.png)

## Configuration Procedure

### Azure and guest forwarding layers

Routing through an Azure Linux VM required forwarding to be enabled at two different layers:

- Azure NIC IP forwarding allowed the platform virtual NIC to send and receive traffic whose source or destination was not the NIC's own address.
- Linux `net.ipv4.ip_forward=1` allowed the guest kernel to forward packets between `wg0` and `eth0`.

Neither setting replaced the other. The Phase 3 deployment supplied the Azure-side setting; Phase 4 supplied the Linux-side setting.

### Server interface and NAT configuration

The final server configuration established these behaviors:

- `wg0` owned `10.66.0.1/24`.
- WireGuard listened on UDP `51820`.
- The server authenticated itself with the private key stored at `/etc/wireguard/server.key`.
- `PostUp` added a POSTROUTING MASQUERADE rule for traffic from `10.66.0.0/24` leaving through `eth0`.
- `PostDown` removed the same rule when the tunnel stopped.
- The Windows peer was limited to `10.66.0.2/32` on the server.

The post-configuration system record independently showed:

```text
eth0  10.10.0.40/28
wg0   10.66.0.1/24
default route via 10.10.0.33 dev eth0
10.66.0.0/24 dev wg0
```

This confirmed that `eth0` was the correct Azure-facing guest interface for the NAT rule.

### Client routing and peer identity

WireGuard public keys identify peers, while `AllowedIPs` controls both route selection and the addresses a peer is permitted to use.

On the server, the client peer used only `10.66.0.2/32`. On Windows, the server peer used `10.66.0.0/24, 10.10.0.0/24`. This asymmetric configuration was intentional:

- The server needed to associate one tunnel IP with the Windows peer.
- The Windows client needed routes for the tunnel network and Azure private VNet.
- A default route such as `0.0.0.0/0` was not required for the administrative-access objective.

### Key handling and publication controls

The server and Windows private keys are authentication secrets. They must not be committed to the repository, embedded in documentation, or shown in published screenshots. The server private key should remain readable only by root, and the Windows private key should remain protected by the WireGuard application and workstation access controls.

The original evidence captured private-key material during troubleshooting. Redaction protects the published record, but it does not restore the secrecy of a key that was displayed or shared. All exposed keys should be regenerated before the environment is reused.

### Source and assistance methodology

Primary and authoritative technical sources drove the Central US configuration. These included the official WireGuard manual pages, Ubuntu Server WireGuard guidance, Ubuntu and GNU/Linux manual pages, the Linux kernel IP sysctl documentation, netfilter documentation, and Microsoft Learn material describing the Linux Azure network interface.

The historical `.txt` setup notes describe the earlier West US WireGuard VM. They were used as a reference baseline and comparison point, not as proof that the Central US server was configured successfully.

`Every Command We Ran for WireGuard.md` records the source and command set used during the server setup. `ubuntu-help-docs.md` expands that research trail by mapping individual configuration decisions to the supporting documentation. The current Central US screenshots, recovered shell history, and post-configuration system record provide the implementation evidence.

AI was used as an assistance tool to retrieve relevant sources, explain unfamiliar concepts, interpret documentation, and support troubleshooting. It was not treated as the authority for the configuration and was not used as proof that commands succeeded. The authoritative sources informed the decisions; the user's executed commands and captured system state established the result.

### Phase boundary

Phase 4 includes:

- Guest package installation and key generation.
- Linux forwarding and `wg0` configuration.
- NAT hook configuration.
- Windows peer configuration.
- Service, listener, handshake, routing, ping, and SSH verification.

Phase 4 excludes:

- Bicep creation of the WireGuard VM, which was completed in Phase 3.
- Client VM deallocation or deletion.
- Targeted teardown commands and remaining-resource verification.
- Later Phase 5 cleanup and lifecycle testing.

## Verification

### Azure prerequisite verification

The Azure portal confirmed that the WireGuard VM had the expected Central US resource properties, private address `10.10.0.40`, public endpoint association, restricted SSH ingress, and UDP `51820` ingress. Phase 3 had already enabled NIC IP forwarding.

### Service and listener verification

`systemctl status wg-quick@wg0` reported the service enabled and `active (exited)` after a successful `wg-quick up wg0` operation. The service output showed creation of `wg0`, assignment of `10.66.0.1/24`, activation with MTU `1420`, and application of the NAT rule.

`ss` showed UDP `51820` listening on wildcard IPv4 and IPv6 addresses.

### Interface and peer verification

`ip -br addr show wg0` confirmed `10.66.0.1/24`. Server-side `wg` output confirmed the listener and Windows peer with `allowed ips: 10.66.0.2/32`.

The Windows WireGuard application showed the tunnel active, client address `10.66.0.2/32`, the server peer, a recent handshake, persistent keepalive, and nonzero transferred bytes.

### Tunnel and subnet reachability

The final ping to `10.66.0.1` returned four replies with zero packet loss. The PowerShell reachability check returned successful results for the server tunnel address and the six private VM addresses from `10.10.0.5` through `10.10.0.10`.

### Private client access

Successful SSH sessions identified the six private systems as:

| Private IP | Verified host |
| --- | --- |
| `10.10.0.5` | `BatchTestClientVM1` |
| `10.10.0.6` | `BatchTestClientVM2` |
| `10.10.0.7` | `BatchTestClientVM3` |
| `10.10.0.8` | `BatchTestClientVM4` |
| `10.10.0.9` | `BatchTestClientVM5` |
| `10.10.0.10` | `BatchTestClientVM6` |

This verified the intended administrative path without public IP addresses on the client VMs.

### Evidence limitations

The original shell session logs were incomplete, and the screenshots were not stored in execution order. The evidence chain was therefore reconstructed from:

- Redacted screenshots of installation, configuration, troubleshooting, and verification.
- Recovered Bash command history from the WireGuard VM.
- A post-configuration system record showing interfaces, addresses, and routes.
- The final WireGuard service, peer, handshake, reachability, and SSH results.

The evidence supports the functional endpoint. It does not support a claim that the final NAT rule was explicitly saved with `netfilter-persistent` after `wg0` was configured.

## Common Issues

### The SSH alias was not recognized immediately

The first workstation attempts treated `lab-server` as an unknown command or unresolved host. The OpenSSH configuration file had to exist as `$HOME\.ssh\config` without a `.txt` extension, and the alias had to be invoked through `ssh lab-server`.

### The sysctl path was misspelled

The first forwarding command targeted `/etc/systectl.d/99-wg.conf`. The correct system configuration directory was `/etc/sysctl.d`.

After correction, `sudo sysctl --system` loaded the file and reported `net.ipv4.ip_forward = 1`.

### The initial WireGuard service start failed

`wg-quick@wg0` failed because the configuration did not initially use valid bracketed section headers. The interface file required `[Interface]` and, when persisted in the file, `[Peer]`.

Service status and journal output were the correct diagnostics. After fixing the syntax, the service started successfully.

### The wrong key was placed in the Windows peer block

The Windows configuration initially used an incorrect public key for the server peer. A WireGuard peer block must contain the remote peer's public key.

Replacing the value with the server public key allowed authentication to proceed.

### The client route list was incomplete

The tunnel could appear active while traffic to `10.66.0.1` or `10.10.0.0/24` still failed if the client `AllowedIPs` list did not include those networks.

The final Windows peer used:

```text
AllowedIPs = 10.66.0.0/24, 10.10.0.0/24
```

### A WireGuard command subcommand was mistyped

`sudo wg se ...` returned `Invalid subcommand: 'se'`. The correct command was `sudo wg set ...`.

The corrected command added the peer immediately, and `sudo wg` verified it.

### Ping failed before the final corrections

Early `ping 10.66.0.1` attempts returned general failure or timeouts. The failures were useful intermediate evidence but did not represent the final state.

After correcting the server identity and client routes, the same address returned successful replies.

### SSH authentication failed with the wrong username or key

The first private-VM SSH attempt used the workstation username and then prompted unsuccessfully for a password. The deployed Linux username and corresponding private SSH key had to be specified explicitly.

Successful sessions used the pattern:

```powershell
ssh -i "<PRIVATE_SSH_KEY_PATH>" david@<PRIVATE_VM_IP>
```

### The screenshots were out of chronological order

Some Phase 5 screenshots had been imported into the Phase 4 guide, and later evidence additions changed the display order. The final Phase 4 evidence set was selected by technical event rather than original file sequence.

Phase 5 deallocation and teardown screenshots were excluded from the Phase 4 record.

### Private key material appeared in raw evidence

Raw screenshots displayed sensitive key material during troubleshooting. Redacted replacements must be used in the published documentation.

Redaction is a publication control, not key recovery. Exposed keys should be rotated.

## Lessons Learned

- Azure NIC IP forwarding and Linux kernel IP forwarding are separate requirements for an Azure routing VM.
- `wg-quick` configuration syntax must use bracketed section names and valid WireGuard key values.
- The Linux guest interface name must be verified inside the VM; the Azure NIC resource name is not used in iptables commands.
- A restrictive directory mode, file mode, and umask provide defense in depth for WireGuard private keys.
- Server-side and client-side `AllowedIPs` have different routing and peer-address responsibilities.
- Split tunneling limited workstation routes to the VPN and private Azure networks required by the lab.
- An `active (exited)` `wg-quick` service can be healthy because the kernel interface remains configured after the helper exits.
- Handshake status and byte counters provide stronger tunnel evidence than an active-looking client toggle alone.
- Tunnel endpoint tests should precede private-subnet tests so peer or routing errors can be isolated.
- Direct SSH to each private address confirmed both network reachability and usable administrative access.
- Failed commands and timeouts should be preserved when they explain the troubleshooting path, but they must be clearly distinguished from the final state.
- Screenshots should be named by technical event and stored in execution order as soon as they are captured.
- Session recording should begin before configuration work and be retained alongside screenshots.
- Evidence should never display private keys; if a key is exposed, it should be rotated even when the screenshot is later redacted.
- Installing `iptables-persistent` and saving rules during package installation does not by itself prove that a later-added NAT rule was saved.
- Historical lab notes are valuable references, but the current deployment requires its own command history and final-state evidence.
- Primary technical sources should remain the authority; AI assistance should be described transparently as retrieval, explanation, and troubleshooting support.

Post-configuration improvements identified for future reuse include:

- Rotate all WireGuard keys exposed during the original evidence capture.
- Verify and document final NAT-rule persistence after the completed `wg0` configuration.
- Store a publication-safe configuration template containing placeholders rather than live keys or endpoints.
- Add a scripted health check for service state, listener state, peer handshake, routes, and client reachability.
- Record exact package versions and capture a complete terminal transcript from the start of the procedure.
- Consider stricter forwarding-filter rules in addition to the demonstrated NAT rule before treating the lab configuration as a production pattern.
- Review whether source NAT or routed return paths best fit the intended long-term architecture.

These improvements do not change the tested Phase 4 endpoint documented here.

## Related Documents

- [Batch Deployment Network Foundation](phase-1-batch-deployment-network-foundation-module.md)
- [Batch Deployment Phase 2 — Client VM Module](phase-2-batch-deployment-client-vm-module.md)
- [Batch Deployment Phase 3 — WireGuard VM Module](phase-3-batch-deployment-wireguard-module.md)
- [WireGuard VPN Gateway](../../remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
- [Security Model](../../architecture/security-model.md)
- [WireGuard `wg-quick` manual](https://man7.org/linux/man-pages/man8/wg-quick.8.html)
- [WireGuard `wg` manual](https://man7.org/linux/man-pages/man8/wg.8.html)
- [Ubuntu Server: WireGuard VPN as the default gateway](https://ubuntu.com/server/docs/how-to/wireguard-vpn/vpn-as-the-default-gateway/)
- [Linux kernel IPv4 sysctl documentation](https://docs.kernel.org/networking/ip-sysctl.html)
- [`sysctl.d` manual](https://man7.org/linux/man-pages/man5/sysctl.d.5.html)
- [Ubuntu iptables guidance](https://help.ubuntu.com/community/IptablesHowTo)
- [Microsoft Learn: MANA and Linux networking in Azure](https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-mana-linux)
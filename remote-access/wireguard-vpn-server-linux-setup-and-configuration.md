# WireGuard VPN Server Linux Setup and Configuration

## Overview

This document records the initial Linux-side installation and configuration of `WireGuardVM1` in the original Azure lab environment. It covers the work performed inside the Ubuntu virtual machine to install WireGuard, create the server key pair, enable routing, define the `wg0` interface, configure forwarding and network address translation, and manage the WireGuard service with `systemd`.

The initial setup established the Linux foundation later completed and operationally validated in [WireGuard VPN Server Completion and One-Hop Administration](wireguard-vpn-server-completion-and-one-hop-access.md).

No contemporaneous screenshots of the initial Linux configuration are available. This document is reconstructed from the retained command records, configuration notes, client configuration, and a later export of the server's operating state. It distinguishes recorded implementation steps from claims that were not validated until the later completion work.

## Purpose

The Linux configuration prepared `WireGuardVM1` to perform three functions:

- Terminate an encrypted WireGuard tunnel from an external administration workstation.
- Route traffic arriving on the WireGuard interface toward the Azure virtual network.
- Translate tunnel-client traffic through the VM's Azure-facing interface so internal systems could return traffic without routes to the WireGuard client subnet.

This document is limited to the Ubuntu operating system and WireGuard service. Azure NIC IP forwarding, network security group rules, the corrected Windows peer configuration, SSH-key distribution, and one-hop access validation are documented separately.

## Initial Server Context

The retained setup records identify the initial server as:

- Virtual machine: `WireGuardVM1`
- Operating system: Ubuntu 24.04 LTS
- Azure private IP: `10.0.0.36`
- Azure subnet: `DMZ-Subnet`, `10.0.0.32/29`
- Linux Azure-facing interface: `eth0`
- WireGuard interface: `wg0`
- WireGuard server address: `10.6.0.1/24`
- WireGuard listener: UDP `51820`
- Initial Windows peer address: `10.6.0.2`

The public endpoint and all private-key values are intentionally omitted from this document.

## Prerequisites

The initial Linux work assumed the following conditions:

- `WireGuardVM1` had been provisioned and was reachable through SSH.
- The administrator had `sudo` privileges.
- The VM had package-repository access.
- `eth0` was the Linux interface connected to the Azure VNet.
- Azure NIC IP forwarding would be enabled separately for the VM to forward packets at the Azure platform layer.
- An Azure NSG rule allowing inbound UDP `51820` would be required separately for external WireGuard traffic.

The retained February notes claimed that the NSG rule already existed. Later inspection proved that it had not actually been added. This Linux document therefore treats UDP `51820` access as an external dependency, not as part of the confirmed initial Linux result.

## Update the Operating System

The initial command record shows that the Ubuntu package index and installed packages were updated before WireGuard was configured:

```bash
sudo apt update && sudo apt upgrade -y
```

- `apt update` refreshed the package metadata available to the VM.
- `apt upgrade` installed available upgrades for existing packages.
- `-y` automatically accepted the upgrade prompt.

The retained notes state that the VM was rebooted after the upgrade. No original terminal transcript or screenshot remains to independently show the reboot.

## Install WireGuard and Persistent Firewall Support

WireGuard and the persistent `iptables` support package were installed with:

```bash
sudo apt install -y wireguard iptables-persistent
```

The packages served different purposes:

- `wireguard` supplied the WireGuard command-line utilities and `wg-quick` interface-management tooling.
- `iptables-persistent` supplied the persistence mechanism used to save firewall rules across reboots.

The historical notes also state that UFW was removed to avoid overlapping firewall management. They do not retain the exact removal command, so no unverified command is reproduced here.

## Create the WireGuard Configuration Directory

The server configuration directory was created and restricted to the root account:

```bash
sudo mkdir -p /etc/wireguard
sudo chmod 700 /etc/wireguard
```

- `mkdir -p` created the directory if it did not already exist and did not fail if it was already present.
- Mode `700` grants the owner full access while denying access to the group and other users.

Restricting `/etc/wireguard` protects configuration files that may contain private keys.

Mode `700` represents owner read, write, and execute permissions with no permissions for the group or other users. Execute permission on a directory permits traversal and access to its contents; it does not mean that the directory itself is executed as a program.

## Generate the Server Key Pair

### Generate the private key

The WireGuard server private key was generated and written directly to a root-controlled file:

```bash
wg genkey | sudo tee /etc/wireguard/server.key >/dev/null
sudo chmod 600 /etc/wireguard/server.key
```

The command pipeline performs the following actions:

- `wg genkey` generates a new WireGuard private key.
- The pipe sends the generated value to `sudo tee`.
- `sudo tee` writes the value to `/etc/wireguard/server.key` with the required elevated permissions.
- `>/dev/null` suppresses `tee` from repeating the private key in the terminal output.
- Mode `600` permits only the file owner to read or modify the private key.

The private-key file does not require execute permission because it is data consumed by WireGuard, not an executable program.

### Derive the public key

The server public key was derived from the private key:

```bash
sudo cat /etc/wireguard/server.key | wg pubkey | sudo tee /etc/wireguard/server.pub >/dev/null
sudo chmod 644 /etc/wireguard/server.pub
```

- `cat` reads the stored private key.
- `wg pubkey` derives the matching public key.
- `tee` writes the public key to `/etc/wireguard/server.pub`.
- Mode `644` permits the owner to modify the file and permits other users to read the non-secret public key.

The server private key remained on `WireGuardVM1`. Only the public key was intended for use in a remote peer configuration.

## Enable Linux IPv4 Forwarding

The Linux kernel was configured to forward IPv4 traffic between interfaces:

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wg.conf
sudo sysctl --system
```

The first command created a persistent sysctl configuration at `/etc/sysctl.d/99-wg.conf`. The second reloaded system sysctl files so the forwarding setting could take effect without waiting for another boot.

Files beneath `/etc/sysctl.d` use the `.conf` extension and are processed according to sysctl configuration precedence. The `99-` prefix places this local setting late in the filename ordering, allowing it to take precedence over many lower-numbered vendor defaults.

The setting is required because traffic enters through `wg0` and must be routed toward `eth0`. Linux forwarding alone is not sufficient in Azure; IP forwarding must also be enabled on the VM's Azure NIC.

A later server-state capture confirmed the Linux setting by showing:

```text
net.ipv4.ip_forward = 1
```

## Create the WireGuard Interface Configuration

The primary server configuration was created at:

```bash
sudo nano /etc/wireguard/wg0.conf
```

The retained configuration records support the following sanitized structure:

```ini
[Interface]
Address = 10.6.0.1/24
PrivateKey = <SERVER-WIREGUARD-PRIVATE-KEY>
ListenPort = 51820

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```

### Interface settings

- `[Interface]` defines the local WireGuard interface on `WireGuardVM1`.
- `Address = 10.6.0.1/24` assigns the server's address within the WireGuard tunnel network.
- `PrivateKey` authenticates the server interface and must contain the private-key value from `/etc/wireguard/server.key`.
- `ListenPort = 51820` instructs WireGuard to listen for UDP tunnel traffic on port `51820`.

### Forwarding rule

The `FORWARD` command permits packets arriving through `wg0` to traverse the Linux host:

```bash
iptables -A FORWARD -i wg0 -j ACCEPT
```

- `-A FORWARD` appends a rule to the forwarding chain.
- `-i wg0` matches packets entering through the WireGuard interface.
- `-j ACCEPT` permits the matching packets to be forwarded.

The corresponding `PostDown` command deletes the rule when `wg0` is stopped.

### NAT masquerade rule

The initial notes show NAT masquerading through the Azure-facing `eth0` interface:

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

- `-t nat` selects the NAT table.
- `-A POSTROUTING` appends a rule after the routing decision has been made.
- `-o eth0` matches traffic leaving through the Azure-facing interface.
- `-j MASQUERADE` replaces the tunnel client's source address with the address used by `WireGuardVM1` on that interface.

Masquerading allowed internal Azure VMs to return traffic to `WireGuardVM1` without requiring a separate route to `10.6.0.0/24`.

One retained generic setup record shows a narrower version using `-s 10.6.0.0/24`. The later server-state export confirms that the implemented original environment used the broader rule shown above without a source restriction. Source-scoping the rule remains a potential hardening improvement.

## Resolve the Initial Private-Key Placeholder Error

The first configuration attempt used placeholder text instead of a valid WireGuard private key. Starting the interface produced a key-length error because WireGuard could not interpret the placeholder as a valid key.

The retained command summary records that the configuration was rebuilt after reading the actual server private key:

```bash
PRIVATE_KEY=$(sudo cat /etc/wireguard/server.key)
```

The value was then used to populate the `PrivateKey` entry in `wg0.conf`. The literal key is not reproduced here.

This correction established an important configuration rule: explanatory placeholders are appropriate in documentation but cannot remain in the live WireGuard configuration.

## Add the Initial Peer Definition

The Linux server required a `[Peer]` block identifying the remote Windows WireGuard client. The intended server-side structure was:

```ini
[Peer]
PublicKey = <WINDOWS-WIREGUARD-PUBLIC-KEY>
AllowedIPs = 10.6.0.2/32
```

- `PublicKey` must contain the Windows client's WireGuard public key.
- `AllowedIPs = 10.6.0.2/32` associates that peer with its single tunnel address.

The initial records show that a client key pair and client configuration were created. However, the July completion work found that the server and Windows peer-key relationship was incorrect or incomplete. The peer block above represents the intended Linux-side design and later corrected state; the initial peer relationship is not treated as operationally validated.

## Start and Enable the WireGuard Service

The `wg0` interface was managed through the `wg-quick@wg0` systemd service:

```bash
sudo systemctl enable --now wg-quick@wg0
```

- `enable` configures the service to start automatically during boot.
- `--now` starts the service immediately as part of the same operation.
- `wg-quick@wg0` maps the service instance to `/etc/wireguard/wg0.conf`.

The `wg-quick` configuration format also explains why `PostUp` and `PostDown` belong in `wg0.conf`: `wg-quick up` creates and configures the interface before running post-up commands, while `wg-quick down` runs the corresponding teardown commands as the interface is removed.

The retained control commands were:

```bash
sudo systemctl start wg-quick@wg0
sudo systemctl stop wg-quick@wg0
sudo systemctl restart wg-quick@wg0
sudo systemctl status wg-quick@wg0
```

A later state export confirmed that `wg-quick@wg0` was enabled and active. Its service log showed creation of `wg0`, assignment of `10.6.0.1/24`, application of the forwarding and masquerade rules, and successful service startup.

## Save Firewall State

The historical command record states that the active `iptables` rules were saved with:

```bash
sudo netfilter-persistent save
```

The purpose was to retain firewall state across VM restarts. The later state export confirmed that `netfilter-persistent.service` was installed and started successfully.

The WireGuard configuration also adds and removes its required rules through `PostUp` and `PostDown`. When changing this configuration, the administrator must avoid creating duplicate persistent and runtime-managed rules.

## Verify the Linux Service

The retained setup procedure used the following commands to inspect the server:

```bash
sudo wg
sudo ss -uulpn | grep 51820 || true
sudo systemctl status wg-quick@wg0
```

These commands serve different validation purposes:

- `sudo wg` displays the WireGuard interface, listening port, peers, handshake state, and transfer counters.
- `ss -uulpn` lists listening UDP sockets and their associated processes.
- `grep 51820` limits the socket output to the WireGuard port.
- `|| true` prevents the overall command from being treated as a shell failure when no matching line is returned.
- `systemctl status` reports the service's current state and recent logs.

The initial records do not include an original terminal transcript showing these command results. The later server-state export confirms that the interface and service configuration persisted, but it does not retroactively prove that the initial Windows peer completed a valid handshake.

## Initial Client Relationship

The retained Windows client file used:

- A client address in the `10.6.0.0/24` tunnel network.
- The WireGuard server public key.
- The server's public endpoint on UDP `51820`.
- `PersistentKeepalive = 25`.
- Azure VNet prefixes in `AllowedIPs` for split tunneling.

The client file demonstrates the intended relationship between the Windows workstation and the Linux server. Its literal private key and public endpoint must not be published.

The February summary described the client as connected and later described VNet access. Those claims are not used as conclusive evidence here because the July completion session found the missing NSG rule, corrected the peer-key direction, corrected the Windows `AllowedIPs`, reloaded the service, and produced the first retained evidence of a current handshake and direct one-hop administration.

## Initial Linux Result

The retained records and later server-state export support the following conclusions about the initial Linux setup:

- WireGuard and persistent firewall tooling were installed.
- `/etc/wireguard` and the server key files were created with restricted permissions.
- Linux IPv4 forwarding was configured persistently.
- `wg0` was defined at `10.6.0.1/24` and configured to listen on UDP `51820`.
- Linux forwarding and NAT masquerading were attached to the WireGuard interface lifecycle.
- `wg-quick@wg0` was enabled for boot and successfully managed by systemd.
- The Linux host was substantially prepared to operate as a VPN router.

The records do not support treating the initial environment as a fully validated VPN service. External UDP access and the Windows/server peer relationship remained incomplete until the July completion work.

## Operational Notes

### Reload configuration changes

Editing `/etc/wireguard/wg0.conf` does not automatically change the running interface. The service must be reloaded after configuration changes:

```bash
sudo systemctl restart wg-quick@wg0
```

The restart temporarily removes `wg0`, applies the updated configuration, and recreates the interface and its associated rules.

### Protect key material

- `/etc/wireguard/server.key` must remain restricted to root.
- Documentation and published evidence must never contain a WireGuard private key.
- Backups containing `server.key` or `wg0.conf` must be stored securely outside the public repository.
- A peer receives the server public key, never the server private key.

### Keep WireGuard and SSH keys separate

WireGuard keys authenticate VPN peers. SSH keys authenticate user sessions on Linux systems. A WireGuard public key cannot be installed in `authorized_keys` and does not replace an SSH public key.

## Evidence and Source Records

No screenshot evidence exists for the initial Linux configuration. The document was reconstructed from the following retained records:

- `How to stand up a wireGuard VPN VM.txt` — generic server installation and configuration procedure matching the implemented design.
- `Every Command We Ran for WireGuard.md` — dated command and troubleshooting summary from the original setup work.
- `Create-WireGuard-Keys.txt` — retained server key-generation commands.
- `WireGuardVM-VPN-Setup-Documentation.txt` — dated environment and service summary containing both supported setup facts and later-corrected operational claims.
- `client1.conf.txt` — initial Windows peer configuration; private values must remain excluded from publication.
- `wireguard-original-vm-configuration-20260717T175005Z.txt` — later system-state capture confirming persistent Linux configuration, service state, interface addressing, and firewall behavior.

The source files are historical records rather than a contemporaneous terminal transcript. Where they conflict with later direct inspection, the later confirmed state controls.

The separate `ubuntu-help-docs.md` research record is not a source for this original setup. Those official references were collected and used exclusively during the later Batch Deployment WireGuard configuration and are intentionally excluded from this document's source record.

## AI Assistance and Implementation Ownership

The original `WireGuardVM1` Linux setup was heavily assisted by AI tools, primarily Grok and ChatGPT. AI assistance was used to generate or refine substantial portions of the command sequence, configuration structure, command explanations, and troubleshooting guidance used during the initial setup.

The administrator remained responsible for the hands-on implementation. The administrator:

- Provisioned and accessed the Azure VM.
- Entered and executed the Linux commands.
- Created and edited the WireGuard configuration files.
- Observed command output and system behavior.
- Made decisions during troubleshooting.
- Retained the resulting commands, configuration records, and environment notes.
- Later reviewed the original claims against the actual server state and corrected inaccuracies.

The level of AI assistance in this initial setup was greater than in the later Batch Deployment WireGuard work. During the later implementation, the administrator used independently collected Ubuntu, Linux, WireGuard, `iptables`, and Azure documentation to understand the commands and configuration in greater depth. Those later research sources belong to the Batch Deployment work and are not presented as sources used during this original setup.

AI-generated guidance and the retained historical summaries are not treated as proof that every claimed result succeeded. The implementation claims in this document are limited to commands and configuration supported by the retained records and the later direct server-state capture. The completed VPN behavior is documented separately using the July validation evidence.

## Related Documents

- [WireGuard VPN Server Completion and One-Hop Administration](wireguard-vpn-server-completion-and-one-hop-access.md)
- [WireGuard VM Initial Deployment and Jumpbox Configuration](wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
- [Jumpbox Administration Workflow](jumpbox-administration-workflow.md)

The completion document is the authoritative record for the corrected peer configuration, missing Azure NSG rule, active handshake, and successful private one-hop administration.
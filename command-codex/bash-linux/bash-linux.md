# Bash/Linux Command Reference

## Overview

This document serves as the Bash and Linux command reference for the Azure Network Infrastructure Lab.

Commands in this file are organized by function and are intended to explain reusable Linux command patterns used across the lab. System-specific context is documented separately under `command-codex/system-specific/`.

This file begins with Bash and Linux commands used during the WireGuard VPN Gateway implementation.

## Purpose

The purpose of this reference is to:

* Explain Linux commands used in the lab.
* Break down flags, arguments, pipes, redirects, and shell behavior.
* Provide reusable examples that can apply beyond a single system.
* Reduce future reliance on AI-assisted command generation.
* Support deeper understanding of Linux administration commands.

## Scope

This document currently covers commands related to:

* Package management
* Files and permissions
* File viewing and editing
* Key generation workflows
* Service management
* Kernel parameter configuration
* Socket and network validation
* SSH access

---

# Package Management

## apt update

### Command

```bash
sudo apt update
```

### Purpose

Refreshes the local package index.

### Breakdown

* `sudo` = runs the command as an administrator.
* `apt` = Ubuntu package management tool.
* `update` = downloads updated package metadata.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## apt install

### Command

```bash
sudo apt install -y wireguard iptables-persistent
```

### Purpose

Installs one or more packages.

### Breakdown

* `sudo` = administrator privileges.
* `apt install` = installs packages.
* `-y` = automatically confirms prompts.
* `wireguard` = package to install.
* `iptables-persistent` = package to install.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Files and Permissions

## mkdir

### Command

```bash
sudo mkdir -p /etc/wireguard
```

### Purpose

Creates a directory.

### Breakdown

* `sudo` = elevated privileges.
* `mkdir` = make directory.
* `-p` = create parent directories as needed and do not fail if the directory already exists.
* `/etc/wireguard` = target directory.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## chmod

### Command

```bash
sudo chmod 700 /etc/wireguard
```

### Purpose

Changes file or directory permissions.

### Breakdown

* `sudo` = elevated privileges.
* `chmod` = change mode.
* `700` = owner can read, write, and execute; group and others have no permissions.
* `/etc/wireguard` = target path.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## chmod for Private Key

### Command

```bash
sudo chmod 600 /etc/wireguard/server.key
```

### Purpose

Restricts a private key file so only the owner can read and write it.

### Breakdown

* `600` = owner read/write only.
* `/etc/wireguard/server.key` = private key file.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## chmod for Public Key

### Command

```bash
sudo chmod 644 /etc/wireguard/server.pub
```

### Purpose

Allows a public key file to be readable while limiting write access to the owner.

### Breakdown

* `644` = owner read/write; group and others read-only.
* `/etc/wireguard/server.pub` = public key file.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

# File Viewing and Editing

## cat

### Command

```bash
sudo cat /etc/wireguard/wg0.conf
```

### Purpose

Prints file contents to the terminal.

### Breakdown

* `sudo` = needed when reading protected files.
* `cat` = concatenate and print file content.
* `/etc/wireguard/wg0.conf` = target file.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---
## cat /etc/fstab

### Command

cat /etc/fstab

### Purpose

Displays the Linux filesystem table file.

### Breakdown

* `cat` = prints file contents to the terminal.
* `/etc/fstab` = system file that defines persistent filesystem mounts.

### Used In

* Golden Image Management

### Related Syntax

* `../syntax/bash-syntax.md`

---
## nano

### Command

```bash
sudo nano /etc/wireguard/wg0.conf
```

### Purpose

Opens a file in the Nano terminal text editor.

### Breakdown

* `sudo` = allows saving changes to protected paths.
* `nano` = terminal text editor.
* `/etc/wireguard/wg0.conf` = file to edit.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---
# Mount Validation

## findmnt

### Command

findmnt /srv/nfsclient

### Purpose

Checks whether a specific path is mounted and displays mount information.

### Breakdown

* `findmnt` = lists mounted filesystems or searches for a specific mount.
* `/srv/nfsclient` = local NFS client mount point used in the lab.

### Used In

* Golden Image Management

### Related Syntax

* `../syntax/bash-syntax.md`

---
## tee

### Command

```bash
wg genkey | sudo tee /etc/wireguard/server.key >/dev/null
```

### Purpose

Writes command output to a file, often when elevated permissions are required.

### Breakdown

* `wg genkey` = generates output.
* `|` = pipes output to another command.
* `sudo tee /etc/wireguard/server.key` = writes output to a protected file.
* `>/dev/null` = suppresses terminal display of the output.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

# WireGuard Tooling

## wg genkey

### Command

```bash
wg genkey
```

### Purpose

Generates a WireGuard private key.

### Breakdown

* `wg` = WireGuard command-line utility.
* `genkey` = generate a private key.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## wg pubkey

### Command

```bash
wg pubkey
```

### Purpose

Generates a WireGuard public key from a private key passed into the command.

### Breakdown

* `wg` = WireGuard command-line utility.
* `pubkey` = derive public key.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## wg

### Command

```bash
sudo wg
```

### Purpose

Displays WireGuard interface and peer status.

### Breakdown

* `sudo` = provides access to full WireGuard details.
* `wg` = WireGuard command-line utility.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Kernel and Network Configuration

## sysctl file write

### Command

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wg.conf
```

### Purpose

Writes a kernel setting to a sysctl configuration file.

### Breakdown

* `echo` = prints text.
* `'net.ipv4.ip_forward=1'` = kernel parameter being written.
* `|` = pipe operator.
* `sudo tee` = writes to a protected file.
* `/etc/sysctl.d/99-wg.conf` = target configuration file.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## sysctl reload

### Command

```bash
sudo sysctl --system
```

### Purpose

Reloads sysctl settings from system configuration files.

### Breakdown

* `sudo` = elevated privileges.
* `sysctl` = kernel parameter utility.
* `--system` = load settings from system config locations.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## iptables NAT rule

### Command

```bash
iptables -t nat -A POSTROUTING -s 10.6.0.0/24 -o eth0 -j MASQUERADE
```

### Purpose

Adds a NAT rule for outbound VPN client traffic.

### Breakdown

* `iptables` = firewall rules command.
* `-t nat` = use NAT table.
* `-A POSTROUTING` = append to POSTROUTING chain.
* `-s 10.6.0.0/24` = source subnet.
* `-o eth0` = outbound interface.
* `-j MASQUERADE` = rewrite source address.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Service Management

## systemctl enable --now

### Command

```bash
sudo systemctl enable --now wg-quick@wg0
```

### Purpose

Enables a service at boot and starts it immediately.

### Breakdown

* `sudo` = elevated privileges.
* `systemctl` = systemd service manager.
* `enable` = configure service to start at boot.
* `--now` = start immediately.
* `wg-quick@wg0` = WireGuard service instance.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## systemctl status

### Command

```bash
sudo systemctl status wg-quick@wg0
```

### Purpose

Displays current service status and recent logs.

### Breakdown

* `systemctl` = service manager.
* `status` = show service state.
* `wg-quick@wg0` = target service.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---
## systemctl status for WireGuard

### Command

sudo systemctl status wg-quick@wg0

### Purpose

Displays the current status and recent logs for the WireGuard service instance.

### Breakdown

* `sudo` = runs the command with elevated privileges.
* `systemctl` = manages systemd services.
* `status` = displays service state and recent log output.
* `wg-quick@wg0` = WireGuard service instance for the `wg0` interface.

### Used In

* WireGuard VPN Gateway
* WireGuard service troubleshooting

### Related Syntax

* `../syntax/bash-syntax.md`

---
## systemctl start

### Command

```bash
sudo systemctl start wg-quick@wg0
```

### Purpose

Starts a service.

### Breakdown

* `start` = starts the specified service.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## systemctl stop

### Command

```bash
sudo systemctl stop wg-quick@wg0
```

### Purpose

Stops a service.

### Breakdown

* `stop` = stops the specified service.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## systemctl restart

### Command

```bash
sudo systemctl restart wg-quick@wg0
```

### Purpose

Restarts a service.

### Breakdown

* `restart` = stops and starts the service.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Network and Socket Validation
## hostname -I

### Command

hostname -I

### Purpose

Displays the IP addresses assigned to the Linux host.

### Breakdown

* `hostname` = displays or manages hostname information.
* `-I` = prints all assigned IP addresses for the host.

### Used In

* Golden Image Management

### Related Syntax

* `../syntax/bash-syntax.md`

---
## ss

### Command

```bash
sudo ss -uulpn
```

### Purpose

Displays UDP listening sockets and related process information.

### Breakdown

* `ss` = socket statistics.
* `-u` = UDP sockets.
* `-l` = listening sockets.
* `-p` = process information.
* `-n` = numeric output.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## grep

### Command

```bash
sudo ss -uulpn | grep 51820
```

### Purpose

Filters command output for matching text.

### Breakdown

* `sudo ss -uulpn` = lists UDP listening sockets.
* `|` = pipe operator.
* `grep 51820` = show only lines containing `51820`.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

# SSH

## ssh by hostname

### Command

```bash
ssh David@TestLinuxServer1
```

### Purpose

Connects to a remote host using SSH.

### Breakdown

* `ssh` = secure shell client.
* `David` = remote username.
* `@` = separates username from hostname.
* `TestLinuxServer1` = remote hostname.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---
## ssh with Identity File

### Command

ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>

### Purpose

Connects to the WireGuard gateway using SSH with a specified private key file.

### Breakdown

* `ssh` = secure shell client used to connect to a remote system.
* `-i` = specifies the private key file used for authentication.
* `"C:\Path\To\WireGuardVM1_key.pem"` = placeholder path to the SSH private key.
* `David` = placeholder username for the remote system.
* `@` = separates the username from the target host.
* `<WIREGUARD_PUBLIC_IP>` = placeholder for the WireGuard gateway public IP address.

### Used In

* WireGuard VPN Gateway
* PowerShell quick-connect function

### Related Syntax

* `../syntax/bash-syntax.md`
---
## hostname

### Command

```bash
hostname
```

### Purpose

Displays the current system hostname.

### Breakdown

* `hostname` = prints the hostname of the current system.

### Used In

* WireGuard VPN Gateway

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Related Documents

* [WireGuard Command Library](../system-specific/wireguard.md)
* [Bash Syntax Reference](../syntax/bash-syntax.md)
---
BASH-LINUX ADDITIONS
PUT THIS BLOCK IN command-codex/bash-linux/bash-linux.md

# DNS Client Validation

## View DNS Resolver Configuration

### Command

cat /etc/resolv.conf

### Purpose

Displays the Linux DNS resolver configuration file.

### Breakdown

* `cat` = prints file contents to the terminal.
* `/etc/resolv.conf` = resolver configuration file that shows DNS settings used by the system.

### Used In

* Private DNS VNet DNS Lab

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Run DNS Lookup for Private DNS Name

### Command

nslookup nfs-server.vnet-dns.lab

### Purpose

Tests DNS resolution for a private DNS hostname.

### Breakdown

* `nslookup` = DNS lookup utility.
* `nfs-server.vnet-dns.lab` = private DNS name being resolved.

### Used In

* Private DNS VNet DNS Lab

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Run DNS Lookup Using Current Hostname

### Command

nslookup $(hostname).vnet-dns.lab

### Purpose

Tests DNS resolution for the current VM hostname inside the private DNS zone.

### Breakdown

* `nslookup` = DNS lookup utility.
* `$(hostname)` = runs `hostname` and inserts the result into the command.
* `.vnet-dns.lab` = private DNS zone suffix.

### Used In

* Private DNS VNet DNS Lab

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Public IP Detection and Command Piping

## Update NSG Rule Using Current Public IP

### Command

curl -s ifconfig.me | xargs -I {} az network nsg rule update \
  --resource-group TestGroup1 \
  --nsg-name WireGuardNSG1 \
  --name SSH \
  --source-address-prefixes {}

### Purpose

Retrieves the current public IP address and passes it into an Azure CLI NSG rule update command.

### Breakdown

* `curl` = transfers data from a URL.
* `-s` = silent mode.
* `ifconfig.me` = external service that returns the current public IP address.
* `|` = pipe operator.
* `xargs` = builds a command from piped input.
* `-I {}` = defines `{}` as the placeholder for the piped value.
* `az network nsg rule update` = Azure CLI command being run with the current IP.

### Used In

* WireGuard NSG and ASG Rules

### Related Syntax

* `../syntax/bash-syntax.md`
* `../syntax/azure-cli-query-syntax.md`

---

# Kernel Network Configuration

## Temporarily Enable IPv4 Forwarding

### Command

sudo sysctl -w net.ipv4.ip_forward=1

### Purpose

Temporarily enables IPv4 forwarding in the running Linux kernel.

### Breakdown

* `sudo` = runs the command with elevated privileges.
* `sysctl` = reads or changes kernel parameters.
* `-w` = writes a new value.
* `net.ipv4.ip_forward=1` = enables IPv4 packet forwarding.

### Used In

* WireGuard Remote Access

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Persist IPv4 Forwarding Setting

### Command

echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

### Purpose

Appends the IPv4 forwarding setting to `/etc/sysctl.conf` so it persists across reboots.

### Breakdown

* `echo` = prints text.
* `"net.ipv4.ip_forward=1"` = kernel setting text.
* `|` = sends the text to the next command.
* `sudo tee -a /etc/sysctl.conf` = appends the text to the protected sysctl configuration file.

### Used In

* WireGuard Remote Access

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Reload Sysctl Configuration

### Command

sudo sysctl -p

### Purpose

Reloads sysctl settings from `/etc/sysctl.conf`.

### Breakdown

* `sudo` = runs the command with elevated privileges.
* `sysctl` = kernel parameter utility.
* `-p` = loads settings from the sysctl configuration file.

### Used In

* WireGuard Remote Access

### Related Syntax

* `../syntax/bash-syntax.md`

---

# JSON Processing and Shell Execution

## Generate and Run Azure CLI Commands from JSON

### Command

jq -r '.[] | "az network private-dns record-set ptr create --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --name \(.name) --ttl 3600 && az network private-dns record-set ptr add-record --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --record-set-name \(.name) --ptrdname \(.PTRRecords[0].ptrdname)"' ptr-records-backup.json | bash

### Purpose

Uses `jq` to read a JSON backup file, generate Azure CLI commands, and execute them with Bash.

### Breakdown

* `jq` = command-line JSON processor.
* `-r` = raw output mode.
* `.[]` = processes each item in the JSON array.
* `\(.name)` = inserts the record name from the JSON object.
* `\(.PTRRecords[0].ptrdname)` = inserts the PTR hostname from the JSON object.
* `ptr-records-backup.json` = input JSON file.
* `| bash` = executes the generated command text with Bash.

### Used In

* Reverse DNS Zone Migration

### Related Syntax

* `../syntax/bash-syntax.md`
* `../syntax/azure-cli-query-syntax.md`
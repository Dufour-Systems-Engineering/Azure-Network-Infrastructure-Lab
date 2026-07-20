# WireGuard Command Library

## Overview

This document explains commands used to deploy, configure, validate, and administer the WireGuard VPN Gateway in the Azure Network Infrastructure Lab.

This file is system-specific. It documents WireGuard-related commands in context, while language-specific command behavior is also tracked separately under the Bash/Linux, PowerShell, and Azure CLI sections of the Command Codex.

## Purpose

The purpose of this document is to:

* Preserve commands used during WireGuard VPN Gateway setup.
* Explain what each command does in plain English.
* Group commands by function instead of strict chronology.
* Document commands used for deployment, configuration, validation, evidence gathering, and administration.
* Support future troubleshooting and reuse.

## Scope

This document covers commands related to:

* Ubuntu package installation
* WireGuard directory and key setup
* IP forwarding
* WireGuard service management
* WireGuard interface validation
* Listening port validation
* SSH access validation
* PowerShell quick-connect alias setup

This document does not replace the WireGuard VPN Gateway build guide. The build guide explains the implementation. This file explains the commands used during and around that implementation.

## Source Material

Commands were compiled from:

* `remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration.md`
* WireGuard VPN Gateway screenshots
* `How to stand up a wireGuard VPN VM.txt`
* `Every Command We Ran for WireGuard.md`
* `WireGuardVM-VPN-Setup-Documentation.txt`
* Later administrative workflow notes for the `wgssh` quick-connect function

## Command Groups

1. Package Management
2. Files and Permissions
3. Key Management
4. IP Forwarding
5. WireGuard Configuration
6. Service Management
7. Tunnel and Port Validation
8. SSH Administration
9. Administrative Convenience

---

# Package Management

## Update Package Lists

### Classification

Deployment

### Command

```bash
sudo apt update
```

### Purpose

Updates the local Ubuntu package index so the system knows what package versions are available from configured repositories.

### Context Used

Used before installing WireGuard packages on the VPN gateway VM.

### Breakdown

* `sudo` = runs the command with administrative privileges.
* `apt` = Ubuntu package management tool.
* `update` = refreshes the package index.

### Common Mistakes

* Confusing `apt update` with `apt upgrade`.
* Running install commands before refreshing package metadata.
* Assuming this installs software; it only updates package lists.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Install WireGuard and iptables Persistence

### Classification

Deployment

### Command

```bash
sudo apt install -y wireguard iptables-persistent
```

### Purpose

Installs WireGuard tools and the package used to persist firewall rules across reboots.

### Context Used

Used during initial WireGuard gateway setup.

### Breakdown

* `sudo` = runs with administrative privileges.
* `apt install` = installs packages.
* `-y` = automatically answers yes to prompts.
* `wireguard` = installs WireGuard VPN tools.
* `iptables-persistent` = allows iptables rules to survive reboot.

### Common Mistakes

* Forgetting `-y` during scripted or repeated installs.
* Installing WireGuard without considering whether firewall/NAT rules need persistence.
* Assuming Azure networking rules are handled by Linux alone; Azure NSGs and NIC forwarding still matter.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Files and Permissions

## Create WireGuard Configuration Directory

### Classification

Configuration

### Command

```bash
sudo mkdir -p /etc/wireguard
```

### Purpose

Creates the directory used to store WireGuard configuration and key files.

### Context Used

Used before generating server keys and creating `wg0.conf`.

### Breakdown

* `sudo` = creates the directory with elevated privileges.
* `mkdir` = makes a directory.
* `-p` = creates parent directories as needed and does not error if the directory already exists.
* `/etc/wireguard` = standard WireGuard configuration path.

### Common Mistakes

* Forgetting `sudo`.
* Creating the directory in the wrong path.
* Omitting `-p` when parent paths may not exist.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Restrict WireGuard Directory Permissions

### Classification

Configuration

### Command

```bash
sudo chmod 700 /etc/wireguard
```

### Purpose

Restricts the WireGuard configuration directory so only the owner can read, write, or access it.

### Context Used

Used to protect sensitive WireGuard configuration and key files.

### Breakdown

* `sudo` = modifies permissions with elevated privileges.
* `chmod` = changes file or directory permissions.
* `700` = owner has read/write/execute; group and others have no access.
* `/etc/wireguard` = target directory.

### Common Mistakes

* Using overly permissive permissions.
* Not understanding that execute permission on a directory controls traversal.
* Applying permissions to the wrong path.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## View WireGuard Server Configuration

### Classification

Evidence Gathering

### Command

```bash
sudo cat /etc/wireguard/wg0.conf
```

### Purpose

Displays the WireGuard server configuration file.

### Context Used

Used to verify the server interface, listening port, peer entries, and NAT rules for screenshot evidence.

### Breakdown

* `sudo` = required because the file is protected.
* `cat` = prints file contents.
* `/etc/wireguard/wg0.conf` = WireGuard interface configuration file.

### Common Mistakes

* Exposing private keys in screenshots or published documentation.
* Forgetting to redact sensitive values.
* Editing the file when only intending to view it.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Key Management

## Generate Server Private Key

### Classification

Configuration

### Command

```bash
wg genkey | sudo tee /etc/wireguard/server.key >/dev/null
```

### Purpose

Generates a WireGuard private key and writes it to the server key file.

### Context Used

Used during initial server key creation.

### Breakdown

* `wg genkey` = generates a new WireGuard private key.
* `|` = sends generated key output into the next command.
* `sudo tee /etc/wireguard/server.key` = writes the key to the protected file.
* `>/dev/null` = suppresses terminal output so the private key is not printed visibly.

### Common Mistakes

* Accidentally displaying or publishing the private key.
* Overwriting an existing working key.
* Forgetting to restrict file permissions afterward.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Restrict Server Private Key Permissions

### Classification

Configuration

### Command

```bash
sudo chmod 600 /etc/wireguard/server.key
```

### Purpose

Restricts the private key so only the owner can read and write it.

### Context Used

Used immediately after generating the server private key.

### Breakdown

* `sudo` = runs with elevated privileges.
* `chmod` = changes permissions.
* `600` = owner can read/write; group and others have no access.
* `/etc/wireguard/server.key` = private key file.

### Common Mistakes

* Leaving private keys readable by other users.
* Applying permissions to the public key instead of the private key.
* Publishing private key contents in documentation.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Generate Server Public Key

### Classification

Configuration

### Command

```bash
sudo cat /etc/wireguard/server.key | wg pubkey | sudo tee /etc/wireguard/server.pub >/dev/null
```

### Purpose

Reads the server private key, derives the corresponding public key, and writes it to `server.pub`.

### Context Used

Used after private key creation so the server public key could be used in client configuration.

### Breakdown

* `sudo cat /etc/wireguard/server.key` = reads the private key.
* `|` = pipes output to the next command.
* `wg pubkey` = derives the public key from the private key.
* `sudo tee /etc/wireguard/server.pub` = writes the public key file.
* `>/dev/null` = suppresses output to the terminal.

### Common Mistakes

* Confusing private and public keys.
* Copying the private key into a client configuration where a public key is expected.
* Forgetting to generate the public key after creating the private key.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Set Server Public Key Permissions

### Classification

Configuration

### Command

```bash
sudo chmod 644 /etc/wireguard/server.pub
```

### Purpose

Sets public key file permissions so the file is readable but not broadly writable.

### Context Used

Used after generating the server public key.

### Breakdown

* `sudo` = runs with elevated privileges.
* `chmod` = changes permissions.
* `644` = owner can read/write; group and others can read.
* `/etc/wireguard/server.pub` = public key file.

### Common Mistakes

* Treating the public key with the same secrecy requirements as the private key.
* Applying `644` to the private key by mistake.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# IP Forwarding

## Enable IPv4 Forwarding

### Classification

Configuration

### Command

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wg.conf
```

### Purpose

Creates a sysctl configuration file that enables IPv4 forwarding on the WireGuard VM.

### Context Used

Used so the VM could route traffic between the WireGuard interface and the Azure virtual network.

### Breakdown

* `echo 'net.ipv4.ip_forward=1'` = prints the kernel setting.
* `|` = sends the output into the next command.
* `sudo tee /etc/sysctl.d/99-wg.conf` = writes the setting to a protected sysctl config file.

### Common Mistakes

* Enabling Linux forwarding but forgetting Azure NIC IP forwarding.
* Typing the sysctl key incorrectly.
* Assuming the setting is active before reloading sysctl.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Apply sysctl Configuration

### Classification

Configuration

### Command

```bash
sudo sysctl --system
```

### Purpose

Reloads system kernel parameters from sysctl configuration files.

### Context Used

Used after creating the WireGuard IP forwarding configuration file.

### Breakdown

* `sudo` = applies system-level configuration.
* `sysctl` = views or changes kernel parameters.
* `--system` = loads settings from system configuration files.

### Common Mistakes

* Creating the sysctl file but forgetting to apply it.
* Assuming changes are active without checking.
* Forgetting Azure-side IP forwarding.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# WireGuard Configuration

## Edit WireGuard Interface Configuration

### Classification

Configuration

### Command

```bash
sudo nano /etc/wireguard/wg0.conf
```

### Purpose

Opens the WireGuard interface configuration file for editing.

### Context Used

Used to create or modify the `wg0` interface configuration.

### Breakdown

* `sudo` = opens the file with permission to save changes.
* `nano` = terminal text editor.
* `/etc/wireguard/wg0.conf` = WireGuard interface configuration file.

### Common Mistakes

* Saving malformed configuration syntax.
* Leaving placeholder keys in the file.
* Exposing private keys in screenshots.
* Forgetting that indentation and section names matter in config files.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Add NAT Rule in WireGuard PostUp

### Classification

Configuration

### Command

```bash
iptables -t nat -A POSTROUTING -s 10.6.0.0/24 -o eth0 -j MASQUERADE
```

### Purpose

Adds a NAT rule allowing VPN client traffic to appear as though it is leaving from the WireGuard VM.

### Context Used

Used in the WireGuard `PostUp` configuration so NAT is applied when the tunnel starts.

### Breakdown

* `iptables` = Linux firewall rule tool.
* `-t nat` = uses the NAT table.
* `-A POSTROUTING` = appends rule after routing decision.
* `-s 10.6.0.0/24` = matches WireGuard VPN client subnet.
* `-o eth0` = matches outbound interface.
* `-j MASQUERADE` = rewrites source address for outbound traffic.

### Common Mistakes

* Using the wrong outbound interface.
* Forgetting Azure NSG rules.
* Forgetting that this is modifying firewall behavior.
* Adding a rule but not removing or persisting it correctly.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Remove NAT Rule in WireGuard PostDown

### Classification

Configuration

### Command

```bash
iptables -t nat -D POSTROUTING -s 10.6.0.0/24 -o eth0 -j MASQUERADE
```

### Purpose

Removes the NAT rule when the WireGuard interface shuts down.

### Context Used

Used in the WireGuard `PostDown` configuration so firewall rules are cleaned up when the tunnel stops.

### Breakdown

* `iptables` = Linux firewall rule tool.
* `-t nat` = uses the NAT table.
* `-D POSTROUTING` = deletes the matching rule.
* `-s 10.6.0.0/24` = matches WireGuard VPN client subnet.
* `-o eth0` = matches outbound interface.
* `-j MASQUERADE` = target rule being removed.

### Common Mistakes

* PostDown rule does not match PostUp rule exactly.
* Removing the wrong firewall rule.
* Forgetting to test tunnel restart behavior.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Service Management

## Enable and Start WireGuard Service

### Classification

Configuration

### Command

```bash
sudo systemctl enable --now wg-quick@wg0
```

### Purpose

Enables the WireGuard service to start at boot and starts it immediately.

### Context Used

Used after creating `wg0.conf`.

### Breakdown

* `sudo` = runs with administrative privileges.
* `systemctl` = manages systemd services.
* `enable` = configures service startup at boot.
* `--now` = starts the service immediately.
* `wg-quick@wg0` = systemd unit for the WireGuard interface named `wg0`.

### Common Mistakes

* Starting the service before `wg0.conf` exists.
* Incorrect interface name.
* Invalid WireGuard config preventing service startup.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Start WireGuard Service

### Classification

Administration

### Command

```bash
sudo systemctl start wg-quick@wg0
```

### Purpose

Starts the WireGuard interface service.

### Context Used

Used as a control command for managing the VPN gateway.

### Breakdown

* `sudo` = administrative privileges.
* `systemctl start` = starts a service.
* `wg-quick@wg0` = WireGuard service instance for interface `wg0`.

### Common Mistakes

* Starting the wrong service.
* Not checking status after starting.
* Failing to identify config errors.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Stop WireGuard Service

### Classification

Administration

### Command

```bash
sudo systemctl stop wg-quick@wg0
```

### Purpose

Stops the WireGuard interface service.

### Context Used

Used during service control and shutdown workflows.

### Breakdown

* `sudo` = administrative privileges.
* `systemctl stop` = stops a service.
* `wg-quick@wg0` = WireGuard service instance for interface `wg0`.

### Common Mistakes

* Stopping the tunnel while connected through it.
* Assuming VM shutdown is the same as tunnel shutdown.
* Forgetting to restart the service afterward.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Restart WireGuard Service

### Classification

Administration

### Command

```bash
sudo systemctl restart wg-quick@wg0
```

### Purpose

Restarts the WireGuard service to reload configuration or recover from changes.

### Context Used

Used after configuration changes or during troubleshooting.

### Breakdown

* `sudo` = administrative privileges.
* `systemctl restart` = stops and starts the service.
* `wg-quick@wg0` = WireGuard service instance.

### Common Mistakes

* Restarting before confirming configuration syntax.
* Disconnecting active VPN sessions.
* Not checking service status after restart.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Check WireGuard Service Status

### Classification

Validation

### Command

```bash
sudo systemctl status wg-quick@wg0
```

### Purpose

Displays the service state, recent logs, and startup status for the WireGuard interface service.

### Context Used

Used for validation screenshots and troubleshooting.

### Breakdown

* `sudo` = allows full service status details.
* `systemctl` = manages and inspects systemd services.
* `status` = shows service state.
* `wg-quick@wg0` = WireGuard service for interface `wg0`.

### Common Mistakes

* Running without understanding whether the service is active, failed, or inactive.
* Missing error messages shown in the status output.
* Forgetting that status output may include sensitive paths or system details.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Save Persistent Firewall Rules

### Classification

Configuration

### Command

```bash
sudo netfilter-persistent save
```

### Purpose

Saves current firewall rules so they persist across reboot.

### Context Used

Used after firewall/NAT rule setup.

### Breakdown

* `sudo` = administrative privileges.
* `netfilter-persistent` = tool for saving and restoring firewall rules.
* `save` = writes current rules to persistent storage.

### Common Mistakes

* Saving incorrect rules.
* Forgetting to save after changes.
* Assuming active rules automatically persist.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Tunnel and Port Validation

## Display WireGuard Interface Status

### Classification

Validation / Evidence Gathering

### Command

```bash
sudo wg
```

### Purpose

Displays WireGuard interface state, peer information, endpoint data, transfer counters, and handshake information.

### Context Used

Used to validate the tunnel and capture evidence of WireGuard interface status.

### Breakdown

* `sudo` = allows access to full WireGuard interface details.
* `wg` = WireGuard command-line tool.

### Common Mistakes

* Publishing peer public IPs or endpoint data without redaction.
* Misreading missing handshake as normal.
* Confusing interface state with client connectivity.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Check UDP Listening Ports

### Classification

Validation / Evidence Gathering

### Command

```bash
sudo ss -uulpn
```

### Purpose

Displays UDP listening sockets and associated processes.

### Context Used

Used to confirm WireGuard was listening on UDP port 51820.

### Breakdown

* `sudo` = shows process details.
* `ss` = socket statistics tool.
* `-u` = show UDP sockets.
* `-u` = repeated UDP flag as typed in the captured command.
* `-l` = show listening sockets.
* `-p` = show process using the socket.
* `-n` = show numeric addresses and ports.

### Common Mistakes

* Forgetting that WireGuard uses UDP.
* Looking for TCP instead of UDP.
* Not recognizing the listening port.
* Publishing public IPs or local process details without review.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Filter Listening Port for WireGuard

### Classification

Validation / Evidence Gathering

### Command

```bash
sudo ss -uulpn | grep 51820 || true
```

### Purpose

Checks whether anything is listening on UDP port 51820 and avoids treating no-match output as a hard script failure.

### Context Used

Used in the generic WireGuard setup validation procedure.

### Breakdown

* `sudo ss -uulpn` = lists UDP listening sockets with process names.
* `|` = sends output to `grep`.
* `grep 51820` = filters for WireGuard's listening port.
* `|| true` = prevents the command from returning failure if no match is found.

### Common Mistakes

* Forgetting WireGuard listens on UDP.
* Omitting `sudo` and missing process details.
* Misusing `|| true` in scripts where failure should stop execution.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# SSH Administration

## SSH to WireGuard Gateway with Key

### Classification

Administration

### Command

```powershell
ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>
```

### Purpose

Connects to the WireGuard gateway using a private SSH key.

### Context Used

Used from the administrative workstation to access the WireGuard VM.

### Breakdown

* `ssh` = OpenSSH client.
* `-i` = specifies identity/private key file.
* `"C:\Path\To\WireGuardVM1_key.pem"` = private key path.
* `David@<WIREGUARD_PUBLIC_IP>` = username and host target.

### Common Mistakes

* Using the wrong username case.
* Typing the key path incorrectly.
* Publishing public IPs or key paths without redaction.
* Forgetting quotes around Windows paths with spaces.

### Related Syntax

* `../syntax/powershell-syntax.md`

---

## SSH from WireGuard Gateway to Internal VM

### Classification

Validation / Administration

### Command

```bash
ssh David@TestLinuxServer1
```

### Purpose

Connects from the WireGuard gateway to an internal Linux VM using private network name resolution.

### Context Used

Used to validate internal resource access through the WireGuard gateway.

### Breakdown

* `ssh` = OpenSSH client.
* `David` = remote username.
* `@` = separates username from host.
* `TestLinuxServer1` = internal VM hostname.

### Common Mistakes

* Wrong username case.
* DNS/name resolution failure.
* NSG restrictions blocking SSH.
* Trying to connect before VPN or internal routing works.

### Related Syntax

* `../syntax/bash-syntax.md`

---

## Confirm Hostname After SSH

### Classification

Validation / Evidence Gathering

### Command

```bash
hostname
```

### Purpose

Displays the current system hostname.

### Context Used

Used after SSH login to prove the session reached the expected internal VM.

### Breakdown

* `hostname` = prints the system hostname.

### Common Mistakes

* Assuming the SSH prompt alone proves the target host.
* Forgetting to confirm the destination after multiple hops.

### Related Syntax

* `../syntax/bash-syntax.md`

---

# Administrative Convenience

## Create PowerShell Quick-Connect Function

### Classification

Administration

### Command

```powershell
function wgssh {
    ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>
}
```

### Purpose

Creates a reusable PowerShell function that connects to the WireGuard gateway with a short command.

### Context Used

Added after initial deployment to reduce repetitive typing during recurring administrative access.

### Breakdown

* `function wgssh` = defines a PowerShell function named `wgssh`.
* `{ ... }` = contains the commands run by the function.
* `ssh -i` = starts SSH using a specified private key.
* `"C:\Path\To\WireGuardVM1_key.pem"` = placeholder for private key path.
* `David@<WIREGUARD_PUBLIC_IP>` = placeholder for remote username and gateway IP.

### Common Mistakes

* Saving the real key path or public IP in published documentation.
* Forgetting to add the function to the PowerShell profile.
* Closing PowerShell before making the function persistent.

### Related Syntax

* `../syntax/powershell-syntax.md`

---

## Check for PowerShell Profile

### Classification

Validation

### Command

```powershell
Test-Path $PROFILE
```

### Purpose

Checks whether the current PowerShell profile file exists.

### Context Used

Used before making the `wgssh` function permanent.

### Breakdown

* `Test-Path` = checks whether a path exists.
* `$PROFILE` = automatic variable containing the PowerShell profile path.

### Common Mistakes

* Assuming the profile file exists by default.
* Editing the wrong profile.
* Confusing PowerShell profile with Windows user profile.

### Related Syntax

* `../syntax/powershell-syntax.md`

---

## Create PowerShell Profile If Missing

### Classification

Configuration

### Command

```powershell
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}
```

### Purpose

Creates the PowerShell profile file if it does not already exist.

### Context Used

Used to persist the `wgssh` function across new PowerShell sessions.

### Breakdown

* `if` = starts conditional logic.
* `!` = negates the test result.
* `Test-Path -Path $PROFILE` = checks whether the profile exists.
* `New-Item` = creates a new item.
* `-ItemType File` = creates a file.
* `-Path $PROFILE` = targets the PowerShell profile path.
* `-Force` = creates parent path elements if required and suppresses certain prompts.

### Common Mistakes

* Forgetting the parentheses around the condition.
* Creating a profile in the wrong shell environment.
* Editing the profile but not restarting PowerShell.

### Related Syntax

* `../syntax/powershell-syntax.md`

---

## Open PowerShell Profile in Notepad

### Classification

Configuration

### Command

```powershell
notepad $PROFILE
```

### Purpose

Opens the PowerShell profile file for editing.

### Context Used

Used to paste the `wgssh` function into the profile file.

### Breakdown

* `notepad` = launches Windows Notepad.
* `$PROFILE` = path to the PowerShell profile.

### Common Mistakes

* Forgetting to save the file.
* Pasting malformed function syntax.
* Not restarting PowerShell after editing.

### Related Syntax

* `../syntax/powershell-syntax.md`

---

## Use WireGuard Quick-Connect Function

### Classification

Administration

### Command

```powershell
wgssh
```

### Purpose

Runs the saved PowerShell function to connect to the WireGuard gateway.

### Context Used

Used as the recurring quick-login method after profile configuration.

### Breakdown

* `wgssh` = custom PowerShell function defined in the user's profile.

### Common Mistakes

* Running it before restarting PowerShell.
* Function not loading because it was saved to the wrong profile.
* Forgetting that it depends on the SSH key path remaining valid.

### Related Syntax

* `../syntax/powershell-syntax.md`

---

# Batch Deployment Peer and One-Hop Validation

## Add a Peer to the Running Interface

### Classification

Validated runtime command.

### Command

```bash
sudo wg set wg0 peer <CLIENT_PUBLIC_KEY> allowed-ips <CLIENT_TUNNEL_IP>/32
```

### Purpose

Add or update a peer on the running `wg0` interface without restarting the service.

### Common Mistakes

* Using the server public key in place of the client public key.
* Assigning an overlapping `AllowedIPs` value.
* Assuming the runtime change survives a restart. Add the peer to `/etc/wireguard/wg0.conf` to make it persistent.

---

## Verify the Tunnel Interface and Peer State

### Classification

Validated verification sequence.

### Commands

```bash
sudo wg show
ip -br addr show wg0
sudo systemctl is-enabled wg-quick@wg0
sudo systemctl is-active wg-quick@wg0
sudo ss -uulpn
```

### Purpose

Confirm that the interface exists, WireGuard has loaded its peers, the service is enabled and active, and the UDP socket is listening.

---

## Restart After Updating Persistent Configuration

### Classification

Validated service command.

### Command

```bash
sudo systemctl restart wg-quick@wg0
```

### Common Mistakes

* Writing `INI` or `Interface` instead of the required `[Interface]` section header.
* Adding whitespace in an endpoint such as `<HOST> :51820`.
* Restarting before preserving a known-good configuration or active peer state.

---

## Validate One-Hop SSH Through the VPN

### Classification

Validated access pattern.

### Command

```powershell
ssh -i "<PRIVATE_KEY_PATH>" <ADMIN_USERNAME>@<PRIVATE_VM_IP>
```

### Purpose

Connect directly from the administrator workstation to a private VM after the WireGuard tunnel and Azure routing were validated.

### Environment Note

The original manually built environment used the `10.6.0.0/24` tunnel network. The later batch environment used `10.66.0.0/24`. They are separate validated lab contexts and must not be combined into one configuration.

---

## Related Documents

* [WireGuard VPN Gateway](../../remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
* [Bash/Linux Command Reference](../bash-linux/bash-linux.md)
* [PowerShell Command Reference](../powershell/powershell.md)
* [Bash Syntax Reference](../syntax/bash-syntax.md)
* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

# PowerShell Command Reference

## Overview

This document serves as the PowerShell command reference for the Azure Network Infrastructure Lab.

Commands in this file are organized by function and are intended to explain reusable PowerShell command patterns used across the lab. System-specific context is documented separately under `command-codex/system-specific/`.

This file begins with PowerShell commands used during the WireGuard VPN Gateway quick-connect configuration.

## Purpose

The purpose of this reference is to:

* Explain PowerShell commands used in the lab.
* Break down cmdlets, parameters, variables, script blocks, and function syntax.
* Provide reusable examples that can apply beyond a single system.
* Reduce future reliance on AI-assisted command generation.
* Support deeper understanding of Windows-side administration commands.

## Scope

This document currently covers commands related to:

* PowerShell profile validation
* PowerShell profile creation
* PowerShell profile editing
* Custom quick-connect functions
* Command discovery

---

# Profile Management

## Test-Path

### Command

Test-Path $PROFILE

### Purpose

Checks whether the current user’s PowerShell profile file exists.

### Breakdown

* `Test-Path` = checks whether a path exists.
* `$PROFILE` = built-in PowerShell variable that stores the path to the current user’s PowerShell profile.
* The command returns `True` if the profile exists and `False` if it does not.

### Used In

* WireGuard VPN Gateway
* PowerShell quick-connect configuration

### Related Syntax

* `../syntax/powershell-syntax.md`

---

## Create PowerShell Profile File If Missing

### Command

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

### Purpose

Checks whether the PowerShell profile file exists and creates it if it is missing.

### Breakdown

* `if` = starts a conditional statement.
* `!` = negates the result of the condition.
* `Test-Path -Path $PROFILE` = checks whether the profile file exists.
* `{ ... }` = script block containing the command to run if the condition is true.
* `New-Item` = creates a new item.
* `-ItemType File` = creates a file instead of a directory.
* `-Path $PROFILE` = creates the file at the PowerShell profile path.
* `-Force` = allows creation even when parent path handling or overwrite behavior would otherwise block the command.

### Used In

* WireGuard VPN Gateway
* PowerShell quick-connect configuration

### Related Syntax

* `../syntax/powershell-syntax.md`

---

## Open PowerShell Profile in Notepad

### Command

notepad $PROFILE

### Purpose

Opens the PowerShell profile file in Notepad for editing.

### Breakdown

* `notepad` = launches the Windows Notepad editor.
* `$PROFILE` = path to the current user’s PowerShell profile file.

### Used In

* WireGuard VPN Gateway
* PowerShell quick-connect configuration

### Related Syntax

* `../syntax/powershell-syntax.md`

---

# Functions

## WireGuard Quick-Connect Function

### Command

function wgssh {
    ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>
}

### Purpose

Creates a reusable PowerShell function named `wgssh` that starts an SSH session to the WireGuard gateway.

### Breakdown

* `function` = defines a reusable PowerShell function.
* `wgssh` = function name.
* `{ ... }` = script block containing the command run by the function.
* `ssh` = starts an SSH connection.
* `-i` = specifies the SSH private key file.
* `"C:\Path\To\WireGuardVM1_key.pem"` = placeholder path to the SSH private key.
* `David@<WIREGUARD_PUBLIC_IP>` = placeholder SSH target using username and gateway public IP.

### Used In

* WireGuard VPN Gateway
* PowerShell quick-connect configuration

### Related Syntax

* `../syntax/powershell-syntax.md`
* `../syntax/bash-syntax.md`

---

## Run WireGuard Quick-Connect Function

### Command

wgssh

### Purpose

Runs the custom quick-connect function and starts the saved SSH connection command.

### Breakdown

* `wgssh` = custom PowerShell function name.
* Running the function executes the SSH command stored inside the profile function.

### Used In

* WireGuard VPN Gateway
* PowerShell quick-connect validation

### Related Syntax

* `../syntax/powershell-syntax.md`

---

# Command Discovery

## Get-Command

### Command

Get-Command wgssh

### Purpose

Checks whether PowerShell recognizes the `wgssh` function or command.

### Breakdown

* `Get-Command` = finds commands available in the current PowerShell session.
* `wgssh` = command or function name being searched for.

### Used In

* WireGuard VPN Gateway
* PowerShell quick-connect validation

### Related Syntax

* `../syntax/powershell-syntax.md`

---

# Session Evidence and Secure Input

## Record a PowerShell Session

### Classification

Validated PowerShell commands.

### Commands

```powershell
Start-Transcript -Path ".\<SESSION_NAME>.txt"
Stop-Transcript
```

### Purpose

Capture commands and console output as execution evidence. Review transcripts for secrets before sharing them.

---

## Read a Sensitive Deployment Value Interactively

### Classification

Validated input and validation pattern.

### Commands

```powershell
$adminPassword = Read-Host "Enter VM admin password"
[string]::IsNullOrWhiteSpace($adminPassword)
```

### Purpose

Avoid hardcoding a password in the command history and check that a value was supplied.

### Common Mistakes

* Saving the entered value in documentation or source control.
* Assuming `Read-Host` makes a normal string cryptographically secure.

---

# SSH Key Preparation

## Generate an RSA SSH Key Pair in PEM Format

### Classification

Validated PowerShell-hosted external command.

### Commands

```powershell
ssh-keygen -m PEM -t rsa -b 2048 -f "C:\Path\To\Keys\<KEY_FILENAME>"
Get-Content -Path "C:\Path\To\Keys\<KEY_FILENAME>.pub"
```

### Common Mistakes

* Omitting `-b` before the key size.
* Passing only a directory after `-f`; it requires an output filename.
* Publishing the generated private key.

---

# Connectivity Validation

## Test Multiple VPN and Private Targets

### Classification

Validated PowerShell sequence.

### Commands

```powershell
$targets = "<VPN_GATEWAY_IP>", "<PRIVATE_VM_IP_1>", "<PRIVATE_VM_IP_2>"

$targets | ForEach-Object {
    [pscustomobject]@{
        Target    = $_
        Reachable = Test-Connection -ComputerName $_ -Count 2 -Quiet
    }
}
```

### Purpose

Produce a compact reachability result for the WireGuard interface and internal VMs.

---

## Related Documents

* [WireGuard Command Library](../system-specific/wireguard.md)
* [Bash/Linux Command Reference](../bash-linux/bash-linux.md)
* [PowerShell Syntax Reference](../syntax/powershell-syntax.md)

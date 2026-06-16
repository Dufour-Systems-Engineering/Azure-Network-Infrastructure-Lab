# PowerShell Syntax Reference

## Overview

This document explains PowerShell syntax patterns used throughout the Azure Network Infrastructure Lab.

The purpose of this file is to explain variables, cmdlets, parameters, script blocks, functions, conditions, and command patterns that appear inside documented PowerShell commands. System-specific command usage is documented separately under `command-codex/system-specific/`.

## Purpose

The purpose of this syntax reference is to:

* Explain PowerShell syntax in plain English.
* Define operators, variables, cmdlet structure, and function syntax used in lab commands.
* Support command breakdowns in the Command Codex.
* Reduce repeated explanations across system-specific documents.
* Build reusable PowerShell knowledge from commands used in the lab.

## Scope

This document currently covers syntax used during the WireGuard VPN Gateway quick-connect configuration.

Covered syntax includes:

* Built-in variables
* Cmdlets
* Parameters
* Conditional statements
* Negation
* Script blocks
* Function definitions
* External commands from PowerShell
* Windows file paths

---

# Variables

## PowerShell Profile Variable

### Symbol or Pattern

$PROFILE

### Plain-English Meaning

`$PROFILE` is a built-in PowerShell variable that stores the path to the current user’s PowerShell profile file.

### Where It Appears

Test-Path $PROFILE

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

notepad $PROFILE

### Breakdown

* `$` = indicates a PowerShell variable.
* `PROFILE` = built-in variable name.
* The value points to the profile file loaded by PowerShell when a new session starts.

### Why It Was Used

The profile file was used to make the `wgssh` quick-connect function persistent across PowerShell sessions.

### Common Mistakes

* Treating `$PROFILE` as plain text instead of a variable.
* Editing the wrong PowerShell profile.
* Forgetting to restart PowerShell after changing the profile.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)
* [WireGuard Command Library](../system-specific/wireguard.md)

---

# Cmdlets

## Verb-Noun Cmdlet Format

### Symbol or Pattern

Verb-Noun

### Plain-English Meaning

PowerShell cmdlets commonly use a `Verb-Noun` naming pattern.

### Where It Appears

Test-Path $PROFILE

New-Item -ItemType File -Path $PROFILE -Force

Get-Command wgssh

### Breakdown

* `Test-Path` = tests whether a path exists.
* `New-Item` = creates a new file, directory, or other item.
* `Get-Command` = finds available commands in the current session.
* The verb describes the action.
* The noun describes what the action applies to.

### Why It Was Used

These cmdlets were used to check for the PowerShell profile, create it if missing, and verify the custom `wgssh` function.

### Common Mistakes

* Forgetting the hyphen between verb and noun.
* Mixing up cmdlet names with Bash command names.
* Assuming all commands in PowerShell use Verb-Noun format.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)

---

# Parameters

## Named Parameters

### Symbol or Pattern

-Path
-ItemType
-Force

### Plain-English Meaning

Named parameters modify how a PowerShell command behaves or tell the command what value to operate on.

### Where It Appears

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

### Breakdown

* `-Path` = specifies the target path.
* `-ItemType` = specifies what type of item to create.
* `-Force` = forces creation behavior when needed.
* Parameter names begin with a dash.

### Why It Was Used

Named parameters made the profile-check and profile-creation commands explicit and easier to read.

### Common Mistakes

* Forgetting the dash before a parameter.
* Passing a value to the wrong parameter.
* Assuming `-Force` means a command is always safe.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)

---

# Conditional Logic

## If Statement

### Symbol or Pattern

if (condition) {
    command
}

### Plain-English Meaning

An `if` statement runs a command only when the condition evaluates to true.

### Where It Appears

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

### Breakdown

* `if` = starts conditional logic.
* `( ... )` = contains the condition being tested.
* `{ ... }` = contains the command to run if the condition is true.

### Why It Was Used

The profile file only needed to be created if it did not already exist.

### Common Mistakes

* Missing parentheses around the condition.
* Missing braces around the command block.
* Reversing the logic and creating a file when it already exists.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)

---

## Negation Operator

### Symbol or Pattern

!

### Plain-English Meaning

`!` means “not” in this PowerShell condition.

### Where It Appears

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

### Breakdown

* `Test-Path -Path $PROFILE` = checks whether the profile exists.
* `!` = reverses the result.
* If the profile does not exist, the condition becomes true.

### Why It Was Used

The command needed to create the PowerShell profile only when the file was missing.

### Common Mistakes

* Missing the `!` and reversing the intended behavior.
* Not noticing that the condition is checking for absence, not presence.
* Adding too many parentheses and making the statement harder to read.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)

---

# Script Blocks

## Curly Brace Script Block

### Symbol or Pattern

{
    command
}

### Plain-English Meaning

Curly braces group one or more commands into a script block.

### Where It Appears

if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

function wgssh {
    ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>
}

### Breakdown

* `{` = starts the script block.
* Commands inside the braces are grouped together.
* `}` = ends the script block.

### Why It Was Used

Script blocks were used to define what happens inside the `if` statement and what command runs when the `wgssh` function is called.

### Common Mistakes

* Missing a closing brace.
* Putting commands outside the intended block.
* Confusing PowerShell script blocks with Bash braces.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)

---

# Functions

## Function Definition

### Symbol or Pattern

function name {
    command
}

### Plain-English Meaning

Defines a reusable command that can be run by typing the function name.

### Where It Appears

function wgssh {
    ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>
}

### Breakdown

* `function` = tells PowerShell a function is being created.
* `wgssh` = function name.
* `{ ... }` = command block executed by the function.

### Why It Was Used

The `wgssh` function shortened the full WireGuard gateway SSH command into a reusable quick-connect command.

### Common Mistakes

* Forgetting to save the function in the PowerShell profile.
* Not restarting PowerShell after editing the profile.
* Using a function name that conflicts with another command.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)
* [WireGuard Command Library](../system-specific/wireguard.md)

---

# External Commands

## Running SSH From PowerShell

### Symbol or Pattern

ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>

### Plain-English Meaning

PowerShell can run external commands such as `ssh` when they are available on the Windows system path.

### Where It Appears

function wgssh {
    ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>
}

### Breakdown

* `ssh` = external SSH client command.
* `-i` = SSH option for specifying an identity file.
* `"C:\Path\To\WireGuardVM1_key.pem"` = quoted Windows key path placeholder.
* `David@<WIREGUARD_PUBLIC_IP>` = remote SSH target.

### Why It Was Used

The SSH command was embedded inside the PowerShell `wgssh` function to simplify gateway access.

### Common Mistakes

* Assuming `ssh` is a native PowerShell cmdlet.
* Using the wrong key path.
* Forgetting quotes around a Windows path.
* Publishing real local paths, usernames, or public IP addresses.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)
* [Bash Syntax Reference](./bash-syntax.md)

---

# File Paths

## Quoted Windows Path

### Symbol or Pattern

"C:\Path\To\WireGuardVM1_key.pem"

### Plain-English Meaning

A quoted Windows path keeps the full file path together as one argument.

### Where It Appears

ssh -i "C:\Path\To\WireGuardVM1_key.pem" David@<WIREGUARD_PUBLIC_IP>

### Breakdown

* `C:` = Windows drive letter.
* `\` = Windows path separator.
* `Path\To\WireGuardVM1_key.pem` = placeholder path to the private key.
* Double quotes keep the path together as one argument.

### Why It Was Used

The SSH key path needed to be passed to SSH as one complete value.

### Common Mistakes

* Missing quotes around paths with spaces.
* Publishing a real local key path.
* Confusing Windows backslashes with Linux forward slashes.

### Related Documents

* [PowerShell Command Reference](../powershell/powershell.md)
* [Bash Syntax Reference](./bash-syntax.md)

---
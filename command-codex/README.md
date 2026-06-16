# Command Codex

## Overview

The Command Codex is the centralized command reference system for the Azure Network Infrastructure Lab.

This section documents commands used throughout the lab and explains how they work. It is intended to preserve command usage, support learning, and provide a reusable reference for future Azure, Linux, PowerShell, and system-specific administration.

The Command Codex should not imply that every command was written from memory. Many commands were initially acquired through research, documentation review, troubleshooting, or AI-assisted learning, then tested, validated, and documented to build understanding.

The Command Codex exists to transform working commands into understood administrative knowledge.

---

## Purpose

The Command Codex exists to:

* Preserve commands used during lab deployment, validation, troubleshooting, administration, and maintenance.
* Explain commands in plain English.
* Break down meaningful command parts, flags, parameters, and syntax patterns.
* Separate system-specific command usage from general language and syntax references.
* Provide reusable references for commands that were actually used in the lab.
* Support future review, reuse, and command-line learning.
* Avoid overstating command-line proficiency.

---

## Repository Placement

The Command Codex is a root-level repository component located at:

```text
command-codex/
```

It exists separately from build guides, runbooks, scripts, screenshots, and evidence.

Build guides and runbooks explain what was built and how the process worked.

The Command Codex explains the commands used to build, validate, troubleshoot, and administer those systems.

---

## Folder Structure

```text
command-codex/
├── README.md
├── azure-cli/
│   └── azure-cli.md
├── bash-linux/
│   └── bash-linux.md
├── powershell/
│   └── powershell.md
├── syntax/
│   ├── azure-cli-query-syntax.md
│   ├── bash-syntax.md
│   └── powershell-syntax.md
└── system-specific/
    ├── cost-control-ops.md
    ├── golden-image-management.md
    └── wireguard.md
```

---

## Folder Roles

### azure-cli/

The `azure-cli/` folder documents Azure CLI commands used across the lab.

This includes commands for resource inspection, VM administration, networking, deployment validation, cleanup, and other Azure resource management tasks.

Current file:

```text
azure-cli/azure-cli.md
```

---

### bash-linux/

The `bash-linux/` folder documents Bash and Linux commands used across the lab.

This includes commands for package management, files and permissions, service management, networking, SSH access, validation, and system inspection.

Current file:

```text
bash-linux/bash-linux.md
```

---

### powershell/

The `powershell/` folder documents PowerShell commands and patterns used across the lab.

This includes local workstation administration, profile configuration, repo setup helpers, Azure PowerShell usage, object handling, and command pipeline behavior.

Current file:

```text
powershell/powershell.md
```

---

### syntax/

The `syntax/` folder documents command syntax, shell behavior, operators, flags, variables, quoting, redirection, pipelines, and query patterns.

Syntax files explain how command language works. They are not full language manuals. They focus on syntax patterns that appear in the lab command library.

Current files:

```text
syntax/azure-cli-query-syntax.md
syntax/bash-syntax.md
syntax/powershell-syntax.md
```

---

### system-specific/

The `system-specific/` folder documents commands related to a specific technology, service, workflow, or build document.

These files explain commands in system context.

Current files:

```text
system-specific/cost-control-ops.md
system-specific/golden-image-management.md
system-specific/wireguard.md
```

Future examples may include:

```text
nfs.md
azure-vm-management.md
network-validation.md
jumpbox-administration.md
private-dns.md
```

---

## Command Documentation Model

The Command Codex uses three documentation types.

### System-Specific Command Documents

System-specific documents explain commands in the context of a specific lab system or workflow.

Examples include:

* WireGuard VPN gateway commands
* Golden image management commands
* Cost-control operations commands
* Future NFS, VM lifecycle, and network validation command references

These files focus on how commands were used in the lab.

---

### Language and Tool References

Language and tool references group commands by command environment rather than by system.

Current references include:

* Azure CLI
* Bash/Linux
* PowerShell

These files are used as reusable command references across multiple lab documents.

---

### Syntax References

Syntax references explain command mechanics that appear across multiple commands.

Examples include:

* Bash pipes and redirection
* PowerShell variables and pipeline behavior
* Azure CLI query syntax
* Quoting rules
* Command substitution
* Common flags and output formats

These files explain the structure behind commands rather than the operational task itself.

---

## Command Sources

Commands documented in this section originated from multiple sources, including:

* Personal experimentation
* Active lab execution
* Build guides
* Runbooks
* Screenshot evidence
* Troubleshooting notes
* Command history
* Official vendor documentation
* Microsoft documentation
* Ubuntu documentation
* WireGuard documentation
* Community references
* AI-assisted tooling

AI-assisted tools used during the project included:

* ChatGPT
* Gemini
* Grok

Commands generated through AI-assisted workflows were not assumed to be correct.

Commands were validated through:

* Successful execution
* Troubleshooting and correction
* Azure Portal verification
* Linux command output
* Service validation
* Network testing
* Screenshot evidence
* Configuration review
* Follow-up inspection commands

---

## Deployment and Validation Commands

The Command Codex includes both commands that changed the environment and commands that verified the environment.

### Deployment and Configuration Commands

These commands create, modify, configure, or manage resources.

Examples:

* Creating VMs
* Creating NICs
* Updating NSG rules
* Installing packages
* Modifying configuration files
* Starting or stopping services
* Updating Azure resources
* Creating or changing local workstation helper functions

---

### Evidence and Validation Commands

These commands gather information and verify system state.

Examples:

* Service status checks
* Interface validation
* Configuration inspection
* Network validation
* Resource inventory
* Log inspection
* Mount validation
* File permission review

Both command categories are included because the lab documents both how systems were changed and how those changes were verified.

---

## Relationship to Other Repository Areas

### Build Guides and Runbooks

Relevant folders include:

```text
deployment/
operations/
remote-access/
storage/
```

Build guides and runbooks explain the system, workflow, procedure, and validation.

The Command Codex explains the commands used inside those documents.

---

### Scripts

Relevant folder:

```text
scripts/
```

Scripts contain executable code or reusable helper logic.

The Command Codex explains command patterns used by scripts when those patterns are relevant to lab administration or learning.

---

### Evidence

Relevant folder:

```text
evidence/
```

Evidence proves that commands produced the expected result.

The Command Codex explains the commands themselves.

---

### Screenshots

Relevant folder:

```text
screenshots/
```

Screenshots provide visual proof of configuration, command output, portal state, and validation results.

The Command Codex may reference screenshots indirectly through related build guides or runbooks, but screenshots remain stored under the `screenshots/` directory.

---

### Exports

Relevant folder:

```text
exports/
```

Exports contain generated configurations, templates, or system-generated data.

The Command Codex may explain commands used to create, inspect, or validate exports.

---

### Templates

Relevant folder:

```text
templates/
```

Templates define repeatable documentation formats.

Current related templates include:

```text
templates/command-library-template.md
templates/syntax-reference-template.md
```

---

## Redaction and Safety

Command documentation should preserve learning value without exposing reusable access details.

Do not include:

* Private keys
* Passwords
* Full local private key paths
* Unredacted public IP addresses when not required
* Public usernames tied to live administrative access
* Unredacted endpoint values when a placeholder is sufficient
* Secrets from configuration files
* Subscription IDs unless there is a clear reason to include them

Use placeholders where needed.

Examples:

```text
<WIREGUARD_PUBLIC_IP>
<CLIENT_PUBLIC_KEY>
<C:\Path\To\Key.pem>
<RESOURCE_GROUP>
<VM_NAME>
<ADMIN_USERNAME>
```

---

## Guiding Principle

The purpose of the Command Codex is not to demonstrate command-line expertise by implying every command was known from memory.

Its purpose is to document, understand, validate, and continuously improve command-line knowledge through practical use within the Azure Network Infrastructure Lab.

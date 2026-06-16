# Command Library Document Template

Use this template for:

```text
operations/admin-command-library/azure-cli.md
operations/admin-command-library/bash-linux.md
operations/admin-command-library/powershell.md
operations/admin-command-library/wireguard.md
```

---

# Document Title

Example:

```text
Azure CLI Command Library
```

## Overview

Briefly explain what type of commands this file contains and where they were used in the Azure lab.

Example:

```text
This document explains Azure CLI commands used to inspect, deploy, modify, validate, and clean up Azure resources in the lab environment.
```

## Scope

This document covers:

* Command types included in this file
* Resource types or systems affected
* Whether commands are read-only, modifying, or destructive
* Related syntax reference files

This document does not replace official documentation. It records commands used in this lab and explains them for operational reuse and learning.

## Command Groups

List the major command categories in the file.

Example:

```text
1. VM Inventory and Power State
2. VM Start, Stop, and Deallocation
3. NIC and IP Configuration
4. NSG and ASG Validation
5. Disk Inspection and Cleanup
6. Deployment and Troubleshooting
```

---

# Command Entries

## Command Name

Example:

```text
List VM Power States
```

### Command

```bash
command goes here
```

### Purpose

Explain what the command does in plain English.

### Context Used

Explain where this command was used in the lab.

Examples:

* Used before taking screenshots
* Used to verify VM state after deployment
* Used to confirm NIC configuration
* Used during troubleshooting
* Used before cleanup or deallocation

### Breakdown

Explain every meaningful part of the command.

Example:

```text
- `az` = Azure CLI command-line tool
- `vm` = Azure virtual machine command group
- `list` = lists virtual machines
- `-g TestGroup1` = limits the command to the TestGroup1 resource group
- `-d` = includes power state and instance details
- `--query` = filters or reshapes the output
- `-o table` = displays the result as a readable table
```

### Familiarity Level

Choose one:

```text
Comfortable
Working Knowledge
Learning
High-Risk / Review Before Use
```

### Risk Level

Choose one:

```text
Read-Only
Modification
Destructive
```

### Why This Was Safe To Run

Explain why the command was reasonable to execute in the lab.

Examples:

```text
This was safe to run because it only displayed resource state and did not modify Azure resources.
```

```text
This was safe to run because the target VM was confirmed by name, the environment was non-production, and the command was run against a known lab resource.
```

### Expected Result

Explain what should happen if the command works.

Example:

```text
The command should return a table showing VM names and current power states.
```

### Actual Result / Validation

Summarize how the result was validated.

Examples:

* Output matched Azure Portal state
* Screenshot captured after command
* VM state changed as expected
* Follow-up command confirmed the change
* Service status confirmed the result

### Common Mistakes

List likely mistakes or risks.

Examples:

* Wrong resource group
* Wrong VM name
* Missing quotation marks
* Incorrect query syntax
* Running a destructive command without confirming the target

### Related Syntax

Link to the syntax file that explains symbols or patterns used in the command.

Examples:

```markdown
- [Azure CLI Query Syntax](./syntax/azure-cli-query-syntax.md)
- [Bash Syntax](./syntax/bash-syntax.md)
- [PowerShell Syntax](./syntax/powershell-syntax.md)
```

### Related Documents

Link to related operational or build documents.

Examples:

```markdown
- [VM Lifecycle Management](../vm-lifecycle-management.md)
- [Cost Control Operations](../cost-control-operations.md)
- [Command Output Reference](../../evidence/command-output-reference.md)
```

### Notes

Add caveats, lessons learned, or reminders.

---

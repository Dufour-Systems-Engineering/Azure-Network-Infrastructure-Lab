# Syntax Reference Document Template

Use this template for:

```text
operations/admin-command-library/syntax/bash-syntax.md
operations/admin-command-library/syntax/powershell-syntax.md
operations/admin-command-library/syntax/azure-cli-query-syntax.md
operations/admin-command-library/syntax/wireguard-config-syntax.md
```

---

# Syntax Reference Title

Example:

```text
Bash Syntax Reference
```

## Overview

Explain what syntax this file covers and why it matters.

Example:

```text
This document explains Bash syntax patterns that appear in commands used throughout the Azure Network Infrastructure Lab.
```

## Scope

This document covers:

* Symbols
* Operators
* Flags
* Variables
* Quoting rules
* Command patterns
* Common mistakes
* Examples from the lab

This document focuses only on syntax seen or likely to be reused in this lab.

## Syntax Categories

List the major syntax groups.

Example for Bash:

```text
1. Pipes and Redirection
2. Variables and Substitution
3. Quoting
4. Loops
5. File Permissions
6. Command Chaining
```

Example for PowerShell:

```text
1. Variables
2. Arrays
3. Hashtables
4. Pipelines
5. Objects and Properties
6. Comparison Operators
7. Script Blocks
```

Example for Azure CLI query syntax:

```text
1. Output Formats
2. JMESPath Queries
3. Object Projection
4. Filtering
5. Common Azure CLI Flags
```

---

# Syntax Entries

## Syntax Item

Example:

```text
Pipe Operator
```

### Symbol or Pattern

```bash
|
```

### Plain-English Meaning

Explain what the symbol or pattern does.

Example:

```text
The pipe sends the output of one command into another command.
```

### Where It Appears

Show one or more lab commands where this syntax appears.

```bash
az vm list --query "[].id" -o tsv | example-command
```

### Breakdown

Explain the syntax behavior step by step.

Example:

```text
- The command on the left runs first.
- Its output becomes input for the command on the right.
- In Bash, the pipe usually passes text.
- In PowerShell, the pipe usually passes objects.
```

### Why It Was Used

Explain why this syntax was useful in the lab.

Example:

```text
This was used to pass resource IDs from one command into another without manually copying each ID.
```

### Risk or Confusion Point

Explain what could go wrong.

Example:

```text
A pipe can hide complexity because the second command may act on every item passed from the first command.
```

### Mini Example

Use a simple generic example.

```bash
command-one | command-two
```

### Lab Example

Use a real or realistic lab command.

```bash
az vm list --query "[].id" -o tsv
```

### Related Commands

Link to command library entries that use this syntax.

```markdown
- [Azure CLI Command Library](../azure-cli.md)
- [Bash and Linux Command Library](../bash-linux.md)
```

### Familiarity Status

Choose one:

```text
Understood
Partially Understood
Needs Review
High-Risk Pattern
```

### Notes

Add reminders or lessons learned.

---

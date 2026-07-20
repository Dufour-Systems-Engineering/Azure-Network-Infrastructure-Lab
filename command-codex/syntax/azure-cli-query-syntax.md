# Azure CLI Query Syntax Reference

## Overview

This document explains Azure CLI syntax patterns used throughout the Azure Network Infrastructure Lab.

The purpose of this file is to explain Azure CLI command structure, parameters, output formats, query syntax, and common Azure CLI patterns found in documented lab commands.

## Purpose

The purpose of this syntax reference is to:

* Explain Azure CLI command structure in plain English.
* Define common Azure CLI flags and parameters used in the lab.
* Explain output formats such as table and JSON.
* Explain query syntax used to filter and reshape command output.
* Support command breakdowns in the Command Codex.

## Scope

This document currently covers syntax used during DNS migration, NSG rule configuration, private DNS validation, and VM cost-control workflows.

Covered syntax includes:

* Azure CLI command groups
* Resource group targeting
* Resource names
* Output formats
* Confirmation flags
* Boolean parameters
* JMESPath object projection
* JMESPath array indexing
* NSG rule parameters
* DNS zone parameters

---

# Azure CLI Command Structure

## Command Group Pattern

### Symbol or Pattern

az network private-dns zone create

### Plain-English Meaning

Azure CLI commands are structured as nested command groups followed by an action.

### Where It Appears

az network private-dns zone create --resource-group TestGroup1 --name 0.0.10.in-addr.arpa

### Breakdown

* `az` = Azure CLI.
* `network` = Azure networking command group.
* `private-dns` = private DNS command subgroup.
* `zone` = DNS zone resource type.
* `create` = action being performed.

### Why It Was Used

The lab used Azure CLI command groups to manage DNS zones, PTR records, VNet links, and NSG rules.

### Common Mistakes

* Mixing public DNS and private DNS command groups.
* Using `dns` when the resource is under `private-dns`.
* Placing parameters before the command group is complete.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

# Resource Targeting

## Resource Group Parameter

### Symbol or Pattern

--resource-group TestGroup1

### Plain-English Meaning

Specifies the Azure resource group where the target resource exists.

### Where It Appears

az network dns zone show --resource-group TestGroup1 --name 0.0.10.in-addr.arpa --output table

### Breakdown

* `--resource-group` = parameter name.
* `TestGroup1` = resource group value.

### Why It Was Used

Most lab resources were managed inside the TestGroup1 resource group.

### Common Mistakes

* Using the wrong resource group.
* Mixing `--resource-group` with PowerShell’s `-ResourceGroupName`.
* Forgetting that many Azure CLI commands require a resource group.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

## Name Parameter

### Symbol or Pattern

--name

### Plain-English Meaning

Specifies the name of the Azure resource being managed.

### Where It Appears

az network private-dns zone create --resource-group TestGroup1 --name 0.0.10.in-addr.arpa

### Breakdown

* `--name` = parameter name.
* The value after `--name` identifies the resource.

### Why It Was Used

Used to target DNS zones, DNS links, NSG rules, and other named Azure resources.

### Common Mistakes

* Confusing `--name` with `--zone-name`.
* Using the wrong resource name.
* Forgetting that some commands use different name-related parameters.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

## Zone Name Parameter

### Symbol or Pattern

--zone-name

### Plain-English Meaning

Specifies the DNS zone that contains the record set or link being managed.

### Where It Appears

az network private-dns record-set ptr list \
  --resource-group TestGroup1 \
  --zone-name 0.0.10.in-addr.arpa \
  --output table

### Breakdown

* `--zone-name` = DNS zone parameter.
* `0.0.10.in-addr.arpa` = reverse lookup zone name.

### Why It Was Used

PTR records are managed inside a specific DNS zone, so the command must identify the zone.

### Common Mistakes

* Using `--name` when the command expects `--zone-name`.
* Targeting the public zone instead of the private zone.
* Misspelling reverse DNS zone names.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

# Output Formats

## Table Output

### Symbol or Pattern

--output table

### Plain-English Meaning

Displays Azure CLI output as a readable table.

### Where It Appears

az network dns zone show --resource-group TestGroup1 --name 0.0.10.in-addr.arpa --output table

### Breakdown

* `--output` = controls output format.
* `table` = readable table format.

### Why It Was Used

Table output was used for human-readable validation and screenshot evidence.

### Common Mistakes

* Using table output when JSON is needed for automation.
* Expecting table output to preserve full nested object details.
* Mixing `--output` with PowerShell’s formatting cmdlets.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

## JSON Output

### Symbol or Pattern

--output json

### Plain-English Meaning

Displays Azure CLI output as JSON.

### Where It Appears

az network dns record-set ptr list --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --output json > ptr-records-backup.json

### Breakdown

* `--output` = controls output format.
* `json` = structured JSON output.

### Why It Was Used

JSON output was used to back up PTR records so they could be processed later with `jq`.

### Common Mistakes

* Using table output when a structured backup is needed.
* Forgetting to redirect JSON output to a file.
* Editing JSON manually and breaking formatting.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)
* [Bash Syntax Reference](./bash-syntax.md)

---

# Query Syntax

## Query Parameter

### Symbol or Pattern

--query

### Plain-English Meaning

Filters or reshapes Azure CLI output using JMESPath query syntax.

### Where It Appears

az network private-dns record-set ptr list \
  --resource-group TestGroup1 \
  --zone-name 0.0.10.in-addr.arpa \
  --query "[].{Name:name, Hostname:ptrRecords[0].ptrdname, TTL:ttl}" \
  --output table

### Breakdown

* `--query` = enables output filtering or shaping.
* The expression after `--query` controls what fields are returned.

### Why It Was Used

The command needed to show only the record name, PTR hostname, and TTL for verification.

### Common Mistakes

* Incorrect quoting around the query.
* Misspelling property names.
* Forgetting that query syntax is case-sensitive.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

## Object Projection

### Symbol or Pattern

[].{Name:name, Hostname:ptrRecords[0].ptrdname, TTL:ttl}

### Plain-English Meaning

Creates a custom output object for each item in a list.

### Where It Appears

--query "[].{Name:name, Hostname:ptrRecords[0].ptrdname, TTL:ttl}"

### Breakdown

* `[]` = process each item in the list.
* `{...}` = create a new object.
* `Name:name` = output column named Name using the `name` property.
* `Hostname:ptrRecords[0].ptrdname` = output column named Hostname using the first PTR record hostname.
* `TTL:ttl` = output column named TTL using the `ttl` property.

### Why It Was Used

It produced a clean verification table for PTR records.

### Common Mistakes

* Forgetting the leading `[]`.
* Using the wrong property name.
* Confusing display names with actual JSON property names.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

## Array Indexing

### Symbol or Pattern

ptrRecords[0].ptrdname

### Plain-English Meaning

Selects the first item in the `ptrRecords` array and then reads its `ptrdname` property.

### Where It Appears

--query "[].{Name:name, Hostname:ptrRecords[0].ptrdname, TTL:ttl}"

### Breakdown

* `ptrRecords` = array of PTR record objects.
* `[0]` = first item in the array.
* `.ptrdname` = hostname property inside that first item.

### Why It Was Used

Each PTR record set contained a PTR record object, and the command needed to display its hostname.

### Common Mistakes

* Forgetting that arrays start at index `0`.
* Using the wrong capitalization.
* Querying a missing array item.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

# Confirmation and Boolean Values

## Confirmation Flag

### Symbol or Pattern

--yes

### Plain-English Meaning

Confirms an Azure CLI action without prompting interactively.

### Where It Appears

az network dns zone delete --resource-group TestGroup1 --name 0.0.10.in-addr.arpa --yes

### Breakdown

* `--yes` = automatically confirms the operation.

### Why It Was Used

The public DNS zone deletion command required confirmation.

### Common Mistakes

* Using `--yes` without confirming the target resource.
* Assuming `--yes` makes an operation reversible.
* Running destructive commands from copied examples without changing resource names.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

## Boolean Parameter Value

### Symbol or Pattern

--registration-enabled false

### Plain-English Meaning

Sets a true/false option for an Azure CLI command.

### Where It Appears

az network private-dns link vnet create --resource-group TestGroup1 --zone-name 0.0.10.in-addr.arpa --name reverse-vnet-link --virtual-network TestVNet1 --registration-enabled false

### Breakdown

* `--registration-enabled` = controls auto-registration.
* `false` = disables the setting.

### Why It Was Used

Reverse DNS zones do not use auto-registration, so registration was disabled.

### Common Mistakes

* Enabling registration on a reverse zone.
* Typing Boolean values inconsistently.
* Assuming every private DNS zone should use auto-registration.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)

---

# NSG Rule Parameters

## Source Address Prefixes

### Symbol or Pattern

--source-address-prefixes

### Plain-English Meaning

Specifies what source IP address, CIDR range, or Azure service tag is allowed or denied by an NSG rule.

### Where It Appears

az network nsg rule update \
  --resource-group TestGroup1 \
  --nsg-name WireGuardNSG1 \
  --name SSH \
  --source-address-prefixes {}

### Breakdown

* `--source-address-prefixes` = source address condition for the NSG rule.
* `{}` = placeholder replaced by the current public IP in the Bash pipeline.

### Why It Was Used

The SSH rule needed to match the administrator’s current public IP address.

### Common Mistakes

* Setting the wrong source address.
* Leaving SSH open too broadly.
* Forgetting that home public IPs can change.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)
* [Bash Syntax Reference](./bash-syntax.md)

---

# Special Values

## Wildcard Port Range

### Symbol or Pattern

'*'

### Plain-English Meaning

Represents any destination port in the NSG rule command.

### Where It Appears

--destination-port-ranges '*'

### Breakdown

* `*` = wildcard for any value.
* Single quotes prevent the shell from expanding the wildcard.

### Why It Was Used

The ICMP rule did not need a specific destination port.

### Common Mistakes

* Forgetting quotes around `*`.
* Using port wildcards where a narrow rule would be safer.
* Assuming all protocols use ports the same way.

### Related Documents

* [Azure CLI Command Reference](../azure-cli/azure-cli.md)
* [Bash Syntax Reference](./bash-syntax.md)

---

# Tab-Separated Output

## `--output tsv`

### Symbol or Pattern

```text
--output tsv
```

### Plain-English Meaning

Return values without JSON decoration so they can be captured directly by PowerShell or passed to another command.

### Where It Appears

```powershell
$resourceIds = az resource list --resource-group <RESOURCE_GROUP> --query "[].id" --output tsv
```

### Common Mistakes

* Expecting a table header or JSON property names.
* Passing empty output to a destructive command without checking it first.

---

# Array Projection and Filtering

## Project One Property from Every Result

### Symbol or Pattern

```text
[].id
```

### Plain-English Meaning

Select the `id` property from every object in the result array.

### Where It Appears

Resource inventory, cleanup, and VM-ID collection.

---

## Filter NICs by Subnet Membership

### Symbol or Pattern

```text
[?contains(ipConfigurations[].subnet.id, '/subnets/<CLIENT_SUBNET>')].virtualMachine.id
```

### Plain-English Meaning

Keep NICs whose IP configuration belongs to the named subnet, then return the attached VM resource IDs.

### Breakdown

* `[? ... ]` filters an array.
* `contains(...)` tests whether a value contains the supplied subnet fragment.
* `ipConfigurations[].subnet.id` projects subnet IDs from the NIC IP configurations.
* `.virtualMachine.id` returns the attached VM ID.

### Common Mistakes

* Supplying `--query` without a query expression.
* Filtering by an ambiguous substring.
* Assuming every NIC is attached to a VM.
* Using the returned IDs in `delete` before inspecting the selected VM names.

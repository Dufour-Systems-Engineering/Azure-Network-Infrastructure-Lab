## Section Template Guide

Templates are selected according to the document's purpose, not its repository location. Repository folders classify subject matter. Templates classify documentation type. A single folder may legitimately contain documents created from multiple approved templates.


# 1. Architecture Template

Used for:

```text
architecture/
network/
```

Examples:

* Environment or Resource Overview Documents (VMs, VNets, Subnets, etc)
* VNet Design
* Security Model
* IP Addressing Plan
* Private DNS Design

Template:

# Title

## Overview

Brief description of the system and its role in the environment.

## Purpose

Why this system exists.

## Scope

What is covered and what is excluded.

## Architecture Summary

High-level description of how the system functions.

## Components

List and describe major components.

## Design Decisions

Explain major implementation choices and rationale.

## Security Considerations

Relevant security controls and protections.

## Validation

How functionality was confirmed.

## Lessons Learned

Key takeaways from implementation.

## Related Documents

Links to supporting documentation.

---

# 2. Build Guide Template

Used for:

```text
storage/
deployment/
monitoring/
remote-access/
```

Examples:

* NFS Server Deployment
* WireGuard VPN Gateway
* Prometheus Deployment
* Golden Image Management

Template:

# Title

## Overview

Brief summary of the implementation.

## Purpose

Why the system was deployed.

## Prerequisites

Required resources, permissions, or dependencies.

## Deployment Procedure

Step-by-step deployment process.

## Configuration Procedure

Post-deployment configuration steps.

## Verification

Commands, tests, or checks used to verify success.

## Common Issues

Known pitfalls and troubleshooting notes.

## Lessons Learned

Important observations from implementation.

## Related Documents

Links to supporting documentation.

---

# 3. Runbook Template

Used for:

```text
operations/
```

Examples:

* VM Lifecycle Management
* Auto Shutdown Operations
* Environment Maintenance

Template:

# Title

## Overview

Administrative procedure summary.

## Purpose

Why this operational task exists.

## Business Rationale

Operational impact and benefits.

## Prerequisites

Required access and conditions.

## Procedure

Step-by-step execution instructions.

## Verification

How successful completion is confirmed.

## Rollback Procedure

Recovery steps if the operation fails.

## Common Issues

Known operational problems.

## Lessons Learned

Operational observations.

## Related Documents

Links to supporting documentation.

---

# 4. Troubleshooting Template

Used for:

```text
troubleshooting/
```

Examples:

* WireGuard Routing Issue
* NFS Connectivity Issue
* DNS Migration Issue

Template:

# Incident Title

## Summary

Brief description of the issue.

## Symptoms

Observable behavior and error messages.

## Environment

Affected systems and configuration.

## Root Cause

Underlying cause of the issue.

## Investigation Process

Diagnostic process used.

## Resolution

Corrective action taken.

## Validation

How resolution was confirmed.

## Lessons Learned

Key takeaways and prevention measures.

## Related Documents

Links to supporting documentation.

---

# 5. Validation Template

Used for:

```text
evidence/
```

Examples:

* NFS Validation
* WireGuard Validation
* Monitoring Validation

Template:

# Validation Title

## Objective

What is being validated.

## Environment

Systems involved.

## Test Procedure

Step-by-step validation process.

## Expected Results

Expected behavior.

## Actual Results

Observed behavior.

## Evidence

Screenshots, command output, logs, or exports.

## Conclusion

Final determination.

## Related Documents

Links to supporting documentation.

---

# Screenshot Standard

Every screenshot should follow:

```text
01-description.png
02-description.png
03-description.png
```

Examples:

```text
01-vnet-overview.png
02-subnet-layout.png
03-nsg-rules.png
```

Never:

```text
Screenshot 2026-06-01 101234.png
```

---

# Image Embedding Standard

Same as AD repo:

```markdown
*See Evidence:* [01-vnet-overview.png](../../screenshots/01-vnet-overview.png)
```

or embedded when appropriate.

---

# Naming Standard

Documents:

```text
system-action-purpose.md
```

Examples:

```text
wireguard-vpn-gateway.md
nfs-server-deployment.md
golden-image-management.md
```

Avoid:

```text
azure-notes.md
network-stuff.md
vpn-guide-final-v3.md
```

---

These five templates should cover essentially every document in the Azure repo and keep it consistent with the professionalism of the AD repo while still fitting the **System-First Flexible Depth Structure**.

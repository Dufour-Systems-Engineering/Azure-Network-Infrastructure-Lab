# Azure Network Infrastructure Lab

## Overview

Azure Network Infrastructure Lab is a hands-on Azure infrastructure project focused on private networking, subnet segmentation, remote access, internal DNS, security group design, Linux-based infrastructure services, deployment standardization, operational cost control, and command documentation.

The lab is built around a segmented Azure virtual network that hosts Linux infrastructure systems, a Linux client fleet, a WireGuard remote access gateway, an NFS server, a golden image workflow, and a monitoring/diagnostics host.

The purpose of this repository is to document the design, implementation, validation, troubleshooting, and operational administration of the environment in a professional, repeatable format.

## Project Goals

This project is designed to demonstrate practical infrastructure administration skills across Azure networking, Linux systems, remote access, deployment workflows, command-line operations, and documentation.

Primary goals include:

* Build a segmented Azure virtual network
* Separate systems by subnet and role
* Use private IP addressing for internal communication
* Implement WireGuard-based remote administrative access
* Configure Azure Private DNS for internal name resolution
* Document NSG and ASG usage for traffic control
* Deploy Linux infrastructure services such as NFS
* Configure client-side NFS integration
* Validate NFS exports, permissions, mounts, and write behavior
* Build and validate a reusable golden image workflow
* Support monitoring and diagnostics through a dedicated NetMon host
* Document operational cost-control procedures
* Maintain evidence-backed documentation with screenshots and validation results
* Build a command reference system for Azure CLI, Bash/Linux, PowerShell, and system-specific workflows
* Preserve reusable scripts and documentation templates for future lab expansion

## Environment Summary

The lab is hosted in Azure using a single virtual network:

| Item                | Value                                        |
| ------------------- | -------------------------------------------- |
| Project name        | Azure Network Infrastructure Lab             |
| Resource group      | TestGroup1                                   |
| Primary VNet        | TestVNet1                                    |
| Primary region      | West US                                      |
| VNet address space  | 10.0.0.0/24                                  |
| Remote access model | WireGuard VPN and SSH                        |
| DNS model           | Azure Private DNS linked to TestVNet1        |
| Storage model       | Linux NFS server hosted on TestLinuxServer1  |
| Deployment model    | Golden image and client VM standardization   |
| Operations model    | Manual and scheduled cost-control procedures |
| Command model       | Command Codex documentation and syntax notes |

## Network Layout

`TestVNet1` is divided into dedicated subnets by system role.

| Subnet        |          CIDR | Purpose                          |
| ------------- | ------------: | -------------------------------- |
| TestSubNet1   |   10.0.0.0/28 | Shared infrastructure services   |
| TestSubNet2   |  10.0.0.16/28 | Linux client fleet               |
| DMZ-Subnet    |  10.0.0.32/29 | WireGuard remote access boundary |
| NetMonSubnet1 | 10.0.0.128/29 | Monitoring and diagnostics       |

## Key Systems

| System           | Private IP | Role                               |
| ---------------- | ---------: | ---------------------------------- |
| TestLinuxServer1 |   10.0.0.4 | NFS server / shared infrastructure |
| TestClientVM1    |  10.0.0.21 | Linux client                       |
| TestClientVM2    |  10.0.0.22 | Linux client                       |
| TestClientVM3    |  10.0.0.23 | Linux client                       |
| TestClientVM4    |  10.0.0.24 | Linux client                       |
| TestClientVM5    |  10.0.0.25 | Linux client                       |
| TestClientVM6    |  10.0.0.26 | Linux client                       |
| WireGuardVM1     |  10.0.0.36 | WireGuard VPN gateway              |
| NetMonVM1        | 10.0.0.132 | Monitoring and diagnostics host    |

## Repository Structure

```text
azure-network-infrastructure-lab/
├── CHANGELOG.md
├── README.md
│
├── architecture/
│   ├── environment-overview.md
│   ├── ip-addressing-plan.md
│   ├── logical-topology.md
│   └── security-model.md
│
├── command-codex/
│   ├── README.md
│   ├── azure-cli/
│   │   └── azure-cli.md
│   ├── bash-linux/
│   │   └── bash-linux.md
│   ├── powershell/
│   │   └── powershell.md
│   ├── syntax/
│   │   ├── azure-cli-query-syntax.md
│   │   ├── bash-syntax.md
│   │   └── powershell-syntax.md
│   └── system-specific/
│       ├── cost-control-ops.md
│       ├── golden-image-management.md
│       └── wireguard.md
│
├── deployment/
│   └── golden-image-management.md
│
├── evidence/
│
├── exports/
│
├── governance/
│   ├── README.md
│   ├── document-standards-manual.md
│   ├── publication-quality-gate.md
│   ├── repository-audit-log.md
│   ├── repository-decision-log.md
│   ├── repository-governance.md
│   ├── repository-principles.md
│   ├── repository-style-guide.md
│   └── repository-workflow.md
│
├── monitoring/
│   └── netmonvm1-overview.md
│
├── network/
│   ├── nsg-asg-implementation.md
│   ├── private-dns-implementation.md
│   ├── reverse-dns-migration.md
│   └── vnet-subnet-design.md
│
├── operations/
│   └── cost-control-operations.md
│
├── remote-access/
│   ├── jumpbox-administration-workflow.md
│   └── wireguard-vpn-gateway.md
│
├── screenshots/
│
├── scripts/
│   └── repo-setup/
│       ├── create-admin-command-library-structure.ps1
│       └── rename-reformat-screenshots.ps1
│
├── storage/
│   ├── nfs-client-integration.md
│   ├── nfs-exports-and-permissions.md
│   └── nfs-server-deployment.md
│
├── templates/
│   ├── command-library-template.md
│   ├── section-template-repo.md
│   └── syntax-reference-template.md
│
└── troubleshooting/
    └── nfs-mount-permission-denied.md

Only representative files are shown where appropriate. Screenshot directories contain additional evidence organized by subsystem.
```

## Current Documentation Status

Completed documentation includes:

| Area            | Document                                                   |
| --------------- | ---------------------------------------------------------- |
| Architecture    | `architecture/environment-overview.md`                     |
| Architecture    | `architecture/ip-addressing-plan.md`                       |
| Architecture    | `architecture/logical-topology.md`                         |
| Architecture    | `architecture/security-model.md`                           |
| Command Codex   | `command-codex/README.md`                                  |
| Command Codex   | `command-codex/azure-cli/azure-cli.md`                     |
| Command Codex   | `command-codex/bash-linux/bash-linux.md`                   |
| Command Codex   | `command-codex/powershell/powershell.md`                   |
| Command Codex   | `command-codex/syntax/azure-cli-query-syntax.md`           |
| Command Codex   | `command-codex/syntax/bash-syntax.md`                      |
| Command Codex   | `command-codex/syntax/powershell-syntax.md`                |
| Command Codex   | `command-codex/system-specific/cost-control-ops.md`        |
| Command Codex   | `command-codex/system-specific/golden-image-management.md` |
| Command Codex   | `command-codex/system-specific/wireguard.md`               |
| Deployment      | `deployment/golden-image-management.md`                    |
| Governance      | `governance/README.md`                                     |
| Governance      | `governance/repository-governance.md`                      |
| Governance      | `governance/repository-principles.md`                      |
| Governance      | `governance/repository-style-guide.md`                     |
| Governance      | `governance/document-standards-manual.md`                  |
| Governance      | `governance/repository-workflow.md`                        |
| Governance      | `governance/publication-quality-gate.md`                   |
| Governance      | `governance/repository-decision-log.md`                    |
| Governance      | `governance/repository-audit-log.md`                       |
| Monitoring      | `monitoring/netmonvm1-overview.md`                         |
| Network         | `network/nsg-asg-implementation.md`                        |
| Network         | `network/private-dns-implementation.md`                    |
| Network         | `network/reverse-dns-migration.md`                         |
| Network         | `network/vnet-subnet-design.md`                            |
| Operations      | `operations/cost-control-operations.md`                    |
| Remote Access   | `remote-access/wireguard-vpn-gateway.md`                   |
| Remote Access   | `remote-access/jumpbox-administration-workflow.md`         |
| Storage         | `storage/nfs-client-integration.md`                        |
| Storage         | `storage/nfs-exports-and-permissions.md`                   |
| Storage         | `storage/nfs-server-deployment.md`                         |
| Troubleshooting | `troubleshooting/nfs-mount-permission-denied.md`           |

Phase 1 documentation remains in progress.

Remaining high-priority documentation includes:

* `deployment/batch-client-deployment.md`
* `operations/vm-lifecycle-management.md`

Additional documentation will continue to be published as Phase 1 development progresses, with primary emphasis on batch client deployment and virtual machine lifecycle management.

## Command Codex

The `command-codex/` section documents commands used throughout the Azure Network Infrastructure Lab.

It separates command documentation into reusable reference categories:

* Azure CLI commands
* Bash/Linux commands
* PowerShell commands
* Syntax references
* System-specific command documentation

The Command Codex exists to explain commands used during lab deployment, validation, troubleshooting, administration, and maintenance.

Command documentation includes:

* Command purpose
* Lab context
* Command breakdown
* Common mistakes
* Related syntax references
* Related lab documents

Many commands in this lab were developed through research, documentation review, AI-assisted learning, and iterative validation. The Command Codex preserves those commands in an explainable format so they can be reviewed, reused, and understood instead of treated as one-time copy-paste actions.

## Scripts

The `scripts/` directory stores reusable helper scripts used to support repository setup, documentation maintenance, and administrative workflows.

Current script files include:

| Script                                                          | Purpose                                                            |
| --------------------------------------------------------------- | ------------------------------------------------------------------ |
| `scripts/repo-setup/create-admin-command-library-structure.ps1` | Creates the Command Codex documentation folder and file structure. |
| `scripts/repo-setup/rename-reformat-screenshots.ps1`            | Supports screenshot renaming and formatting consistency.           |

Scripts are kept separate from documentation. Documentation explains the process, while scripts contain reusable automation or helper logic.

## Evidence Standard

Screenshots are stored under the `screenshots/` directory and referenced from documentation files using evidence links.

Example:

```markdown
*See Evidence:* [01-vnet-overview.png](../screenshots/network/vnet-subnet-design/01-vnet-overview.png)
```

Documentation should reference screenshots where they support configuration, validation, or design decisions.

Screenshots follow a numbered naming convention:

```text
01-description.png
02-description.png
03-description.png
```

Existing screenshots are periodically renamed or redacted to keep the evidence set consistent and safe for public review.

## Documentation Standards

This repository uses standardized document templates to maintain consistency across all published documentation.

Current document classes include:

* Architecture Template
* Build Guide Template
* Runbook Template
* Troubleshooting Template
* Validation Template
* Command Library Template
* Syntax Reference Template

Templates are selected according to the **purpose of the document**, not its repository location.

Repository folders organize subject matter while templates define document structure. A single repository folder may therefore contain documents created from multiple approved templates when appropriate.

Operations documents use the Runbook Template.

Command reference documents use the Command Library Template.

Syntax explanation documents use the Syntax Reference Template.

Current template files include:

| Template                                 | Purpose                                           |
| ---------------------------------------- | ------------------------------------------------- |
| `templates/command-library-template.md`  | Standard format for command reference documents.  |
| `templates/section-template-repo.md`     | Standard format for repository documentation.     |
| `templates/syntax-reference-template.md` | Standard format for syntax explanation documents. |

## Repository Governance

This repository is governed by a documentation framework intended to promote consistency, maintainability, and engineering quality.

The Governance framework establishes repository standards, document templates, workflow expectations, publication requirements, and repository-wide design decisions.

All published documentation is expected to conform to the repository Governance framework, ensuring consistency, maintainability, and engineering quality throughout the project.

## Current Implementation Highlights

Current implemented and documented capabilities include:

* Repository governance framework and publication standards
* Publication Quality Gate
* Standardized documentation templates
* Command Codex for Azure CLI, Bash/Linux, PowerShell, and system-specific operations
* Segmented Azure Virtual Network design
* Dedicated subnets for infrastructure, clients, remote access, and monitoring
* WireGuard VPN gateway in a DMZ-style subnet
* WireGuard remote access validation from an external workstation to internal private IPs
* PowerShell `wgssh` quick-connect function for recurring WireGuard gateway administration
* Jumpbox administration workflow
* Azure Private DNS forward and reverse lookup zones
* Private DNS virtual network links
* DNS lookup validation from multiple subnets
* NSG association by subnet role
* ASG-based NFS rule intent
* Current ASG state documentation
* NFS server deployment on `TestLinuxServer1`
* NFS export tree configuration under `/srv/nfs`
* NFS export validation using `exportfs` and `showmount`
* NFS client integration using persistent mount configuration
* NFS export and permissions validation using `/etc/exports`, `exportfs`, `findmnt`, `df`, and elevated write testing
* NFS mount permission troubleshooting with documented root-cause analysis
* Dedicated NetMon monitoring platform overview
* Golden image creation and validation workflow
* VM deployment validation from managed image source
* Azure cost-control operations using power-state inventory, deallocation, scheduled shutdown, and cleanup review
* Evidence-backed portal and terminal screenshots
* Internal name resolution validation

---

## Notes

This lab is designed as an engineering portfolio and learning environment.

The environment prioritizes practical implementation, engineering documentation, governance, cost control, command understanding, and hands-on Azure/Linux infrastructure administration.

Phase 1 documentation remains in active development. Remaining high-priority documentation includes batch client deployment and virtual machine lifecycle management.

Production hardening, compliance controls, and enterprise-scale availability patterns are outside the current scope unless specifically documented in future sections.


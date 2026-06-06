# Azure Network Infrastructure Lab

## Overview

Azure Network Infrastructure Lab is a hands-on Azure infrastructure project focused on private networking, subnet segmentation, remote access, internal DNS, security group design, and Linux-based infrastructure services.

The lab is built around a segmented Azure virtual network that hosts Linux infrastructure systems, a Linux client fleet, a WireGuard remote access gateway, and a monitoring/diagnostics host.

The purpose of this repository is to document the design, implementation, validation, and troubleshooting of the environment in a professional, repeatable format.

## Project Goals

This project is designed to demonstrate practical infrastructure administration skills across Azure networking and Linux systems.

Primary goals include:

* Build a segmented Azure virtual network
* Separate systems by subnet and role
* Use private IP addressing for internal communication
* Implement WireGuard-based remote administrative access
* Configure Azure Private DNS for internal name resolution
* Document NSG and ASG usage for traffic control
* Support Linux infrastructure services such as NFS
* Support monitoring and diagnostics through a dedicated NetMon host
* Maintain evidence-backed documentation with screenshots and validation results

## Environment Summary

The lab is hosted in Azure using a single virtual network:

| Item                | Value                                 |
| ------------------- | ------------------------------------- |
| Project name        | Azure Network Infrastructure Lab      |
| Resource group      | TestGroup1                            |
| Primary VNet        | TestVNet1                             |
| Primary region      | West US                               |
| VNet address space  | 10.0.0.0/24                           |
| Remote access model | WireGuard VPN and SSH                 |
| DNS model           | Azure Private DNS linked to TestVNet1 |

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
├── README.md
├── CHANGELOG.md
│
├── architecture/
│   ├── environment-overview.md
│   ├── logical-topology.md
│   ├── ip-addressing-plan.md
│   └── security-model.md
│
├── network/
│   ├── vnet-subnet-design.md
│   ├── nsg-asg-implementation.md
│   ├── private-dns-implementation.md
│   ├── reverse-dns-migration.md
│   └── network-validation.md
│
├── storage/
├── deployment/
├── remote-access/
├── monitoring/
├── operations/
├── troubleshooting/
├── evidence/
├── screenshots/
├── scripts/
├── exports/
└── templates/
```

## Current Documentation Status

The current push focuses on the architecture and network foundation for the lab.

Completed documentation includes:

| Area         | Document                                |
| ------------ | --------------------------------------- |
| Architecture | `architecture/environment-overview.md`  |
| Architecture | `architecture/logical-topology.md`      |
| Architecture | `architecture/ip-addressing-plan.md`    |
| Architecture | `architecture/security-model.md`        |
| Network      | `network/vnet-subnet-design.md`         |
| Network      | `network/nsg-asg-implementation.md`     |
| Network      | `network/private-dns-implementation.md` |

Additional sections will be expanded as the storage, deployment, remote access, monitoring, operations, troubleshooting, evidence, scripts, and export documentation are completed.

## Evidence Standard

Screenshots are stored under the `screenshots/` directory and referenced from documentation files using evidence links.

Example:

```markdown
*See Evidence:* [01-vnet-overview.png](../screenshots/network/01-vnet-overview.png)
```

Documentation should reference screenshots where they support configuration, validation, or design decisions.

## Documentation Standards

This repository uses standardized document templates to keep formatting consistent.

Current document classes include:

* Architecture Template
* Build Guide Template
* Runbook Template
* Troubleshooting Template
* Validation Template

Architecture and network design documents use the Architecture Template unless a more specific template is required.

## Current Implementation Highlights

Current implemented and documented capabilities include:

* Segmented Azure VNet design
* Dedicated subnets for infrastructure, clients, remote access, and monitoring
* WireGuard VPN gateway in a DMZ-style subnet
* Azure Private DNS forward and reverse lookup zones
* Private DNS virtual network links
* DNS lookup validation from multiple subnets
* NSG association by subnet role
* ASG-based NFS rule intent
* Current ASG state documentation
* Evidence-backed portal screenshots
* Internal name resolution validation

## Notes

This lab is designed as a learning and portfolio environment.

The environment prioritizes practical implementation, clear documentation, cost control, and hands-on understanding of Azure networking and Linux infrastructure services.

Production hardening, compliance controls, and enterprise-scale availability patterns are outside the current scope unless specifically documented in future sections.

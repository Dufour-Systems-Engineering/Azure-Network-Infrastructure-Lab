# Azure Network Infrastructure Lab

## Overview

Azure Network Infrastructure Lab is a hands-on Azure infrastructure project focused on private networking, subnet segmentation, remote access, internal DNS, security group design, Linux-based infrastructure services, deployment standardization, and operational cost control.

The lab is built around a segmented Azure virtual network that hosts Linux infrastructure systems, a Linux client fleet, a WireGuard remote access gateway, an NFS server, a golden image workflow, and a monitoring/diagnostics host.

The purpose of this repository is to document the design, implementation, validation, and troubleshooting of the environment in a professional, repeatable format.

## Project Goals

This project is designed to demonstrate practical infrastructure administration skills across Azure networking, Linux systems, remote access, deployment workflows, and operations.

Primary goals include:

* Build a segmented Azure virtual network
* Separate systems by subnet and role
* Use private IP addressing for internal communication
* Implement WireGuard-based remote administrative access
* Configure Azure Private DNS for internal name resolution
* Document NSG and ASG usage for traffic control
* Deploy Linux infrastructure services such as NFS
* Configure client-side NFS integration
* Build and validate a reusable golden image workflow
* Support monitoring and diagnostics through a dedicated NetMon host
* Document operational cost-control procedures
* Maintain evidence-backed documentation with screenshots and validation results

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
│   └── reverse-dns-migration.md
│
├── storage/
│   ├── nfs-server-deployment.md
│   └── nfs-client-integration.md
│
├── deployment/
│   └── golden-image-management.md
│
├── remote-access/
│   └── wireguard-vpn-gateway.md
│
├── monitoring/
│
├── operations/
│   └── cost-control-operations.md
│
├── troubleshooting/
├── evidence/
├── screenshots/
├── scripts/
├── exports/
└── templates/
```

## Current Documentation Status

Completed documentation includes:

| Area          | Document                                 |
| ------------- | ---------------------------------------- |
| Architecture  | `architecture/environment-overview.md`   |
| Architecture  | `architecture/logical-topology.md`       |
| Architecture  | `architecture/ip-addressing-plan.md`     |
| Architecture  | `architecture/security-model.md`         |
| Network       | `network/vnet-subnet-design.md`          |
| Network       | `network/nsg-asg-implementation.md`      |
| Network       | `network/private-dns-implementation.md`  |
| Network       | `network/reverse-dns-migration.md`       |
| Storage       | `storage/nfs-server-deployment.md`       |
| Storage       | `storage/nfs-client-integration.md`      |
| Deployment    | `deployment/golden-image-management.md`  |
| Remote Access | `remote-access/wireguard-vpn-gateway.md` |
| Operations    | `operations/cost-control-operations.md`  |

Additional sections will be expanded as batch deployment, VM lifecycle management, NFS permissions, jumpbox administration, monitoring, troubleshooting, evidence, scripts, and export documentation are completed.

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

This repository uses standardized document templates to keep formatting consistent.

Current document classes include:

* Architecture Template
* Build Guide Template
* Runbook Template
* Troubleshooting Template
* Validation Template

Architecture and network design documents use the Architecture Template unless a more specific template is required. Storage, deployment, monitoring, and remote access implementation documents use the Build Guide Template unless a more specific template is required. Operations documents use the Runbook Template.

## Current Implementation Highlights

Current implemented and documented capabilities include:

* Segmented Azure VNet design
* Dedicated subnets for infrastructure, clients, remote access, and monitoring
* WireGuard VPN gateway in a DMZ-style subnet
* WireGuard remote access validation from an external workstation to internal private IPs
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
* Client-side NFS validation through active mount, filesystem, directory, write, and automount checks
* Golden image creation and validation workflow
* VM deployment validation from managed image source
* Azure cost-control operations using power-state inventory, deallocation, scheduled shutdown, and cleanup review
* Evidence-backed portal and terminal screenshots
* Internal name resolution validation

## Notes

This lab is designed as a learning and portfolio environment.

The environment prioritizes practical implementation, clear documentation, cost control, and hands-on understanding of Azure networking and Linux infrastructure services.

Production hardening, compliance controls, and enterprise-scale availability patterns are outside the current scope unless specifically documented in future sections.

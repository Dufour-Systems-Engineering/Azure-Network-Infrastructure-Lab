# Environment Overview

## Overview

This project documents the design, deployment, operation, security, monitoring, documentation, and troubleshooting of a cloud-hosted Linux infrastructure environment built in Microsoft Azure.

The environment was developed to gain practical experience with infrastructure administration, network segmentation, centralized storage, remote administration, automation, validation, and operational troubleshooting using real Azure resources.

Rather than focusing on individual technologies in isolation, the environment was designed as a collection of interconnected systems that support one another and operate as a cohesive infrastructure platform.

## Purpose

The purpose of this project is to develop and demonstrate practical infrastructure administration skills through the implementation and operation of a multi-system Linux environment hosted in Azure.

Key focus areas include:

* Azure networking
* Linux administration
* Shared storage
* Remote administration
* Infrastructure deployment
* Operational automation
* Monitoring and diagnostics
* Documentation
* Troubleshooting

## Scope

This repository documents the systems that were successfully deployed, tested, and integrated into the final environment.

Included systems:

* Azure Virtual Network infrastructure
* Network segmentation and security controls
* Linux NFS shared storage
* Standardized Linux client fleet
* Golden image deployment methodology
* WireGuard remote administration platform
* Private DNS services
* NetMonVM1 monitoring and diagnostics host
* Administrative automation and operational procedures

The repository focuses on the final implemented environment and does not attempt to document every experiment, prototype, or abandoned implementation that occurred during development.

## Architecture Summary

The environment consists of multiple Linux virtual machines deployed within a segmented Azure virtual network.

Infrastructure services such as storage, remote administration, monitoring, and automation are separated into dedicated systems to support operational management and troubleshooting. Network security controls are used to regulate communication between systems while maintaining administrative access through a secure WireGuard VPN gateway.

The environment was designed around repeatability, operational consistency, and practical administration rather than maximum scale or complexity.

## Components

### Azure Network Foundation

Provides virtual networking, subnet segmentation, routing, security boundaries, and communication between systems.

### Linux Client Fleet

A group of standardized Linux virtual machines used for administration, testing, validation, and operational activities.

### NFS Shared Storage

Provides centralized storage services for Linux systems within the environment.

### WireGuard Remote Administration

Provides secure administrative access into the Azure environment from external networks.

### NetMonVM1

Provides monitoring, diagnostics, validation, and troubleshooting capabilities for the environment.

### Automation Services

Supports operational tasks, VM lifecycle management, and cost-control procedures.

### Private DNS Services

Provides internal name resolution for resources hosted within the environment.

## Design Decisions

Several architectural decisions were made to improve maintainability, repeatability, and operational realism.

Key decisions include:

* Use of Linux-based infrastructure components
* Segmentation of services into dedicated systems
* Standardized client deployment methods
* Private internal addressing
* Centralized storage architecture
* VPN-based administrative access
* Automation of routine operational tasks
* Documentation-first project methodology

## Security Considerations

Security controls implemented within the environment include:

* Network Security Groups (NSGs)
* Application Security Groups (ASGs)
* Private addressing
* Segmented subnets
* Controlled administrative access paths
* WireGuard VPN authentication
* Principle of least privilege where practical

Security was incorporated throughout the design process rather than added after deployment.

## Validation

The environment was validated through deployment testing, connectivity verification, remote administration testing, storage validation, DNS testing, operational testing, and troubleshooting exercises.

Validation artifacts and supporting evidence are documented throughout this repository.

## Lessons Learned

Building and maintaining the environment reinforced the importance of:

* Planning before deployment
* Standardization
* Documentation
* Repeatable operational procedures
* Network design
* Validation testing
* Root-cause analysis during troubleshooting

These lessons influenced both the final architecture and the documentation standards used throughout this repository.

## Related Documents

<!-- Related documents will be added as system documentation is created. -->

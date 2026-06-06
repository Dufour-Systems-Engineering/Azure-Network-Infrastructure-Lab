# Logical Topology

## Overview

This document provides a high-level view of the relationships between systems within the Azure Linux Infrastructure environment.

The topology illustrates how administrative access, storage services, monitoring services, and client systems interact across multiple segmented subnets.

## Purpose

The purpose of this document is to describe the logical relationships between infrastructure systems and explain how communication occurs within the environment.

## Scope

This document covers:

* Administrative access paths
* Network segmentation
* System relationships
* Storage relationships
* Monitoring relationships
* DNS relationships

This document does not cover:

* Individual NSG rules
* Detailed IP assignments
* Deployment procedures
* Troubleshooting procedures

## Architecture Summary

The environment consists of a segmented Azure virtual network containing dedicated infrastructure, client, remote administration, and monitoring systems.

Administrative access originates from an external workstation and enters the environment through a WireGuard VPN gateway. Once connected, administrative access can be performed across multiple subnets using private addressing.

Shared storage is provided by a centralized NFS server. Monitoring and diagnostics capabilities are provided by a dedicated NetMonVM1 host. Internal name resolution is provided through Azure Private DNS.

## Components

### Administrative Workstation

External management system used to access the Azure environment.

### WireGuardVM1

Provides secure VPN access into the environment and serves as the primary administrative entry point.

### TestSubNet1

Infrastructure subnet containing shared infrastructure services.

### TestSubNet2

Client subnet containing standardized Linux client systems.

### WireGuard Subnet

Dedicated subnet containing the WireGuard VPN gateway.

### NetMon Subnet

Dedicated subnet containing monitoring and diagnostics resources.

### NFS Server

Provides centralized storage services for client systems.

### NetMonVM1

Provides centralized monitoring, diagnostics, validation, and troubleshooting capabilities.

### Linux Client Fleet

Standardized Linux client systems used for administration, testing, validation, and operational activities.

### Azure Private DNS

Provides internal name resolution services for resources hosted within the environment.

## Design Decisions

The environment was designed around subnet segmentation and dedicated service roles.

Administrative access was centralized through a WireGuard VPN gateway rather than direct access to individual systems.

Monitoring functions were centralized through a dedicated NetMonVM1 host.

Shared storage was centralized through an NFS server to support future client workloads.

Several technologies and services were evaluated during development. Only systems that directly supported the final infrastructure design were retained as primary architectural components.

## Security Considerations

Administrative access is restricted through the WireGuard VPN gateway.

Network segmentation is enforced through dedicated subnets and security controls.

Infrastructure services, client systems, monitoring systems, and remote administration services are separated into distinct network segments.

Private addressing and internal DNS services are used for communication within the environment.

## Validation

The logical topology was validated through:

* VPN connectivity testing
* Cross-subnet administrative access testing
* DNS validation
* Storage connectivity validation
* VM deployment validation
* Network connectivity testing

Validation evidence is maintained within the appropriate system documentation.

## Lessons Learned

Network segmentation significantly improved organization and security.

Dedicated infrastructure roles simplified administration and troubleshooting.

Centralized remote administration reduced management complexity.

Documentation and standardization improved repeatability throughout the environment.

## Related Documents

<!-- Related documents will be added as system documentation is created. -->

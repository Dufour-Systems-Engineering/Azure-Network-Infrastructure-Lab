# Security Model

## Overview

This document describes the security model used by the Azure Linux Infrastructure environment.

The environment uses subnet segmentation, private addressing, Network Security Groups, Application Security Groups, WireGuard VPN access, and Azure Private DNS to control administrative access and internal communication between systems.

The security model is designed to support practical infrastructure administration while avoiding direct public exposure of internal Linux systems.

## Purpose

The purpose of this document is to explain how access is controlled within the Azure Linux Infrastructure environment.

This document defines the security boundaries used to separate infrastructure services, client systems, remote access services, monitoring services, and administrative access paths.

## Scope

This document covers the security design for the Azure Linux Infrastructure environment.

Included in scope:

* Subnet-based segmentation
* Network Security Groups
* Application Security Groups
* WireGuard VPN administrative access
* Remote access boundary design
* Private internal communication
* Azure Private DNS security considerations
* Administrative access flow
* Monitoring and diagnostics access boundaries

Excluded from scope:

* Full NSG rule-by-rule documentation
* User account lifecycle management
* Operating system hardening details
* SSH key rotation procedure
* WireGuard key rotation procedure
* Public DNS configuration
* Application-layer authentication
* Production compliance frameworks

## Architecture Summary

The environment is hosted inside `TestVNet1` and separated into dedicated subnets by system role.

Core infrastructure services are placed in `TestSubNet1`. Linux client systems are placed in `TestSubNet2`. Remote administrative ingress is isolated in `DMZ-Subnet`. Monitoring and diagnostics functions are placed in `NetMonSubnet1`.

Administrative access enters the environment through `WireGuardVM1` in `DMZ-Subnet`. After the WireGuard tunnel is established, internal systems are administered over private Azure network paths rather than direct public exposure.

Network Security Groups and Application Security Groups are used to define and organize traffic rules between systems. Azure Private DNS supports internal name resolution without requiring public DNS exposure for internal resources.

## Components

### TestVNet1

`TestVNet1` is the primary Azure virtual network for the environment.

It provides the private network boundary where internal systems communicate using private IP addressing.

### TestSubNet1

`TestSubNet1` contains shared infrastructure services.

The primary system in this subnet is `TestLinuxServer1`, which provides NFS shared storage services to the Linux client fleet.

### TestSubNet2

`TestSubNet2` contains the standardized Linux client fleet.

The client systems are grouped together to support consistent administration, access control, validation, and troubleshooting.

### DMZ-Subnet

`DMZ-Subnet` contains `WireGuardVM1`.

This subnet functions as the remote access boundary for the environment. It separates the public-facing VPN gateway from internal infrastructure, client, and monitoring systems.

### NetMonSubnet1

`NetMonSubnet1` contains `NetMonVM1`.

This subnet separates monitoring and diagnostics functions from the systems being monitored or tested.

### WireGuardVM1

`WireGuardVM1` provides VPN-based administrative access into the Azure environment.

It acts as the primary remote access gateway and administrative entry point. Administrative access flows from the external workstation through the WireGuard tunnel before reaching internal Azure systems.

### Network Security Groups

Network Security Groups are used to control allowed and denied traffic at subnet or NIC boundaries.

They provide traffic filtering for remote access, infrastructure services, client systems, and monitoring systems.

### Application Security Groups

Application Security Groups are used to group systems by role for cleaner security rule design.

This allows security rules to reference logical system groups instead of relying only on individual IP addresses.

### Azure Private DNS

Azure Private DNS provides internal name resolution for systems inside the virtual network.

It supports private administration and troubleshooting without requiring public DNS records for internal systems.

## Design Decisions

The environment uses subnet segmentation to separate systems by function.

Remote access is isolated in `DMZ-Subnet` instead of being placed directly with internal infrastructure or client systems. This keeps the public-facing access point separated from the rest of the environment.

Internal Linux systems are accessed through the WireGuard VPN path rather than direct public exposure.

The client fleet is grouped into `TestSubNet2` to simplify administration, security rule design, and troubleshooting.

Monitoring and diagnostics functions are separated into `NetMonSubnet1` to keep observation and validation tooling logically distinct from the systems being observed.

Network Security Groups are used to enforce traffic boundaries between system groups.

Application Security Groups are used where practical to make security rules easier to manage and understand.

Azure Private DNS is used for internal name resolution so systems can be administered using private network identity instead of relying only on IP addresses.

## Security Considerations

The security model reduces direct exposure by keeping internal systems on private Azure addresses.

Administrative access is centralized through `WireGuardVM1`, which limits the number of systems requiring external-facing access.

`DMZ-Subnet` provides a separated ingress zone for remote administration.

Internal systems are segmented by subnet role:

* Infrastructure services in `TestSubNet1`
* Client systems in `TestSubNet2`
* Remote access services in `DMZ-Subnet`
* Monitoring and diagnostics services in `NetMonSubnet1`

Network Security Groups control traffic between these areas.

Application Security Groups support role-based rule organization for systems such as clients and infrastructure servers.

Azure Private DNS supports private name resolution without exposing internal system names through public DNS.

The environment is designed for a lab and portfolio context, not as a production compliance-certified environment.

## Validation

The security model was validated through remote access testing, cross-subnet administrative access testing, private IP connectivity checks, WireGuard VPN testing, NSG review, and internal name resolution testing.

WireGuard access was validated as the administrative path into the environment.

Communication between the WireGuard gateway and internal systems was verified across the private Azure network.

Private DNS was configured to support internal name resolution for virtual network resources.

## Lessons Learned

Security boundaries are easier to manage when the network is segmented by system role before services are deployed.

A dedicated remote access subnet provides a cleaner administrative ingress model than exposing multiple internal systems directly.

NSG and ASG planning becomes easier when systems are grouped predictably by role and subnet.

Private DNS improves administration and troubleshooting by reducing dependence on manually tracking private IP addresses.

Security documentation should describe the final implemented access model without over-documenting abandoned or experimental paths.

## Related Documents

<!-- Related documents will be added as system documentation is created. -->

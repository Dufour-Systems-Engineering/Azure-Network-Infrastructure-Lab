# IP Addressing Plan

## Overview

This document describes the IP addressing structure used by the Azure Linux Infrastructure environment.

The environment uses a single Azure virtual network divided into dedicated subnets for infrastructure services, client systems, remote access, and monitoring. Each subnet has a defined CIDR range to support segmentation, predictable system placement, and cleaner troubleshooting.

## Purpose

The purpose of this document is to document the IP addressing plan for the Azure Linux Infrastructure environment.

This plan supports predictable administration, subnet-level organization, static private IP assignment, security rule planning, and operational troubleshooting.

## Scope

This document covers the internal Azure IP addressing structure for the Linux infrastructure environment.

Included in scope:

* Azure virtual network
* Subnet CIDR assignments
* Known private IP assignments
* Infrastructure subnet placement
* Client subnet placement
* Remote access subnet placement
* Monitoring subnet placement
* Private DNS considerations

Excluded from scope:

* Public IP addressing
* WireGuard tunnel addressing
* External home network addressing
* Detailed NSG rule definitions
* DNS record-by-record documentation
* Application-level port documentation

## Architecture Summary

The environment is hosted inside `TestVNet1`.

The virtual network is segmented into four primary subnets:

* `TestSubNet1`
* `TestSubNet2`
* `DMZ-Subnet`
* `NetMonSubnet1`

Each subnet supports a specific infrastructure function. Core infrastructure services are separated from client systems, remote access services, and monitoring systems. Static private IP assignments are used for known systems to make documentation, access control, and troubleshooting more predictable.

## Components

### TestVNet1

`TestVNet1` is the primary Azure virtual network for the environment.

It contains the internal Azure infrastructure systems documented in this repository.

### TestSubNet1

`TestSubNet1` is assigned the following CIDR range:

`10.0.0.0/28`

This subnet contains shared infrastructure services.

Known assignment:

| System           | Private IP | Role       |
| ---------------- | ---------: | ---------- |
| TestLinuxServer1 |   10.0.0.4 | NFS server |

### TestSubNet2

`TestSubNet2` is assigned the following CIDR range:

`10.0.0.16/28`

This subnet contains the standardized Linux client fleet.

Known assignments:

| System        | Private IP | Role         |
| ------------- | ---------: | ------------ |
| TestClientVM1 |  10.0.0.21 | Linux client |
| TestClientVM2 |  10.0.0.22 | Linux client |
| TestClientVM3 |  10.0.0.23 | Linux client |
| TestClientVM4 |  10.0.0.24 | Linux client |
| TestClientVM5 |  10.0.0.25 | Linux client |
| TestClientVM6 |  10.0.0.26 | Linux client |

### DMZ-Subnet

`DMZ-Subnet` is assigned the following CIDR range:

`10.0.0.32/29`

This subnet contains the WireGuard VPN gateway and serves as the remote administrative access boundary for the environment.

Known assignment:

| System       | Private IP | Role                  |
| ------------ | ---------: | --------------------- |
| WireGuardVM1 |  10.0.0.36 | WireGuard VPN gateway |

### NetMonSubnet1

`NetMonSubnet1` is assigned the following CIDR range:

`10.0.0.128/29`

This subnet contains the centralized monitoring and diagnostics host.

Known assignment:

| System    | Private IP | Role                            |
| --------- | ---------: | ------------------------------- |
| NetMonVM1 | 10.0.0.132 | Monitoring and diagnostics host |

### Azure Private DNS

Azure Private DNS provides internal name resolution for systems inside the virtual network.

Private DNS supports administration and troubleshooting by allowing internal systems to be referenced by name instead of only by private IP address.

## Design Decisions

The environment uses subnet segmentation to separate systems by operational role.

Infrastructure services, client systems, remote access services, and monitoring systems are placed into dedicated subnets instead of a single flat network. This makes the environment easier to document, administer, secure, and troubleshoot.

Static private IP assignments are used for known systems to provide predictable administrative targets and cleaner documentation.

`DMZ-Subnet` is used for the WireGuard VPN gateway because it functions as the public-facing remote access boundary for the environment.

`NetMonSubnet1` is separated from the infrastructure and client subnets so monitoring and diagnostics functions remain logically distinct from the systems being monitored or tested.

## Security Considerations

The IP addressing plan supports security by separating infrastructure roles across subnet boundaries.

The subnet model supports clearer NSG and ASG rule design because systems are grouped by function:

* Infrastructure services are placed in `TestSubNet1`
* Client systems are placed in `TestSubNet2`
* Remote access services are placed in `DMZ-Subnet`
* Monitoring and diagnostics services are placed in `NetMonSubnet1`

The WireGuard VPN gateway is placed in `DMZ-Subnet` to separate external administrative ingress from internal infrastructure and client systems.

Private IP addressing is used for internal system communication inside the Azure virtual network.

## Validation

The IP addressing plan was validated through Azure network configuration review, VM private IP assignment review, cross-subnet connectivity testing, WireGuard administrative access testing, and monitoring connectivity testing.

Known client VM private IP assignments were standardized in `TestSubNet2`.

NetMonVM1 was validated as the centralized monitoring and diagnostics host in `NetMonSubnet1`.

## Lessons Learned

Static private IP planning should be completed before deploying or reassigning multiple virtual machines.

When IP assignments are changed after deployment, Azure NICs can temporarily hold addresses that block reassignment. A cleaner approach is to create NICs with static private IPs before VM creation or move existing NICs through a temporary unused IP range before assigning final addresses.

Subnet segmentation improves documentation, troubleshooting, and security rule design, but it requires careful tracking of CIDR ranges, subnet placement, and private IP assignments.

## Related Documents

<!-- Related documents will be added as system documentation is created. -->

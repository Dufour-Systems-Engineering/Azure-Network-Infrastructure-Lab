# VNet Subnet Design

## Overview

This document describes the virtual network and subnet design used by the Azure Linux Infrastructure environment.

The environment is built around a single Azure virtual network, `TestVNet1`, with dedicated subnets used to separate infrastructure services, client systems, remote access, and monitoring resources.

The subnet design supports organized system placement, private communication, security boundary planning, cost-conscious service selection, and easier operational troubleshooting.

*See Evidence:* [01-vnet-overview.png](../screenshots/network/01-vnet-overview.png)

*See Evidence:* [02-subnet-layout.png](../screenshots/network/02-subnet-layout.png)

## Purpose

The purpose of this document is to explain how the Azure virtual network is laid out, what subnets exist, what belongs in each subnet, and why the network was designed this way.

This design supports:

* Logical separation of system roles
* Predictable private IP assignment
* Cleaner Network Security Group design
* Easier troubleshooting
* Controlled remote administration
* Monitoring and diagnostics separation
* Clear documentation of network boundaries
* Cost-conscious infrastructure design

## Scope

This document covers the design and final-state layout of `TestVNet1`.

The scope of this document is limited to the VNet address space, subnet segmentation, connected system placement, and design-level decisions that affect VNet isolation, DNS, Bastion, DDoS protection, and subnet-level security boundaries.

This document explains why the VNet and subnets are structured the way they are. It does not provide implementation procedures or detailed configuration for every service that uses or attaches to the network.

Included in this document:

* The purpose of `TestVNet1`
* The VNet address space
* The subnet layout
* The role of each subnet
* Which systems are placed in each subnet
* Why the VNet is segmented by system role
* Why the VNet is currently isolated
* Why no VNet peering is configured
* Why Azure Bastion is not part of the final access model
* Why Azure DDoS Network Protection is not configured
* Which DNS model is visible at the VNet level
* Which NSGs are associated with the subnets at a high level

Excluded from this document:

* Exact NSG inbound and outbound rule tables
* ASG membership and rule implementation
* WireGuard installation steps
* WireGuard client configuration
* Private DNS zone records
* NFS export configuration
* NFS client mount configuration
* VM creation procedures
* Monitoring tool setup
* Bastion deployment steps
* DDoS protection deployment planning
* VNet peering setup steps
* Troubleshooting procedures
* Command-by-command build history

## Architecture Summary

The Azure Linux Infrastructure environment is hosted inside `TestVNet1`.

`TestVNet1` uses the address space `10.0.0.0/24` and is divided into four subnets:

* `TestSubNet1`
* `TestSubNet2`
* `DMZ-Subnet`
* `NetMonSubnet1`

Each subnet is assigned a specific operational role. Infrastructure services are separated from client systems, remote access services, and monitoring systems. This prevents the environment from becoming a flat network and makes access control easier to reason about.

The design uses private IP addressing for internal Azure communication. Public access is limited to the remote access boundary rather than being assigned broadly across internal systems.

The VNet is currently isolated and does not use VNet peering to connect to another Azure virtual network. Azure DDoS Network Protection is not configured because the environment is a small lab with limited public exposure, and the additional Azure service cost is outside the current project scope.

Azure Bastion was used as an earlier remote access method, but it was later removed because of cost and because WireGuard provided a more flexible remote administration model for this lab. The current administrative access design is based on WireGuard and SSH rather than Bastion.

*See Evidence:* [03-connected-devices.png](../screenshots/network/03-connected-devices.png)

## Components

### TestVNet1

`TestVNet1` is the primary Azure virtual network for the environment.

It provides the private network boundary for the Linux infrastructure systems documented in this repository.

Known configuration:

| Item              | Value                      |
| ----------------- | -------------------------- |
| VNet name         | TestVNet1                  |
| Resource group    | TestGroup1                 |
| Region            | West US                    |
| Address space     | 10.0.0.0/24                |
| Subnet count      | 4                          |
| DNS servers       | Azure-provided DNS service |
| Connected devices | 9                          |

### TestSubNet1

`TestSubNet1` is assigned the following CIDR range:

`10.0.0.0/28`

This subnet is used for shared infrastructure services.

Known system placement:

| System / NIC        | Private IP | Purpose                            |
| ------------------- | ---------: | ---------------------------------- |
| testlinuxserver1364 |   10.0.0.4 | NFS server / shared infrastructure |

`TestSubNet1` separates shared infrastructure services from the Linux client fleet and remote access boundary.

### TestSubNet2

`TestSubNet2` is assigned the following CIDR range:

`10.0.0.16/28`

This subnet is used for the standardized Linux client fleet.

Known system placement:

| System / NIC      | Private IP | Purpose      |
| ----------------- | ---------: | ------------ |
| TestClientVM1-nic |  10.0.0.21 | Linux client |
| TestClientVM2-nic |  10.0.0.22 | Linux client |
| TestClientVM3-nic |  10.0.0.23 | Linux client |
| TestClientVM4-nic |  10.0.0.24 | Linux client |
| TestClientVM5-nic |  10.0.0.25 | Linux client |
| TestClientVM6-nic |  10.0.0.26 | Linux client |

`TestSubNet2` groups client systems into a single subnet for consistent administration, validation, and security rule design.

### DMZ-Subnet

`DMZ-Subnet` is assigned the following CIDR range:

`10.0.0.32/29`

This subnet is used for the remote access boundary.

Known system placement:

| System / NIC    | Private IP | Purpose               |
| --------------- | ---------: | --------------------- |
| wireguardvm1997 |  10.0.0.36 | WireGuard VPN gateway |

`DMZ-Subnet` contains the WireGuard VPN gateway and separates the public-facing remote access role from internal infrastructure and client systems.

### NetMonSubnet1

`NetMonSubnet1` is assigned the following CIDR range:

`10.0.0.128/29`

This subnet is used for monitoring and diagnostics.

Known system placement:

| System / NIC  | Private IP | Purpose                         |
| ------------- | ---------: | ------------------------------- |
| NetMonVM1-nic | 10.0.0.132 | Monitoring and diagnostics host |

`NetMonSubnet1` separates monitoring and diagnostic activity from the infrastructure and client subnets.

### Network Security Groups

The subnet design is supported by Network Security Groups assigned to the network environment.

Relevant NSGs include:

| NSG            | Purpose                              |
| -------------- | ------------------------------------ |
| TestNSG1       | Infrastructure subnet security group |
| TestSubNet2NSG | Client subnet security group         |
| WireGuardNSG1  | Remote access subnet security group  |
| NetMonNSG1     | Monitoring subnet security group     |

This document only identifies the NSGs associated with the network design at a high level. Detailed NSG rule documentation belongs in the NSG and ASG implementation document.

*See Evidence:* [04-nsg-inventory.png](../screenshots/network/04-nsg-inventory.png)

### VNet Address Space

The VNet address space defines the parent private network range used by the environment.

`TestVNet1` uses the following address space:

`10.0.0.0/24`

The configured subnets are carved from this address space.

*See Evidence:* [05-vnet-address-space.png](../screenshots/network/05-vnet-address-space.png)

### VNet Peering

VNet peering is not currently configured.

The VNet is intentionally isolated and is not connected to another Azure virtual network at this stage of the lab. There is no current requirement to connect this lab network to another VNet.

*See Evidence:* [08-vnet-peerings.png](../screenshots/network/08-vnet-peerings.png)

### Azure-Provided DNS

The VNet uses Azure-provided DNS at the VNet level.

This supports basic Azure name resolution without requiring custom DNS servers at the VNet configuration level. Private DNS implementation details are documented separately from this VNet/subnet design file.

*See Evidence:* [07-vnet-dns-settings.png](../screenshots/network/07-vnet-dns-settings.png)

### DDoS Protection

Azure DDoS Network Protection is not configured for this environment.

This reflects the lab scope, limited public-facing exposure, and cost-control goals of the project.

*See Evidence:* [09-ddos-protection-status.png](../screenshots/network/09-ddos-protection-status.png)

### Bastion

Azure Bastion is not part of the current final remote administration model.

Bastion was used as an earlier remote access method, but it was removed because of cost and replaced by a WireGuard-based remote administration path.

*See Evidence:* [10-bastion-status.png](../screenshots/network/10-bastion-status.png)

## Design Decisions

The environment uses one primary VNet instead of multiple VNets.

A single-VNet design keeps the lab manageable while still allowing subnet-level segmentation. This supports realistic infrastructure design without adding unnecessary routing, peering, or gateway complexity.

The VNet address space is larger than the current subnet allocations. This leaves room for additional subnets or future systems without redesigning the entire address plan.

Subnets are separated by system role:

* Infrastructure services
* Client systems
* Remote access services
* Monitoring and diagnostics services

This design keeps the environment organized and supports cleaner security rules.

`DMZ-Subnet` is used for the WireGuard VPN gateway because that system functions as the administrative ingress point into the environment.

`NetMonSubnet1` is separated from the client and infrastructure subnets because monitoring and diagnostics should remain logically distinct from the systems being observed or tested.

Client systems are grouped into `TestSubNet2` because they share a common operational role and can be managed as a fleet.

VNet peering is not configured because the environment is currently designed as an isolated lab network. There is no current requirement to connect `TestVNet1` to another VNet, though that may change in a future expansion.

Azure DDoS Network Protection is not configured because the environment has very limited public-facing exposure and does not require paid Azure DDoS protection for the current lab scope. Avoiding this service also supports cost control.

Azure Bastion was removed from the current access model because WireGuard and SSH provide a more flexible and cost-effective remote administration path for this project. Bastion served as an initial access method, but WireGuard became the preferred final model after remote access was stabilized and validated.

The environment favors learning-oriented, VM-hosted, self-managed solutions where practical instead of relying on paid supplemental Azure services. This approach reduces cost while also creating more hands-on experience with deployment, integration, validation, and troubleshooting.

Future browser-based or GUI-based utilities may be added to `NetMonVM1` if needed. That would support browser-based administration or monitoring tools from inside the private network without changing the current VNet and subnet design.

## Security Considerations

The subnet design supports security by separating systems according to function.

Internal systems use private IP addresses and are not designed to be directly exposed to the public internet.

Remote administrative access is centralized through `WireGuardVM1` in `DMZ-Subnet`.

Network Security Groups are associated with the subnet design to control traffic between system groups.

The design supports clearer access control because traffic boundaries can be defined by subnet and system role:

* `TestSubNet1` for infrastructure services
* `TestSubNet2` for client systems
* `DMZ-Subnet` for remote access
* `NetMonSubnet1` for monitoring and diagnostics

No route tables are assigned in the subnet layout shown in the Azure portal. This indicates the environment relies on Azure default virtual network routing for internal subnet communication.

Azure-provided DNS is used at the VNet level.

The absence of VNet peering keeps the environment isolated from other VNets.

The absence of Azure DDoS Network Protection is acceptable for the current lab scope because the environment is not intended to operate as a production internet-facing service.

The removal of Bastion reduces ongoing Azure service cost, while the WireGuard gateway keeps remote administration centralized through a dedicated access boundary.

## Validation

The VNet and subnet design was validated through Azure portal review and connected device verification.

Validation confirmed:

* `TestVNet1` exists in `TestGroup1`
* The VNet address space is `10.0.0.0/24`
* Four subnets are configured
* Subnet CIDR ranges match the documented design
* Connected devices are placed in the expected subnets
* The Linux client fleet is grouped in `TestSubNet2`
* The NFS server is placed in `TestSubNet1`
* WireGuardVM1 is placed in `DMZ-Subnet`
* NetMonVM1 is placed in `NetMonSubnet1`
* Network Security Groups exist for the subnet design
* VNet peering is not configured
* Azure-provided DNS is used at the VNet level
* Azure DDoS Network Protection is not configured
* Azure Bastion is not part of the current final access model

## Lessons Learned

Subnet design should be planned before VM deployment.

Assigning systems to dedicated subnets by role makes the environment easier to document, secure, and troubleshoot.

A single VNet can still support meaningful segmentation when subnet boundaries and NSG rules are used correctly.

Keeping remote access in a dedicated subnet creates a cleaner administrative ingress model than exposing multiple systems directly.

Connected device review is useful for validating whether NICs and private IPs match the intended network design.

Azure-native supplemental services can be useful, but they should be evaluated against cost, lab scope, and learning value. In this environment, replacing Bastion with WireGuard reduced cost while increasing hands-on experience with VPN routing, Linux networking, and remote administration.

Screenshots of omitted or disabled features are still useful when they document intentional design decisions, such as no VNet peering, no Azure DDoS Network Protection, and no current Bastion dependency.

## Related Documents

<!-- Related documents will be added as system documentation is created. -->

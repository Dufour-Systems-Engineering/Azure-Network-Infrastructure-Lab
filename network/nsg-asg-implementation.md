# NSG ASG Implementation

## Overview

This document describes the current Network Security Group and Application Security Group implementation used by the Azure Linux Infrastructure environment.

The environment uses Network Security Groups to control traffic at subnet boundaries and Application Security Groups to support role-based traffic rules between system groups.

The current implementation includes security controls for infrastructure services, client systems, remote access, and monitoring resources.

*See Evidence:* [01-nsg-inventory.png](../screenshots/network/nsg-asg-implementation/01-nsg-inventory.png)

*See Evidence:* [02-asg-inventory.png](../screenshots/network/nsg-asg-implementation/02-asg-inventory.png)

## Purpose

The purpose of this document is to explain how NSGs and ASGs are currently used to control network access within the Azure Linux Infrastructure environment.

This implementation supports:

* Subnet-level traffic control
* Role-based rule organization
* Controlled remote administration
* Restricted NFS access
* Monitoring and diagnostics access
* Separation between infrastructure, client, remote access, and monitoring systems
* Documentation of the current security group state

## Scope

This document covers the current NSG and ASG implementation visible in the Azure Linux Infrastructure environment.

The scope of this document is limited to documenting which NSGs and ASGs exist, how they are associated with the environment, which major rules are currently configured, and how those rules support subnet-level and role-based traffic control.

This document documents the current observed state of the ASGs. It does not describe an intended final ASG state unless that state is already visible in the current configuration.

Included in this document:

* Current NSG inventory
* Current ASG inventory
* Subnet-to-NSG associations
* Current inbound rules for `TestNSG1`
* Current inbound and outbound rules for `TestSubNet2NSG`
* Current inbound rules for `WireGuardNSG1`
* Current inbound and outbound rules for `NetMonNSG1`
* Current `ASG-NFS-SERVER` membership
* Current observed state of `ASG-CLIENTS`
* High-level purpose of current NSG and ASG rules

Excluded from this document:

* Full Azure firewall implementation
* Azure Firewall Manager configuration
* Route table implementation
* VM operating system firewall configuration
* WireGuard installation steps
* WireGuard client configuration
* NFS server export configuration
* NFS client mount configuration
* Private DNS zone records
* Effective security rule screenshots not currently captured
* Command-by-command NSG creation history
* Troubleshooting procedures

## Architecture Summary

The Azure Linux Infrastructure environment uses NSGs to enforce traffic boundaries between subnets and system roles.

The current subnet-level NSG model includes:

* `TestNSG1` for the infrastructure subnet
* `TestSubNet2NSG` for the client subnet
* `WireGuardNSG1` for the remote access subnet
* `NetMonNSG1` for the monitoring subnet

The environment also includes ASGs intended to support role-based security rules:

* `ASG-NFS-SERVER`
* `ASG-CLIENTS`

Current evidence shows that `ASG-NFS-SERVER` is associated with one network interface in `TestVNet1`. Current evidence also shows that `ASG-CLIENTS` exists but currently has zero associated network interfaces in the ASG inventory view.

Because of that current state, this document treats `ASG-CLIENTS` as an existing ASG referenced by security rules, but it does not claim that client NICs are currently attached to it.

*See Evidence:* [03-subnet-nsg-associations.png](../screenshots/network/nsg-asg-implementation/03-subnet-nsg-associations.png)

## Components

### Network Security Groups

Network Security Groups provide traffic filtering for the Azure Linux Infrastructure environment.

Relevant current NSGs include:

| NSG              | Current role                         |
| ---------------- | ------------------------------------ |
| `TestNSG1`       | Infrastructure subnet security group |
| `TestSubNet2NSG` | Client subnet security group         |
| `WireGuardNSG1`  | Remote access subnet security group  |
| `NetMonNSG1`     | Monitoring subnet security group     |

The NSG inventory also shows other NSGs in the resource group, but this document focuses on the NSGs associated with the current Linux infrastructure network design.

### Application Security Groups

Application Security Groups provide logical grouping for network rule sources and destinations.

Current ASGs include:

| ASG              | Current observed state                                                        |
| ---------------- | ----------------------------------------------------------------------------- |
| `ASG-NFS-SERVER` | Exists and shows one associated network interface                             |
| `ASG-CLIENTS`    | Exists and shows zero associated network interfaces in the ASG inventory view |

`ASG-NFS-SERVER` is actively associated with the NFS server NIC.

`ASG-CLIENTS` exists and is referenced by NSG rules, but the current ASG inventory view shows zero network interfaces associated with it. This document does not claim active client NIC membership unless additional evidence later confirms it.

### Subnet NSG Associations

The subnet layout shows NSG associations for the VNet subnets.

Current subnet-to-NSG associations include:

| Subnet          | NSG association  |
| --------------- | ---------------- |
| `TestSubNet1`   | `TestNSG1`       |
| `TestSubNet2`   | `TestSubNet2NSG` |
| `DMZ-Subnet`    | `WireGuardNSG1`  |
| `NetMonSubnet1` | `NetMonNSG1`     |

These associations align security controls with the role of each subnet.

### TestNSG1

`TestNSG1` is associated with the infrastructure subnet.

Current visible inbound rules include:

| Priority | Rule purpose                                 | Port | Protocol | Source              | Destination      | Action |
| -------: | -------------------------------------------- | ---: | -------- | ------------------- | ---------------- | ------ |
|      100 | Allow SSH from Azure Cloud West US           |   22 | TCP      | `AzureCloud.westus` | `10.0.0.4`       | Allow  |
|     1001 | Allow NFS traffic from clients to NFS server | 2049 | TCP      | `ASG-CLIENTS`       | `ASG-NFS-SERVER` | Allow  |

The NFS rule uses ASGs to describe source and destination roles rather than only using raw IP addresses.

*See Evidence:* [04-testnsg1-inbound-rules.png](../screenshots/network/nsg-asg-implementation/04-testnsg1-inbound-rules.png)

### TestSubNet2NSG

`TestSubNet2NSG` is associated with the client subnet.

Current visible inbound rules include:

| Priority | Rule purpose                         | Port | Protocol | Source           | Destination | Action |
| -------: | ------------------------------------ | ---: | -------- | ---------------- | ----------- | ------ |
|     1000 | Allow SSH from VNet                  |   22 | TCP      | `VirtualNetwork` | Any         | Allow  |
|     1001 | Allow HTTP from server subnet        |   80 | TCP      | `10.0.0.0/28`    | Any         | Allow  |
|     1010 | Allow HTTP from clients              |   80 | TCP      | `10.0.0.0/28`    | Any         | Allow  |
|     1020 | Deny ASG client traffic to port 8080 | 8080 | Any      | `ASG-CLIENTS`    | Any         | Deny   |

The inbound rules allow selected internal access and include a deny rule that references `ASG-CLIENTS`.

*See Evidence:* [05-testsubnet2-inbound-rules.png](../screenshots/network/nsg-asg-implementation/05-testsubnet2-inbound-rules.png)

Current visible outbound rules include:

| Priority | Rule purpose                       | Port | Protocol | Source        | Destination      | Action |
| -------: | ---------------------------------- | ---: | -------- | ------------- | ---------------- | ------ |
|     1030 | Allow client-to-server NFS traffic | 2049 | TCP      | `ASG-CLIENTS` | `ASG-NFS-SERVER` | Allow  |

This outbound rule shows role-based traffic intent from the client ASG toward the NFS server ASG.

Because the current ASG inventory shows `ASG-CLIENTS` with zero associated network interfaces, the rule is documented as currently configured rule intent, not proof of active client NIC membership.

*See Evidence:* [06-testsubnet2-outbound-rules.png](../screenshots/network/nsg-asg-implementation/06-testsubnet2-outbound-rules.png)

### WireGuardNSG1

`WireGuardNSG1` is associated with the remote access subnet.

Current visible inbound rules include:

| Priority | Rule purpose                           | Port | Protocol | Source        | Destination | Action |
| -------: | -------------------------------------- | ---: | -------- | ------------- | ----------- | ------ |
|      100 | Allow SSH from administrator public IP |   22 | TCP      | `76.50.0.197` | Any         | Allow  |

This rule limits SSH access to the WireGuard subnet from a specific administrator public IP address.

The current screenshot evidence shows the SSH access rule. It does not show a visible UDP 51820 rule in the current captured view.

*See Evidence:* [07-wireguard-inbound-rules.png](../screenshots/network/nsg-asg-implementation/07-wireguard-inbound-rules.png)

### NetMonNSG1

`NetMonNSG1` is associated with the monitoring subnet.

Current visible inbound rules include:

| Priority | Rule purpose                   | Port | Protocol | Source           | Destination | Action |
| -------: | ------------------------------ | ---: | -------- | ---------------- | ----------- | ------ |
|      100 | Allow SSH from VNet            |   22 | TCP      | `VirtualNetwork` | Any         | Allow  |
|      110 | Allow ICMP from VNet           |  Any | ICMP     | `VirtualNetwork` | Any         | Allow  |
|      120 | Allow iperf3 from VNet         | 5201 | TCP      | `VirtualNetwork` | Any         | Allow  |
|      130 | Allow Grafana from VNet        | 3000 | TCP      | `VirtualNetwork` | Any         | Allow  |
|      140 | Allow RDP from VNet/admin path | 3389 | TCP      | `VirtualNetwork` | Any         | Allow  |
|      145 | Allow VNC from VNet            | 5900 | TCP      | `VirtualNetwork` | Any         | Allow  |
|      150 | Allow noVNC from VNet          | 6080 | TCP      | `VirtualNetwork` | Any         | Allow  |

These rules support monitoring, diagnostics, remote administration, and potential GUI/browser-based access from inside the private network.

*See Evidence:* [08-netmon-inbound-rules.png](../screenshots/network/nsg-asg-implementation/08-netmon-inbound-rules.png)

Current visible outbound rules for `NetMonNSG1` are the default outbound rules:

| Priority | Rule purpose            | Port | Protocol | Source           | Destination      | Action |
| -------: | ----------------------- | ---- | -------- | ---------------- | ---------------- | ------ |
|    65000 | Allow VNet outbound     | Any  | Any      | `VirtualNetwork` | `VirtualNetwork` | Allow  |
|    65001 | Allow Internet outbound | Any  | Any      | Any              | Internet         | Allow  |
|    65500 | Deny all outbound       | Any  | Any      | Any              | Any              | Deny   |

This allows NetMonVM1 to communicate within the VNet and reach the internet through default outbound behavior, unless additional restrictions are later added.

*See Evidence:* [09-netmon-outbound-rules.png](../screenshots/network/nsg-asg-implementation/09-netmon-outbound-rules.png)

### ASG-NFS-SERVER Membership

`ASG-NFS-SERVER` currently shows one associated network interface.

The associated private IP is:

`10.0.0.4`

The associated network interface is:

`testlinuxserver1364`

The NIC is attached to:

`TestLinuxServer1`

This confirms that the NFS server role is actively represented by `ASG-NFS-SERVER`.

*See Evidence:* [10-nfs-nic-asg-membership.png](../screenshots/network/nsg-asg-implementation/10-nfs-nic-asg-membership.png)

## Design Decisions

The environment uses separate NSGs for each major subnet role.

This keeps the rule structure aligned with the network design:

* Infrastructure services use `TestNSG1`
* Client systems use `TestSubNet2NSG`
* Remote access uses `WireGuardNSG1`
* Monitoring and diagnostics use `NetMonNSG1`

ASGs are used to express role-based traffic rules, especially for NFS access between client systems and the NFS server.

The NFS-related rules reference `ASG-CLIENTS` and `ASG-NFS-SERVER`, which makes the rule intent clearer than using only raw IP addresses.

The current ASG state is not fully symmetrical. `ASG-NFS-SERVER` is actively associated with one NIC, while `ASG-CLIENTS` currently shows zero NICs in the ASG inventory. This is documented as the current observed state rather than treated as a final or ideal ASG configuration.

WireGuard access is controlled through `WireGuardNSG1`, which keeps remote administration rules separated from internal infrastructure and client subnet rules.

NetMon access is controlled through `NetMonNSG1`, which keeps monitoring and diagnostics access separate from the systems being monitored or tested.

## Security Considerations

The NSG design supports subnet-level access control by separating security rules across infrastructure, client, remote access, and monitoring subnets.

The NFS server is protected by rules that target the server role through `ASG-NFS-SERVER`.

Client-to-NFS traffic is represented through ASG-based rules, but the current ASG inventory shows that `ASG-CLIENTS` has zero associated NICs. This should be reviewed before relying on `ASG-CLIENTS` for active enforcement.

The WireGuard subnet has a visible SSH rule restricted to a specific administrator public IP address.

The monitoring subnet allows selected diagnostic and remote access ports from the virtual network. This supports internal lab administration and diagnostics, but these ports should remain limited to private network access.

Default Azure inbound deny rules remain present across the NSGs. These default deny rules help block traffic that is not explicitly allowed by higher-priority custom rules.

## Validation

The NSG and ASG implementation was validated through Azure portal review of NSG inventories, ASG inventories, subnet associations, rule tables, and ASG membership.

Validation confirmed:

* Relevant NSGs exist in `TestGroup1`
* ASGs exist for NFS server and client grouping
* `ASG-NFS-SERVER` currently has one associated network interface
* `ASG-CLIENTS` currently shows zero associated network interfaces
* `TestSubNet1` is associated with `TestNSG1`
* `TestSubNet2` is associated with `TestSubNet2NSG`
* `DMZ-Subnet` is associated with `WireGuardNSG1`
* `NetMonSubnet1` is associated with `NetMonNSG1`
* NFS-related rules reference `ASG-CLIENTS` and `ASG-NFS-SERVER`
* WireGuard inbound SSH access is restricted to a specific administrator public IP
* NetMon inbound rules allow selected management and diagnostic traffic from the VNet
* NetMon outbound rules currently rely on Azure default outbound behavior

## Lessons Learned

NSGs are easier to understand when they are aligned with subnet roles.

ASGs make rule intent clearer by describing traffic in terms of system roles instead of only raw IP addresses.

ASG inventory should be checked before assuming that an ASG-based rule is actively applying to a group of systems.

A configured rule that references an ASG does not prove that any NICs are currently members of that ASG.

Screenshots of both rule configuration and ASG membership are necessary to accurately document the current state.

Separating WireGuard, client, infrastructure, and monitoring rules into different NSGs improves readability and troubleshooting.

## Related Documents

<!-- Related documents will be added as system documentation is created. -->

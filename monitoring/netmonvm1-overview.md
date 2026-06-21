# NetMonVM1 Overview

## Overview

NetMonVM1 is the dedicated monitoring virtual machine for the Azure Network Infrastructure Lab. It serves as the central platform for network validation, infrastructure diagnostics, and operational monitoring throughout the environment.

Rather than hosting production workloads, NetMonVM1 functions as the lab's network operations workstation. It provides a consistent administrative platform for validating network services, troubleshooting infrastructure issues, and supporting future monitoring capabilities without placing administrative tooling directly on workload systems.

## Purpose

The purpose of NetMonVM1 is to centralize network monitoring and infrastructure validation within the Azure Network Infrastructure Lab.

Primary responsibilities include:

* Validating connectivity between Azure resources
* Verifying Private DNS functionality
* Supporting infrastructure troubleshooting
* Hosting centralized logging services
* Serving as the primary platform for future monitoring and diagnostics

## Scope

This document provides a high-level overview of NetMonVM1, including its role within the Azure Network Infrastructure Lab, network placement, security design, and integration with other infrastructure components.

Detailed monitoring procedures, logging configuration, and operational workflows are documented separately.

## Architecture Summary

NetMonVM1 is deployed as a dedicated Ubuntu Server virtual machine within the monitoring segment of the Azure virtual network.

The virtual machine was deployed from the standardized **Golden-Base-1.2** managed image and operates entirely within the private network. Administrative access is performed through the WireGuard VPN gateway rather than direct public exposure.

The monitoring platform provides a centralized location for validating infrastructure services while maintaining logical separation from production workloads.

## Components

### NetMonVM1

| Component             | Description                   |
| --------------------- | ----------------------------- |
| Operating System      | Ubuntu Server 22.04 LTS       |
| VM Size               | Standard B2s                  |
| Source Image          | Golden-Base-1.2 Managed Image |
| Network Connectivity  | Private Virtual Network       |
| Administrative Access | SSH via WireGuard             |

*See Evidence:* [01-netmonvm1-resource-overview.png](../screenshots/monitoring/netmonvm1-overview/01-netmonvm1-resource-overview.png)

*See Evidence:* [02-netmonvm1-network-settings.png](../screenshots/monitoring/netmonvm1-overview/02-netmonvm1-network-settings.png)

### Network Security

NetMonVM1 is protected by **NetMonNSG1**, a dedicated Network Security Group that permits only the services required for monitoring and administrative activities.

Configured rules support:

* SSH administration
* ICMP testing
* Network diagnostics
* Monitoring platform services
* Remote administration

Outbound communication allows NetMonVM1 to validate connectivity with internal infrastructure resources while remaining isolated from unnecessary external exposure.

*See Evidence:* [08-netmon-inbound-rules.png](../screenshots/network/nsg-asg-implementation/08-netmon-inbound-rules.png)

*See Evidence:* [09-netmon-outbound-rules.png](../screenshots/network/nsg-asg-implementation/09-netmon-outbound-rules.png)

### Infrastructure Integration

NetMonVM1 is integrated with several core services throughout the Azure Network Infrastructure Lab.

These include:

* Azure Virtual Network
* Private DNS
* Network Security Groups
* WireGuard VPN Gateway
* NFS storage infrastructure
* Linux client virtual machines

Private DNS validation confirms successful name resolution of multiple internal systems from the monitoring platform.

*See Evidence:* [10-dns-lookup-from-netmonvm.png](../screenshots/network/private-dns-implementation/10-dns-lookup-from-netmonvm.png)

## Design Decisions

### Dedicated Monitoring Platform

A dedicated monitoring virtual machine was implemented to separate operational tooling from workload systems. This approach provides a centralized administrative platform while reducing unnecessary software and configuration on production infrastructure.

### Standardized Deployment

NetMonVM1 was deployed from the Golden-Base-1.2 managed image to maintain consistency with the remainder of the environment and simplify future deployments.

### Private Administration

The monitoring platform operates entirely within the Azure virtual network. Administrative access is performed through the WireGuard VPN gateway, eliminating the need for direct public management access.

### Operational Command Center

NetMonVM1 was intentionally designed to function as the operational command center for the lab, providing a centralized location for infrastructure validation, diagnostics, logging, and future monitoring capabilities.

## Security Considerations

NetMonVM1 incorporates several security controls consistent with the broader lab architecture.

These include:

* Private IP addressing
* Dedicated monitoring subnet
* Dedicated Network Security Group
* SSH-based administration
* Remote access through the WireGuard VPN gateway
* Automatic daily shutdown to reduce unnecessary exposure and Azure compute costs

## Validation

NetMonVM1 was validated by confirming:

* Successful deployment from the Golden-Base-1.2 managed image
* Correct placement within the monitoring subnet
* Proper Network Security Group association
* Successful resolution of internal systems through Private DNS
* Connectivity to infrastructure resources throughout the virtual network

## Lessons Learned

Implementing a dedicated monitoring platform simplified infrastructure validation by providing a centralized location for administrative and diagnostic activities.

Separating monitoring responsibilities from workload systems also established a scalable foundation for future capabilities including centralized logging, network diagnostics, and additional monitoring services without increasing operational complexity on production resources.

## Related Documents

* `deployment/golden-image-management.md`
* `network/nsg-asg-implementation.md`
* `network/private-dns-implementation.md`
* `remote-access/wireguard-vpn-gateway.md`
* `operations/cost-control-operations.md`
* `monitoring/centralized-logging-with-rsyslog.md` *(Planned)*
* `monitoring/network-monitoring-workflows.md` *(Planned)*

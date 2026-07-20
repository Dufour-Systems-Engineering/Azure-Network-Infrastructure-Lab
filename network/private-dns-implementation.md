# Private DNS Implementation

## Overview

This document describes the current Private DNS implementation used by the Azure Linux Infrastructure environment.

The environment uses Azure Private DNS zones to support internal name resolution for systems inside `TestVNet1`. The implementation includes a forward lookup zone for hostname-to-IP resolution and a reverse lookup zone for IP-to-hostname mapping.

The Private DNS configuration supports easier administration, validation, troubleshooting, and documentation by allowing lab systems to be referenced by internal names instead of relying only on private IP addresses.

*See Evidence:* [01-forward-dns-recordsets.png](../screenshots/network/private-dns-implementation/01-forward-dns-recordsets.png)

*See Evidence:* [02-reverse-dns-recordsets.png](../screenshots/network/private-dns-implementation/02-reverse-dns-recordsets.png)

## Purpose

The purpose of this document is to explain how Private DNS is implemented in the Azure Linux Infrastructure environment.

This implementation supports:

* Internal hostname resolution
* Reverse DNS lookup support
* Easier system administration
* Easier troubleshooting
* Validation of private IP assignments
* Cleaner references to infrastructure systems
* VNet-linked DNS behavior
* Reduced dependence on manually tracking private IP addresses

## Scope

This document covers the current Azure Private DNS implementation used by the Azure Linux Infrastructure environment.

The scope of this document is limited to the Private DNS zones, recordsets, virtual network links, VNet DNS settings, and DNS resolution validation currently visible in the lab.

Included in this document:

* Forward Private DNS zone
* Reverse Private DNS zone
* Forward DNS recordsets
* Reverse DNS PTR recordsets
* Virtual network links
* Auto-registration status
* VNet DNS server setting
* DNS lookup validation from `WireGuardVM1`
* DNS lookup validation from `TestClientVM1`
* DNS lookup validation from `NetMonVM1`
* IAM and tagging evidence for the DNS zones

Excluded from this document:

* Public DNS configuration
* External domain registration
* Azure DNS Private Resolver deployment
* Custom DNS server deployment
* Linux DNS server configuration
* DNS forwarding rulesets
* Conditional forwarding configuration
* Full DNS troubleshooting procedures
* DNS automation scripts
* Command-by-command DNS creation history

## Architecture Summary

The environment uses Azure Private DNS zones linked to `TestVNet1`.

The current DNS design includes two Private DNS zones:

| Zone                  | Purpose                                                    |
| --------------------- | ---------------------------------------------------------- |
| `vnet-dns.lab`        | Forward lookup zone for hostname-to-private-IP records     |
| `0.0.10.in-addr.arpa` | Reverse lookup zone for private-IP-to-hostname PTR records |

`TestVNet1` uses Azure-provided DNS at the VNet level. The private zones are linked to the VNet so systems inside the network can resolve internal names using Azure DNS behavior.

The forward lookup zone, `vnet-dns.lab`, is linked to `TestVNet1` with auto-registration enabled.

The reverse lookup zone, `0.0.10.in-addr.arpa`, is linked to `TestVNet1` with auto-registration disabled. Reverse PTR records are maintained as explicit recordsets.

*See Evidence:* [05-vnet-dns-private-zone-links.png](../screenshots/network/private-dns-implementation/05-vnet-dns-private-zone-links.png)

## Components

### TestVNet1 DNS Settings

`TestVNet1` uses Azure-provided DNS service.

This allows Azure VMs in the VNet to use Azure DNS behavior without requiring a custom DNS server at the VNet level.

*See Evidence:* [06-vnet-dns-server-settings.png](../screenshots/network/private-dns-implementation/06-vnet-dns-server-settings.png)

### Forward Private DNS Zone

The forward Private DNS zone is:

`vnet-dns.lab`

This zone contains A records for internal systems in the environment.

Current visible forward records include:

| Record name        | Type |   Private IP |
| ------------------ | ---- | -----------: |
| `netmonvm1`        | A    | `10.0.0.132` |
| `testclientvm1`    | A    |  `10.0.0.21` |
| `testclientvm2`    | A    |  `10.0.0.22` |
| `testclientvm3`    | A    |  `10.0.0.24` |
| `testclientvm5`    | A    |  `10.0.0.25` |
| `testclientvm6`    | A    |  `10.0.0.26` |
| `testlinuxserver1` | A    |   `10.0.0.4` |
| `wireguardvm1`     | A    |  `10.0.0.36` |

The visible forward recordset evidence should be reviewed before treating the forward zone as a complete final inventory. The screenshot shows the current records visible at the time of capture.

*See Evidence:* [01-forward-dns-recordsets.png](../screenshots/network/private-dns-implementation/01-forward-dns-recordsets.png)

### Reverse Private DNS Zone

The reverse Private DNS zone is:

`0.0.10.in-addr.arpa`

This zone contains PTR records for private IP address reverse lookup.

Current visible reverse records include:

| Record name | Type | Value              |
| ----------: | ---- | ------------------ |
|         `4` | PTR  | `TestLinuxServer1` |
|        `21` | PTR  | `TestClientVM1`    |
|        `22` | PTR  | `TestClientVM2`    |
|        `23` | PTR  | `TestClientVM3`    |
|        `24` | PTR  | `TestClientVM4`    |
|        `25` | PTR  | `TestClientVM5`    |
|        `26` | PTR  | `TestClientVM6`    |
|        `36` | PTR  | `WireGuardVM1`     |
|       `132` | PTR  | `NetMonVM1`        |

These records map the final octet of each `10.0.0.x` address to the corresponding internal system name.

*See Evidence:* [02-reverse-dns-recordsets.png](../screenshots/network/private-dns-implementation/02-reverse-dns-recordsets.png)

### Forward Zone VNet Link

The forward zone `vnet-dns.lab` is linked to `TestVNet1`.

Current link configuration:

| Item                 | Value           |
| -------------------- | --------------- |
| Link name            | `vnet-dns-link` |
| Link status          | Completed       |
| Virtual network      | `TestVNet1`     |
| Auto-registration    | Enabled         |
| Fallback to Internet | Disabled        |

Auto-registration is enabled for the forward lookup zone so VM names can be registered into the zone through the VNet link behavior.

*See Evidence:* [03-forward-zone-vnet-link.png](../screenshots/network/private-dns-implementation/03-forward-zone-vnet-link.png)

### Reverse Zone VNet Link

The reverse zone `0.0.10.in-addr.arpa` is linked to `TestVNet1`.

Current link configuration:

| Item                 | Value               |
| -------------------- | ------------------- |
| Link name            | `reverse-vnet-link` |
| Link status          | Completed           |
| Virtual network      | `TestVNet1`         |
| Auto-registration    | Disabled            |
| Fallback to Internet | Disabled            |

Auto-registration is disabled for the reverse zone, so reverse PTR records are handled as explicit DNS records.

*See Evidence:* [04-reverse-zone-vnet-link.png](../screenshots/network/private-dns-implementation/04-reverse-zone-vnet-link.png)

### Connected Devices Reference

The connected devices view for `TestVNet1` provides a reference for matching DNS records to actual NIC private IP assignments.

Visible connected devices include:

| Device / NIC          |   Private IP | Subnet          |
| --------------------- | -----------: | --------------- |
| `testlinuxserver1364` |   `10.0.0.4` | `TestSubNet1`   |
| `TestClientVM1-nic`   |  `10.0.0.21` | `TestSubNet2`   |
| `TestClientVM2-nic`   |  `10.0.0.22` | `TestSubNet2`   |
| `TestClientVM3-nic`   |  `10.0.0.23` | `TestSubNet2`   |
| `TestClientVM4-nic`   |  `10.0.0.24` | `TestSubNet2`   |
| `TestClientVM5-nic`   |  `10.0.0.25` | `TestSubNet2`   |
| `TestClientVM6-nic`   |  `10.0.0.26` | `TestSubNet2`   |
| `wireguardvm1997`     |  `10.0.0.36` | `DMZ-Subnet`    |
| `NetMonVM1-nic`       | `10.0.0.132` | `NetMonSubnet1` |

This reference is useful for comparing DNS records against actual Azure network interface assignments.

*See Evidence:* [07-vnet-connected-devices.png](../screenshots/network/private-dns-implementation/07-vnet-connected-devices.png)

### IAM Evidence

Access control evidence was captured for both Private DNS zones.

The IAM screenshots show inherited role assignments for the current administrative account.

*See Evidence:* [11-forward-zone-iam.png](../screenshots/network/private-dns-implementation/11-forward-zone-iam.png)

*See Evidence:* [12-reverse-zone-iam.png](../screenshots/network/private-dns-implementation/12-reverse-zone-iam.png)

### Tags

Both Private DNS zones use project tags to identify their environment, owner, project, purpose, and region.

*See Evidence:* [13-forward-zone-tags.png](../screenshots/network/private-dns-implementation/13-forward-zone-tags.png)

*See Evidence:* [14-reverse-zone-tags.png](../screenshots/network/private-dns-implementation/14-reverse-zone-tags.png)

## Design Decisions

The environment uses Azure Private DNS instead of a self-hosted DNS server.

This keeps DNS management integrated with Azure while still supporting private internal name resolution for lab systems.

A forward lookup zone is used for hostname-to-IP resolution.

A reverse lookup zone is used for IP-to-hostname mapping. This supports troubleshooting workflows where IP addresses need to be mapped back to system names.

The forward zone uses auto-registration because it is linked to `TestVNet1` and supports automatic registration behavior for VM names.

The reverse zone does not use auto-registration. PTR records are explicitly maintained so reverse lookup behavior can be controlled and documented.

Fallback to Internet is disabled for the Private DNS zone links. This keeps private DNS resolution behavior scoped to the private zones and avoids relying on fallback behavior for this lab design.

The VNet continues to use Azure-provided DNS service rather than custom DNS servers. This reduces complexity and avoids the need to deploy and maintain a dedicated DNS server VM.

Private DNS records are documented alongside connected device evidence so that DNS entries can be compared against actual private IP assignments.

## Security Considerations

Private DNS reduces reliance on public DNS for internal system names.

The internal records are scoped to the Azure private DNS zones and VNet links rather than being exposed as public DNS records.

The DNS zones are linked to `TestVNet1`, limiting their intended use to the lab virtual network context.

Fallback to Internet is disabled on the private zone links shown in the evidence.

The implementation avoids deploying a separate custom DNS server, which reduces the number of systems that would require hardening, patching, and firewall management.

IAM evidence shows administrative access is inherited from higher-level Azure scopes. This is acceptable for the lab environment, but a production environment would normally use tighter role assignments and least-privilege access.

## Validation

Private DNS functionality was validated from multiple systems inside the Azure environment.

Validation was performed from:

* `WireGuardVM1`
* `TestClientVM1`
* `NetMonVM1`

DNS lookup testing confirmed that internal names resolved to expected private IP addresses.

From `WireGuardVM1`, lookups resolved:

| Query              |       Result |
| ------------------ | -----------: |
| `TestLinuxServer1` |   `10.0.0.4` |
| `TestClientVM1`    |  `10.0.0.21` |
| `NetMonVM1`        | `10.0.0.132` |

*See Evidence:* [08-dns-lookup-from-wireguardvm.png](../screenshots/network/private-dns-implementation/08-dns-lookup-from-wireguardvm.png)

From `TestClientVM1`, lookups resolved:

| Query              |       Result |
| ------------------ | -----------: |
| `TestLinuxServer1` |   `10.0.0.4` |
| `NetMonVM1`        | `10.0.0.132` |
| `TestClientVM1`    |  `10.0.0.21` |

*See Evidence:* [09-dns-lookup-from-clientvm.png](../screenshots/network/private-dns-implementation/09-dns-lookup-from-clientvm.png)

From `NetMonVM1`, lookups resolved:

| Query              |      Result |
| ------------------ | ----------: |
| `TestLinuxServer1` |  `10.0.0.4` |
| `TestClientVM1`    | `10.0.0.21` |
| `WireGuardVM1`     | `10.0.0.36` |

*See Evidence:* [10-dns-lookup-from-netmonvm.png](../screenshots/network/private-dns-implementation/10-dns-lookup-from-netmonvm.png)

The lookup results show resolution through the local system resolver at `127.0.0.53`, with Azure-provided internal DNS names resolving to private IP addresses.

## Lessons Learned

Private DNS is easier to validate when DNS records are compared directly against the VNet connected devices list.

Forward and reverse DNS solve different administrative problems. Forward records help locate systems by name, while reverse records help identify systems from private IP addresses.

Auto-registration should be used intentionally. It is useful for forward lookup zones but may not fit reverse DNS zones where PTR records need to be explicitly controlled.

DNS evidence should include both portal configuration and live lookup results. Portal screenshots show that the zones and records exist, while terminal lookups confirm that systems can actually resolve names from inside the environment.

Private DNS implementation should be documented separately from the general VNet/subnet design because DNS records, VNet links, and lookup validation are detailed enough to justify their own document.

## Related Documents

<!-- Related documents will be added as system documentation is created. -->

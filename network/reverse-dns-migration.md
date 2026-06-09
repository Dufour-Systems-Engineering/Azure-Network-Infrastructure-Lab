`network/reverse-dns-migration.md`

# Reverse DNS Migration

## Overview

This document describes the reverse DNS migration implemented in the Azure Network Infrastructure Lab.

Reverse DNS was added to support IP-to-hostname resolution for systems inside `TestVNet1`. The implementation uses an Azure Private DNS reverse lookup zone with manually maintained PTR records for core infrastructure, client, remote access, and monitoring systems.

*See Evidence:* [02-reverse-dns-recordsets.png](../screenshots/network/private-dns-implementation/02-reverse-dns-recordsets.png)

## Purpose

The purpose of this document is to explain why reverse DNS was added, how the reverse lookup zone is structured, and how reverse lookup functionality was validated.

Reverse DNS supports:

* IP-to-hostname lookup
* Easier troubleshooting
* Cleaner validation of private IP assignments
* Better comparison between DNS records and Azure NIC assignments
* More complete internal DNS coverage for the lab environment

## Scope

This document covers the reverse DNS migration for the Azure Network Infrastructure Lab.

Included in scope:

* Reverse DNS zone purpose
* Reverse DNS zone name
* PTR record structure
* Current PTR records
* Reverse zone virtual network link
* Manual PTR record management
* Reverse lookup validation

Excluded from scope:

* Full Private DNS implementation details
* Forward DNS record management
* Public DNS
* Custom DNS servers
* Azure DNS Private Resolver
* DNS troubleshooting procedures
* Step-by-step PTR update procedures

## Architecture Summary

Reverse DNS is implemented through the Azure Private DNS zone `0.0.10.in-addr.arpa`.

The reverse zone is linked to `TestVNet1` through `reverse-vnet-link`, allowing systems inside the virtual network to perform reverse DNS lookups against private IP addresses.

PTR records are manually maintained. Each PTR record maps the final octet of a `10.0.0.x` private IP address back to the corresponding lab hostname.

*See Evidence:* [04-reverse-zone-vnet-link.png](../screenshots/network/private-dns-implementation/04-reverse-zone-vnet-link.png)

## Components

### Reverse Private DNS Zone

The reverse Private DNS zone is:

`0.0.10.in-addr.arpa`

This zone provides reverse lookup functionality for private IP addresses in the `10.0.0.x` address space.

### PTR Records

PTR records map private IP addresses back to hostnames.

Current reverse DNS records include:

| Record |   Private IP | Hostname           |
| -----: | -----------: | ------------------ |
|    `4` |   `10.0.0.4` | `TestLinuxServer1` |
|   `21` |  `10.0.0.21` | `TestClientVM1`    |
|   `22` |  `10.0.0.22` | `TestClientVM2`    |
|   `23` |  `10.0.0.23` | `TestClientVM3`    |
|   `24` |  `10.0.0.24` | `TestClientVM4`    |
|   `25` |  `10.0.0.25` | `TestClientVM5`    |
|   `26` |  `10.0.0.26` | `TestClientVM6`    |
|   `36` |  `10.0.0.36` | `WireGuardVM1`     |
|  `132` | `10.0.0.132` | `NetMonVM1`        |

### Virtual Network Link

The reverse DNS zone is linked to `TestVNet1`.

Current link configuration:

| Item                 | Value               |
| -------------------- | ------------------- |
| Link name            | `reverse-vnet-link` |
| Virtual network      | `TestVNet1`         |
| Auto-registration    | Disabled            |
| Fallback to Internet | Disabled            |

### Connected Devices Reference

The connected devices view confirms the private IP assignments used by the PTR records.

*See Evidence:* [07-vnet-connected-devices-reference.png](../screenshots/network/private-dns-implementation/07-vnet-connected-devices-reference.png)

## Design Decisions

A dedicated reverse lookup zone was created to support IP-to-hostname resolution inside the lab.

PTR records are manually maintained because the lab uses a small number of systems with predictable private IP assignments. Manual control keeps the records explicit and easier to verify.

Auto-registration is disabled for the reverse zone. This prevents automatic record creation and keeps PTR record management intentional.

Fallback to Internet is disabled because the reverse DNS zone is intended for private lab resolution only.

## Security Considerations

Reverse DNS is scoped to Azure Private DNS and linked to `TestVNet1`.

No public DNS records are used for reverse lookup.

Manual PTR record management reduces unintended record creation and keeps DNS changes controlled.

Administrative access to the DNS zone is governed through Azure access control.

## Validation

Reverse DNS was validated from inside the lab network.

Validation confirmed that private IP addresses resolve back to expected hostnames through the reverse lookup zone.

*See Evidence:* [10-dns-lookup-from-netmonvm.png](../screenshots/network/private-dns-implementation/10-dns-lookup-from-netmonvm.png)

## Lessons Learned

Reverse DNS improves troubleshooting when starting from an IP address instead of a hostname.

Forward DNS and reverse DNS serve different purposes and should be validated separately.

Manual PTR records are practical in a small lab with static private IP assignments.

Reverse DNS records should be compared against Azure connected device evidence to avoid stale or incorrect mappings.

## Related Documents

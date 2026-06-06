# Changelog

All notable changes to the Azure Network Infrastructure Lab repository will be documented in this file.

## 2026-06-06

### Added

* Added initial root repository documentation.
* Added project name: `Azure Network Infrastructure Lab`.
* Added initial architecture documentation set.
* Added initial network documentation set.
* Added screenshot-backed evidence references for architecture and network documentation.

### Architecture

* Added `architecture/environment-overview.md`.
* Added `architecture/logical-topology.md`.
* Added `architecture/ip-addressing-plan.md`.
* Added `architecture/security-model.md`.

Documented architecture topics include:

* Lab purpose and environment overview
* Logical topology
* VNet and subnet structure
* IP addressing plan
* Remote access boundary
* Security model
* Infrastructure, client, monitoring, and DNS placement

### Network

* Added `network/vnet-subnet-design.md`.
* Added `network/nsg-asg-implementation.md`.
* Added `network/private-dns-implementation.md`.

Documented network topics include:

* `TestVNet1` address space
* Subnet segmentation
* Connected device placement
* VNet isolation status
* Azure Bastion design decision
* DDoS protection status
* Azure-provided DNS at the VNet level
* NSG inventory
* ASG inventory
* Subnet-to-NSG associations
* Current NSG rule state
* Current ASG state
* Private DNS forward zone
* Private DNS reverse zone
* Private DNS virtual network links
* DNS lookup validation from WireGuardVM1, TestClientVM1, and NetMonVM1

### Screenshots

* Added network evidence screenshots for VNet and subnet design.
* Added network evidence screenshots for NSG and ASG implementation.
* Added network evidence screenshots for Private DNS implementation.
* Organized screenshots under topic-specific folders where needed.

### Validation

* Documented private IP placement for core systems.
* Documented DNS lookup validation from multiple systems.
* Documented current ASG state instead of treating ASGs as a completed final-state design.
* Documented current NSG rules from Azure Portal screenshots.
* Documented private DNS records and VNet link status.

### Notes

* This push establishes the repository foundation.
* Remaining sections will be expanded in later updates, including storage, deployment, remote access, monitoring, operations, troubleshooting, evidence, scripts, exports, and templates.

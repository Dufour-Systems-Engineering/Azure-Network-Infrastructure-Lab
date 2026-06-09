# Changelog

All notable changes to the Azure Network Infrastructure Lab repository will be documented in this file.

## 2026-06-09

### Added

* Added `storage/nfs-server-deployment.md`.
* Added NFS server deployment evidence screenshots under `screenshots/storage/nfs-server-deployment/`.

### Storage

* Documented NFS server package installation.
* Documented NFS service status.
* Documented `/srv/nfs` export directory structure.
* Documented `/etc/exports` configuration.
* Documented active NFS exports using `exportfs`.
* Documented local NFS export validation using `showmount`.

### Notes

* This update begins the storage documentation section.
* Client-side NFS integration will be documented separately.

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

### Network

* Added `network/vnet-subnet-design.md`.
* Added `network/nsg-asg-implementation.md`.
* Added `network/private-dns-implementation.md`.
* Added `network/reverse-dns-migration.md`.

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
* Reverse DNS PTR record implementation and validation

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
* Remaining sections will be expanded in later updates, including deployment, remote access, monitoring, operations, troubleshooting, evidence, scripts, exports, and templates.

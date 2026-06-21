# Changelog

All notable changes to the Azure Network Infrastructure Lab repository will be documented in this file.
## 2026-06-21

### Added

* Added the Governance v1.0 framework under the new `governance/` directory, including repository governance, principles, workflow, style guide, document standards, publication quality gate, decision log, audit log, and supporting documentation.
* Added `monitoring/netmonvm1-overview.md`.
* Added `remote-access/jumpbox-administration-workflow.md`.
* Added `troubleshooting/nfs-mount-permission-denied.md`.
* Added supporting screenshot evidence for the NetMon overview, jumpbox administration workflow, and NFS troubleshooting documentation.

### Changed

* Updated `README.md` to reflect the current repository structure, documentation status, governance framework, implementation highlights, and Phase 1 progress.
* Updated `templates/section-template-repo.md` to clarify that templates are selected according to document purpose rather than repository location.
* Expanded repository governance to formalize documentation standards, publication requirements, repository workflow, and lifecycle guidance.
* Refined repository documentation standards to distinguish governance documents from static technical documentation.

### Notes

Phase 1 remains in progress.

The remaining major Phase 1 documentation objectives are:

* `deployment/batch-client-deployment.md`
* `operations/vm-lifecycle-management.md`

These documents are intentionally being completed after the environment has been prepared to allow comprehensive evidence collection rather than reconstruction from historical implementation.

## 2026-06-16

### Added

* Added `command-codex/` as a root-level command reference system for the Azure Network Infrastructure Lab.
* Added Azure CLI command reference documentation under `command-codex/azure-cli/`.
* Added Bash/Linux command reference documentation under `command-codex/bash-linux/`.
* Added PowerShell command reference documentation under `command-codex/powershell/`.
* Added syntax reference documentation under `command-codex/syntax/`.
* Added system-specific command documentation under `command-codex/system-specific/`.
* Added Command Codex documentation for WireGuard, cost-control operations, and golden image management.
* Added `storage/nfs-exports-and-permissions.md` documenting NFS export structure, `/etc/exports` configuration, active export validation, client mount validation, and elevated write testing.
* Added NFS exports and permissions evidence screenshots under `screenshots/storage/nfs-exports-and-permissions/`.
* Added WireGuard quick-connect evidence screenshots:

  * `13-powershell-profile-quick-connect-function.png`
  * `14-wireguard-quick-connect-login-validation.png`
* Added repo setup scripts under `scripts/repo-setup/`.
* Added command documentation templates:

  * `templates/command-library-template.md`
  * `templates/syntax-reference-template.md`

### Changed

* Updated `README.md` to include the Command Codex, NFS exports and permissions documentation, repo setup scripts, and command documentation templates.
* Updated `command-codex/README.md` to describe the Command Codex purpose, folder roles, documentation model, command sources, redaction expectations, and relationship to other repository areas.
* Updated `remote-access/wireguard-vpn-gateway.md` with a PowerShell `wgssh` quick-connect workflow for recurring administrative SSH access to the WireGuard gateway.
* Expanded WireGuard prerequisites, validation, troubleshooting, lessons learned, and related documentation links.
* Updated existing WireGuard evidence screenshots for VM overview, gateway login, and private IP SSH validation.
* Updated repository documentation standards to include command library and syntax reference templates.

### Notes

* The WireGuard quick-connect workflow uses placeholder values for private key paths, usernames, and public IP addresses to avoid exposing sensitive administrative details.
* NFS write validation is documented as elevated administrative write validation because the test used `sudo tee`.
* Command Codex documentation is intended to explain commands actually used in the lab and preserve command understanding without overstating command-line proficiency.


## 2026-06-12

### Added

* Added `storage/nfs-client-integration.md`.
* Added `deployment/golden-image-management.md`.
* Added `remote-access/wireguard-vpn-gateway.md`.
* Added `operations/cost-control-operations.md`.
* Added cost-control operations evidence screenshots under `screenshots/operations/cost-control-operations/`.

### Storage

* Documented client-side NFS package validation.
* Documented active NFS mount verification.
* Documented persistent `/etc/fstab` configuration.
* Documented filesystem capacity validation.
* Documented client directory access validation.
* Documented client write validation.
* Documented automount behavior validation.

### Deployment

* Documented golden image management workflow.
* Documented managed image overview.
* Documented validation VM deployment from image source.
* Documented validation VM networking state.
* Documented configuration validation from the deployed image.

### Remote Access

* Documented WireGuard VPN gateway deployment and configuration.
* Documented WireGuard VM overview and network placement.
* Documented Azure NIC IP forwarding requirement.
* Documented WireGuard NSG rule configuration.
* Documented WireGuard package and service validation.
* Documented WireGuard interface status.
* Documented UDP listening-port validation.
* Documented server configuration review.
* Documented VPN login and private IP SSH validation.

### Operations

* Documented cost-control procedures for the Azure lab.
* Documented Azure Cost Management review.
* Documented VM power-state inventory by region.
* Documented VM deallocation workflow.
* Documented deallocation verification.
* Documented Azure Automation runbook schedule validation.
* Documented delete-option and orphan-resource cleanup review.

### Screenshots

* Added six new cost-control operation screenshots.
* Modified existing network screenshots to apply redactions for sensitive account or tenant information.
* Updated existing screenshot filenames to align with the repository naming convention.
* Replaced `screenshots/network/private-dns-implementation/07-vnet-connected-devices-reference.png` with `07-vnet-connected-devices.png`.
* Replaced `screenshots/network/vnet-subnet-design/08-vnet-peerings.png` with `08-net-peerings.png`.

### Notes

* This update expands the repository beyond the initial architecture, network, and NFS server documentation.
* Existing screenshots were cleaned up for consistency and redaction; the only new screenshot set added in this update was for cost-control operations.
* Remaining high-priority documentation includes VM lifecycle management, batch client deployment, NFS exports and permissions, jumpbox administration workflow, and administrative command library.

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

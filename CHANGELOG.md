# Changelog

All notable changes to the Azure Network Infrastructure Lab repository will be documented in this file.

## 2026-07-20

### Added

* Added `deployment/golden-image-management/golden-image-management.md` as the authoritative implementation record for the West US Golden-Base managed image.
* Added `deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md` to document the managed-image lineage, Azure Compute Gallery publication, Central US replication, and batch-deployment use of version `1.0.0`.
* Added `runbooks/golden-image-lifecycle-runbook.md` to define controlled image inventory, baseline validation, candidate preparation, capture, promotion, gallery publication, retirement, verification, and rollback procedures.
* Replaced `command-codex/system-specific/golden-image-management.md` with a governed command library covering managed-image inventory, VM consumer verification, gallery version creation and replication, gallery inspection, and inherited guest-baseline validation.
* Added golden-image evidence for the authoritative managed image, tags, consumer inventory, representative guest validation, marketplace-image exceptions, and gallery replication status.
* Added `monitoring/centralized-logging-with-rsyslog.md` to document the `NetMonVM1` rsyslog receiver, TCP and UDP listeners on port 514, hostname-based storage, local validation, troubleshooting, limitations, and next forwarding milestone.
* Added seven curated rsyslog screenshots under `screenshots/monitoring/rsyslog/` covering package validation, default configuration review, receiver configuration, listener validation, unsuccessful local-rule testing, corrective configuration, and successful message storage.
* Added `evidence/powershell-batch-deployment/README.md` as the scope, navigation, sanitization, and publication boundary for the batch-deployment evidence set.
* Added seven curated and sanitized public evidence artifacts covering Phase 2 gallery and client deployment work, Phase 3 WireGuard deployment success and troubleshooting, Phase 4 server configuration and system state, and Phase 5 teardown and resource preservation.
* Added `.gitignore` publication rules that keep the local batch SSH key pair out of version control while preserving `command-codex/powershell/powershell.md` as the only published file in that directory.

### Changed

* Updated the root `README.md` with the complete four-document golden-image system, runbook navigation, verified consumer scope, marketplace-image exceptions, and Central US gallery lineage.
* Reconciled the root README's repository tree against the current public file inventory, representing every populated public documentation and script folder while collapsing individual evidence and screenshot assets beneath their subject directories.
* Added root README navigation for the sanitized batch evidence and centralized rsyslog documentation.
* Updated the root README's monitoring state and priorities to distinguish the locally validated rsyslog receiver foundation from the still-unvalidated cross-VM forwarding milestone.
* Updated `deployment/README.md` from a batch-only entry point into the navigation document for both golden-image management and the five-phase Bicep deployment.
* Updated `deployment/README.md` to list the four published `*-redacted.bicep` files by their actual filenames and explain that they are public reference copies requiring valid environment-specific values before validation or deployment.
* Updated the batch evidence README to list both Phase 4 artifacts and define their separate evidentiary limits.
* Clarified that `TestClientVM1` through `TestClientVM6` and `NetMonVM1` are the seven confirmed consumers of `Golden-Base-1.2-image-20251103141303`.
* Clarified that `WireGuardVM1` and `TestLinuxServer1` use Canonical marketplace images and are not consumers of the Golden-Base managed image.
* Clarified that the separate Central US batch WireGuard VM used the versioned Azure Compute Gallery derivative.
* Corrected Related Documents and evidence links to match the final `runbooks/`, `deployment/golden-image-management/`, `command-codex/system-specific/`, and `screenshots/` paths.
* Expanded the root README's AI disclosure into a clear authorship and responsibility statement.

### Validated

* Verified the authoritative managed image in West US with provisioning state `Succeeded`.
* Verified seven current West US consumers through Azure VM image-reference inventory.
* Verified `TestClientVM1` as a representative consumer of the authoritative image.
* Verified the inherited Ubuntu 22.04 and NFS client baseline on the representative validation VM.
* Verified `WireGuardVM1` and `TestLinuxServer1` as marketplace-image exceptions.
* Verified Azure Compute Gallery version `1.0.0` as a derivative of the authoritative managed image.
* Verified completed gallery replication to West US and Central US.
* Preserved the distinction between the authoritative operational managed image and the historical batch-deployment gallery derivative.
* Verified that `NetMonVM1` listened on TCP and UDP port 514 and stored a locally generated TCP test message in `/var/log/remote/NetMonVM1.log`.
* Preserved the validation boundary that remote forwarding from another lab VM, UDP message storage, encrypted transport, rotation, and retention remain unverified.
* Reviewed the seven public batch evidence artifacts for exposed private-key material, credentials, account paths, email addresses, and subscription identifiers before publication.
* Verified through Git that the local batch SSH private and public key files remain ignored and that only `command-codex/powershell/powershell.md` is tracked from that directory.
* Reconciled the root README structure against the public file inventory and excluded retired document paths, superseded screenshot locations, and empty directories from the published tree.

### Removed or Superseded

* Replaced the four earlier golden-image screenshots with a curated ten-image evidence set covering authoritative image state, tags, consumer inventory, representative guest validation, marketplace-image exceptions, and gallery replication.

### Documentation Authorship

* Documented that AI tools were used to organize project-owner-supplied material, draft narrative text, explain concepts, support troubleshooting, classify commands, identify documentation gaps, and revise content under the project owner's direction.
* Documented that the project owner designed, implemented, tested, and validated the environment; executed the commands; collected and curated the evidence; corrected inaccuracies; applied redactions; and approved all published material.
* Clarified that AI-generated or AI-assisted narrative is not treated as implementation evidence and that final responsibility remains with the project owner.

### Next Priorities

* Continue consolidating existing operational and diagnostic material into purpose-built runbooks and troubleshooting records.
* Configure one original West US Linux VM as an rsyslog forwarding client and verify that its messages arrive in a source-specific file on `NetMonVM1`.
* Expand monitoring only through measurable, evidence-backed implementation and validation.
* Continue treating disaster recovery, WireGuard key rotation, client lifecycle management, routine maintenance, configuration-drift review, and rebuild-from-zero automation as future lifecycle improvements rather than completed capabilities.

## 2026-07-18

### Added

* Added `deployment/README.md` as the entry point for the completed five-phase Central US batch-deployment project.
* Added five evidence-backed batch-deployment documents under `deployment/batch-deployment/`:

  * Network foundation module deployment.
  * Six-client VM module deployment.
  * WireGuard VM module deployment.
  * WireGuard VPN server configuration and one-hop validation.
  * Selective teardown and retained-resource verification.

* Added the final modular Bicep source set under `deployment/batch-deployment-bicep-files/`, including the parent template and reusable network, client VM, and WireGuard VM modules.
* Added deployment evidence covering Bicep validation, What-If analysis, Azure deployment results, portal inspection, guest validation, VPN configuration, connectivity testing, and teardown verification.
* Added `remote-access/README.md` as the entry point and scope boundary for the original West US WireGuard implementation.
* Added `remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration.md`.
* Added `remote-access/wireguard-vpn-server-linux-setup-and-configuration.md`.
* Added `remote-access/wireguard-vpn-server-completion-and-one-hop-access.md`.
* Added new and expanded remote-access evidence for initial VM deployment, jumpbox administration, Private DNS validation, VPN completion, and direct one-hop administration.
* Added Bash and PowerShell scripts supporting lab administration, connectivity validation, evidence handling, and repeatable workflows.
* Added structured evidence content under `evidence/` for the batch-deployment work.

### Changed

* Updated the root `README.md` to reconcile the documented repository structure with the current implementation.
* Updated the root README to distinguish the established West US lab from the separate Central US Bicep batch-deployment project.
* Replaced the obsolete Phase 1 progress language with the current documentation and monitoring priorities.
* Expanded the root README with current deployment, remote-access, Command Codex, scripts, evidence, Governance, AI-assistance, and future-work information.
* Reorganized golden-image documentation from `deployment/golden-image-management.md` into `deployment/golden-image-management/golden-image-management.md`.
* Expanded and reorganized the Command Codex across Azure CLI, Bash/Linux, PowerShell, syntax, and system-specific references.
* Updated `command-codex/README.md` to formalize command provenance, evidence classification, destructive-command handling, and the relationship between curated command references and raw transcripts.
* Expanded Azure CLI documentation with Bicep deployment, inventory, subnet-based targeting, and selective-cleanup commands.
* Expanded Bash/Linux documentation with DNS inspection, IPv4 forwarding, WireGuard runtime validation, SSH administration, and command-pipeline examples.
* Expanded PowerShell documentation with transcript capture, secure input, SSH key preparation, and connectivity validation.
* Updated the jumpbox administration workflow with retained evidence for forward Private DNS and internal host resolution.
* Reframed the original WireGuard documentation as a chronological sequence from initial deployment and jumpbox use through completed VPN validation.
* Clarified that the original West US WireGuard implementation and the later Central US batch-deployed WireGuard implementation are separate evidence scopes.
* Replaced the batch-deployment Bicep files with redacted publication copies after archiving the original working versions.

### Validated

* Validated the Central US network foundation through Bicep validation, What-If, deployment, resource inspection, and teardown checks.
* Validated deployment of six Linux client VMs from an Azure Compute Gallery image through a loop-based Bicep module.
* Validated the complete seven-VM module chain after adding the WireGuard infrastructure module.
* Validated WireGuard server configuration, peer handshake, tunnel traffic, private reachability, and one-hop SSH access to all six batch-deployed clients.
* Validated selective removal of the six client VMs, NICs, and OS disks while preserving the network foundation and WireGuard resources.
* Verified the retained batch-deployed WireGuard VM as stopped and deallocated for cost control.
* Validated the original `WireGuardVM1` as both an SSH jumpbox and a completed WireGuard gateway for direct administration of private West US systems.
* Validated forward Private DNS resolution for the documented West US client and infrastructure systems from the WireGuard administration path.

### Removed or Superseded

* Removed the superseded `deployment/golden-image-management.md` path after relocating the document into its dedicated folder.
* Removed the superseded `remote-access/wireguard-vpn-gateway.md` document and replaced its combined claims with scoped documents that distinguish initial deployment, jumpbox administration, Linux server setup, and completed VPN validation.
* Removed the obsolete `screenshots/remote-access/wireguard-vpn-gateway/` evidence location after reorganizing the retained evidence under the current remote-access workflows.

### Documentation Method

* Documented that AI assistance was used to accelerate research, troubleshooting support, source organization, command classification, and drafting.
* Clarified that the project owner performed the implementation, executed and validated the commands, collected the evidence, reviewed and corrected drafts, and approved the final technical content.
* Maintained the distinction between AI-assisted documentation and evidence of implemented technical work.

### Next Priorities

* Collate operational and diagnostic material already distributed across build documents, transcripts, command records, and evidence.
* Create separate runbooks for repeatable operational procedures.
* Create separate troubleshooting documents for confirmed incidents, failed approaches, root causes, and validated resolutions.
* Pivot to evidence-backed monitoring work after the runbook and troubleshooting consolidation is complete.
* Continue treating disaster recovery, WireGuard key rotation, client lifecycle management, routine maintenance, configuration-drift review, and rebuild-from-zero automation as future lifecycle improvements rather than completed capabilities.

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
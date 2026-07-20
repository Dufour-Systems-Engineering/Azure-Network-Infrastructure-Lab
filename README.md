# Azure Network Infrastructure Lab

## Overview

Azure Network Infrastructure Lab is a hands-on Azure infrastructure project focused on private networking, subnet segmentation, remote access, internal DNS, security group design, Linux infrastructure services, deployment automation, operational cost control, monitoring, troubleshooting, and command documentation.

The repository documents two related implementations:

* The established West US lab, which contains the primary segmented network, Linux client fleet, NFS server, WireGuard gateway, Private DNS implementation, golden-image workflow, and monitoring host.
* A separate Central US batch-deployment project used to revisit an earlier unsuccessful PowerShell batch-deployment attempt and demonstrate a complete modular Bicep build, validation, VPN configuration, and selective teardown workflow.

The purpose of this repository is to present the design, implementation, validation, troubleshooting, and administration of these environments in a professional, evidence-backed, and maintainable format.

## Project Goals

This project demonstrates practical infrastructure administration across Azure networking, Linux systems, remote access, infrastructure as code, command-line operations, troubleshooting, and engineering documentation.

Primary goals include:

* Build segmented Azure virtual networks and separate systems by role.
* Use private IP addressing and Azure Private DNS for internal communication.
* Implement WireGuard-based remote administration of private Azure systems.
* Configure and validate Linux infrastructure services such as NFS.
* Build and validate a reusable golden-image workflow.
* Deploy coordinated Azure resources through modular Bicep templates.
* Validate infrastructure through Azure CLI, What-If, portal inspection, Linux guest checks, and connectivity tests.
* Apply deliberate teardown and cost-control procedures.
* Preserve evidence-backed build, validation, and troubleshooting records.
* Maintain a reusable Command Codex for Azure CLI, Bash/Linux, PowerShell, and system-specific administration.
* Develop dedicated runbooks, troubleshooting records, scripts, and monitoring workflows as the lab matures.

## Environment Summary

### Established West US Lab

| Item | Value |
|---|---|
| Resource group | `TestGroup1` |
| Primary VNet | `TestVNet1` |
| Region | West US |
| VNet address space | `10.0.0.0/24` |
| Remote access | WireGuard VPN and SSH |
| DNS | Azure Private DNS linked to `TestVNet1` |
| Storage | Linux NFS server hosted on `TestLinuxServer1` |
| Monitoring | Dedicated `NetMonVM1` host with a locally validated rsyslog receiver foundation |
| Operations | Manual and scheduled cost-control procedures |

### Central US Batch-Deployment Project

| Item | Value |
|---|---|
| Implementation boundary | Separate Central US resource group |
| Deployment method | Modular Bicep templates orchestrated by a parent template |
| Network | Dedicated client and WireGuard subnets |
| Compute | Six Linux client VMs and one WireGuard VM |
| Image source | Azure Compute Gallery image |
| Remote access validation | WireGuard handshake, tunnel traffic, private reachability, and one-hop SSH |
| Final lifecycle state | Client VMs and dependencies removed; network and deallocated WireGuard resources retained |

The Central US project is documented independently from the original West US environment. Evidence from one implementation is not used to claim validation of the other.

## West US Network Layout

`TestVNet1` is divided into dedicated subnets by system role.

| Subnet | CIDR | Purpose |
|---|---:|---|
| `TestSubNet1` | `10.0.0.0/28` | Shared infrastructure services |
| `TestSubNet2` | `10.0.0.16/28` | Linux client fleet |
| `DMZ-Subnet` | `10.0.0.32/29` | WireGuard remote-access boundary |
| `NetMonSubnet1` | `10.0.0.128/29` | Monitoring and diagnostics |

## Key West US Systems

| System | Private IP | Role |
|---|---:|---|
| `TestLinuxServer1` | `10.0.0.4` | NFS server and shared infrastructure |
| `TestClientVM1` | `10.0.0.21` | Linux client |
| `TestClientVM2` | `10.0.0.22` | Linux client |
| `TestClientVM3` | `10.0.0.23` | Linux client |
| `TestClientVM4` | `10.0.0.24` | Linux client |
| `TestClientVM5` | `10.0.0.25` | Linux client |
| `TestClientVM6` | `10.0.0.26` | Linux client |
| `WireGuardVM1` | `10.0.0.36` | WireGuard VPN gateway and SSH jumpbox |
| `NetMonVM1` | `10.0.0.132` | Monitoring and diagnostics host |

## Repository Structure

```text
azure-network-infrastructure-lab/
├── .gitignore
├── CHANGELOG.md
├── README.md
├── architecture/
│   ├── architecture-diagram.jpg
│   ├── environment-overview.md
│   ├── ip-addressing-plan.md
│   ├── logical-topology.md
│   └── security-model.md
├── command-codex/
│   ├── README.md
│   ├── azure-cli/
│   │   └── azure-cli.md
│   ├── bash-linux/
│   │   └── bash-linux.md
│   ├── powershell/
│   │   └── powershell.md
│   ├── syntax/
│   │   ├── azure-cli-query-syntax.md
│   │   ├── bash-syntax.md
│   │   └── powershell-syntax.md
│   └── system-specific/
│       ├── cost-control-ops.md
│       ├── golden-image-management.md
│       └── wireguard.md
├── deployment/
│   ├── README.md
│   ├── batch-deployment/
│   │   ├── phase-1-batch-deployment-network-foundation-module.md
│   │   ├── phase-2-batch-deployment-client-vm-module.md
│   │   ├── phase-3-batch-deployment-wireguard-module.md
│   │   ├── phase-4-batch-deployment-wireguard-vpn-server-configuration.md
│   │   └── phase-5-batch-deployment-teardown.md
│   ├── batch-deployment-bicep-files/
│   │   ├── main-redacted.bicep
│   │   ├── network-module-redacted.bicep
│   │   ├── vm-batch-deployment-redacted.bicep
│   │   └── wireguard-vm-module-redacted.bicep
│   └── golden-image-management/
│       ├── golden-image-management.md
│       └── golden-image-lineage-and-batch-gallery-migration.md
├── evidence/
│   └── powershell-batch-deployment/
│       ├── README.md
│       ├── phase-02-client-vm-deployment/
│       ├── phase-03-wireguard-vm-deployment/
│       ├── phase-04-wireguard-configuration-validation/
│       └── phase-05-teardown/
├── governance/
│   ├── README.md
│   ├── document-standards-manual.md
│   ├── publication-quality-gate.md
│   ├── repository-audit-log.md
│   ├── repository-decision-log.md
│   ├── repository-governance.md
│   ├── repository-principles.md
│   ├── repository-style-guide.md
│   └── repository-workflow.md
├── monitoring/
│   ├── centralized-logging-with-rsyslog.md
│   └── netmonvm1-overview.md
├── network/
│   ├── nsg-asg-implementation.md
│   ├── private-dns-implementation.md
│   ├── reverse-dns-migration.md
│   └── vnet-subnet-design.md
├── operations/
│   └── cost-control-operations.md
├── remote-access/
│   ├── README.md
│   ├── jumpbox-administration-workflow.md
│   ├── wireguard-vm-initial-deployment-and-jumpbox-configuration.md
│   ├── wireguard-vpn-server-completion-and-one-hop-access.md
│   └── wireguard-vpn-server-linux-setup-and-configuration.md
├── runbooks/
│   └── golden-image-lifecycle-runbook.md
├── screenshots/
│   ├── deployment/
│   │   ├── batch-deployment-phase-one/
│   │   ├── batch-deployment-phase-two/
│   │   ├── batch-deployment-phase-three/
│   │   ├── batch-deployment-phase-four-wireguard-server-conf/
│   │   ├── batch-deployment-phase-five-cleanup/
│   │   └── golden-image-management/
│   ├── monitoring/
│   │   ├── netmonvm1-overview/
│   │   └── rsyslog/
│   ├── network/
│   │   ├── nsg-asg-implementation/
│   │   ├── private-dns-implementation/
│   │   └── vnet-subnet-design/
│   ├── operations/
│   │   └── cost-control-operations/
│   ├── remote-access/
│   │   ├── jumpbox-administration-workflow/
│   │   ├── vpn-one-hop-administration-workflow/
│   │   └── wireguard-vm-initial-deployment-and-jumpbox-configuration/
│   ├── storage/
│   │   ├── nfs-client-integration/
│   │   ├── nfs-exports-and-permissions/
│   │   └── nfs-server-deployment/
│   └── troubleshooting/
│       └── nfs-mount-permission-denied/
├── scripts/
│   ├── bash/
│   │   └── batchwireguardvm1-sys-conf
│   ├── powershell/
│   │   ├── fping-all-systems.ps1
│   │   └── relocate-powershell-session-logs.ps1
│   └── repo-setup/
│       ├── create-admin-command-library-structure.ps1
│       └── rename-reformat-screenshots.ps1
├── storage/
│   ├── nfs-client-integration.md
│   ├── nfs-exports-and-permissions.md
│   └── nfs-server-deployment.md
├── templates/
│   ├── command-library-template.md
│   ├── section-template-repo.md
│   └── syntax-reference-template.md
└── troubleshooting/
    └── nfs-mount-permission-denied.md
```

All populated public documentation and script folders are represented. Individual sanitized evidence files and screenshot images are intentionally collapsed beneath their phase or subject folders to keep the overview readable.

## Documentation Areas

| Area | Purpose | Entry point or representative document |
|---|---|---|
| Architecture | Environment, topology, addressing, and security design | [`architecture/environment-overview.md`](architecture/environment-overview.md) |
| Command Codex | Reusable Azure CLI, Bash/Linux, PowerShell, syntax, and system-specific command references | [`command-codex/README.md`](command-codex/README.md) |
| Deployment | Golden-image management and the five-phase Bicep deployment | [`deployment/README.md`](deployment/README.md) |
| Evidence | Curated and sanitized supporting records for validated implementation work | [`evidence/powershell-batch-deployment/README.md`](evidence/powershell-batch-deployment/README.md) |
| Governance | Repository authority, standards, workflow, decisions, and publication controls | [`governance/README.md`](governance/README.md) |
| Monitoring | NetMon host implementation and locally validated rsyslog receiver foundation | [`monitoring/netmonvm1-overview.md`](monitoring/netmonvm1-overview.md) and [`monitoring/centralized-logging-with-rsyslog.md`](monitoring/centralized-logging-with-rsyslog.md) |
| Network | VNet, subnet, NSG, ASG, and Private DNS implementation | [`network/vnet-subnet-design.md`](network/vnet-subnet-design.md) |
| Operations | Cost-control and recurring administrative procedures | [`operations/cost-control-operations.md`](operations/cost-control-operations.md) |
| Remote Access | Original WireGuard VM progression from jumpbox to validated VPN gateway | [`remote-access/README.md`](remote-access/README.md) |
| Runbooks | Repeatable lifecycle and administrative procedures | [`runbooks/golden-image-lifecycle-runbook.md`](runbooks/golden-image-lifecycle-runbook.md) |
| Scripts | Reusable Bash, PowerShell, and repository-maintenance automation | [`scripts/`](scripts/) |
| Storage | NFS server, exports, permissions, and client integration | [`storage/nfs-server-deployment.md`](storage/nfs-server-deployment.md) |
| Templates | Governed starting points for command, section, and syntax documentation | [`templates/`](templates/) |
| Troubleshooting | Evidence-backed incident and resolution records | [`troubleshooting/nfs-mount-permission-denied.md`](troubleshooting/nfs-mount-permission-denied.md) |

## Golden Image Documentation

Golden-image documentation is separated by purpose so that implemented state, historical lineage, operational procedure, and command explanation remain distinct.

1. [Golden Image Management](deployment/golden-image-management/golden-image-management.md)

   Documents the authoritative West US managed image, its confirmed consumers, its inherited Ubuntu and NFS client baseline, the two verified marketplace-image exceptions, and the current operational source of record.

2. [Golden Image Lineage and Batch Gallery Migration](deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md)

   Records how the authoritative managed image was published unchanged to Azure Compute Gallery, replicated to Central US, and used by the separate Bicep batch-deployment project without replacing the operational authority.

3. [Golden Image Lifecycle Runbook](runbooks/golden-image-lifecycle-runbook.md)

   Defines the repeatable procedure for inventory, baseline validation, candidate preparation, capture, validation, promotion, gallery publication, retirement, verification, and rollback.

4. [Golden Image Management Command Library](command-codex/system-specific/golden-image-management.md)

   Preserves and explains the validated Azure CLI, PowerShell, and Linux commands used for managed-image inventory, consumer verification, gallery publication, replication, inspection, and guest-baseline validation.

The verified West US consumer scope is seven VMs: `TestClientVM1` through `TestClientVM6` and `NetMonVM1`. `WireGuardVM1` and `TestLinuxServer1` use Canonical marketplace images and are not consumers of the Golden-Base managed image. The later Central US batch WireGuard VM is a separate system and used the versioned Azure Compute Gallery derivative documented in the lineage record.

## Batch-Deployment Project

The [Azure Batch Deployment Project](deployment/README.md) documents a five-phase Central US implementation:

1. [Network Foundation Module](deployment/batch-deployment/phase-1-batch-deployment-network-foundation-module.md)
2. [Client VM Module](deployment/batch-deployment/phase-2-batch-deployment-client-vm-module.md)
3. [WireGuard VM Module](deployment/batch-deployment/phase-3-batch-deployment-wireguard-module.md)
4. [WireGuard VPN Server Configuration](deployment/batch-deployment/phase-4-batch-deployment-wireguard-vpn-server-configuration.md)
5. [Teardown and Cleanup](deployment/batch-deployment/phase-5-batch-deployment-teardown.md)

The project successfully deployed a network foundation, six Linux client VMs, and a WireGuard VM through a coordinated Bicep module chain. It then completed the WireGuard data path, validated direct private administration, and selectively removed the six client systems and their dependent resources while retaining reusable network and WireGuard infrastructure.

The public Bicep reference copies are stored under `deployment/batch-deployment-bicep-files/` and retain the `-redacted.bicep` suffix to distinguish them from the private implementation templates. Sensitive and environment-specific values were removed or replaced with descriptive placeholders. The published files must be reviewed and supplied with valid environment-specific values before validation or deployment.

## Remote Access Documentation

The [Remote Access Documentation](remote-access/README.md) records the original `WireGuardVM1` implementation as a four-document sequence:

1. [Initial Deployment and Jumpbox Configuration](remote-access/wireguard-vm-initial-deployment-and-jumpbox-configuration.md)
2. [Jumpbox Administration Workflow](remote-access/jumpbox-administration-workflow.md)
3. [WireGuard VPN Server Linux Setup and Configuration](remote-access/wireguard-vpn-server-linux-setup-and-configuration.md)
4. [VPN Server Completion and One-Hop Administration](remote-access/wireguard-vpn-server-completion-and-one-hop-access.md)

This sequence preserves an important historical distinction. The initial server state supported public SSH and jumpbox-based administration, but it did not yet prove a complete workstation-to-VNet VPN. The later work completed the peer relationship, UDP path, routing, forwarding, NAT, handshake, and direct one-hop administration of private Azure VMs.

## Command Codex

The [Command Codex](command-codex/README.md) centralizes commands used during deployment, validation, troubleshooting, administration, and maintenance.

It separates:

* General Azure CLI, Bash/Linux, and PowerShell commands.
* Language and query syntax references.
* System-specific workflows for WireGuard, golden-image management, and cost control.
* Validated commands from troubleshooting or deployment history.
* Failed, superseded, destructive, and unconfirmed commands when their context provides a useful engineering lesson.

The Command Codex is a curated reference, not a raw transcript archive. Commands are consolidated, explained, classified, and connected to the documents in which they were used.

## Scripts

The `scripts/` directory stores reusable Bash, PowerShell, and repository-setup automation. Scripts are kept separate from narrative documentation so that technical documents explain implemented workflows while script files preserve reusable logic.

Scripts support tasks such as repository setup, screenshot organization, evidence handling, Azure administration, connectivity checks, and repeatable lab maintenance. Script publication follows the same validation and redaction expectations as the rest of the repository.

## Evidence Standard

Technical claims are supported where practical through screenshots, terminal output, transcripts, configuration files, Bicep source, and Azure resource inspection.

Screenshots are stored under `screenshots/` and linked from the relevant documentation. Curated supporting records are organized under `evidence/` according to their purpose. The batch-deployment evidence set contains sanitized excerpts from Phases 2 through 5; no Phase 1 terminal transcript was retained, and none was reconstructed after the fact. Evidence strengthens the written explanation but does not replace it.

Evidence is reviewed for sensitive account, tenant, subscription, credential, key, and endpoint information before publication. Files that require further redaction remain outside the published evidence set until reviewed.

## Documentation Authorship and AI Assistance

The technical implementation documented in this repository was designed, performed, tested, and validated by the project owner. The project owner selected the project goals and scope, made the implementation decisions, executed the commands, collected and curated the evidence, identified inaccuracies, applied corrections and redactions, and approved all material before publication.

AI tools were used to accelerate documentation production. Their role included organizing project-owner-supplied source material, drafting narrative text, explaining technical concepts, assisting with troubleshooting, classifying commands, identifying documentation gaps, and revising content under the project owner's direction.

Many published documents therefore began as AI-generated or AI-assisted drafts. They should not be interpreted as independently produced evidence or as proof that an AI system implemented the environment. Technical claims are based on the project owner's work, retained commands and configuration, screenshots, transcripts, Azure resource inspection, and confirmed validation results.

Final responsibility for the repository's technical accuracy, editorial decisions, scope, and publication remains with the project owner.

## Documentation Standards and Governance

The repository uses a formal [Governance framework](governance/README.md) to control documentation structure, terminology, workflow, evidence use, publication quality, and repository-wide decisions.

Templates are selected according to document purpose rather than destination folder. Static technical documents describe the implemented environment and rely on Git for revision history. Metadata tables are reserved for Governance and other lifecycle-managed documents unless an approved template explicitly requires one.

Relative links, evidence references, current-state accuracy, redaction, and repository consistency are verified before publication.

## Current Implementation Highlights

Current implemented and documented capabilities include:

* A segmented West US Azure network supporting infrastructure, client, remote-access, and monitoring roles.
* Azure Private DNS forward and reverse lookup implementation and validation.
* NSG and ASG implementation records tied to the current environment state.
* NFS server deployment, export configuration, client integration, mount validation, permissions testing, and troubleshooting.
* An original WireGuard VM documented from initial deployment through jumpbox use and completed one-hop VPN administration.
* A separate seven-VM Central US deployment produced through modular Bicep templates.
* Bicep validation, What-If analysis, deployment, control-plane inspection, guest validation, and selective teardown.
* An authoritative Golden-Base managed image used by the six West US client VMs and `NetMonVM1`, with verified marketplace-image exceptions for `WireGuardVM1` and `TestLinuxServer1`.
* Azure Compute Gallery publication, cross-region replication, lineage documentation, and use of the versioned derivative by the separate Central US batch deployment.
* A controlled golden-image lifecycle runbook and validated system-specific command reference.
* A Governance v1.0 framework and Publication Quality Gate.
* A structured Command Codex spanning Azure CLI, Bash/Linux, PowerShell, syntax, and system-specific workflows.
* Reusable Bash and PowerShell scripts supporting lab and repository administration.
* Cost-control operations including inventory, deallocation, scheduled shutdown, and cleanup review.
* A dedicated NetMon host with a locally validated rsyslog receiver, TCP and UDP listeners on port 514, and hostname-based log storage. Forwarding from another lab VM remains future work.

## Current Priorities

The next documentation priority is to collate operational and diagnostic information already distributed across the existing build documents, transcripts, command records, and evidence. That material will be separated into purpose-built runbooks and troubleshooting documents without duplicating or weakening the existing implementation records.

After that consolidation, monitoring work will continue from the existing `NetMonVM1` foundation and locally validated rsyslog receiver. The next logging milestone is to configure an original West US Linux VM as a forwarding client and verify that its messages arrive in a source-specific file on `NetMonVM1`. Broader monitoring work will continue to emphasize measurable results and evidence-backed operational capability.

Longer-term remote-access work may include disaster recovery, key rotation, client onboarding and revocation, routine maintenance, configuration-drift review, health monitoring, and rebuild-from-zero automation. These are identified as future lifecycle improvements and are not presented as currently implemented capabilities.

## Notes

This lab is an engineering portfolio and learning environment. It prioritizes practical implementation, technical accuracy, evidence, governance, cost awareness, command understanding, and maintainable documentation.

Production hardening, regulatory compliance, enterprise-scale availability, and high-availability gateway design remain outside the current documented scope unless added through future validated work.
# Deployment Documentation

## Overview

The `deployment/` directory documents the Azure Network Infrastructure Lab's reusable image workflow and a separate five-phase infrastructure deployment completed in Central US with modular Bicep templates.

The golden-image records establish the authoritative West US managed image, its verified consumers and exceptions, and the lineage of the Azure Compute Gallery derivative used by the batch project. The batch-deployment records document the network foundation, six Linux client VMs, WireGuard VM, completed VPN path, validation, and selective teardown.

## Documentation and Source Layout

```text
deployment/
├── README.md
├── golden-image-management/
│   ├── golden-image-management.md
│   └── golden-image-lineage-and-batch-gallery-migration.md
├── batch-deployment/
│   ├── phase-1-batch-deployment-network-foundation-module.md
│   ├── phase-2-batch-deployment-client-vm-module.md
│   ├── phase-3-batch-deployment-wireguard-module.md
│   ├── phase-4-batch-deployment-wireguard-vpn-server-configuration.md
│   └── phase-5-batch-deployment-teardown.md
└── batch-deployment-bicep-files/
    ├── main.bicep
    └── modules/
```

## Golden Image Documentation

### Golden Image Management

[Golden Image Management](./golden-image-management/golden-image-management.md) documents:

* `Golden-Base-1.2-image-20251103141303` as the authoritative West US managed image.
* `TestClientVM1` through `TestClientVM6` and `NetMonVM1` as its seven confirmed consumers.
* The inherited Ubuntu 22.04 and NFS client baseline.
* `WireGuardVM1` and `TestLinuxServer1` as verified Canonical marketplace-image exceptions.
* The difference between the operational managed-image authority and its later gallery derivative.

### Golden Image Lineage and Batch Gallery Migration

[Golden Image Lineage and Batch Gallery Migration](./golden-image-management/golden-image-lineage-and-batch-gallery-migration.md) records this distribution path:

```text
Golden-Base-1.2 source VM
└── Golden-Base-1.2-image-20251103141303
    └── BatchTestGallery2
        └── BatchTestImage2
            └── Version 1.0.0
                ├── West US replica
                └── Central US replica
```

The gallery version was an unchanged, project-specific distribution copy. It supported the Central US Bicep deployment and did not replace the authoritative West US managed image.

Supporting operational and command documentation is maintained separately:

* [Golden Image Lifecycle Runbook](../runbooks/golden-image-lifecycle-runbook.md)
* [Golden Image Management Command Library](../command-codex/system-specific/golden-image-management.md)

## Azure Batch Deployment Project

The batch project revisited an earlier unsuccessful attempt to deploy the original West US client fleet as a batch with PowerShell. The West US systems were ultimately created individually, leaving the batch-deployment objective incomplete.

The work was recreated in a separate Central US resource group using Bicep because Bicep is Azure's native declarative infrastructure language. Its modules, dependency handling, parameters, outputs, validation, and What-If support provided a structured and repeatable deployment workflow without disrupting the established lab.

## Batch Project Documentation

Read the phase documents in order:

1. [Phase 1 — Network Foundation Module](./batch-deployment/phase-1-batch-deployment-network-foundation-module.md)

   Builds, validates, deploys, inspects, and independently removes the reusable network foundation.

2. [Phase 2 — Client VM Module](./batch-deployment/phase-2-batch-deployment-client-vm-module.md)

   Adds a reusable loop-based module that deploys six Linux client VMs with static private IP addresses from the versioned gallery image.

3. [Phase 3 — WireGuard VM Module](./batch-deployment/phase-3-batch-deployment-wireguard-module.md)

   Adds the WireGuard Azure infrastructure from the same gallery version and validates the complete three-module, seven-VM deployment.

4. [Phase 4 — WireGuard VPN Server Configuration](./batch-deployment/phase-4-batch-deployment-wireguard-vpn-server-configuration.md)

   Configures the VPN, confirms a live handshake, validates private reachability, and establishes one-hop SSH access to all six clients.

5. [Phase 5 — Teardown and Cleanup](./batch-deployment/phase-5-batch-deployment-teardown.md)

   Selectively deletes the six client VMs and their dependent NICs and disks while preserving and deallocating the WireGuard server.

## Bicep Source Files

The redacted parent template and reusable modules are stored separately from the narrative documentation:

* [Open the batch-deployment Bicep source directory](./batch-deployment-bicep-files/)

The source set consists of:

* `main.bicep` — coordinates the complete module chain.
* `network-module.bicep` — deploys the VNet, subnets, NSGs, and subnet outputs.
* `vm-batch-deployment.bicep` — deploys the six client VMs and their NICs.
* `wireguard-vm-module.bicep` — deploys the WireGuard VM, NIC, public IP, and related Azure configuration.

## Batch Architecture Summary

| Network function | Addressing |
|---|---|
| Client subnet | `10.10.0.0/28` |
| Client VM private addresses | `10.10.0.5` through `10.10.0.10` |
| WireGuard subnet | `10.10.0.32/28` |
| WireGuard VM private address | `10.10.0.40` |
| WireGuard tunnel network | `10.66.0.0/24` |
| WireGuard server tunnel address | `10.66.0.1` |
| Validated Windows client tunnel address | `10.66.0.2` |

The parent template deployed the network module first and passed subnet resource IDs through module outputs to the two VM modules. Both VM modules consumed the immutable Azure Compute Gallery version ID documented in the lineage record.

## Batch Project Lifecycle

| Lifecycle point | Result |
|---|---|
| Image distribution | Gallery version `1.0.0` was replicated to Central US from the authoritative managed image. |
| Network foundation | The VNet, two subnets, and two NSGs were deployed through Bicep. |
| Client deployment | Six Linux client VMs were deployed from the gallery version. |
| Complete environment | The WireGuard VM was added from the same gallery version, producing a seven-VM deployment. |
| Functional validation | VPN handshake, tunnel traffic, private reachability, and SSH access to all six clients were verified. |
| Selective teardown | The six client VMs and their associated NICs and OS disks were removed. |
| Retained state | The network foundation and WireGuard resources were preserved. |
| Cost control | The retained WireGuard VM was verified as **Stopped (deallocated)**. |

## Evidence and Documentation Methodology

Each deployment document links to evidence appropriate to its scope, including managed-image and gallery inspection, Bicep validation, What-If output, Azure CLI results, portal verification, Linux guest checks, WireGuard status, connectivity testing, SSH sessions, and post-teardown inventory checks.

The documentation was developed from Bicep source files, executed commands, PowerShell and shell transcripts, configuration files, and redacted screenshots. AI assistance accelerated source organization, explanation, troubleshooting support, and drafting. The project owner performed and validated the implementation, collected and reviewed the evidence, corrected the drafts, and approved the final content.

## Outcome

Together, the deployment records demonstrate:

* Verification and lifecycle control of a reusable managed-image baseline.
* Separation of operational image authority from project-specific gallery distribution.
* Cross-region image replication and immutable version use.
* Modular Azure infrastructure deployment with Bicep.
* Dependency-aware orchestration through module outputs.
* Repeatable deployment of multiple Linux VMs from a shared image version.
* Segmented networking and WireGuard-based one-hop administration.
* Verification across the Azure control plane, Linux guests, and VPN data path.
* Intentional lifecycle management through selective deletion and deallocation.

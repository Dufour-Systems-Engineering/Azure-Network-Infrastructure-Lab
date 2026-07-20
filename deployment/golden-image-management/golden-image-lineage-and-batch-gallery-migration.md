# Golden Image Lineage and Batch Gallery Migration

## Overview

This document records how the authoritative West US managed image was published to Azure Compute Gallery and used by the separate batch-deployment environment. It is a historical build record and does not declare that the gallery version replaced the operational image.

The lineage was:

```text
Golden-Base-1.2 source VM
└── Golden-Base-1.2-image-20251103141303
    └── BatchTestGallery2
        └── BatchTestImage2
            └── Version 1.0.0
                ├── West US replica
                └── Central US replica
```

## Purpose

The gallery copy supported a separate Bicep-based recreation of the lab's client and WireGuard deployment workflow. Regional quota limits required the recreated environment to use Central US, and the distinct gallery path helped prevent the batch/test environment from being confused with the existing operational lab.

No guest-level changes were made during publication. Version `1.0.0` was a distribution copy of the authoritative image and did not become a general operational utility.

## Prerequisites

The migration required:

- Access to `TestGroup1`.
- The source managed-image resource ID.
- `BatchTestGallery2`.
- The generalized Linux image definition `BatchTestImage2`.
- Permission to create and update gallery image versions.
- Regional replication targets for West US and Central US.
- Bicep VM modules able to accept a versioned gallery image ID.

The confirmed source and gallery properties were:

| Setting | Value |
| --- | --- |
| Source managed image | `Golden-Base-1.2-image-20251103141303` |
| Source VM | `Golden-Base-1.2` |
| Source resource group | `TestGroup1` |
| Source region | West US |
| Gallery | `BatchTestGallery2` |
| Image definition | `BatchTestImage2` |
| Version | `1.0.0` |
| Publisher | `DufourSystems` |
| Offer | `GoldenBase` |
| SKU | `Ubuntu2204` |
| OS state | Generalized |
| Architecture | x64 |
| Hyper-V generation | V2 |

## Deployment Procedure

### 1. Identify the Source Managed Image

The managed-image inventory confirmed `Golden-Base-1.2-image-20251103141303` as the source.

*See Evidence:* [02-source-managed-image-inventory.png](../../screenshots/deployment/batch-deployment-phase-two/02-source-managed-image-inventory.png)

### 2. Create Gallery Version 1.0.0

The source resource ID was assigned to a PowerShell variable and passed to `az sig image-version create`. Azure created `BatchTestGallery2/BatchTestImage2/1.0.0` successfully and retained the authoritative managed image under `source.id`.

*See Evidence:* [03-gallery-image-version-created.png](../../screenshots/deployment/batch-deployment-phase-two/03-gallery-image-version-created.png)

### 3. Replicate the Version to Central US

The version publishing profile was updated to target West US and Central US. Azure returned successful provisioning, Trusted Launch validation, and the intended platform attributes.

*See Evidence:* [04-gallery-image-version-replicated.png](../../screenshots/deployment/batch-deployment-phase-two/04-gallery-image-version-replicated.png)

The Azure portal subsequently reported replication status `Completed` for both regions.

*See Evidence:* [10-gallery-image-version-replication-completed.png](../../screenshots/deployment/golden-image-management/10-gallery-image-version-replication-completed.png)

### 4. Deploy the Batch Client VMs

The Phase 2 client module used the full gallery version resource ID through `storageProfile.imageReference.id`. Six Central US client VMs were created from version `1.0.0`.

*See Evidence:* [28-successful-deployment-output-part-02.png](../../screenshots/deployment/batch-deployment-phase-two/28-successful-deployment-output-part-02.png)

*See Evidence:* [30-deployment-provisioning-succeeded.png](../../screenshots/deployment/batch-deployment-phase-two/30-deployment-provisioning-succeeded.png)

### 5. Deploy the Batch WireGuard VM

The Phase 3 WireGuard module used the same versioned gallery image ID. This batch VM was separate from the existing West US `WireGuardVM1`, which uses a Canonical marketplace image.

*See Evidence:* [22-deployment-output-resources.png](../../screenshots/deployment/batch-deployment-phase-three/22-deployment-output-resources.png)

*See Evidence:* [23-provisioning-state-succeeded.png](../../screenshots/deployment/batch-deployment-phase-three/23-provisioning-state-succeeded.png)

## Configuration Procedure

The Bicep VM modules accepted `sharedGalleryImageId` and supplied it to the VM storage profile:

```bicep
param sharedGalleryImageId string

storageProfile: {
  imageReference: {
    id: sharedGalleryImageId
  }
}
```

The final configuration referenced the immutable gallery path ending in:

```text
/galleries/BatchTestGallery2/images/BatchTestImage2/versions/1.0.0
```

The version was configured for generalized Linux, x64 architecture, V2 generation, and the West US and Central US targets. Publishing changed distribution and availability; it did not alter the guest configuration inherited from the managed image.

## Verification

Verification established that:

- The gallery version source was the authoritative managed image.
- Version `1.0.0` provisioned successfully.
- Trusted Launch validation succeeded.
- West US and Central US replication completed.
- The Phase 2 client deployment created the expected VM resources.
- The Phase 3 batch WireGuard deployment completed successfully.
- The authoritative managed image remained the operational source of record.

| Image path | Final status |
| --- | --- |
| `Golden-Base-1.2-image-20251103141303` | Authoritative operational source |
| `BatchTestGallery2/BatchTestImage2/1.0.0` | Historical batch-deployment derivative |

The recorded timeline is:

| Date | Event |
| --- | --- |
| 2025-11-03 | Authoritative managed image recorded with creation tag |
| 2026-06-25 | Gallery version `1.0.0` created and replicated to Central US |
| 2026-06-28 | Phase 2 client deployment completed successfully |
| 2026-07-08 | Phase 3 batch WireGuard deployment completed successfully |
| 2026-07-19 | Original-lab consumer inventory and baseline validation completed |

## Common Issues

### Unquoted PowerShell Variables

Early assignments omitted quotation marks, causing resource IDs to be interpreted as commands. The successful assignments used quoted strings.

### Inconsistent Gallery Values

Early attempts mixed gallery names, image definitions, and resource groups. The final lineage consistently used `TestGroup1`, `BatchTestGallery2`, `BatchTestImage2`, and version `1.0.0`.

### Malformed Region Syntax

One update used `centralus2`, which was not the intended target syntax. The successful update used `westus=1 centralus`.

### Gallery Image Reference Failure

The initial Bicep deployment failed while the gallery reference and parameter flow were being corrected. The final VM modules consumed the full versioned resource ID through `imageReference.id`.

### Authority Confusion

The gallery version existed for the batch-deployment demonstration. It did not supersede the source managed image.

## Lessons Learned

- Managed-image authority and gallery distribution are separate concerns.
- Immutable version IDs are appropriate for repeatable Bicep deployments.
- Gallery, definition, version, resource-group, and region values must remain consistent.
- Resource IDs assigned in PowerShell require quotation marks.
- Cross-region replication requires explicit validation before deployment.
- Temporary demonstration infrastructure should have a documented lineage and purpose.

## Related Documents

- [Golden Image Management](golden-image-management.md)
- [Golden Image Lifecycle Runbook](../../runbooks/golden-image-lifecycle-runbook.md)
- [Golden Image Command Reference](../../command-codex/system-specific/golden-image-management.md)


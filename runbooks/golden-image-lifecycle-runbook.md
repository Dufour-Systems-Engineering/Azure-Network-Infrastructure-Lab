# Golden Image Lifecycle Runbook

## Overview

This runbook defines the controlled lifecycle for reusable Linux images in the Azure Network Infrastructure Lab. It covers inventory, baseline validation, candidate preparation, image capture, promotion, gallery publication, rollback, and retirement.

## Purpose

The runbook protects the current authoritative baseline while providing a repeatable process for future replacement images and project-specific gallery derivatives.

## Business Rationale

A reusable image can affect several downstream VMs and deployment templates. Formal lifecycle controls reduce configuration drift, prevent accidental deletion, preserve rollback options, and keep operational images separate from temporary test derivatives.

The current authoritative image is `Golden-Base-1.2-image-20251103141303`. Its confirmed consumers are `TestClientVM1` through `TestClientVM6` and `NetMonVM1`. The gallery version `BatchTestGallery2/BatchTestImage2/1.0.0` is a historical batch-deployment derivative and is not the operational authority.

## Prerequisites

Before beginning an image lifecycle operation, confirm:

- Access to the correct Azure subscription and resource group.
- Permission to inspect or manage the relevant image resources.
- Administrative access to a confirmed image-based validation VM.
- The authoritative image name and full Azure resource ID.
- A current VM consumer inventory.
- The intended image purpose, target region, and version.
- An evidence-capture plan for portal views, terminal output, and transcripts.
- A rollback path that retains the current authoritative image.

For a future capture, also confirm:

- A dedicated candidate source VM exists.
- Intended updates and configuration changes are documented.
- Temporary files, credentials, and host-specific artifacts have been removed.
- The current approved Azure Linux generalization procedure has been reviewed.

## Procedure

### 1. Inventory the Current Image

1. Confirm the active Azure subscription.
2. Retrieve the authoritative image resource ID.
3. List VM names, regions, and source-image IDs.
4. Record confirmed consumers and marketplace-image exceptions.
5. Compare the inventory with the management document.

Expected state: the six client VMs and `NetMonVM1` reference the authoritative image. `WireGuardVM1` and `TestLinuxServer1` do not.

*See Evidence:* [03-authoritative-image-vm-consumer-inventory.png](../screenshots/deployment/golden-image-management/03-authoritative-image-vm-consumer-inventory.png)

### 2. Validate the Deployed Baseline

Use a confirmed image-based client that has not been intentionally reconfigured outside the baseline.

1. Confirm Azure reports the expected source image.
2. Confirm the guest reports Ubuntu 22.04 LTS.
3. Confirm `nfs-common` is installed.
4. Confirm `/etc/fstab` contains the expected NFS entry.
5. Confirm `srv-nfsclient.automount` is active.
6. Trigger access to `/srv/nfsclient`.
7. Confirm `findmnt` reports `10.0.0.4:/`, NFSv4.2, and the correct target.

*See Evidence:* [04-validation-vm-image-source.png](../screenshots/deployment/golden-image-management/04-validation-vm-image-source.png)

*See Evidence:* [07-validation-vm-nfs-automount-and-mount.png](../screenshots/deployment/golden-image-management/07-validation-vm-nfs-automount-and-mount.png)

### 3. Prepare a Candidate Replacement

1. Create a dedicated candidate source VM.
2. Apply only the intended baseline configuration.
3. Install current approved updates.
4. Validate required packages, services, and mounts.
5. Remove temporary files, credentials, host keys when required, and test data.
6. Record the candidate name, OS version, changes, and creation date.
7. Capture terminal transcripts and screenshots before generalization.

The existing source was generalized with `waagent`, but its exact command was not retained. A future capture must use the current approved Azure procedure and preserve the exact executed command as evidence.

### 4. Capture and Identify the Candidate

1. Complete the approved Linux generalization process.
2. Stop and deallocate the source VM as required.
3. Create a new managed image with an unambiguous, versioned name.
4. Apply project, environment, region, owner, purpose, and creation-date tags.
5. Record the new image resource ID.
6. Capture successful provisioning evidence.

Do not overwrite the identity or documentation of the current authority.

### 5. Validate the Candidate Image

1. Deploy a temporary VM from the candidate image.
2. Confirm its Azure source-image association.
3. Run the complete guest baseline validation.
4. Confirm network placement and administrative access.
5. Record failures and corrections.
6. Retain the evidence before removing the validation VM.

Image creation success alone is not sufficient for promotion.

### 6. Promote a New Authoritative Image

Promotion requires:

- Successful candidate deployment.
- Successful guest baseline validation.
- Completed documentation and evidence links.
- A confirmed consumer migration plan.
- An explicit decision that the candidate replaces the previous authority.

After approval:

1. Update the management document.
2. Update the Command Codex identifiers.
3. Update Bicep or other deployment references.
4. Deploy or rebuild consumers according to the approved plan.
5. Re-run the consumer inventory.
6. Retain the prior image until rollback is no longer required.

### 7. Publish a Gallery Derivative

Use a gallery derivative only when cross-region distribution, controlled versioning, or a separate project requires it.

1. Confirm the managed-image source ID.
2. Confirm the gallery and image definition.
3. Create a versioned gallery image.
4. Add only the required target regions and replica counts.
5. Wait for provisioning and replication to complete.
6. Record the source, version, regions, purpose, and intended consumers.
7. Validate a deployment from the exact gallery version.

Publishing does not make the gallery version authoritative unless promotion is separately approved.

### 8. Retire an Image or Gallery Version

1. Inventory VM and template references.
2. Confirm no required rebuild or rollback workflow depends on the image.
3. Confirm a validated replacement exists when necessary.
4. Preserve final evidence and lineage records.
5. Remove nested gallery resources in dependency order when deleting a gallery.
6. Verify removal through Azure inventory.

Do not delete an image solely because its original source VM was decommissioned.

## Verification

Complete the following checklist before closing the lifecycle operation:

- [ ] Image overview and tags were captured.
- [ ] Source-image ID was recorded.
- [ ] Consumer inventory was captured.
- [ ] A validation VM identifies the expected image.
- [ ] OS and required packages were validated.
- [ ] Persistent configuration was validated.
- [ ] Mount or service behavior was validated.
- [ ] Gallery source and target regions were recorded, when applicable.
- [ ] Sensitive information was redacted.
- [ ] Management, lineage, and command documentation were updated.

## Rollback Procedure

If a candidate or replacement fails validation:

1. Stop promotion and further rollout.
2. Keep the existing authoritative image unchanged.
3. Restore templates to the last validated image ID.
4. Re-run deployment validation and What-If checks.
5. Confirm consumers still reference the intended image.
6. Document the failure, impact, and corrective action.

If a gallery replication or deployment fails, retain the authoritative managed image and correct the derivative workflow without changing operational authority.

## Common Issues

### Missing Capture Evidence

Do not reconstruct an exact generalization command that was not retained. Label historical steps appropriately and capture the full future workflow.

### Consumer Inventory Mismatch

Do not infer image use from a VM's Linux role. Inspect `storageProfile.imageReference` and verify exceptions separately.

### Resource-ID Capitalization

Exact resource-ID comparisons can omit valid consumers when resource-group capitalization differs. Review the complete image-reference inventory.

### Gallery Deletion Failure

Azure prevents gallery deletion while nested image definitions or versions remain. Inventory and remove nested resources in dependency order.

### Authority Drift

Creating or replicating a gallery version does not automatically supersede the managed-image authority. Record promotion as a separate decision.

## Lessons Learned

- Evidence collection must begin before generalization and decommissioning.
- Candidate creation, validation, and promotion are separate lifecycle stages.
- The previous authority should remain available through the rollback window.
- Consumer inventories are required before promotion or retirement.
- Historical project derivatives must remain distinct from operational sources.

## Related Documents

- [Golden Image Management](../deployment/golden-image-management/golden-image-management.md)
- [Golden Image Lineage and Batch Gallery Migration](../deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md)
- [Golden Image Command Reference](../command-codex/system-specific/golden-image-management.md)


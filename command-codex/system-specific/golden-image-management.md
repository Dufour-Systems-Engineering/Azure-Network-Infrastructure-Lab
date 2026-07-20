# Golden Image Management Command Library

## Overview

This command reference records the Azure CLI, PowerShell, and Linux commands used to inventory the authoritative managed image, publish and replicate its Azure Compute Gallery derivative, inspect gallery resources, and validate the inherited Ubuntu/NFS baseline.

Sensitive subscription identifiers are replaced with `<subscription-id>`. This is a publication redaction of executed commands, not a newly designed command workflow.

## Scope

This document includes commands that were executed during the managed-image and gallery workflows. It records successful commands, their validation, and relevant failed or superseded forms under the applicable command entry.

The exact historical `waagent` generalization command is excluded because it was not retained.

## Command Groups

- Managed-image inventory.
- VM consumer inventory.
- Gallery version creation.
- Gallery replication and inspection.
- Ubuntu and NFS baseline validation.

# Command Entries

## List Managed Images in the Resource Group

### Command

```powershell
az image list --resource-group TestGroup1
```

### Purpose

Discover the managed images available in the source resource group before selecting the authoritative image.

### Context Used

Executed during the June 2026 Azure Compute Gallery preparation workflow before the source managed-image ID was assigned.

### Breakdown

| Element | Function |
| --- | --- |
| `az image list` | Lists managed-image resources. |
| `--resource-group TestGroup1` | Limits the inventory to the source image resource group. |

### Classification

Executed and validated.

### Risk Level

Low. This is a read-only resource inventory command.

### Why This Was Safe To Run

The command listed image resources without modifying the images or their consumers.

### Expected Result

The inventory should include `Golden-Base-1.2-image-20251103141303`.

### Actual Result / Validation

The authoritative managed image appeared in the resource-group inventory.

*See Evidence:* [02-source-managed-image-inventory.png](../../screenshots/deployment/batch-deployment-phase-two/02-source-managed-image-inventory.png)

### Common Mistakes

- Querying the batch deployment resource group instead of the source image resource group.
- Confusing a managed image with an Azure Compute Gallery image definition or version.
- Treating an inventory result as proof that a specific VM consumed the image.

### Related Syntax

- Azure CLI resource targeting.
- Azure CLI JSON output.

### Related Documents

- [Golden Image Management](../../deployment/golden-image-management/golden-image-management.md)
- [Golden Image Lineage and Batch Gallery Migration](../../deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md)

### Notes

Use `az image show` when one known managed image must be retrieved precisely.

## Retrieve the Authoritative Managed-Image ID

### Command

```powershell
$imageId = az image show `
    --resource-group TestGroup1 `
    --name Golden-Base-1.2-image-20251103141303 `
    --query id `
    --output tsv

$imageId
```

### Purpose

Retrieve the full Azure resource ID for the authoritative managed image and store it in PowerShell.

### Context Used

Used during the July 2026 consumer review to identify the managed image before inspecting VM image references.

### Breakdown

| Element | Function |
| --- | --- |
| `az image show` | Retrieves one managed-image resource. |
| `--resource-group TestGroup1` | Selects the image resource group. |
| `--name` | Selects the authoritative image. |
| `--query id` | Returns only the resource ID. |
| `--output tsv` | Returns an unquoted value suitable for a variable. |

### Classification

Executed and validated.

### Risk Level

Low. This is a read-only resource query.

### Why This Was Safe To Run

The command inspected one named image and did not modify Azure state.

### Expected Result

`$imageId` should end with:

```text
/images/Golden-Base-1.2-image-20251103141303
```

### Actual Result / Validation

The command returned the full managed-image resource ID successfully.

### Common Mistakes

- Using the source VM name instead of the managed-image name.
- Omitting `--output tsv` when the value will be reused directly.
- Publishing the returned subscription ID without redaction.

### Related Syntax

- PowerShell variable assignment.
- Azure CLI JMESPath queries.
- Azure CLI output formatting.

### Related Documents

- [Golden Image Management](../../deployment/golden-image-management/golden-image-management.md)

### Notes

The variable contains a sensitive subscription identifier and must be redacted in published evidence.

## Inventory VM Image References

### Command

```powershell
az vm list `
    --resource-group TestGroup1 `
    --query "[].{VM:name,Location:location,ImageId:storageProfile.imageReference.id}" `
    --output table
```

### Purpose

Display each VM's name, region, and managed-image resource ID when one is present.

### Context Used

Used to determine which original West US lab VMs actually consumed the authoritative image.

### Breakdown

| Element | Function |
| --- | --- |
| `az vm list` | Lists VMs in the selected scope. |
| `--resource-group TestGroup1` | Limits results to the lab resource group. |
| `[].{...}` | Projects selected properties for every VM. |
| `storageProfile.imageReference.id` | Returns a managed or gallery image ID when stored as an ID. |
| `--output table` | Produces a readable inventory. |

### Classification

Executed and validated.

### Risk Level

Low. This is a read-only inventory command.

### Why This Was Safe To Run

The command listed resource properties without changing VMs or image resources.

### Expected Result

`TestClientVM1` through `TestClientVM6` and `NetMonVM1` should display `Golden-Base-1.2-image-20251103141303` in `ImageId`.

### Actual Result / Validation

Seven VMs displayed the authoritative image ID. `WireGuardVM1` and `TestLinuxServer1` did not.

*See Evidence:* [03-authoritative-image-vm-consumer-inventory.png](../../screenshots/deployment/golden-image-management/03-authoritative-image-vm-consumer-inventory.png)

### Common Mistakes

The following form failed because `-r` was not recognized as the resource-group flag:

```powershell
az vm list -r TestGroup1
```

An exact full-ID comparison returned only `NetMonVM1` because equivalent IDs contained different resource-group capitalization:

```powershell
az vm list --resource-group TestGroup1 --query "[?storageProfile.imageReference.id=='$imageId'].{VM:name,Location:location,ImageId:storageProfile.imageReference.id}" --output table
```

The complete inventory was used instead of presenting that filter as reliable.

### Related Syntax

- Azure CLI JMESPath projection.
- Nested Azure resource properties.
- Case-sensitive string comparison.

### Related Documents

- [Golden Image Management](../../deployment/golden-image-management/golden-image-management.md)
- [Golden Image Lifecycle Runbook](../../runbooks/golden-image-lifecycle-runbook.md)

### Notes

Marketplace-image VMs may show publisher, offer, SKU, and version fields instead of a managed-image ID.

## Assign the Managed-Image Source ID

### Command

```powershell
$sourceImageID = "/subscriptions/<subscription-id>/resourceGroups/TestGroup1/providers/Microsoft.Compute/images/Golden-Base-1.2-image-20251103141303"

$sourceImageID
```

### Purpose

Store the source managed-image ID for reuse during gallery version creation.

### Context Used

Used during the June 2026 gallery publication workflow.

### Breakdown

| Element | Function |
| --- | --- |
| `$sourceImageID` | PowerShell variable used by the gallery command. |
| Quotation marks | Preserve the resource ID as one string. |
| `<subscription-id>` | Redacted subscription segment. |

### Classification

Executed and validated after correction.

### Risk Level

Low. Variable assignment changes only the local PowerShell session.

### Why This Was Safe To Run

The assignment did not call Azure or modify a resource.

### Expected Result

Printing `$sourceImageID` should return one complete Azure resource ID.

### Actual Result / Validation

The quoted assignment succeeded and was used by the successful gallery version creation.

### Common Mistakes

The unquoted form failed because PowerShell interpreted the resource ID as a command:

```powershell
$sourceImageID=/subscriptions/<subscription-id>/resourceGroups/TestGroup1/providers/Microsoft.Compute/images/Golden-Base-1.2-image-20251103141303
```

### Related Syntax

- PowerShell string literals.
- PowerShell variable assignment.

### Related Documents

- [Golden Image Lineage and Batch Gallery Migration](../../deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md)

### Notes

Always redact the subscription segment before publication.

## Create Gallery Image Version 1.0.0

### Command

```powershell
az sig image-version create `
    --gallery-image-definition BatchTestImage2 `
    --gallery-image-version 1.0.0 `
    --gallery-name BatchTestGallery2 `
    --resource-group TestGroup1 `
    --managed-image $sourceImageID
```

### Purpose

Create gallery version `1.0.0` from the authoritative managed image.

### Context Used

Used to make the West US image available to the separate batch-deployment workflow.

### Breakdown

| Flag | Function |
| --- | --- |
| `--gallery-image-definition` | Selects `BatchTestImage2`. |
| `--gallery-image-version` | Creates version `1.0.0`. |
| `--gallery-name` | Selects `BatchTestGallery2`. |
| `--resource-group` | Selects the gallery resource group. |
| `--managed-image` | Supplies the authoritative source image. |

### Classification

Executed and validated after earlier attempts were corrected.

### Risk Level

Medium. The command creates a persistent Azure image-version resource.

### Why This Was Safe To Run

The source, gallery, definition, version, and resource group were explicitly identified. The command created a derivative and did not alter the source image.

### Expected Result

Azure should return a version resource ending in `/BatchTestImage2/versions/1.0.0`, provisioning state `Succeeded`, and the managed image under `source.id`.

### Actual Result / Validation

Version `1.0.0` was created successfully from `Golden-Base-1.2-image-20251103141303`.

*See Evidence:* [03-gallery-image-version-created.png](../../screenshots/deployment/batch-deployment-phase-two/03-gallery-image-version-created.png)

### Common Mistakes

- Mixing `BatchTestGallery1` and `BatchTestGallery2`.
- Mixing `BatchTestImage1` and `BatchTestImage2`.
- Using the batch resource group instead of the gallery's actual resource group.
- Passing an empty or unquoted `$sourceImageID`.

### Related Syntax

- PowerShell line continuation.
- Azure resource IDs.
- Azure Compute Gallery versioning.

### Related Documents

- [Golden Image Lineage and Batch Gallery Migration](../../deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md)

### Notes

The operation copied the source image for distribution; it did not make guest-level changes.

## Replicate Gallery Version 1.0.0

### Command

```powershell
az sig image-version update `
    --resource-group TestGroup1 `
    --gallery-name BatchTestGallery2 `
    --gallery-image-definition BatchTestImage2 `
    --gallery-image-version 1.0.0 `
    --target-regions westus=1 centralus
```

### Purpose

Retain one West US replica and add Central US as a target region.

### Context Used

Used after gallery version creation to support the Central US batch-deployment environment required by regional quota limits.

### Breakdown

| Element | Function |
| --- | --- |
| `az sig image-version update` | Updates the publishing profile. |
| `westus=1` | Sets one West US replica. |
| `centralus` | Adds Central US using the accepted CLI form recorded in the transcript. |

### Classification

Executed and validated after correction.

### Risk Level

Medium. The command changes regional replication and can increase storage use.

### Why This Was Safe To Run

The command targeted one known version and the two intended lab regions. Replica scope remained limited.

### Expected Result

The publishing profile should contain West US and Central US and return successful provisioning.

### Actual Result / Validation

Azure reported successful provisioning and Trusted Launch validation. Portal status later showed both regions as `Completed`.

*See Evidence:* [04-gallery-image-version-replicated.png](../../screenshots/deployment/batch-deployment-phase-two/04-gallery-image-version-replicated.png)

*See Evidence:* [10-gallery-image-version-replication-completed.png](../../screenshots/deployment/golden-image-management/10-gallery-image-version-replication-completed.png)

### Common Mistakes

The following malformed attempt was superseded:

```powershell
az sig image-version update --resource-group TestGroup1 --gallery-name BatchTestGallery2 --gallery-image-definition BatchTestImage2 --gallery-image-version 1.0.0 --target-regions westus=2 centralus2
```

`centralus2` was not the intended target syntax.

### Related Syntax

- Azure CLI multi-value arguments.
- PowerShell line continuation.

### Related Documents

- [Golden Image Lineage and Batch Gallery Migration](../../deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md)

### Notes

Replication does not change which image is operationally authoritative.

## Retrieve and Inspect the Gallery Version ID

### Command

```powershell
$sharedGalleryImageId = az sig image-version show `
    --resource-group TestGroup1 `
    --gallery-name BatchTestGallery2 `
    --gallery-image-definition BatchTestImage2 `
    --gallery-image-version 1.0.0 `
    --query id `
    --output tsv

$sharedGalleryImageId

az resource show `
    --ids $sharedGalleryImageId `
    --query "{id:id, name:name, type:type}" `
    --output table
```

### Purpose

Retrieve the exact gallery version resource ID and confirm that it resolves to the intended Azure resource.

### Context Used

Used while preparing the gallery version for Bicep VM deployment.

### Breakdown

| Element | Function |
| --- | --- |
| `az sig image-version show` | Retrieves the named version. |
| `--query id --output tsv` | Returns the reusable version ID. |
| `az resource show --ids` | Resolves the ID as an Azure resource. |
| Projection query | Displays only ID, name, and type. |

### Classification

Executed and validated.

### Risk Level

Low. Both Azure commands are read-only.

### Why This Was Safe To Run

The commands inspected one known version and did not modify Azure state.

### Expected Result

The ID should end with `/galleries/BatchTestGallery2/images/BatchTestImage2/versions/1.0.0`, and the resource type should be `Microsoft.Compute/galleries/images/versions`.

### Actual Result / Validation

The correct version ID was returned and used by the Bicep deployment workflow.

### Common Mistakes

- Typing `--rsource-group` instead of `--resource-group`.
- Printing the misspelled variable `$sharedGallertyImageId`.
- Relying on a session variable without first verifying its value.

### Related Syntax

- Azure CLI queries.
- PowerShell variable reuse.
- Azure resource IDs.

### Related Documents

- [Golden Image Lineage and Batch Gallery Migration](../../deployment/golden-image-management/golden-image-lineage-and-batch-gallery-migration.md)

### Notes

The full ID was supplied to Bicep through `storageProfile.imageReference.id`.

## Validate the Inherited Ubuntu and NFS Baseline

### Command

```bash
cat /etc/os-release

dpkg-query -W -f='${Status}\t${Package}\t${Version}\n' nfs-common

grep -nE '^[[:space:]]*[^#].*[[:space:]]/srv/nfsclient[[:space:]]' /etc/fstab

systemctl status srv-nfsclient.automount --no-pager

timeout 10 ls -la /srv/nfsclient

findmnt --target /srv/nfsclient --output SOURCE,TARGET,FSTYPE,OPTIONS
```

### Purpose

Validate the operating system, installed NFS package, persistent mount entry, automount service, share accessibility, and active NFS mount on a confirmed image-based VM.

### Context Used

Executed on `TestClientVM1` after Azure confirmed that the VM used `Golden-Base-1.2-image-20251103141303`.

### Breakdown

| Command | Function |
| --- | --- |
| `cat /etc/os-release` | Reports the installed Ubuntu release. |
| `dpkg-query` | Confirms `nfs-common` package status and version. |
| `grep` | Finds the active `/srv/nfsclient` fstab entry. |
| `systemctl status` | Inspects the generated automount unit. |
| `timeout 10 ls -la` | Triggers and tests share access with a time limit. |
| `findmnt` | Reports source, target, filesystem, and options. |

### Classification

Executed and validated.

### Risk Level

Low. These commands inspect configuration and read directory contents.

### Why This Was Safe To Run

The commands did not modify packages, files, service definitions, or persistent mount configuration. Accessing `/srv/nfsclient` could activate the existing automount as designed. The timeout limited the duration of the share-access test.

### Expected Result

- Ubuntu 22.04 LTS.
- `install ok installed` for `nfs-common`.
- An fstab entry for `10.0.0.4:/` at `/srv/nfsclient`.
- `srv-nfsclient.automount` active.
- A successful directory listing.
- An NFSv4.2 mount from `10.0.0.4:/`.

### Actual Result / Validation

`TestClientVM1` reported Ubuntu 22.04.5 LTS, the installed NFS package, the intended fstab entry, an active automount unit, accessible NFS directories, and the expected NFSv4.2 mount.

*See Evidence:* [05-validation-vm-ubuntu-and-nfs-package.png](../../screenshots/deployment/golden-image-management/05-validation-vm-ubuntu-and-nfs-package.png)

*See Evidence:* [06-validation-vm-nfs-fstab-entry.png](../../screenshots/deployment/golden-image-management/06-validation-vm-nfs-fstab-entry.png)

*See Evidence:* [07-validation-vm-nfs-automount-and-mount.png](../../screenshots/deployment/golden-image-management/07-validation-vm-nfs-automount-and-mount.png)

### Common Mistakes

- Running the validation on `WireGuardVM1` or `TestLinuxServer1`, which are not image consumers.
- Treating guest configuration alone as proof of image inheritance.
- Omitting the `timeout` from a potentially stalled share-access test.

### Related Syntax

- Bash command arguments.
- Regular expressions with `grep`.
- `dpkg-query` formatting.
- systemd unit naming.

### Related Documents

- [Golden Image Management](../../deployment/golden-image-management/golden-image-management.md)
- [Golden Image Lifecycle Runbook](../../runbooks/golden-image-lifecycle-runbook.md)

### Notes

Pair this validation with Azure source-image evidence before claiming that the configuration was inherited from the image.

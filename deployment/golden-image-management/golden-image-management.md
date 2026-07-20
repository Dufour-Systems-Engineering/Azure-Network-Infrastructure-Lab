# Golden Image Management

## Overview

The Azure Network Infrastructure Lab uses `Golden-Base-1.2-image-20251103141303` as the authoritative managed-image baseline for reusable Ubuntu client systems. The image was captured from the generalized `Golden-Base-1.2` source VM and remains the operational source of record.

The baseline standardizes the Ubuntu release and NFS client configuration used by six Linux client VMs and `NetMonVM1`. An unchanged derivative was also published to Azure Compute Gallery for the separate batch-deployment project.

## Purpose

The managed image was created to:

- Reduce repetitive post-deployment configuration.
- Maintain a consistent Ubuntu and NFS client baseline.
- Provide a reusable deployment source for client and monitoring VMs.
- Support repeatable deployment and automation exercises.
- Preserve a clearly identified authoritative image while allowing project-specific derivatives.

## Prerequisites

The original image workflow required:

- Azure subscription and resource-group access.
- A configured Ubuntu 22.04 LTS source VM.
- Administrative SSH access to the source VM.
- Existing VNet and subnet infrastructure.
- A functional NFS server at `10.0.0.4`.
- The `nfs-common` package and validated NFS client configuration.
- Permission to create and inspect Azure managed images.

The confirmed authoritative image properties are:

| Setting | Value |
| --- | --- |
| Managed image | `Golden-Base-1.2-image-20251103141303` |
| Source VM | `Golden-Base-1.2` |
| Resource group | `TestGroup1` |
| Region | West US |
| Operating system | Linux / Ubuntu 22.04 LTS baseline |
| VM generation | V2 |
| Architecture | x64 |
| OS disk storage | Standard SSD LRS |
| Provisioning state | Succeeded |

## Deployment Procedure

The original source VM was prepared as a reusable Linux-client baseline. Project records confirm the following sequence:

1. `Golden-Base-1.2` was created as an Ubuntu 22.04 LTS VM.
2. Operating-system updates and required client configuration were applied.
3. NFS client integration was configured and validated.
4. The VM was generalized with `waagent`.
5. The generalized VM was captured as `Golden-Base-1.2-image-20251103141303`.
6. The source VM was decommissioned after image capture.
7. The managed image became the deployment source for the Linux client fleet and `NetMonVM1`.

The exact `waagent` command and original capture screenshots were not retained because the work predated the repository's formal evidence standards. The sequence above is confirmed project history rather than a screenshot-validated procedure.

*See Evidence:* [01-authoritative-managed-image-overview.png](../../screenshots/deployment/golden-image-management/01-authoritative-managed-image-overview.png)

The image tags identify the project, purpose, Linux-client environment, West US region, and creation date of November 3, 2025.

*See Evidence:* [02-authoritative-managed-image-tags.png](../../screenshots/deployment/golden-image-management/02-authoritative-managed-image-tags.png)

## Configuration Procedure

The image baseline contains:

- Ubuntu 22.04 LTS.
- The `nfs-common` package.
- Persistent NFS client configuration.
- A systemd-triggered NFS automount.
- The lab's standard Linux client settings present at capture time.

The persistent mount entry is:

```text
10.0.0.4:/  /srv/nfsclient  nfs  vers=4.2,_netdev,nofail,x-systemd.automount  0 0
```

The source configuration was originally applied with cloud-init before generalization. This allowed systems deployed from the image to receive the established NFS client baseline without repeating the original configuration process.

For the batch-deployment project, the authoritative image was published without guest-level changes through this lineage:

```text
Golden-Base-1.2-image-20251103141303
└── BatchTestGallery2
    └── BatchTestImage2
        └── Version 1.0.0
```

Version `1.0.0` was replicated from West US to Central US because regional quota limits required the recreated batch environment to use a different region. The separate gallery path also kept the batch/test environment distinct from the operational lab. It did not replace the authoritative managed image.

## Verification

### Managed Image Verification

Azure reported the managed image in West US with provisioning state `Succeeded`, Linux OS type, V2 generation, and `Golden-Base-1.2` as its source VM.

*See Evidence:* [01-authoritative-managed-image-overview.png](../../screenshots/deployment/golden-image-management/01-authoritative-managed-image-overview.png)

### Consumer Verification

Azure resource inventory confirmed seven current consumers:

- `TestClientVM1` through `TestClientVM6`.
- `NetMonVM1`.

*See Evidence:* [03-authoritative-image-vm-consumer-inventory.png](../../screenshots/deployment/golden-image-management/03-authoritative-image-vm-consumer-inventory.png)

`TestClientVM1` was selected as the representative validation system. Its Azure overview identifies `Golden-Base-1.2-image-20251103141303` as its source image.

*See Evidence:* [04-validation-vm-image-source.png](../../screenshots/deployment/golden-image-management/04-validation-vm-image-source.png)

### Configuration Verification

Validation on `TestClientVM1` confirmed:

- Ubuntu 22.04.5 LTS.
- `nfs-common` installed.
- The expected `/etc/fstab` entry.
- An active `srv-nfsclient.automount` unit.
- Successful access to `/srv/nfsclient`.
- An active NFSv4.2 mount from `10.0.0.4:/`.

*See Evidence:* [05-validation-vm-ubuntu-and-nfs-package.png](../../screenshots/deployment/golden-image-management/05-validation-vm-ubuntu-and-nfs-package.png)

*See Evidence:* [06-validation-vm-nfs-fstab-entry.png](../../screenshots/deployment/golden-image-management/06-validation-vm-nfs-fstab-entry.png)

*See Evidence:* [07-validation-vm-nfs-automount-and-mount.png](../../screenshots/deployment/golden-image-management/07-validation-vm-nfs-automount-and-mount.png)

The Azure image association and guest-side validation form the evidence chain for the inherited baseline. Guest configuration by itself would prove current state, but not its image source.

### Exception Verification

`TestLinuxServer1` and `WireGuardVM1` do not use the managed-image baseline:

- `TestLinuxServer1` uses a Canonical Ubuntu 22.04 marketplace image.
- `WireGuardVM1` uses a Canonical Ubuntu 24.04 marketplace image.

*See Evidence:* [08-testlinuxserver-marketplace-image-exception.png](../../screenshots/deployment/golden-image-management/08-testlinuxserver-marketplace-image-exception.png)

*See Evidence:* [09-wireguard-marketplace-image-exception.png](../../screenshots/deployment/golden-image-management/09-wireguard-marketplace-image-exception.png)

### Gallery Replication Verification

Azure reported replication status `Completed` for West US and Central US for gallery version `1.0.0`.

*See Evidence:* [10-gallery-image-version-replication-completed.png](../../screenshots/deployment/golden-image-management/10-gallery-image-version-replication-completed.png)

## Common Issues

### Missing Original Capture Evidence

The original image-capture screenshots and exact `waagent` command were not retained. This limitation is documented explicitly rather than reconstructed. Current Azure state, consumer association, and representative guest validation provide evidence for the image's present role and baseline.

### Incorrect Consumer Assumption

Earlier project context described all nine original Linux lab VMs as image consumers. Azure inventory disproved that assumption. The verified count is seven; `WireGuardVM1` and `TestLinuxServer1` are exceptions.

### Full Resource-ID Comparison

An exact CLI comparison initially returned only `NetMonVM1` because equivalent image IDs contained different resource-group capitalization. The complete VM image-reference inventory was used to verify all consumers.

### Authority Confusion

The batch gallery version was a project-specific distribution copy. It must not be described as replacing the original managed image or becoming a general operational utility.

## Lessons Learned

- Managed images reduce repetitive configuration across similar VMs.
- Image-source evidence and guest validation should be preserved together.
- Resource-ID comparisons must account for capitalization differences.
- Consumer scope should be verified through Azure rather than inferred from VM role.
- Gallery publication and operational authority are separate decisions.
- Capture evidence should be collected before the source VM is generalized and decommissioned.

## Related Documents

- [Golden Image Lifecycle Runbook](../../runbooks/golden-image-lifecycle-runbook.md)
- [Golden Image Lineage and Batch Gallery Migration](golden-image-lineage-and-batch-gallery-migration.md)
- [Golden Image Command Reference](../../command-codex/system-specific/golden-image-management.md)


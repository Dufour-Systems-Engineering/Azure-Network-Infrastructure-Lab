# Golden Image Management

## Overview

A standardized Ubuntu 22.04 LTS virtual machine was prepared and captured as a reusable managed image to support rapid deployment of Linux client systems within the Azure Network Infrastructure Lab. The image provided a consistent operating system baseline, preconfigured NFS client integration, and standardized deployment settings for all future client virtual machines.

## Purpose

The purpose of the managed image was to eliminate repetitive post-deployment configuration tasks and ensure that newly deployed Linux client systems shared a common configuration baseline.

Key objectives included:

* Standardizing operating system deployment.
* Automating NFS client configuration.
* Reducing deployment time for additional client systems.
* Improving consistency across the client fleet.
* Supporting future scaling and automation efforts.

## Prerequisites

The following resources were required before image creation:

* Azure subscription and resource group access.
* Existing virtual network infrastructure.
* Functional NFS server deployment.
* Ubuntu 22.04 LTS source virtual machine.
* Azure managed image permissions.
* SSH administrative access.

The source virtual machine used for image creation was:

| Setting          | Value            |
| ---------------- | ---------------- |
| Computer Name    | Golden-Base-1.2  |
| Operating System | Ubuntu 22.04 LTS |
| VM Generation    | Gen2             |
| Architecture     | x64              |
| Size             | Standard B2s     |
| Private IP       | 10.0.0.23        |
| Virtual Network  | TestVNet1        |
| Subnet           | TestSubNet2      |

## Deployment Procedure

A baseline Linux client virtual machine was created and configured prior to image capture.

The source system was configured with:

* Ubuntu 22.04 LTS.
* Operating system updates.
* NFS client package installation.
* Standardized network placement.
* Daily auto-shutdown policy.
* NFS automount configuration.

The NFS client configuration was deployed through cloud-init and configured the client to automatically mount the NFS root export located on the NFS server at 10.0.0.4.

After validation was completed, the source virtual machine was captured as a managed image named **Golden-Base-1.2** and retained as the deployment source for future client virtual machines.

*See Evidence:* [01-managed-image-overview.png](../screenshots/deployment/golden-image-management/01-managed-image-overview.png)

## Configuration Procedure

Cloud-init was used to automate NFS client configuration during deployment.

The configuration performed the following actions:

1. Updated package repositories.
2. Installed the `nfs-common` package.
3. Added a persistent NFS mount entry to `/etc/fstab`.
4. Enabled systemd automount functionality for the NFS share.

The deployed configuration added the following NFS mount:

```text
10.0.0.4:/  /srv/nfsclient  nfs  vers=4.2,_netdev,nofail,x-systemd.automount  0 0
```

This ensured all virtual machines deployed from the image inherited a consistent NFS client configuration without requiring additional manual configuration.

## Verification

Because the original image capture process occurred before repository evidence collection standards were established, image-capture screenshots were not retained.

Validation was instead performed by deploying a new virtual machine from the managed image and verifying that the expected configuration was inherited successfully.

Validation checks included:

### Managed Image Verification

The managed image was confirmed to exist within Azure and was available as a deployment source.

*See Evidence:* [01-managed-image-overview.png](../screenshots/deployment/golden-image-management/01-managed-image-overview.png)

### Deployment Verification

A validation virtual machine was deployed from the managed image.

The deployment confirmed:

* Successful image provisioning.
* Correct operating system deployment.
* Proper image association.

*See Evidence:* [02-validation-vm-overview.png](../screenshots/deployment/golden-image-management/02-validation-vm-overview.png)

### Network Placement Verification

The validation VM was confirmed to reside within the expected virtual network and subnet.

*See Evidence:* [03-validation-vm-networking.png](../screenshots/deployment/golden-image-management/03-validation-vm-networking.png)

### Configuration Verification

The deployed VM inherited the expected configuration baseline.

Validation included:

* `/etc/fstab` verification.
* NFS client configuration verification.
* Hostname validation.
* IP address validation.
* NFS mount verification.

*See Evidence:* [04-validation-vm-configuration-validation.png](../screenshots/deployment/golden-image-management/04-validation-vm-configuration-validation.png)

## Common Issues

### Missing Image Capture Evidence

The original image capture process was completed before formal repository screenshot standards were implemented.

As a result, screenshots of the capture workflow were not retained.

This limitation was mitigated by deploying a validation VM from the managed image and confirming successful inheritance of all required configuration settings.

### Cloud-Init Validation

Azure does not expose the original cloud-init contents through standard portal views after deployment.

Validation was therefore performed through configuration inheritance testing on deployed virtual machines.

## Lessons Learned

* Managed images significantly reduce deployment effort when building multiple Linux client systems.
* Cloud-init provides an effective mechanism for standardizing Linux configuration at scale.
* Validation of deployed systems is more valuable than preserving every deployment step.
* Repository evidence standards should be established before implementation work begins.
* Standardized images simplify future automation and fleet expansion efforts.

## Related Documents

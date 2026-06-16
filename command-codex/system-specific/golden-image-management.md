# Golden Image Management Command Library

## Overview

This document preserves commands used to validate the Golden Image Management workflow in the Azure Network Infrastructure Lab.

The golden image workflow used a standardized Ubuntu 22.04 LTS VM as a reusable managed image. A validation VM was deployed from that image to confirm that the expected configuration baseline was inherited successfully.

## Purpose

This document explains the commands used to verify inherited configuration on a VM deployed from the golden image.

## Scope

This document covers:

* `/etc/fstab` validation
* NFS client mount validation
* VM IP address validation

This document does not include commands that were not shown in the source material.

## Source Material

Commands were compiled from:

* `deployment/golden-image-management.md`
* Golden Image Management validation screenshots

## Command Groups

1. Filesystem Configuration Validation
2. NFS Mount Validation
3. Network Validation

---

# Filesystem Configuration Validation

## View Filesystem Table

### Classification

Validation
Evidence Gathering

### Command

```bash
cat /etc/fstab
```

### Purpose

Displays the contents of the Linux filesystem table.

### Context Used

This command was used to verify that the validation VM inherited the expected persistent NFS mount entry from the golden image baseline.

### Breakdown

* `cat` = prints file contents to the terminal.
* `/etc/fstab` = Linux filesystem table used to define persistent mounts.

### Common Mistakes

* Editing `/etc/fstab` when only viewing it is needed.
* Assuming the file entry proves the mount is active.
* Missing commented-out lines versus active configuration lines.

### Related Syntax

* [Bash Syntax Reference](../syntax/bash-syntax.md)

---

# NFS Mount Validation

## Check NFS Client Mount

### Classification

Validation
Evidence Gathering

### Command

```bash
findmnt /srv/nfsclient
```

### Purpose

Checks whether `/srv/nfsclient` is mounted and displays mount information.

### Context Used

This command was used to verify the NFS client mount inherited from the golden image configuration.

### Breakdown

* `findmnt` = displays mounted filesystems.
* `/srv/nfsclient` = local NFS client mount point.

### Common Mistakes

* Checking the wrong mount path.
* Assuming the directory exists means the NFS share is mounted.
* Forgetting that systemd automount may mount the path when accessed.

### Related Syntax

* [Bash Syntax Reference](../syntax/bash-syntax.md)

---

# Network Validation

## Display Assigned IP Addresses

### Classification

Validation
Evidence Gathering

### Command

```bash
hostname -I
```

### Purpose

Displays the IP addresses assigned to the Linux VM.

### Context Used

This command was used to validate the deployed VM’s network identity after deployment from the managed image.

### Breakdown

* `hostname` = displays or manages system hostname information.
* `-I` = prints all assigned IP addresses.

### Common Mistakes

* Using lowercase `-i` instead of uppercase `-I`.
* Assuming the first IP address shown is always the expected Azure private IP.
* Missing additional IP addresses if multiple interfaces are present.

### Related Syntax

* [Bash Syntax Reference](../syntax/bash-syntax.md)

---

## Related Documents

* [Golden Image Management](../../deployment/golden-image-management.md)
* [Bash/Linux Command Reference](../bash-linux/bash-linux.md)
* [Bash Syntax Reference](../syntax/bash-syntax.md)

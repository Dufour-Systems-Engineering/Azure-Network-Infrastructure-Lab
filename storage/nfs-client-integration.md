# NFS Client Integration

## Overview

This document describes how the Linux client VM fleet was integrated with the NFS server in the Azure Network Infrastructure Lab. The NFS client configuration allows Linux client systems to consume shared storage from `TestLinuxServer1` across the private Azure virtual network.

## Purpose

The purpose of NFS client integration is to provide consistent shared storage access for Linux client VMs. This supports centralized file access, repeatable client configuration, and validation of storage consumption across the lab client fleet.

## Prerequisites

* Azure resource group: `TestGroup1`
* Virtual network: `TestVNet1`
* NFS server: `TestLinuxServer1`
* NFS server private IP: `10.0.0.4`
* Client VM used for validation: `TestClientVM1`
* Client VM private IP: `10.0.0.21`
* Client subnet: `TestSubNet2`
* Client subnet CIDR: `10.0.0.16/28`
* NFS server exports configured under `/srv/nfs`
* NFS client mount point: `/srv/nfsclient`
* Network access allowed between the client subnet and NFS server

## Deployment Procedure

NFS client support was installed across all six Linux client VMs in the lab so they could mount shared exports from `TestLinuxServer1`. Validation screenshots were captured from `TestClientVM1`, which was used as the representative client for documenting the deployment.

The client package validation confirmed the presence of NFS support libraries and common client support files:

* `libnfsidmap1`
* `nfs-common`

*See Evidence:* [01-client-packages-installed.png](../screenshots/storage/nfs-client-integration/01-client-packages-installed.png)

The NFS client mount point was configured at:

```text
/srv/nfsclient
```

Each client system was configured to mount the NFSv4 export root from:

```text
10.0.0.4:/
```

This allows the client VMs to consume the shared export tree provided by `TestLinuxServer1`.

## Configuration Procedure

Persistent NFS mounting was configured through `/etc/fstab` on all six client VMs.

The configured mount entry points each client to the NFS server export root and mounts it locally at `/srv/nfsclient`:

```text
10.0.0.4:/ /srv/nfsclient nfs vers=4.2,_netdev,nofail,x-systemd.automount 0 0
```

The mount uses the following options:

* `vers=4.2` to use NFS version 4.2
* `_netdev` to indicate the filesystem depends on network availability
* `nofail` to prevent boot failure if the mount is unavailable
* `x-systemd.automount` to allow systemd-managed automount behavior

*See Evidence:* [03-fstab-configuration.png](../screenshots/storage/nfs-client-integration/03-fstab-configuration.png)

The active mount state was verified from the client system. The output shows systemd automount handling `/srv/nfsclient`, confirming the mount path is registered and managed by the client OS.

*See Evidence:* [02-active-nfs-mount.png](../screenshots/storage/nfs-client-integration/02-active-nfs-mount.png)

## Verification

Client-side verification was performed from `TestClientVM1` as a representative member of the six-client fleet.

Filesystem capacity was checked using `df -h` to review local disk and mounted filesystem state.

*See Evidence:* [04-filesystem-capacity.png](../screenshots/storage/nfs-client-integration/04-filesystem-capacity.png)

Directory access was verified by listing the mounted NFS export tree under:

```text
/srv/nfsclient
```

The client was able to browse shared directories, including:

* `BackUp`
* `Misc`
* `Test`
* `clients`
* `conf`
* `home`

The client was also able to view per-client directory structures for the VM fleet.

*See Evidence:* [05-directory-access-validation.png](../screenshots/storage/nfs-client-integration/05-directory-access-validation.png)

Write access was validated by creating a test file inside the mounted NFS share. Initial write attempts as the regular user were denied, confirming that permissions were enforced. The file was successfully created using elevated permissions, then removed after validation.

This confirmed both share accessibility and permission behavior.

*See Evidence:* [06-client-write-validation.png](../screenshots/storage/nfs-client-integration/06-client-write-validation.png)

Remote filesystem readiness was validated using the systemd remote filesystem target.

The `remote-fs.target` service showed an active state, confirming that the system reached the remote filesystem target during boot/runtime operation.

*See Evidence:* [07-automount-validation.png](../screenshots/storage/nfs-client-integration/07-automount-validation.png)

## Common Issues

NFS client integration depends on both Linux configuration and Azure network access. If the mount path is configured correctly but inaccessible, the issue may be related to NFS export permissions, NSG rules, client subnet access, or server-side export configuration.

Because the clients use `x-systemd.automount`, mount behavior may appear different from a traditional always-mounted filesystem. The mount is persistent through `/etc/fstab`, but systemd manages access to the mount path through automount behavior.

Permission-denied messages during write testing do not necessarily indicate a broken mount. In this lab, the regular user was denied write access to the tested location, while elevated permissions were able to create and remove the test file. This confirms the share was accessible while still enforcing filesystem permissions.

## Lessons Learned

Deploying NFS client support across all six Linux client VMs demonstrated the value of standardized configuration. Using the same mount point, mount options, and NFS version across the fleet simplified deployment and troubleshooting.

NFS client integration also highlighted the difference between persistent mount configuration and active filesystem access. The `/etc/fstab` entry provides persistence, while `x-systemd.automount` allows the system to manage when the remote filesystem is accessed.

Validating the integration required more than checking `/etc/fstab`. Package state, active mount behavior, directory visibility, write behavior, and systemd remote filesystem status all provided useful evidence.

The permission-denied result during regular-user write testing was useful because it showed that access controls were active rather than completely open.

## Related Documents

# NFS Exports and Permissions

## Overview

This document covers the NFS export configuration and permission model used by the Azure Linux infrastructure lab. The NFS server provides shared storage from `TestLinuxServer1` to client VMs through NFSv4, using `/srv/nfs` as the server-side export root and `/srv/nfsclient` as the standard client-side mount point.

The configuration includes both shared directories and client-specific export paths. Export access is restricted by client subnet and individual client IP addresses.

## Purpose

The purpose of this configuration is to provide centralized Linux file sharing for internal Azure client VMs while maintaining a consistent export structure and predictable client access paths.

This supports:

* Shared storage access for Linux client systems.
* Client-specific NFS directories.
* Persistent client mounts through `/srv/nfsclient`.
* Validation of NFS export visibility, active export state, and write behavior.
* A repeatable permission model for future client expansion.

## Prerequisites

The following resources and conditions are required before validating NFS exports and permissions:

* `TestLinuxServer1` deployed and reachable inside the Azure VNet.
* NFS server packages installed and configured.
* NFSv4 export root created under `/srv/nfs`.
* Client VM deployed and reachable from the NFS server subnet.
* Client NFS packages installed.
* Client mount point standardized as `/srv/nfsclient`.
* Network Security Group rules allowing NFS traffic between client VMs and the NFS server.
* SSH access to both the NFS server and at least one client VM.

## Deployment Procedure

The NFS export structure is hosted from the server-side directory:

```bash
/srv/nfs
```

The export root contains shared directories and client-specific directories:

```text
/srv/nfs
├── BackUp
├── Misc
├── Test
├── clients
│   ├── vm1
│   ├── vm2
│   ├── vm3
│   ├── vm4
│   ├── vm5
│   └── vm6
├── conf
└── home
```

The primary export configuration is stored in:

```bash
/etc/exports
```

The NFS server exports the root path and supporting subdirectories to the client subnet. Individual client directories are also mapped to specific client IP addresses.

*See Evidence:* [01-nfs-directory-permissions.png](../screenshots/storage/nfs-exports-and-permissions/01-nfs-directory-permissions.png)

## Configuration Procedure

The NFS export file defines the active export policy for the server.

The root export is configured from:

```bash
/srv/nfs
```

The NFSv4 root export uses `fsid=0` and `crossmnt`, allowing clients to mount the exported NFS tree from a single root path.

The shared export paths include:

```bash
/srv/nfs/home
/srv/nfs/BackUp
/srv/nfs/Misc
/srv/nfs/Test
```

The client-specific export paths include:

```bash
/srv/nfs/clients/vm1
/srv/nfs/clients/vm2
/srv/nfs/clients/vm3
/srv/nfs/clients/vm4
/srv/nfs/clients/vm5
/srv/nfs/clients/vm6
```

Each client-specific directory is mapped to its corresponding client IP address:

```text
vm1 -> 10.0.0.21
vm2 -> 10.0.0.22
vm3 -> 10.0.0.23
vm4 -> 10.0.0.24
vm5 -> 10.0.0.25
vm6 -> 10.0.0.26
```

The export options include read/write access and synchronous writes:

```text
rw,sync,no_subtree_check
```

Shared export paths also use `crossmnt` where nested mount traversal is required.

*See Evidence:* [02-nfs-exports-file.png](../screenshots/storage/nfs-exports-and-permissions/02-nfs-exports-file.png)

## Verification

### Server-Side Directory and Permission Validation

The server export directory was reviewed using:

```bash
sudo ls -lah /srv/nfs
sudo find /srv/nfs -maxdepth 2 -type d -exec ls -ld {} \;
```

The output confirmed that the export root exists and contains the expected shared and client-specific directories.

Several exported directories are owned by `nobody:nogroup`, which is expected in this lab because the export model uses NFS identity mapping behavior rather than local named user ownership for every exported path.

*See Evidence:* [01-nfs-directory-permissions.png](../screenshots/storage/nfs-exports-and-permissions/01-nfs-directory-permissions.png)

### Active Export Validation

The active exports were reviewed using:

```bash
sudo exportfs -v
```

The output confirmed that the configured exports were actively loaded by the NFS server.

The active export list showed:

* `/srv/nfs` exported as the NFSv4 root.
* Shared directories exported to the client subnet.
* Client-specific directories exported to individual client IP addresses.
* NFS export options applied as expected.

*See Evidence:* [03-exportfs-active-exports.png](../screenshots/storage/nfs-exports-and-permissions/03-exportfs-active-exports.png)

### Client Mount Validation

The client VM mount state was validated from `TestClientVM1` using:

```bash
sudo findmnt /srv/nfsclient
df -hT /srv/nfsclient
```

The output confirmed that the client mounted the NFS export at:

```bash
/srv/nfsclient
```

The mount was confirmed as NFSv4 with the server address:

```text
10.0.0.4
```

The client address was shown as:

```text
10.0.0.21
```

This confirmed that `TestClientVM1` mounted the NFS export from `TestLinuxServer1` over the internal Azure network.

*See Evidence:* [04-client-mounted-export.png](../screenshots/storage/nfs-exports-and-permissions/04-client-mounted-export.png)

### Client Write Validation

Client-side write behavior was tested from `TestClientVM1` using:

```bash
echo "nfs permission validation $(hostname) $(date)" | sudo tee /srv/nfsclient/nfs-permission-test.txt
cat /srv/nfsclient/nfs-permission-test.txt
ls -lah /srv/nfsclient/nfs-permission-test.txt
sudo rm /srv/nfsclient/nfs-permission-test.txt
```

The test confirmed that the mounted NFS export accepted a client-side file creation, read, listing, and cleanup operation.

Because the write test used `sudo tee`, this validates elevated administrative write access through the NFS mount. It does not validate standard non-privileged user write access.

*See Evidence:* [05-client-write-permission-validation.png](../screenshots/storage/nfs-exports-and-permissions/05-client-write-permission-validation.png)

## Common Issues

### Export File Does Not Match Active Exports

Editing `/etc/exports` does not automatically guarantee that the live NFS export table has been refreshed.

If `/etc/exports` is changed, reload the export table:

```bash
sudo exportfs -ra
```

Then verify the active export state:

```bash
sudo exportfs -v
```

### Client Mount Exists but Write Fails

If the client can mount the export but cannot write to it, check:

* Server-side directory ownership.
* Server-side directory permissions.
* Export options in `/etc/exports`.
* Whether the test is being run as a normal user or with elevated permissions.
* Whether root squashing is enabled or disabled for the relevant export.
* Whether the client is mounting the expected export path.

### Wrong Client IP Assigned to Export

Client-specific exports depend on the client VM retaining the expected private IP address.

For example:

```text
/srv/nfs/clients/vm1 -> 10.0.0.21
```

If a client NIC receives a different private IP address, the matching client-specific export may no longer apply correctly.

### Mount Point Confusion

The client-side standard for this lab is:

```bash
/srv/nfsclient
```

Older or temporary mount paths should not be used in final validation unless the document is specifically describing troubleshooting or migration.

## Lessons Learned

NFS validation should include both configuration evidence and live state evidence. The `/etc/exports` file shows the intended configuration, but `sudo exportfs -v` confirms what the NFS server is actively exporting.

Client validation should also prove that the mount is active from the client perspective. The `findmnt` and `df -hT` commands confirm that the client is using the expected NFS mount point and that the mounted filesystem is visible to the operating system.

Permission testing should be described accurately. A write test performed with `sudo` proves administrative write access through the mounted export, but it should not be described as standard user write validation.

The final screenshot set avoids duplication by using one detailed permission screenshot instead of keeping a separate basic `/srv/nfs` listing.

## Related Documents

* [NFS Server Deployment](nfs-server-deployment.md)
* [NFS Client Integration](nfs-client-integration.md)
* [NSG and ASG Implementation](../network/nsg-asg-implementation.md)
* [Private DNS Implementation](../network/private-dns-implementation.md)
* [Bash/Linux Command Reference](../command-codex/bash-linux/bash-linux.md)

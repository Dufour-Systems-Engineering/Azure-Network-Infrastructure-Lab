# NFS Server Deployment

## Overview

This document describes the deployment and configuration of the NFS server used by the Azure Network Infrastructure Lab. The NFS server provides centralized Linux file sharing for the client VM fleet inside the private Azure virtual network.

## Purpose

The purpose of the NFS server is to provide shared storage services to Linux client systems in the lab. This supports centralized file access, repeatable client configuration, and storage consumption across multiple Azure-hosted Linux virtual machines.

## Prerequisites

* Azure resource group: `TestGroup1`
* Virtual network: `TestVNet1`
* Server subnet: `TestSubNet1`
* NFS server VM: `TestLinuxServer1`
* NFS server private IP: `10.0.0.4`
* Client subnet: `10.0.0.16/28`
* NFS access allowed through the lab network security configuration
* Administrative SSH access to `TestLinuxServer1`

## Deployment Procedure

The NFS server was deployed on `TestLinuxServer1`, an Ubuntu Linux VM located in the infrastructure subnet.

NFS server packages were installed on the system, including the NFS kernel server and supporting NFS common libraries.

Installed packages included:

* `libnfsidmap1`
* `nfs-common`
* `nfs-kernel-server`

*See Evidence:* [01-nfs-packages-installed.png](../screenshots/storage/nfs-server-deployment/01-nfs-packages-installed.png)

After installation, the NFS server service was enabled and started using systemd.

The service was verified as loaded and enabled under:

```text
nfs-server.service
```

*See Evidence:* [02-nfs-service-running.png](../screenshots/storage/nfs-server-deployment/02-nfs-service-running.png)

## Configuration Procedure

The NFS export root was configured under:

```text
/srv/nfs
```

The directory structure includes shared folders and client-specific directories for the Linux VM fleet.

Configured top-level directories include:

* `/srv/nfs/home`
* `/srv/nfs/BackUp`
* `/srv/nfs/Misc`
* `/srv/nfs/Test`
* `/srv/nfs/clients`
* `/srv/nfs/conf`

Client-specific directories were created for:

* `/srv/nfs/clients/vm1`
* `/srv/nfs/clients/vm2`
* `/srv/nfs/clients/vm3`
* `/srv/nfs/clients/vm4`
* `/srv/nfs/clients/vm5`
* `/srv/nfs/clients/vm6`

Each client directory includes subfolders for configuration, home data, and project files.

*See Evidence:* [03-nfs-directory-structure.png](../screenshots/storage/nfs-server-deployment/03-nfs-directory-structure.png)

The NFS exports were defined in:

```text
/etc/exports
```

The root NFS export was configured with `fsid=0` and `crossmnt` to support NFSv4-style access through a unified export tree.

The shared directories were exported to the client subnet:

```text
10.0.0.16/28
```

Client-specific directories were restricted to individual client VM IP addresses:

* `10.0.0.21`
* `10.0.0.22`
* `10.0.0.23`
* `10.0.0.24`
* `10.0.0.25`
* `10.0.0.26`

*See Evidence:* [04-exports-configuration.png](../screenshots/storage/nfs-server-deployment/04-exports-configuration.png)

After updating `/etc/exports`, the active export table was verified using `exportfs`.

*See Evidence:* [05-exportfs-active-exports.png](../screenshots/storage/nfs-server-deployment/05-exportfs-active-exports.png)

## Verification

NFS server configuration was verified using local export inspection from `TestLinuxServer1`.

The server successfully advertised the configured exports through `showmount`.

Validated exports included:

* `/srv/nfs`
* `/srv/nfs/home`
* `/srv/nfs/BackUp`
* `/srv/nfs/Misc`
* `/srv/nfs/Test`
* `/srv/nfs/clients/vm1`
* `/srv/nfs/clients/vm2`
* `/srv/nfs/clients/vm3`
* `/srv/nfs/clients/vm4`
* `/srv/nfs/clients/vm5`
* `/srv/nfs/clients/vm6`

*See Evidence:* [06-nfs-server-validation.png](../screenshots/storage/nfs-server-deployment/06-nfs-server-validation.png)

## Common Issues

NFS server deployment requires both Linux-level configuration and Azure network access to be correct. If exports are configured correctly but clients cannot connect, the issue may be related to subnet routing, NSG rules, ASG membership, or client-side mount configuration.

Export definitions must also be reloaded after changes to `/etc/exports`. If export changes are not visible, `exportfs` should be used to confirm the active export state.

Client-specific exports require accurate static IP assignments. If a client VM is rebuilt or its private IP changes, the matching export rule may need to be updated.

## Lessons Learned

The NFS server deployment showed the value of separating shared storage from client-specific storage paths. Shared directories provide common access points, while per-client directories allow more controlled organization for each VM.

Using `fsid=0` and a structured `/srv/nfs` export root creates a cleaner NFSv4-style layout.

Export validation with both `exportfs` and `showmount` provides a clearer view of the difference between configured exports and actively advertised exports.

## Related Documents

# NFS Mount Permission Denied Troubleshooting

| Metadata              | Value                                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Document Type**     | Troubleshooting Guide                                                                                                                                        |
| **Category**          | Storage                                                                                                                                                      |
| **Status**            | Complete                                                                                                                                                     |
| **Last Updated**      | June 2026                                                                                                                                                    |
| **Related Documents** | `storage/nfs-server-deployment.md`<br>`storage/nfs-client-integration.md`<br>`storage/nfs-exports-and-permissions.md`<br>`network/nsg-asg-implementation.md` |

---

## Summary

This document details an NFS mount failure encountered during the Azure Network Infrastructure Lab deployment.

The issue occurred while validating an NFS share exported from `TestLinuxServer1`. Mount attempts failed with a server-side permission error until the NFS export configuration was corrected, exports were reloaded, and NFS services were restarted.

---

## Symptoms

The following symptoms were observed:

* NFS packages were being installed and verified.
* The NFS export path existed.
* Local mount validation failed.
* The mount command returned:

```text
mount.nfs: mount(2): Permission denied
mount.nfs: access denied by server while mounting localhost:/export
```

A related issue also occurred when using `mount -t nfs` before `nfs-common` was installed.

---

## Environment

| Component             | Value              |
| --------------------- | ------------------ |
| Resource Group        | `TestGroup1`       |
| VNet                  | `TestVNet1`        |
| NFS Server            | `TestLinuxServer1` |
| NFS Server Private IP | `10.0.0.4`         |
| Client VM             | `TestClientVM1`    |
| Server Export Path    | `/export`          |
| Client Mount Point    | `/mnt/nfs`         |
| Protocol              | NFS                |
| Required Port         | TCP `2049`         |

---

## Root Cause

The primary root cause was that the NFS export line in `/etc/exports` was not active because a leading `#` was still present. This caused the export rule to be treated as a comment instead of an active NFS export.

As a result, the server denied the mount request.

A secondary issue was that `nfs-common` was missing during testing, which caused problems when using `mount -t nfs`.

A client-side connectivity issue also depended on Azure NSG/ASG rules allowing NFS traffic over TCP `2049` between the client systems and the NFS server.

---

## Investigation Process

### 1. Verify NFS Package Installation and Observe Failure

NFS packages were installed and checked before attempting a local mount.

```bash
sudo apt install nfs-kernel-server nfs-common -y
dpkg -l | grep nfs
sudo mkdir -p /mnt/test
sudo mount -t nfs -v localhost:/export /mnt/test
```

The local mount attempt failed with:

```text
access denied by server while mounting localhost:/export
```

*See Evidence:* [01-nfs-package-verification-and-initial-mount-failure.png](../screenshots/troubleshooting/nfs-mount-permission-denied/01-nfs-package-verification-and-initial-mount-failure.png)

---

### 2. Review and Correct `/etc/exports`

The NFS export configuration was reviewed.

```bash
sudo nano /etc/exports
```

The intended export rule was:

```text
/export *(rw,sync,no_subtree_check,no_root_squash)
```

The issue was that the export line was still commented out with a leading `#`. Removing the `#` activated the export rule.

*See Evidence:* [02-nfs-export-rule-before-correction.png](../screenshots/troubleshooting/nfs-mount-permission-denied/02-nfs-export-rule-before-correction.png)

---

### 3. Reload Exports and Restart NFS

After correcting `/etc/exports`, the NFS export table was reloaded and the NFS service was restarted.

```bash
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
sudo systemctl status nfs-kernel-server
sudo rpcinfo -p
```

The service status and RPC registration were reviewed to confirm that NFS services were running.

```bash
sudo mount -t nfs -v localhost:/export /mnt/test
df -h | grep /mnt/test
touch /mnt/test/testfile.txt
ls /export
```

The local mount succeeded and a test file was visible in the exported directory.

*See Evidence:* [03-nfs-service-status-rpc-and-localhost-mount-validation.png](../screenshots/troubleshooting/nfs-mount-permission-denied/03-nfs-service-status-rpc-and-localhost-mount-validation.png)

---

## Resolution

The issue was resolved by:

1. Installing the required NFS packages.
2. Correcting `/etc/exports` by removing the leading `#`.
3. Reloading the NFS export table.
4. Restarting the NFS service.
5. Confirming RPC service registration.
6. Validating the export locally.
7. Configuring the client mount.
8. Verifying read/write access from the client.

---

## Client Configuration and Validation

### 1. Configure Persistent Client Mount

The client mount was added to `/etc/fstab`.

```bash
sudo nano /etc/fstab
```

Entry:

```text
10.0.0.4:/export /mnt/nfs nfs defaults,nofail 0 0
```

*See Evidence:* [04-client-fstab-nfs-mount-entry.png](../screenshots/troubleshooting/nfs-mount-permission-denied/04-client-fstab-nfs-mount-entry.png)

---

### 2. Install Client Package and Mount Share

The client required `nfs-common` before it could mount the NFS export.

```bash
sudo apt update
sudo apt install nfs-common -y
sudo mkdir -p /mnt/nfs
sudo mount -t nfs 10.0.0.4:/export /mnt/nfs
df -h | grep /mnt/nfs
```

*See Evidence:* [05-client-nfs-package-install-and-mount-success.png](../screenshots/troubleshooting/nfs-mount-permission-denied/05-client-nfs-package-install-and-mount-success.png)

---

### 3. Validate Export Directory Remotely

The server export directory was checked remotely from the client.

```bash
ssh David@10.0.0.4 "ls /export"
```

*See Evidence:* [06-remote-export-directory-validation.png](../screenshots/troubleshooting/nfs-mount-permission-denied/06-remote-export-directory-validation.png)

---

### 4. Validate Read/Write Access

A test file was created from the client through the mounted NFS share.

```bash
touch /mnt/nfs/clienttest.txt
ls /mnt/nfs
```

The client-mounted directory showed both the server-created and client-created test files.

*See Evidence:* [07-client-mounted-share-read-write-validation.png](../screenshots/troubleshooting/nfs-mount-permission-denied/07-client-mounted-share-read-write-validation.png)

---

### 5. Validate Server Access

Server SSH access was confirmed after the troubleshooting process.

```bash
ssh David@10.0.0.4
```

*See Evidence:* [08-server-access-validation.png](../screenshots/troubleshooting/nfs-mount-permission-denied/08-server-access-validation.png)

---

## Network Security Consideration

For client systems to mount the NFS export across the VNet, Azure network security rules must allow NFS traffic.

Required rule:

| Direction        | Source        | Destination      | Protocol | Port   |
| ---------------- | ------------- | ---------------- | -------- | ------ |
| Client to Server | `ASG-CLIENTS` | `ASG-NFS-SERVER` | TCP      | `2049` |

If the mount works locally on the server but fails from the client, verify the NSG and ASG rules before continuing filesystem troubleshooting.

---

## Validation

The resolution was validated by confirming:

* NFS packages were installed.
* The export rule was active.
* NFS services were running.
* RPC services were registered.
* The export mounted successfully on the server.
* The client mounted the export successfully.
* Files created from the client appeared in the mounted share.
* Server access remained available for remote validation.

---

## Lessons Learned

* A single leading `#` in `/etc/exports` can disable the entire export rule.
* Always run `sudo exportfs -ra` after modifying `/etc/exports`.
* Install `nfs-common` on systems that need to perform NFS client-side mount operations.
* Validate locally on the NFS server before testing from client systems.
* If local mounting works but client mounting fails, check Azure NSG/ASG rules for TCP `2049`.
* Read/write validation is stronger than mount validation alone.

---

## Related Documents

* `storage/nfs-server-deployment.md`
* `storage/nfs-client-integration.md`
* `storage/nfs-exports-and-permissions.md`
* `network/nsg-asg-implementation.md`
* `command-codex/bash-linux/bash-linux.md`

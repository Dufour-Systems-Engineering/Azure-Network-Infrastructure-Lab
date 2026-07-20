# Centralized Logging with rsyslog

## Overview

NetMonVM1 was configured as an rsyslog receiver for the Azure Network Infrastructure Lab. The implementation established TCP and UDP listeners on port 514 and a dedicated storage location for messages received by the service.

The server-side configuration was validated locally from NetMonVM1. The final test confirmed that a TCP syslog message sent to the local receiver was written to `/var/log/remote/NetMonVM1.log`.

This implementation establishes the receiving and storage foundation for centralized logging. Forwarding from another lab virtual machine was not configured or validated during this phase.

## Purpose

The purpose of this implementation was to prepare NetMonVM1 to centralize Linux system logs from the original West US lab environment.

The work supported the broader role of NetMonVM1 as the lab's monitoring and diagnostics platform by establishing:

* A dedicated rsyslog receiver
* TCP and UDP listeners on port 514
* Hostname-based remote log storage
* A validated server-side message path
* A foundation for future forwarding from the original Linux servers and clients

## Prerequisites

The implementation used the following established lab components:

* NetMonVM1 deployed in `NetMonSubnet1`
* Ubuntu Server 22.04.5 LTS
* Private IP address `10.0.0.132`
* SSH administrative access to NetMonVM1
* An account with `sudo` privileges
* `rsyslog` package version 8.2112.0 already installed
* VNet traffic permitted by the Azure network security configuration

The host identity, operating system, and installed rsyslog package were confirmed before the receiver configuration was completed.

*See Evidence:* [01-netmonvm1-os-and-rsyslog-package-validation.png](../screenshots/monitoring/rsyslog/01-netmonvm1-os-and-rsyslog-package-validation.png)

## Deployment Procedure

### 1. Confirm the host and rsyslog package

The NetMonVM1 host identity and operating system were displayed, and the package manager confirmed that rsyslog was already installed at the newest available version for the configured Ubuntu repositories.

```bash
whoami && hostname && cat /etc/os-release | head -n 5
sudo apt update && sudo apt install -y rsyslog
```

The installation command did not add a new package because rsyslog was already present.

### 2. Review the default rsyslog file settings

The main `/etc/rsyslog.conf` configuration was inspected. The existing configuration defined the default log-file owner and group as `syslog:adm`, set file and directory creation modes, and included configuration files from `/etc/rsyslog.d/`.

The include directive allowed the receiver configuration to be separated from the main distribution-managed file.

*See Evidence:* [02-rsyslog-default-file-settings-and-include-configuration.png](../screenshots/monitoring/rsyslog/02-rsyslog-default-file-settings-and-include-configuration.png)

### 3. Create the remote-log storage directory

The remote log directory was created and assigned to the same service account and administrative group used by the default rsyslog configuration.

```bash
sudo mkdir -p /var/log/remote
sudo chown -R syslog:adm /var/log/remote
sudo chmod -R 755 /var/log/remote
```

## Configuration Procedure

### 1. Attempt hostname-and-program-based storage

The initial receiver configuration loaded the UDP and TCP input modules, opened port 514 for both transports, and defined a dynamic path using the sending hostname and program name:

```rsyslog
module(load="imudp")
module(load="imtcp")

input(type="imudp" port="514")
input(type="imtcp" port="514")

template(name="RemoteLogs" type="string"
         string="/var/log/remote/%HOSTNAME%/%PROGRAMNAME%.log")

if $fromhost-ip != '127.0.0.1' and $fromhost-ip != '::1' then {
    *.* ?RemoteLogs
    & stop
}

$AllowedSender UDP, 10.0.0.0/24
$AllowedSender TCP, 10.0.0.0/24
```

This version was designed for messages arriving from remote systems within the lab address space. Its routing condition explicitly excluded IPv4 and IPv6 localhost traffic.

*See Evidence:* [03-initial-central-rsyslog-receiver-configuration.png](../screenshots/monitoring/rsyslog/03-initial-central-rsyslog-receiver-configuration.png)

### 2. Restart and inspect the receiver

The rsyslog service was restarted after the configuration change. Service inspection confirmed that rsyslog remained active and enabled.

```bash
sudo systemctl restart rsyslog
sudo systemctl status rsyslog --no-pager
ss -tuln | grep 514
```

Socket inspection confirmed listeners on TCP and UDP port 514 for IPv4 and IPv6.

*See Evidence:* [04-rsyslog-service-and-port-514-listener-validation.png](../screenshots/monitoring/rsyslog/04-rsyslog-service-and-port-514-listener-validation.png)

### 3. Test the initial rule locally

A TCP message was sent to the receiver through the IPv4 loopback address:

```bash
logger -n 127.0.0.1 -P 514 -T "TEST MESSAGE FROM NETMONVM1 ITSELF - $(date)"
```

The expected remote log path was not created. The test used `127.0.0.1`, while the initial routing condition excluded messages whose source was `127.0.0.1` or `::1`. The unsuccessful result therefore did not demonstrate failure of the remote-sender rule; it demonstrated that the selected local test did not enter that rule.

*See Evidence:* [05-initial-local-test-no-remote-log-created.png](../screenshots/monitoring/rsyslog/05-initial-local-test-no-remote-log-created.png)

### 4. Reapply directory ownership and permissions

The directory ownership and permissions were reapplied, the service was restarted, and the local test was repeated. No hostname directory appeared under `/var/log/remote` while the localhost-excluding rule remained in use.

```bash
sudo mkdir -p /var/log/remote
sudo chown -R syslog:adm /var/log/remote
sudo chmod -R 755 /var/log/remote
sudo systemctl restart rsyslog
logger -n 127.0.0.1 -P 514 -T "TEST MESSAGE FROM NETMONVM1 ITSELF - $(date)"
ls -l /var/log/remote/
sudo ls -l /var/log/remote/NetMonVM1/ 2>/dev/null || echo "Directory still not created"
```

*See Evidence:* [06-directory-permission-retry-remained-unsuccessful.png](../screenshots/monitoring/rsyslog/06-directory-permission-retry-remained-unsuccessful.png)

### 5. Create the dedicated validated configuration

The receiver configuration was simplified and moved into `/etc/rsyslog.d/10-central-lab.conf`. The final rule stored messages in one file per hostname:

```rsyslog
# Central syslog server for lab - simple and reliable

module(load="imudp")
module(load="imtcp")

# Listen for logs
input(type="imudp" port="514")
input(type="imtcp" port="514")

# Save ALL remote logs to one file per hostname
$template RemoteLog,"/var/log/remote/%HOSTNAME%.log"
*.* ?RemoteLog
```

The directory settings were applied again and rsyslog was restarted:

```bash
sudo mkdir -p /var/log/remote
sudo chown -R syslog:adm /var/log/remote
sudo chmod -R 755 /var/log/remote
sudo systemctl restart rsyslog
```

This dedicated configuration became the validated server-side implementation.

## Verification

The final validation sent a TCP syslog message to the local receiver on port 514:

```bash
logger -n 127.0.0.1 -P 514 -T "FINAL TEST MESSAGE - \$(date)"
```

The escaped command substitution caused `$(date)` to be stored as literal message text. This did not affect validation of message receipt or file creation.

The remote-log directory was listed and the stored log content was displayed:

```bash
ls -l /var/log/remote/
sudo find /var/log/remote -type f -exec tail -n 3 {} + 2>/dev/null || echo "No log files yet"
```

The verification confirmed:

* `/var/log/remote/NetMonVM1.log` was created
* The log file was owned by `syslog:adm`
* The locally generated test message was present in the file
* The rsyslog server accepted and stored a TCP message through port 514

*See Evidence:* [07-dedicated-configuration-and-successful-local-test.png](../screenshots/monitoring/rsyslog/07-dedicated-configuration-and-successful-local-test.png)

The validation did not establish remote forwarding from another virtual machine, UDP message storage, encrypted transport, log rotation, or long-term retention.

## Common Issues

### Local validation did not enter the remote-sender rule

The first test sent a message from `127.0.0.1`, but the initial rule processed only messages whose source was not `127.0.0.1` or `::1`. Reapplying directory permissions did not change the result because the test traffic still did not match the routing condition.

The final dedicated rule accepted the local test and demonstrated the receiver's file-writing path. A message sent from another West US lab VM is still required to validate the original remote-sender design.

### Expected hostname directory was not created

The initial template expected a nested path in the form `/var/log/remote/<hostname>/<program>.log`. No such path appeared during the localhost test. The final configuration reduced the storage model to `/var/log/remote/<hostname>.log`, which successfully created `NetMonVM1.log`.

### Service availability did not prove message storage

The active service state and open TCP/UDP sockets proved that rsyslog was running and listening. Separate message and filesystem validation was required to prove that the receiver could write a received message to the intended storage location.

## Lessons Learned

Receiver validation must account for the filtering conditions applied by the configuration. A localhost-generated message cannot validate a rule that deliberately excludes localhost traffic.

Separating the lab receiver configuration into `/etc/rsyslog.d/10-central-lab.conf` reduced changes to the main rsyslog file and made the implemented behavior easier to inspect and maintain.

Service status, listening sockets, message transmission, file creation, ownership, and stored content answer different validation questions. Confirming each layer produced a stronger result than relying on service status alone.

The server-side foundation is complete for local TCP validation. The next implementation phase should configure one original West US Linux VM as a forwarding client and confirm that its messages arrive in a source-specific file on NetMonVM1.

## Related Documents

* `monitoring/netmonvm1-overview.md`
* `network/nsg-asg-implementation.md`
* `network/private-dns-implementation.md`
* `remote-access/README.md`
* `remote-access/wireguard-vpn-server-completion-and-one-hop-access.md`

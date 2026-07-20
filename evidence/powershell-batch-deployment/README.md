# PowerShell Batch Deployment Evidence

This directory contains sanitized PowerShell evidence from the Azure Network Infrastructure Lab batch-deployment project. The evidence supports the documented deployment, troubleshooting, validation, and teardown work performed during Phases 2 through 5.

The files published here are curated evidence excerpts rather than complete terminal transcripts. They preserve commands, relevant output, errors, and validation results while excluding unrelated terminal activity and sensitive workstation or Azure account information.

## Why There Is No Phase 1 Folder

No persistent PowerShell transcript or equivalent terminal log was saved during Phase 1 of the batch-deployment project. PowerShell transcript collection became part of the evidence workflow after that phase was completed.

Phase 1 is therefore not represented in this directory. Its absence does not indicate that the network-foundation work was skipped or unsuccessful. The phase is documented through its deployment document and associated screenshots, but no PowerShell log exists that can be responsibly published here.

No Phase 1 transcript was reconstructed from memory, screenshots, later commands, or other phases. Creating such a file would misrepresent reconstructed material as contemporaneous terminal evidence.

## Directory Contents

### Phase 2 — Client VM Deployment

Folder: [`phase-02-client-vm-deployment`](./phase-02-client-vm-deployment/)

- [`phase-2-gallery-image-creation-sanitized.txt`](./phase-02-client-vm-deployment/phase-2-gallery-image-creation-sanitized.txt) records the Azure Compute Gallery image-version creation and regional target update.
- [`phase-2-client-vm-deployment-troubleshooting-sanitized.txt`](./phase-02-client-vm-deployment/phase-2-client-vm-deployment-troubleshooting-sanitized.txt) records the 15-resource What-If and the failed client VM deployment caused by an invalid gallery image reference.

### Phase 3 — WireGuard VM Deployment

Folder: [`phase-03-wireguard-vm-deployment`](./phase-03-wireguard-vm-deployment/)

- [`phase-3-wireguard-vm-deployment-success-sanitized.txt`](./phase-03-wireguard-vm-deployment/phase-3-wireguard-vm-deployment-success-sanitized.txt) records Bicep validation, the 18-resource What-If, planned WireGuard resources, and the successful final deployment.
- [`phase-3-wireguard-vm-deployment-troubleshooting-sanitized.txt`](./phase-03-wireguard-vm-deployment/phase-3-wireguard-vm-deployment-troubleshooting-sanitized.txt) records the Basic-SKU public IP limit failure, the invalid SSH public-key data failure, and cleanup after both attempts.

### Phase 4 — WireGuard Configuration and Validation

Folder: [`phase-04-wireguard-configuration-validation`](./phase-04-wireguard-configuration-validation/)

- [`phase-4-wireguard-server-configuration-sanitized.txt`](./phase-04-wireguard-configuration-validation/phase-4-wireguard-server-configuration-sanitized.txt) records returned SSH-session output confirming WireGuard package installation and persistent IPv4 forwarding.
- [`phase-4-wireguard-system-state-sanitized.txt`](./phase-04-wireguard-configuration-validation/phase-4-wireguard-system-state-sanitized.txt) records the sanitized WireGuard VM interface, forwarding, routing, and system-state validation.

The Phase 4 PowerShell transcript did not capture the remote Linux commands themselves, and the system-state capture contains output without its collection commands. Together, the artifacts support WireGuard package installation, persistent IPv4 forwarding, `wg0` interface presence, and WireGuard routing state. They do not independently prove private-key or peer configuration, NAT behavior, a WireGuard handshake, or client connectivity. Those activities are supported by the Phase 4 deployment documentation and other evidence sources.

### Phase 5 — Teardown

Folder: [`phase-05-teardown`](./phase-05-teardown/)

- [`phase-5-client-resource-teardown-and-preservation-sanitized.txt`](./phase-05-teardown/phase-5-client-resource-teardown-and-preservation-sanitized.txt) records the six-client allowlist, confirmation that the WireGuard VM was excluded, client VM deletion, removal of client NICs and OS disks, and preservation of the WireGuard VM and its resources.

## Sanitization Method

The original private transcripts were preserved without modification. Public evidence files were created as separate sanitized excerpts.

Depending on the source transcript, the following information was removed or replaced with descriptive placeholders:

- Plaintext credentials and secure parameter values
- Azure subscription and tenant identifiers
- Azure login and account-selection metadata
- Local Windows usernames, computer names, and filesystem paths
- Public endpoint addresses
- Interface addresses and routing details when they were unnecessary to the evidence
- SSH and WireGuard key material
- Irrelevant process, shell, and workstation metadata
- Duplicate output, generic help text, and unrelated command attempts

PowerShell prompts, line wrapping, whitespace, and selected JSON output were normalized where needed for readability. Error codes, resource names, commands, and validation results were retained when they were relevant to the documented phase.

Each evidence file includes its own sanitization notice and any limitations specific to that excerpt.

## Evidence Boundaries

These files support the batch-deployment documentation but do not replace it. They should be read alongside the corresponding phase documents and screenshot evidence.

Only the curated evidence files listed in this README are approved for public repository use. The original transcripts contain sensitive or irrelevant information and must remain private.
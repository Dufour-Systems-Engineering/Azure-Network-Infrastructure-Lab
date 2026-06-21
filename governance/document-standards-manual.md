# Document Standards Manual

## Document Information

| Property        | Value                     |
| --------------- | ------------------------- |
| Classification  | Document Standards Manual |
| Applies To      | Entire Repository         |
| Authority Level | 4                         |
| Maintainer      | Repository Owner          |
| Version         | 1.0                       |
| Status          | Active                    |
| Effective Date  | 2026-06-19                |
| Last Reviewed   | 2026-06-19                |

---

## Overview

This document defines the repository-wide standards governing document classification, template usage, document organization, and structural consistency throughout the Azure Network Infrastructure Lab repository.

Its purpose is to establish a controlled documentation framework that promotes consistency, maintainability, and long-term scalability while preventing documentation configuration drift.

This document defines **what** documentation standards shall be followed. Approved templates define **how** those standards are implemented.

---

## Purpose

The Document Standards Manual exists to:

* Define approved repository document classes.
* Govern approved document templates.
* Standardize repository document structure.
* Prevent template and document proliferation.
* Establish repository-wide structural requirements.
* Support long-term maintainability and scalability.

---

# Repository Document Classes

The repository currently supports the following document classes:

* Architecture
* Build Guide
* Operations
* Validation
* Troubleshooting
* Command Codex
* Governance

Each published document shall belong to one approved document class.

New document classes shall not be introduced without updating this document and creating an approved template where applicable.

---

# Approved Templates

Approved templates implement the Governance framework.

Templates define:

* Required section order
* Required sections
* Optional sections
* Section purpose
* Document layout
* Evidence placement
* Cross-reference structure

Approved templates are controlled documents and shall remain consistent with all Governance documents.

---

# Template Compliance

Published documentation shall:

* Use the approved template for its document class.
* Preserve required section order.
* Preserve required section headings.
* Include all mandatory sections.
* Remove placeholder content prior to publication.
* Remain consistent with the current template version.

Templates shall not be modified through individual published documents.

---
### Metadata Tables

Metadata tables are reserved for documents that require lifecycle management or communicate revision status over time.

Metadata tables shall be used for:

- Governance documents
- Repository policies
- Repository standards
- Decision logs
- Audit logs
- Other documents specifically intended to communicate document status, version history, or effective dates

Metadata tables shall **not** be used for static technical documentation.

This includes:

- Architecture documentation
- Build guides
- Deployment documentation
- Monitoring documentation
- Operations documentation
- Troubleshooting documentation
- Validation documentation
- Command Codex documentation

Technical documentation represents the implemented state of the environment. Its revision history is maintained through Git rather than embedded document metadata. Repository structure, approved templates, and Git history collectively provide document classification and revision history, making embedded metadata unnecessary for static technical documentation.

Metadata tables shall not be added to published technical documentation unless explicitly required by the approved repository template.
---
# Repository Naming Standards

Repository documents shall follow consistent naming conventions.

Document filenames should:

* Clearly describe the documented system or process.
* Use lowercase letters.
* Use hyphen-separated words.
* Avoid abbreviations unless they are established repository terminology.
* Remain descriptive without becoming unnecessarily long.

Examples:

```text
wireguard-vpn-gateway.md
golden-image-management.md
private-dns-vnet-dns-lab.md
```

---

# Repository Organization

Published documents shall reside within the appropriate repository directory.

Repository organization shall follow the established System-First Flexible Depth model.

Document placement should prioritize logical organization and discoverability.

Repository organization standards shall remain consistent across the repository.

---

# Section Standards

Section names defined by approved templates are controlled.

Published documentation shall not rename required section headings without an approved template revision.

Examples include:

* Overview
* Purpose
* Scope
* Architecture Summary
* Components
* Prerequisites
* Deployment Procedure
* Configuration Procedure
* Verification
* Security Considerations
* Common Issues
* Lessons Learned
* Related Documents

Templates define which sections are applicable to each document class.

---

# Required Repository Elements

Where applicable, published documentation shall include:

* Relative cross-references
* Supporting evidence
* Validation procedures
* Lessons Learned
* Related Documents

The applicable template defines how these elements are implemented.

---

# Evidence Standards

Evidence strengthens repository credibility.

Where applicable, documentation should reference:

* Screenshots
* Azure Portal verification
* Validation commands
* Configuration excerpts
* Command output

Evidence shall support technical claims rather than replace written explanation.

---

# Document Lifecycle

Repository documentation progresses through the following lifecycle:

```text
Source Material
        │
        ▼
Draft
        │
        ▼
Technical Review
        │
        ▼
Repository Integration
        │
        ▼
Publication Review
        │
        ▼
Published
        │
        ▼
Revision
        │
        ▼
Archived (if applicable)
```

Detailed workflow requirements are defined in the Repository Workflow.

---

# Template Modification

Template modifications are controlled changes.

Template revisions shall:

* Address a demonstrated repository need.
* Improve repository consistency.
* Improve repository maintainability.
* Be documented through the Repository Decision Log.
* Be reviewed before implementation.
* Be applied consistently where appropriate.

Template revisions shall not introduce conflicting repository standards.

---

# New Document Creation

Before creating a new published document, the following shall be identified:

* Applicable document class
* Applicable template
* Repository location
* Related documentation
* Required supporting evidence

If no suitable template exists, a new template shall be approved before the document is created.

---

# Repository Consistency

Repository consistency takes precedence over individual stylistic or organizational preference.

When an approved standard exists, it shall be followed unless the Governance framework is formally revised.

---

# Relationship to Other Governance Documents

Repository Governance establishes repository authority.

Repository Principles establish engineering philosophy.

The Repository Style Guide defines editorial and formatting standards.

This document governs repository document structure and template usage.

The Repository Workflow defines document development.

The Publication Quality Gate verifies compliance prior to publication.

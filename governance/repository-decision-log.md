# Repository Decision Log

## Document Information

| Property        | Value                   |
| --------------- | ----------------------- |
| Classification  | Repository Decision Log |
| Applies To      | Entire Repository       |
| Authority Level | Reference               |
| Maintainer      | Repository Owner        |
| Version         | 1.0                     |
| Status          | Active                  |
| Effective Date  | 2026-06-19              |
| Last Reviewed   | 2026-06-19              |

---

## Overview

This document records significant decisions affecting the structure, governance, standards, and long-term evolution of the Azure Network Infrastructure Lab repository.

Its purpose is to preserve the reasoning behind repository decisions so that future changes remain informed, consistent, and traceable.

The Repository Decision Log documents **why** significant decisions were made rather than **how** they were implemented.

---

## Purpose

The Repository Decision Log exists to:

* Preserve repository design rationale.
* Record governance decisions.
* Improve long-term maintainability.
* Support future repository evolution.
* Reduce repeated discussion of previously resolved issues.

---

# Decision Record Format

Each repository decision should follow the structure below.

## Decision ID

Sequential identifier.

Example:

```text
RD-001
```

---

## Title

Short descriptive title summarizing the decision.

---

## Status

Examples include:

* Proposed
* Accepted
* Superseded
* Deprecated

---

## Date

Date the decision was approved.

---

## Problem

Describe the issue or requirement that prompted the decision.

---

## Decision

Describe the chosen solution.

---

## Rationale

Explain why the selected solution was preferred over alternatives.

---

## Impact

Summarize expected effects on:

* Repository organization
* Documentation
* Workflow
* Governance
* Future maintenance

---

## Related Governance Documents

Reference applicable Governance documents where appropriate.

---

# Current Repository Decisions

## RD-001 — Maintain Three-Level Repository Depth With Screenshot Exception

**Status**

Accepted

**Date**

2026-06-19

**Problem**

The repository required a predictable folder depth to prevent unnecessary nesting and make documentation easier to browse. However, screenshot organization required additional depth because screenshots are grouped by document or workflow and referenced directly from published documentation.

**Decision**

Maintain a three-level folder depth standard across the repository, with an approved exception for the `screenshots/` directory.

The `screenshots/` directory may use a fourth level when needed to organize screenshots by document or workflow.

**Rationale**

Most repository content should remain easy to browse directly.

Screenshots are different because they are not intended for routine direct navigation. They are primarily accessed through links from the relevant documentation.

Allowing a fourth level under `screenshots/` improves screenshot organization without increasing complexity for normal repository browsing.

**Impact**

Established a repository-wide depth standard while allowing screenshot evidence to remain organized and scalable.

---

## RD-002 — Adopt System-First Flexible Depth Repository Structure

**Status**

Accepted

**Date**

2026-06-19

**Problem**

Repository growth required a scalable organizational structure capable of supporting additional systems without frequent restructuring.

**Decision**

Adopt the System-First Flexible Depth repository organization model.

**Rationale**

The structure improves discoverability, logical grouping, and long-term scalability while minimizing future repository restructuring.

**Impact**

Established the organizational model used throughout the repository.

---

## RD-003 — Introduce Command Codex

**Status**

Accepted

**Date**

2026-06-19

**Problem**

Commands used throughout the lab were spread across notes, build guides, troubleshooting records, command history files, and AI-assisted sessions. This made command reuse, review, and learning difficult.

**Decision**

Introduce the Command Codex as a dedicated repository section for documenting commands, syntax, and system-specific command usage.

**Rationale**

The Command Codex provides a structured way to preserve command knowledge, explain command usage, support learning, and reduce dependence on repeated AI-assisted command generation.

**Impact**

Established a dedicated documentation area for Azure CLI, Bash/Linux, PowerShell, syntax references, and system-specific command documentation.

---

## RD-004 — Establish Repository Governance Framework

**Status**

Accepted

**Date**

2026-06-19

**Problem**

Repository growth resulted in documentation configuration drift, inconsistent formatting, template variation, and increasing maintenance overhead.

**Decision**

Create a formal Governance framework consisting of repository standards, workflows, quality controls, decision records, and audit records.

**Rationale**

Centralizing repository standards improves consistency, reduces ambiguity, and supports long-term maintainability.

**Impact**

Governance became the highest authority for repository documentation standards.

---

## Continuous Improvement

New decision records should document significant repository changes rather than routine document updates.

Minor editorial changes do not require decision records.
---
## RD-005 — Restrict Metadata Tables to Governance and Lifecycle Documents

**Status**

Accepted

**Date**

2026-06-21

**Problem**

As repository governance matured, metadata tables were found to provide little value in static technical documentation while introducing unnecessary duplication of information already maintained through Git and repository structure.

**Decision**

Metadata tables will be reserved for governance and lifecycle-managed documentation.

Static technical documentation will not include metadata tables unless explicitly required by the governing template.

**Rationale**

Technical documentation within this repository is intended to describe the implemented state of the lab rather than manage evolving policy or configuration baselines. Git provides authoritative revision history for these documents, making embedded metadata unnecessary and potentially redundant.

Restricting metadata tables to governance documents maintains a clear distinction between repository policy and technical implementation while improving consistency across published documentation.

**Impact**

Established a repository-wide distinction between governance documentation and static technical documentation.

Governance documents retain metadata tables to support policy lifecycle management.

Technical documentation relies on approved templates and Git history rather than embedded document metadata.
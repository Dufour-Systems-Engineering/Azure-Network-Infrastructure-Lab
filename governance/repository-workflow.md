# Repository Workflow

## Document Information

| Property        | Value               |
| --------------- | ------------------- |
| Classification  | Repository Workflow |
| Applies To      | Entire Repository   |
| Authority Level | 5                   |
| Maintainer      | Repository Owner    |
| Version         | 1.0                 |
| Status          | Active              |
| Effective Date  | 2026-06-19          |
| Last Reviewed   | 2026-06-19          |

---

## Overview

This document defines the standard workflow used to create, review, integrate, and publish documentation within the Azure Network Infrastructure Lab repository.

Its purpose is to ensure that all repository content follows a consistent, repeatable development process while minimizing documentation configuration drift.

---

## Purpose

The Repository Workflow exists to:

* Standardize documentation development.
* Improve repository consistency.
* Reduce rework.
* Establish repeatable publication practices.
* Ensure technical accuracy prior to publication.
* Support long-term repository maintenance.

---

# Workflow Stages

Repository documentation shall progress through the following stages.

## Stage 1 — Source Material Collection

Collect and review available source material.

Examples include:

* Published repository documents
* Screenshots
* Lab notes
* Command history
* Configuration files
* Validation output
* User-confirmed implementation details

Source material shall be validated before documentation begins.

---

## Stage 2 — Scope Definition

Determine:

* Document class
* Applicable template
* Intended audience
* Repository location
* Related documentation
* Required evidence

The approved template shall be identified before drafting begins.

---

## Stage 3 — Evidence Planning

Determine required supporting evidence.

Examples include:

* Screenshots
* Validation commands
* Configuration excerpts
* Azure Portal verification
* Command output

Evidence requirements should be identified before writing implementation details.

---

## Stage 4 — Draft Development

Create the initial document using the approved repository template.

Drafts shall:

* Follow the applicable template.
* Follow the Repository Style Guide.
* Follow the Document Standards Manual.
* Reflect implemented reality.

Drafts should not be published directly.

---

## Stage 5 — Technical Review

Review the draft for:

* Technical accuracy
* Completeness
* Repository consistency
* Terminology
* Cross-references
* Evidence

Technical review should occur before publication review.

---

## Stage 6 — Repository Integration

Integrate the completed document into the repository.

Tasks may include:

* Adding screenshot references
* Updating Related Documents
* Updating README files
* Updating navigation
* Updating CHANGELOG entries
* Verifying relative links

---

## Stage 7 — Publication Review

Verify that the document satisfies the Publication Quality Gate.

Documents that do not satisfy publication requirements shall not be published.

---

## Stage 8 — Publication

After successful review:

* Commit repository changes.
* Push approved changes.
* Verify published repository state.

Publication marks the completion of the workflow.

---

# Workflow Diagram

```text
Source Material
        │
        ▼
Scope Definition
        │
        ▼
Evidence Planning
        │
        ▼
Draft Development
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
Publication
```

---

# Responsibilities

## Repository Owner

Responsible for:

* Technical accuracy
* Source material validation
* Final approval
* Publication authorization

---

## AI Assistant

Responsible for:

* Applying repository standards
* Following approved templates
* Identifying documentation drift
* Assisting with repository integration
* Supporting quality assurance

The AI Assistant shall not bypass any workflow stage without Repository Owner approval.

---

# Continuous Improvement

Workflow improvements shall be introduced through the Governance framework.

Workflow changes should improve repeatability, reduce documentation configuration drift, and simplify long-term repository maintenance without compromising repository quality.

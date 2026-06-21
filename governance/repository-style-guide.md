# Repository Style Guide

## Document Information

| Property        | Value                  |
| --------------- | ---------------------- |
| Classification  | Repository Style Guide |
| Applies To      | Entire Repository      |
| Authority Level | 3                      |
| Maintainer      | Repository Owner       |
| Version         | 1.0                    |
| Status          | Active                 |
| Effective Date  | 2026-06-19             |
| Last Reviewed   | 2026-06-19             |

---

## Overview

This document defines the editorial, formatting, and Markdown standards used throughout the Azure Network Infrastructure Lab repository.

Its purpose is to eliminate documentation configuration drift by ensuring that all published documents follow a consistent writing style, structure, and presentation.

Repository standards are intended to improve readability, maintainability, and long-term consistency rather than individual writing style.

---

## Purpose

This document establishes standards for:

* Markdown formatting.
* Headings.
* Lists.
* Tables.
* Code blocks.
* Links.
* Screenshot references.
* Terminology.
* Punctuation.
* General writing style.

---

# Writing Standards

## Professional Tone

Repository documentation shall use professional, objective, technical language.

Avoid conversational language, humor, slang, opinion, or unnecessary emphasis.

---

## Voice

Write using an instructional and descriptive style.

Avoid first-person language unless documenting lessons learned or personal observations where appropriate.

---

## Tense

Describe completed work using past tense.

Describe current repository behavior, architecture, or standards using present tense.

---

## Heading Standards

* Use Sentence Case.
* Headings shall remain consistent across documents of the same class.
* Do not rename established section headings without updating the Document Standards Manual.

Example:

```text
Overview

Purpose

Architecture Summary

Lessons Learned
```

---

## Paragraph Standards

* Keep paragraphs focused on a single topic.
* Avoid unnecessarily long paragraphs.
* Separate concepts into individual paragraphs where appropriate.

---

## Bullet List Standards

Repository standard:

* Use the hyphen (`-`) for unordered lists.
* Do not mix bullet styles within a document.
* Keep bullet wording grammatically consistent.
* Parallel lists should use parallel sentence structure.

Example:

```text
- Create the virtual network.
- Configure the subnet.
- Validate connectivity.
```

---

## Numbered Lists

Use numbered lists only when sequence matters.

Examples:

* Deployment procedures.
* Validation procedures.
* Operational workflows.

Do not use numbered lists solely for visual formatting.

---

## Tables

Use tables when comparing structured information.

Examples include:

* IP addressing.
* VM inventories.
* NSG rules.
* Document metadata.
* Decision summaries.

---

## Code Blocks

* Specify the language whenever practical.
* Preserve indentation.
* Do not wrap commands unnecessarily.
* Use placeholders for sensitive information.

Example:

```bash
az vm list -g TestGroup1
```

---

## Links

* Use relative links throughout the repository.
* Verify links before publication.
* Link only to current repository content.

---

## Screenshot References

Screenshots shall:

* Use standardized filenames.
* Be referenced using relative paths.
* Support the surrounding documentation.
* Match the current implementation.

Do not reference screenshots that do not exist.

---

## Terminology Standards

Use consistent terminology throughout the repository.

Do not introduce alternate names for an established concept.

Examples include:

* Virtual Network
* Resource Group
* WireGuard VPN Gateway
* Jumpbox
* Command Codex

---

## Punctuation Standards

* Use consistent punctuation throughout each document.
* Complete sentences should end with periods.
* Headings shall not end with punctuation.
* Table headers shall not end with punctuation.

---

## Governance Language

Governance documents shall use normative language where appropriate.

Preferred terms include:

* shall
* should
* may
* must not

Normative language reduces ambiguity and improves consistency.

---

## Consistency Rule

Repository consistency takes precedence over individual stylistic preference.

When an established repository standard exists, it shall be followed even if another approach is equally valid.

---

## Relationship to Other Governance Documents

This document defines how repository documentation is written.

Document structure is defined by the Document Standards Manual.

Documentation lifecycle is defined by the Repository Workflow.

Publication requirements are defined by the Publication Quality Gate.

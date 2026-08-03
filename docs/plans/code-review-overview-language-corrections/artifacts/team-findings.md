# Team Findings: Understandable and Usable Output from Code Review and Code Overview

This file records every finding raised by the review team for this feature, and how each was resolved. Behavioral
outcomes live in [../feature-specification.md](../feature-specification.md); decisions the findings affected live in
[decision-log.md](decision-log.md). No `feature-technical-notes.md` was created for this feature: every mechanic the
spec relies on is discoverable from the repository, so no note qualified.

**Review team.** `han-core:junior-developer`, `han-core:user-experience-designer`, `han-core:edge-case-explorer`.
Feature size: medium.

## Major findings

<!-- Populated after the review round returns. -->

## Minor edits

<!-- Populated after the review round returns. -->

## Escalation register

### E1: Whether the extended gloss rule binds every Han document or only the overview

- **Answer:** "go with first" — put it in Han's shared writing standard, so every Han document gains the rule and the
  agent that rewrites finished drafts enforces it.
- **Landed in:** [D10](decision-log.md#d10-where-the-extended-gloss-rule-lives), and the Primary Flow and Coordinations
  sections of the specification.

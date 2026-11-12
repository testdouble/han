# Investigation: {Issue Title}

**Investigation type:** bug: Find the root cause of a failure and plan the fix

<!-- Section rule: include a section only when this investigation produced meaningful content for it. Omit any section (its heading and body) that would otherwise be empty or "N/A", and keep the sections that remain in the order shown below. Sections marked CONDITIONAL are the ones most often omitted, but the rule applies to every section. -->

<!-- Readability: write prose regions against the shared readability standard the skill sources via han-communication:readability-guidance. Lead with the main point (the root cause / the answer) first, give each heading a descriptive name, keep one idea per paragraph with the first sentence carrying it, number sequential steps and bullet non-sequential items, and disclose detail progressively. This does not touch code fences, file:line citations, or diagram bodies. -->

<!-- One-line orientation: what this report is and the decision it asks for. -->
<!-- E.g. "Investigation report. Read the Summary, then approve the Planned Fix or push back." -->

## Summary

<!-- One sentence for each field. Reference evidence (E1, E2, ...) and validation (V1, V2, ...) where appropriate. -->
<!-- Reader key: (E#) items are defined under Evidence Summary and (V#) items under Validation Results, both near the end of this report. -->

- **Root Cause:** <!-- What caused the problem -->
- **Fix:** <!-- What the planned changes will do -->
- **Why Correct:** <!-- Reference the strongest evidence supporting the fix -->
- **Validation Outcome:** <!-- What validation confirmed or changed -->
- **Remaining Risks:** <!-- See Confidence Assessment under Validation Results. -->

## Problem Statement

<!-- Describe the problem in concrete terms. Include: -->
<!-- - Symptoms: What is happening? (error messages, unexpected behavior, failed tests) -->
<!-- - Expected behavior: What should happen instead? -->
<!-- - Conditions: When does it occur? (specific inputs, environments, timing) -->
<!-- - Impact: Who/what is affected? (users, builds, deployments, other features) -->

## Root Cause Analysis

### Root Cause

<!-- One sentence stating the root cause. -->

### Detailed Analysis

<!-- Explain the root cause in detail. Reference evidence items by number: (E1), (E2), etc. -->
<!-- Trace the causal chain from root cause to symptom, showing how each piece of evidence supports the conclusion. -->

## Planned Fix

### Approach

<!-- One sentence describing what the fix will do. -->

### Changes

<!-- List every file that needs to change. Reference evidence (E1, E2, ...) and standards to justify each change. -->

#### `path/to/first-file.ext`

- **Change:** <!-- What will be modified, added, or removed -->
- **Evidence:** <!-- Which evidence items justify this change, e.g., (E1), (E3) -->
- **Standards:** <!-- Which coding standards apply -->
- **Details:** <!-- Implementation specifics — new function signatures, changed logic, updated tests -->

#### `path/to/second-file.ext`

- **Change:** <!-- What will be modified, added, or removed -->
- **Evidence:** <!-- Which evidence items justify this change -->
- **Standards:** <!-- Which coding standards apply -->
- **Details:** <!-- Implementation specifics -->

<!-- Add more file entries as needed -->

<!-- shared: evidence-and-validation.md -->

## Coding Standards Reference

<!-- CONDITIONAL: Include this section only when standards, conventions, ADRs, or patterns inferred from surrounding code govern the fix. These are the standards the fix was written against. If nothing governs the fix, omit the section per the section rule at the top. -->

| Standard                              | Source                                                     | Applies To                          |
| ------------------------------------- | ---------------------------------------------------------- | ----------------------------------- |
| Description of standard or convention | File path, ADR number, or "inferred from surrounding code" | Which files or changes this governs |

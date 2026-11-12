# Available Options: {Goal}

**Investigation type:** available-options: Compare the ways a piece of work could be done in this codebase

<!-- Section rule: include a section only when this investigation produced meaningful content for it. Omit any section (its heading and body) that would otherwise be empty or "N/A", and keep the sections that remain in the order shown below. Sections marked CONDITIONAL are the ones most often omitted, but the rule applies to every section. -->

<!-- Readability: write prose regions against the shared readability standard the skill sources via han-communication:readability-guidance. Lead with the recommendation, give each heading a descriptive name, keep one idea per paragraph with the first sentence carrying it, number sequential steps and bullet non-sequential items, and disclose detail progressively. This does not touch code fences, file:line citations, or diagram bodies. -->

<!-- One-line orientation: what this report is and the decision it supports. -->
<!-- E.g. "Options for adding a fixed-amount coupon. Read the Summary, then the Comparison, before planning the change." -->

## Summary

<!-- One sentence for each field. Reference evidence (E1, E2, ...) and validation (V1, V2, ...) where appropriate. -->
<!-- Reader key: (E#) items are defined under Evidence Summary and (V#) items under Validation Results, both near the end of this report. -->

- **Recommendation:** <!-- The option to take, in one sentence -->
- **Options Considered:** <!-- The options, by name -->
- **Deciding Factor:** <!-- The constraint or evidence that settled the call -->
- **Validation Outcome:** <!-- What validation confirmed or changed -->
- **Remaining Risks:** <!-- See Confidence Assessment under Validation Results. -->

## Goal and Constraints

<!-- The work to be done, restated plainly. Then the constraints any option must meet, each citing evidence: (E1), (E2). -->

## Current State

<!-- What the code does today where the work would land, citing evidence. -->

## Options

<!-- Two or more genuinely different ways to do the work in this codebase. Include an option only when the evidence shows the codebase can support it. -->

### Option 1: {Name}

- **How it works:** <!-- The approach, in plain words -->
- **Change surface:** <!-- The files and types it touches -->
- **Fits existing patterns:** <!-- Which existing code it follows or departs from, citing evidence -->
- **Costs and risks:** <!-- What it costs to build and keep, and what could go wrong -->

### Option 2: {Name}

- **How it works:**
- **Change surface:**
- **Fits existing patterns:**
- **Costs and risks:**

<!-- Add more options as needed -->

## Comparison

<!-- Options against the constraints from Goal and Constraints. -->

| Constraint   | Option 1       | Option 2       |
| ------------ | -------------- | -------------- |
| {constraint} | {how it fares} | {how it fares} |

## Recommendation

<!-- The option that best meets the constraints, why, and what would change the call. -->

<!-- shared: evidence-and-validation.md -->

## Coding Standards Reference

<!-- CONDITIONAL: Include this section only when standards, conventions, ADRs, or patterns inferred from surrounding code bear on the options. If nothing does, omit the section per the section rule at the top. -->

| Standard                              | Source                                                     | Bears On                   |
| ------------------------------------- | ---------------------------------------------------------- | -------------------------- |
| Description of standard or convention | File path, ADR number, or "inferred from surrounding code" | Which options this governs |

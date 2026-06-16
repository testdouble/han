# Investigation: {Issue Title}

<!-- Section rule: include a section only when this investigation produced meaningful content for it. Omit any section (its heading and body) that would otherwise be empty or "N/A", and keep the sections that remain in the order shown below. Sections marked CONDITIONAL are the ones most often omitted, but the rule applies to every section. -->

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

## Evidence Summary

<!-- List every piece of evidence gathered during investigation. -->
<!-- Number each item sequentially (E1, E2, E3, ...) so they can be referenced throughout the document. -->
<!-- Every item must include a concrete source — no unsupported claims. -->

### E1: {Brief description of finding}

- **Source:** `path/to/file.ext:line_number` <!-- or git commit, log output, test result -->
- **Finding:**
  ```
  <!-- Relevant code snippet, error message, or log output -->
  ```
- **Relevance:** <!-- How this evidence connects to the problem -->

### E2: {Brief description of finding}

- **Source:** `path/to/file.ext:line_number`
- **Finding:**
  ```
  <!-- Relevant code snippet, error message, or log output -->
  ```
- **Relevance:** <!-- How this evidence connects to the problem -->

### E3: {Brief description of finding}

- **Source:** `path/to/file.ext:line_number`
- **Finding:**
  ```
  <!-- Relevant code snippet, error message, or log output -->
  ```
- **Relevance:** <!-- How this evidence connects to the problem -->

<!-- Add more evidence items as needed (E4, E5, ...) -->

## Validation Results

<!-- Document how the fix was stress-tested by adversarial validation and the resulting confidence. -->

### Counter-Evidence Investigated

<!-- Number each validation finding (V1, V2, ...) so they can be referenced in the Summary. -->

#### V1: {Hypothesis tested}

- **Hypothesis:** <!-- What was assumed to be wrong or what could fail -->
- **Investigation:** <!-- What was checked — file paths, code searched, tests run -->
- **Result:** Confirmed / Refuted / Partially Refuted <!-- Did the original analysis hold up? -->
- **Impact:** <!-- If refuted: what changed in the plan. If confirmed: why this supports the original analysis. -->

#### V2: {Hypothesis tested}

- **Hypothesis:** <!-- What was assumed to be wrong or what could fail -->
- **Investigation:** <!-- What was checked -->
- **Result:** Confirmed / Refuted / Partially Refuted
- **Impact:** <!-- Effect on the plan -->

<!-- Add more validation findings as needed (V3, V4, ...) -->

### Adjustments Made

<!-- CONDITIONAL: Include only if validation findings caused changes to the plan. -->
<!-- List what changed and which validation finding (V1, V2, ...) triggered each change. -->

### Confidence Assessment

- **Confidence:** High / Medium / Low
- **Remaining Risks:** <!-- Known risks, areas not fully validated, or assumptions that could not be verified -->

## Coding Standards Reference

<!-- CONDITIONAL: Include this section only when standards, conventions, ADRs, or patterns inferred from surrounding code govern the fix. These are the standards the fix was written against. If nothing governs the fix, omit the section per the section rule at the top. -->

| Standard | Source | Applies To |
|----------|--------|------------|
| Description of standard or convention | File path, ADR number, or "inferred from surrounding code" | Which files or changes this governs |

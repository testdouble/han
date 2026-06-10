# Investigation: {Issue Title}

<!-- One-sentence summary of the problem being investigated. -->

## Problem Statement

<!-- Describe the problem in concrete terms. Include: -->
<!-- - Symptoms: What is happening? (error messages, unexpected behavior, failed tests) -->
<!-- - Expected behavior: What should happen instead? -->
<!-- - Conditions: When does it occur? (specific inputs, environments, timing) -->
<!-- - Impact: Who/what is affected? (users, builds, deployments, other features) -->

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

## Root Cause Analysis

### Summary

<!-- One sentence stating the root cause. -->

### Detailed Analysis

<!-- Explain the root cause in detail. Reference evidence items by number: (E1), (E2), etc. -->
<!-- Trace the causal chain from root cause to symptom, showing how each piece of evidence supports the conclusion. -->

## Coding Standards Reference

<!-- CONDITIONAL: Include this section if coding standards, conventions, or ADRs were found that apply to the fix. -->
<!-- If no explicit standards were found, note that and document patterns inferred from surrounding code. -->

| Standard | Source | Applies To |
|----------|--------|------------|
| Description of standard or convention | File path, ADR number, or "inferred from surrounding code" | Which files or changes this governs |

## Planned Fix

### Summary

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

## Validation Results

<!-- Document the results of adversarial validation from Step 5. -->

### Counter-Evidence Investigated

<!-- Number each validation finding (V1, V2, ...) so they can be referenced in the final summary. -->

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

## Final Summary

<!-- One sentence for each field. Reference evidence (E1, E2, ...) and validation (V1, V2, ...) where appropriate. -->

- **Root Cause:** <!-- What caused the problem -->
- **Fix:** <!-- What the planned changes will do -->
- **Why Correct:** <!-- Reference the strongest evidence supporting the fix -->
- **Validation Outcome:** <!-- What validation confirmed or changed -->
- **Remaining Risks:** <!-- See Confidence Assessment above -->

# Shared Report Sections: Evidence and Validation

<!-- Every investigation type's report carries these sections. Each type template holds one line `<!-- shared: evidence-and-validation.md -->`; write these sections in that line's place, in the order shown. The lazy-create rule applies here as everywhere: omit a section that would be empty. -->

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
- **Relevance:** <!-- How this evidence connects to the question -->

### E2: {Brief description of finding}

- **Source:** `path/to/file.ext:line_number`
- **Finding:**
  ```
  <!-- Relevant code snippet, error message, or log output -->
  ```
- **Relevance:** <!-- How this evidence connects to the question -->

### E3: {Brief description of finding}

- **Source:** `path/to/file.ext:line_number`
- **Finding:**
  ```
  <!-- Relevant code snippet, error message, or log output -->
  ```
- **Relevance:** <!-- How this evidence connects to the question -->

<!-- Add more evidence items as needed (E4, E5, ...) -->

## Validation Results

<!-- Document how the findings were stress-tested by adversarial validation and the resulting confidence. -->

### Counter-Evidence Investigated

<!-- Number each validation finding (V1, V2, ...) so they can be referenced in the Summary. -->

#### V1: {Hypothesis tested}

- **Hypothesis:** <!-- What was assumed to be wrong, missing, or likely to fail -->
- **Investigation:** <!-- What was checked — file paths, code searched, tests run -->
- **Result:** Confirmed / Refuted / Partially Refuted <!-- Did the original analysis hold up? -->
- **Impact:** <!-- If refuted: what changed in the report. If confirmed: why this supports the original analysis. -->

#### V2: {Hypothesis tested}

- **Hypothesis:** <!-- What was assumed to be wrong, missing, or likely to fail -->
- **Investigation:** <!-- What was checked -->
- **Result:** Confirmed / Refuted / Partially Refuted
- **Impact:** <!-- Effect on the report -->

<!-- Add more validation findings as needed (V3, V4, ...) -->

### Adjustments Made

<!-- CONDITIONAL: Include only if validation findings caused changes to the report. -->
<!-- List what changed and which validation finding (V1, V2, ...) triggered each change. -->

### Confidence Assessment

- **Confidence:** High / Medium / Low
- **Remaining Risks:** <!-- Known risks, areas not fully validated, or assumptions that could not be verified -->

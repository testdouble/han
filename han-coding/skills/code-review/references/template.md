# Code Review: {PR title, branch name, or directory name}

<!--
LAZY SECTIONS: render a section ONLY when it has content. Do not emit a heading
followed by empty-state placeholder text. The Review Summary table and the Review
Recommendation are always present; every other section below appears only when it has
at least one item. A clean review is the table's no-issues row plus an approval
recommendation, and nothing else.

FIXED ORDER: when more than one section is present, render them in this order and never
vary it — Critical, Warnings, Suggestions, YAGNI, Security Vulnerabilities, Remediation,
What's Good.

READABILITY: the finding prose and narrative sections follow ../../references/readability-rule.md
— each finding leads with what to do and why, one idea per paragraph, short active sentences,
plain words. The standard governs prose only; it never rewrites task IDs, severities,
file_path:line_number references, EXPLOIT fields, the fixed section headings and their order,
the Review Summary table, or code snippets. The prescribed section headings are fixed, not
subject to the descriptive-heading rule.

PROSE ONCE: each finding's prose lives in exactly one place — its finding block, or its
full security block. The Review Summary table row is an index entry, not prose; a
`Tension with …` pointer note is a pointer, not prose.
-->

## 📋 Review Summary

<!-- Order rows by severity (CRIT first, then WARN, then SUGG), and within each severity by task ID number. Security findings (SEC-###) sort in by their own severity tier. YAGNI findings are NOT included in this summary table — they live in their own section below and are advisory, not corrective. -->

<!-- A corrective finding's severity is already carried by its task-ID prefix (CRIT-/WARN-/SUGG-). A security finding's task ID does not encode a tier, so show the tier inline in the Task ID cell — e.g. `SEC-001 (Critical)` — so the table stands alone as the complete severity-ordered index. -->

<!-- If no issues were found, use the no-issues row instead. -->

| Task ID | Category | File | Description |
|---------|----------|------|-------------|
| {TASK-ID} | {Category} | {file:line} | {Brief description of finding} |
| SEC-### ({Critical\|High\|Medium}) | {OWASP: A0X} | {file:line} | {Brief description of security vulnerability} |

<!-- No-issues row if applicable: -->
<!-- | — | — | — | No issues found | -->

### Review Recommendation

<!-- Select ONE of the following based on the highest severity present across ALL findings, INCLUDING security findings (whose severity is read from their security block even though they are not listed in the Critical section): -->
<!-- CRIT items (or a Critical-severity security finding) exist: "This code should not be merged until the critical issues are resolved." -->
<!-- WARN items exist (no CRIT, no Critical/High security): "This code can be merged, but the identified warnings should be reviewed first." -->
<!-- SUGG items exist (no CRIT/WARN): "This code can be merged, but the suggestions should be reviewed first." -->
<!-- No items: "This code can be approved." -->

{Selected recommendation text}

## Recommended Changes

<!-- Render only the severity subsections that have findings. Omit any that are empty. -->

### 🔴 Critical

<!-- Finding block format. Keep `file:line` (the actionable anchor). Omit the [Category] label when the category is generic and already conveyed by the table and task-ID prefix (logic, performance, clarity, and similar). Keep a category cue only when it names content a standalone reader needs and the task ID does not supply — an ADR violation that names the record, a standards violation that names the standard, or a security finding. -->

<!-- Generic category (omit the label): -->
**{TASK-ID}** `{file_path:line_number}`
{Description of issue.}
```suggestion
{Suggested fix}
```

<!-- Content-bearing category (keep the label): -->
**{TASK-ID}** **[{ADR: record / Standard: name / Security}]** `{file_path:line_number}`
{Description of issue.}
```suggestion
{Suggested fix}
```

### 🟡 Warnings

**{TASK-ID}** `{file_path:line_number}`
{Description of concern.}

### 🔵 Suggestions

**{TASK-ID}** `{file_path:line_number}`
{Optional improvement idea.}

### 🟡 YAGNI

> These findings will not be corrected unless explicitly requested. They are documented so the team can decide consciously whether to keep, simplify, or defer the items.

<!-- One line per finding plus a single reopen-trigger clause. -->

**{YAGNI-###}** **[{Named anti-pattern from yagni-rule.md, or "Evidence-test failure" / "Simpler-version available"}]** `{file_path:line_number}` — {description of the code that fails the YAGNI evidence test or has a strictly simpler version available}. Reopen / keep when: {the concrete trigger that would justify keeping this code as written}.

## 🔐 Security Vulnerabilities

<!-- Render this whole section only when proven vulnerabilities exist. Each finding's full prose lives here and nowhere else — there is no cross-reference under Critical. -->

**SEC-001: [Brief descriptive title]**
- **OWASP:** A0X — Category Name
- **Location:** `file_path:line_number`
- **Evidence:** {exact code snippet demonstrating the vulnerability}
- **EXPLOIT:** {step-by-step attack path showing real exploitability}
- **Severity:** Critical | High | Medium

### Remediation

<!-- A single short note. Reference the SEC-### IDs and state the actionable remediation in one or two sentences. Do NOT repeat the finding descriptions, and do NOT add a generic "how to prevent this going forward" narrative. -->

{Remediation referencing SEC-### IDs, one or two sentences.}

## ✅ What's Good

<!-- Render this section ONLY when there is a specific, substantive positive worth recording. Omit it entirely otherwise — do not force generic praise. -->

- {Specific, substantive positive}

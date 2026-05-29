# Code Review: {PR title, branch name, or directory name}

## 📋 Review Summary

<!-- Order rows by severity (CRIT first, then WARN, then SUGG), and within each severity by task ID number. YAGNI findings are NOT included in this summary table — they live in their own section below and are advisory, not corrective. -->

<!-- If no issues were found, use the no-issues row instead. -->

| Task ID | Category | File | Description |
|---------|----------|------|-------------|
| {TASK-ID} | {Category} | {file:line} | {Brief description of finding} |
| SEC-### | {OWASP: A0X} | {file:line} | {Brief description of security vulnerability} |

<!-- No-issues row if applicable: -->
<!-- | — | — | — | No issues found | -->

### Review Recommendation

<!-- Select ONE of the following based on the highest severity found: -->
<!-- CRIT items exist: "This code should not be merged until the critical issues are resolved." -->
<!-- WARN items exist (no CRIT): "This code can be merged, but the identified warnings should be reviewed first." -->
<!-- SUGG items exist (no CRIT/WARN): "This code can be merged, but the suggestions should be reviewed first." -->
<!-- No items: "This code can be approved." -->

{Selected recommendation text}

## Recommended Changes

### 🔴 Critical

{If no critical items: "No critical fixes needed."}

**{TASK-ID}** **[{Category}]** `{file_path:line_number}`
{Description of issue.}
```suggestion
{Suggested fix}
```

<!-- Security cross-reference pattern (one per SEC-### finding, all severities): -->
<!-- **CRIT-###** **[Security]** → see SEC-### for full exploit path -->

### 🟡 Warnings

{If no warning items: "No warnings."}

**{TASK-ID}** **[{Category}]** `{file_path:line_number}`
{Description of concern.}

### 🔵 Suggestions

{If no suggestion items: "No suggestions."}

**{TASK-ID}** **[{Category}]** `{file_path:line_number}`
{Optional improvement idea.}

### 🟡 YAGNI

> These findings will not be corrected unless explicitly requested. They are documented so the team can decide consciously whether to keep, simplify, or defer the items.

{If no YAGNI items: "No YAGNI candidates found."}

**{YAGNI-###}** **[{Named anti-pattern from yagni-rule.md, or "Evidence-test failure" / "Simpler-version available"}]** `{file_path:line_number}`
{Description of the code introduced by this change that fails the YAGNI evidence test or has a strictly simpler version available.}
- **Why YAGNI:** {which gate failed — evidence test or simpler-version test, with the specific reason}
- **Simpler form considered:** {one-line description of the smaller alternative that would satisfy the same evidence, or "n/a — defer entirely until reopen trigger fires"}
- **Reopen / keep when:** {the concrete trigger that would justify keeping this code as written}

### ✅ What's Good

<!-- Always include 2-4 bullet points highlighting positive aspects: -->
- {Patterns followed correctly}
- {Security practices implemented properly}
- {Code quality improvements}
- {Other notable positive aspects}

## 🔐 Security Vulnerabilities

{If no proven vulnerabilities: "No proven security vulnerabilities found."}

**SEC-001: [Brief descriptive title]**
- **OWASP:** A0X — Category Name
- **Location:** `file_path:line_number`
- **Evidence:** {exact code snippet demonstrating the vulnerability}
- **EXPLOIT:** {step-by-step attack path showing real exploitability}
- **Severity:** Critical | High | Medium

## Security Improvement Summary

### What Was Found

{Brief factual summary of proven vulnerabilities, referencing SEC-### IDs. No blame. No judgment.}

### How to Improve

{Numbered list of specific, actionable remediation steps tied to SEC-### findings.}

### How to Prevent This Going Forward

{Numbered list of practices, patterns, or tooling that would catch or prevent these classes of vulnerability in future code.}

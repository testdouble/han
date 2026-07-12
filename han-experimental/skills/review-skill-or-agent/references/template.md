# Review report template

<!-- Render a section only when it has content. The Review Summary table and the Review Recommendation are always present. When more than one section is present, keep the fixed order: Critical, Warnings, Suggestions, Legibility, Bloat & Restatement, What's Good. Each finding's prose lives in exactly one place — its finding block; the table row is an index, not a second copy. -->

**Artifact:** {path}

**Scope:** {whole-artifact | diff; add "(inferred)" when the skill chose the scope rather than the caller stating it}

<!-- When review halts, render only this block instead of the full report (never the no-issues table) -->
<!-- ## ⛔ Review Halted

**Reason:** {why review halted}

**Detail:** {detector failure or structural-signal; for a guidance halt, the missing files and the paths searched}

**To proceed:** {name the concrete blocker to fix — the missing files, the absent git repo, or the tool that covers a neither target — then re-invoke; the review restarts from scratch, resuming nothing}. -->

## 📋 Review Summary

Findings: X critical, X warnings, X suggestions, X legibility, X bloat (of them X critical). Critical, warnings, and suggestions are defects and gate the recommendation; legibility and bloat are advisory.

<!-- Render a coverage note when `$gaps` is non-empty — one entry per gap, naming the absent lens — so a reader sees exactly which passes are missing: -->
<!-- **Coverage:** this review is partial.
- {absent lens / reason} -->

<!-- One row per corrective finding, ordered Critical → Warning → Suggestion, then by task ID. Bloat category includes critical/warning/suggestion sub-categories. Use the no-issues row when the review is clean. -->

| Task ID | Category | Location | Description |
|---------|----------|----------|-------------|
| {TASK-ID} | {Category} | {file:line or heading} | {brief description} |

<!-- No-issues row — only when the pool is empty AND `$gaps` is empty; with any gap, mark the row "Partial — see Coverage" instead: -->
<!-- | — | — | — | No issues found | -->

## Review Recommendation

<!-- Decided by the ladder below from the defect and bloat pools; legibility findings are advisory and never gate. -->
<!-- Any `$gaps` entry (a reviewer, triage, or the validator that did not return) bars the clean and no-Critical recommendations — say the review is partial and not a pass. -->
<!-- Conformance & quality reviewer did not return (Step 4/7): "This review is blocked — the conformance pass did not complete, so guidance conformance is unverified. Do not treat this as a pass." This overrides every case below. -->
<!-- Any Critical (incl. a Critical bloat finding): "This artifact should not ship until the critical issues are resolved." -->
<!-- Warning present, no Critical: "Ship after addressing the warnings." -->
<!-- Suggestion, legibility, or bloat only: "Ship as-is; the suggestions, legibility notes, and bloat findings are worth addressing." -->
<!-- Nothing: "This artifact conforms to the guidance and is clean." -->

{recommendation}

## Recommended Changes

<!-- Each defect leads with its consequence class and, when they set the tier, the deciding containment modifiers (e.g. "CORRUPTS — demonstrated, externally-reachable", "BLOCKS", "MISLEADS") so the tier is auditable against the spine in finding-classification.md. -->

### 🔴 Critical
**{TASK-ID}** `{file:line}` — {class + deciding modifiers}

{issue}

### 🟡 Warnings
**{TASK-ID}** `{file:line}` — {class + deciding modifiers}

{concern}

### 🔵 Suggestions
**{TASK-ID}** `{file:line}` — {class}

{improvement}

## 📖 Legibility

<!-- Advisory. A first-time reader could be slowed, but the artifact runs correctly. No severity tier; never gates the recommendation. Omit the section when empty. -->

**{LEGIB-###}** `{file:line}`

{what could confuse a reader, suggested fix}

## 🩹 Bloat & Restatement

<!-- Own pool; a Critical bloat finding still gates the recommendation. Order big-fish first: global findings (cross-step/section duplication, cohesion/decomposition) before small-fish local restatement. A local finding subsumed by a big fish is rolled up into it, not listed separately. -->

**{BLOAT-###}** `{file:line}` — {🔴 Critical|🟡 Warning|🔵 Suggestion}

{what is duplicated/restated/filler or the split proposed, and the consolidation; for a big fish, the local instances it rolls up}

## ✅ What's Good

<!-- Only when there is a specific, substantive positive worth recording. Omit rather than force generic praise. -->

- {specific positive}

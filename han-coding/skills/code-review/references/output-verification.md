# Review Output Verification

The checks Step 9 runs over the finished review before presenting it: the self-consistency pass that
detects contradictory recommendations, then the structural verification items.

Before presenting the review, run the self-consistency check first, then verify the structural items below.

### Step 9.0: Self-consistency check

Detect contradictory recommendations on overlapping code. Run two passes:

1. **Extraction pass.** For every finding (manual and agent), extract a tuple:
   `{task-id, file-path, line-range, recommended-action-summary}`. The recommended-action-summary is a one-line summary
   of what the finding tells the developer to do (e.g., "remove the className.toMatch assertion", "add a
   className.toMatch assertion", "wrap the call in try/catch", "remove the try/catch wrapper"). Skip findings that have
   no actionable recommendation.
2. **Comparison pass.** For every pair of tuples on the same `file-path` whose `line-range` overlaps, check whether the
   two `recommended-action-summary` values prescribe opposite actions on the same code (one says add X, the other says
   remove X; one says split, the other says merge; one says inline, the other says extract). For each contradictory pair
   found:
   - Demote both findings by one severity (CRIT → WARN, WARN → SUGG, SUGG stays at SUGG and is annotated rather than
     dropped).
   - Append a `Tension with {other-task-id}:` note to each finding's body, naming the contradicting task ID and the
     opposite action it prescribes. The human reviewer must adjudicate.

Scope is overlapping line ranges in a single file only. Cross-file semantic contradictions are out of scope for this
check.

### Step 9.1: Structural verification

Then verify:

1. Task IDs are sequential within each category (CRIT-001, CRIT-002, ...; WARN-001, WARN-002, ...)
2. Agent findings from every dispatched agent (testing, edge-case, structural, behavioral, concurrency, data, devops,
   han-core:junior-developer) have valid task IDs continuing from manual review IDs. Findings from agents that were not
   dispatched in Step 3 must not appear.
3. Agent findings have valid `file_path:line_number` references
4. Deferred tests note is present if the han-core:test-engineer produced skipped items
5. The Review Summary table includes every corrective finding (CRIT/WARN/SUGG) and every security finding, and matches
   the sections that are present. YAGNI findings are excluded from the table (see rule 12). For findings whose block
   omits the category, the table is the only place that category appears. Every CRIT/WARN/SUGG row carries its fix route
   in the `Fix` column and every security row carries `—` there; any finding the review established may never fire opens
   its Description cell with that cue.
6. All `file_path:line_number` references point to real files from the file list determined in Step 1
7. SEC-### IDs are sequential starting at SEC-001
8. Every SEC-### finding has an `EXPLOIT:` field populated
9. Security findings are NOT cross-referenced in `### 🔴 Critical`. Instead, when any SEC-### finding exists, the Review
   Recommendation reflects the highest severity across all findings including the security findings' own severities (a
   Critical-severity security finding yields a do-not-merge recommendation)
10. Junior-developer findings that overlap with a specialist agent's finding reference the specialist finding instead of
    duplicating it
11. The report file is the COMPLETE deliverable. It carries no trailing commentary or sign-off, and no part of it is
    pasted into the conversation. What the run says in the conversation is the short closing message Step 10 specifies,
    and nothing else.
12. The `### 🟡 YAGNI` section, when present, opens with the verbatim statement defined in Review Constraints, and YAGNI
    findings appear ONLY in this section — not duplicated under CRIT/WARN/SUGG and not in the Review Summary table.
13. Any `Tension with {other-task-id}:` notes added by Step 9.0 appear on both members of each contradictory pair.
14. No section is rendered empty, and present sections appear in the template's fixed order, per Step 8. The only
    always-present elements are the Review Summary table and the Review Recommendation.
15. Each security finding's severity tier is shown inline in its Review Summary table row (e.g., `SEC-001 (Critical)`),
    since its task ID does not encode a tier.
16. Finding blocks omit the `[Category]` label for generic categories (already carried by the table and the task-ID
    prefix) and keep it only for content-bearing categories — ADR violations (naming the record), standards violations
    (naming the standard), and security. The `file_path:line_number` reference remains on every block.
17. When proven security vulnerabilities exist, exactly one Remediation note follows the SEC-### blocks and references
    the SEC-### IDs without restating the finding descriptions. When there are no security findings, neither the
    Security Vulnerabilities section nor the Remediation note is rendered.
18. The `### ✅ What's Good` section is rendered only when a specific, substantive positive exists; it is omitted
    entirely rather than filled with generic praise.
19. Every CRIT / WARN / SUGG block opens with its plain-language explanation, and every SEC block carries its
    `What this means` line. YAGNI findings carry neither, because their reopen trigger already answers it.
20. Every CRIT / WARN / SUGG block names a fix route. SEC blocks name none, since the single Remediation note carries
    it.
21. A finding the review established may never fire carries that cue in two places and they agree: leading its own
    explanation, and opening its summary row's Description cell.

Every item in this list is fixed before the review is presented, never reported alongside it as a caveat. A required
piece of content that is missing is missing; saying so in the message does not put it in the report.

### Step 9.2: Readability self-check

Run the standardized readability self-check (the shared standard is in your context from
`han-communication:readability-guidance`) over the report's prose regions only — never inside task IDs, severity labels,
`file_path:line_number` references, `EXPLOIT:` fields, category labels, the Review Summary table, or any code snippet.
Confirm each criterion and fix any failure before presenting:

1. Each finding's prose leads with its main point (what to do and why), not with background.
2. Descriptive-heading check: this applies to any sub-headings a finding body adds, not to the report's prescribed
   section headings, which are fixed.
3. Each paragraph carries one idea and leads with it.
4. No sentence runs past the soft length flag (about thirty words) without reason.
5. No word from the vocabulary blocklist (the writing-voice profile's "Avoided words and phrases" and "AI slop to avoid"
   lists) is present.
6. Every fact is preserved — every finding's recommended action, severity, location, quantity, and named entity survives
   with its precision intact.
7. The report matches the shape the reader asked for, in count, format, and register. Where their stated shape collides
   with a criterion above, their shape wins.

Fidelity wins: the standard governs how each finding reads, and drops a required technical fact only when the reader
asked for less and losing it would not change what they do next.

# Investigation: Code-Review Skill Guardrails

Author: Claude (River's investigation, 2026-05-15).
Sources: three real PR bundles (`tmp/gearjot-v2-web-pr-299/`, `pr-307/`, `pr-339/`) plus a behavioral trace of the `code-review` skill and its dispatched agents.
Evidence: 62 verbatim findings across the three PRs and 8 behavioral findings about the skill itself, written to:

- [artifacts/pr-299-evidence.md](artifacts/pr-299-evidence.md) (E1...E23)
- [artifacts/pr-307-evidence.md](artifacts/pr-307-evidence.md) (E1...E22)
- [artifacts/pr-339-evidence.md](artifacts/pr-339-evidence.md) (E1...E17)
- [artifacts/skill-behavioral-trace.md](artifacts/skill-behavioral-trace.md) (B1...B8)

---

## Executive summary

All four reported symptoms (going too deep, YAGNI under-applying, severity inflation, and context not forwarded) are real, well-evidenced across multiple PRs, and traceable to specific lines in `plugin/skills/code-review/SKILL.md`, its three reference files, and the dispatched agent definitions. They are not separate bugs but four expressions of two underlying structural failures:

1. **Calibration is defined once and bypassed everywhere else.** The skill's Step 3.3 calibration directive (which scopes findings to the change and demotes by change size) lives only inside the agent prompt that goes out to specialists. The classification step that processes what the agents return (Step 7) uses a different rubric (`agent-finding-classification.md`) that does not apply the size-based demotion and that sets "Most findings land here = WARN" as a default floor for six of nine agent types. Two specialist agents (`structural-analyst`, `behavioral-analyst`) also carry "skeptic-default" rules in their own bodies that explicitly conflict with the calibration directive. The result is that severity inflation and off-rails findings are not a bug; they are the structural default behavior of the skill, and the user has been compensating by passing mode flags ("WARN-justified, SUGG suppressed per reviewer instruction") and by running the review twice on the same PR.

2. **User-provided focus areas are captured at Step 1 and never reach the sub-agents that produce most findings.** The skill notes the focus areas "for use in Step 4", but the nine agent prompt templates in Step 3.5 have no placeholder for them. PR descriptions, implementation plans, deferred items, and explicit "what to look at first" lists from the human author are not loaded by the skill or forwarded to agents. The agents work from the file list alone. This is why PR 307's reviewer raised WARN-002 and WARN-003 against premises the implementation plan had already resolved, and why PR 339's review answered none of the three concerns the PR author explicitly named.

The most consequential single piece of evidence is that PR #299 required a **second `han:code-review` run with explicit reclassification**, in which "7 of the prior 11 warnings were downgraded to suggestions on a second pass" because they were "defensive refinements or refactoring opportunities, not reachable defects" (`pr-299-review-2.md:3`). The user has already been running the workaround. The investigation's job is to bake that second pass into the first pass.

There are no `adversarial-validator` confidence-busting counter-examples in the evidence: every finding category is corroborated by at least two of the three PR bundles plus a behavioral trace. The investigation's confidence is high.

Risk level: the proposed solutions edit a single skill body and its three reference files. They do not change the agent definitions invasively, with the exception of removing two skeptic-default rules from `structural-analyst.md` and `behavioral-analyst.md`. The blast radius is contained to the code-review pipeline and its derivative `gh-pr-review`.

---

## Indexed examples (cross-PR)

Examples are grouped by the four symptoms. Each example references at least one E# finding in the artifacts directory.

### Symptom 1: Goes too deep / off the rails

- **EX1.1.** PR 299's first pass produced 11 warnings, of which 7 were demoted to suggestions because they concerned code outside the change surface or theoretical rather than reachable defects. Evidence: PR 299 E1, E3, E4, E6, E7.
- **EX1.2.** PR 307 WARN-002 raised "API may return bad coordinates" against a frontend, even though the database CHECK constraint, the non-nullable Go DTO, and Go's JSON serializer (all in a different repository) make the bad-coordinate state unrepresentable. Evidence: PR 307 E1, E5, E6.
- **EX1.3.** PR 307 WARN-003 raised a SPA-style company-switch state-leak finding against an app whose company-switch path is a full-document redirect that tears down all module state. The four files proving this were never changed by the PR and were never read by the review. Evidence: PR 307 E2, E4, E7.
- **EX1.4.** PR 339 WARN-001 flagged a stale `data-testid` in a documentation file outside the review's own declared 2-file scope. The reviewer explicitly labeled the issue "not introduced by this branch but adjacent". Evidence: PR 339 E1, E3.
- **EX1.5.** PR 339 missed an in-scope `text-warning-foreground` bug in the same file as CRIT-001 with the same root cause pattern, because attention was spent on out-of-scope documentation drift. The PR author found the bug in their own pass. Evidence: PR 339 E4.
- **EX1.6.** PR 299's feature overview directly records: "Several review comments were 'you should add filtering / a list pane / a current-location button' and the team consistently said: that's a different slice." Evidence: PR 299 E7.

### Symptom 2: YAGNI under-applies

- **EX2.1.** PR 299's first pass surfaced one YAGNI finding (for dead code) while filing seven YAGNI-shaped findings as warnings: speculative defensive code, refactor opportunities, single-implementation abstractions. Evidence: PR 299 E8, E9, E10.
- **EX2.2.** PR 307 raised YAGNI-001 and then immediately accepted the developer's rationale in the same comment, instead of routing the finding to a `project-manager` or `user-experience-designer` agent who could weigh the demoability question first. Evidence: PR 307 E8, E9.
- **EX2.3.** PR 307 WARN-002 and WARN-003 are textbook YAGNI candidates (defensive code at a trusted internal boundary, for a failure mode the architecture cannot produce) but were filed as warnings. Evidence: PR 307 E11.
- **EX2.4.** PR 339's review reported zero YAGNI findings even though the implementation plan logged an explicit YAGNI rejection (D-5: no `<LabeledRow>` component extraction) that the review never validated against the implementation. Evidence: PR 339 E5, E6, E7.
- **EX2.5.** PR 339 WARN-002 recommended adding an implementation-coupled assertion (`className.toMatch(/italic/)`) which is itself the named anti-pattern WARN-003 was flagging. The review created the YAGNI violation rather than detecting it. Evidence: PR 339 E8.
- **EX2.6.** PR 307 PR description pre-acknowledged the placeholder rationale 21 seconds before YAGNI-001 fired. The YAGNI check ran without weighting the PR-level context. Evidence: PR 307 E10.

### Symptom 3: Severity inflation

- **EX3.1.** PR 299's second review opened with the explicit statement that 7 of 11 first-pass warnings were demoted to suggestions on reclassification. Evidence: PR 299 E11, E12.
- **EX3.2.** PR 299 SUGG-003 was a first-pass warning even though the concurrency agent that raised it labeled the defect "effectively impossible in production". Evidence: PR 299 E6, E13.
- **EX3.3.** PR 299 SUGG-004 was a first-pass warning over a "hypothetical" threat with explicit "defense-in-depth" rationale. Evidence: PR 299 E14.
- **EX3.4.** PR 307 had a 3:1 ratio of won't-fix to accepted WARN findings. Evidence: PR 307 E12, E13, E14, E16.
- **EX3.5.** PR 339 raised WARN-002 and WARN-003 with co-equal severity even though they prescribed contradictory remedies for the same category of issue. The user resolved WARN-002 by doing the opposite of what it recommended. Evidence: PR 339 E10, E11, E12.
- **EX3.6.** The user has been compensating with mode flags ("WARN-justified, SUGG suppressed per reviewer instruction") because the default mode produces inflation. Evidence: PR 299 E17.
- **EX3.7.** Process log explicitly names the missing first-pass reachability gate: "Bake this into the first pass instead of needing a second pass to catch it." Evidence: PR 299 E10, E15, E16.

### Symptom 4: Context not forwarded to sub-agents

- **EX4.1.** The skill's nine agent prompt templates have no placeholder for user-provided focus areas. The user's free-form argument reaches Step 4 only. Evidence: B1.
- **EX4.2.** PR 339's PR description named three specific reviewer concerns (conditional-logic copy, DOM ordering at the section boundary, intentional UUID exposure). The review surfaced none of them. Evidence: PR 339 E14, E15, E16, E17.
- **EX4.3.** PR 307's implementation plan in issue #304 explicitly resolved the WARN-003 question before any code was written: "The viewport flag does not need `clearForCompanySwitch()` because a company switch hard-navigates; it just needs `_resetForTest()`." The review raised WARN-003 anyway. Evidence: PR 307 E18, E22.
- **EX4.4.** PR 299's PR description's Deferred section explicitly listed the Sentry PII work as out of scope. Both review passes re-raised it as a security gap. Evidence: PR 299 E20, E21.
- **EX4.5.** PR 307's review fired 21 seconds after PR open, suggesting agents started before the PR-level context could be loaded by the orchestrator. Evidence: PR 307 E21.
- **EX4.6.** Process logs across all three PRs name "before raising a violates-standard-X warning, prove the standard's premise applies", "skill prompts should know this is a multi-repo project", and "test-gap chaining in code review needs prior-review context". Evidence: PR 307 E19, E20; PR 299 E22, E23.

---

## Indexed root causes

Each cause C# names the structural mechanism, cites the skill file or line, and points at the evidence and behavioral findings that support it.

### C1: Severity floor in the classification rubric pulls findings up to WARN
- **Location:** `plugin/skills/code-review/references/agent-finding-classification.md`, lines 6, 14, 34, 42, 50, 58, 68. Seven of nine agent rubrics include the phrase "Most findings land here" pointing at WARN.
- **Effect:** Any finding that is ambiguous between SUGG and WARN is pulled up to WARN by the rubric's documented expected landing zone.
- **Supports:** symptom 3 (severity inflation).
- **Evidence:** PR 299 E11-E17; PR 307 E12-E16; PR 339 E9-E13; B3.

### C2: Step 7 reclassifies agent output without applying Step 3.3's size-based demotion
- **Location:** `plugin/skills/code-review/SKILL.md`, Step 7 (line 253 onward) reads agent output files and applies the rubric in `agent-finding-classification.md`. The size-based demotion rules from Step 3.3's calibration directive ("Small change: omit Suggestions entirely") are inside the agent prompt only and are not referenced from the rubric.
- **Effect:** Even if an agent honored the calibration directive in its output file, the classification step re-raises severity according to the rubric, which has no notion of change size.
- **Supports:** symptom 3.
- **Evidence:** B4; PR 299 E17.

### C3: Skeptic-default rules in two specialist agents conflict with the calibration directive
- **Location:** `plugin/agents/structural-analyst.md` Rules section ("Default posture is skeptical: assume structural problems exist until proven otherwise. When in doubt about whether something is a structural issue, include it: a false positive is cheaper than a missed risk"). Same rule with "behavioral" substituted in `plugin/agents/behavioral-analyst.md`.
- **Effect:** The agent body says "include when in doubt"; the calibration directive says "prefer the lower severity". The more absolute rule wins.
- **Supports:** symptom 1 (going too deep) and symptom 3.
- **Evidence:** B2; PR 299 E1, E2, E3.

### C4: Adjacent-file and call-site reads in junior-developer and edge-case-explorer pull out-of-scope code into findings
- **Location:** `plugin/agents/junior-developer.md` Protocol 4 ("patterns in code adjacent to what the artifact will change"). `plugin/agents/edge-case-explorer.md` Protocol 1 ("use Grep to search for every call site... read the callers").
- **Effect:** Findings about out-of-scope code flow back into the review as if they concerned the changed files. The Step 3.4 file-list scoping does not constrain these protocols.
- **Supports:** symptom 1.
- **Evidence:** B7; PR 299 E5, E7; PR 339 E1.

### C5: No focus-area or user-context placeholder in any agent prompt template
- **Location:** `plugin/skills/code-review/SKILL.md` Step 3.5, all nine prompt templates. The skill body acknowledges focus areas at Step 1 ("note them for use in Step 4") and Step 4 ("apply extra scrutiny"), but never plumbs them into Step 3.5's templates.
- **Effect:** All eight or nine sub-agents work without the user's focus context. They produce findings unweighted by the user's priorities.
- **Supports:** symptom 4 (context not forwarded).
- **Evidence:** B1; PR 339 E14-E17; PR 307 E17-E22; PR 299 E18-E20.

### C6: No step in the skill loads PR-level or branch-level context beyond a file list
- **Location:** `plugin/skills/code-review/SKILL.md` Step 1 ("Detect review context") reads the script output and the diff. It does not read the PR description, the linked issue, the branch's commit messages, or the planning artifacts in adjacent repos. CLAUDE.md is read for project-discovery purposes only.
- **Effect:** The PR description's "Deferred", "Files of interest", and "What to look at first" sections do not reach the sub-agents. Cross-repo context (planning, linked issues, backend invariants) is never loaded.
- **Supports:** symptom 4 and symptom 1.
- **Evidence:** PR 299 E20, E21; PR 307 E20; PR 339 E14, E15.

### C7: YAGNI is applied as a pattern-match against named anti-patterns rather than as the evidence-test gate the rule requires
- **Location:** `plugin/skills/code-review/references/review-checklist.md` YAGNI section lists anti-patterns as bullet triggers without embedding the affirmative evidence test. `plugin/references/yagni-rule.md` says the rule should be "run the evidence test first; flag only if no evidence applies".
- **Effect:** YAGNI fires on items that pass the evidence test (the user described the need) and misses items that don't match a named anti-pattern but fail the evidence test (novel speculative code that looks normal).
- **Supports:** symptom 2 (YAGNI under-applies) and symptom 1.
- **Evidence:** B6; PR 307 E8, E9, E10, E11; PR 339 E5, E6, E7, E8; PR 299 E8, E9.

### C8: No self-consistency check on findings; contradictory findings can coexist at the same severity
- **Location:** `plugin/skills/code-review/SKILL.md` Step 9 (verification) has eleven checks but no "for each pair of findings on the same file/lines, detect contradictory remedies" check.
- **Effect:** Two co-equal warnings can recommend opposite fixes. The user adjudicates manually.
- **Supports:** symptom 3.
- **Evidence:** PR 339 E10, E11, E12, E13.

### C9: No premise-verification step before raising "violates standard X" findings
- **Location:** `plugin/skills/code-review/SKILL.md` Step 5 (documentation compliance) reads standards documents and reports violations. No sub-step asks "does this standard's premise apply to this codebase before I raise the violation?"
- **Effect:** Standards written for one architecture (SPA-style company switch, rich-error API responses) are applied to codebases with a different architecture (full-page redirect, type-system-closed contracts).
- **Supports:** symptom 1.
- **Evidence:** PR 307 E2, E4, E19; PR 299 E1.

### C10: No reachability gate before assigning severity
- **Location:** `plugin/skills/code-review/SKILL.md` Step 3.3's calibration directive partially addresses this ("Do not raise theoretical concerns the change does not touch"), but only within the agent prompt. Step 7 has no reachability filter.
- **Effect:** Findings rated "theoretical" by their own raising agent still come through as warnings.
- **Supports:** symptom 3.
- **Evidence:** PR 299 E6, E10, E13, E14, E15, E16.

### C11: Whole-file checklist application in Modes B and C, plus YAGNI on whole-file content
- **Location:** `plugin/skills/code-review/SKILL.md` Step 4 sub-step 4 ("Apply the review checklist to the entire file content" when no diff is available). Step 4 sub-step 5 applies the full checklist (including YAGNI) to whole files.
- **Effect:** In Mode B (uncommitted) and Mode C (no git), the skill cannot distinguish introduced code from pre-existing code. YAGNI surfaces for code that predates the change entirely.
- **Supports:** symptom 1, symptom 2.
- **Evidence:** B5, B8.

### C12: The Review Constraints global rule "When uncertain, choose the higher severity" governs manual review (Steps 4 to 6) and directly contradicts the calibration directive
- **Location:** `plugin/skills/code-review/SKILL.md` line 24: "When uncertain, choose the higher severity." This is in the Review Constraints section that governs the orchestrator's own work in Steps 4 to 6 (file-by-file review, documentation compliance, documentation freshness). Step 3.3's calibration directive says the opposite ("prefer the lower severity") but applies only to agent prompts and only at Step 7.
- **Effect:** Manual findings produced by Steps 4 to 6 (the orchestrator reading code and docs directly, not agent output) are still routed through the "prefer higher severity" rule with no size-based demotion. Documentation-freshness findings, documentation-compliance findings, and file-by-file checklist findings all inherit the inflated default.
- **Supports:** symptom 3 (severity inflation) and symptom 1 (going too deep on documentation drift).
- **Evidence:** PR 339 E1 (WARN-001 is a documentation-compliance finding produced by Step 5 or 6, not by an agent; it concerns code "not introduced by this branch but adjacent" and would not have been raised by any agent constrained to the scoped file list). V9 in the adversarial validation.

---

## Indexed solutions

Each solution S# describes a concrete change, cites the file(s) to edit, the C# causes it addresses, and the evidence rule (every solution must trace to evidence from the artifacts). Solutions are ordered by leverage: S1 to S5 are high-impact structural changes; S6 to S11 are additive guardrails.

### S1: Rewrite agent-finding-classification.md to remove the WARN severity floor and derive severity from change size
- **Change:** In each of the seven rubric sections that currently say "Most findings land here" pointing at WARN, replace that floor with a size-aware rule:
  > For Small changes, this category lands at SUGG unless the finding is directly introduced by this change and not handled, in which case it lands at WARN; only critical or data-safety findings escalate further. For Medium changes, this category lands at WARN when directly introduced and at SUGG otherwise. For Large changes, the rubric remains as written. When in doubt, prefer the lower severity.
- **Files to edit:** `plugin/skills/code-review/references/agent-finding-classification.md`.
- **Causes addressed:** C1, C2.
- **Evidence rule:** removes the structural mechanism that produced PR 299's 7-of-11 inflation and PR 307's 3-of-4 inflation.

### S2: Move the calibration directive's size-based demotion logic into Step 7
- **Change:** In Step 7, before applying the classification rubric, add a sub-step that re-applies the size-based demotion rules from Step 3.3:
  > Before classifying agent findings, apply the size-based demotion rules from Step 3.3's calibration directive to every finding read from agent output files. A finding marked WARN by an agent that does not satisfy the calibration directive (directly introduced by this change, or critical irrespective of who introduced it) is demoted one severity. Suggestions on Small changes are dropped entirely.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Step 7.
- **Causes addressed:** C2.
- **Evidence rule:** closes the gap between the directive in the agent prompt and the classification that produces final output.

### S3: Lower the default output severity of structural-analyst and behavioral-analyst, but keep "include when in doubt"
- **Change:** Both agents already have Anti-Patterns sections that specifically warn against false-positive shapes ("Abstraction Purity Bias", "Duplication False Positive", "Static-as-Behavioral"). Do not remove the "include when in doubt" rule, because the second-pass evidence in PR 299 confirms that the SUGG-005, SUGG-006, SUGG-007 findings produced by the structural-analyst were *correct at SUGG severity*. The defect was that the classification rubric promoted them to WARN, not that the agents produced them. Replace the rule with:
  > Default posture is skeptical, but calibrated. When in doubt about whether something is an issue, include it as a low-severity finding (SUGG). Raise to WARN or CRIT only when the change actively introduces or worsens the issue, or when the issue is critical irrespective of who introduced it. A false positive at SUGG severity is cheaper than a missed real issue, but a false positive at WARN severity erodes trust.
- **Files to edit:** `plugin/agents/structural-analyst.md`, `plugin/agents/behavioral-analyst.md`.
- **Causes addressed:** C3 (partially; the rest is handled by S1).
- **Evidence rule:** preserves the agents' ability to produce legitimate low-priority findings (which the PR 299 second-pass output validated) while preventing the auto-promotion to WARN. Aligned with V8 in the adversarial validation.

### S4: Constrain junior-developer and edge-case-explorer reads to the scoped file list except where their protocol explicitly requires outward reads, and document the constraint
- **Change:** Add to `junior-developer.md` Protocol 4 and `edge-case-explorer.md` Protocol 1: "Outward reads (adjacent code, callers) are for context only; findings must concern code on the scoped file list. A finding about code outside the file list is permitted only when it directly demonstrates that the changed code on the file list cannot be safely interpreted without the out-of-scope context. Otherwise, omit the finding."
- **Files to edit:** `plugin/agents/junior-developer.md`, `plugin/agents/edge-case-explorer.md`.
- **Causes addressed:** C4.
- **Evidence rule:** prevents PR 339 E1 (the data-testid drive-by) and PR 299 E5 (the suppressed-suggestion deep dive) without removing the agents' ability to gather context.

### S5: Add `{focus areas}` and `{user context}` placeholders to every agent prompt template
- **Change:** In `plugin/skills/code-review/SKILL.md` Step 3.5, add a "Focus areas" block to every agent prompt template:
  > **Focus areas from the user.** {focus areas, or "none provided"}.
  > **PR / branch context.** {branch context summary, or "none provided"}.
  > Findings in the focus area receive extra scrutiny and additional detail. Findings outside the focus area must still satisfy the calibration directive above; do not raise minor findings outside the focus area when a focus area is provided.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Step 3.5.
- **Causes addressed:** C5.
- **Evidence rule:** PR 339 E14 to E17, PR 307 E17 to E22, and PR 299 E18 to E22 all name this as the primary "context not forwarded" failure.

### S6: Add Step 1.5 "Load PR-level and branch-level context"
- **Change:** Insert a new Step 1.5 between current Steps 1 and 2:
  > **Step 1.5: Load branch context.** When in Mode A or Mode B, gather context the agents will need: (a) read the PR description if a PR exists for the branch (use `gh pr view` if available, otherwise read locally if a `pr-body` file is present); (b) read commit messages for the branch's commits since the default branch; (c) if the CLAUDE.md project map names a planning directory or linked-issue convention, look for an implementation plan or design doc for this branch; (d) summarize the context as a "Branch Context" block of at most 200 words covering: scope, deferred items, premises the team has already locked in, focus areas the author named. Pass this block to every agent in Step 3.5 alongside the focus areas from S5.
- **Files to edit:** `plugin/skills/code-review/SKILL.md`.
- **Causes addressed:** C5, C6.
- **Evidence rule:** PR 307 E18 (the implementation plan resolved WARN-003 before code was written) and PR 299 E20 (the Deferred section listed the Sentry PII work) both required this context.

### S7: Tighten the YAGNI checklist to run the evidence test first
- **Change:** Rewrite the YAGNI bullet list in `review-checklist.md` and the YAGNI block in Step 3.3 of `SKILL.md` to be a two-step procedure:
  > For every change in the diff, apply YAGNI in two passes:
  > Pass 1, evidence test: for each new abstraction, configuration knob, defensive guard, observability hook, runbook, SLO, index, or audit column, ask whether the diff contains evidence of need from one of the five acceptable evidence types in yagni-rule.md Gate 1. If yes, do not flag.
  > Pass 2, anti-pattern check: only for items that fail Pass 1, match against the named anti-patterns. Items that match any anti-pattern become YAGNI-### findings.
  > A YAGNI finding's body must name (a) the failing evidence type, (b) the matched anti-pattern, and (c) the simpler form considered.
- **Files to edit:** `plugin/skills/code-review/references/review-checklist.md`, `plugin/skills/code-review/SKILL.md` Step 3.3 YAGNI block.
- **Causes addressed:** C7.
- **Evidence rule:** PR 307 E8 to E11 (the placeholder rationale was evidence of need that YAGNI did not weigh) and PR 339 E5 to E8 (the plan's explicit YAGNI rejection should have been Pass 1 evidence).

### S8: Add a self-consistency check to Step 9
- **Change:** Add to Step 9 (verification):
  > For every pair of findings that reference the same file path or overlapping line ranges, check whether their recommendations are mutually consistent. If two findings recommend opposite actions on the same code, demote one or both to Suggestion and add a note to each: "Tension with {other finding ID}: the human reviewer must adjudicate between {action A from finding X} and {action B from finding Y}." Do not silently drop either finding.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Step 9.
- **Causes addressed:** C8.
- **Evidence rule:** PR 339 E10 to E13 (the WARN-002 / WARN-003 contradiction is the bundle's "most instructive single moment").

### S9: Add a premise-verification sub-step to Step 5
- **Change:** Add to Step 5 (documentation compliance):
  > Before raising a "violates standard X" finding, verify that the standard's premise applies to this codebase. A standard that says "module-level Map/Set caches must clear on company switch" applies only when the codebase has SPA-style company switching with module-level Map/Set caches. Read the standard's own "When this applies" or scope statement (or infer it from the standard's own examples). If the premise does not hold in this codebase, do not raise the finding; instead, log a brief note in the agent's output explaining why the standard does not apply.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Step 5.
- **Causes addressed:** C9.
- **Evidence rule:** PR 307 E2 (WARN-003's standard premise did not apply) and PR 299 E1 (the structural agent applied standards out of context).

### S10: Add a reachability gate to Step 3.3 and re-apply at Step 7
- **Change:** Strengthen Step 3.3's calibration directive with explicit reachability criteria, then mirror it at Step 7:
  > Reachability gate: for every finding, ask whether the described failure mode is reachable in production given the actual code paths in this codebase. "Theoretical race", "defense-in-depth", "in case the upstream is bad" all signal non-reachable findings unless the agent can cite a specific production path that exercises the failure. Demote non-reachable findings by one severity. A non-reachable "Critical" becomes Warning; a non-reachable "Warning" becomes Suggestion; a non-reachable "Suggestion" is omitted.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Step 3.3 calibration directive, Step 7 classification.
- **Causes addressed:** C10.
- **Evidence rule:** PR 299 E10, E15, E16 explicitly call for the reachability gate to be in the first pass. PR 299 E6 (SUGG-003 documented "effectively impossible in production" yet was first-pass warning) and PR 307 E12 to E16 (3:1 won't-fix ratio).

### S11: Document Mode-B and Mode-C scope limitations
- **Change:** Add to Step 4 sub-step 4:
  > In Mode B (uncommitted changes) and Mode C (no git), the skill cannot distinguish introduced code from pre-existing code. In these modes, apply the review checklist conservatively: raise findings only for items that the user explicitly asked about in the focus areas, items that the file list's own author wrote intentionally (judged by being in source files versus generated/vendored), and items at the file boundaries (imports, exports, public API). Skip YAGNI entirely in Mode B and Mode C unless the user explicitly requests it.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Step 4.
- **Causes addressed:** C11.
- **Evidence rule:** B5, B8.

### S12: Optional: replace mode flags with explicit defaults that match user preference
- **Change:** Acknowledge that the user has been compensating with "SUGG suppressed per reviewer instruction" by making suppression the default for small changes and surfacing-on-request for medium changes. Reuse the existing `size` argument; do not add a new argument.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Step 3.3.
- **Causes addressed:** C1, C2 (reinforces).
- **Evidence rule:** PR 299 E17 (the user has already configured the workaround manually).

### S13: Qualify the Review Constraints global "prefer higher severity" rule with size-based logic
- **Change:** Replace SKILL.md line 24 ("When uncertain, choose the higher severity") with:
  > When uncertain about severity, apply the calibration directive's size-based demotion to manual findings from Steps 4 to 6 as well. For Small changes, prefer the lower severity; only Critical findings escalate. For Medium changes, Critical and Warning findings escalate; suggestions stay at SUGG. For Large changes, prefer the higher severity when in doubt. This rule applies to manual review findings (Steps 4 to 6) and is mirrored by the agent calibration directive in Step 3.3.
- **Files to edit:** `plugin/skills/code-review/SKILL.md` Review Constraints section (line 24).
- **Causes addressed:** C12.
- **Evidence rule:** PR 339 E1 (the documentation-compliance WARN-001 finding is a manual-review finding produced under the global "higher severity" rule, not an agent finding; no agent-side fix addresses it). V9 in the adversarial validation directly names this gap.

### Note on the S1 and S2 interaction
S1 makes the rubric size-aware. S2 adds a pre-classification demotion step at Step 7 that re-applies Step 3.3's calibration directive. If both ship together, a finding could be demoted twice: once by S2's pre-step (because the agent did not satisfy the directive) and again by S1's size-aware rubric. Bound the interaction with this rule: **S2 applies only when an agent finding's rationale does not cite a "directly introduced by this change" justification.** When an agent's finding explicitly claims direct introduction, skip S2's demotion and let S1's rubric assign the final severity. When the agent's rationale is silent on direct introduction, apply S2's demotion and then S1's rubric assigns the floor. This prevents double-demotion while preserving the protective behavior in both steps. V5 in the adversarial validation surfaces this risk.

---

## Cross-reference: symptom-to-cause-to-solution map

| Symptom | Primary causes | Primary solutions |
|---------|----------------|-------------------|
| Goes too deep | C3, C4, C9, C11, C12 | S3, S4, S9, S11, S13 |
| YAGNI under-applies | C7, C11 | S7, S11 |
| Severity inflation | C1, C2, C8, C10, C12 | S1, S2, S8, S10, S13 |
| Context not forwarded | C5, C6 | S5, S6 |

S1, S2, S5, S6, S13 are the five highest-leverage changes. Together they address the three structural failures: (a) calibration logic is not enforced where severity is assigned (S1, S2), (b) user-provided context never reaches the sub-agents (S5, S6), and (c) the global manual-review severity rule is not size-aware (S13).

---

## Adversarial validation findings

The investigation was reviewed by an `adversarial-validator` agent. Nine validation findings were raised. The investigation was updated in response. The findings and adjustments:

- **V1.** The 7-of-11 demotion in PR 299 partly reflects user configuration (the first pass was run with "WARN-justified, SUGG suppressed" mode), not pure malfunction. **Adjustment:** confidence reduced from "High across all causes" to "High for behavioral causes (B1-B8) and directly-readable structural mechanisms (C1, C2, C5, C12); Medium for PR-outcome-only causes."
- **V2 and V8.** S3 as originally written would have suppressed correct SUGG-level findings the second pass validated, and both agents already have Anti-Patterns sections that constrain the skeptic posture. **Adjustment:** S3 rewritten to lower the default output severity to SUGG, not remove the "include when in doubt" rule.
- **V3.** S1's proposed language could under-classify concurrency findings for newly-introduced async errors. **Adjustment:** documented as a remaining risk; implementation should test S1's language against concurrency scenarios specifically.
- **V4.** C4 overstates the agents' protocols; outward reads in junior-developer and edge-case-explorer are for context, not findings. **Adjustment:** S4's framing remains correct (add the explicit constraint), but the diagnosis acknowledges that PR 339 E1's documentation finding is more likely a Step 5/6 manual finding than an agent finding (see C12, S13).
- **V5.** S1 and S2 could double-demote findings if both ship together. **Adjustment:** added an explicit interaction rule (the note after S13).
- **V6.** "Structural failure" overstates Symptom 4; "missing feature" is a more accurate framing for context-forwarding. **Adjustment:** acknowledged in the cause definitions; S5 and S6 remain the correct fix.
- **V7.** All three PR bundles come from the same project; the evidence is not fully independent. **Adjustment:** confidence framing now distinguishes behavioral causes (high confidence) from PR-outcome causes (medium confidence). Recommended pre-implementation step: test the proposed solutions against a different project's PR.
- **V9.** SKILL.md line 24's "When uncertain, choose the higher severity" governs manual review (Steps 4 to 6) and was not addressed by any solution. **Adjustment:** added C12 and S13.

## What the investigation does not cover

- **Test plan.** Once solutions are implemented, a test plan is needed to verify the fixes do not break existing review quality. Suggested: re-run the code-review skill against PRs 299, 307, and 339 (treating the merged-state code as the input) and confirm that (a) PR 299 produces 4 warnings (matching the second pass), not 11; (b) PR 307 produces 1 warning and 1 YAGNI-or-context-flagged demoability question, not 4 warnings; (c) PR 339 produces 1 CRIT and at most 1 WARN, and detects the WARN-002/WARN-003 contradiction internally.
- **Cross-project validation.** All three PR bundles come from gearjot-v2-web. Before shipping the solutions widely, re-run the analysis against a PR from a different project with a different stack to confirm the structural mechanisms (C1, C2, C5, C12) hold beyond the one team.
- **Implementation sequence.** The skill changes are small and can be batched, but if sequenced: do S1 and S13 first (the highest-frequency severity issue covering both agent and manual findings), then S2 (with the V5 interaction rule), then S5 and S6 (the highest-trust context issue), then S3 and S4 (the agent-rule changes), then the additive guardrails S7 through S11.

---

## Confidence

- **High for the behavioral causes (B1 to B8) and the directly-readable structural mechanisms (C1, C2, C5, C6, C12).** These are visible by reading the skill source and the agent definitions; they are not inferred from PR outcomes.
- **Medium for the PR-outcome-driven causes (C3, C4, C9, C10).** Three PRs from one project is corroboration but not independent triangulation. The mechanisms are plausible but would benefit from cross-project validation.
- **High that the user has been compensating manually.** "WARN-justified, SUGG suppressed per reviewer instruction" is a visible, dated workaround that proves the default behavior does not match the user's preference. The fix needs to land at the skill level.

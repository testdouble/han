# Behavioral trace of the code-review skill

This artifact traces how the four reported symptoms flow through the code-review skill body and the dispatched agents. Findings are keyed B1...B8 and reference verbatim lines from the skill and agent definitions.

Files in scope:

- `plugin/skills/code-review/SKILL.md`
- `plugin/skills/code-review/references/review-checklist.md`
- `plugin/skills/code-review/references/agent-finding-classification.md`
- `plugin/skills/code-review/references/template.md`
- `plugin/references/yagni-rule.md`
- All nine dispatched agents under `plugin/agents/`

---

## B1: Agent prompt templates have no placeholder for user focus areas

Dimension: data flow.
Files: `plugin/skills/code-review/SKILL.md`.

Step 1 of the skill ends with:
> If the user provided focus areas in their arguments, note them for use in Step 4.

Step 3.5 then lists nine agent prompt templates. None of them carry a `{focus areas}`, `{user context}`, `{branch description}`, or `{PR description}` placeholder. The text directly says:
> Each agent's prompt has three parts: the domain-specific question, the calibration directive verbatim from Step 3.3, and the domain-scoped file list from Step 3.4.

Focus areas are not one of those three parts. The user's stated context reaches only Step 4's manual review pass. The eight or nine specialist agents receive no instruction to weight or prioritize the focus surface.

Impact: when a user writes `/code-review focus on auth middleware`, the agents review the full file list with equal weight. This explains PR 307 E17 to E22 (the implementation plan's WARN-003 resolution did not reach the reviewer) and PR 339 E14 to E17 (three named focus areas in the PR description were not addressed).

---

## B2: structural-analyst and behavioral-analyst have skeptic-default rules that conflict with the calibration directive

Dimension: data flow.
Files: `plugin/agents/structural-analyst.md`, `plugin/agents/behavioral-analyst.md`.

`structural-analyst.md` says verbatim:
> Default posture is skeptical: assume structural problems exist until proven otherwise.
> When in doubt about whether something is a structural issue, include it: a false positive is cheaper than a missed risk.

`behavioral-analyst.md` carries the same rule with "behavioral" substituted for "structural".

The calibration directive from Step 3.3 says:
> When uncertain about severity, prefer the lower severity. If the worst-case impact is "an operator sees an error and retries," that is not Critical.
> Do not raise theoretical concerns the change does not touch.
> Do not raise pre-existing best-practice gaps the change did not make worse.

The agent body and the calibration directive collide. The agent body's rule is positioned as "Rules" (the last word) and is absolute; the calibration directive lives in the middle of the prompt and depends on the agent honoring conditional logic about change size. When two instructions conflict, the more absolute, more recent, more prominently positioned one wins.

Impact: structural and behavioral findings flag pre-existing concerns that the change did not introduce. This is the primary structural mechanism behind PR 299 E1 to E7 (the structural-agent finding flood that produced SUGG-005, SUGG-006, SUGG-007).

---

## B3: Six of nine agent rubrics in agent-finding-classification.md set "Most findings land here = WARN"

Dimension: data flow.
File: `plugin/skills/code-review/references/agent-finding-classification.md`.

The rubric contains the phrase "Most findings land here" eight times. In seven of those, the phrase points at WARN:

- test-engineer: "WARN: ... Most findings land here."
- edge-case-explorer: "WARN: ... Most findings land here."
- structural-analyst: "WARN: ... Most findings land here."
- behavioral-analyst: "WARN: ... Most findings land here."
- concurrency-analyst: "WARN: ... Most findings land here."
- data-engineer: "WARN: ... Most findings land here."
- devops-engineer: "WARN: ... Most findings land here."

Only junior-developer puts "Most findings land here" at SUGG.

The phrase creates a severity floor. When a finding is ambiguous between SUGG and WARN, the rubric pulls it up to WARN because WARN is the rubric's documented expected landing zone. This applies regardless of change size or calibration.

Impact: across PRs 299, 307, and 339, almost every reclassification or won't-fix concerned a WARN finding that the user demoted to SUGG (PR 299 E11 to E17), would have demoted (PR 307 E12 to E16), or that should have been flagged for inconsistency (PR 339 E10 to E13). The severity inflation is structural.

---

## B4: The calibration directive's "prefer lower severity" rule travels in the agent prompt but not into the classification step

Dimension: data flow.
Files: `plugin/skills/code-review/SKILL.md`, `plugin/skills/code-review/references/agent-finding-classification.md`.

Step 3.3 embeds in each agent's prompt:
> Severity calibration scales with size:
> - Small change: only Critical findings escalate. Raise Warnings only when the finding is directly introduced by this change. Omit Suggestions entirely.
> - Medium change: Critical and Warning findings escalate. Raise Suggestions only when directly introduced by this change.
> - Large change: all severities are in scope.

Step 7 then says:
> Classify agent findings using the rubrics at [agent-finding-classification.md](references/agent-finding-classification.md).

The rubric does not reference Step 3.3. It does not apply the size-based demotion. Once an agent writes a finding to its output file, Step 7's rubric reclassifies it without applying the change-size demotion logic. The "Small change: omit Suggestions entirely" rule is never enforced at the step where the final severity is assigned.

Impact: for small and medium changes, suggestions get classified as warnings because the rubric's "Most findings land here = WARN" applies without the size filter that would have demoted them. This compounds with B3.

---

## B5: Step 4 applies the review checklist to whole files in Modes B and C

Dimension: data flow.
File: `plugin/skills/code-review/SKILL.md`.

Step 4 sub-step 4:
> Examine the diff to understand what changed. If no diff is available (Mode B uncommitted review or Mode C non-git review from Step 1), skip this sub-step: the full file read from sub-step 3 provides all necessary context. Apply the review checklist to the entire file content.

In Mode B (uncommitted) and Mode C (no git), the checklist is explicitly applied to the entire file. The checklist has no clause limiting any category to changed lines.

Impact: in non-Mode-A reviews, the skill cannot distinguish introduced code from pre-existing code, so every category of the checklist applies to everything in the file. This is the structural source of "goes too deep" for non-branch reviews.

---

## B6: YAGNI is applied as pattern-match against named anti-patterns, not as the evidence-test gate the rule mandates

Dimension: data flow.
Files: `plugin/skills/code-review/references/review-checklist.md`, `plugin/references/yagni-rule.md`.

The review checklist enumerates anti-patterns as bullet triggers:
> New abstraction (interface, base class, port, adapter) introduced for code with one current concrete implementation
> Defensive guard (null check, type check, validation) added at a trusted internal boundary the caller fully controls
> ...

The yagni-rule.md defines YAGNI through two gates, where Gate 1 is the evidence test:
> Any committed item must cite at least one piece of evidence that it is needed now. Acceptable evidence: a user-described need, a named direct dependency, an existing production code path or contract that will break without it, a regulatory or compliance rule that demonstrably applies, a documented incident or measured metric.

The checklist does not embed the affirmative evidence test. A reviewer who pattern-matches an anti-pattern without running the evidence test flags items that should not be flagged (the user described the demoability need in PR 307 but YAGNI fired anyway, see PR 307 E8 to E11) and misses items that should be flagged (PR 339 E5, E6 where the plan's explicit YAGNI rejection went unsurfaced).

Impact: YAGNI under-applies in one direction (legitimate items are flagged because they match a structural anti-pattern but pass the evidence test) and over-applies in the other (speculative items that don't match a named anti-pattern slip through).

---

## B7: junior-developer and edge-case-explorer agents have protocol instructions to read code beyond the scoped file list

Dimension: integration boundaries.
Files: `plugin/agents/junior-developer.md`, `plugin/agents/edge-case-explorer.md`.

`junior-developer.md` Protocol 4 says:
> Read, in this order: CLAUDE.md at repo root, any project-discovery.md or equivalent, coding standards, ADRs, and patterns in code adjacent to what the artifact will change.

"Patterns in code adjacent" is unbounded.

`edge-case-explorer.md` Protocol 1 says:
> Find callers and consumers. Use Grep to search for every call site of the target code's public functions. Read the callers to understand what values they actually pass.

This is a repo-wide grep. The agent's file list scopes what it analyzes, but the protocol pushes it to follow call sites outward.

Impact: out-of-scope findings flow back into the review as if they were findings about the changed files. This combined with B2 explains how the skill produces findings about untouched code surfaces.

---

## B8: YAGNI can be applied to entire file contents in Mode C, including code that predates the change

Dimension: data flow.
Files: `plugin/skills/code-review/SKILL.md`, `plugin/skills/code-review/references/review-checklist.md`, `plugin/references/yagni-rule.md`.

SKILL.md Review Constraints section:
> Apply the evidence-based YAGNI rule from references/yagni-rule.md to every change in the diff.

But in Mode C there is no diff. Step 4 still applies the checklist (including the YAGNI bullet) to the entire file. yagni-rule.md says:
> A YAGNI finding identifies code introduced by this change that has no evidence of being needed now.

Without a diff, the skill cannot distinguish introduced code from pre-existing code. The checklist's YAGNI bullet fires on whatever pattern-matches, regardless of when the code was written.

Impact: YAGNI surfaces for code that predates the current change in Mode C. Combined with B6, this means YAGNI both under-applies (by missing legitimate candidates) and over-applies (against pre-existing code).

---

## Summary of structural failures

| Symptom | Direct cause | Findings |
|---------|--------------|----------|
| Goes too deep | Skeptic-default agent rules (B2) + protocol-driven scope expansion (B7) + whole-file checklist application in Modes B and C (B5, B8) | PR 299 E1-E7; PR 307 E1-E7; PR 339 E1-E3 |
| YAGNI under-applies | Pattern-match-only application bypasses the evidence test (B6, B8) | PR 299 E8-E10; PR 307 E8-E11; PR 339 E5-E8 |
| Severity inflation | "Most findings land here = WARN" floor (B3) + Step 7 classification ignores the calibration directive (B4) | PR 299 E11-E17; PR 307 E12-E16; PR 339 E9-E13 |
| Context not forwarded | No focus-area placeholder in any agent prompt template (B1) | PR 299 E18-E23; PR 307 E17-E22; PR 339 E14-E17 |

Each symptom traces to at least one specific section of the skill where the structural cause is locatable.

# Decision Log: Leaner Code-Review Output Document

<!--
This file records every decision settled while specifying the leaner code-review
output document. Behavioral statements live in
[../feature-specification.md](../feature-specification.md) — this file captures the
history, rationale, evidence, and rejected alternatives for each decision.
-->

## Trivial decisions

### D1: Scope, output document only

The feature changes only what the generated review document contains and how it is structured, not the skill's source files; trimming `SKILL.md`, the `references/` files, or the long-form doc for their own size is explicitly out of scope (covered by issue #51). Considered widening to source-file size; rejected because issue #57 explicitly carves that out as #51's territory.

- **Referenced in spec:** Outcome, Out of Scope.

### D9: Self-consistency and analysis behavior unchanged

What the review analyzes, which agents it dispatches, the severity rubric, the self-consistency tension check, and YAGNI's categorically non-corrective status are untouched; only the emitted document's shape and redundancy change.

- **Referenced in spec:** Primary Flow, Out of Scope, Edge Cases and Failure Modes.

### D10: Long-form doc consistency

The operator-facing long-form documentation that describes the review document's structure is updated for accuracy against the new structure, not trimmed for its own size.

- **Referenced in spec:** Coordinations.

## Full decisions

### D2: Success criterion

- **Question:** How is "significantly reduced" measured, given the issue flags this as the missing piece?
- **Decision:** Size is governed by two structural invariants rather than a numeric target: (a) every finding's prose appears exactly once, and (b) no section is rendered when it has no content (lazy sections). A review of a small change therefore produces a small document.
- **Rationale:** A word/line ceiling is brittle — it varies with finding count and exploit-path length, and would either be violated by legitimately large reviews or padded by trivial ones. The structural bar is durable, enforceable as a verification rule, and directly serves the issue's "nothing meaningful is lost; the redundancy and filler are what shrink."
- **Evidence:** User input (success-metric question; user chose the structural bar and added the lazy-section principle so smaller review context yields smaller output). Issue #57 "Missing Information" section proposes the structural bar "each finding's prose appears exactly once" as an alternative to source word/line counts.
- **Rejected alternatives:**
  - A fixed word/line target for a representative review — rejected because it is brittle to finding count and exploit-path length and does not generalize across reviews.
  - Both a structural bar and a numeric target — rejected because the numeric target adds a brittle gate with no benefit over the structural one.
- **Linked technical notes:** —
- **Driven by findings:** F3, F14
- **Dependent decisions:** D3, D5, D7, D8
- **Referenced in spec:** Outcome.

### D3: Security finding de-duplication

- **Question:** A proven security finding currently appears up to four times — as a Review Summary row, a critical-severity cross-reference, a full security block, and again in the Security Improvement Summary. How is the redundancy collapsed without losing the exploit path?
- **Decision:** Each security finding appears as exactly one Review Summary table row (the index) and one full security block carrying its OWASP category, location, evidence, step-by-step exploit path, and severity (the single home for its prose). The separate critical-severity cross-reference is dropped. The Security Improvement Summary is collapsed from three prose subsections into a single short paragraph that names what was found and the actionable remediation, referencing the security finding IDs; it is omitted entirely when there are no security findings.
- **Rationale:** The full security block already carries the complete, decision-driving content (exploit path). The critical-severity cross-reference and the three-subsection summary restate that content without changing the merge decision. Collapsing to one short paragraph keeps an actionable remediation pointer while removing the generic "how to prevent this going forward" future-proofing prose that repeats the findings.
- **Evidence:** User input (security-dedup question; user chose "keep summary, drop cross-ref + collapse"). Issue #57 names the four appearances and the decided direction to keep one full block. Current template renders the four appearances (`references/template.md`: summary row, `### 🔴 Critical` cross-reference pattern, `## 🔐 Security Vulnerabilities` block, `## Security Improvement Summary` three subsections). `SKILL.md` Step 9.1 rule 9 currently mandates the critical-severity cross-reference.
- **Rejected alternatives:**
  - Keep the full block + table row only and remove the Security Improvement Summary entirely — rejected because the user chose to retain a collapsed one-paragraph summary as an actionable remediation pointer.
  - Drop only the critical-severity cross-reference and keep the three-subsection summary minus its prevention subsection — rejected because the remaining two subsections still restate the findings; a single paragraph is leaner.
- **Linked technical notes:** —
- **Driven by findings:** F1, F6
- **Dependent decisions:** D4, D11, D12
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes.

### D4: Merge recommendation covers security

- **Question:** If a critical-severity security finding no longer appears in the 🔴 Critical section, how does the merge recommendation still treat it as merge-blocking?
- **Decision:** The Review Recommendation is chosen from the highest severity present across all findings including security findings, even though security findings are presented only in their dedicated section. A critical-severity security finding still produces a "should not be merged until resolved" recommendation.
- **Rationale:** Dropping the critical-severity cross-reference (D3) removes the security finding from the 🔴 Critical list, so the recommendation logic must explicitly fold security severities in or it would understate the merge risk. This is the behavioral consequence that keeps the de-duplication safe.
- **Evidence:** Derived from D3. Current template's Review Recommendation selects text by "the highest severity found" (`references/template.md`), which today is satisfied by the critical-severity cross-reference; removing the cross-reference makes the security-severity inclusion explicit.
- **Rejected alternatives:**
  - Leave the recommendation keyed only to the 🔴/🟡/🔵 sections — rejected because a critical security finding would then never raise the recommendation above its non-security severity, understating merge risk.
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Dependent decisions:** D12
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes.

### D5: What's Good optional

- **Question:** The What's Good section is mandatory at 2–4 bullets today, which forces generic praise. Should it remain mandatory, become optional, or be removed?
- **Decision:** What's Good becomes optional: it is rendered only when the reviewer has a specific, substantive positive worth recording, and omitted entirely otherwise.
- **Rationale:** A mandatory 2–4 bullet section forces filler that does not change the merge decision, which is exactly the kind of prose the issue targets. Making it optional removes the filler while preserving a real positive-signal affordance when something substantive exists.
- **Evidence:** User input (What's-Good question; user chose "make it optional"). Issue #57 flags the mandatory always-2–4-bullets section. Current template marks the section "Always include 2-4 bullet points" (`references/template.md`).
- **Rejected alternatives:**
  - Remove the section entirely — rejected because it loses the positive-signal affordance when a genuine, specific positive exists.
  - Keep it mandatory at 2–4 bullets — rejected because it preserves the forced filler the issue targets.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D6
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes.

### D6: Consumer treats What's Good as optional

- **Question:** The PR-posting skill builds its review body from the Review Summary table, Review Recommendation, What's Good section, and findings. If What's Good can now be absent, how does the consumer behave?
- **Decision:** The PR-posting skill treats the What's Good section as optional — it includes the section in the posted body when present and omits it without error when absent.
- **Rationale:** Making What's Good optional in the producer (D5) would break a consumer that assumes the section always exists. The consumer must be updated in lockstep so a document without What's Good still posts cleanly.
- **Evidence:** Codebase — the PR-posting skill currently builds the review body from "Review Summary table, Review Recommendation, What's Good section, and all findings organized by severity" (`han.github/skills/post-code-review-to-pr/SKILL.md`).
- **Rejected alternatives:**
  - Leave the consumer unchanged — rejected because it assumes a now-optional section is always present.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations, Edge Cases and Failure Modes.

### D7: Finding-block condensing

- **Question:** Each finding block repeats `[Category]` and `file:line` already shown in the Review Summary table, and each YAGNI finding carries three sub-bullets (Why YAGNI / Simpler form / Reopen-keep-when). What is condensed?
- **Decision:** Keep the `file:line` reference in each finding block as the actionable jump anchor. Condense each YAGNI finding from three sub-bullets to one finding line plus a single reopen-trigger clause. Drop the `[Category]` label from a finding block only when the category is generic and already conveyed by the table and the task-ID prefix (logic, performance, clarity, and similar); keep a category cue when it names content a standalone reader needs and the task ID does not supply — an ADR violation that names the specific record, a standards violation that names the specific standard, or a security finding.
- **Rationale:** `file:line` is where the developer acts, so it stays on the block even though the table also lists it — the table is the scannable index, the block is the actionable home. The three YAGNI sub-bullets restate the same advisory; the finding line plus reopen trigger is the minimum the team needs to act. For categories, the original blanket drop assumed every reader has the table in view, but the PR-posting path renders each block as a standalone GitHub comment with no table present (F7). For generic categories the table and task-ID prefix are enough; for ADR and standards violations the category string names the specific document being violated — that is decision-relevant content, not redundant labeling — so it is retained.
- **Evidence:** User input (finding-blocks question; user selected drop-`[Category]`, keep `file:line`, condense YAGNI — then, on the escalation of F7, selected keeping content-bearing categories). Issue #57 flags the `[Category]`/`file:line` repetition and the three YAGNI sub-bullets. Current template repeats `**[{Category}]** \`{file:line}\`` on each block and lists three YAGNI sub-bullets (`references/template.md`). The PR-posting consumer renders blocks as standalone comments (`han.github/skills/post-code-review-to-pr/SKILL.md`).
- **Rejected alternatives:**
  - Remove `file:line` from the block and rely on the table — rejected because the block is where the developer acts; forcing a cross-reference to the table to find the location adds friction.
  - Keep all three YAGNI sub-bullets — rejected because they restate one advisory; the finding line plus reopen trigger is the minimum the team needs to act.
  - Drop `[Category]` from every block (the initial direction before F7) — rejected because a standalone / PR-comment reader loses the document-naming content carried by ADR and standards categories.
  - Keep `[Category]` on every block — rejected because generic categories are already conveyed by the table and task-ID prefix; repeating them is the redundancy the issue targets.
- **Linked technical notes:** —
- **Driven by findings:** F7
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow.

### D8: Lazy section creation

- **Question:** Today the output includes all sections even when empty, each with placeholder text ("No critical fixes needed.", "No warnings.", etc.). Should empty sections still render?
- **Decision:** Sections are created lazily — a section is rendered only when it has content. Severity sections (Critical, Warnings, Suggestions), the YAGNI section, the security-vulnerabilities section, the security-improvement paragraph, and the What's Good section are each omitted entirely when they would be empty. A clean review states no issues were found (via the table's no-issues row and an approval recommendation) without rendering any empty finding sections.
- **Rationale:** Rendering empty sections with placeholder text is pure filler that scales the document with the number of section types rather than the number of findings. Lazy creation makes a small review produce a small document — the user's stated goal that smaller review context yields smaller output. It mirrors the lazily-created-artifact pattern already used elsewhere in the suite.
- **Evidence:** User input (success-metric note: "structural bar, with output content sections lazily created as needed, so that smaller context for the review produces smaller review output"). Current `SKILL.md` Step 8 instructs "Include all sections even when empty"; the template carries empty-state placeholder lines for every section (`references/template.md`).
- **Rejected alternatives:**
  - Keep rendering empty sections with placeholder text — rejected because it is filler that grows the document independent of findings, contrary to the success criterion.
- **Linked technical notes:** —
- **Driven by findings:** F10
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes.

### D11: Security row tier in summary table

- **Question:** Once the critical-severity cross-reference is dropped (D3), the summary table is the only severity-ordered index of a security finding, but the table's Category cell shows an OWASP code, not a tier. How does a reader scanning the table tell a security finding's severity?
- **Decision:** The summary table shows a security finding's severity tier inline on its row (for example, `SEC-001 (Critical)`). No dedicated Severity column is added: corrective rows already carry the tier in their task-ID prefix (CRIT-/WARN-/SUGG-), so a column would duplicate that for every corrective finding. The tier is surfaced only where the task ID does not already encode it — the security rows.
- **Rationale:** The de-duplication removes the security finding from the 🔴 Critical list, so the table must independently communicate "this row blocks merge" or it fails the role the spec assigns it (the complete at-a-glance index). Showing the tier on security rows only preserves findability without reintroducing redundancy on corrective rows or adding bulk to every row.
- **Evidence:** User input (escalation of finding F6; user chose "tier on security rows only" over a full Severity column or no table change). Finding F6 / information-architect IA-001 established the findability gap. The full security block already carries a `Severity:` field (`references/template.md`); D11 surfaces that tier in the index.
- **Rejected alternatives:**
  - Add a dedicated Severity column to every row — rejected because it duplicates the tier already in corrective task-ID prefixes, adding a cell to every row against the shrink goal.
  - No table change; rely on severity ordering plus the Review Recommendation — rejected because ordering is not a visible label and forces the reader to trust the one-line recommendation without being able to verify a blocker from the index.
- **Linked technical notes:** —
- **Driven by findings:** F6
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes.

### D12: Generation and verification rules in scope

- **Question:** The output structure is governed not only by the document template but by the skill's review-assembly step and its structural verification rules. Are those rules in scope, given D1 frames the feature as "output document only"?
- **Decision:** The skill's generation step and structural verification rules are in scope and change in lockstep with the new structure. Specifically: the generation step stops emitting empty sections (it previously instructed "include all sections even when empty"); the verification rules drop the mandate that each security finding carry a critical-severity cross-reference; a verification rule is added that when any security finding exists the Review Recommendation reflects the highest security severity; the table-completeness rule is scoped to corrective and security findings while the existing rule keeping YAGNI findings out of the table is preserved; and a check confirms lazy sections render only when populated.
- **Rationale:** The assembly step and verification rules are what actually produce and gate the document — they are output-behavior drivers, not the skill's analysis behavior. Changing the template without them would leave the skill flagging compliant output as invalid (the cross-reference rule) or contradicting itself (the "include all sections" instruction). The issue itself names these as levers that must change together with the template. This is the in-scope counterpart to D1: D1 excludes trimming the source files for their own size; D12 includes editing the rules that define the output.
- **Evidence:** Issue #57 states "changing the output means changing these plus the matching `SKILL.md` Step 9.1 verification rules so they stay consistent." Findings F1, F2, F4, and F13 (junior-developer F1/F2/F4/F8; information-architect IA-002/IA-007) each identified a specific rule that conflicts with the new structure. Current `SKILL.md` Step 8 instructs "include all sections even when empty"; Step 9.1 rule 9 mandates the cross-reference; rule 5 governs table completeness; rule 12 keeps YAGNI out of the table.
- **Rejected alternatives:**
  - Treat only the template as in scope and leave the rules unchanged — rejected because the verification rules would then fail or contradict every compliant review, and the assembly step would still force empty sections.
- **Linked technical notes:** —
- **Driven by findings:** F1, F2, F4, F13
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations.

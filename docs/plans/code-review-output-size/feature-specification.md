# Feature Specification: Leaner Code-Review Output Document

The code-review skill produces a review document that records every finding once and grows only sections that have content, so a small change yields a small document and the same review information survives at a fraction of the prose.

## Outcome

Running a code review produces a review document in which every finding's prose appears exactly once, no section is rendered empty, and the generic and duplicated commentary that does not change the merge decision is gone. Nothing that drives a decision is lost: every finding keeps its severity, its task ID, its `file:line` reference, every proven security exploit path, and its YAGNI advisory class. A review of a change with few findings produces a correspondingly short document; a review of a large, problem-heavy change still records everything, just without the repetition ([D2](./artifacts/decision-log.md#d2-success-criterion), [D8](./artifacts/decision-log.md#d8-lazy-section-creation)).

"Prose appears exactly once" means each finding has a single prose home — the finding block (for corrective findings) or the full security block (for security findings). The Review Summary table row is an index entry, not prose; pointer references such as a self-consistency tension note that cites another finding's task ID are pointers, not prose, and are likewise exempt from the once rule ([D2](./artifacts/decision-log.md#d2-success-criterion)).

## Actors and Triggers

- **Actors** — a solo or small-team product engineer running the code-review skill on a branch, on uncommitted work, or on a set of named files; and the pull-request-posting skill that consumes the review document to build a PR review body.
- **Triggers** — the engineer invokes the code-review skill; on completion the skill emits the review document.
- **Preconditions** — the review has completed its analysis and holds a set of findings (possibly empty), each with a severity, task ID, location, and category, plus any proven security findings and YAGNI advisories.

## Primary Flow

1. The review assembles a **Review Summary table** that indexes every corrective finding and every security finding as one row carrying its task ID, category, `file:line`, and a brief description, ordered by severity. For a corrective finding the severity tier is already carried by the task-ID prefix; for a security finding — whose task ID does not encode a tier — the row shows the tier inline (for example, `SEC-001 (Critical)`), so the table stands alone as the complete severity-ordered index ([D11](./artifacts/decision-log.md#d11-security-row-tier-in-summary-table)). The table is the at-a-glance index for every finding's category and severity ([D7](./artifacts/decision-log.md#d7-finding-block-condensing)).
2. The review states a one-line **Review Recommendation** chosen from the highest severity present across all findings including security findings. A critical-severity security finding produces a "do not merge until resolved" recommendation even though that finding is presented in its own dedicated section rather than in the critical-severity list ([D4](./artifacts/decision-log.md#d4-merge-recommendation-covers-security)).
3. For each severity that has at least one finding, the review renders that severity's section (🔴 Critical, 🟡 Warnings, 🔵 Suggestions). Each finding block carries its task ID, `file:line` location, the issue, and — for corrective findings — a suggested fix. The block omits the category when it is generic and already conveyed by the table and task-ID prefix (logic, performance, clarity, and similar); it keeps a category cue only when the category names content a standalone reader needs and the task ID does not supply — an ADR violation that names the specific record, a standards violation that names the specific standard, or a security finding ([D7](./artifacts/decision-log.md#d7-finding-block-condensing)). A severity with no findings produces no section at all ([D8](./artifacts/decision-log.md#d8-lazy-section-creation)).
4. If the review found proven security vulnerabilities, it renders one **full security block per finding** carrying that finding's OWASP category, location, evidence, step-by-step exploit path, and severity. This block is the single home for each security finding's prose ([D3](./artifacts/decision-log.md#d3-security-finding-de-duplication)).
5. If the review found proven security vulnerabilities, it appends a single labeled **remediation note** that references the security finding IDs and states the actionable remediation in one or two sentences. It does not repeat the finding descriptions and does not carry a separate generic prevention narrative; its label marks it as remediation guidance, distinct from the finding blocks above it ([D3](./artifacts/decision-log.md#d3-security-finding-de-duplication)).
6. If the review found YAGNI advisories, it renders the **YAGNI section**, opening with its verbatim advisory statement. Each YAGNI finding is one line carrying its task ID, anti-pattern class, location, and description, plus a single reopen-trigger clause naming when the code should be kept or revisited ([D7](./artifacts/decision-log.md#d7-finding-block-condensing)). YAGNI findings remain a categorically non-corrective class — they appear only here, never in a severity section and never in the summary table, even when the underlying code could also have been described as a corrective issue ([D9](./artifacts/decision-log.md#d9-self-consistency-and-analysis-behavior-unchanged)).
7. If — and only if — the reviewer has a specific, substantive positive worth recording, the review renders a **What's Good** section naming it. When there is nothing substantive to say, the section is omitted entirely rather than filled with generic praise ([D5](./artifacts/decision-log.md#d5-whats-good-optional)).
8. If the change introduced no findings at all, the review states that no issues were found and recommends approval, with no empty finding sections ([D8](./artifacts/decision-log.md#d8-lazy-section-creation)).

When more than one of these sections is present, they always render in this fixed order so a repeat reader builds a stable mental model: Critical, Warnings, Suggestions, YAGNI, the security blocks, the remediation note, then What's Good. Lazy sections are omitted from the sequence; the order of the sections that do appear never changes ([D8](./artifacts/decision-log.md#d8-lazy-section-creation)).

## Alternate Flows and States

### Clean review (no findings)

- **Entry condition:** the review completed and found no corrective findings, no security vulnerabilities, and no YAGNI advisories.
- **Sequence:** the Review Summary table shows its no-issues row; the Review Recommendation states the code can be approved; no severity sections, no security sections, no YAGNI section are rendered. A What's Good section appears only if a substantive positive exists.
- **Exit:** a short document recording a clean result.

### Security findings present

- **Entry condition:** the review found one or more proven security vulnerabilities.
- **Sequence:** each security finding appears as one summary-table row (with its tier shown inline) and one full security block with its exploit path; a single labeled remediation note follows; no per-finding cross-reference is created in the critical-severity list. The Review Recommendation reflects the highest security severity ([D3](./artifacts/decision-log.md#d3-security-finding-de-duplication), [D4](./artifacts/decision-log.md#d4-merge-recommendation-covers-security), [D11](./artifacts/decision-log.md#d11-security-row-tier-in-summary-table)).
- **Exit:** each security finding's prose has appeared exactly once (the table row is an index, not prose).

## Edge Cases and Failure Modes

| Condition | Required Behavior |
|-----------|-------------------|
| A finding is both a security vulnerability and critical severity | It appears as a summary-table row (tier shown inline) and a full security block; it is **not** also duplicated in the 🔴 Critical section. The Review Recommendation still treats it as a merge-blocking critical issue ([D4](./artifacts/decision-log.md#d4-merge-recommendation-covers-security), [D11](./artifacts/decision-log.md#d11-security-row-tier-in-summary-table)). |
| The same code location could be read as both a YAGNI advisory and a corrective finding | It is recorded as one or the other, never both. YAGNI is a categorically non-corrective class, so the advisory home is the YAGNI section only; it is never also placed in a severity section or the summary table ([D9](./artifacts/decision-log.md#d9-self-consistency-and-analysis-behavior-unchanged)). |
| A severity tier has no findings | No section is rendered for that tier — no heading, no empty-state placeholder line ([D8](./artifacts/decision-log.md#d8-lazy-section-creation)). |
| There are no security findings | Neither the security-vulnerabilities section nor the remediation note is rendered ([D8](./artifacts/decision-log.md#d8-lazy-section-creation)). |
| There are no YAGNI advisories | The YAGNI section is omitted entirely ([D8](./artifacts/decision-log.md#d8-lazy-section-creation)). |
| The reviewer has no substantive positive to record | The What's Good section is omitted entirely ([D5](./artifacts/decision-log.md#d5-whats-good-optional)). |
| A self-consistency tension is detected between two findings | The existing tension-annotation behavior is preserved; the tension note still appears on both members of the contradictory pair. The note cites the other finding's task ID as a pointer, which is exempt from the prose-once rule ([D2](./artifacts/decision-log.md#d2-success-criterion)). |
| The PR-posting consumer builds a review body from a document with missing lazy sections (no What's Good, or absent severity sections on a clean review) | The consumer treats every lazy section as optional — it includes a section when present and omits it without error or empty heading when absent ([D6](./artifacts/decision-log.md#d6-consumer-treats-whats-good-as-optional)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| Code-review generation and verification rules | internal (produce and check the document) | The skill's review-assembly step and its structural verification rules govern exactly what the document contains | Must change in lockstep with the new structure: the assembly step stops emitting empty sections; the verification rules drop the mandate that each security finding carry a critical-severity cross-reference, gain a rule that the recommendation reflects the highest security severity, scope the table-completeness rule to corrective findings (YAGNI stays out of the table), and confirm lazy sections render only when populated ([D12](./artifacts/decision-log.md#d12-generation-and-verification-rules-in-scope)) |
| Pull-request-posting skill | outbound (consumes the review document) | Builds a PR review body from the Review Summary table, Review Recommendation, the optional What's Good section, and all findings by severity | Must treat every lazy section as optional — the What's Good section and any absent severity section — and not assume a fixed set of sections is always present ([D6](./artifacts/decision-log.md#d6-consumer-treats-whats-good-as-optional)) |
| Code-review long-form documentation | outbound (describes the output) | The operator-facing description of the review document's structure (the section that enumerates what the review produces, and the verify-step description) | Stays consistent with the new structure (security de-duplication, optional What's Good, lazy sections, condensed finding blocks, security-row tier) — updated for accuracy, not trimmed for its own size ([D10](./artifacts/decision-log.md#d10-long-form-doc-consistency)) |

## Out of Scope

- Trimming the code-review skill's own source files — the skill definition, its reference files, or the long-form documentation — for their own size. That is the territory of a separate effort (issue #51). This feature changes only what the generated review document contains and how it is structured ([D1](./artifacts/decision-log.md#d1-scope-output-document-only)).
- Changing what the review analyzes, which agents it dispatches, the severity rubric, or the self-consistency tension check. Only the shape and redundancy of the emitted document change.
- A fixed word or line ceiling for a review. Size is governed structurally (prose once, no empty sections), not by a numeric target ([D2](./artifacts/decision-log.md#d2-success-criterion)).

## Deferred (YAGNI)

### Explanatory note when the What's Good section is absent
- **Why deferred:** Evidence-test failure. The concern is that a reader used to seeing What's Good in every review might misread its absence as "the reviewer found nothing good" rather than "no filler was forced." No incident, metric, or user report shows this misreading actually happens; adding standing explanatory text to mitigate a hypothetical would reintroduce the kind of generic prose this feature removes.
- **Reopen when:** A user reports — or session feedback shows — that an absent What's Good section is being read as a negative signal. The cheapest fix at that point is a one-line note in the long-form documentation, not text in the generated document.
- **Source:** Finding F11 (information-architect, IA-008).

## Open Items

None. All three candidate questions identified during finding resolution (table-row prose-once carve-out, security-severity verification backstop, and consumer lazy-section scope) were resolved before synthesis: the table-row carve-out via F3/D2, the verification backstop via F4/D12, and the consumer scope via F12/D6.

## Summary

- **Outcome delivered:** the code-review document records every finding once and grows only sections that have content, shrinking the artifact without losing any finding, severity, location, exploit path, or YAGNI class.
- **Primary actors:** an engineer running the code-review skill; the PR-posting skill that consumes the document.
- **Decisions settled by evidence:** 6 (D1, D4, D6, D9, D10, D12) — see [artifacts/decision-log.md](./artifacts/decision-log.md)
- **Decisions settled by user input:** 6 (D2, D3, D5, D7, D8, D11) — see [artifacts/decision-log.md](./artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, information-architect — see [artifacts/team-findings.md](./artifacts/team-findings.md)
- **Key adjustments from review:** the summary table now carries an inline tier on security rows (so it stands alone as the severity index once the cross-reference is dropped); content-bearing categories (ADR, standards, security) are kept on finding blocks while generic ones are dropped; the skill's generation and verification rules were pulled in as an explicit in-scope coordination so the new structure stays internally consistent — see [artifacts/team-findings.md](./artifacts/team-findings.md)
- **Remaining open items:** 0

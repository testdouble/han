# Synthesis Directives

What the plan-synthesizer must do, and the record invariants the plan folder holds.
Step 8 hands these to the agent; it does not restate them.

instead), plus the spec's `artifacts/decision-log.md`, `artifacts/team-findings.md`, and
`artifacts/feature-technical-notes.md` paths if they exist (falling back to the spec folder root for legacy layouts).

- The full verbatim output from every specialist engaged across all rounds.
- The aggregated round entries from `artifacts/implementation-iteration-history.md` (claim ledger, Open Questions,
  spec-maturity tags, next-step recommendations). These are the deterministic-aggregation summaries that replaced
  per-round facilitation; no agent facilitated per round, so there are no separate facilitation summaries to read.
- If the spec-maturity gate tripped at any point, the verbatim `han-planning:discussion-facilitator` output for that single gate-trip pass.
- Every resolution from Step 6 (what evidence, reframing, or user input settled each question).
- The YAGNI ledger from Step 7.5 (items demoted or replaced under the YAGNI rule, plus any user overrides made during
  the sweep).
- Any remaining open items and the user's disposition on each, including any spec-maturity-gate overrides and the
  reasoning the user provided.
- The three target output paths: `{same-folder-as-source}/feature-implementation-plan.md`,
  `{same-folder-as-source}/artifacts/implementation-decision-log.md`, and
  `{same-folder-as-source}/artifacts/implementation-iteration-history.md` (the latter already populated with round
  entries from Step 6, awaiting backfill).
- The templates: [feature-implementation-plan-template.md](./feature-implementation-plan-template.md),
  [implementation-decision-log-template.md](./implementation-decision-log-template.md), and
  [implementation-iteration-history-template.md](./implementation-iteration-history-template.md).

Ask the han-core:plan-synthesizer to produce the final synthesis across all three files:

1. **Write `artifacts/implementation-decision-log.md`** — classify each decision as **full** or **trivial** before
   writing it. Full: has rejected alternatives, evidence beyond the user's framing or the source spec's commitments, was
   changed across rounds, has dependent decisions, or has recorded dissent. Trivial: settled directly by the user, the
   source spec, or an obvious convention. Full decisions go under `## Full decisions` with the structured fields
   (rationale, evidence, rejected alternatives, specialist owner, revisit criterion, dissent, `Driven by rounds:`,
   `Dependent decisions:`, `Referenced in plan:`). Trivial decisions go under `## Trivial decisions` as a one-line
   bullet (`D-N: {title} — {outcome}. — Referenced in plan: {sections}.`). The D-N counter is shared across both
   sections, and every plan inline link still resolves to a D-N whether full or trivial.
2. **Write `feature-implementation-plan.md`** — the primary plan, following the template's progressive-disclosure
   order: a plain-language opening paragraph, Outcome, User Stories (when the feature has a describable actor benefit),
   Constraints and Boundaries, Implementation Approach, Work Units and Sequencing, Definition of Done, Testing
   Strategy, the lazy specialist sections, Open Items, Sources and Plan Records, and Recommendation. The upper layers
   stay in plain language at intention altitude per the Operating Principles: plain language leads every section,
   technical detail appears only as minimal references below the plain language it illustrates, and work units name the
   user story each one advances. The template's guidance comments carry the per-section rules. The lazy sections are written only when
   they have real content and omitted entirely otherwise, never as an empty stub: `Security Posture` (threat surface or
   `han-core:adversarial-security-analyst` contributed), `Operational Readiness` (operational surface or
   `han-core:devops-engineer` contributed), `On-Call Resilience Posture` (resilience surface or
   `han-core:on-call-engineer` contributed), `Risks and Assumptions` (at least one real entry), `Deferred (YAGNI)` (at
   least one item deferred per Step 7.5's ledger), and `Specialist Handoffs for Implementation` (at least one planned
   handoff). Omitting a lazy section records the judgment that the surface is genuinely absent, not a skipped concern —
   confirm before omitting. The plan carries no team-composition table and no statistics summary — both live in the
   companion artifacts, linked from Sources and Plan Records. For every claim that embodies a non-obvious decision,
   append an inline parenthetical link, e.g. `([D-3](artifacts/implementation-decision-log.md#d-3-rollout-strategy))`.
   Link only non-obvious claims. Do not inline rationale or rejected alternatives. Do not repeat round-by-round
   history.
3. **Backfill `artifacts/implementation-iteration-history.md`** — for each `R#` entry already present from Step 6,
   populate `Decisions produced:` with the `D#` IDs added or changed that round and `Changed in plan:` with the plan
   sections updated that round.
4. **Preserve the cross-reference invariants across all three files:**
   - Every `D#` in `artifacts/implementation-decision-log.md` lists its `Driven by rounds:` (`R#` IDs),
     `Dependent decisions:` (`D#` IDs), and `Referenced in plan:` (plan section headings).
   - Every `R#` in `artifacts/implementation-iteration-history.md` lists its `Decisions produced:` (`D#` IDs) and
     `Changed in plan:` (plan section headings).
   - Every non-obvious claim in `feature-implementation-plan.md` has its inline
     `([D-N](artifacts/implementation-decision-log.md#...))` link.
   - When an Open Question was settled by your own re-reading of the spec during this synthesis pass (not in the Step 6
     loop), label its `Resolution source:` in `artifacts/implementation-iteration-history.md` as
     **`synthesis (Step 8 evidence)`** — not bare `evidence` — so the audit record distinguishes a loop-stage
     resolution from a synthesis-stage one.

5. **Audit and correct, do not just populate.** Beyond preserving the structural invariants above, actively reconcile
   the artifacts against each other and rewrite any inconsistency in place — the same active-correction mandate
   `plan-a-feature`'s synthesis carries ("any leak the han-core:plan-synthesizer finds is rewritten in place"). During
   synthesis, audit and fix:
   - **Every decision-log entry's title matches its body.** A title copied from another decision (a `D-3` carrying
     `D-1`'s title) is rewritten to describe its own decision.
   - **Every path, filename, or directory referenced in one plan section is consistent with the file layout described in
     another.** An install-script path that the layout section never places there is reconciled to one layout.
   - **The altitude rule is honored** (see Operating Principles): a full file block inlined in the plan is replaced with
     a named reference plus only the decision-bearing values. This is a semantic audit on top of the
     structural-invariant preservation, not a replacement for it; LLM generation is probabilistic, so the audit lowers
     the odds of a copy-paste title or path mismatch rather than guaranteeing zero.
   - **Every work unit's `Justification` cell is filled**, naming the work item's own language, the visual material the
     user attached, or the asked-for work the unit is a necessity of. A unit that cannot fill it moves to
     `## Cut for Scope`.
   - **`## Cut for Scope` carries every scope-gate cut** from Step 7.5's ledger, with what each would have done in plain
     language and the boundary citation, and no entry appears in both that section and `## Deferred (YAGNI)`.

**The `Sources and Plan Records` section of `feature-implementation-plan.md` must be populated.** If a feature
specification file was provided, the han-core:plan-synthesizer must include a relative markdown link to it (typically
`[feature-specification.md](feature-specification.md)` since both files live in the same folder). If the spec's
`decision-log.md`, `team-findings.md`, and/or `feature-technical-notes.md` also exist (in `artifacts/` for the current
layout, or at the folder root for legacy layouts), list them there with the correct relative path. The
`feature-technical-notes.md` entry is present only when the file exists — its absence is not a gap. If no file was
provided and the plan was built from conversational context only, the section must state that explicitly and summarize
what context was used.

The han-core:plan-synthesizer's synthesis is authoritative.

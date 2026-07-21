# Gap Analysis: Phase 7 Build-Phase Outline Entry vs. Phase 7 Feature Specification

## Comparison Direction

Desired state (reference): the Phase 7 entry ({#phase-7}) of
`/Users/riverbailey/dev/testdouble/han/docs/plans/han-publishing-cleanup/build-phase-outline.md`.

Current state: `/Users/riverbailey/dev/testdouble/han/docs/plans/han-publishing-cleanup/phase-7-automated-check/feature-specification.md`,
cross-checked against `artifacts/decision-log.md` for evidence of any spec content beyond the outline.

Comparison direction used: outline (desired state) toward spec (current state) for coverage gaps; spec toward outline
for scope-creep/addition checks, per explicit task instruction (bidirectional, scoped to this one phase entry).

## Scope

Comparison area is limited to the Phase 7 outline entry (What we build, Why, Outcome to demonstrate's 4 steps, Source
citations, Connects to, Preconditions) against the full Phase 7 feature-specification.md and its decision-log.md.
Excluded: Phases 1–6 and 8 outline entries in full (referenced only where Phase 7 cites or connects to them), and the
source-han-cleanup-plan.md (referenced only where the spec or outline cite it directly).

## Actors and Modes Observed

The outline names three implicit actors for Phase 7: a person running the check against the repository (interactive/
demo mode), a contributor proposing a change (automated, triggered mode), and the maintainer cutting a release (gated,
automated mode). The spec's "Actors and Triggers" section names the same three roles explicitly: "Anyone proposing a
change," "the maintainer cutting releases," and "the future contributor who adds a plugin." Two triggers are named:
automatic on every proposed change, and as a release-process gate. No API/agent/integration surface is named in either
document beyond the repository's own automatic-check and release-process machinery.

## Summary

Compared the Phase 7 outline entry (desired state) to the Phase 7 feature specification and decision log (current
state). Direction: outline toward spec for coverage, spec toward outline for additions. The spec covers three of the
outline's four guarded phases and all 4 demo steps and the precondition verbatim, but the outline's explicit claim that
Phase 7 "guards the outcomes of... Phase 4" has no corresponding behavior anywhere in the spec — the spec never
mentions dependency declarations. The spec also adds two behaviors (an orphan-listing edge case and an out-of-scope
carve-out for Phase 5's version statements) that the decision log does not evidence.

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 1 | Elements in desired state with no current state correspondence |
| Partial | 0 | Elements present in both but incompletely covered |
| Divergent | 0 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: /Users/riverbailey/dev/testdouble/han/docs/plans/han-publishing-cleanup/phase-7-automated-check/artifacts/gap-analysis-scratch.md

## Correspondence Map: Outcome-to-Demonstrate (4 steps)

| Outline step | Spec correspondence | Verdict |
|---|---|---|
| 1. "Run the check against the current repository and watch it pass." | Spec D4 + Edge Cases row "The check's very first run against the real tree fails": the check "begins blocking only after its first green run against the real tree" (Outcome, Preconditions, Edge Cases). | Covered — the single initial passing run is addressed as the arrival condition, not as a separate ad hoc invocation, but the behavior matches. |
| 2. "On a throwaway branch, add a new plugin without publishing it anywhere." | Spec Alternate Flow "A new plugin is added without being published everywhere": entry condition "adds a plugin directory but does not list it on every surface it belongs on" (a superset of the outline's "not published anywhere" case). | Covered. |
| 3. "Run the check again and watch it fail, naming the new plugin and each surface it is missing from." | Spec Primary Flow step 3 and the same Alternate Flow: "fails the change, naming the new plugin and each surface it is missing from." | Covered — near-verbatim match. |
| 4. "Confirm the all-in-one bundle's known exception is not flagged in either run." | Spec Outcome and D3: the check "reads the same durable exception record... and never flags it," in both the pass and fail cases. | Covered. |

Precondition: outline's "Confirm Phases 1, 3, and 6 are complete and the check's first run against the real tree
passes before it is allowed to block anything" (Phase 7, Preconditions) matches the spec's "Preconditions" bullet
verbatim in substance: "Phases 1, 3, and 6 are complete... The check's first run against the real tree passes before
it is allowed to block anything" (feature-specification.md, Preconditions). No gap.

## Findings

**GAP-001: Phase 7 spec does not guard Phase 4's outcome, despite the outline's explicit commitment**

- **Category:** Missing
- **Feature/Behavior:** The check's coverage of the untrue-dependency-declaration fix (Phase 4) as one of the things
  Phase 7 prevents from regressing.
- **Current State:** `feature-specification.md` contains no reference to dependency declarations anywhere — not in
  Outcome, Primary Flow, Alternate Flows, Edge Cases, Coordinations, or Out of Scope. A full-text search for "depend"
  in the spec and decision log returns no behavioral content (only the unrelated "Dependent decisions" metadata field
  in `artifacts/decision-log.md`, lines 35, 55, 77). The spec's entire behavioral surface is presence-across-four-
  surfaces and version agreement (Outcome: "does every plugin appear everywhere it should, at the right version?").
- **Desired State:** `build-phase-outline.md`, Phase 7, "Connects to": "This is the final phase. It guards the
  outcomes of [Phase 1](#phase-1), [Phase 3](#phase-3), [Phase 4](#phase-4), and [Phase 6](#phase-6) from
  regressing." Phase 4's outcome is removing untrue dependency declarations (Reporting, Feedback, and Linear on
  Core); nothing in the check as specified would catch a regression of that fix (e.g., a plugin re-declaring a false
  dependency), because the check's discovery rule and surface list are about publishing presence, not the
  dependency graph.
- **Note on internal consistency:** the spec explicitly and traceably scopes out a different phase's outcome — Phase
  5's version-compatibility statements — in its "Out of Scope" section, and that exclusion is consistent with the
  outline (the outline's "Connects to" for Phase 7 never claims to guard Phase 5). But Phase 4 receives no equivalent
  explicit exclusion; it is simply absent, with no decision-log entry (D2, D3, D4) explaining or ratifying the
  omission. This makes the scoping inconsistent: one outline-adjacent phase (5) is deliberately and visibly excluded,
  the other (4), which the outline explicitly claims is guarded, is silently dropped.

## Additions Beyond the Outline (spec toward outline direction)

The outline's Phase 7 entry describes the check at the level of "does every plugin appear everywhere it should, at
the right version," the 4 demo steps, and the guarded-phases list. The spec adds detail beyond that. Per-addition
decision-log evidence check:

1. **Single shared rule enforced at two moments (change-time block, release-time gate), with the release's override
   as the only sanctioned bypass.** Evidenced: `decision-log.md` D2, citing the source analysis's "Only now, turn on
   the automated check," the outline's Phase 7 outcome and demo, and the Phase 6 spec's release-side gate.
2. **Bundle exception read from a durable record shared with Phase 6, failing closed if unreadable.** Evidenced:
   `decision-log.md` D3, citing Phase 6's spec and decision log (its D4) and the source analysis's "know about it
   permanently" language.
3. **No-disable-once-on rule; a disputed report is resolved by fixing the tree or the record, never by turning the
   check off.** Evidenced: `decision-log.md` D4, citing the source analysis's "order matters" section and the
   outline's builds-on/precondition line.
4. **Edge case: a change deletes a plugin directory but leaves its listings behind ("orphan entries"), and the check
   fails on the orphan the same way it fails on a missing listing.** Not evidenced. This row in the Edge Cases and
   Failure Modes table has no D2/D3/D4 citation, and no decision log entry addresses plugin deletion or orphaned
   listings. The outline's 4 demo steps only cover a plugin being *added* without being published, never removed.
5. **Out-of-Scope carve-out: "Checking companion version statements and release markers on every proposed change...
   this check owns presence and version agreement across the four surfaces. Reopen if a statement-marker mismatch
   ever escapes the release reconciliation."** Not evidenced. No decision-log entry (D2, D3, or D4) discusses this
   scoping choice or the delegation to Phase 6's "post-publish reconciliation." This is the same scoping decision
   flagged in GAP-001 as inconsistent with the silent Phase 4 omission — it is itself unevidenced, even though it
   happens to be consistent with what the outline claims Phase 7 guards.

Additions 1–3 are legitimate elaborations with a documented evidence trail. Additions 4 and 5 are unevidenced by the
decision log; 5 is also the source of the Phase 4/Phase 5 scoping asymmetry identified in GAP-001.

## Areas Needing Separate Analysis

- **Phase 6 feature-specification.md and its decision log**, referenced repeatedly by Phase 7's D2/D3 as the source
  of the shared discovery rule, surface list, and exception record. Not read in this analysis; a correctness check of
  Phase 7's claims about what Phase 6 provides would require it.
- **source-han-cleanup-plan.md**, cited by both the outline and the spec's decision log as the origin of the
  "order matters" and "know about it permanently" language. Not read in this analysis; confirming those citations
  quote the source accurately would require it.

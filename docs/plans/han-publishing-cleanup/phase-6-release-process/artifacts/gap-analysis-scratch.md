# Gap Analysis: Build Phase Outline Phase 6 vs. Phase 6 Draft Feature Specification

## Comparison Direction

Current state: `docs/plans/han-publishing-cleanup/phase-6-release-process/feature-specification.md` (plus its
`artifacts/decision-log.md`) — the draft spec that must satisfy the outline's commitment.

Desired state: the Phase 6 entry (`{#phase-6}`, "Teach the release process about all four publishing surfaces") of
`docs/plans/han-publishing-cleanup/build-phase-outline.md`.

Comparison performed at the behavioral level only (no implementation, data-type, or file-format comparison beyond what
both documents themselves name).

## Scope

Comparison areas: the Phase 6 outline entry's What we build (including the Phase 5 companion-version-statement
hand-off), Why, four-step Outcome to demonstrate, Source citations, Connects to (Phase 7), and both Preconditions to
verify — checked against the spec's Outcome, Actors and Triggers, Primary Flow, Alternate Flows and States, Edge Cases,
Coordinations, Out of Scope, and Open Items, corroborated against `decision-log.md`'s D2–D5.

Excluded: Source citations were checked only for whether they name a behavior the spec must still cover; the source
artifact itself (`source-han-cleanup-plan.md`) was not re-read, since the outline already distills it and the task
scope is outline-vs-spec. Phases 1, 3, 5, and 7 were read only as far as needed to verify Phase 6's stated dependencies
on them (their own specs were not separately audited).

## Actors and Modes Observed

The outline names no actors or sub-roles for Phase 6 itself; it speaks only in terms of "the release process" and "the
automated check" as systems. The spec adds two named actors (the maintainer cutting a release; every user of both
channels) and two triggers (an ordinary release run; a rehearsal run that reports without publishing) — an
interactive/batch distinction the outline implies (its demo opens in "rehearsal mode") but does not spell out as a
mode. No API or agent/integration surface is named in either document.

## Summary

Compared the Phase 6 entry of the build-phase outline against the phase-6 draft feature specification and its decision
log, current state (spec) toward desired state (outline). All four outcome-demonstration steps, both named connections
to earlier/later phases, and the first precondition have direct, evidenced correspondence in the spec; one precondition
is only partially settled. The spec also adds three behaviors the outline does not mention, one backed by decision-log
evidence and two without a decision-log citation.

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 0 | Elements in desired state with no current state correspondence |
| Partial | 1 | Elements present in both but incompletely covered |
| Divergent | 0 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: /Users/riverbailey/dev/testdouble/han/docs/plans/han-publishing-cleanup/phase-6-release-process/artifacts/gap-analysis-scratch.md

## Findings

**GAP-001: Bundle-exception precondition confirmed as a requirement, not as a resolved durable location**

- **Category:** Partial
- **Feature/Behavior:** The outline's second precondition: "Confirm the bundle exception is recorded somewhere durable
  the release process and the check can both consult" — a confirmation the outline expects done *before starting*
  Phase 6.
- **Current State:** `feature-specification.md` Open Items, OI-1: "Decide where the durable bundle-exception record
  lives so both the release process and the Phase 7 check read the same one... **Blocks implementation:** No — it is a
  placement choice inside a settled behavior." `decision-log.md` D4 settles the *requirement* (one durable record, read
  by both, silences the report) but explicitly leaves the *location* open, with the same "does not block
  implementation" framing.
- **Desired State:** `build-phase-outline.md#phase-6`, "Preconditions to verify before starting": "Confirm the bundle
  exception is recorded somewhere durable the release process and the check can both consult." The outline frames this
  as something to verify pre-start, not a placement detail deferrable into implementation planning.
- **Note:** The behavioral requirement itself (single durable record, consulted by both systems, silences the report)
  is fully and correctly captured — this is not a Missing or Divergent gap. The gap is that the outline's precondition
  asks for a confirmed, existing durable location before work starts, while the spec explicitly defers that
  confirmation and marks it non-blocking, which waters down the urgency the outline assigns to it.

## Outline Elements Confirmed Covered (evidence of no gap)

- **What we build — repository as source of truth:** Outline: "the release process starts from the plugins as they
  exist in the repository, rather than trusting a list that can go stale." Spec: Outcome paragraph 1 and Primary Flow
  step 1, backed by `decision-log.md` D2.
- **What we build — four surfaces, not two:** Outline: "updates all four surfaces." Spec: Outcome paragraph 1 and
  Primary Flow step 4, backed by D3, which also answers outline precondition 1 ("Confirm the full list of four
  publishing surfaces and what 'up to date' means for each") by naming and defining all four.
- **What we build — Phase 5 hand-off:** Outline: "It keeps the companion version statements from Phase 5 current as
  new versions ship." Spec: Outcome paragraph 2 and Primary Flow step 5, backed by D5.
- **What we build — bundle exception known permanently:** Outline: "it also knows the one deliberate exception
  permanently: the all-in-one bundle cannot be published to the second channel." Spec: Outcome paragraph 1 sentence 3,
  Primary Flow step 2, Edge Cases table row 2, backed by D4.
- **Why — sequencing after Phases 1 and 3:** Outline: "It lands after Phases 1 and 3 so it maintains a correct state
  instead of inheriting a broken one." Spec: Actors and Triggers, Preconditions: "Phases 1 and 3 are complete."
- **Outcome step 1 (rehearsal mode against the current repository):** Spec Actors and Triggers ("or runs it in
  rehearsal mode") and Primary Flow step 6.
- **Outcome step 2 (lists every plugin found in the repository):** Spec Primary Flow step 1 and step 6 ("including the
  discovered plugin list").
- **Outcome step 3 (updates, or reports it would update, all four surfaces):** Spec Primary Flow step 4 and step 6
  ("the per-surface check results" / "reports everything it would do").
- **Outcome step 4 (bundle absence reported as a known, documented exception, not an error):** Spec Primary Flow step 2
  and step 6 ("the bundle exception as a known allowance"), Edge Cases table row 2.
- **Connects to Phase 7:** Outline: "the check turns the behavior this phase teaches into something that cannot
  regress." Spec: Coordinations table row "The automated completeness check (Phase 7)," backed by D4's shared durable
  record.
- **Precondition 1 (four surfaces and what "current" means for each):** Fully resolved by D3, cited above.

## Spec Additions Beyond the Outline

The outline does not mention these three behaviors. Listed per task instructions, not counted in the gap taxonomy above
(they are current-state surface area beyond the desired state's scope, not gaps against it).

1. **Per-plugin release marker production.** Spec Outcome paragraph 2 and Primary Flow step 5: "produces a per-plugin
   release marker for every released plugin." The outline's What we build names only "keeps the companion version
   statements from Phase 5 current," not markers. **Decision-log evidence:** D5 covers this, but its own evidence cites
   Phase 5's spec ("the release-process hand-off in its Coordinations and D4/D5") and a codebase file
   (`docs/semantic-versioning.md`) — not the outline. The addition is evidenced, but by a downstream document, not by
   the desired-state artifact under comparison here.
2. **Orphan storefront-listing entry (a plugin that no longer exists in the repository but is still listed).** Spec
   Edge Cases table row 1. Not named in the outline's What we build or Outcome steps. **Decision-log evidence:** none —
   no D-entry's "Referenced in spec" field cites the Edge Cases table, and D2's rationale (listings become outputs, not
   inputs) implies but does not name this scenario.
3. **Interrupted-release re-run safety.** Spec Edge Cases table row 3. Not named in the outline. **Decision-log
   evidence:** none — no D-entry cites this edge case.

## Areas Needing Separate Analysis

- **Source citations accuracy.** The outline's Phase 6 source citations point into `source-han-cleanup-plan.md`; this
  analysis did not re-verify those citations against the source document itself, since the task scope was outline vs.
  spec. A separate pass could confirm the source material still supports the citations as the spec has evolved them.
- **Phase 5 and Phase 7 spec consistency.** Phase 6's D5 and Coordinations depend on claims about Phase 5's spec
  (markers, version-statement enforcement) and Phase 7's spec (shared exception record, same rule). Those two specs
  were not independently audited here; a cross-phase consistency check would confirm Phase 6's characterization of
  their content is accurate rather than assumed.

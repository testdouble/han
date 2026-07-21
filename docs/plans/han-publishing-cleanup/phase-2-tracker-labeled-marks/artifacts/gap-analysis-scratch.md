# Gap Analysis: Phase 2 Build-Phase Outline vs. Draft Feature Specification

## Comparison Direction

Current state: the draft feature specification at
`docs/plans/han-publishing-cleanup/phase-2-tracker-labeled-marks/feature-specification.md`, read together with its
`artifacts/decision-log.md`. Desired state: the Phase 2 entry (`{#phase-2}`) of
`docs/plans/han-publishing-cleanup/build-phase-outline.md` — "Label every tracker's marks and close the silent gap" —
including its "What we build," 5-step "Outcome to demonstrate," "Source citations," and two "Preconditions to verify
before starting," plus the outline's OQ-1 resolution (`{#oq-1}`) and departure 3 (`{#departures}`).

Comparison direction used: desired state (outline) toward current state (spec), per protocol default. A secondary,
explicitly requested bidirectional check (spec additions not present in the outline, and whether the decision log
evidences them) is reported separately in "Additions Beyond the Outline" and is not counted in the taxonomy table.

## Scope

Comparison areas analyzed: the Phase 2 "What we build" narrative, all 5 numbered demonstration steps, both source
citations, the two preconditions, the OQ-1 resolution text, and departure 3's text. These were walked against the
spec's Outcome, Actors and Triggers, Primary Flow, Alternate Flows and States, Edge Cases, Coordinations, Out of Scope,
and Open Items sections, cross-referenced against every decision (D1-D5) in the decision log.

Excluded from analysis: the outline's "Why this is Phase 2," "Builds on," and "Connects to" prose, since these are
sequencing rationale rather than behavior the spec is required to implement. Phases 1, 3-8 and OQ-2 are out of scope;
they do not bear on Phase 2. Analysis is behavioral only — no code was read or assessed.

## Actors and Modes Observed

The outline and spec both address a single actor type: "a person" (or "a real user") running one of three named
work-item publisher skills (GitHub, Jira, Linear) against a shared work-items file, interactively, one run at a time.
No sub-roles are named. No batch/automated mode is described — every run is a person-invoked skill. No API or
agent-to-agent surface is named; the file itself is described as a passive, shared coordination point between runs,
not an actor. None of this differs between the two documents.

## Summary

Compared the Phase 2 entry of the build-phase outline (desired state) against the draft feature specification and its
decision log (current state), walking all 5 demonstration steps, both preconditions, the OQ-1 resolution, and
departure 3. Comparison direction: desired state (outline) toward current state (spec), per protocol default.

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 1 | Elements in desired state with no current state correspondence |
| Partial | 0 | Elements present in both but incompletely covered |
| Divergent | 1 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

A separate, explicitly requested check of spec additions beyond the outline (bidirectional) found 3 items; see
"Additions Beyond the Outline" below.

Full analysis written to: `/Users/riverbailey/dev/testdouble/han/docs/plans/han-publishing-cleanup/phase-2-tracker-labeled-marks/artifacts/gap-analysis-scratch.md`

## Findings

**GAP-001: Old-format migration is bifurcated in the spec but stated as unconditional in the outline**

- **Category:** Divergent
- **Feature/Behavior:** What happens when a publisher meets a file marked in the old, unlabeled format.
- **Current State:** `feature-specification.md`, "Alternate Flows and States" > "Old-format marks found in the file"
  (lines 46-54): "Marks whose old shape identifies their tracker without doubt are upgraded in place to the labeled
  format, and the run reports each upgrade" (no stop, no ask) — only "marks whose old shape could belong to more than
  one tracker stop the run" and prompt the person. `artifacts/decision-log.md` D4 ("Migration behavior," lines 60-80)
  makes this an explicit, evidenced decision: unambiguous old marks are silently auto-upgraded; only ambiguous marks
  stop and ask.
- **Desired State:** `build-phase-outline.md#phase-2`, "What we build" (line 223): "Files marked up in the old format
  get an upgrade path that stops and asks rather than guesses" — stated without qualification. The same unconditional
  claim is repeated twice more: demo step 5 (line 237), "Feed in a file marked up in the old format and confirm the
  run stops and asks instead of guessing," and OQ-1's resolution (`#oq-1`, lines 509-510), "files marked up the old
  way get an upgrade path that stops and asks rather than guesses," and departure 3 (`#departures`, lines 152-153),
  "old-format files get an upgrade path that stops and asks rather than guesses."
- **Note:** The decision log offers a rationale for the bifurcation (D4: "Upgrading an unambiguous mark is not
  guessing"), and this rationale is not unreasonable. But taken literally, demo step 5 as written cannot be
  demonstrated on a file carrying only unambiguous old marks (e.g., a GitHub-only old-format file, per D2/D4's own
  evidence that the GitHub shape `(#NNN)` is unique and unambiguous): such a file would be silently auto-upgraded, not
  stopped and asked about. Three separate places in the outline state the "stops and asks" behavior without the
  ambiguous/unambiguous distinction the spec introduces, so this is a same-concern, incompatible-approach conflict,
  not merely an implementation detail.

**GAP-002: Second Phase 2 precondition is absent from the spec**

- **Category:** Missing
- **Feature/Behavior:** Pre-start verification that no known user files would be stranded by the old-format upgrade
  path.
- **Current State:** `feature-specification.md`, "Actors and Triggers" > "Preconditions" (lines 22-25) states only one
  precondition — the OQ-3 safety-net trial. `Open Items` (OI-1, lines 99-105) likewise addresses only the safety-net
  trial. No section of the spec or the decision log (`artifacts/decision-log.md`) mentions stranded files, orphaned
  old-format files, or a check of known user files against the upgrade path.
- **Desired State:** `build-phase-outline.md#phase-2`, "Preconditions to verify before starting" (line 253): "Confirm
  no known user files in the old mark format would be stranded by the upgrade path's stop-and-ask behavior."
- **Note:** Validated by re-reading the full spec and decision log for any indirect coverage (e.g., under "Edge Cases,"
  "Out of Scope," or "Open Items"); no correspondence was found anywhere. Given GAP-001's bifurcation, this precondition
  is also harder to satisfy as originally worded, since "stranded by stop-and-ask" no longer describes every old-format
  file under the spec's design — but its absence is a Missing gap regardless of that complication.

## Additions Beyond the Outline

Explicitly requested bidirectional check: current-state (spec) elements with no desired-state (outline) correspondence,
each with its decision-log evidence status.

1. **Unrecognizable-mark classification category** — `feature-specification.md`, "Alternate Flows and States" > "A
   mark the publisher cannot recognize" (lines 56-62), and D3 in the decision log (lines 37-58). The outline names only
   two ticket-file problems (GitHub's silent drop, and the other two publishers mistaking each other's marks); it does
   not name a third case of an unrecognized annotation shape. **Evidenced:** yes — D3 cites the GitHub publisher's
   existing written rule (`han-github/skills/work-items-to-issues/SKILL.md` lines 73-75, 93-100) as the basis for
   generalizing this category to all three publishers.

2. **"Upgraded from the old format" as a fourth closing-report category** — `feature-specification.md`, Primary Flow
   step 6 (lines 40-42), and D5 in the decision log (lines 7-10). The outline's Phase 2 "What we build" names three
   report categories (published, skipped with a count, reported as belonging to another tracker); the spec's closing
   report adds a fourth. **Evidenced:** yes — D5 records the decision and rejects a count-only report as insufficient
   against the outline's own accounting requirement.

3. **"Publishing succeeds but marking fails" recovery flow** — `feature-specification.md`, "Alternate Flows and
   States" > "Publishing succeeds but marking fails" (lines 64-70). This describes new behavior (stopping the run and
   reporting an orphaned tracker item when a mark write fails after a tracker accepts the item) that has no
   correspondence anywhere in the outline's Phase 2 entry, OQ-1, or departure 3. **Evidenced:** no — this section cites
   no decision-log entry (no `D`-number reference) and no `artifacts/decision-log.md` entry addresses mark-write
   failure. This is an un-evidenced addition.

## Areas Needing Separate Analysis

- **Source citations fidelity.** The spec's decision log cites the same source-artifact sections the outline's Phase 2
  entry cites (`the shared ticket file` finding, `what I would do, in order` item 2). A full check of whether every
  claim in the spec traces back to those source sections (versus the outline's own text) was not performed line by
  line and would benefit from a dedicated citation audit if the team wants that level of rigor.
- **OI-1's "blocks implementation: No" claim.** The spec states the pre-start safety-net trial does not block
  implementation because "the target behavior in this spec is the same either way." Given GAP-001, this claim may need
  re-examination once the stranded-files precondition (GAP-002) is addressed, since the trial's outcome and the
  stranding question are related but were not evaluated together here.

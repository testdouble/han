# Gap Analysis: Phase 5 outline entry vs. Phase 5 feature specification

## Comparison Direction

Current state: the draft spec at
`docs/plans/han-publishing-cleanup/phase-5-version-declarations/feature-specification.md`, with its supporting
`artifacts/decision-log.md` and `artifacts/feature-technical-notes.md`.

Desired state (reference): the Phase 5 entry (`{#phase-5}`) of
`docs/plans/han-publishing-cleanup/build-phase-outline.md` — "Declare the plugin versions that work together" —
including What we build, Why, the 3-step Outcome to demonstrate, Source citations, Connects to (Phase 6), both
preconditions, plus the OQ-2 resolution (`{#oq-2}`) and departure 2 (`{#departures}`).

A secondary, explicitly requested reverse-direction check is also performed: anything the spec adds beyond what the
outline names, and whether the decision log evidences each addition. This does not change the primary direction above;
it is reported separately under "Spec Additions Beyond the Outline."

Analysis is behavioral only: no file paths, function names, or implementation mechanics are treated as gaps in
themselves; they are cited only as evidence.

## Scope

Comparison areas, drawn from the user's explicit scope:

1. Phase 5 "What we build" / "Why this is Phase 5" narrative.
2. The 3-step "Outcome to demonstrate."
3. "Source citations."
4. "Connects to" (Phase 6).
5. Both "Preconditions to verify before starting."
6. The OQ-2 resolution text.
7. Departure 2 text.
8. (Reverse check) Spec elements — Primary Flow, Alternate Flows, Edge Cases, Coordinations, Out of Scope — that go
   beyond anything named in the seven areas above, and whether `artifacts/decision-log.md` evidences each.

Excluded: the source artifact (`source-han-cleanup-plan.md`) itself. The outline is treated as the desired state
directly; the source is one level further removed and out of scope for this comparison.

## Actors and Modes Observed

The outline's Phase 5 entry addresses two actor types without naming them as roles: the person installing or updating
a plugin ("the person installing it," "a machine with an out-of-date companion") and, implicitly, the maintainer who
writes the version statements (never named directly, only implied by "every plugin states"). It describes only
interactive, one-machine-at-a-time install/update scenarios — no batch, API, or agent-driven install surface is named.
It distinguishes two install channels only in the preconditions ("whether the install channels read and enforce"),
not in the main body. The spec's "Actors and Triggers" section makes the maintainer role explicit and scopes the
person-actor to "the first channel" specifically — a narrowing addressed in Findings below.

## Summary

Compared the Phase 5 entry of the build-phase outline (desired state) against the current draft feature spec and its
decision log (current state), current-state-toward-desired-state. Both named preconditions are addressed and two of
three outcome-demonstration steps line up cleanly; one gap narrows the outline's channel-agnostic commitment to a
first-channel-only guarantee, and one gap closes an option the outline's own precondition had left open. The reverse
check found two spec additions beyond the outline, both evidenced in the decision log.

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 0 | Elements in desired state with no current state correspondence |
| Partial | 1 | Elements present in both but incompletely covered |
| Divergent | 1 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: `/Users/riverbailey/dev/testdouble/han/docs/plans/han-publishing-cleanup/phase-5-version-declarations/artifacts/gap-analysis-scratch.md`

## Findings

**GAP-001: "Every plugin states" narrows to "every first-channel-resolvable plugin states"**

- **Category:** Partial
- **Feature/Behavior:** Whether a person can see a plugin's stated companion-version requirements regardless of which
  install channel they use.
- **Current State:** `feature-specification.md` Outcome (lines 3–14) and Alternate Flows "The second channel" (lines
  58–64): "The second channel resolves no dependencies at all, so it neither reads nor enforces the statements... a
  named limitation, not a gap in this phase ([D3])." `decision-log.md` D3 (lines 32–49): "Statements live where a
  mechanism reads them: the first channel's dependency declarations... it gets no statements." `Out of Scope` (lines
  83–88): "Any statement on the second channel, which has no dependency mechanism to read one."
- **Desired State:** `build-phase-outline.md` Phase 5 "What we build" (lines 346–350): "Every plugin states explicitly
  which versions of the other plugins it works with... each plugin's requirements are written down where the person
  installing it can see them" — stated without a channel qualifier, unlike Phases 1, 3, 4, and 6, which name "the
  second channel" explicitly whenever the commitment is channel-specific. Outcome-to-demonstrate step 1 (line 358):
  "Open any plugin's listing and see which versions of its companion plugins it states it works with" — "any plugin's
  listing," not "any plugin's first-channel listing." The OQ-2 resolution (lines 524–526) repeats the same unqualified
  phrasing: "all plugins should state which versions of each other they depend on, explicitly."
- **Note:** The spec's narrowing is a deliberate, evidenced decision (D3 cites the second channel's manifest format
  lacking a dependency field), not an oversight. It still falls short of the outline's repeated unqualified "every
  plugin" / "any plugin's listing" language: a person installing from the second channel gets no visible version
  statement at all, whereas the outline's plain-language commitment does not carve that channel out.

**GAP-002: Spec closes the "visible-but-unenforced" option the outline's own precondition left open**

- **Category:** Divergent
- **Feature/Behavior:** What happens to version statements on a channel that does not enforce them.
- **Current State:** `decision-log.md` D3, "Rejected alternatives" (lines 43–45): "Informational statements in
  second-channel manifests — rejected: no tooling reads them, and unenforced claims drift into the docs-versus-reality
  gap this cleanup exists to close."
- **Desired State:** `build-phase-outline.md` Phase 5 "Preconditions to verify before starting," first bullet (lines
  375–376): "Confirm whether the install channels read and enforce version statements. If they do not, decide whether
  the statements start as visible information for people until the channels can act on them." The precondition frames
  "visible but unenforced" as a live, acceptable path forward for a non-enforcing channel; the spec's decision rules
  that path out entirely for the second channel rather than choosing it or leaving it open.
- **Note:** Both sides are documented decisions, not oversights, so this is Divergent rather than Missing: the
  concern (what to do when a channel can't enforce) is addressed in both, but the resolutions are opposite. The
  outline names an open branch; the spec eliminates that branch. Validated against the spec's own rationale (D3) and
  found no other spec section that reopens or partially restores the informational option.

## Spec Additions Beyond the Outline

Per the explicit request, this section checks the reverse direction: capabilities the spec commits to that the
outline's Phase 5 entry does not name, and whether the decision log evidences each one.

1. **Per-plugin release-marker backfill.** `feature-specification.md` lines 16–19, Primary Flow step 1 (lines 34–35),
   and the Edge Cases table (line 69) commit to a one-time backfill of per-plugin release markers as a prerequisite to
   any version statement landing. The outline's Phase 5 entry never mentions release markers; Phase 6 is where the
   outline discusses the release process, and Phase 5's "Connects to" section only says Phase 6 "keeps these version
   statements current," not that Phase 5 itself must first create markers to make enforcement possible. **Evidenced:**
   yes — `decision-log.md` D4 (lines 51–72) cites codebase evidence (`git tag --list` showing 27 suite-level tags and
   zero per-plugin markers; `docs/semantic-versioning.md`) and platform evidence (official plugin-dependencies
   documentation) for why the backfill is a necessary, in-scope precondition rather than scope creep.

2. **Range-conflict refusal between two installed plugins' statements for the same companion.** Primary Flow step 5
   (lines 43–45): "When two installed plugins state ranges for the same companion that cannot both be satisfied, the
   channel refuses the combination with a named error." The outline's three demo steps describe only a single
   plugin/companion pair going out of date (step 3), not two installed plugins disagreeing about a shared companion's
   acceptable range. **Evidenced:** yes — `decision-log.md` T1 reference and `feature-technical-notes.md` T1 (lines
   3–19) cite the official plugin-dependencies documentation's `range-conflict` behavior as the platform mechanism
   this follows from; the addition is a documented consequence of the enforcement the outline commits to, not an
   independent invention.

## Areas Needing Separate Analysis

- **Whether "every plugin's requirements... where the person installing it can see them" (outline) is satisfiable for
  the second channel in some non-statement form** — e.g., documentation-only guidance, as D3 gestures at ("its
  companion guidance stays in the documented install instructions, unchanged"). Confirming whether that documentation
  actually names version ranges today, or only install steps, would need a check of the second channel's current
  install-instructions content, which is out of scope here.
- **The Phase 4 dependency-edge list in OI-1** — the spec's own open item flags that the exact set of edges receiving
  statements is not yet confirmed against Phase 4's merged state. This is a spec-internal open item, not an
  outline-vs-spec gap, but it will affect whether GAP-001's channel-scope finding applies uniformly across all edges
  once Phase 4 lands.

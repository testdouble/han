# Gap Analysis: Phase 1 Build Outline Entry vs. Phase 1 Feature Specification

## Comparison Direction

Current state (artifact under review): the draft feature specification at
`docs/plans/han-publishing-cleanup/phase-1-linear-publishing/feature-specification.md`, with companion artifacts
`artifacts/decision-log.md` and `artifacts/feature-technical-notes.md`.

Desired state (reference): the Phase 1 entry `{#phase-1}` ("Publish the Linear plugin to the second channel") of
`docs/plans/han-publishing-cleanup/build-phase-outline.md`, comprising its What we build, Why, Outcome to demonstrate
(4-step demo script), Source citations, Connects to, and Preconditions to verify subsections.

This is checked current-state-toward-desired-state (does the spec cover everything the outline's Phase 1 entry
commits to), per the task's request. Additions the spec makes beyond the outline are also reported, as requested, in a
dedicated non-gap section, since the taxonomy's four categories describe desired-state coverage gaps, not current-state
scope creep.

## Scope

Comparison areas analyzed, matching the outline Phase 1 entry's own subsection structure:

1. What we build (feature description)
2. Why this is Phase 1 (rationale — checked only for behavioral claims restated or contradicted by the spec, not for
   narrative framing)
3. Outcome to demonstrate — all 4 demo steps, checked individually
4. Connects to (the Phase 7 dependency)
5. Preconditions to verify (the first-time-publication precondition)
6. Source citations (excluded from gap findings — see Areas Needing Separate Analysis)

Excluded from findings: implementation mechanics (channel tooling commands, file paths, commit hashes) per the task's
constraint to behavioral-level findings only. These appear in the spec's technical notes and decision log as supporting
evidence, not as gap subject matter.

## Actors and Modes Observed

The outline's Phase 1 entry addresses one behavioral actor type: "anyone... who follows [the setup instructions]" /
"a new user," in an interactive, self-service installation mode. It names no sub-roles, no automated/batch mode, and no
API or agent surface for this phase (those show up only later, in Phase 7's automated check). The spec extends this
with a second actor the outline does not name for Phase 1: a "maintainer verifying the listing before ship," operating
in a distinct pre-ship verification mode. No API or agent surface is observed in either document for this phase.

## Summary

Compared the Phase 1 entry of the build phase outline (desired state) against the Phase 1 feature specification and its
decision log and technical notes (current state), current state toward desired state. All four demo steps are covered
without contradiction; the gaps found are narrower — one precondition that is exercised in practice but never named as
a distinct check, and one cross-phase dependency that the outline frames as a blocking relationship but the spec
records only as an exclusion.

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 0 | Elements in desired state with no current state correspondence |
| Partial | 2 | Elements present in both but incompletely covered |
| Divergent | 0 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: `docs/plans/han-publishing-cleanup/phase-1-linear-publishing/artifacts/gap-analysis-scratch.md`

## Findings

**GAP-001: First-time-publication precondition is never named as a distinct check**
- **Category:** Partial
- **Feature/Behavior:** Confirming, before work starts, that the second channel's publishing mechanism accepts a
  brand-new listing (a plugin "that was never listed there") rather than only accepting updates to existing listings.
- **Current State:** `feature-specification.md`, "Actors and Triggers" → Preconditions ("The user has the second
  channel's tooling installed and can reach the repository") and "Alternate Flows and States" → Maintainer verification
  before ship (three confirmations: listing entry shape, manifest version match, one real end-to-end install). None of
  these three confirmations is framed as answering the specific question the outline raises — whether the channel's
  mechanism handles a plugin that has no prior listing at all, as opposed to an update path. The end-to-end install
  step would incidentally exercise this, but the spec never names it as a distinct risk to verify, and the decision log
  (`decision-log.md` D2) treats the remaining work as "verification and shipping, not authoring," without calling out
  first-time-listing acceptance as one of the things being verified.
- **Desired State:** `build-phase-outline.md` {#phase-1}, "Preconditions to verify before starting": "Confirm the
  second channel accepts a first-time publication of a plugin that was never listed there, rather than only updates to
  existing listings."

**GAP-002: Phase 7 dependency is recorded as an exclusion, not as the outline's blocking relationship**
- **Category:** Partial
- **Feature/Behavior:** The relationship between this phase and the later automated completeness check — specifically,
  that the check cannot pass while the Linear plugin is missing from the second channel, making this phase a
  precondition for Phase 7's success.
- **Current State:** `feature-specification.md`, "Out of Scope": "Teaching the release process about all four
  publishing surfaces (Phase 6) and the automated completeness check (Phase 7)." This states only that Phase 7's own
  work is excluded from this spec; it does not state that Phase 7 depends on this phase's outcome, or that this
  phase's success is a precondition for Phase 7 landing green.
- **Desired State:** `build-phase-outline.md` {#phase-1}, "Connects to": "[Phase 7](#phase-7): the automated check
  cannot land green while this plugin is missing from the channel."

## Additions Beyond the Outline (Not Gaps)

These are current-state elements in the spec that the outline's Phase 1 entry does not address. They are not gap
findings under the taxonomy — the taxonomy measures desired-state coverage, not current-state scope creep — but the
task asked that they be flagged, with a note on whether the decision log evidences each one.

1. **Definition of done: verify + ship at branch merge, no hotfix.** The outline's Phase 1 entry is silent on shipping
   mechanics — it describes the fix as something to build, not a timeline for reaching users. The spec's Outcome and
   Out of Scope sections commit to a specific timeline (ships at branch merge; no hotfix ships ahead of it). This is
   evidenced: `decision-log.md` D2 records it as a decision made by the user on 2026-07-21, with rationale (the fix is
   already authored on the working branch; the user chose to ride the merge rather than hotfix) and a rejected
   alternative (hotfix now). This is the legitimate, user-sourced addition the task anticipated.
2. **No companion-install instruction (D3).** The spec adds a decision that the Linear plugin's install instructions
   need no note about installing a companion plugin alongside it, unlike the Atlassian plugin's install note. The
   outline's Phase 1 entry does not raise or foreclose this question. This is evidenced: `decision-log.md` D3 cites a
   codebase check (`grep -rn "han-core|han-communication" han-linear/skills/` returns nothing) and the plugin's
   existing first-channel dependency declaration, supporting the claim that no companion note is needed.
3. **Second-channel manifest version must match the first channel's released version.** The spec's Coordinations table
   and one Edge Case row commit to a specific rule beyond the outline's demo step 4 ("confirm it is the current
   version"): that the second channel's manifest version must match the first channel's, and that a mismatch holds the
   ship. This is not tied to any decision-log entry (no D-numbered decision cites it as evidence), so it is a
   lower-confidence addition — reasonable given the outline's general "current version" framing, but not
   independently evidenced the way D2 and D3 are.

## Areas Needing Separate Analysis

- **Source citation traceability.** The outline's Phase 1 entry cites two source-artifact sections
  (`source-han-cleanup-plan.md`) to let the fix be traced back to the original analysis. The spec does not cite the
  source artifact at all — only the build outline and its own artifacts folder. Because the spec and the outline sit
  at different abstraction levels (a feature spec vs. a phase-tracing document), this is a structural/format
  difference rather than a behavioral gap, and was excluded from the numbered findings per the task's constraint to
  behavioral-level findings. A documentation-conventions review (whether feature specs are expected to carry
  source-artifact citations) would need separate, focused analysis.
- **"Why this is Phase 1" rationale.** The outline's rationale (this is the only fix causing a hard error on a new
  user's first action) is narrative framing for sequencing, not a behavioral commitment the spec needs to restate. It
  was checked only for claims that the spec might contradict (none found) and excluded from further analysis as
  out-of-scope for a feature specification's format.

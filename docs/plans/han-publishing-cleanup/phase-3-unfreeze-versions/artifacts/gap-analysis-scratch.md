# Gap Analysis: Phase 3 outline entry vs. Phase 3 draft feature specification

## Comparison Direction

Current state: `docs/plans/han-publishing-cleanup/phase-3-unfreeze-versions/feature-specification.md`, with
`artifacts/decision-log.md` and `artifacts/feature-technical-notes.md` as supporting evidence.

Desired state: the Phase 3 entry (`{#phase-3}`, "Unfreeze the second channel's version numbers") of
`docs/plans/han-publishing-cleanup/build-phase-outline.md`.

## Scope

Comparison areas: What we build, Why this is Phase 3 (context only, not a commitment), the 4-step Outcome to
demonstrate, Source citations, Connects to (Phase 6, Phase 7), and the Preconditions to verify before starting.
Analysis is behavioral only — no code, file format, or implementation-level comparison. `team-findings.md` was read
and contains no entries (review pending), so it contributes no evidence either way.

## Actors and Modes Observed

The outline and spec both name two actors: the person installing Han plugins from the second channel (an end user
checking for and accepting an update) and the maintainer performing the one-time correction. No API, agent, or batch
automation surface is named for this phase — that capability (an automated release process and a completeness check)
belongs to Phases 6 and 7, which this phase only connects to. No sub-roles observed.

## Summary

Compared the Phase 3 outline entry (desired state) against the draft feature specification and its two artifact
files (current state), current state toward desired state. The spec fully covers the outline's What-we-build,
Outcome-to-demonstrate, precondition, and its Connects-to relationship with Phase 6, and adds several behaviors
beyond the outline's text that the decision log and technical notes evidence. It is missing any acknowledgment of
the outline's second Connects-to relationship (Phase 7).

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 1 | Elements in desired state with no current state correspondence |
| Partial | 0 | Elements present in both but incompletely covered |
| Divergent | 0 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: /Users/riverbailey/dev/testdouble/han/docs/plans/han-publishing-cleanup/phase-3-unfreeze-versions/artifacts/gap-analysis-scratch.md

## Findings

**GAP-001: Connects-to Phase 7 relationship absent from the spec**

- **Category:** Missing
- **Feature/Behavior:** The outline commits Phase 3 to a specific downstream relationship with the automated
  completeness check (Phase 7): "the check cannot land green while these numbers are stale." This is one of two
  Connects-to entries the outline lists for Phase 3.
- **Current State:** `feature-specification.md` has no "Connects to" section and no mention of Phase 7 or an
  automated/completeness check anywhere in the file. The Coordinations table and Out of Scope section mention only
  the release process (Phase 6): "Ongoing upkeep is the release-process phase's job, building on this one" (line 58)
  and "That is the release-process phase (Phase 6 of the outline)" (lines 62-63). A repository-wide search of the
  spec and both artifact files for "phase 7", "phase-7", "completeness check", and "automated check" returns no
  matches.
- **Desired State:** `build-phase-outline.md` lines 286-289, "Connects to." — "[Phase 6](#phase-6): once the release
  process owns all four surfaces, it keeps these numbers moving. [Phase 7](#phase-7): the check cannot land green
  while these numbers are stale." Phase 7 itself lists Phase 3 among the phases it "guards... from regressing" (line
  454), confirming the relationship is bidirectional and load-bearing, not incidental narrative.

## Validation Notes (Step 5)

- **Outcome-to-demonstrate (4 steps):** All four outline steps (set up an old install, check for updates, confirm an
  update is offered where none was before, accept and confirm the version now matches) have corresponding behavior in
  the spec's Outcome paragraph (lines 6-14) and Primary Flow steps 4-5 (lines 32-34). No gap found; searched the full
  spec body, not just the Outcome section, before concluding coverage.
- **Precondition:** The outline's precondition ("Confirm which released version each plugin... should be corrected
  to, so the fix does not guess") is resolved by decision D2 and carried into the spec's own "Preconditions" bullet
  (lines 21-24: "The target version for each plugin is read from the first channel's released versions, not guessed
  (D2)"). No gap found.
- **Connects to Phase 6:** Covered by the spec's Coordinations table row for "The release process" (line 58) and the
  Out of Scope entry citing Phase 6 by name (lines 62-63). No gap found.
- **Source citations:** Both outline citations (the "People on the second channel are stuck..." finding and "What I
  would do, in order" item 3) are consistent with the spec's content; the spec does not restate citations verbatim
  (expected — citations are an outline-level artifact) and nothing in the spec contradicts the cited source material.
  No gap found; this area is a citation-format check, not a behavioral gap, so it is not scored.
- Disproof attempt for GAP-001: searched `feature-specification.md`, `decision-log.md`, and `feature-technical-notes.md`
  for any indirect reference to a completeness check, a regression guard, or "everything must be green" framing that
  might satisfy the Phase 7 connection under different wording. None found. The gap survives validation.

## Additions Beyond the Outline (current state has no desired-state correspondence)

These are current-state elements with no counterpart in the outline's Phase 3 entry. None contradict the outline;
each is evidenced by the decision log or technical notes, so none are flagged as unevidenced scope creep.

1. **Backward-move safety rule** — "A second-channel version is found ahead of the first channel's version: the
   correction stops for that plugin and the discrepancy is raised to the maintainer; a version is never moved
   backward without a person deciding" (Edge Cases table, line 48). Not stated in the outline. Evidenced by decision
   D2's rationale and rejected-alternatives list (`decision-log.md` lines 24-29), which explicitly considers and
   rejects moving versions backward.
2. **"Already matching" no-op behavior** — the Alternate Flow "A plugin's two versions already match" (lines 38-42)
   and the Edge Cases row "A user is on the corrected version already" (line 50). Not stated in the outline. Evidenced
   by D2's decision text ("Plugins already matching are left untouched," `decision-log.md` line 14) and by the
   codebase drift measurement cited as D2's evidence (`han-communication` and `han-linear` already match, line 23).
3. **Merge-timing edge case** — "A user checks for updates before the correction reaches the default branch... the
   outcome is promised from the merge onward" (Edge Cases table, line 49). Not stated in the outline. Evidenced by T1
   (`feature-technical-notes.md` lines 7-11), which explains the second channel reads from the default branch.
4. **Explicit exclusion of the Linear plugin and the all-in-one bundle** — Out of Scope, lines 64: "The Linear
   plugin's listing (Phase 1) and the all-in-one bundle, which the second channel does not carry." Not stated in the
   outline's Phase 3 entry. Not contradictory: cross-checked against the outline's Phase 1 entry ("Publish the Linear
   plugin to the second channel"), which confirms the Linear plugin is not yet on the second channel, and Phase 6's
   text, which confirms the bundle "cannot be published to the second channel because that channel does not support
   bundles yet." Evidenced by the outline itself (cross-phase), not by the decision log.
5. **Open Item OI-1** — verifying the second channel offers updates purely by version comparison, with no other
   freshness signal (lines 69-72). Not stated in the outline as an open question. Evidenced by T1's note that this is
   "external channel behavior, not discoverable from this repo's own code" (`feature-technical-notes.md` line 11).

## Areas Needing Separate Analysis

- **Phase 1 and Phase 6 draft specs (if/when written)** — this analysis only validates Phase 3's own document set.
  Whether Phase 6's eventual spec correctly inherits "keeps these numbers moving" from Phase 3, and whether Phase 7's
  eventual spec correctly treats Phase 3 as a regression-guard precondition, both require separate gap analyses once
  those specs exist.
- **Source-artifact fidelity** — this analysis compared the spec against the outline only. Whether the outline's own
  citations faithfully represent `source-han-cleanup-plan.md` was spot-checked (item 3 of "What I would do, in
  order" and the "stuck on old versions" finding) but not exhaustively re-verified against the full source document,
  since the outline itself is the desired-state artifact of record for this comparison.

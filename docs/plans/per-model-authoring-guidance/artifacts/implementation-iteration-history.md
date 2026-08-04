# Implementation Iteration History: Per-Model Authoring Guidance

This file records how the implementation plan evolved across discussion rounds. Committed decisions live in [implementation-decision-log.md](implementation-decision-log.md); the primary plan lives in [../feature-implementation-plan.md](../feature-implementation-plan.md).

## R1: Parallel specialist review

- **Specialists engaged:** `han-core:junior-developer`, `han-core:information-architect`. (Size: small; round cap 1. `han-core:project-manager` reserved for synthesis.)
- **New input provided:** the feature specification, its decision log, and the discovery notes (`.discovery-notes.md`).
- **Claim ledger:**
  - **C1 (Evidenced, junior-developer JD-001):** the Guidance Mode routing map exists in two files, the plugin's `skills/guidance/SKILL.md` and the vendored `assets/guidance-portable-SKILL.md`; only the portable copy is vendored into other repos (`scripts/init-guidance.sh:73`, `:31`). Both need the new task-distinguishing bullet, or vendored-repo authors get the reference on disk with no scent to it. Extends spec D4/D9, which named one routing map.
  - **C2 (Evidenced, junior-developer JD-002 + information-architect Q2):** the ship-together set is five edits in one atomic commit: the new reference file, the routing bullet in `SKILL.md`, the routing bullet in `guidance-portable-SKILL.md`, the entry in `assets/rule-index-body.md`, and the reverse link in `specialization-and-model-selection.md`.
  - **C3 (Evidenced, information-architect Q2 flag + junior-developer JD-003):** `assets/rule-index-body.md` is a third curated navigation surface not named by spec D4/D9/D10. It hand-enumerates every guidance doc and regenerates the vendored `.claude/rules` index (`init-guidance.sh` regeneration step). Omitting it leaves the doc orphaned in the vendored rule index. The new entry belongs under the `## Plugin development` section and needs the same task-distinguishing wording as the routing bullet.
  - **C4 (Evidenced, information-architect Q3):** top-level `references/` placement is correct. The doc is cross-cutting to both skill and agent authors (spec Actors), like the adjacent tier doc; a per-entity subfolder or a new two-file "model" folder would be Category Fiction and unearned structure.
  - **C5 (Evidenced, junior-developer JD-004, resolved):** a repo-relative link to `docs/research/` would break in every vendored copy because `references/` is copied into arbitrary repos. The adjacent tier doc's Sources section cites external URLs only.
- **Open Questions raised:**
  - **OQ-1 (plan-level):** what citation form should the new doc use for its source, given the vendoring constraint (C5)? Resolved by evidence in this round.
- **Spec-maturity tags:** plan-level: all findings (C1–C5, OQ-1). spec-level: 0. T#-contradiction: not applicable (no `feature-technical-notes.md` exists). Spec-maturity gate did not trip.
- **Resolution source:** OQ-1 resolved by evidence: cite the Anthropic per-model page URLs directly and name the research report without a fragile repo-relative path, matching the adjacent tier doc's external-URL Sources convention. No question required user input or reframing.
- **Decisions produced:** D-1, D-2, D-3, D-4, D-5, D-6
- **Changed in plan:** Implementation Approach, Decomposition and Sequencing, Definition of Done
- **Project-manager next-step recommendation:** Go to synthesis. No spec-maturity trip, no named handoff, the one Open Question resolved by evidence.

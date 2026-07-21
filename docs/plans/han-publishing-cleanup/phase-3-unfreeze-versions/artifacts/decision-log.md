# Decision Log: Unfreeze the Second Channel's Version Numbers

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-3-unfreeze-versions/`, nested beside
  the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: Align to the first channel's versions

- **Question:** What version should each plugin on the second channel be corrected to?
- **Decision:** Each plugin's second-channel version is set to the version of its last published release, as the first
  channel records it. Plugins already matching are untouched. A second-channel version found ahead of the first
  channel's is never moved backward without a person deciding; that guard is kept as a cheap safety rail for a
  one-time human action even though no plugin is ahead today.
- **Rationale:** The source analysis's target picture labels the second channel's version numbers as "copied from
  channel one", and the outline's Phase 3 precondition requires the fix not to guess. The first channel's versions are
  the released record, maintained by the release process, so copying them is the no-guess answer.
- **Evidence:** Source analysis: the "After" diagram in
  [`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#the-publishing-pipeline-the-actual-problem)
  ("Version numbers, copied from channel one"). Codebase: current drift measured on the working branch — for example
  `han-core/.codex-plugin/plugin.json` states 1.2.0 while `han-core/.claude-plugin/plugin.json` states 2.2.1; 8 of 10
  plugins lag, and `han-communication` (1.0.0) and `han-linear` (1.0.2) already match.
- **Rejected alternatives:**
  - Independent second-channel versioning, bumped at each release — rejected because two version histories for one
    plugin re-creates the drift this cleanup exists to end, and the source's target picture copies from channel one.
  - Restarting every second-channel version at the same fresh number — rejected because it discards the released
    history and could move ahead of or behind the true release state; it is exactly the guessing the precondition
    forbids.
- **Linked technical notes:** T1
- **Driven by findings:** F3 (the source of truth is pinned to the last published release), F5 (the ahead-guard is a
  deliberate safety rail, mirrored as a pre-start check)
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Coordinations

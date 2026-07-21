# Decision Log: Declare the Plugin Versions That Work Together

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-5-version-declarations/`, nested
  beside the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: Same-major version statements

- **Question:** How strict is each statement: an exact version, a minimum, or a range?
- **Decision:** Same-major, at-or-above: a companion satisfies the statement when its version shares the stated major
  line and is at or above the stated release. Pre-release forms are excluded by default; when a companion's baseline
  version is itself a pre-release, its statements deliberately opt into the pre-release form, because a plain range
  would exclude the only marker that exists. Enforcement reaches an existing installation only after the depending
  plugin upgrades to a statement-carrying version, and the shipping release says so.
- **Rationale:** The project's versioning policy reserves major bumps for breaking changes, so "same major, at or
  above" is exactly the range the policy promises compatible. An exact pin would break on every patch release; a bare
  minimum would silently admit the next breaking major. The pre-release clause is load-bearing on the current alpha
  line, not speculative. The enforcement-reach limit follows from statements shipping inside the depending plugin's
  own manifest.
- **Evidence:** Codebase: `docs/semantic-versioning.md` (major = breaking; minor/patch = compatible); current branch
  context `han-v5.0.0-alpha-1` (a pre-release baseline is plausible, making the opt-in clause load-bearing).
  Platform: semver range support on dependency entries per T1.
- **Rejected alternatives:**
  - Exact version pins — rejected: every patch release of a companion would break resolution and demand a suite-wide
    edit.
  - Bare minimum with no major cap — rejected: it admits the next major, which the versioning policy defines as
    allowed to break users.
  - Dropping the pre-release opt-in clause as speculative — rejected after review: on an alpha line the clause is the
    difference between a working statement and a suite-wide install break.
- **Linked technical notes:** T1
- **Driven by findings:** F1 (enforcement-reach limit), F9 (pre-release baseline hazard)
- **Dependent decisions:** D4, D5
- **Referenced in spec:** Outcome; Actors and Triggers; Edge Cases and Failure Modes

### D3: First channel only

- **Question:** Do version statements appear on the second channel in any form?
- **Decision:** No. Statements live where a mechanism reads them: the first channel's dependency declarations. The
  second channel resolves no dependencies, so it gets no statements; its companion guidance stays in the documented
  install instructions, unchanged. This deliberately narrows the outline's channel-unqualified "every plugin states"
  wording, and deliberately closes the outline's "visible but unenforced" fallback: if the verification trial
  disproves enforcement, the phase pauses and the question returns to the team rather than shipping decoration.
- **Rationale:** A statement nothing reads is decoration, the same class of untruth Phase 4 removed.
- **Evidence:** Codebase: `README.md` lines 74-89 ("Codex ... resolves no dependencies"); the `.codex-plugin`
  manifests carry no dependency field. Outline: OQ-2 resolution and Phase 5 preconditions
  (`../build-phase-outline.md#oq-2`).
- **Rejected alternatives:**
  - Informational statements in second-channel manifests — rejected: no tooling reads them, and unenforced claims
    drift into the docs-versus-reality gap this cleanup exists to close.
  - Shipping statements as visible information if enforcement fails — rejected in favor of pausing and re-deciding;
    recorded because the outline's precondition had left that option open (gap-analysis divergence).
- **Linked technical notes:** —
- **Driven by findings:** F13, F14 (the two recorded divergences from the outline's wording)
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Alternate Flows and States; Coordinations; Out of Scope; Open Items

### D4: Per-plugin release markers

- **Question:** The first channel resolves a version statement by finding a matching per-plugin release marker, and
  this repository marks releases only at the suite level today. How do statements become resolvable?
- **Decision:** This phase backfills one release marker per companion plugin — only the plugins that appear on the
  depended-upon side of a statement — at its latest published release, pointing at the exact content that shipped
  under that release, never at the working branch's in-flight state. "Latest published release" means the per-plugin
  versions as of the newest suite release the marketplace serves. Markers are confirmed present on the shared
  repository before any statement stage ships. Until more markers accumulate, each range resolves to that single
  marked version in practice. Phase 6 takes over producing markers for every plugin on every future release.
- **Rationale:** The channel disables a depending plugin when no marker matches, so marker-before-statement is a hard
  gate. Markers travel separately from merged changes, so presence on the shared repository is confirmed, not
  assumed. Marking only companions is the strictly simpler version that satisfies the same evidence; markers for
  plugins nothing resolves against would do no work this phase. Pointing markers at released content preserves what a
  version name means: a marker on unreleased content would serve wrong code under a released number.
- **Evidence:** Platform: resolution against per-plugin markers, disable on missing match, per T1. Codebase:
  `git tag --list` shows 27 suite-level `vX.Y.Z` tags and zero per-plugin markers; `docs/semantic-versioning.md`
  ("the git tag for a release tracks the parent version" and its per-plugin tag note).
- **Rejected alternatives:**
  - Backfill a marker for every plugin — rejected: the simpler companion-only set satisfies the same evidence; Phase
    6 covers the rest going forward.
  - Backfill additional markers for older versions each range nominally allows — rejected: installs resolve to the
    newest in range, and history accumulates naturally from Phase 6 onward.
  - Marking the working branch's current content — rejected: it binds released version names to unreleased content, a
    silent provenance defect.
- **Linked technical notes:** T1
- **Driven by findings:** F2 (single-marker point resolution stated), F6 (companion-only simpler version), F7
  (baseline pinned to the latest published suite release), F10 (markers confirmed on the shared repository)
- **Dependent decisions:** D5
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Alternate Flows and States; Out of Scope

### D5: Staged, verified, reversible rollout

- **Question:** How do the statements land without risking a suite-wide install break on a mechanism this repository
  cannot inspect?
- **Decision:** Four safeguards, in order. First, a live verification trial on a clean machine before any statement
  reaches general installers: one edge resolves correctly, an unsatisfiable statement produces the channel's named
  error, an out-of-range companion is refused; the trial is the corroboration for the channel's externally-documented
  behavior, and if it disproves that behavior the phase pauses. Second, staging: one low-traffic edge first, then the
  remaining single edges, the all-in-one bundle's six statements last. Third, a pre-ship check per stage that the
  authored ranges admit a common solution for every supported install combination. Fourth, reversibility: statements
  start deliberately wide; rollback is reverting the statement manifests, with markers left in place as harmless;
  corrections reach already-resolved installations at their next update, a latency the wide-start posture is chosen
  to make survivable. The Phase 5-to-Phase 6 gap is covered by a named manual marker step on every release in the
  window.
- **Rationale:** Every enforcing behavior rests on a single external documentation source; the trial converts that
  single-source claim into observed behavior before users can be hurt. The bundle is the most-installed path and
  fails whole on one bad marker among six, so it lands last. A self-inflicted refused combination would present as
  the suite's own bug, so it is checked before ship rather than left to users. A release in the gap would otherwise
  pin users to stale versions or disable dependents, reproducing the harms Phases 2 and 3 exist to end.
- **Evidence:** Review findings of this phase (the rollout-safety review's five blocking findings and the
  single-source evidence flag). Platform mechanics per T1, single-source, corroborated by the trial this decision
  mandates. Sibling precedent: the cleanup's other phases already gate risky behavior on throwaway-project trials
  (outline OQ-3 resolution).
- **Rejected alternatives:**
  - Landing all statements as one change across the suite — rejected: a single bad marker or misread mechanic breaks
    every install at once with no incremental signal.
  - Shipping without a live trial — rejected: the mechanics are not discoverable from this repository, and the
    evidence rule does not let a single web source carry a suite-wide behavioral commitment.
  - Narrow statements from day one — rejected: a bad narrow statement pins users below later fixes and takes a full
    release cycle to correct.
- **Linked technical notes:** T1
- **Driven by findings:** F3, F4, F8, F10, F11, F12
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Alternate Flows and States; Edge Cases and
  Failure Modes; Open Items

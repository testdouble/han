# Decision Log: Declare the Plugin Versions That Work Together

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-5-version-declarations/`, nested
  beside the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: Same-major version statements

- **Question:** How strict is each statement: an exact version, a minimum, or a range?
- **Decision:** Same-major, at-or-above: a companion satisfies the statement when its version shares the stated major
  line and is at or above the stated release. Pre-release forms are excluded unless a statement opts in.
- **Rationale:** The project's own versioning policy reserves major bumps for breaking changes, so "same major, at or
  above" is exactly the range the policy promises compatible. An exact pin would break on every patch release; a bare
  minimum would silently admit the next breaking major.
- **Evidence:** Codebase: `docs/semantic-versioning.md` ("Bump the major version when the update would break existing
  users' expectations or workflows"; minor and patch are backwards-compatible). Platform: the first channel accepts
  standard semantic-version range expressions on dependency entries (official plugin-dependencies documentation,
  fetched 2026-07-21; see T1).
- **Rejected alternatives:**
  - Exact version pins — rejected: every patch release of a companion would break resolution and demand a suite-wide
    edit.
  - Bare minimum with no major cap — rejected: it admits the next major, which the versioning policy defines as
    allowed to break users.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D4
- **Referenced in spec:** Outcome; Primary Flow

### D3: First channel only

- **Question:** Do version statements appear on the second channel in any form?
- **Decision:** No. Statements live where a mechanism reads them: the first channel's dependency declarations. The
  second channel resolves no dependencies, so it gets no statements; its companion guidance stays in the documented
  install instructions, unchanged.
- **Rationale:** A statement nothing reads is decoration, the same class of untruth Phase 4 removed. The outline's
  own resolution of this question already anticipated statements starting where they can be acted on.
- **Evidence:** Codebase: `README.md` lines 74-89 ("Codex ... resolves no dependencies, so install the Han packages
  directly"); the `.codex-plugin/plugin.json` manifests carry no dependency field. Outline: OQ-2 resolution and Phase
  5 preconditions (`../build-phase-outline.md#oq-2`).
- **Rejected alternatives:**
  - Informational statements in second-channel manifests — rejected: no tooling reads them, and unenforced claims
    drift into the docs-versus-reality gap this cleanup exists to close.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Alternate Flows and States; Coordinations; Out of Scope

### D4: Per-plugin release markers

- **Question:** The first channel resolves a version statement by finding a matching per-plugin release marker, and
  this repository marks releases only at the suite level today. How do statements become resolvable?
- **Decision:** This phase backfills one release marker per plugin at its current released version, in the form the
  channel resolves, before any statement lands. The release-process phase (Phase 6) takes over producing markers on
  every future release. Statement-before-marker is treated as an unreachable state by ordering, not by hope.
- **Rationale:** The channel disables a depending plugin with a named error when no marker matches its statement, so
  landing statements first would break installs suite-wide. Backfill-then-declare makes the failure unreachable, and
  handing ongoing production to Phase 6 keeps this phase a one-time correction like Phase 3.
- **Evidence:** Platform: the channel resolves constraints against per-plugin release markers and disables the
  dependent on a missing match (official plugin-dependencies documentation, fetched 2026-07-21; see T1). Codebase:
  `git tag --list` shows 27 suite-level `vX.Y.Z` tags and zero per-plugin markers;
  `docs/semantic-versioning.md` ("the git tag for a release tracks the parent version").
- **Rejected alternatives:**
  - Land statements and markers in any order — rejected: the wrong order disables plugins at install.
  - Skip markers and keep statements informational — rejected: unenforced statements are the decoration D3 already
    rejects, and the channel's enforcement is the phase's whole payoff.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Edge Cases and Failure Modes; Coordinations

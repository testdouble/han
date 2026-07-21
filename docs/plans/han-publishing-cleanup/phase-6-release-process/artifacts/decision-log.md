# Decision Log: Teach the Release Process About All Four Publishing Surfaces

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-6-release-process/`, nested beside
  the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: The repository is the source of truth

- **Question:** Where does a release get its list of plugins?
- **Decision:** From the repository itself: the release discovers every plugin from what actually exists on disk, and
  the listing files become outputs the release maintains, never inputs it trusts. A discovered plugin missing from a
  surface it belongs on stops the release with a named report.
- **Rationale:** The root cause of the whole publishing rot is that the release reads its world from one listing
  file, so it structurally cannot see what that file omits. Roughly twenty releases missed the second channel's decay
  because the problem was invisible from inside the release.
- **Evidence:** Codebase: the release skill reads its plugin list from the first channel's storefront listing
  (`.claude/skills/han-release/SKILL.md` lines 37-48) and updates only the first channel's manifests and listing
  (lines 234, 326); the second channel's files appear nowhere in it. Source analysis: "The release process only knows
  about half the world" and the After diagram's "the release starts here" arrow from the repository
  ([`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#the-publishing-pipeline-the-actual-problem)).
- **Rejected alternatives:**
  - Keeping the listing as input and adding the missing surfaces to it — rejected: a stale-able input stays
    stale-able; the Linear gap happened exactly this way.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D4
- **Referenced in spec:** Outcome; Primary Flow; Alternate Flows and States

### D3: The four surfaces and what current means

- **Question:** Which surfaces does a release update, and what does "up to date" mean on each?
- **Decision:** Four surfaces. On the first channel: each plugin's version record, and the storefront listing with
  its per-plugin versions. On the second channel: each plugin's version record, and the storefront listing, which
  carries no version numbers, so current there means complete presence. After a release, both channels state the same
  released version for every plugin.
- **Rationale:** These are the four places the source analysis counted, and each has a distinct staleness mode: the
  first channel's pair drifts by version, the second channel's version records freeze, and its listing loses whole
  plugins.
- **Evidence:** Codebase: `.claude-plugin/plugin.json` per plugin and `.claude-plugin/marketplace.json` (versioned
  entries); `.codex-plugin/plugin.json` per plugin (versioned) and `.agents/plugins/marketplace.json` (entries carry
  no version field). Source analysis: the Before diagram's two channels with two records each.
- **Rejected alternatives:**
  - Treating the second channel's listing as versioned like the first's — rejected: it has no version field, and
    inventing one there duplicates the per-plugin records.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Coordinations

### D4: The bundle exception lives in one durable place

- **Question:** The all-in-one bundle cannot be published to the second channel. How do the release process and the
  later automated check both know that, permanently, without either flagging it forever?
- **Decision:** One durable exception record, read by both the release process and the Phase 7 check. Only such a
  record silences a missing-plugin report; an undocumented absence always stops the release. The record's shape can
  name future deliberate exceptions if any arise, but none are added speculatively.
- **Rationale:** Two independent copies of the exception would eventually disagree, and a hardcoded allowance inside
  either tool is invisible to the other. The outline's Phase 6 precondition asks for exactly this durability.
- **Evidence:** Source analysis: "the check needs to know about it permanently rather than flagging it forever".
  Codebase: the second channel's marketplace has no entry for the bundle today, and the front-door documentation
  records the channel's bundle limitation (`README.md` lines 74-76). Outline: Phase 6 preconditions
  (`../build-phase-outline.md#phase-6`).
- **Rejected alternatives:**
  - Hardcoding the exception in the release process and again in the check — rejected: duplicated knowledge drifts,
    and this cleanup exists because duplicated records drifted.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Coordinations; Open Items

### D5: Markers and statements on every release

- **Question:** Phase 5 backfilled per-plugin release markers and named a gap plan until this phase lands. What does
  the release process owe that baseline?
- **Decision:** Every release produces a per-plugin release marker for each plugin it releases, and updates companion
  version statements whenever the release makes that necessary, including moving every edge to a companion in the
  same release when that companion's major version bumps.
- **Rationale:** Phase 5's enforcement resolves against markers, so a release that skips them either pins users to
  stale versions or disables dependents on a major bump. This is the named downstream dependency that justifies the
  work now.
- **Evidence:** Phase 5 spec: the release-process hand-off in its Coordinations and D4/D5
  (`../phase-5-version-declarations/feature-specification.md`). Codebase: `docs/semantic-versioning.md` on per-plugin
  tags becoming required once dependencies carry ranges.
- **Rejected alternatives:**
  - Leaving marker production manual indefinitely — rejected: the manual step was a gap plan, and a forgotten manual
    step recreates the disable-at-install failure Phase 5 guards against.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Alternate Flows and States; Coordinations

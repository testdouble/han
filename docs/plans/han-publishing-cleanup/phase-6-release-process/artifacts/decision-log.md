# Decision Log: Teach the Release Process About All Four Publishing Surfaces

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-6-release-process/`, nested beside
  the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: The repository is the source of truth

- **Question:** Where does a release get its list of plugins, and what counts as a plugin?
- **Decision:** From the repository itself: a plugin is a top-level directory carrying the first channel's manifest,
  and the all-in-one bundle is the one plugin whose role is to install the others. The listing files become outputs
  the release maintains, never inputs it trusts. A discovered plugin missing from a surface it belongs on stops the
  release with a named report, and so does a listing entry naming a plugin that no longer exists, kept as a cheap
  symmetric rail without a claimed incident behind it.
- **Rationale:** The root cause of the publishing rot is that the release reads its world from one listing file, so
  it structurally cannot see what that file omits. Roughly twenty releases missed the second channel's decay because
  the problem was invisible from inside the release. Discovery needs a deterministic discriminator or it is not
  implementable.
- **Evidence:** Codebase: the release skill reads its plugin list from the first channel's storefront listing
  (`.claude/skills/han-release/SKILL.md` lines 37-48) and updates only the first channel's manifests and listing
  (lines 234, 326); eleven top-level directories carry `.claude-plugin/plugin.json`, distinguishing them from
  `docs/`, `images/`, and the rest. Source analysis: "The release process only knows about half the world"
  ([`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#the-publishing-pipeline-the-actual-problem)).
- **Rejected alternatives:**
  - Keeping the listing as input and adding the missing surfaces to it — rejected: a stale-able input stays
    stale-able; the Linear gap happened exactly this way.
- **Linked technical notes:** —
- **Driven by findings:** F2 (the plugin discriminator), F7 (the orphan rail's honest labeling)
- **Dependent decisions:** D3, D4
- **Referenced in spec:** Outcome; Primary Flow; Alternate Flows and States; Edge Cases and Failure Modes

### D3: The four surfaces and what current means

- **Question:** Which surfaces does a release update, what does "up to date" mean on each, and how is the target
  version decided?
- **Decision:** Four surfaces. On the first channel: each plugin's version record, and the storefront listing with
  its per-plugin versions. On the second channel: each plugin's version record, and the storefront listing, which
  carries no version numbers, so current there means complete presence. The release keeps today's bump-proposal step:
  it proposes a semantic bump per changed plugin, the maintainer confirms once, and that one confirmed target is what
  every surface receives. Where the two channels' records disagree beforehand, the first channel's record is the
  baseline, because the second channel's records are the ones that froze.
- **Rationale:** These are the four places the source analysis counted, each with a distinct staleness mode. A single
  confirmed target per plugin is what makes "both channels state the same version" achievable; two baselines would
  reintroduce drift at the moment of sync.
- **Evidence:** Codebase: `.claude-plugin/plugin.json` per plugin and `.claude-plugin/marketplace.json` (versioned
  entries); `.codex-plugin/plugin.json` per plugin (versioned) and `.agents/plugins/marketplace.json` (entries carry
  no version field); the bump-proposal interaction in `.claude/skills/han-release/SKILL.md` (its steps 3b-3d).
  Phase 3 spec: the second channel's records are the frozen ones
  (`../phase-3-unfreeze-versions/feature-specification.md`).
- **Rejected alternatives:**
  - Treating the second channel's listing as versioned like the first's — rejected: it has no version field, and
    inventing one duplicates the per-plugin records.
  - Deciding targets per channel — rejected: two baselines drift; one confirmed target is the sync.
- **Linked technical notes:** —
- **Driven by findings:** F4 (the bump-proposal step and the drift baseline made explicit)
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Coordinations

### D4: The bundle exception lives in one durable place

- **Question:** The all-in-one bundle cannot be published to the second channel. How do the release process and the
  later automated check both know that, permanently, without either flagging it forever?
- **Decision:** One durable exception record, read by both the release process and the Phase 7 check, holding a
  single named allowance: the bundle's absence from the second channel. Only that record silences a missing-plugin
  report; an undocumented absence always stops the release. A record that exists but cannot be read fails closed and
  names itself as the fault, distinctly from a missing-plugin report. No general multi-exception format is designed
  now; that question reopens if a concrete second exception ever arises.
- **Rationale:** Two independent copies would eventually disagree, and a hardcoded allowance inside either tool is
  invisible to the other. Exactly one exception exists, so a general format is flexibility without evidence. The
  fail-closed-and-name-itself rule keeps a corrupted record from either blocking releases with a misleading gap
  report or, worse, silencing real gaps.
- **Evidence:** Source analysis: "the check needs to know about it permanently rather than flagging it forever".
  Codebase: the `han` directory has no second-channel manifest, uniquely among the eleven; `README.md` lines 74-76
  document the channel's bundle limitation. Outline: Phase 6 preconditions (`../build-phase-outline.md#phase-6`).
- **Rejected alternatives:**
  - Hardcoding the exception in the release process and again in the check — rejected: duplicated knowledge drifts.
  - A general exception format designed now — rejected: one real exception exists; the simpler single allowance
    satisfies the same evidence, with the reopening trigger named.
- **Linked technical notes:** —
- **Driven by findings:** F3 (the default membership rule and naming the bundle), F6 (single allowance, general
  format deferred), F11 (fail closed and name itself), F14 (the precondition's requirement-versus-placement split recorded as OI-1)
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Edge Cases and Failure Modes; Coordinations;
  Out of Scope; Open Items

### D5: Markers, statements, and the publish boundary

- **Question:** Phase 5 hands this phase the markers and statements. Where does a release actually break, and what
  order and verification protect it?
- **Decision:** Three commitments. Ordering: per-plugin markers reach the shared repository before, or atomically
  with, any change that moves version statements, because the four surface files land together in one change while
  markers and the release record travel separately; the wrong order can refuse every install of the bundle. Re-run
  safety: the checks read the shared repository's real state, including marker presence and the release record, not
  only local file content, so a half-landed publish is detected rather than invisibly skipped. Reconciliation: after
  publishing, the process reads every surface, marker, and the release record back from the shared repository and
  fails loudly with a named report on anything that did not land. Every release also produces a per-plugin marker for
  each released plugin, new behavior relative to today's suite-only marker, and moves every edge to a companion in
  the same release as that companion's major bump.
- **Rationale:** The review relocated the real partial-failure boundary: the four files are effectively atomic under
  one change, while the markers and the release record are separate acts that can half-land. A file-state re-run
  check passes cleanly over a missing marker, reproducing the silent decay this cleanup exists to end, one axis over.
- **Evidence:** Phase 5 spec: statement-without-marker disables the depending plugin, and its gap plan expects this
  phase to take over marker production (`../phase-5-version-declarations/feature-specification.md`). Codebase: the
  release skill's publish sequence pushes the change before its markers today
  (`.claude/skills/han-release/SKILL.md` line 335), and its final report recounts local actions without reading the
  shared state back (lines 350-356).
- **Rejected alternatives:**
  - Treating the four surfaces as the partial-failure unit — rejected: they land together; the boundary that breaks
    is markers and the release record.
  - Leaving marker production manual indefinitely — rejected: a forgotten manual step recreates the
    disable-at-install failure Phase 5 guards against.
- **Linked technical notes:** —
- **Driven by findings:** F5 (in-spec definitions; markers are new), F8, F9, F10 (the three publish-boundary
  commitments)
- **Dependent decisions:** D6, D7
- **Referenced in spec:** Outcome; Primary Flow; Alternate Flows and States; Edge Cases and Failure Modes;
  Coordinations

### D6: Rehearsal mode

- **Question:** Is rehearsal an existing capability, and when is it required?
- **Decision:** Rehearsal is new behavior. It reports the discovered plugin list, per-surface results, the version
  plan, and the bundle exception as a known allowance, and it writes no surface, publishes nothing, pushes nothing,
  and produces no markers. It still shows the version plan for review. Whenever a release moves any version
  statement or includes a major bump, the maintainer sees and acknowledges the rehearsal view before anything
  publishes: the preview is opt-out on risky releases, not opt-in.
- **Rationale:** The release process today has no dry run, and its publish gate defaults to continuing without a
  pause. A release that can refuse every bundle install must not reach that state through a default path with no
  human checkpoint; making the preview opt-out for exactly those releases puts the guardrail where the risk is.
- **Evidence:** Codebase: the release skill's draft path still commits, tags, and publishes a draft release, and its
  pause option defaults off (`.claude/skills/han-release/SKILL.md` steps 8-9 and its `pause_before_publish`
  default). Review: the rollout-safety finding that the default path was deploy-without-preview.
- **Rejected alternatives:**
  - Rehearsal as an always-optional trigger — rejected for statement-moving and major-bump releases: recovery from a
    bad statement takes a release cycle, so skipping the preview is the expensive mistake.
  - Requiring rehearsal before every release — rejected: routine releases with no statement movement carry none of
    the refusal risk, and a mandatory step people resent gets skipped or hollowed out.
- **Linked technical notes:** —
- **Driven by findings:** F1 (rehearsal named as new and bounded), F12 (opt-out preview on risky releases)
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers; Primary Flow; Edge Cases and Failure Modes

### D7: A loud, recorded hotfix override

- **Question:** The release stops on any gap. What happens when an urgent fix must ship while an unrelated gap is
  open?
- **Decision:** A deliberate, single-use override ships the release and names every deferred gap in the release's own
  notes, so the bypass is loud and auditable. It is never the default, and the next ordinary release stops on the
  same gaps again.
- **Rationale:** Without an override, the completeness policy blocks incident recovery on unrelated bookkeeping,
  which pressures people to disable the whole gate: the exact failure the source analysis warns about. A loud,
  recorded door keeps the paved path easier than the shortcut while giving urgency a way through.
- **Evidence:** Review: the operational finding that gap-stops couple incident recovery to unrelated completeness.
  Source analysis: "turn the check on first and it fails on everything, someone disables it, and you are back where
  you started" names the disable-under-pressure failure this door prevents.
- **Rejected alternatives:**
  - No override — rejected: it converts the safety gate into the thing that gets switched off during the first real
    incident.
  - A silent skip flag — rejected: an unrecorded bypass is how gaps go invisible for twenty releases.
- **Linked technical notes:** —
- **Driven by findings:** F13
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States; Summary

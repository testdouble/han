# Feature Implementation Plan: han-core Restructure

This plan splits han-core into a lean shared-agent plugin plus two new topical plugins, han-documentation and
han-research, so depending on han-core no longer installs seven skills most dependents never use.

The whole restructure lands as one merge to the default branch. Every moved skill, rewritten manifest, dependency edit,
and reconciled documentation surface co-lands together, because the suite catalog resolves against the live default
branch with no staging boundary ([D-1](artifacts/implementation-decision-log.md#d-1-single-merge-atomicity-is-the-coordination-and-release-unit)).

This is a pure markdown-and-JSON change with no code, no build step, and no test runner. Verification is grep sweeps, a
manifest consistency check, link resolution, and one real-install procedure before release.

## Outcome

When this plan is executed, han-core contains the shared specialist-agent roster (every current agent except
research-analyst), the project-discovery skill with its project-scanner agent, and the canonical rule files, and nothing
else. Two new bundled plugins carry the moved skills: han-documentation holds project-documentation,
architectural-decision-record, and runbook; han-research holds research, gap-analysis, and issue-triage plus the
research-analyst agent. Three plugins that declared han-core without using it (han-reporting, han-feedback, han-linear)
drop the dependency, and han-atlassian re-points its one cross-plugin skill call to han-documentation.

Full-suite users keep every skill and agent they have today, now organized so each plugin's name matches its contents.
Edge-plugin users stop receiving the roster they never invoke.

Every reader-facing surface across the repository matches the new layout, and every reachable upgrade shape is verified
against a real install before release.

## User Stories

- **US-1:** As a suite maintainer, I want han-core reduced to the shared roster plus project discovery, so that plugins
  depending on it stop dragging in seven unused skills.
- **US-2:** As a user installing an edge plugin (han-linear, han-feedback, or han-reporting), I want only the
  dependencies my skills use, so that I no longer receive the full agent roster and skill set I never invoke.
- **US-3:** As a user upgrading a full `han` install, I want the upgrade to keep every skill and agent I had, so that the
  restructure is invisible to me except for the cleaner organization.
- **US-4:** As a user on a partial install that relied on han-core for the moved skills, I want the release notes to name
  each moved skill and how to restore it, so that the loss is a documented migration rather than a silent disappearance.
- **US-5:** As a Claude Code session dispatching across plugin boundaries, I want every moved skill and agent to resolve
  at its new namespaced home, so that cross-plugin invocations and dispatches keep working after the split.
- **US-6:** As a suite maintainer, I want every reader-facing surface reconciled with the new layout, so that no index,
  guide, or manifest advertises a skill its plugin no longer carries.

## Constraints and Boundaries

- **Driving constraint:** The user described the footprint pain directly: installing anything that depends on han-core
  pulls in 23 agents and 7 skills, and three plugins pull it for nothing (investigation problem statement). The
  restructure exists to remove that footprint.
- **Out of scope:** Renaming any skill or agent (spec D9); bumping any existing plugin's version (spec D11); a
  finer-grained per-entity dependency mechanism; changing what any skill or agent does; and adding dependencies to
  han-planning, han-coding, or han-github to preserve the moved skills on partial installs (spec D12). The two new
  plugins do start at version 1.0.0, which spec D11 does not govern
  ([D-13](artifacts/implementation-decision-log.md#trivial-decisions)).
- **Watch after ship:** Whether `/plugin update` re-fetches content on unchanged catalog versions is unknown until the
  OI-1 procedure runs; if it no-ops, effective release moves to the next han-release version bump
  ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)).

## Implementation Approach

The restructure moves leaf skills, not shared infrastructure. The agent roster stays put because han-planning and
han-coding each dispatch most of it. Six of the seven skills have zero cross-plugin callers, so moving them breaks
almost nothing (investigation E1, E2, E8). The work is mechanical relocation plus reference rewriting plus surface
reconciliation, all landing in one merge.

The two new plugins reuse the existing five-part plugin shape rather than introducing any new structure: README,
`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `skills/`, `docs/`, and `references/` with vendored rule
copies.

Rule files are vendored per plugin and never read cross-plugin, so each new plugin carries byte-identical copies
of evidence-rule.md and yagni-rule.md, following the han-planning and han-atlassian precedent
([D-12](artifacts/implementation-decision-log.md#trivial-decisions), investigation E12).

Each moved skill is one atomic unit, not simply a directory. A skill moves with its `references/` folder and its long-form
doc; the research skill additionally moves the research-analyst agent definition and that agent's doc. Nothing enforces
this pairing automatically, so the plan tracks each move as a unit
([D-3](artifacts/implementation-decision-log.md#d-3-each-moved-skill-is-one-atomic-multi-artifact-unit)).

### Reference rewriting

Namespace references are rewritten per moving entity across a repo-wide search, never by a blunt `han-core:` prefix
replace and never by a plugin-scoped sweep. A single file mixes moving and staying references. Some references also sit
outside the spec's named blast radius (the han-plugin-builder guidance cites `han-core:project-documentation`), so only
a per-entity repo-wide search resolves both hazards
([D-2](artifacts/implementation-decision-log.md#d-2-entity-name-scoped-repo-wide-grep-drives-every-namespace-rewrite)).

The moved long-form docs carry 23 relative agent-doc links. Twenty-two rewrite to the cross-plugin form
`../../../han-core/docs/agents/{name}.md`. The one exception is research.md's link to research-analyst, which stays
relative because that agent moves with the doc into han-research
([D-7](artifacts/implementation-decision-log.md#d-7-moved-doc-agent-links-are-rewritten-per-entity-sparing-the-one-link-that-moves)).

### Manifest and dependency edits

The manifest changes form one co-land set checked by a single scripted consistency sweep before merge: two new plugin
entries across marketplace and both manifest platforms, the han-core and re-pointed descriptions, the han meta-plugin
and han-atlassian dependency additions, and the three vestigial dependency drops
([D-5](artifacts/implementation-decision-log.md#d-5-a-single-co-land-manifest-set-passes-one-pre-merge-consistency-sweep)).

Dependency edits touch only the `.claude-plugin/plugin.json` manifests. The `.codex-plugin/plugin.json` manifests carry
no dependencies field, so their edits are content re-authoring only, wherever prose, keywords, or prompts name a moving
skill ([D-4](artifacts/implementation-decision-log.md#d-4-codex-manifests-get-content-re-authoring-not-dependency-edits)).

### Surface reconciliation

Reconciliation corrects stale statements, not only additions. The false "its skills dispatch shared han-core agents"
claim sits on three plugin READMEs, not one. Two docs/agents index prose lines assert han-core owns every agent but
readability-editor. And docs/concepts.md carries three dependency-prose corrections beyond link repoints
([D-8](artifacts/implementation-decision-log.md#d-8-reconciliation-corrects-stale-surfaces-including-three-false-readme-claims)).
han-research's reader surfaces present it as pre-planning knowledge work so all three of its skills are predictable from
its scent line, without renaming anything
([D-10](artifacts/implementation-decision-log.md#d-10-han-research-presents-as-pre-planning-knowledge-work-across-its-reader-surfaces)).

## Work Units and Sequencing

The work units below are an authoring order, not a release order. Everything co-lands in one merge
([D-1](artifacts/implementation-decision-log.md#d-1-single-merge-atomicity-is-the-coordination-and-release-unit)). The
dependencies below express which work must be authored before which, inside that single change.

| # | Work Unit | Story | Delivers | Depends On | Verification |
| --- | --------- | ----- | -------- | ---------- | ------------ |
| 1 | Scaffold the two new plugins | US-1 | han-documentation and han-research exist in the five-part shape with vendored rule copies, both bundled by the han meta-plugin and listed in the marketplace ([D-12](artifacts/implementation-decision-log.md#trivial-decisions), [D-13](artifacts/implementation-decision-log.md#trivial-decisions)) | — | Directory shape matches the han-planning precedent |
| 2 | Move the six skills and their docs | US-1, US-5 | Each skill, its `references/`, and its long-form doc land at the new home; research-analyst and its doc move with the research skill, each as one atomic unit ([D-3](artifacts/implementation-decision-log.md#d-3-each-moved-skill-is-one-atomic-multi-artifact-unit)) | 1 | Move-unit completeness check |
| 3 | Rewrite namespaces and agent-doc links | US-5 | Every moving reference re-namespaced per entity; 22 of 23 agent-doc links rewritten cross-plugin, research.md's spared ([D-2](artifacts/implementation-decision-log.md#d-2-entity-name-scoped-repo-wide-grep-drives-every-namespace-rewrite), [D-7](artifacts/implementation-decision-log.md#d-7-moved-doc-agent-links-are-rewritten-per-entity-sparing-the-one-link-that-moves)) | 2 | grep sweeps; link resolution |
| 4 | Edit dependency manifests and codex content | US-1, US-2, US-3 | Three vestigial drops, han-atlassian and han meta additions, both new plugins registered, han-atlassian's wrapper invocation re-pointed, codex prose re-authored ([D-4](artifacts/implementation-decision-log.md#d-4-codex-manifests-get-content-re-authoring-not-dependency-edits), [D-5](artifacts/implementation-decision-log.md#d-5-a-single-co-land-manifest-set-passes-one-pre-merge-consistency-sweep)) | 1 | jq co-land consistency sweep |
| 5 | Reconcile shared documentation surfaces | US-6 | Skills and agents indexes, choosing guide, workflows map, concepts, and the CLAUDE.md layout tree and Conventions sentence match the new layout ([D-8](artifacts/implementation-decision-log.md#d-8-reconciliation-corrects-stale-surfaces-including-three-false-readme-claims)) | 2, 4 | grep sweeps |
| 6 | Correct stale and false claims | US-6 | Three false README dispatch claims, han-core's front door, and the docs/agents index prose corrected; han-research scent framing applied ([D-8](artifacts/implementation-decision-log.md#d-8-reconciliation-corrects-stale-surfaces-including-three-false-readme-claims), [D-10](artifacts/implementation-decision-log.md#d-10-han-research-presents-as-pre-planning-knowledge-work-across-its-reader-surfaces)) | 4 | grep sweeps |
| 7 | Pre-release OI-1 verification | US-3, US-4 | Four upgrade shapes verified against a real install, plus recovery via merge revert ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)) | 3, 4, 5, 6 | Install-and-revert procedure |

## Definition of Done

- [ ] han-core contains the shared roster (every agent except research-analyst), project-discovery, project-scanner, and
      the canonical rule files, and nothing else.
- [ ] han-documentation and han-research exist, are bundled by the han meta-plugin, are listed in the marketplace, and
      carry vendored rule copies ([D-12](artifacts/implementation-decision-log.md#trivial-decisions)).
- [ ] han-reporting, han-feedback, and han-linear no longer depend on han-core; han-atlassian depends on
      han-documentation and keeps its direct han-core dependency.
- [ ] The five grep sweeps pass, showing no surface references a moved entity at its old home and every index lists each
      entity at its new home ([D-9](artifacts/implementation-decision-log.md#d-9-five-grep-sweeps-are-the-acceptance-artifact-for-surface-reconciliation)).
- [ ] The jq consistency sweep passes: no manifest advertises a skill its plugin no longer carries and no dependency
      list names a plugin absent from the catalog ([D-5](artifacts/implementation-decision-log.md#d-5-a-single-co-land-manifest-set-passes-one-pre-merge-consistency-sweep)).
- [ ] Every rewritten agent-doc link resolves, and research.md's research-analyst link resolves at its co-located home
      ([D-7](artifacts/implementation-decision-log.md#d-7-moved-doc-agent-links-are-rewritten-per-entity-sparing-the-one-link-that-moves)).
- [ ] The OI-1 procedure has run against a real install for all four upgrade shapes and confirmed the revert recovery
      path ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)).

## Testing Strategy

This is a markdown-and-JSON change with no test runner, so "testing" means reproducible searches, a manifest check, link
resolution, and one real-install procedure. There are no unit tests to write and none to run.

- **Observable behaviors to verify:** every bare skill name still resolves to exactly one skill suite-wide; every moved
  skill resolves at its new namespaced home; every agent dispatch inside a moved skill resolves at its post-split home;
  han-atlassian's wrapper resolves project-documentation at han-documentation.
- **Verification artifacts:** the five repo-wide grep sweeps are the acceptance artifact for surface reconciliation,
  giving a canonical runnable search-term list rather than a manual count
  ([D-9](artifacts/implementation-decision-log.md#d-9-five-grep-sweeps-are-the-acceptance-artifact-for-surface-reconciliation)).
  The jq consistency sweep proves the catalog invariant across the co-land manifest set
  ([D-5](artifacts/implementation-decision-log.md#d-5-a-single-co-land-manifest-set-passes-one-pre-merge-consistency-sweep)).
  Link resolution confirms the 22 rewritten agent-doc links and the one spared link
  ([D-7](artifacts/implementation-decision-log.md#d-7-moved-doc-agent-links-are-rewritten-per-entity-sparing-the-one-link-that-moves)).
- **Real-install verification:** the OI-1 procedure installs each of the four upgrade shapes, upgrades, diffs the
  invocable set against the spec commitment, and reverts the merge to confirm recovery
  ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)).
  Its first assertion tests whether `/plugin update` re-fetches on unchanged versions.

## Operational Readiness

- **Release gate:** Release is gated on the OI-1 procedure passing for all four upgrade shapes (full `han`, standalone
  han-core, partial such as han-coding-only, and han-atlassian). Implementation may proceed before the gate. Release may
  not ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)).
- **Atomicity:** The marketplace resolves against the default branch with no ref pinning, so the merged state is the live
  state. The whole change lands in one merge to avoid any inconsistent intermediate catalog
  ([D-1](artifacts/implementation-decision-log.md#d-1-single-merge-atomicity-is-the-coordination-and-release-unit)).
- **Recovery:** Because the change is pure markdown and JSON, reverting the merge with `git revert -m 1` is a complete
  recovery. Upgraded installs return to their prior working set on next resolve. The revert is verified in the same OI-1
  run ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)).
- **Pre-merge check:** The jq consistency sweep over the co-land manifest set runs before merge and must pass
  ([D-5](artifacts/implementation-decision-log.md#d-5-a-single-co-land-manifest-set-passes-one-pre-merge-consistency-sweep)).

## Risks and Assumptions

### Risks

| ID | Risk | Impact | Mitigation | Owner |
| --- | ---- | ------ | ---------- | ----- |
| R1 | The resolver mishandles the two new bundled plugin names on a full-suite upgrade | A full-suite upgrade could silently miss the moved skills | OI-1 verifies the full-`han` shape against a real install before release; revert recovery confirmed in the same run ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)) | devops-engineer |
| R2 | A per-entity reference is missed, leaving a stale `han-core:` namespace that no longer resolves | A cross-plugin invocation or link breaks after the split | Per-entity repo-wide grep, not prefix or plugin-scoped sweeps, plus the five acceptance sweeps ([D-2](artifacts/implementation-decision-log.md#d-2-entity-name-scoped-repo-wide-grep-drives-every-namespace-rewrite), [D-9](artifacts/implementation-decision-log.md#d-9-five-grep-sweeps-are-the-acceptance-artifact-for-surface-reconciliation)) | structural-analyst |

### Assumptions

| ID | Assumption | What Changes If Wrong | Status |
| --- | ---------- | --------------------- | ------ |
| A1 | The marketplace resolves against the default branch, so the merged state is the live state | The atomicity unit would shift from the merge to a tag or ref | Verified (OQ-1r: `README.md:38`, `docs/choosing-a-han-plugin.md:106`) |
| A2 | `/plugin update` re-fetches content when catalog versions are unchanged | Effective release moves to the next han-release version bump | Runtime-only (OI-1 first assertion) |
| A3 | No `.codex-plugin/plugin.json` carries a dependencies field, so dependency edits touch only `.claude-plugin` manifests | Codex manifests would also need dependency edits | Verified (OQ-4r: grep across all nine returned none) |

## Open Items

- **OI-1 (inherited from spec):** Whether plugin dependency resolution behaves correctly for every reachable upgrade
  shape when the restructure ships.
  - **Resolves when:** The concrete install-and-revert procedure passes for all four shapes, with the re-fetch behavior
    settled as its first assertion ([D-6](artifacts/implementation-decision-log.md#d-6-oi-1-verification-runs-a-concrete-per-shape-install-and-revert-procedure)).
  - **Blocks implementation:** No. Implementation proceeds; release is gated on this passing.
- **OI-2 (inherited from spec):** Whether external documentation or user muscle memory depends on the old namespaced
  forms such as `han-core:research`.
  - **Resolves when:** han-release publishes the old-to-new namespace map plus a restore step per moved skill
    ([D-11](artifacts/implementation-decision-log.md#d-11-the-release-notes-namespace-map-is-handed-to-han-release)).
  - **Blocks implementation:** No. The bare skill names keep working wherever the new plugins are installed.

## Specialist Handoffs for Implementation

- **`devops-engineer` (as the han-release owner)**, dispatched at release time, needs the old-to-new namespace map and
  the per-skill restore step this restructure produces, which han-release publishes as the release notes
  ([D-11](artifacts/implementation-decision-log.md#d-11-the-release-notes-namespace-map-is-handed-to-han-release)).

## Sources and Plan Records

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Investigation report:** [investigation.md](investigation.md)
- **Specification companions:** [decision log](artifacts/decision-log.md), [team findings](artifacts/team-findings.md)
- **Specification decisions inherited / open items to respect:** spec D1-D13 / OI-1, OI-2
- **Decision rationale and rejected alternatives:** [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:** [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned: proceed to implementation now. The restructure is fully specified, every open question raised in
planning was resolved by codebase evidence, and the YAGNI sweep found nothing to defer. Release is gated on the OI-1
install-and-revert procedure passing for all four upgrade shapes. Implementation does not wait on that gate.

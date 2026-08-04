# Gap Analysis Round 2: han-communication Plugin Spec vs. Repo Reality (Post-Update)

## Comparison Direction

Current state: this repo, as it exists on disk today (the `han-communication-plugin` feature has not been implemented). Desired state: `docs/plans/han-communication-plugin/feature-specification.md` and `docs/plans/han-communication-plugin/artifacts/decision-log.md`, as they stand **after** the update that makes `han-communication` a **direct** dependency of `han-core`, `han-coding`, `han-github`, `han-reporting`, the `han` meta-plugin, and `han-atlassian` (no transitive reliance), and that removes OI-1.

Comparison is unidirectional: current state (repo) checked against desired state (spec) for gaps in the spec's change-inventory. This round builds on `docs/plans/han-communication-plugin/artifacts/gap-analysis-scratch.md` (round 1) and focuses on what changed or was left unexamined by round 1 given the updated D5/D7 scope, plus the three task areas requested: D5 dependency-declaration completeness, D7 documentation/tooling scope, and the marketplace manifest.

## Scope

Comparison areas:
1. Every `plugin.json` (both `.claude-plugin/` and `.codex-plugin/` variants) and every `SKILL.md` in the repo, checked for hosting or triggering a delegating skill, against D5's named set.
2. The full stale-pointer inventory for the four assets (`readability-editor`, `edit-for-readability`, `readability-rule`, `writing-voice`), re-verified against the updated D7's four classes.
3. `.claude-plugin/marketplace.json`, checked against D8 and the dependency edges D5/D6 add.

Excluded, consistent with round 1 and `docs/plans/CLAUDE.md`: `docs/plans/**` other than `han-communication-plugin` itself (frozen historical planning artifacts), `docs/research/**` (historical narrative), and `CHANGELOG.md` (append-only history).

## Actors and Modes Observed

Same as round 1: an operator running any prose-producing Han skill; a contributor maintaining the suite; the plugin loader resolving declared dependencies at install time. This round surfaces one additional mode the spec's Actors section does not name: a **Codex** operator, installing Han plugins through the separate Codex plugin marketplace/CLI documented in `README.md`'s "Codex" section, which installs plugins individually rather than through the meta-plugin. This is a distinct installation surface from the Claude Code plugin loader the spec's Actors section describes.

## Summary

Compared the updated han-communication-plugin feature specification and decision log (desired state, with han-atlassian now a direct dependency and OI-1 removed) against the repo (current state) across three areas: D5's dependency-declaration completeness, D7's documentation/tooling scope, and the marketplace manifest. Direction: current state (repo) checked against desired state (spec).

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 5 | Elements in desired state with no current state correspondence |
| Partial | 2 | Elements present in both but incompletely covered |
| Divergent | 1 | Elements addressing same concern in incompatible ways |
| Implicit | 1 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: `/Users/riverbailey/dev/testdouble/han/docs/plans/han-communication-plugin/artifacts/gap-analysis-round2-scratch.md`

## Task 1: D5 Dependency-Declaration Completeness — Verified, No Discrepancy in the Plugin Set Itself

Grepped every `.claude-plugin/plugin.json` and every `.codex-plugin/plugin.json` in the repo for the four asset strings: zero hits anywhere (manifests don't carry prose about the assets). Grepped every `SKILL.md` in `han-planning/`, `han-linear/`, `han-feedback/`, and `han-plugin-builder/` for the four asset strings and for dispatches of the nine delegating skills (`han-core:research`, `han-core:gap-analysis`, `han-core:project-documentation`, `han-core:issue-triage`, `han-core:architectural-decision-record`, `han-core:runbook`, `han-coding:code-review`, `han-coding:code-overview`, `han-coding:investigate`, `han-coding:architectural-analysis`, `han-github:update-pr-description`, `han-reporting:stakeholder-summary`, `han-reporting:html-summary`): zero true hits. The two incidental matches (`han-feedback/skills/han-feedback/SKILL.md` and `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md`) are both illustrative prose (a session-naming example and a skill-composition example), not actual dispatches — neither skill invokes a delegating skill.

Grepped `han-atlassian/` for the four asset strings directly: zero hits, confirming D5's framing that `han-atlassian` reaches the capability only by wrapping `han-core`/`han-coding` skills that delegate, not by referencing the assets itself.

`han` (the meta-plugin) has no `skills/` directory of its own, confirming it only bundles.

**Conclusion: D5's exact-match claim — `{han-core, han-coding, han-github, han-reporting, han meta-plugin, han-atlassian}` — holds. No plugin the set misses, no plugin wrongly included.** This confirms and closes the round-1 "adjacent observation" about `han-planning`'s transitive exposure: since D5 no longer relies on transitive resolution and OI-1 is removed, that concern is resolved by the spec update itself, not left open.

## Task 2: D7 Documentation/Tooling Scope — Prior Findings Now Covered, One New Category Found

Cross-checked round 1's GAP-001 through GAP-008 against the current (updated) D7 text:

| Round-1 finding | Current D7 coverage |
|---|---|
| GAP-001 (`docs/readability.md`, 13 sites) | Named explicitly in D7 clause 2 |
| GAP-002 (8 long-form docs hardcoding `han-core:readability-editor` in prose) | Covered by D7 clause 3 ("~9 docs"; re-verified below — actual count is 8 live docs, `readability-editor.md`'s own copy is a 9th but is covered separately as a relocating doc, so the "~9" figure is accounted for) |
| GAP-003 (`docs/concepts.md:99`) | Named explicitly in D7 clause 2 |
| GAP-004 (CONTRIBUTING.md vendoring procedure) | D7 clause 4 now says CONTRIBUTING.md's "Wiring the readability standard into a skill" section is **rewritten**, not just repointed |
| GAP-005 (`han-release/references/changelog-rules.md`) | Named explicitly in D7 clause 4 |
| GAP-006 (`han-update-documentation`) | Named explicitly in D7 clause 4 |
| GAP-007 (5 skill-internal template files) | Named explicitly in D7 clause 4 ("the five skill-internal template files") — count re-verified at exactly 5 |
| GAP-008 (`.github/pull_request_template.md`) | Named explicitly in D7 clause 4 |

Re-ran the full-repo grep for the four asset strings (excluding `docs/plans/**` other than this feature, `docs/research/**`, and `CHANGELOG.md`): the resulting file list is unchanged from round 1's inventory. No new stale-pointer site inside the four-asset grep scope was found. **All eight round-1 findings are now closed by the updated D7.**

However, re-verifying D7 against the *reason* those eight findings existed — sites that don't literally contain any of the four asset strings but that will still go stale because D5/D6 change the plugin *dependency graph*, not just the location of the four assets — surfaced a new, unflagged category, detailed in GAP-101 below. This category was invisible to round 1's grep methodology (scoped to the four asset strings) and remains invisible to the current D7 (scoped to "pointers to the canonical location of the readability rule or writing-voice profile" and the relocating docs), because D7 is entirely about *where the assets live*, not about *which plugins declare which dependencies*.

## Task 3: Marketplace Manifest — Plugin List Confirmed, But D8's "Only Manifest Change" Claim Is Incomplete

`.claude-plugin/marketplace.json` currently lists exactly the 10 plugins the plan and `CLAUDE.md`'s own tree comment (line 23) say it lists: `han`, `han-core`, `han-planning`, `han-coding`, `han-github`, `han-reporting`, `han-feedback`, `han-atlassian`, `han-linear`, `han-plugin-builder`. No discrepancy there.

D8 states the marketplace manifest's only needed change is gaining a `han-communication` entry. Checking that claim against the file's actual structure: marketplace entries carry no `dependencies` field at all — the "new dependency edges" D5/D6 add live entirely in each plugin's own `.claude-plugin/plugin.json` `dependencies` array, not in `marketplace.json`. So D8's phrasing already conflates two files. More substantively: three marketplace entries' `description` fields narrate the plugin's current dependency set in prose, mirrored byte-for-byte (or near-identically) from the corresponding `plugin.json` `description` field:
- `han`: "it depends on `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`"
- `han-coding`: "Depends on `han-core`; bundled by the `han` meta-plugin."
- `han-atlassian`: "Depends on `han-core`, `han-planning`, and `han-coding` (its wrapper skills run skills from each)"

Once D5/D6 add `han-communication` to these three plugins' `dependencies` arrays, these description strings under-state the dependency set unless also rewritten — a fourth kind of manifest change beyond "add an entry," not named by D8. See GAP-102.

## Findings

**GAP-101: Plugin dependency-graph narration outside the four-asset scope goes stale, and no decision addresses it**
- **Category:** Missing
- **Feature/Behavior:** Documentation and prose that describes which Han plugins depend on which other plugins must reflect the new `han-communication` dependency edges D5/D6 add to `han-core`, `han-coding`, `han-github`, `han-reporting`, the `han` meta-plugin, and `han-atlassian`.
- **Current State:** Multiple files narrate the current dependency graph in prose that contains none of the four asset strings (`readability-editor`, `edit-for-readability`, `readability-rule`, `writing-voice`), so they fall outside both round 1's grep scope and D7's asset-pointer scope entirely:
  - `CLAUDE.md` lines 3, 24, 33, 38, 53, 57, 58, 62, and 80 (the intro paragraph and every affected plugin's tree-comment line in "Repository layout")
  - `CONTRIBUTING.md` lines 34 and 37 (the `han-atlassian` and `han` bullets in "Which plugin does the change belong in?")
  - `README.md` lines 57–60 and 72–83 (the bundled-suite sentence and the entire "Codex" install-command section)
  - `docs/concepts.md` lines 121, 123, and 125 ("Each of these four depends on `han-core`..."; "It depends on `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`..."; "...it depends on those two as well")
  - `docs/choosing-a-han-plugin.md` lines 20–27 and 34 (a per-plugin dependency sentence for every affected plugin, plus a summary sentence: "`han-planning`, `han-coding`, `han-github`, and `han-reporting` all depend on `han-core`")
  - `docs/how-to/extend-han-with-plugin-dependencies.md` line 45 ("`han-core` is the base layer... it depends on nothing") — this line becomes false the moment `han-core` gains a dependency; the surrounding doc is an illustrative worked example already out of sync with the current plugin family in other ways (it omits `han-planning`, `han-coding`, and `han-atlassian` from its walkthrough), so it carries lower confidence as a must-fix site than the others above, but the false "depends on nothing" claim is a direct, first-order contradiction of D1.
- **Desired State:** D7's decision text scopes the documentation/tooling change entirely around "every pointer to the canonical location of the readability rule or writing-voice profile" and "every `han-core:readability-editor` qualified-name string" (decision-log.md D7, clauses 2 and 3) or vendoring-procedure prose specific to the four assets (clause 4). No clause in D5, D6, D7, or D8 addresses prose that describes the plugin dependency graph itself, independent of the four assets. The feature specification's Coordinations table states only that `han-communication`'s inbound consumers and the `han` meta-plugin's outbound dependency change — it does not mention any documentation surface that narrates the dependency graph in prose.

**GAP-102: `plugin.json` and `marketplace.json` description fields that narrate dependencies in prose are not covered by D5, D6, or D8**
- **Category:** Missing
- **Feature/Behavior:** A plugin's own manifest `description` field, and its mirrored `description` in `marketplace.json`, must stay consistent with that plugin's `dependencies` array.
- **Current State:** `han/.claude-plugin/plugin.json:3`, `han-coding/.claude-plugin/plugin.json:3`, and `han-atlassian/.claude-plugin/plugin.json:3` each narrate their plugin's current dependency set in the `description` string ("Depends on `han-core`; bundled by the `han` meta-plugin." for `han-coding`; "Depends on `han-core`, `han-planning`, and `han-coding`..." for `han-atlassian`; "it depends on `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`" for `han`). `.claude-plugin/marketplace.json` lines 13, 31, and 55 mirror these same three descriptions.
- **Desired State:** D5 changes only the `dependencies` array; D6 changes only the `han` meta-plugin's `dependencies` array; D8 says only that the marketplace manifest "gains a `han-communication` entry." None of the three decisions mentions updating the `description` prose inside the affected plugins' own `plugin.json` files or their `marketplace.json` mirrors, even though three of those description strings will under-state the true dependency set once implemented.

**GAP-103: No decision addresses whether `han-communication` needs a `.codex-plugin/plugin.json` counterpart**
- **Category:** Implicit
- **Feature/Behavior:** Every other plugin in the repo except the `han` meta-plugin ships a paired `.codex-plugin/plugin.json` alongside its `.claude-plugin/plugin.json`, so that the plugin is installable through the separate Codex marketplace/CLI documented in `README.md`.
- **Current State:** `find . -name plugin.json` shows a `.codex-plugin/plugin.json` for `han-atlassian`, `han-coding`, `han-core`, `han-feedback`, `han-github`, `han-linear` (has none, actually — see note below), `han-planning`, `han-plugin-builder`, and `han-reporting` — 8 of the 9 non-meta plugins. (`han-linear` also lacks a `.codex-plugin/plugin.json`; that is a pre-existing gap unrelated to this feature, noted for completeness, not raised here.) `han-plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-naming.md:60` documents that a plugin rename must update the name "in the plugin's own `plugin.json` (both `.claude-plugin/` and `.codex-plugin/` if present)," confirming the repo treats the two manifest formats as a paired convention where both are typically present.
- **Desired State:** D1 says "Create a new plugin, `han-communication`, that depends on nothing." Neither D1 nor D2 nor D8 states whether the new plugin needs a `.codex-plugin/plugin.json`, and the feature specification's Coordinations table names only the Claude Code marketplace manifest, not a Codex one. The spec is silent on this scaffolding question — an Implicit gap, not a confirmed Missing one, since it is plausible the repo's Codex support is being deliberately left out of scope rather than overlooked.

**GAP-104: `README.md`'s Codex install-command section is not addressed by D5, D6, or D7**
- **Category:** Divergent
- **Feature/Behavior:** Instructions for installing Han plugins through the Codex CLI, as a documented alternative to the Claude Code plugin loader.
- **Current State:** `README.md:72–79` states "Codex does not yet support meta-plugins like `han@han`... so install the Han packages directly," followed by five explicit `codex plugin add` commands for `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting` — with no `codex plugin add han-communication@han` command, and no statement about whether Codex resolves a plugin's `dependencies` array automatically the way the Claude Code loader does.
- **Desired State:** The feature specification's Primary Flow step 1 and Edge Cases table both assume "the plugin loader resolves that plugin's declared **direct** dependency on `han-communication`... and installs it alongside" as the mechanism that guarantees the capability is present. If Codex does not auto-resolve `dependencies` the way the spec assumes for the Claude Code loader (the doc's own framing — "install the Han packages directly" — suggests it might not), a Codex user following `README.md`'s literal instructions after this change would end up with `han-core`, `han-coding`, `han-github`, and `han-reporting` installed but no `han-communication`, contradicting the spec's Edge Cases row: "A plugin that produces prose output is installed without `han-communication` present... A skill that reaches a delegation point with the capability unresolved is a broken install, not a supported state." The spec frames this as impossible for a "supported install," but does not address the Codex install path where the explicit-command pattern could produce exactly that unsupported state. Neither D5, D6, nor D7 mentions `README.md`'s Codex section.

**GAP-105: `docs/choosing-a-han-plugin.md` is not named in D7's doc-scope despite containing the densest per-plugin dependency narration in the repo**
- **Category:** Partial
- **Feature/Behavior:** Same underlying concern as GAP-101 (dependency-graph narration going stale), isolated to a single file with the highest concentration of affected text.
- **Current State:** `docs/choosing-a-han-plugin.md` lines 20–27 give one dependency-narrating sentence per plugin (six of the eight bulleted plugins state a `han-core` or `han-core`/`han-planning`/`han-coding` dependency), and line 34 restates it in summary form: "`han-planning`, `han-coding`, `han-github`, and `han-reporting` all depend on `han-core`." This is the file `README.md:62` and `README.md:88–89` point readers to for "the full picture" of plugin dependencies.
- **Desired State:** D7's doc-scope enumerates "the agent and skill indexes, `docs/concepts.md`, `docs/readability.md`, and the long-form docs of the consuming skills" (clause 2) plus CLAUDE.md, CONTRIBUTING.md, repo-maintenance skills, and templates (clause 4). `docs/choosing-a-han-plugin.md` — the page the repo's own README calls the canonical "which one do you need?" guide — is not named anywhere in D7, despite being the single densest concentration of exactly the kind of stale content D7 is trying to prevent doc readers from encountering.

**GAP-106: `docs/how-to/build-a-plugin-that-depends-on-han.md` and `docs/how-to/extend-han-with-plugin-dependencies.md` teach the pre-change dependency graph as a worked example**
- **Category:** Partial
- **Feature/Behavior:** Conceptual and hands-on guides that use Han's own plugins as the worked example for how the `dependencies` mechanism functions.
- **Current State:** `docs/how-to/extend-han-with-plugin-dependencies.md:3` states its purpose is to explain "how `han-github`, `han-reporting`, and `han-feedback` extend `han-core`," and line 45 states "`han-core` is the base layer... it depends on nothing." `docs/how-to/build-a-plugin-that-depends-on-han.md:7` cites `han-github` as the worked example of "declares `han-core` as a dependency." Both docs are already a partial, illustrative snapshot (they omit `han-planning`, `han-coding`, and `han-atlassian` from the worked example, and use placeholder version numbers), so they carry lower confidence than GAP-101's other sites, but the "`han-core`... depends on nothing" statement is a direct, unqualified claim that becomes false under D1.
- **Desired State:** D7 does not name either how-to document. D1 states `han-communication` "depends on nothing" and becomes "the foundational layer beneath `han-core` and every other plugin" — displacing `han-core`'s current claimed status as the layer with no dependencies, which is exactly the claim these two docs teach.

## Areas Needing Separate Analysis

- **`docs/research/*.md` standalone reports** — same note as round 1: not evaluated for post-move correction versus intentional historical-snapshot status.
- **`.codex-plugin/plugin.json` format's actual dependency-resolution behavior** — this analysis could not confirm from repo files alone whether the Codex CLI/marketplace resolves a plugin's Claude-Code-style `dependencies` array at all (the `.codex-plugin/plugin.json` schema observed in this repo carries no `dependencies` field for any existing plugin). Whether GAP-103 and GAP-104 are real operational risks or moot (because Codex install of a dependent plugin already requires the operator to separately install every dependency by hand, a pattern the docs already model) depends on Codex's actual resolution behavior, which is outside this repo and was not independently verified.
- **`han-linear`'s missing `.codex-plugin/plugin.json`** — noted in GAP-103 as a pre-existing gap unrelated to this feature; whether it should also gain one is a separate question from this plan.

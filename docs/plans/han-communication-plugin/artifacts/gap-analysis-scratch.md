# Gap Analysis: han-communication Plugin Spec vs. Repo Reality

## Comparison Direction

Current state: this repo, as it exists on disk today (the `han-communication-plugin` feature has not been implemented). Desired state: `docs/plans/han-communication-plugin/feature-specification.md` and `docs/plans/han-communication-plugin/artifacts/decision-log.md`.

Comparison is unidirectional: current state (repo) checked against desired state (spec) for gaps in the spec's change-inventory (D5's grep inventory and D7's doc-scope) relative to what a full repo-wide grep for the four assets actually turns up.

## Scope

Comparison area: every file in the repo that references any of `readability-editor`, `edit-for-readability`, `readability-rule`, or `writing-voice` (full-repo grep, case-sensitive on those literal strings), cross-checked against the spec's explicit change-inventory (D5's plugin list, D7's doc-scope, D9's invocation-site scope).

Excluded: `docs/plans/**` other than `han-communication-plugin` itself — these are frozen historical planning artifacts per `docs/plans/CLAUDE.md` ("should not be updated during documentation reviews... not a source of truth for any feature work beyond the initial features built from it"). `docs/research/**` standalone reports were located by the grep but not analyzed for update-need; they are historical narrative, not live cross-references, and are flagged under Areas Needing Separate Analysis rather than as gaps. `CHANGELOG.md` was located by grep but excluded as a gap candidate: changelog entries are an append-only historical record by suite convention and are not expected to be rewritten when an asset later moves.

## Actors and Modes Observed

The spec's Actors section names: an operator running any prose-producing Han skill; a contributor maintaining the suite; the plugin loader resolving declared dependencies at install time. No interactive-vs-batch distinction is drawn — every consuming skill runs the same way (dispatch or self-check) regardless of invocation mode. No API/agent/integration surface beyond the `Agent` tool dispatch mechanism itself is named. The spec also implicitly addresses a fourth actor type not named in its own Actors list: repo-maintenance tooling that runs as part of this repository's own release and documentation-audit process (`.claude/skills/han-release`, `.claude/skills/han-update-documentation`) rather than as an installed plugin skill — see GAP-005 and GAP-006.

## Summary

Compared the han-communication-plugin feature specification and decision log (desired state) against a full-repo grep for `readability-editor`, `edit-for-readability`, `readability-rule`, and `writing-voice` (current state), to find reference sites the spec's change-inventory (D5, D7, D9) does not account for. Direction: current state (repo) checked against desired state (spec).

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 5 | Elements in desired state with no current state correspondence |
| Partial | 2 | Elements present in both but incompletely covered |
| Divergent | 1 | Elements addressing same concern in incompatible ways |
| Implicit | 1 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: `/Users/riverbailey/dev/testdouble/han/docs/plans/han-communication-plugin/artifacts/gap-analysis-scratch.md`

## Complete Reference Inventory (Task Item 1)

Full-repo grep for the four asset strings, excluding `docs/plans/han-communication-plugin/` itself, classified by role:

### (d) The assets themselves
- `han-core/agents/readability-editor.md`
- `han-core/skills/edit-for-readability/SKILL.md`
- `han-core/references/readability-rule.md`
- `han-core/references/writing-voice.md`

### (a) Skill that dispatches/invokes the capability directly
- `han-coding/skills/architectural-analysis/SKILL.md`
- `han-coding/skills/code-overview/SKILL.md`
- `han-coding/skills/code-review/SKILL.md`
- `han-coding/skills/investigate/SKILL.md`
- `han-core/skills/gap-analysis/SKILL.md`
- `han-core/skills/project-documentation/SKILL.md`
- `han-core/skills/research/SKILL.md`
- `han-github/skills/update-pr-description/SKILL.md`
- `han-reporting/skills/stakeholder-summary/SKILL.md`

All nine dispatch `han-core:readability-editor` directly with their own `Agent` call (none route through the `edit-for-readability` skill) and separately load `../../references/readability-rule.md` for in-line drafting guidance. Each is a dual-role (a)+(b) site.

### (b) Skill/agent/template that reads a reference file by path (self-check only, no dispatch today)
- `han-core/skills/issue-triage/SKILL.md` — reads `../../references/readability-rule.md`; "This skill runs no rewrite pass" (D4 target)
- `han-core/skills/architectural-decision-record/SKILL.md` — same pattern (D4 target)
- `han-core/skills/runbook/SKILL.md` — same pattern (D4 target)
- `han-reporting/skills/html-summary/SKILL.md` — same pattern (D4 target)
- `han-core/skills/edit-for-readability/SKILL.md` — reads its own within-plugin rule path; not a "consumer," moves together with the rule (D1/D2), so this site needs no delegation conversion

### (b) Template/reference files inside `skills/references/` that read the rule by relative path
- `han-coding/skills/code-overview/references/overview-template.md:11`
- `han-coding/skills/code-review/references/template.md:14`
- `han-core/skills/issue-triage/references/template.md:1`
- `han-core/skills/research/references/research-report-template.md:8`
- `han-reporting/skills/html-summary/references/writing-conventions.md:11`

See GAP-007 — none of these five are named in D7's doc-scope.

### (c) Docs/top-level files that point at a location
- `CLAUDE.md` (project map, lines 32/42/47/52/94/106) — explicitly in D7's scope
- `CONTRIBUTING.md` (lines 69–73, 85, 119) — explicitly named by D7, but see GAP-004
- `.github/pull_request_template.md:18` — see GAP-008
- `docs/concepts.md:99` — see GAP-003
- `docs/readability.md` (13 pointers/qualified names) — see GAP-001
- `docs/agents/README.md:69` — in D7 scope (index)
- `docs/agents/han-core/readability-editor.md` — the asset's own long-form doc; moves per D7
- `docs/skills/README.md:39` — in D7 scope (index)
- `docs/skills/han-core/edit-for-readability.md` — the asset's own long-form doc; moves per D7
- `docs/skills/han-coding/architectural-analysis.md:118`, `code-overview.md:97`, `code-review.md:128`, `investigate.md:82` — see GAP-002
- `docs/skills/han-core/gap-analysis.md:130`, `research.md:96` — see GAP-002
- `docs/skills/han-github/update-pr-description.md:72` — see GAP-002
- `docs/skills/han-reporting/stakeholder-summary.md:71` — see GAP-002
- `.claude/skills/han-release/references/changelog-rules.md:126` — see GAP-005
- `.claude/skills/han-update-documentation/SKILL.md:131` — see GAP-006
- `.claude/skills/han-update-documentation/references/scope-mapping.md:25` — see GAP-006
- `CHANGELOG.md` — historical release notes, multiple hits, excluded (append-only convention)
- `docs/research/*.md`, `docs/plans/*` (other than han-communication-plugin) — historical, excluded per scope

## Task Item 2: D5's Exact-Match Claim

**Verified, no discrepancy found.** D5 claims the plugin set that references the four assets is exactly `{han-core, han-coding, han-github, han-reporting}`. A grep of `han-planning/`, `han-atlassian/`, `han-linear/`, `han-feedback/`, and `han-plugin-builder/` for all four asset strings returns zero hits in every one. A grep of `han-core/`, `han-coding/`, `han-github/`, and `han-reporting/` confirms all four have live references. D5's plugin-level inventory holds exactly as claimed — the gaps found in this analysis are all in the **documentation and repo-tooling layer**, not in an uncounted plugin.

One adjacent observation, not raised to a gap because it has no repo-file evidence pair (it is a question about the spec's own internal reasoning, not about repo reality): `han-planning`'s existing `plugin.json` already depends on `han-core`, and `han-core` will depend on `han-communication` after this change. If the plugin loader resolves dependencies transitively — which D5 itself relies on to get `han-communication` to `han-atlassian`/`han-linear`/`han-feedback` through `han-core` — then `han-planning` receives `han-communication` transitively too, the same as the opt-in plugins, even though D5 and Out of Scope both frame `han-planning` as not getting it at all. This is worth a look during implementation planning (OI-1 already flags the transitive-resolution question generally) but is not a file-level repo gap.

## Task Item 3: `../../references/readability-rule.md` and `../../references/writing-voice.md` Sites

**`../../references/readability-rule.md` (or the one-level-deeper `../../../references/...` from a nested template file) — 19 sites in the four consuming plugins, plus 1 in `edit-for-readability` itself, plus 1 in CONTRIBUTING.md:**

1. `han-coding/skills/architectural-analysis/SKILL.md` (4 occurrences)
2. `han-coding/skills/code-overview/SKILL.md` (3 occurrences)
3. `han-coding/skills/code-overview/references/overview-template.md` (1 occurrence)
4. `han-coding/skills/code-review/SKILL.md` (3 occurrences)
5. `han-coding/skills/code-review/references/template.md` (1 occurrence)
6. `han-coding/skills/investigate/SKILL.md` (3 occurrences)
7. `han-core/skills/architectural-decision-record/SKILL.md` (3 occurrences)
8. `han-core/skills/edit-for-readability/SKILL.md` (1 occurrence — not a delegation site, see above)
9. `han-core/skills/gap-analysis/SKILL.md` (4 occurrences)
10. `han-core/skills/issue-triage/SKILL.md` (2 occurrences)
11. `han-core/skills/issue-triage/references/template.md` (1 occurrence)
12. `han-core/skills/project-documentation/SKILL.md` (4 occurrences)
13. `han-core/skills/research/SKILL.md` (3 occurrences)
14. `han-core/skills/research/references/research-report-template.md` (1 occurrence)
15. `han-core/skills/runbook/SKILL.md` (3 occurrences)
16. `han-github/skills/update-pr-description/SKILL.md` (4 occurrences)
17. `han-reporting/skills/html-summary/SKILL.md` (3 occurrences)
18. `han-reporting/skills/html-summary/references/writing-conventions.md` (1 occurrence, as `../../../references/readability-rule.md`)
19. `han-reporting/skills/stakeholder-summary/SKILL.md` (3 occurrences)
20. `CONTRIBUTING.md` (1 occurrence — prose, not a skill; see GAP-004)

**`../../references/writing-voice.md` — 0 sites, anywhere in the repo.** No consuming skill or template reads `writing-voice.md` directly by relative path. Every in-plugin mention of "the writing-voice profile" (in the self-check criterion 5 language repeated across all nine dispatching skills and the four self-check skills) is prose description, not a file read — the only structural file-to-file link to `writing-voice.md` is the one inside each vendored `readability-rule.md` itself (`[writing-voice.md](./writing-voice.md)`, same-directory, line 41 in all four copies), which continues to resolve correctly after the move because D2 moves both files into the same `han-communication/references/` folder together. This means D3's "stop reading the reference files inline" instruction only has to convert `readability-rule.md` read/dispatch sites; it does not need a parallel `writing-voice.md` conversion at each of the 19 sites above. The spec does not state this explicitly, but nothing in the spec contradicts it either — flagged here as a clarification, not a gap.

**All 20 `readability-rule.md` sites above (minus the `edit-for-readability` self-reference) are accounted for in general terms by D3 ("every skill that references any of them... stop reading them inline") and D9 (qualified-name updates for actual dispatch sites). No site in this list is unaccounted for by the spec's general language.** The gaps below are in the layer *outside* this list: templates (GAP-007), long-form docs (GAP-001/002/003), contributor guidance (GAP-004), and repo-local tooling (GAP-005/006).

## Task Item 4: Vendored-Copy Inventory

Confirmed by `find` and `diff`:

- `readability-rule.md` physically exists in exactly four plugins: `han-core/references/readability-rule.md`, `han-coding/references/readability-rule.md`, `han-github/references/readability-rule.md`, `han-reporting/references/readability-rule.md`.
- `writing-voice.md` physically exists in exactly the same four plugins: `han-core/references/writing-voice.md`, `han-coding/references/writing-voice.md`, `han-github/references/writing-voice.md`, `han-reporting/references/writing-voice.md`.
- All four copies of each file are byte-identical (`diff` against the `han-core` copy returns no differences for either file in `han-coding`, `han-github`, or `han-reporting`).

**D3's vendored-copy claim is fully confirmed.** No fifth plugin carries a copy, and no copy has drifted.

## Findings

**GAP-001: `docs/readability.md` carries the highest concentration of stale pointers in the repo, uncounted by D7**
- **Category:** Partial
- **Feature/Behavior:** Documentation must stop pointing at `han-core` as the canonical home of the readability capability once the assets move.
- **Current State:** `docs/readability.md` is the dedicated operator-facing page for the whole capability. It contains at least 13 separate `han-core`-rooted references that will break or mislead after the move: relative links to `./agents/han-core/readability-editor.md` and `./skills/han-core/edit-for-readability.md` (lines 12, 48, 79, 86, 98, 99), a direct statement that "The canonical rule lives in `han-core/references/readability-rule.md`" (line 14) with a matching relative link (line 97) and a parallel writing-voice link (line 103), a full per-skill dispatch table naming `readability-editor` nine times as the thing each skill "dispatches" (lines 59–71) without a plugin qualifier that would need to become `han-communication`, and prose describing the rewrite pass and self-check split (lines 12, 79) that assumes the reader already knows the capability lives in `han-core`.
- **Desired State:** `docs/plans/han-communication-plugin/artifacts/decision-log.md` D7: "the long-form docs for the agent and skill move to `docs/agents/han-communication/` and `docs/skills/han-communication/`; the agent and skill indexes, the CLAUDE.md project map, CONTRIBUTING.md, and every top-level pointer to the canonical location of the readability rule and writing-voice profile update to name `han-communication` as the owner." This clause is broad enough to cover `docs/readability.md` in principle, but neither D7 nor the feature specification names this file, its per-skill table, or its 13 individual sites anywhere.

**GAP-002: Eight consumer skill long-form docs hardcode the `han-core:readability-editor` qualified name in operator-facing prose**
- **Category:** Missing
- **Feature/Behavior:** Documentation describing how a consuming skill dispatches the readability capability must name the capability's post-move qualified name.
- **Current State:** `docs/skills/han-coding/architectural-analysis.md:118`, `docs/skills/han-coding/code-overview.md:97`, `docs/skills/han-coding/code-review.md:128`, `docs/skills/han-coding/investigate.md:82`, `docs/skills/han-core/gap-analysis.md:130`, `docs/skills/han-core/research.md:96`, `docs/skills/han-github/update-pr-description.md:72`, and `docs/skills/han-reporting/stakeholder-summary.md:71` each state in prose that the skill "dispatches ... `han-core:readability-editor`."
- **Desired State:** D9 covers "invocation sites" (the actual `Agent` dispatch code in each `SKILL.md`) moving to the `han-communication:`-qualified name. D7 covers "pointer[s] to the canonical location of the readability rule and writing-voice profile" in docs. Neither clause's stated scope is a doc naming an agent's *qualified name* in explanatory prose about a different skill's own behavior — this is a third category the spec's two doc/invocation clauses don't overlap on.

**GAP-003: `docs/concepts.md:99` links to the pre-move agent doc path**
- **Category:** Partial
- **Feature/Behavior:** Same as GAP-001, on a single site.
- **Current State:** `docs/concepts.md:99` links `readability-editor` to `./agents/han-core/readability-editor.md`.
- **Desired State:** D7's general "every top-level pointer... update[s]" clause; `docs/concepts.md` is not individually named.

**GAP-004: CONTRIBUTING.md's "Vendor the rule" step is a procedural instruction that contradicts D3, not a relabelable pointer**
- **Category:** Divergent
- **Feature/Behavior:** Contributor guidance for wiring the readability standard into a new or existing skill.
- **Current State:** `CONTRIBUTING.md:69` reads: "**Vendor the rule.** The canonical rule is `han-core/references/readability-rule.md`. If the skill ships in a plugin that does not yet carry a copy, copy the file byte-for-byte into that plugin's `references/` directory... Never wire a skill to load the rule before its plugin carries the copy. When the rule changes, update the canonical copy and re-copy it into every plugin that ships an in-scope skill." `CONTRIBUTING.md:71` then instructs: "The skill reads `../../references/readability-rule.md` as it produces output..." This is a step-by-step contributor workflow that prescribes exactly the vendoring pattern D3 eliminates.
- **Desired State:** D3: "Stop vendoring copies into consuming plugins... The single canonical copy of each reference document lives only in `han-communication`." D7 characterizes the needed CONTRIBUTING.md change as updating a pointer "to name `han-communication` as the owner" — language that fits a location relabel, not a rewrite of a multi-step vendoring procedure into a delegation procedure. If CONTRIBUTING.md is only relabeled (the vendored path swapped for a `han-communication` path) rather than restructured, it will keep instructing future contributors to vendor a copy — the exact pattern the feature removes.

**GAP-005: `.claude/skills/han-release/references/changelog-rules.md` hard-references `han-core/references/writing-voice.md` and is outside D5's plugin inventory and D7's doc-scope**
- **Category:** Missing
- **Feature/Behavior:** A repo-local (not plugin-shipped) maintenance skill uses the writing-voice profile as a hard constraint list when generating changelog prose.
- **Current State:** `.claude/skills/han-release/references/changelog-rules.md:126`: "Hard constraints from [`han-core/references/writing-voice.md`](../../../../han-core/references/writing-voice.md), applied verbatim to generated changelog prose:" followed by an inlined copy of several blocklist rules.
- **Desired State:** Neither D5's plugin inventory (which only enumerates `han-core`, `han-coding`, `han-github`, `han-reporting`) nor D7's doc-scope (long-form docs, indexes, CLAUDE.md, CONTRIBUTING.md, top-level pointers) mentions `.claude/skills/`. `.claude/skills/` is repo-local tooling, not a shipped plugin, so it falls outside D5's framing entirely, and D7 does not name it either. Once `han-core/references/writing-voice.md` is deleted, this relative link breaks.

**GAP-006: `.claude/skills/han-update-documentation` hard-references `han-core/references/writing-voice.md` in two places, including its own scope-mapping table**
- **Category:** Missing
- **Feature/Behavior:** The repo's own documentation-audit skill maps changed files to doc entities, and separately states the writing-voice rule as an editing constraint.
- **Current State:** `.claude/skills/han-update-documentation/references/scope-mapping.md:25` has a mapping-table row: `| han-core/references/writing-voice.md | writing-voice |`. `.claude/skills/han-update-documentation/SKILL.md:131` states: "Every edit follows `han-core/references/writing-voice.md`..." Notably, `scope-mapping.md`'s own mapping table explicitly excludes `.claude/skills/**` from the audit's scope ("ignore (repo-local maintenance skills, no plugin docs)"), so nothing in the doc-audit skill's own process would catch that this table row itself has gone stale after the move.
- **Desired State:** Same gap as GAP-005: neither D5 nor D7 names `.claude/skills/` at all.

**GAP-007: Five skill-internal template/reference files hardcode `../../references/readability-rule.md`, a category D7's doc-scope does not name**
- **Category:** Missing
- **Feature/Behavior:** A skill's output template embeds a readability-rule pointer as drafting guidance, separate from the SKILL.md's own dispatch or self-check instructions.
- **Current State:** `han-coding/skills/code-overview/references/overview-template.md:11`, `han-coding/skills/code-review/references/template.md:14`, `han-core/skills/issue-triage/references/template.md:1`, `han-core/skills/research/references/research-report-template.md:8`, and `han-reporting/skills/html-summary/references/writing-conventions.md:11` each read `../../references/readability-rule.md` (or, for the nested `writing-conventions.md`, `../../../references/readability-rule.md`) directly.
- **Desired State:** D7's doc-scope names "the agent and skill indexes, the CLAUDE.md project map, CONTRIBUTING.md, and every top-level pointer." A skill's own `references/*.md` template file is not a doc index, not CLAUDE.md, not CONTRIBUTING.md, and not conventionally a "top-level pointer" (it is skill-internal, loaded at runtime the same way the SKILL.md itself is). D3's "every skill that references any of the four assets" language could be read to cover these by extension (they are references *inside* a skill's directory), but neither decision names template files as a distinct site type, so an implementer working strictly from D7's enumerated list could miss all five.

**GAP-008: `.github/pull_request_template.md` names `han-core/references/writing-voice.md` directly; not individually confirmed in scope**
- **Category:** Implicit
- **Feature/Behavior:** A repo-level contributor-facing checklist item points a PR author at the writing-voice profile.
- **Current State:** `.github/pull_request_template.md:18`: "Confirm the writing follows [`han-core/references/writing-voice.md`](../han-core/references/writing-voice.md)."
- **Desired State:** D7's "every top-level pointer to the canonical location... update[s]" clause is broad enough to plausibly include this file, but the spec is silent on whether `.github/pull_request_template.md` — which sits outside `docs/`, `CLAUDE.md`, and `CONTRIBUTING.md` — was considered. No evidence in the spec confirms or denies it was in scope.

## Areas Needing Separate Analysis

- **`docs/research/*.md` standalone reports** (`docs/research/human-readable-output-standard.md`, `docs/research/artifacts-references-dedupe.md`, and others) reference the four assets. These are narrative research artifacts, not live cross-references, so whether any need a post-move correction (versus staying as a historical snapshot, like the excluded `docs/plans/` folders) needs a content-by-content read this analysis did not perform.
- **Transitive dependency resolution for `han-planning`** (see Task Item 2 note above): whether `han-planning` ends up transitively depending on `han-communication` through `han-core` the same way the opt-in plugins do, and whether that contradicts the spec's framing of `han-planning` as excluded, is a question about the spec's own internal consistency and the plugin loader's real resolution behavior (OI-1), not a repo-file gap. Worth resolving before implementation.
- **`CHANGELOG.md` historical entries** describing the original `readability-editor`/`writing-voice.md` introduction (lines 50–78) were confirmed out of scope by suite convention (append-only history), but this analysis did not verify that convention against `CONTRIBUTING.md`'s changelog rules in depth — a final check before implementation would confirm no changelog-editing exception applies to a relocation this large.

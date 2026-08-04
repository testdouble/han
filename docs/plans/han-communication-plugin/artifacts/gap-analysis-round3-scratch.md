# Gap Analysis Round 3: han-communication Plugin Spec vs. Repo Reality (Post-D7-Five-Class Expansion)

## Comparison Direction

Current state: this repo, as it exists on disk today (the `han-communication-plugin` feature has not been implemented). Desired state: `docs/plans/han-communication-plugin/feature-specification.md` and `docs/plans/han-communication-plugin/artifacts/decision-log.md`, as they stand after D7 was expanded to five classes (relocated docs, inbound links, canonical-location/qualified-name pointers, vendoring instructions/tooling/templates/repo-maintenance skills/standing dependency rule, dependency-graph narration) and after D8 (marketplace + dependency edges + descriptions) and D10 (Codex packaging parity) were added.

Comparison is unidirectional: current state (repo) checked against desired state (spec) for gaps in the spec's change-inventory. This round verifies the D7 five-class expansion is complete and looks for repo surface still outside D7/D8/D10, per the task's four numbered checks. Findings F12–F22 in `review-findings.md` (which closed round 1's GAP-001–008 and round 2's GAP-101–106) were read and are treated as resolved; they are not re-raised here.

## Scope

Comparison areas, matching the task's four checks:
1. A comprehensive repo grep for the four assets (`readability-editor`, `edit-for-readability`, `readability-rule`, `writing-voice`), for dependency-graph narration (`depends on`, `dependency`, `dependencies`, `meta-plugin`), and for every plugin-packaging file (`plugin.json`, `marketplace.json`, `.codex-plugin`, `.agents/plugins`), checked against D7's five classes, D8, and D10.
2. `.agents/plugins/marketplace.json` structure, checked against `.claude-plugin/marketplace.json` and D8/D10.
3. A count of marketplace/catalog/index files that enumerate plugins.
4. Internal consistency of the spec's decision count, evidence-vs-user tally, and anchor resolution.

Excluded, consistent with rounds 1–2 and `docs/plans/CLAUDE.md`: `docs/plans/**` other than `han-communication-plugin` itself, `docs/research/**`, and `CHANGELOG.md`.

## Actors and Modes Observed

Same as round 2: an operator running any prose-producing Han skill; a contributor maintaining the suite; the plugin loader resolving declared dependencies at install time; a Codex operator installing through the separate Codex marketplace/CLI. No new actor or mode surfaced in this round.

## Summary

Compared the han-communication-plugin feature specification and decision log (desired state, with D7's five classes, D8, and D10 all in place) against the repo (current state) across the four task areas: comprehensive asset/dependency-narration/packaging grep, the Codex marketplace file, the marketplace-file count, and internal spec consistency. Direction: current state (repo) checked against desired state (spec).

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 2 | Elements in desired state with no current state correspondence |
| Partial | 1 | Elements present in both but incompletely covered |
| Divergent | 0 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: `/Users/riverbailey/dev/testdouble/han/docs/plans/han-communication-plugin/artifacts/gap-analysis-round3-scratch.md`

## Task 1: Comprehensive Grep — Two Uncovered Dependency-Narration Files, One Uncovered Template Site

Re-ran the four-asset grep (`readability-editor`, `edit-for-readability`, `readability-rule`, `writing-voice`) across the whole repo, excluding `docs/plans/**` (other than this feature), `docs/research/**`, and `CHANGELOG.md`: the file list is unchanged from round 1/round 2's inventory, with one exception — `han-coding/skills/investigate/references/template.md` was not in either prior inventory (see GAP-203).

Re-ran a dependency-narration grep (`depends on`, `dependency`, `dependencies`, `meta-plugin`) across the same scope and cross-checked every hit against D7 clause 5's enumerated list (`CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `docs/concepts.md`, `docs/choosing-a-han-plugin.md`, `docs/how-to/extend-han-with-plugin-dependencies.md`). Two files narrate the plugin dependency graph in prose and are not on that list: `han/README.md` (see GAP-201) and `docs/skills/README.md` (see GAP-202). `docs/agents/README.md` was checked and does not narrate per-plugin dependencies (it groups agents by role, not by plugin, with no "Depends on" sentence). `docs/how-to/build-a-plugin-that-depends-on-han.md` was checked and, unlike its sibling `extend-han-with-plugin-dependencies.md`, contains no "depends on nothing" or similar claim that the move falsifies — its only dependency statements (`han-github` declares `han-core` as a dependency) remain true after the move, so its exclusion from D7 clause 5 is correct, not a gap.

Ran `find . -name plugin.json`, `find . -iname marketplace.json`, and `find . -path "*.agents/plugins*"` across the whole repo. Every `.claude-plugin/plugin.json` is covered by D5 (new `dependencies` entries) and, for the three that narrate dependencies in their `description` field, by D8. Every `.codex-plugin/plugin.json` was read in full: none of the eight existing ones carries a `dependencies` field or a description that narrates dependencies (confirmed by direct read of all eight files), so D10's claim that `han-communication` is the only Codex-packaging addition needed holds — no existing `.codex-plugin/plugin.json` goes stale. Both marketplace files are addressed in Task 2 below.

## Task 2: `.agents/plugins/marketplace.json` — Entry Covered by D10, No Description Field to Go Stale

Read `.agents/plugins/marketplace.json` in full. Its plugin entries carry only `name`, `source`, `policy`, and `category` — no `description` field at all, unlike `.claude-plugin/marketplace.json`, whose entries carry a `description` string mirrored from each plugin's own `plugin.json`. D10's decision text explicitly names `.agents/plugins/marketplace.json` as one of the three surfaces `han-communication` needs ("a `.codex-plugin/plugin.json` manifest, an entry in the Codex marketplace catalog (`.agents/plugins/marketplace.json`), and a line in the README's Codex install instructions"), so the new-entry need is covered.

**Confirmed, no gap:** D8 covers `.claude-plugin/marketplace.json`'s entry-plus-description update; D10 covers `.agents/plugins/marketplace.json`'s entry addition. Because the Codex marketplace file structurally carries no description field, there is no parallel "update descriptions" obligation for it to miss — D8's description-update clause simply does not apply to a file with no description field. Together, D8 and D10 fully account for both marketplace files.

One adjacent, pre-existing observation with no repo-file gap attached: `.agents/plugins/marketplace.json` is already missing a `han-linear` entry (confirmed: 8 entries — `han-core`, `han-planning`, `han-coding`, `han-github`, `han-reporting`, `han-feedback`, `han-atlassian`, `han-plugin-builder` — no `han-linear`, consistent with `han-linear` also lacking a `.codex-plugin/plugin.json`, as round 2 noted). This is unrelated to the `han-communication` move and out of scope for this plan.

## Task 3: Exactly Two Marketplace Files; No Other Plugin-Enumerating Catalog Found

`find . -iname marketplace.json` returns exactly two files: `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`. No third marketplace, registry, or catalog file exists.

Checked for other files that enumerate the plugin family and could need a `han-communication` row: `docs/choosing-a-han-plugin.md` (already in D7 clause 5), `docs/skills/README.md` and `docs/agents/README.md` (skill/agent indexes grouped by plugin — already generally in D7 clause 2's "agent and skill indexes" scope for the two relocating docs' links, but see GAP-202 for the separate dependency-narration sentences in `docs/skills/README.md`), `README.md` (root, in D7 clause 5), and `han/README.md` (not in D7 clause 5 — see GAP-201). No `docs/plugins/` index or similar directory exists.

**Confirmed:** exactly two marketplace files, both accounted for by D8/D10 per Task 2. No third catalog/index file enumerates plugins for install purposes; the two prose indexes that enumerate plugins for narrative purposes (`docs/choosing-a-han-plugin.md`, `docs/skills/README.md`) are one already in scope and one newly flagged (GAP-202).

## Task 4: Internal Counts and Cross-References — Consistent, No Discrepancy Found

- **Decision count:** the spec's Summary states "Decisions settled by evidence: 7" + "Decisions settled by user input: 3" = 10. `decision-log.md` contains exactly 10 decisions: 3 trivial (D6, D8, D9) + 7 full (D1–D5, D7, D10). The total matches.
- **Evidence-vs-user split:** D3, D4, and D5 each contain an explicit "The user chose..." / "The user directed..." sentence in their Rationale, framing them as decisions resolved by user preference between named rejected alternatives. The remaining seven (D1, D2, D6, D7, D8, D9, D10) are framed by evidence, findings citations (F6–F10, F13–F18, F21, F22), or mechanical consequence of an earlier decision, even where their Evidence field also cites "user input" as context. This 3-vs-7 split is consistent with the spec's stated tally; no miscount found.
- **Anchor resolution:** every `[D1]`–`[D10]` anchor in `feature-specification.md` (`artifacts/decision-log.md#d1-...` through `#d10-...`) resolves to a real `###` heading in `decision-log.md`. No `[OI]` anchor exists anywhere in the current `feature-specification.md` (the Open Items section reads "None," and `OI-1` was closed and removed per the F13/D5 update). No dangling anchor found.

**Confirmed, no gap.**

## Findings

**GAP-201: `han/README.md` narrates the meta-plugin's dependency set and is outside D7's five classes**
- **Category:** Missing
- **Feature/Behavior:** Documentation that names which plugins the `han` meta-plugin depends on must reflect the new `han-communication` dependency edge D5/D6 add.
- **Current State:** `han/README.md:3`: "Installing it pulls in the whole suite through its dependencies: [`han-core`](../han-core) ... and [`han-github`](../han-github) ... Install this one when you want all of Han in a single step." Line 9 also calls `han` "one of three options." This is the meta-plugin's own README, distinct from the root `README.md` — it is already stale before this feature (it omits `han-planning`, `han-coding`, and `han-reporting` from `han`'s actual dependency array), but that pre-existing staleness does not exempt it from the new `han-communication` edge; if anything it means the file is the kind of dependency-narrating prose D7 clause 5 is meant to catch.
- **Desired State:** `decision-log.md` D7 clause 5 lists exactly six files as needing dependency-graph-narration updates: `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `docs/concepts.md`, `docs/choosing-a-han-plugin.md`, and `docs/how-to/extend-han-with-plugin-dependencies.md`. `han/README.md` is not one of them, and no other decision (D5, D6, D8, D10) names it either.

**GAP-202: `docs/skills/README.md`'s per-plugin "Depends on X" sentences are outside D7's five classes**
- **Category:** Missing
- **Feature/Behavior:** Same underlying concern as GAP-201 and round 2's GAP-101/105 (dependency-graph narration going stale), on the skills index specifically.
- **Current State:** `docs/skills/README.md` states, per plugin section: line 55 ("Depends on `han-core`; bundled by the `han` meta-plugin." for `han-planning`), line 65 (same, for `han-coding`), line 78 ("Depends on `han-core`." for `han-github`), line 86 (same, for `han-reporting`), line 93 (same, for `han-feedback`), line 99 ("Depends on `han-core`, `han-planning`, and `han-coding`..." for `han-atlassian`), line 110 (same as 78, for `han-linear`), and line 116 ("It depends on nothing" for `han-plugin-builder`). Five of these plugins (`han-core` implicitly, `han-coding`, `han-github`, `han-reporting`, `han-atlassian`) gain a `han-communication` dependency under D5/D6 and will be under-stated here once that happens.
- **Desired State:** D7 clause 2 names "the agent and skill indexes" only for repointing inbound links to the two relocating long-form docs (`readability-editor`, `edit-for-readability`), not for updating each plugin section's dependency-narrating sentence. D7 clause 5's six-file list (see GAP-201) does not include `docs/skills/README.md` either. No decision covers this file's per-plugin "Depends on" text.

**GAP-203: A sixth-plus skill-internal template site hardcodes the rule's location in a non-relative-path form, missed by every prior inventory**
- **Category:** Partial
- **Feature/Behavior:** A skill's output template embeds a pointer to the readability rule's location as drafting guidance — the same concern D7 clause 4 names for the five (now six, per F16) template/reference files that hardcode `../../references/readability-rule.md`.
- **Current State:** `han-coding/skills/investigate/references/template.md:5`: "Readability: write prose regions against the readability rule the skill loads (`han-coding/references/readability-rule.md`)." This is a plugin-root-qualified path (no `../` segments), not the dot-relative form (`../../references/readability-rule.md`) that every other template site in the inventory uses and that D7 clause 4's phrase "hardcodes the rule's relative path" literally describes. This file was not in round 1's original five-file GAP-007 list, and it was not the "sixth" file F16 added (F16's sixth was `html-summary/references/writing-conventions.md`, which was already present in round 1's five) — meaning this specific site has not appeared in any inventory pass, including the review team's own correction.
- **Desired State:** D7 clause 4: "every skill-internal template and reference file that hardcodes the rule's relative path (including `han-reporting/skills/html-summary/references/writing-conventions.md`, which sits one directory deeper) ... are updated to the new home or the delegation model." The clause's count-free "every" language plausibly sweeps this file in by intent, but its illustrative phrasing is anchored to the dot-relative path pattern, and this site uses a different path form and was never actually identified by any review pass to date — leaving a strict implementer working from the named examples at risk of missing it.

## Areas Needing Separate Analysis

- **`docs/skills/README.md`'s parallel "which plugin do you need?" role alongside `docs/choosing-a-han-plugin.md`** — both files narrate per-plugin dependencies for an overlapping but not identical plugin set; whether they should be reconciled into one canonical source (rather than each independently gaining a `han-communication` mention) is a documentation-architecture question outside this gap analysis's remit.
- **`han/README.md`'s pre-existing staleness** (omits `han-planning`, `han-coding`, `han-reporting` from `han`'s dependency list; calls `han` "one of three options" when there are now nine sibling plugins) is a defect independent of this feature. GAP-201 flags only the incremental `han-communication` omission this feature would add to that existing gap, not the pre-existing gap itself.

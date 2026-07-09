# Gap Analysis Round 4: han-communication Plugin — Revised Plan (D11 Staged Guidance-Plus-Editor Model)

## Comparison Direction

Current state: this repo, as it exists on disk today (the `han-communication-plugin` feature has not been implemented; commit `17f4b4c` is the revision under review). Desired state: `docs/plans/han-communication-plugin/feature-specification.md` and `docs/plans/han-communication-plugin/artifacts/decision-log.md` as they stand **after** the revision that replaced full delegation with the staged guidance-plus-editor model (D3/D4 reframed, D11 added, OI-3 added).

Comparison is unidirectional: current state (repo) checked against desired state (revised plan) for gaps the revision does not yet account for. Two findings (GAP-301, GAP-304) are internal-consistency checks within the desired state itself (decision-log.md's own cross-references and the spec's Summary tally against decision-log.md's actual content) — reported as Divergent because two parts of the desired state address the same concern in incompatible ways. Findings F12–F35 (review-findings.md) and round 1–3 findings (gap-analysis-scratch.md, round2, round3) are treated as resolved and are not re-raised.

## Scope

Comparison areas, matching the task's five checks:
1. New-skill surface for `readability-guidance` (SKILL.md, long-form doc, skills index, CLAUDE.md/concepts.md/readability.md mentions).
2. The rewiring of all 13 consumer SKILL.md files' drafting sections (and the sites beyond "drafting section" that also hardcode the rule).
3. `docs/readability.md`'s staged-model description and its "self-check only" table under the preserved (not collapsed) staged model.
4. Codex/marketplace surface for a new skill inside an already-covered plugin.
5. Internal consistency of decision anchors and counts after the revision.

Excluded, consistent with rounds 1–3 and `docs/plans/CLAUDE.md`: `docs/plans/**` other than `han-communication-plugin` itself, `docs/research/**`, and `CHANGELOG.md`.

## Actors and Modes Observed

Same as round 3: an operator running any prose-producing Han skill; a contributor maintaining the suite; the plugin loader resolving declared dependencies at install time; a Codex operator installing through the separate Codex marketplace/CLI. No new actor or mode surfaced in this round; the revision adds a new **mode of sourcing** (a same-context skill invocation of `readability-guidance` at drafting time) rather than a new actor.

## Summary

Compared the revised han-communication-plugin feature specification and decision log (desired state, with D3/D4 reframed and D11 added for the staged guidance-plus-editor model) against the repo (current state) across the task's five areas. Direction: current state (repo) checked against desired state (revised plan); two findings additionally check the revised desired state against itself for internal consistency.

| Category | Count | Description |
|----------|-------|-------------|
| Missing | 1 | Elements in desired state with no current state correspondence |
| Partial | 1 | Elements present in both but incompletely covered |
| Divergent | 3 | Elements addressing same concern in incompatible ways |
| Implicit | 0 | Assumed capabilities neither confirmed nor denied |

Full analysis written to: `/Users/riverbailey/dev/testdouble/han/docs/plans/han-communication-plugin/artifacts/gap-analysis-round4-scratch.md`

## Task 1: New-Skill Surface — Mostly Covered; One Convention List Falls Outside D7's Grep Patterns

D1 commits to creating the `readability-guidance` SKILL.md ("hosts the four moved assets plus a new `readability-guidance` skill (D11)"), and D11's own "Documentation" bullet explicitly commits to a long-form doc under `docs/skills/han-communication/` and an entry in the skills index. `docs/concepts.md`'s plugin-family narrative (`docs/concepts.md:119-131`) is explicitly named in D7 clause 5's file list, and it already contains "depends on"/"depends on nothing" phrasing D7's grep pattern (d) catches, so it is covered for the new plugin's dependency edge (though not specifically for naming the new skill, which is not a dependency-graph concern).

One site is not caught: `CLAUDE.md:108`'s "Indexes stay complete, not counted" convention bullet enumerates every plugin's `skills/` directory by name ("Every skill in `han-core/skills/`, `han-planning/skills/`, ..., and `han-plugin-builder/skills/` has a long-form doc..."). This line contains none of D7's four grep-seed patterns — no dependency-narration phrase (`depends on`, `bundled by`, `pulls in`, `depends on nothing`), no asset string, no qualified name, no path to `readability-rule.md`/`writing-voice.md` — so the comprehensive-grep method D7 mandates would not surface it, and no other decision names it. See GAP-303.

## Task 2: The 13 Rewired Consumers — Count Accurate, but the Editor's Rule-Path Parameter Mechanism Is Unresolved

Re-verified the 13-consumer count directly against the repo: `architectural-analysis`, `code-overview`, `code-review`, `investigate` (han-coding); `architectural-decision-record`, `gap-analysis`, `issue-triage`, `project-documentation`, `research`, `runbook` (han-core); `update-pr-description` (han-github); `html-summary`, `stakeholder-summary` (han-reporting) = 13, excluding `edit-for-readability` (a moved asset, not a consumer) and `.claude/skills/han-update-documentation/SKILL.md` (a repo-maintenance skill already in D7 clause 4's separate bucket). The count in D4 ("All thirteen consumer skills") and D11 ("across all thirteen consumers") is honest.

Reading each SKILL.md's drafting-stage lines confirms D7's grep pattern (c) will catch and let an implementer rewire the *drafting-stage* touchpoint D11 names (for example `han-core/skills/research/SKILL.md:29`).

But 9 of the 13 also carry a *second*, distinct touchpoint: an explicit **rule-path parameter** passed to the editor at dispatch time (for example `han-core/skills/research/SKILL.md:129`: "Pass it the report file path, the readability rule path `../../references/readability-rule.md`..."; the same pattern repeats in `gap-analysis`, `project-documentation`, `code-overview`, `architectural-analysis`, `update-pr-description`, `stakeholder-summary`, `code-review`, `investigate`). This is not a documentation pointer — it is a **behavioral parameter** the calling skill must supply so the editor (dispatched via the `Agent` tool, a separate-context subagent, not a same-context `Skill` invocation) knows where to read the rule. D3's own rationale establishes "no supported way for a skill to read a *file* inside a declared dependency plugin" and that only same-context `Skill`-tool invocations solve that (which is exactly why D11 built `readability-guidance` for the *drafting* stage). The editor is dispatched via `Agent`, not `Skill`, so it gets none of that same-context benefit — yet D9 states "the invocation contract is otherwise unchanged," implying the caller still supplies a rule-path parameter. Once vendored copies are removed (D3), a caller in `han-core` (etc.) has no valid path to supply: the file no longer exists in its own plugin tree, and no cross-plugin path mechanism exists (D3's own claim). No decision states whether the editor now resolves its own canonical copy internally (dropping the caller-supplied parameter) or receives some other cross-plugin-safe reference. See GAP-302.

A secondary, lower-severity observation: D11's documentation bullet says only that the consumer skill's "**drafting** section is rewired." Each of the 13 files also carries a self-check touchpoint in a separate section (for example `han-core/skills/research/SKILL.md:131`) that independently reads `../../references/readability-rule.md`. D7's comprehensive grep will still catch these by pattern (c), so this is unlikely to be missed in practice, but D11's own scope language ("drafting section") under-describes the edit surface. See GAP-305.

## Task 3: docs/readability.md — The Self-Check-Only Table Stays True Under the Revision, but D7's Own Rationale Text Was Not Updated to Say So

Read `docs/readability.md:57-71` in full. Its "Scope: which skills are reader-facing" table currently lists `issue-triage`, `runbook`, and `architectural-decision-record` as "Self-check only" and `html-summary` as "Self-check only (prose content; visual layout keeps its own conventions)" — exactly four rows. D4 (current, post-revision) explicitly names the same four skills as the ones that "run no rewrite, as today." **The table is true under the revision** — this is a confirmed no-gap for the table's own content.

However, D7 clause 3 (decision-log.md:120) still reads: `docs/readability.md` "restates ... the pre-delegation staged-application model (including a 'self-check only' table for issue-triage, runbook, ADR, and html-summary **that D4 falsifies**)". That clause was written when D4 meant full delegation (which genuinely did collapse the table, per F32). The revision rewrote D4 to preserve the staged model — the table is no longer falsified by D4, it is *confirmed* by D4. D7's rationale sentence was not updated when D3/D4 were reframed, so the decision log now asserts something about its own dependency (D4) that D4's current text contradicts. An implementer reading D7 literally would be told to rewrite `docs/readability.md`'s table away as false, when the correct action is to keep the table and instead rewrite only the *sourcing* description (vendored file → `readability-guidance` invocation) around it. See GAP-301.

## Task 4: Codex + Marketplace — No Gap; New Skill Adds No Manifest Surface Beyond the Plugin-Level Entry D10/D8 Already Cover

Read a `.codex-plugin/plugin.json` sample (`han-core`, `han-feedback`, `han-coding`, `han-atlassian`): each carries `"skills": "./skills/"` — a directory pointer, not a per-skill enumeration — plus plugin-level `name`/`description`/`interface` fields. Read `.agents/plugins/marketplace.json`'s `han-core` entry: `name`, `source`, `description`, `version` — again plugin-level, no per-skill listing. `.claude-plugin/marketplace.json` entries are likewise plugin-level.

Because both Codex-surface files (`.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`) and both Claude Code marketplace/plugin files operate at plugin granularity, adding `readability-guidance` inside the already-covered `han-communication` plugin (D10 for Codex, D8 for the Claude Code marketplace) requires no additional manifest entry, field, or file beyond what D8/D10 already commit to creating for the plugin as a whole. **Confirmed, no gap.**

## Task 5: Internal Consistency — Decision Anchors Resolve, but the Evidence/User-Input Tally No Longer Matches decision-log.md's Content

**Anchor resolution:** every `[D1]`–`[D11]` anchor in `feature-specification.md` resolves to a real `###` heading in `decision-log.md` (`grep -n "^### D"` returns exactly D1–D11, 11 headings; 3 trivial — D6, D8, D9 — plus 8 full — D1–D5, D7, D10, D11). **Confirmed, no gap.**

**Decision count:** the spec's Summary states "Decisions settled by evidence: 7" + "Decisions settled by user input: 4" = 11, matching the 11 headings. The *total* is right.

**Evidence-vs-user split is now wrong.** `git show 17f4b4c` (the revision commit) shows the user-input count was bumped from 3 to 4 with no change to the evidence count (7 → 7), implying the newly added D11 was counted as the fourth user-input decision. But a full-file grep for "user" in the current `decision-log.md` shows only three decisions mention "user" at all — D1 (Rationale: "The user asked for a dedicated plugin"), D2 (Evidence field only: "user input"), and D5 (Rationale: "The user directed that any plugin relying on `han-communication` declare it directly"). **D11 contains zero "user" mentions** — its Rationale is "This is the mechanism that makes D3/D4 possible with existing runtime features. It reuses the one supported cross-plugin composition primitive..." — entirely evidence-framed, not a decision resolved by user preference between alternatives.

Worse, the same revision commit *removed* the "user chose" framing from D3 and D4, which round 3's own audit had correctly classified as user-input decisions pre-revision: the diff shows D3's old Rationale ("The user chose delegation over keeping vendored copies") replaced by a purely evidence-framed paragraph, and D4's old Rationale ("The user chose full delegation for the strongest single source of truth") replaced by a purely evidence-framed paragraph citing `docs/readability.md`'s own rules. Applying round 3's own classification test (an explicit "the user chose/directed" sentence in the Rationale) to the current file finds **only D1 and D5** with such language in Rationale (D2's is Evidence-field-only, consistent with round 3 counting D2 as evidence). That yields at most 2 user-input decisions today, not 4, with evidence correspondingly higher than 7 — the tally was not recalculated after the same commit both rewrote D3/D4's rationale and added D11. See GAP-304.

## Findings

**GAP-301: D7's rewrite-depth rationale for `docs/readability.md` still claims the self-check-only table is "falsified," which the revised D4 no longer does**
- **Category:** Divergent
- **Feature/Behavior:** The instruction an implementer follows when rewriting `docs/readability.md`'s staged-application description and its per-skill rewrite-pass table.
- **Current State:** `docs/readability.md:57-71`'s "Scope" table lists `issue-triage`, `runbook`, `architectural-decision-record` (self-check only) and `html-summary` (self-check only, prose) — unchanged on disk, still four rows.
- **Desired State:** `decision-log.md` D7 clause 3 (line 120) says `docs/readability.md` "restates... the pre-delegation staged-application model (including a 'self-check only' table for issue-triage, runbook, ADR, and html-summary that D4 falsifies)." `decision-log.md` D4 (lines 85-99, current/post-revision) instead *preserves* that exact four-skill table: "The four draft-and-self-check-only skills (issue-triage, architectural-decision-record, runbook, html-summary) run no rewrite, as today." D7's clause was written against the pre-revision D4 (full delegation, which genuinely falsified the table per F32) and was not updated when D3/D4 were reframed by the same commit that added D11.

**GAP-302: No decision states how the readability-editor obtains the rule text once vendored copies are removed and the caller can no longer supply a valid rule-path parameter**
- **Category:** Divergent
- **Feature/Behavior:** The editor-dispatch mechanism for the 9 synthesis skills among the 13 consumers.
- **Current State:** `han-core/skills/research/SKILL.md:129` (representative of 9 sites: `gap-analysis:195`, `project-documentation:107`, `code-overview:134`, `architectural-analysis:144`, `update-pr-description:129`, `stakeholder-summary:91`, `code-review:400`, `investigate:79`) instructs the calling skill to "Pass it... the readability rule path `../../references/readability-rule.md`" when dispatching the editor. `han-core/agents/readability-editor.md:10` frames this as caller-supplied: "You will receive the path to a draft file... and the shared readability rule."
- **Desired State:** `decision-log.md` D3 (lines 70-83) establishes "the plugin runtime has no supported way for a skill to read a *file* inside a declared dependency plugin" and that only same-context `Skill`-tool invocation (the basis for D11's `readability-guidance`) solves that constraint. `decision-log.md` D9 (lines 31-37) states "the invocation contract is otherwise unchanged" for the editor dispatch — implying the caller-supplied rule-path parameter persists — without reconciling that claim against D3's constraint, since the editor is dispatched via the `Agent` tool (a separate-context subagent), not the `Skill` tool D11's mechanism relies on. No decision states whether the editor now resolves its own canonical copy internally or the caller passes something else.

**GAP-303: CLAUDE.md's "Indexes stay complete, not counted" convention enumerates every plugin's skills directory by name and is not caught by D7's four grep patterns**
- **Category:** Missing
- **Feature/Behavior:** The completeness convention that every plugin's `skills/` directory has a matching long-form doc and skills-index entry.
- **Current State:** `CLAUDE.md:108`: "Every skill in `han-core/skills/`, `han-planning/skills/`, `han-coding/skills/`, `han-github/skills/`, `han-reporting/skills/`, `han-feedback/skills/`, `han-atlassian/skills/`, `han-linear/skills/`, and `han-plugin-builder/skills/` has a long-form doc in `docs/skills/` and an entry in the skills index... Verify the indexes list every entity when editing them, rather than tracking a running total." No mention of `han-communication/skills/`, and no dependency-narration, asset-name, qualified-name, or rule-path phrase appears in the line for D7's grep to catch.
- **Desired State:** `decision-log.md` D7's "Method" (lines 123) scopes the comprehensive grep to four seed patterns: (a) the four asset strings, (b) the old qualified names, (c) paths to `readability-rule.md`/`writing-voice.md`, (d) dependency-narration phrasing (`depends on`, `bundled by`, `pulls in`, `depends on nothing`). This convention-list enumeration matches none of the four.

**GAP-304: The spec's Summary evidence/user-input tally (7/4) does not match decision-log.md's actual content after the revision**
- **Category:** Divergent
- **Feature/Behavior:** Internal consistency between the spec's Summary counts and the decision log's decision-by-decision rationale.
- **Current State:** N/A (this is a desired-state-vs-desired-state check; see Desired State for both sides).
- **Desired State:** `feature-specification.md:93` states "Decisions settled by user input: 4"; `feature-specification.md:92` states "Decisions settled by evidence: 7." `decision-log.md`, re-audited in full, shows explicit user-directed Rationale language only in D1 and D5 (D2's "user input" appears in its Evidence field only); D3 and D4's Rationale text was rewritten by the same commit (`17f4b4c`) that added D11 to remove all "the user chose/directed" language, replacing it with evidence/research framing; D11's own Rationale ("This is the mechanism that makes D3/D4 possible with existing runtime features...") contains no user-directed language either. The 3→4 user-input bump in that commit's diff lands on D11 (evidence-framed) while D3 and D4 (previously the other two of the three user-input decisions) lost their user framing in the same diff — the tally was not recalculated to reflect either change.

**GAP-305: D11's "drafting section is rewired" language under-describes the edit surface; the self-check touchpoint sits in a separate section of the same 13 files**
- **Category:** Partial
- **Feature/Behavior:** The scope of the SKILL.md edits the D11 "Documentation" bullet claims for the new sourcing mechanism.
- **Current State:** `han-core/skills/research/SKILL.md:131` (representative of all 13 consumers) reads the rule again in a self-check step located well after the drafting-stage line D11 describes: "Run the standardized readability self-check from `../../references/readability-rule.md` over the report's prose regions..." This is a separate touchpoint from the drafting-stage line D11 names.
- **Desired State:** `decision-log.md` D11's "Documentation" bullet (line 159) says only: "every consumer skill's **drafting section** is rewired from 'read the vendored rule file' to 'invoke `han-communication:readability-guidance`'." It does not name the self-check section as part of that rewire, though D7's comprehensive-grep method (which does catch the self-check line via pattern (c), a literal path string) makes the omission low-risk in practice rather than a functional miss.

## Areas Needing Separate Analysis

- **Whether `readability-guidance`'s single invocation genuinely persists usable self-check criteria in context through to the end of a long synthesis skill run** (OI-3's prototype gate) — this is an operational/reliability question the plan already defers to a `plan-implementation` spike, not a documentation-inventory gap; noted here only because GAP-302 and GAP-305 both touch the same "does content actually survive to the later section" mechanic from a different angle (the editor's separate-context dispatch vs. the guidance skill's same-context persistence).
- **Whether the editor agent should be redesigned to self-resolve its own canonical copy** (one candidate resolution to GAP-302) is an implementation-mechanism decision outside this gap analysis's remit — flagged as an open question, not resolved here.

# Verification: Change Plan Surface Delta vs. Ground Truth

## Comparison Direction

Current state: `docs/plans/gh-200-docs-consistency/change-plan.md#surface-delta`, entries S-1 through S-6, each pinning
exact replacement text. Desired state: the ground truth those entries claim to describe — `arguments: size` and
`## Sizing` sections across `han-*/skills/*/SKILL.md` and `han-*/docs/skills/{name}.md`, the `dependencies` arrays in
`han-*/.claude-plugin/plugin.json`, the live text at each named edit site, and the three asks in GitHub issue
testdouble/han#200 as quoted in `artifacts/scope-boundary.md#stated-scope`.

## Scope

Six delta entries (S-1–S-6), the 13/14-skill sizing membership, the `han-reporting` dependency claim, the banner alt
text, and line-length compliance. Excluded: the Change Units, Risks, and Deferred sections (process framing, not
pinned text); `docs/sizing.md` (out of scope per `scope-boundary.md`, verified correct by C-3/C-4 already).

## Actors and Modes Observed

Three reader roles the desired state implies, none stated as formal personas: a prospective adopter reading
`docs/quickstart.md` / `docs/concepts.md` / `docs/choosing-a-han-plugin.md` to pick an install; a contributor following
`CONTRIBUTING.md`'s numbered checklist when adding a skill; a screen-reader or no-image reader of `README.md` (the
subject of S-6). No API, agent, or batch surface — this is prose documentation with no runtime.

## Summary

Compared the change plan's six pinned Surface Delta entries against their live edit sites, the skill/plugin manifests,
and issue #200's three asks (current state: `change-plan.md#surface-delta`; desired state: the manifests, live files,
and issue text named above). All 13 skill names, alphabetical order, and link targets in the executable entries are
correct, all three issue asks are covered, and every pinned line is under 120 columns. Four gaps found, none in the
pinned text content itself.

| Category  | Count | Description                                                    |
| --------- | ----- | -------------------------------------------------------------- |
| Missing   | 1     | Elements in desired state with no current state correspondence |
| Partial   | 3     | Elements present in both but incompletely covered              |
| Divergent | 0     | Elements addressing same concern in incompatible ways          |
| Implicit  | 0     | Assumed capabilities neither confirmed nor denied              |

Full analysis written to: `/Users/riverbailey/dev/testdouble/han/docs/plans/gh-200-docs-consistency/artifacts/verification-gaps.md`

## Findings

**GAP-001: S-2 pins no exact replacement text, unlike every other entry**

- **Category:** Partial
- **Severity:** High
- **Feature/Behavior:** The plan's own convention that every Surface Delta entry commits to exact wording.
- **Current State:** `change-plan.md:122-134` (S-2). The "Target state" is prose only: "It differs from today by one
  entry: `/ddd-analysis`, linked to `../han-ddd/docs/skills/ddd-analysis.md`, inserted between `/code-walkthrough` and
  `/design-an-api`." No fenced block follows, unlike S-1 (`change-plan.md:106-111`), S-3 (`:140-143`), S-4
  (`:158-162`), S-5 (`:176-181`), and S-6 (`:200-202`), each of which pins a `markdown or `html block.
- **Desired State:** `change-plan.md:94-97`, the "Pinned replacement text" preamble: "Every entry below commits to
  exact text, because the value of this plan is the wording and not the intent behind it." That standard is the
  desired state for every entry in the section it introduces.
- **Note:** The insertion point itself checks out — `ddd-analysis` sorts correctly between `code-walkthrough` and
  `design-an-api`, and `../han-ddd/docs/skills/ddd-analysis.md` resolves from `docs/concepts.md` (the file exists at
  `han-ddd/docs/skills/ddd-analysis.md`). What's missing is the exact markdown for the other 12 entries' links and
  punctuation, which cannot be checked because no pinned text exists to check.

**GAP-002: Every Decision citation across all six entries points into an empty file**

- **Category:** Missing
- **Severity:** High
- **Feature/Behavior:** The recorded rationale (D-1 through D-5) that the plan cites as grounding each pinned text
  choice — most directly D-3 for S-3/S-4's exact wording and D-4 for S-6's exact alt text.
- **Current State:** `docs/plans/gh-200-docs-consistency/artifacts/change-decision-log.md` is 0 bytes (confirmed via
  `ls -la` on the artifacts directory). Every `**Decision.**` line in S-1 through S-6 (`change-plan.md:120`, `:134`,
  `:152`, `:170`, `:194`, `:210`) and the "Target State" section's D-1/D-3/D-4/D-5 references (`change-plan.md:65`,
  `:82`, `:86`, `:90`) link into this file by heading anchor.
- **Desired State:** `change-plan.md:94`: exact text is pinned "because the value of this plan is the wording and not
  the intent behind it" — implying the intent is recorded somewhere a reader can check it. The change-plan text treats
  D-1 through D-5 as already-written content (e.g., "reject alternative recorded in D-1", `change-plan.md:329`).
- No decision content exists anywhere in the repository under that name; this is not a stale link, the file has never
  been populated.

**GAP-003: S-1's underlying line citation undercounts the sentence it replaces by one line**

- **Category:** Partial
- **Severity:** Low
- **Feature/Behavior:** The location citation used to identify the edit site for S-1.
- **Current State:** `docs/quickstart.md:196-198` (confirmed by direct read): the sentence S-1 replaces runs "The
  sizing-aware skills (...) classify the work as **small**," (196) / "**medium**, or **large** before dispatching
  agents." (198) — three lines, not two.
- **Desired State:** `current-state-findings.md:71` (C-1's own Location field): `docs/quickstart.md:196-197`, which the
  task brief inherited. The two-line citation stops before "**medium**, or **large** before dispatching agents.",
  which is on line 198.
- **Note:** This does not affect the pinned text itself — S-1's replacement block correctly reproduces the full
  sentence through "dispatching agents." — only the location pointer a builder would use to find the lines to delete.

**GAP-004: S-6's alt text lowercases "solo" where the banner's rendered text capitalizes "Solo"**

- **Category:** Partial
- **Severity:** Low
- **Feature/Behavior:** The alt text's fidelity to what a sighted reader receives from the image, which is the target
  state's own stated test (`change-plan.md:88-90`: the alt text "carries... the one-line identity the banner renders,
  which is what a sighted reader gets from it at that position").
- **Current State:** `images/han-banner.png`, read directly: the tagline renders as two lines, "your agentic ally for"
  / "Solo product engineers", with "Solo" capitalized and set in a different color than the surrounding text —
  confirmed independently of `current-state-findings.md` C-11, which quotes the same rendered text.
- **Desired State:** `change-plan.md:201` (S-6's pinned block): `alt="Han: your agentic ally for solo product
engineers"` — lowercase "solo".
- **Note:** This is a stylistic, not a factual, mismatch — "Solo" is plausibly a design accent (color/weight) on the
  banner rather than a claim about capitalization, and ordinary English prose would lowercase the word mid-sentence.
  Recorded because the target state names verbatim fidelity to the rendered image as its own success criterion, and
  the rationale that would settle the question (D-4) is unavailable — see GAP-002.

## Checks That Passed (evidence of no gap)

- **S-1 and S-2 membership.** All 13 names in S-1 (`change-plan.md:106-110`) match skills that both declare
  `arguments: size` and carry a `## Sizing` section: confirmed by grep over `han-*/skills/*/SKILL.md` frontmatter (14
  matches) and by grep for `^## Sizing` over each of those 14 skills' long-form docs (13 matches; the 14th,
  `plan-a-feature-to-confluence`, correctly has none). Alphabetical order in S-1 verified by direct inspection.
  S-2's one spelled-out addition (`ddd-analysis`) is correctly placed and its link resolves (see GAP-001 for what
  could not be checked).
- **S-1 clause preservation.** `docs/quickstart.md:198-200`, the three sentences following the replaced one ("They
  default to small...", "Pass the size...", "See Sizing...") are untouched by S-1's pinned block, which ends at
  "dispatching agents." — the same point the original sentence ends. Nothing is dropped.
- **S-3 against live text.** `docs/choosing-a-han-plugin.md:84` today reads "That means **every layer install comes
  with the shared agents.**"; S-3's replacement inserts "except `han-reporting`" and preserves "The real choice comes
  down to:" verbatim. The parenthetical two lines above (`:82`) already states the exception and needs no change.
- **S-4's factual claim.** `han-reporting/skills/` contains exactly `html-summary` and `stakeholder-summary`, matching
  the `/html-summary` and `/stakeholder-summary` named in S-4. `han-reporting/.claude-plugin/plugin.json:6`:
  `"dependencies": ["han-communication"]` — no `han-core` — matching the claim.
- **S-5 against live text.** `CONTRIBUTING.md:194-197` today names only Sizing and Concepts; S-5 inserts "to the
  sizing-aware list in [Quickstart](./docs/quickstart.md)," and preserves the rest verbatim. The link resolves
  (`CONTRIBUTING.md` is at repo root; `docs/quickstart.md` exists).
- **S-6 HTML well-formedness and Prettier compliance.** Built the pinned tag into a scratch markdown file and ran
  `npx prettier --check` under this repo's `.prettierrc.json` (`printWidth: 120`, `proseWrap: "preserve"`): Prettier
  reports it already conforms and does not rewrite attribute order or quoting.
- **Issue coverage.** All three asks in `scope-boundary.md#stated-scope` are addressed: ask 1 (add `/design-an-api` to
  the quickstart list) by S-1 (widened to four skills, per the plan's own recorded correction); ask 2 (scope the bold
  claim; drop `reporting-only`) by S-3 and S-4, using the issue's exact suggested phrasing for S-3; ask 3 (banner alt
  text) by S-6.
- **Line length.** Every pinned fenced block's longest line is under 120 columns: S-1 119, S-3 118, S-4 118, S-5 119,
  S-6 89 (measured directly from the fenced blocks in `change-plan.md`).

## Areas Needing Separate Analysis

- **The empty `change-decision-log.md` (GAP-002).** Whether D-1 through D-5 were ever drafted and lost, or never
  written, is a provenance question this pass cannot answer from the files present. Worth a direct question to
  whoever ran the planning skill before this plan is executed.
- **S-6's capitalization question (GAP-004).** Resolving it requires either the missing D-4 rationale or an operator
  call on whether alt text should mirror a banner's typographic accents. Out of reach of file comparison alone.

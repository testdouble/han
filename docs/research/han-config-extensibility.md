# Research: Extending Han Plugins with Project-Local Configuration

The question: how should Han support per-project configuration overrides, such as a `.han/` folder at a consuming
project's root, for things like "write all markdown outputs to `.scratch/`" and "when picking agents to dispatch for a
skill, also consider these extra agents"? Which format fits best, JSON or markdown? Where should the config live, in
`.han/`, `.claude/rules/`, or CLAUDE.md? And how should every skill read it consistently?

Evidence mode: strict.

## Summary

Store Han's project-level settings in one dedicated markdown file kept at the root of the consuming project, and have
every Han skill read that file the same reliable way skills already read project context today.

Markdown fits better than a structured format like JSON, because most of the overrides people want are instructions a
language model has to interpret, not fixed values a program checks. Every AI coding tool surveyed splits its
configuration the same way: structured settings go in a format like JSON or YAML, and open-ended instructions go in
markdown. A small block of structured values at the top of that markdown file can still hold the handful of settings
that are simple choices, such as an output directory.

Two other places could hold this configuration instead, but both work only as soft guidance that a language model may
or may not follow. Reading the settings file directly from inside each skill is the only approach that guarantees the
configuration reaches the model every time a skill runs.

This recommendation is well supported. Two independent vendors confirm the same format pattern, and Han's own skills
already prove the loading mechanism works today. Some of the finer design choices are less settled: research did not
find a firm answer for where this new settings file should rank against other sources of configuration, or whether it
should be one file or a folder of files, and one structural limit on the approach rests on a single documentation
page.

- **Confidence:** Medium

## Research Results

### Every surveyed AI coding tool splits settings from instructions

The tools surveyed all separate machine-enforced settings from prose instructions. Claude Code puts enforced
configuration in `settings.json` and behavioral guidance in CLAUDE.md and `.claude/rules/` (A2). Gemini CLI does the
same with `.gemini/settings.json` and `GEMINI.md` (A5). Aider keeps settings in `.aider.conf.yml` and coding rules in a
`CONVENTIONS.md` the settings file merely points at (A6, A7). The older, non-AI dot-folder precedents (`.vscode/`,
`.devcontainer/`) use JSON with comments for settings that a program, not a model, consumes (A8, A9 [single-source]).
EditorConfig deliberately rejected JSON and YAML for a flat INI format on readability grounds (A4 [single-source]).

Two vendors independently converged on a hybrid shape for rule files: a small YAML frontmatter block of machine-readable
keys on top of a markdown body of prose instructions. Claude Code's `.claude/rules/*.md` files use a `paths` frontmatter
glob (A2); Cursor's `.cursor/rules/*.mdc` files use `description`, `globs`, and `alwaysApply` (A3). The convergence is
meaningful corroboration that the hybrid is a real pattern. But the two tools disagree on key names and even on
precedence direction: Claude Code and VS Code let project config beat user config (A2, A8), while Cursor lets team rules
beat project rules (A3). There is no cross-tool standard to inherit here. The AGENTS.md standard goes the other
direction entirely: plain markdown, no schema at all, with nesting as its only structure (A1).

### Markdown instructions are guidance; only skill-side loading is deterministic

Anthropic's own documentation states plainly that CLAUDE.md and rules content is context the model tries to follow,
with "no guarantee of strict compliance," and points to hooks for anything that must be enforced (A2). A community bug
report shows the rules path-scoping frontmatter has had real reliability gaps (A15 [single-source]). So any design that
relies on ambient instructions alone inherits a soft ceiling.

Skills can do better. A skill's body supports `${CLAUDE_PROJECT_DIR}` substitution and dynamic context injection: an
inline `` !`command` `` runs before the model sees the skill's content, and its output is spliced into the prompt
verbatim (A14). Han does not need the docs to prove this works: its own skills already use exactly this mechanism to
probe for CLAUDE.md and `project-discovery.md` today (A18, A23). The codebase evidence is the load-bearing proof here;
the documentation page is confirmatory (validated in V6).

### Han cannot ship the config; the consuming project must carry it

Two constraints force the config into the consuming project. First, a CLAUDE.md at a plugin's root is not loaded as
project context, so Han cannot bundle instructions that become live on install (A13 [single-source]). Second, the
plugin manifest's `userConfig` mechanism is stored and read only from user-scope settings; project and local settings
entries are ignored, so it cannot carry a per-repo, version-controlled override (A13 [single-source]). Both claims come
from the same official documentation page and were not tested against a live plugin install (flagged in V7).

One related question stays open: whether Claude Code tolerates arbitrary custom keys in a project's
`.claude/settings.json` is not answered by the settings documentation either way (A12 [single-source]).

### Han already has the machinery a config file would plug into

Han's skills resolve project context through a consistent three-tier fallback: read CLAUDE.md's `## Project Discovery`
section, fall back to `project-discovery.md`, fall back to Glob defaults (A18).

The `project-discovery` skill is the existing precedent for machine-written, skill-consumed project context, and it
writes into CLAUDE.md or AGENTS.md precisely because the host loads those files automatically (A21).

Output paths are resolved per skill in prose, with real inconsistencies: code-overview writes outside the repository,
while planning skills target `docs/` (A19).

Agent rosters are hardcoded tables in each SKILL.md with signal-based selection and band caps, and today there is no
extension point for project-supplied agents (A20).

A narrow search did not surface another Claude Code plugin suite with a `.han/`-style config folder. A community
feature request confirms per-project plugin configuration was a recognized gap as of late 2025 (A16, A17
[single-source]); read that as "not found," not "does not exist" (V5).

One scoping fact matters for rollout: only 26 of the 49 SKILL.md files in the repo have a `## Project Context` block to
extend. The other 15 real skills (the Atlassian and Linear wrappers, the communication skills, the plugin-builder
skills, and a few others) would need a separate decision about whether project overrides even apply to them (V2).

## Options to Consider

### O1: A `.han/config.md` markdown file, read deterministically by each skill

- **What it is:** One markdown file in a `.han/` folder at the project root. Optional YAML frontmatter carries the few
  simple values (an output directory, for example); named markdown sections carry the prose overrides (extra agents to
  consider per skill, output conventions). Each participating skill adds a probe to its `## Project Context` block, such
  as `` !`cat .han/config.md 2>/dev/null || echo ""` ``, plus a short resolution step that honors what the file supplies.
- **Trade-offs:** The config is guaranteed in context every time a participating skill runs, independent of the model's
  judgment. Han fully owns the schema. The costs: it is a Han-invented convention with no native discoverability,
  since nothing in Claude Code surfaces `.han/` to the user. The rollout touches every participating skill: 26 have
  the block today, and 15 need a scoping decision. And malformed or invalid content needs an explicit
  graceful-degradation rule, so a bad file cannot silently break dispatch (V9).
- **Rests on:** (A13), (A14), (A18), (A20), (A23); format choice on (A2), (A3).
- **Evidence status:** corroborated (loading mechanism proven in-repo; format pattern confirmed by two independent
  vendors). The "must live in the consuming project" constraint is single-source (A13).

### O2: A `.claude/rules/han.md` rules file

- **What it is:** The consuming project writes Han's overrides into a Claude Code rules file, which loads ambiently and
  shows up in `/memory` and `/context`.
- **Trade-offs:** First-class, Anthropic-maintained surface with zero custom parsing in Han. But it is pure guidance
  with a documented soft-compliance ceiling (A2). The path-scoping frontmatter has a reported reliability bug (A15).
  The content occupies context in every session, whether or not a Han skill runs, and no skill can verify it loaded.
  Structured overrides such as roster extensions are exactly what free-text ambient rules handle worst.
- **Rests on:** (A2), (A15).
- **Evidence status:** corroborated for the mechanism; the reliability caveat is single-source (A15).

### O3: A `## Han Configuration` section in the project's CLAUDE.md

- **What it is:** A named section beside `## Project Discovery`, which Han's skills already know how to find and read.
- **Trade-offs:** The tightest match to Han's existing read pattern; validation found this precedent analogy stronger
  for O3 than for O1, since `project-discovery` targets CLAUDE.md precisely because the host auto-loads it (V3). Skills
  could still read the section explicitly for determinism. The costs: it grows an always-loaded file that Anthropic
  recommends keeping lean. Han cannot seed or validate the section from the plugin side (A13). And mixing Han's
  override schema into a team's shared narrative file invites drift and merge friction.
- **Rests on:** (A2), (A13), (A18), (A21).
- **Evidence status:** corroborated.

### O4: JSON config (`.han/config.json` or custom keys in `.claude/settings.json`)

- **What it is:** A structured, schema-validatable file holding Han's overrides as keys and values.
- **Trade-offs:** Deterministic to parse and easy to validate, and the right shape for values a program checks. But
  the overrides you named are mostly instructions a model interprets, and no surveyed source shows JSON handling
  open-ended guidance without degrading into prose stuffed inside strings (A10 [single-source]). Whether custom keys in
  `settings.json` are tolerated long-term is unconfirmed (A12). Claude Code already warns on unknown plugin-manifest
  fields under strict validation, suggesting Anthropic tightens unknown-key handling over time (A13).
- **Rests on:** (A10), (A12), (A13).
- **Evidence status:** single-source (caveated) on the format trade-off claims; inconclusive on settings.json custom
  keys.

## Recommendation

- **Recommendation:** O1. Create a `.han/config.md` file: YAML frontmatter for the few simple values, named markdown
  sections for the prose overrides, loaded by each participating skill through the same `!`-probe pattern the skills
  already use.
  - Start with one file rather than a folder of files. That is a deliberate simplification to avoid speculative
    structure, not a claim that one file is superior on the merits, and splitting into per-concern files later carries
    a migration cost (V8).
  - Treat O3 as the close runner-up and a natural complement: the `project-discovery` skill could offer to write a
    pointer to `.han/config.md` into CLAUDE.md, so the config is discoverable in the file every contributor already
    reads.
  - Scope the rollout to the skills that already carry a `## Project Context` block and resolve project context
    today. Decide separately whether the wrapper and builder skills participate at all (V2).
  - Specify graceful degradation up front: unparseable content or unknown keys are ignored with a one-line note to the
    user, and any project-supplied agent name is validated against the skill's actual roster and band caps before it
    is honored (V9).
- **Proposed precedence, marked as a design proposal:** explicit user input, then `.han/config.md`, then CLAUDE.md's
  `## Project Discovery`, then `project-discovery.md`, then Glob defaults. No source establishes this ordering; it is a
  design choice to validate in use, and it carries a visibility trade-off: a value the user can see in CLAUDE.md would
  be silently outranked by a file they may forget exists (V4).
- **Evidence basis:** The format choice (markdown with optional frontmatter over JSON) rests on corroborated evidence.
  Two independent vendors converged on the hybrid shape (A2, A3), and the settings-versus-instructions split recurs
  across Claude Code, Gemini CLI, and Aider (A2, A5, A6, A7). The loading mechanism rests on codebase-verified evidence
  (A18, A23) with the official skills documentation as confirmation (A14). The constraint forcing the config into the
  consuming project rests on a single official documentation page (A13). It deserves a cheap empirical check before
  implementation locks in: install a plugin with a project-scoped `userConfig` entry and see whether it is honored.
  The absence of ecosystem precedent is a narrow negative search result (A16, A17), not corroborated proof the pattern
  is safe.

## Validation

The adversarial validator returned ten findings. The recommendation's shape survived; several supporting claims and
sub-decisions were corrected or reframed.

### V1: The "YAGNI culture" objection rested on a mischaracterized changelog entry

- **Strategy:** Challenge the Evidence
- **Investigation:** Read CHANGELOG.md lines 495 to 538 directly. The v4.3.1 removal of model overrides was a
  portability fix (a Claude-specific tier name broke skills on other hosts), not a stance against configuration knobs.
- **Result:** Refuted
- **Impact:** The YAGNI framing in this report now rests on the named "speculative configuration knobs" anti-pattern in
  the junior-developer agent definition and on the absence of prior precedent, not on the changelog entry (A24).

### V2: "Add one probe line per skill" understates the rollout

- **Strategy:** Challenge the Fix
- **Investigation:** Grepped all SKILL.md files for `## Project Context`. 26 of 49 have the block; 15 real skills do
  not, including all six Atlassian skills, both communication skills, and the three plugin-builder skills.
- **Result:** Partially Refuted
- **Impact:** The recommendation now scopes the rollout to the skills that already resolve project context and calls
  for an explicit decision on the rest.

### V3: Han's own precedent favors O3 more literally than O1

- **Strategy:** Challenge the Assumptions
- **Investigation:** Read the project-discovery skill in full. It writes into CLAUDE.md or AGENTS.md specifically
  because the host auto-loads those files; that is precedent for an ambient file, not a separately-probed one.
- **Result:** Partially Refuted
- **Impact:** O3 was elevated to close runner-up and complement, and the CLAUDE.md-pointer idea was added to the
  recommendation.

### V4: The precedence order was asserted, not derived

- **Strategy:** Challenge the Recommendation
- **Investigation:** No source discusses ordering `.han/` against CLAUDE.md; the cited fallback chain has three tiers
  that coexist in one resolution step.
- **Result:** Refuted as a claim of derivation
- **Impact:** The order is now labeled a design proposal, with the CLAUDE.md-visibility trade-off stated.

### V5: The "no ecosystem precedent" finding is a shallow negative search

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The negative result rests on one closed GitHub issue and one repo family, with no second search
  strategy.
- **Result:** Confirmed as a gap
- **Impact:** The report now says "a narrow search did not surface one" and does not treat the absence of precedent as
  evidence the pattern is safe.

### V6: Discounting the skills documentation does not break the recommendation

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The dynamic-injection mechanism the recommendation depends on is verified working in
  code-review's SKILL.md, independent of the web source.
- **Result:** Confirmed
- **Impact:** Strengthens the loading-mechanism plank; the report now names the codebase evidence as load-bearing.

### V7: The plugin-constraint claim is single-sourced and untested

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Both halves of the "config must live in the consuming project" constraint cite the same
  documentation page, with no live-install test and no page revision date.
- **Result:** Not independently corroborated
- **Impact:** The report flags A13 as single-source throughout and the recommendation calls for a cheap empirical check
  before implementation locks in.

### V8: Single file versus folder of files was asserted away

- **Strategy:** Challenge the Recommendation
- **Investigation:** Per-skill override sections in one shared file trade against Han's own "each skill probes its own
  small artifact" convention; a folder would mirror that convention more closely.
- **Result:** Partially Refuted
- **Impact:** The single file is now framed as a deliberate v1 simplification with a named migration cost.

### V9: No failure-mode handling was specified

- **Strategy:** Challenge the Fix
- **Investigation:** Nothing in the draft addressed malformed frontmatter, unknown keys, or a config naming an agent
  that does not exist in a skill's roster.
- **Result:** Refuted as complete
- **Impact:** The recommendation now includes an explicit graceful-degradation requirement and roster validation.

### V10: Web sources carry access dates, not revision dates

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Every web source is dated 2026-07-23 as an access date only; no revision-date or archive check was
  performed against an actively-developed product's documentation.
- **Result:** Confirmed as a gap
- **Impact:** Treat any hard constraint drawn from a single official page as provisional pending direct testing.

### Adjustments Made

Validation changed the report in five places:

1. The YAGNI objection was re-grounded (V1).
2. The rollout was scoped to the 26 skills with a `## Project Context` block (V2).
3. O3 was elevated to complement status, with the CLAUDE.md-pointer idea added (V3).
4. The precedence order and single-file choice were relabeled as design proposals (V4, V8).
5. The graceful-degradation requirement was added (V9).

The recommendation itself survived.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** The "config must live in the consuming project" constraint rests on one documentation page
  (A13) and has not been tested against a live plugin install. If wrong, JSON-plus-userConfig options reopen. The
  rollout blast radius across the 15 skills without a `## Project Context` block needs a scoping decision before
  implementation. No precedent from another plugin suite validates the `.han/` pattern in production (A16, A17). Web
  sources are dated by access only, so documentation drift is possible.

## Sources

| ID  | Source                                        | Link / location                                                             | Retrieved  | Trust class | Summary (one line)                                                                        | Evidence status                          |
| --- | --------------------------------------------- | --------------------------------------------------------------------------- | ---------- | ----------- | ----------------------------------------------------------------------------------------- | ---------------------------------------- |
| A1  | AGENTS.md official site                       | https://agents.md                                                            | 2026-07-23 | web         | Plain markdown, no schema, nearest-file-wins nesting                                       | corroborated by A2, A11                  |
| A2  | Claude Code memory docs                       | https://code.claude.com/docs/en/memory                                       | 2026-07-23 | web         | CLAUDE.md hierarchy, `.claude/rules/` with `paths` frontmatter, "no guarantee of strict compliance" | corroborated by A3, A15                  |
| A3  | Cursor rules docs                             | https://cursor.com/docs/rules.md                                             | 2026-07-23 | web         | `.mdc` frontmatter-plus-markdown rules; team beats project beats user                      | corroborated by A2 (hybrid pattern)      |
| A4  | EditorConfig format rationale                 | https://github.com/editorconfig/editorconfig/wiki/Why-EditorConfig-uses-an-INI-like-format | 2026-07-23 | web         | Rejected JSON/YAML/XML for flat INI on readability grounds                                 | single source (caveated)                 |
| A5  | Gemini CLI configuration docs                 | https://geminicli.com/docs/reference/configuration/                          | 2026-07-23 | web         | `.gemini/settings.json` for settings, `GEMINI.md` for prose                                | corroborated by A2, A6                   |
| A6  | Aider config file docs                        | https://aider.chat/docs/config/aider_conf.html                               | 2026-07-23 | web         | YAML settings file, home then repo root then cwd override order                            | corroborated by A5, A7                   |
| A7  | Aider CONVENTIONS.md docs                     | https://aider.chat/docs/usage/conventions.html                               | 2026-07-23 | web         | Prose rules in markdown; the settings file only points at it                               | corroborated by A2, A6                   |
| A8  | VS Code JSON docs                             | https://code.visualstudio.com/docs/languages/json                            | 2026-07-23 | web         | `.vscode/settings.json` is JSONC; workspace beats user                                     | corroborated by A9                       |
| A9  | devcontainer.json conventions                 | https://docs.github.com/codespaces/setting-up-your-project-for-codespaces/introduction-to-dev-containers | 2026-07-23 | web         | JSONC convention for dev-container config                                                  | single source (caveated, aggregated)     |
| A10 | JSON vs YAML vs TOML comparisons              | https://www.anbowell.com/blog/an-in-depth-comparison-of-json-yaml-and-toml/  | 2026-07-23 | web         | Format trade-offs; ecosystem convention dominates the choice                               | single source (caveated, SEO-genre)      |
| A11 | Cross-tool AI config file comparisons         | https://www.deployhq.com/blog/ai-coding-config-files-guide                   | 2026-07-23 | web         | File-name landscape across AI coding tools; AGENTS.md deliberately minimal                 | single source (caveated)                 |
| A12 | Claude Code settings docs                     | https://code.claude.com/docs/en/settings                                     | 2026-07-23 | web         | Settings hierarchy; silent on whether arbitrary custom keys are tolerated                  | single source (inconclusive)             |
| A13 | Claude Code plugins reference                 | https://code.claude.com/docs/en/plugins-reference                            | 2026-07-23 | web         | Plugin CLAUDE.md not loaded; `userConfig` user-scoped only; path substitutions             | single source (caveated, load-bearing)   |
| A14 | Claude Code skills docs                       | https://code.claude.com/docs/en/skills                                       | 2026-07-23 | web         | `${CLAUDE_PROJECT_DIR}` and `` !`command` `` dynamic context injection                     | corroborated by A18, A23 (in-repo)       |
| A15 | Rules `paths` frontmatter bug report          | https://github.com/anthropics/claude-code/issues/17204                       | 2026-07-23 | web         | Documented `paths:` key unreliable in some configs; undocumented `globs:` works            | single source (caveated)                 |
| A16 | Per-project plugin config feature request     | https://github.com/anthropics/claude-code/issues/11461                       | 2026-07-23 | web         | Per-project plugin configuration named as a gap, Nov 2025; closed, resolution unclear      | single source (caveated)                 |
| A17 | SuperClaude framework repos                   | https://github.com/SuperClaude-Org/SuperClaude_Framework                     | 2026-07-23 | web         | No documented per-project override-folder precedent found                                  | single source (inconclusive, negative)   |
| A18 | Han three-tier context fallback               | han-coding/skills/code-review/SKILL.md:16-89                                 | n/a        | codebase    | CLAUDE.md section, then project-discovery.md, then Glob defaults, via `!` probes           | corroborated across 15+ skills           |
| A19 | Han output-path resolution patterns           | han-planning/skills/plan-a-feature/SKILL.md:74-79 (and siblings)             | n/a        | codebase    | Per-skill prose resolution; inconsistent defaults across skills                            | corroborated (multiple skills read)      |
| A20 | Han agent roster tables                       | han-planning/skills/plan-implementation/SKILL.md:150-195 (and siblings)      | n/a        | codebase    | Hardcoded rosters with signal selection and band caps; no extension point                  | corroborated (three skills read)         |
| A21 | project-discovery skill                       | han-core/skills/project-discovery/SKILL.md:1-107                             | n/a        | codebase    | Writes a structured section into auto-loaded CLAUDE.md or AGENTS.md, with dedup            | corroborated by A18 (consumers)          |
| A22 | Progressive-disclosure guidance               | han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md | n/a | codebase    | Three loading levels; on-demand files are where a config read sits                         | corroborated by A18                      |
| A23 | Han dynamic-injection convention              | multiple SKILL.md `## Project Context` blocks                                | n/a        | codebase    | `!`-probe with sentinel fallbacks used across the suite; 26 of 49 skills carry the block   | corroborated by A18                      |
| A24 | No existing override mechanism in Han         | repo-wide grep; han-core/agents/junior-developer.md:289                      | n/a        | codebase    | No `.han/` or per-project override anywhere; "speculative configuration knobs" named an anti-pattern | corroborated (validated in V1)           |
| A25 | Skill composition pattern                     | han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md | n/a | codebase    | Skills compose via Skill-tool invocation; config informs selection inside existing flows   | corroborated by A18                      |

### A2: Claude Code memory docs (recommendation-bearing)

- **Link / location:** https://code.claude.com/docs/en/memory
- **Retrieved:** 2026-07-23
- **Trust class:** web
- **Summary:** Documents the CLAUDE.md scope hierarchy and load order, `.claude/rules/*.md` files with YAML `paths`
  frontmatter globs, and the `@path` import mechanism. States that markdown instructions shape behavior but are not a
  hard enforcement layer, with "no guarantee of strict compliance," and that enforced configuration belongs in
  settings.json or hooks. This is the direct evidence for both the hybrid frontmatter-plus-markdown pattern and the
  soft-compliance ceiling that rules out ambient-only designs.
- **Evidence status:** corroborated by A3 (hybrid pattern) and A15 (reliability caveat)

### A3: Cursor rules docs (recommendation-bearing)

- **Link / location:** https://cursor.com/docs/rules.md
- **Retrieved:** 2026-07-23
- **Trust class:** web
- **Summary:** Cursor's `.cursor/rules/*.mdc` files pair YAML frontmatter (`description`, `globs`, `alwaysApply`) with
  a markdown instruction body. An independent, competitively-differentiated vendor converging on the same shape as
  Claude Code's rules files is the corroboration that makes the hybrid format a pattern rather than one vendor's
  idiosyncrasy. Cursor's team-beats-project precedence direction also documents that no cross-tool layering consensus
  exists.
- **Evidence status:** corroborated by A2

### A13: Claude Code plugins reference (recommendation-bearing)

- **Link / location:** https://code.claude.com/docs/en/plugins-reference
- **Retrieved:** 2026-07-23
- **Trust class:** web
- **Summary:** States that a CLAUDE.md at a plugin's root is not loaded as project context, and that plugin `userConfig`
  values are stored and read only from user-scope settings, with project and local entries ignored. Together these force
  a per-repo override into a file the consuming project carries and Han's skills read themselves. Both claims come from
  this one page; validation flagged them as single-sourced and untested against a live install, so they are provisional
  pending an empirical check.
- **Evidence status:** single source (caveated, load-bearing)

### A14: Claude Code skills docs (recommendation-bearing)

- **Link / location:** https://code.claude.com/docs/en/skills
- **Retrieved:** 2026-07-23
- **Trust class:** web
- **Summary:** Documents `${CLAUDE_PROJECT_DIR}` substitution in skill bodies and dynamic context injection: an inline
  `` !`command` `` runs before the model sees the skill content and its stdout is spliced into the prompt verbatim.
  This is the mechanism that makes deterministic loading of an optional project config possible. Validation confirmed
  Han's own skills prove the mechanism independently, so this source is confirmatory rather than load-bearing.
- **Evidence status:** corroborated by A18, A23

### A18: Han three-tier context fallback (recommendation-bearing)

- **Link / location:** han-coding/skills/code-review/SKILL.md:16-89
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Code-review, and more than fifteen sibling skills, resolve project context through `!`-command probes
  and a fixed fallback chain: CLAUDE.md's `## Project Discovery` section, then `project-discovery.md`, then Glob
  defaults. This working pattern is the load-bearing proof that a `.han/config.md` probe is feasible and consistent
  with the suite's conventions, and it is the chain the new file would slot into.
- **Evidence status:** corroborated across the suite; validated directly in V6

### A20: Han agent roster tables (recommendation-bearing)

- **Link / location:** han-planning/skills/plan-implementation/SKILL.md:150-195; han-coding/skills/code-review/SKILL.md:214-234; han-research/skills/research/SKILL.md:137-169
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Agent rosters are hardcoded tables in each dispatching skill, selected by signals and capped by size
  band, with user override by explicit naming. This is where a project-supplied "also consider these agents" override
  must hook in, and why the recommendation requires validating any supplied agent name against the actual roster and
  caps before honoring it.
- **Evidence status:** corroborated (three dispatching skills read directly)

### A21: project-discovery skill (recommendation-bearing)

- **Link / location:** han-core/skills/project-discovery/SKILL.md:1-107
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Han's existing precedent for machine-written, skill-consumed project context. It writes a structured
  section into CLAUDE.md or AGENTS.md, with deduplication, because the host auto-loads those files. Validation noted
  this precedent maps more literally onto O3 than O1, which is why the recommendation pairs the `.han/` file with a
  CLAUDE.md pointer this skill could offer to write.
- **Evidence status:** corroborated by A18 (its consumers)

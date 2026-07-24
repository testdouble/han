# Investigation: A han-config Skill for Reading and Writing .han/config.md

Investigation report. Read the Summary, then approve the Planned Fix or push back.

## Summary

- **Root Cause:** The config surface was built read-only. Every shipped skill reads `.han/config.md` uniformly through
  an inline probe (E1, E3), but no component owns authoring, validation, or reporting. The only write path is
  hand-editing, with no schema feedback and silent read-time degradation on mistakes (E6, E10).
- **Fix:** Add a `han-config` skill to `han-core` with three modes: an inline read mode every shipped skill invokes in
  place of its own config probe, a show mode that reports the effective config and flags ignored values, and a set mode
  that makes validated, surgical, shape-preserving edits to `.han/config.md`. The plan reroutes all 39 shipped skills'
  reads through the new skill, loosens the skill-composition guidance from outright refusal to named watch-outs,
  retires the 11 vendored `config-rule.md` copies, and updates the documentation surfaces the change touches.
- **Why Correct:** The docs state the write gap directly ("You write the file; Han cannot," E10), and nothing in the
  suite writes the file today (E11). Centralizing the read path follows the inline sub-skill shape the composition
  guidance already validated for readability-guidance (E12, V2), extended by this plan's guidance update, and it ends
  the hand-synced vendoring of the interpretation contract across 12 plugins (E8, E13).
- **Validation Outcome:** A first validation pass re-verified every evidence item (V1, V2) and forced two plan changes
  (V3, V5). At review, the user made the read rerouting a requirement, reversing the first draft's scope decision. A
  second pass stress-tested the revised design and refuted six assumptions (V8 through V15), all now folded in: the
  mid-body `config-rule.md` citations, the `allowed-tools` enforcement question, the depth-2 nesting risk, the
  han-reporting omission, and three documentation-coherence gaps.
- **Remaining Risks:** See the Confidence Assessment under Validation Results: no automated test coverage exists for
  the write logic, surgical-edit behavior on unusual config files can only be verified once the skill is built, the
  depth-2 nesting path needs its pre-rollout spike (V10), the `Skill`-in-`allowed-tools` determination may surface a
  latent bug in eight-plus shipped skills (V9), and repos with vendored guidance lag until they run `guidance update`
  (V15).

## Problem Statement

Han has no supported way to change `.han/config.md` other than hand-editing the file, and no single entry point that
reads the effective config back to the user. The operator guide is explicit about the gap: "You write the file; Han
cannot" (E10).

A user who wants to set the output directory, the default swarm size, the writing-voice profile, or the extra-agents
list must copy the annotated example from `docs/configuration.md` and edit it by hand, hoping they matched the schema.
Nothing validates what they wrote. A typo in `default-swarm-size` or an escaping `output-directory` path is silently
ignored at read time under the degradation rule (E6), and the user never learns why their setting did nothing.

On the read side, every shipped skill already consumes the config the same way: an inline probe in its
`## Project Context` block splices the file's content into context before the skill runs (E1, E3). That mechanism is
uniform and works, but it serves skills, not people. There is no skill a user can invoke to see what their config is,
what it means, and what the suite would do with it.

The request driving this investigation asks for a new `han-config` skill in `han-core` with two goals: give users a
skill that changes the config without hand-editing the file, and have every config-consuming skill read config through
it. Both goals are requirements. The second conflicts with the current skill-composition guidance (E12), so the plan
also loosens that guidance from an outright refusal to compose skills into a set of watch-outs to design around.

## Root Cause Analysis

### Root Cause

The config surface was built read-only by design. The interpretation contract (`config-rule.md`) and the inline probe
give every skill a uniform read path, but no component owns authoring, validation, or reporting of `.han/config.md`.
The only write path is the user's own editor, with no schema feedback.

### Detailed Analysis

The read path is complete and deliberate. All 39 shipped skills carry the identical probe line and the identical
deferral sentence pointing at their plugin's vendored `config-rule.md` (E1, E3, E4). The plugin-builder guidance
codifies this as the intended pattern: skills discover config inline rather than calling a data-fetch sub-skill, to
avoid a documented early-exit failure mode (E12). So "skills cannot read config" is not the problem. They all can,
uniformly.

The write path is entirely absent, and deliberately so far. `docs/configuration.md` states Han cannot write or seed the
file (E10), and repo-wide searches found no skill, script, or agent that writes `.han/config.md` content. The closest
precedent is `project-discovery`, which only writes a consent-gated one-line pointer to the file in CLAUDE.md or
AGENTS.md (E11).

Because no component owns the write path, the schema knowledge a writer needs lives only in prose docs the user must
apply by hand: the four tokens (E5), the containment rules (E7), the canonical file shape (E9), and the degradation
semantics (E6).

The degradation rule then guarantees a mis-authored value is silently ignored rather than surfaced (E6). That is
correct behavior for a skill run, but it leaves the hand-editing user with no feedback loop.

The maintenance history shows the cost compounds as the schema grows. Each of the three schema additions to date
touched all 12 vendored `config-rule.md` copies plus every adopting consumer, with no sync tooling or CI check guarding
the byte-identical invariant (E8, E13, E14).

## Planned Fix

### Approach

Add a `han-config` skill to `han-core` that owns the whole config surface: an inline read mode every shipped skill
invokes in place of its own probe, a show mode that reads the effective config back in plain language, and a set mode
that makes validated, shape-preserving edits to `.han/config.md`. Loosen the skill-composition guidance so the
rerouting is a supported pattern with named watch-outs rather than a violation.

### Scope decision: reads route through han-config, and the composition guidance loosens

Every config-consuming skill reads config via `han-config`. This is a requirement of the work, set at plan review, and
it reverses the first draft's recommendation to keep the inline probes.

The design stays inside the shape the composition guidance already validated. The read mode is an inline sub-skill,
never `context: fork`, that surfaces content into the caller's context and hands control straight back, which is
exactly the readability-guidance pattern the guidance's own spike testing supports (E12, V2). What han-config surfaces
is not a few bare values: it is the config file's content together with the interpretation contract
(`config-rule.md`), the same shared reference set that is today vendored byte-identically into 12 plugins (E8). That
makes the rerouting closer to the guidance's "whole shared standard" exception than to the docs-directory fetch it
warns against.

The guidance still forbids this in its current wording, naming "a config setting" as a disallowed data-fetch example
(E12). So the plan updates the guidance itself: the "Data-fetch composition (avoid)" section loosens from outright
refusal into watch-outs to design around, and the config read becomes its second worked example. The watch-outs keep
the substance of the old rule: stay inline and never fork, carry an explicit proceed-to-the-next-step instruction
after the invocation, surface interpretation context rather than bare values, and degrade gracefully when the
sub-skill is unavailable.

Centralizing reads pays for its dispatch cost by ending the vendoring treadmill. Once no skill carries the deferral
sentence, the 11 vendored `config-rule.md` copies outside `han-core` retire, and a schema addition touches the
canonical rule, the han-config skill, and the docs, instead of all 12 copies plus every consumer (E13).

One behavior change follows for the five plugins that do not depend on `han-core` (`han-communication`,
`han-feedback`, `han-linear`, `han-plugin-builder`, and `han-reporting`, nine shipped skills between them, V11): when
`han-core` is not installed, their skills' han-config invocation is unavailable, and they proceed as if no project
config is present. Today those skills can read config standalone through their own probe. The plan accepts this
degradation rather than adding a han-core dependency to those plugins, because `han-communication` and
`han-plugin-builder` are deliberately dependency-free layers (per CLAUDE.md), and a missing config has always been a
supported state (E6).

Two mechanics questions surfaced by validation get explicit handling rather than assumptions. First, the guidance says
a skill invoking another skill must list `Skill` in `allowed-tools`, yet at least eight shipped skills already invoke
`han-communication:readability-guidance` without declaring it (V9); implementation starts by determining empirically
whether the declaration is enforced, then either fixes the existing gap and declares `Skill` in all rerouted files, or
corrects the guidance rule. Second, because readability-guidance is itself one of the rerouted skills, a caller that
reads config and later invokes readability-guidance would trigger a second, nested han-config call (V10). The read
mode prevents this: both invocations are inline and share the caller's context, so readability-guidance's config step
first checks whether han-config already surfaced the config this run and only invokes it when it has not. Depth-2
nesting therefore only occurs when readability-guidance is the run's first config consumer, and that path gets a
manual spike test before rollout, since the guidance's spike evidence covered single-hop invocation only (V10).

### Behavior of the new skill

The skill is deterministic and flowchartable, which is the taxonomy test for a skill rather than an agent (E15). It has
three modes, chosen by the invocation arguments:

1. **Read (invoked by another skill).** The inline mode the other 39 shipped skills call at the start of their run, in
   place of the probe block they carry today. It reads `.han/config.md` from the working directory (E7), surfaces the
   file's content and the interpretation contract into the caller's context, resolves nothing on the caller's behalf,
   and hands control straight back with an explicit instruction to proceed with the calling skill's own workflow. When
   the file is absent, it says so and hands back the same way; a missing or empty config never fails the caller's run
   (E6).
2. **Show (no arguments, or "show"/"get").** Read `.han/config.md` from the working directory (E7). Report each
   recognized setting with its current value, what it does, and what the effective behavior is when the key is absent
   (the built-in default under the precedence chain, E6). Flag any value the config rule would ignore (an unrecognized
   swarm size, an escaping output path, a missing writing-voice file), with the reason. This gives the user the
   feedback loop that silent read-time degradation removes.
3. **Set (a change request in the arguments).** Parse the requested change against the four-token schema (E5) and
   validate it with the same rules readers apply: containment for `output-directory` (E7), the four accepted
   `default-swarm-size` values (E5), file existence for `writing-voice` (E5), and `plugin:agent` or bare-name form for
   `## Extra Agents` entries (E5). Refuse an invalid value with a one-line explanation instead of writing it. On a
   valid change, create `.han/` and `config.md` if absent, or edit the existing file, preserving the canonical shape
   (frontmatter scalars, then the `## Extra Agents` bullet list, E9) and any unrecognized content the user put there,
   since the config rule tolerates it (E6). Extra-agents changes are list edits, adding or removing an entry, matching
   the section's additive semantics (E6). After a successful write, echo the resulting file content back.

Removal is symmetric: "unset the writing voice" deletes the key, restoring the built-in default under the precedence
chain. The skill never touches settings the user did not name.

When the skill creates the file for the first time, it follows the `project-discovery` precedent (E11). It offers, via
a consent question, to add the one-line `.han/config.md` pointer to CLAUDE.md or AGENTS.md so future sessions keep the
file visible.

### Changes

#### `han-core/skills/han-config/SKILL.md`

- **Change:** New skill definition.
- **Evidence:** (E5), (E6), (E7), (E9), (E10), (E12), (E15)
- **Standards:** Skill layout and frontmatter conventions (E16); `allowed-tools` narrow-prefix Bash rules and
  find-over-ls (E17); the standard `## Project Context` probe block (E1); the inline sub-skill discipline the
  composition guidance validates: inline, never `context: fork`, with an explicit hand-control-back instruction (E12);
  built with `/han-plugin-builder:skill-builder` per CLAUDE.md's plugin-authoring rule.
- **Details:** Frontmatter `name: han-config`, description covering all three modes with "does not" boundaries against
  `project-discovery` (repo scanning) and hand-editing guidance, `allowed-tools: Read, Write, Edit, Glob, Grep,
  Bash(find *)`, and no `context: fork` (E12). Body: the standard probe block, then the read flow (surface config
  content plus the interpretation contract, hand control straight back, explicit proceed instruction for the caller),
  then the show flow, then the set flow with a per-token validation table, then the first-write consent step.
  Validation logic defers to the canonical `../../references/config-rule.md` for interpretation semantics rather than
  restating them. It restates only what a writer needs beyond the read contract: shape preservation,
  refuse-don't-write, echo-back. The set flow names its
  edit strategy explicitly, so every path stays flowchartable (V5). A scalar change is a surgical Edit of that one
  frontmatter line, or an insertion into the existing frontmatter block. An extra-agents change is an Edit of that one
  bullet line, or an append of the `## Extra Agents` section when absent. Full-file regeneration happens only when the
  file does not exist yet, produced from the reference template. The flow also names its edge behaviors. It refuses
  with a one-line explanation when `.han` exists but is a file rather than a directory, or when a `writing-voice` path
  resolves to a directory instead of a file. A file with only frontmatter and no `## Extra Agents` section, or with
  unrecognized keys and prose, is edited around, never rewritten.

#### `han-core/skills/han-config/references/config-template.md`

- **Change:** New reference file carrying the canonical annotated file shape the write path reproduces.
- **Evidence:** (E9)
- **Standards:** One canonical source per concept: this template mirrors the `docs/configuration.md` annotated example
  (E9) rather than inventing a second shape; the skill links it instead of inlining it (progressive disclosure, E16).
- **Details:** The frontmatter-plus-`## Extra Agents` skeleton with placeholder values and one comment per token naming
  its validation rule.

#### `han-core/docs/skills/han-config.md`

- **Change:** New long-form doc for the skill.
- **Evidence:** Coverage rule: every skill gets a long-form doc (`docs/templates/coverage-rule.md`).
- **Standards:** `docs/templates/skill-long-form-template.md`; writing-voice profile.
- **Details:** What the skill does, both modes with example invocations, the refuse-don't-write behavior, and Related
  documentation linking up to the han-core README then the repo root.

#### `han-core/README.md`

- **Change:** Add the `han-config` scent line to the skills list, and update the top-of-file prose (lines 5 and 8)
  that currently describes han-core as carrying only "the project-discovery skill" (V3).
- **Evidence:** Coverage rule; the README currently lists only `project-discovery` under skills; validation finding V3.
- **Standards:** Scent line reuses the long-form doc's summary line; no counts.

#### `CLAUDE.md`

- **Change:** Update the han-core descriptions at lines 10, 73, and 78, which each name han-core's skill set as "the
  `project-discovery` skill" (singular), to name both skills (V3).
- **Evidence:** Validation finding V3: these lines go stale the moment `han-config` ships.
- **Standards:** One canonical source per concept; the project map must match what is on disk.

#### `docs/choosing-a-han-plugin.md`

- **Change:** Update line 35, which describes han-core as "the project-discovery skill, and the canonical rule files,"
  to include `han-config` (V3).
- **Evidence:** Validation finding V3.
- **Standards:** Plugin index carries scent plus link, no second copy of content.

#### `docs/skills/README.md`

- **Change:** Add the alphabetized index entry for `han-config`.
- **Evidence:** Coverage rule.
- **Standards:** Index stays complete, not counted; verify every entry while editing.

#### `docs/configuration.md`

- **Change:** Replace the "You write the file; Han cannot" bullet (E10) with one naming `han-config` as the supported
  way to create and change the file, keeping hand-editing as an equally valid path. Update the description of how
  skills read the file to name the han-config read mode as the mechanism. Update lines 24 and 25, which state the rule
  file is "vendored byte-identical into each plugin," since the vendored copies retire (V12).
- **Evidence:** (E10) is the exact statement the new skill makes false; the read rerouting changes the doc's account
  of consumption; V12 caught the vendoring sentence.
- **Standards:** One canonical source per concept: this doc stays the schema's home; the skill doc links to it.

#### All 39 shipped `SKILL.md` files (the config-read rerouting)

- **Change:** In every shipped skill across the 12 plugins (E3), replace the `.han/config.md` probe line and the
  deferral sentence with an instruction to invoke `han-core:han-config` (read mode) at the start of the run, then
  proceed with the skill's own workflow. Add `Skill` to each file's `allowed-tools` where it is not already present.
  The other `## Project Context` probes (CLAUDE.md, project-discovery, default branch) stay as they are.
- **Evidence:** (E1), (E3), (E4); the requirement set at plan review.
- **Standards:** The loosened composition guidance's watch-outs: explicit continuation instruction after the Skill
  call, `Skill` declared in `allowed-tools` (pending the V9 enforcement determination), graceful degradation when the
  sub-skill is unavailable (proceed as if no project config is present, E6).
- **Details:** The probe-and-deferral swap uses the same replacement text in every file, mirroring how the probe and
  deferral sentence are identical today (E3, E4), but it is not the whole diff everywhere (V13). Roughly 13 skills in
  `han-atlassian`, `han-coding`, `han-planning`, and `han-research` also cite `../../references/config-rule.md` mid-body
  (for example the swarm-size band-selection steps, V8); each of those citations is rewritten to reference the
  interpretation contract han-config surfaces into context, removing the file link, and the implementation enumerates
  them per file rather than relying on a single find-and-replace. `readability-guidance` additionally gets the
  config-dedupe step: use config already surfaced in this run's context, and invoke han-config only when none is
  present (V10). Skills in the five plugins that do not depend on `han-core` carry the same text; their degradation
  path is the unavailable-sub-skill case above (V11).

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md`

- **Change:** Loosen the "Data-fetch composition (avoid)" section (lines 85 through 112) from outright refusal into
  watch-outs to design around, and extend the inline-exception section (lines 114 through 142) so its second property
  admits a shared interpretation contract plus the values it interprets, with the han-config read mode as the second
  worked example alongside readability-guidance. Update "Deciding which way to go" (lines 152 onward) to match.
- **Evidence:** (E12), (V2); the requirement set at plan review.
- **Standards:** The guidance keeps its evidence discipline: the observed fork-specific failure mode (lines 91 through
  95) stays documented as the reason the watch-outs exist, and the honest limit on the spike evidence (lines 139
  through 142) stays.
- **Details:** The watch-outs carry forward the old rule's substance: stay inline and never `context: fork` for
  data-shaped composition, keep the explicit proceed instruction, prefer surfacing interpretation context over bare
  values, degrade gracefully when the callee is unavailable, and still prefer inline discovery for genuinely small
  one-off lookups like a docs directory. The "Declare the Skill tool in `allowed-tools`" rule (lines 80 through 83) is
  reconciled with the V9 enforcement determination: either the rule stands and the eight-plus existing
  readability-guidance callers are fixed alongside the rerouting, or the rule is corrected to match observed behavior.
  The cross-references section (lines 171 through 175) gains a pointer to the fork-specific worked example in
  `writing-effective-instructions.md` so the loosened rule and that example read coherently side by side (V14).
  Consumer repos that ran `guidance init` keep the stricter vendored copy until they run `guidance update`; the plan
  notes this lag rather than attempting to push updates outward (V15).

#### `han-plugin-builder/skills/guidance/references/skill-building-guidance/graceful-degradation.md`

- **Change:** Update lines 95 and 96, which state that skills discover config inline rather than calling a data-fetch
  sub-skill, to name the han-config read mode as the config path and keep inline discovery for non-config project
  values.
- **Evidence:** (E12); the requirement set at plan review.
- **Standards:** Guidance stays consistent with `skill-composition.md` after its loosening.

#### The 11 vendored `config-rule.md` copies outside `han-core`

- **Change:** Delete `references/config-rule.md` from `han-atlassian`, `han-coding`, `han-communication`,
  `han-documentation`, `han-feedback`, `han-github`, `han-linear`, `han-planning`, `han-plugin-builder`,
  `han-reporting`, and `han-research`. The canonical copy at `han-core/references/config-rule.md` stays, and its
  "vendored byte-identical" sentence updates to say the file lives only in han-core.
- **Evidence:** (E4), (E8). The reference sweep (V8) refuted the first draft's assumption that the deferral sentences
  were the copies' only consumers: about 13 skills in `han-atlassian`, `han-coding`, `han-planning`, and `han-research`
  also link the file mid-body. Those links are rewritten as part of the 39-file rerouting entry above (V8, V13), and
  the deletion lands only after a final per-plugin grep for `config-rule` comes back empty.
- **Standards:** One canonical source per concept; the change removes the hand-synced invariant no tooling guards (E8).

No version bump is included; versioning is handled at release time.

## Evidence Summary

### E1: The probe mechanism, an inline command in every skill's `## Project Context` block

- **Source:** `han-core/skills/project-discovery/SKILL.md:12-22`
- **Finding:**
  ```
  - .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

  When the `.han/config.md` probe returns content, apply it per the config rule in
  [../../references/config-rule.md](../../references/config-rule.md). When it returns nothing, no project config is
  present and nothing changes.
  ```
- **Relevance:** Config content enters a skill's context through Claude Code's dynamic command injection, spliced into
  the prompt before the model runs, not through a Read tool call. This is the read mechanism any centralizing skill
  would be replacing or wrapping.

### E2: The probe runs outside `allowed-tools` gating

- **Source:** `han-core/skills/project-discovery/SKILL.md:9`; `han-communication/skills/readability-guidance/SKILL.md:10`
- **Finding:** No shipped skill lists `Bash(cat *)` in `allowed-tools` (zero matches across all 39), yet every body runs
  the `cat` probe. `readability-guidance` allows only `Read`.
- **Relevance:** The probe is a pre-processing step, not a model tool call, so it costs the skill nothing at runtime.
  That is part of why replacing it with a sub-skill dispatch is a downgrade.

### E3: All 39 shipped skills carry the identical probe

- **Source:** grep for the probe line across `han-*/skills/*/SKILL.md`
- **Finding:** 39 of 39 shipped skills across all 12 plugins carry the probe: han-atlassian (6), han-coding (9),
  han-communication (2), han-core (1), han-documentation (3), han-feedback (1), han-github (3), han-linear (1),
  han-planning (5), han-plugin-builder (3), han-reporting (2), han-research (3). The 10 other SKILL.md files in the
  repo are local dev skills and spike artifacts, not shipped skills.
- **Relevance:** Read coverage is already complete and uniform; the unmet need is authoring and reporting, not reading.

### E4: Every consuming skill defers interpretation to the vendored config rule

- **Source:** `han-documentation/skills/project-documentation/SKILL.md:22-24`; identical sentence verified in
  spot-checks across plugins
- **Finding:** The deferral sentence in E1 appears verbatim after every probe; the set of files mentioning
  `config-rule` and the set carrying the probe are identical.
- **Relevance:** Skills do not duplicate schema logic locally, so the new skill can defer the same way and add only
  writer-specific rules.

### E5: The complete schema is four tokens

- **Source:** `han-core/references/config-rule.md:8-34`
- **Finding:** Three frontmatter keys: `output-directory` (relative base path), `default-swarm-size`
  (`small`/`medium`/`large`/`dynamic`, case-insensitive, trimmed), and `writing-voice` (relative file path). Plus one
  section, `## Extra Agents` (one agent per list line, `plugin:agent` or bare name, matched case-insensitively).
- **Relevance:** This is the entire surface the new skill must show, validate, and edit.

### E6: Precedence and degradation semantics

- **Source:** `han-core/references/config-rule.md:36-47, 70-87`
- **Finding:** Precedence: explicit user input, then `.han/config.md`, then CLAUDE.md's `## Project Discovery`, then
  the project-discovery file, then built-in defaults. Extra-agents is additive (union), not replacing. "A bad config
  can never fail a skill run; the worst it can do is be ignored," with one exception: a `writing-voice` value naming a
  missing file triggers an ask-the-user question.
- **Relevance:** The write path must honor additive extra-agents semantics and preserve unrecognized content. The
  silent-ignore rule is also why hand-editing errors currently give no feedback, which the show mode fixes.

### E7: Working-directory scoping and containment

- **Source:** `han-core/references/config-rule.md:49-60`
- **Finding:** The file is looked up only in the directory where the skill is running. `output-directory` must be a
  relative path whose normalized form stays inside the working directory. Absolute paths, drive prefixes, and `..`
  escapes are refused.
- **Relevance:** The write path must resolve `.han/config.md` against the invoking working directory and refuse the
  same values readers refuse, so it never writes a value the readers will ignore.

### E8: Twelve byte-identical vendored copies of config-rule.md, synced by hand

- **Source:** `find . -name config-rule.md` plus `md5`; CI and script searches
- **Finding:** All 12 copies hash to `52539cead3b59156cb25072d85697647`, canonical at
  `han-core/references/config-rule.md:6`. No sync script, CI check, or pre-commit hook guards the invariant; CI runs
  only Prettier/ShellCheck lint and bats tests.
- **Relevance:** The plan avoids touching the read contract at all, so no re-vendoring pass is needed for this change.

### E9: The canonical file shape

- **Source:** `docs/configuration.md:33-65`
- **Finding:**
  ```markdown
  ---
  output-directory: docs/han
  default-swarm-size: dynamic
  writing-voice: docs/our-writing-voice.md
  ---

  ## Extra Agents

  - my-plugin:payments-domain-expert
  - accessibility-reviewer
  ```
- **Relevance:** This is the shape the write path must produce and preserve: YAML frontmatter for scalars, then the
  `## Extra Agents` markdown section with a bullet list.

### E10: The docs state Han cannot write the file today

- **Source:** `docs/configuration.md:14-16`
- **Finding:** "**You write the file; Han cannot.** Han cannot ship or seed a project-level config from the plugin
  side. You create `.han/config.md` by hand..."
- **Relevance:** The direct statement of the constraint this skill lifts, and a doc line the change must update.

### E11: Nothing in the suite writes .han/config.md; project-discovery is the nearest precedent

- **Source:** repo-wide negative searches for any write to `.han/config.md`; `han-core/skills/project-discovery/SKILL.md:104-119`
- **Finding:** Zero matches for any skill, script, or agent writing the file's content. `project-discovery` has
  `Read, Write, Edit` in `allowed-tools` and writes only a consent-gated one-line pointer to the file in CLAUDE.md or
  AGENTS.md.
- **Relevance:** The write side is greenfield, and the consent-gated-mutation pattern to follow already exists in the
  same plugin.

### E12: Guidance names sub-skill config reads as the pattern to avoid

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/graceful-degradation.md:93-96`;
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md:87-88, 131-133`
- **Finding:** "Skills discover config inline (context injection + Read) rather than calling a data-fetch sub-skill.
  This avoids the early-exit failure mode documented in `writing-effective-instructions.md`." The composition guidance
  goes further. It names "a config setting" as an example of the disallowed data-fetch shape. Its inline sub-skill
  exception (the pattern `readability-guidance` uses) explicitly excludes fetching "a few values" like config settings,
  reserving the exception for a whole shared standard or reference set (V2).
- **Relevance:** This is the guidance the read rerouting conflicts with as written, and it is the file the plan
  loosens. Its inline-exception properties (inline, never fork; whole shared reference; caller finishes its own
  workflow) are the discipline the han-config read mode is designed to satisfy.

### E13: Every schema addition to date rippled through all vendored copies and consumers

- **Source:** `git log --oneline -- han-core/references/config-rule.md` (`cfdfff7`, `38bead9`, `89feac0`);
  `git show 89feac0 --stat`
- **Finding:** Three additive commits; the writing-voice addition touched 19 files: all vendored `config-rule.md`
  copies, `docs/configuration.md`, and every adopting consumer skill, agent, and long-form doc.
- **Relevance:** Documents the schema-growth ripple. The new skill becomes one more consumer to update when the schema
  grows, and its deferral to the vendored rule (rather than restating the schema) keeps that cost to the
  writer-specific parts.

### E14: Per-token consumer counts

- **Source:** grep across `han-*/skills/*/SKILL.md`; `docs/configuration.md:78-85`
- **Finding:** `writing-voice` named in 23 skills; `default-swarm-size` in 8 (matching the docs' "eight sizing-aware
  skills"); `## Extra Agents` in 9; the literal `output-directory` string in only 3, with others using resolved forms
  like `{output_directory}` or the generic deferral sentence.
- **Relevance:** Most consumers never restate token names, confirming the deferral pattern the new skill should follow.

### E15: The taxonomy test lands on skill, not agent

- **Source:** `han-plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md`
- **Finding:** "Deterministic, flowchartable, repeatable process? → Skill."
- **Relevance:** Show and set against a fixed four-token schema with fixed validation rules is flowchartable end to
  end; nothing in the schema requires contextual judgment.

### E16: Skill layout convention

- **Source:** `han-core/skills/project-discovery/` directory listing
- **Finding:** `SKILL.md` plus a `references/` folder holding a template the body links to.
- **Relevance:** The layout `han-core/skills/han-config/` follows.

### E17: allowed-tools conventions

- **Source:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-bash-permissions.md:14-45, 90-104`
- **Finding:** One `Bash(...)` entry per command prefix; prefer `find` over `ls` for discovery.
- **Relevance:** Governs the new skill's frontmatter.

### E18: No existing test coverage for config behavior

- **Source:** `find test -iname "*config*"` (empty)
- **Finding:** No bats tests exercise config parsing, precedence, or containment anywhere in `test/`.
- **Relevance:** The new skill's validation behavior lands with no automated test precedent to extend; verification is
  manual, consistent with how the rest of the suite's skills are tested.

### E19: Prior research on config extensibility is stale on its counts

- **Source:** `docs/research/han-config-extensibility.md:94-96` (a folder `docs/research/CLAUDE.md` marks as historical)
- **Finding:** The research claims 26 of 49 SKILL.md files carry a `## Project Context` block; current evidence (E3)
  shows 39 of 39 shipped skills do.
- **Relevance:** Treat that document as historical context only; the counts in this report are re-derived from the
  current codebase.

## Validation Results

An adversarial validation pass re-verified every load-bearing evidence item against the current codebase, git history,
and file hashes, then attacked the root cause, the fix, and the scope decision. The evidence layer survived intact;
the fix scope and the write-path detail did not, and the plan above already carries the resulting adjustments.

### Counter-Evidence Investigated

#### V1: The 39-skill probe count and byte-identical vendoring hold up

- **Hypothesis:** E1, E3, and E8 overstate uniformity; some probes or vendored copies have drifted.
- **Investigation:** Re-ran the probe grep (39 matches, same per-plugin breakdown), re-hashed all 12 `config-rule.md`
  copies (all `52539cead3b59156cb25072d85697647`), re-ran the git log (the same three commits as E13).
- **Result:** Confirmed
- **Impact:** The "read path is complete and uniform" premise stands.

#### V2: The guidance rules out even the inline-exception route for config reads

- **Hypothesis:** The E12 quote is narrower than claimed, and `readability-guidance` (an inline sub-skill surfacing a
  shared standard into ten-plus callers) is a working precedent for routing config reads through a skill.
- **Investigation:** Read `graceful-degradation.md:93-96` in context and
  `skill-composition.md:85-150`. The composition guidance names "a config setting" as an example of the disallowed
  data-fetch shape (lines 87-88), and its inline sub-skill exception explicitly excludes fetching "a few values" like
  config settings (lines 131-133), reserving the exception for a whole shared standard or reference set.
- **Result:** Confirmed, and stronger than the original citation.
- **Impact:** E12 was extended with the composition-guidance citations. The first draft's scope decision stood on this
  finding; the user reversed that scope at review, and the finding now anchors which guidance text the plan loosens
  and which inline-sub-skill discipline the read mode follows (see Adjustments Made).

#### V3: The fix scope missed four stale-reference sites

- **Hypothesis:** `docs/configuration.md:14-16` is the only surface asserting the write gap, and the Changes list
  covers everything that goes stale.
- **Investigation:** Read all 171 lines of `docs/configuration.md` (no other "Han cannot write" line exists), then
  grepped the repo's descriptions of han-core: `CLAUDE.md:10, 73, 78`, `docs/choosing-a-han-plugin.md:35`, and
  `han-core/README.md:5, 8` all describe han-core's skill set as "the project-discovery skill" (singular).
- **Result:** Refuted: the original Changes list was incomplete.
- **Impact:** Three change entries were added or extended; see Adjustments Made.

#### V4: No name collision, and the no-version-bump note matches repo practice

- **Hypothesis:** `han-config` collides with an existing name, and skipping the version bump contradicts
  `docs/semantic-versioning.md`, which names "adding a new skill" as a minor-bump trigger.
- **Investigation:** Repo-wide grep for `han-config` outside `docs/plans/` found zero hits. The most recent
  skill-adding commit (`2b6b6cb`) states "No version bump; versioning is left to the release process," and the
  schema-adding commit `89feac0` shipped 19 files with no `plugin.json` diff.
- **Result:** Confirmed on both points.
- **Impact:** None.

#### V5: The write path's shape-preservation promise was underspecified

- **Hypothesis:** "Preserve unrecognized content and the canonical shape" is asserted but not specified against edge
  cases: frontmatter-only files, unrecognized keys interleaved with recognized ones, `writing-voice` resolving to a
  directory, `.han` existing as a file, whitespace and case variants, duplicate extra-agents entries.
- **Investigation:** Confirmed `config-rule.md:15-16` covers trim-and-case handling on the read side. But the planned
  SKILL.md detail named what to preserve without naming how the edit is performed, and E18 confirms no test surface
  exists to catch a regression.
- **Result:** Partially Refuted: design property asserted without the mechanics that guarantee it.
- **Impact:** The SKILL.md change entry now names the edit strategy (surgical line-anchored edits; full-file generation
  only on first write, from the template) and explicit refusal behaviors for the `.han`-as-file and
  voice-path-is-a-directory cases; see Adjustments Made.

#### V6: The per-token consumer counts are accurate

- **Hypothesis:** E14's counts (23 writing-voice, 8 swarm-size, 9 extra-agents, 3 literal `output-directory`) are
  inflated or stale.
- **Investigation:** Re-ran the greps; all counts matched, and `docs/configuration.md:78-85` names exactly the eight
  sizing-aware skills.
- **Result:** Confirmed
- **Impact:** None; supports the deferral-pattern premise.

#### V7: Reading this plan folder respected its own access guard

- **Hypothesis:** The validation pass read `docs/plans/` content without the explicit instruction its `CLAUDE.md`
  requires.
- **Investigation:** The validation task named this file's path explicitly, satisfying the folder's
  explicit-instruction carve-out; the validator only read it.
- **Result:** Confirmed: no provenance violation.
- **Impact:** None.

A second validation pass ran after the user made the read rerouting a requirement. It attacked the revised design:
the vendored-copy retirement, the skill-invokes-skill mechanics, the writing-voice resolution chain, the
dependency-free plugins, the guidance loosening's coherence, and the uniform-replacement claim. It refuted six
assumptions, and the plan above already carries the resulting adjustments.

#### V8: The deferral sentences are not the vendored copies' only consumers

- **Hypothesis:** Deleting the 11 vendored `config-rule.md` copies is safe once the probe and deferral sentences are
  gone.
- **Investigation:** Grepped every plugin tree for `config-rule`. About 13 skills in `han-atlassian`, `han-coding`,
  `han-planning`, and `han-research` link `../../references/config-rule.md` mid-body, outside the probe block, for
  example the swarm-size band-selection step at `han-coding/skills/architectural-analysis/SKILL.md:123`.
- **Result:** Refuted: the deletion as first written would ship dangling relative links.
- **Impact:** The rerouting entry now enumerates and rewrites the mid-body citations per file, and the deletion is
  gated on a final per-plugin grep coming back empty; see Adjustments Made.

#### V9: The `Skill`-in-`allowed-tools` rule is contradicted by shipped skills

- **Hypothesis:** The guidance rule that a skill invoking another skill must list `Skill` in `allowed-tools`
  (`skill-composition.md:78-83`) matches current practice.
- **Investigation:** At least eight shipped skills instruct a `han-communication:readability-guidance` invocation
  without listing `Skill` (for example `han-coding/skills/coding-standard/SKILL.md:182` against its line-10
  `allowed-tools`). Only the three orchestration skills declare it.
- **Result:** Refuted: either the rule is unenforced or eight-plus existing invocations are broken.
- **Impact:** Implementation begins with an empirical enforcement determination, then either fixes the existing eight
  and declares `Skill` everywhere, or corrects the guidance rule; see Adjustments Made.

#### V10: Rerouting creates an untested depth-2 nested invocation and a duplicate config read

- **Hypothesis:** The single-hop spike evidence behind the inline exception covers the rerouted call graph.
- **Investigation:** `readability-guidance` carries the probe at `SKILL.md:14` and resolves `writing-voice` from it,
  so after rerouting, a caller that reads config and later invokes readability-guidance would nest a second han-config
  call inside a Skill call. The spike (`skill-composition.md:118-124`) tested one inline sub-skill from one caller.
- **Result:** Refuted as a completeness claim: the first revision did not address the scenario.
- **Impact:** The read mode gained the context-dedupe rule (readability-guidance invokes han-config only when no
  config was surfaced this run), and the remaining depth-2 path gets a manual spike test before rollout; see
  Adjustments Made.

#### V11: A fifth plugin lacks the han-core dependency

- **Hypothesis:** Exactly four plugins do not depend on `han-core`.
- **Investigation:** Read every `.claude-plugin/plugin.json`. `han-reporting` depends only on `han-communication`,
  and its two shipped skills carry the probe.
- **Result:** Refuted: the list is five plugins and nine skills, not four and seven.
- **Impact:** The Scope decision section's degradation accounting now includes `han-reporting`; see Adjustments Made.

#### V12: docs/configuration.md asserts the vendoring in a second place

- **Hypothesis:** The planned `docs/configuration.md` edits cover every line the vendored-copy retirement makes stale.
- **Investigation:** Lines 24 and 25 state the rule file is "vendored byte-identical into each plugin," separate from
  the write-gap bullet and the read-mechanism description.
- **Result:** Refuted as completeness.
- **Impact:** The `docs/configuration.md` change entry now names lines 24 and 25; see Adjustments Made.

#### V13: The uniform-replacement claim understated the diff for about 13 files

- **Hypothesis:** One identical replacement text describes the whole rerouting diff in all 39 files.
- **Investigation:** Cross-referencing V8's file list: the files with mid-body citations need file-specific edits
  beyond the uniform probe-and-deferral swap.
- **Result:** Refuted.
- **Impact:** The rerouting entry now separates the uniform swap from the per-file citation rewrites; see Adjustments
  Made.

#### V14: A third guidance file carries the config-sub-skill anti-pattern example

- **Hypothesis:** Only `skill-composition.md` and `graceful-degradation.md` need updates for guidance coherence.
- **Investigation:** `writing-effective-instructions.md:129-168` holds a worked before/after example whose "before" is
  a forked config-reading sub-skill. The example stays accurate (it is fork-specific, and the read mode is inline),
  but nothing links it to the loosened rule.
- **Result:** Partially Refuted: accurate but uncross-referenced.
- **Impact:** The `skill-composition.md` change entry now adds the cross-reference pointer; see Adjustments Made.

#### V15: Consumer repos keep the stricter vendored guidance until they update

- **Hypothesis:** Updating the canonical guidance files is sufficient for the loosening to take effect everywhere.
- **Investigation:** `guidance init` vendors the guidance references into consumer repos and `update` replaces them in
  full (`han-plugin-builder/skills/guidance/SKILL.md:63-97`), so already-initialized repos keep enforcing the old rule
  until someone runs `guidance update`.
- **Result:** Partially Refuted as a completeness claim.
- **Impact:** The guidance change entry and Remaining Risks now note the lag; the plan does not attempt to push
  updates outward.

### Adjustments Made

- Extended E12 with the `skill-composition.md:87-88, 131-133` citations, which name config settings as the disallowed
  data-fetch shape even under the inline sub-skill exception (triggered by V2).
- Added a `CLAUDE.md` change entry, a `docs/choosing-a-han-plugin.md` change entry, and extended the
  `han-core/README.md` entry to cover its top-of-file prose, so every surface describing han-core as a single-skill
  plugin is updated (triggered by V3).
- Expanded the SKILL.md change entry with the explicit edit strategy and the refusal behaviors for `.han` existing as
  a file and `writing-voice` resolving to a directory (triggered by V5).
- Reversed the first draft's scope decision at user direction: every shipped skill's config read now routes through
  the han-config read mode, the skill-composition and graceful-degradation guidance loosen from refusal to watch-outs,
  and the 11 vendored `config-rule.md` copies outside han-core retire. The plan's Scope decision section, the read
  mode, and five Changes entries carry the revision (user review feedback; V8 through V15 validate the revised
  design).
- Added the per-file rewrite of about 13 mid-body `config-rule.md` citations to the rerouting entry, and gated the
  vendored-copy deletion on an empty per-plugin grep (triggered by V8 and V13).
- Added the empirical `Skill`-in-`allowed-tools` enforcement determination as the first implementation step, with the
  two reconciliation paths (triggered by V9).
- Added the config-dedupe rule to the read mode and readability-guidance, plus a pre-rollout spike test for the
  remaining depth-2 nesting path (triggered by V10).
- Corrected the dependency-free plugin accounting from four plugins and seven skills to five and nine, adding
  `han-reporting` (triggered by V11).
- Extended the `docs/configuration.md` entry to lines 24 and 25, added the `writing-effective-instructions.md`
  cross-reference to the guidance entry, and noted the `guidance update` vendoring lag (triggered by V12, V14, V15).

### Confidence Assessment

- **Confidence:** High on the evidence layer (every item independently re-verified with no stale citation found).
  Medium on the revised fix: the second validation pass rated the revision Low as first written, on six refuted
  assumptions (V8 through V13), and every one of those findings is now folded into the plan; what keeps the rating at
  Medium rather than High is that two of the fixes prescribe verification work (the V9 enforcement determination and
  the V10 nesting spike) whose outcomes cannot be known before implementation starts.
- **Remaining Risks:** No automated test coverage exists or is planned for the write and validation logic (E18), so
  the edge-case behaviors specified in the SKILL.md entry rely on manual verification, consistent with how the suite's
  other skills are verified. The exact behavior of surgical edits on unusual real-world config files cannot be
  verified until the skill is built and run. The depth-2 nested invocation path (V10) could be harmless or could
  reproduce the early-exit failure one level deeper; only the planned spike settles it. The `Skill`-in-`allowed-tools`
  question (V9) may reveal a latent bug in eight-plus shipped skills that predates this work. Consumer repos that
  vendored the guidance keep the stricter rule until they run `guidance update` (V15).

## Coding Standards Reference

| Standard | Source | Applies To |
| --- | --- | --- |
| Config interpretation contract: schema, precedence, containment, degradation | `han-core/references/config-rule.md` | The skill's validation and write behavior |
| Inline sub-skill discipline: inline never fork, explicit continuation, caller owns its workflow | `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-composition.md:114-142` | The han-config read mode and the 39 rerouted skills |
| Skill authoring flow: build via `/han-plugin-builder:skill-builder` | `CLAUDE.md`, "Creating skills, agents, or other plugin aspects" | `han-core/skills/han-config/SKILL.md` |
| One `Bash(...)` entry per prefix; find over ls | `han-plugin-builder/.../allowed-tools-bash-permissions.md` | The skill's `allowed-tools` frontmatter |
| Coverage rule: every skill gets a long-form doc, a README scent line, and an index entry | `docs/templates/coverage-rule.md`; CLAUDE.md conventions | The three documentation changes |
| One canonical source per concept; indexes complete, not counted | `CLAUDE.md` conventions | `docs/configuration.md`, README, and index edits |
| Writing voice: no em-dashes, direct second person, plain verbs | `han-communication/references/writing-voice.md` | All new prose |

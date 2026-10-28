# Round 1: software-architect

Scope: the structure of the `han-core:load-han-config` loader, the consumer rewire across the shipped skills, and the
guidance edits around it. Every count below was measured on `main` at `abba73a` unless the discovery notes already
carried it. Findings are ordered by impact.

## SA-1: The loader surfaces raw file content under today's labels, not resolved values

- **Addresses:** issue-203.md#open-questions ("Does the personal-config Read survive consolidation?"), the "resolved
  values" case in issue-203.md#proposal step 2, config-rule.md#the-two-files-the-two-probes-and-the-personal-read.
- **Principle:** SRP. The loader owns one thing, getting both files into context once. config-rule.md keeps owning
  interpretation, and each skill keeps owning how a setting applies to it.
- **Recommendation:** the loader surfaces exactly what the 65-word block yields today, under byte-identical labels:
  the `personal config directory` value, the `project .han/config.md` value, and the content of the personal file it
  reads with the Read tool. It resolves nothing and emits no note.
- **Why not resolved values in a fixed shape:** the loader cannot finish the job, so a resolved shape splits
  interpretation across two places.
  - Precedence levels 1, 4, 5, and 6 (explicit input, CLAUDE.md, project-discovery, built-in defaults,
    config-rule.md#precedence) are per skill. The loader could merge only levels 2 and 3.
  - "A setting that does not apply to the running skill: ignore it silently" (config-rule.md#degradation-and-the-one-line-note)
    means a note is right for one caller and wrong for another. The loader cannot emit it.
  - A missing `writing-voice` file asks the user a question (config-rule.md#schema). That must happen in a prose skill
    that uses the voice, not in a loader that every non-prose skill also calls.
  - Byte-identical labels mean `readability-guidance` Step 1, `edit-for-readability` lines 82-84, `pairing` line 49,
    and `project-discovery` line 112 read the same thing whether the loader or an old-style block (SA-6) put it there.
    A new shape would force those four to handle two shapes.
- **Personal Read:** it survives, and it moves into the loader. The reason config-rule.md gives, that a probe "cannot
  prompt and cannot degrade", still holds, because the loader also uses the Read tool rather than a probe. What moves
  is who carries the instruction, not how the read happens. config-rule.md's opening paragraph and the first bullet
  under its "two probes and the personal read" heading change wording (SA-8).
- **Trial implication:** the trial (issue-203.md#proposal step 2) should test this raw shape, because it is what ships.
  The values in question are raw file content plus one directory path, a lighter load than a whole standard, which is
  exactly the gap the issue names.
- **YAGNI evidence:** this is the strictly simpler of the two shapes. It needs no new schema and no consumer reading
  change.
- **Contract (pinned):** see SA-2 for the rendered field layout two components must agree on.

## SA-2: `han-core/skills/load-han-config/SKILL.md`, step by step

- **Addresses:** issue-203.md#proposal step 3. Precedents: `readability-guidance/SKILL.md` (an inline surfacing
  skill with an explicit RETURN instruction) and `project-discovery/SKILL.md` (probes plus the identical block).
- **Shape:** move the probe, the grant, and the instruction verbatim into one file, then add the hand-back.

```markdown
---
name: load-han-config
description: >
  Brings this run's Han configuration (the personal and the project .han/config.md) into the calling skill's own
  context, once per run, so the caller applies it per config-rule.md. Use when a Han skill's Project Context says to
  resolve configuration with han-core:load-han-config. Runs in the caller's context and hands control straight back;
  it resolves no setting, shows no note, and produces no deliverable. Does not write or edit .han/config.md.
allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

# Load Han Configuration

You invoked `load-han-config` to bring this run's Han configuration into your own context. This skill is inline: what
it surfaces stays in your context after it returns. It is not a stopping point or a final answer.

## Step 1: Read the personal file

Use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read that returns no file
is no personal configuration: continue silently.

## Step 2: Hand back

The `personal config directory` and `project .han/config.md` values above, and the personal file you just read, are
this run's Han configuration. They replace any copy surfaced earlier in this context. Apply them per
[config-rule.md](../../references/config-rule.md) at the point your own workflow uses a setting. Say nothing about the
configuration here. RETURN to the skill that invoked you and continue with its next step.
```

- **Rendered worked example** of what the caller's context holds after the call (project file present, no personal
  file):

```text
- personal config directory: /home/tami/.claude
- project .han/config.md: ---
output-directory: docs/han
---
[Read /home/tami/.claude/.han/config.md -> file does not exist]
```

- **"Already resolved" reporting:** the loader does not report it and cannot detect it. Its probes inject at load,
  before any instruction runs, so a second invocation has already paid its cost. It declares *latest wins* ("replace
  any copy surfaced earlier") instead, so a second load is harmless and the newest content governs. SA-4 covers the
  dedupe on the caller's side.
- **Link resolution:** the relative `../../references/config-rule.md` inside the loader resolves to the canonical
  `han-core/references/config-rule.md`, not to a vendored copy.
- **Out of scope, said explicitly:** the July attempt's `show` and `set` modes (origin `han-config-skill`
  investigation.md, "Behavior of the new skill" items 2 and 3) are not in issue #203's proposal. They are not planned.
  See the YAGNI list.
- **Process:** CLAUDE.md requires `/han-plugin-builder:skill-builder` for the new skill. The long-form doc follows
  `docs/templates/coverage-rule.md#the-inline-guidance-variant`, as readability-guidance's does.

## SA-3: The consumer line, its placement, and the allowed-tools change (35 skills)

- **Addresses:** issue-203.md#proposal step 4, and the open question "Is one line enough when a skill is invoked
  directly?"
- **Who gets it:** the 35 shipped skills in plugins that depend on han-core. That is han-core 2, han-documentation 3,
  han-research 3, han-planning 6, han-coding 11, han-github 3, han-atlassian 6, and han-ddd 1. `readability-guidance`
  carries a variant (SA-5). The other 10 are covered in SA-5 and SA-6.
- **Exact text, pinned byte for byte:** use the issue's own line, unchanged.
  `Resolve configuration with \`han-core:load-han-config\` if you have not already this run.`
- **Placement:** the line goes inside `## Project Context`, at the spot the 65-word paragraph held. The two config
  probe lines are deleted, and any other probes (branch, CLAUDE.md, project-discovery.md) stay above the line. One
  fixed location keeps the sweep and the grep gate mechanical. Where a skill's Project Context held only the config
  probes, the heading stays and holds the line alone.
- **Continuation:** the "proceed" instruction lives in the loader's Step 2, following readability-guidance's
  precedent. The caller adds none, so the issue's wording holds. The trial's worst-case arm (SA-10, Phase B) must run
  this exact line with no caller-side continuation, since that is what ships.
- **allowed-tools:** remove `Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")` from all 35. Whether to add
  `Skill` is decided by SA-7.
- **Worked before/after** (`han-planning/skills/plan-a-feature/SKILL.md`):

```diff
 allowed-tools:
-  Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(mkdir *), Bash(cp *),
-  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
+  Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(mkdir *), Bash(cp *)
 ...
 ## Project Context
-- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
-- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`
-
-As your first action, use the Read tool on ... [65 words] ... a file that reads but cannot be used.
+Resolve configuration with `han-core:load-han-config` if you have not already this run.
```

- **Sweep hazards the uniform swap misses (measured):**
  - `han-ddd/skills/ddd-analysis/SKILL.md` lines 26-30 wrap the 65-word paragraph at different points than the other
    44 files. A line-based replace misses it, so the sweep script must match the paragraph with whitespace normalized.
  - Three bodies cite the probe by name outside the block. `han-core/skills/pairing/SKILL.md:49` says "the
    configuration probed above". `han-core/skills/project-discovery/SKILL.md:112` says "The Project Context probe
    above". `readability-guidance` lines 46 and 48 are handled in SA-5. Each gets a hand edit that names the loader as
    the source.
  - A precedent shows why the gate matters: 0e5f44f, "The config-probe migration reached 42 of the 43 skills", is a
    hand sweep that missed `pairing` and took the skill down.
- **Direct invocation:** the line names the skill by its qualified name. The loader's description must say when to use
  it, which SA-2 does. The trial needs a top-level arm where the consumer runs with no prior config in context
  (SA-10).

## SA-4: Idempotence, meaning what "this run" means and why the check sits in the caller

- **Addresses:** issue-203.md#the-duplication ("copies two and three tell a model that has already resolved the config
  to resolve it again"), and V10 in the July investigation.
- **Assessment:** the conditional in the consumer line is the right mechanism, and the only possible one. A probe
  cannot be conditional, so the skip has to happen before the loader is invoked, and only the caller's line can do
  that. The line's check is content-based: the model looks for the surfaced values in context. That has two good
  properties.
  - After compaction drops the earlier copy, the check fails and the skill reloads. It heals itself.
  - Inside a chain (pairing to tdd, an Atlassian wrapper to plan-a-feature, a caller to readability-guidance), the
    first skill loads and the later ones skip.
- **The gap: "this run" carries only prose.** Pin it in config-rule.md (SA-8) as: *a run begins when the person
  invokes a skill and ends when that skill finishes; every skill it invokes is part of the same run. A skill the person
  invokes later in the same session is a new run and loads again.* Without that definition, a second slash command in
  a long session could reuse a file the person edited in between. With it, the second command reloads, and the
  loader's "latest wins" sentence (SA-2) makes the newer copy govern.
- **On a second invocation the loader** does nothing special and declares that its copy supersedes the earlier one
  (SA-2). No detection step is added. It could not run before the probes anyway.
- **What the docs must now say:** `docs/configuration.md` line 7, "Every Han skill reads both files on every run", is
  still true under the definition above, but it needs one added clause: "a skill invoked by another skill uses what
  the first one loaded". The discovery notes flag this.

## SA-5: The two chain-target guidance skills: explanation-guidance drops its block, readability-guidance takes the line with a fallback

- **Addresses:** issue-203.md#the-duplication (the plan-a-feature to readability-guidance to explanation-guidance
  chain), and V10.
- **explanation-guidance:** delete the whole block (both probes, the 65-word paragraph, and the Bash grant). Add no
  loader line. Evidence: its body names no schema setting. A grep for `output-directory`, `default-swarm-size`,
  `writing-voice`, `Extra Agents`, and `voice` returns 0. config-rule.md#degradation-and-the-one-line-note says a
  setting that does not apply "ignore it silently". The block is dead weight, and deleting it is strictly simpler than
  rewiring it. allowed-tools becomes `Read`.
- **readability-guidance:** drop its probes and carry the line plus one fallback sentence, because han-communication
  does not depend on han-core (SA-6). Pinned text:
  `Resolve configuration with \`han-core:load-han-config\` if you have not already this run. If that skill is not
  available, treat this run as having no configuration.`
  - Step 1's first bullet changes only its source phrase. "When either `.han/config.md` probe supplied a
    `writing-voice` value" becomes "When the run's `project .han/config.md` value or personal `.han/config.md` supplied
    a `writing-voice` value". Line 48 changes from "the probe reported" to "the run's `personal config directory`
    value".
  - allowed-tools becomes `Read`.
  - Every shipped caller (23 distinct skills by the discovery measurement, 2 of them in han-reporting with the old
    block) has config in context before it calls readability-guidance, so the fallback fires only on a direct
    invocation without han-core. The
    worst case is the built-in voice instead of a configured one, on a skill whose description positions it as a
    sub-skill.
- **Result for the issue's chain:** one copy of the config and one instruction, down from three.
- **Not pinned:** how the model recognizes that "that skill is not available" is prose only. The Skill tool's
  response to an unknown skill name decides it.
  Unverified: could not inspect the Skill tool's response to an uninstalled qualified skill name, because no run
  without han-core installed was available in this session.

## SA-6: Degradation for the plugins without han-core: 10 skills, not 9; 8 keep the old block

- **Addresses:** V11 (July). The count is now 10, because explanation-guidance shipped after July. The plugins are
  han-communication 3, han-feedback 1, han-linear 1, han-plugin-builder 3, and han-reporting 2.
- **Options weighed:**
  - **Add a han-core dependency.** Rejected at this altitude. CLAUDE.md states han-communication "depends on nothing",
    and han-feedback and han-linear "depend on no other Han plugin". The plugin dependency graph is a relationship
    between deployable units. Deferred to `system-architect`.
  - **Accept the degradation (the July choice).** Users who install these plugins alone silently lose
    `output-directory` and `writing-voice`. That is a regression with no finding that asks for it.
  - **Keep the old block (recommended)** in the 8 skills nobody invokes from another skill: edit-for-readability,
    han-feedback, work-items-to-linear, agent-builder, guidance, skill-builder, html-summary, and stakeholder-summary.
    The issue itself says "a skill invoked on its own loads the block once" and that suite-wide duplication "is not the
    problem". These 8 cause no in-context duplication, so the issue's finding does not reach them, and keeping the
    block changes nothing for their users.
- **Cost of keeping it:** 8 copies of the probe and grant remain, still guarded by `scripts/han-config-dir.bats`. A
  lookup change still lands in the script alone (SA-9). A wording change to the block touches 8 files, not 45.
- **YAGNI evidence:** this is the strictly simpler structure that satisfies the finding. It adds no fallback path and
  changes no dependency.
- **Codex:** every han-* plugin ships a Codex manifest.
  Unverified: could not establish whether Codex runs context-injection probes or lets one skill invoke another, because
  nothing in the repo states it (discovery notes, "Gaps"). If Codex cannot run Skill calls, the 35 rewired skills lose
  config under Codex. Deferred to `system-architect` as a cross-runtime concern.

## SA-7: `Skill` in allowed-tools (V9) is decided by the trial, with both branches pinned

- **Evidence:** 23 skills invoke `han-communication:readability-guidance`, and only 6 list `Skill` (discovery notes,
  Measurements). This planning run invoked explanation-guidance from plan-implementation, whose allowed-tools omit
  `Skill`, and it ran. `skill-composition.md#declare-the-skill-tool-in-allowed-tools` says "Without it the Skill call
  is not permitted".
  Unverified: could not determine the permission mode of the observing session, because it is not recorded. A
  pre-approved or bypass mode would hide a prompt.
- **Recommendation:** add one trial arm that runs in default permission mode, with a consumer that lacks `Skill`.
  - **If it prompts:** the sweep adds `Skill` to all 36 rewired skills. The 2 han-reporting skills, which call
    readability-guidance without it today, are a pre-existing bug fixed in the same mechanical pass.
  - **If it does not prompt:** correct that heading's sentence to say `allowed-tools` pre-approves a tool rather than
    gating it, and add nothing to the 36.
  - Either branch is one sed-able frontmatter edit or one guidance sentence.

## SA-8: config-rule.md: edit the canonical copy, keep all 13 copies for now, and count what retiring them would break

- **Edits (canonical, then re-sync the 12 copies byte for byte):**
  - The opening paragraph's "Each participating skill finds both through its `## Project Context` block" becomes:
    "Each participating skill finds both through `han-core:load-han-config`, invoked once per run; a skill in a plugin
    that does not depend on han-core carries the probes in its own `## Project Context` block."
  - The section with "two probes and the personal read" in its heading opens: "`han-core:load-han-config` carries the
    two probe lines and directs one Read-tool call." The personal-read bullet's "The skill reads this file itself as
    its first action" becomes "The loader reads this file with the Read tool". The rationale sentence stays verbatim.
  - Add one paragraph pinning "run" and *latest wins*, in the wording SA-4 gives.
- **Retirement:** the July attempt said the vendored copies retire. Measured, they cannot all retire without more work,
  and #203 does not ask for it.
  - Retiring a copy breaks 27 mid-body SKILL.md lines across 18 skills, from a grep for `config-rule` excluding the
    block line. ddd-analysis line 29 is its block, wrapped differently, and is not counted.
  - It also breaks 7 lines in 5 skill reference files: `code-review/references/agent-dispatch.md:40`,
    `iterative-plan-review/references/team-selection.md:59`, `plan-a-change/references/team-selection.md:33,69`,
    `plan-a-feature/references/review-team-briefs.md:30`, and `plan-implementation/references/team-selection.md:32,73`.
  - The 5 plugins in SA-6 need their copies regardless.
  - After the sweep, the copies in han-documentation and han-github are referenced by nothing. They are harmless and
    stay byte-identical.
  - Kept: all 13. Retirement is listed under YAGNI with its trigger.
- **Mid-body links stay valid:** a band-selection citation that points at the local vendored copy still resolves, so
  the sweep does not touch those 34 lines.

## SA-9: `han-config-dir.sh` and its symlinks: the issue's claim about #172 is already true today

- **Correction to issue-203.md#the-cost-is-already-visible:** "Under a consolidated loader, #172's config half becomes
  one line inside `han-config-dir.sh`" has been true since #184 (52abdf4, 2026-08-19). Every probe already calls the
  script, so `AGENT_CONFIG_DIR` is today the one-line change
  `printf '%s\n' "${AGENT_CONFIG_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"`.
  - Inside a script, a nested expansion is fine. The loader's refusal applies to probe text
    (`context-injection-commands.md`, lines 140-215).
  - What consolidation actually single-sources is the probe text, the grant, and the 65-word instruction. #184's
    investigation counted those as "84 places to land", and they have been swept 4 times since 2026-07-30: e483783,
    78dc4f8, e79299f, and 55bdb1d, plus the missed `pairing`. That history is the measured friction, and it passes the
    Rule of Three on its own.
- **The script stays.** Its callers become the loader plus the 8 old-block skills.
- **Symlinks:** keep the 6 in han-core, han-communication, han-feedback, han-linear, han-plugin-builder, and
  han-reporting. Remove the 7 in han-atlassian, han-coding, han-ddd, han-documentation, han-github, han-planning, and
  han-research, which no SKILL.md references after the sweep. The bats test "every plugin holding such a skill can
  reach the resolver script" stays green either way.

## SA-10: Sequencing: five phases, only one of which touches the 45 files

| Phase | Lands | Touches SKILL.md? | Gate to start next |
| --- | --- | --- | --- |
| A | issue step 1: troubleshooting.md Cause 1 and checklist item 8 (SA-11, pre-trial wording) | no | none, it stands alone |
| B | issue step 2: trial artifacts under this plan's `artifacts/`, harness hot-loaded in `.claude/skills/`, OI-3 method | no | 0 early exits plus all carried facts present, in every arm |
| C | issue steps 3 and 5: loader skill, its long-form doc, han-core README scent line, both indexes, CLAUDE.md layout line, han-core minor bump, guidance widening (SA-11) | adds 1 new file | loader merged and unused, so it is safe alone |
| D | issue step 4: scripted sweep of 35, hand edits (readability-guidance, explanation-guidance, pairing, project-discovery), config-rule.md re-sync, bats, CONTRIBUTING.md:181-182, docs/configuration.md:7, graceful-degradation.md:102, symlink removal | yes | #172 no longer edits any SKILL.md |

- **Phase B arms:** the arms beyond OI-3's are values-case inline, worst-case adversarial (no caller continuation, a
  final-sounding loader close), depth-2 chain (consumer, then loader, then readability-guidance with its line), direct
  top-level invocation, and default-permission without `Skill` (SA-7). If any arm fails, stop after Phase A.
- **Phase D gate, scripted:**
  - The exact line appears in 36 files (35 plus readability-guidance).
  - The 65-word paragraph, with whitespace normalized, appears in exactly 8.
  - `han-config-dir.sh` appears in SKILL.md files in exactly 9: the loader plus the 8.
  - explanation-guidance carries neither.
  - Encode these as a new bats test beside `scripts/han-config-dir.bats`. Its existing probe and grant checks keep
    passing over the 9.
- **#172, one sentence per option:**
  1. **#172 first:** rebase it so its config half is the one-line script change plus the config-rule.md wording, with
     no SKILL.md edits, which is possible today (SA-9); Phase D then starts on a clean base.
  2. **#203 first:** hold #172 until Phase D merges, then rebase it to the same script line, at the price of keeping
     #172 open for four phases.
  3. **Split #172:** land its Pi marketplace and compat half now (out of #203's scope), and treat its config half as
     the script line whenever convenient.
  - Recommended: 1 or 3. Both free #172 from the 45 files immediately, so Phases A through C can run while it is open.
    The only remaining overlap is the 13 config-rule.md copies, which Phase D re-syncs anyway.

## SA-11: Guidance edits, section by section

All under `han-plugin-builder/skills/guidance/references/skill-building-guidance/`.

- **troubleshooting.md, "### Cause 1: Data-fetch sub-skill (forked or inline)"** (Phase A):
  - Retitle it to "Data-fetch sub-skill under `context: fork`".
  - Keep the forked sentence verbatim, including the `api_retry` anchoring and the link.
  - Replace the inline sentence with: "Inline, the sub-skill renders into the caller's context and returns no value to
    anchor on; the OI-3 spike ran 34 same-context invocations with zero early exits (8c96157). That evidence covers
    surfacing a standard; a values-only inline sub-skill is untested." Phase C rewrites the last clause to cite the
    trial.
  - Fix paragraph: "Do not fork a data-fetch sub-skill." Inline discovery stays the default, and the line points to the
    exception in Skill Composition.
  - Summary Checklist item 8: "Replace forked data-fetch sub-skills with inline discovery or an inline sub-skill under
    Skill Composition's exception".
- **skill-composition.md** (Phase C):
  - "## Data-fetch composition (avoid)" becomes "Forked data-fetch composition (avoid)". Its definition gains "under
    `context: fork`". The failure account, from "The failure mode is concrete" through "the small amount of discovery
    logic it saves", stays verbatim.
  - "### Duplicate small discovery logic rather than sharing it through a skill" keeps its one-off advice and gains a
    trigger: when one discovery block is copied into many skills and has had to be re-swept, surface it through an
    inline sub-skill under the exception. The config block is the worked example: 4 sweeps, 1 of which missed a
    skill.
  - "### The one exception: surfacing a shared standard inline" becomes "surfacing shared content inline". Property 2
    becomes: "It surfaces content many consumers would otherwise duplicate (a whole standard, or a shared lookup's raw
    results) and leaves interpretation to the caller; fetching one value for one skill is still inline discovery."
  - Add the trial result beside the spike paragraph. Keep the "honest limit" paragraph and extend it with the trial's
    own limits.
  - "### Declare the Skill tool in `allowed-tools`" changes only per SA-7's outcome.
  - "## Deciding which way to go": the "A few values" bullet splits into "values one skill needs: stay inline" and "a
    lookup many skills share: an inline sub-skill under the exception".
- **writing-effective-instructions.md, "### Rule: Prefer inline discovery over forked data-fetch sub-skills"**
  (Phase C):
  - The rule is accurate as it stands, since it is fork-specific. Keep the account and the before/after unchanged.
  - Change the closing paragraph's "data-fetch sub-skills that return structured values" to "forked data-fetch
    sub-skills".
  - Add one sentence pointing to Skill Composition's exception for a shared lookup surfaced inline. This closes the
    cross-reference gap that V14 recorded.
- **graceful-degradation.md:102**, which the brief did not name: "Skills discover config inline ... rather than
  calling a data-fetch sub-skill" becomes false after Phase D. Rewrite it to name the inline loader for
  `.han/config.md` and inline discovery for other project values (Phase D).
- **context-hygiene.md:** no edit. The issue's quoted rule, "The attention cost is per-context, not per-file", does not
  exist anywhere (discovery notes, Measurements). Line 104 is "Position critical content at the edges". If the plan
  wants a citation for the cost of duplicate copies, use "### Rule: Every token must earn its place" (line 36) or
  "### Rule: Treat stale context as a bug, not tech debt" (line 201). Do not carry the issue's quote.
- **Lag:** consumer repos that ran `guidance init` keep the old wording until they run `guidance update` (V15). Note
  the lag. Do not push updates outward.

## SA-12: Docs and contributor surfaces that move with Phase D

- `CONTRIBUTING.md:181-182` tells authors to "copy the `personal config directory` probe and its matching ... grant".
  It becomes: "carry the line `Resolve configuration with han-core:load-han-config if you have not already this run.`
  in `## Project Context`; in a plugin that does not depend on han-core, copy the probe block from `edit-for-readability`
  instead". The discovery notes cited lines 299-302, but the text is at 181-182 on `main`.
- `docs/configuration.md:7` gets the clause SA-4 gives. Line 29's "vendored byte-identical into each plugin" stays
  true (SA-8).
- `CLAUDE.md`'s han-core description and layout line list `project-discovery` and `pairing`. Add `load-han-config` in
  Phase C.

## Software Architecture Recommendations Summary

- **Upstream findings addressed:**
  - Covered by SA-1 through SA-12: all five proposal steps in the issue, its four open questions, the V9, V10, and V11
    findings from the July attempt, and the discovery measurements on duplication, chain targets, the context-hygiene
    citation, and #172.
  - Intentionally not addressed:
    - The issue's open question "Is there inline-failure evidence I missed?" belongs to the maintainer, and the
      discovery notes' "Gaps" already record that none was found.
    - #172's Pi marketplace entries are out of scope (scope-boundary.md#stated-exclusions).
- **Key themes:**
  - Separate acquisition (loader) from interpretation (config-rule.md) from application (each skill).
  - Put dedupe where it can act, which is the caller's line, because a probe cannot be conditional.
  - Change the fewest files that the duplication finding actually reaches. That means 35 rewired, 2 chain targets hand
    edited, and 8 untouched.
- **Highest-impact:**
  - SA-1 and SA-2: the raw-content loader under the existing labels.
  - SA-5: the chain targets. Deleting explanation-guidance's block alone removes one of the three copies.
  - SA-10: phasing that keeps #172's overlap to the script line.
- **Deferred to `system-architect`:**
  - The V11 option of adding han-core as a dependency of han-communication, han-feedback, han-linear,
    han-plugin-builder, or han-reporting. It changes the plugin dependency graph, which is a relationship between
    deployable units.
  - Codex support for Skill-to-Skill calls and probes (SA-6). It is a cross-runtime packaging concern.
- **Deferred (YAGNI):**
  - `show` and `set` modes (July V-plan). These are speculative features: issue #203 does not ask for them and no
    finding needs them. Reopen when a user request to view or edit config through Han is recorded.
  - Resolved-values output shape (SA-1). It is an abstraction with one consumer that could use it,
    readability-guidance, and the other consumers cannot use it (per-skill precedence and notes). Reopen if a trial
    arm shows models misapplying raw content, which would be measured friction.
  - Retiring the vendored config-rule.md copies (SA-8). Out of #203's stated scope, with 34 citation lines to
    rewrite. Reopen at the next config-rule.md edit that forces a 13-copy re-sync, or if a copy drifts. Even then only
    7 can retire.
  - A fallback Read path in the 8 old-block skills, or a SessionStart hook. Both add a mechanism to solve a duplication
    those skills do not have. Reopen if one of the 8 becomes another skill's Skill-call target.
  - Scoped permission such as `Skill(han-core:load-han-config)`. Reopen only if SA-7's arm shows a prompt and a blanket
    `Skill` grant is judged too broad.
    Unverified: could not inspect whether Claude Code accepts a per-skill `Skill(...)` permission rule, because no
    documentation for it is vendored in the repo.

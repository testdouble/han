# Current State Findings: Opus 5.5 plugin-builder guidance update

## Provenance

No prior findings report existed. This run produced the findings itself, on 2026-09-23, over the area
`han-plugin-builder/`:

- `han-core:structural-analyst`: which files restate one another, what `guidance init` vendors, and where dates and model
  names are pinned.
- `han-core:behavioral-analyst`: what `skill-builder`, `agent-builder`, and `guidance` read at run time, and how the
  builders' own instructions behave.
- Four `han-core:gap-analyzer` runs, one per slice of the plugin's files. Each compared its slice against the source
  digest and grepped the whole plugin before reporting a gap.
- Five `han-core:adversarial-validator` runs. Together they tested every merged candidate against counter-evidence.

The analysis ran against four sources. The operator named the first two. The run added the third and fourth as related
sources; the context-engineering article is linked from both operator-named articles.

| ID       | Source                                                                                                                                                                                               | Role                               |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| SOURCE 1 | [Getting the most out of Opus 5.5 in Claude and Claude Code](https://claude.dev/blog/getting-the-most-out-of-opus-5-5/), Addy Osmani, 2026-09-22                                                     | Primary; overrides the others      |
| SOURCE 2 | [Lessons from building Claude Code: How we use skills](https://claude.dev/blog/lessons-from-building-claude-code-how-we-use-skills/), Thariq Shihipar, 2026-06-03                                    | Baseline (operator-named)          |
| SOURCE 3 | [The new rules of context engineering for Claude 5 generation models](https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/), Thariq Shihipar, 2026-07-24     | Baseline (related post)            |
| SOURCE 4 | [Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5), Anthropic platform docs                                             | Baseline (related source)          |

All four are Anthropic publications. Where two of them agree, the agreement is single-vendor, two publications. It is
not independent corroboration.

## Project Context

- **Stack:** Markdown (skill, agent, and reference content) and Bash (`skills/guidance/scripts/init-guidance.sh`). No
  build.
- **Conventions source:** `CLAUDE.md` (`## Project Discovery`, `## Conventions`); the voice profile at
  `han-communication/references/writing-voice.md`.
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md`. It does not bear on this area.
- **Coding standards found:** none apply to guidance prose. Prettier runs with `printWidth: 120` and
  `proseWrap: preserve` (`.prettierrc.json`).
- **Recent churn:** 44 commits touched the plugin in the last 90 days. The closest precedent is `59398fc`
  (2026-07-31), "docs(guidance): update per-model authoring for Claude Opus 5". It retargeted `per-model-authoring.md`
  to Sonnet 5, Opus 5, and Fable 5, swept the four surfaces that name the model trio, and added the delegation policy to
  `multi-agent-economics.md`. `33ed427` (2026-08-20) brought reference files over 100 lines under a `## Contents`
  convention.

## Gaps

- No automated test covers any guidance file. `test/` holds only `codex-packaging.bats` and `sanity.bats`, and neither
  reads guidance content. A content change has nothing automated to break, and nothing automated to confirm it.
- This repo carries no vendored copy of the plugin-building skills. Consuming repos pick up changes when they re-run
  `/guidance update`.
- Anthropic publishes a separate Fable 5.1 prompting page (`prompting-claude-fable-5-1`, HTTP 200 on 2026-09-23). This
  run did not read it; see the plan's Cut for Scope.

## Findings

### C-1: The per-model guide names three models and was last checked before Opus 5.5 shipped

- **Claim:** `per-model-authoring.md` covers Sonnet 5, Opus 5, and Fable 5 only, and dates itself 2026-07-31. No file in
  the plugin names Opus 5.5.
- **Location:** `han-plugin-builder/skills/guidance/references/per-model-authoring.md:5`
- **Evidence:**
  ```markdown
  _Last checked against Anthropic's published guidance on 2026-07-31, for Sonnet 5, Opus 5, and Fable 5. ..._
  ```
- **Raised by:** gap-analyzer (slice A, GA-1); structural-analyst S-12; a validator confirmed it (group 1).
- **Confidence:** Verified
- **Bears on:** S-1, D-1

### C-2: The model list is restated in four other files, and a change must reach all of them

- **Claim:** The guidance router, its portable copy, the rule index, and the specialization guide each carry their own
  copy of the model-list clause. `init-guidance.sh` vendors the portable copy and the rule index into consuming repos.
- **Location:** `skills/guidance/SKILL.md:48-50`; `skills/guidance/assets/guidance-portable-SKILL.md:27-29`
  (byte-identical body); `skills/guidance/assets/rule-index-body.md:166-171`;
  `skills/guidance/references/specialization-and-model-selection.md:89`
- **Evidence:**
  ```markdown
  - Writing the instructions for a target model (how Sonnet 5, Opus 5, and Fable 5 differ in following instructions, which
  ```
  ```markdown
    Opus 5, and Fable 5 differ in how they follow instructions, ... and the Fable 5
    reasoning-echo refusal to avoid.
  ```
- **Raised by:** structural-analyst S-1, S-10, S-17
- **Confidence:** Verified
- **Bears on:** S-1

### C-3: The reasoning-echo warning is scoped to Fable 5 and called single-source

- **Claim:** The guide warns only about Fable 5 refusing requests to reproduce internal reasoning, and says the warning
  rests on one uncorroborated source. SOURCE 1 and SOURCE 4 both place the same refusal on Opus 5.5, under the
  `reasoning_extraction` category.
- **Location:** `per-model-authoring.md:35-41`, `:83`, `:85`
- **Evidence:**
  ```markdown
  On Fable 5, an instruction that tells the model to reproduce or transcribe its own internal thinking into its visible answer can be refused outright.
  ```
  SOURCE 4: "Requests that push the model to reproduce its internal reasoning in the response text can be declined with
  the `reasoning_extraction` category, which is new if you're coming from Claude Opus 5."
- **Raised by:** gap-analyzer GA-2; gap-analyzer (slice C) contradiction note; a validator confirmed it (group 1).
- **Confidence:** Verified
- **Bears on:** S-2

### C-4: The thinking-mode bullet describes disabling thinking on Opus 5, which Opus 5.5 does not allow

- **Claim:** The bullet says Opus 5 can disable thinking at effort `high` or below, and ties an XML-tag-leak caveat to
  that case. SOURCE 4 says Opus 5.5 does not accept disabled thinking.
- **Location:** `per-model-authoring.md:47`
- **Evidence:**
  ```markdown
  Opus 5 and Sonnet 5 have thinking on by default; on Opus 5 it can be disabled only at effort `high` or below. Fable 5 always has it on and cannot turn it off.
  ```
- **Raised by:** gap-analyzer GA-3; a validator narrowed it (group 1).
- **Confidence:** Verified
- **Bears on:** S-3

### C-5: The effort bullet predates Opus 5.5's default, and authors can pin effort in frontmatter

- **Claim:** The effort bullet describes Opus 5 only. Skills and agents both accept an `effort` frontmatter value, so a
  value tuned for Opus 5 carries over silently. SOURCE 4 says Opus 5.5 defaults to `medium` (Opus 5 defaults to `high`),
  that `medium` on 5.5 matches or exceeds Opus 5 at `high`, and that 5.5 thinks more per turn at a given level.
- **Location:** `per-model-authoring.md:48`; `skill-building-guidance/skill-frontmatter-fields.md:46`;
  `agent-building-guidelines/agent-external-files.md:112`
- **Evidence:**
  ```markdown
  | `effort`  | No       | `low`, `medium`, `high`, `xhigh`, or `max`. Overrides the session's effort level for this skill.
  ```
- **Raised by:** gap-analyzer GA-4, GC-1; a validator confirmed it (group 1).
- **Confidence:** Verified
- **Bears on:** S-4

### C-6: The guide warns against every "only report X" review limit, while SOURCE 1 recommends one with a concrete bar

- **Claim:** The guide treats a limiting phrase in a review instruction as a failure mode, and its two examples are
  vague ("high-severity", "be conservative"). SOURCE 1 recommends a limit that names a checkable bar and demands evidence
  per item. No source says Opus 5.5 follows instructions less literally than Opus 5.
- **Location:** `per-model-authoring.md:31`
- **Evidence:**
  ```markdown
  A review instruction that says "only report high-severity issues" or "be conservative" is followed literally, and the run reports less than it found.
  ```
  SOURCE 1: "List only problems you'd block the merge for. For each one, give the file and line, why it's wrong, and how
  to show it fails."
- **Raised by:** gap-analyzer (slice C) contradiction note; a validator confirmed the tension (group 3).
- **Confidence:** Verified
- **Bears on:** S-5, D-5

### C-7: The per-model Sources section cites only the Opus 5-era pages

- **Claim:** The Sources section lists the Opus 5, Sonnet 5, and Fable 5 prompting pages plus a research report titled
  for the Opus 4.8 era. `multi-agent-economics.md` cites the same Opus 5 URL.
- **Location:** `per-model-authoring.md:81-91`; `multi-agent-economics.md:168`;
  `docs/research/model-specific-guidance-for-skills.md:1`
- **Evidence:**
  ```markdown
  - [Prompting Claude Opus 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)
  ```
- **Raised by:** structural-analyst S-4, S-14, S-15; a validator narrowed it (group 1).
- **Confidence:** Verified
- **Bears on:** S-6

### C-8: Workflow guidance covers deliberate pauses, not a model that stops early to report

- **Claim:** `workflow-patterns.md` covers human gates placed before irreversible actions. Nothing in the plugin covers
  a run that ends its turn with a status report, an offer to continue, or a list of non-blocking choices. SOURCE 1 and
  SOURCE 4 both describe that Opus 5.5 behavior. Both also say to leave the keep-going instruction out of
  human-in-the-loop work, which is the shape of most Han skills and the whole of `han-core`'s collaborative-stop contract.
- **Location:** `skill-building-guidance/workflow-patterns.md:296-341`; `han-core/references/collaborative-stop-rule.md`
- **Evidence:**
  ```markdown
  **Human gates** are different: they pause execution to ask the user for confirmation before an irreversible
  operation.
  ```
- **Raised by:** gap-analyzer GA-5, GB1-6, GB2-9; a validator narrowed it (group 2).
- **Confidence:** Verified
- **Bears on:** S-7

### C-9: No guidance names a finish line or a durable task list for long steps

- **Claim:** The plugin has per-step validation gates and a planning-time "Expected Result" field. It has no rule for
  stating a completion condition on a step that iterates over an unbounded set, and no rule for keeping that step's
  progress in a file that survives context summarization. The two nearby rules cover other mechanisms: continuation after
  a Skill call, and the skill definition surviving compaction.
- **Location:** `skill-building-guidance/skill-composition.md:81-85`; `skill-building-guidance/context-hygiene.md:191-199`;
  `skill-building-guidance/use-case-planning.md:129-143`
- **Evidence:**
  ```markdown
  A Skill call mid-workflow is the moment the calling model is most likely to stop, treating the sub-skill's output as its
  own final answer.
  ```
- **Raised by:** gap-analyzer GB1-5, GB1-7, GB2-8, GC-5; a validator narrowed it (group 2).
- **Confidence:** Verified
- **Bears on:** S-8

### C-10: Delegation guidance has no evidence check on returned subagent work and no wait for background dispatches

- **Claim:** `multi-agent-economics.md` has three delegation rules: do not delegate small work, do not dispatch an agent
  to check the dispatching skill's own work, and prefer one agent to several. None covers checking a fanned-out
  subagent's evidence before accepting it, which SOURCE 1 recommends, or waiting for a background dispatch before calling
  the run done, which SOURCE 4 recommends. Han skills do dispatch in the background.
- **Location:** `agent-building-guidelines/multi-agent-economics.md:33-48`, `:131`;
  `han-coding/skills/automated-test-planning/SKILL.md:134`
- **Evidence:**
  ```markdown
  - **Do not dispatch an agent to verify or double-check the dispatching skill's own work.** This is a self-check, and
  ```
  ```markdown
  Launch the testing agents **in parallel** using the `Agent` tool with `run_in_background: true`.
  ```
- **Raised by:** gap-analyzer GC-2, GC-3, GB2-10, GB2-11; validators narrowed it (groups 2 and 3).
- **Confidence:** Verified
- **Bears on:** S-9

### C-11: Agent graceful-degradation covers a missing tool, not a claim the agent could not confirm

- **Claim:** The agent rule fires when a tool is unavailable. It says nothing about an agent that had every tool, looked,
  and still could not establish a claim.
- **Location:** `agent-building-guidelines/graceful-degradation.md:16-27`
- **Evidence:**
  ```markdown
  If the tool is not available, skip the step and note the limitation explicitly in the agent's output.
  ```
- **Raised by:** gap-analyzer GB1-8, GC-6; a validator narrowed it (group 3).
- **Confidence:** Verified
- **Bears on:** S-10

### C-12: The instruction-writing guide pushes toward specificity with no stated limit

- **Claim:** "Be specific and actionable" has no counterweight in the instruction-writing guide. The per-model guide's
  middle path (goal, reasons, and load-bearing constraints, with no exhaustive checklist) applies only when the target
  model is unknown.
- **Location:** `skill-building-guidance/writing-effective-instructions.md:34`; `per-model-authoring.md:17-21`
- **Evidence:**
  ```markdown
  ### Rule: Be specific and actionable
  ```
- **Raised by:** gap-analyzer GB1-2; a validator narrowed it (group 4).
- **Confidence:** Verified
- **Bears on:** S-11, D-11

### C-13: "When to remove entirely" names only toolchain-enforced rules

- **Claim:** The removal list the builder review reads covers rules a linter enforces, not instructions restating what
  the model already does by default. `context-hygiene.md` states the general principle, but the builder review does not
  cite it.
- **Location:** `skill-building-guidance/progressive-disclosure.md:111-116`; `skill-building-guidance/context-hygiene.md:36-40`
- **Evidence:**
  ```markdown
  - Rules already enforced by the toolchain (linters, formatters, CI checks).
  ```
- **Raised by:** gap-analyzer GB1-3; a validator narrowed it (group 4).
- **Confidence:** Verified
- **Bears on:** S-12

### C-14: No reference-file category holds accumulated gotchas

- **Claim:** "Gotcha" appears nowhere in the plugin. The two lists of reference-file categories name templates,
  checklists, rate tables, decision matrices, style guides, and canonical examples. `troubleshooting.md` covers failures
  to build or load a skill, which is a different audience.
- **Location:** `skill-building-guidance/skill-reference-files.md:29-37`; `skill-building-guidance/progressive-disclosure.md:95-101`
- **Evidence:**
  ```markdown
  - **Canonical examples** that demonstrate conventions the skill enforces (2-3 representative "do this / not this" code
  ```
- **Raised by:** gap-analyzer GB1-4, GB2-3; a validator confirmed it (group 4).
- **Confidence:** Verified
- **Bears on:** S-13

### C-15: Testing guidance covers testing a skill, not building a skill that verifies a product

- **Claim:** `success-criteria-and-testing.md` covers triggering tests, functional tests, and performance comparison of
  the skill under construction. It has no pattern for a skill whose job is to drive a running product and assert its
  state.
- **Location:** `skill-building-guidance/success-criteria-and-testing.md:30-181`
- **Evidence:** section headings `## Triggering Tests`, `## Functional Tests`, `## Performance Comparison`.
- **Raised by:** gap-analyzer GB2-2; a validator confirmed it (group 5).
- **Confidence:** Verified
- **Bears on:** S-14

### C-16: The persistent data directory is documented only as a plugin.json variable

- **Claim:** `plugin-json-options.md` defines `${CLAUDE_PLUGIN_ROOT}` (changes on update) and `${CLAUDE_PLUGIN_DATA}`
  (survives updates), plus `userConfig`. No skill-building guide tells an author where to keep a skill's first-run
  answers or its run history. SOURCE 2 describes a `config.json` inside the skill directory. In an installed plugin, that
  directory sits under `${CLAUDE_PLUGIN_ROOT}` and is replaced on update.
- **Location:** `claude-marketplace-and-plugin-configuration/plugin-json-options.md:72-88`, `:137-138`
- **Evidence:**
  ```markdown
  | `${CLAUDE_PLUGIN_ROOT}` | Absolute path to plugin install directory. Changes on plugin update.      |
  | `${CLAUDE_PLUGIN_DATA}` | Persistent state dir at `~/.claude/plugins/data/{id}/`. Survives updates. |
  ```
- **Raised by:** gap-analyzer GB2-4, GB2-5, GB1-9; a validator narrowed it (group 5).
- **Confidence:** Verified
- **Bears on:** S-15

### C-17: Script guidance treats every script as one fixed operation

- **Claim:** Script guidance shows one script per step, invoked directly. Nothing covers a helper library in `scripts/`
  that the model imports into a one-off script it writes. Script commands are kept out of `allowed-tools`, so a composed
  script still prompts for permission.
- **Location:** `skill-building-guidance/hardening-fuzzy-vs-deterministic.md:32-41`;
  `skill-building-guidance/script-execution-instructions.md`
- **Evidence:** `### Deterministic Steps` describes a script per step. The script-execution guide's "Why Scripts Should
  Not Be in `allowed-tools`" section covers the permission prompt.
- **Raised by:** gap-analyzer GB2-6; a validator narrowed it (group 5).
- **Confidence:** Verified
- **Bears on:** S-16

### C-18: Hooks are documented as one-line table rows

- **Claim:** The `hooks` field appears as a single row in the skill frontmatter table and in the plugin.json table.
  `PreToolUse` appears nowhere in the plugin.
- **Location:** `skill-building-guidance/skill-frontmatter-fields.md:49`;
  `claude-marketplace-and-plugin-configuration/plugin-json-options.md:49`
- **Evidence:**
  ```markdown
  | `hooks`   | No       | Lifecycle hooks scoped to this skill's run.
  ```
- **Raised by:** gap-analyzer GB2-7; a validator confirmed it (group 5).
- **Confidence:** Verified
- **Bears on:** S-17

### C-19: Neither builder skill reads or checks against the per-model guide

- **Claim:** `skill-builder` and `agent-builder` read guidance through their own decision tables, not the guidance
  router. Neither table nor either Step 6 review names `per-model-authoring.md`.
- **Location:** `skills/skill-builder/SKILL.md:36-54`, `:160-195`; `skills/agent-builder/SKILL.md:36-46`, `:157-187`
- **Evidence:**
  ```markdown
  ## Step 6: Full Guidance-Conformance Review

  This is the review pass the skill commits to. Re-read each governing document that applies to what you built and verify
  the finished files against it, applying every fix directly.
  ```
- **Raised by:** behavioral-analyst B-1, B-2; a validator confirmed it (group 2).
- **Confidence:** Verified
- **Bears on:** S-18, D-18

### C-20: The builders' own instructions carry none of the patterns the sources say to remove

- **Claim:** Neither builder contains a "think step by step" line, a request to reproduce reasoning, all-caps emphasis,
  or a bare double-check step. Their Step 6 is a review scoped to named guidance files. Neither builder dispatches a
  subagent, and each ends by asking whether to iterate.
- **Location:** `skills/skill-builder/SKILL.md`, `skills/agent-builder/SKILL.md`, `skills/guidance/SKILL.md`
- **Evidence:** behavioral-analyst B-11 to B-15 grepped for `think`, `step.by.step`, `reasoning`, `MUST|NEVER|ALWAYS`,
  `verify|double-check`, and `Agent`/`Task` in `allowed-tools`, and found none of the patterns.
- **Raised by:** behavioral-analyst; gap-analyzer (slice C) "Confirmed no-gap findings".
- **Confidence:** Verified
- **Bears on:** no entry. This finding is why the builders' own bodies are not rewritten.

### C-21: A new reference file needs a rule-index entry; the router finds it by listing the directory

- **Claim:** The guidance router tells the model to list a subdirectory and read the file that applies, so a new file
  under `skill-building-guidance/` is reachable with no router edit. The rule index lists every file by name, so a new
  file needs one line there. `init-guidance.sh:74` copies `references/` wholesale.
- **Location:** `skills/guidance/SKILL.md:38-39`, `:52-56`; `skills/guidance/assets/rule-index-body.md:29-106`;
  `skills/guidance/scripts/init-guidance.sh:74`
- **Evidence:**
  ```markdown
  2. List the relevant subdirectory under `${CLAUDE_SKILL_DIR}/references/` to see the available documents, using the map
     above.
  ```
- **Raised by:** structural-analyst S-9; this run's own sweep.
- **Confidence:** Verified
- **Bears on:** S-15

### C-22: The plugin's docs and README do not restate per-model content

- **Claim:** `README.md` and `docs/skills/{guidance,skill-builder,agent-builder}.md` link to the per-model guide without
  naming the model list. They need no edit for the model-list change.
- **Location:** `han-plugin-builder/README.md`; `han-plugin-builder/docs/skills/*.md`
- **Evidence:** structural-analyst S-8 grepped for "Sonnet 5", "Opus 5", and "Fable 5" and found no hits.
- **Raised by:** structural-analyst
- **Confidence:** Verified
- **Bears on:** S-18 (the builder docs describe Step 6 and may need one line; see the plan)

## Findings No Agent Could Audit

- **The live source pages.** The validators worked from this run's captured text. They could not refetch the four
  sources to confirm that text matches the live pages. The captures were taken on 2026-09-23 with `curl`.
- **Whether authors hit these failures in practice.** No usage logs or session transcripts exist to show whether an
  author has shipped a skill that stopped early or hit a `reasoning_extraction` refusal. Every entry rests on the sources'
  own claims about model behavior.

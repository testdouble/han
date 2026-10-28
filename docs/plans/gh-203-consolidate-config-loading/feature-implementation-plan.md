# Feature Implementation Plan: Consolidate config loading (issue #203)

This plan replaces the 65-word config block that every Han skill carries with one shared, inline loader skill. A chain
of skills then loads `.han/config.md` once instead of once per skill. The work runs in four gated phases. The guidance
correction ships on its own first. A trial on the values case comes next and gates everything else. Then the loader
lands unused in `han-core`, as the issue's step 3 says ([D-1](artifacts/implementation-decision-log.md#d-1-loader-lives-in-han-core-with-five-new-dependency-edges)), and the five plugins
that do not yet declare `han-core` gain it as a dependency ([D-21](artifacts/implementation-decision-log.md#d-21-five-plugins-gain-a-direct-han-core-dependency)). Only after that
does the scripted sweep rewire the skills. The dependency edges go past the issue's text: the user chose them so every
skill can reach the loader, and they are the one item the maintainer may decline at review.

## Outcome

When this plan is done, a person who runs a chained skill such as `plan-a-feature` gets one copy of their Han
configuration in the conversation, not three. Every shipped skill that uses a setting points at a shared loader in one
line, and the loader carries the two probes and the personal-file read that used to be copied into each skill. No skill
keeps the old block, and nobody loses a setting. The cost is that installing `han-communication`, `han-feedback`,
`han-linear`, `han-plugin-builder`, or `han-reporting` now also installs `han-core`.

The maintainer gets one place to change how config is found. The plugin-building guidance stops forbidding what its own
spike measured as working, and it names the config loader as the second validated case of an inline shared sub-skill.
If the trial fails, only the guidance correction and the removal of one unused block ship, and no plugin gains a
dependency.

## User Stories

- **US-1:** As an operator who runs a skill that invokes other skills, I want my configuration loaded once per run, so
  that later skills in the chain are not told to load it again and the context holds one copy.
- **US-2:** As an operator who invokes any Han skill directly, I want my `output-directory`, `default-swarm-size`,
  `writing-voice`, and extra agents to keep taking effect, so that consolidation changes nothing I can observe except
  the duplication.
- **US-3:** As the maintainer who changes how config is looked up, I want that lookup to live in one skill and one
  script, so that the next change edits a few files instead of sweeping 45.
- **US-4:** As the maintainer who authors skills against the plugin-building guidance, I want that guidance to say only
  what the evidence shows about inline sub-skills, so that I do not avoid a pattern the measurements support.

## Constraints and Boundaries

- **Driving constraint:** the maintainer asked for "a better solution" for long-term maintenance and does not like
  "having everything trying to load the config file when it's already loaded" (comment on the issue). The block has
  been swept four times since July, and one hand sweep missed `pairing` and broke it (commit `0e5f44f`). PR #172 is
  open against the same files.
- **Recorded boundary:** issue #203's five proposal steps, with steps 3 to 5 conditional on the trial holding. See
  [artifacts/scope-boundary.md](artifacts/scope-boundary.md).
- **User direction past the boundary:** the five new `han-core` dependency edges are not among the issue's five
  steps. The user added them after reading the plan (E1 in the iteration history), so that every skill reaches the
  loader.
- **Out of scope:**
  - PR #172's Pi marketplace entries and compat checks, which the issue excludes by statement.
  - `show` and `set` modes on the loader, retiring the vendored `config-rule.md` copies, and running the trial under
    Codex. Each is in Deferred (YAGNI) with its trigger.
  - No security or operations surface changes. The loader reads the same two files the block reads today, with the
    same tools, so no threat or runtime review was needed.
- **Corrections to the issue the plan carries (measured, not decisions):**
  - 45 of 45 shipped skills carry the probe, not 44 of 47.
  - `readability-guidance` has 23 consuming skills, not 24. `explanation-guidance` has about 7, not 8.
  - About 13 skills are Skill-call targets, not five. The fix shape is the same for all of them.
  - "#172's config half becomes one line inside `han-config-dir.sh`" has been true since #184. It is not a benefit of
    consolidation.
  - The quoted rule "The attention cost is per-context, not per-file" at `context-hygiene.md:104` does not exist. No
    guidance edit carries it.
- **Watch after ship:**
  - Consumer repos that ran `guidance init` keep the old guidance wording until they run `guidance update`.
  - A report of a chained skill misapplying raw config content reopens the resolved-values shape.
  - Installs of `han-communication`, `han-feedback`, `han-linear`, `han-plugin-builder`, or `han-reporting` now pull in
    `han-core` and its 22 agents.

## Implementation Approach

The work moves three things out of every skill and into one inline loader: the two config probes, the Bash grant for
the resolver script, and the instruction to read the personal file. Each skill keeps one line that names the loader and
tells the model to skip it when the config is already in context this run. The shared config rule keeps owning how
settings are interpreted, and each skill keeps owning how a setting applies to it. The loader only brings the files into
context.

The loader is inline, never forked. It renders into the caller's context, so whatever it surfaced stays there after it
returns, which is how `readability-guidance` already works. That is the property the OI-3 spike measured (34 of 34
same-context invocations, zero early exits) and the property a forked loader would lose.

### Where the loader lives

The loader goes in `han-core`, beside `project-discovery`, as the issue's step 3 says
([D-1](artifacts/implementation-decision-log.md#d-1-loader-lives-in-han-core-with-five-new-dependency-edges)). Today only seven
plugins depend on `han-core`, and they exclude both guidance skills the issue's chain runs through. So the five
plugins that do not declare `han-core` gain it as a direct dependency: `han-communication`, `han-feedback`,
`han-linear`, `han-plugin-builder`, and `han-reporting`
([D-21](artifacts/implementation-decision-log.md#d-21-five-plugins-gain-a-direct-han-core-dependency)). After that, every
plugin is `han-core` or depends on it, and every one of the 45 skills can reach the loader.

The new edges create no cycle. `han-core/skills` and `han-core/agents` hold zero references to `han-communication`,
which is why the install-footprint plan (`docs/plans/reduce-required-install-footprint/investigation.md`) cut the
edge from `han-core` to `han-communication`. The edges do cost something, and D-21 records each cost:

- CLAUDE.md, CONTRIBUTING.md, `docs/concepts.md`, `docs/choosing-a-han-plugin.md`, the `han-communication` plugin
  description, and its marketplace entry all say `han-communication` depends on nothing. They change.
- `docs/concepts.md` line 266 offers a reporting-only install "without the `han-core` agent roster". That stops being
  true.
- `han-communication` is 196K and `han-core` is 896K with 22 agents, so installing any of the five now pulls in the
  agent roster.
- The suite declares every edge directly, so each of the five manifests gains its own `han-core` edge, mirrored in
  `.claude-plugin/marketplace.json` where an entry narrates dependencies. Codex manifests have no dependency field and
  do not change.

- Skill path: `han-core/skills/load-han-config/SKILL.md`
- Qualified name every consumer uses: `han-core:load-han-config`

### What the loader surfaces

> Superseded in part after execution: the shipped loader is a single probe whose script prints both files and
> the rule ([D-23](artifacts/implementation-decision-log.md#d-23-the-loader-is-one-probe-whose-script-prints-both-files-and-the-rule)),
> the twelve vendored copies of the rule are gone ([D-24](artifacts/implementation-decision-log.md#d-24-the-vendored-config-rulemd-copies-are-retired)),
> and the script is a regular file in `han-core/scripts/` with no symlink ([D-25](artifacts/implementation-decision-log.md#d-25-the-loader-script-lives-in-han-core-not-at-the-repo-root)).

The loader surfaces raw file content under today's exact labels and resolves nothing
([D-2](artifacts/implementation-decision-log.md#d-2-loader-surfaces-raw-file-content-under-the-existing-labels)). It
emits no note. Because the labels are byte-identical to the old block's, a skill reading config sees the same text
whether the loader or an old-block skill put it there. The loader is built through `/han-plugin-builder:skill-builder`
([D-19](artifacts/implementation-decision-log.md#d-19)) from the software-architect's sketch (SA-2 in
[round-1-software-architect.md](artifacts/round-1-software-architect.md)) as written. Its rule link,
`../../references/config-rule.md`, resolves to the canonical copy in `han-core`.

These values are pinned. The builder may refine the rest of the body.

- Frontmatter: `name` and `allowed-tools` exactly as below, and no `context` key (never `context: fork`). The
  description must name `han-core:load-han-config` and the phrase "resolve configuration" so a direct
  invocation finds it.

  ```yaml
  name: load-han-config
  allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
  ```

- Probe lines: byte-identical to today's two lines.

  ```markdown
  - personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
  - project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`
  ```

- H1, which is also the already-loaded marker: `# Load Han Configuration`
- Hand-back paragraph, verbatim (the link inside it is the loader's own relative link to the canonical
  `config-rule.md` in `han-core`, not a plan artifact):

  ```markdown
  The `personal config directory` and `project .han/config.md` values above, and the personal file you just read, are
  this run's Han configuration. They replace any copy surfaced earlier in this context. Apply them per
  [config-rule.md](../../references/config-rule.md) at the point your own workflow uses a setting. Say nothing about
  the configuration here. RETURN to the skill that invoked you and continue with its next step.
  ```

- Rendered worked example of what the caller's context holds after the call, with a project file present and no
  personal file:

  ```text
  - personal config directory: /home/tami/.claude
  - project .han/config.md: ---
  output-directory: docs/han
  ---
  [Read /home/tami/.claude/.han/config.md -> file does not exist]
  ```

### How a chained skill knows the config is already loaded

A later skill in the chain sees the loader's own rendered body in its context: the `# Load Han Configuration` heading
and the hand-back paragraph. That is the marker, and no separate marker line is added
([D-3](artifacts/implementation-decision-log.md#d-3-rendered-loader-body-is-the-already-loaded-marker)). When the
loader runs twice, the latest copy wins, because the hand-back paragraph says so. A copy dropped by compaction fails the
check, and the skill loads again.

"This run" gets a pinned definition in the shared config rule
([D-4](artifacts/implementation-decision-log.md#d-4-definition-of-a-run)):

> A run begins when the person invokes a skill and ends when that skill finishes. Every skill it invokes is part of the
> same run. A skill the person invokes later in the same session is a new run and loads again.

### The line each consumer carries

Each consumer's `## Project Context` holds this line where the 65-word paragraph sat. The two config probes and the
script grant are removed. Any other probes in that section stay above the line
([D-5](artifacts/implementation-decision-log.md#d-5-the-consumer-line-and-where-it-sits)).

```markdown
Resolve configuration with `han-core:load-han-config` if you have not already this run.
```

Whether `Skill` joins each consumer's `allowed-tools` is decided by the trial's no-grant arm, with both branches pinned
in advance ([D-8](artifacts/implementation-decision-log.md#d-8-skill-grant-decided-by-trial)).

### Which skills change

Every skill takes the line, except `explanation-guidance`, which uses no setting and loses its block outright. No skill
keeps today's block ([D-6](artifacts/implementation-decision-log.md#d-6-which-skills-carry-the-line)).

- 44 skills carry the line: every shipped skill except `explanation-guidance`. That includes `han-core`'s own
  `project-discovery` and `pairing`, `readability-guidance` and `edit-for-readability`, `han-feedback`,
  `work-items-to-linear`, and `han-plugin-builder`'s `agent-builder`, `guidance`, and `skill-builder`.
  - `readability-guidance` Step 1 changes only its source phrases. "Either `.han/config.md` probe" becomes the run's
    `project .han/config.md` value or personal `.han/config.md`, and "the probe reported" becomes the run's
    `personal config directory` value. It needs no fallback sentence, because `han-communication` depends on
    `han-core` once D-21 lands.
- `explanation-guidance` deletes both probes, the paragraph, and the Bash grant, and carries no line.
- `guidance init` also vendors `han-plugin-builder`'s skills into consumer repos, to run with no plugin installed. The
  vendored copies carry the line unchanged. Where `han-core` is installed, the line reaches the loader; where it is
  not, the run has no configuration, and the long-form `guidance` doc says so
  ([D-22](artifacts/implementation-decision-log.md#d-22-vendored-plugin-builder-copies-carry-the-line-unchanged)). Before the sweep, the
  implementer confirms this by reading `han-plugin-builder/skills/guidance/scripts/init-guidance.sh`. Read during this
  revision, it copies `skill-builder` and `agent-builder` verbatim apart from the `plugin-` renames, and the vendored
  `guidance` comes from `assets/guidance-portable-SKILL.md`, which carries no config block.

The sweep is scripted and grep-gated, not done by hand
([D-7](artifacts/implementation-decision-log.md#d-7-scripted-and-grep-gated-sweep)). Three hazards travel with it:

- `ddd-analysis` wraps the paragraph at different points, so the script matches it with whitespace normalized.
- `pairing` line 49 and `project-discovery` line 112 cite "the probe above". These get hand edits that point them at
  the run's `personal config directory` value from the loader instead.
- Commit `0e5f44f` shows a hand sweep that missed `pairing`. The count gate below catches the same miss.

### The shared config rule and the resolver script

> Superseded in part after execution: the shipped loader is a single probe whose script prints both files and
> the rule ([D-23](artifacts/implementation-decision-log.md#d-23-the-loader-is-one-probe-whose-script-prints-both-files-and-the-rule)),
> the twelve vendored copies of the rule are gone ([D-24](artifacts/implementation-decision-log.md#d-24-the-vendored-config-rulemd-copies-are-retired)),
> and the script is a regular file in `han-core/scripts/` with no symlink ([D-25](artifacts/implementation-decision-log.md#d-25-the-loader-script-lives-in-han-core-not-at-the-repo-root)).

The canonical `han-core/references/config-rule.md` is edited once and re-synced byte for byte into the 12 vendored
copies. All 13 copies stay ([D-9](artifacts/implementation-decision-log.md#d-9-edit-config-rule-once-and-keep-all-13-copies)).

- The opening paragraph says skills find both files through `han-core:load-han-config`, invoked once per run.
- The section on the two probes and the personal read opens by saying the loader carries the two probe lines and directs
  one Read-tool call. The rationale for the Read tool stays verbatim.
- One new paragraph carries the run definition above and the latest-wins rule.

`scripts/han-config-dir.sh` stays as the single place a lookup changes. Its symlinks narrow to `han-core`, the only
plugin whose SKILL.md still calls it ([D-10](artifacts/implementation-decision-log.md#d-10-script-stays-and-its-symlinks-narrow)).

- Kept: `han-core/scripts/han-config-dir.sh` (the loader).
- Removed: the other 12, in `han-atlassian`, `han-coding`, `han-communication`, `han-ddd`, `han-documentation`,
  `han-feedback`, `han-github`, `han-linear`, `han-planning`, `han-plugin-builder`, `han-reporting`, and
  `han-research`.

### The trial

The trial reruns the OI-3 subagent harness on the values case before anything ships past the guidance correction
([D-12](artifacts/implementation-decision-log.md#d-12-trial-harness-arms-and-pass-criterion)). Harness skills are
hot-loaded under `.claude/skills/` and removed afterward. Each trial runs in a fresh subagent told only to run the
skill. Every artifact lands under `artifacts/trial/` in this plan folder.

- Fixture values, chosen to be unlike any default:
  - `output-directory: trial-out-A`
  - `default-swarm-size: large`
  - `writing-voice: ./voice-fixture.md`, a file whose sentinel line is `VOICE_SENTINEL_K7Q`
  - `## Extra Agents` listing `han-core:code-reviewer` and the nonexistent `fake:ghost`
- Carried facts from the spike's incident file: `INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api`
- Completion token, the last line of every consumer artifact. Grammar, then a worked example:

  ```text
  CONSUMER_COMPLETE | TRIAL_ID=<id> | facts: <4 space-separated> | cfg: dir=<path|none> swarm=<band|none> voice=<sentinel|builtin|none> agents=<comma list|none>
  CONSUMER_COMPLETE | TRIAL_ID=CHN-03 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api | cfg: dir=trial-out-A swarm=large voice=VOICE_SENTINEL_K7Q agents=han-core:code-reviewer,fake:ghost
  ```

- Load counter: the harness loader appends one line to `<trial-dir>/<TRIAL_ID>.loads` each time its body runs. The
  write must append, never overwrite, or a double load reads as one. Grammar, then a worked example:

  ```text
  LOADED | TRIAL_ID=<id> | by=<invoking skill name>
  LOADED | TRIAL_ID=CHN-03 | by=trial-consumer
  ```

- A checker script compares each token's `cfg:` field to the arm's expected string and counts `.loads` lines. It never
  trusts the subagent's own claim.

| Arm            | What it checks                                                                                                   | N   |
| -------------- | ---------------------------------------------------------------------------------------------------------------- | --- |
| BASE           | Consumer carries today's block and calls no skill; isolates consumer flakiness                                   | 6   |
| INL            | Consumer calls the loader once, mid-workflow, through the pinned line                                            | 12  |
| WORST          | Loader ends on a final-sounding line and the consumer has no continuation guardrail                              | 10  |
| SONNET-WORST   | WORST on the smaller model                                                                                       | 6   |
| CHAIN          | Consumer loads, then calls a second skill carrying the line; `.loads` holds exactly 1 line                       | 12  |
| BLOCK-THEN-LINE | Consumer carries the old block, then calls a skill carrying the line; `.loads` holds 0 lines                    | 5   |
| DEPTH-2        | Consumer calls a second skill that carries the line and itself invokes the loader; `.loads` holds exactly 1 line | 6   |
| DIRECT         | Subagent runs the loader with no caller; correct values surface and it stops                                     | 6   |
| INL-NOGRANT    | Consumer without `Skill` in `allowed-tools`, default permission mode; records whether a prompt appears           | 4   |
| CFG-P, CFG-J, CFG-B, CFG-C, CFG-M, CFG-A | Personal only, project only, both disjoint, both conflicting, malformed, absent in both | 5 each |
| CFG-P-MISSING  | Personal directory points at a missing path; no note, no error, project values still apply                       | 5   |

The trial passes when every arm shows zero early exits and every carried fact and configured value is present. A
SONNET-WORST failure on its own narrows the guidance claim to the larger model and does not fail the trial. INL-NOGRANT
selects a branch rather than passing or failing. If any other arm fails, only the guidance correction and the
`explanation-guidance` block deletion ship
([D-13](artifacts/implementation-decision-log.md#d-13-what-ships-if-the-trial-fails)).

Skillwalker evals do not host the trial, because they cannot express per-arm counts, a side-effect file, or an artifact
check. They host one post-ship smoke eval of the shipped loader
([D-17](artifacts/implementation-decision-log.md#d-17-skillwalker-hosts-a-post-ship-smoke-eval-only)).

### The guidance edits

All guidance edits sit under `han-plugin-builder/skills/guidance/references/skill-building-guidance/`
([D-16](artifacts/implementation-decision-log.md#d-16-guidance-corrections-and-bounded-widening)).

- Before the trial, `troubleshooting.md` Cause 1 is retitled to the forked case. Its inline sentence is replaced with
  the spike's measured result and this pre-trial clause: "a values-only inline sub-skill is untested." Summary checklist
  item 8 changes to match.
- After the trial, `skill-composition.md` narrows "data-fetch composition (avoid)" to the forked case. The exception
  becomes "surfacing shared content inline", and property 2 takes this bounded wording, naming the config loader as the
  second validated case:

  > It surfaces content many consumers would otherwise duplicate (a whole standard, or a shared lookup's raw results)
  > and leaves interpretation to the caller; fetching one value for one skill is still inline discovery.

- `writing-effective-instructions.md` keeps its fork-only rule and gains one cross-reference to the exception.
- `graceful-degradation.md` line 102 is rewritten in the sweep phase to name the inline loader.
- `context-hygiene.md` is not edited. A citation for the cost of duplicate copies uses "Every token must earn its place"
  or "Treat stale context as a bug, not tech debt", never the issue's nonexistent quote.

### The guards that replace the probe checks

`scripts/han-config-dir.bats` keeps its three script tests and replaces the skill-scanning tests with a count gate
([D-11](artifacts/implementation-decision-log.md#d-11-bats-guards-replace-the-probe-checks)). The counts are the
contract between the sweep script and the test. The test "every plugin holding such a skill can reach the resolver
script" stays, and now covers only `han-core`.

| Assertion                                                                                         | Expected count |
| ------------------------------------------------------------------------------------------------- | -------------- |
| SKILL.md files carrying the consumer line verbatim, exactly once each                             | 44             |
| SKILL.md files carrying the 65-word paragraph (whitespace normalized)                             | 0              |
| SKILL.md files referencing `han-config-dir.sh` (the loader alone)                                 | 1              |
| `explanation-guidance` carries the line, the paragraph, or the script                             | 0              |
| Line carriers whose plugin is not `han-core` and does not list it in `dependencies` (every plugin) | 0              |
| Loader frontmatter containing `context: fork`                                                     | 0              |

## Work Units and Sequencing

Phase A ships on its own. Phase B gates C and D. Phase C lands the loader unused and the five dependency edges, so it
is safe alone: nothing calls the loader yet, and the edges only add an install. Phase D starts only when PR #172 no
longer edits any SKILL.md
([D-14](artifacts/implementation-decision-log.md#d-14-four-phases-with-gates),
[D-15](artifacts/implementation-decision-log.md#d-15-sequencing-with-pr-172)).

| #   | Work Unit                              | Story      | Delivers                                                                                                                                                                       | Justification                                                                                                                                         | Depends On       | Verification                                                                                               |
| --- | -------------------------------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ---------------------------------------------------------------------------------------------------------- |
| 1   | Phase A: guidance correction           | US-4       | `troubleshooting.md` Cause 1 and checklist item 8 say the inline values case is untested, not unreliable                                                                       | Issue step 1: "Correct `troubleshooting.md:473` to match the evidence"; "Step 1 stands regardless"                                                    | —                | Review against SA-11; the nonexistent context-hygiene quote appears nowhere in `han-plugin-builder/`       |
| 2   | Phase A: version bump                  | US-4       | One `han-plugin-builder` patch bump, kept in sync in `marketplace.json`                                                                                                         | Necessity of unit 1: `docs/semantic-versioning.md` requires a bump so users receive the change                                                        | 1                | `npm test` (`test/codex-packaging.bats`) passes                                                            |
| 3   | Phase B: trial harness and fixtures    | US-1, US-2 | Harness consumer, harness loader, WORST variant, second inline skill, fixture configs, voice file, checker script                                                              | Issue step 2: "Run an OI-3-shaped trial on the values case, with a worst-case arm"                                                                    | —                | Checker run against one hand-made passing and one failing artifact                                         |
| 4   | Phase B: run the trial and report      | US-1, US-2 | All arms run; `artifacts/trial/` holds every artifact, `.loads` file, and a report stating pass or fail, the INL-NOGRANT branch, and the trial's limits                          | Issue step 2 and step 3's condition: "If it holds"                                                                                                    | 3                | Checker output for every arm; harness skills removed from `.claude/skills/`                                |
| 5   | Phase C: loader skill                  | US-1, US-3 | `han-core:load-han-config`, built through `/han-plugin-builder:skill-builder`, with the pinned frontmatter, probes, H1, and hand-back                                          | Issue step 3: "add `load-han-config` to `han-core`" ([D-1](artifacts/implementation-decision-log.md#d-1-loader-lives-in-han-core-with-five-new-dependency-edges))                                                                                     | 4 passes         | Bats: loader has no `context: fork`; DIRECT smoke run                                                      |
| 6   | Phase C: loader doc surfaces           | US-3       | Long-form doc under the inline-guidance variant, `han-core` README scent line, skills index entry, CLAUDE.md layout line for `han-core`                                         | Necessity of unit 5: CLAUDE.md "Indexes stay complete" and `docs/templates/coverage-rule.md`                                                         | 5                | Index review lists the new skill in all three places                                                       |
| 7   | Phase C: `han-core` dependency edges   | US-1, US-2 | `han-core` added to `dependencies` in the `han-communication`, `han-feedback`, `han-linear`, `han-plugin-builder`, and `han-reporting` manifests, mirrored in `.claude-plugin/marketplace.json`; CLAUDE.md, CONTRIBUTING.md, `docs/concepts.md` (including line 266), `docs/choosing-a-han-plugin.md`, the five plugin descriptions, and the five front-door READMEs say so | Necessity of the user's direction that every skill reach the loader (E1) ([D-21](artifacts/implementation-decision-log.md#d-21-five-plugins-gain-a-direct-han-core-dependency))                                                         | 4 passes         | `npm test` passes; no surface says any of the five depends on nothing or on no other Han plugin; `han-core/skills` and `han-core/agents` still hold zero references to `han-communication` |
| 8   | Phase C: guidance widening             | US-4       | `skill-composition.md` exception and property 2 in the bounded wording; trial result beside the spike; `writing-effective-instructions.md` cross-reference; Cause 1 cites the trial | Issue step 5: "Widen property 2 of the exception to match the trial"                                                                                  | 4 passes         | Review against SA-11; wording names the config loader, not values in general                               |
| 9   | Phase C: version bumps                 | US-3, US-4 | `han-core` minor bump; at least a patch for each of the five plugins gaining an edge; `han-plugin-builder` covered by one bump for its edge and unit 8 unless unit 2's branch already covers it | Necessity of units 5, 7, and 8: `docs/semantic-versioning.md` (adding a skill is minor) ([D-20](artifacts/implementation-decision-log.md#d-20))                                   | 5, 7, 8          | `npm test` passes; `marketplace.json` matches every `plugin.json`                                          |
| 10  | Phase D: shared config rule            | US-2, US-3 | Canonical `config-rule.md` names the loader, carries the run definition and latest-wins, and is re-synced into all 12 copies                                                   | Necessity of issue step 4: the rule pins the per-skill probes, which become false after the sweep                                                     | 5, #172 gate     | All 13 copies share one checksum                                                                           |
| 11  | Phase D: scripted sweep and hand edits | US-1, US-3 | 44 skills carry the line; `explanation-guidance` drops its block; `readability-guidance` Step 1, `pairing`, and `project-discovery` hand edits; 12 unused symlinks removed; INL-NOGRANT branch applied | Issue step 4: "Cut each consuming skill's block to one line"                                                                                          | 5, 7, 10, #172 gate | Unit 12's count gate                                                                                    |
| 12  | Phase D: Bats guards                   | US-3       | `scripts/han-config-dir.bats` carries the count gate in place of the probe-in-every-skill checks                                                                               | Necessity of unit 11: today's tests assert the probe in every skill and would fail; the gate is what catches a missed file                            | 11               | `npm test` passes; deliberately reverting one swept file fails it                                         |
| 13  | Phase D: contributor and operator docs | US-2, US-3 | `CONTRIBUTING.md` "Adding a skill" step 2, `docs/configuration.md` line 7 clause, `graceful-degradation.md` line 102, CLAUDE.md's `scripts/` layout comment, the symlink count in `test/codex-packaging.bats`'s header comment, and the `guidance` long-form doc's note on vendored copies | Necessity of units 11 and 7: each describes the per-skill block, the symlinks, or the vendored skills as they were ([D-18](artifacts/implementation-decision-log.md#d-18-docs-and-contributor-surfaces-move-with-the-sweep)) | 11               | Each statement is true against the swept tree                                                              |
| 14  | Phase D: version bumps                 | US-2       | One patch bump for every plugin whose files changed (all 13, through the config-rule re-sync), recalculated from baseline                                                       | Necessity of units 10 to 13: `docs/semantic-versioning.md` ([D-20](artifacts/implementation-decision-log.md#d-20)) | 10 to 13         | `npm test` passes; `marketplace.json` matches every `plugin.json`                                          |
| 15  | Post-ship smoke eval                   | US-2       | One Skillwalker eval: a scaffold with a project config, asserting the loader is called and the configured swarm band is announced                                              | Necessity of unit 5: the trial tests a harness copy, so the shipped loader needs one check of its own ([D-17](artifacts/implementation-decision-log.md#d-17-skillwalker-hosts-a-post-ship-smoke-eval-only)) | 14               | The eval passes once on the shipped plugins                                                                |

Unit 15 rests on a runner nobody could inspect. Unverified: could not inspect the Skillwalker runner, because no runner
is in `package.json` and `CONTRIBUTING.md` does not document it.

## Definition of Done

- [ ] `troubleshooting.md` no longer says inline data-fetch is unreliable without evidence
  ([D-16](artifacts/implementation-decision-log.md#d-16-guidance-corrections-and-bounded-widening)).
- [ ] The trial report under `artifacts/trial/` records every arm's count and result, the INL-NOGRANT branch taken, and
  what the trial cannot measure ([D-12](artifacts/implementation-decision-log.md#d-12-trial-harness-arms-and-pass-criterion)).
- [ ] If the trial failed, nothing past Phase A and the `explanation-guidance` deletion merged
  ([D-13](artifacts/implementation-decision-log.md#d-13-what-ships-if-the-trial-fails)).
- [ ] Running `plan-a-feature` shows one `# Load Han Configuration` heading in context and no 65-word paragraph from
  any later skill in the chain ([D-3](artifacts/implementation-decision-log.md#d-3-rendered-loader-body-is-the-already-loaded-marker)).
- [ ] A skill invoked directly with a project `.han/config.md` applies its `output-directory`.
- [ ] `npm test` passes with the count gate at 44, 0, and 1
  ([D-11](artifacts/implementation-decision-log.md#d-11-bats-guards-replace-the-probe-checks)).
- [ ] The five manifests declare `han-core`, `marketplace.json` mirrors them, and no doc surface says any of the five
  depends on nothing ([D-21](artifacts/implementation-decision-log.md#d-21-five-plugins-gain-a-direct-han-core-dependency)).
- [ ] The `guidance` long-form doc says vendored skills apply config only when `han-core` is installed, and the
  implementer's read of `init-guidance.sh` is recorded in the PR
  ([D-22](artifacts/implementation-decision-log.md#d-22-vendored-plugin-builder-copies-carry-the-line-unchanged)).
- [ ] All 13 `config-rule.md` copies are byte-identical and carry the run definition
  ([D-9](artifacts/implementation-decision-log.md#d-9-edit-config-rule-once-and-keep-all-13-copies)).
- [ ] The loader has a long-form doc, a scent line, an index entry, and a CLAUDE.md layout mention
  ([D-19](artifacts/implementation-decision-log.md#d-19)).
- [ ] Every changed plugin has exactly one bump for its branch ([D-20](artifacts/implementation-decision-log.md#d-20)).
- [ ] `CONTRIBUTING.md`, `docs/configuration.md`, `graceful-degradation.md`, and CLAUDE.md's `scripts/` comment describe
  the loader and the single symlink
  ([D-18](artifacts/implementation-decision-log.md#d-18-docs-and-contributor-surfaces-move-with-the-sweep)).
- [ ] Nothing in `## Deferred (YAGNI)` was built, or its `Reopen when:` trigger fired and is recorded.

## Testing Strategy

- **Observable behaviors to test:**
  - A chained run loads config once: the CHAIN, DEPTH-2, and BLOCK-THEN-LINE `.loads` counts.
  - Configured values take effect after the loader returns: the artifact lands in `trial-out-A`, the token carries the
    voice sentinel and the band.
  - The caller keeps working after an inline sub-skill returns, including under a final-sounding loader close.
  - A direct invocation surfaces the config and stops.
  - Precedence and degradation hold across the six config states and a missing personal directory.
- **Edge cases requiring coverage:** malformed frontmatter in one file; a nonexistent extra agent (`fake:ghost`, skipped
  with a one-line note); no config anywhere (`cfg: none`, no note); the `ddd-analysis` paragraph wrapping; a skill that
  carries the old block calling one that carries the line (BLOCK-THEN-LINE; after the sweep no shipped skill keeps the
  block); a vendored `plugin-skill-builder` in a repo without `han-core` (D-22, checked by reading `init-guidance.sh`,
  not by a trial arm).
- **Test doubles posture and levels:** no doubles. Real files, real skills, and the real resolver script. The only
  non-real parts are trial-only harness skills, deleted afterward. The trial is the behavior level; Bats guards the
  sweep's structure; one Skillwalker eval smoke-tests the shipped loader.

## Risks and Assumptions

Risk IDs use `RK-` so they are not confused with round IDs.

### Risks

| ID   | Risk                                                                                                                                  | Impact                                                                                     | Mitigation                                                                                                                                    | Owner                 |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| RK-1 | An `api_retry` event after the loader returns anchors the caller, the failure behind the forked account. No harness can inject it.    | A caller stops early and treats the loader's output as its answer.                         | The loader returns no value to anchor on and ends with RETURN; the trial report states the gap; fault injection is deferred with a trigger.    | test-engineer         |
| RK-2 | The trial runs on one or two models, so the result may not hold for others.                                                          | The guidance claim overreaches.                                                            | SONNET-WORST arm; a failure there narrows the claim instead of passing silently.                                                             | test-engineer         |
| RK-3 | Codex may not run probes or Skill-to-skill calls, so rewired skills could lose config under Codex.                                   | Codex users lose their settings.                                                           | No new exposure class: 23 skills already rely on a Skill call to `readability-guidance` under Codex. Tracked as OI-4.                          | software-architect    |
| RK-4 | The sweep misses or half-edits a file, as commit `0e5f44f` did.                                                                       | A skill loses config or breaks at load.                                                    | Scripted sweep with whitespace-normalized matching and the Bats count gate.                                                                   | test-engineer         |
| RK-5 | Consumer repos keep the old guidance wording until they run `guidance update`.                                                       | Their authors keep avoiding the pattern.                                                   | Accepted; noted in the release notes. No outward push.                                                                                       | maintainer            |
| RK-6 | Missing `Skill` in `allowed-tools` may prompt or block in default permission mode.                                                   | Rewired skills prompt or fail to load config.                                              | INL-NOGRANT arm selects the branch before the sweep: add `Skill` to every line carrier, or correct the guidance sentence ([D-8](artifacts/implementation-decision-log.md#d-8-skill-grant-decided-by-trial)). | test-engineer         |
| RK-7 | PR #172 lands SKILL.md edits while the sweep runs.                                                                                   | Merge conflicts across 44 files.                                                           | Phase D gate: #172 no longer edits any SKILL.md.                                                                                              | maintainer            |
| RK-8 | The maintainer declines the five `han-core` dependency edges at review.                                                            | Rework to the `han-communication` placement.                                               | The superseded design is recorded in D-1's rejected alternatives and differs by one plugin folder and seven skills; Phase B gates the edges, so nothing past the trial is built on them before review. | maintainer            |

### Assumptions

| ID  | Assumption                                                                                                           | What Changes If Wrong                                                                | Status       |
| --- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ------------ |
| A1  | Every line carrier's plugin is `han-core` or declares it in `dependencies`, and dependencies are hard requirements. | The loader could be absent and the line would point at nothing.                      | Verified for the 7 plugins that declare it today (plugin manifests; discovery notes, dependency graph); true for the other 5 once unit 7 lands, checked by the count gate |
| A2  | A Skill-invoked sub-skill re-renders its probes and block today.                                                      | The duplication the plan removes would not exist.                                    | Verified (observed in this run; discovery notes) |
| A3  | `Skill` in `allowed-tools` pre-approves rather than gates the call.                                                   | The sweep adds `Skill` to every line carrier.                                        | Runtime-only (INL-NOGRANT arm) |
| A4  | The subagent harness predicts behavior in a real session.                                                             | The trial result does not transfer; the post-ship smoke eval is the backstop.        | Runtime-only |
| A5  | No unrecorded inline-failure evidence exists behind "both forms".                                                     | The Phase A wording changes to cite it, and the trial may need a new arm.            | Open (OI-1)  |
| A6  | Codex supports a skill invoking another skill.                                                                        | Rewired skills lose config under Codex.                                              | Open (OI-4)  |

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### `show` and `set` modes on the loader

- **Why deferred:** evidence test. Issue #203 does not ask for them and no finding needs them.
- **Reopen when:** a user request to view or edit config through Han is recorded.
- **Source:** R1, software-architect (SA-2), inherited from the July `origin/han-config-skill` branch.

### Resolved-values output with a `HAN_CONFIG_RESOLVED` marker line

- **Why deferred:** simpler-version test. Raw content under the existing labels meets the same need, and interpretation
  is per skill. See the rejected alternative on [D-2](artifacts/implementation-decision-log.md#d-2-loader-surfaces-raw-file-content-under-the-existing-labels).
- **Reopen when:** a trial arm or a user report shows a chained skill misapplying raw content.
- **Source:** R1, test-engineer (TE-4) and software-architect (SA-1).

### Retiring the 12 vendored `config-rule.md` copies

- **Why deferred:** evidence test. The issue does not ask, and 34 citation lines would break.
- **Reopen when:** the next `config-rule.md` edit forces a 13-copy re-sync, or a copy drifts.
- **Source:** R1, software-architect (SA-8).

### A SessionStart hook or fallback Read path for the 7 old-block skills

- **Why deferred:** evidence test. With the D-21 edges, no installed skill is left without the loader. The only
  remaining case is a vendored `han-plugin-builder` copy run without `han-core`, and no report shows one relying on
  config ([D-22](artifacts/implementation-decision-log.md#d-22-vendored-plugin-builder-copies-carry-the-line-unchanged)).
- **Reopen when:** a consumer repo reports a vendored builder skill ignoring its config, or the maintainer declines the
  dependency edges.
- **Source:** R1, software-architect deferred list.

### A scoped `Skill(han-core:load-han-config)` permission rule

- **Why deferred:** evidence test. No prompt has been observed.
- **Reopen when:** the INL-NOGRANT arm prompts and a blanket `Skill` grant is judged too broad.
- **Source:** R1, software-architect deferred list.

### API-layer `api_retry` fault injection

- **Why deferred:** evidence test. No harness can inject it, and the spike set the precedent of recording the gap.
- **Reopen when:** a user reports an inline early exit after shipping.
- **Source:** R1, test-engineer (S1).

### A Skillwalker eval per rewired consumer

- **Why deferred:** simpler-version test. One Bats guard asserts the line verbatim in every consumer.
- **Reopen when:** a consumer ships a non-canonical line.
- **Source:** R1, test-engineer (S2).

### Running the trial under Codex

- **Why deferred:** evidence test. Codex skill-to-skill behavior is undocumented.
- **Reopen when:** Codex documents skill invocation from a skill.
- **Source:** R1, test-engineer (S3).

### Re-running the OI-3 standard-case arms

- **Why deferred:** evidence test. Already measured at 34 of 34.
- **Reopen when:** the harness model changes.
- **Source:** R1, test-engineer (S4).

### Bats guards for `Skill` grants, index completeness, and config-rule byte identity

- **Why deferred:** evidence test. Grant enforcement is unknown, indexes are reviewed by hand per CLAUDE.md, and the
  copies have not drifted.
- **Reopen when:** the INL-NOGRANT result shows the grant matters, a merged skill misses an index entry, or a copy
  drifts, respectively.
- **Source:** R1, test-engineer (TE-6.6 to TE-6.8).

### Widening property 2 to "a few values" in general

- **Why deferred:** named anti-pattern, for-future-flexibility. One trial on one loader is evidence for one loader. The
  bounded wording replaces it; see [D-16](artifacts/implementation-decision-log.md#d-16-guidance-corrections-and-bounded-widening).
- **Reopen when:** a second values sub-skill is validated by its own trial.
- **Source:** R1, junior-developer (JD-12) and software-architect (SA-11).

## Open Items

None of these blocks implementation. Each has a recommended answer already built into the plan.

- **OI-1:** Does the maintainer hold unrecorded inline-failure evidence behind "unreliable in both forms", and which
  skill and Claude Code version did the original coworker report involve?
  - **Resolves when:** the maintainer replies on issue #203 with a transcript or a statement that none exists.
  - **Blocks implementation:** No. Phase A says "untested", which stays true either way; evidence of an inline failure
    would add a trial arm before Phase C.
- **OI-2:** Why did `origin/han-config-skill` stop?
  - **Resolves when:** the maintainer names a reason. A technical reason not already covered by V9, V10, or V11 gets a
    trial arm or a decision before Phase C.
  - **Blocks implementation:** No. Its three recorded concerns are each handled here (D-8, D-12, D-1 with D-21).
- **OI-3:** How does the maintainer want this sequenced with PR #172?
  - **Resolves when:** PR #172 no longer edits any SKILL.md, by rebase to the one-line script change, a split, merge, or
    close.
  - **Blocks implementation:** No for Phases A to C. Phase D waits on it by design
    ([D-15](artifacts/implementation-decision-log.md#d-15-sequencing-with-pr-172)).
- **OI-4:** Does Codex run context-injection probes and let one skill invoke another?
  - **Resolves when:** Codex documentation or a Codex session shows a Skill call from a skill completing with config
    applied, or failing.
  - **Blocks implementation:** No. 23 skills already rely on a Skill call to `readability-guidance` under Codex, so the
    plan adds no new exposure class. Codex manifests carry no dependency field, so the D-21 edges do not apply there
    either.
  - Unverified: could not inspect Codex behavior, because nothing in the repository documents it and no Codex session
    was available.
Other unverified inputs the plan carries, none of them blocking:

- The Skill tool's response to an uninstalled skill name. It matters only for a vendored `han-plugin-builder` copy run
  without `han-core` (D-22), where the intended result is a run with no configuration. Unverified: could not inspect it,
  because no session without the target plugin installed was available.
- This run invoked a sub-skill without a `Skill` grant and was not prompted, but its permission mode is unrecorded.
  INL-NOGRANT settles it. Unverified: could not inspect this run's permission mode, because it is not recorded.

## Specialist Handoffs for Implementation

- **`han-core:test-engineer`**: dispatch at the start of Phase B to build the harness, fixtures, and checker against the
  pinned token and `.loads` grammars; needs this plan's trial subsection and `round-1-test-engineer.md`. Dispatch again
  at Phase D for the count gate; needs the INL-NOGRANT branch taken.
- **`han-core:software-architect`**: dispatch if any trial arm other than SONNET-WORST fails, to re-scope Phases C and
  D; needs the trial report. Dispatch also if the maintainer declines the dependency edges (RK-8), to restore the
  `han-communication` placement; needs D-1's rejected alternatives.
- **`han-core:system-architect`**: dispatch only if the maintainer asks for a review of the five new dependency edges
  before accepting them, or OI-4 shows Codex cannot run Skill calls; needs D-1, D-21, and the dependency-graph
  measurements in `.discovery-notes.md`.

## Sources and Plan Records

- **Feature specification:** no source specification file. The plan was built from
  [issue-203.md](issue-203.md), GitHub issue #203 verbatim plus the maintainer's comment, not from a `plan-a-feature`
  spec. No spec decision log, team findings, or technical notes exist.
- **Recorded boundary:** [artifacts/scope-boundary.md](artifacts/scope-boundary.md)
- **Measurements and prior attempts:** [artifacts/.discovery-notes.md](artifacts/.discovery-notes.md)
- **Specialist reports (verbatim):** [test-engineer](artifacts/round-1-test-engineer.md),
  [software-architect](artifacts/round-1-software-architect.md),
  [junior-developer](artifacts/round-1-junior-developer.md)
- **YAGNI and scope ledger:** [artifacts/.yagni-ledger.md](artifacts/.yagni-ledger.md)
- **Decision rationale and rejected alternatives:**
  [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:**
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned. Phase A can merge now. Phase B gates Phases C and D, and Phase D also waits for PR #172 to stop editing
SKILL.md files. The five new `han-core` dependency edges (D-21) are the item the maintainer may decline at review. If
that happens, the `han-communication` placement recorded in D-1's rejected alternatives returns, which differs by one
plugin folder and seven skills (RK-8).

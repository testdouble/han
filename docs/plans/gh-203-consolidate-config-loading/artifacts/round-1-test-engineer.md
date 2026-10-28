# Round 1: test-engineer findings, issue #203 (consolidate config loading)

Sources read: `issue-203.md`, `scope-boundary.md`, `.discovery-notes.md` (Measurements relied on as measured),
`OI-3-spike-report.md` plus `harness-skills/spike-consumer-inline` and `spike-guidance-inline` and `spike-trials/INL-01.md`,
`scripts/han-config-dir.bats`, `han-core/references/config-rule.md`, `han-communication/skills/readability-guidance/SKILL.md`,
`evals/architectural-analysis/tests.json`, plugin manifests. Nothing was executed; every prediction below is from reading.

## Coverage assessment

Tested today: the resolver script's two outputs, and the probe and grant text in every skill that carries them
(`scripts/han-config-dir.bats`). Untested today: everything about what a skill does with resolved values. No test, bats or eval,
asserts that `output-directory`, `default-swarm-size`, `writing-voice`, or extra agents take effect (grep of `test/*.bats`,
`scripts/*.bats` for `config-rule` returns nothing; no eval folder covers config). The 12 vendored `config-rule.md` copies
have no byte-identity guard (same grep). So the sweep removes the only guarded surface and the new surface starts at zero.

## Findings

### TE-1: The trial is a values trial; build it as a clone of the spike's inline consumer plus a fixture config
- **Category:** Required (grounds step 2 of `issue-203.md#proposal`)
- **Entry point:** a harness consumer and a harness loader, created for the trial only, under the plan's artifacts folder
  and hot-loaded into `.claude/skills/` as in `OI-3-spike-report.md#how-the-spike-was-built`, removed afterward.
- **Harness consumer (clone of `spike-consumer-inline`, six steps):**
  1. Read an incident file and extract four facts (reuse `incident-data.md`: `INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api`).
  2. Hold them as a working note.
  3. Invoke the loader (the mid-workflow Skill call; the one line under test).
  4. Use each resolved value: write the artifact to `<output-directory>/<TRIAL_ID>.md`; state the swarm band and the file that
     supplied it; read the writing-voice file and quote its sentinel line; list the extra agents it would add to its pool.
  5. Draft the five-section report (spike's step 4).
  6. Write the artifact and end with the completion token.
- **Completion token (pin it; the spike's token is the grammar to extend), exact worked example:**
  `CONSUMER_COMPLETE | TRIAL_ID=CHN-03 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api | cfg: dir=trial-out-A swarm=large voice=VOICE_SENTINEL_K7Q agents=han-core:code-reviewer,fake:ghost`
  Grammar: `CONSUMER_COMPLETE | TRIAL_ID=<id> | facts: <4 space-separated> | cfg: dir=<path|none> swarm=<band|none> voice=<sentinel|builtin|none> agents=<comma list|none>`.
  The checker is a Bats or shell script comparing the token's `cfg:` field to the arm's expected string, not the subagent's claim.
- **What the artifact lets a checker verify without trusting the subagent:** file exists at the configured directory (proves
  `output-directory` was applied, because the location is the observable); token present and last line; four facts intact;
  five sections; `cfg:` field equals expected.
- **Fixture values must be unmistakable and unlike defaults:** `output-directory: trial-out-A`, `default-swarm-size: large`,
  `writing-voice: ./voice-fixture.md` containing the sentinel `VOICE_SENTINEL_K7Q`, `## Extra Agents` with one real name and
  one nonexistent (`fake:ghost`, expected to be skipped with a one-line note naming it, per `config-rule.md#extra-agents-joining-the-pool`).
- Unverified: could not run a subagent, because this role plans only; whether a subagent inherits a `CLAUDE_CONFIG_DIR` set by
  the launcher is not documented in the repo (the spike never varied environment).

### TE-2: Arms, assertions, pass criteria, trial counts
Baseline attributes failure to the Skill call, exactly as `OI-3-spike-report.md#why-a-baseline-arm`.

| Arm | Mechanism | Asserts | N |
|---|---|---|---|
| BASE | consumer carries today's probe block and applies config itself, no Skill call | token, facts, cfg equals expected | 6 |
| INL | loader called once, consumer step 3, guardrail present | token, facts, cfg, artifact at configured dir | 12 |
| WORST | loader's last line is final-sounding ("Configuration resolved. Nothing further is required."), consumer has no continuation guardrail, copy of `spike-guidance-adversarial` | token, facts, cfg | 10 |
| CHAIN | consumer calls loader, then calls a second inline harness skill carrying the one-line instruction (a stand-in for `readability-guidance`) which reads `writing-voice` | token, cfg, and loader ran once (below) | 12 |
| DIRECT | loader invoked by the subagent with no caller; prompt "run `load-han-config`" only | loader's output block present, correct values, subagent stops after reporting | 6 |
| CFG-P, CFG-J, CFG-B, CFG-C, CFG-M, CFG-A | personal-only, project-only, both disjoint, both conflicting, malformed frontmatter in one file, absent in both | cfg field per `config-rule.md#precedence`; for CFG-M a one-line note naming the file; for CFG-A no note and `cfg: none` | 5 each (30) |
| SONNET-WORST | WORST on `model: sonnet` | as WORST | 6 |

- **Chain idempotence assertion (TE-4 explains why):** the loader writes a marker into context; the harness loader also appends
  one line to `<TRIALS_DIR>/<TRIAL_ID>.loads` each time its body is executed, via Write. CHAIN passes only if that file holds
  exactly one line. This is the one place a trial-only side effect is warranted: it turns "did not re-resolve" into a file.
- **Pass criterion:** deterministic outcomes (CFG-*, DIRECT, values correct) must be all-pass; one wrong value fails the arm,
  because a wrong value is a wrong write location or voice, not a flaky style. Completion arms (INL, WORST, CHAIN, SONNET-WORST)
  follow the spike: zero early exits. A WORST failure blocks step 3 of the proposal; a SONNET-WORST failure alone narrows the
  guidance claim to Opus and is recorded, not blocking (the spike recorded model-specificity as a caveat, `OI-3-spike-report.md#the-limitation-this-spike-could-not-overcome`).
- **Why these N:** 12 and 10 match the spike so results compare. With zero failures the 95% upper bound on the failure rate is
  about 22% at N=12 and about 26% at N=10 (rule of three: 3/N, approximate); the spike's 0/34 pooled bound is about 9%.
  This trial can claim "no failure seen in 40 completion trials" (INL+WORST+CHAIN+DIRECT combine to 40 with the spike's 34 as a
  separate population), not "cannot fail". The config-state arms are small (5) because their fixtures are deterministic and
  the question is correctness of one resolution, not a rate. Total about 87 trials; one subagent each.
- Unverified: counts are my estimate of what the trial needs; the 95% bounds are arithmetic, not measured.

### TE-3: What the trial cannot measure (record this in the trial report, not only in the guidance)
1. `api_retry`. The spike could not inject it and neither can this trial (`OI-3-spike-report.md#the-limitation-this-spike-could-not-overcome`).
   The values case is the same exposure: the model resumes after a sub-skill returns. Say so, reduced by inference, not measured.
   The only faithful test is an API-layer proxy forcing retries; recommend it as `Category: YAGNI candidate`, trigger: a
   production report of an inline early exit (none exists, `.discovery-notes.md#gaps`).
2. Models other than the ones run (spike: Opus 4.8 only). SONNET-WORST narrows this, does not close it.
3. Codex. The notes record no statement of whether Codex runs probes or supports skill-to-skill calls
   (`.discovery-notes.md#gaps`). The trial runs on Claude Code only; the Codex manifests are structural.
4. Whether `Skill` in `allowed-tools` is enforced: 6 shipped skills list it, 39 do not, and consumers like `plan-a-feature` do
   already call `readability-guidance` (`.discovery-notes.md#the-works-figures-measured`, Skill-in-allowed-tools line). The
   spike consumers granted `Skill`. Add one arm variant, INL-NOGRANT (consumer without `Skill` in allowed-tools, N=4), so the
   guard in TE-6 requires or does not require the grant on evidence. Without it the guard is a guess.
5. Context-window contents. A subagent cannot show what is in its context; copies-in-context is inferred from the `.loads`
   file and from the rendered probe text, not inspected.

### TE-4: Idempotence of "if you have not already this run" needs a detectable signal; today it is prose only
- **Entry point:** the one-line instruction in `issue-203.md#proposal` item 4 and the future `han-core/skills/load-han-config/SKILL.md`.
- **Gap:** the line says "already this run" but nothing says how a model decides. In CHAIN the second skill sees the first skill's
  loader output in context, so a visible marker is the only detectable signal. **Contract carrying only prose: flag.**
  Pin a worked example of the loader's output (the contract the consumer, the second inline skill, and the guard all agree on):
  ```
  HAN_CONFIG_RESOLVED | personal=present | project=absent
  - output-directory: /home/u/out (personal .han/config.md)
  - default-swarm-size: large (personal .han/config.md)
  - writing-voice: /home/u/.claude/voice.md (personal .han/config.md)
  - extra agents: han-core:code-reviewer (personal .han/config.md)
  - note: <one line naming the ignored item and which file held it>
  ```
  and the consumer rule "when a line beginning `HAN_CONFIG_RESOLVED` is already in your context, use it; do not invoke again".
  Each value line names its source file, as `config-rule.md#degradation-and-the-one-line-note` already requires.
- **Test:** CHAIN arm (TE-2). Kill set: a loader that omits the marker, or a one-line instruction that omits "if you have not
  already", makes the `.loads` file hold two lines; no existing test fails under either change (none touches config behavior).
- **Discriminating power for DIRECT:** the idempotence hint must not suppress a direct call; DIRECT guards that "already this
  run" never turns the loader into a no-op when it is the first and only skill.

### TE-5: Can Skillwalker evals host this? Partly, and not the trial
- **Evidence:** `evals/*/tests.json` fields (read `evals/architectural-analysis/tests.json`; counted across all files):
  types `skill-prompt` and `skill-call`; `plugins`, `model`, `promptFile`, `scaffold`; expects `skill-call` (68), `agent-call` (36),
  `llm-judge` (9), `result-contains` (10), `result-does-not-contain` (9). `scaffold` names a fixture project directory
  (`evals/project-discovery/scaffolds/polyglot-project`), which can carry a project `.han/config.md`.
- **What it can host (regression layer, after step 3 ships):** a scaffold carrying a project `.han/config.md` with
  `default-swarm-size: large` and a prompt invoking a swarm-sizing skill; expects `skill-call` for `han-core:load-han-config`
  (a real behavior: the consumer's one line triggered the loader) and `result-contains` the announced band plus the supplying
  file. A DIRECT eval (`skill-call` type, prompt "load my han config") also fits and answers the open question "is one line
  enough when a skill is invoked directly" only for the loader's discoverability by description. Both are single-run checks
  at one sample, so they are smoke tests, not trial evidence.
- **What it cannot host:** per-arm N, a `.loads` side-effect check, a completion token judged from a file on disk, a worst-case
  arm with a rewritten loader, and the personal-only arms (no field sets `CLAUDE_CONFIG_DIR`; `promptFile`/`scaffold` are the
  only inputs). `result-contains` checks the final result text, not an artifact path.
- **Verdict:** the trial needs the spike's subagent harness; evals host the shipping smoke layer. Keep the two separate.
- Unverified: could not inspect the Skillwalker runner or its docs, because no runner is in `package.json` and
  `CONTRIBUTING.md` does not document it (`.discovery-notes.md#test-and-eval-surfaces`); a runner may support env or file setup
  that `tests.json` fields do not show.

### TE-6: Bats guards after the sweep (replace the probe guards in `scripts/han-config-dir.bats`)
Keep as is: resolver exists and is executable; honors `CLAUDE_CONFIG_DIR`; falls back to `$HOME/.claude` (these tests test the
script, which the loader still calls). Replace the four skill-scanning tests with the following. `consumers` = every shipped
`*/skills/*/SKILL.md` except the loader's.
1. **Every consumer carries the one line, verbatim, exactly once.** Exact text pinned from `issue-203.md#proposal` item 4:
   `Resolve configuration with \`han-core:load-han-config\` if you have not already this run.` Assertion: `grep -cF` equals 1
   per consumer. Kill set: a skill that kept the old block and dropped the line, or paraphrased it. Today's exact-text test
   already fails under paraphrase only for the old text, so this replaces it, not duplicates it.
2. **No consumer carries any of the old pieces:** no line matching `personal config directory`; no `.han/config.md` probe
   `cat .han/config.md`; no `han-config-dir.sh` in `allowed-tools`; no `As your first action, use the Read tool`; no link to
   `config-rule.md` unless the plan decides consumers still link it (decision needed: the issue is silent on the 12 vendored
   copies, `issue-203.md#proposal`). Kill set: a half-swept skill. This is the guard against the 12-times-a-week churn the notes
   record, so a hand edit that reintroduces the block is caught.
3. **Only the loader carries the probes and the grant:** loader contains the exact current `PROBE` and `GRANT` text and the
   `As your first action, use the Read tool` instruction; exactly one SKILL.md in the repo does. Kill set: a second skill
   quietly re-adding the probe (the double-load the issue describes). Also the existing "plugin can reach the resolver script"
   test narrows to `han-core` only, since only the loader runs it. Kill set: deleting the `han-core/scripts` symlink.
4. **Dependency reachability, the structural test the five non-han-core plugins force:** for every consumer, the plugin's
   `.claude-plugin/plugin.json` lists `han-core` in `dependencies`, or the skill is on an explicit allow-list. Measured today:
   han-communication, han-feedback, han-linear, han-plugin-builder, han-reporting carry zero `"han-core"` matches in their
   manifests (my check above; han-core's manifest also matches zero for dependencies). The test turns the open decision into a
   failing test, so nobody can ship a one-line instruction pointing at an uninstalled skill. Without it, nine skills (per
   `.discovery-notes.md`, V11) degrade silently.
5. **Loader is inline and contained:** frontmatter has no `context: fork` (the property the spike disqualified,
   `OI-3-spike-report.md#the-decisive-secondary-finding-forked-does-not-surface-content`), and its `allowed-tools` grants `Read`
   and the exact script command. Kill set: someone adding `context: fork`, which drops values on the floor.
6. **Callers that invoke a skill grant `Skill`:** only if INL-NOGRANT (TE-3 item 4) shows it matters; otherwise drop. Category:
   YAGNI candidate until measured; trigger: INL-NOGRANT shows a failure, or the loader's enforcement is documented.
7. **Index completeness for the new skill:** long-form doc, plugin README scent line, skills index entry. Existing guard: none
   found in `test/`; `docs/templates/coverage-rule.md` is a rule, not a test. Add one bats check only if the plan adds the others
   by hand; otherwise a review gate. Category: YAGNI candidate; trigger: first merged skill missing an index entry.
8. **Byte-identity of surviving `config-rule.md` copies**, if any survive: no guard exists today; with a loader the copies drift
   risk drops. Category: YAGNI candidate; trigger: plan keeps more than the canonical copy.
- **Brittleness:** 1 pins one sentence; accepted because that sentence is the cross-component contract (a consumer, the loader,
  the guard), and the guard exists so a change is made once. Tests 2 and 3 use `grep -cF` on literal text, as the current bats does.

### TE-7: Behaviors the plan must cover (from your list), with test level and evidence
| Behavior | Level | Evidence and assertion |
|---|---|---|
| Chain idempotence | trial (CHAIN) | TE-4; `.loads` has one line |
| Loader invoked directly | trial (DIRECT) then one eval | answers `issue-203.md#open-questions` item 3 for discoverability: the loader's `description` must name config resolution; assert a direct prompt triggers `skill-call` |
| Consumer in a non-`han-core` plugin without `han-core` | bats TE-6.4 plus one manual run | Behavior is not specified by the issue: pick fail-closed or accept degradation. Manual run: install only `han-reporting`, run `stakeholder-summary`, assert it completes and says nothing broken. Cannot be automated here (no installer in harness). |
| Personal-config Read degrading silently | trial arm CFG-P with the personal directory pointed at a missing path (add CFG-P-MISSING, N=5) | `config-rule.md#degradation-and-the-one-line-note`: no note, no error, project values still apply. Today `scripts/han-config-dir.bats` does not touch this. Open question 2 of the issue (`issue-203.md#open-questions`) is the decision moving to the loader; this arm verifies it survived. |
| readability-guidance resolving `writing-voice` after the loader | trial CHAIN stand-in, then one real-skill run | `readability-guidance/SKILL.md` Step 1 reads "either `.han/config.md` probe". After the sweep that probe is gone, so Step 1 must read the loader's `writing-voice` line instead. **This is a required edit with no stated owner; flag.** Assertion: the artifact quotes `VOICE_SENTINEL_K7Q` from the configured file; a missing voice file yields the warning and the question, not silence. |
- **Structural problem the trial does not surface:** `readability-guidance` and `explanation-guidance` live in `han-communication`,
  which depends on nothing (`CLAUDE.md` project map); a `han-core:load-han-config` call from them cannot resolve when han-core
  is absent. These two are the loader's main chain targets (24 and 8 callers per the issue), so TE-6.4 will fail on them first.
  Options for the plan to choose, not for me: they keep their own block (undoing the issue's headline win for them), or
  han-communication gains a han-core dependency (breaks "depends on nothing"), or the loader lives in han-communication.
  Unverified: could not inspect how Claude Code resolves a qualified skill name when the plugin is absent, because it needs a
  live install; the repo records no measurement.

### TE-8: Test doubles
None recommended. Real files (fixture `.han/config.md`, real `voice-fixture.md`, real resolver script) and real skills are usable
everywhere. The one non-real element is the harness loader variant used for WORST and for the `.loads` write; it is a
trial-only skill, deleted afterward as the spike's scaffolding was, and the shipped loader is tested unmodified in the eval
smoke layer (TE-5) and bats (TE-6). Do not mock `Skill` or `Read`; a mock would remove the behavior under test.

### TE-9: Guidance correction (step 1 of the proposal) test
- **Entry point:** `han-plugin-builder/skills/guidance/references/skill-building-guidance/troubleshooting.md:473` (line number measured
  in the notes). A bats check is justified only for the one false citation the notes found: `context-hygiene.md:104` quote
  "The attention cost is per-context, not per-file" does not exist. Assertion: `! grep -rF "The attention cost is per-context" han-plugin-builder/`
  after the edit. Kill set: carrying the issue's wrong quote into the guidance. Priority: Medium; cheap and the failure is
  specific. Do not add a bats test for wording of the rewritten rule (brittle prose snapshot).

## Deferred / Skipped (YAGNI)

- **S1 API-layer retry injection proxy.** Category: YAGNI candidate. Behavior guarded: early exit after `api_retry`; no recorded
  inline occurrence. Trigger: a user report of an inline early exit. Discriminating power: not determined; no existing test
  injects retries, so no existing test fails under the change this would catch, and none could.
- **S2 Per-skill eval for all 45 consumers.** Category: YAGNI candidate. The one-line sentence is the same everywhere and TE-6.1
  pins it; one DIRECT eval plus the CHAIN trial catch the realistic failures. Trigger: a consumer whose line is not the
  canonical one (an exception to TE-6.1).
- **S3 Codex run of the trial.** Trigger: the notes' gap closes (Codex documents skill-to-skill calls).
- **S4 Re-run of 34-trial spike arms on the loader unmodified.** The spike's standard result stands; the values case is the
  open question (`issue-203.md#what-the-evidence-shows`, last paragraph).

## Priority and counts
High: TE-1, TE-2, TE-4, TE-6 (1, 2, 3, 4, 5), TE-7 readability and non-han-core rows. Medium: TE-3 INL-NOGRANT, TE-5 smoke evals, TE-9.
Low: TE-6.6 to 6.8 as YAGNI candidates. Skipped: S1 to S4.

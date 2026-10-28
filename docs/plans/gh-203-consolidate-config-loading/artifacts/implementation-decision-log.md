# Implementation Decision Log: Consolidate config loading (issue #203)

<!--
This file records every implementation decision committed while planning the consolidation of config loading.
Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md);
this file captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

Full: has rejected alternatives, evidence beyond the user's framing, was changed across rounds, has dependents, or has
dissent. Trivial: settled by the work item or an obvious convention. The D-N counter is shared across both sections.
Trivial entries carry an HTML anchor so the plan's inline links resolve.
-->

## Trivial decisions

- D-19: <a id="d-19"></a>Loader built through skill-builder with the inline-guidance doc variant. The loader is authored
  with `/han-plugin-builder:skill-builder` per CLAUDE.md, gets a long-form doc under
  `docs/templates/coverage-rule.md#the-inline-guidance-variant` (as `readability-guidance` has) at
  `han-core/docs/skills/load-han-config.md`, a `han-core` README scent line, an entry in `docs/skills/README.md`, and a
  mention in CLAUDE.md's `han-core` description and layout line. — Referenced in plan: Implementation Approach (What the loader surfaces), Definition of Done.
- D-20: <a id="d-20"></a>Version bumps follow the one-bump-per-branch policy. `han-core` takes a minor for the new
  skill. The five plugins gaining a `han-core` edge (`han-communication`, `han-feedback`, `han-linear`,
  `han-plugin-builder`, `han-reporting`) each take at least a patch; for `han-plugin-builder` the same bump covers the
  guidance edits. Every plugin whose files change in Phase D (all 13, through the config-rule re-sync) takes a patch.
  Each bump is recalculated from its branch baseline and mirrored in `marketplace.json` per
  `docs/semantic-versioning.md`. — Referenced in plan: Work Units and Sequencing, Definition of
  Done.

## Full decisions

### D-1: Loader lives in han-core with five new dependency edges

- **Question:** Which plugin hosts `load-han-config`, given that the issue's step 3 names `han-core` and the chain it
  targets lives in `han-communication`?
- **Decision:** The loader is `han-core/skills/load-han-config/SKILL.md`, invoked as `han-core:load-han-config`, beside
  `project-discovery` as the issue's step 3 says. The five plugins that do not declare `han-core` gain it as a direct
  dependency (D-21), so every skill can reach the loader. This supersedes the earlier decision to place the loader in
  `han-communication`, which stays below as a rejected alternative.
- **Rationale:** The user, who wrote issue #203, chose this after reading the plan: "let's put it into han-core and make
  it a dependency of all other plugins so that we cover all skills. If maintainer declines, we can always refactor."
  It matches the issue's step 3. It reaches the issue's chain (`plan-a-feature` to `readability-guidance` to
  `explanation-guidance`) through the new `han-communication` edge, with no fallback sentence. It leaves no skill on the
  old block, so one pattern holds for every skill, including new ones.
- **Evidence:**
  - The user's direction, escalation register entry E1 in the iteration history.
  - No cycle results: `han-core/skills` and `han-core/agents` hold zero references to `han-communication` (grep,
    measured by the user), and `docs/plans/reduce-required-install-footprint/investigation.md` cut the edge from
    `han-core` to `han-communication` for that reason.
  - Plugin manifests (`.discovery-notes.md`, "Plugin dependency graph"): today 7 plugins (35 skills) depend on
    `han-core`, and they exclude both guidance skills. 8 plugins (38 skills) depend on `han-communication`.
  - JD-1, TE-7, SA-5, SA-6 all identify the reachability gap. The July branch recorded it as V11.
- **Rejected alternatives:**
  - `han-communication`, the prior D-1 decision, now superseded — it reached the issue's chain with zero dependency
    changes, because 8 plugins already depend on `han-communication`, and it needed no fallback sentence. Rejected
    because 7 skills (`project-discovery`, `pairing`, `han-feedback`, `work-items-to-linear`, `agent-builder`,
    `guidance`, `skill-builder`) could not reach it and would keep the old block, which leaves two patterns side by side
    and 8 SKILL.md files on the resolver script, and because it departs from the issue's step 3. The prior record also
    rejected adding a `han-core` dependency to `han-communication`, because CLAUDE.md states `han-communication`
    "depends on nothing and every prose-producing plugin depends on it". That cost is now accepted and recorded in D-21.
    This is the design that returns under the revisit criterion: line `han-communication:load-han-config`, 37 line
    carriers, 7 old-block skills, 8 script references.
  - `han-core` with no new edges and SA-5's fallback sentence in `readability-guidance` — rejected because the
    fallback's trigger rests on the Skill tool's response to an uninstalled skill name, which is Unverified, and 10
    skills still could not reach the loader.
  - Rewiring only the ~13 chain targets (JD-2) — rejected under D-6; it does not decide placement on its own.
- **Specialist owner:** software-architect (placement); maintainer (accepts or declines the edges at review).
- **Revisit criterion:** the maintainer declines the dependency edges at review. The `han-communication` placement then
  returns as recorded above.
- **Dissent (if any):** SA-6 rejected a new `han-core` dependency "at this altitude" and deferred it to
  `system-architect`, who was not dispatched. Recorded under disagree-and-commit: the user made the call with the
  no-cycle evidence, and the maintainer's review is the check.
- **Driven by rounds:** R1, R2, E1.
- **Dependent decisions:** D-5, D-6, D-9, D-10, D-11, D-14, D-18, D-19, D-20, D-21, D-22.
- **Referenced in plan:** Outcome, Implementation Approach (Where the loader lives), Work Units and Sequencing, Risks
  and Assumptions, Recommendation.

### D-2: Loader surfaces raw file content under the existing labels

- **Question:** Does the loader emit raw file content or resolved values?
- **Decision:** The loader surfaces the `personal config directory` value, the `project .han/config.md` value, and the
  personal file read with the Read tool, under labels byte-identical to today's block. It resolves nothing and emits no
  note. Pinned form, the rendered caller context with a project file and no personal file:

  ```text
  - personal config directory: /home/tami/.claude
  - project .han/config.md: ---
  output-directory: docs/han
  ---
  [Read /home/tami/.claude/.han/config.md -> file does not exist]
  ```

  Pinned frontmatter values: `name: load-han-config`;
  `allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")`; no `context` key. The
  description names `han-core:load-han-config` and "resolve configuration". The body follows SA-2's sketch as written;
  its rule link resolves to the canonical `han-core/references/config-rule.md`.
- **Rationale:** Precedence levels 1, 4, 5, and 6 and the silent-ignore rule are per skill, so a loader can never finish
  resolution. A resolved shape would split interpretation across two places. Identical labels let the skills that read
  config by label (`readability-guidance`, `edit-for-readability`, `pairing`, `project-discovery`) work unchanged,
  whether the loader or an old-block skill supplied the text.
- **Evidence:** SA-1 and SA-2; `config-rule.md` sections on precedence and on degradation and the one-line note; the
  personal-read rationale ("a probe cannot prompt and cannot degrade") survives because the loader also uses Read.
- **Rejected alternatives:**
  - Resolved values behind a `HAN_CONFIG_RESOLVED` marker line (TE-4, JD-5) — rejected because raw content under the
    existing labels is the strictly simpler version that meets the same need. Deferred under YAGNI with a reopen trigger.
- **Specialist owner:** software-architect.
- **Revisit criterion:** a trial arm or a user report shows a chained skill misapplying raw content.
- **Dissent (if any):** TE-4 proposed the marker shape; resolved in R2 without re-dispatch because the rendered loader
  body supplies the signal TE-4 needed (D-3).
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** D-3, D-12.
- **Referenced in plan:** Implementation Approach (What the loader surfaces), Deferred (YAGNI).

### D-3: Rendered loader body is the already-loaded marker

- **Question:** What lets a later skill in the chain see that config is already loaded this run?
- **Decision:** The loader's own rendered body in the caller's context: its H1 `# Load Han Configuration` and its
  hand-back paragraph. No separate marker line. When the loader runs twice, the latest copy wins. Pinned hand-back
  paragraph:

  > The `personal config directory` and `project .han/config.md` values above, and the personal file you just read, are
  > this run's Han configuration. They replace any copy surfaced earlier in this context. Apply them per
  > [config-rule.md](../../references/config-rule.md) at the point your own workflow uses a setting. Say nothing about
  > the configuration here. RETURN to the skill that invoked you and continue with its next step.

- **Rationale:** A probe cannot be conditional, so the skip must happen in the caller's line before the loader is
  invoked, and the only signal the caller has is earlier text in context. The loader's body is already there; adding a
  marker line adds a second form to keep in sync. Latest-wins makes a redundant load harmless, and a copy lost to
  compaction makes the check fail and reload.
- **Evidence:** SA-2 ("Already resolved" reporting), SA-4; observed re-render of a sub-skill's block
  (`.discovery-notes.md` Measurements).
- **Rejected alternatives:**
  - A fixed `HAN_CONFIG_RESOLVED | personal=... | project=...` line (TE-4) — rejected because the rendered body already
    serves as the marker; a second form is a contract with no extra consumer.
  - A detection step inside the loader — rejected because the loader's probes inject at load, before any instruction
    runs, so it cannot skip its own cost (SA-2).
- **Specialist owner:** software-architect; test-engineer verifies through the CHAIN, DEPTH-2, and BLOCK-THEN-LINE arms.
- **Revisit criterion:** the CHAIN or DEPTH-2 arm records more than one `.loads` line, or BLOCK-THEN-LINE records any.
- **Dissent (if any):** none beyond TE-4's original shape (see D-2).
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** D-4, D-12.
- **Referenced in plan:** Implementation Approach (How a chained skill knows the config is already loaded), Definition
  of Done.

### D-4: Definition of a run

- **Question:** What does "this run" mean in the consumer line?
- **Decision:** `config-rule.md` carries this definition verbatim: "A run begins when the person invokes a skill and ends
  when that skill finishes. Every skill it invokes is part of the same run. A skill the person invokes later in the same
  session is a new run and loads again." It sits beside the latest-wins rule.
- **Rationale:** Without a definition, a second slash command in a long session could reuse a file the person edited in
  between. With it, the second command reloads and the newer copy governs.
- **Evidence:** SA-4; JD-5's question about two `/plan-a-feature` runs with an edit between them.
- **Rejected alternatives:**
  - Leave "this run" as prose (the issue's text) — rejected because a model has no rule to apply across slash commands.
  - Define a run as the session — rejected because it reuses stale config after the person edits it (SA-4).
- **Specialist owner:** software-architect.
- **Revisit criterion:** a report of a chained skill reloading inside one run, or of a second invocation reusing stale
  config.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** D-9.
- **Referenced in plan:** Implementation Approach (How a chained skill knows the config is already loaded).

### D-5: The consumer line and where it sits

- **Question:** What exact text does a consumer carry, and where?
- **Decision:** This line, verbatim, inside `## Project Context` where the 65-word paragraph sat, with the two config
  probes and the script grant removed. Other probes stay above it.

  ```markdown
  Resolve configuration with `han-core:load-han-config` if you have not already this run.
  ```

- **Rationale:** The issue's own line, verbatim. One fixed location keeps the sweep and
  the grep gate mechanical. The continuation instruction lives in the loader's hand-back, following
  `readability-guidance`'s precedent, so the line adds none.
- **Evidence:** issue #203 proposal step 4; SA-3.
- **Rejected alternatives:**
  - `han-communication:load-han-config`, the prior text — superseded with D-1; it returns if the maintainer declines
    the dependency edges.
  - SA-5's variant with a fallback sentence ("If that skill is not available, treat this run as having no
    configuration") — rejected because after D-21 every plugin depends on `han-core`, so the loader is always reachable
    in an installed plugin, and the sentence's trigger is Unverified. The vendored copies, the one case without the
    loader, are handled by D-22.
- **Specialist owner:** software-architect.
- **Revisit criterion:** the DIRECT arm or the smoke eval shows the line does not lead a directly invoked skill to the
  loader.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2, E1.
- **Dependent decisions:** D-7, D-11.
- **Referenced in plan:** Implementation Approach (The line each consumer carries).

### D-6: Which skills carry the line

- **Question:** Which of the 45 skills rewire, which keep the block, and which change otherwise?
- **Decision:**
  - 44 skills carry the line: every shipped skill except `explanation-guidance`.
  - `readability-guidance` Step 1 changes its source phrases to name the run's `project .han/config.md` value or
    personal `.han/config.md`, and the run's `personal config directory` value. No fallback sentence.
  - `explanation-guidance` deletes both probes, the paragraph, and its Bash grant, and carries no line.
  - No skill keeps the old block. The `han-plugin-builder` skills that `guidance init` vendors carry the line too (D-22).
- **Rationale:** The issue's step 4 asks for each consuming skill. The measured sweep history (4 sweeps since July, one
  missing `pairing`) is evidence for single-sourcing beyond the chain targets. After D-21 every plugin reaches
  `han-core`, so no skill needs the block. `explanation-guidance` names no setting, so deleting its block is strictly
  simpler than rewiring it.
- **Evidence:** SA-3, SA-5 (grep for every schema token in `explanation-guidance` returns 0), SA-9 (commits e483783,
  78dc4f8, e79299f, 55bdb1d, and 0e5f44f); `.discovery-notes.md` dependency graph; D-21.
- **Rejected alternatives:**
  - 37 carry the line and 7 keep the old block, the prior D-6 under the `han-communication` placement — superseded with
    D-1; it returns if the maintainer declines the dependency edges.
  - Rewire only the ~13 chain targets (JD-2) — rejected because two patterns would live side by side with no rule for
    which one a new skill gets, and the block's sweep history is measured friction beyond the chain.
  - Accept degraded config for skills that cannot reach the loader (the July choice) — moot now that every plugin
    reaches it; it was rejected because users who install those plugins alone would silently lose `output-directory`
    and `writing-voice`.
  - Rewire `explanation-guidance` with the line — rejected because it uses no setting.
- **Specialist owner:** software-architect.
- **Revisit criterion:** the maintainer declines the dependency edges (then the 7 keep the block), or a new skill is
  added, which changes the count.
- **Dissent (if any):** JD-2 recommended chain targets only, citing the issue's "suite-wide duplication is not the
  problem". Recorded under disagree-and-commit; the reason for the call is the sweep history above.
- **Driven by rounds:** R1, R2, E1.
- **Dependent decisions:** D-7, D-10, D-11, D-13, D-22.
- **Referenced in plan:** Implementation Approach (Which skills change).

### D-7: Scripted and grep-gated sweep

- **Question:** How do 44 SKILL.md edits land without missing a file?
- **Decision:** A script performs the swap with whitespace-normalized matching of the paragraph. `pairing` line 49 and
  `project-discovery` line 112 get hand edits that point "the probe above" at the run's `personal config directory`
  value from the loader, and `readability-guidance` Step 1 gets its source-phrase edits. The Bats count gate (D-11) must pass
  before merge.
- **Rationale:** Every SKILL.md changed 6 to 19 times in 90 days, and a hand sweep has already missed a file.
- **Evidence:** SA-3 hazards (verified after R1: `ddd-analysis` wrapping, the two "probe above" lines); commit 0e5f44f;
  `.discovery-notes.md` "Recent churn".
- **Rejected alternatives:**
  - A hand sweep — rejected because commit 0e5f44f shows one missing `pairing` and taking it down.
  - A line-based replace — rejected because it misses `ddd-analysis`'s wrapping.
- **Specialist owner:** test-engineer (gate); implementer (script).
- **Revisit criterion:** the gate passes while a skill still carries a partial block.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** D-11.
- **Referenced in plan:** Implementation Approach (Which skills change).

### D-8: Skill grant decided by trial

- **Question:** Must every line carrier list `Skill` in `allowed-tools`?
- **Decision:** The INL-NOGRANT arm (N=4, default permission mode) decides, with both branches pinned:
  - It prompts: the sweep adds `Skill` to every line carrier, which also fixes the 2 `han-reporting` skills that call
    `readability-guidance` without it today.
  - It does not prompt: the `skill-composition.md` sentence under "Declare the Skill tool in `allowed-tools`" is
    corrected to say the list pre-approves a tool rather than gating it, and no carrier changes.
- **Rationale:** 23 skills call `readability-guidance` and only 6 list `Skill`; the guidance says the call is not
  permitted without it. Enforcement is unknown, and either branch is one mechanical edit.
- **Evidence:** SA-7, TE-3 item 4, JD-9, V9 from the July branch.
- **Rejected alternatives:**
  - Add `Skill` everywhere now — rejected because it acts on an unmeasured rule.
  - Leave it alone — rejected because the guidance and 23 skills already disagree.
- **Specialist owner:** test-engineer.
- **Revisit criterion:** Claude Code documents how `allowed-tools` treats `Skill`.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** none.
- **Referenced in plan:** Implementation Approach (The line each consumer carries), Risks and Assumptions.

Unverified: could not inspect this planning run's permission mode when it invoked a sub-skill without a `Skill` grant,
because it is not recorded.

### D-9: Edit config-rule once and keep all 13 copies

- **Question:** How does the shared config rule change, and do the vendored copies retire?
- **Decision:** Edit the canonical `han-core/references/config-rule.md`, then re-sync the 12 copies byte for byte.
  - Opening paragraph: skills find both files through `han-core:load-han-config`, invoked once per run.
  - The section on the two probes and the personal read opens: "`han-core:load-han-config` carries the two probe lines
    and directs one Read-tool call." The personal-read bullet says the loader reads the file with the Read
    tool. The rationale sentence stays verbatim.
  - One new paragraph: the run definition (D-4) and latest-wins.
  - All 13 copies stay.
- **Rationale:** The rule pins the per-skill probes, which becomes false after the sweep. Retiring copies would break 27
  mid-body SKILL.md lines and 7 reference-file lines, and the issue does not ask for it.
- **Evidence:** SA-8 counts; `.discovery-notes.md` (13 copies, one checksum).
- **Rejected alternatives:**
  - Retire the vendored copies (July branch) — rejected; 34 citation lines break. Deferred under YAGNI.
  - Leave the rule unchanged — rejected because it would describe a mechanism 44 skills no longer use.
  - Keep the clause for skills in plugins that do not depend on the loader's plugin (the prior wording) — dropped,
    because after D-21 there are none.
- **Specialist owner:** software-architect.
- **Revisit criterion:** the next edit that forces a 13-copy re-sync, or a copy drifts.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** none.
- **Referenced in plan:** Implementation Approach (The shared config rule and the resolver script), Definition of Done.

### D-10: Script stays and its symlinks narrow

- **Question:** What happens to `scripts/han-config-dir.sh` and its 13 symlinks?
- **Decision:** The script stays unchanged. Only `han-core/scripts/han-config-dir.sh` stays, because the loader is the
  only SKILL.md that still calls the script. The other 12 symlinks are removed. The Bats test "every plugin holding
  such a skill can reach the resolver script" stays and now covers only `han-core`. CLAUDE.md's `scripts/` layout
  comment and the symlink count in `test/codex-packaging.bats`'s header comment change with it (D-18).
- **Rationale:** The script remains the single place a lookup changes; after the sweep only the loader references it.
- **Evidence:** SA-9; D-6's skill set; `CLAUDE.md` line 84 and `test/codex-packaging.bats` line 18 (read during the R3
  revision) narrate the 13 symlinks.
- **Rejected alternatives:**
  - Keep all 13 symlinks — rejected because 12 would point at a script no file in their plugin calls.
  - The five-plugin set under the `han-communication` placement — superseded with D-1.
  - SA-9's original set of six, which kept `han-reporting` — superseded earlier, when `han-reporting`'s 2 skills took
    the line.
- **Specialist owner:** software-architect.
- **Revisit criterion:** a skill outside `han-core` needs the script again, or the maintainer declines the dependency
  edges.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2, E1.
- **Dependent decisions:** D-11.
- **Referenced in plan:** Implementation Approach (The shared config rule and the resolver script).

### D-11: Bats guards replace the probe checks

- **Question:** What tests guard the sweep once the probe is no longer in every skill?
- **Decision:** `scripts/han-config-dir.bats` keeps its three script tests and the "plugin can reach the resolver"
  test (now covering only `han-core`), narrows its exact probe and grant checks to the loader, and adds a count gate:

  | Assertion                                                                                    | Expected |
  | -------------------------------------------------------------------------------------------- | -------- |
  | SKILL.md files carrying the consumer line verbatim, exactly once each                        | 44       |
  | SKILL.md files carrying the 65-word paragraph, whitespace normalized                         | 0        |
  | SKILL.md files referencing `han-config-dir.sh`                                               | 1        |
  | `explanation-guidance` carries the line, the paragraph, or the script                        | 0        |
  | Line carriers outside `han-core` whose manifest omits it from `dependencies` (every plugin)  | 0        |
  | Loader frontmatter containing `context: fork`                                                | 0        |

- **Rationale:** Today's tests assert the probe in every skill and would fail after the sweep. The counts are the only
  thing that catches a missed or half-swept file. The dependency check now covers every plugin, so it also catches a
  dropped D-21 edge.
- **Evidence:** TE-6 items 1 to 5; SA-10 gate; counts derived from D-6 (44 + `explanation-guidance` = 45; the loader is
  the one script reference).
- **Rejected alternatives:**
  - SA-10's counts (36 / 8 / 9), the brief's 38, and the prior 37 / 7 / 8 under the `han-communication` placement —
    superseded; the last returns if the maintainer declines the dependency edges.
  - A Bats check that the false `context-hygiene.md` quote is absent (TE-9) — rejected; the simpler version is a review
    check in work unit 1.
  - Grant, index, and byte-identity guards (TE-6.6 to 6.8) — deferred under YAGNI.
- **Specialist owner:** test-engineer.
- **Revisit criterion:** a skill is added or removed, which changes the counts.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2, E1.
- **Dependent decisions:** none.
- **Referenced in plan:** Implementation Approach (The guards that replace the probe checks), Definition of Done.

### D-12: Trial harness, arms, and pass criterion

- **Question:** How is the issue's step 2 trial run, and what counts as holding?
- **Decision:** The OI-3 subagent harness, hot-loaded under `.claude/skills/`, artifacts under `artifacts/trial/`.
  - Fixtures: `output-directory: trial-out-A`, `default-swarm-size: large`, `writing-voice: ./voice-fixture.md` with
    sentinel `VOICE_SENTINEL_K7Q`, extra agents `han-core:code-reviewer` and `fake:ghost`; facts
    `INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api`.
  - Completion token grammar:
    `CONSUMER_COMPLETE | TRIAL_ID=<id> | facts: <4 space-separated> | cfg: dir=<path|none> swarm=<band|none> voice=<sentinel|builtin|none> agents=<comma list|none>`
  - `.loads` line grammar, one appended line per loader execution: `LOADED | TRIAL_ID=<id> | by=<invoking skill name>`
  - Arms and N: BASE 6, INL 12, WORST 10, SONNET-WORST 6, CHAIN 12, BLOCK-THEN-LINE 5, DEPTH-2 6, DIRECT 6, INL-NOGRANT
    4, CFG-P/J/B/C/M/A 5 each, CFG-P-MISSING 5. About 102 trials.
  - Pass: zero early exits and every carried fact and configured value present in every arm; CHAIN and DEPTH-2 hold
    exactly one `.loads` line and BLOCK-THEN-LINE holds none. A SONNET-WORST failure alone narrows the guidance claim to
    the larger model. INL-NOGRANT selects D-8's branch.
  - No "loader absent" arm, since every installed plugin reaches the loader under D-1 and D-21. The one absent case,
    a vendored builder copy, is checked by reading `init-guidance.sh` (D-22).
- **Rationale:** The spike measured the standard case; the values case is the gap the issue names. Matching the spike's
  N lets results compare, and a side-effect file turns "did not reload" into something a checker can count.
- **Evidence:** TE-1, TE-2, TE-3, TE-7 (CFG-P-MISSING); SA-10 Phase B arms; YAGNI ledger ("Kept after the
  simpler-version test"); `OI-3-spike-report.md` method.
- **Rejected alternatives:**
  - Host the trial in Skillwalker evals — rejected under D-17.
  - Re-run the spike's standard arms — deferred under YAGNI (already 34 of 34).
  - A "loader absent" arm — dropped because D-1 and D-21 make the loader reachable from every installed plugin.
- **Specialist owner:** test-engineer.
- **Revisit criterion:** the harness model changes, or a user reports an inline early exit.
- **Dissent (if any):** none. DEPTH-2's N=6 is a synthesis choice matching DIRECT and BASE; test-engineer confirms it at
  Phase B.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** D-8, D-13, D-14.
- **Referenced in plan:** Implementation Approach (The trial), Definition of Done.

Unverified: could not inspect whether a subagent inherits a launcher-set `CLAUDE_CONFIG_DIR`, because the spike never
varied the environment and the repo does not document it.

### D-13: What ships if the trial fails

- **Question:** What ships if an arm other than SONNET-WORST fails?
- **Decision:** Phase A (the guidance correction) and the `explanation-guidance` block deletion ship. Nothing else does:
  no loader, no dependency edges, no sweep, no widening.
- **Rationale:** The issue says step 1 "stands regardless", and `explanation-guidance` uses no setting, so its block is
  dead weight whatever the trial shows.
- **Evidence:** issue #203 proposal; JD-7; SA-10 gate; SA-5.
- **Rejected alternatives:**
  - Ship the loader anyway for chain targets only — rejected because the trial is the issue's condition for step 3.
  - Ship nothing — rejected because the guidance contradicts its own spike regardless.
- **Specialist owner:** software-architect.
- **Revisit criterion:** a later trial passes after the failure's cause is fixed.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** none.
- **Referenced in plan:** Implementation Approach (The trial), Definition of Done.

### D-14: Four phases with gates

- **Question:** In what order does the work land?
- **Decision:** A: guidance correction with the pre-trial wording, no gate. B: trial; gate is D-12's pass criterion. C:
  loader, its doc surfaces, the five `han-core` dependency edges and the surfaces that narrate them (D-21), guidance
  widening, the `han-core` minor bump and the five patch bumps; safe alone because the loader is unused and the edges
  only add an install. D: config-rule re-sync, scripted sweep, hand edits, Bats, docs, symlink removal, patch bumps;
  gate is PR #172 no longer editing any SKILL.md. The edges must land before D, or the line in those five plugins
  points at nothing.
- **Rationale:** Only Phase D touches the 45 files, so it goes last and alone; everything before it is small and
  reversible.
- **Evidence:** SA-10 (whose Phase C already placed the loader and its minor bump in `han-core`), plus D-21.
- **Rejected alternatives:**
  - One combined change — rejected because the trial must gate the loader, and the sweep must not race #172.
  - Sweep before the loader lands — rejected because the line would point at nothing.
  - Dependency edges in Phase D with the sweep — rejected because Phase D waits on #172 and the edges touch no
    SKILL.md, so they need not wait, and the maintainer sees them earlier.
- **Specialist owner:** software-architect.
- **Revisit criterion:** the trial fails (D-13), or #172 resolves in a way that removes the Phase D gate.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2, E1.
- **Dependent decisions:** D-15.
- **Referenced in plan:** Work Units and Sequencing.

### D-15: Sequencing with PR 172

- **Question:** How does this work sequence with PR #172?
- **Decision:** Recommend that #172 is rebased so its config half is the one-line change in `han-config-dir.sh` plus
  the config-rule wording, with no SKILL.md edits, or that it is split so its Pi marketplace half lands alone. Phase D
  waits until #172 edits no SKILL.md. The Pi marketplace entries stay out of scope.
- **Rationale:** Either recommended option frees #172 from the 45 files immediately, so Phases A to C run while it is
  open. The only remaining overlap is the 13 config-rule copies, which Phase D re-syncs anyway.
- **Evidence:** SA-9 (the script line has been possible since #184); SA-10's three options; PR #172 is open and
  conflicting, 61 files (`.discovery-notes.md`); the issue: "they should not run in parallel against the same 40-odd
  files".
- **Rejected alternatives:**
  - #203 first, holding #172 until Phase D merges — rejected as the recommendation because it keeps #172 open for four
    phases. It stays available to the maintainer.
- **Specialist owner:** maintainer (sequencing call); software-architect (recommendation).
- **Revisit criterion:** the maintainer chooses otherwise (OI-3).
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** none.
- **Referenced in plan:** Work Units and Sequencing, Open Items.

### D-16: Guidance corrections and bounded widening

- **Question:** What do the guidance edits say, and how far does property 2 widen?
- **Decision:** SA-11, section by section.
  - Phase A, `troubleshooting.md`: Cause 1 retitled to the forked case; forked sentence kept; inline sentence replaced
    with the spike result and "a values-only inline sub-skill is untested"; checklist item 8 to match.
  - Phase C, `skill-composition.md`: "Data-fetch composition (avoid)" narrowed to forked; the exception becomes
    "surfacing shared content inline"; property 2 reads "It surfaces content many consumers would otherwise duplicate (a
    whole standard, or a shared lookup's raw results) and leaves interpretation to the caller; fetching one value for
    one skill is still inline discovery", naming the config loader as the second validated case; trial result beside the
    spike; "Deciding which way to go" splits the "few values" bullet. Cause 1's last clause cites the trial.
  - Phase C, `writing-effective-instructions.md`: closing paragraph says "forked data-fetch sub-skills" plus one
    cross-reference to the exception.
  - Phase D, `graceful-degradation.md` line 102 names the inline loader.
  - `context-hygiene.md` is not edited. Citations use "Every token must earn its place" or "Treat stale context as a
    bug, not tech debt", never the issue's nonexistent quote.
  - Consumer repos lag until `guidance update`; noted, not pushed.
- **Rationale:** The guidance should state what the evidence shows: the failure account is fork-only and the inline case
  was measured. One trial on one loader justifies naming one loader, not values in general.
- **Evidence:** `troubleshooting.md:473`, `writing-effective-instructions.md:145`, `skill-composition.md:121` (all
  verified in `.discovery-notes.md`); commit 8c96157; the `context-hygiene.md` quote measured absent; JD-8, JD-12.
- **Rejected alternatives:**
  - Widen property 2 to "a few values" in general — rejected as a for-future-flexibility anti-pattern; deferred under
    YAGNI.
  - Remove the inline half of Cause 1 outright — rejected because the values case is untested, not proven (JD-8).
  - Carry the issue's `context-hygiene.md:104` quote — rejected because it does not exist.
- **Specialist owner:** maintainer (guidance author); software-architect.
- **Revisit criterion:** OI-1 surfaces inline-failure evidence, or a second values sub-skill is validated.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, R2.
- **Dependent decisions:** none.
- **Referenced in plan:** Implementation Approach (The guidance edits), Definition of Done, Deferred (YAGNI).

### D-17: Skillwalker hosts a post-ship smoke eval only

- **Question:** Can the trial run in the Skillwalker evals?
- **Decision:** No. The trial uses the subagent harness. Skillwalker hosts one post-ship smoke eval: a scaffold with a
  project config, expecting a `skill-call` to `han-core:load-han-config` and `result-contains` the configured
  band and its source file.
- **Rationale:** `tests.json` cannot express per-arm counts, a side-effect file, a token judged from a file on disk, a
  rewritten worst-case loader, or a personal-directory override. The smoke eval exercises the shipped loader, which the
  trial does not.
- **Evidence:** TE-5 (fields counted across `evals/*/tests.json`).
- **Rejected alternatives:**
  - The trial in Skillwalker — rejected for the reasons above.
  - One eval per consumer — deferred under YAGNI.
- **Specialist owner:** test-engineer.
- **Revisit criterion:** the runner gains file-system or environment assertions.
- **Dissent (if any):** none.
- **Driven by rounds:** R1.
- **Dependent decisions:** none.
- **Referenced in plan:** Implementation Approach (The trial), Work Units and Sequencing.

Unverified: could not inspect the Skillwalker runner, because no runner is in `package.json` and `CONTRIBUTING.md` does
not document it.

### D-18: Docs and contributor surfaces move with the sweep

- **Question:** Which docs become false after the sweep?
- **Decision:** In Phase D:
  - `CONTRIBUTING.md` "Adding a skill" step 2 tells authors to carry the consumer line in `## Project Context`. It
    gives no block-copy instruction, because every plugin depends on `han-core` after D-21.
  - `docs/configuration.md` line 7 gains the clause "a skill invoked by another skill uses what the first one loaded".
  - `graceful-degradation.md` line 102 (under D-16).
  - CLAUDE.md's `scripts/` layout comment (line 84), which says every plugin except `han` carries a resolver symlink,
    and the "thirteen" symlink count in `test/codex-packaging.bats`'s header comment (line 18) follow D-10.
  - The `guidance` long-form doc notes that vendored skills apply config only when `han-core` is installed (D-22).
  - The dependency narration itself (CLAUDE.md, CONTRIBUTING.md, `docs/concepts.md`, `docs/choosing-a-han-plugin.md`,
    READMEs, descriptions) moves earlier, in Phase C, with the edges (D-21).
- **Rationale:** Each describes the per-skill block, the symlinks, or the vendored skills as they were.
- **Evidence:** JD-11, SA-12, `docs/configuration.md:7`, `CONTRIBUTING.md:181-182` (verified on `main`); CLAUDE.md line
  84 and `test/codex-packaging.bats` line 18 (read during the R3 revision).
- **Rejected alternatives:**
  - SA-12's pointer to `edit-for-readability` as the block to copy, and the later pointer to one of the 7 old-block
    skills — both moot, because no skill keeps the block.
  - Leave docs for a follow-up — rejected because `CONTRIBUTING.md` would tell authors to copy a probe the gate rejects.
- **Specialist owner:** implementer; maintainer reviews.
- **Revisit criterion:** a doc still describes the per-skill block after Phase D.
- **Dissent (if any):** none.
- **Driven by rounds:** R1, E1.
- **Dependent decisions:** none.
- **Referenced in plan:** Work Units and Sequencing, Definition of Done.

### D-21: Five plugins gain a direct han-core dependency

- **Question:** How does every skill reach a loader in `han-core`, and what do the new edges cost?
- **Decision:** `han-communication`, `han-feedback`, `han-linear`, `han-plugin-builder`, and `han-reporting` each add
  `han-core` to `dependencies` in `.claude-plugin/plugin.json` as a direct edge. `.claude-plugin/marketplace.json`
  mirrors it wherever an entry narrates dependencies. The surfaces that narrate those dependencies change in the same
  unit: CLAUDE.md, CONTRIBUTING.md, `docs/concepts.md` (including line 266), `docs/choosing-a-han-plugin.md`, the five
  plugin descriptions, and the five front-door READMEs. Codex manifests have no dependency field and do not change. The
  edges land in Phase C, after the trial passes and before the sweep.
- **Rationale:** The line names `han-core:load-han-config`, so a skill whose plugin does not depend on `han-core` would
  point at nothing. The suite declares every edge directly and no plugin relies on a transitive install, so each of
  the five gets its own edge, and the count gate can check every plugin the same way.
- **Evidence:**
  - The user's direction, E1.
  - No cycle: zero references to `han-communication` in `han-core/skills` and `han-core/agents`;
    `docs/plans/reduce-required-install-footprint/investigation.md`.
  - Surfaces that narrate the old dependencies, measured: CLAUDE.md, CONTRIBUTING.md, `docs/concepts.md`, and
    `docs/choosing-a-han-plugin.md` say `han-communication` depends on nothing; `docs/concepts.md` line 266 offers a
    reporting-only install "without the `han-core` agent roster"; `han-communication/README.md:8`,
    `han-feedback/README.md:8`, `han-linear/README.md:8`, `han-plugin-builder/README.md:9` ("does not pull `han-core`
    along"), and `han-reporting/README.md:8` narrate each plugin's dependencies; the `han-communication` and
    `han-linear` marketplace entries do too.
- **Costs, recorded:**
  - `han-communication` stops being the plugin that depends on nothing. `han-core` becomes the only plugin with no
    dependency, and the layering CLAUDE.md describes changes to match.
  - A reporting-only install no longer avoids the `han-core` agent roster.
  - `han-communication` is 196K; `han-core` is 896K with 22 agents. Installing any of the five now pulls in the roster.
- **Rejected alternatives:**
  - No new edges, with the loader in `han-communication` — see D-1; it returns if the maintainer declines.
  - One edge from `han-communication` to `han-core`, relying on transitive installs for the rest — rejected because the
    suite declares every edge directly, and `han-feedback`, `han-linear`, and `han-plugin-builder` do not depend on
    `han-communication`, so they would still need their own edge.
- **Specialist owner:** maintainer (accepts or declines at review); implementer.
- **Revisit criterion:** the maintainer declines the edges at review (RK-8), or a reference from `han-core` to
  `han-communication` appears, which would make the edge a cycle.
- **Dissent (if any):** SA-6 deferred any new `han-core` edge to `system-architect`, who was not dispatched (see D-1).
- **Driven by rounds:** R3, E1.
- **Dependent decisions:** D-6, D-10, D-11, D-20, D-22.
- **Referenced in plan:** Implementation Approach (Where the loader lives), Work Units and Sequencing, Definition of
  Done, Risks and Assumptions.

### D-22: Vendored plugin-builder copies carry the line unchanged

- **Question:** `guidance init` vendors `han-plugin-builder`'s skills into consumer repos to run with no plugin
  installed. Do the vendored copies get the old probe block back, or carry the line?
- **Decision:** The vendored copies carry the line unchanged, and `init-guidance.sh` does not change. Where `han-core` is
  installed, the line reaches the loader. Where it is not, the named skill is missing, which counts as no
  configuration, and the run continues, per `config-rule.md`'s degradation rule that a bad config never fails a run.
  The long-form `guidance` doc notes that config applies to vendored skills only when `han-core` is installed. Before
  the sweep, the implementer reads `han-plugin-builder/skills/guidance/scripts/init-guidance.sh` to confirm it copies
  the line through untouched.
- **Rationale:** It is the simpler option: no substitution logic and no second copy of the block to keep in sync.
- **Evidence:** `init-guidance.sh`, read during the R3 revision: it copies the `skill-builder` and `agent-builder`
  directories verbatim, and `rewrite_skill` (lines 51 to 66) rewrites only the `plugin-` names, the
  `${CLAUDE_PLUGIN_ROOT}/skills/guidance/references/` path, and `use guidance.`. The line contains none of those
  strings. The vendored `guidance` comes from `assets/guidance-portable-SKILL.md`, which carries no config block, so
  only `plugin-skill-builder` and `plugin-agent-builder` are affected. The script vendors neither `han-config-dir.sh`
  nor `config-rule.md`, so today's vendored probe already falls back to `$HOME/.claude` for the personal directory, and
  its `config-rule.md` link already does not resolve.
- **Cost, recorded:** today a vendored builder still reads the project `.han/config.md` through its `cat` probe. With the
  line and no `han-core` installed, it reads no configuration.
- **Rejected alternatives:**
  - `init-guidance.sh` substitutes the old probe block back into the vendored copies — rejected because it puts a second
    copy of the probes, the grant, and the 65-word paragraph inside a sed script, to serve consumer repos that have not
    installed `han-core`, with no report of one relying on config in a vendored builder.
- **Specialist owner:** implementer; maintainer reviews.
- **Revisit criterion:** a consumer repo reports a vendored builder skill ignoring its config, or the implementer's read
  of `init-guidance.sh` shows it rewrites text the line contains.
- **Dissent (if any):** none.
- **Driven by rounds:** R3.
- **Dependent decisions:** none.
- **Referenced in plan:** Implementation Approach (Which skills change), Work Units and Sequencing, Definition of Done,
  Deferred (YAGNI).

Unverified: could not inspect the Skill tool's response to an uninstalled qualified skill name, because no session
without the target plugin installed was available.

### D-23: The loader is one probe whose script prints both files and the rule

- **Question:** After the trial, does the loader keep its two probes plus a Read-tool step, or become a single probe?
- **Decision:** A single probe. `han-core/skills/load-han-config/SKILL.md` is frontmatter plus one guarded probe line
  that runs `scripts/load-han-config.sh` (symlinked as `han-core/scripts/load-han-config.sh`). The script resolves the
  personal directory (`CLAUDE_CONFIG_DIR`, else `~/.claude`) and the working directory, prints whichever
  `.han/config.md` exists under `# Load Han Configuration` with where each was found, the project file first, each
  under its own `##` heading and between `===== BEGIN ... config =====` and `===== END ... config =====` marker lines,
  then the config rule under `## How to apply them`, whose own sections are `###` so they nest, and closes with the
  hand-back sentence; when neither exists it says so and names both paths tried.
  Two lookups that name one file print it once as the project file. The old `han-config-dir.sh` is removed.
  `config-rule.md` loses everything above `## Schema`, which described the probe mechanics rather than how to apply
  a setting; the twelve copies are re-synced.
- **Rationale:** The user's own info skills load everything they need through one script probe and have run that way
  in daily use, and the only reason the personal read was a model step was a classifier refusal of probe text that
  named the path, which a script command does not. One probe leaves the caller nothing to do after the call.
- **Evidence:** user input (E2); the plumbing probes of this run, which loaded a repository-relative script probe in
  every trial; `scripts/load-han-config.bats` (7 script tests, 7 skill guards).
- **Rejected alternatives:**
  - Two probes plus a Read-tool step (D-2's shape, the one the trial ran) — superseded; it keeps a model step whose
    only purpose was to dodge a probe-text refusal.
  - Measure the single-probe form through the classifier before shipping it — declined by the user as unnecessary
    given the info skills' track record.
- **Specialist owner:** software-architect.
- **Revisit criterion:** a load-time refusal of the script probe reported from any permission mode; the fallback would
  be D-2's shape, whose evidence is the trial record.
- **Dissent (if any):** none.
- **Driven by rounds:** R5, E2.
- **Dependent decisions:** D-3 (the marker stays the printed H1), D-9, D-10, D-11.
- **Referenced in plan:** Implementation Approach (What the loader surfaces), Implementation Approach (The shared config rule and the resolver script).

### D-24: The vendored config-rule.md copies are retired

- **Question:** With the loader printing the rule into every run, do the twelve vendored copies still earn their place?
- **Decision:** No. The twelve copies are deleted, the 33 mid-body citations in 22 skill and reference files now read
  "the config rule `han-core:load-han-config` surfaced" instead of linking a file, the byte-identity guard goes, and
  the layout and configuration docs stop describing the copies. `han-core/references/config-rule.md` is the single
  copy.
- **Rationale:** The copies existed because a skill cannot read a dependency plugin's files. The loader now puts the
  rule in context for every skill, so the file links had no reader left; the deferral's reopen trigger (a config-rule
  edit forcing a 13-copy re-sync) fired twice on this branch.
- **Evidence:** user input (E3); the citation grep recorded in R6; `scripts/load-han-config.bats`.
- **Rejected alternatives:**
  - Symlink the copies to the canonical file — root-escaping symlinks are proven for Claude Code installs but not for
    Codex, and the links had no remaining purpose either way.
  - Keep the copies and the guard (the plan's deferral) — superseded by the trigger firing.
- **Specialist owner:** software-architect.
- **Revisit criterion:** a skill that must read the rule without invoking the loader.
- **Dissent (if any):** none.
- **Driven by rounds:** R6, E3.
- **Dependent decisions:** D-9 (its re-sync step is now moot).
- **Referenced in plan:** Implementation Approach (The shared config rule and the resolver script).

### D-25: The loader script lives in han-core, not at the repo root

- **Question:** With one plugin running the script, does it still need a repo-root home and a symlink?
- **Decision:** No. `han-core/scripts/load-han-config.sh` is a regular file with `load-han-config.bats` beside it,
  the repo-root `scripts/` folder is gone, and the script reads the rule only from `../references/config-rule.md`
  beside it; the repo-root fallback lookup is removed.
- **Rationale:** The symlink existed so twelve plugins could share one script; after D-10 and D-24 only han-core
  runs it, and a symlink that reaches outside the plugin is one more thing an installer has to preserve.
- **Evidence:** user input (E4); `han-core/scripts/load-han-config.bats`.
- **Rejected alternatives:**
  - Keep the repo-root script and symlink — nothing else uses it.
- **Specialist owner:** software-architect.
- **Revisit criterion:** a second plugin that must run the script without han-core installed.
- **Dissent (if any):** none.
- **Driven by rounds:** R7, E4.
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach (The shared config rule and the resolver script).


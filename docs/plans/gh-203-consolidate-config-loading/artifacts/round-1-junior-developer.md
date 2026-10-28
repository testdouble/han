# Round 1: Junior-Developer Review of issue #203 (consolidate config loading)

Scope: `issue-203.md` (issue body and maintainer comment), read against `.discovery-notes.md`, `scope-boundary.md`,
CLAUDE.md, `han-core/references/config-rule.md`, `skill-composition.md` lines 88-149, `troubleshooting.md` lines
470-505, the 13 `plugin.json` dependency lists, and `git log` on the block since #184. Nothing was changed.

## Summary

The diagnosis in the issue holds up. Direct observation confirms that a chained sub-skill re-renders the probes and the
block (`.discovery-notes.md` Measurements, line 36), and the "both forms" wording in `troubleshooting.md` has no
recorded evidence for its inline half. The fix the issue proposes needs more work before it can be planned. Its main
chain targets live in a plugin that cannot reach `han-core`. The 45-file sweep rests on a maintenance cost that #184
already removed. The trial has no success or failure criterion. And neither the "if you have not already this run"
hint nor what the loader surfaces is pinned down.

| Severity         | Count |
| ---------------- | ----- |
| Blocks decision  | 3     |
| Muddies artifact | 5     |
| Worth clarifying | 4     |
| Polish           | 0     |

Open Questions: 8. Specialist handoffs: 7 (software-architect on JD-1, JD-2, JD-6, JD-9; test-engineer on JD-5, JD-7,
JD-11).

## Plain-language restatement

Every skill tells the model "go read the two config files" when it starts. When one skill calls another, the model is
told this again and gets the config content again, two or three times in one conversation. The issue wants one shared
skill that does the reading, with every other skill pointing at it in one line and skipping it if it already ran. The
plugin-building guidance bans that kind of shared skill, so the issue first argues that the ban is broader than its
evidence, then proposes a trial, and only builds and wires in the loader if the trial passes. Written out this way,
it is two changes bundled together: (a) stop chained calls from re-loading the config, which touches about 13 skills,
and (b) move every skill onto a new loader, which touches 45. The issue argues for (a) and proposes (b).

## Findings

**JD-1: The main chain targets cannot call a `han-core` skill** (Blocks decision; Standards conflict)
- Location: `issue-203.md#proposal` step 3 ("add `load-han-config` to `han-core`"). Against CLAUDE.md, which says
  `han-communication` "depends on nothing and every prose-producing plugin depends on it".
- Evidence: `han-communication/.claude-plugin/plugin.json` declares no dependencies. `readability-guidance` and
  `explanation-guidance`, the two skills in the issue's flagship `plan-a-feature` example, live there. Ten of the 45
  skills are in plugins without `han-core` as a dependency: han-communication (3), han-feedback (1), han-linear (1),
  han-plugin-builder (3), han-reporting (2). The July branch recorded the same issue as V11 (`.discovery-notes.md`
  "Prior attempts").
- Plain terms: as written, the fix cannot reach the exact double-load it was proposed for. The only ways around it are
  to make the foundational plugin depend on `han-core` (which reverses the layering CLAUDE.md describes), to put the
  loader somewhere else, or to leave those 10 skills on the old block. The issue doesn't pick one of these.
- Questions: OQ1. Specialist: software-architect (where the loader lives, and the dependency direction).
- Next step: decide where the loader lives before step 2, because the trial should exercise the real call path.

**JD-2: The stated problem is about ~13 chain targets, but the proposal edits 45 skills** (Blocks decision; YAGNI
candidate, simpler version available)
- Location: `issue-203.md#the-duplication` ("five-skill problem rather than a 44-skill one") against
  `#proposal` step 4 ("Cut each consuming skill's block").
- Evidence: the issue itself says suite-wide duplication "is not the problem". Measured chain targets come to about 13
  (`.discovery-notes.md` line 37). The other argument for a full sweep, "each pass edits 40-odd files"
  (`#the-cost-is-already-visible`), predates #184. `git log -G` shows that since 2026-08-20 the block was only copied
  into new skills (f586d00, 4fef1ba), never rewritten, and `scripts/han-config-dir.sh` has had one commit.
- Plain terms: Option A rewires only the chain targets. It solves the stated problem, and it can be rolled back one
  skill at a time. The cost is that two patterns live side by side, and authors need a rule for which one a new skill
  gets. Option B rewires all 45. That gives one pattern, but it adds a `Skill` grant and a nested call to roughly 39
  skills nobody chains, lands on files that change weekly, and rolling it back is another 45-file sweep. The evidence
  supports A. B needs evidence the issue doesn't cite.
- Questions: OQ2. Specialist: software-architect. Recommended resolution: replace with the simpler version (chain targets
  only), and record the full sweep under Deferred (YAGNI). Reopen trigger: the block or probe needs a content change
  again.

**JD-3: The #172 benefit is already true today** (Muddies artifact; uncited claim)
- Location: `issue-203.md#the-cost-is-already-visible`: "Under a consolidated loader, #172's config half becomes one
  line inside `han-config-dir.sh`."
- Plain terms: after #184 every probe calls the script, so adding `AGENT_CONFIG_DIR` is already a one-line change to the
  script. Consolidation doesn't add this benefit. It just shouldn't be counted toward the 45-file sweep.
- Questions: Q1 (Answered: `.discovery-notes.md` line 26 and the probe text in `readability-guidance/SKILL.md:17`).
- Next step: drop this claim from the plan's justification, or restate it as "already achieved by #184".

**JD-4: Citations to re-check before anything is quoted into guidance** (Worth clarifying; Evidence)
- `context-hygiene.md:104` and its quoted rule do not exist (`.discovery-notes.md` line 35). The argument that leans on
  it ("These co-reside") needs a real citation. Line 205 "Stale tokens compete for attention" is the nearest candidate.
- These figures are off: "44 of 47" is 45 of 45; "24 callers" is 23 consuming skills; "(8)" is about 7; "five-skill" is
  about 13. None of these changes the direction. The plan should still use the measured figures.
- `scope-boundary.md#stated-scope` quotes the issue as "contradicts its own spec". The issue says "spike"
  (`issue-203.md#proposal`). A verbatim quote in the scope record is wrong.
- "Three copies" for `plan-a-feature` is Assumed. One re-render was observed, but not this exact three-skill chain.
- Next step: fix the scope-record quote, and use only the measured figures and verified line citations in any guidance
  edit.

**JD-5: How would a skill know whether it has already loaded the config "this run"?** (Muddies artifact; Hidden
assumption, unpinned contract)
- Location: `issue-203.md#proposal` step 4: "if you have not already this run. The idempotence hint keeps a chain
  resolving once."
- The naive question: the only signal the model has is earlier text in its context, and nothing about it is reliable.
  An empty project config renders as "(Bash completed with no output)" (`.discovery-notes.md` line 36), which looks the
  same as a probe that never ran. "This run" has no definition when someone runs `/plan-a-feature` twice in one session
  and edits `.han/config.md` in between. After compaction, the earlier load may be summarized away.
- What would convince a reader: a stated marker the loader prints (for example a fixed heading plus "no project config
  found" instead of blank output), a rule for what counts as a run, and a trial arm showing a chained skill skips the
  load when the marker is present and loads when it is absent.
- Questions: OQ3. Specialist: test-engineer (trial arms for skip and no-skip).

**JD-6: What the loader surfaces is described only in prose** (Muddies artifact; contract between components)
- Location: `issue-203.md#proposal` steps 3-4. Against `config-rule.md#the-two-files-the-two-probes-and-the-personal-read`,
  which pins the mechanism per skill.
- The issue leaves open: the exact one-line text and where it sits; whether the loader outputs raw file text (so each
  caller still applies precedence) or resolved values; who resolves `writing-voice`, which `readability-guidance` does
  itself today (`.discovery-notes.md` "The config contract"); and what a caller does if the loader degrades. The issue
  calls this "the values case". If the loader surfaces raw files, it is closer to the existing "surface a standard"
  exception, and that changes what step 2 needs to test.
- Questions: OQ4; the issue's own open question on the personal Read (`#open-questions`) is part of this.
  Specialist: software-architect. Next step: pin the output shape with a worked example, per
  `han-planning/references/contract-pinning-rule.md`.

**JD-7: The trial gates steps 3-5, but "holds" is undefined and there is no failure branch** (Blocks decision; Scope and
definition of done)
- Location: `issue-203.md#proposal` steps 2-3 ("If it holds").
- The issue doesn't say what happens if the trial fails. It only says step 1 "stands regardless". The OI-3 shape
  measures early exits. It wouldn't measure whether the caller used the right resolved values, whether the skip hint
  works (JD-5), or the depth-2 call (caller, then `readability-guidance`, then loader; V10 in the July branch). The OI-3
  limits carry over: `api_retry` couldn't be induced, and only one model was tested. Skillwalker evals have no
  documented way to assert on what is in context (`.discovery-notes.md` "Gaps").
- Smallest useful outcome on failure: step 1 reworded to "inline values case untested" (not "reliable"). Either keep
  today's block, or have the chain targets alone skip their own Read when config is already in context, with no new
  skill. The plan should name this branch up front.
- Questions: OQ5. Specialist: test-engineer (pass criteria, arms, which models, harness).

**JD-8: What exactly does step 1's correction say?** (Worth clarifying)
- Location: `issue-203.md#proposal` step 1 against `troubleshooting.md` "Cause 1" and summary item 8.
- The issue concedes "untested, not known-broken" (`#what-the-evidence-shows`). The honest correction is "inline is
  untested for values". It would be wrong to remove the inline half outright. The maintainer's comment says the
  original failure report "came from a coworker". That may be where "both forms" came from, and it isn't in the repo.
- Questions: OQ6 (maintainer). Unverified: could not inspect the coworker's original report, because it is not recorded
  in the repo or in git history.

**JD-9: The `Skill` grant and Codex behavior are unaddressed** (Muddies artifact; Hidden assumption)
- Location: `issue-203.md#proposal` step 4. `skill-composition.md` line 88 says a caller "must list `Skill` in its
  `allowed-tools`". Only 6 skills do today (`.discovery-notes.md` line 24). V9 found that this rule is contradicted in
  practice and that enforcement is unknown.
- Every `han-*` plugin ships a Codex manifest, and there is no statement of whether Codex lets a skill invoke another
  skill. If it doesn't, Codex users lose config entirely under a one-line block.
- Questions: OQ7. Specialist: software-architect. Unverified: could not inspect Codex's skill-invocation behavior,
  because no in-repo source documents it and none was run.

**JD-10: Prior attempts aren't cited** (Worth clarifying; Standards and prior art)
- `origin/han-config-skill` (2026-07-24) planned this same loader and raised V9, V10 and V11, which are JD-9, JD-5/JD-7
  and JD-1 here. `origin/research/plugin-config-discovery` found that a plugin can't read a dependency's files by path.
  The issue cites neither (`.discovery-notes.md` "Prior attempts").
- Questions: OQ8 (maintainer: why the July branch stopped).

**JD-11: The definition of done leaves out the surfaces the change forces** (Muddies artifact; Scope)
- Not named in `#proposal`: the `docs/configuration.md` sentence "Every Han skill reads both files on every run";
  CONTRIBUTING.md "Adding a skill" step 2; `scripts/han-config-dir.bats` (exact-probe assertions);
  `config-rule.md` "two probes" section and its 12 vendored copies; a long-form doc, scent line and index entry for the
  new skill (CLAUDE.md "Indexes stay complete"); building it through `skill-builder` (CLAUDE.md); version bumps
  (`docs/semantic-versioning.md`); guidance vendored into consumer repos, which lags until `guidance update` runs.
- There is no rollback story or post-ship owner. Specialist: test-engineer (what Bats/eval guards replace the
  exact-probe test).

**JD-12: "Widen property 2 to match the trial" has no bound** (Worth clarifying; YAGNI candidate, named anti-pattern
"for future flexibility")
- Location: `issue-203.md#proposal` step 5 against `skill-composition.md` "The one exception", property 2.
- One trial on one loader gives evidence for one loader. Widening to "values" in general would allow every future
  data-fetch sub-skill on the strength of a single case. Recommended resolution: replace with a simpler version that
  names the config loader as the second validated case and leaves the general rule alone.

## Open Questions

1. **OQ1:** Where does the loader live, given that `han-communication` depends on nothing? Affects JD-1, JD-2.
   Resolve: software-architect, then the maintainer (layering is their call).
2. **OQ2:** Is the goal the chain duplication (about 13 skills) or one pattern for all 45? Affects JD-2, JD-11, JD-12.
   Resolve: the issue author and the maintainer.
3. **OQ3:** What marker proves the config "already loaded this run", and what counts as a run? Affects JD-5, JD-7.
   Resolve: software-architect drafts, test-engineer adds a trial arm.
4. **OQ4:** Does the loader surface raw file text or resolved values, and who applies `config-rule.md` precedence?
   Affects JD-6, JD-7, JD-12.
5. **OQ5:** What pass and fail criteria does the trial use, and what ships if it fails? Affects JD-7. Resolve:
   test-engineer.
6. **OQ6:** Maintainer: is there unrecorded inline-failure evidence behind "both forms"? Who reported the original
   failure (the coworker), on which Claude Code version, and was that skill forked or inline? Affects JD-8.
7. **OQ7:** Does Codex run context-injection probes and skill-to-skill calls, and does missing `Skill` in
   `allowed-tools` actually block a call? Affects JD-9.
8. **OQ8:** Maintainer: was `origin/han-config-skill` abandoned for a reason (V9 to V11, a decision, or time)? Affects
   JD-1, JD-10.

### Questions only the maintainer can answer (draft reply to "any specific questions?")

- Where did "unreliable in both forms" in `troubleshooting.md` come from? Was anything ever seen failing inline, or did
  the wording generalize from the fork case? (OQ6)
- The coworker's original report: which skill, which Claude Code version, forked or inline, and is the transcript still
  available? (OQ6)
- Why did the July `han-config-skill` branch stop, and does anything in its V9 to V11 findings still worry you? (OQ8)
- Are you willing to have `han-communication` depend on `han-core`, or should it stay foundational with a loader
  somewhere else? (OQ1)
- Is the goal to stop the chain double-load (about 13 skills), or to have one config pattern for every skill (45)?
  (OQ2)
- How do you want this sequenced with #172: rebase #172 onto #184 first (now a one-line script change, JD-3), or hold
  it? The issue says the two should not run in parallel (`#open-questions`).
- Do Han users run these skills under Codex today, so that a skill-to-skill call has to keep working there? (OQ7)

## Protocol coverage

- P1 Clarifying-question sweep: OQ1 to OQ8 plus Q1 (Answered, JD-3).
- P2 Hidden assumptions: JD-1, JD-5, JD-9.
- P3 Evidence: JD-3, JD-4, JD-8.
- P4 Standards: JD-1 (CLAUDE.md layering), JD-9 (`skill-composition.md` grant rule), JD-10, JD-11. There is no
  `docs/coding-standards/` and no ADR on composition, so the plugin-builder guidance and CONTRIBUTING.md stand in.
- P5 Specialists: software-architect (JD-1, JD-2, JD-6, JD-9), test-engineer (JD-5, JD-7, JD-11).
- P6 Done and scope: JD-7, JD-11.
- P7 YAGNI: JD-2 (full sweep), JD-12 (unbounded widening). Step 1 and the loader for the chain targets both pass the
  evidence test (observed re-render, `.discovery-notes.md` line 36).
- P8 Plain language: the restatement shows two changes bundled under one argument (JD-2).

## Deferred (YAGNI)

- Rewiring the roughly 32 skills that nothing chains. Reopen trigger: the block or probe needs a content change again.
- A general widening of property 2 to "values". Reopen trigger: a second validated values sub-skill.

# Change Plan: Opus 5.5 plugin-builder guidance update

## Why This Change

Anthropic shipped Opus 5.5, and `han-plugin-builder` still teaches authors to write for Sonnet 5, Opus 5, and Fable 5,
as checked on 2026-07-31. This is a **constraint arriving**: a new model whose behavior differs in ways that change what
a skill or agent author should write.

The operator asked to evaluate the whole plugin against
[Getting the most out of Opus 5.5](https://claude.dev/blog/getting-the-most-out-of-opus-5-5/). The operator also named
[How we use skills](https://claude.dev/blog/lessons-from-building-claude-code-how-we-use-skills/) and related sources as
a baseline, with the Opus 5.5 article winning on conflict ([D-19](artifacts/change-decision-log.md#d-19-the-source-set-and-its-precedence)).

The plan cites four sources by number. SOURCE 1 is the Opus 5.5 article and SOURCE 2 is the skills article. SOURCE 3 is
[The new rules of context engineering for Claude 5 generation models](https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/),
linked as related from both. SOURCE 4 is Anthropic's
[Prompting Claude Opus 5.5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)
page. The findings file's Provenance section lists all four with dates.

Every suggestion went through adversarial validation before it could enter this plan: 28 candidates went in, and 18
entries came out ([D-20](artifacts/change-decision-log.md#d-20-candidates-rejected-by-adversarial-validation)).

## What Changes, In One Paragraph

After this change, the plugin's guidance names Opus 5.5 and says what an author does differently for it. Opus 5.5 can
refuse an instruction to show its reasoning. It cannot turn thinking off. Its effort levels mean more thinking than the
same names did on Opus 5, so a pinned effort needs re-testing. Everything else from Opus 5 carries over
([D-1](artifacts/change-decision-log.md#d-1-add-opus-55-to-the-per-model-guide-and-every-file-that-restates-its-model-list)). The workflow and delegation guides gain the patterns the new model's long
runs call for. They name the stops an autonomous stretch should and should not make, state a finish line and keep a
task file for unbounded steps, check each fanned-out subagent's evidence, and wait for background work. None of it
weakens Han's deliberate human checkpoints. The skill-building guides also pick up five patterns from the baseline
articles that the plugin lacked: gotchas, verification skills, keeping skill state across plugin updates,
helper-script libraries, and a skill-scoped guardrail hook. Finally, `skill-builder` and `agent-builder` start reading
and checking against the per-model guide, so the update reaches people who build through them.

## Current State

The per-model guide names three models, is dated 2026-07-31, and has four independent copies of its model list: the
router, the portable router, the rule index, and the specialization guide
([C-1](artifacts/current-state-findings.md#c-1-the-per-model-guide-names-three-models-and-was-last-checked-before-opus-55-shipped),
[C-2](artifacts/current-state-findings.md#c-2-the-model-list-is-restated-in-four-other-files-and-a-change-must-reach-all-of-them)).

Its reasoning-echo warning covers only Fable 5
([C-3](artifacts/current-state-findings.md#c-3-the-reasoning-echo-warning-is-scoped-to-fable-5-and-called-single-source)).

Its thinking and effort bullets describe Opus 5 only
([C-4](artifacts/current-state-findings.md#c-4-the-thinking-mode-bullet-describes-disabling-thinking-on-opus-5-which-opus-55-does-not-allow),
[C-5](artifacts/current-state-findings.md#c-5-the-effort-bullet-predates-opus-55s-default-and-authors-can-pin-effort-in-frontmatter)).

It warns against every limiting phrase in a review instruction, including the concrete one the Opus 5.5 article
recommends
([C-6](artifacts/current-state-findings.md#c-6-the-guide-warns-against-every-only-report-x-review-limit-while-source-1-recommends-one-with-a-concrete-bar)).

The workflow and delegation guides cover deliberate human gates but not a model that stops early to report. They say
nothing about finish lines or task files for unbounded steps, about checking fanned-out evidence, or about waiting for
background dispatches ([C-8](artifacts/current-state-findings.md#c-8-workflow-guidance-covers-deliberate-pauses-not-a-model-that-stops-early-to-report), [C-9](artifacts/current-state-findings.md#c-9-no-guidance-names-a-finish-line-or-a-durable-task-list-for-long-steps),
[C-10](artifacts/current-state-findings.md#c-10-delegation-guidance-has-no-evidence-check-on-returned-subagent-work-and-no-wait-for-background-dispatches)).

Neither builder skill reads the per-model guide
([C-19](artifacts/current-state-findings.md#c-19-neither-builder-skill-reads-or-checks-against-the-per-model-guide)).

The builders' own instructions already avoid every pattern the sources say to remove, so their bodies need no rewrite
([C-20](artifacts/current-state-findings.md#c-20-the-builders-own-instructions-carry-none-of-the-patterns-the-sources-say-to-remove)).

No automated test covers guidance content (see the findings file's Gaps), so every check in this plan is a grep or a
read.

## Target State

The target state is placement of guidance text in existing files. No new file is added
([D-15](artifacts/change-decision-log.md#d-15-keep-skill-state-in-the-plugin-data-directory-documented-as-a-section-not-a-new-file)).

The adversarial validators set each entry's landing file, and the structural map shows which files must change
together. No separate architect pass ran
([D-21](artifacts/change-decision-log.md#d-21-the-target-state-came-from-the-validators-landing-recommendations-not-a-separate-architect-pass)).

- **`per-model-authoring.md`** owns every model-specific fact, now including Opus 5.5. It does not own the long-run
  patterns; it links to them.
- **`workflow-patterns.md`** owns the stop-naming pattern and the finish-line and task-file pattern for unbounded steps.
  Both are model-agnostic.
- **`multi-agent-economics.md`** owns the fan-out evidence check and the background-wait rule.
- **`plugin-json-options.md`** owns where a plugin-shipped skill keeps state that must survive an update.
- **The two builder skills** route to `per-model-authoring.md` and check for model-specific leftovers.

Three contracts must stay in agreement across files.

**1. The model list.** `per-model-authoring.md:5` is the source. The router line in `guidance/SKILL.md` and
`guidance/assets/guidance-portable-SKILL.md` must stay byte-identical, and after the change reads:

```markdown
- Writing the instructions for a target model (how Sonnet 5, Opus 5, Opus 5.5, and Fable 5 differ in following
  instructions, which instructions to leave out, and how to calibrate length, narration, and scope) →
  `${CLAUDE_SKILL_DIR}/references/per-model-authoring.md`.
```

`specialization-and-model-selection.md:89` names the same four models: "Sonnet 5, Opus 5, Opus 5.5, or Fable 5".

**2. The rule-index descriptions.** `guidance/assets/rule-index-body.md` is vendored into every consuming repo and is
how the model decides which file to read. Every file whose scope this plan widens gets its description updated
([D-22](artifacts/change-decision-log.md#d-22-pin-every-widened-files-rule-index-description)). Keep each entry's link and wrap lines at 120 characters. The new
description text:

| Entry                           | Description after the change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Per-Model Authoring Guidance    | How Sonnet 5, Opus 5, Opus 5.5, and Fable 5 differ in how they follow instructions, and how those differences change what you write: the model-agnostic default for an unknown target, the opposite-direction instruction-style split, the verification and re-check instructions to leave out, how to calibrate response length, narration, and scope, effort and thinking on Opus 5.5, and the reasoning-echo refusal on Fable 5 and Opus 5.5. Read when writing or hardening a skill or agent and tuning the instructions to a target model, not when choosing which model tier to run (see Specialization and Model Selection). |
| Workflow Patterns               | Four structural patterns for organizing the steps inside a single skill, mapped to Anthropic's effective-agent patterns, plus how to name the stops an autonomous stretch should and should not make and how to bound a step that works through an unknown number of items. Read when designing or restructuring a skill's internal workflow, or when a skill stops early or loses track mid-run.                                                                                                                              |
| Multi-Agent Economics           | The escalation cascade for deciding whether adding more agents is justified, given that each agent multiplies latency and token cost, plus the delegation policy a skill should state because the model's own default is eager, the evidence check a skill runs on each fanned-out subagent's result, and the rule against finishing while a background dispatch is still running. Read when a skill is considering dispatching multiple or parallel agents.                                                                   |
| Graceful Degradation (agents)   | How a dispatched agent should check tool availability inline and skip gracefully, so the orchestrating skill needs no defensive guards around the dispatch, and how a research or analysis agent marks a claim it could not confirm and says where it looked. Read when an agent's steps depend on git or other tools that may be missing, or when an agent reports findings.                                                                                                                                                  |
| Success Criteria and Testing    | Three test types (triggering, functional, outcome) for knowing a skill works, plus the rule to test on the model tier the skill targets, and how to build a skill whose job is verifying a running product. Read when validating a skill before shipping it, or when building a verification skill.                                                                                                                                                                                                                           |
| Writing Effective Instructions  | How to write the SKILL.md body so steps are specific, actionable, and reliably followed across sessions, and where to stop specifying. Read when a skill behaves inconsistently, skips steps, or improvises when it should follow a fixed process, or when its rules are over-constraining it.                                                                                                                                                                                                                                  |
| Skill Reference Files           | When and how to extract domain knowledge (templates, checklists, rate tables, gotchas) into a `references/` subdirectory loaded on demand. Read when a skill carries content that is knowledge rather than process steps.                                                                                                                                                                                                                                                                                                       |
| Hardening: Fuzzy vs. Deterministic | The framework for classifying each skill step as fuzzy (keep as an LLM instruction) or deterministic (extract to a script), including a helper library the model composes into one-off scripts. Read when hardening a skill for reliability or deciding what to script.                                                                                                                                                                                                                                                      |
| plugin.json Schema Reference    | Full schema for `.claude-plugin/plugin.json`: required fields, metadata, component paths, dependencies, and experimental keys, plus where a plugin-shipped skill keeps state that must survive an update. Read when creating or editing a plugin manifest, or when a skill saves first-run answers or run history.                                                                                                                                                                                                         |

**3. The review-limit test.** S-5 and S-18 must agree on what separates a vague limit from an acceptable one
([D-5](artifacts/change-decision-log.md#d-5-keep-the-limiting-phrase-warning-and-separate-vague-limits-from-a-concrete-bar)). A limit is acceptable when it names a bar the reader could check (a
consequence such as "would block the merge", or a rubric the skill itself carries) and requires evidence for each item.
The two examples both files use:

```text
Acceptable: List only problems you'd block the merge for. For each one, give the file and line, why it's wrong, and how
to show it fails.

Vague: Only report high-severity issues.
```

## Surface Delta

Every path below is under `han-plugin-builder/skills/` unless it says otherwise. Entries S-1 to S-10 and S-18 are
driven by the Opus 5.5 sources. Entries S-11 to S-17 are baseline gaps from the two earlier articles
([D-19](artifacts/change-decision-log.md#d-19-the-source-set-and-its-precedence)).

### S-1: `per-model-authoring.md` model list and its four mirrors — Re-scoped

**Target state.** `per-model-authoring.md` covers Sonnet 5, Opus 5, Opus 5.5, and Fable 5, with a "last checked" stamp
dated to the build. It states that Opus 5.5 inherits the Opus 5 guidance except where the guide says otherwise. The
headings "Instructions to leave out on Opus 5" and "Calibrating length, narration, and scope on Opus 5" name Opus 5 and
Opus 5.5. The router line, the portable router line, the rule-index entry, and `specialization-and-model-selection.md:89`
match contracts 1 and 2 in Target State.

**Behavior.** Preserving. Every existing recommendation stands, and the router sends the same questions to the same
file.

**Why.** The guide and its copies predate Opus 5.5 ([C-1](artifacts/current-state-findings.md#c-1-the-per-model-guide-names-three-models-and-was-last-checked-before-opus-55-shipped),
[C-2](artifacts/current-state-findings.md#c-2-the-model-list-is-restated-in-four-other-files-and-a-change-must-reach-all-of-them)).

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-add-opus-55-to-the-per-model-guide-and-every-file-that-restates-its-model-list)

### S-2: `per-model-authoring.md` reasoning-echo section — Re-scoped

**Target state.** The section, headed to name both Fable 5 and Opus 5.5, covers both models and names the
`reasoning_extraction` refusal category. Its evidence note reads as single-vendor across three Anthropic publications,
not as uncorroborated.

**Behavior.** Preserving. The test for spotting the pattern is unchanged.

**Why.** Both Opus 5.5 sources place the refusal on 5.5 ([C-3](artifacts/current-state-findings.md#c-3-the-reasoning-echo-warning-is-scoped-to-fable-5-and-called-single-source)).

**Depends on.** S-1.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-the-reasoning-echo-warning-covers-opus-55-and-names-the-refusal-category)

### S-3: `per-model-authoring.md` thinking-mode bullet — Re-scoped

**Target state.** The bullet says Opus 5.5 always thinks and cannot disable it. The XML-tag-leak caveat is stated as an
Opus 5 thinking-disabled artifact that does not arise on 5.5.

**Behavior.** Preserving.

**Why.** [C-4](artifacts/current-state-findings.md#c-4-the-thinking-mode-bullet-describes-disabling-thinking-on-opus-5-which-opus-55-does-not-allow).

**Depends on.** S-1.

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-one-clause-on-opus-55-thinking-not-a-new-section)

### S-4: `per-model-authoring.md` effort bullet, with pointers from both frontmatter tables — Re-scoped

**Target state.** The effort bullet says the same effort name means more thinking on Opus 5.5 than on Opus 5. It says
Anthropic's platform docs put Opus 5.5's API default at `medium`, where Opus 5's is `high`, and report `medium` on 5.5
matching or beating Opus 5 at `high`. It says `xhigh` and `max` are for measured gains, and that a pinned `effort` tuned
for Opus 5 should be re-tested rather than carried over. The `effort` rows in
`skill-building-guidance/skill-frontmatter-fields.md` and `agent-building-guidelines/agent-external-files.md` each link
to the section "Other settings the model differences affect" in `per-model-authoring.md`.

**Behavior.** Preserving. Additive.

**Why.** Authors can pin effort, and what an effort name means changed ([C-5](artifacts/current-state-findings.md#c-5-the-effort-bullet-predates-opus-55s-default-and-authors-can-pin-effort-in-frontmatter)).

**Depends on.** S-1.

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-tell-authors-to-re-test-a-pinned-effort-value-on-opus-55)

### S-5: `per-model-authoring.md` limiting-phrase paragraph — Re-scoped

**Target state.** The paragraph still warns that a vague limit ("only report high-severity issues", "be conservative")
is followed literally and under-reports. It still recommends reporting everything and filtering in a separate step for
vague limits. It adds the test from contract 3 and quotes the acceptable example whole, evidence clause included.

**Behavior.** Changing. Readers learn one acceptable shape of limiting phrase. Settled by the operator (option A).

**Why.** The primary source recommends a limit of that shape, and no source says 5.5 is less literal
([C-6](artifacts/current-state-findings.md#c-6-the-guide-warns-against-every-only-report-x-review-limit-while-source-1-recommends-one-with-a-concrete-bar)).

**Depends on.** S-1.

**Decision.** [D-5](artifacts/change-decision-log.md#d-5-keep-the-limiting-phrase-warning-and-separate-vague-limits-from-a-concrete-bar)

### S-6: `per-model-authoring.md` Sources section — Re-scoped

**Target state.** Sources lists the Opus 5.5 prompting page as Anthropic docs and the Opus 5.5 article as an Anthropic
blog post with author and date. The "postdates that research report" sentence covers the Opus 5.5 material.
`docs/research/model-specific-guidance-for-skills.md` is unchanged.

**Behavior.** Preserving.

**Why.** [C-7](artifacts/current-state-findings.md#c-7-the-per-model-sources-section-cites-only-the-opus-5-era-pages).

**Depends on.** S-2 to S-5.

**Decision.** [D-6](artifacts/change-decision-log.md#d-6-add-the-opus-55-sources-labeled-by-tier-without-touching-the-research-report)

### S-7: `workflow-patterns.md` stop-naming subsection, plus one sentence in `per-model-authoring.md` — Added

**Target state.** A subsection after "Human Gates in Workflow Steps", listed in the file's Contents, covers a stretch of
a skill meant to run without the user. It names the unwanted stops: a summary that announces the next step without
taking it, an offer to continue, and a list of choices that block nothing. It names the wanted stops: no work can move
without the user, a destructive or irreversible action is next, or a human gate is reached. It states that human
gates, interview turns, and collaborative-stop boundaries are wanted stops, and that a skill built to hand control back
carries no keep-going instruction. It links to `han-core/references/collaborative-stop-rule.md` for that claim.
`per-model-authoring.md` gains one sentence naming Opus 5.5's early-stop behavior and linking to the subsection.

**Behavior.** Preserving. No existing gate or stop rule changes.

**Why.** [C-8](artifacts/current-state-findings.md#c-8-workflow-guidance-covers-deliberate-pauses-not-a-model-that-stops-early-to-report).

**Depends on.** S-1, for the per-model sentence.

**Decision.** [D-7](artifacts/change-decision-log.md#d-7-name-the-stops-a-long-autonomous-stretch-should-and-should-not-make-and-protect-the-collaborative-stops)

### S-8: `workflow-patterns.md` finish-line and task-file subsection for unbounded steps — Added

**Target state.** A subsection, listed in Contents, covers steps that work through a set whose size is not known up
front. Such a step states its completion condition in checkable terms, keeps its checklist in a file it updates as items
finish, and reads that file to decide what remains. It cross-references `skill-composition.md`'s continuation rule and
`multi-agent-economics.md`, and says a fixed flowchart step needs neither.

**Behavior.** Preserving. Additive.

**Why.** [C-9](artifacts/current-state-findings.md#c-9-no-guidance-names-a-finish-line-or-a-durable-task-list-for-long-steps).

**Depends on.** S-7, which sits beside it and supplies the stop vocabulary.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-state-the-finish-line-and-keep-the-task-list-in-a-file-only-for-unbounded-steps)

### S-9: `multi-agent-economics.md` fan-out and background rules, plus a pointer in `agent-external-files.md` — Re-scoped

**Target state.** `multi-agent-economics.md` carries a fan-out rule. A skill that gives each unit of work to its own
subagent checks the evidence each subagent cites against its source before accepting the finding. It then produces one
consolidated result. The rule states the line against the existing self-check ban: checking a subagent's cited evidence
is allowed; dispatching another agent to redo the skill's own reasoning is not. "Practical Implications for Skills" says
a skill does not treat its run as complete while a `run_in_background: true` dispatch it launched is still running, and
labels that item single-source. The `background` row in `agent-external-files.md` links to that item.

**Behavior.** Preserving. Additive.

**Why.** [C-10](artifacts/current-state-findings.md#c-10-delegation-guidance-has-no-evidence-check-on-returned-subagent-work-and-no-wait-for-background-dispatches).

**Decision.** [D-9](artifacts/change-decision-log.md#d-9-check-fanned-out-evidence-and-wait-for-background-dispatches)

### S-10: `agent-building-guidelines/graceful-degradation.md` unconfirmed-claim rule, plus `agent-builder` Step 6 item 8 — Re-scoped

**Target state.** The agent graceful-degradation guide has two rules. The first: skip the step and note the limitation
when a tool is missing. The second: a research or analysis agent marks a claim it could not confirm and names where it
looked. The `agent-builder` Step 6 item 8 summary names both.

**Behavior.** Changing, for `agent-builder` users: the final review checks one more condition. The guide itself only
gains a rule. See Behavior Changes.

**Why.** [C-11](artifacts/current-state-findings.md#c-11-agent-graceful-degradation-covers-a-missing-tool-not-a-claim-the-agent-could-not-confirm).

**Decision.** [D-10](artifacts/change-decision-log.md#d-10-agents-say-what-they-could-not-confirm-and-where-they-looked)

### S-11: `writing-effective-instructions.md` limit on specificity — Added

**Target state.** A rule beside "Be specific and actionable" says to spell out conventions that break something when
missed. It also says to leave out instructions for routine details the model gets right unprompted, rather than
writing blanket rules for them. The rule governs how much detail an instruction carries, not whether a step is fixed.
It links to `plugin-entity-taxonomy.md`'s flowchart test and to the per-model middle path rather than restating either.

**Behavior.** Changing. The specificity rule now carries a stated limit. Settled by the operator (option A).

**Why.** [C-12](artifacts/current-state-findings.md#c-12-the-instruction-writing-guide-pushes-toward-specificity-with-no-stated-limit).

**Decision.** [D-11](artifacts/change-decision-log.md#d-11-add-a-limit-to-be-specific)

### S-12: `progressive-disclosure.md` "When to remove entirely" — Re-scoped

**Target state.** The list names a second removable kind: instructions restating what the model already does by
default, such as "read the code before changing it." It links to `context-hygiene.md`'s "every token must earn its
place" rule.

**Behavior.** Changing, for `skill-builder` users: its Step 6 review reads this list, so it will now cut such
instructions from the skills it builds. See Behavior Changes.

**Why.** [C-13](artifacts/current-state-findings.md#c-13-when-to-remove-entirely-names-only-toolchain-enforced-rules).

**Decision.** [D-12](artifacts/change-decision-log.md#d-12-name-restates-a-default-as-removable-in-the-list-the-builder-review-reads)

### S-13: Gotchas category in `skill-reference-files.md`, named in `progressive-disclosure.md` — Re-scoped

**Target state.** `skill-reference-files.md`'s category list defines gotchas: failure points found in use that the
skill tells the model to avoid. The definition says gotchas grow over the skill's life and differ from a checklist
(what to verify) and a canonical example (what a convention looks like). `progressive-disclosure.md`'s extraction list
names gotchas and links to that definition.

**Behavior.** Preserving. Additive.

**Why.** [C-14](artifacts/current-state-findings.md#c-14-no-reference-file-category-holds-accumulated-gotchas).

**Decision.** [D-13](artifacts/change-decision-log.md#trivial-decisions)

### S-14: `success-criteria-and-testing.md` verification-skill subsection — Added

**Target state.** A subsection covers building a skill whose job is to verify a running product, as distinct from
testing a skill. The skill pairs with an external driver such as browser automation or a terminal tool, asserts state
at each step rather than once at the end, and can record the run so a person sees what was tested.

**Behavior.** Preserving. Additive.

**Why.** [C-15](artifacts/current-state-findings.md#c-15-testing-guidance-covers-testing-a-skill-not-building-a-skill-that-verifies-a-product).

**Decision.** [D-14](artifacts/change-decision-log.md#trivial-decisions)

### S-15: `plugin-json-options.md` section on keeping skill state across updates — Added

**Target state.** A section beside the environment-variable table covers two uses of `${CLAUDE_PLUGIN_DATA}` for a
skill shipped in a plugin. First-run setup: read a saved answer, ask with `AskUserQuestion` when it is absent, and
save it. Run memory: an append-only log or JSON file read at the next run. The section says:

- The skill's own directory is under `${CLAUDE_PLUGIN_ROOT}` and is replaced on update, so nothing is written there.
- `userConfig` is the choice when the value is known at install time.
- A file the user is expected to edit by hand belongs where the user edits it, not in the data directory.
- A skill checked into a repo's `.claude/skills/`, including one vendored by `/guidance init`, has no plugin data
  directory. It keeps its state in the repository or asks each run.

`allowed-tools-AskUserQuestion.md` links to the section.

**Behavior.** Preserving. Additive.

**Why.** [C-16](artifacts/current-state-findings.md#c-16-the-persistent-data-directory-is-documented-only-as-a-pluginjson-variable).

**Decision.** [D-15](artifacts/change-decision-log.md#d-15-keep-skill-state-in-the-plugin-data-directory-documented-as-a-section-not-a-new-file)

### S-16: `hardening-fuzzy-vs-deterministic.md` helper-library shape — Re-scoped

**Target state.** Deterministic Steps says `scripts/` can hold a library of helper functions, with their gotchas in the
functions' comments. The model loads that library into a one-off script it writes for the question at hand. It notes
that each composed script still prompts for permission, linking to `script-execution-instructions.md`.

**Behavior.** Preserving. Additive.

**Why.** [C-17](artifacts/current-state-findings.md#c-17-script-guidance-treats-every-script-as-one-fixed-operation).

**Decision.** [D-16](artifacts/change-decision-log.md#trivial-decisions)

### S-17: `skill-frontmatter-fields.md` `hooks` row — Re-scoped

**Target state.** The `hooks` row adds one sentence: a hook here lasts only for the skill's run, which suits a guardrail
you want only while that skill is active, such as blocking destructive shell commands. The row links to the official
hooks reference for the schema.

**Behavior.** Preserving. Additive.

**Why.** [C-18](artifacts/current-state-findings.md#c-18-hooks-are-documented-as-one-line-table-rows).

**Decision.** [D-17](artifacts/change-decision-log.md#d-17-one-sentence-on-skill-scoped-guardrail-hooks)

### S-18: `skill-builder` and `agent-builder` per-model routing and review item — Re-scoped

**Target state.** Each builder's decision table routes "instructions for a named target model" to
`per-model-authoring.md`. Each builder's Step 6 review checks that the finished files carry no model-specific leftovers:

- no "think step by step" or "think carefully" line;
- no instruction to reproduce reasoning in the reply;
- no pinned `effort` without a reason stated in the skill or agent body;
- no vague limiting phrase in a review step, judged by contract 3 with both of its examples quoted.

**Behavior.** Changing. Builder runs read one more file when a target model comes up, and the review checks one more
item. Settled by the operator (option A).

**Why.** [C-19](artifacts/current-state-findings.md#c-19-neither-builder-skill-reads-or-checks-against-the-per-model-guide).

**Depends on.** S-1 to S-5, the content the builders route to.

**Decision.** [D-18](artifacts/change-decision-log.md#d-18-the-builders-read-the-per-model-guide-when-a-target-model-is-named-and-always-check-for-leftovers)

## Behavior Changes

Five entries change what a reader or a builder user experiences.

- **Review-limit advice (S-5).** An author reading the per-model guide used to be told to avoid every "only report X"
  instruction. After the change, a limit that names a checkable bar and demands evidence per item is acceptable. Vague
  limits are still warned against. Operator, 2026-09-23: "go with recommendation for this one."
- **Specificity advice (S-11).** An author reading the instruction-writing guide used to see "be specific" with no
  limit. After the change, they are told to spell out conventions that break something when missed and to leave out
  instructions for details the model gets right unprompted. Operator, 2026-09-23: "go with recommendation."
- **Builder runs (S-18).** For someone building a skill or agent, naming a target model now makes the builder read the
  per-model guide. Their final review also flags leftovers such as a "think step by step" line or a pinned effort with
  no stated reason. Operator, 2026-09-23: "go with recommendation."
- **The agent-builder review (S-10) and the skill-builder review (S-12).** Both builders' final reviews re-read
  guidance files this plan changes. After the change, `agent-builder` checks that a research agent marks claims it could
  not confirm, and `skill-builder` cuts instructions that restate what the model already does by default. Operator, 2026-09-23: "option A" ([D-23](artifacts/change-decision-log.md#d-23-builder-reviews-that-pick-up-s-10-and-s-12)).

## Change Units

Each unit leaves every file consistent with the others and passes `npm run lint`.

### Unit 1: Per-model facts

**What it does.** Brings the per-model guide and its four mirrors up to Opus 5.5.

**Delta entries.** S-1, S-2, S-3, S-4, S-5, S-6, and the Per-Model Authoring row of contract 2.

**How you know it worked.** No file still carries the three-model list, across line wraps:

```bash
perl -0ne 'print "$ARGV\n" if /Sonnet 5,\s+Opus 5,?\s+(and|or)\s+Fable 5/' $(grep -rl "Fable 5" han-plugin-builder)
```

prints nothing. The router line matches between `guidance/SKILL.md` and `guidance/assets/guidance-portable-SKILL.md`
(`diff` on the extracted line). `grep -rln "Opus 5.5" han-plugin-builder` lists `per-model-authoring.md`, both
routers, `rule-index-body.md`, and `specialization-and-model-selection.md`. `npm run lint` passes.

### Unit 2: Long runs and delegation

**What it does.** Adds the stop-naming, finish-line, fan-out, background-wait, and unconfirmed-claim patterns, with
their rule-index rows from contract 2.

**Delta entries.** S-7, S-8, S-9, S-10.

**Ordering constraint.** After Unit 1, because S-7's per-model sentence lands in text Unit 1 rewrites.

**How you know it worked.** `grep -n collaborative-stop-rule han-plugin-builder/skills/guidance/references/skill-building-guidance/workflow-patterns.md`
hits the new subsection. `git diff --stat main -- han-core han-coding han-planning` is empty, so no collaborative skill
changed. Both new subsections appear in the file's Contents. Every new cross-reference resolves to an existing
heading. `npm run lint` passes.

### Unit 3: Instruction style and reference-file categories

**What it does.** Adds the specificity limit, the "already does by default" removal bullet, and the gotchas category,
with their rule-index rows from contract 2.

**Delta entries.** S-11, S-12, S-13.

**How you know it worked.** The S-11 rule links to `plugin-entity-taxonomy.md`, and it does not use the word
"judgment", which the taxonomy reserves for agents. `grep -rn -i gotcha han-plugin-builder` hits the definition in
`skill-reference-files.md` and the link in `progressive-disclosure.md`. `npm run lint` passes.

### Unit 4: Skill patterns from the baseline

**What it does.** Adds verification skills, keeping state across updates, helper libraries, and the skill-scoped
guardrail note, with their rule-index rows from contract 2.

**Delta entries.** S-14, S-15, S-16, S-17.

**How you know it worked.** Each rule-index row in contract 2 matches the file. `npm run lint` passes.

### Unit 5: Builder routing

**What it does.** Points both builders at the per-model guide and adds the leftover check.

**Delta entries.** S-18.

**Ordering constraint.** After Unit 1, so the builders route to updated content, and after Unit 2, so `agent-builder`'s
Step 6 carries S-10's item 8 change alongside the new item.

**How you know it worked.** `grep -n per-model-authoring han-plugin-builder/skills/*-builder/SKILL.md` hits the decision
table and Step 6 in each. Both examples from contract 3 appear in each Step 6. `npm run lint` passes.

After Unit 5, run `/han-update-documentation` on the branch. The plugin's long-form docs describe the builders' review
in general terms (`docs/skills/skill-builder.md:32-34`, `docs/skills/agent-builder.md:30-33`) and stay accurate, so
that pass is a safety check, not a planned edit.

The release version bump for `han-plugin-builder` belongs to `/han-release`, not to this plan.

## Risks

- **The stop-naming guidance gets pasted into a collaborative skill.** Six skills across three plugins rely on
  `collaborative-stop-rule.md`, and a keep-going instruction in any of them would silently remove a human checkpoint.
  S-7 names those stops as wanted in its own text. Unit 2 checks that the subsection links the rule and that no
  collaborative skill changed. Nothing guards a later edit.
- **The specificity limit reads as permission to turn a skill's steps into judgment calls.** The guide is read on
  nearly every skill-authoring task. S-11 limits the rule to instruction detail, avoids the word the taxonomy reserves
  for agents, and links the flowchart test. A reviewer still reads the wording at Unit 3.
- **The builder review over-flags or under-flags.** S-18 runs on the next skill or agent anyone builds. A false positive
  costs a rework. A false negative ships a leftover the review was meant to catch. Contract 3's two examples are the
  guard.
- **A mirror or index description gets missed.** The model list lives in five files, and nine rule-index descriptions
  change. Unit 1's multi-line check covers the model list. The index rows are checked by reading each against contract 2.
- **Consuming repos keep the old text.** Repos that ran `/guidance init` see the change only after `/guidance update`.
  Name that in the release notes.
- **The sources change.** The article and the platform page are snapshots from 2026-09-23. The per-model guide's
  "last checked" stamp is how a reader knows.

## Deferred (YAGNI)

- **Designing expressive script and tool interfaces instead of usage examples (K-15).** SOURCE 3 says examples
  constrain newer models, but the claim is about tool definitions, not the convention examples the plugin teaches. SOURCE
  1 and SOURCE 4 both teach through concrete examples. Reopen if a Han skill's scripts grow parameters the model misuses,
  or if an Anthropic page extends the claim to skill instructions.
- **A hooks guide, and the usage-logging hook pattern.** No Han plugin or skill ships a hook today. S-17 keeps one
  sentence on the skill-scoped guardrail. Reopen when a Han skill ships a hook, or when an author asks how to measure how
  often a skill is used.
- **A dedicated file for skill state.** S-15 lands as a section instead. Reopen if the section outgrows its host file,
  or when a Han skill starts saving state.

## Cut for Scope

- **Re-checking the Fable 5 guidance against Fable 5.1.** Anthropic publishes a separate Fable 5.1 prompting page. None
  of the four sources describes Fable 5.1's instruction style, and the operator's request is an evaluation against the
  Opus 5.5 article and its related sources (`artifacts/scope-boundary.md`, Stated Scope). Cutting it means the guide
  keeps describing Fable 5, not Fable 5.1, after this change. The operator can reinstate it.
- **Making `agent-builder` cite `writing-effective-instructions.md`.** The behavioral trace found that `agent-builder`
  never cites the instruction-writing guide. The gap is real, but no source drives it, and the request is an evaluation
  against the sources. Cutting it means agent authors using the builder still are not pointed at the general
  instruction-writing rules. The operator can reinstate it.

## Open Items

- **Whether writing to `${CLAUDE_PLUGIN_DATA}` prompts for permission.** Non-blocking. S-15 should tell the author what
  to expect on the first save. The build confirms it against the Claude Code permissions docs before writing that
  sentence, and leaves the sentence out if the docs do not say.

## Review Findings

Two specialists reviewed the draft: `han-core:junior-developer` (16 findings, none blocking) and `han-core:risk-analyst`
(no critical or high risks; four medium, one low, one YAGNI candidate). Findings that changed the plan, merged where
both raised the same thing:

- **The new state file was more structure than the reason justified** (junior-developer JD-1, JD-2; risk-analyst R5).
  S-15 became a section in `plugin-json-options.md`, and it now covers vendored skills and user-edited config
  ([D-15](artifacts/change-decision-log.md#d-15-keep-skill-state-in-the-plugin-data-directory-documented-as-a-section-not-a-new-file)).
- **Rule-index descriptions for widened files would go stale** (JD-3, JD-11). Pinned as contract 2
  ([D-22](artifacts/change-decision-log.md#d-22-pin-every-widened-files-rule-index-description)).
- **S-12 changes what `skill-builder` produces** (JD-4). Reclassified as Changing and sent to the operator with S-10
  ([D-23](artifacts/change-decision-log.md#d-23-builder-reviews-that-pick-up-s-10-and-s-12)).
- **The hook entry was the same evidence gap as the deferred hooks guide** (JD-5, R6). S-17 narrowed to one sentence
  ([D-17](artifacts/change-decision-log.md#d-17-one-sentence-on-skill-scoped-guardrail-hooks)).
- **The review-limit test and the builder check could drift apart** (JD-6). Pinned as contract 3
  ([D-5](artifacts/change-decision-log.md#d-5-keep-the-limiting-phrase-warning-and-separate-vague-limits-from-a-concrete-bar), [D-18](artifacts/change-decision-log.md#d-18-the-builders-read-the-per-model-guide-when-a-target-model-is-named-and-always-check-for-leftovers)).
- **Unit 1's check could not see the wrapped rule-index copy** (R1, JD-15). Replaced with a multi-line match.
- **S-7 and S-11 relied on reading alone** (R2, R3). Unit 2 and Unit 3 gained mechanical checks.
- **Wording**: "judgment calls" became "routine details the model gets right unprompted" (JD-7). The fan-out rule's line
  against the self-check ban is now stated (JD-8). The effort default is attributed to the API docs (JD-9). Headings
  that name only Opus 5 or only Fable 5 are renamed (JD-10). Gotchas are defined once (JD-13). Helper-library wording is
  language-neutral (JD-14). New subsections go in Contents (JD-16).
- **Closed with a citation**: JD-12, which asked for explicit doc entries. The long-form docs describe the review in
  general terms and stay accurate (Unit 5 note).

The reviewers marked `Unverified` any finding that rested on inputs they could not inspect (the live source pages).
None was blocking. The one that mattered, the effort default (JD-9), was checked against the captured SOURCE 4 text
and resolved by attributing the default to the API.

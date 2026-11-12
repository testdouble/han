# Change Decision Log: Opus 5.5 plugin-builder guidance update

<!--
This file records every decision committed while planning the Opus 5.5 plugin-builder guidance update.
The plan itself lives in [../change-plan.md](../change-plan.md). This file captures the
question, rationale, evidence, and rejected alternatives behind each decision.
Evidence about the plugin as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.
Decision numbers D-1 to D-18 match the surface delta entries S-1 to S-18 one for one.
-->

## Trivial decisions

- D-13: Gotchas as a reference-file category — defined once in `skill-reference-files.md`'s category list as
  failure points found in use and distinct from a checklist, and named with a link in `progressive-disclosure.md`
  (review finding JD-13). — Referenced in plan: Surface Delta.
- D-14: Verification skills — a new subsection in `success-criteria-and-testing.md`, separated from testing the skill
  itself. — Referenced in plan: Surface Delta.
- D-16: Helper-script libraries — added to `hardening-fuzzy-vs-deterministic.md`'s Deterministic Steps in
  language-neutral words (review finding JD-14), with the permission-prompt caveat cross-referenced to
  `script-execution-instructions.md`. — Referenced in plan: Surface Delta.

## Full decisions

### D-1: Add Opus 5.5 to the per-model guide and every file that restates its model list

- **Question:** How does the plugin come to name Opus 5.5, and what does it say about Opus 5 guidance that 5.5 inherits?
- **Decision:** Add Opus 5.5 to `per-model-authoring.md`, bump its "last checked" stamp to the date the build runs,
  and state that Opus 5.5 inherits the Opus 5 guidance except where the guide says otherwise. Mirror the new model list
  in `guidance/SKILL.md:48-50`, `assets/guidance-portable-SKILL.md:27-29`, `assets/rule-index-body.md:166-171`, and
  `specialization-and-model-selection.md:89`. Keep "Fable 5" as written.
- **Rationale:** The guide dates itself before Opus 5.5 shipped and names no Opus 5.5 behavior. SOURCE 4 says "Existing
  Claude Opus 5 prompts should perform well without changes," so saying that 5.5 inherits the Opus 5 advice is both
  accurate and the smallest change. The four mirrors are independent copies, so missing one leaves a stale router or rule
  index in every repo that vendors the guidance.
- **Evidence:** C-1, C-2; SOURCE 4 opening paragraph; precedent commit `59398fc`, which swept the same four surfaces for
  Opus 5.
- **Behavior impact:** Preserving. Every existing recommendation still stands. Readers see an extra model named, and the
  router routes the same questions to the same file.
- **Rejected alternatives:**
  - Rename Fable 5 to Fable 5.1 throughout — rejected because the four sources mention Fable 5.1 once, about biology
    safeguards, and say nothing about its instruction style (group 1 validation).
  - Write a standalone Opus 5.5 guide — rejected because it would duplicate the Opus 5 content SOURCE 4 says still
    applies.
- **Revisit criterion:** A Fable 5.1 review (see Cut for Scope), or an Anthropic page stating that an Opus 5
  recommendation no longer holds on 5.5.
- **Dissent (if any):** None.
- **Settles delta entry:** S-1
- **Dependent decisions:** D-2, D-3, D-4, D-6, D-18
- **Referenced in plan:** What Changes, In One Paragraph; Surface Delta; Change Units

### D-2: The reasoning-echo warning covers Opus 5.5 and names the refusal category

- **Question:** Does the reasoning-echo warning stay Fable 5 only?
- **Decision:** Extend the section to Opus 5.5 and name the `reasoning_extraction` refusal category. Replace
  "single-source, not independently corroborated" with "single-vendor, stated on the Fable 5 page, the Opus 5.5 page,
  and the Opus 5.5 blog post". Update the rule-index description that names "the Fable 5 reasoning-echo refusal" to match.
- **Rationale:** Opus 5.5 can refuse an author's "explain your reasoning" instruction outright, a functional failure
  rather than a style mismatch. SOURCE 1 and SOURCE 4 both say so.
- **Evidence:** C-3; SOURCE 1 "Don't ask it to show its reasoning in the reply"; SOURCE 4 "Safeguard refusals".
- **Behavior impact:** Preserving. The existing test for spotting the pattern is unchanged; it now applies to two models.
- **Rejected alternatives:**
  - Describe the claim as independently corroborated — rejected because every source is an Anthropic publication
    (group 1 validation, V8).
- **Revisit criterion:** A source saying the refusal no longer applies on either model.
- **Dissent (if any):** None.
- **Settles delta entry:** S-2
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta

### D-3: One clause on Opus 5.5 thinking, not a new section

- **Question:** How much does the guide say about thinking on Opus 5.5?
- **Decision:** Add one clause to the thinking-mode bullet: Opus 5.5 always thinks and cannot disable it, so the
  XML-tag-leak caveat, which applies only when thinking is disabled on Opus 5, does not apply to it.
- **Rationale:** The bullet already turns an API fact into author-facing advice. The only thing an author needs to know
  about 5.5 is that the leak caveat does not apply.
- **Evidence:** C-4; SOURCE 4 "Prompts written for thinking disabled".
- **Behavior impact:** Preserving.
- **Rejected alternatives:**
  - Carry SOURCE 4's four-step migration list for thinking-disabled integrations — rejected because it covers API request
    fields (`thinking.display`, `max_tokens`) that a skill author does not set.
- **Revisit criterion:** Claude Code exposing a thinking toggle to skills or agents.
- **Dissent (if any):** None.
- **Settles delta entry:** S-3
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta

### D-4: Tell authors to re-test a pinned effort value on Opus 5.5

- **Question:** What does an author who pinned `effort` in frontmatter need to know?
- **Decision:** Add to the effort bullet: the same effort name means more thinking on Opus 5.5 than on Opus 5;
  Anthropic's platform docs put 5.5's API default at `medium` (Opus 5's is `high`) and report `medium` on 5.5 matching
  or exceeding Opus 5 at `high`; and `xhigh` and `max` are for measured gains. The default is attributed to the API docs
  because Claude Code's own session default is not stated in any source (review finding JD-9). A pinned value tuned
  for Opus 5 should be re-tested rather than carried over. Add a one-line pointer to the section "Other settings the
  model differences affect" beside the `effort` row in `skill-frontmatter-fields.md` and in `agent-external-files.md`.
- **Rationale:** Skill and agent frontmatter can pin effort, so a value chosen for Opus 5 silently produces longer,
  costlier turns on 5.5. The pointers put the warning where an author first sees the field.
- **Evidence:** C-5; SOURCE 4 "Calibrate effort"; SOURCE 1 "To change how much it thinks in Claude Code, change effort."
- **Behavior impact:** Preserving. Additive.
- **Rejected alternatives:**
  - Recommend a specific effort level for skills — rejected because SOURCE 4 says to test levels against your own evals,
    and the plugin's specialization guide already owns tier choice.
- **Revisit criterion:** A later model changing the default again.
- **Dissent (if any):** None.
- **Settles delta entry:** S-4
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta

### D-5: Keep the limiting-phrase warning and separate vague limits from a concrete bar

- **Question:** Does the warning against "only report X" review instructions stay, given that SOURCE 1 recommends one?
- **Decision:** Keep the warning and its report-then-filter default for vague limits ("high-severity", "be
  conservative"). Add that a limit is acceptable when it names a bar a reader could check (a consequence such as "would block
  the merge", or a rubric the skill itself carries) and requires evidence for each item. Quote SOURCE 1's example whole,
  evidence clause included: "List only problems you'd block the merge for. For each one, give the file and line, why it's
  wrong, and how to show it fails." This test and its two examples are the plan's contract 3, shared with D-18 (review
  finding JD-6).
- **Rationale:** No source says Opus 5.5 is less literal than Opus 5, so the warning's premise still holds. SOURCE 1's
  prompt differs from the vague examples in two ways the model can act on: the bar is observable, and each finding must
  carry proof.
- **Evidence:** C-6; SOURCE 1 "Ask it to review the code"; group 3 validation (K-14).
- **Behavior impact:** Changing. A reader who used to avoid every limiting phrase now learns one shape of limit that is
  acceptable. The user was asked on 2026-09-23 and answered: "go with recommendation for this one" (option A: keep the
  warning and add the distinction).
- **Rejected alternatives:**
  - Keep the warning unchanged (option B) — rejected by the user, and it leaves the primary source's recommended prompt
    reading as a mistake.
  - Drop the warning for Opus 5.5 (option C) — rejected because no source supports it.
  - Distinguish reusable skill instructions from one-off prompts (a validator's proposal) — rejected because a skill
    author only ever writes reusable instructions, so the distinction gives them nothing to act on.
- **Revisit criterion:** A source stating Opus 5.5 under-reports with a concrete bar, or no longer follows limits
  literally.
- **Dissent (if any):** None.
- **Settles delta entry:** S-5
- **Dependent decisions:** D-18
- **Referenced in plan:** Target State; Surface Delta; Behavior Changes; Review Findings

### D-6: Add the Opus 5.5 sources, labeled by tier, without touching the research report

- **Question:** What goes in the per-model Sources section?
- **Decision:** Add the Opus 5.5 prompting page as an Anthropic docs entry. Add SOURCE 1 labeled as an Anthropic blog
  post with its author and date. Extend the existing "postdates that research report" sentence to cover the Opus 5.5
  material. Leave `docs/research/model-specific-guidance-for-skills.md` and `multi-agent-economics.md`'s Opus 5 URL
  unchanged.
- **Rationale:** The section already distinguishes evidence tiers. The research report is a dated artifact that the
  guide already marks as superseded. `multi-agent-economics.md`'s Opus 5 URL still supports the claim it is cited for.
- **Evidence:** C-7; group 1 validation (K-28, K-11).
- **Behavior impact:** Preserving.
- **Rejected alternatives:**
  - Rewrite the research report — rejected because `docs/research/` holds point-in-time reports.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** S-6
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta

### D-7: Name the stops a long autonomous stretch should and should not make, and protect the collaborative stops

- **Question:** How does the guidance answer Opus 5.5 ending a turn early with a report?
- **Decision:** Add a subsection after "Human Gates in Workflow Steps" in `workflow-patterns.md`. For a stretch of a
  skill meant to run without the user, such as a fan-out or a long tool-calling loop, the step names the stops it does
  not want: a summary that announces the next step instead of taking it, an offer to continue, and a list of choices
  that block nothing. It also names the stops it does want: no work can move without the user, a destructive or
  irreversible action is next, or a human gate is reached. The subsection says plainly that human gates, interview
  turns, and `han-core`'s collaborative-stop boundaries are wanted stops, and that the keep-going instruction does not
  belong in a skill whose design is to hand control back. Add one sentence to `per-model-authoring.md` naming the Opus
  5.5 behavior and linking to the subsection.
- **Rationale:** SOURCE 1 and SOURCE 4 both describe the behavior and both say naming the stops works. Both also say to
  leave the keep-going instruction out of human-in-the-loop work ("For pair programming, you may want the opposite";
  "leave the addition out of human-in-the-loop applications"). Most Han skills are that shape, so an unscoped rule would
  weaken them.
- **Evidence:** C-8; SOURCE 1 "Tell it which stops you want"; SOURCE 4 "Unattended agentic runs"; group 2 validation
  (K-5).
- **Behavior impact:** Preserving. Additive. No existing gate or stop rule changes.
- **Rejected alternatives:**
  - A blanket keep-going rule for all skills — rejected because it contradicts both sources' human-in-the-loop carve-out
    and `han-core/references/collaborative-stop-rule.md`.
  - Put the whole pattern in `per-model-authoring.md` — rejected because the pattern holds on any model that stops
    early. The guide carries only the model fact.
- **Revisit criterion:** A report of a Han skill stopping mid-stretch on Opus 5.5 despite the guidance, or of the
  guidance being pasted into a collaborative skill.
- **Dissent (if any):** None.
- **Settles delta entry:** S-7
- **Dependent decisions:** D-8
- **Referenced in plan:** Surface Delta; Risks

### D-8: State the finish line and keep the task list in a file, only for unbounded steps

- **Question:** Does every skill need a stated finish line and a task file?
- **Decision:** No. Add one subsection to `workflow-patterns.md` for steps that iterate over a set whose size is not
  known up front: every file, every endpoint, every finding. Such a step states its completion condition in checkable
  terms, keeps its checklist in a file it updates as items finish, and reads that file rather than the conversation to
  decide what remains. Cross-reference `skill-composition.md`'s continuation rule and `multi-agent-economics.md`.
- **Rationale:** A fixed flowchart skill already ends at its last step (`plugin-entity-taxonomy.md`). The sources' finish
  line and TASKS.md advice targets open-ended, multi-part work, which inside a skill is the unbounded step.
- **Evidence:** C-9; SOURCE 1 "Say what 'done' looks like" and "Keep the task list in a file"; SOURCE 4 "keep the task's
  parts in a checklist the model updates, such as a to-do tool or a file"; group 2 validation (K-6, K-7).
- **Behavior impact:** Preserving. Additive.
- **Rejected alternatives:**
  - A finish line on every skill — rejected as restating what the flowchart already guarantees.
  - SOURCE 4's checker model and continuation cap — rejected because both need a custom harness a skill author does not
    have.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** S-8
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta

### D-9: Check fanned-out evidence and wait for background dispatches

- **Question:** What do multi-agent skills need that the delegation rules do not say?
- **Decision:** In `multi-agent-economics.md`, add a rule for fan-out: when a skill gives each unit of work to its own
  subagent, the skill checks each returned finding's evidence before accepting it, then produces one consolidated
  result. State the line against the existing self-check ban: checking the evidence a subagent cites against its source is
  allowed; dispatching another agent to redo the skill's own reasoning is not (review finding JD-8). Under
  "Practical Implications for Skills," add that a skill does not treat its run as complete while a dispatch it launched
  with `run_in_background: true` is still running, and label that item as resting on a single source. Add a
  cross-reference beside the `background` row in `agent-external-files.md`.
- **Rationale:** SOURCE 1 gives the fan-out pattern as a worked prompt. Han already dispatches in the background, at
  `han-coding/skills/automated-test-planning/SKILL.md:134`.
- **Evidence:** C-10; SOURCE 1 FIG C; SOURCE 4 "If something the model started is still running, such as a background
  command or a subagent, don't treat the task as done yet"; group 2 and group 3 validation (K-8, K-9).
- **Behavior impact:** Preserving. Additive.
- **Rejected alternatives:**
  - Tie the wait rule to the frontmatter `background: true` field only — rejected because no Han agent uses that field;
    the `Agent` tool parameter is the mechanism in use.
  - A continuation cap — rejected as harness-only.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** S-9
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta

### D-10: Agents say what they could not confirm and where they looked

- **Question:** Where does "mark anything you couldn't confirm" belong?
- **Decision:** Add a second rule to `agent-building-guidelines/graceful-degradation.md`. When a research or analysis
  agent cannot establish a claim even with every tool available, it says so on the claim and names where it looked.
  Reuse the file's "note the limitation" wording. Update `agent-builder` Step 6 item 8 so its one-line summary names both
  rules, since the review re-reads that file.
- **Rationale:** The existing rule fires only on a missing tool. The source's case, where the agent looked and found
  nothing, is a different trigger.
- **Evidence:** C-11; SOURCE 1 "Ask it to mark what it couldn't confirm"; group 3 validation (K-12).
- **Behavior impact:** Changing for `agent-builder` users, whose final review checks one more condition. The guide
  itself only gains a rule. Operator decision recorded in D-23.
- **Rejected alternatives:**
  - Land it in the skill-side `graceful-degradation.md` — rejected because that file covers environment detection, not
    agent output.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** S-10
- **Dependent decisions:** D-23
- **Referenced in plan:** Surface Delta; Behavior Changes

### D-11: Add a limit to "be specific"

- **Question:** Should the instruction-writing guide tell authors when not to be specific?
- **Decision:** Add a rule beside "Be specific and actionable" in `writing-effective-instructions.md`. Spell out
  conventions that break something when missed. Leave out instructions for routine details the model gets right
  unprompted, rather than writing blanket rules for them. The wording avoids "judgment", which `plugin-entity-taxonomy.md`
  reserves for agents (review finding JD-7). The rule governs how much detail an instruction carries, not whether a step is fixed. Skills stay
  flowchartable, per `plugin-entity-taxonomy.md`. Link the taxonomy's flowchart test and the per-model middle path rather than restating either.
- **Rationale:** The baseline articles report that newer models are over-constrained by blanket rules, and that
  Anthropic removed such rules from Claude Code with no measured loss. The existing counterweight covers only an unknown
  target model.
- **Evidence:** C-12; SOURCE 2 "Avoid railroading Claude"; SOURCE 3 "Then: Give Claude rules / Now: Let Claude use
  judgement" and "Avoid making them overconstrained, except in highly important areas"; group 4 validation (K-16).
- **Behavior impact:** Changing. Readers of the specificity rule now meet a stated limit on it. The user was asked on
  2026-09-23 and answered: "go with recommendation" (option A: add the counterweight).
- **Rejected alternatives:**
  - Leave the rule as it is (option B) — rejected by the user.
- **Revisit criterion:** Evidence that skills written under the new rule lose conventions they needed.
- **Dissent (if any):** A validator warned that the wording could blur the line between a skill and an agent. The
  decision limits the rule to instruction detail for that reason.
- **Settles delta entry:** S-11
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta; Behavior Changes; Risks

### D-12: Name "restates a default" as removable, in the list the builder review reads

- **Question:** Where does "don't state the obvious" land, and what does it change?
- **Decision:** Add one bullet to `progressive-disclosure.md`'s "When to remove entirely" list: instructions restating
  what the model already does by default, such as "read the code before changing it." Link `context-hygiene.md`'s
  "every token must earn its place" rule, which already states the principle.
- **Rationale:** `context-hygiene.md` states the principle but the `skill-builder` review does not cite it.
  `progressive-disclosure.md` is the file that review names, so the example lands where it is applied.
- **Evidence:** C-13; SOURCE 2 "Don't state the obvious"; SOURCE 3 "Avoid stating 'the obvious'"; group 4 validation
  (K-17).
- **Behavior impact:** Changing for `skill-builder` users: its Step 6 review will now cut such instructions from the
  skills it builds (review finding JD-4). Operator decision recorded in D-23.
- **Rejected alternatives:**
  - A new rule in `context-hygiene.md` — rejected because the principle is already there and the builder review would
    not see it.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** S-12
- **Dependent decisions:** D-23
- **Referenced in plan:** Surface Delta; Behavior Changes

### D-15: Keep skill state in the plugin data directory, documented as a section, not a new file

- **Question:** Where does guidance on first-run setup and skill memory live, and where does the state itself live?
- **Decision:** Add a section beside the environment-variable table in `plugin-json-options.md` covering two uses of
  `${CLAUDE_PLUGIN_DATA}` for a skill shipped in a plugin. The first is first-run setup: read a saved answer, ask with
  `AskUserQuestion` when it is absent (under the existing rule that keeps that tool out of `allowed-tools`), and save
  it. The second is run memory: an append-only log or JSON file read at the next run. The section also says:
  - the skill's own directory is under `${CLAUDE_PLUGIN_ROOT}` and is replaced on update, so nothing is written there;
  - `userConfig` is the choice for a value known at install time;
  - a file the user edits by hand belongs where the user edits it;
  - a skill checked into `.claude/skills/`, including one vendored by `/guidance init`, has no plugin data directory.

  `allowed-tools-AskUserQuestion.md` links to the section.
- **Rationale:** SOURCE 2 describes both patterns with a `config.json` in the skill directory, and points to
  `${CLAUDE_PLUGIN_DATA}` for memory. For an installed plugin, the skill directory does not survive an update. The two
  facts that make this work already sit in `plugin-json-options.md`'s environment-variable table, so a section there
  adds the least structure. No Han skill uses the data directory today, which argues for the smaller form.
- **Evidence:** C-16, C-21; SOURCE 2 "Think through the setup" and "Help Claude remember"; group 5 validation (K-21,
  K-22); review findings JD-1, JD-2, R5.
- **Behavior impact:** Preserving. Additive.
- **Rejected alternatives:**
  - A new `skill-persistent-state.md` file (the draft's choice) — rejected in review because it added a file, a
    rule-index line, and a builder-routing question for content two table rows already anchor.
  - Two separate files — rejected because both would explain the same directory.
  - Follow SOURCE 2 literally and use `config.json` in the skill directory — rejected because the plugin's own
    reference says that path "Changes on plugin update."
- **Revisit criterion:** The section outgrows its host file, or a Han skill starts saving state.
- **Dissent (if any):** The group 5 validator recommended a new file. The review round reversed that.
- **Settles delta entry:** S-15
- **Dependent decisions:** —
- **Referenced in plan:** Target State; Surface Delta; Deferred (YAGNI); Review Findings

### D-17: One sentence on skill-scoped guardrail hooks

- **Question:** How much hooks guidance does the plugin add?
- **Decision:** Extend the `hooks` row in `skill-frontmatter-fields.md` with one sentence: a hook declared there lasts
  only for the skill's run, which suits a guardrail wanted only while that skill is active, such as blocking destructive
  shell commands. Link the official hooks reference for the schema. Defer the usage-logging hook.
- **Rationale:** SOURCE 2 names the on-demand guardrail, and the plugin mentions skill hooks only as a bare table row.
  No Han plugin or skill ships a hook, so anything larger fails the same evidence test as the deferred hooks guide. The
  usage-logging hook lives in plugin or settings configuration, not in the frontmatter inventory.
- **Evidence:** C-18; SOURCE 2 "Use on-demand hooks" and "Measuring skills"; group 5 validation (K-24); review
  findings JD-5, R6.
- **Behavior impact:** Preserving. Additive.
- **Rejected alternatives:**
  - A new hooks guide covering the full schema (validator's proposal) — deferred.
  - A section with both the guardrail and the usage-logging patterns (the draft's choice) — narrowed in review.
- **Revisit criterion:** A Han skill ships a hook, or an author asks how to measure how often a skill is used.
- **Dissent (if any):** The group 5 validator recommended the larger guide.
- **Settles delta entry:** S-17
- **Dependent decisions:** —
- **Referenced in plan:** Surface Delta; Deferred (YAGNI); Review Findings

### D-18: The builders read the per-model guide when a target model is named, and always check for leftovers

- **Question:** Should `skill-builder` and `agent-builder` route to and review against `per-model-authoring.md`?
- **Decision:** Add a row to each builder's decision table: "Instructions for a named target model →
  `per-model-authoring.md`." Add one item to each builder's Step 6 review: the finished files carry no model-specific
  leftovers. That means no "think step by step" or "think carefully" line, no instruction to reproduce reasoning in the
  reply, no pinned `effort` without a reason stated in the skill or agent body, and no vague limiting phrase in a review
  step, judged by the plan's contract 3 with both of its examples quoted in each Step 6 (review finding JD-6).
- **Rationale:** Without this, the Opus 5.5 guidance reaches only people who ask the `guidance` skill directly. The
  check applies the guide's own model-agnostic default rather than contradicting it.
- **Evidence:** C-19, C-20; group 2 validation (K-25).
- **Behavior impact:** Changing. Builder runs read one more file when a target model comes up, and the final review
  checks one more item. The user was asked on 2026-09-23 and answered: "go with recommendation" (option A: add it to both
  builders).
- **Rejected alternatives:**
  - Leave the builders unchanged (option B) — rejected by the user.
  - Also make `agent-builder` cite `writing-effective-instructions.md` — cut for scope; the sources do not drive it.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** S-18
- **Dependent decisions:** D-23
- **Referenced in plan:** Surface Delta; Behavior Changes; Review Findings

### D-19: The source set and its precedence

- **Question:** Which sources does the evaluation run against, and which wins when they conflict?
- **Decision:** SOURCE 1 is primary and overrides the others. SOURCE 2 is the operator-named baseline. SOURCE 3 (linked
  as related from both operator-named articles) and SOURCE 4 (Anthropic's own Opus 5.5 prompting page) are related
  baseline sources. Entries resting only on SOURCE 2 or SOURCE 3 are labeled baseline gaps rather than Opus 5.5 changes.
- **Rationale:** The operator said to include "related sources in this eval as a baseline, but letting the article on
  getting the most out of opus 5.5 override anything from this one." SOURCE 4 is the platform page for the same model.
- **Evidence:** Operator message recorded in `scope-boundary.md`.
- **Behavior impact:** —
- **Rejected alternatives:**
  - Treat SOURCE 4 as primary because it is the platform docs — rejected because the operator named SOURCE 1. The two
    do not conflict on any retained entry.
- **Revisit criterion:** —
- **Dissent (if any):** A validator noted that SOURCE 1 is a blog post outranking platform docs. No conflict arose.
- **Settles delta entry:** —
- **Dependent decisions:** D-6
- **Referenced in plan:** Why This Change

### D-20: Candidates rejected by adversarial validation

- **Question:** Which proposed changes did not survive?
- **Decision:** Eight of the twenty-eight merged candidates are not in the plan:
  - **Time-budget signal for agent teams (K-10)** — needs a harness that appends elapsed time to each message; a skill
    author has no such surface. SOURCE 4 only.
  - **Delegation eagerness on Opus 5.5 (K-11)** — no source says 5.5 reaches for subagents more or less readily; SOURCE
    4's claim is about endurance.
  - **Marking pasted content as untrusted (K-13)** — an API-level tagging technique with a random ID a skill cannot
    generate. SOURCE 4 only.
  - **The nine skill categories (K-19)** — `skill-decomposition.md:20-39` already gives the single-concern test with a
    worked example; SOURCE 2 presents the categories as a portfolio audit.
  - **Updating the `claude-opus-5` example ID (K-26)** — the sentence illustrates that pinned IDs go stale, which is
    still true.
  - **"Repeat a reminder" versus "don't repeat yourself" (K-27)** — different mechanisms: a recency reminder in one
    document versus duplicate tool instructions in two places.
  - **Examples constrain newer models (K-15)** — deferred; see the plan's Deferred section.
  - **A full hooks schema guide (part of K-24)** — deferred; see D-17.
- Also confirmed already covered, so not candidates: removing "think carefully" lines (covered by the thinking bullet's
  "do not write 'think step by step' prompt hacks"), `${CLAUDE_PLUGIN_DATA}` as a variable (`plugin-json-options.md`),
  skill-scoped `hooks` as a field (`skill-frontmatter-fields.md:49`), composing skills by name
  (`skill-composition.md`), and descriptions written for the model (`skill-description-frontmatter.md`).
- **Rationale:** Each item failed the evidence, applicability, or coverage test in its validator's report.
- **Evidence:** Group 1 to 5 validation reports; C-20.
- **Behavior impact:** —
- **Rejected alternatives:** —
- **Revisit criterion:** Per item, as named in Deferred.
- **Dissent (if any):** A validator called K-19's rejection a judgment call.
- **Settles delta entry:** —
- **Dependent decisions:** —
- **Referenced in plan:** Deferred (YAGNI); Review Findings

### D-21: The target state came from the validators' landing recommendations, not a separate architect pass

- **Question:** Does the run dispatch `han-core:software-architect` for the target state, as the skill's Step 4
  prescribes?
- **Decision:** No. The target state is file placement of guidance text. Each validator already named a landing file
  with evidence and checked it for duplication, and the structural map (C-2, C-21) shows which files move together.
- **Rationale:** An architect pass would re-derive placement from the same evidence with no module or interface design to
  add. The deviation is disclosed here and in the plan.
- **Evidence:** Group 1 to 5 validation reports; the structural-analyst report.
- **Behavior impact:** —
- **Rejected alternatives:**
  - Dispatch the architect anyway — rejected as cost without new information.
- **Revisit criterion:** The review round finding a placement conflict the validators missed.
- **Dissent (if any):** None.
- **Settles delta entry:** —
- **Dependent decisions:** —
- **Referenced in plan:** Target State

### D-22: Pin every widened file's rule-index description

- **Question:** Which rule-index descriptions change, and to what?
- **Decision:** Update the description of every file whose scope this plan widens, using the text in the plan's
  contract 2: Per-Model Authoring Guidance, Workflow Patterns, Multi-Agent Economics, Graceful Degradation (agents),
  Success Criteria and Testing, Writing Effective Instructions, Skill Reference Files, Hardening: Fuzzy vs.
  Deterministic, and plugin.json Schema Reference.
- **Rationale:** The rule index is vendored into consuming repos and is how the model chooses which file to read. A
  description that omits a file's new content sends a reader with that question elsewhere.
- **Evidence:** C-21; `rule-index-body.md:39-41`, `:46-51`, `:58-63`, `:97-99`, `:125-135`, `:143-145`; review
  findings JD-3, JD-11.
- **Behavior impact:** Preserving. Descriptions widen to match content; no link or routing changes.
- **Rejected alternatives:**
  - Update only the two lines the draft pinned — rejected in review because six other descriptions would mislead.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** — (applies across S-1, S-7 to S-11, S-13 to S-16)
- **Dependent decisions:** —
- **Referenced in plan:** Target State; Review Findings

### D-23: Builder reviews that pick up S-10 and S-12

- **Question:** The `agent-builder` and `skill-builder` final reviews re-read guidance files this plan changes. Does the
  operator accept that those reviews will now check that research agents mark unconfirmed claims (S-10), and cut
  instructions that restate model defaults (S-12)?
- **Decision:** Both builder reviews apply the new guidance. `agent-builder` checks that a research or analysis agent
  marks claims it could not confirm (S-10), and `skill-builder` cuts instructions that restate model defaults (S-12).
  The operator was asked on 2026-09-23 and answered: "option A".
- **Rationale:** Both are behavior changes that the review round surfaced (JD-4) after the three approved escalations.
  They are asked together because they share one mechanism: a builder review applies whatever the guidance file it
  re-reads says.
- **Evidence:** C-11, C-13, C-19; review finding JD-4.
- **Behavior impact:** Changing. See the plan's Behavior Changes.
- **Rejected alternatives:**
  - Add the guidance but carve the builders out (option B) — rejected by the operator; it adds text and leaves the two
    surfaces disagreeing.
  - Drop S-10 and S-12 (option C) — rejected by the operator.
- **Revisit criterion:** —
- **Dissent (if any):** None.
- **Settles delta entry:** S-10, S-12
- **Dependent decisions:** —
- **Referenced in plan:** Behavior Changes; Open Items; Review Findings


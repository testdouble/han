# Implementation Decision Log: Readability Standard in the Planning and Coding Skills

<!--
This file records every implementation decision committed while planning this feature.
Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md) —
this file captures the question, rationale, evidence, and rejected alternatives for each decision.
Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).
-->

## Trivial decisions

<!-- None. Every committed decision carries at least one rejected alternative and rests on codebase or specialist evidence, so all are full. -->

None.

## Full decisions

### D-1: Edit sequencing

- **Question:** In what order are the edits applied, and as one atomic change or incremental commits?
- **Decision:** Incremental, commit-and-push-as-you-go, in this order: (a) the D9 `readability-rule.md` scope-text
  clarification plus the `readability-guidance` restatement; (b) the D4 `han-planning` dependency add; (c) the five
  full-pattern skills; (d) the two lightweight skills; (e) verification. The seven skill edits are order-independent
  among themselves.
- **Rationale:** Until D9 lands, `readability-rule.md` lines 20-23 textually read as excluding the very artifact types
  the seven skills produce, so a contributor reading the standard mid-stream would see it contradict the integrations.
  D4's purpose is to stop `han-planning` relying on the transitive `han-core` chain to reach `han-communication`, so it
  lands before the five planning-skill edits that invoke the sibling skill and agent. The incremental posture follows
  the user's directive rather than a single atomic PR.
- **Evidence:** junior-developer R1 sequencing finding; `han-communication/references/readability-rule.md` lines 20-23
  (the carve-out text); `han-planning/.claude-plugin/plugin.json:5` (`["han-core"]`); user directive "commit and push
  as you go" (OQ-1, resolution source user input).
- **Rejected alternatives:**
  - Single atomic PR of all edits — rejected by the user's commit-and-push-as-you-go directive.
  - Skill edits before the D9 clarification — rejected because it leaves the canonical standard textually contradicting
    the edits mid-implementation.
  - D4 dependency after the skill edits — rejected because the transitive chain works today but the edits' purpose is to
    stop relying on it, so the dependency must precede the skills that lean on it.
- **Specialist owner:** han-core:project-manager (executes as the sequenced work units).
- **Revisit criterion:** If the user reverses the commit-as-you-go directive, or if a skill edit is found to depend on
  another skill edit (they are independent today).
- **Dissent (if any):** —
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Decomposition and Sequencing

### D-2: Two frozen canonical snippets for drift control

- **Question:** How is the readability-integration text kept consistent across seven near-identical skill edits?
- **Decision:** Freeze two canonical snippets and reuse them verbatim. FULL = the guidance-source line plus the
  `han-communication:readability-editor` dispatch plus the six-point self-check, taken from `investigate` Step 5.
  LIGHTWEIGHT = the guidance-source line plus the six-point self-check, explicitly no editor, with the guidance line
  matching `issue-triage:30`. Vary only two named slots per skill: the D5 named reader and the excluded citation-ID
  tokens. A post-edit grep is the consistency gate.
- **Rationale:** Seven near-identical edits invite wording drift. Freezing the snippet and varying only two named slots
  keeps the integrations consistent and greppable, and keeps the canonical pattern (D1) intact across the suite.
- **Evidence:** junior-developer R1 drift-control finding; `han-coding/skills/investigate/SKILL.md` Step 5 (FULL
  reference); `han-core/skills/issue-triage/SKILL.md:30` (LIGHTWEIGHT guidance line); spec
  [D1](decision-log.md#d1-canonical-integration-pattern), [D5](decision-log.md#d5-per-skill-scope-and-named-audience).
- **Rejected alternatives:**
  - Hand-write each of the seven independently — rejected because it drifts across files and leaves no greppable
    invariant.
  - Vendor a shared snippet file into the skills — rejected because it violates the single-canonical-source convention;
    the canonical source is `readability-guidance`, which the snippet invokes rather than copies.
- **Specialist owner:** han-core:project-manager.
- **Revisit criterion:** If a target skill's workflow cannot host the frozen snippet verbatim and needs a structural
  variant.
- **Dissent (if any):** —
- **Driven by rounds:** R1
- **Dependent decisions:** D-4
- **Referenced in plan:** Implementation Approach, Testing Strategy

### D-3: Author via han-plugin-builder Guidance Mode, not the builders or guidance init

- **Question:** CLAUDE.md mandates that authoring go through han-plugin-builder guidance — which path applies to editing
  existing skills and one manifest?
- **Decision:** Consult the han-plugin-builder guidance docs directly (Guidance Mode). Do not run `skill-builder` or
  `agent-builder` (build-from-scratch), and do not run `guidance init` (vendors the builder skills). Docs to consult:
  `skill-building-guidance/skill-composition.md`, `agent-dispatch-namespacing.md`, `writing-effective-instructions.md`,
  and `claude-marketplace-and-plugin-configuration/` for the `plugin.json` edit.
- **Rationale:** These are edits to existing skills plus one manifest, not new artifacts, so the interview-driven
  builders do not fit. `guidance init` vendors the builder skills into a repo's `.claude/skills/`, which this work does
  not need.
- **Evidence:** CLAUDE.md "Creating skills, agents, or other plugin aspects" mandate; junior-developer R1 process
  finding (the four named guidance docs confirmed to exist).
- **Rejected alternatives:**
  - `skill-builder` / `agent-builder` — rejected because they build artifacts from scratch, the wrong tool for editing
    existing skills.
  - `guidance init` — rejected because it vendors builder skills into the repo, which is unnecessary machinery here.
- **Specialist owner:** han-core:project-manager.
- **Revisit criterion:** If any edit turns out to require a new skill or agent rather than editing an existing one.
- **Dissent (if any):** —
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Implementation Approach, Specialist Handoffs for Implementation

### D-4: Verification is a grep/jq acceptance checklist plus one smoke run

- **Question:** How is "done" verified when no behavior test harness exists?
- **Decision:** A deterministic grep/jq acceptance checklist (items T1-T17) over the edited files, plus one
  representative smoke run — one full-pattern skill and one lightweight skill. `plugin.json` gets free JSON validation
  from the existing prek/Prettier lint; Markdown stays deliberately unlinted.
- **Rationale:** No behavior test runner exists for skills. Consistency across the frozen snippets (D-2) is checkable by
  grep, JSON validity by the existing lint, and one smoke run confirms the integrated steps actually fire without
  dry-running all seven.
- **Evidence:** test-engineer R1 (checklist items T1-T17, deferrals S1 and S2); `.discovery-notes.md` "Gaps / not
  found" (no automated harness); `.pre-commit-config.yaml` (JSON lint via prek/Prettier).
- **Rejected alternatives:**
  - Dry-run all seven skills end to end (S1) — rejected because it adds cost without signal beyond the grep checklist
    plus one smoke run.
  - Build a prose-lint tool (S2) — rejected as single-use tooling with no evidence forcing it now (YAGNI).
- **Specialist owner:** han-core:test-engineer.
- **Revisit criterion:** If grep proves insufficient to catch a class of drift the checklist misses.
- **Dissent (if any):** —
- **Driven by rounds:** R1
- **Dependent decisions:** —
- **Referenced in plan:** Testing Strategy, Definition of Done

### D-5: plugin.json dependency order and no version bump

- **Question:** Exactly how is `han-planning`'s `plugin.json` edited?
- **Decision:** Change `dependencies` from `["han-core"]` to `["han-communication", "han-core"]`, matching
  `han-coding`'s order (`han-communication` first). Do not bump the version (stays `2.0.4`). No `han` meta-plugin or
  marketplace change, because `han-planning` is already bundled and declared.
- **Rationale:** The convention lists `han-communication` first, matching the sibling `han-coding` manifest. Repo memory
  forbids unprompted version bumps. The meta-plugin already bundles `han-planning`, so no wider manifest edit is needed.
- **Evidence:** spec [D4](decision-log.md#d4-han-planning-gains-a-direct-han-communication-dependency);
  `han-coding/.claude-plugin/plugin.json` (`["han-communication", "han-core"]`);
  `han-planning/.claude-plugin/plugin.json` lines 4-5 (`"version": "2.0.4"`, `"dependencies": ["han-core"]`); repo
  memory "never bump version unprompted"; R1 evidence-check (meta-plugin and marketplace need no change).
- **Rejected alternatives:**
  - Append `han-communication` after `han-core` — rejected because it breaks the ordering convention set by
    `han-coding`.
  - Bump the version — rejected because repo memory forbids unprompted bumps.
  - Edit the meta-plugin or marketplace manifest — rejected because `han-planning` is already bundled and declared
    there.
- **Specialist owner:** han-core:project-manager.
- **Revisit criterion:** If the user directs a version bump, or a release cut requires one.
- **Dissent (if any):** —
- **Driven by rounds:** R1
- **Dependent decisions:** D-1
- **Referenced in plan:** Implementation Approach, Decomposition and Sequencing

### D-6: The readability-guidance scope restatement is new text

- **Question:** What does the D9 "echo in `readability-guidance`" edit actually do?
- **Decision:** Add a brief restatement of the clarified reader-facing scope test to
  `readability-guidance/SKILL.md`'s own instructions. The skill carries no such restatement today (only an audience
  frame at Step 2), so this is additive new text, not an edit to an existing summary, and it must agree with the
  clarified `readability-rule.md` lines 20-23 scope text.
- **Rationale:** Review finding F13 confirmed there is no existing scope summary to echo into. The deliverable is
  therefore additive, and the two surfaces (canonical rule and guidance skill) must not disagree.
- **Evidence:** spec [D9](decision-log.md#d9-reader-facing-scope-reconciliation); review finding F13
  ([review-findings.md](review-findings.md)); `han-communication/skills/readability-guidance/SKILL.md` (no reader-facing
  scope restatement present today).
- **Rejected alternatives:**
  - Edit an existing scope summary in the guidance skill — rejected because none exists (F13).
  - Clarify only the canonical rule and skip `readability-guidance` — rejected by user direction (D9): a caller sees the
    guidance summary in context, and the two surfaces must agree.
- **Specialist owner:** han-core:project-manager.
- **Revisit criterion:** If the `readability-rule.md` scope wording changes after this lands, the restatement must be
  kept in sync.
- **Dissent (if any):** —
- **Driven by rounds:** R1
- **Dependent decisions:** D-1
- **Referenced in plan:** Implementation Approach, Decomposition and Sequencing

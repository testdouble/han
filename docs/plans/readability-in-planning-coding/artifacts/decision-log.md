# Decision Log: Readability Standard in the Planning and Coding Skills

Decisions behind [../feature-specification.md](../feature-specification.md). Each full decision records its outcome,
rationale, evidence, and the alternatives a reasonable engineer would have weighed.

## Full decisions

### D1: Canonical integration pattern

- **Decision:** Each target skill sources `han-communication:readability-guidance` from instruction text, drafts in
  voice, and runs the standardized six-point self-check before presenting. This is the same pattern the already-integrated
  skills use.
- **Rationale:** The pattern is established and canonical, so copying it keeps all integrated skills consistent and lets
  the standard evolve in one place. Inventing a new pattern would fragment the suite.
- **Evidence:** (codebase) The integrated skills `investigate`, `issue-triage`, `update-pr-description`,
  `stakeholder-summary`, `research`, and others all follow this shape. The canonical rule lives in
  `han-communication/skills/readability-guidance/SKILL.md` (Step 3, "Apply the standard in stages").
- **Rejected alternatives:** Vendor the readability rule text into each skill — rejected because it violates the
  suite's single-canonical-source convention and would drift.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Outcome, Primary Flow
- **Dependent decisions:** D2, D3, D7

### D2: Synthesis-rule split for the editor pass

- **Decision:** Five skills (`plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, `coding-standard`,
  `test-planning`) get the full pattern, which adds a `han-communication:readability-editor` agent pass. Two skills
  (`plan-work-items`, `iterative-plan-review`) get the lightweight pattern: guidance plus self-check, no editor pass.
- **Rationale:** The canonical rule reserves the adversarial rewrite pass for synthesis output. The five full-pattern
  skills each synthesize a substantial authored deliverable from an agent-team or project-manager pass; the two
  lightweight skills transform or iterate on already-structured content, where a per-item or per-iteration editor
  dispatch would be heavy for little gain. The self-check still runs everywhere as the mandatory fidelity floor.
- **Evidence:** (codebase) `readability-guidance/SKILL.md` line 52: "If your workflow is a synthesis skill, dispatch
  `han-communication:readability-editor` for the adversarial rewrite after your full draft exists, as the standard
  reserves that pass for synthesis output." Integrated synthesis skills (`research`, `project-documentation`,
  `investigate`) dispatch the editor; templated or structured skills (`issue-triage`, `runbook`, `html-summary`) run
  self-check only.
- **Rejected alternatives:** Full pattern for all seven — rejected because it dispatches a heavy agent pass on
  structured and iterative skills against the standard's own guidance. Lightweight for all seven — rejected because the
  five synthesizers would lose the rewrite the standard reserves for them.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States
- **Dependent decisions:** D5, D6

### D3: Prose-regions-only scope and fact fidelity

- **Decision:** The readability work (both the editor pass and the self-check) operates on prose regions only and never
  inside code fences, tables, diagram bodies, function signatures, or citation identifiers. Every fact, quantity, named
  entity, stated qualifier, and cross-reference identifier survives unchanged.
- **Rationale:** These skills produce deliverables dense with load-bearing identifiers (file:line citations, D#/T#/F#
  cross-references, work-item IDs). Rewriting inside them would break references or corrupt facts. Fidelity is the
  point of the deliverable; readability governs only how the prose is said.
- **Evidence:** (codebase) Every integrated skill scopes its readability pass to "prose regions only," and the
  `readability-editor` agent definition (`han-communication/agents/readability-editor.md`) already leaves code fences,
  diagram bodies, and citation identifiers byte-for-byte unchanged.
- **Rejected alternatives:** Let the editor rewrite the whole document — rejected because it would rewrite citation
  identifiers and structured tables.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes
- **Dependent decisions:** D5

### D5: Per-skill scope and named audience

- **Decision:** Each skill's readability step names the specific prose regions it covers and the specific audience it
  holds while applying the standard. The audience per skill: `plan-a-feature` and `plan-a-phased-build` hold the
  stakeholder or reviewer reading the plan; `plan-implementation`, `plan-work-items`, and `test-planning` hold the
  engineer who will build or test; `coding-standard` holds the engineer who must follow the standard;
  `iterative-plan-review` holds the reader of the plan it refines.
- **Rationale:** The integrated skills all pass a named audience to the editor and self-check so the standard is applied
  for a concrete reader rather than in the abstract. Naming the covered regions keeps structured companion files out of
  scope.
- **Evidence:** (codebase) `investigate` names "the engineer who will implement the fix and may be paged on the bug";
  `update-pr-description` names "the reviewer evaluating the pull request." Each target skill's own description states
  its deliverable and reader.
- **Rejected alternatives:** A single generic audience for all seven — rejected because the standard is audience-scoped
  and the seven deliverables have different readers.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes
- **Dependent decisions:** —

### D6: Readability pass runs after the final synthesis step

- **Decision:** In skills that end with a synthesis step owning final content (notably `plan-a-feature`'s
  project-manager synthesis), the readability pass runs after that step produces the final content and before the
  deliverable is presented.
- **Rationale:** The readability pass governs how final content reads. Running it before an authoritative later step
  would let that step reintroduce voice violations. Ordering it last, before presentation, matches how `investigate`
  places its editor pass after adversarial validation.
- **Evidence:** (codebase) `investigate/SKILL.md` Step 5 runs the editor pass after the Step 4 validation, "separate
  from the adversarial-validator pass." `plan-a-feature` Step 8 hands final synthesis to the project-manager.
- **Rejected alternatives:** Run the readability pass inside the synthesis step — rejected because the synthesis agent
  owns content decisions, not voice, and coupling the two muddies both.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Edge Cases and Failure Modes
- **Dependent decisions:** —

### D7: Reference the single canonical standard, never vendor it

- **Decision:** The seven skills reach the standard only through `han-communication:readability-guidance`; they never
  copy the rule text or the writing-voice profile into themselves.
- **Rationale:** The suite keeps one canonical source per concept. A change to the standard must reach all consumers
  without editing them.
- **Evidence:** (codebase) CLAUDE.md: "Single canonical copy in the foundational `han-communication` plugin; no
  vendored copies. Consuming skills source it cross-plugin by invoking `han-communication:readability-guidance`."
- **Rejected alternatives:** Vendor a copy per plugin for offline resilience — rejected as a direct violation of the
  single-canonical-source convention.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Coordinations
- **Dependent decisions:** —

### D8: Scope is exactly these seven skills

- **Decision:** This feature integrates the standard into exactly the seven named skills. It excludes already-integrated
  skills, non-prose skills, and skills that inherit prose from an upstream source.
- **Rationale:** A prior survey classified all 38 skills. The seven are the only ones that author user-facing prose and
  lack the standard. The publishing wrappers (Confluence, Jira, GitHub, Linear, work-items publishers) inherit their
  prose from upstream skills, so their gaps close when the upstream skill is integrated rather than by editing the
  wrapper.
- **Evidence:** (provided) The survey earlier in this session enumerated the integrated set (15 skills), the direct
  gaps (these 7), the inherited gaps, and the not-applicable skills.
- **Rejected alternatives:** Also edit the publishing wrappers — rejected because they transform prose an integrated
  upstream skill authored, so editing them would duplicate the pass.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Out of Scope
- **Dependent decisions:** —

## Trivial decisions

- **D4:** No tooling or dependency changes needed — the integrated skills invoke `readability-guidance` from
  instruction text with no `Skill` tool grant, and all seven target skills already grant the `Agent` tool the editor
  pass uses; every target plugin's dependency chain already reaches `han-communication` (verified against the integrated
  skills' frontmatter, none of which grant `Skill`). — Referenced in spec: Actors and Triggers.

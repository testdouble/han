# Decision Log: Readability Standard in the Planning and Coding Skills

Decisions behind [../feature-specification.md](../feature-specification.md). Each full decision records its outcome,
rationale, evidence, and the alternatives a reasonable engineer would have weighed.

## Full decisions

### D1: Canonical integration pattern

- **Decision:** Each target skill sources `han-communication:readability-guidance` from instruction text, drafts its own
  prose in voice, and runs the standardized six-point self-check before presenting. This is the same pattern the
  already-integrated skills use.
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

### D2: Prose-document vs structured-artifact split for the editor pass

- **Decision:** Five skills (`plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, `coding-standard`,
  `test-planning`) get the full pattern, which adds a `han-communication:readability-editor` agent pass. Two skills
  (`plan-work-items`, `iterative-plan-review`) get the lightweight pattern: guidance plus self-check, no editor pass.
- **Rationale:** The split is by deliverable type, not by whether the skill runs an agent pass. The five full-pattern
  skills produce a prose-heavy document a reader works through end to end, where an adversarial rewrite earns its cost.
  The two lightweight skills produce an itemized or in-place-edited artifact (`plan-work-items` emits a structured list
  of atomic items; `iterative-plan-review` edits an existing plan across iterations), where a whole-document editor pass
  would churn structured content or re-edit already-approved prose for little gain. The self-check still runs everywhere
  as the mandatory fidelity floor. This framing is chosen deliberately because the alternative test — "does the skill
  run a project-manager or agent pass?" — misclassifies: `plan-work-items` runs a project-manager synthesis yet stays
  lightweight, and three of the five full-pattern skills self-author their draft and dispatch only a review agent.
- **Evidence:** (codebase) `readability-guidance/SKILL.md` line 52 reserves the rewrite pass for "synthesis output";
  integrated prose-document skills (`research`, `project-documentation`, `investigate`) dispatch the editor, while
  itemized or templated skills (`issue-triage`, `html-summary`) run self-check only. `plan-work-items/SKILL.md` Step 5
  dispatches `han-core:project-manager` yet its deliverable is a structured work-items list.
- **Rejected alternatives:** Classify by "runs an agent/PM synthesis pass" — rejected because it misclassifies
  `plan-work-items` (F3). Full pattern for all seven — rejected because it dispatches a heavy agent pass on structured
  and in-place skills. Lightweight for all seven — rejected because the five prose-document skills would lose the
  rewrite the standard reserves for reader-facing documents.
- **Driven by findings:** F3
- **Linked technical notes:** —
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States
- **Dependent decisions:** D5, D6

### D3: Prose-regions-only scope and fact fidelity

- **Decision:** The readability work (both the editor pass and the self-check) operates on prose regions only and never
  inside code fences, tables, diagram bodies, frontmatter, or citation identifiers. Every fact, quantity, named entity,
  stated qualifier, and cross-reference identifier survives unchanged.
- **Rationale:** These skills produce deliverables dense with load-bearing identifiers (file:line citations, D#/T#/F#
  cross-references, work-item IDs, YAML frontmatter). Rewriting inside them would break references or corrupt facts.
  Fidelity is the point of the deliverable; readability governs only how the prose is said.
- **Evidence:** (codebase) Every integrated skill scopes its readability pass to "prose regions only," and the
  `readability-editor` agent definition (`han-communication/agents/readability-editor.md`) already leaves code fences,
  diagram bodies, and citation identifiers unchanged.
- **Rejected alternatives:** Let the editor rewrite the whole document — rejected because it would rewrite citation
  identifiers, structured tables, and frontmatter.
- **Driven by findings:** F8
- **Linked technical notes:** —
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes
- **Dependent decisions:** D5

### D4: han-planning gains a direct han-communication dependency

- **Decision:** Add `han-communication` to `han-planning`'s plugin dependencies. `han-coding` already declares it. No
  tool grants change, because every target skill already grants the `Agent` tool the editor pass uses, and the
  integrated skills invoke `readability-guidance` from instruction text with no `Skill` tool grant.
- **Rationale:** `han-planning` currently declares only `han-core`, reaching `han-communication` transitively. Every
  plugin whose skills successfully invoke `readability-guidance` today (`han-core`, `han-coding`, `han-github`,
  `han-reporting`) declares `han-communication` directly. Han's own convention requires every prose-producing plugin to
  depend on `han-communication` directly, and `han-planning` was absent from that list. Adding the direct dependency
  both follows the convention and removes the risk that a transitive-only chain fails to resolve the sibling skill and
  agent at runtime.
- **Evidence:** (codebase) `han-planning/.claude-plugin/plugin.json` declares `"dependencies": ["han-core"]`;
  `han-coding/.claude-plugin/plugin.json` declares `["han-communication", "han-core"]`;
  `han-core/.claude-plugin/plugin.json` declares `["han-communication"]`. CLAUDE.md names `han-core`, `han-coding`,
  `han-github`, `han-reporting`, and `han-atlassian` as direct `han-communication` dependents and omits `han-planning`.
- **Rejected alternatives:** Rely on the transitive chain and change nothing — rejected because it contradicts the
  stated convention and leaves the runtime resolution untested for the five planning skills.
- **Driven by findings:** F2
- **Linked technical notes:** —
- **Referenced in spec:** Actors and Triggers
- **Dependent decisions:** —

### D5: Per-skill scope and named audience

- **Decision:** Each skill's readability step names the prose regions it covers and the reader it holds while applying
  the standard. Coverage is the prose the skill authors or changes this run, not pre-existing prose it leaves untouched.
  For in-place editing (`iterative-plan-review`; `coding-standard` update mode), the pass runs on the changed regions of
  the converged document. The reader per skill: `plan-a-feature` holds the stakeholder or reviewer reading the spec;
  `plan-a-phased-build` holds the per-run audience it already asks the user for (engineering, mixed, or customer-facing);
  `plan-implementation`, `plan-work-items`, and `test-planning` hold the engineer who will build or test;
  `coding-standard` holds the engineer who must follow the standard; `iterative-plan-review` holds the reader of the
  plan it refines.
- **Rationale:** The integrated skills all pass a named reader to the editor and self-check so the standard is applied
  for a concrete audience rather than in the abstract. Scoping coverage to authored-or-changed regions keeps structured
  companion files and untouched prose out of the pass, and prevents an in-place skill from re-editing prose another
  skill already approved.
- **Evidence:** (codebase) `investigate` names "the engineer who will implement the fix and may be paged on the bug";
  `update-pr-description` names "the reviewer evaluating the pull request." `plan-a-phased-build/SKILL.md` already
  collects an audience choice per run. `iterative-plan-review/SKILL.md` and `coding-standard/SKILL.md` both edit
  existing documents in place.
- **Rejected alternatives:** A single generic audience for all seven — rejected because the deliverables have different
  readers. Whole-document coverage for in-place skills — rejected because it re-checks and may re-edit prose the run did
  not touch (F5).
- **Driven by findings:** F5, F7, F9
- **Linked technical notes:** —
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes
- **Dependent decisions:** —

### D6: Readability pass runs after the final content exists

- **Decision:** The readability pass (editor for the five prose-document skills, self-check for all seven) runs after
  the skill's final content-producing step completes — including any project-manager synthesis, review, or IA step the
  skill already runs near the end — and before the deliverable is presented.
- **Rationale:** The readability pass governs how final content reads. When a dispatched agent authors the final content
  (for example `plan-a-feature`'s project-manager synthesis or `plan-work-items`'s project-manager pass), the standard
  is in the skill's context, not the agent's, so "draft in voice" alone cannot carry voice into agent-authored content.
  The after-the-fact pass is the lever that does. Running it before an authoritative later step would let that step
  reintroduce voice violations, so it runs last, before presentation, matching how `investigate` places its editor pass
  after adversarial validation.
- **Evidence:** (codebase) `investigate/SKILL.md` Step 5 runs the editor pass after Step 4 validation, "separate from
  the adversarial-validator pass." `plan-a-feature` Step 8 hands final synthesis to `han-core:project-manager`;
  `plan-work-items` Step 5 returns the project-manager's output; `plan-a-phased-build`, `coding-standard`, and
  `test-planning` each run review or IA steps before presenting.
- **Rejected alternatives:** Run the readability pass inside or before the synthesis/review step — rejected because that
  agent owns content decisions, not voice, and a later authoritative step would undo the readability work.
- **Driven by findings:** F4, F6
- **Linked technical notes:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes
- **Dependent decisions:** —

### D7: Reference the single canonical standard, never vendor it

- **Decision:** The seven skills reach the standard only through `han-communication:readability-guidance`; they never
  copy the rule text or the writing-voice profile into themselves. The D9 scope-text clarification edits the one
  canonical `readability-rule.md`, not any copy.
- **Rationale:** The suite keeps one canonical source per concept. A change to the standard must reach all consumers
  without editing them.
- **Evidence:** (codebase) CLAUDE.md: "Single canonical copy in the foundational `han-communication` plugin; no
  vendored copies. Consuming skills source it cross-plugin by invoking `han-communication:readability-guidance`."
- **Rejected alternatives:** Vendor a copy per plugin for offline resilience — rejected as a direct violation of the
  single-canonical-source convention.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Referenced in spec:** Coordinations
- **Dependent decisions:** D9

### D8: Scope is exactly these seven skills

- **Decision:** This feature integrates the standard into exactly the seven named skills. It excludes already-integrated
  skills, non-prose skills, and skills that inherit prose from an upstream source.
- **Rationale:** A survey classified all 38 skills in the suite. Fifteen already integrate the standard. Two produce
  code, not prose (`tdd`, `refactor`). The publishing wrappers and work-items publishers transform or republish prose an
  upstream skill authored, so their gaps close when the upstream skill is integrated; `markdown-to-confluence`
  republishes user prose verbatim and authors none. That leaves these seven as the only skills that author reader-facing
  prose and lack the standard.
- **Evidence:** (provided) The 38-skill classification produced earlier in this session, recorded here so scope is
  auditable: integrated (15) — `architectural-analysis`, `code-overview`, `code-review`, `investigate`,
  `edit-for-readability`, `readability-guidance`, `architectural-decision-record`, `gap-analysis`, `issue-triage`,
  `project-documentation`, `research`, `runbook`, `update-pr-description`, `html-summary`, `stakeholder-summary`; direct
  gaps (these 7); inherited gaps (the Confluence, Jira, GitHub, Linear publishers); not applicable (`tdd`, `refactor`,
  `markdown-to-confluence`, `project-discovery`, and the plugin-builder authoring skills).
- **Rejected alternatives:** Also edit the publishing wrappers — rejected because they transform prose an integrated
  upstream skill authored, so editing them would duplicate the pass.
- **Driven by findings:** F10, F11
- **Linked technical notes:** —
- **Referenced in spec:** Out of Scope
- **Dependent decisions:** —

### D9: Reader-facing scope reconciliation

- **Decision:** Keep all seven skills in scope, and add a narrow clarification to `readability-rule.md`'s "who reads
  reader-facing output" section so it distinguishes a plan-of-record or standard a human reads end to end (reader-facing,
  applies the rule) from a pure pipeline artifact consumed only by downstream skills (not reader-facing). Add the same
  clarified scope test to the `readability-guidance` skill's own instructions: today that skill surfaces the reader-facing
  scope only by having the caller read the canonical rule and carries no restatement of its own, so this work adds a brief
  restatement, giving a caller the clarified test in context. The rules the standard enforces do not change; only the
  scope text is clarified, in both places.
- **Rationale:** As written, the scope text excludes "a structured specification / plan / work-item / standard consumed
  mainly by downstream skills," and all seven targets produce those artifact types. Left unreconciled, the standard's own
  text would read as excluding the very skills this feature integrates, inviting a future contributor to remove the
  integration. In Han's actual use, a solo product engineer and their stakeholders read these deliverables end to end (a
  phased build is explicitly plain-language for demoing to real users; a coding standard is a document engineers follow;
  a spec is read for approval), and already-integrated skills such as `issue-triage`, `gap-analysis`, and
  `project-documentation` set the precedent that Han treats structured documents as reader-facing. Clarifying the text
  keeps the standard internally consistent with that intent.
- **Evidence:** (codebase) `readability-rule.md` lines 20-23 define the carve-out. (codebase)
  `readability-guidance/SKILL.md` carries an audience frame but no restatement of the reader-facing scope test — it
  surfaces that test only by having the caller read the canonical rule (confirmed in review, F13). (user) The user chose
  to keep all seven and clarify the rule rather than narrow scope or leave the text unchanged, and directed that the
  clarification also appear in `readability-guidance`, not only the canonical rule.
- **Rejected alternatives:** Keep seven but leave the rule text unchanged — rejected because the text still reads as
  excluding these skills and would drift. Narrow scope to only the clearly human-read outputs — rejected because the
  user judges all seven reader-facing in Han's use. Clarify only the canonical rule and leave `readability-guidance`'s
  in-context summary unchanged — rejected by user direction, because a caller sees the guidance summary in context and
  the two surfaces must not disagree.
- **Driven by findings:** F1; F13 (wording accuracy for the guidance-skill edit); user direction (also clarify in
  `readability-guidance`)
- **Linked technical notes:** —
- **Referenced in spec:** Outcome, Coordinations, Open Items
- **Dependent decisions:** —

## Trivial decisions

<!-- None. D4, formerly trivial, became a full decision when review surfaced the transitive-dependency gap (F2). -->

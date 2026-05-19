# Decision Log: `/research` skill

This file records every decision settled while specifying the `/research`
skill. Behavioral statements live in
[../feature-specification.md](../feature-specification.md). The investigation
that decided `/research` should exist at all is
[../recommendation.md](../recommendation.md), backed by
[01](./01-investigate-skill-analysis.md), [02](./02-skill-taxonomy-guidance.md),
[03](./03-precedent-and-cost.md), and [04](./04-adversarial-validation.md).

No `feature-technical-notes.md` was created: every load-bearing mechanic is
either stated behaviorally in the spec or discoverable from the repo (the
`/investigate` analog, `docs/sizing.md`, and existing agent definitions).

## Trivial decisions

- D12: Slash command name — the skill is invoked as `/research`, per the user's request. — Referenced in spec: title, Actors and Triggers, User Interactions.
- D13: Durable report output — `/research` writes a report file, matching the `/investigate` analog where the investigation is written to a plan file rather than only answered in channel. — Referenced in spec: Outcome, Primary Flow.
- D14: Invocation surface — `/research <question> [output path]`, mirroring `/investigate`'s invocation shape. — Referenced in spec: User Interactions, Primary Flow.

## Full decisions

### D1: Skill purpose and output shape

- **Question:** What is `/research`, and what does it produce?
- **Decision:** A skill that takes an open-ended question (options, prior art, trade-offs, "how does X work") and produces a research report: framed question, numbered evidence, an options landscape with trade-offs, a recommended option, and adversarial-validation findings.
- **Rationale:** The source investigation established that research is a structurally distinct process from investigation — it starts from a question and ends at a recommended option among trade-offs, not from a symptom ending at a fix.
- **Evidence:** [../recommendation.md](../recommendation.md) Plain-language summary and Final recommendation; [01](./01-investigate-skill-analysis.md) E2–E5.
- **Rejected alternatives:**
  - Expand `/investigate` to cover research — rejected because it violates Han's single-responsibility rule ([../recommendation.md](../recommendation.md) Option B).
  - Two-mode "deep-dive" skill — rejected for the same reason ([../recommendation.md](../recommendation.md) Option C).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D6, D10
- **Referenced in spec:** Actors and Triggers

### D2: Scope boundary and bidirectional routing

- **Question:** What does `/research` explicitly not do, and how does it disambiguate from its neighbors?
- **Decision:** `/research` is scoped to open-ended, output-agnostic research only. It explicitly does not specify features, set standards, compare two concrete artifacts, assess module architecture, or diagnose bugs, and its description names each of those siblings; the siblings name `/research` back.
- **Rationale:** The single largest risk the investigation surfaced is trigger collision with adjacent skills; the only mechanism Han has for it is bidirectional "Does not X — use Y" routing, used by all existing skills.
- **Evidence:** [../recommendation.md](../recommendation.md) Final recommendation constraint 2; [02](./02-skill-taxonomy-guidance.md) E11; `docs/guidance/skill-building-guidance/skill-description-frontmatter.md` ("Disambiguation must work in both directions").
- **Rejected alternatives:**
  - Broad research description with no sibling routing — rejected because it collides with `plan-a-feature`, `coding-standard`, `gap-analysis`, and `architectural-analysis` ([../recommendation.md](../recommendation.md) Option A row 6; [04](./04-adversarial-validation.md) V7).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D8, D9, D10
- **Referenced in spec:** Actors and Triggers, Primary Flow, Out of Scope

### D3: Research reach

- **Question:** How far should `/research` reach for information — codebase only, codebase plus provided material, or also the open web?
- **Decision:** `/research` reaches the codebase, the open web, and any operator-provided material. A codebase is optional; pure external idea research works outside a repository.
- **Rationale:** The user explicitly framed `/research` as covering "ideas, possible solutions, and other info that sits outside" `/investigate`'s codebase-only focus; web reach is the differentiator that makes the skill non-duplicative.
- **Evidence:** User input (research-reach question, this conversation); `/investigate` is deliberately codebase-only (`plugin/skills/investigate/SKILL.md` allowed-tools); [../recommendation.md](../recommendation.md) Final recommendation constraint 1.
- **Rejected alternatives:**
  - Codebase only — rejected because it largely duplicates `/investigate`'s reach and undercuts the skill's purpose (user input).
  - Codebase plus provided material, no live web — rejected because it cannot answer "what is the prior art out there" (user input).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D4
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes, Coordinations

### D4: Agent roster

- **Question:** Should `/research` add a new agent for open-ended research, reuse existing agents with reframed briefs, or defer the choice to implementation?
- **Decision:** Add one new dedicated research agent for the open-ended / idea-space posture, and reuse `codebase-explorer` (codebase angle), `gap-analyzer` (option comparison), and `adversarial-validator` (challenge the recommendation).
- **Rationale:** No existing agent is scoped to idea-space research; `evidence-based-investigator` is bug-vocabulary and `codebase-explorer` is documentation-oriented, so reuse-only accepts a quality-degrading vocabulary mismatch. `adversarial-validator` already works on recommendations, proven by the source investigation itself.
- **Evidence:** User input (agent-roster question, this conversation); [03](./03-precedent-and-cost.md) E13; [../recommendation.md](../recommendation.md) Final recommendation constraint 4; [04](./04-adversarial-validation.md) V9 (validator works on non-bug recommendations).
- **Rejected alternatives:**
  - Reuse existing agents with reframed briefs only — rejected because it accepts the bug-vocabulary mismatch flagged as a quality risk (user input).
  - Defer the agent decision to `plan-implementation` — rejected because the roster materially shapes the skill's behavior and the user chose to settle it now (user input).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Coordinations

### D5: Team-size model

- **Question:** Should `/research` use a fixed roster like `/investigate`, or scale its team with Han's small/medium/large sizing model?
- **Decision:** `/research` scales its research team with Han's small/medium/large sizing model, becoming Han's 7th sized skill.
- **Rationale:** The user chose research breadth that scales with question scope over a fixed roster.
- **Evidence:** User input (team-sizing question, this conversation); Han's sizing model is documented at `docs/sizing.md` and used by the six existing swarming skills.
- **Rejected alternatives:**
  - Fixed roster like `/investigate` (parallel researchers + one validation pass, no tiers) — rejected by the user in favor of scope-scaled breadth, despite being the simpler YAGNI default.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions, Open Items

### D6: Workflow spine

- **Question:** What is the ordered workflow of `/research`?
- **Decision:** Research → consolidated numbered evidence (E#) → options landscape with trade-offs → recommended option (or explicit "no clear winner" with deciding criteria) → adversarial-validation pass (V#) → write report → present for review. No bug classification, no root-cause step, no fix-planning step.
- **Rationale:** The spine mirrors `/investigate`'s proven evidence→numbering→validation scaffold but is question-shaped, not symptom-shaped; every bug-specific stage is removed because research has a different terminus.
- **Evidence:** [../recommendation.md](../recommendation.md) Plain-language summary; [01](./01-investigate-skill-analysis.md) E2–E5, E10; `plugin/skills/investigate/SKILL.md` (analog spine).
- **Rejected alternatives:**
  - Reuse `/investigate`'s bug-shaped steps verbatim — rejected because "classify the bug", "root cause", and "plan the fix" have no analog in research ([01](./01-investigate-skill-analysis.md) E3–E5).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D7
- **Referenced in spec:** Outcome, Primary Flow, Alternate Flows and States

### D7: Adversarial-validation target

- **Question:** What does the adversarial-validation pass attack in a research run?
- **Decision:** It attacks the evidence, the way the options were framed, and the recommendation itself — not a "fix".
- **Rationale:** Research has no fix to break; `adversarial-validator` already operates on evidence-plus-recommendation structures, demonstrated by the source investigation, which validated this very recommendation.
- **Evidence:** [04](./04-adversarial-validation.md) V9; [../recommendation.md](../recommendation.md) Validation outcome section.
- **Rejected alternatives:**
  - Skip adversarial validation for research — rejected because adversarial validation is the quality differentiator carried over from `/investigate` and the user's framing called for research "similar to" `/investigate`.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D8: Out-of-scope redirect behavior

- **Question:** What does `/research` do when the request is actually a sibling skill's concern?
- **Decision:** It names the correct sibling skill, explains in one sentence why that skill fits better, and stops without running the research pipeline.
- **Rationale:** Han's house style routes between skills explicitly; proceeding on an out-of-scope request would produce the wrong artifact and erode triggering trust.
- **Evidence:** [../recommendation.md](../recommendation.md) Final recommendation constraints 1–2; [02](./02-skill-taxonomy-guidance.md) E11.
- **Rejected alternatives:**
  - Attempt the research anyway and append a "you may also want skill X" note — rejected because it still produces a partial wrong-shaped result.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, User Interactions

### D9: Reciprocal-routing coordination

- **Question:** What must be true of the neighbor skills for `/research` to route correctly?
- **Decision:** Releasing `/research` requires `investigate`, `plan-a-feature`, `coding-standard`, `gap-analysis`, and `architectural-analysis` to each carry a reciprocal boundary statement pointing research-shaped requests back to `/research`. The exact file list is implementation detail.
- **Rationale:** One-way disambiguation leaves a gap requests fall through; the frontmatter guidance requires both directions.
- **Evidence:** `docs/guidance/skill-building-guidance/skill-description-frontmatter.md` ("Disambiguation must work in both directions"); [../recommendation.md](../recommendation.md) Final recommendation constraints 2–3.
- **Rejected alternatives:**
  - Only describe `/research`'s outward boundaries — rejected because siblings would still over-trigger on research requests ([04](./04-adversarial-validation.md) V7).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations, Out of Scope

### D10: Output-agnostic guarantee

- **Question:** May `/research` ever produce a sibling's artifact (a spec, a standard, a gap report, an architecture assessment)?
- **Decision:** No. `/research` produces a research report and only a research report. A request that mixes research with a sibling concern gets the research portion plus an explicit handoff naming the sibling.
- **Rationale:** Output-agnosticism is the anti-collision guarantee that keeps `/research` from duplicating four existing skills; the investigation narrowed the open slot specifically to output-agnostic research.
- **Evidence:** [../recommendation.md](../recommendation.md) Final recommendation constraint 1; [04](./04-adversarial-validation.md) V6.
- **Rejected alternatives:**
  - Let `/research` optionally emit a starter spec/standard — rejected because it recreates the trigger-collision and single-responsibility problems the investigation rejected.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Edge Cases and Failure Modes, Out of Scope

### D11: Verifiable evidence sourcing

- **Question:** What integrity requirement applies to evidence items?
- **Decision:** Every numbered evidence item carries a source the reader can independently check — a file path for codebase evidence, a source URL for web evidence. Unverifiable web claims are marked as such and cannot be the sole basis for the recommendation.
- **Rationale:** The skill's value is evidence-based, like `/investigate` whose E# items are file-anchored; web reach introduces unverifiable claims, so sourcing must be explicit to keep the report trustworthy.
- **Evidence:** `/investigate` analog (E# items keyed to file paths and line numbers, `plugin/skills/investigate/SKILL.md`); [../recommendation.md](../recommendation.md) emphasis on evidence-based output.
- **Rejected alternatives:**
  - Allow unsourced synthesized claims — rejected because it makes the report unfalsifiable and defeats the adversarial-validation step.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes, Coordinations

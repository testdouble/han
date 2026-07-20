# Decision Log: Per-Model Authoring Guidance

This file records the decisions settled while specifying the per-model authoring guidance reference. Behavioral statements live in [../feature-specification.md](../feature-specification.md); this file holds the history, rationale, evidence, and rejected alternatives.

The source research is [docs/research/model-specific-guidance-for-skills.md](../../../research/model-specific-guidance-for-skills.md), which recommended author-time guidance (its option O3) and is cited below as "the research."

## Trivial decisions

- D7: Models the guidance covers — Sonnet 5, Opus 4.8, and Fable 5, plus the model-agnostic default as the fallback for any other model. — Referenced in spec: Outcome, Alternate Flows and States.
- D8: Writing voice — the document follows the Han writing-voice profile like every other guidance reference (considered a looser doc style; rejected because the repo holds one voice standard). — Referenced in spec: (whole document).

## Full decisions

### D1: A new authoring-guidance reference, distinct from tier selection

- **Question:** Should per-model authoring guidance be a new reference, or an addition to the existing `specialization-and-model-selection.md`?
- **Decision:** A new, separate guidance reference about how to write instructions for a given model.
- **Rationale:** The existing document answers a different question, which model tier to run (opus, sonnet, haiku) based on how specialized the prompt is. This feature answers how to write instructions for a specific model generation at whatever tier. Mixing the two would blur both.
- **Evidence:** `han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md` is scoped to tier and effort selection (codebase). The research frames per-model prompting divergence as a separate concern from tier choice (the research).
- **Rejected alternatives:**
  - Extend `specialization-and-model-selection.md` — rejected because it would combine tier-choice reasoning with instruction-style reasoning in one document and make both harder to find and maintain.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D5
- **Referenced in spec:** Outcome

### D2: Focus the content on the high-impact differences

- **Question:** How much per-model detail should the document carry?
- **Decision:** Lead with the two differences that change an authoring decision (the opposite-direction instruction style, and the Fable 5 reasoning-echo refusal trap), and cover thinking mode and effort and subagent eagerness as short supporting notes. Do not mirror every axis of Anthropic's per-model pages.
- **Rationale:** The instruction-style split points an author in the wrong direction if they follow the wrong model's guidance, and the Fable 5 refusal trap is the one difference that can cause an outright failure rather than a style mismatch. The lighter axes were not shown to change an authoring decision, and a smaller document is cheaper to keep current against pages that get revised and archived.
- **Evidence:** the research (instruction-following runs in opposite directions across Opus 4.8 / Sonnet 5 and Fable 5; the Fable 5 refusal category is the one functional-failure risk; model pages are pinned snapshots that get archived). User input on the content-depth question.
- **Rejected alternatives:**
  - Comprehensive per-model sections mirroring the full pages (verbosity, design defaults, tokenizer, and so on) — rejected because the extra axes were not shown to change authoring decisions and enlarge the maintenance surface. Deferred, not dropped (see the spec's Deferred section).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D3: Author-time guidance that reaffirms the model-agnostic default

- **Question:** Should the guidance encourage any run-time adaptation to the active model?
- **Decision:** No. The guidance is author-time only. It states that shipped skills stay model-agnostic, that the model-agnostic form is the generalized fallback, and that run-time model detection and branching are out of scope and not reliable.
- **Rationale:** The research found no reliable way for a skill to learn its own model at run time (no environment variable, the skill model field sets rather than reads the model, self-report is unreliable), and that run-time variants break cross-host portability and multiply maintenance. Acting on the real model differences at authoring time avoids all of that.
- **Evidence:** the research (a skill cannot reliably learn which model is running it; the reject-run-time-branching conclusion is over-determined). Han's current skills already carry no model field and reference everything model-neutrally (`han-core/skills/*/SKILL.md`, codebase).
- **Rejected alternatives:**
  - Guidance that endorses inline "if running on model X" branches or per-model variants — rejected because the detection those depend on is unsound and the variants break portability.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D4: Surface through the guidance routing map, document only

- **Question:** How is the document surfaced to authors, and does this feature also change the interactive builders?
- **Decision:** Add one entry to the guidance skill's routing map pointing at the new reference, and place the reference alongside the other guidance references so the existing install and refresh carry it along. Do not change the skill-builder or agent-builder interviews.
- **Rationale:** Authors already reach every guidance document through the routing map, and the install and refresh step vendors the references wholesale, so a new reference needs no separate wiring beyond the map entry. Prompting for a target model inside the builders is a larger change across two more skills with no evidence yet that it is needed.
- **Evidence:** the guidance skill's Guidance Mode routing map lists reference groups and points authors to them (`han-plugin-builder/skills/guidance/SKILL.md`, codebase). The init and update modes vendor the `references/` directory wholesale (`han-plugin-builder/skills/guidance/SKILL.md`, codebase). User input on the scope-boundary question.
- **Rejected alternatives:**
  - Also add a target-model step to skill-builder and agent-builder — rejected as a larger surface with no evidence of need. Deferred, not dropped (see the spec's Deferred section).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Coordinations, Out of Scope

### D5: Cross-reference tier selection and cite the research as source

- **Question:** How does the new document relate to the tier-selection guidance and to the research it comes from?
- **Decision:** The document opens by stating its own scope, cross-references `specialization-and-model-selection.md` for the tier question, and cites the research report as the source of its per-model claims.
- **Rationale:** The two documents answer adjacent questions that authors will confuse, so each should point at the other. Citing the research lets a reader trace a claim and judge its currency, and the research already recorded which per-model claims rest on single-vendor documentation.
- **Evidence:** `specialization-and-model-selection.md` already uses a Cross-References section pointing at related guidance (codebase). The research labels the evidence status of each per-model claim (the research).
- **Rejected alternatives:**
  - Restate the tier-selection reasoning inline — rejected because it duplicates a maintained document and invites drift.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D6: Carry a currency marker

- **Question:** How does the guidance stay trustworthy as Anthropic revises the model pages?
- **Decision:** The document carries a visible marker of the date it was last checked and the models it was written against.
- **Rationale:** The per-model claims rest largely on Anthropic's own pages, which are pinned snapshots that get revised and archived. A currency marker lets a reader judge whether the guidance is still current instead of trusting it blind.
- **Evidence:** the research (model IDs are pinned snapshots, and legacy guidance is archived at each release; the per-model behavioral case leans on single-vendor documentation). Prior research reports in this repo carry a retrieval date convention (`docs/research/`, codebase).
- **Rejected alternatives:**
  - No currency marker — rejected because a reader could not tell whether the guidance had gone stale.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes

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
- **Decision:** Lead with the two differences that change an authoring decision (the opposite-direction instruction style, and the Fable 5 reasoning-echo refusal trap). Cover thinking mode and effort and subagent eagerness as short supporting notes, and tie each note to the authoring decision it changes rather than listing it for completeness: the thinking-mode note tells an author not to write "think step by step" or thinking-toggle instructions for a model whose thinking is always on, and the effort note tells an author to rely on the effort setting rather than "think harder" prompt hacks. Do not mirror every axis of Anthropic's per-model pages.
- **Rationale:** The instruction-style split points an author in the wrong direction if they follow the wrong model's guidance, and the Fable 5 refusal trap is the one difference that can cause an outright failure rather than a style mismatch. The supporting notes each change a concrete authoring choice, so they earn their place; the lighter axes (verbosity, design defaults, tokenizer) were not shown to change an authoring decision, and a smaller document is cheaper to keep current against pages that get revised and archived.
- **Evidence:** the research (instruction-following runs in opposite directions across Opus 4.8 / Sonnet 5 and Fable 5; the Fable 5 refusal category is the one functional-failure risk; thinking-mode defaults differ across the three models; the effort setting is the reasoning-depth lever; model pages are pinned snapshots that get archived). User input on the content-depth question.
- **Rejected alternatives:**
  - Comprehensive per-model sections mirroring the full pages (verbosity, design defaults, tokenizer, and so on) — rejected because the extra axes were not shown to change authoring decisions and enlarge the maintenance surface. Deferred, not dropped (see the spec's Deferred section).
  - Listing the supporting notes for symmetry with no stated decision they change — rejected after review (F6) as a completeness anti-pattern; each note now names the decision it drives.
- **Linked technical notes:** —
- **Driven by findings:** F6
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

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
- **Driven by findings:** F1
- **Dependent decisions:** D9
- **Referenced in spec:** Primary Flow, Coordinations, Out of Scope

### D5: Cross-reference tier selection and cite the research as source

- **Question:** How does the new document relate to the tier-selection guidance and to the research it comes from?
- **Decision:** The document opens by stating its own scope, cross-references `specialization-and-model-selection.md` for the tier question, and cites the research report as the source of its per-model claims. The reverse link and a scope disambiguator on the tier doc are handled as a coordination (see D10).
- **Rationale:** The two documents answer adjacent questions that authors will confuse, so each should point at the other. Citing the research lets a reader trace a claim and judge its currency, and the research already recorded which per-model claims rest on single-vendor documentation.
- **Evidence:** `specialization-and-model-selection.md` already uses a Cross-References section pointing at related guidance (codebase). The research labels the evidence status of each per-model claim (the research).
- **Rejected alternatives:**
  - Restate the tier-selection reasoning inline — rejected because it duplicates a maintained document and invites drift.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** D10
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D6: Carry a currency marker

- **Question:** How does the guidance stay trustworthy as Anthropic revises the model pages?
- **Decision:** The document carries a visible marker recording when it was written and against which model versions, and names its source (the research report and, through it, Anthropic's per-model pages) so a reader knows what to re-verify against. It also discloses that the Fable 5 refusal warning rests on single-vendor, single-source evidence. The marker records currency; it does not commit an owner to a re-check cadence, because the document is static and is refreshed when someone revisits it.
- **Rationale:** The per-model claims rest largely on Anthropic's own pages, which are pinned snapshots that get revised and archived, and the refusal warning is the highest-stakes claim on the weakest evidence. A currency marker and an evidence-status disclosure let a reader judge how far to trust each claim instead of trusting it blind.
- **Evidence:** the research (model IDs are pinned snapshots, and legacy guidance is archived at each release; the per-model behavioral case leans on single-vendor documentation; the refusal category is single-source, A3). Prior research reports in this repo carry a retrieval date convention (`docs/research/`, codebase).
- **Rejected alternatives:**
  - No currency marker — rejected because a reader could not tell whether the guidance had gone stale.
  - Presenting the refusal warning without its evidence status — rejected after review (F5) because the highest-stakes claim would read as the best-established one.
- **Linked technical notes:** —
- **Driven by findings:** F5, F10
- **Dependent decisions:** —
- **Referenced in spec:** Edge Cases and Failure Modes

### D9: Give the routing entry its own bullet with task-distinguishing scent

- **Question:** How does the guidance routing map surface the new document so an author looking for "how do I write for Fable 5" is routed here and not to the tier-selection doc?
- **Decision:** The routing map gains its own bullet for per-model authoring, worded to distinguish the author task "how to write instructions for a target model" from the existing "which model tier to run." The new document is not folded into the location-based "top-level files" line.
- **Rationale:** Findability is the whole feature for an on-demand document. The map's only model-related scent today points at the tier doc, so a per-model authoring entry needs task-distinguishing wording or authors are misrouted. A distinct bullet resolves the confusion at the routing layer, where prevention lives, rather than relying on the reader backtracking after landing on the wrong doc.
- **Evidence:** the guidance routing map groups references and today routes "specialization-versus-model-tier reasoning" to the top-level files (`han-plugin-builder/skills/guidance/SKILL.md`, codebase). Review findings F1 (information-architect IA-001, junior-developer JD-006).
- **Rejected alternatives:**
  - Fold the new doc into the existing "top-level files" bucket line — rejected because that bucket is organized by file location and its only model scent points at the tier doc, so the author task would be misrouted.
- **Linked technical notes:** —
- **Driven by findings:** F1
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Coordinations

### D10: The tier-selection doc is a coordinating artifact

- **Question:** How is the bidirectional relationship with the tier-selection doc kept whole?
- **Decision:** `specialization-and-model-selection.md` is a coordinating artifact that gains the reverse cross-reference to the new document and a one-line scope disambiguator, shipping in lockstep with the new document.
- **Rationale:** The spec claims each document cross-references the other, but the reverse link was untracked, so an author who lands on the older, higher-scent tier doc would have no path onward to the authoring guidance. Naming the tier doc as a ship-together coordination keeps the cross-reference whole in both directions.
- **Evidence:** `specialization-and-model-selection.md` has a Cross-References section that would carry the reverse link (`han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md`, codebase). Review finding F2 (information-architect IA-003).
- **Rejected alternatives:**
  - Rely on the new doc's forward link alone — rejected because a reader entering through the tier doc would orphan.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** —
- **Referenced in spec:** Coordinations, Edge Cases and Failure Modes

### D11: The concrete unknown-target default

- **Question:** When the target model is unknown, what does "write model-agnostic" concretely tell an author to write, given that Opus 4.8 and Sonnet 5 want enumerated steps while Fable 5 degrades on checklists?
- **Decision:** The default is to lead with the goal and the reasons behind it, state the load-bearing constraints and scope explicitly, and avoid exhaustive step-by-step micro-checklists. This pragmatic middle gives Fable 5 the goal and context it uses well without the checklist that degrades it, and gives Opus 4.8 and Sonnet 5 the explicit scope they need on the behaviors that matter.
- **Rationale:** A bare "write model-agnostic" left the doc's central instruction undefined at the exact point the model families pull in opposite directions, which is the common unknown-target case. The middle path is synthesizable from the research: Fable 5 uses stated reasons to make good micro-decisions and is harmed by over-enumeration, while Opus 4.8 and Sonnet 5 read literally and need explicit scope. Stating the goal plus the load-bearing constraints satisfies both without the failure mode of either extreme.
- **Evidence:** the research (Opus 4.8 / Sonnet 5 read instructions literally and need explicit scope; Fable 5 does better with a stated goal and reasons and degrades on step-by-step checklists). This is a synthesis across those findings, surfaced to the user as a settled decision they can revisit.
- **Rejected alternatives:**
  - Default to fully enumerated checklists — rejected because the research says this degrades Fable 5 output.
  - Default to goal-only prompting — rejected because Opus 4.8 and Sonnet 5 read literally and would be under-specified on load-bearing behaviors.
- **Linked technical notes:** —
- **Driven by findings:** F3
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D12: A concrete test for the refusal pattern

- **Question:** How does an author tell when the Fable 5 reasoning-echo warning applies to an instruction they are writing?
- **Decision:** The warning carries a concrete test. The pattern is present when an instruction tells the model to reproduce or transcribe its own internal thinking into the visible deliverable. That is distinct from asking the model to write a normal explanation of a decision or a reasoned answer as ordinary content, which the warning does not cover.
- **Rationale:** "Avoid it where it matters" offloaded a judgment without giving the author criteria, and the research calls the reasoning-echo pattern a common one in agentic skills, which raises the stakes. A recognition test makes the one failure-causing warning actionable.
- **Evidence:** the research (the Fable 5 refusal category triggers on instructions that ask the model to echo its own reasoning into the response). Review finding F4 (junior-developer JD-002).
- **Rejected alternatives:**
  - Leave "where it matters" undefined — rejected because the author could not tell when the warning applies.
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

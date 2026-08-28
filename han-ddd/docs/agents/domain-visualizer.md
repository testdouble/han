# domain-visualizer

Operator documentation for the `domain-visualizer` agent in the han-ddd plugin. This agent is dispatched for
you by [`/ddd-analysis`](../skills/ddd-analysis.md) after the final model and report pass their integrity
checks; you rarely invoke it directly. For the agent's internal instructions and output format, read the agent
definition at [`han-ddd/agents/domain-visualizer.md`](../../agents/domain-visualizer.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Reads the eight persisted artifacts from a completed DDD analysis run and produces a
  structured set of Mermaid diagrams and Markdown tables — domain landscape, capability map, workflow map,
  lifecycle diagrams, boundary friction map, ownership map, language collision matrix, question impact map,
  and scenario diagrams — that make the established domain model legible for engineering and product teams.
- **When to dispatch it.** Dispatched automatically by `/ddd-analysis` after the final context model and
  rendered report pass their integrity checks. Invoke directly when you have a completed DDD analysis run
  folder and want visual artifacts without re-running the full analysis.
- **What you get back.** A set of Markdown files in `$run_folder/visuals/`, each containing a Mermaid diagram
  or Markdown table, with an evidence footer listing the identifiers that support it.

## Key concepts

- **Presentation only, no model changes.** The domain visualizer renders the canonical model; it does not
  interpret it. It may not create, rename, merge, split, promote, or demote any BCM#, DC#, or IBN# entry.
  It may not change status, confidence, or disposition. The canonical model in `context-model-final.md` is
  authoritative and the visualizer treats it as read-only.
- **Evidence-backed visuals only.** Every visual must be traceable to specific identifiers in the persisted
  analysis artifacts. A visual that would require inventing or inferring a domain conclusion not already in
  the artifacts is not produced.
- **Evidence footer required.** Each artifact ends with a footer line naming the DL#, CAP#, OWN#, S#, B#,
  BCM#, DC#, IBN#, or BCR# identifiers that support it.
- **No strategic DDD type inference.** Named strategic relationship types (Shared Kernel, Customer/Supplier,
  Partnership, Conformist, Open Host Service, Published Language, Anti-Corruption Layer) are rendered only
  when the canonical model explicitly establishes them from documented evidence. Code-dependency or runtime
  evidence does not justify a named type; observation labels are used instead.
- **No target architecture.** The visualizer shows the established domain model, implementation friction,
  uncertainty, and open domain questions. It never produces a future-state or target-architecture diagram,
  and never uses directive phrasing ("extract service", "move model", "create bounded context").

## When to use it

**Dispatch when:**

- You want visual explanations of a completed DDD analysis for a planning meeting, an architecture review, or
  a domain-expert consultation.
- You are running `/ddd-analysis` — the skill dispatches this agent for you after the report passes its
  integrity checks.
- You want to regenerate visuals from an existing run folder without re-running the full analysis.

**Do not dispatch for:**

- **Discovering domain concepts or classifying boundaries.** Use [`/ddd-analysis`](../skills/ddd-analysis.md),
  which runs the discovery agents and the full modeling loop before dispatching the visualizer.
- **Evaluating bounded-context proposals.** Use [`bounded-context-critic`](./bounded-context-critic.md).
- **Recommending structural changes.** The visualizer does not recommend architectural changes. For planning
  work that follows from DDD findings, use `han-planning:plan-a-feature`.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically after the final report passes its integrity
checks. To invoke it directly on an existing run folder:

Give it the eight artifact paths from the completed run:

1. `$run_folder/synthesis/context-model-final.md`
2. `$run_folder/synthesis/critique.md`
3. `$run_folder/discovery/domain-language.md`
4. `$run_folder/discovery/business-capabilities.md`
5. `$run_folder/discovery/domain-ownership.md`
6. `$run_folder/discovery/structural.md`
7. `$run_folder/discovery/behavioral.md`
8. `$run_folder/synthesis/ddd-analysis.md`

And the output path: `$run_folder/visuals/`.

## What you get back

A set of Markdown files in `$run_folder/visuals/`. The exact files depend on what evidence the analysis
produced; files are skipped when evidence is insufficient.

**Standard visual set:**

- `domain-landscape.md` — Always produced. Mermaid flowchart showing all BCM#, DC#, and IBN# entries with
  visually distinct styles per category (CURRENT, LATENT, SPECULATIVE, DC#, IBN#) and factual relationship
  labels from the canonical model.
- `capability-map.md` — When CAP# findings exist. Groups each significant capability under its owning context
  or concern, revealing concentration and fragmentation.
- `workflow-map.md` — When ordered cross-context workflow evidence exists. Swimlane diagram showing the
  business journey across bounded contexts.
- `state-machines/{name}.md` — One file per explicit lifecycle with evidence-backed states and transitions.
  Authority overlay when OWN# shows multiple writers.
- `ownership-map.md` — When OWN# reveals contested authority or multiple writers. Shows observed actors and
  the models they write.
- `language-collisions.md` — When DL# identifies cross-context semantic collisions. Markdown table or Mermaid
  diagram showing "same word, different model."
- `boundary-friction.md` — When BCR# failure modes or structural findings establish implementation friction
  against the established domain model.
- `question-impact.md` — When domain-expert questions exist. Shows each question and the model elements whose
  interpretation depends on its answer.
- `scenarios/{name}.md` — One file per important LATENT or SPECULATIVE candidate with competing interpretations
  in the critique.

The agent returns a summary naming the artifact paths, generated visual types, and any visuals that were
skipped with reasons.

## How to get the most out of it

- **Use it with domain experts.** The domain landscape and question impact map are directly usable in a domain
  expert session — they show the established model and the questions that most reduce uncertainty.
- **Use the boundary friction map selectively.** This visual shows where the implementation resists the domain
  model; it is most useful when the team is deciding which module to look at next.
- **Pair with `/architectural-analysis`.** After the domain map identifies a friction area, run
  `/architectural-analysis` on that module for code-level coupling and SOLID findings.
- **Re-run without re-analyzing.** If the team wants visuals in a different format or at a different level of
  detail, invoke the visualizer directly on the existing run folder without repeating the full discovery and
  modeling pipeline.

## Cost and latency

Model tier: Sonnet. The visualizer reads the eight persisted artifacts and writes visual files. It does not
run discovery analysis or complex judgment loops. It runs sequentially after the readability-editor and
integrity checks in a `/ddd-analysis` run.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent as its final step.
- [`bounded-context-modeler`](./bounded-context-modeler.md). The agent whose final output (`context-model-final.md`)
  this agent renders.
- [`bounded-context-critic`](./bounded-context-critic.md). The agent whose BCR# entries and domain-expert
  questions this agent uses for the friction map and question impact map.
- [`domain-language-analyst`](./domain-language-analyst.md). Provides the DL# language-signal findings that
  drive the language collision map.
- [`business-capability-analyst`](./business-capability-analyst.md). Provides the CAP# capability findings
  that drive the capability map and workflow map.
- [`domain-ownership-analyst`](./domain-ownership-analyst.md). Provides the OWN# ownership findings that
  drive the ownership map and state-machine authority overlays.

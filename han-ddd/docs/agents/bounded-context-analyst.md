# bounded-context-analyst

Operator documentation for the `bounded-context-analyst` agent in the han-ddd plugin. This agent is dispatched for
you by [`/ddd-analysis`](../skills/ddd-analysis.md); you rarely invoke it directly. For the agent's internal
instructions and output format, read the agent definition at
[`han-ddd/agents/bounded-context-analyst.md`](../../agents/bounded-context-analyst.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Reads a codebase through a DDD lens across seven evidence dimensions and classifies bounded
  context candidates as strongly expressed, latent, speculative, or contested.
- **When to use it.** Dispatched by `/ddd-analysis`. Invoke directly only when you need raw BC# discovery findings
  without the full domain map.
- **What you get back.** Numbered BC# findings, each with a classification tier, core domain concepts, boundary
  evidence, boundary leaks, integration signals, open questions, and file-path citations; plus a Discovery Summary.

## Key concepts

- **Seven evidence dimensions.** The agent analyzes naming cohesion, module and package structure, data model
  clusters, API surface shapes, deployment boundary signals, shared code, and git history or team signals. It reports
  which dimensions yielded evidence and which did not.
- **Classification tiers.** Every candidate receives one of four tiers based on the evidence: Strongly Expressed,
  Latent, Speculative, or Contested. The tier is a confidence characterization, not a quality judgment.
- **Verbatim vocabulary.** The agent quotes domain vocabulary exactly as it appears in the code. Renaming or
  normalizing terms would lose the evidence — the exact words are the finding.
- **Discovery only.** This agent does not recommend service splits, migrations, or refactors. It reads and classifies.

## When to use it

**Dispatch when:**

- You want raw bounded-context discovery findings to pass to a downstream synthesis step you are building.
- You are running `/ddd-analysis` — the skill dispatches this agent for you.

**Do not dispatch for:**

- **Synthesizing a domain map.** Use [`domain-map-synthesizer`](./domain-map-synthesizer.md) to turn BC# findings
  into a structured context map.
- **Static coupling or SOLID analysis.** Use `han-core:structural-analyst` instead.
- **Runtime data flow.** Use `han-core:behavioral-analyst` instead.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically. To invoke it directly:

```
Agent(subagent_type: "han-ddd:bounded-context-analyst", prompt: "...")
```

The brief must include the scope, the depth band and its calibration directive, project-context conventions (or a
note that inference from surrounding code applies), git availability, and a reminder that this agent produces
discovery findings only.

## What you get back

Numbered BC# findings. Each finding contains:

- **Classification:** Strongly Expressed, Latent, Speculative, or Contested
- **Dimensions with evidence:** Which of the seven dimensions produced evidence
- **Core domain concepts:** 3-8 domain terms quoted verbatim from the code
- **Boundary evidence:** File paths and the strongest boundary signals
- **Boundary leaks:** Foreign concepts appearing here, or this candidate's concepts appearing elsewhere
- **Context relationship signals:** Integration evidence pointing to other BC candidates
- **Open questions:** What a domain expert would need to answer to refine the classification
- **Files:** 3-8 key file paths anchoring the finding

After all BC# items, the agent produces a Discovery Summary: candidate counts by tier, strongest signals, weakest
candidates, contested areas, and evidence gaps.

## Cost and latency

Model tier: Sonnet. The agent reads across the full analysis scope, which makes it the most time-intensive step in
the `/ddd-analysis` run on large repositories. At `small` depth it focuses on naming and structure only; at `large`
depth it runs all seven dimensions including git history queries.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent.
- [`domain-map-synthesizer`](./domain-map-synthesizer.md). The synthesis agent that consumes BC#, DL#, CAP#, and
  OWN# findings into a domain and context map.
- [`structural-analyst`](../../../han-core/docs/agents/structural-analyst.md). The adjacent agent for static
  coupling and module-boundary analysis independent of DDD concerns.

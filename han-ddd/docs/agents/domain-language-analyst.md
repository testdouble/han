# domain-language-analyst

Operator documentation for the `domain-language-analyst` agent in the han-ddd plugin. This agent is dispatched for
you by [`/ddd-analysis`](../skills/ddd-analysis.md); you rarely invoke it directly. For the agent's internal
instructions and output format, read the agent definition at
[`han-ddd/agents/domain-language-analyst.md`](../../agents/domain-language-analyst.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Reads a codebase and surfaces Domain-Driven Design language signals: business terminology,
  vocabulary clusters, semantic collisions (the same term with different meanings in different parts of the system),
  synonyms, technical obscuration, and invariant divergences. Each finding is independently traceable to repository
  evidence.
- **When to use it.** Dispatched by `/ddd-analysis` in parallel with the other discovery agents. Invoke directly
  only when you want to survey a codebase for DDD language signals without running a full domain map.
- **What you get back.** Numbered DL# findings, each with a signal type, verbatim term evidence, file paths, and a
  language observation; plus a Language Summary.

## Key concepts

- **Six analysis dimensions.** The agent analyzes business term inventory, vocabulary cluster mapping, semantic
  collision detection, synonym detection, technical obscuration, and invariant and rule divergence. It reports which
  dimensions yielded evidence and which did not.
- **Semantic collision is the highest-priority signal.** When the same term carries materially different meanings in
  different parts of the system, that divergence is a strong signal that two areas of the codebase model the concept
  differently. These findings are the most useful input to the domain-map synthesizer.
- **Verbatim vocabulary.** The agent quotes domain vocabulary exactly as it appears in the code. Renaming or
  normalizing terms would lose the evidence — the exact words are the finding.
- **Language evidence only.** This agent does not propose bounded contexts, evaluate whether vocabulary clusters
  should become bounded contexts, or recommend any structural change. It reads the code and characterizes the
  language.

## When to use it

**Dispatch when:**

- You want raw DL# language-signal findings to pass to a downstream synthesis step you are building.
- You are running `/ddd-analysis` — the skill dispatches this agent for you in parallel with the other discovery
  agents.

**Do not dispatch for:**

- **Classifying bounded context candidates.** Use [`bounded-context-analyst`](./bounded-context-analyst.md) to
  produce BC# findings organized by classification tier.
- **Synthesizing a domain map.** Use [`domain-map-synthesizer`](./domain-map-synthesizer.md) to turn BC# and DL#
  findings into a structured context map.
- **Static coupling or SOLID analysis.** Use `han-core:structural-analyst` instead.
- **Runtime data flow.** Use `han-core:behavioral-analyst` instead.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically. To invoke it directly:

```
Agent(subagent_type: "han-ddd:domain-language-analyst", prompt: "...")
```

The brief must include the scope, a calibration directive matched to the desired depth (surface the highest-frequency
terms and most obvious collisions at small depth; full vocabulary inventory and all six dimensions at medium depth;
exhaustive cross-module semantic collision detection at large depth), and a reminder that this agent produces
language-signal evidence only.

## What you get back

Numbered DL# findings. Each finding contains:

- **Signal type:** One of Business vocabulary, Vocabulary cluster, Semantic collision, Synonym, Technical obscuration,
  or Invariant divergence
- **Term(s):** The exact term or terms, quoted verbatim from the code
- **Locations:** File paths organized by sense when a collision or synonym is present
- **Evidence:** Verbatim code snippets anchoring the finding — class names, field names, function signatures, schema
  column names, API paths, test assertions
- **Observation:** What the language signal reveals about how the domain is expressed, stated without bounded context
  implications

After all DL# items, the agent produces a Language Summary: business term counts, the strongest vocabulary clusters,
the most significant collisions and synonyms, the overall balance between technical and business naming, and any
evidence gaps.

## Cost and latency

Model tier: Sonnet. The agent reads across the full analysis scope, which makes it one of the more time-intensive
steps in the `/ddd-analysis` run on large repositories. It runs in parallel with `bounded-context-analyst`, `business-capability-analyst`, and
`domain-ownership-analyst` — all four complete before the `domain-map-synthesizer` begins.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent.
- [`bounded-context-analyst`](./bounded-context-analyst.md). The companion discovery agent, run in parallel, that
  classifies BC candidates from structural signals.
- [`domain-map-synthesizer`](./domain-map-synthesizer.md). The synthesis agent that consumes BC#, DL#, CAP#, and OWN#
  findings.

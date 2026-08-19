# business-capability-analyst

Operator documentation for the `business-capability-analyst` agent in the han-ddd plugin. This agent is dispatched
for you by [`/ddd-analysis`](../skills/ddd-analysis.md); you rarely invoke it directly. For the agent's internal
instructions and output format, read the agent definition at
[`han-ddd/agents/business-capability-analyst.md`](../../agents/business-capability-analyst.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Reads a codebase and surfaces cohesive business capabilities — what the business actually
  does — expressed as behavioral verb phrases. Explicitly distinguishes behavioral capabilities from CRUD groupings
  and entity decomposition, which it treats as discovery failure modes.
- **When to use it.** Dispatched by `/ddd-analysis` in parallel with `bounded-context-analyst`,
  `domain-language-analyst`, and `domain-ownership-analyst`. Invoke directly when you want raw capability evidence
  without running a full domain map.
- **What you get back.** Numbered CAP# findings, each with a verb-phrase capability name, behavioral evidence,
  key responsibilities, important concepts, state or lifecycle signals, and adjacent capability relationships; plus
  a Capability Summary.

## Key concepts

- **Verb phrases, not entity nouns.** Every capability is named as a verb phrase describing what the business
  does: "determine eligibility", "fulfill order", "settle claim". A noun like "member management" is not a
  capability name — it is an entity decomposition, which this agent treats as a failure mode.
- **Six analysis dimensions.** The agent analyzes commands and actions, domain events, workflows and processes,
  policies and rules, state and lifecycle, and outcomes and outputs. It reports which dimensions yielded evidence
  and which did not.
- **Entity decomposition and CRUD as failure modes.** When code is organized around CRUD operations on an entity
  with no observable business intent, the agent names this as a negative result rather than inventing a capability.
  This prevents CRUD groupings from masquerading as business capabilities.
- **Capability evidence only.** This agent does not propose bounded contexts, evaluate whether capabilities align
  with bounded contexts, or recommend any structural change. It reads the code and names what the business does.

## When to use it

**Dispatch when:**

- You want raw CAP# findings to pass to a downstream synthesis step you are building.
- You are running `/ddd-analysis` — the skill dispatches this agent for you in parallel with the other discovery
  agents.

**Do not dispatch for:**

- **Classifying bounded context candidates.** Use [`bounded-context-analyst`](./bounded-context-analyst.md) to
  produce BC# findings organized by classification tier.
- **Language signals and vocabulary.** Use [`domain-language-analyst`](./domain-language-analyst.md) to produce
  DL# findings.
- **Synthesizing a domain map.** Use [`domain-map-synthesizer`](./domain-map-synthesizer.md) to turn discovery
  findings into a structured context map.
- **Static coupling or SOLID analysis.** Use `han-core:structural-analyst` instead.
- **Runtime data flow.** Use `han-core:behavioral-analyst` instead.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically. To invoke it directly:

```
Agent(subagent_type: "han-ddd:business-capability-analyst", prompt: "...")
```

The brief must include the scope, a calibration directive matched to the desired depth (surface commands and
domain events with the strongest behavioral signals at small depth; all six dimensions at medium depth; all six
dimensions with emphasis on cross-module workflows and process orchestration at large depth), and a reminder that
this agent produces capability evidence only.

## What you get back

Numbered CAP# findings. Each finding contains:

- **Capability:** One sentence naming the business action and who benefits
- **Evidence:** 3-5 strongest code signals with file paths and verbatim names
- **Key responsibilities:** 2-5 behavioral responsibilities the capability must fulfill
- **Important concepts:** Business terms central to the capability, quoted verbatim from the code
- **State or lifecycle:** Status enumerations or lifecycle stages, with file paths (omitted when none found)
- **Adjacent capabilities:** Other CAP# findings with named relationship types (orchestrates, publishes-to,
  depends-on, depended-on-by)
- **Open questions:** What a domain expert would need to confirm the capability's scope or refine its name

After all CAP# items, the agent produces a Capability Summary: the count of distinct capabilities, the strongest
signals, any areas where CRUD structure was found but no behavioral capability was identified, and evidence gaps.

## Cost and latency

Model tier: Sonnet. The agent reads across the full analysis scope, which makes it one of the more time-intensive
steps in the `/ddd-analysis` run on large repositories. It runs in parallel with `bounded-context-analyst`, `domain-language-analyst`, and `domain-ownership-analyst` —
all four complete before the `domain-map-synthesizer` begins.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent.
- [`bounded-context-analyst`](./bounded-context-analyst.md). The companion discovery agent that classifies BC
  candidates from structural signals.
- [`domain-language-analyst`](./domain-language-analyst.md). The companion discovery agent that surfaces
  language signals.
- [`domain-map-synthesizer`](./domain-map-synthesizer.md). The synthesis agent that consumes BC#, DL#, CAP#, and
  OWN# findings into a domain and context map.

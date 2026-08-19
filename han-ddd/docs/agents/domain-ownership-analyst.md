# domain-ownership-analyst

Operator documentation for the `domain-ownership-analyst` agent in the han-ddd plugin. This agent is dispatched
for you by [`/ddd-analysis`](../skills/ddd-analysis.md); you rarely invoke it directly. For the agent's internal
instructions and output format, read the agent definition at
[`han-ddd/agents/domain-ownership-analyst.md`](../../agents/domain-ownership-analyst.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md)

## TL;DR

- **What it does.** Reads a codebase and surfaces domain ownership evidence: who creates, modifies, and consumes
  domain concepts; which representation is authoritative; where lifecycle begins and ends; which rules protect the
  concept; which changes must remain consistent together; and where authority is contested or ambiguous.
- **When to use it.** Dispatched by `/ddd-analysis` in parallel with the four other discovery agents. Invoke
  directly when you want raw ownership evidence without running a full domain map.
- **What you get back.** Numbered OWN# findings, each tracing authority, creators, modifiers, consumers,
  lifecycle, consistency rules, consistency coupling, and contested ownership for one domain concept; plus an
  Ownership Summary.

## Key concepts

- **Technical ownership is evidence, not conclusion.** A database table, ORM model, service, API, or team owning
  a deployment unit is a possible claim to domain authority. The agent reads the code to determine whether that
  claim holds — it does not equate technical structure with domain ownership.
- **Contested ownership is the highest-priority signal.** When multiple parts of the system write to the same
  domain concept, represent it in competing stores, or reuse the same model for different responsibilities, the
  agent surfaces this prominently. Authority ambiguity is more valuable as a finding than confirmed authority.
- **Consistency coupling crosses ownership boundaries.** Changes that must remain consistent across multiple
  domain concepts — sagas, dual-writes, synchronized state — are ownership signals, especially when the coupled
  concepts are held by different parts of the system.
- **Ownership evidence only.** This agent does not propose bounded contexts, evaluate whether ownership patterns
  align with bounded contexts, or recommend any structural change. It reads the code and reports what it finds.

## When to use it

**Dispatch when:**

- You want raw OWN# findings to pass to a downstream synthesis step you are building.
- You are running `/ddd-analysis` — the skill dispatches this agent for you in parallel with the other discovery
  agents.

**Do not dispatch for:**

- **Language signals and vocabulary.** Use [`domain-language-analyst`](./domain-language-analyst.md) to produce
  DL# findings.
- **Business capability discovery.** Use [`business-capability-analyst`](./business-capability-analyst.md) to
  produce CAP# findings.
- **Constructing bounded context proposals.** Use [`bounded-context-modeler`](./bounded-context-modeler.md) after
  all discovery agents have completed.
- **Static coupling or SOLID analysis.** Use `han-core:structural-analyst` instead.
- **Runtime data flow.** Use `han-core:behavioral-analyst` instead.

## How to invoke it

The `/ddd-analysis` skill dispatches this agent automatically. To invoke it directly:

```
Agent(subagent_type: "han-ddd:domain-ownership-analyst", prompt: "...")
```

The brief must include the scope, a calibration directive matched to the desired depth (authority mapping and the
most obvious contestation signals at small depth; all six dimensions at medium depth; all six dimensions with
emphasis on cross-module consistency coupling and exhaustive contestation detection at large depth), and a
reminder that this agent produces ownership evidence only.

## What you get back

Numbered OWN# findings. Each finding contains:

- **Authoritative representation:** The primary record location, or "unclear" when no single authoritative
  location was found
- **Creators:** Code that creates instances, with file paths and verbatim method or endpoint names
- **Modifiers:** Code that changes the authoritative record, with notes on what authority each claims
- **Consumers:** Code that reads without writing the authoritative record, with notes on what each does with the
  data
- **Lifecycle stages:** Creation, transitions, and terminal state with file-path evidence; omitted when no
  lifecycle structure was found
- **Consistency rules:** Invariants, validation rules, and constraints, with verbatim code and file paths
- **Consistency coupling:** Other concepts this concept must change atomically with, and where that coordination
  lives
- **Contested ownership:** Every party that claims authority, the nature of the contestation, and file-path
  evidence
- **Open questions:** What the code cannot answer about ultimate authority over the concept

After all OWN# items, the agent produces an Ownership Summary: total concepts analyzed, split by uncontested and
contested authority, lifecycle traceability, and the most significant contestation findings.

## Cost and latency

Model tier: Sonnet. The agent reads across the full analysis scope, which makes it one of the more time-intensive
steps in the `/ddd-analysis` run on large repositories. It runs in parallel with `domain-language-analyst`,
`business-capability-analyst`, `han-core:structural-analyst`, and `han-core:behavioral-analyst` — all five complete
before `bounded-context-modeler` begins.

## Related documentation

- [Plugin README](../../README.md). The han-ddd plugin front door.
- [Repo root README](../../../README.md). The Han suite landing page.
- [`/ddd-analysis`](../skills/ddd-analysis.md). The skill that dispatches this agent.
- [`domain-language-analyst`](./domain-language-analyst.md). The companion discovery agent that surfaces language
  signals.
- [`business-capability-analyst`](./business-capability-analyst.md). The companion discovery agent that surfaces
  behavioral capabilities.
- [`bounded-context-modeler`](./bounded-context-modeler.md). The synthesis agent that reads all discovery findings
  and proposes bounded contexts.

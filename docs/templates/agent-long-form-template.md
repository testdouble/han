# {agent-name}

Operator documentation for the `{agent-name}` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/{agent-name}.md`](../../han.core/agents/{agent-name}.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** {one sentence}
- **When to dispatch it.** {one sentence, with the single strongest trigger}
- **What you get back.** {one sentence, naming the output artifact or report shape}

## Key concepts

- **{Concept 1}.** {one line}
- **{Concept 2}.** {one line}
- **{Concept 3}.** {one line}

## When to use it

**Dispatch when:**

- {Specific situation 1}
- {Specific situation 2}

**Do not dispatch for:**

- **{Adjacent task 1}.** Use [`{sibling-agent}`](./{sibling-agent}.md) instead.
- **{Adjacent task 2}.** Use [`{sibling-agent}`](./{sibling-agent}.md) instead.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:{agent-name}`.

Give it:

1. **A focus area.** {What is in-scope and what's out-of-scope.}
2. **A brief (optional).** {What reduces open questions most.}
3. **An output path (optional).** {If it writes a report to disk, the default path and filename.}

Example prompts:

- *"{Concrete situation 1}"*
- *"{Concrete situation 2}"*

## What you get back

{Describe the returned summary and, if applicable, the full report on disk: sections, finding-ID schemes, severity tables, open-question lists.}

## How to get the most out of it

- **{Lever 1}.** {...}
- **{Lever 2}.** {...}
- **{Lever 3}.** {...}
- **Pair with `{companion-agent}`.** {When and why}

## YAGNI (when applicable)

{If this agent reviews artifacts, produces recommendations, or otherwise contributes items the team will commit, describe the YAGNI posture: which items it gates, which named anti-patterns it enforces (Speculative Test, Speculative Edge Case, Speculative Data Machinery, Premature Operational Machinery, Evidence Gate, Evidence Sweep, and so on), and how findings or deferrals surface in the agent's output. Cross-reference [YAGNI](../yagni.md). Pure-discovery agents that do not produce committed items can omit this section.}

## Cost and latency

{Model tier (`opus`, `sonnet`, `haiku`, or `inherit`), dispatch cost, when to avoid tight-loop or parallel dispatching.}

## In more detail (optional)

{Expanded prose: modes of operation, protocol sketches, rationale for the agent's stance, boundary with sibling agents.}

## Sources

{Provenance of the agent's principles, vocabulary, and anti-patterns. Each source is cited because the agent draws specific, named artifacts from it.}

### {Source 1: Author, Title, Year}

{Why this source is cited.}

URL: {url}

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule (when applicable). The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [`{companion-agent}`](./{companion-agent}.md). {How they pair}
- [`/{skill-that-dispatches-this}`](../skills/{skill}.md). {The skill that typically dispatches this agent}
- [{build-guideline link}](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/{file}.md). {Relevance}

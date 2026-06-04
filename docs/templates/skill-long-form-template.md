# /{skill-name}

Operator documentation for the `/{skill-name}` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/{skill-name}/SKILL.md`](../../han.core/skills/{skill-name}/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** {one sentence}
- **When to use it.** {one sentence, with the single strongest trigger}
- **What you get back.** {one sentence, naming the primary output artifact}

## Key concepts

- **{Concept 1}.** {one line explaining the concept as this skill uses it}
- **{Concept 2}.** {one line}
- **{Concept 3}.** {one line}

## When to use it

**Invoke when:**

- {Specific situation 1}
- {Specific situation 2}
- {Specific situation 3}

**Do not invoke for:**

- **{Adjacent task 1}.** Use [`/{sibling-skill}`](./{sibling-skill}.md) instead.
- **{Adjacent task 2}.** Use [`/{sibling-skill}`](./{sibling-skill}.md) instead.

## How to invoke it

Run `/{skill-name}` in Claude Code.

Give it:

1. **{Input 1}.** {What it is, why it matters, what a thin vs. sharp version looks like.}
2. **{Input 2, optional}.** {...}
3. **{Any context to respect}.** {PRDs, linked issues, prior specs, and so on.}

Example prompts:

- `/{skill-name}`. *"{Concrete example 1}"*
- `/{skill-name} {arg}`. *"{Concrete example 2}"*

## What you get back

{Describe every artifact the skill produces: file names, where they land, and what each section or ID scheme means. If multiple files are cross-referenced, explain how the cross-references work.}

## How to get the most out of it

- **{Lever 1}.** {Why this matters, what it unlocks}
- **{Lever 2}.** {...}
- **{Lever 3}.** {...}
- **Pair with `/{companion-skill}` next.** {When and why}

## YAGNI (when applicable)

{If this skill produces or reviews an artifact that can accrete speculative items (plan steps, abstractions, infrastructure additions, observability hooks, configuration knobs, ADRs, coding standards, tests, or build phases), describe the YAGNI posture this skill takes: which items it gates, which named anti-patterns force a finding, whether the rule is enforcing (defer-by-default) or advisory-only, and how the deferral surfaces in the artifact. Cross-reference [YAGNI](../yagni.md). Skills that do not produce or review such artifacts can omit this section.}

## Cost and latency

{Model tier, dispatch fan-out, typical run shape. Name the most expensive single step. Note whether the skill is built for tight-loop iteration or for infrequent high-signal runs.}

## In more detail (optional)

{Expanded prose: modes of operation, protocol sketches, decision flow, design rationale. This is the only section where narrative prose is appropriate. Everything above is structured for scannability.}

## Sources

The skill's protocols and vocabulary are grounded in {named practice / named framework}. Each source below is cited because the skill draws specific, named artifacts from it. Not as a reading list, but as the provenance of the principles the skill applies.

### {Source 1: Author, Title, Year}

{Why this source is cited and which artifact of the skill traces to it.}

URL: {url}

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule (when applicable). The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [`{sibling-skill}`](./{sibling-skill}.md). {Why and when they pair}
- [`{agent-this-skill-dispatches}`](../agents/{agent}.md). {Role in this skill}
- [{build-guideline link}](../../han.plugin-builder/skills/guidance/references/skill-building-guidance/{file}.md). {Relevance}

# /agent-builder

Operator documentation for the `/agent-builder` skill in the opt-in `han-plugin-builder` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-plugin-builder/skills/agent-builder/SKILL.md`](../../../han-plugin-builder/skills/agent-builder/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [How to create a new agent](../../how-to/create-a-new-agent.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Builds a new Claude Code agent (subagent) from scratch through a relentless, evidence-based interview that walks the agent's design tree decision-by-decision. It then reviews the finished agent against the plugin-building guidance and applies every fix it finds.
- **When to use it.** When you want to create, author, scaffold, or design a new agent or subagent and want it to conform to the domain-focus, description-length, model-selection, and self-containment rules without your having to remember them.
- **What you get back.** A real, self-contained agent file on disk (`{plugin}/agents/{agent-name}.md`) that has already passed a guidance-conformance review.

## Key concepts

- **Interview-driven, one question at a time.** The skill interviews you relentlessly, walking each branch of the design tree and resolving dependencies between decisions one at a time. It never batches questions.
- **Explore before asking.** Any question the repository can answer (the target plugin's existing agents, sibling descriptions, the skills that would dispatch this agent, conventions, the guidance) it answers by exploring instead of asking you.
- **Recommend, then ask.** Every question surfaced to you comes with a recommended answer and its rationale, grounded in evidence. You accept, amend, or redirect.
- **The design tree.** Foundational decisions (which plugin, the single narrow domain, generate-or-evaluate) settle before identity (role identity under 50 tokens, domain vocabulary, anti-patterns). Identity settles before triggering (the description), which settles before capabilities (model tier, tools) and body structure (inlined protocol, graceful degradation).
- **One role per agent.** An agent generates *or* evaluates, never both, because self-evaluation bias means the reasoning that created a blind spot also rates it as correct. If your request bundles both, the skill recommends splitting it.
- **Agents are self-contained.** Unlike a skill, an agent is a single flat `.md` file with no `references/` folder, no `scripts/`, and no context injection. Everything the agent needs is inlined. The skill enforces this throughout.
- **Self-contained review.** `han-plugin-builder` depends on nothing and ships no agents, so the review is done inline by reading the guidance, not by dispatching a review team.

## When to use it

**Invoke when:**

- You want to author a brand-new agent and have it conform to the domain-focus, role-identity, model-selection, and self-containment rules.
- You have a domain in mind but want the design tree walked so the vocabulary, anti-patterns, model tier, and tool set are settled deliberately.
- You are adding an agent to a plugin that dispatches it from a skill and want its description to disambiguate cleanly against near-sibling agents.

**Do not invoke for:**

- **Building a skill or slash command.** Use [`/skill-builder`](./skill-builder.md) instead.
- **Reading the rules without building anything.** Use [`/guidance`](./guidance.md) to serve the relevant guidance, or `/guidance init` to vendor the plugin-building skills (including this one) into a repo.
- **A deterministic, flowchartable process.** That is a skill, not an agent; the skill will stop and redirect you to [`/skill-builder`](./skill-builder.md).

## How to invoke it

Run `/agent-builder` in Claude Code.

The skill ships in the opt-in `han-plugin-builder` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-plugin-builder@han`. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **One or two sentences on the agent's domain and what it produces.** A thin request ("build an agent") makes the skill ask for this first. A sharp one ("an agent that audits SQL migrations for unsafe operations and returns findings") lets it start walking the tree immediately.
2. **The target plugin, if you know it.** If you do not name one, the skill infers candidates and confirms the plugin ships agents (or is the right home for the first one).
3. **The skill that will dispatch it, if one exists.** Knowing the caller tells the skill what the agent receives and returns.

Example prompts:

- `/agent-builder`. *"I want an agent that reviews error messages for missing debugging context."*
- `/agent-builder`. *"Add an evaluator agent to han-core that challenges a research brief's citations."*

## What you get back

A single self-contained agent file:

- **`{plugin}/agents/{agent-name}.md`**, the agent definition. Frontmatter carries `name`, a four-component `description` under 1024 characters, a minimal `tools` allowlist, and an explicit `model`. The body follows in order: the Role Identity paragraph (under 50 tokens), a `## Domain Vocabulary` section (15-30 precise terms), an `## Anti-Patterns` section (5-10 named patterns with detection signals), and the inlined protocol the agent follows, with graceful-degradation wording on tool-dependent steps.
- **A new plugin scaffold**, if the agent belongs in a brand-new plugin: the `.claude-plugin/plugin.json` and marketplace entry, built per the configuration guidance.

The skill closes by summarizing the agent's shape (role, model, tools, vocabulary and anti-pattern counts) and the decisions settled by evidence versus by you. It also reports the fixes the review pass applied (with the guidance document behind each) and how the agent is dispatched: the qualified `defining-plugin:agent-name` and the skill that would call it.

## How to get the most out of it

- **Name the domain narrowly.** A focused domain activates deep expertise; a broad one averages shallow knowledge across competing domains. The skill pushes for precision, but starting narrow helps.
- **Decide generate-or-evaluate up front.** If you want an agent that both produces and judges, the skill will split it. Knowing which role you want avoids a mid-interview redirect.
- **Push back on the model tier.** The skill recommends a tier from the cognitive load (opus for synthesis and judgment, sonnet for structured procedures, haiku for fast lookups). If your sense of the work differs, say so.
- **Trust the review pass.** The Step 6 conformance review fixes role-identity length, description budget, self-containment violations, and an over-broad tool set before you see them. That includes dropping the `Agent` tool unless the agent's own protocol dispatches sub-agents, since dispatch flows from skills to agents by default.
- **Wire up the caller.** An agent is dispatched by a skill. If the calling skill does not exist yet, the skill recommends [`/skill-builder`](./skill-builder.md) to build it.

## YAGNI

The skill applies an evidence-based YAGNI discipline to the agent it builds: vocabulary terms, anti-patterns, tools, and frontmatter fields must each earn their place against the agent's actual job. Anything added "for completeness" is cut during the Step 6 review. This keeps the agent's domain framing tight and its always-loaded description lean. See [YAGNI](../../yagni.md) for the rule the discipline derives from.

## Cost and latency

No agents are dispatched; the review is inline. Cost is dominated by the interview length and the just-in-time reads of the governing guidance documents (one or two per decision, not the whole set). A focused single-domain agent settles in a handful of exchanges. Built for a deliberate, conversational session, not a tight automated loop.

## In more detail

The workflow runs in seven steps: capture the request and confirm an agent is the right entity (a judgment layer, not a flowchartable process) with a single role; discover the target plugin, its sibling agents, and the calling skill; and build the design tree in dependency order. Then it runs the interview loop one branch at a time; writes the single self-contained file; runs the full guidance-conformance review; and presents the result with the dispatch wiring. Each design-tree decision maps to a specific governing document (domain focus, description length, model selection, external files, multi-agent economics, dispatch namespacing), read only when that decision is on the table. The review pass re-reads each document that applies and corrects the file directly rather than reporting problems back to you.

## Sources

The skill's design tree and review checklist are grounded in the plugin's own agent-authoring guidance, which in turn cites external practice.

### The Specialized Review Principle

The vocabulary-routing, persona-length (under 50 tokens), and self-evaluation-bias rules trace to the research-backed Specialized Review Principle.

URL: https://jdforsythe.github.io/10-principles/principles/specialized-review/

### Towards a Science of Scaling Agent Systems (Google Research / DeepMind / MIT, 2025)

The multi-agent-economics framing the skill uses to justify whether a new agent is warranted traces to this 2025 study on when and why agent systems help.

URL: https://research.google/blog/towards-a-science-of-scaling-agent-systems-when-and-why-agent-systems-work/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [How to create a new agent](../../how-to/create-a-new-agent.md). The end-to-end recipe for driving this skill, with the prompts, the stages, and what to expect.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule the skill applies to the agent it builds.
- [`/skill-builder`](./skill-builder.md). The sibling builder for skills; reach for it when the work is a flowchartable process rather than a judgment layer.
- [`/guidance`](./guidance.md). Serves the same authoring guidance this skill applies, and its `init` vendors this skill (with `guidance` and `skill-builder`) into a repo; use it when you want the rules, not a finished agent.
- [Agent-building guidance](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/). The rules the skill's interview and review enforce, readable directly.

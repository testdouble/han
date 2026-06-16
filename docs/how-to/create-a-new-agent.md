# How To: Create a New Agent

A walkthrough for building a new Claude Code agent (subagent) from scratch with [`/agent-builder`](../skills/han.plugin-builder/agent-builder.md): describe the agent's domain and what it produces, answer the interview that walks the agent's design tree decision-by-decision, and end with a single self-contained agent file on disk that has already passed a guidance-conformance review. This is the recipe for *using* the builder; the [agent-building guidance](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/) is canonical for the rules the builder enforces.

> See also: [How-to index](./README.md) · [`/agent-builder`](../skills/han.plugin-builder/agent-builder.md) · [`/guidance`](../skills/han.plugin-builder/guidance.md) · [Create a new skill](./create-a-new-skill.md)

The happy path below builds an agent into a plugin that already ships agents and a skill that will dispatch it, because that is the case the builder is built around: an agent earns its place by being dispatched. When the agent belongs in a brand-new plugin, the [Variations](#variations) section covers the scaffold the builder adds.

## Before you begin

- You have installed the opt-in `han.plugin-builder` plugin. The `han` meta-plugin does not bundle it, so install it on its own first with `/plugin install han.plugin-builder@han`. See [Choosing a Han plugin](../choosing-a-han-plugin.md) for where it sits in the suite.
- You have a single narrow domain in mind. A focused domain ("auditing SQL migrations for unsafe operations") activates deep expertise; a broad one ("reviewing code") averages shallow knowledge across competing domains. The builder pushes for precision, but starting narrow helps.
- You know whether the agent generates or evaluates. An agent does one or the other, never both, because self-evaluation bias means the reasoning that created a blind spot also rates it as correct. If your request bundles both, the builder recommends splitting it.
- You have a sense of whether this is an agent at all. An agent is a judgment layer that reasons over messy input. If the work is a deterministic, flowchartable process, it is a skill, and the builder will stop and redirect you to [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md). [Create a new skill](./create-a-new-skill.md) is the matching guide. When you are not sure, [`/guidance`](../skills/han.plugin-builder/guidance.md) answers "is this better as a skill or an agent?" before you start.

## What you'll end up with

- A single self-contained agent file at `{plugin}/agents/{agent-name}.md`: frontmatter with a `name`, a four-component `description` under 1024 characters, a minimal `tools` allowlist, and an explicit `model`; then a body in order: a Role Identity paragraph under 50 tokens, a `## Domain Vocabulary` section of 15-30 precise terms, an `## Anti-Patterns` section of 5-10 named patterns with detection signals, and the inlined protocol the agent follows with graceful-degradation wording on tool-dependent steps.
- A closing summary from the builder: the agent's shape (role, model, tools, vocabulary and anti-pattern counts), which decisions it settled by evidence versus which it asked you, the fixes the review pass applied with the guidance document behind each, and the dispatch wiring (the qualified `defining-plugin:agent-name` and the skill that would call it).

## The happy path

The workflow runs as one continuous interview that moves through three natural stages: you frame the agent and its domain, the builder walks the design tree with you, and then it writes and reviews the single file. Each stage is a place you can stop and look at what you have.

### Stage 1: Frame the agent, its domain, and its caller

1. **Run [`/agent-builder`](../skills/han.plugin-builder/agent-builder.md) with one or two sentences on the domain and what the agent produces.** Lead with the domain and the output. Two examples that give the builder enough to start:

    > `/agent-builder` *"I want an agent that reviews error messages for missing debugging context."*

    > `/agent-builder` *"Add an evaluator agent to han.core that challenges a research brief's citations."*

2. **Name the target plugin, or let the builder infer it.** If you name one, the builder confirms it ships agents (or is the right home for the first one) and reads its sibling agents. If you do not, it infers candidates from the repository and confirms with you before writing anywhere.

3. **Name the skill that will dispatch the agent, if one exists.** An agent is dispatched by a skill, and knowing the caller tells the builder what the agent receives and what it must return. If the calling skill does not exist yet, the builder recommends [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md) to build it; [Create a new skill](./create-a-new-skill.md) is that recipe.

### Stage 2: Walk the design tree

1. **Answer one question at a time, in dependency order.** The builder never batches questions. It settles foundational decisions (which plugin, the single narrow domain, generate-or-evaluate) before identity (the role identity under 50 tokens, the domain vocabulary, the anti-patterns), before triggering (the description), before capabilities (model tier, tools) and body structure (the inlined protocol, graceful degradation).

2. **Take the recommendation, or redirect it.** Every question comes with a recommended answer and the evidence behind it. Anything the repository can answer (sibling agent descriptions, the skills that would dispatch this agent, conventions, the guidance) the builder answers by exploring, so you are only asked the questions evidence cannot settle.

3. **Push back on the model tier when your sense of the work differs.** The builder recommends a tier from the cognitive load: opus for synthesis and judgment, sonnet for structured procedures, haiku for fast lookups. The recommendation comes with its rationale; if the work is heavier or lighter than the builder read it, say so, and it resolves the dependent decisions from your redirect.

### Stage 3: Write, review, and wire up

1. **Let the builder write the single file and run the conformance review.** Everything the agent needs is inlined into one flat `.md` file: no `references/` folder, no `scripts/`, no context injection. After writing it, the builder re-reads every guidance document that applies and corrects the file directly: role-identity length, the description budget, self-containment violations, and an over-broad tool set, including removing the `Agent` tool, since subagents cannot spawn subagents. You see the result after the fixes land.

2. **Read the closing summary and the dispatch wiring.** The builder reports the agent's shape, which decisions it settled by evidence versus by you, the fixes the review applied with the guidance behind each, and how the agent is dispatched: the qualified `defining-plugin:agent-name` and the skill that calls it.

3. **Wire up the caller and exercise the path.** If the dispatching skill already exists, confirm it calls the new agent with the input the agent expects and consumes what it returns. If the skill does not exist yet, build it with [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md) before the agent has a way to run. An agent with no caller does nothing.

## Variations

- **The agent belongs in a brand-new plugin.** When there is no plugin to hold the agent, the builder scaffolds one: the `.claude-plugin/plugin.json` and the marketplace entry, built per the [configuration guidance](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/). You answer the same design-tree questions; the builder adds the plugin scaffold to what it writes. If that new plugin should build on Han, [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) covers wiring the dependency.

- **Your request bundles a generator and an evaluator.** When you ask for an agent that both produces something and judges it, the builder splits the request into two agents and explains why: a single agent that rates its own output carries self-evaluation bias. Decide which role you want first to avoid a mid-interview redirect, or accept the split and build both.

- **The work turns out to be a skill, not an agent.** If the design tree reveals the work is a deterministic, flowchartable process rather than a judgment layer, the builder stops and redirects you to [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md). Follow the redirect; [Create a new skill](./create-a-new-skill.md) is the matching recipe.

- **You only want the rules, not a finished agent.** When you are reviewing or hardening an existing agent rather than building a new one, reach for [`/guidance`](../skills/han.plugin-builder/guidance.md) instead. It serves the governing document for the question you have and cites it, without running an interview.

- **You expect to iterate.** Plugin entities rarely land in one pass. Build the agent, dispatch it from its caller against real input, bring back what missed, and rebuild the affected decisions rather than starting over.

## What you should expect

- **The domain and the vocabulary do the work.** An agent is good because its domain is narrow and its vocabulary is precise. If the agent's findings are shallow or off-target, the domain framing is usually too broad or the vocabulary too thin. That is where the next pass goes.
- **One role per agent is non-negotiable.** The builder will not produce an agent that both generates and evaluates. If you want both, you get two agents. This is the rule that keeps an agent's judgment honest.
- **YAGNI applies to the artifact.** Vocabulary terms, anti-patterns, tools, and frontmatter fields each have to earn their place against the agent's actual job. Anything added "for completeness" is cut during the review pass, which keeps the always-loaded description lean. See [YAGNI](../yagni.md) for the rule the discipline derives from.
- **No agents are dispatched to build yours.** `han.plugin-builder` depends on nothing and ships no agents, so the review is done inline by reading the guidance, not by a review team.

## Where to go next

- [Create a new skill](./create-a-new-skill.md) is the matching recipe when the work is a flowchartable process, or when you need to build the skill that dispatches your new agent.
- [`/agent-builder`](../skills/han.plugin-builder/agent-builder.md) is the skill long-form doc, canonical for what the builder does on its own.
- [`/guidance`](../skills/han.plugin-builder/guidance.md) serves the same rules the builder applies; reach for it when you want a citation, not a finished agent.
- [Agent-building guidance](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/) is the body of rules the interview and review enforce, readable directly.
- [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) is the next guide when your new agent lives in a new plugin that should build on Han.

## Related Documentation

- [Plugin landing page](../../README.md). Where the Han suite starts, and where the install commands live.
- [How-to index](./README.md). The rest of the end-to-end guides.
- [`/agent-builder`](../skills/han.plugin-builder/agent-builder.md). The skill long-form doc for the builder this guide drives.
- [Create a new skill](./create-a-new-skill.md). The sibling recipe for building a skill with `/skill-builder`.
- [`/guidance`](../skills/han.plugin-builder/guidance.md). Serves the authoring rules the builder applies, and vendors the builders into a repo.
- [Agent-building guidance](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/). The rules the builder's interview and review enforce.

# How To: Create a New Skill

A walkthrough for building a new Claude Code skill from scratch with [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md): describe what the skill should do, answer the interview that walks the skill's design tree decision-by-decision, and end with a real skill on disk that has already passed a guidance-conformance review. This is the recipe for *using* the builder; the [skill-building guidance](../../han.plugin-builder/skills/guidance/references/skill-building-guidance/) is canonical for the rules the builder enforces.

> See also: [How-to index](./README.md) · [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md) · [`/guidance`](../skills/han.plugin-builder/guidance.md) · [Create a new agent](./create-a-new-agent.md)

The happy path below builds a skill into a plugin that already exists, because that is the common case: you have a plugin and you want to add a slash command to it. When the skill belongs in a brand-new plugin, the [Variations](#variations) section covers the one extra thing the builder does for you.

## Before you begin

- You have installed the opt-in `han.plugin-builder` plugin. The `han` meta-plugin does not bundle it, so install it on its own first with `/plugin install han.plugin-builder@han`. See [Choosing a Han plugin](../choosing-a-han-plugin.md) for where it sits in the suite.
- You know roughly what the skill should do and what should trigger it. You do not need a finished design; the interview walks the tree for you. But a sharp one-line request ("a skill that turns a changelog into release notes, triggered when I say 'draft release notes'") lets the builder start walking immediately, where a thin one ("build a skill") makes it ask for this first.
- You have a sense of whether this is a skill at all. A skill is a deterministic, flowchartable process. If the work is a judgment layer that reasons over messy input rather than following steps, it is an agent, and the builder will stop and redirect you to [`/agent-builder`](../skills/han.plugin-builder/agent-builder.md). [Create a new agent](./create-a-new-agent.md) is the matching guide. When you are not sure which you want, [`/guidance`](../skills/han.plugin-builder/guidance.md) answers "is this better as a skill or an agent?" before you start.

## What you'll end up with

- A skill written into the target plugin at `{plugin}/skills/{skill-name}/SKILL.md`: frontmatter with a `name` matching the directory, a four-component `description` under 1024 characters, scoped `allowed-tools`, and a body of numbered process steps following the workflow pattern the interview settled.
- Any `references/`, `scripts/`, or `assets/` the skill needs, created only when a use case justified them. No empty or speculative folders.
- A closing summary from the builder: which decisions it settled by evidence versus which it asked you, the fixes the review pass applied with the guidance document behind each, and the triggering and functional tests derived from your use cases.

## The happy path

The workflow runs as one continuous interview, but it moves through three natural stages: you frame the skill, the builder walks the design tree with you, and then it writes and reviews the files. Each stage is a place you can stop and look at what you have.

### Stage 1: Frame the skill and name the plugin

1. **Run [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md) with one or two sentences on what the skill does and what triggers it.** Lead with the trigger and the outcome, not the mechanism. Two examples that give the builder enough to start:

    > `/skill-builder` *"I want a skill that summarizes the day's merged PRs into a standup update."*

    > `/skill-builder` *"Add a skill to han.github that closes stale issues after confirming with me."*

2. **Name the target plugin, or let the builder infer it.** If you name one ("add a skill to han.github"), the builder confirms it ships skills and reads its existing siblings. If you do not, it infers candidates from the repository and confirms with you before writing anywhere.

3. **Bring the two or three concrete use cases, or let the builder derive them.** These are the spine of the whole design: they drive the description's trigger phrases and become your test cases at the end. The sharper they are going in, the less the interview has to ask. If you only have a vague idea, the builder derives candidates and confirms them with you.

### Stage 2: Walk the design tree

1. **Answer one question at a time, in dependency order.** The builder never batches questions, because later answers routinely make earlier ones moot. It settles foundational decisions (which plugin, the use cases) before identity (name, description), before workflow (the pattern and the steps), before capabilities (tools, dispatch, scripts) and layout (body versus references versus scripts versus assets).

2. **Take the recommendation, or redirect it.** Every question comes with a recommended answer and the evidence behind it. Anything the repository can answer (sibling descriptions, conventions, the target `plugin.json`, the guidance documents) the builder answers by exploring, so you are only asked the questions evidence cannot settle. When a recommended workflow pattern or tool set is wrong for your case, say so; the builder resolves the dependent decisions from your redirect rather than starting over.

3. **Let it disambiguate the description against the siblings.** When the skill joins a plugin that already has skills, the description has to trigger for your cases and *not* trigger for the neighbors'. The builder reads the sibling descriptions and writes the new one to draw a clean line between them. This is the step that keeps two skills in the same plugin from fighting over the same prompts.

### Stage 3: Write, review, and test

1. **Let the builder write the files and run the conformance review.** Writing the `SKILL.md` is not the last step. The builder then re-reads every guidance document that applies to what it built and corrects the files directly: description length and component coverage, the `name`-matches-directory rule, progressive-disclosure layout, and an over-broad `allowed-tools` set. The interview gets each decision approximately right; this review pass makes the artifact correct. You see the result after the fixes land, not before.

2. **Read the closing summary.** The builder reports which decisions it settled by evidence versus by you, the fixes the review applied with the guidance document behind each, and the triggering and functional tests it derived from your use cases.

3. **Run the tests it hands you.** Exercise the triggering tests (does the skill activate on the prompts the use cases described, and stay quiet on the neighbors' prompts?) and the functional tests (does the workflow do what the use cases said?) against the model tier the skill targets. This is how you confirm the description disambiguates and the steps hold.

## Variations

- **The skill belongs in a brand-new plugin.** When there is no plugin to hold the skill, the builder scaffolds one: the `.claude-plugin/plugin.json` and the marketplace entry, built per the [configuration guidance](../../han.plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/). You answer the same design-tree questions; the builder adds the plugin scaffold to what it writes. If that new plugin should build on Han's skills and agents, [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) covers wiring the dependency.

- **The work turns out to be an agent, not a skill.** If the design tree reveals the work is a judgment layer rather than a flowchartable process, the builder stops and redirects you to [`/agent-builder`](../skills/han.plugin-builder/agent-builder.md). Follow the redirect; [Create a new agent](./create-a-new-agent.md) is the matching recipe. Forcing a judgment task into a skill's numbered steps produces a brittle skill that does its real work badly.

- **You only want the rules, not a finished skill.** When you are reviewing or hardening an existing skill rather than building a new one, reach for [`/guidance`](../skills/han.plugin-builder/guidance.md) instead. It serves the governing document for the question you have and cites it, without running an interview. `/guidance init` vendors the builders and the guidance into a repo so they run with no dependency on the plugin.

- **You expect to iterate.** Plugin entities rarely land in one pass. The builder says so and invites you to iterate on specific steps. Expect three to five passes for a non-trivial skill: build it, run the tests, bring back what missed, and rebuild the affected decisions rather than starting over.

## What you should expect

- **The description does most of the work, and it is the part most likely to need a second pass.** A skill triggers on its description. If your new skill activates on prompts meant for a sibling, or stays silent on prompts it should catch, the description is where you fix it. Run the triggering tests before you trust it.
- **YAGNI applies to the artifact.** Every step, reference file, tool permission, and frontmatter field has to earn its place against a real use case. Anything added "for completeness" or "for future flexibility" is cut during the review pass. See [YAGNI](../yagni.md) for the rule the discipline derives from.
- **No agents are dispatched.** `han.plugin-builder` depends on nothing and ships no agents, so the review is done inline by reading the guidance, not by a review team. Cost is dominated by the interview length and the just-in-time reads of the governing documents, not by a swarm.

## Where to go next

- [Create a new agent](./create-a-new-agent.md) is the matching recipe when the work is a judgment layer rather than a flowchartable process.
- [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md) is the skill long-form doc, canonical for what the builder does on its own.
- [`/guidance`](../skills/han.plugin-builder/guidance.md) serves the same rules the builder applies; reach for it when you want a citation, not a finished skill.
- [Skill-building guidance](../../han.plugin-builder/skills/guidance/references/skill-building-guidance/) is the body of rules the interview and review enforce, readable directly.
- [Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md) is the next guide when your new skill lives in a new plugin that should build on Han.

## Related Documentation

- [Plugin landing page](../../README.md). Where the Han suite starts, and where the install commands live.
- [How-to index](./README.md). The rest of the end-to-end guides.
- [`/skill-builder`](../skills/han.plugin-builder/skill-builder.md). The skill long-form doc for the builder this guide drives.
- [Create a new agent](./create-a-new-agent.md). The sibling recipe for building an agent with `/agent-builder`.
- [`/guidance`](../skills/han.plugin-builder/guidance.md). Serves the authoring rules the builder applies, and vendors the builders into a repo.
- [Skill-building guidance](../../han.plugin-builder/skills/guidance/references/skill-building-guidance/). The rules the builder's interview and review enforce.

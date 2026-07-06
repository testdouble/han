# /skill-builder

Operator documentation for the `/skill-builder` skill in the opt-in `han-plugin-builder` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-plugin-builder/skills/skill-builder/SKILL.md`](../../../han-plugin-builder/skills/skill-builder/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [How to create a new skill](../../how-to/create-a-new-skill.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Builds a new Claude Code skill from scratch through a relentless, evidence-based interview that walks the skill's design tree decision-by-decision. It then reviews the finished files against the plugin-building guidance and applies every fix it finds.
- **When to use it.** When you want to create, author, scaffold, or design a new skill or slash command and want it to conform to the established authoring rules without your having to remember them.
- **What you get back.** A real skill on disk (`{plugin}/skills/{skill-name}/SKILL.md` plus any `references/`, `scripts/`, or `assets/` a use case justified) that has already passed a guidance-conformance review.

## Key concepts

- **Interview-driven, one question at a time.** The skill interviews you relentlessly, walking each branch of the design tree and resolving dependencies between decisions one at a time. It never batches questions; later answers routinely make earlier ones moot.
- **Explore before asking.** Any question the repository can answer (the target plugin's existing skills, sibling descriptions, `plugin.json`, conventions, the guidance documents) it answers by exploring instead of asking you.
- **Recommend, then ask.** Every question surfaced to you comes with a recommended answer and its rationale, grounded in evidence. You accept, amend, or redirect.
- **The design tree.** Foundational decisions (which plugin, the 2-3 use cases) settle before identity (name, description). Identity settles before workflow (pattern, steps, human gates), which settles before capabilities (tools, dispatch, scripts) and layout (body vs. references vs. scripts vs. assets).
- **Apply-as-you-go, verify-at-the-end.** The interview consults the governing guidance document when a decision is on the table; a final review pass re-reads every relevant document and corrects the finished files. The interview gets each decision approximately right; the review pass makes the artifact correct.
- **Self-contained review.** `han-plugin-builder` depends on nothing and ships no agents, so the review is done inline by reading the guidance, not by dispatching a review team.

## When to use it

**Invoke when:**

- You want to author a brand-new skill or slash command and have it conform to the description-frontmatter, naming, progressive-disclosure, and instruction-quality rules.
- You have a rough idea for a skill but want the design tree walked so the use cases, triggers, tools, and layout are settled deliberately rather than guessed.
- You are scaffolding a skill into an existing plugin and want its description to disambiguate cleanly against its new siblings.

**Do not invoke for:**

- **Building an agent or subagent.** Use [`/agent-builder`](./agent-builder.md) instead.
- **Reading the rules without building anything.** Use [`/guidance`](./guidance.md) to serve the relevant guidance, or `/guidance init` to vendor the plugin-building skills (including this one) into a repo.
- **Restructuring or reviewing an existing skill's code.** This skill authors a new skill; it is not a code-review or refactor tool.

## How to invoke it

Run `/skill-builder` in Claude Code.

The skill ships in the opt-in `han-plugin-builder` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han-plugin-builder@han`. See [Choosing a Han plugin](../../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **One or two sentences on what the skill should do and what triggers it.** A thin request ("build a skill") makes the skill ask for this first. A sharp one ("a skill that turns a changelog into release notes, triggered when I say 'draft release notes'") lets it start walking the tree immediately.
2. **The target plugin, if you know it.** If you do not name one, the skill infers candidates from the repository and confirms with you.
3. **Any context to respect.** Existing sibling skills, conventions, an external tool the skill must drive (gh, jq, an MCP server).

Example prompts:

- `/skill-builder`. *"I want a skill that summarizes the day's merged PRs into a standup update."*
- `/skill-builder`. *"Add a skill to han-github that closes stale issues after confirming with me."*

## What you get back

A skill written into the target plugin:

- **`{plugin}/skills/{skill-name}/SKILL.md`**, the skill definition. Frontmatter carries `name` matching the directory, a four-component `description` under 1024 characters, scoped `allowed-tools`, and any other settled fields. The body is a set of numbered process steps following the chosen workflow pattern.
- **`{plugin}/skills/{skill-name}/references/`, `scripts/`, or `assets/`**, created only when a use case justified them. Domain knowledge (templates, checklists, matrices) lands in `references/`; deterministic operations in `scripts/`; output-only files in `assets/`. No empty or speculative folders.
- **A new plugin scaffold**, if the skill belongs in a brand-new plugin: the `.claude-plugin/plugin.json` and marketplace entry, built per the configuration guidance.

The skill closes by summarizing the decisions settled by evidence versus by you, and the fixes the review pass applied (with the guidance document behind each). It also hands you the triggering and functional tests derived from the use cases.

## How to get the most out of it

- **Bring the use cases, or let it derive them.** The 2-3 concrete use cases drive the description's trigger phrases and become your test cases. The sharper they are going in, the less the interview has to ask.
- **Push back during the interview.** Every recommendation is a proposal. If a recommended workflow pattern or tool set is wrong for your case, say so; the skill resolves dependent decisions from your redirect.
- **Trust the review pass, then run the tests.** The Step 6 conformance review fixes description length, naming, progressive-disclosure, and `allowed-tools` problems before you ever see them. After it lands, run the triggering and functional tests it hands you against the model tier the skill targets.
- **Plan for iteration.** Plugin entities rarely land in one pass. Expect 3-5 iterations; the skill says so and invites you to iterate on specific steps.

## YAGNI

The skill applies an evidence-based YAGNI discipline to the artifact it builds: every step, reference file, tool permission, and frontmatter field must earn its place against a real use case. Anything added "for completeness" or "for future flexibility" is cut during the Step 6 review. This keeps the new skill's body focused on process and its frontmatter free of speculative knobs. See [YAGNI](../../yagni.md) for the rule the discipline derives from.

## Cost and latency

No agents are dispatched; the review is inline. Cost is dominated by the interview length and the just-in-time reads of the governing guidance documents (one or two per decision, not the whole set). A simple skill settles in a handful of exchanges; a skill with an external dependency, scripts, and a new plugin scaffold takes longer. Built for a deliberate, conversational session, not a tight automated loop.

## In more detail

The workflow runs in seven steps: capture the request and confirm a skill is the right entity (not an agent or hook); discover the target plugin and its conventions; and build the design tree in dependency order. Then it runs the interview loop one branch at a time; writes the skill files; runs the full guidance-conformance review; and presents the result with tests. Each design-tree decision maps to a specific governing document (use-case planning, naming conventions, description frontmatter, progressive disclosure, workflow patterns, allowed-tools, and so on). It is read only when that decision is on the table. The review pass re-reads each document that applies to what was built and corrects the files directly rather than reporting problems back to you.

## Sources

The skill's design tree and review checklist are grounded in the plugin's own authoring guidance, which in turn cites external practice.

### Anthropic, Agent Skills best practices and Building effective agents

The use-case-first planning, the description rules, and the workflow patterns (sequential, iterative, routing, orchestration) trace to Anthropic's skill authoring and agent-building guidance.

URL: https://www.anthropic.com/engineering/building-effective-agents

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [How to create a new skill](../../how-to/create-a-new-skill.md). The end-to-end recipe for driving this skill, with the prompts, the stages, and what to expect.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule the skill applies to the artifact it builds.
- [`/agent-builder`](./agent-builder.md). The sibling builder for agents; reach for it when the work is a judgment layer rather than a flowchartable process.
- [`/guidance`](./guidance.md). Serves the same authoring guidance this skill applies, and its `init` vendors this skill (with `guidance` and `agent-builder`) into a repo; use it when you want the rules, not a finished skill.
- [Skill-building guidance](../../../han-plugin-builder/skills/guidance/references/skill-building-guidance/). The rules the skill's interview and review enforce, readable directly.

# How-To Guides

End-to-end recipes that walk a whole loop: what to type, what decisions you make between steps, and what you should expect along the way. Two kinds live here. Most guides are workflow recipes for *using* Han on a real piece of work. A second set covers *extending* Han: building a plugin on top of it, and authoring the skills and agents that go in a plugin.

> See also: [Plugin landing page](../../README.md) · [Quickstart](../quickstart.md) · [Concepts](../concepts.md)

How-to guides are for people who already know roughly what the plugin does and want to use it on a real piece of work. If you are not there yet, start with [Concepts](../concepts.md) and the [Quickstart](../quickstart.md).

The skill long-form docs in [docs/skills/](../skills/README.md) are canonical for what each individual skill does on its own. These how-tos are canonical for the multi-skill workflows the plugin was built to support. When in doubt, the skill doc tells you what the skill does; the how-to tells you how to run a workflow that uses several skills together.

## Which guide do you need?

### Using Han on a real piece of work

- **[Plan a feature, end to end](./plan-a-feature.md).** You have a feature idea and want a behavioral spec, an implementation plan, and a list of independently grabbable work items, grounded in evidence rather than your best guess. The longest of these; covers most of the planning skills.
- **[Revise a plan after the build has started](./revise-a-plan.md).** You already planned the work and started building, and now a later work item needs refining or an earlier decision no longer holds, and you want to change the right planning document and keep the others consistent rather than editing code and letting the plan drift.
- **[Accelerate your understanding of unfamiliar code](./accelerate-understanding-of-unfamiliar-code.md).** You have landed in code you do not know and want a fast mental model, then a grounded, written artifact that you, your team, and Claude can all read again later instead of re-deriving it every time. Covers `/code-overview`, `/project-documentation`, and the Confluence wrappers that share the result.
- **[Triage and investigate a bug](./triage-and-investigate-a-bug.md).** Something is broken or behaving oddly and you want a root cause backed by evidence, not a guess. Or the work is queued rather than immediate, and you want a structured triage document instead.
- **[Run an effective code review](./run-an-effective-code-review.md).** A branch is ready to merge and you want a review whose findings are worth acting on, not a generic nit list. Covers the four levers that make AI review useful (feed it the context you had, scope it, filter the output, own the result) across `/code-review` and `/post-code-review-to-pr`.
- **[Research a decision and capture it](./research-a-decision.md).** Nothing is broken; you have a question (a new library, a hosting move, a build-vs-buy call) and want the options, prior art, and a recommendation, then record the chosen direction as an ADR.
- **[Provide feedback on Han](./provide-feedback.md).** You want to tell the maintainers something: an idea or complaint you sharpen with `/issue-triage` before posting, or a report on how the skills performed in a session you just ran, summarized and posted by the opt-in `han-feedback` plugin.

### Extending Han with a plugin of your own

- **[Extend Han with plugin dependencies](./extend-han-with-plugin-dependencies.md).** You want to understand how one plugin builds on another through the `dependencies` field, using Han's own `han-core` / `han-github` / `han` split as the worked example. The conceptual half: how the mechanism works and why Han is built this way.
- **[Build a plugin that depends on Han](./build-a-plugin-that-depends-on-han.md).** You are ready to stand up a new plugin that depends on `han-core`, add a skill that builds on it, and confirm a clean install pulls Han in alongside it. The hands-on half, with both the suite-internal and own-marketplace paths.

### Authoring a skill or agent with the plugin builder

- **[Create a new skill](./create-a-new-skill.md).** You want to build a new slash command and have it conform to the authoring rules without remembering them. Drives `/skill-builder` through the interview that walks the skill's design tree, then writes and reviews the files. Needs the opt-in `han-plugin-builder` plugin.
- **[Create a new agent](./create-a-new-agent.md).** You want to build a new subagent (a judgment layer a skill dispatches) and have it conform to the domain-focus, model-selection, and self-containment rules. Drives `/agent-builder` through its design-tree interview, then writes and reviews the single self-contained file. Needs the opt-in `han-plugin-builder` plugin.

## Where to go next

- Pick a guide above and follow the **happy path** (the most common way through the workflow, named explicitly in each guide).
- Skim the [Skills Index](../skills/README.md) if you want to know what every individual skill does.
- Read [Sizing](../sizing.md) if a step in a guide says "small / medium / large" and you want to know how the team scales.
- Read [YAGNI](../yagni.md) if a skill defers something to a "Deferred (YAGNI)" section and you want to know why.

### About these guides

Every guide opens with two short blocks: **Before you begin** (prerequisites the workflow assumes) and **What you'll end up with** (the artifacts and outcomes you should expect). The steps are grouped into named phases of three to four items each (occasionally up to six when a phase is a natural unit), and each phase is a natural pause point where you can stop and look at what you have. Decision points inside a step are written inline as "if X, do Y; otherwise, do Z" rather than as separate tracks. Each guide documents the **happy path** first and groups variations (different starting points, optional follow-ons) under a final **Variations** section. When you are new to a workflow, follow the happy path. Come back for variations once you understand what each step produces.

# How To: Accelerate Your Understanding of Unfamiliar Code

A walkthrough for getting from "I have never seen this code before" to a mental model you can act on, fast, and then turning that model into a grounded, written artifact that you, your teammates, and Claude can all read again later instead of re-deriving it from scratch every time.

> See also: [How-to index](./README.md) · [Quickstart](../quickstart.md) · [Skills](../skills/README.md)

## Before you begin

Landing in code you do not know can an imposter-syndrome inducing experience for an engineer. And, the research literature on code comprehension is consistent about why: you understand new code by building a mental model in layers, the control flow first, then the data flow and the goals on top of it, and you do it by following "information scent," the cues in names, call chains, and module boundaries that tell you where to look next. An LLM is good at this kind of foraging, because it navigates a codebase the same way you would, reading files, running grep, and following references. That is what this guide is built on.

There is one finding worth carrying through every step. A controlled study of developers working on legacy code with an AI assistant found that they finished their tasks faster but understood the code no better, and the one thing that separated the people who did build understanding from the people who did not was verification: the people who understood the code checked what the AI told them against the real source far more often. So the whole shape of this guide is "let Claude orient you, then check it against the code," not "read the summary and move on."

- You have a target you can name sharply. A file, a directory, a symbol, or a pull request. "The whole backend" is too thin; `/code-overview` will ask you to narrow it. If you genuinely do not know where the feature lives yet, that is fine, you start broad and drill in, but you still name the broad thing.
- You have the project checked out and, for the PR path, git available locally. The orientation step reads real source, so it needs the source.
- You know roughly what you are trying to do with the code. Reviewing a PR, fixing a bug, extending a module, and getting onboarded are different goals, and they send you down different branches of this guide. Hold the goal in mind; the variations at the end key off it.
- For the team-knowledge-base part at the end, you have a configured Atlassian MCP server. That part is optional. The in-repo path works with nothing but the plugin.

## What you'll end up with

- A fast, throwaway orientation to the code, produced by [`/code-overview`](../skills/han-coding/code-overview.md): a purpose statement, a Mermaid flow chart, the directly related context, and a where-to-start section, written to a scratch file outside the repo. This is the "understand it now" artifact.
- Optionally, a deeper read of the part that matters: a structural and risk assessment from [`/architectural-analysis`](../skills/han-coding/architectural-analysis.md) when you are about to change the code, or a root-caused investigation from [`/investigate`](../skills/han-coding/investigate.md) when something is broken.
- A durable, grounded feature doc in the repo, produced by [`/project-documentation`](../skills/han-core/project-documentation.md): real code examples, absolute file paths, and a reference added to `CLAUDE.md` so future Claude sessions read it automatically. This is the "remember it later" artifact, and it is the one that makes the cost of understanding pay off more than once.
- Optionally, that same understanding published to a shared space your whole team and Claude can reach, through the Atlassian wrapper skills.

When you have the orientation and the durable doc, the understanding has moved out of your head and one chat session and into an artifact anyone can check and correct.

## The happy path

The workflow has three phases. Phase 1 orients you fast and throwaway. Phase 2 goes deep where it matters. Phase 3 makes the understanding durable and shared. Most onboarding jobs use Phase 1 and Phase 3; Phase 2 is for when you are about to change the code or chase a bug.

### Phase 1: Get oriented fast

1. **Run [`/code-overview`](../skills/han-coding/code-overview.md) on your target.** This is the first thing you reach for in unfamiliar code. Point it at a file, a directory, a symbol, or a PR.

    > `/code-overview {path or symbol or PR}`

    A few filled-in examples:

    > `/code-overview src/auth/` for *"help me understand the auth module before I work on it."*

    > `/code-overview #82` for *"walk me through pull request 82 so I know how to review it."*

    > `/code-overview` with no argument on a feature branch, for *"explain what the changes on this branch do before I review them."*

    The skill classifies the target as small, medium, or large, dispatches that many `codebase-explorer` agents to read the real source in parallel, and writes the overview itself. It leads with what the code does and why, then the main flow as a Mermaid chart, then the context and uses, then where to start. That ordering is progressive disclosure on purpose: the most important understanding comes first, so if you stop reading after the purpose statement you are still oriented correctly. The overview raises no findings about whether the code is any good; it is orientation, not judgment.

2. **Open the overview where the charts render, and read it against the code.** The skill writes the file to a scratch location outside the repo and shows you the path. Read it, but do not stop at reading. Open the entry points it names in the where-to-start section and confirm they say what the overview says they say. This is the verification step the research is emphatic about: the value comes from checking the explanation against the real source, not from consuming it passively. The overview is grounded in actual files and real paths precisely so you can do this quickly.

3. **Re-run larger, or drill in, when coverage is partial.** If the target was bigger than the chosen size could cover, the overview adds a coverage note right after the header, naming what it skipped and the next size up. Re-run at the larger size for a fuller picture (`/code-overview large src/billing/`), or pick the one submodule that matters and run a focused small overview on that. Starting broad and narrowing is the normal motion when you did not know where the feature lived.

At the end of Phase 1 you have a working mental model and a sense of where the important code is. For a quick review or a small change, that may be all you need; skip to Phase 3 if you want to write it down, or stop here if the overview was a one-time orientation.

### Phase 2: Go deeper where it matters

Reach for this phase when the orientation showed you that you need more than a map, either because you are about to change the structure or because something is broken.

1. **Run [`/architectural-analysis`](../skills/han-coding/architectural-analysis.md) when you are about to change the code.** An overview tells you how the code flows; it does not tell you where the coupling is, which seams are load-bearing, or what will break if you pull on a given thread. When you are going to modify an unfamiliar module, that structural read is what keeps you from a surprise.

    > `/architectural-analysis src/billing/` for *"assess the structure, coupling, and risk of the billing module before I refactor it."*

    The skill examines structural coupling, data flow, concurrency, and risk, and tells you where the design will resist the change you have in mind.

2. **Run [`/investigate`](../skills/han-coding/investigate.md) when the reason you are in this code is that it is broken.** Understanding unfamiliar code and diagnosing a failure in it are different jobs. If you came here because of a bug, the overview gets you oriented and then `/investigate` finds the root cause with evidence, file paths, line numbers, and git history, rather than a guess.

    > `/investigate the checkout total is wrong when a coupon and a gift card are both applied`

3. **Feed what you learned back into your mental model.** Both of these skills produce evidence-backed findings tied to real locations. Read them the same way you read the overview: against the code. By the end of Phase 2 you understand not only how the code works but where it is fragile or why it is failing.

### Phase 3: Make the understanding durable and shared

This is the phase that makes the whole effort pay off more than once. An overview is a scratch file; a chat session ends. If the understanding only ever lives in those places, the next person, or you in three months, or Claude in a fresh session, pays the full cost of building it again. Worse, an LLM asked to re-explain a module from memory each time can confabulate it differently each time. The defense is a grounded artifact written down once and corrected once.

1. **Run [`/project-discovery`](../skills/han-core/project-discovery.md) first if the project has not been scanned.** It finds the docs directory and aligns the doc's code fences with the project's actual stack, so the durable doc lands in the right place in the right language.

2. **Run [`/project-documentation`](../skills/han-core/project-documentation.md) to write the understanding into the repo.** Where `/code-overview` is the ephemeral, understand-now counterpart, this is the durable one: it writes a maintained `docs/{feature}.md` with real code examples and absolute paths.

    > `/project-documentation document the authentication system` for *"turn what I now understand about auth into a doc the repo keeps."*

    The skill explores the code again with `codebase-explorer` agents so the doc is grounded in the source rather than in your recollection, leads with behavior (summary, how it works, primary flows) before the technical reference, and, importantly for this workflow, adds a reference to the new doc in `CLAUDE.md`. That last step is what makes the doc readable by both audiences: you can open it, and every future Claude session reads it as project context automatically, so the next time anyone asks about this code the answer starts from a checked artifact instead of a fresh, possibly-wrong re-derivation.

3. **Review the doc against the code one more time.** Same discipline as every other step. The skill grounds the doc in real files, so check that the examples and paths are right. When you correct something here, you correct it for everyone who reads the doc later, human or AI.

4. **Publish it to a shared space when the team needs it, not only the repo.** A `CLAUDE.md`-referenced doc in the repo is enough for you and for Claude working in that repo. When the understanding needs to live somewhere the whole team reads, and somewhere Claude can reach through the Atlassian MCP server, use the wrapper skills:

    - [`/project-documentation-to-confluence`](../skills/han-atlassian/project-documentation-to-confluence.md) writes the durable feature doc and publishes it to a Confluence space or page in one move.
    - [`/code-overview-to-confluence`](../skills/han-atlassian/code-overview-to-confluence.md) does the same for the orientation overview when you want to share the fast map (for example, on a PR a few people are about to review) rather than a maintained doc.

    Both require a configured Atlassian MCP server. The point of this step is the compounding one from the research: a shared, grounded artifact lowers your team's bus factor and means the next person to touch this code reads and corrects an explanation instead of building one from nothing.

## Variations

- **You are reviewing a PR, not onboarding.** Run `/code-overview` with no argument on the branch, or `/code-overview #82` on a specific PR, to understand what the change does and how to look at it. Then run `/code-review` to judge it. The overview orients you; the review evaluates the work. Do not use the overview as a review; it raises no findings on purpose.

- **The code is broken and that is why you are here.** Phase 1 still orients you fast, but the main event is `/investigate` from Phase 2, not `/project-documentation`. Document afterward only if the fix changed how the feature behaves.

- **You do not know where the feature lives.** Start with a broad `/code-overview` at medium or large size over the directory you suspect, read the where-to-start section, then run a focused small overview on the submodule it points you at. The coverage note tells you when the first pass was partial.

- **You want the understanding shared but do not use Confluence.** The in-repo path is the whole point: `/project-documentation` writes the doc into `docs/` and references it from `CLAUDE.md`. That already makes it readable by you, your teammates who pull the repo, and Claude in any future session. The Atlassian wrappers are for when the audience is wider than the repo.

- **The overview surfaced a decision or a convention, not only behavior.** If understanding the code turned up an architectural choice nobody recorded, capture it with [`/architectural-decision-record`](../skills/han-core/architectural-decision-record.md). If it turned up a pattern the team should follow, capture it with [`/coding-standard`](../skills/han-coding/coding-standard.md). Documentation describes how the code works; those two capture why it was decided and what the rule is.

## What you should expect at each step

- **The overview is throwaway, the doc is durable.** `/code-overview` writes to a scratch file outside the repo and is never committed or maintained; it is a point-in-time map. `/project-documentation` writes a maintained doc into the repo tree. Reach for the first to understand now and the second to remember later. Mixing them up is the most common mistake.
- **Everything is grounded in real source, so check it against real source.** Every skill in this guide reads actual files and cites real paths. That grounding exists so you can verify, which the research says is the step that turns reading into understanding. Open the files the artifacts name.
- **Once a doc is referenced from `CLAUDE.md`, Claude reads it on its own.** The reference `/project-documentation` adds is not decoration. In later sessions, when Claude explores the codebase, it reads that doc as project context, so the understanding you captured flows into every future planning, review, and overview pass without you doing anything else.
- **Sizing is read from the target, not the prompt length.** `/code-overview` and `/architectural-analysis` classify the target and scale their agent rosters, defaulting to small and escalating only on a clear signal. Pass `small`, `medium`, or `large` as the first argument when you already know the target is bigger than the default. See [Sizing](../sizing.md).

## Where to go next

- [`/code-review`](../skills/han-coding/code-review.md) is the judgment counterpart to `/code-overview`: orient with the overview, then evaluate the change with the review.
- [Triage and investigate a bug](./triage-and-investigate-a-bug.md) is the matching how-to when the reason you are in unfamiliar code is that something is broken.
- [Plan a feature, end to end](./plan-a-feature.md) is the right next step when understanding the code was the prelude to building on it.
- The skill long-form docs cover each step in depth: [code-overview](../skills/han-coding/code-overview.md), [architectural-analysis](../skills/han-coding/architectural-analysis.md), [investigate](../skills/han-coding/investigate.md), [project-discovery](../skills/han-core/project-discovery.md), [project-documentation](../skills/han-core/project-documentation.md), and the Atlassian wrappers [project-documentation-to-confluence](../skills/han-atlassian/project-documentation-to-confluence.md) and [code-overview-to-confluence](../skills/han-atlassian/code-overview-to-confluence.md).
</content>

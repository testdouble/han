# /stakeholder-summary

Operator documentation for the `/stakeholder-summary` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.reporting/skills/stakeholder-summary/SKILL.md`](../../han.reporting/skills/stakeholder-summary/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md)

## TL;DR

- **What it does.** Turns a feature specification into a plain-language stakeholder summary you can share before implementation kicks off.
- **When to use it.** You have a feature spec written and want stakeholder feedback on shape, scope, and trade-offs before the team starts building.
- **What you get back.** A `stakeholder-summary.md` file next to the source spec, with Mermaid diagrams for user experience and data flow.

## Key concepts

- **Stakeholder-shaped, not engineer-shaped.** The document is for non-technical readers. No file paths, no API shapes, no database tables — just the customer problem, the experience, the before-and-after, and the open questions.
- **Diagrams replace prose.** A user-experience flowchart and before-and-after data-flow diagrams carry most of the weight. The text frames them, but the diagrams do the explaining.
- **Feedback before kickoff.** The closing questions ask stakeholders to confirm framing and scope, not to make technical decisions.

## When to use it

**Invoke when:**

- A feature specification exists and you want to share it with non-technical stakeholders for feedback.
- Leadership, product, or customer-facing stakeholders need to greenlight a feature before implementation starts.
- You want a one-page artifact that sits next to the full spec for stakeholder use.

**Do not invoke for:**

- **Writing the spec itself.** Use [`/plan-a-feature`](./plan-a-feature.md) instead.
- **Sequencing the build.** Use [`/plan-a-phased-build`](./plan-a-phased-build.md) instead.
- **Producing an implementation plan.** Use [`/plan-implementation`](./plan-implementation.md) instead.

## How to invoke it

Run `/stakeholder-summary` in Claude Code.

Give it:

1. **The source specification.** Usually `feature-specification.md`, but any feature spec, PRD, or design document works. The summary lands in the same directory.
2. **Optional shaping context.** Audience ("this is going to leadership"), emphasis ("lean into the customer-trust angle"), or anything else that should shape tone.

Example prompts:

- `/stakeholder-summary docs/features/share/feature-specification.md`
- `/stakeholder-summary docs/features/share/feature-specification.md — emphasize the customer-trust angle for leadership`

## What you get back

One file: `stakeholder-summary.md`, written in the same directory as the source spec. It opens with a title heading, then has six sections in fixed order:

1. **What problem are we solving?** — customer-voice framing plus the capabilities introduced.
2. **What does this open up?** — outcomes the feature unblocks.
3. **What will the user experience look like?** — paragraph plus a Mermaid `flowchart TD`.
4. **How does the data flow today vs. after this change?** — Mermaid `flowchart LR` diagrams for today and each after-this-change path.
5. **What is intentionally not in this slice?** — explicit deferrals from the source spec.
6. **What we are asking stakeholders.** — open questions in stakeholder language.

## How to get the most out of it

- **Write the spec first.** The summary derives from the spec — the cleaner the spec, the better the summary. Pair with [`/plan-a-feature`](./plan-a-feature.md) before this.
- **Name your audience.** Leadership, customers, and product reviewers read for different things. Tell the skill who will receive it.
- **Confirm the "intentionally not in this slice" list.** That section is where stakeholder pushback usually happens — make sure it matches what the spec actually defers.
- **Pair with `/plan-a-phased-build` next.** Once stakeholders greenlight the shape, sequence the build.
- **Render it to HTML with `/html-summary`.** When you want an executive-styled, self-contained HTML version of the summary to open in a browser or hand off, run [`/html-summary`](./html-summary.md) on the `stakeholder-summary.md` this skill produces.
- **Cross-repo planning folders are supported.** If the source spec lives outside the current working directory (for example, a planning folder for a different project), the skill reads that project's `CLAUDE.md` to pick up its vocabulary and naming conventions — not the cwd's.

## Cost and latency

Single-pass authoring with no sub-agent dispatch. Reads the source spec, drafts the summary, writes it once, and self-checks. Built for tight-loop iteration — re-run it after the spec changes.

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [`/plan-a-feature`](./plan-a-feature.md). Produces the feature specification this skill consumes.
- [`/plan-a-phased-build`](./plan-a-phased-build.md). The natural next step once the summary lands stakeholder feedback.
- [`/plan-implementation`](./plan-implementation.md). Turns the spec into an implementation plan after stakeholders sign off.
- [`/html-summary`](./html-summary.md). Converts the `stakeholder-summary.md` this skill produces into a self-contained HTML executive report.

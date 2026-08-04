# Long-form Doc Coverage Rule

Every skill and agent in the han plugin gets a long-form doc. No exceptions.

## The Rule

When you add a new skill, you create a long-form doc in `{plugin}/docs/skills/{name}.md` using
[the skill template](./skill-long-form-template.md).

When you add a new agent, you create a long-form doc in `{plugin}/docs/agents/{name}.md` (today that plugin is
`han-core`, `han-communication`, `han-research`, or `han-planning`, the only agent-owning plugins) using
[the agent template](./agent-long-form-template.md).

The long-form doc lands in the same pull request as the skill or agent definition. Not as a follow-up. Not "when there's
time."

## Why this rule

Earlier versions of the plugin used a tiered coverage rule that left simple agents and skills without long-form docs.
That model produced two problems:

1. **Inconsistent reader experience.** Some agents had rich docs; others linked straight to the SKILL.md or the agent
   definition. Readers learned which agents had docs and which didn't, which is exactly the wrong thing to learn.
2. **Drift over time.** Agents that started simple grew into multi-mode tools, and the missing long-form doc was hard to
   schedule retroactively.

The simpler rule (every skill and every agent has a doc) removes both problems.

The cost is small per agent: a screen or two of structured content explaining when to use it, how to invoke it, and how
to get the most out of it.

## What goes in the long-form doc

Each long-form doc answers the same questions:

- **What it does.** One sentence the reader can act on.
- **When to dispatch it.** The single strongest trigger plus the named anti-cases (when to use a different agent
  instead).
- **What you get back.** The artifact, return shape, and ID scheme.
- **Key concepts.** The vocabulary and posture the agent or skill brings.
- **How to invoke it.** Inputs, optional flags, example prompts.
- **How to get the most out of it.** Levers, pairings with other agents or skills.
- **Cost and latency.** Model tier, typical run shape, when to avoid tight loops.
- **YAGNI** (when applicable). Which rule the agent or skill enforces.
- **Sources.** The named frameworks the agent or skill draws from.
- **Related documentation.** Cross-references to sibling agents, dispatching skills, and contributor guidance.

The skill and agent templates in this folder lay out the section order. Follow it.

## The inline-guidance variant

One family of skills does not fit the template's headings, and its docs deviate on purpose. An **inline-guidance skill**
runs in a calling skill's context and hands control straight back. A person never invokes it, and it returns no artifact.
Today that family is [`readability-guidance`](../../han-communication/docs/skills/readability-guidance.md) and
[`explanation-guidance`](../../han-communication/docs/skills/explanation-guidance.md).

Their docs carry this section list, in this order:

```markdown
## TL;DR

## Key concepts

## When it is used

## How it works

## Cost and latency

## Troubleshooting

## Related documentation
```

Three headings are renamed and four are dropped, each for a reason that follows from the skill having no operator and no
output:

- **`When to use it` becomes `When it is used`.** The reader is not the one deciding to invoke it; a calling skill is.
- **`How to invoke it` becomes `How it works`.** There is nothing for a person to invoke, so the section describes the
  mechanism instead.
- **`Troubleshooting` replaces `What you get back`.** Nothing comes back. What a reader needs is what to do when the
  standard fails to surface.
- **`How to get the most out of it` and `Sources` are dropped.** There are no invocation levers to tune, and the standard
  the skill surfaces carries its own citations.

Use this variant only for a skill that both runs inline in the caller's context and produces no deliverable. A skill an
operator invokes directly follows the full template, even when its output is small.

## What is _not_ the long-form doc

The long-form doc does not duplicate the SKILL.md or agent definition. The definition is the implementation: protocols,
anti-patterns, output formats, the agent's internal vocabulary. The long-form doc is the operator manual: when to reach
for it, what to expect back, and how to wire it into the workflow.

If you find yourself copy-pasting from the definition into the long-form doc, stop. Cite the section in the definition
and explain when the operator would care about it.

# Han Concise

Operator documentation for the `Han Concise` output style in the han plugin. This document helps you decide _when_ and
_how_ to select the style. For the instructions it adds to the system prompt, read the style itself at
[`han-communication/output-styles/han-concise.md`](../../output-styles/han-concise.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Readability](../../../docs/readability.md)

## TL;DR

- **What it does.** Holds the shared readability standard and the writing voice across every turn of a session, and
  adds a brevity property: no preamble, no recap, no sentence that carries neither a fact nor a needed transition, and
  detail rolled up into the statement it supports.
- **When to select it.** Turn it on for a working session you read in the terminal, where you want the answer and not
  the narration.
- **What it changes.** How work is written up, not how it is done. It keeps Claude Code's software engineering
  instructions, so coding behavior is unchanged.

## Key concepts

- **The short-form sibling of `Han Readability`.** Both styles carry the same audience frame, output properties,
  writing voice, blocklist, and prose-only scope.
  [`Han Readability`](./han-readability.md) preserves every fact at full precision.
  `Han Concise` adds the brevity property and rolls detail up instead.
- **A standing selection, not a call.** The style is text Claude Code appends to the system prompt once, at session
  start. You pick it in `/config` and it applies until you pick something else.
- **It assumes you want less, rather than making you ask.** Detail rolls up into the statement it supports whenever it
  adds no meaningful value or clarification: nine near-identical passing checks become "all nine passed". The roll-up
  has to be true of everything it covers, so a roll-up is never a blur. "Was sometimes slow" does not stand in for
  "exceeded 340ms in three of ten windows", because it drops the magnitude and the frequency you would judge it by.
- **Three things stay at full precision.** A fact whose loss would change what you do next, a number you will act on,
  and a stated condition that bounds when a claim holds. Everything else is a candidate for the roll-up. Ask what was
  left out and you get it in full.
- **A derived copy, with two deliberate departures.** The style distills
  [`readability-rule.md`](../../references/readability-rule.md) and the blocklist in
  [`writing-voice.md`](../../references/writing-voice.md). Those two files stay authoritative on everything else. The
  brevity property and the roll-up rule that replaces the canonical `Fidelity wins` section are this style's own, and
  are deliberately kept out of the rule, so Han's skills are unaffected by either.

## When to select it

**Select it when:**

- You read the session in the terminal and want the result first, without the lead-in or the closing summary.
- You keep re-prompting for the same corrections: skip the preamble, drop the recap, get to the answer.
- The work is iterative and conversational, so each turn's framing is context you already have.

**Leave it off when:**

- The session's output is a document someone reads cold, where the connective prose earns its place. Use
  [`Han Readability`](./han-readability.md) instead.
- You need a configured `writing-voice` profile to apply. Neither style can read one; see
  [What it does not reach](#what-it-does-not-reach).

## How to select it

1. Install `han-communication`, or install `han` to get it with the bundled suite.
2. Run `/config` and choose **Han Concise** under **Output style**.
3. Start a new session or run `/clear`. Claude Code reads the output style once at session start, so the change does not
   take effect mid-session.

Claude Code saves the choice to `.claude/settings.local.json` at the project level. To set it without the menu, write the
`outputStyle` field directly:

```json
{
  "outputStyle": "Han Concise"
}
```

## What it changes

Every response is written for a capable reader who did not do the work. The main point comes first, each paragraph
carries one idea, headings name their content, and sentences stay short and active. Terms the reader cannot look up get
a half-sentence explanation at first use, and the vocabulary blocklist applies, so the hype words and the AI-slop
phrases do not appear.

Responses are also shorter than under `Han Readability`. A turn does not restate your request, announce what it is about
to do, or summarize what it just said. It spends no sentence carrying neither a fact, a qualifier, nor a needed
transition, and it reserves headings for responses with parts worth navigating.

Detail rolls up instead of listing out. The style starts from the assumption that you want less than the source carries,
so a set of details becomes the statement it supports whenever the detail adds no meaningful value or clarification.
That is a roll-up, not a blur: it has to be true of everything it covers, and the shorter true statement always beats
the vaguer one. Three things stay at full precision anyway, so the roll-up never costs you a decision: a fact whose loss
would change what you do next, a number you will act on, and a stated condition that bounds when a claim holds.

One guard is untouched. Prose is the only target, so code fences, diagram bodies, rendered markup, and citation
identifiers pass through unchanged and still compile, render, and resolve.

The style closes with an eight-criterion self-check. Seven criteria match the rule's, including **Technical detail
separated**, which keeps paths, signatures, and snippets out of the sentences and after the prose that explains them.
The seventh is rewritten to check the roll-up rather than full fact preservation.

## What it does not reach

Three boundaries decide whether the style is enough on its own.

- **Dispatched subagents.** A subagent runs its own system prompt, so the style leaves Han's specialist agents
  unchanged. The skills remain the mechanism that brings the standard to agent output, and the `readability-editor`
  remains the rewrite pass for synthesis skills.
- **Han's skills.** The brevity property lives in this style alone. A skill sourcing
  [`/readability-guidance`](../skills/readability-guidance.md) gets the canonical rule without it, so a skill's
  deliverable keeps its full framing while the conversation around it stays short.
- **A configured writing voice.** A static system prompt cannot run the `.han/config.md` probe, so the style carries the
  built-in Han voice and no configured-profile override. When your project sets `writing-voice`,
  [`/readability-guidance`](../skills/readability-guidance.md) honors it and this style does not.

## Cost and latency

The style adds roughly a hundred and twenty lines to the system prompt, about the same as `Han Readability`. That is
input tokens on the first request of a session, after which prompt caching, which reuses the unchanged front of a
request, absorbs the cost. It adds no dispatch, no file reads, and no extra turns. Output length goes down, because the
brevity property removes preamble and recap from every turn.

## Troubleshooting

- **You selected it and nothing changed.** The output style loads once at session start. Run `/clear` or start a new
  session.
- **A response dropped something you needed.** Working as designed unless it crossed the floor. Ask what was left out
  and you get it in full. If losing it would have changed what you do next, was a number you had to act on, or was a
  condition bounding a claim, the style was supposed to keep it; file that as a bug.
- **A roll-up was not true of everything it covered.** That is a bug, not a trade-off. A roll-up is exact at its own
  altitude by definition.
- **A skill's document is still long.** Expected. The brevity property does not reach skills. See
  [What it does not reach](#what-it-does-not-reach).
- **A dispatched agent's report ignores the standard.** Also expected, and for the same reason. Use a skill that
  dispatches the [`readability-editor`](../agents/readability-editor.md), or run
  [`/edit-for-readability`](../skills/edit-for-readability.md) over the report.
- **The style contradicts the canonical rule.** Outside the brevity property and the roll-up rule, the rule wins. File
  the drift as a bug against the style and fix the style to match
  [`readability-rule.md`](../../references/readability-rule.md).

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, output styles, and how they fit
  together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [`Han Readability`](./han-readability.md). The sibling style that preserves every fact at full precision and carries
  no brevity property, for sessions whose output someone reads cold.
- [Readability](../../../docs/readability.md). The shared standard, its required properties, its staged application, and
  the per-skill table.
- [`readability-rule.md`](../../references/readability-rule.md) and
  [`writing-voice.md`](../../references/writing-voice.md). The canonical files this style is distilled from. They are
  authoritative on everything but the brevity property and the roll-up rule.
- [`/readability-guidance`](../skills/readability-guidance.md). The skill that sources the same standard into a calling
  skill's context, and the one that honors a configured writing-voice profile.
- [`readability-editor`](../agents/readability-editor.md). The agent the synthesis skills dispatch for the adversarial
  rewrite the style does not perform.
- [`/edit-for-readability`](../skills/edit-for-readability.md). The standalone skill that applies the standard on demand
  to a file, pasted text, or a conversation draft.
- [Coverage rule](../../../docs/templates/coverage-rule.md). The output-style variant this doc's section list follows.

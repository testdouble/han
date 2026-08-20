# Han Readability

Operator documentation for the `Han Readability` output style in the han plugin. This document helps you decide _when_
and _how_ to select the style. For the instructions it adds to the system prompt, read the style itself at
[`han-communication/output-styles/han-readability.md`](../../output-styles/han-readability.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Readability](../../../docs/readability.md)

## TL;DR

- **What it does.** Holds the shared readability standard and the writing voice across every turn of a session, instead
  of only inside the skills that source them.
- **When to select it.** Turn it on for a session whose output people will read: documentation, reviews, plans,
  summaries, or a long conversation you will paste elsewhere.
- **What it changes.** How work is written up, not how it is done. It keeps Claude Code's software engineering
  instructions, so coding behavior is unchanged.

## Key concepts

- **A standing selection, not a call.** The style is text Claude Code appends to the system prompt once, at session
  start. You pick it in `/config` and it applies until you pick something else.
- **The third delivery path for one standard.** The rule reaches output three ways: a skill sources it while drafting,
  the `readability-editor` rewrites a finished draft, and this style shapes every turn. All three trace to the same
  canonical files.
- **The long-form sibling of `Han Concise`.** Both styles carry the same standard and voice.
  [`Han Concise`](./han-concise.md) goes further: it adds a brevity property and rolls supporting detail up into the
  statement it supports. This style does neither, so the connective prose and the full precision a cold reader needs
  stay in.
- **A derived copy.** The style distills
  [`readability-rule.md`](../../references/readability-rule.md) and the blocklist in
  [`writing-voice.md`](../../references/writing-voice.md). Those two files stay authoritative, and the style can drift
  from them.

## When to select it

**Select it when:**

- The session's output is prose a non-author will read, and much of it falls outside any one skill.
- You keep re-prompting for the same corrections: lead with the answer, drop the hype words, shorten the sentences.
- You are writing or editing documentation across many files and want one voice throughout.

**Leave it off when:**

- The session is mechanical work whose output nobody reads end to end: a dependency bump, a rename sweep, a build fix.
- You need a configured `writing-voice` profile to apply. The style cannot read one; see
  [What it does not reach](#what-it-does-not-reach).

## How to select it

1. Install `han-communication`, or install `han` to get it with the bundled suite.
2. Run `/config` and choose **Han Readability** under **Output style**.
3. Start a new session or run `/clear`. Claude Code reads the output style once at session start, so the change does not
   take effect mid-session.

Claude Code saves the choice to `.claude/settings.local.json` at the project level. To set it without the menu, write the
`outputStyle` field directly:

```json
{
  "outputStyle": "Han Readability"
}
```

## What it changes

Every response is written for a capable reader who did not do the work. The main point comes first, each paragraph
carries one idea, headings name their content, and sentences stay short and active. Terms the reader cannot look up get
a half-sentence explanation at first use, and the vocabulary blocklist applies, so the hype words and the AI-slop
phrases do not appear.

Two guards outrank the rest. Fidelity wins, so no claim, quantity, named entity, or stated condition is dropped or
blurred to read more simply, unless the reader asked for less and losing it would not change what they do next.
Prose is the only target, so code fences, diagram bodies, rendered markup, and citation identifiers pass through
untouched and still compile, render, and resolve.

The style closes with the same eight-criterion self-check the rule carries, run over the draft before it is presented.
One of the eight is **Technical detail separated**: no paragraph or list item threads several paths, signatures, or
snippets through its sentences. Plain sentences say what happens and the detail comes after them, with inline reserved
for the one identifier a sentence is genuinely about.

## What it does not reach

Three boundaries decide whether the style is enough on its own.

- **Dispatched subagents.** A subagent runs its own system prompt, so the style leaves Han's specialist agents
  unchanged. The skills remain the mechanism that brings the standard to agent output, and the `readability-editor`
  remains the rewrite pass for synthesis skills.
- **A configured writing voice.** A static system prompt cannot run the `.han/config.md` probe, so the style carries the
  built-in Han voice and no configured-profile override. When your project sets `writing-voice`,
  [`/readability-guidance`](../skills/readability-guidance.md) honors it and this style does not.
- **The canonical files it came from.** The style is a distilled copy. When you edit the readability rule or the writing
  voice, check whether the style needs the same change; nothing propagates the edit for you.

## Cost and latency

The style adds roughly a hundred lines to the system prompt. That is input tokens on the first request of a session,
after which prompt caching, which reuses the unchanged front of a request, absorbs the cost. It adds no dispatch, no file reads, and no extra turns. Output length is shaped by
the standard rather than inflated by it, since the rule pushes toward shorter sentences and earlier answers.

## Troubleshooting

- **You selected it and nothing changed.** The output style loads once at session start. Run `/clear` or start a new
  session.
- **A dispatched agent's report ignores the standard.** Expected. See
  [What it does not reach](#what-it-does-not-reach). Use a skill that dispatches the
  [`readability-editor`](../agents/readability-editor.md), or run
  [`/edit-for-readability`](../skills/edit-for-readability.md) over the report.
- **Your configured writing voice is not being applied.** Also expected, and for the same reason. Invoke a skill that
  sources [`/readability-guidance`](../skills/readability-guidance.md), which resolves the configured profile.
- **The style contradicts the canonical rule.** The rule wins. File the drift as a bug against the style and fix the
  style to match [`readability-rule.md`](../../references/readability-rule.md).

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, output style, and how they fit
  together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [`Han Concise`](./han-concise.md). The sibling style with the same standard plus a brevity property, for a working
  session you read in the terminal.
- [Readability](../../../docs/readability.md). The shared standard, its required properties, its staged application, and
  the per-skill table.
- [`readability-rule.md`](../../references/readability-rule.md) and
  [`writing-voice.md`](../../references/writing-voice.md). The canonical files this style is distilled from. They are
  authoritative; the style is a copy.
- [`/readability-guidance`](../skills/readability-guidance.md). The skill that sources the same standard into a calling
  skill's context, and the one that honors a configured writing-voice profile.
- [`readability-editor`](../agents/readability-editor.md). The agent the synthesis skills dispatch for the adversarial
  rewrite the style does not perform.
- [`/edit-for-readability`](../skills/edit-for-readability.md). The standalone skill that applies the standard on demand
  to a file, pasted text, or a conversation draft.
- [Coverage rule](../../../docs/templates/coverage-rule.md). The output-style variant this doc's section list follows.

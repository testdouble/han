# /han-feedback

Operator documentation for the `/han-feedback` skill in the opt-in `han.feedback` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.feedback/skills/han-feedback/SKILL.md`](../../han.feedback/skills/han-feedback/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md) · [Evidence](../evidence.md)

## TL;DR

- **What it does.** Captures structured post-session feedback on the Han skills and agents you just used across the whole `han.*` plugin family, and optionally posts it as a GitHub issue to testdouble/han for maintainers to act on.
- **When to use it.** At the end of any session where one or more `han.*` skills or agents ran — when you have observations about what worked, what didn't, or where a run surprised you.
- **What you get back.** A dated markdown feedback file at `~/.claude/han-feedback/{date}-{skill-names}.md` recording the skills and agents used, and (if you confirm) an open GitHub issue at testdouble/han.

## Key concepts

- **Whole-family scope.** The skill captures skills and agents from every Han plugin (`han.core`, `han.github`, `han.reporting`, `han.feedback`, and any future `han.*` plugin). It identifies each by its plugin namespace (the prefix before the colon, like `han.core:` or `han.github:`). Components from non-Han plugins are out of scope.
- **Agents are captured too.** Most Han agents run because a skill dispatched them. The skill records every Han agent that ran, whether a skill launched it or you dispatched it directly, so the feedback names where specialist value came from.
- **Session scope.** The skill works from the current context window. It can only find `han.*` invocations visible in the conversation at the time you run it. If the session was compacted before you run `/han-feedback`, earlier invocations may not appear. Run it before compaction to catch everything.
- **Feedback file.** A plain markdown file written to `~/.claude/han-feedback/`. The filename encodes the date and the skills covered. One file per day per run; existing files for today are not overwritten.
- **Sensitive-content gate.** Before offering to post, the skill displays the full file and asks you to confirm it contains no personal identifiers, internal operational details, or client-specific information. An ambiguous response stops the posting flow. The posting target is a public GitHub repository.
- **Rating dimensions.** The rating table uses a named default set (output accuracy, evidence discipline, finding signal-to-noise, output length vs. decision count, turn efficiency), adjusted to the skill type only when it clearly calls for it. When prior feedback files exist, the skill reads the most recently modified one to anchor the format so your feedback collection stays consistent.
- **Context window limitation.** Invocations from compacted turns are not visible. The skill counts any invocation as used regardless of whether it completed successfully.

## When to use it

**Invoke when:**

- You just finished a session that used one or more `han.*` skills or agents and have observations worth sharing.
- A skill or agent run surprised you (better or worse than expected) and you want to log it while it is fresh.
- A maintainer asked for feedback on a specific skill or agent after a release.

**Do not invoke for:**

- **Reviewing code or investigating a bug.** Use [`/code-review`](./code-review.md) or [`/investigate`](./investigate.md).
- **Researching how a skill works or what its options are.** Use [`/research`](./research.md).
- **Feedback on components from non-Han plugins.** The skill scans for `han.*` namespaced skills and agents only; skills and agents from third-party plugins are out of scope.
- **Editing or amending prior feedback.** Open `~/.claude/han-feedback/` and edit the file directly.

## How to invoke it

Run `/han-feedback` in Claude Code at the end of a session where `han.*` skills or agents ran. No arguments are required.

The skill ships in the opt-in `han.feedback` plugin, which the `han` meta-plugin does not bundle. Install it on its own first with `/plugin install han.feedback@han` (it pulls `han.core` along the way). See [Choosing a Han plugin](../choosing-a-han-plugin.md) for where it sits in the suite.

Give it:

1. **A session with at least one `han.*` skill or agent invocation.** The skill reads the context window; the invocations need to be visible. If the session was compacted, the skill will ask you to list what you used.
2. **A moment to review.** The skill displays the full feedback file and asks for confirmation before posting. Plan for one or two exchanges.

Example prompts:

- `/han-feedback`. *Run at the end of a session that used `/han.core:plan-a-feature` and `/han.core:plan-implementation`.*
- `/han-feedback`. *"I just finished a session with `/han.core:investigate` and it found the root cause faster than I expected."* — use this framing to prime the skill with a concrete observation before it generates the feedback.

## What you get back

One feedback file per run:

- **`~/.claude/han-feedback/{date}-{skill-names}.md`** — the feedback file. Contains `**Skills used:**` and `**Agents used:**` headers (each listing the components with their full plugin namespace, like `han.core:plan-a-feature` or `han.core:risk-analyst`), context and outcome lines, three sections (What worked well, What didn't work, Overall), and a rating table. The date is today in ISO format; the filename's skill names are the plugin namespace stripped and joined with hyphens.
- **A GitHub issue URL** (conditional) — if you confirm posting, the skill runs `gh issue create` against testdouble/han and returns the issue URL.

## How to get the most out of it

- **Run before context compaction.** The skill reads the current context window. If you compact a long session before running `/han-feedback`, earlier skill invocations drop out of visibility. Run it while the full session is still in context.
- **Be specific.** The skill synthesizes feedback from the session, but it benefits from concrete moments you name upfront. A phrase like "the step where it asked me about the database schema when the schema was right there in the code" gives the skill something to work with.
- **Review the file before confirming.** The sensitive-content gate is there because feedback files capture session context, which can include internal team details or client project names. Read what was written before confirming it is clean.
- **Post when the feedback is ready.** The manual posting command is always provided if you decline — you can edit the file and post it yourself with `gh issue create --repo testdouble/han --body-file ~/.claude/han-feedback/{filename}`.

## Cost and latency

No agents are dispatched. The skill runs in the current conversation context using Read, Write, and Bash tool calls. Total elapsed time is under a minute for most sessions. The only external call is the optional `gh issue create` at the end, which takes a few seconds.

## Related documentation

- [Plugin landing page](../../README.md)
- [All skills](./README.md)
- [How to provide feedback on Han](../how-to/provide-feedback.md) — the end-to-end recipe this skill is the second half of, alongside `/issue-triage` for ideas and vague observations
- [Choosing a Han plugin](../choosing-a-han-plugin.md) — why `han.feedback` is installed separately from the bundled suite
- [Concepts](../concepts.md) — the skill-and-agent model the plugin uses

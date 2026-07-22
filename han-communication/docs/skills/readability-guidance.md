# /readability-guidance

Operator documentation for the `/readability-guidance` skill in the han plugin. This document helps you decide _when_
and _how_ the skill is used. For what the skill does internally, read the skill definition at
[`han-communication/skills/readability-guidance/SKILL.md`](../../skills/readability-guidance/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Readability](../../../docs/readability.md)

## TL;DR

- **What it does.** Surfaces the shared readability rule and writing-voice profile into a calling skill's own context,
  from `han-communication`'s single canonical copy, so the caller drafts in voice and runs its self-check against one
  source.
- **When it runs.** A prose-producing skill invokes it by qualified name at its drafting point. You rarely run it
  directly; the consumer skills call it for you.
- **What you get back.** Nothing of its own. It hands control straight back to the caller, which resumes its own
  workflow with the standard now in context.

## Key concepts

- **It is the cross-plugin source of the standard.** Before this skill existed, each plugin read a vendored copy of the
  rule from its own `references/` directory. Now every consuming skill invokes `han-communication:readability-guidance`
  instead, so there is one canonical copy and no vendored duplicates.
- **It is inline, not forked.** The skill runs in the caller's context so the content it surfaces stays available to the
  caller. It never sets `context: fork`; a forked invocation would isolate the standard so it never reached the caller.
- **It sources; it does not rewrite.** The guidance skill makes the standard available for the caller to apply. The
  adversarial rewrite is a separate pass that synthesis skills run through the
  [`readability-editor`](../agents/readability-editor.md) agent.

## When it is used

**Invoked when:**

- A prose-producing skill reaches the point where it begins drafting its deliverable and needs the shared readability
  standard in context. Every consuming skill invokes it at that point.

**Not used for:**

- **The adversarial rewrite pass.** A synthesis skill dispatches the
  [`readability-editor`](../agents/readability-editor.md) agent after its full draft exists.
- **Rewriting an existing target on demand.** Use [`/edit-for-readability`](./edit-for-readability.md), which dispatches
  the editor over a file, pasted text, or a conversation draft.

## How it works

The skill reads its own two canonical reference files (the readability rule and the writing-voice profile) so their
content enters the caller's context, then instructs the caller to hold the audience frame, draft into its template, run
the standardized self-check, and (for a synthesis skill) dispatch the editor. It closes by telling the caller to return
to the workflow that invoked it.

## Cost and latency

The skill reads two reference files into context and returns. Its cost is the reference content it surfaces, which
persists in the caller's context for the rest of that skill's run. It is invoked once per consuming-skill run, at the
drafting point.

## Troubleshooting

- **A consumer skill stops right after the guidance call.** This is the one residual risk carried from the resolving
  spike: the standard is surfaced through same-context skill composition, and a real `api_retry` (a transient
  infrastructure fault) could in principle anchor a caller on the guidance output and cause it to skip its remaining
  steps. The spike could not induce a real `api_retry`, so the risk is reduced by inference, not measured. If you
  observe a consumer early-exiting immediately after sourcing the standard, re-run the consumer; if it recurs, report
  it, and the documented fallbacks (editor-only delegation for synthesis skills, or vendoring the rule for the
  non-synthesis skills) remain the safety net.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [Readability](../../../docs/readability.md). The shared standard this skill surfaces, its required properties, staged
  application, and the per-skill table.
- [`readability-editor`](../agents/readability-editor.md). The agent the synthesis skills dispatch
  for the rewrite pass, separate from this sourcing step.
- [`/edit-for-readability`](./edit-for-readability.md). The standalone skill that rewrites an existing target against
  the standard on demand.
- [`SKILL.md` for /readability-guidance](../../skills/readability-guidance/SKILL.md). The internal
  process definition.

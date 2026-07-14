---
name: readability-guidance
description: >
  Surfaces Han's shared Human-Readable Output Standard — the readability rule and the writing-voice profile — into the
  calling skill's own context, so the caller drafts in voice and runs its self-check against the current standard
  sourced from one canonical copy. Use when a prose-producing skill needs the shared readability standard available in
  context before it drafts. Runs in the caller's context and hands control straight back; it does not produce a
  deliverable of its own, rewrite anything, or judge the caller's work. Does not run the adversarial rewrite pass —
  dispatch the readability-editor agent for that, or use edit-for-readability to rewrite an existing target.
allowed-tools: Read
---

# Readability Guidance

You have invoked `readability-guidance` to source the shared readability standard before you draft prose. This skill
surfaces the standard into your own context and hands control back. It is a means to writing your deliverable, not the
deliverable itself: apply what it surfaces while you draft and self-check, then RETURN to the workflow that called you
and finish it.

This skill is **inline** — it runs in your context, not an isolated one, so the standard it surfaces stays available to
you after it returns. Do not treat anything here as a stopping point or a final answer.

## Step 1: Read the canonical standard

Read both canonical reference files, in this order, so their full content enters your context:

1. `${CLAUDE_PLUGIN_ROOT}/references/readability-rule.md` — the Human-Readable Output Standard: the audience frame, the
   output properties, the length guidance, the prose-only and fidelity rules, and the standardized self-check.
2. `${CLAUDE_PLUGIN_ROOT}/references/writing-voice.md` — the writing-voice profile, whose "Avoided words and phrases"
   and "AI slop to avoid" sections are the authoritative vocabulary blocklist the rule points to.

Read them from this plugin's own `references/` directory. Do not paraphrase or summarize them in place of reading them —
the surfaced content is the point.

## Step 2: Hold the audience frame while you draft

While you draft, write for a capable reader who did not do this work and lacks the author's context. If the calling
skill names a specific reader (an engineer implementing a fix, a PR reviewer, a non-technical stakeholder), write for
that reader instead and keep the technical specifics that reader needs. The frame governs how a fact is said, never
whether a required fact appears.

## Step 3: Apply the standard in stages, then continue

The standard takes effect in stages, never as one stacked instruction block:

- **Draft into your template** so the structural rules (main point first, descriptive headings, one idea per paragraph,
  numbered-vs-bullet lists, progressive disclosure, technical detail after the prose) are built in.
- **After the draft exists, run the standardized self-check** from the readability rule over the prose regions only —
  never inside code fences, diagram bodies, rendered markup, or citation identifiers. Correct every failure before
  presenting. On a skill that runs no separate rewrite pass, the fidelity criterion is the only fact-preservation guard
  the output has, so it is not optional.
- **If your workflow is a synthesis skill**, dispatch `han-communication:readability-editor` for the adversarial rewrite
  after your full draft exists, as the standard reserves that pass for synthesis output. This skill does not run that
  rewrite.

The standard is now in your context. Proceed to the next step of the skill that invoked you and produce its deliverable.

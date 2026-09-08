---
name: readability-guidance
description: >
  Surfaces Han's shared Human-Readable Output Standard — the readability rule and the writing-voice profile — into the
  calling skill's own context, so the caller drafts in voice and runs its self-check against the current standard
  sourced from one canonical copy. Use when a prose-producing skill needs the shared readability standard available in
  context before it drafts. Governs the shape of a written deliverable, where explanation-guidance governs what a run
  says to a person in a turn. Runs in the caller's context and hands control straight back; it does not produce a
  deliverable of its own, rewrite anything, or judge the caller's work. Does not run the adversarial rewrite pass —
  dispatch the readability-editor agent for that, or use edit-for-readability to rewrite an existing target. Does not
  cover explaining technical work to a reader who will not implement it — use explanation-guidance for that.
allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

# Readability Guidance

You have invoked `readability-guidance` to source the shared readability standard before you draft prose. This skill
surfaces the standard into your own context and hands control back. It is a means to writing your deliverable, not the
deliverable itself: apply what it surfaces while you draft and self-check, then RETURN to the workflow that called you
and finish it.

This skill is **inline** — it runs in your context, not an isolated one, so the standard it surfaces stays available to
you after it returns. Do not treat anything here as a stopping point or a final answer.

## Which outputs this standard covers

A structured specification, plan, phased build, work-item list, coding standard, or test plan is reader-facing whenever a
human reads it end to end — to approve it, follow it, or build from it — even when downstream skills also consume it. Only
an artifact consumed purely as a pipeline input, with no human reading it end to end, falls outside the standard. If a
human reads your deliverable end to end, apply the standard to it.

## Step 1: Resolve the writing-voice source, then read the standard

First resolve which writing-voice profile this run uses:

- When either `.han/config.md` probe supplied a `writing-voice` value, resolve it and check that the file exists. A
  relative value resolves against the folder holding the file that declared it: the working directory for the project
  file, and the `personal config directory` the probe reported for the personal file. A full path is used as it stands,
  and a leading `~` expands to the home directory. When both files supply a value, the project file's wins.
  - When the file exists, it is the writing-voice profile for this run, used in place of the built-in profile.
  - When the file does not exist, warn the user that the configured writing-voice file was not found, naming which of
    the two configuration files declared it, and ask whether to use the built-in Han voice or skip the writing voice
    entirely for this run. Honor the answer: fall back to the built-in profile, or proceed with no voice profile at all.
- When neither probe supplied a `writing-voice` value, the built-in profile at
  `${CLAUDE_PLUGIN_ROOT}/references/writing-voice.md` applies.

Then read the reference files, in this order, so their full content enters your context:

1. `${CLAUDE_PLUGIN_ROOT}/references/readability-rule.md` — the Human-Readable Output Standard: the audience frame, the
   output properties, the length guidance, the prose-only and fidelity rules, and the standardized self-check.
2. The resolved writing-voice profile — the configured file, or the built-in
   `${CLAUDE_PLUGIN_ROOT}/references/writing-voice.md`, whose "Avoided words and phrases" and "AI slop to avoid"
   sections are the authoritative vocabulary blocklist the rule points to. A configured profile stands in for the
   built-in one wholesale: apply whatever voice and vocabulary guidance it carries. When the user chose to skip the
   writing voice, read only the readability rule and apply it with no voice profile and no vocabulary blocklist.

Do not paraphrase or summarize the files in place of reading them — the surfaced content is the point.

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

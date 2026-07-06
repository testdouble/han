# /edit-for-readability

Operator documentation for the `/edit-for-readability` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-core/skills/edit-for-readability/SKILL.md`](../../../han-core/skills/edit-for-readability/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Readability](../../readability.md)

## TL;DR

- **What it does.** Rewrites the prose of a target you already have (a file, pasted text, or a draft from the conversation) against the shared Human-Readable Output Standard, preserving every fact.
- **When to use it.** You have something already written that was never run through the readability standard, and you want it to lead with its point, read plainly, and reveal detail in layers.
- **What you get back.** The target rewritten (in place for a file, inline for text or a conversation draft), plus the editor's rubric verdict and fact-preservation ledger.

## Key concepts

- **The standalone readability pass.** Synthesis skills (`/research`, `/project-documentation`, `/investigate`, and the rest) bake the standard into their own output at generation time. This skill exists for the gap that leaves: a file or draft written or hand-edited *outside* one of those skills, so it was never checked against the standard.
- **Dispatches the readability-editor.** The judgment-heavy rewrite belongs to the [`readability-editor`](../../agents/han-core/readability-editor.md) agent. The skill resolves the target, dispatches the agent over it, and delivers the result; it does not restate the rubric itself, so it never drifts from the standard.
- **Fidelity outranks readability.** Every claim, quantity, named entity, and stated condition survives with its precision intact. When a readability change would blur a fact, the fact wins, and the editor's ledger records it.
- **Prose only.** Code fences, diagram bodies, rendered markup, and citation identifiers (`A1`, `[F5]`, and the like) are left byte-for-byte unchanged, so they still compile, render, and resolve.

## When to use it

**Invoke when:**

- A markdown file, README, or note was written by hand and reads like it: buried point, generic headings, long sentences.
- You pasted a block of text and want it rewritten to read plainly without losing any of its facts.
- A draft produced earlier in the conversation needs a readability pass before you share or commit it.
- A document was edited after a synthesis skill wrote it, so the earlier readability pass no longer covers the current text.

**Do not invoke for:**

- **Writing new feature or system documentation.** Use [`/project-documentation`](./project-documentation.md). It creates and maintains docs; this skill only rewrites prose you already have.
- **Restructuring or reviewing code.** Use [`/refactor`](../han-coding/refactor.md) to restructure code and [`/code-review`](../han-coding/code-review.md) to audit it. This skill edits prose, not code.
- **Judging the underlying work.** The skill rewrites the writing and raises no findings about the bug, the plan, the architecture, or whether a claim is true.

## How to invoke it

Run `/edit-for-readability` with a path, pasted text, or a pointer to a draft in the conversation.

Give it:

1. **The target.** A file path, the text itself, or a phrase like *"the draft above."* If the target is ambiguous or names no real file, the skill stops and asks rather than guessing at a file to overwrite.
2. **The reader, optional.** By default the skill edits for a capable reader who did not do the work. Name a specific reader (an engineer implementing a fix, a PR reviewer, a non-technical stakeholder) to keep the technical specifics that reader needs.

Example prompts:

- `/edit-for-readability docs/onboarding.md`. *"Make this readable."*
- `/edit-for-readability`. *"Clean up the draft you just wrote before I paste it into the PR."*
- `/edit-for-readability`. *"Rewrite this for a non-technical stakeholder: <pasted text>."*

## What you get back

The rewritten target plus the editor's report:

- **For a file target**, the file is rewritten in place at its path, after a one-line change summary and your go-ahead. Overwriting a file you own is the one action the skill confirms first.
- **For pasted text or a conversation draft**, the rewrite comes back inline, with the scratch file path where the working copy was written. The original is never touched, so no confirmation is needed.
- **Rubric verdict.** One line per criterion (main point first, descriptive headings, one idea per paragraph, sentence length, common words / no blocklisted words, progressive disclosure): pass, or what changed to make it pass.
- **Fact-preservation ledger.** Confirmation that every claim, quantity, named entity, and stated condition survived. Any fact that could not be preserved while satisfying a criterion is named, with a note that the fact was kept.
- **Untouched regions.** The non-prose regions left unchanged (code fences, diagrams, citation identifiers).

## How to get the most out of it

- **Name the real reader.** The default frame is a capable non-author. If the target is for a specific expert, say so, so the editor keeps the specifics that reader needs instead of simplifying them away.
- **Hand it finished prose, not an outline.** The editor rewrites written text; it does not draft from notes or add content.
- **Point at one target per run.** The skill rewrites a single target. For several files, run it once per file so each gets its own verdict and ledger.
- **Reach for it after a manual edit.** The readability standard covers a document at generation time, not after a later hand-edit. This skill is how you re-apply it on demand.

## Cost and latency

The skill dispatches one [`readability-editor`](../../agents/han-core/readability-editor.md) agent on its default model (`sonnet`). Cost scales with the length of the target, not with a codebase sweep. It is a single pass over one target; it is not built for tight-loop iteration on the same text.

## In more detail

The skill runs a short, four-step process:

1. **Resolve the target and the reader.** Classify the target as a file on disk, pasted text, or a draft from the conversation. A file is edited in place; text or a draft is copied verbatim to a scratch file so the editor has something to rewrite. Ambiguous or missing targets stop and ask. The reader defaults to a capable non-author unless a specific reader is named.
2. **Confirm before an in-place file rewrite.** For a file target, the skill names the file and gets a go-ahead before dispatching, because the in-place rewrite is the one action that changes a file you own. Scratch copies of pasted text or a conversation draft skip the gate, because the original is untouched.
3. **Dispatch the readability-editor.** One `Agent` call hands the editor the target path, the readability rule, and the reader frame, with the instruction to operate on prose regions only and preserve every fact. The editor owns the rubric.
4. **Deliver the result.** Report the rewrite with the editor's rubric verdict, fact-preservation ledger, and untouched regions. If the ledger flags a fact that could not be preserved while satisfying a criterion, the skill relays it rather than presenting the result as clean.

## Sources

The skill applies the shared Human-Readable Output Standard rather than an external framework. Its provenance is that standard and the voice profile whose blocklist it reuses.

### The Human-Readable Output Standard

The canonical rule the skill applies, loaded at runtime from [`han-core/references/readability-rule.md`](../../../han-core/references/readability-rule.md). The [Readability](../../readability.md) page is the operator-facing summary of its required properties, staged application, and fidelity guard.

### The writing-voice profile

The word-level blocklist the standard reuses lives in [`han-core/references/writing-voice.md`](../../../han-core/references/writing-voice.md).

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Readability](../../readability.md). The shared standard this skill applies on demand, its required properties, and the fidelity guard.
- [`readability-editor`](../../agents/han-core/readability-editor.md). The agent this skill dispatches to do the rewrite.
- [`/project-documentation`](./project-documentation.md). Use to write new docs; this skill rewrites prose that already exists.
- [`/refactor`](../han-coding/refactor.md). The code counterpart: restructure code without changing behavior, where this skill rewrites prose without changing facts.
- [`SKILL.md` for /edit-for-readability](../../../han-core/skills/edit-for-readability/SKILL.md). The internal process definition.

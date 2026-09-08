---
name: explanation-guidance
description: >
  Surfaces Han's shared standard for explaining technical work to a reader who will not implement it into the calling
  skill's own context, so the caller writes its escalations, confirmation turns, and stops as a concrete outcome the
  reader could observe rather than as a mechanism. Use when a skill is about to ask a person a question, stop for an
  input, or explain a technical consequence to someone who will not open the code. Governs what a run says to a person
  in a turn, where readability-guidance governs the shape of a written deliverable. Runs in the caller's context and
  hands control straight back; it does not produce a deliverable of its own, rewrite anything, or judge the caller's
  work. Carries guidance only and adds no self-check step.
allowed-tools: Read, Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

# Explanation Guidance

You have invoked `explanation-guidance` to source the shared explanation standard before you talk to a person. This skill
surfaces the standard into your own context and hands control back. It is a means to writing your turn, not the turn
itself: apply what it surfaces, then RETURN to the workflow that called you and finish it.

This skill is **inline** — it runs in your context, not an isolated one, so the standard it surfaces stays available to
you after it returns. Do not treat anything here as a stopping point or a final answer.

## When this standard applies

It applies to what you say to a person in a turn: an escalation, an opening confirmation turn, a stop for a missing
input, or any explanation of a technical consequence to someone who will not implement the work.

It does not apply to the written deliverable you are producing. That is governed by the readability standard, which you
source through `han-communication:readability-guidance`. A run often needs both, at different moments.

## Step 1: Read the standard

Read `${CLAUDE_PLUGIN_ROOT}/references/explanation-rule.md` so its full content enters your context. It carries the
concrete-outcome requirement, the four-part form for a question shaped like data entry, the unintroduced-term test, and
the rule that the consequence comes before the technical detail.

Do not paraphrase or summarize the file in place of reading it. The surfaced content is the point.

## Step 2: Hold the reader while you write the turn

Write for a reader who knows the product and will not open the code. Name something they could observe. Put paths,
identifiers, and line numbers below the question, or leave them out.

Before you use a term, check whether it appears in the work item or in this conversation. If it appears in neither, it is
unintroduced: replace it with a concrete outcome rather than defining it mid-turn.

## Step 3: Write the turn, then continue

The standard carries guidance only. There is no self-check to run and no verification step to add, so apply it as you
write rather than as a pass afterward.

The standard is now in your context. Proceed to the next step of the skill that invoked you and finish its workflow.

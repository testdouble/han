---
name: spike-guidance-inline
description: OI-3 spike harness — the INLINE (non-forked) readability-guidance variant. Surfaces the shared readability standard into the calling skill's own context. Use only when a spike consumer skill invokes it.
allowed-tools: Read
---

# Readability Guidance (inline variant)

You have invoked the readability-guidance skill to source the shared writing standard before you draft prose. This content is now in your context. Apply it while you draft, then RETURN to the workflow that called you — this guidance is a means to writing your deliverable, not the deliverable itself.

Emit the line `SPIKE_GUIDANCE_MARKER_5R8_INLINE` once, to confirm the guidance rendered, then continue.

## The audience frame (drafting stage)

While drafting, write for a capable reader who did not do this work and lacks the author's context. This single instruction is the most practical lever for plain output: it steers away from insider shorthand, unstated assumptions, and the author's own mental model.

## What the standard requires

- **Main point first.** The opening line states the bottom line. A reader who stops after one sentence still gets the answer.
- **One idea per paragraph.** Each paragraph carries one idea; its first sentence carries the weight.
- **Descriptive headings.** Each heading names its content ("Why the request times out," not "Analysis").
- **Short, active sentences.** Roughly fifteen to twenty words on average; few past twenty-five.
- **Common words.** Prefer the common word over the technical synonym.
- **Numbered lists for steps, bullets for the rest.**
- **Progressive disclosure.** Reveal the core first and detail in layers.

## Self-check criteria (post-draft stage)

After the draft exists, check: does the opening line state the main point? Does each paragraph carry one idea? Does each heading name its content? Any sentence past about thirty words is a candidate to split.

---

The standard is now surfaced into your context. Do not treat this guidance as your final answer. Proceed to the next step of the skill that invoked you and produce its deliverable.

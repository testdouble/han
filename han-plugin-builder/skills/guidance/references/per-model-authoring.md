# Per-Model Authoring Guidance

Write your skill and agent instructions to be model-agnostic by default. When you know the model that will run them, three of Anthropic's models differ enough in how they follow instructions that you should adjust how you write. This document tells you when that adjustment is worth making and what it is.

_Last checked against Anthropic's published guidance on 2026-07-31, for Sonnet 5, Opus 5, and Fable 5. The per-model behavior below comes from Anthropic's own prompting pages (see Sources). Treat it as current only as of that date: those pages are pinned snapshots that get revised and archived as new models ship._

This is author-time guidance. It shapes how you write instructions, not how a skill behaves while it runs.

A skill cannot reliably detect which model is running it, so do not try to branch skill content on the active model. Claude Code exposes no reliable model signal to a skill, and asking a model to name itself is unreliable. The source research covers the reasons in more detail. Keep your shipped skills model-agnostic, and act on the differences below as you write them.

## Default to model-agnostic instructions

Most of the time you do not know which model will run your skill. The operator picks the model when they run it, and can switch it mid-session, so you cannot count on a specific target. Write for the general case first. The model-agnostic form is also the right fallback for any model this document does not name, including future ones.

Reach for per-model tuning only when you have a specific reason: you know the target model, and one of the differences below applies to what you are writing. When in doubt, the model-agnostic default is the safe choice.

## What "model-agnostic" means when you do not know the target

The three models pull in opposite directions on how much to spell out (see the next section), so "write model-agnostic" needs a concrete meaning. Here it is: lead with the goal and the reasons behind it, state the load-bearing constraints and scope explicitly, and skip the exhaustive step-by-step micro-checklist.

This middle path serves all three models. Stating the goal and the reasons gives Fable 5 the context it uses well, without the checklist that degrades its output. Stating the load-bearing constraints explicitly gives Opus 5 and Sonnet 5 the scope they need on the behaviors that matter. You are not writing to the lowest common denominator; you are giving each model what it needs and withholding what hurts one of them.

## The difference that changes how you write: instruction style

This is the one difference worth acting on. Opus 5 and Sonnet 5 follow instructions literally and do not generalize on their own, so they want each behavior spelled out and the scope stated.

Fable 5 runs the other way. A short, goal-based instruction works better for it, and spelling out every step with a checklist actively degrades its output.

Because the two directions are opposite, a skill written to one model's guidance points the other the wrong way. If you tune a skill for Fable 5 with terse goals and then it runs on Opus 5, the Opus run may under-specify. If you tune for Opus 5 with an exhaustive checklist and then it runs on Fable 5, the Fable run may degrade.

Literal instruction-following cuts both ways, and on Opus 5 the cost of a careless limiting phrase is high. A review instruction that says "only report high-severity issues" or "be conservative" is followed literally, and the run reports less than it found. When you want a filtered result, have the skill report everything and filter in a separate step, rather than narrowing what the model is allowed to notice in the first place.

When you know the target, match its style. When you do not, use the model-agnostic middle above.

## The difference that can cause a failure: Fable 5 and reasoning echo

On Fable 5, an instruction that tells the model to reproduce or transcribe its own internal thinking into its visible answer can be refused outright. This is the one difference here that causes a functional failure rather than a stylistic mismatch, so it is worth recognizing on sight.

Use this test to tell when the pattern is present. It applies when an instruction tells the model to copy its own internal reasoning or thinking into the deliverable it returns. It does not apply when you ask the model to write a normal explanation of a decision, or to produce a reasoned answer as ordinary content. Asking for an explanation written for the reader is fine; asking the model to echo its private thinking verbatim is the pattern to avoid.

This warning rests on a single Anthropic source and is not independently corroborated (see Sources). It is a documented product behavior, not a subjective style claim, so it is worth heeding. Weigh it knowing the evidence is single-source and single-vendor.

## Other settings the model differences affect: thinking mode, effort, and subagent eagerness

These three differences rarely decide how you write on their own, but each changes a specific choice:

- **Thinking mode.** The three models default differently. Opus 5 and Sonnet 5 have thinking on by default; on Opus 5 it can be disabled only at effort `high` or below. Fable 5 always has it on and cannot turn it off. So do not write "think step by step" prompt hacks or instructions that assume you can toggle thinking. Set the behavior you want through the model's own controls, not through prose that fights the default. Never write a rule telling the model not to think or not to reason: on Opus 5 with thinking disabled, that kind of rule increases the chance internal XML tags leak into the visible response.
- **Effort.** The reasoning-depth lever is the effort setting, not "think harder" phrasing in your instructions. The same effort label does not mean the same depth across the three models, so do not hardcode an assumption that a given level produces a fixed amount of reasoning. On Opus 5, `low` and `medium` hold quality on most work at a fraction of the tokens and latency, and `xhigh` is reserved for demanding coding and agentic work. Effort governs how much the model thinks, not how much it says, so lowering it will not reliably shorten a response.
- **Subagent eagerness.** The three models reach for subagents with different eagerness, and Opus 5 delegates more readily than earlier models. If your skill dispatches subagents, state the delegation you want rather than relying on the model's default tendency. [Multi-Agent Economics](./agent-building-guidelines/multi-agent-economics.md) covers the delegation rules that follow from this.

## Instructions to leave out on Opus 5

Opus 5 already does several things that older prompts told the model to do. Leaving those instructions in does not reinforce the behavior; it compounds with it and burns tokens for no quality gain. When you write for Opus 5, or when you inherit a skill written for an older model, cut the following.

- **Verification steps the model already performs.** Opus 5 verifies its own work unprompted. Remove instructions like "include a final verification step for any non-trivial task" or "use a subagent to verify the result", along with any legacy harness scaffolding that adds a separate verification pass. This does not mean cutting genuine review by a second perspective, which is a different mechanism and still earns its cost. The rule is about a step that re-checks the model's own work.
- **Re-check and double-check prompts.** "Double-check your answer" and "re-verify before responding" fall in the same category. Opus 5 catches and fixes its own mistakes well, and these phrasings add cost without improving the result.
- **Rules that forbid thinking or reasoning.** Covered in the thinking-mode bullet above.

## Calibrating length, narration, and scope on Opus 5

Opus 5 runs longer and narrates more than earlier models, and it will extend a task's scope on its own judgment. None of these are fixed by lowering effort; each needs an explicit instruction. Write the behavior you want positively, describing the shape you are after rather than listing what to avoid, which works better on this model.

- **Response length.** Say so directly when a skill's conversational output should stay short. State that most of the response belongs to the main answer, and that caveats and disclaimers stay brief. In a long skill body, repeat a one-line reminder near the end.
- **Written deliverables.** Files a skill writes to disk run long on Opus 5 too, and that is a separate lever from conversational verbosity. A skill that produces a report or a document should tell the model to match length to what the task needs and to skip filler sections, redundant summaries, and boilerplate.
- **Progress narration.** Describe the cadence you want rather than leaving it to the default: one sentence before the first tool call, brief updates only on a real finding or a change of direction, and a closing message that leads with the outcome before the supporting detail.
- **Correction narration.** Opus 5 announces corrections to its own earlier statements more than earlier models. When that noise matters, instruct it to correct an earlier statement only when the error changes the reader's code, conclusions, or decisions, and to fix silent slips without narrating them.
- **Scope.** For a narrow task, constrain scope in the skill body: deliver what was asked at the scope intended, make routine judgment calls without checking in, and say so in a sentence and continue when the request looks mistaken rather than quietly reshaping it.

## What this guidance does not cover

This document is about how to write instructions for a model. It is not about which model tier to run. For the tier question (opus, sonnet, or haiku, and at what effort), read [Specialization and Model Selection](./specialization-and-model-selection.md).

It also does not cover run-time model detection or per-model skill variants. Those are out of scope by design, because a skill cannot reliably detect its own model at run time.

## Cross-References

- [Specialization and Model Selection](./specialization-and-model-selection.md). The counterpart to this document. It covers which model _tier_ to run and at what effort; this one covers how to _write the instructions_ for a given model.
- [Writing Effective Instructions](./skill-building-guidance/writing-effective-instructions.md). How to write clear skill instructions in general, independent of the target model.
- [Multi-Agent Economics](./agent-building-guidelines/multi-agent-economics.md). What Opus 5's readier delegation means for how many agents a skill should dispatch and what it may delegate.

## Sources

The per-model behavior above comes from Anthropic's own prompting pages, plus this suite's own research report, `model-specific-guidance-for-skills.md`, which gathered and adversarially validated the instruction-style and Fable 5 claims. The Fable 5 reasoning-echo refusal is single-source on the Fable 5 page.

The Opus 5 material (the instructions to leave out, the length and narration and scope calibration, the effort recommendations, the readier delegation, and the thinking defaults) comes directly from the Opus 5 prompting page and postdates that research report. It is single-vendor and not independently corroborated.

- [Prompting Claude Opus 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)
- [Prompting Claude Sonnet 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5)
- [Prompting Claude Fable 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
- [Claude prompting best practices (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Claude models overview (Anthropic)](https://platform.claude.com/docs/en/about-claude/models/overview)

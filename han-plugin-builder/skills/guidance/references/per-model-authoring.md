# Per-Model Authoring Guidance

Write your skill and agent instructions to be model-agnostic by default. When you know the model that will run them, three of Anthropic's models differ enough in how they follow instructions that you should adjust how you write. This document tells you when that adjustment is worth making and what it is.

_Last checked against Anthropic's published guidance on 2026-07-20, for Sonnet 5, Opus 4.8, and Fable 5. The per-model behavior below comes from Anthropic's own prompting pages (see Sources). Treat it as current only as of that date: those pages are pinned snapshots that get revised and archived as new models ship._

This is author-time guidance. It shapes how you write instructions, not how a skill behaves while it runs.

A skill cannot reliably detect which model is running it, so do not try to branch skill content on the active model. Claude Code exposes no reliable model signal to a skill, and asking a model to name itself is unreliable. The source research covers the reasons in more detail. Keep your shipped skills model-agnostic, and act on the differences below as you write them.

## Default to model-agnostic instructions

Most of the time you do not know which model will run your skill. The operator picks the model when they run it, and can switch it mid-session, so you cannot count on a specific target. Write for the general case first. The model-agnostic form is also the right fallback for any model this document does not name, including future ones.

Reach for per-model tuning only when you have a specific reason: you know the target model, and one of the differences below applies to what you are writing. When in doubt, the model-agnostic default is the safe choice.

## What "model-agnostic" means when you do not know the target

The three models pull in opposite directions on how much to spell out (see the next section), so "write model-agnostic" needs a concrete meaning. Here it is: lead with the goal and the reasons behind it, state the load-bearing constraints and scope explicitly, and skip the exhaustive step-by-step micro-checklist.

This middle path serves all three models. Stating the goal and the reasons gives Fable 5 the context it uses well, without the checklist that degrades its output. Stating the load-bearing constraints explicitly gives Opus 4.8 and Sonnet 5 the scope they need on the behaviors that matter. You are not writing to the lowest common denominator; you are giving each model what it needs and withholding what hurts one of them.

## The difference that changes how you write: instruction style

This is the one difference worth acting on. Opus 4.8 and Sonnet 5 follow instructions literally and do not generalize on their own, so they want each behavior spelled out and the scope stated.

Fable 5 runs the other way. A short, goal-based instruction works better for it, and spelling out every step with a checklist actively degrades its output.

Because the two directions are opposite, a skill written to one model's guidance points the other the wrong way. If you tune a skill for Fable 5 with terse goals and then it runs on Opus 4.8, the Opus run may under-specify. If you tune for Opus 4.8 with an exhaustive checklist and then it runs on Fable 5, the Fable run may degrade.

When you know the target, match its style. When you do not, use the model-agnostic middle above.

## The difference that can cause a failure: Fable 5 and reasoning echo

On Fable 5, an instruction that tells the model to reproduce or transcribe its own internal thinking into its visible answer can be refused outright. This is the one difference here that causes a functional failure rather than a stylistic mismatch, so it is worth recognizing on sight.

Use this test to tell when the pattern is present. It applies when an instruction tells the model to copy its own internal reasoning or thinking into the deliverable it returns. It does not apply when you ask the model to write a normal explanation of a decision, or to produce a reasoned answer as ordinary content. Asking for an explanation written for the reader is fine; asking the model to echo its private thinking verbatim is the pattern to avoid.

This warning rests on a single Anthropic source and is not independently corroborated (see Sources). It is a documented product behavior, not a subjective style claim, so it is worth heeding. Weigh it knowing the evidence is single-source and single-vendor.

## Other settings the model differences affect: thinking mode, effort, and subagent eagerness

These three differences rarely decide how you write on their own, but each changes a specific choice:

- **Thinking mode.** The three models default differently. Opus 4.8 has thinking off unless you turn it on. Sonnet 5 has it on by default. Fable 5 always has it on and cannot turn it off. So do not write "think step by step" prompt hacks or instructions that assume you can toggle thinking. Set the behavior you want through the model's own controls, not through prose that fights the default.
- **Effort.** The reasoning-depth lever is the effort setting, not "think harder" phrasing in your instructions. The same effort label does not mean the same depth across the three models, so do not hardcode an assumption that a given level produces a fixed amount of reasoning.
- **Subagent eagerness.** The three models reach for subagents with different eagerness. If your skill dispatches subagents, state the delegation you want rather than relying on the model's default tendency, which varies by model.

## What this guidance does not cover

This document is about how to write instructions for a model. It is not about which model tier to run. For the tier question (opus, sonnet, or haiku, and at what effort), read [Specialization and Model Selection](./specialization-and-model-selection.md).

It also does not cover run-time model detection or per-model skill variants. Those are out of scope by design, because a skill cannot reliably detect its own model at run time.

## Cross-References

- [Specialization and Model Selection](./specialization-and-model-selection.md). The counterpart to this document. It covers which model _tier_ to run and at what effort; this one covers how to _write the instructions_ for a given model.
- [Writing Effective Instructions](./skill-building-guidance/writing-effective-instructions.md). How to write clear skill instructions in general, independent of the target model.

## Sources

The per-model behavior above comes from Anthropic's own prompting pages, plus this suite's own research report, `model-specific-guidance-for-skills.md`, which gathered and adversarially validated these claims. The Fable 5 reasoning-echo refusal is single-source on the Fable 5 page.

- [Prompting Claude Opus 4.8 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-4-8)
- [Prompting Claude Sonnet 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5)
- [Prompting Claude Fable 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
- [Claude prompting best practices (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Claude models overview (Anthropic)](https://platform.claude.com/docs/en/about-claude/models/overview)

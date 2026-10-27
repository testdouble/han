# Per-Model Authoring Guidance

## Contents

- Default to model-agnostic instructions
- What "model-agnostic" means when you do not know the target
- The difference that changes how you write: instruction style
- The difference that can cause a failure: reasoning echo on every current model
- Other settings the model differences affect: thinking mode, effort, and subagent eagerness
- Instructions to leave out on Opus 5 and Opus 5.5, and to keep on Sonnet 5.5 and Haiku 5.5
- Calibrating length, narration, and scope on Opus 5 and Opus 5.5
- Early stops and scope on Sonnet 5.5 and Haiku 5.5
- What this guidance does not cover
- Cross-References
- Sources

Write your skill and agent instructions to be model-agnostic by default. When you know the model that will run them, Anthropic's models differ enough in how they follow instructions that you should adjust how you write. This document tells you when that adjustment is worth making and what it is.

_Last checked against Anthropic's published guidance on 2026-10-15, for Sonnet 5, Sonnet 5.5, Haiku 5.5, Opus 5, Opus 5.5, Fable 5, and Fable 5.1. The per-model behavior below comes from Anthropic's own prompting pages (see Sources). Treat it as current only as of that date: those pages are pinned snapshots that get revised and archived as new models ship._

This is author-time guidance. It shapes how you write instructions, not how a skill behaves while it runs.

Opus 5.5 inherits the Opus 5 guidance below except where a section says otherwise. Anthropic's Opus 5.5 prompting page says that existing Opus 5 prompts should perform well on Opus 5.5 without changes, so wherever this document says "Opus 5" without naming Opus 5.5, the advice holds for both.

The other 5.5 models follow the same pattern. Anthropic says existing Sonnet 5 prompts should perform well on Sonnet 5.5, existing Haiku 4.5 prompts on Haiku 5.5 (there is no Haiku 5), and existing Fable 5 prompts on Fable 5.1. So wherever this document says "Sonnet 5" or "Fable 5", the advice holds for its successor too, except where a section names Sonnet 5.5 or Haiku 5.5 on its own.

A skill cannot reliably detect which model is running it, so do not try to branch skill content on the active model. Claude Code exposes no reliable model signal to a skill, and asking a model to name itself is unreliable. The source research covers the reasons in more detail. Keep your shipped skills model-agnostic, and act on the differences below as you write them.

## Default to model-agnostic instructions

Most of the time you do not know which model will run your skill. The operator picks the model when they run it, and can switch it mid-session, so you cannot count on a specific target. Write for the general case first. The model-agnostic form is also the right fallback for any model this document does not name, including future ones.

Reach for per-model tuning only when you have a specific reason: you know the target model, and one of the differences below applies to what you are writing. When in doubt, the model-agnostic default is the safe choice.

## What "model-agnostic" means when you do not know the target

The models pull in opposite directions on how much to spell out (see the next section), so "write model-agnostic" needs a concrete meaning. Here it is: lead with the goal and the reasons behind it, state the load-bearing constraints and scope explicitly, and skip the exhaustive step-by-step micro-checklist.

This middle path serves all of them. Stating the goal and the reasons gives Fable 5 the context it uses well, without the checklist that degrades its output. Stating the load-bearing constraints explicitly gives Opus 5, Opus 5.5, Sonnet 5, and Sonnet 5.5 the scope they need on the behaviors that matter. You are not writing to the lowest common denominator; you are giving each model what it needs and withholding what hurts one of them.

## The difference that changes how you write: instruction style

This is the one difference worth acting on. Opus 5 and Sonnet 5 follow instructions literally and do not generalize on their own, so they want each behavior spelled out and the scope stated. Anthropic's Sonnet 5 page says the literal reading is strongest at lower effort. Neither the Sonnet 5.5 nor the Haiku 5.5 page restates this, so treat Sonnet 5.5 as inheriting it through the carried-over Sonnet 5 prompts, not as a claim Anthropic verified for 5.5.

Fable 5 runs the other way. Anthropic says you can steer most behaviors on it "with a brief instruction rather than enumerating each behavior by name", and that skills written for earlier models "are often too prescriptive" and "can degrade output quality".

Because the two directions are opposite, a skill written to one model's guidance points the other the wrong way. If you tune a skill for Fable 5 with terse goals and then it runs on Opus 5, the Opus run may under-specify. If you tune for Opus 5 by enumerating every behavior and then it runs on Fable 5, the Fable run may degrade.

Literal instruction-following cuts both ways, and on Opus 5 the cost of a careless limiting phrase is high. A review instruction that says "only report high-severity issues" or "be conservative" is followed literally, and the run reports less than it found. When you want a filtered result, have the skill report everything and filter in a separate step, rather than narrowing what the model is allowed to notice in the first place.

A limit is not the problem on its own; a vague one is. A limit is fine when it names a bar the reader could check, such as a consequence ("would block the merge") or a rubric the skill itself carries, and it requires evidence for each item it keeps. Anthropic's Opus 5.5 blog post recommends a review prompt of exactly that shape:

> List only problems you'd block the merge for. For each one, give the file and line, why it's wrong, and how to show it fails.

Compare "Only report high-severity issues", which names no bar anyone could check and asks for no evidence. Keep the report-then-filter approach for a limit like that one.

When you know the target, match its style. When you do not, use the model-agnostic middle above.

## The difference that can cause a failure: reasoning echo on every current model

On every current Anthropic model, an instruction that tells the model to reproduce its own internal reasoning in its visible answer can be refused outright, with the `reasoning_extraction` refusal category. Anthropic's refusals page lists the classifiers on Fable 5.1, Fable 5, Opus 5.5, Opus 5, Sonnet 5.5, and Haiku 5.5, and the Fable 5, Opus 5, Opus 5.5, and Sonnet 5.5 prompting pages each name the category. This is the one difference here that causes a functional failure rather than a stylistic mismatch, so it is worth recognizing on sight. A skill whose agent hits it does not degrade; the request comes back declined, and server-side fallback does not retry it.

Haiku 5.5 is the one unclear case: its own prompting page lists four refusal categories and leaves this one out, while the refusals page puts Haiku 5.5 in scope. Write as if it applies.

The pattern is wider than "echo your thinking". Anthropic lists four shapes that trigger it, and says the wording can sit in a system prompt, a skill, or a tool description:

- A `<thinking>`, `<reasoning>`, or scratchpad section the model fills in before it answers.
- A `reasoning`, `thinking`, or `trace` field in JSON output or in a tool input. An agent output format with a `reasoning` field is this pattern.
- The model's private notes, or a running log of its reasoning.
- Reasoning asked for verbatim or in full.

Asking for an explanation written for the reader is fine. A short explanation of the answer, the evidence behind a result, or a summary of the actions taken all stay safe. Name the field for what the reader gets (`rationale`, `evidence`, `why`) and ask for it in a sentence or two, rather than for the model's reasoning.

These are all Anthropic publications, so the evidence is single-vendor rather than independently corroborated. It is a documented product behavior, not a subjective style claim, so it is worth heeding.

## Other settings the model differences affect: thinking mode, effort, and subagent eagerness

These differences rarely decide how you write on their own, but each changes a specific choice:

- **Thinking mode.** The models default differently. Opus 5 and Sonnet 5 have thinking on by default; on Opus 5 it can be disabled only at effort `high` or below. In Claude Code, Opus 5.5, Sonnet 5.5, Haiku 5.5, and the Fable models always have it on, and the thinking toggle has no effect on them. (On the API, Haiku 5.5 can still disable thinking at `high` or below, and Sonnet 5.5's lowest setting is `between_tools`, which skips thinking before the first tool call. Neither changes what a skill author writes.) So do not write "think step by step" prompt hacks or instructions that assume you can toggle thinking. Set the behavior you want through the model's own controls, not through prose that fights the default. Never write a rule telling the model not to think or not to reason: on Opus 5 with thinking disabled, that kind of rule increases the chance internal XML tags leak into the visible response. That leak is an artifact of disabled thinking, so it does not arise on Opus 5.5, but the rule still has no place in a skill.
- **Effort.** The reasoning-depth lever is the effort setting, not "think harder" phrasing in your instructions. The same effort label does not mean the same depth across models, so do not hardcode an assumption that a given level produces a fixed amount of reasoning. On Opus 5, `low` and `medium` hold quality on most work at a fraction of the tokens and latency, and `xhigh` is reserved for demanding coding and agentic work. On Opus 5.5 the same name means more thinking than it did on Opus 5: Anthropic's platform docs put Opus 5.5's API default at `medium`, where Opus 5's is `high`, and report `medium` on Opus 5.5 matching or beating Opus 5 at `high`. Reserve `xhigh` and `max` for work where you have measured a gain. Sonnet 5.5's levels were recalibrated against Sonnet 5 in the same way: the same name no longer produces the same amount of thinking. Haiku 5.5 is the first Haiku with effort levels at all. In Claude Code, Opus 5.5, Sonnet 5.5, and Haiku 5.5 all default to `medium`; on the API, Sonnet 5.5 defaults to `high`. If a skill or agent pins `effort` in its frontmatter and that value was tuned for an earlier model, re-test it on the 5.5 model rather than carrying it over, and say in the body why the value is pinned. Effort governs how much the model thinks, not how much it says, so lowering it will not reliably shorten a response.
- **Subagent eagerness.** The models reach for subagents with different eagerness, and Opus 5 delegates more readily than earlier models. If your skill dispatches subagents, state the delegation you want rather than relying on the model's default tendency. [Multi-Agent Economics](./agent-building-guidelines/multi-agent-economics.md) covers the delegation rules that follow from this.

## Instructions to leave out on Opus 5 and Opus 5.5, and to keep on Sonnet 5.5 and Haiku 5.5

Opus 5 already does several things that older prompts told the model to do. Leaving those instructions in does not reinforce the behavior; it compounds with it and burns tokens for no quality gain. When you write for Opus 5, or when you inherit a skill written for an older model, cut the following.

- **Verification steps the model already performs.** Opus 5 verifies its own work unprompted. Remove instructions like "include a final verification step for any non-trivial task" or "use a subagent to verify the result", along with any legacy harness scaffolding that adds a separate verification pass. This does not mean cutting genuine review by a second perspective, which is a different mechanism and still earns its cost. The rule is about a step that re-checks the model's own work.
- **Re-check and double-check prompts.** "Double-check your answer" and "re-verify before responding" fall in the same category. Opus 5 catches and fixes its own mistakes well, and these phrasings add cost without improving the result.
- **Rules that forbid thinking or reasoning.** Covered in the thinking-mode bullet above.

The verification items above are Opus advice. Do not carry them to Sonnet 5.5 or Haiku 5.5. Sonnet 5.5 generally checks its work, but at `low` effort it sometimes reports a code change done without running a check; Haiku 5.5 does the same at `low` and `medium`. Anthropic's pages for both supply a paragraph to add rather than remove: before reporting a code change done, run a real check that exercises it (the project's tests, type-checker, or build) and, if none can run, say which one was skipped and why. Fable 5 also asks for explicit self-verification on long runs. A model-agnostic skill that changes code and may run at low effort should keep a one-line verification instruction; on Opus it costs a little, and on the others it closes a real gap.

## Calibrating length, narration, and scope on Opus 5 and Opus 5.5

Opus 5 runs longer and narrates more than earlier models, and it will extend a task's scope on its own judgment. None of these are fixed by lowering effort; each needs an explicit instruction. Write the behavior you want positively, describing the shape you are after rather than listing what to avoid, which works better on this model.

- **Response length.** Say so directly when a skill's conversational output should stay short. State that most of the response belongs to the main answer, and that caveats and disclaimers stay brief. In a long skill body, repeat a one-line reminder near the end.
- **Written deliverables.** Files a skill writes to disk run long on Opus 5 too, and that is a separate lever from conversational verbosity. A skill that produces a report or a document should tell the model to match length to what the task needs and to skip filler sections, redundant summaries, and boilerplate.
- **Progress narration.** Describe the cadence you want rather than leaving it to the default: one sentence before the first tool call, brief updates only on a real finding or a change of direction, and a closing message that leads with the outcome before the supporting detail.
- **Correction narration.** Opus 5 announces corrections to its own earlier statements more than earlier models. When that noise matters, instruct it to correct an earlier statement only when the error changes the reader's code, conclusions, or decisions, and to fix silent slips without narrating them.
- **Early stops on long runs.** On a long task with several parts, Opus 5.5 keeps the user posted, and some of those updates end the turn with a report instead of the next step. It responds to instructions that name the stops you do not want and the ones you do. [Workflow Patterns](./skill-building-guidance/workflow-patterns.md#naming-the-stops-in-an-autonomous-stretch) shows how, and when to leave the instruction out.
- **Scope.** For a narrow task, constrain scope in the skill body: deliver what was asked at the scope intended, make routine judgment calls without checking in, and say so in a sentence and continue when the request looks mistaken rather than quietly reshaping it.

## Early stops and scope on Sonnet 5.5 and Haiku 5.5

The two newer tiers stop early and stretch scope in their own ways, mostly tied to effort. These matter for a skill that runs long or changes code.

- **Sonnet 5.5 checks in early at `low` and `medium`.** On long agentic tasks at those levels it is more likely to stop and ask before it finishes. Raising effort helps; so does a sentence telling it to keep working until everything asked for is done and to stop only when it cannot go on without the user or before a risky step.
- **Sonnet 5.5 adds work it was not asked for.** It adds tests, docs, and small supporting files at every effort level, more at higher effort. When a skill wants changes limited to the request, say that once it is done and checked it should stop and report, and mention any addition it thinks would help instead of making it.
- **Sonnet 5.5 starts its own review rounds at `xhigh` and `max`.** At those levels it can launch reviewer subagents after it finishes. Anthropic reports that a sentence telling it not to start extra review rounds unless asked cut session cost by about a third with no change in quality. Prefer running routine work at `high` or below.
- **Haiku 5.5 stops early on long prompts at `low`.** With a short system prompt it rarely stops early; with a long coding-agent prompt at `low` it sometimes hands the task back. The same keep-working sentence helps, and so does `medium` effort, which in Anthropic's testing roughly halved early stops while more than doubling output tokens. Keep a Haiku agent's prompt short.
- **Asking any of them to think less in prose does not work.** Lower the effort instead.

## What this guidance does not cover

This document is about how to write instructions for a model. It is not about which model tier to run. For the tier question (opus, sonnet, or haiku, and at what effort), read [Specialization and Model Selection](./specialization-and-model-selection.md).

It also does not cover run-time model detection or per-model skill variants. Those are out of scope by design, because a skill cannot reliably detect its own model at run time.

## Cross-References

- [Specialization and Model Selection](./specialization-and-model-selection.md). The counterpart to this document. It covers which model _tier_ to run and at what effort; this one covers how to _write the instructions_ for a given model.
- [Writing Effective Instructions](./skill-building-guidance/writing-effective-instructions.md). How to write clear skill instructions in general, independent of the target model.
- [Multi-Agent Economics](./agent-building-guidelines/multi-agent-economics.md). What Opus 5's readier delegation means for how many agents a skill should dispatch and what it may delegate.

## Sources

The per-model behavior above comes from Anthropic's own prompting pages, plus this suite's own research report, `model-specific-guidance-for-skills.md`, which gathered and adversarially validated the instruction-style and Fable 5 claims. The reasoning-echo refusal, single-source on the Fable 5 page when that report was written, is now stated on the Fable 5, Opus 5, Opus 5.5, and Sonnet 5.5 prompting pages and on the refusals page.

The Opus 5 material (the instructions to leave out, the length and narration and scope calibration, the effort recommendations, the readier delegation, and the thinking defaults) comes directly from the Opus 5 prompting page and postdates that research report. It is single-vendor and not independently corroborated.

The Opus 5.5 material (the inherited Opus 5 guidance, the thinking and effort changes, the acceptable review limit, and the early-stop behavior) comes from the Opus 5.5 prompting page and Anthropic's Opus 5.5 blog post, and postdates that research report too. The two agree with each other, but both are Anthropic's, so this material is also single-vendor. The review-limit example appears only in the blog post.

The Sonnet 5.5, Haiku 5.5, and Fable 5.1 material, the widened reasoning-echo section, and the Claude Code thinking and effort defaults come from the pages below as of 2026-10-15, gathered and adversarially validated in `docs/plans/opus-5-5-plugin-builder-guidance/research/claude-5-5-family-guidance.md`. It is single-vendor as well.

- [Prompting Claude Opus 5.5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5)
- [Getting the most out of Opus 5.5 in Claude and Claude Code (Anthropic blog, Addy Osmani, 2026-09-22)](https://claude.dev/blog/getting-the-most-out-of-opus-5-5/)
- [Prompting Claude Sonnet 5.5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5)
- [What's new in Claude Sonnet 5.5 (Anthropic)](https://platform.claude.com/docs/en/models/sonnet-5-5/whats-new-sonnet-5-5)
- [Prompting Claude Haiku 5.5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-haiku-5-5)
- [Prompting Claude Fable 5.1 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-1)
- [Refusals and fallback (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback)
- [Effort (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/effort)
- [Claude Code model configuration](https://code.claude.com/docs/en/model-config)
- [Prompting Claude Opus 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)
- [Prompting Claude Sonnet 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5)
- [Prompting Claude Fable 5 (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
- [Claude prompting best practices (Anthropic)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Claude models overview (Anthropic)](https://platform.claude.com/docs/en/about-claude/models/overview)

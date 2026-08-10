# /code-overview

Operator documentation for the `/code-overview` skill in the han plugin. This document helps you decide _when_ and _how_
to use the skill. For what the skill does internally, read the skill definition at
[`han-coding/skills/code-overview/SKILL.md`](../../skills/code-overview/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Sizing](../../../docs/sizing.md)

## TL;DR

- **What it does.** Produces a human-readable, progressive-disclosure overview of unfamiliar code or of a pull request's
  changes, leading with _why_ (the real problem the code solves or the goal it accomplishes for the business or a
  user) and flowing from there into what it does, how it works, and where to start, so you can get up to speed before
  working on or reviewing it.
- **When to use it.** You have landed in code you do not know, or a PR you are about to review, and you want a fast
  orientation before you start.
- **What you get back.** An overview file (written where you configured Han's output to go, or outside the repository
  when you configured nothing) with a purpose statement, a linked
  list of the context the overview drew on, Mermaid flow charts, the directly-related context, and where to start, all
  at minimal technical depth.

## Key concepts

- **Size-aware.** The skill classifies the target as small / medium / large, defaults to small, and scales how many
  `codebase-explorer` agents it dispatches. Pass the size as the first positional argument to override
  (`/code-overview medium`). See [Sizing](../../../docs/sizing.md).
- **Why first.** The overview is built to answer one question before any other: _why does this code exist?_ The answer
  is the real problem it solves or the goal it accomplishes for the business or a user, not the technical mechanics.
  What it does, how it flows, and where to start are not dropped; they flow out of the why and exist to give you the
  context to understand it. A confidently stated why that the code's intent does not support is the one thing the skill
  guards hardest against.
- **Two modes.** _Code mode_ explains a file, directory, or symbol as it is now: why it exists, then what it does. _PR
  mode_ explains a set of changes: why they exist, grouped by the intent each group serves, and how to look at the PR
  before reviewing it. The skill picks the mode from the target.
- **Understand now, not document for later.** The overview is an ephemeral orientation aid, and the skill never commits
  it into the repository's documentation tree. That is the line against `/project-documentation`. It is why the file
  lands outside the repository when you have configured nothing; a destination you configure yourself wins over that
  default, wherever it points.
- **No findings.** The overview raises no quality findings, severities, or recommended changes. Even the PR-mode "what
  to watch" section is navigational: it names where the change is hardest to follow, not whether it is any good. That is
  the line against `/code-review`.
- **Accurate, not only readable.** Before you see it, an `adversarial-validator` pass re-reads the code and challenges
  every claim the draft makes, so the flow charts, entry points, and change groupings reflect what the code does. The
  validation guards truth (the description matches the code); it never crosses into judging the code's quality, which
  stays `/code-review`'s job.
- **Progressive disclosure, anchored on the why.** The most important understanding comes first: _why the code exists_,
  the problem it solves or goal it serves. Then comes the flow chart, then context, then where to start, each flowing
  from and serving that why. A reader who stops early still knows why the target exists and what need it meets.
- **Minimal technical detail, scoped per section.** The why, flow, and context stay high-level: the why is told as a
  problem solved or goal met, not technical mechanics. The where-to-start section is the exception, and names concrete
  entry points so you can open the right file.

## When to use it

**Invoke when:**

- You have been handed code you have never seen and need to work on it.
- You are about to review a PR and want to understand what it does and why before you start reading line by line.
- You are ramping onto an unfamiliar module, directory, or symbol and want a map before you dive in.

**Do not invoke for:**

- **Reviewing code quality or finding problems.** Use [`/code-review`](./code-review.md) instead (or
  [`/post-code-review-to-pr`](../../../han-github/docs/skills/post-code-review-to-pr.md) to post a review to GitHub).
- **Writing durable feature or system documentation.** Use
  [`/project-documentation`](../../../han-documentation/docs/skills/project-documentation.md) instead.
- **Assessing architecture, coupling, or structural risk.** Use [`/architectural-analysis`](./architectural-analysis.md)
  instead.
- **Diagnosing a bug or root-causing a failure.** Use [`/investigate`](./investigate.md) instead.
- **Being paced through the code one step at a time.** Use [`/code-walkthrough`](./code-walkthrough.md) instead. It
  produces a conversation you drive, not a document you read alone.

## How to invoke it

Run `/code-overview` in Claude Code.

Give it:

1. **A target (optional).** A file path, a directory, a symbol name, or a pull request reference / URL. With no target,
   the skill defaults to the current branch's changes in PR mode. A sharp target is a single file, symbol, directory, or
   PR; a thin one ("explain the backend") forces the skill to ask you to narrow it.
2. **A size (optional).** `small`, `medium`, `large`, or `dynamic` as the first positional argument, when you want to
   override the skill's auto-classification.

Example prompts:

- `/code-overview`. _"Explain what the changes on this branch do before I review them."_
- `/code-overview src/auth/`. _"Help me understand the auth module before I work on it."_
- `/code-overview #82`. _"Walk me through pull request 82 so I know how to review it."_
- `/code-overview large src/billing/`. _"Give me a thorough overview of the billing subsystem."_

## What you get back

A single Markdown overview file. It lands under the `output-directory` in your `.han/config.md` when you have set one,
and outside the repository (for example under your system temp directory) when you have not. A configured directory
inside the repository is honored without comment, because you chose it. When the resolved destination cannot be written,
the run falls back to the outside-the-repository default and tells you which destination it could not use, rather than
throwing away work it has already finished.

The skill shows you the path; open it where the Mermaid charts render. The file is not committed and is not maintained;
it is a point-in-time orientation aid.

The document follows one structure per mode, under a shared grammar. It opens with a title and a short intro paragraph
naming what is being examined (not a metadata block), then leads with the why and lets every later section flow from it:

- **Code mode:** _Why it exists_ (the problem solved or goal served, then briefly what it is) → _Context used_ (the
  sources the overview drew on) → _Main flow_ (a Mermaid chart with a scope label, read as how the code delivers on the
  why) → _Context and uses_ → _Where to start_ (the entry points numbered in the order to open them, each with what you
  learn there, and a runnable example call on any entry point that is an interface other code calls) → _What this code
  does, in plain language_.
- **PR mode:** _Why this change exists_ (the need that motivated it, then the bottom line of what it does, plus a
  sentence when the code turns out not to support that reason) → _Context
  used_ → _Changes by intent_ (grouped by the outcome, the why, each group delivers) → _How the change flows_ (a Mermaid
  chart with a scope label) → _What to watch when reviewing_ (navigational only) → _What this change does, in plain
  language_.

Both modes end with three or four sentences you could read aloud, carrying no file paths and no type names. They are
there to be lifted out and pasted into a pull request description or a message to a reviewer. The run's closing message
repeats those exact sentences rather than writing its own version, so you can paste from the terminal without opening
the file and never wonder which of two summaries is the real one.

Every chart is drawn to be read at a glance. Each box names a component or a boundary you can point at, and the fields,
types, and technical annotations sit in the prose beneath the chart instead. A step the flow needs is never dropped to
make the picture simpler; the step stays and its detail moves down. The skill owns this itself, because the readability
pass described below is deliberately barred from editing chart bodies.

The _Context used_ section, placed directly after the lead why section, lists every source the overview drew on. Each
source with an address is a direct link (a repository file by path, a pull request, issue, or commit by URL), so you
can walk the same evidence the overview was built from. A source with no address (an uncommitted diff, the branch's
commit messages, context supplied in conversation) is stated in one plain sentence instead.

In PR mode, when the pull request has screenshots, the overview embeds them inline next to the text they illustrate, so
you do not have to switch back to the PR to see them.

Before you see it, the draft passes two checks in order: accuracy first, then readability.

The accuracy pass runs first. `adversarial-validator` re-reads the code and its intent and challenges every claim the
overview makes. It starts with the load-bearing claim: is the stated _why_ grounded in real evidence (commit and
PR/issue intent, comments, what the code visibly does toward a goal), or is it an invented rationale? It also checks
whether the flow chart matches the real control flow, whether the named entry points exist, and whether each
change-by-intent grouping describes what the code does. A confidently wrong overview, most of all a confidently wrong
_why_, gets corrected before it can mislead you.

The readability pass runs next. `readability-editor` rewrites the corrected draft against the shared readability
standard, preserving every fact, so the overview leads with its point and reads for someone who did not do the work.
Accuracy settles first, so the editor never polishes a claim that is about to change.

The skill then checks its own output before showing it to you: that every chart's boxes name components rather than
carrying field and type detail, that the starting points are numbered in reading order with an example call where one is
called for, that terms you could not look up carry their explanations, and that the closing restatement is there and free
of file paths and type names. Anything that fails is fixed before you see it, not reported to you as a caveat.

The validator checks the description against the code only to keep it truthful. It never judges the code's quality; the
overview still raises no findings about the work itself.

One thing a change overview will now tell you that it used to keep to itself: when the code shows that the stated reason
for a change is already satisfied, or does not hold, the overview says so where it states that reason. It says it as a
fact about the reason, with no finding, no severity, and no recommendation. It only says it when it checked and found
that, so a reason the code is silent about is still marked as inferred rather than reported as contradicted.

When the target is too large to cover fully at the chosen size, the overview adds a coverage note immediately after the
header, naming what it did not cover and the next size up, so you know the picture is partial before you study the
charts.

## How to get the most out of it

- **Name a sharp target.** A file, a symbol, a directory, or a specific PR gets a focused overview. "The whole app" does
  not; the skill will ask you to narrow it.
- **Let the default carry the PR case.** With no argument on a feature branch, the skill orients you to exactly the
  changes you are about to review. You rarely need to name the PR explicitly.
- **Re-run larger when coverage is partial.** If the overview adds a coverage note, re-run at the next size up for a
  fuller picture rather than guessing at the gaps.
- **Read it before `/code-review`, not instead of it.** The overview tells you how to look at a PR; the review tells you
  whether the PR is any good. Run code-overview first to orient, then `/code-review` to judge.

## Sizing

The skill is one of the size-aware skills. It classifies the target and scales the exploration roster:

| Size                  | Typical target                                                               | Explorers dispatched |
| --------------------- | ---------------------------------------------------------------------------- | -------------------- |
| **Small** _(default)_ | A single file, a single symbol, or a small change set                        | 1                    |
| **Medium**            | A directory or module, or a moderate change set across one or two subsystems | 2–3                  |
| **Large**             | Multiple subsystems, or a large change set                                   | 3–5                  |

Classification defaults to small and escalates only on a clear signal; a borderline target stays at the smaller band.
Pass `small`, `medium`, or `large` as the first positional argument to override. The roster is intentionally lean,
`codebase-explorer` agents only, because this is read-only orientation, not the multi-specialist audit that
`/code-review` and `/architectural-analysis` run. See [Sizing](../../../docs/sizing.md) for the cross-skill model.

## Cost and latency

The skill runs on the default model tier and dispatches a lean roster: one to five `han-core:codebase-explorer` agents
in parallel, scaled to size, then a synthesis pass the skill performs itself, then two review passes in order:
`adversarial-validator` (accuracy, re-reading the code) first, then `han-communication:readability-editor` (a
readability rewrite of the corrected draft, preserving every fact). The skill applies the accuracy corrections and the
rewrite. The most expensive single step is the parallel exploration wave at large size. It is built for quick, on-demand
orientation, so it is cheap at small size and safe to run often; it is read-only and re-runnable, so there is no
approval gate before it works.

## In more detail

The skill orchestrates and synthesizes; the agents discover, validate, and refine.

It resolves the target by a fixed precedence: an explicit pull request reference first, then a file or directory path,
then a symbol, and finally (with no target) the current branch's changes. This order means an ambiguous string never
silently selects the wrong mode.

It classifies size, then dispatches `codebase-explorer` agents over the target or the changed files. Each agent surfaces
the evidence of _why_ the code exists (the problem it solves or goal it serves, drawn from commit and PR intent,
comments, naming, and tests) alongside entry points, context, uses, and flow.

The skill then writes the overview itself, leading with that why and flowing the grouping, charts, and orientation out
of it. The grouping, the charts, and the orientation are the skill's work, not pasted agent output.

PR mode runs on the local branch diff and does not require a remote pull request; a remote PR is needed only when you
name one explicitly.

The skill degrades gracefully when its tools are missing. Code mode against a named target still runs without git, while
PR mode and the bare-invocation default tell you they need git to read changes. When a named pull request cannot be
reached, the skill offers code mode against a local target instead.

## Sources

The skill's posture is grounded in established practice for progressive disclosure, information scent, and program
comprehension. Each source below is cited because the skill draws a specific, named artifact from it.

### Jakob Nielsen: Progressive Disclosure

Nielsen's work on progressive disclosure (Nielsen Norman Group) is the structural principle behind the overview's
section order: show the single most important thing first, then let detail unfold beneath it, so a reader who stops
early is still oriented correctly. The skill's "what it does and why → flow → context → where to start" ordering is this
principle applied to code.

URL: https://www.nngroup.com/articles/progressive-disclosure/

### Peter Pirolli and Stuart Card: Information Foraging Theory

Pirolli and Card's information-foraging work formalized "information scent," the cues a reader follows to decide where
to look next. The skill's content-bearing section headings, the chart scope labels, and the partial-coverage note exist
so a reader can forage the overview efficiently and know when the picture is incomplete.

URL: https://www.researchgate.net/publication/200085665_Information_Foraging

### Spinellis and others: Program Comprehension

The program-comprehension literature establishes that developers understand unfamiliar code by building a mental model
from entry points, control flow, and call relationships before reading detail. The skill's flow charts and its "where to
start" section target exactly that model-building path, at minimal technical depth.

URL: https://www.spinellis.gr/codereading/

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [Skills Index](../../../docs/skills/README.md). All skills, grouped by purpose.
- [`/code-review`](./code-review.md). The judgment counterpart: run code-overview to understand a PR, then code-review
  to evaluate it.
- [`/project-documentation`](../../../han-documentation/docs/skills/project-documentation.md). The durable counterpart: code-overview is ephemeral
  orientation, project-documentation is maintained docs in the repo tree.
- [`/architectural-analysis`](./architectural-analysis.md). Reach for this when you need a structural, coupling, and
  risk assessment rather than an orientation.
- [`/investigate`](./investigate.md). Reach for this when something is broken and you need a root cause, not an
  overview.
- [`/code-walkthrough`](./code-walkthrough.md). The paced counterpart: same understanding goal, delivered as a
  step-by-step conversation you can interrupt rather than one document.
- [Sizing](../../../docs/sizing.md). The cross-skill sizing model. Explains the small / medium / large bands, the
  default-to-small rule, and the `$size` override.
- [`codebase-explorer`](../../../han-core/docs/agents/codebase-explorer.md). The agent this skill dispatches, scaled to size, to
  discover entry points, context, uses, and flow.
- [`adversarial-validator`](../../../han-core/docs/agents/adversarial-validator.md). The agent that re-reads the code to
  challenge the drafted overview's claims for accuracy before you see it, so the description matches what the code does.
- [`readability-editor`](../../../han-communication/docs/agents/readability-editor.md). Rewrites the drafted overview against
  the shared readability standard, preserving every fact, before you see it. Runs after the accuracy validator, not
  alongside it.
- [`SKILL.md` for /code-overview](../../skills/code-overview/SKILL.md). The internal process definition.

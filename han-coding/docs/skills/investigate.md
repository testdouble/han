# /investigate

Operator documentation for the `/investigate` skill in the han plugin. This document helps you decide _when_ and _how_
to use the skill. For what the skill does internally, read the skill definition at
[`han-coding/skills/investigate/SKILL.md`](../../skills/investigate/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All skills](../../../docs/skills/README.md) ·
> [All agents](../../../docs/agents/README.md) · [Evidence](../../../docs/evidence.md)

## TL;DR

- **What it does.** Runs an evidence-based investigation of a question about this codebase as one of three types (a bug
  to root-cause, how the code works, or the options for a piece of work), with adversarial validation of the findings.
- **When to use it.** You want an answer backed by file-level evidence, not a guess: why something is broken, how
  something works, or which way a change should go.
- **What you get back.** A report whose sections follow the type, with numbered evidence (E1, E2, …) and validation
  findings (V1, V2, …). A bug report carries a root cause and a planned fix; a how-it-works report carries an answer and
  a walkthrough; an available-options report carries options, a comparison, and a recommendation.

## Key concepts

- **One run, one investigation type.** Every run answers one kind of question:

  | Type                | What it answers                                                 | What you get                                                   |
  | ------------------- | --------------------------------------------------------------- | -------------------------------------------------------------- |
  | `bug`               | Find the root cause of a failure and plan the fix               | Problem statement, root cause, planned fix, coding standards   |
  | `available-options` | Compare the ways a piece of work could be done in this codebase | Goal and constraints, current state, options, comparison, pick |
  | `how-it-works`      | Explain how this codebase behaves, with cited evidence          | The question, a one-sentence answer, a walkthrough, key parts  |

- **Name a type, or let the skill pick.** Put the type first (`/investigate how-it-works …`) to choose it. Leave it out
  and the skill reads your question and picks one. A failure outranks everything; an options question outranks a
  how-it-works one; a question that reads as none of them runs as `how-it-works`.
- **A type that does not fit gets one question.** When you name a type and your question clearly reads as a different
  one (`/investigate how-it-works login throws 500 since Tuesday`), the skill asks once which to use, and suggests the
  better fit. Anything short of a clear mismatch keeps your choice.
- **You see what it decided before any work starts.** Every run opens with a short block naming the type, why it was
  chosen, the question as the skill read it, where the report will be written, and the other types you could re-run as.
- **Parallel evidence gathering with specialists.** Each type dispatches its own agents in parallel. A bug run sends two
  or more `evidence-based-investigator` agents, each from a different angle, plus `concurrency-analyst`,
  `behavioral-analyst`, or `data-engineer` when the symptom matches. A how-it-works run sends `codebase-explorer` and
  `behavioral-analyst`. An options run sends `codebase-explorer` and `structural-analyst`. Specialists join either when
  the question calls for them.
- **Evidence is numbered.** Every finding gets an ID (E1, E2, E3…) so the analysis can cite specific evidence (_"the
  handler passes an unvalidated ID (E1) to the service layer, which assumes non-nil (E3)"_).
- **Adversarial validation before you act.** `adversarial-validator` agents try to falsify the evidence and break the
  conclusion: the fix for a bug, the completeness of the explanation for how-it-works, the recommendation for options.
  Counter-evidence becomes validation findings (V1, V2, …) that reshape the report.
- **This codebase, not the open web.** The skill reads your repository and any material you paste in. For prior art,
  outside libraries, or the state of the art, use `/research`.

## When to use it

**Invoke when:**

- A bug, failure, or unexpected behavior needs a root cause backed by code-level evidence.
- An integration or API call is misbehaving and you want a trace from symptoms to data flow to recent changes.
- You need an accurate account of how a flow, a lifecycle, or an integration in this codebase works before you change it.
- You are weighing how to make a change and want the options this codebase supports, compared against its constraints.
- You want the conclusion adversarially validated, not only drafted, before writing any code.

**Do not invoke for:**

- **Code review.** Use [`/code-review`](./code-review.md) for a correctness, testing, and compliance audit of a branch.
- **Architectural analysis.** Use [`/architectural-analysis`](./architectural-analysis.md) for coupling, data flow,
  concurrency, and SOLID assessment of a module.
- **Test planning.** Use [`/automated-test-planning`](./automated-test-planning.md) when the gap is coverage, not a bug.
- **Plan review.** Use [`/iterative-plan-review`](../../../han-planning/docs/skills/iterative-plan-review.md) for
  multi-pass review of an existing plan.
- **The open web and prior art.** Use [`/research`](../../../han-research/docs/skills/research.md) when the answer lives
  outside this codebase: outside libraries, prior art, or how an outside technology works.
- **An orientation to a whole area.** Use [`/code-overview`](./code-overview.md) for a written overview of a file,
  directory, or PR, or [`/code-walkthrough`](./code-walkthrough.md) to be paced through code one step at a time.
  `/investigate how-it-works` answers one question with cited, validated evidence.
- **Planning the change a finding calls for.** Use [`/plan-a-change`](../../../han-planning/docs/skills/plan-a-change.md)
  when the report shows a responsibility in the wrong place rather than a one-line fix, or when you have picked an
  option to restructure toward. Its report is a valid input there.
- **Mapping bounded contexts or domain boundaries.** Use [`/ddd-analysis`](../../../han-ddd/docs/skills/ddd-analysis.md)
  when the question is where the domain's boundaries sit.
- **Feedback on Han's own skills.** Use [`/han-feedback`](../../../han-feedback/docs/skills/han-feedback.md) to capture
  post-session feedback on the Han skills you ran.

## How to invoke it

Run `/investigate` in Claude Code with an optional type, your question, and an optional report path:

```
/investigate [bug | available-options | how-it-works] <question or symptom> [report path ending in .md]
```

Give it:

1. **The type, optional.** The first word, when it is one of the three tokens. A trailing colon is fine (`bug:`).
2. **The question or symptom.** For a bug, what you observed: the error message, the unexpected value, the failed
   deploy. For how-it-works, what you want explained. For options, the work you want to do. Concrete wording collapses
   the search space.
3. **A report path, optional.** A final word ending in `.md` that does not name an existing file is where the report is
   written. A final `.md` that already exists is read as part of your question, and the skill never writes over it.
   Otherwise the report goes to your configured `output-directory`, or to `investigations/` under the project's
   documentation root, named after your question.

Example prompts:

- `/investigate`. _"Why are webhook deliveries failing intermittently in production?"_ Runs as `bug`.
- `/investigate bug`. _"Users see stale data after updating their profile. The update returns 200 but the next page
  load shows the old value."_
- `/investigate how-it-works`. _"How does the retry queue pick a backoff?"_
- `/investigate`. _"What happens when a payment webhook arrives for an order that was already refunded?"_ Runs as
  `how-it-works`.
- `/investigate available-options`. _"Add rate limiting to the public API."_
- `/investigate`. _"How should we add a fixed-amount coupon alongside the percentage discounts?"_ Runs as
  `available-options`.
- `/investigate the import job drops rows docs/incidents/2026-04-23.md`. Investigate and write the report to that path.

## What you get back

A report file, plus an in-channel summary. Every report leads with the bottom line and keeps the supporting detail near
the end. Sections appear only when the investigation produced meaningful content for them, and the rest keep the order
below. Every report names its type on the line under its title.

**A `bug` report** carries:

- **Summary.** One sentence each for root cause, fix, why correct, validation outcome, and remaining risks.
- **Problem Statement.** Symptoms, expected behavior, conditions under which it occurs, impact.
- **Root Cause Analysis.** One to three sentences on the root cause, then a detailed analysis citing evidence items.
- **Planned Fix.** Per-file changes: full path, what changes, which evidence justifies it, which standards apply, and
  implementation specifics.
- **Evidence Summary and Validation Results.** The shared sections, below.
- **Coding Standards Reference.** Each standard the fix was written against, and where it was found.

**A `how-it-works` report** carries:

- **Summary.** The answer, the entry points, the validation outcome, and the paths the evidence did not reach.
- **Question.** What was asked, and what the answer covers and leaves out.
- **Answer.** A one-sentence answer, then a numbered walkthrough of the flow citing evidence items.
- **Key Components.** A table of each part the walkthrough depends on, its file, and its role.
- **Evidence Summary and Validation Results.**

**An `available-options` report** carries:

- **Summary.** The recommendation, the options considered, the deciding factor, the validation outcome, and remaining
  risks.
- **Goal and Constraints.** The work, and the constraints any option must meet.
- **Current State.** What the code does today where the work would land.
- **Options.** Two or more genuinely different ways to do the work, each with how it works, its change surface, how it
  fits existing patterns, and its costs and risks.
- **Comparison.** The options against the constraints.
- **Recommendation.** The pick, why, and what would change the call.
- **Evidence Summary and Validation Results.**
- **Coding Standards Reference.** The standards that bear on the options.

**Every report shares** an **Evidence Summary** (E1, E2, …, consolidated from every agent, duplicates merged) and
**Validation Results** (V1, V2, … from `adversarial-validator`, each recording the challenge, the result, and its
impact), followed by **Adjustments Made** and the **Confidence Assessment**.

The run ends by saying where the report is and what to do next. After a bug report, reply "approve" to have the session
implement the Planned Fix, or reply with corrections. After the other two, the skill points you at `/plan-a-change` or
`/plan-a-feature` for the next step, and at `/research` when options need prior art.

## How to get the most out of it

- **Name the symptom or the question concretely.** _"Stale data after update"_ beats _"profile issue."_ _"How does the
  retry queue pick a backoff"_ beats _"explain the queue."_
- **Name the type when you know it.** Detection is good at the common shapes, but a question that mentions a failure in
  passing reads as a bug. If the opening block shows the wrong type, re-run with the type first.
- **Drop in any evidence you already have.** Error messages, stack traces, log excerpts, recent deploy notes, vendor
  docs. Paste them. The agents read the codebase, but they cannot see your production logs or the web unless you bring
  them in.
- **Let the validator push back.** The adversarial validation step frequently reshapes the conclusion. Treat validation
  findings as first-class input.
- **Pair with `/iterative-plan-review`** if a bug's fix plan needs further stress-testing before implementation.
- **Re-run after the fix.** Once a fix has shipped, re-run against the incident context with _"did this fix hold?"_
  framing.
- **For the full end-to-end bug-handling workflow**, see
  [How to triage and investigate a bug](../../../docs/how-to/triage-and-investigate-a-bug.md).

## Cost and latency

Each type dispatches two to five agents in parallel for evidence, then `adversarial-validator` agents for validation,
then one `han-communication:readability-editor` rewrite. A bug run sends at least two `evidence-based-investigator`
agents plus zero to three specialists. A how-it-works or options run sends two agents plus zero to three specialists.
Agents run on their default models. Expect one evidence round, one validation round, and one readability pass, roughly
five to eight sub-agent dispatches. The skill is built for per-question cadence, not tight-loop iteration.

## In more detail

The skill walks a six-step process. The type file under `references/types/` drives every step that differs by type.

1. **Resolve the type, the question, and the report path.** The skill parses a leading type token and a trailing report
   path, detects or checks the type, asks once on a clear mismatch, resolves where the report goes, and prints the
   opening block.
2. **Gather evidence.** The type's agents run in parallel. Extra agents from `.han/config.md` join when their specialty
   matches. The skill compiles one numbered evidence list (E1, E2, E3, …), tagging specialist findings with their domain.
3. **Analyze and write the report.** The skill runs the type's analysis steps into the type's template under
   `references/templates/`, for example [`references/templates/bug.md`](../../skills/investigate/references/templates/bug.md).
   The evidence and validation sections every type shares live in
   [`references/evidence-and-validation.md`](../../skills/investigate/references/evidence-and-validation.md).
4. **Adversarial validation.** `adversarial-validator` agents receive the full evidence and the type's conclusion. They
   challenge the evidence, the conclusion, and the assumptions. Counter-evidence becomes `V#` findings that reshape the
   report.
5. **Summary and readability.** The skill writes the Summary, then dispatches `readability-editor` to rewrite the
   write-up for the type's reader, preserving every fact and `file:line` reference, and runs a readability self-check.
6. **Present the report.** The skill prints the type's closing line and how to re-run as another type.

## Sources

The skill's protocols are grounded in established practice for evidence-based root-cause analysis and adversarial
review.

### Toyota Production System: The Five Whys

Root-cause analysis via repeated "why" questioning, popularized at Toyota and adopted widely across software and
operations. The `bug` type applies it to the evidence chain: every root-cause claim must trace back to at least one `E#`
evidence item and survive the adversarial-validator's counter-evidence search.

URL: https://www.toyota-industries.com/company/history/toyoda_precepts/

### John Allspaw: Blameless Post-Mortems and the Art of Learning from Incidents

Allspaw's work at Etsy on blameless post-mortems reframed incident analysis around understanding cause, not assigning
blame. The skill's evidence summary, analysis, and validation sections follow this posture: findings cite code and
behavior, not people or teams.

URL: https://www.etsy.com/codeascraft/blameless-postmortems

### Klein: Pre-Mortem (The Power of Intuition)

Gary Klein's pre-mortem technique (imagining the plan has already failed and asking why, before it ships) maps directly
to the skill's adversarial-validator step. The validator assumes the conclusion is wrong and hunts for why. The resulting
counter-evidence reshapes the report before anyone acts on it.

URL: https://hbr.org/2007/09/performing-a-project-premortem

### The Pragmatic Programmer (Hunt and Thomas): Bisecting and Rubber Duck Debugging

The Pragmatic Programmer formalized rubber-duck debugging and evidence-bisection as core debugging disciplines. The bug
type's parallel-angle investigation (error path vs. data flow vs. recent changes) is evidence-bisection applied at the
agent level.

URL: https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [Skills Index](../../../docs/skills/README.md). All skills, grouped by purpose.
- [`/investigate-to-confluence`](../../../han-atlassian/docs/skills/investigate-to-confluence.md). Runs this skill as
  any of its investigation types and publishes the report to a Confluence page after you confirm. Requires the opt-in
  `han-atlassian` plugin.
- [`/issue-triage`](../../../han-research/docs/skills/issue-triage.md). Run before investigation when the incoming report is too vague to
  trace; triage produces the sharp problem statement investigation needs.
- [`/research`](../../../han-research/docs/skills/research.md). The open-web sibling. Use it when the answer lives
  outside this codebase: prior art, outside libraries, or how an outside technology works.
- [`evidence-based-investigator`](../../../han-core/docs/agents/evidence-based-investigator.md). The agent a bug run
  dispatches in parallel for multi-angle evidence gathering.
- [`codebase-explorer`](../../../han-core/docs/agents/codebase-explorer.md). The agent how-it-works and options runs
  dispatch to find entry points, core logic, and precedent.
- [`adversarial-validator`](../../../han-core/docs/agents/adversarial-validator.md). The agent that challenges the
  evidence and the conclusion after the report is drafted.
- [`readability-editor`](../../../han-communication/docs/agents/readability-editor.md). Dispatched after validation to
  rewrite the write-up for the type's reader, preserving every fact and `file:line` reference. Separate from the
  accuracy validation pass.
- [Evidence](../../../docs/evidence.md). The canonical evidence rule the skill applies to every finding. Codebase findings stand
  on their citation; pasted web context is subject to the corroboration gate when it drives a conclusion; no-evidence
  states are labeled rather than guessed at.
- [`concurrency-analyst`](../../../han-core/docs/agents/concurrency-analyst.md),
  [`behavioral-analyst`](../../../han-core/docs/agents/behavioral-analyst.md),
  [`structural-analyst`](../../../han-core/docs/agents/structural-analyst.md),
  [`data-engineer`](../../../han-core/docs/agents/data-engineer.md). Specialist analysts dispatched when the question
  calls for them.
- [`/iterative-plan-review`](../../../han-planning/docs/skills/iterative-plan-review.md). Pair when a bug's fix plan needs further
  stress-testing before implementation.
- [`/plan-a-change`](../../../han-planning/docs/skills/plan-a-change.md) and
  [`/plan-a-feature`](../../../han-planning/docs/skills/plan-a-feature.md). The next step after a how-it-works or
  options report, when you are ready to plan the change.
- [`/code-review`](./code-review.md). Run before merge when the fix lands, to audit the change end-to-end.
- [`/code-overview`](./code-overview.md). The orientation sibling. Use it for a written overview of a whole target
  rather than an answer to one question.
- [`/code-walkthrough`](./code-walkthrough.md). The learning-shaped sibling. Use it when you want to be paced through
  how a change works in conversation.
- [`/runbook`](../../../han-documentation/docs/skills/runbook.md). Pair after the investigation lands a procedure the team will reuse. Investigate
  captures the root cause and fix; the runbook captures the procedure for the next engineer who sees the same symptom.
- [`SKILL.md` for /investigate](../../skills/investigate/SKILL.md). The internal process definition.

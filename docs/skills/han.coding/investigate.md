# /investigate

Operator documentation for the `/investigate` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.coding/skills/investigate/SKILL.md`](../../../han.coding/skills/investigate/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Evidence-based investigation of a bug, failure, or unexpected behavior, followed by adversarial validation of the proposed fix.
- **When to use it.** Something is broken and you want a root cause backed by file-level evidence, not a guess.
- **What you get back.** An investigation report with symptoms, numbered evidence (E1, E2, …), root cause analysis, fix plan, and validation findings (V1, V2, …).

## Key concepts

- **Trace backward from symptoms.** Don't guess. Follow the code. The skill works from the observed failure outward to the data flow, the error path, and the recent changes that might have broken it.
- **Parallel evidence gathering with specialists.** At least two `evidence-based-investigator` agents run in parallel, each from a different angle: one on the error path, one on the data flow. When the symptom matches, specialist analysts dispatch in parallel alongside the investigators. `concurrency-analyst` for intermittent / race / timeout bugs. `behavioral-analyst` for data-flow and error-propagation bugs. `data-engineer` for schema, query, migration, and isolation bugs. Specialists find root causes generalists miss.
- **Evidence is numbered.** Every finding gets an ID (E1, E2, E3…) so the root-cause analysis and fix plan can reference specific evidence explicitly (*"the handler passes an unvalidated ID (E1) to the service layer, which assumes non-nil (E3)"*).
- **Adversarial validation before ship.** After the fix is planned, `adversarial-validator` agents try to falsify the evidence, break the fix, and challenge the assumptions. Counter-evidence becomes validation findings (V1, V2, …) that reshape the plan.
- **Coding-standards aware.** The fix plan is written against the project's standards, ADRs, and inferred patterns. Not against generic best practice.

## When to use it

**Invoke when:**

- A bug, failure, or unexpected behavior needs a root cause backed by code-level evidence.
- An integration or API call is misbehaving and you want a trace from symptoms to data flow to recent changes.
- You suspect a regression and want the investigation to consider git history alongside the code.
- You want the proposed fix adversarially validated, not just designed, before writing any code.
- You want a durable report that names the exact file, function, and line where the problem originates, plus the evidence that proves it.

**Do not invoke for:**

- **Code review.** Use [`/code-review`](./code-review.md) for a correctness, testing, and compliance audit of a branch.
- **Architectural analysis.** Use [`/architectural-analysis`](../han.coding/architectural-analysis.md) for coupling, data flow, concurrency, and SOLID assessment of a module.
- **Test planning.** Use [`/test-planning`](./test-planning.md) when the gap is coverage, not a bug.
- **Plan review.** Use [`/iterative-plan-review`](../han.planning/iterative-plan-review.md) for multi-pass review of an existing plan.
- **Open-ended research.** Use [`/research`](../han.core/research.md) when nothing is broken and you want options, prior art, or how something works before committing to a direction.
- **Feedback on Han's own skills.** Use [`/han-feedback`](../han.feedback/han-feedback.md) to capture post-session feedback on the Han skills you ran.

## How to invoke it

Run `/investigate` in Claude Code with a description of the problem.

Give it:

1. **The symptom.** What you observed: the error message, the unexpected value, the failed deploy, the intermittent timeout. A concrete observation collapses the initial search space.
2. **The reproduction context, if known.** Environment, branch, specific user account, specific data, specific time. The skill does not need a full reproduction (it can investigate from a single observation), but the more context you give, the faster the angles converge.
3. **An output path, optional.** The skill writes the investigation plan to a file. Default lives under `~/.claude/plans/` if no path is given.

Example prompts:

- `/investigate`. *"Why are webhook deliveries failing intermittently in production?"*
- `/investigate`. *"Users are seeing stale data after updating their profile. The update returns 200 but the next page load shows the old value."*
- `/investigate`. *"The background job queue is backing up during peak hours. Jobs enqueued at 9am don't run until 9:30am."*
- `/investigate docs/incidents/2026-04-23.md`. Investigate and write the report into the incident folder.

## What you get back

An investigation plan file, plus an in-channel summary. The plan leads with the bottom line and keeps the supporting detail near the end, so it reads conclusion-first. Sections appear only when the investigation produced meaningful content for them; one that would be empty is omitted, and the rest keep the order below. So a given report covers some or all of, in order:

- **Summary.** One sentence each for root cause, fix, why correct, validation outcome, remaining risks. Up top so a reader gets the verdict before the backing detail.
- **Problem Statement.** Symptoms, expected behavior, conditions under which it occurs, impact.
- **Root Cause Analysis.** One to three sentences summarizing the root cause, followed by a detailed analysis that references evidence items by number.
- **Planned Fix.** Per-file changes: full path, what will be modified, which evidence items justify the change, which standards apply, and implementation specifics (new function signatures, changed logic, updated tests).
- **Evidence Summary.** A numbered list (E1, E2, E3, …) consolidated from the parallel `evidence-based-investigator` agents. Duplicates merged; conflicts resolved with explicit citations.
- **Validation Findings.** Numbered `V1, V2, …` entries from `adversarial-validator`. Each records the challenge attempted, whether counter-evidence was found, and what changed in response. Followed by **Adjustments Made** (what changed after validation, cross-referenced to the `V#` that drove it) and the **Confidence Assessment and Remaining Risks** that close the validator's judgment.
- **Coding Standards Reference.** For each standard that applies, what it says, where it was found (path, ADR number, or *"inferred from surrounding code"*), and which files the fix will touch. This keeps the fix consistent with how the project already works.

The plan is presented for approval before any code is written. Approve to trigger implementation; push back with feedback to revise.

## How to get the most out of it

- **Name the symptom concretely.** *"Stale data after update"* beats *"profile issue."* The more specific the observation, the sharper the investigator agents' angles.
- **Drop in any evidence you already have.** Error messages, stack traces, log excerpts, recent deploy notes, the commit you suspect. Paste them. The skill's agents read the codebase, but they cannot see your production logs unless you bring them in.
- **Let the validator push back.** The adversarial validation step is not ceremony. It frequently reshapes the root cause analysis. Treat validation findings as first-class input.
- **Pair with `/iterative-plan-review`** if the fix plan needs further stress-testing before implementation, especially when the fix touches cross-cutting concerns.
- **Re-run after the fix.** Once the fix has shipped, re-run against the incident context with *"did this fix hold?"* framing. Validation findings from the new run confirm or falsify the hypothesis under production conditions.
- **For the full end-to-end bug-handling workflow**, including when to triage instead of investigating now and how to bring in production logs and browser integrations, see [How to triage and investigate a bug](../../how-to/triage-and-investigate-a-bug.md).

## Cost and latency

The skill dispatches at least two `evidence-based-investigator` agents in parallel, plus zero to three specialist analysts (`concurrency-analyst`, `behavioral-analyst`, `data-engineer`) depending on bug classification, followed by `adversarial-validator` agents for the validation pass. Agents run on their default models. For a medium-complexity bug, expect one investigation round plus one validation round, roughly four to seven sub-agent dispatches. The skill is built for per-bug cadence, not tight-loop iteration. Fix the bug and move on.

## In more detail

The skill walks a five-step process:

1. **Research and investigation.** At least two `evidence-based-investigator` agents run in parallel, each from a different angle. Specialist analysts (`concurrency-analyst`, `behavioral-analyst`, `data-engineer`) dispatch in parallel alongside them based on how you described the symptom. After all complete, the skill compiles a unified numbered evidence list (E1, E2, E3, …), tagging specialist findings with their domain.
2. **Document root cause.** The skill writes Problem Statement, Evidence Summary, and Root Cause Analysis into the plan file using the template at [`references/template.md`](../../../han.coding/skills/investigate/references/template.md).
3. **Plan the fix.** The skill resolves project config (CLAUDE.md → project-discovery.md → docs/ Glob fallback), reads ADRs and coding standards relevant to the fix, and writes the Planned Fix section with file-level changes justified by specific evidence items.
4. **Adversarial validation.** `adversarial-validator` agents receive the full evidence summary, root cause analysis, and planned fix. They challenge evidence, challenge the fix, and challenge assumptions. Counter-evidence becomes `V#` findings that reshape the plan.
5. **Summary and user review.** The skill writes the Summary section at the top of the report and presents the plan for approval.

## Sources

The skill's protocols are grounded in established practice for evidence-based root-cause analysis and adversarial review.

### Toyota Production System: The Five Whys

Root-cause analysis via repeated "why" questioning, popularized at Toyota and adopted widely across software and operations. The skill applies it to the evidence chain: every root-cause claim must trace back to at least one `E#` evidence item and survive the adversarial-validator's counter-evidence search.

URL: https://www.toyota-industries.com/company/history/toyoda_precepts/

### John Allspaw: Blameless Post-Mortems and the Art of Learning from Incidents

Allspaw's work at Etsy on blameless post-mortems reframed incident analysis around understanding cause, not assigning blame. The skill's evidence summary, root-cause analysis, and validation sections follow this posture: findings cite code and behavior, not people or teams.

URL: https://www.etsy.com/codeascraft/blameless-postmortems

### Klein: Pre-Mortem (The Power of Intuition)

Gary Klein's pre-mortem technique (imagining the plan has already failed and asking why, before it ships) maps directly to the skill's adversarial-validator step. The validator assumes the fix will fail and hunts for why. The resulting counter-evidence reshapes the plan before it becomes production code.

URL: https://hbr.org/2007/09/performing-a-project-premortem

### The Pragmatic Programmer (Hunt and Thomas): Bisecting and Rubber Duck Debugging

The Pragmatic Programmer formalized rubber-duck debugging and evidence-bisection as core debugging disciplines. The skill's parallel-angle investigation (error path vs. data flow vs. recent changes) is evidence-bisection applied at the agent level.

URL: https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/issue-triage`](../han.core/issue-triage.md). Run before investigation when the incoming report is too vague to trace; triage produces the sharp problem statement investigation needs.
- [`/research`](../han.core/research.md). The question-shaped sibling. Use it when nothing is broken and you want options, prior art, or how something works before committing.
- [`evidence-based-investigator`](../../agents/han.core/evidence-based-investigator.md). The agent the skill dispatches in parallel for multi-angle evidence gathering.
- [`adversarial-validator`](../../agents/han.core/adversarial-validator.md). The agent that challenges evidence and fix after the plan is drafted.
- [Evidence](../../evidence.md). The canonical evidence rule the skill applies to every finding. Codebase findings stand on their citation; web-source context is subject to the corroboration gate when it drives the proposed fix; no-evidence states are labeled rather than guessed at.
- [`concurrency-analyst`](../../agents/han.core/concurrency-analyst.md), [`behavioral-analyst`](../../agents/han.core/behavioral-analyst.md), [`data-engineer`](../../agents/han.core/data-engineer.md). Specialist analysts dispatched alongside the investigators when the symptom classification calls for them.
- [`/iterative-plan-review`](../han.planning/iterative-plan-review.md). Pair when the fix plan needs further stress-testing before implementation.
- [`/code-review`](./code-review.md). Run before merge when the fix lands, to audit the change end-to-end.
- [`/runbook`](../han.core/runbook.md). Pair after the investigation lands a procedure the team will reuse. Investigate captures the root cause and fix; the runbook captures the procedure for the next engineer who sees the same symptom.
- [`SKILL.md` for /investigate](../../../han.coding/skills/investigate/SKILL.md). The internal process definition.

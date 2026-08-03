# plan-synthesizer

Operator documentation for the `plan-synthesizer` agent in the han plugin. This document helps you decide _when_ and
_how_ to dispatch the agent. For what the agent does internally, read the agent definition at
[`han-core/agents/plan-synthesizer.md`](../../agents/plan-synthesizer.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md) · [YAGNI](../../../docs/yagni.md) · [Evidence](../../../docs/evidence.md)

## TL;DR

- **What it does.** Reconciles the input from every specialist who contributed to a discussion into a final plan the team
  can commit to.
- **When to dispatch it.** A discussion has run its course and the team needs the plan of record: decisions, rejected
  alternatives, evidence, and remaining open items.
- **What you get back.** A synthesized plan with a decision record and a RAID log, written to disk by default, plus a
  short posture-and-counts summary in the tool response.

## Key concepts

- **One role: it produces.** The agent generates the plan. It does not audit the discussion that fed it. That half
  belongs to [`discussion-facilitator`](../../../han-planning/docs/agents/discussion-facilitator.md), so the reasoning
  that writes a plan is never the reasoning that grades it.
- **Strict evidence standard.** Every recommendation, claim, and proposal must be backed by valid, contextually relevant
  evidence. The agent pushes back hard when it is not, and records what would settle the question.
- **RAID log carried forward.** Risks, Assumptions, Issues, and Decisions arrive from the discussion record and survive
  into the plan, pruned to what is still open at synthesis.
- **Disagree-and-commit with recorded dissent.** Once the decision is committed, the team commits with it. Dissent with
  cited evidence is recorded so the decision can reopen cleanly if the evidence changes.
- **Caller-controlled writes.** By default it writes `synthesized-plan.md`. When a caller directs it not to write a file,
  it returns the same content in full instead.

## Summary

A facilitative synthesizer that turns cross-specialist input into a plan the team can commit to. Its default posture is
adversarial toward the work on the table (plans, processes, proposed solutions, recommendations, inconsistencies,
undocumented assumptions) and collaborative toward the team members who produced them.

It is strict about evidence. Every recommendation, claim, and proposal must be backed by valid, contextually relevant
evidence, and the agent pushes back hard when it is not.

It reads every contributor's input, reconciles the recommendations against each other and against the project's
standards, and records each committed decision with its rationale, its rejected alternatives, and the evidence behind
the call.

Final decisions belong to the synthesizer, but it does not close over a voice the record never heard. When a domain the
plan touches has no contributor in the inputs, that becomes a specialist handoff rather than a decision made on the
specialist's behalf.

The agent focuses on outcomes (shipping working software quickly while protecting the future operability of the system
at scale), not on implementation detail, which remains the specialists' domain.

## When to use it

**Dispatch when:**

- A discussion has run its course across multiple specialists and the team needs a final plan committed to disk, with the
  decisions made, the alternatives rejected (and why), the evidence behind each call, and the remaining open items.
- A set of specialist findings is on the table (from UX, DevOps, security, architecture, testing, and so on) and someone
  needs to reconcile the recommendations and produce a coherent plan the team can commit to.
- A decision has been reached informally in conversation and needs to be recorded as a decision log entry with rationale,
  rejected alternatives, evidence, specialist owner, and revisit criterion so the team can revisit it cleanly later if
  evidence changes.
- A PRD or design doc is ready to be converted into an actionable plan with a clear definition of done, acceptance
  criteria, smallest viable slice, rollback plan, and post-ship ownership.
- A trusted plan needs breaking into a drafted set of work units, returned rather than written. `/plan-work-items`
  dispatches the agent this way.

**Do not dispatch for:**

- **Auditing a discussion in progress.** Running the round-robin, challenging claims as they surface, and logging what is
  still open belongs to [`discussion-facilitator`](../../../han-planning/docs/agents/discussion-facilitator.md). It
  decides nothing, which is the point: a different agent audits the discussion that feeds this one.
- **Specialist-depth analysis of any kind.** The agent delegates all specialist work. If you need UX analysis, use
  `user-experience-designer`. Security exploit paths, use `adversarial-security-analyst`. Production readiness, use
  `devops-engineer`. Intra-codebase architectural SOLID / coupling analysis, use `structural-analyst` /
  `behavioral-analyst` / `concurrency-analyst` / `risk-analyst` / `software-architect`. Cross-service / bounded-context
  topology, use `system-architect`. Test planning, use `test-engineer` / `edge-case-explorer`. Bug root-cause work, use
  `evidence-based-investigator`. Spec-vs-implementation gap, use `gap-analyzer`. Documentation preservation, use
  `content-auditor`. Adversarial validation of a completed investigation or fix, use `adversarial-validator`. Generalist
  clarifying questions before specialists, use `junior-developer`.
- **Implementation calls.** The agent does not pick the data store, the framework, the test library, or the feature-flag
  strategy. Those belong to the specialists whose domain owns the call.
- **Writing or modifying code.** The agent produces a plan. Not code changes, not implementation.
- **Plan iteration in isolation.** If you already have a drafted plan and want to stress-test it through multiple review
  passes, use `/iterative-plan-review`.
- **Investigation of a specific bug.** Use `/investigate` and `evidence-based-investigator` for evidence-based root-cause
  work.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:plan-synthesizer`.

Give it:

1. **The inputs from the discussion.** Paths to specialist reports (UX analysis, DevOps readiness report, code review,
   test plan, architectural analysis), paths to a prior facilitation summary, an aggregated round record, or a clear
   paraphrase of the discussion outcomes. Synthesis is only as good as the inputs. Thin inputs produce thin plans with
   many open items.
2. **The outcome the plan should deliver.** One or two sentences on what shipping this plan should accomplish.
3. **Any deadline or constraint context.** If the plan has a ship date, a compliance deadline, an incident driving it, or
   a strategic commitment behind it, state that so the driving-constraint section is grounded.
4. **The standards library references.** Point the agent at `CLAUDE.md`, `project-discovery.md`,
   `docs/coding-standards/`, and the ADR directory so the inconsistency and standards-conflict check has material to work
   against.
5. **An output path, or a directive not to write.** The agent writes the plan to disk and returns a summary. Default
   filename is `synthesized-plan.md`. Pass "do not write any files" and it returns the full content instead.

Example prompts that work well:

- _"We've heard from the UX, DevOps, and test-engineer agents on the new notification feature. Here are the three reports
  [paths]. Synthesize a plan the team can commit to: decisions, rejected alternatives, evidence, and remaining open
  items."_
- _"The team reached a decision on the queue migration during yesterday's design review. Here are the notes [path].
  Produce a decision record for the commit with rationale, rejected alternatives, evidence, specialist owner, and revisit
  criterion."_
- _"Take the facilitation summary at `docs/plans/facilitation-auth-migration.md` and synthesize the final plan. Flag
  anything that should block ship."_
- _"Synthesize a plan for shipping the reports API caching layer. The devops-engineer flagged cache stampede risk, the
  structural-analyst flagged coupling between the controller and the cache, and the test-engineer flagged a hole in the
  invalidation tests. Produce the committable plan."_

Thin prompts (_"make a plan for X"_) still work but produce more open items and shallower decisions. The agent is
designed to recommend a return to facilitation when synthesis cannot be clean.

## What you get back

- A summary in the tool-call response:
  - A one-to-three-sentence posture on whether the plan is committable today or blocked pending a specialist handoff or
    open item.
  - A counts table (decisions committed, rejected alternatives, risks, assumptions, dependencies, remaining open items,
    specialist handoffs for implementation).
  - A ship recommendation.
  - The path to the full synthesized plan, when one was written.
- A full synthesized plan with:
  - The outcome statement.
  - Context (driving constraint, stakeholders, future-state concern, out-of-scope boundary).
  - The participation record.
  - Numbered decisions (each with rationale, evidence, rejected alternatives, specialist owner, revisit criterion, and
    any recorded dissent).
  - The RAID log carried forward.
  - The definition-of-done and smallest-viable-slice record.
  - Specialist handoffs for implementation.
  - A `## Deferred (YAGNI)` section when anything failed the evidence gate.
  - Any remaining open items.

Every claim and decision is traceable to a specific citation (evidence) or a specific question (when evidence is
missing). When evidence is missing and cannot be gathered in the current run, the plan is not synthesized cleanly. The
blocking open items are named and the agent recommends returning to facilitation.

## How to get the most out of it

- **State the outcome up front.** The single biggest lever. An outcome stated in one or two plain-language sentences
  collapses whole classes of open questions during Protocol 1. If the outcome is unclear, the agent will tell you. That
  is itself useful signal.
- **Facilitate before you synthesize.** Synthesis is only as strong as its inputs. Run
  [`discussion-facilitator`](../../../han-planning/docs/agents/discussion-facilitator.md) over the live discussion first,
  then hand its summary here. That ordering is also what keeps the producing and grading roles apart.
- **Name every specialist who contributed.** The agent builds the participation record from what you hand it. Missing
  specialist context produces missing specialist participation records and extra handoffs.
- **Point it at the standards library.** CLAUDE.md, ADRs, coding standards, and any project-discovery reference sharpen
  the inconsistency and standards-conflict check. When those are missing, the agent flags the missing library as a
  finding. Useful signal on its own.
- **Treat open questions as work.** Open questions are not rhetorical. Each one is something the team must answer before
  the plan can be fully trusted. The agent will not close an open question by inventing a plausible answer.
- **Dispatch the named handoffs.** When the plan names specialists to bring in for implementation (for example,
  _"devops-engineer to confirm rollout plan"_), dispatch them rather than treating the handoff as decoration.
- **Pair with a reviewer agent.** The synthesizer generates the plan. It does not evaluate its own output. For
  adversarial validation of the finished plan, follow it with `adversarial-validator` or a `junior-developer`
  stress-test. See
  [multi-agent-economics.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md)
  for why self-evaluation is a bad default.
- **Re-run after changes.** As specialists report back, open questions become answered questions, and the synthesis
  improves. The agent is designed to be re-dispatched once new evidence has landed.

## Cost and latency

The agent runs on `opus`. A single synthesis pass is slower and more expensive than a typical lookup agent, which is
intentional. The task is multi-dimensional synthesis across specialist inputs, claim ledgers, RAID tracking, and
standards libraries, plus the judgment call of which questions would change the decision and which specialists must be
heard before the plan can commit. Avoid dispatching it in parallel for the same discussion or in tight loops over every
planning conversation. Scope tightly and it pays off.

## YAGNI

The agent applies the **YAGNI Evidence Gate** protocol before any decision is written. A discussion can commit many kinds
of proposals: a plan step, abstraction, infrastructure addition, configuration knob, ADR, coding standard, test, or build
phase. Each one must cite at least one piece of acceptable evidence that it is needed _now_. If no evidence surfaces,
the item moves to a `## Deferred (YAGNI)` section in the synthesized plan with a named _reopen-when_ trigger. The agent
never silently drops a deferral. You always see the deferred item and the trigger that would justify reopening it, so
the choice to keep or release the item stays conscious.

See [YAGNI](../../../docs/yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

Alongside the YAGNI gate, the agent applies the companion [evidence rule](../../../docs/evidence.md) to characterize the quality
of evidence each surviving item rests on. It names the trust class of the citation (codebase, web, provided), marks
single-source web claims that cannot stand alone, and labels claims with no evidence at any tier as a distinct deferred
state rather than weak evidence.

## Sources

The agent's posture and protocols draw on established project-management practice and research. Each source below is
cited because the agent draws specific, named artifacts from it.

### PMI: PMBOK Guide (7th and 8th Editions)

The PMBOK 7th Edition reoriented project management around value delivery, systems thinking, and principled
decision-making rather than process checklists. PMBOK 8 (launching the updated PMP exam in July 2026) extends this
emphasis on stakeholder engagement, governance, and tailoring. The agent's focus on outcomes over process, its
out-of-scope boundary protocol, and its future-state scan reflect this value-delivery framing.

URLs: https://www.pmi.org/standards/pmbok and https://projectmanagementacademy.net/resources/blog/what-is-pmbok-8/

### RAID Log: Risks, Assumptions, Issues, Decisions

The RAID log is a standard project-management artifact for tracking the four items a plan cannot survive without. The
agent's Protocol 4 carries the RAID log forward into the synthesized plan. Risks come with likelihood, severity, blast
radius, reversibility, owner, and mitigation. Assumptions come with what-changes-if-wrong. Issues with an owner and next
step. Decisions with rationale, rejected alternatives, and evidence.

URLs: https://asana.com/resources/raid-log and https://www.smartsheet.com/content/raid-logs

### Decision Logs and Agile Decision-Making

Decision logs are the Agile-era discipline for recording the _what_ and the _why_ of a decision so the team can revisit
it cleanly later if evidence changes. The agent's Protocol 9 (Decision Synthesis) records decision ID, rationale,
rejected alternatives, evidence, specialist owner, and revisit criterion. That is the full decision-log shape, applied
inside a synthesized plan rather than as a separate artifact.

URLs: https://projectmanagementcompass.substack.com/p/building-decision-logs-that-protect and
https://www.projectmanagertemplate.com/post/decision-logs-the-ultimate-guide

### Amazon: Have Backbone; Disagree and Commit

Jeff Bezos's _"Have Backbone; Disagree and Commit"_ is the canonical articulation of this principle. Teammates may
disagree with a decision, but once the evidence has been weighed and every relevant voice has been heard, the team
commits to executing it. The agent encodes this in Protocol 9 (Decision Synthesis), which records the dissent and its
cited evidence alongside the committed decision so the call can be revisited later if evidence changes.

URLs: https://en.wikipedia.org/wiki/Disagree_and_commit and
https://www.amazon.jobs/content/en/our-workplace/leadership-principles

### Servant Leadership in Agile and Scrum

The servant-leader framing (from Robert Greenleaf, applied to Agile by Ken Schwaber and Jeff Sutherland) casts the
coordinator as someone who serves the team. That means removing impediments, protecting focus, and enabling
decision-making rather than imposing it. The agent's posture (adversarial toward the work, collaborative toward the
people) comes from this tradition.

URLs: https://www.toptal.com/project-managers/agile/agile-servant-leadership and
https://www.atlassian.com/agile/scrum/scrum-master-project-manager

### Acceptance Criteria and Definition of Done

Acceptance criteria and Definition of Done are the standard project-management artifacts for making "done" testable
rather than subjective. The agent's Protocol 5 requires a testable definition of done, unambiguous acceptance criteria,
a smallest-viable-slice framing, a rollback plan, and a post-ship owner. Vague done-criteria are flagged as open items
that block synthesis.

URLs: https://www.atlassian.com/work-management/project-management/acceptance-criteria and
https://www.projectmanager.com/blog/acceptance-criteria-project-management

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs tree.
- [YAGNI](../../../docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the
  acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../../../docs/evidence.md). The companion rule the agent applies alongside YAGNI. Trust classes, the corroboration
  gate, and the no-evidence label.
- [Agents Index](../../../docs/agents/README.md). All agents, grouped by role.
- [`discussion-facilitator`](../../../han-planning/docs/agents/discussion-facilitator.md). The reviewer half of the same
  split. It audits a discussion in progress and decides nothing; this agent produces the plan from what it surfaced.
- [`junior-developer`](./junior-developer.md). The generalist stress-tester that reframes specialist input in plain
  language when it gets entangled.
- [`/plan-a-feature`](../../../han-planning/docs/skills/plan-a-feature.md) and
  [`/plan-implementation`](../../../han-planning/docs/skills/plan-implementation.md). Skills that dispatch this agent for
  final synthesis.
- [`/plan-work-items`](../../../han-planning/docs/skills/plan-work-items.md). Dispatches this agent to draft the work
  items as vertical slices from the trusted plan, writing no files.
- [`/gap-analysis`](../../../han-research/docs/skills/gap-analysis.md). Dispatches this agent at medium and large swarm
  sizes to consolidate swarm output into Section 4 of the report.
- [agent-domain-focus.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md).
  The one-role-per-agent rule that produced this split, plus why the agent uses precise project-management vocabulary
  (RAID, disagree-and-commit, revisit criterion, servant leader) and named anti-patterns.
- [agent-model-selection.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md).
  Rationale for the `opus` model tier on a synthesis-heavy agent.
- [graceful-degradation.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/graceful-degradation.md).
  Why the agent handles missing git, missing standards documents, and missing ADRs inline rather than failing.
- [multi-agent-economics.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md).
  Why this agent reconciles specialists rather than replacing them.

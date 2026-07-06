# project-manager

Operator documentation for the `project-manager` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/project-manager.md`](../../../han-core/agents/project-manager.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [YAGNI](../../yagni.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Coordinates discussions between specialist agents and synthesizes their input into a final plan.
- **When to dispatch it.** Multi-specialist planning, design review, or architecture debate needs a facilitator. OR a plan is ready for a final synthesis pass after specialist input has been gathered.
- **What you get back.** Either a facilitation summary with tracked open items (facilitation mode) or a final synthesized plan with decisions, rejected alternatives, and evidence (synthesis mode).

## Key concepts

- **Two modes.** Facilitation mode runs round-robin discussions so every specialist is heard. Synthesis mode produces the final committable plan with a RAID log and decisions.
- **Round-robin facilitation.** Every relevant specialist is asked in turn: quieter voices before the loudest. *"No concerns from my side"* is a valid, recorded answer.
- **Strict evidence standard.** Every recommendation, claim, and proposal must be backed by valid, contextually relevant evidence. The PM pushes back hard when it is not.
- **Live RAID log.** Risks, Assumptions, Issues, Decisions tracked continuously so nothing load-bearing goes undocumented. The synthesized plan carries the RAID log forward.
- **Disagree-and-commit with recorded dissent.** Once the decision is made, the team commits. Dissent with cited evidence is recorded so the decision can reopen cleanly if evidence changes.
- **Explicit stand-down.** When a specialist is not needed on a plan, the PM tells them so rather than letting their attention drift.

## Summary

A seasoned, facilitative project manager that coordinates discussions between the team's specialist sibling agents and synthesizes their input into a final plan the team can commit to. Its default posture is adversarial toward the work on the table (plans, processes, proposed solutions, recommendations, inconsistencies, undocumented assumptions) and collaborative toward the team members who produced them.

It is strict about evidence. Every recommendation, claim, and proposal must be backed by valid, contextually relevant evidence, and the agent pushes back hard when it is not.

It runs round-robin facilitation, so every relevant specialist is heard regardless of subject-matter expertise in the topic on the table. It also tracks a live RAID log of risks, assumptions, issues, and decisions, so nothing load-bearing goes undocumented.

Final decisions belong to the PM, but the PM does not decide until every relevant specialist has been heard. When it does decide, it records the decision, the rejected alternatives, and the evidence.

When a specialist is not needed on a plan, the PM tells them so explicitly rather than letting their attention drift onto unrelated work.

The PM focuses on outcomes (shipping working software quickly while protecting the future operability of the system at scale), not on implementation detail, which remains the specialists' domain.

## When to use it

The agent has two modes (facilitation and synthesis). Invoke the right one for the situation.

**Facilitation mode. Invoke when:**

- A planning session, design review, architecture debate, migration discussion, or cross-specialist coordination conversation needs a project-management voice to keep the team on the real work, surface hidden assumptions, and enforce evidence-based reasoning.
- Multiple specialists are weighing in on a plan and the conversation needs round-robin facilitation so every relevant voice is heard rather than letting the loudest specialist dominate.
- A discussion is drifting into implementation minutiae that the specialists can resolve on their own, or skating past a systemic concern because it looks *"like just implementation."* The team needs a facilitator to re-focus on outcomes.
- A claim in the discussion is surviving because it has been repeated, not because it has been proven, and someone needs to put it in the claim ledger and ask what evidence would resolve it.
- Open questions, undocumented assumptions, and inconsistencies are piling up in a conversation and need to be tracked live so they can be resolved before a plan can be considered done.
- The team wants to know which specialists still need to be consulted before synthesis can happen, and which specialists can be explicitly sent home because the plan does not touch their domain.

**Synthesis mode. Invoke when:**

- A discussion has run its course across multiple specialists and the team needs a final plan committed to disk, with the decisions made, the alternatives rejected (and why), the evidence behind each call, and the remaining open items.
- A set of specialist findings is on the table (from UX, DevOps, security, architecture, testing, and so on) and someone needs to reconcile the recommendations and produce a coherent plan the team can commit to.
- A decision has been reached informally in conversation and needs to be recorded as a decision log entry with rationale, rejected alternatives, evidence, specialist owner, and revisit criterion so the team can revisit it cleanly later if evidence changes.
- A PRD or design doc is ready to be converted into an actionable plan with a clear definition of done, acceptance criteria, smallest viable slice, rollback plan, and post-ship ownership.

**Do not dispatch for:**

- **Specialist-depth analysis of any kind.** The agent delegates all specialist work. If you need UX analysis, use `user-experience-designer`. Security exploit paths, use `adversarial-security-analyst`. Production readiness, use `devops-engineer`. Intra-codebase architectural SOLID / coupling analysis, use `structural-analyst` / `behavioral-analyst` / `concurrency-analyst` / `risk-analyst` / `software-architect`. Cross-service / bounded-context topology, use `system-architect`. Test planning, use `test-engineer` / `edge-case-explorer`. Bug root-cause work, use `evidence-based-investigator`. Spec-vs-implementation gap, use `gap-analyzer`. Documentation preservation, use `content-auditor`. Adversarial validation of a completed investigation or fix, use `adversarial-validator`. Generalist clarifying questions before specialists, use `junior-developer`.
- **Implementation calls.** The agent does not pick the data store, the framework, the test library, or the feature-flag strategy. Those belong to the specialists whose domain owns the call.
- **Writing or modifying code.** The agent produces a facilitation summary or a synthesized plan. Not code changes, not implementation.
- **Plan iteration in isolation.** If you already have a drafted plan and want to stress-test it through multiple review passes without multi-specialist facilitation, use `/iterative-plan-review`.
- **Investigation of a specific bug.** Use `/investigate` and `evidence-based-investigator` for evidence-based root-cause work.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:project-manager`. Pick the right mode for the situation.

### Facilitation mode

Give it:

1. **What the team is discussing.** A summary of the conversation, a quoted chat thread, a meeting transcript, a paraphrase of the current proposal, or a prompt describing the planning problem on the table. The narrower and more specific the topic, the sharper the facilitation.
2. **Who is in the discussion so far.** Specialists already contributing, their input to date (if any), and their recommendations. The agent uses this to run the round-robin and decide who still needs to be invited in and who can be sent home.
3. **The outcome the team is working toward.** One or two sentences on what shipping this plan should deliver. If the outcome is unclear, the agent starts there. Protocol 1 is outcome clarification.
4. **Any standards library references.** Point the agent at `CLAUDE.md`, `project-discovery.md`, `docs/coding-standards/`, and the ADR directory so the inconsistency and standards-conflict check has material to work against.
5. **An output path, optional.** The agent writes the facilitation summary to disk and returns a short response. Default filename is `facilitation-summary.md`.

Example prompts that work well:

- *"We're in a design review for the webhook retry system. The engineer proposing is pushing for a new queue service because 'the current one is slow.' Facilitate. What does the discussion need to resolve, and which specialists should be in the room?"*
- *"Three specialists have weighed in on the auth migration: the security-analyst says rotate the token signing keys, the devops-engineer says the rollout plan is unclear, and the structural-analyst says the middleware boundary is fuzzy. Run round-robin facilitation. Are we ready for synthesis, and what's missing?"*
- *"The team is about to commit to a database migration plan. Facilitate the conversation, check for hidden assumptions and inconsistencies, and tell me which specialists need to chime in before we can synthesize."*
- *"Here's the chat thread from the last 30 minutes [paste]. Facilitate. What's evidenced, what's anecdotal, what's disputed, and what open questions would block a synthesized plan?"*

### Synthesis mode

Give it:

1. **The inputs from facilitation or from specialist runs.** Paths to specialist reports (UX analysis, DevOps readiness report, code review, test plan, architectural analysis), paths to prior facilitation summaries, or a clear paraphrase of the discussion outcomes. Synthesis is only as good as the inputs. Thin inputs produce thin plans with many open items.
2. **The outcome the plan should deliver.** Same as facilitation mode: one or two sentences on what shipping this plan should accomplish.
3. **Any deadline or constraint context.** If the plan has a ship date, a compliance deadline, an incident driving it, or a strategic commitment behind it, state that so the driving-constraint section is grounded.
4. **The standards library references.** Same as facilitation mode. The agent checks the synthesized plan against CLAUDE.md, ADRs, and coding standards for internal consistency.
5. **An output path, optional.** The agent writes the synthesized plan to disk and returns a summary. Default filename is `synthesized-plan.md`.

Example prompts that work well:

- *"We've heard from the UX, DevOps, and test-engineer agents on the new notification feature. Here are the three reports [paths]. Synthesize a plan the team can commit to: decisions, rejected alternatives, evidence, and remaining open items."*
- *"The team reached a decision on the queue migration during yesterday's design review. Here are the notes [path]. Produce a decision record for the commit with rationale, rejected alternatives, evidence, specialist owner, and revisit criterion."*
- *"Take the facilitation summary at `docs/plans/facilitation-auth-migration.md` and synthesize the final plan. Flag anything that should block ship."*
- *"Synthesize a plan for shipping the reports API caching layer. The devops-engineer flagged cache stampede risk, the structural-analyst flagged coupling between the controller and the cache, and the test-engineer flagged a hole in the invalidation tests. Produce the committable plan."*

Thin prompts (*"make a plan for X"*) still work but produce more open items and shallower decisions. The agent is designed to return to facilitation if synthesis cannot be clean.

## What you get back

**In facilitation mode:**

- A summary in the tool-call response:
  - A one-to-three-sentence posture (is the conversation ready for synthesis, needs more specialists, or needs to return to outcome clarification?).
  - A counts table (evidenced / anecdotal / disputed claims, risks, assumptions, issues, decisions committed, open questions, specialist handoffs).
  - A next-step recommendation.
  - The path to the full facilitation summary.
- A full facilitation summary on disk with:
  - The outcome statement.
  - The driving constraint and stakeholders.
  - The specialist participation record (who's in, who's invited, who's been sent home).
  - The claim ledger (each claim categorized Evidenced / Anecdotal / Disputed).
  - The live RAID log.
  - Scope and definition-of-done findings.
  - Inconsistency and standards-conflict findings.
  - Future-state concerns.
  - Open questions.
  - Specialist handoffs.
  - The recommended next step.

**In synthesis mode:**

- A summary in the tool-call response:
  - A one-to-three-sentence posture on whether the plan is committable today or blocked pending a specialist handoff or open item.
  - A counts table (decisions committed, rejected alternatives, risks, assumptions, dependencies, remaining open items, specialist handoffs for implementation).
  - A ship recommendation.
  - The path to the full synthesized plan.
- A full synthesized plan on disk with:
  - The outcome statement.
  - Context (driving constraint, stakeholders, future-state concern, out-of-scope boundary).
  - The participation record.
  - Numbered decisions (each with rationale, evidence, rejected alternatives, specialist owner, revisit criterion, and any recorded dissent).
  - The RAID log carried forward.
  - The definition-of-done and smallest-viable-slice record.
  - Specialist handoffs for implementation.
  - Any remaining open items.

In both modes, every claim and decision is traceable to a specific citation (evidence) or a specific question (when evidence is missing). When evidence is missing and cannot be gathered in the current run, the plan is not synthesized cleanly. The blocking open items are named and the agent recommends returning to facilitation.

## How to get the most out of it

- **State the outcome up front.** The single biggest lever. An outcome stated in one or two plain-language sentences collapses whole classes of open questions during Protocol 1. If the outcome is unclear, the agent will tell you. That is itself useful signal.
- **Name the specialists who should be in the room.** If you already know the plan touches UX, security, and DevOps, say so. The agent runs a round-robin against the specialists it knows about. Missing specialist context produces missing specialist participation records.
- **Point it at the standards library.** CLAUDE.md, ADRs, coding standards, and any project-discovery reference sharpen the inconsistency and standards-conflict check. When those are missing, the agent flags the missing library as a finding. Useful signal on its own.
- **Treat open questions as work.** Open questions are not rhetorical. Each one is something the team must answer (from a specialist, from evidence-gathering, from a stakeholder) before the plan can be fully trusted. The agent will not close an open question by inventing a plausible answer.
- **Use facilitation before synthesis.** Synthesis is only as strong as the facilitation inputs. If the discussion has not had round-robin facilitation, the synthesis will have gaps. Run facilitation mode first, then synthesis mode with the facilitation summary as input.
- **Dispatch the named specialists.** The PM's job is to coordinate, not to replace. When the facilitation summary names specialists to bring in (for example, *"devops-engineer to confirm rollout plan"*), dispatch those specialists before returning to synthesis.
- **Honor the "not needed" calls.** When the PM explicitly says a specialist is not needed on a plan, that is also a decision worth honoring. It frees the specialist's attention for work where their domain is touched.
- **Pair with a reviewer agent.** The PM generates the plan. It does not evaluate its own output. If you want adversarial validation of the synthesized plan, follow it with `adversarial-validator` or a `junior-developer` stress-test. See [multi-agent-economics.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md) for why self-evaluation is a bad default.
- **Re-run after changes.** As specialists report back, open questions become answered questions, and the synthesis improves. The agent is designed to be re-dispatched once new evidence has landed.

## Cost and latency

The agent runs on `opus`. A single facilitation or synthesis pass is slower and more expensive than a typical lookup agent, which is intentional. The task is multi-dimensional synthesis across specialist inputs, claim ledgers, RAID tracking, and standards libraries, plus the judgment call of *which* questions would change the decision and *which* specialists must be heard before the plan can commit. Avoid dispatching it in parallel for the same discussion or in tight loops over every planning conversation. Scope tightly and it pays off.

## YAGNI

The agent applies the **YAGNI Evidence Gate** protocol during facilitation and synthesis. A discussion can commit many kinds of proposals: a plan step, abstraction, infrastructure addition, configuration knob, ADR, coding standard, test, or build phase. Each one must cite at least one piece of acceptable evidence that it is needed *now*. Uncited proposals are challenged in the discussion. If no evidence surfaces, they move to a `## Deferred (YAGNI)` section in the synthesized output with a named *reopen-when* trigger. The agent never silently drops a deferral. You always see the deferred item and the trigger that would justify reopening it, so the choice to keep or release the item stays conscious.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

Alongside the YAGNI gate, the agent applies the companion [evidence rule](../../evidence.md) to characterize the quality of evidence each surviving item rests on. It names the trust class of the citation (codebase, web, provided), marks single-source web claims that cannot stand alone, and labels claims with no evidence at any tier as a distinct deferred state rather than weak evidence.

## Sources

The agent's posture and protocols draw on established project-management practice and research. Each source below is cited because the agent draws specific, named artifacts from it.

### PMI: The Facilitative Project Manager

The Project Management Institute publishes guidance on facilitative project management. It defines the project manager as a process expert whose job is to enable effective decision-making by the group, not to make decisions alone. The agent's round-robin protocol is taken directly from this practice. So is its insistence on hearing every relevant voice before decision, and its posture of driving ownership of a decision to the level where accountability sits.

URL: https://www.pmi.org/learning/library/the-facilitative-project-manager-6970

### PMI: PMBOK Guide (7th and 8th Editions)

The PMBOK 7th Edition reoriented project management around value delivery, systems thinking, and principled decision-making rather than process checklists. PMBOK 8 (launching the updated PMP exam in July 2026) extends this emphasis on stakeholder engagement, governance, and tailoring. The agent's focus on outcomes over process, its out-of-scope boundary protocol, and its future-state scan reflect this value-delivery framing.

URLs: https://www.pmi.org/standards/pmbok and https://projectmanagementacademy.net/resources/blog/what-is-pmbok-8/

### RAID Log: Risks, Assumptions, Issues, Decisions

The RAID log is a standard project-management artifact for tracking, continuously, the four items a plan cannot survive without. The agent's Protocol 4 implements the RAID log live through facilitation and carries it forward into synthesis. Risks come with likelihood, severity, blast radius, reversibility, owner, and mitigation. Assumptions come with what-changes-if-wrong. Issues with an owner and next step. Decisions with rationale, rejected alternatives, and evidence.

URLs: https://asana.com/resources/raid-log and https://www.smartsheet.com/content/raid-logs

### Decision Logs and Agile Decision-Making

Decision logs are the Agile-era discipline for recording the *what* and the *why* of a decision so the team can revisit it cleanly later if evidence changes. The agent's Protocol 9 (Decision Synthesis) records decision ID, rationale, rejected alternatives, evidence, specialist owner, and revisit criterion. That is the full decision-log shape, applied inside a synthesized plan rather than as a separate artifact.

URLs: https://projectmanagementcompass.substack.com/p/building-decision-logs-that-protect and https://www.projectmanagertemplate.com/post/decision-logs-the-ultimate-guide

### Round-Robin Facilitation

Round-robin is a facilitation technique in which every relevant participant speaks in turn, deliberately, so quieter voices are heard before the loudest voice takes the room. The agent's Protocol 2 implements round-robin across the specialist sibling agents it knows about. It explicitly captures *"no concerns from my side"* as a valid, recorded answer, so participation is never silently assumed.

URLs: https://www.mindtools.com/a81qk8y/round-robin-brainstorming/ and https://goodgroupdecisions.com/round-robin/

### Amazon: Have Backbone; Disagree and Commit

Jeff Bezos's *"Have Backbone; Disagree and Commit"* is the canonical articulation of this principle. Teammates may disagree with a decision, but once the evidence has been weighed and every relevant voice has been heard, the team commits to executing it. And the dissent, with its cited evidence, is recorded so the decision can be revisited later if evidence changes. The agent encodes this in Protocol 9 (Decision Synthesis), which records the dissent and its cited evidence alongside the committed decision so the call can be revisited later if evidence changes.

URLs: https://en.wikipedia.org/wiki/Disagree_and_commit and https://www.amazon.jobs/content/en/our-workplace/leadership-principles

### Servant Leadership in Agile and Scrum

The servant-leader framing (from Robert Greenleaf, applied to Agile by Ken Schwaber and Jeff Sutherland) casts the facilitator as someone who serves the team. That means removing impediments, protecting focus, and enabling decision-making rather than imposing it. The agent's posture (adversarial toward the work, collaborative toward the people) and its practice of sending specialists home when their domain is not touched both come from this tradition.

URLs: https://www.toptal.com/project-managers/agile/agile-servant-leadership and https://www.atlassian.com/agile/scrum/scrum-master-project-manager

### Acceptance Criteria and Definition of Done

Acceptance criteria and Definition of Done are the standard project-management artifacts for making "done" testable rather than subjective. The agent's Protocol 5 requires a testable definition of done, unambiguous acceptance criteria, a smallest-viable-slice framing, a rollback plan, and a post-ship owner. Vague done-criteria are flagged as open items that block synthesis.

URLs: https://www.atlassian.com/work-management/project-management/acceptance-criteria and https://www.projectmanager.com/blog/acceptance-criteria-project-management

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../../evidence.md). The companion rule the agent applies alongside YAGNI. Trust classes, the corroboration gate, and the no-evidence label.
- [Agents Index](../README.md). All agents, grouped by role.
- [`junior-developer`](./junior-developer.md). The generalist stress-tester the PM leans on for plain-language reframing when specialist input gets entangled.
- [`/plan-a-feature`](../../skills/han-planning/plan-a-feature.md) and [`/plan-implementation`](../../skills/han-planning/plan-implementation.md). Skills that dispatch this agent as coordinator and synthesizer.
- [`/gap-analysis`](../../skills/han-core/gap-analysis.md). Dispatches this agent in synthesis mode at medium and large swarm sizes to consolidate swarm output into Section 4 of the report.
- [agent-domain-focus.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise project-management vocabulary (RAID, disagree-and-commit, revisit criterion, servant leader) and named anti-patterns.
- [agent-model-selection.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier on a synthesis-heavy coordination agent.
- [graceful-degradation.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/graceful-degradation.md). Why the agent handles missing git, missing standards documents, and missing ADRs inline rather than failing.
- [multi-agent-economics.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md). Why this agent is a coordinator of specialists, not a specialist replacement.

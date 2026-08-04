# discussion-facilitator

Operator documentation for the `discussion-facilitator` agent in the han plugin. This document helps you decide _when_
and _how_ to dispatch the agent. For what the agent does internally, read the agent definition at
[`han-planning/agents/discussion-facilitator.md`](../../agents/discussion-facilitator.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) · [All agents](../../../docs/agents/README.md) ·
> [All skills](../../../docs/skills/README.md) · [YAGNI](../../../docs/yagni.md) · [Evidence](../../../docs/evidence.md)

## TL;DR

- **What it does.** Audits a planning discussion in progress: runs the round-robin, grades every claim against evidence,
  and logs what the team has not answered yet.
- **When to dispatch it.** A multi-specialist conversation is still live and you want to know what is evidenced, what is
  assumed, and who has not been heard, before anyone commits to a plan.
- **What you get back.** A facilitation summary returned in full to the caller. It writes no files and decides nothing.

## Key concepts

- **One role: it evaluates.** The agent audits the discussion. It never produces the plan. That half belongs to
  [`plan-synthesizer`](../../../han-core/docs/agents/plan-synthesizer.md), so the reasoning that grades a discussion is
  never the reasoning that writes the plan from it.
- **Round-robin facilitation.** Every relevant specialist is asked in turn: quieter voices before the loudest. _"No
  concerns from my side"_ is a valid, recorded answer.
- **Strict evidence standard.** Every claim on the table is graded Evidenced, Anecdotal, or Disputed, and a claim
  surviving on repetition rather than proof gets named as such.
- **Live RAID log.** Risks, Assumptions, Issues, and proposed Decisions tracked continuously so nothing load-bearing goes
  undocumented before synthesis.
- **It decides nothing.** Premature closure is an anti-pattern, and the decision is not the facilitator's to make. Its
  strongest verdict is "go to synthesis."
- **Explicit stand-down.** When a specialist is not needed on a plan, the agent says so rather than letting their
  attention drift.

## Summary

A facilitative auditor that works a live planning discussion and surfaces everything the team has not answered yet. Its
default posture is adversarial toward the work on the table (plans, processes, proposed solutions, recommendations,
inconsistencies, undocumented assumptions) and collaborative toward the team members who produced them.

It is strict about evidence. Every recommendation, claim, and proposal must be backed by valid, contextually relevant
evidence, and the agent pushes back hard when it is not.

It runs round-robin facilitation, so every relevant specialist is heard regardless of subject-matter expertise in the
topic on the table. It also tracks a live RAID log of risks, assumptions, issues, and proposed decisions, so nothing
load-bearing goes undocumented.

It does not decide, and it does not write. It hands the plan of record to `han-core:plan-synthesizer` and returns its
summary to the caller in full.

The agent focuses on outcomes (shipping working software quickly while protecting the future operability of the system
at scale), not on implementation detail, which remains the specialists' domain.

## When to use it

**Dispatch when:**

- A planning session, design review, architecture debate, migration discussion, or cross-specialist coordination
  conversation needs a facilitative voice to keep the team on the real work, surface hidden assumptions, and enforce
  evidence-based reasoning.
- Multiple specialists are weighing in on a plan and the conversation needs round-robin facilitation so every relevant
  voice is heard rather than letting the loudest specialist dominate.
- A discussion is drifting into implementation minutiae that the specialists can resolve on their own, or skating past a
  systemic concern because it looks _"like just implementation."_
- A claim in the discussion is surviving because it has been repeated, not because it has been proven, and someone needs
  to put it in the claim ledger and ask what evidence would resolve it.
- Open questions, undocumented assumptions, and inconsistencies are piling up in a conversation and need to be tracked
  live so they can be resolved before a plan can be considered done.
- The team wants to know which specialists still need to be consulted before synthesis can happen, and which specialists
  can be explicitly sent home because the plan does not touch their domain.
- A deterministic aggregation reached a conclusion you want a second, independent read on before escalating it to a
  person. `/plan-implementation` dispatches the agent exactly this way when its spec-maturity gate trips.

**Do not dispatch for:**

- **Producing the plan.** Reconciling specialist input into committed decisions, rejected alternatives, and a plan of
  record belongs to [`plan-synthesizer`](../../../han-core/docs/agents/plan-synthesizer.md). This agent decides nothing,
  which is the point: a different agent writes the plan it audits toward.
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
- **Writing anything to disk.** The agent holds no `Write` tool. Its output comes back through the tool response.
- **Plan iteration in isolation.** If you already have a drafted plan and want to stress-test it through multiple review
  passes without multi-specialist facilitation, use `/iterative-plan-review`.
- **Investigation of a specific bug.** Use `/investigate` and `evidence-based-investigator` for evidence-based
  root-cause work.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-planning:discussion-facilitator`.

Give it:

1. **What the team is discussing.** A summary of the conversation, a quoted chat thread, a meeting transcript, a
   paraphrase of the current proposal, or the verbatim outputs of the specialists who have reported so far. The narrower
   and more specific the topic, the sharper the facilitation.
2. **Who is in the discussion so far.** Specialists already contributing, their input to date, and their
   recommendations. The agent uses this to run the round-robin and decide who still needs to be invited in and who can be
   sent home.
3. **The outcome the team is working toward.** One or two sentences on what shipping this plan should deliver. If the
   outcome is unclear, the agent starts there. Protocol 1 is outcome clarification.
4. **Any standards library references.** Point the agent at `CLAUDE.md`, `project-discovery.md`,
   `docs/coding-standards/`, and the ADR directory so the inconsistency and standards-conflict check has material to work
   against.

Example prompts that work well:

- _"We're in a design review for the webhook retry system. The engineer proposing is pushing for a new queue service
  because 'the current one is slow.' Facilitate. What does the discussion need to resolve, and which specialists should
  be in the room?"_
- _"Three specialists have weighed in on the auth migration: the security-analyst says rotate the token signing keys, the
  devops-engineer says the rollout plan is unclear, and the structural-analyst says the middleware boundary is fuzzy. Run
  round-robin facilitation. Are we ready for synthesis, and what's missing?"_
- _"The team is about to commit to a database migration plan. Facilitate the conversation, check for hidden assumptions
  and inconsistencies, and tell me which specialists need to chime in before we can synthesize."_
- _"Here's the chat thread from the last 30 minutes [paste]. Facilitate. What's evidenced, what's anecdotal, what's
  disputed, and what open questions would block a synthesized plan?"_

## What you get back

A full facilitation summary in the tool-call response, carrying:

- The outcome statement, driving constraint, stakeholders, future-state concern, and out-of-scope boundary.
- The specialist participation record (who's in, who's invited, who's been sent home and why).
- The claim ledger, with each claim categorized Evidenced, Anecdotal, or Disputed and the citation or resolving question
  beside it.
- The live RAID log, with decisions recorded as proposed rather than committed.
- Scope and definition-of-done findings.
- Inconsistency and standards-conflict findings, each with the cited standard and the conflicting part of the plan.
- Future-state concerns, each assigned to the specialist domain that owns it.
- YAGNI candidates, each with its failure mode and recommended resolution.
- Numbered open questions, each marked as blocking synthesis or not.
- Specialist handoffs.
- The recommended next step, and a closing counts table.

Nothing is written to disk. When the discussion is ready, the next step names `han-core:plan-synthesizer`.

## How to get the most out of it

- **State the outcome up front.** The single biggest lever. An outcome stated in one or two plain-language sentences
  collapses whole classes of open questions during Protocol 1. If the outcome is unclear, the agent will tell you. That
  is itself useful signal.
- **Name the specialists who should be in the room.** If you already know the plan touches UX, security, and DevOps, say
  so. The agent runs a round-robin against the specialists it knows about. Missing specialist context produces missing
  specialist participation records.
- **Point it at the standards library.** CLAUDE.md, ADRs, coding standards, and any project-discovery reference sharpen
  the inconsistency and standards-conflict check. When those are missing, the agent flags the missing library as a
  finding. Useful signal on its own.
- **Treat open questions as work.** Open questions are not rhetorical. Each one is something the team must answer (from a
  specialist, from evidence-gathering, from a stakeholder) before the plan can be fully trusted. The agent will not close
  an open question by inventing a plausible answer.
- **Facilitate before you synthesize.** Hand the returned summary to
  [`plan-synthesizer`](../../../han-core/docs/agents/plan-synthesizer.md) rather than asking either agent to do both
  jobs. That ordering is the whole reason the two exist separately.
- **Dispatch the named specialists.** When the summary names specialists to bring in (for example, _"devops-engineer to
  confirm rollout plan"_), dispatch those specialists before returning to synthesis.
- **Honor the "not needed" calls.** When the agent explicitly says a specialist is not needed on a plan, that is also a
  finding worth honoring. It frees the specialist's attention for work where their domain is touched.
- **Re-run as the discussion moves.** Each pass is a snapshot of what is evidenced and what is open. Re-dispatch once
  specialists have reported back and the picture has changed.

## Cost and latency

The agent runs on `opus`. A single facilitation pass is slower and more expensive than a typical lookup agent, which is
intentional. The task is a multi-dimensional audit across specialist inputs, claim ledgers, RAID tracking, and standards
libraries, plus the judgment call of which questions would change the decision and which specialists must be heard
before the plan can commit. Avoid dispatching it in parallel for the same discussion or in tight loops over every
planning round. `/plan-implementation` makes at most one call to it per run, for exactly this reason.

## YAGNI

The agent applies the **YAGNI Evidence Gate** protocol during facilitation. A discussion can propose many kinds of items:
a plan step, abstraction, infrastructure addition, configuration knob, ADR, coding standard, test, or build phase. Each
one must cite at least one piece of acceptable evidence that it is needed _now_. Uncited proposals are challenged in the
discussion, and the specialist who raised one is asked to either find the evidence or restate the item as a deferral.
Everything that fails surfaces under YAGNI Candidates with its failure mode and recommended resolution, so the choice to
keep or release the item stays conscious.

See [YAGNI](../../../docs/yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

Alongside the YAGNI gate, the agent applies the companion [evidence rule](../../../docs/evidence.md) to characterize the quality
of evidence each surviving item rests on. It names the trust class of the citation (codebase, web, provided), marks
single-source web claims that cannot stand alone, and labels claims with no evidence at any tier as a distinct deferred
state rather than weak evidence.

## Sources

The agent's posture and protocols draw on established project-management practice and research. Each source below is
cited because the agent draws specific, named artifacts from it.

### PMI: The Facilitative Project Manager

The Project Management Institute publishes guidance on facilitative project management. It defines the project manager as
a process expert whose job is to enable effective decision-making by the group, not to make decisions alone. The agent's
round-robin protocol is taken directly from this practice. So is its insistence on hearing every relevant voice before a
decision, and its posture of driving ownership of a decision to the level where accountability sits.

URL: https://www.pmi.org/learning/library/the-facilitative-project-manager-6970

### RAID Log: Risks, Assumptions, Issues, Decisions

The RAID log is a standard project-management artifact for tracking, continuously, the four items a plan cannot survive
without. The agent's Protocol 4 implements the RAID log live through facilitation. Risks come with likelihood, severity,
blast radius, reversibility, owner, and mitigation. Assumptions come with what-changes-if-wrong. Issues with an owner and
next step. Proposed decisions with rationale, rejected alternatives, and evidence.

URLs: https://asana.com/resources/raid-log and https://www.smartsheet.com/content/raid-logs

### Round-Robin Facilitation

Round-robin is a facilitation technique in which every relevant participant speaks in turn, deliberately, so quieter
voices are heard before the loudest voice takes the room. The agent's Protocol 2 implements round-robin across the
specialist sibling agents it knows about. It explicitly captures _"no concerns from my side"_ as a valid, recorded
answer, so participation is never silently assumed.

URLs: https://www.mindtools.com/a81qk8y/round-robin-brainstorming/ and https://goodgroupdecisions.com/round-robin/

### Servant Leadership in Agile and Scrum

The servant-leader framing (from Robert Greenleaf, applied to Agile by Ken Schwaber and Jeff Sutherland) casts the
facilitator as someone who serves the team. That means removing impediments, protecting focus, and enabling
decision-making rather than imposing it. The agent's posture (adversarial toward the work, collaborative toward the
people) and its practice of sending specialists home when their domain is not touched both come from this tradition.

URLs: https://www.toptal.com/project-managers/agile/agile-servant-leadership and
https://www.atlassian.com/agile/scrum/scrum-master-project-manager

### Acceptance Criteria and Definition of Done

Acceptance criteria and Definition of Done are the standard project-management artifacts for making "done" testable
rather than subjective. The agent's Protocol 5 asks for a testable definition of done, unambiguous acceptance criteria, a
smallest-viable-slice framing, a rollback plan, and a post-ship owner. Vague done-criteria are flagged as open items that
block synthesis.

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
- [`plan-synthesizer`](../../../han-core/docs/agents/plan-synthesizer.md). The producer half of the same split. This
  agent audits the discussion; that one writes the plan of record from it.
- [`junior-developer`](../../../han-core/docs/agents/junior-developer.md). The generalist stress-tester this agent leans
  on for plain-language reframing when specialist input gets entangled.
- [`/plan-implementation`](../skills/plan-implementation.md). The skill that dispatches this agent, once per run, on
  the spec-maturity gate-trip pass.
- [agent-domain-focus.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md).
  The one-role-per-agent rule that produced this split, plus why the agent uses precise project-management vocabulary
  (RAID, claim ledger, servant leader) and named anti-patterns.
- [agent-model-selection.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md).
  Rationale for the `opus` model tier on a judgment-heavy audit agent.
- [graceful-degradation.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/graceful-degradation.md).
  Why the agent handles missing git, missing standards documents, and missing ADRs inline rather than failing.
- [multi-agent-economics.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md).
  Why the worker-plus-reviewer split this agent belongs to is worth a second agent.

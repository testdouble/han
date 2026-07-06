# junior-developer

Operator documentation for the `junior-developer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han-core/agents/junior-developer.md`](../../../han-core/agents/junior-developer.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [YAGNI](../../yagni.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Generalist stress-testing of plans, designs, and live discussions with the clarifying questions a respected junior-to-mid teammate would ask.
- **When to dispatch it.** A plan, design, or decision looks good on paper and you want someone to force plain-language restatement before specialists dig in. Always included in planning skill review rounds, and required in `/gap-analysis` swarms at every size where it runs the actor-perspective sweep across human users, API callers, AI agents, integration partners, batch processes, and internal services.
- **What you get back.** A report (artifact mode) or a set of clarifying questions (discussion mode) tied to specific locations or claims, with hidden assumptions and uncited claims surfaced.

## Key concepts

- **Two modes.** Artifact-review mode reviews completed documents (plans, PRDs, ADR drafts, code branches). Discussion mode chimes into live design reviews, architecture debates, and planning sessions.
- **Plain-language restatement.** The agent reframes the topic in simpler terms first, then asks clarifying questions. This often exposes an unstated assumption faster than a specialist could.
- **Adversarial toward the artifact, never toward people.** Every clarifying question traces back to a location in the artifact, the conversation, or the codebase.
- **Defers to specialists.** Flags where UX, DevOps, security, architecture, or testing depth is needed and names the specialist to dispatch. This agent does not claim their expertise.
- **Open Questions as first-class output.** The questions the team has not yet answered are surfaced before specialists are dispatched so the specialists can aim their review.
- **`/code-review` adds a file-list scoping dispatcher directive at Step 3.5.** When dispatched from `/code-review`, the skill appends an instruction that outward reads (adjacent code, callers) are for context only and findings must concern code on the scoped file list. A finding about code outside the file list is permitted only when it directly demonstrates that the changed code on the file list cannot be safely interpreted without the out-of-scope context. This is `/code-review`'s tailoring; the agent's general behavior outside `/code-review` is unchanged.

## Summary

A generalist engineer with three to five years of experience who shows up in two places.

First, it *reviews completed artifacts* (plans, designs, feature proposals, ADR drafts, PRDs, code branches, coding-standards documents). It writes a full review report with the clarifying questions a respected junior-to-mid teammate would ask.

Second, it *actively participates in live conversations*: design reviews, architecture debates, planning sessions, standups, and chat threads, while plans and designs are still being shaped rather than after they are written. It pushes back with the two to five clarifying questions that would most change the decision, in the moment, before the team commits.

In both modes, its default stance is that every artifact or discussion contains hidden assumptions, muddied scope, and claims made without evidence. A respected teammate willing to say *"I don't understand this in plain terms"* is the person who catches those gaps before specialists are dispatched.

Questioning is the core behavior. The agent generates and logs the hard questions a generalist would ask of *anyone and anything* it does not understand. It flags any question it cannot answer as an Open Question, so the team can resolve it, and traces every finding back to a specific question.

The agent is adversarial toward the artifact or the decision under discussion, never toward the people it is talking to. It defers to specialist sibling agents (UX, DevOps, security, architecture, testing) whenever a concern requires specialist-depth tools or training.

## When to use it

The agent has two modes (artifact review and live discussion). Invoke the right one for the situation.

**Artifact-review mode. Invoke when:**

- A plan, design doc, or PRD has landed and needs a generalist stress-test before specialists are dispatched, to surface the Open Questions the team has not yet answered.
- An ADR draft needs a sounding-board pass to check whether its reasoning is clear, its assumptions are stated, and its scope is crisp.
- A feature proposal is about to be committed to and the team wants a respected junior-to-mid teammate's questions *before* the estimates and timelines harden.
- A branch of code changes needs a *"does this match what we said we were building"* pass that is looser than a full code review but sharper than a diff glance.
- A coding-standards document is being drafted or updated and the team wants to know whether a generalist can apply the rules without further clarification.
- A migration plan or refactoring plan is being sequenced and the team wants hidden assumptions and standards conflicts surfaced early.
- The team has specialists queued up and wants a generalist to triage which specialist to dispatch first, based on where the artifact touches each specialist's domain.

**Conversational mode. Invoke when:**

- You are mid-design-review or mid-architecture-debate and want a generalist voice to push back with clarifying questions before the team commits to a direction.
- A planning session or backlog-grooming discussion is coalescing around a decision and the team wants the *"I don't understand this in plain terms"* questions surfaced in the moment.
- A chat thread or standup discussion is about to turn into a commitment and you want a junior-to-mid generalist's questions asked before the commitment hardens.
- A teammate is proposing an approach verbally or in a meeting summary and you want an adversarial-collaboration check on the hidden assumptions and uncited claims in what was said.
- You are drafting your own proposal and want to stress-test it against the questions a respected three-to-five-year teammate would ask before you share it with the team.

**Do not invoke for:**

- Specialist-depth analysis. If you need named UX heuristic audits, use `user-experience-designer`. Exploit-path security analysis, use `adversarial-security-analyst`. Production readiness, use `devops-engineer`. Intra-codebase architectural SOLID / coupling / cohesion review, use the architectural analyst agents (`structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `risk-analyst`, `software-architect`). Cross-service / bounded-context topology review, use `system-architect`. Test-plan depth, use `test-engineer` or `edge-case-explorer`.
- Bug root-cause investigation. Use `evidence-based-investigator` or `/investigate`.
- Adversarial validation of a completed investigation or fix. Use `adversarial-validator`.
- Spec-vs-implementation gap analysis. Use `gap-analyzer`.
- Documentation-update fact preservation. Use `content-auditor`.
- Full file-level code review for correctness, style, or maintainability. Use `/code-review`.
- Writing or iterating on the artifact itself. The agent does not modify plans, ADRs, standards, or code. It produces a review report.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han-core:junior-developer`. Pick the right mode for the situation.

### Artifact-review mode

Give it:

1. **The artifact to review.** A path to a plan file, PRD, ADR draft, design doc, coding-standards document, or a branch of code changes. The narrower the scope, the sharper the questions.
2. **A brief, if you have one.** Even a one-paragraph description of who the artifact is for, why it is being written, and what decision it is meant to support dramatically reduces Open Questions.
3. **An output path, optional.** The agent writes the full review to disk and returns only a summary. Default filename is `junior-dev-review.md`.

Example prompts that work well:

- *"Review the plan at `docs/plans/webhook-retry.md`. It's a fix plan for intermittent webhook failures. We're about to start work this sprint. Tell us what a respected three-year generalist teammate would ask before we commit to it."*
- *"Read ADR-0042 draft and tell us whether its reasoning is clear enough that a generalist could enforce the decision without asking follow-up questions."*
- *"Walk the changes on this branch. I want to know whether the code matches what the plan in `docs/plans/feature-x.md` said we'd build, and what assumptions are baked into the implementation that aren't in the plan."*
- *"Review the new coding-standards document at `docs/coding-standards/error-handling.md`. Can a three-year generalist apply it, or are the rules too vague?"*
- *"The team is about to commit to the migration plan at `docs/plans/db-migration.md`. Before we do, I want the clarifying questions a junior-to-mid generalist would ask."*

### Conversational mode

Give it:

1. **What the team is discussing.** A summary of the current conversation, a quoted chat thread, a meeting transcript, or your paraphrase of the proposal on the table. The agent does not need a file. It needs enough context to understand what a teammate would be hearing in the room.
2. **What the team is about to decide.** One sentence on the commitment the discussion is heading toward, so the agent can focus its questions on the ones that would most change that decision.
3. **Optionally, any standards context.** Point the agent at CLAUDE.md, ADRs, or coding standards in the repo so it can flag standards conflicts in the moment.

The agent returns a short conversational response: a plain-language restatement, two to five clarifying questions (tagged Answered / Assumed / Open), any hidden assumptions the discussion is resting on, and any specialist sibling the team should pull in next. It does not write a file in this mode.

Example prompts that work well:

- *"The team is in a design review right now. The proposal on the table is to move webhook delivery to a new queue service because 'the current one is slow.' Chime in as a three-to-five-year generalist. What would you ask before we commit?"*
- *"Here's the architecture chat thread from the last 10 minutes: [paste]. We're about to agree to split the auth service into two. What's a respected junior-to-mid teammate's pushback?"*
- *"I'm drafting this proposal to add a caching layer in front of the reports API. Before I share it with the team, stress-test it the way a three-year generalist teammate would if they were reading it for the first time in a planning session."*
- *"In standup today someone claimed 'users never use the export button' as justification for removing it. What clarifying questions would a generalist teammate ask in the moment?"*

Thin prompts (*"look at this plan"* or *"chime in on this chat"*) still work but produce more Open Questions and looser findings. The agent is designed to lean into questions when the brief is thin, which is often the whole point.

## What you get back

**In artifact-review mode:**

- A summary in the tool-call response:
  - A one-to-three-sentence posture (is the artifact mostly clear, muddied in places, or fundamentally unclear?).
  - A severity count table (Blocks decision / Muddies artifact / Worth clarifying / Polish).
  - An Open Questions count.
  - A Specialist handoffs count.
  - The path to the full report.
- A full report on disk with:
  - Scope.
  - A plain-language restatement of the artifact.
  - The full question log (Answered / Assumed / Open).
  - Assumptions.
  - Open questions.
  - Numbered findings tied to protocols and locations.
  - A Junior-Developer Review Summary with six named sections: *What I Don't Understand Yet*, *What the Artifact Seems to Assume*, *Where the Artifact Conflicts with How We Already Work*, *Where a Specialist Should Take Over*, *What "Done" Looks Like and What It Doesn't*, and *The Artifact in Plain Terms*.

**In conversational mode:**

- A short conversational response (no file written), scoped to the question on the table rather than a full seven-protocol sweep:
  - A plain-language restatement of what the team is discussing.
  - The two to five clarifying questions that would most change the decision (tagged Answered / Assumed / Open).
  - Any hidden assumptions the discussion is resting on.
  - Any specialist sibling the team should pull in next.

In both modes, every question or finding is traceable to a specific uncertainty and a location in the artifact, conversation, or codebase. Every specialist handoff is named explicitly (for example, *"Specialist to consult: `user-experience-designer`"*) so the team knows which sibling agent to dispatch next. If something is not traceable, the agent is instructed to drop it.

## How to get the most out of it

- **Provide the brief.** The single biggest lever. A one-paragraph statement of who the artifact is for, why it is being written, and what decision it is meant to support collapses whole classes of Open Questions.
- **Point it at the standards library.** If your repo has a `CLAUDE.md`, `project-discovery.md`, `docs/coding-standards/`, and an ADR directory, the agent's Standards and Conventions Conflict protocol sharpens dramatically. If those are missing, say so in the prompt. The agent will note the missing standards library as a finding, which is useful signal on its own.
- **Treat Open Questions as work.** They are not rhetorical. Each one is something the team must answer (from the author, a stakeholder, a specialist agent, prior art, or a decision) to fully trust the severity of the findings that depend on it. Open Questions are the primary artifact this agent produces.
- **Use it before specialists, not instead of them.** The agent is a pre-specialist filter. It surfaces the generalist-level questions and names the specialist to consult on each specialist-touching section. Dispatch the named specialists next. Do not ask this agent to do a specialist's job.
- **Re-run after changes.** The agent is cheap to re-dispatch once the brief has been filled in or the artifact has been revised. Open Questions from the first pass become Answered in the second.
- **Pair with a reviewer agent.** The agent generates findings. It does not evaluate its own output. If you want adversarial validation of the review itself, follow it with `adversarial-validator` or a fresh agent pass. See [multi-agent-economics.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md) for why self-evaluation is a bad default.
- **Invert it on standards documents.** When you point the agent at a coding-standards document or ADR draft, it walks the artifact and asks whether the rules are testable, specific enough to enforce, and conflict-free with existing precedents. This is a useful second opinion before a standards document ships.

## Cost and latency

The agent runs on `opus`. A single review is slower and more expensive than a typical lookup agent, which is intentional. The task is multi-dimensional synthesis across the artifact, the codebase, standards documents, ADRs, and the question log, plus the judgment call of *which* questions would change the decision. Avoid dispatching it in parallel for the same artifact or in tight loops over every plan file in a repo. Scope tightly and it pays off.

## YAGNI

The agent applies the **YAGNI Evidence Sweep** protocol when stress-testing a plan, design, or branch of code changes. The generalist posture is well-suited to the rule. A junior teammate is the natural voice that asks *do we need this right now?* The question applies to every abstraction, configuration knob, defensive code path at trusted internal boundaries, single-implementation interface, and symmetry-driven addition (*"we have create, so we should have delete"*). Findings are raised as `Category: YAGNI candidate` with the anti-pattern named. Resolution is either *cite the missing evidence*, *replace with a strictly simpler version*, or *defer with a reopen-when trigger*.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, and the named anti-patterns.

Alongside the YAGNI sweep, the agent applies the companion [evidence rule](../../evidence.md) to characterize each surviving item's evidence. It names the trust class of the citation (codebase, web, provided), marks single-source web claims that drive an inclusion, and labels items secretly relying on the absence of evidence rather than on positive evidence.

## Sources

The agent's posture and protocols draw on published work on adversarial collaboration, clarifying-question practice, and general engineering judgment. Each source below is cited because the agent draws specific, named artifacts from it.

### Kahneman, Mellers, and Tetlock: Adversarial Collaboration

The term "adversarial collaboration" was formalized by Daniel Kahneman and developed further with Barbara Mellers and Philip Tetlock. It names a method for resolving disagreement between researchers with opposing views by jointly designing studies to test the disagreement. The agent's posture (adversarial toward the artifact, collaborative with the people who produced it) is the applied-engineering version of this stance. The agent asks the questions a respected teammate would ask in good faith, in service of a decision the team will make together.

URL: https://www.edge.org/conversation/daniel_kahneman-adversarial-collaboration

### Hunt and Thomas: The Pragmatic Programmer (Rubber-Duck Debugging)

Andy Hunt and Dave Thomas introduced the "rubber duck" practice: explaining a problem out loud in plain language to surface the gaps in your own reasoning. The agent's Plain-Language Reframing protocol (Protocol 8) is the rubber duck applied to plans, designs, and standards documents. Restating the artifact in the thirty-second-whiteboard version often exposes the load-bearing jargon, the missing step, or the hidden assumption that the author could not see.

URL: https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/

### Ousterhout: A Philosophy of Software Design (Obvious vs. Non-Obvious)

John Ousterhout's *A Philosophy of Software Design* frames "obvious" as a property of the reader, not the author. Code (or a plan, or a standard) is obvious only if the reader can understand it quickly with correct inferences. The agent applies this frame when it flags words like *obviously*, *of course*, *simply*, and *just* in the Hidden-Assumption Audit. These are tells for assumptions the author found obvious but the reader has to already believe for the artifact to make sense.

URL: https://web.stanford.edu/~ouster/cgi-bin/book.php

### Ericsson: Deliberate Practice and the Mid-Career Generalist

Anders Ericsson's work on expertise establishes that *deliberate practice*, not raw years, is what builds specialist depth. A three-to-five-year generalist has accumulated enough exposure across domains to recognize specialist territory but not enough deliberate practice in any single domain to claim specialist judgment. The agent encodes this directly: it asks generalist-level questions about specialist-touching sections, then defers to the named specialist sibling agent. Pretending to be an expert is flagged as the `Expert Impersonation` anti-pattern.

URL: https://journals.sagepub.com/doi/abs/10.1111/j.1529-1006.2004.00018.x

### Nielsen Norman Group: The Five Whys

Root-cause analysis via repeated "why" questioning, popularized at Toyota and adopted widely in software and design practice. The agent's Evidence-and-Reasoning Check (Protocol 3) and Clarifying-Question Sweep (Protocol 1) apply a softer version of this pattern. They ask *"says who?"* and *"what is the evidence?"* on repeated claims that sound true because they have been said often, not because they have been proven.

URL: https://www.nngroup.com/articles/5-whys/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this agent applies. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../../evidence.md). The companion rule the agent applies alongside YAGNI. Trust classes, the corroboration gate, and the no-evidence label.
- [Agents Index](../README.md). All agents, grouped by role.
- [`project-manager`](./project-manager.md). The coordinator this agent pairs with in planning skill review rounds.
- [`/plan-a-feature`](../../skills/han-planning/plan-a-feature.md) and [`/plan-implementation`](../../skills/han-planning/plan-implementation.md). Skills that always include this agent in their review rounds.
- [`/code-overview`](../../skills/han-coding/code-overview.md). Dispatches this agent (with `information-architect`) to review the drafted overview for readability before the reader sees it.
- [agent-domain-focus.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise domain vocabulary and named anti-patterns even when the domain is "being a generalist."
- [agent-model-selection.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier on a synthesis-heavy inquiry agent.
- [graceful-degradation.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/graceful-degradation.md). Why the agent handles missing git, missing standards documents, and missing ADRs inline rather than failing.
- [multi-agent-economics.md](../../../han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md). Why this agent is a pre-specialist filter, not a specialist replacement.

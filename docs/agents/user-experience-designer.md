# user-experience-designer

Operator documentation for the `user-experience-designer` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/user-experience-designer.md`](../../han.core/agents/user-experience-designer.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md)

## TL;DR

- **What it does.** Audits a feature, screen, or flow for usability problems grounded in established UX principles.
- **When to dispatch it.** A UI surface needs a principled usability review independent of code correctness: before ship, after a recurring usability complaint, or during a structural redesign. Conditionally dispatched by `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, and `/plan-implementation` when the spec or plan touches user-facing flows, UI, interaction, or accessibility.
- **What you get back.** A UX findings report with every finding tied to a specific UI location, a named UX principle, and a user-impact statement.

## Key concepts

- **Named UX and IxD frameworks.** Findings cite Nielsen's 10 heuristics, WCAG 2.2, universal design (Mace 1997), affordance and signifier theory (Norman), Saffer's microinteractions (trigger / rules / feedback / loops and modes), Cooper's goal-directed design, Fitts's Law, Hick's Law, and named dark-pattern categories.
- **Interaction design is in scope.** The agent audits the interactive layer alongside the broader user experience: microinteractions, input modality coverage (pointer, keyboard, touch, voice, conversational/agent), and motion as a functional channel. Not separate disciplines, but folded into the same protocols.
- **Persona spectrum, not a single persona.** Findings consider first-time users, occasional users, habitual experts, and accessibility users. Not "the user."
- **Jobs-to-Be-Done framing.** Every audit is grounded in a concrete user goal before critique begins. If the goal cannot be defensibly stated, the agent flags it as an Open Question rather than inventing a user.
- **Open Questions as first-class output.** Questions the audit could not answer (arrival path, prior knowledge, device context) are listed separately.
- **Does not review content structure.** For documentation, READMEs, API references, and ADR collections, dispatch `information-architect` instead or in parallel.

## Summary

An adversarial UX designer that audits a feature, screen, or flow and writes a findings report. Its default stance is that the current experience is less than optimal. Every finding is backed by evidence and tied to an established UX principle. Questioning is a core behavior. The agent generates and logs the hard questions a senior designer would ask, and it flags any question it cannot answer as an Open Question so the team can resolve it rather than letting the audit rest on an invented user.

## When to use it

**Dispatch when:**

- A new feature, flow, or screen has landed and needs a principled usability pass before ship.
- A recurring usability problem in an existing surface needs a structured audit.
- A PR that meaningfully changes a UI needs a UX second opinion separate from code review.
- The team wants a shared, evidence-grounded baseline before a redesign, specifically to surface Open Questions the team must resolve.

**Do not dispatch for:**

- Pure visual or brand critique. The agent deliberately rejects aesthetic-only findings.
- Bug triage or functional defects. Use `evidence-based-investigator` or `code-review`.
- Architectural review of UI code. Use `architectural-analysis`.
- Writing or iterating design files (wireframes, mocks). The agent does not produce mockups.
- Documentation or content-structure information architecture (READMEs, API docs, plugin docs, ADR repositories). Use `information-architect`. The two agents share vocabulary on hierarchy, wayfinding, and progressive disclosure, but apply it to different artifacts: UX designer to the rendered UI, information architect to text-first content.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:user-experience-designer`. Give it:

1. **A focus area.** File globs, a directory, a route, a component, or a design-artifact reference. The narrower the scope, the sharper the findings.
2. **A brief, if you have one.** Even a one-paragraph description of the user goal, target persona, or entry path dramatically reduces Open Questions.
3. **An output path, optional.** The agent writes the full report to disk and returns only a summary. Default filename is `ux-analysis.md`.

Example prompts that work well:

- *"Audit the checkout flow in `src/routes/checkout/*.tsx`. Users arrive from the cart page on mobile after adding items. Primary goal is paying and getting a receipt. Focus on dark-pattern and accessibility risks."*
- *"Review the empty, loading, and error states for `DashboardList`. First-time users land here right after signup."*
- *"Audit `components/PermissionsDialog.vue` for consent and confirmshaming risks. This is shown once on first use and never again."*

Thin prompts (*"review the UI"*) still work but produce more Open Questions and looser findings.

## What you get back

- A summary in the tool-call response: a 1–3 sentence posture, a severity count table (Blocks task / Degrades task / Friction / Polish), an Open Questions count, and the path to the full report.
- A full report on disk with: scope, user context, question log (Answered / Assumed / Open), assumptions, open questions, numbered findings tied to principles and locations, and a UX Improvement Summary that sequences shipping vs. improving.

Every finding is traceable to a UX principle, a UI location, and a question in the log. If something is not traceable, the agent is instructed to drop it.

## How to get the most out of it

- **Provide a user goal.** The single biggest lever. A jobs-to-be-done statement (*"When I {situation}, I want to {motivation}, so I can {outcome}"*) collapses whole classes of Open Questions.
- **Name the persona spectrum.** Tell the agent which permanent, temporary, and situational constraints matter for this audit (for example, *"users are on Android in transit, often one-handed"*). This focuses the accessibility and universal-design protocols.
- **Say what ships when.** If a deadline is looming, ask the agent to sequence findings into *"must-fix-now"* vs. *"track-and-improve."* It already does this, but a reminder sharpens the judgment.
- **Treat Open Questions as work.** They are not rhetorical. Each one is something the team must answer (in brief, in analytics, in user research, or in a product decision) to fully trust the severity of the findings that depend on it.
- **Re-run after changes.** The agent is cheap to re-dispatch once a brief or fix has landed. Open Questions from the first pass become Answered in the second.
- **Pair with a reviewer agent.** The agent generates findings. It does not evaluate its own output. If you want adversarial validation of the UX report, follow it with `adversarial-validator` or a fresh agent pass. See [multi-agent-economics.md](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md) for why self-evaluation is a bad default.

## Cost and latency

The agent runs on `opus`. A single audit is slower and more expensive than a typical lookup agent, which is intentional. The task is multi-dimensional synthesis and judgment. Avoid dispatching it in parallel for the same surface or in tight loops over every file in a codebase. Scope tightly and it pays off.

## Sources

The agent's protocols and vocabulary are grounded in published frameworks. Each source below is cited because the agent draws specific, named artifacts from it.

### Nielsen Norman Group: 10 Usability Heuristics for User Interface Design

Jakob Nielsen's 10 heuristics (originally 1994, refined 2024) are the industry-standard rules of thumb for interaction design. The agent walks all 10 as a protocol and uses their names as the citable principle on findings (*"visibility of system status," "recognition rather than recall," "error prevention"*). They are broad enough to cover most interactive software and specific enough to anchor every finding to a known heuristic.

URL: https://www.nngroup.com/articles/ten-usability-heuristics/

### RL Mace Universal Design Institute: Seven Principles of Universal Design (1997)

Ronald Mace and colleagues at NC State defined universal design as usability for the broadest possible human range without adaptation. The agent uses the seven principles as its second protocol and leans on them when critiquing degraded-accessibility paths, inflexible interaction, or physical-effort assumptions. The framework predates most digital-specific guidance and keeps the agent focused on humans rather than interfaces in isolation.

URL: https://www.udinstitute.org/principles

### W3C: Web Content Accessibility Guidelines 2.2 (WCAG 2.2)

WCAG 2.2 is the current W3C accessibility standard, organized around Perceivable, Operable, Understandable, Robust (POUR). The agent cites specific success criteria on findings (contrast (1.4.3), target size (2.5.8), focus order (2.4.3), error identification (3.3.1)) so remediation is testable rather than subjective. POUR also provides the scaffolding the agent uses when automated tooling (axe, Lighthouse, pa11y) is unavailable.

URL: https://www.w3.org/TR/WCAG22/

### Don Norman: Affordances and Signifiers

Don Norman's distinction between affordances (action possibilities) and signifiers (perceptible cues that announce those actions) explains why digital interfaces are harder to make usable than physical tools. The agent uses this framework in its affordance audit and relies on it to push back on "flat" designs that strip signifiers for aesthetic reasons. The `Skeuomorphism Nostalgia` anti-pattern in the agent is directly derived from Norman's work and prevents arguing for physical-imitation ornament without affordance analysis.

URLs: https://ixdf.org/literature/topics/affordances and https://ixdf.org/literature/topics/signifiers

### Dan Saffer: Microinteractions

Dan Saffer's *Microinteractions* defines the unit of interaction design as a single contained moment (a toggle, a save, a react, an undo) and decomposes it into four parts: trigger, rules, feedback, and loops/modes. The agent uses this framework inside its affordance protocol so that every meaningful interaction in the focus area can be audited for whether each of the four parts is present and discoverable. The `Microinteraction Silence` anti-pattern is derived directly from this framework and catches actions that mutate state without perceptible feedback.

URL: https://www.oreilly.com/library/view/microinteractions/9781449342821/

### Alan Cooper: Goal-Directed Design

Alan Cooper's *About Face* established goal-directed design: the practice of grounding interaction decisions in a user's end goal rather than feature lists or technical capabilities. The agent uses Cooper's framing to keep the Critical Inquiry protocol focused on goals and to reject findings that critique a feature without naming the goal it serves. This complements Jobs-to-Be-Done by adding a posture toward designing the interaction backward from the goal, not forward from available controls.

URL: https://www.cooper.com/about-face/

### Fitts's Law (via Nielsen Norman Group)

Paul Fitts's 1954 study established that target-acquisition time scales with distance and inversely with target size. The agent uses Fitts's law to evaluate hit-target sizing, destructive-vs-primary action placement, and pointer travel. This also underpins the WCAG 2.2 target-size minimum the agent enforces.

URL: https://www.nngroup.com/articles/fitts-law/

### Hick's Law (via Dovetail)

The Hick–Hyman law states that decision time grows logarithmically with the number of choices. The agent uses it to detect choice overload in menus, multi-action layouts, and modal *"what next?"* dialogs, and pairs it with progressive disclosure as a remediation pattern. This turns "cognitive load" into an evidence-based finding rather than a vague complaint.

URL: https://dovetail.com/ux/hicks-law/

### Microsoft Inclusive Design Toolkit: Persona Spectrum

Microsoft's toolkit reframes disability as a mismatch between a person and their environment and maps abilities across permanent, temporary, and situational constraints. The agent requires every audit to enumerate the persona spectrum it is scoping to (one-handed, low-bandwidth, second-language reading, assistive-tech use, cognitive fatigue) and flags `Persona of One` as an explicit anti-pattern when findings collapse the spectrum into a single ideal user.

URL: https://inclusive.microsoft.design/tools-and-activities/InclusiveActivityCards.pdf

### Harry Brignull: Dark Patterns (Deceptive Design)

UX designer Harry Brignull coined "dark patterns" in 2010 to describe design choices that steer users against their own interests. A 2022 European Commission report found 97% of popular EU-facing sites used at least one. The agent scans consent, subscription, cancellation, delete, and permission flows for named classes (confirmshaming, roach motel, sneak into basket, misdirection, forced continuity, trick questions, privacy zuckering, nagging), and the `Dark Pattern Blindness` anti-pattern forces this scan even on flows that look successful by conversion metrics.

URL: https://en.wikipedia.org/wiki/Dark_pattern

### Clayton Christensen: Jobs to Be Done (via Nielsen Norman Group)

The Jobs-to-Be-Done framework frames research around the progress a user is trying to make, not demographic personas. The agent uses the JTBD statement format in its Critical Inquiry protocol to force a concrete user goal before critique begins, which blocks the `Invented User` anti-pattern and complements the persona spectrum.

URL: https://www.nngroup.com/articles/personas-jobs-be-done/

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Agents Index](./README.md). All agents, grouped by role.
- [`information-architect`](./information-architect.md). Sibling agent for documentation / content-structure IA. Dispatch in parallel when a surface blends an interactive UI with a content-heavy docs surface.
- [agent-domain-focus.md](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise domain vocabulary and named anti-patterns.
- [agent-model-selection.md](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
- [graceful-degradation.md](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/graceful-degradation.md). Why the agent handles missing git and missing accessibility tooling inline.
- [multi-agent-economics.md](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md). Why a separate reviewer pass is recommended rather than asking this agent to evaluate its own output.

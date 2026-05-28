# information-architect

Operator documentation for the `information-architect` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`plugin/agents/information-architect.md`](../../plugin/agents/information-architect.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md)

## TL;DR

- **What it does.** Audits a documentation set for findability, orientation, and comprehension problems.
- **When to dispatch it.** A README, plugin docs tree, API reference, or ADR collection needs a principled structural audit before or during a rewrite.
- **What you get back.** An IA findings report with numbered findings tied to IA principles and named reader audiences, plus structural recommendations sequenced ship-now vs. track-and-improve.

## Key concepts

- **Nine-protocol audit.** Critical inquiry, content inventory, audience-task mapping, topic typing (DITA), hierarchy and progressive disclosure, labeling and navigation, every-page-is-page-one check, Carroll minimalism, recency and cross-reference integrity.
- **Named IA frameworks.** Findings cite Rosenfeld/Morville's four systems, Dan Brown's 8 Principles, LATCH, EPPO, DITA topic types, Hackos audience-task mapping, or information scent. Never *"this is confusing."*
- **Reader Impact through a named audience.** Every finding is tied to a specific audience (first-time learner, returning expert, contributor, debugger) and a concrete task (JTBD).
- **Open Questions as first-class output.** If the audit cannot defensibly name a reader or task, it flags the question rather than inventing a plausible audience.
- **Structural recommendations, not rewritten prose.** The agent proposes splits, merges, labels, and hierarchy changes. It does not rewrite the documentation itself.

## Summary

An adversarial information architect that audits a documentation set (a README, a plugin docs tree, an API reference, an ADR repository, a tutorial series) and writes a findings report focused on findability, orientation, and comprehension. Its default stance is that the current structure is harder to navigate and harder to understand than it needs to be. Every finding is tied to an established IA principle and a named reader audience with a concrete task. Questioning is a core behavior. The agent generates and logs the hard questions a senior information architect would ask, and it flags any question it cannot answer as an Open Question so the team can resolve it rather than letting the audit rest on an invented reader.

## When to use it

**Dispatch when:**

- A README, plugin docs tree, or documentation set feels long, unfocused, or hard to enter and needs a principled structural audit.
- Reader feedback, support tickets, or repeated questions suggest the docs exist but are not being found, understood, or followed.
- A new feature lands and its documentation is being reorganized. The agent can audit the target structure before the rewrite commits.
- A documentation set has grown organically over a long period and the team wants an evidence-based baseline before consolidating, splitting, or retiring pages.
- Multiple audiences (first-time users, experts, contributors, debuggers) are all reading the same pages and the structure appears to serve none of them well.

**Do not dispatch for:**

- Live user-interface review (rendered screens, form flows, mobile UIs). Use `user-experience-designer`.
- Documentation content-preservation audits after a rewrite or migration. Use `content-auditor`.
- Spec-vs-implementation gap analysis (checking whether code matches a PRD). Use `gap-analyzer`.
- Prose rewriting or copy-editing. The agent proposes structural changes and target shapes. It does not rewrite the content.
- Technical correctness auditing of documentation. The agent is not a code reviewer or fact-checker.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han:information-architect`. Give it:

1. **A focus area.** A docs directory, a README, a specific plugin's docs tree, an ADR folder, an API-reference root, or a specific set of text files. The narrower the scope, the sharper the findings.
2. **A brief, if you have one.** Even a short paragraph naming the target audience, the top reader tasks, and the primary arrival path dramatically reduces Open Questions.
3. **An output path, optional.** The agent writes the full report to disk and returns only a summary. Default filename is `ia-analysis.md`.

Example prompts that work well:

- *"Audit the docs in `plugins/han/docs/` and the plugin README. Primary audience is a solo engineer who is new to the plugin and arrives from the marketplace listing. Focus on orientation and progressive disclosure."*
- *"Review `docs/features/` for consistency. Audiences: feature authors writing new specs, implementers reading an existing spec, and a project manager looking up decisions. Tell us where topic types are mixed."*
- *"Audit `README.md` at the repo root for a first-time reader landing from a GitHub search. Are the first 100 lines the right first 100 lines?"*

Thin prompts (*"review the docs"*) still work but produce more Open Questions and looser findings.

## What you get back

- A summary in the tool-call response: a 1–3 sentence posture, a severity count table (Blocks comprehension / Degrades comprehension / Friction / Polish), an Open Questions count, and the path to the full report.
- A full report on disk with: scope, reader context, content inventory summary, question log (Answered / Assumed / Open), assumptions, open questions, numbered findings tied to IA principles and locations, and an IA Improvement Summary that sequences shipping vs. improving.

Every finding is traceable to an IA principle, a documentation location, and a question in the log. If something is not traceable, the agent is instructed to drop it.

## How to get the most out of it

- **Name the audience.** The single biggest lever. *"Solo product engineer, first contact with the plugin, arriving from a marketplace listing"* collapses whole classes of Open Questions. If there are multiple audiences, say so. The agent will map tasks per audience.
- **Name the top tasks.** JTBD statements (*"when I install the plugin, I want to run my first skill, so I can decide whether to keep it"*) focus the audit on the paths readers take.
- **Name the arrival paths.** GitHub search, a link in a Slack post, a code comment, a marketplace listing, the README on Anthropic's site. Each frames a different first impression.
- **Say what ships when.** If a reorganization is scheduled, ask the agent to sequence findings into *"must-fix-now"* vs. *"track-and-improve."* It already does this, but a reminder sharpens the judgment.
- **Treat Open Questions as work.** They are not rhetorical. Each one is something the team must answer (in analytics, in support-ticket review, in a product decision, or in user research) to fully trust the severity of the findings that depend on it.
- **Re-run after structural changes.** The agent is cheap to re-dispatch once a reorganization has landed. Open Questions from the first pass become Answered in the second, and regressions surface quickly.
- **Pair with a reviewer agent.** The agent generates findings. It does not evaluate its own output. If you want adversarial validation of the IA report, follow it with `adversarial-validator` or a fresh agent pass. See [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md) for why self-evaluation is a bad default.

## Boundary with user-experience-designer

The two agents own different artifacts:

- `user-experience-designer` audits live interactive surfaces (screens, form flows, component libraries, rendered UIs) against Nielsen heuristics, WCAG, universal design, affordance/signifier frameworks, Fitts and Hick, and dark-pattern detection. Its Protocol 6 covers on-screen hierarchy and wayfinding *within a UI*.
- `information-architect` audits text-first content structure (documentation, READMEs, API references, ADRs) against Rosenfeld/Morville, Dan Brown, LATCH, EPPO, DITA, minimalism, and audience/task mapping.

Where a surface blends both (a docs site with navigation UI, a rendered marketplace page with content), dispatch both in parallel and let each own its scope. Progressive disclosure appears in both, but in each it maps to a different remediation: UX remediates the interactive disclosure (details elements, modals, accordions); IA remediates the content disclosure (what belongs on the landing page vs. a deep page).

## Cost and latency

The agent runs on `opus`. A single audit is slower and more expensive than a typical lookup agent, which is intentional. The task is multi-dimensional synthesis and judgment across content inventory, audience mapping, topic typing, and structural critique. Avoid dispatching it in parallel for the same documentation set or in tight loops over every doc in a repo. Scope tightly and it pays off.

## Sources

The agent's protocols and vocabulary are grounded in published IA and technical-communication frameworks. Each source below is cited because the agent draws specific, named artifacts from it.

### Rosenfeld & Morville: Information Architecture for the Web and Beyond (4th edition, 2015)

The "polar bear book" defines IA as the design of four systems: organization, labeling, navigation, and search. The agent treats these four as a set in Protocol 6 and requires every labeling/navigation finding to locate itself within one of them. This is the canonical reference for IA as a discipline distinct from UXD.

URL: https://www.oreilly.com/library/view/information-architecture-4th/9781491913529/

### Dan Brown: 8 Principles of Information Architecture (2010, Bulletin of ASIS&T)

Dan Brown's eight principles (Objects, Choices, Disclosure, Exemplars, Front Doors, Multiple Classification, Focused Navigation, Growth) are the agent's primary vocabulary for naming what went wrong in a structural audit. The `Front-Door Absence` and `Progressive-Disclosure Failure` anti-patterns are drawn from this framework. `Category Fiction` is a failure of the Objects and Choices principles.

URL: https://asistdl.onlinelibrary.wiley.com/doi/full/10.1002/bult.2010.1720360609

### Richard Saul Wurman: LATCH (1989, Information Anxiety)

LATCH (Location, Alphabet, Time, Category, Hierarchy) is the canonical set of organizing schemes. The agent uses LATCH to critique grouping decisions: when a documentation set is grouped "by category" but the category itself is not how readers look for the content, that is a LATCH misfit. Also grounds the `Category Fiction` anti-pattern.

URL: https://en.wikipedia.org/wiki/Richard_Saul_Wurman

### Mark Baker: Every Page is Page One (XML Press, 2013)

Mark Baker's EPPO framework reframes technical documentation around the reality that readers rarely arrive via a linear table of contents. They arrive via search, and every page must stand alone. The agent runs an explicit EPPO check in Protocol 7 and uses EPPO violations to ground the `Context Collapse`, `Orphan Topic`, and `TOC-As-Architecture` anti-patterns.

URL: http://everypageispageone.com/the-book/

### John Carroll: Minimalism (The Nurnberg Funnel, 1990; Minimalism Beyond the Nurnberg Funnel, 1998)

John Carroll's minimalism is the foundational technical-writing research for task-oriented, reader-in-action documentation. The agent's Protocol 8 walks Carroll's four principles (task-orientation, exploration support, error recovery, cutting meta-content) and uses them to push back on prose-heavy, narrative-first docs that slow task completion.

URL: https://en.wikipedia.org/wiki/Minimalism_(technical_communication)

### JoAnn Hackos: Topic-Based Authoring and DITA (Introduction to DITA, 2011; Information Development, 2007)

JoAnn Hackos's work on topic-based authoring and DITA established the concept/task/reference topic-type split the agent uses as its information model in Protocol 4. Hackos also grounds the agent's audience-and-task mapping approach in Protocol 3. Tying content to named reader jobs rather than author narrative structure.

URL: https://en.wikipedia.org/wiki/Darwin_Information_Typing_Architecture

### Peter Pirolli & Stuart Card: Information Foraging and Information Scent

Pirolli and Card's information-foraging theory explains how readers follow "scent" from one piece of content to the next, and the agent uses information scent as its lens in Protocol 6 (labeling) and its anti-pattern `Ghost Navigation`. Nielsen Norman Group has popularized the scent vocabulary for interface design. The agent applies it to content structure.

URL: https://www.nngroup.com/articles/information-scent/

### Abby Covert: How to Make Sense of Any Mess (2014)

Abby Covert reframes IA as sense-making across any medium, not just the web, and emphasizes that IA is the shared understanding of intent, nouns, and relationships before any navigation is drawn. The agent uses Covert's framing to resist treating the table of contents as the architecture. The `TOC-As-Architecture` anti-pattern is directly derived from this.

URL: https://abbycovert.com/make-sense/

### Stewart Brand / Peter Morville: Pace Layering (Ambient Findability, 2005)

Stewart Brand's pace-layering concept, adapted by Peter Morville to IA in *Ambient Findability*, models different layers of a content system as changing at different rates: tags and labels evolve fast, taxonomies slower, ontologies slowest. The agent uses pace layering to distinguish surface-level rename remediations from deeper structural ones, and to prioritize which layers a team should stabilize before iterating on the fast ones.

URL: https://jarango.com/2021/01/14/the-culture-layer/

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Agents Index](./README.md). All 23 agents, grouped by role.
- [`/plan-a-phased-build`](../skills/plan-a-phased-build.md). Dispatches the agent at runtime against every rendered build-phase outline to verify findability, EPPO standalone-ness of phase entries, and progressive comprehension before presenting the document to you.
- [`user-experience-designer`](./user-experience-designer.md). The sibling agent for live UI surfaces. Dispatch both in parallel when a docs site blends content and interactive navigation.
- [agent-domain-focus.md](../guidance/agent-building-guidelines/agent-domain-focus.md). Why this agent uses precise IA vocabulary and named anti-patterns instead of sharing the user-experience-designer's UI vocabulary.
- [agent-model-selection.md](../guidance/agent-building-guidelines/agent-model-selection.md). Rationale for the `opus` model tier.
- [graceful-degradation.md](../guidance/agent-building-guidelines/graceful-degradation.md). Why the agent handles missing git and large-set sampling inline.
- [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md). Why a separate reviewer pass is recommended rather than asking this agent to evaluate its own output.

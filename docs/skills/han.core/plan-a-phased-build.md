# /plan-a-phased-build

Operator documentation for the `/plan-a-phased-build` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/plan-a-phased-build/SKILL.md`](../../../han.core/skills/plan-a-phased-build/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Splits a body of context (gap analysis, PRD, design doc, feature spec, ADR, requirements list, or inline description) into a numbered sequence of vertical-slice build phases. Each phase a thin end-to-end deliverable demonstrable to a real person, each one building on the prior.
- **When to use it.** You have an artifact that describes everything that needs to be built and you need to decide *what to build first, second, third*. And you want a stakeholder-readable plan, not raw analyst output.
- **What you get back.** `build-phase-outline.md`. A plain-language document indexed by stable `Phase N` IDs, with an executive summary, a scan-view phase index, optional "departures from source" section, per-phase entries (kind, builds-on, what we build, why this phase, demo script, source citations, connects-to, preconditions), and stable `OQ-N` open questions.

## Key concepts

- **Vertical slices, not horizontal layers.** A phase delivers a thin end-to-end strip of behavior. Every layer of the system involved for one narrow scenario. A phase does not deliver "all the database work" or "all the API surface." If a phase is not demoable to a real person, it is either too small (merge it forward) or too horizontal (re-think it as a thinner end-to-end strip).
- **Plain language by default.** The outline never names file paths, function or class names, library mechanics, language primitives, or internal flag names. Brand names generalize one level up: *"PostgreSQL"* → *"the database"*, *"NATS"* → *"the events processing system."* A non-technical stakeholder must be able to read the document end-to-end. The only exception is the per-phase "Source citations" line, which may name source-artifact section headings by their actual heading text.
- **Each phase builds on the prior.** As phases ship, the system becomes progressively more capable. Earlier phases stay valid. Later phases enrich what earlier ones delivered. No phase ever invalidates an earlier deliverable.
- **Foundational phases first, only when truly required.** If the demoable feature literally cannot run until a setting, permission model, schema, or configuration foundation exists, the foundation comes first. And even then it must be demoable on its own. *"An admin can edit the new setting and see it persist"* qualifies as a foundation phase. *"We added a database table"* does not. Fold it forward into the first feature slice that uses it.
- **Stable `Phase N` and `OQ-N` IDs.** Phase numbers and open-question IDs are stable for the life of the document. Tickets, threads, and Slack messages cite `Phase 5` or `OQ-3`. The template uses explicit `{#phase-N}` and `{#oq-N}` heading anchors so deep links survive phase renames.
- **IA-reviewed template.** The output template was reviewed by `information-architect` against Rosenfeld & Morville's four IA systems, Mark Baker's "Every Page is Page One," Dan Brown's 8 Principles of IA, LATCH, and Carroll's minimalism. The skill dispatches the same agent at runtime to review each rendered outline before presenting it to you.

## When to use it

**Invoke when:**

- You have a body of context (a gap analysis, PRD, feature spec, design doc, ADR, requirements list, or even conversation notes) and you need to decide what to build first, second, third. The user phrasing usually starts with *"split this into phases," "what should we build first," "phase this work," "turn this into vertical slices," "outline the order of delivery,"* or *"what's our roadmap."*
- The output is going to a mixed audience (engineering, product, leadership) and the deliverable needs to be stakeholder-readable, not raw analyst output with file paths and code identifiers.
- You want a stable, citable index of phases. Each phase gets a `Phase N` you can reference in tickets, threads, and follow-up work. The IDs are stable for the life of the document.
- A previous skill (typically `/gap-analysis`) produced a list of what's missing, and you need the order in which to close those gaps in vertical slices the team can demo.
- You are about to commit to a multi-week or multi-month build and want to confirm phase 1 is the right thing to greenlight before launching the team.
- You have foundational work that must come first (a settings page, a permissions model, a config foundation) and you need a plan that sequences foundation → first feature slice → polish without losing track of what is demoable when.

**Do not invoke for:**

- **Specifying what a feature does.** Use [`/plan-a-feature`](./plan-a-feature.md) when you need to decide *what* the feature should do, what flows it has, what edge cases it handles. This skill orders the build of work that has already been described. It does not specify behavior that has not yet been decided.
- **Implementation detail for a single phase.** Use [`/plan-implementation`](./plan-implementation.md) once a phase has been greenlit and you need to decide *how* to build it: module boundaries, integration patterns, rollout strategy, test strategy. This skill stops at *"what each phase delivers"* and *"why it lands in that order."*
- **Comparing two artifacts.** Use [`/gap-analysis`](./gap-analysis.md) when the question is *"what's missing from X compared to Y."* This skill assumes the gap is already identified (or otherwise described) and orders the build to close it.
- **Refining or stress-testing an existing plan.** Use [`/iterative-plan-review`](./iterative-plan-review.md) for multi-pass review of a plan you have already drafted. This skill produces a new outline. It does not iterate on one in place.
- **Recording an architectural decision.** Use [`/architectural-decision-record`](./architectural-decision-record.md) for ADRs. This skill produces a build sequence, not a record of a single decision and its alternatives.
- **Investigating runtime bugs or failures.** Use [`/investigate`](./investigate.md) for evidence-based root-cause work on a defect.
- **Documenting an already-built feature.** Use [`/project-documentation`](./project-documentation.md) for descriptive docs of features, systems, and components that exist. This skill plans work yet to be built.

## How to invoke it

Run `/plan-a-phased-build` in Claude Code. Point it at the source context (a file path, a folder path, or inline description) in the same message.

Give it:

1. **The source context.** What gets phased. May be:
   - A single file path. Typically a gap analysis, PRD, design doc, feature spec, or requirements list. Examples: `docs/features/share/v1-gap-analysis.md`, `docs/prd-billing-rebuild.md`.
   - A folder path. When multiple related documents need to be considered together. Example: `docs/features/share/`.
   - Inline conversation context. When the work is described in the prompt rather than pointing to a file.
   - A combination. A file plus shaping context in the prompt.
2. **Shaping context, optional but usually load-bearing.** Anything you say about *how* to phase the work that is not in the source. Typical examples:
   - **New behaviors that diverge from the source.** *"We need to add role-based authorization that v1 didn't have." "The new billing engine should support multi-currency, which the Stripe integration didn't."*
   - **Explicit deferrals.** *"Don't include URL shortening yet." "Email delivery is out of scope for this build."*
   - **Sequencing constraints.** *"We can't ship anything that touches auth before Q3." "Mobile team is cutting a release branch on the 5th. Keep merges before then trivial."*
   - **Audience.** *"This is going to the steering committee. Keep it leadership-readable."*
3. **Output location, optional.** A folder path. Defaults to writing the outline next to the source file (when there is one) or under `docs/plans/` / `docs/roadmap/` (when there isn't).

Example prompts that work well:

- `/plan-a-phased-build docs/features/share/v1-gap-analysis.md`. *"Use this gap analysis as the source. We're rebuilding the share feature in v2 and need to add role-based authorization for share visitors that v1 didn't have. Defer URL shortening."*
- `/plan-a-phased-build docs/prd-billing-rebuild.md docs/plans/billing-build/`. *"Split the billing rebuild PRD into phases. The first phase needs to be demoable to leadership in two weeks."*
- `/plan-a-phased-build`. *"Phase the work needed to migrate from our current notification service to the new one. The migration plan is at `docs/migrations/notifications/`. We can't introduce any user-visible behavior change until phase 4. Earlier phases must be backend-only but still independently demoable to engineering."*
- `/plan-a-phased-build docs/features/checkout/feature-specification.md`. *"Turn this feature spec into a phased build. Audience is mixed engineering and product."*

The skill states the resolved source, the chosen output folder, and the shaping context it captured in a short message before starting the interview. It surfaces questions one at a time as the design tree unfolds, with a recommended answer for each. Once the candidate phases are sequenced, it states the proposed order in one short message and asks for any reordering before writing the file.

## What you get back

One file on disk plus an in-channel summary:

- The **`build-phase-outline.md`**. The stakeholder-readable artifact. Sections, in order:
  - **Front matter** (YAML). Title, source-artifact relative path, audience, generated date, generated-by skill name.
  - **H1 + intro paragraphs.** Names what the initiative is and what kind of document this is. Defines "phase" in plain language on the first sentence so a reader unfamiliar with the term is not lost.
  - **Table of Contents.** Every section, plus per-phase deep links.
  - **Executive Summary.** `goal` → `shape of the build` (3-5 plain-language bullets) → `sequencing rationale` → `departures from the source artifact` (only if any) → `phases deliberately deferred` (only if any) → `where to look next`. A leadership reader who reads only this section walks away with the shape of the build, the order, the departures, and what was deferred.
  - **Build Phase Index.** A scan-view table: `# | Phase | Kind | Outcome (one short sentence)`. Cited heavily in tickets and Slack threads. Uses the stable `#phase-N` anchors so deep links survive phase renames.
  - **How {{this build}} Differs from {{the source}}** *(included only when departures were captured).* The new behaviors that shape the rest of the plan, named once and referenced by name from the per-phase entries. Heading is parameterized with concrete nouns (for example, *"How V2's Share Differs from V1"*) so the section carries information scent for leadership scanners.
  - **Phase Kinds.** A four-line glossary defining `Foundation`, `Feature slice`, `Polish`, `Deferred`. The taxonomy is used in the Build Phase Index and on each phase entry's `Kind.` line.
  - **Build Phases.** One entry per phase. Each entry contains, in order: `Kind`, `Builds on` (single short line so a cold-arriving reader sees the dependency at a glance), `What we build`, `Why this is Phase N`, `Outcome to demonstrate` (numbered demo script), `Source citations` (links to source-artifact sections this phase covers), `Connects to` (links to other phases this one builds on or feeds into), `Preconditions to verify before starting`. Every phase heading carries an explicit `{#phase-N}` anchor so renames don't break inbound deep links.
  - **Open Questions.** `OQ-N` entries with options and a recommended answer. Ordered by the lowest-numbered phase each question blocks, ascending. Carry-over questions that don't block any specific phase live at the bottom under a `### Carry-over notes` sub-heading. Each entry carries a `Blocks phase(s).` line so a stakeholder scanning the section can see at a glance which decisions block their next greenlight.
- An **in-channel summary** with the file path, a count of phases by kind (foundational / feature slice / polish / deferred), the open-question count and whether any block phase 1 from starting, the `information-architect`'s overall verdict, and the next concrete action. Typically *"review the executive summary and the phase 1 entry, then either greenlight phase 1 or reorder."*

The default output is the smallest viable artifact. Optional sections (*"How {{this build}} Differs from {{the source}}"*, deferred phase entries, and the *"Phases deliberately deferred"* paragraph in the executive summary) are physically omitted when not needed, not collapsed.

## How to get the most out of it

- **Bring shaping context, not just a source artifact.** The source artifact tells the skill what *was*. The shaping context tells it what should *change* and what should be *deferred*. The skill produces sharper, more decision-ready phase ordering when both are provided. A gap analysis alone produces phases that close every gap in source order. A gap analysis plus *"we need to add role-based authorization that v1 didn't have, and we're deferring URL shortening"* produces phases sequenced for the new product reality.
- **Name divergences from the source up front.** Departures are surfaced once in the executive summary and referenced by name from individual phase entries. If you don't name the divergences, the skill produces an outline that mirrors the source, which is rarely what you want when the source is a *prior* state and the build is a *new* one.
- **Answer the interview questions with the recommendation in front of you.** The skill surfaces each question with a recommended answer grounded in evidence. If the recommendation is right, accept it. That is the cheapest path through the interview. If it's wrong, redirect with the specific reason. The skill folds the reason into the per-phase rationale so future readers see why the build sequenced the way it did.
- **Treat phase 1 as a sanity check.** The first phase is the hardest to get right. If phase 1 is not demoable on its own, the rest of the outline is suspect. The skill probably let a horizontal layer sneak in. Read the phase 1 entry first. If you can't put it in front of a real person and watch something happen, push back and ask the skill to merge it forward into the next demoable slice.
- **Read the executive summary even if you wrote it.** The IA-reviewed template is structured so a stakeholder reading only the executive summary walks away with the shape of the build. Use it as a sanity check on your own framing. If the summary doesn't read well to a non-technical audience, the plain-language-translation step needs adjusting and you should re-run with a sharper audience cue.
- **Pair with `/gap-analysis` upstream.** When the source is a comparison between current and desired state, run `/gap-analysis` first to produce the gap report, then point this skill at the report. The pairing is natural: `G-NNN` gap IDs in the report become source citations on the phase entries that close those gaps, so the team can always answer *"where did this phase come from."*
- **Pair with `/plan-implementation` downstream.** Once a phase is greenlit, `/plan-implementation` produces a committable implementation plan for that phase alone. The pairing is natural: the phase entry's *"What we build"* and *"Outcome to demonstrate"* become the implementation plan's behavioral spec; *"Preconditions to verify"* become Open Items in the implementation plan.
- **Re-run after the source changes.** A build-phase outline is a point-in-time artifact. It does not auto-refresh. After the source artifact changes (the spec gained sections; the gap analysis ran again with new gaps), re-run the skill. The new outline's `Phase N` IDs are independent of the prior run's. The prior outline stays valid as a snapshot.
- **Use deferrals deliberately.** Anything you defer lands at the bottom of the index with a clear *"(deferred)"* marker and a `Why this is deferred` paragraph. Deferrals are first-class output. They signal *"we considered this and chose not to build it now,"* which is a decision worth recording. Don't list everything that wasn't built. List only what the team explicitly considered and chose to slot for later.

## Cost and latency

The skill is structured for one decision-point planning run, not for tight-loop iteration on the same source. Most of the cost lives in the user interview and the IA review of the rendered outline.

- **The interview.** The skill walks the design tree decision-by-decision, surfacing only the questions that genuinely require your judgment. Most renderings produce three to seven user-facing questions. Each question is presented with a recommendation, so accepting most of them runs cheaply. Redirecting any of them adds one more interview turn. There are no sub-agent dispatches during the interview. It is the skill and you.
- **The IA review.** A single dispatch of the `information-architect` agent (sonnet) against the rendered outline. The agent reads the outline once, runs its protocols, and returns findings. Cost is proportional to the outline length. A five-phase outline is cheap; a fifteen-phase outline costs more by token count, not by dispatch count.
- **Apply-findings pass.** The skill applies IA findings in-process. No additional sub-agent dispatch. Plain-language leak findings are required edits. Structural findings are evaluated and applied if they preserve the document's contract.

For a typical mid-size build (six to ten phases, two to four open questions, a handful of named departures), expect: a few minutes of interview-driven question-and-answer with you; a single IA-agent dispatch; and a final summary. The skill is built for periodic, decision-point planning runs (before greenlighting a multi-week build, before a steering-committee briefing, after a gap analysis surfaces a new picture), not for tight-loop iteration on the same source within a single session. Re-running the skill is appropriate after the source artifact has materially changed. Running it repeatedly against the same inputs in the same session does not produce new insight.

## In more detail

The skill's input is a body of context plus your shaping intent. Its output is a stakeholder-readable build-phase outline. The judgment-heavy work happens in three places: the source-and-context discovery (Step 2), the user interview that walks the design tree (Step 3), and the candidate-phase enumeration and sequencing (Steps 4 and 5). Everything after that is rendering and review.

**Discovery before interviewing.** The skill reads the source artifact end-to-end before asking you any shaping questions. It also reads any project context (CLAUDE.md, `project-discovery.md`, existing planning docs in the chosen output folder) so the rendered outline matches the team's tone and format precedent. Any decision the source already settles is taken from the source rather than re-asked.

**Interview discipline.** The skill does not batch every question up front. It walks the design tree decision-by-decision, surfacing one or a small batch of questions, capturing the answer, descending into dependent decisions that the answer enables, and only surfacing the next question when its parent is settled. Every question carries a recommended answer grounded in evidence (source artifact, project context, stated goals) plus one or two alternatives. Accepting the recommendation is the cheapest path; redirecting works fine when needed.

**Candidate-phase enumeration.** A candidate phase is a thin end-to-end slice of the system that produces a demoable outcome. The skill walks the source section by section and asks, for each cluster of capability: could this be demoed on its own? what does it depend on? is it a foundation that nothing depends on yet, but later phases will? is it a deferral you named? Output of this step is an in-memory list: phase candidates with `kind`, `demonstrability`, and `depends-on` tags. The list is kept in conversation memory, not yet written to file.

**Sequencing rules.** Candidates are ordered by these rules in priority:

1. Dependencies are honored. A phase never appears before any phase it depends on.
2. Earliest demoable feature value is preferred. Among candidates whose dependencies are satisfied, pick the one that delivers the most user-recognizable value first. Foundations come first only when their absence blocks every demoable feature.
3. Foundational phases must themselves be demoable. Re-check each foundation: if the demonstrability statement is *"we added a thing the system uses internally,"* merge it forward into the first feature slice that uses it.
4. Polish-tier work lands later. Branding, expiration controls, audit/log views, view counts, accessibility refinements, internationalization. These enrich a working core rather than make it work, so they sequence after the substantive phases.
5. Deferrals always land at the end of the index with a clear *"(deferred)"* marker.

The proposed sequence is surfaced to you in one short message (phase number, name, demoable outcome) for confirmation or reordering before any file content is written.

**Incremental writing.** The skill writes the outline file as soon as the executive summary and phase index are drafted, then updates the file every time a phase is fleshed out. Buffering the entire document in conversation memory and writing at the end is explicitly disallowed. If something interrupts the run, the work-in-progress is preserved on disk.

**IA review at runtime.** After the outline is fully drafted, the skill dispatches `information-architect` to review the rendered document. The agent applies its full protocol set (Rosenfeld/Morville, EPPO, LATCH, Carroll, Brown) against the rendering. The skill then applies findings: plain-language leak findings are required edits (technical detail that snuck into the body gets rewritten behaviorally); structural findings are evaluated and applied if they preserve the document's contract; polish findings are applied if they tighten the document. Findings you must judge (for example, *"the audience seems mixed; should this be split into two documents?"*) are escalated with a recommendation before finalizing.

**Anchor stability is part of the contract.** Every phase heading carries an explicit `{#phase-N}` anchor. Every open-question heading carries an explicit `{#oq-N}` anchor. Renaming a phase or question never breaks inbound deep links from tickets, Slack threads, or other documents. If the project's markdown renderer does not support `{#anchor}` heading attributes, the skill falls back to an `<a id="phase-N"></a>` line immediately above the heading.

## YAGNI

Every phase in the build outline must cite at least one piece of acceptable evidence that it is needed: a behavior you described, a dependency another phase requires, an existing contract that breaks without it. Phases whose only justification is *completeness of the roadmap* are YAGNI candidates. They get deferred, merged into a smaller adjacent phase, or removed entirely. The `information-architect` review pass runs against the rendered outline and flags phases whose demonstrable outcome is unclear or whose justification is symmetry rather than evidence.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

## Sources

The skill draws on three distinct provenance lines: the vertical-slice planning practice itself, the IA frameworks the output template was reviewed against, and the dispatched-at-runtime IA review.

### Kent Beck: *Extreme Programming Explained* (XP, vertical slicing)

The "vertical slice, not horizontal layer" principle traces to XP and the broader agile-delivery tradition. The idea: a release that ships a thin end-to-end strip of behavior is a release. A release that ships "all the database work" is not. The skill's rule that *every* phase must be demonstrable to a real person, including foundation phases, is a strong reading of the same principle.

URL: https://www.oreilly.com/library/view/extreme-programming-explained/0201616416/

### Mike Cohn: *User Stories Applied*

Cohn's INVEST criteria for user stories (Independent, Negotiable, Valuable, Estimable, Small, Testable) inform the per-phase shape. Each phase entry is independent enough to demo on its own, valuable enough to put in front of a real person, and small enough to ship as a unit of delivery. The *"Outcome to demonstrate"* numbered demo script is the testable-and-valuable evidence that the phase qualifies as a deliverable rather than a milestone.

URL: https://www.mountaingoatsoftware.com/books/user-stories-applied

### Rosenfeld & Morville: *Information Architecture* (4th edition)

The four IA systems (organization, labeling, navigation, search) are the foundation of the output template's structure. The Build Phase Index is an *organization system*. The kind taxonomy (Foundation / Feature slice / Polish / Deferred) and the per-entry field names (`Builds on`, `What we build`, `Why this is Phase N`, `Outcome to demonstrate`, `Source citations`, `Connects to`, `Preconditions to verify before starting`) are a *labeling system*. The executive-summary *"Where to look next"* line plus the explicit `{#phase-N}` and `{#oq-N}` anchors form the *navigation system*. The stable IDs make `Cmd-F` search durable across the document's lifetime.

URL: https://www.oreilly.com/library/view/information-architecture-4th/9781491913529/

### Mark Baker: *Every Page is Page One* (EPPO)

Baker's EPPO discipline shapes every per-phase entry. A reader landing on `#phase-5` from a search result, a Slack thread, or a ticket comment must understand the phase without reading prior phases. The entry has to stand alone. The `Builds on` line at the top of every entry is the explicit dependency signal that satisfies EPPO at a glance. The rest of the entry fills in the picture. The skill dispatches `information-architect` to verify EPPO compliance against every rendered outline.

URL: https://everypageispageone.com/

### Richard Saul Wurman: LATCH

Wurman's LATCH framework drove the choice of indexing scheme for phases. The IDs use the *Location* / sequence dimension (assigned in build order, stable for the document's life) rather than *Category* (Foundation / Feature slice / Polish / Deferred) because grouping by category fragments the index and prevents a single citable list. Category appears as a *facet* on each entry's `Kind` line, not as the grouping axis.

URL: https://www.wurman.com/books/

### Dan Brown: *Eight Principles of Information Architecture*

Brown's principle of Disclosure underpins the executive-summary subsection ordering: `goal` → `shape` → `sequencing rationale` → `departures` → `deferrals` → `where to look next`. Brown's principle of Multiple Classification supports the indexing decision: each phase is *classified* by `Kind` but *located* by sequence number, so readers who want to scan by kind use the Build Phase Index, and readers who want to cite a phase use the number.

URL: https://eightprinciples.com/

### John Carroll: Minimalism

Carroll's minimalism principles inform the template's "no throat-clearing" stance. Optional sections (a *"How {{this build}} Differs from {{the source}}"* section when there are no departures; per-phase deferred entries when nothing was deferred) are *physically omitted* (not collapsed) when not generated, so a reader scanning the outline never reads *"no departures captured"* when they could read nothing instead.

URL: https://mitpress.mit.edu/9780262531313/the-nurnberg-funnel/

### `information-architect` agent

The skill dispatches `information-architect` at runtime against every rendered outline. The agent applies its full protocol set against the rendering and returns findings the skill folds into a final pass. The agent is also the reviewer of the output template itself. The template's section order, field names, anchor scheme, and optional-section handling were shaped by the agent's findings before the skill shipped.

URL: see [`information-architect` agent definition](../../../han.core/agents/information-architect.md)

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`information-architect`](../../agents/han.core/information-architect.md). The agent the skill dispatches at runtime to review the rendered outline. Also the agent that reviewed the output template before the skill shipped.
- [`/gap-analysis`](./gap-analysis.md). Pair upstream when the source artifact is a comparison between current and desired state. Run `/gap-analysis` first to produce the gap report, then point this skill at the report. `G-NNN` gap IDs become source citations on the phase entries that close them.
- [`/plan-a-feature`](./plan-a-feature.md). Pair upstream when the source artifact is a single feature that needs a phased rollout. Run `/plan-a-feature` first to produce the spec, then point this skill at the spec when the feature is large enough to ship in slices rather than all at once.
- [`/stakeholder-summary`](../han.reporting/stakeholder-summary.md). Pair upstream when the source spec needs non-technical sign-off before sequencing the build. Run `/stakeholder-summary` after `/plan-a-feature`, get stakeholder feedback, then run this skill to phase the agreed-on shape.
- [`/plan-implementation`](./plan-implementation.md). Pair downstream once a phase is greenlit. The phase entry's *"What we build"* and *"Outcome to demonstrate"* become the implementation plan's behavioral spec. *"Preconditions to verify"* become Open Items.
- [`/iterative-plan-review`](./iterative-plan-review.md). Use to refine an *existing* outline that needs sharpening. This skill produces a new outline from scratch. `/iterative-plan-review` iterates on one in place.
- [`/architectural-decision-record`](./architectural-decision-record.md). The sibling skill for recording an architectural decision. Use `/architectural-decision-record` when the question is *"what did we decide and why."* Use `/plan-a-phased-build` when the question is *"in what order do we build."*
- [Build-phase outline template](../../../han.core/skills/plan-a-phased-build/references/build-phase-outline-template.md). The IA-reviewed template the skill renders. The template's front matter, anchor scheme, and section structure are the canonical reference for the outline's shape.

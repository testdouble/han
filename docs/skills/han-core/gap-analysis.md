# /gap-analysis

Operator documentation for the `/gap-analysis` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-core/skills/gap-analysis/SKILL.md`](../../../han-core/skills/gap-analysis/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Compares two artifacts (a current state and a desired state) and produces a plain-language, stakeholder-readable report indexed by stable gap IDs.
- **When to use it.** You have a spec, PRD, design, or requirements doc and want to know how an implementation (or another artifact) measures up, and you want a report a non-engineer can read.
- **What you get back.** `gap-analysis-report.md` (four-section progressive-disclosure structure) plus the underlying `gap-analysis-source.md` written by the `gap-analyzer` agent.
- **Default-on swarm.** A validator-and-augmenter swarm runs by default at every size, with `junior-developer` running an explicit actor-perspective sweep (human users, API callers, AI agents, integration partners, batch processes, internal services). Reply `no swarm` to opt out and fall back to a lightweight gap-analyzer-only pass.
- **Size-aware.** The skill classifies the analysis as small / medium / large, defaults to small (minimum viable swarm: validator + junior-developer, plus investigator when the current state is concrete), and scales the swarm composition proportional to the gap count and domain spread. Pass the size as the first positional argument to override (`/gap-analysis large`). See [Sizing](#sizing).

## Key concepts

- **Plain language by default.** Sections 1 and 2 of the report contain no file paths, line numbers, function names, or library mechanics. Technical fidelity is quarantined to Section 3 and is only added when you explicitly opt in.
- **Purpose-conditioned "Where to start."** If you say *why* you are running the comparison (for example, "before a redesign pass"), the report opens Section 1 with a short, explicitly-labeled "Where to start" view: up to five gaps that most block that purpose, one reason each. This is the skill's own prioritization judgment layered on top of the analyzer's neutral, unprioritized gap list, never replacing it, and omitted entirely when no purpose is given. The `gap-analyzer` itself stays neutral and does no prioritization.
- **Whole-report caveats surface once.** A provenance concern that applies to the comparison as a whole (most commonly: the desired-state artifact is a provided, uncommitted, same-session source) is surfaced one time as an "Analysis caveats" note in Section 4, not repeated as a finding on every gap and not folded into any gap's confidence. The scrutiny the evidence rule mandates for `provided` sources is preserved; only the per-gap noise is removed.
- **Stable `G-NNN` gap IDs.** Every gap gets a citable ID assigned in discovery order. Tickets, threads, and follow-up reports reference the IDs. Sections 3 and 4 cross-reference them without restating the plain-language explanation.
- **The swarm runs by default.** A minimum viable team ships at every size and you opt out with `no swarm` if you want the lightweight pass. The swarm's job is to corroborate, contradict, and enrich what `gap-analyzer` produced — and to surface gaps the analyzer missed because it only thought about one actor type.
- **Actor-perspective sweep is built in.** `junior-developer` is a required swarm member and runs an explicit actor sweep across every gap: enumerate every actor the desired state addresses or implies (human users and sub-roles, API callers, AI agents, integration partners, batch processes, internal services), check whether the gap holds for each, and raise `proposed_new_gap` whenever the analyzer's gap is correct for one actor but a *different* gap exists for another. The sweep no longer depends on you naming the actors in your prompt: `gap-analyzer` reports the actors and modes it observed in the desired state, and the skill seeds the sweep with that list as a floor `junior-developer` then expands.
- **Four sections, progressively disclosed.** Executive Summary → Indexed Gaps → optional Technical Details → Swarm Findings (default-on). Reading stops anywhere; what came before stands on its own. Optional sections are physically omitted when not requested, not collapsed.
- **IA-designed template.** The report template was designed by `information-architect` against Rosenfeld & Morville's four IA systems, DITA topic typing, LATCH, Mark Baker's "Every Page is Page One", John Carroll's minimalism, JoAnn Hackos's audience-task mapping, and Dan Brown's 8 Principles of IA. The template lives at [`gap-analysis-report-template.md`](../../../han-core/skills/gap-analysis/references/gap-analysis-report-template.md).

## When to use it

**Invoke when:**

- You have a spec, PRD, requirements doc, or design and want to compare it against an implementation, a shipped feature, or another artifact. *"What's missing from X compared to Y," "does the auth module satisfy the auth spec," "did the v3 launch ship everything in the PRD."*
- The audience is mixed (product managers, engineering leads, designers, auditors, stakeholders) and the deliverable needs to be a plain-language report rather than raw analyst output with file paths and code identifiers.
- You want a stable, citable index of gaps. Each gap gets a `G-NNN` ID you can reference in tickets, threads, and follow-up work. The IDs are append-only across sections of the same report.
- You want adversarial validation, actor-perspective coverage, and domain augmentation of the gap list before it goes to stakeholders. The swarm runs by default; reply `no swarm` if you want the lightweight pass.
- You only named one artifact and a comparison target is implied (for example, *"is the auth implementation complete," "what's missing from this feature"*). The skill resolves the implied artifact from the project's documentation root, codebase, and prior context.
- You explicitly ask for a *bidirectional* analysis (current ↔ desired) rather than the default unidirectional pass (current → desired).

**Do not invoke for:**

- **Investigating runtime bugs or failures.** Use [`/investigate`](../han-coding/investigate.md) for evidence-based root-cause work on a bug. This skill compares artifacts. It does not trace data flow or error paths to a defect.
- **Reviewing code correctness, style, or security.** Use [`/code-review`](../han-coding/code-review.md) for a comprehensive code review of a branch or files, or [`/post-code-review-to-pr`](../han-github/post-code-review-to-pr.md) to post the review to a GitHub PR. This skill does not assess correctness of implementation independent of a desired-state artifact.
- **Architectural assessment of an existing module.** Use [`/architectural-analysis`](../han-coding/architectural-analysis.md) for coupling, data flow, concurrency, risk, and SOLID alignment of a module. This skill compares a module against a target spec. It does not assess the module on its own architectural merits.
- **Iterating on a plan that already exists.** Use [`/iterative-plan-review`](../han-planning/iterative-plan-review.md) for multi-pass review of a plan you already drafted. This skill compares two artifacts. It does not refine a single plan in place.
- **Auditing whether documentation updates preserved important content.** Use the [`content-auditor`](../../agents/han-core/content-auditor.md) agent directly when the question is *"did the rewrite drop facts the original carried."* This skill compares two distinct artifacts. `content-auditor` validates a single artifact across a before-and-after.
- **Single-artifact analysis with no comparison target, even implied.** If there is genuinely no second artifact and no implied target, the work is documentation, investigation, or architectural. Pick the matching skill instead.
- **Open-ended research with no comparison target.** Use [`/research`](./research.md) to survey options, prior art, or how something works. This skill needs two artifacts to compare; `/research` needs only a question.

## How to invoke it

Run `/gap-analysis` in Claude Code. Point it at the two artifacts in the same message, or describe them. Paths, URLs, or inline text all work.

Give it:

1. **The current state.** What exists today: a code directory, a file, a URL, or inline text. Examples: `src/auth/`, `docs/features/bulk-export/feature-implementation-plan.md`, `https://staging.example.com/api/users`. The skill defaults to treating the first input as the current state.
2. **The desired state.** What is expected: a spec, a PRD, a design doc, a requirements file, a URL, or inline text. Examples: `docs/specs/auth.md`, `https://wiki.example.com/PRD-v3`, `docs/features/bulk-export/feature-specification.md`. The skill defaults to treating the second input as the desired state.
3. **Scope, optional.** A bounded region to compare (a specific subsystem, feature, section, or capability). Without a scope, the `gap-analyzer` agent identifies the comparison areas itself by reading both inputs.
4. **Mode overrides, optional.** By default the skill runs the recommended swarm and omits technical details. If you want a different shape, say so up front. *"Skip the swarm"* / *"no swarm"* drops to the lightweight gap-analyzer-only pass. *"Lightweight swarm"* drops to the minimum two (validator + junior-developer). *"Include technical details"* adds Section 3. *"Run a large swarm"* overrides the recommended size. Naming specific specialists adds or removes them from the team.
5. **Direction override, optional.** The default direction is current → desired (what does the implementation lack relative to the spec). If you want the analysis reversed (what does the spec lack relative to the implementation: scope creep, undocumented capabilities) or fully bidirectional, say so.
6. **Purpose, optional.** Why you are running the comparison: *"before a redesign pass," "to scope the next sprint," "to decide whether to ship."* When you state a purpose, the report adds a "Where to start" view naming the few gaps that most block it. Omit it and the view is simply not rendered.

Example prompts that work well:

- `/gap-analysis docs/specs/auth.md src/auth/`. Compare the auth spec to the auth implementation. Default modes: swarm runs, plain language only.
- `/gap-analysis`. *"Compare what we shipped in the bulk-export feature to what the PRD called for. The result is going to the steering committee on Friday."* The swarm runs at the recommended size.
- `/gap-analysis docs/features/checkout/feature-specification.md src/checkout/`. *"No swarm — we just want a first-pass scoping pass."* Falls back to the lightweight gap-analyzer-only run.
- `/gap-analysis`. *"Compare the v2 PRD at `docs/prd-v2.md` against the v3 PRD at `docs/prd-v3.md`. Bidirectional. We need to see what was added *and* what was dropped."*
- `/gap-analysis docs/specs/billing.md src/billing/`. *"Include technical details; engineers need to act on this."* Swarm + Section 3.

The skill states the resolved comparison direction, the chosen size class, the swarm composition, and the chosen modes in a short message before launching `gap-analyzer`. If you want to correct any of those, say so and the skill adjusts before proceeding.

## What you get back

Two files on disk plus an in-channel summary:

- The **`gap-analysis-report.md`**. The stakeholder-readable artifact. Four sections, progressively disclosed:
  - **Section 1: Executive Summary.** Plain-language verdict on overall alignment, a magnitude-at-a-glance table broken down by category (Missing / Partial / Divergent / Implicit), 3-5 bullets describing the *shape* of the gap thematically, a *"what this means for the work ahead"* paragraph, and a pointer to subsequent sections. When you stated a purpose for the comparison, the section also opens with a labeled "Where to start" view: up to five gaps that most block that purpose, one reason each.
  - **Section 2: Indexed Gaps.** A scan-view index table mapping gap IDs to plain-language titles and categories, followed by one self-contained entry per gap. Each entry has plain-language `Expected` and `Current` descriptions, a `Why it matters` paragraph, and a `Confidence` field (High / Medium / Low) with a one-sentence reason.
  - **Section 3: Technical Details** *(included only when requested).* Per-gap technical fidelity: `Locations` (file paths, anchors), `Relevant identifiers` (function, class, module names), `Specifics of the divergence`, `Remediation direction`, `Effort signal` (Trivial / Small / Medium / Large / Unknown), `Risks / dependencies`. Cross-references to Section 2 by `G-NNN` ID.
  - **Section 4: Swarm Findings** *(included only when a swarm ran).* Confirmations, Contradictions, and Augmentations from the swarm, grouped by signal type and cross-referenced by `G-NNN` ID. Confidence summary table grouping gaps as High / Medium / Low based on swarm corroboration. When the validator raised a whole-report caveat, it appears once here under "Analysis caveats," outside the confidence table.
- The **`gap-analysis-source.md`**. The `gap-analyzer` agent's full structured output, written alongside the report. Contains `GAP-NNN` entries with evidence pairs (file paths and line numbers, document section headings, URL excerpts), the analyzer's category classifications, and an "Actors and Modes Observed" note recording the actor types and modes the analyzer saw in the desired state (which seeds `junior-developer`'s sweep). The skill maps `GAP-NNN` to `G-NNN` in the report. The source file is preserved for engineers who need the raw evidence to act on a gap.
- An **in-channel summary** with the report path, the source file path, the size class, the modes used, the gap count broken down by category, whether a conditional second round ran (and why), and any open recommendations (for example, *"the swarm contradicted three gaps. Adjudicate before remediation,"* or *"two `proposed_new_gap` entries were surfaced by junior-developer's actor sweep and added to the report"*).

The two files interlock through shared IDs. Every `G-NNN` in the report maps back to a `GAP-NNN` in the source file. Every cross-reference in Sections 3 and 4 of the report names a `G-NNN` from Section 2.

The default report (swarm runs, plain language only) carries Sections 1, 2, and 4. Section 4 reflects the default-on swarm, and per-gap confidence values in Section 2 are derived from swarm verdicts rather than defaulting to `Medium`. The lightweight report (`no swarm` path) is Sections 1 and 2 alone, with every gap at `Medium` confidence. Adding Section 3 augments the report. It never changes the meaning of Sections 1 and 2.

## How to get the most out of it

- **Be explicit about which is current and which is desired.** The default direction is current → desired (what's missing from the implementation relative to the spec). Reversing the direction yields a different finding shape: scope creep, undocumented capabilities, drift in the desired-state artifact. Name the direction up front when it matters.
- **Let the default swarm run unless you have a reason not to.** The default modes (swarm runs at the recommended size, plain language only) produce a stakeholder-readable report with `High` / `Medium` / `Low` confidence on each gap and explicit actor-perspective coverage from `junior-developer`. Drop to the lightweight pass (`no swarm`) when you're doing rapid first-pass scoping and don't need confidence signals yet.
- **Use `lightweight` when you want some validation but not full coverage.** The `lightweight` mode keeps the two required roles (`adversarial-validator` and `junior-developer`) and drops everything else. You get adversarial counter-evidence and an actor sweep without paying for domain specialists when the gaps don't warrant them.
- **Match swarm size to the analysis, not the calendar.** The skill recommends small (2–3 agents, no PM), medium (4–6 agents with PM), or large (6–8 agents with PM) based on gap count, distribution across categories, and the domains the gaps touch. Override the recommendation only when you have a specific reason (for example, the analysis touches auth even though only two gaps were found: promote to medium and include `adversarial-security-analyst`).
- **Name specialists you know you want.** If gaps cluster in a single domain (auth, data, UX, deployment, resilience, architecture), naming the matching specialist (`adversarial-security-analyst`, `data-engineer`, `user-experience-designer`, `devops-engineer`, `on-call-engineer`, `software-architect`, `system-architect`) ensures they are included regardless of what the heuristic would have picked. The three required swarm roles (`adversarial-validator`, `junior-developer`, plus `evidence-based-investigator` when the current state is concrete) are always there.
- **Expect a second round when the swarm finds the analyzer missed an actor type.** When the first-round swarm surfaces ≥ 3 `proposed_new_gap` entries or contradictions on ≥ 20% of gaps, the skill runs one additional pass with `gap-analyzer` to re-scan with the new actor context. That round is scoped to find *additional* gaps in the under-covered actor or behavior class, plus recategorizations and withdrawals; it does not re-confirm gaps the swarm already corroborated. Bounded to one extra round — never iterative beyond that.
- **State your purpose to get a "Where to start" shortcut.** On a long report, the fastest way to cut through it is to tell the skill why you are comparing (*"before a redesign pass," "to scope the next sprint"*). The report then opens with a short, labeled list of the gaps that most block that goal. Without a purpose, you get the full unprioritized list and no shortcut — which is the right default when there is no single goal to prioritize against.
- **Pair with `/plan-implementation` downstream.** Once a gap analysis identifies the gaps, `/plan-implementation` produces a committable plan to close them. The pairing is natural: the gap report's Section 2 IDs become work items in the implementation plan; Section 3 (when present) feeds the technical detail straight into the plan's Implementation Approach section.
- **Pair with `/plan-a-phased-build` when remediation spans phases.** When the gap report shows gaps that cannot all be closed in one deliverable slice, run `/plan-a-phased-build` with the gap report as the source. The `G-NNN` IDs become source citations on the phase entries that close them, and the phased plan flows into `/plan-implementation` per phase.
- **Pair with `/iterative-plan-review` upstream.** When the desired-state artifact is itself a plan you don't yet trust, run `/iterative-plan-review` on it first. A gap analysis against a flawed desired-state produces flawed gaps. Hardening the desired-state before comparing pays for itself.
- **Re-run after the spec or implementation changes.** A gap analysis is a point-in-time artifact. It does not auto-refresh. After the implementation closes gaps (or after the spec changes), re-run the skill. The new report's `G-NNN` IDs are independent of the prior run's. The prior report stays valid as a snapshot.
- **Use bidirectional mode when the desired-state artifact is itself drifting.** Bidirectional analysis catches the *current state has capabilities the desired state never specified* failure mode: scope creep, undocumented behavior, capabilities that were shipped without an explicit spec. The default unidirectional pass misses this entirely.
- **Read Section 1 even if you wrote it.** The IA-designed template is structured so a stakeholder reading only Section 1 has a complete (low-resolution) understanding of the gap. Use it as a sanity check on your own framing. If Section 1 doesn't read well to a non-technical audience, the executive-summary translation step in the skill needs adjusting and you should re-run with a sharper prompt.

## Sizing

Size determines the swarm composition. The skill defaults to small and only escalates when concrete signals require it. Every size ships with a swarm by default — opt out with `no swarm` if you want the lightweight gap-analyzer-only pass.

| Size | Gap count | Domain signals | Swarm composition |
|---|---|---|---|
| **Small** *(default)* | 0–3 total gaps | Single domain (one feature, one module, one document section); no security / data / cross-service / architectural signals in any gap. | **2–3 agents.** `adversarial-validator` and `junior-developer` always, plus `evidence-based-investigator` when the current state is concrete. No PM. |
| **Medium** | 4–10 total gaps | Two or three adjacent domains; may touch one cross-cutting concern (a single auth surface, a single integration boundary, a single data-contract change). | **4–6 agents.** Required three (`adversarial-validator`, `junior-developer`, `evidence-based-investigator`) plus 1–2 domain specialists plus `project-manager` for Section 4 synthesis. |
| **Large** | 11+ total gaps | Cross-cutting concerns across multiple domains (security + data + architecture, or cross-service integration), or you explicitly requested a full swarm. | **6–8 agents.** Required three plus 2–4 domain specialists plus `project-manager`. |

How the size is chosen:

- **Default to small.** Unless the gap count or domain signals push the analysis higher, the skill stays at small.
- **Domain-driven specialist selection.** Augmenters are drawn from `adversarial-security-analyst`, `data-engineer`, `user-experience-designer`, `devops-engineer`, `on-call-engineer`, `system-architect`, `software-architect`, `content-auditor`, `codebase-explorer` based on which domains the gaps touch.
- **The swarm runs by default at every size.** The lightweight (`no swarm`) path is an explicit opt-out.

How to override the size:

- Pass `small`, `medium`, or `large` as the first positional argument: `/gap-analysis medium`, `/gap-analysis large docs/specs/auth.md src/auth/`.
- When the size is overridden via `$size`, the skill announces the override (`Medium: passed via $size`) and uses the chosen band for the swarm composition.
- Conversational overrides (*"run a large swarm anyway"*) still work and are equivalent.

For the cross-skill sizing model and design principles, see [Sizing](../../sizing.md).

## Cost and latency

The default run carries the swarm. Opting out (`no swarm`) is the cheapest configuration and is appropriate for rapid first-pass scoping where confidence signals are not yet needed.

- **Default mode (swarm runs at the recommended size, plain language only).** One `gap-analyzer` dispatch plus the swarm fan-out (2–8 sub-agents in parallel depending on size). At small, that's 3–4 total dispatches (analyzer + 2–3 swarm agents). At medium, 5–7 (analyzer + 4–6 swarm agents). At large, 7–9 (analyzer + 6–8 swarm agents). The swarm runs in a single parallel round; `project-manager` runs after at medium and large to consolidate Section 4 content, then `han-core:readability-editor` rewrites the consolidated report for readability, preserving every fact and `G-NNN` gap ID. If the conditional second round (Step 5.5) fires — when the swarm produces ≥ 3 new gaps or contradictions on ≥ 20% of original gaps — add one more `gap-analyzer` dispatch, never more.
- **Lightweight mode (`no swarm`).** A single `gap-analyzer` dispatch plus the skill's in-process rendering of Sections 1 and 2. No additional sub-agents. Every gap shipped at `Medium` confidence. Lowest-cost configuration.
- **Technical details mode (Section 3 added).** No additional sub-agents. Section 3 is rendered by the skill from the `gap-analyzer`'s existing structured output: file paths, identifiers, and divergence specifics already in the source file. Cost equals the surrounding mode (default or lightweight) plus a marginal rendering pass.

The skill is built for periodic, decision-point analysis (before a steering committee, before a remediation plan, after a release), not for tight-loop iteration on the same comparison within a single session. Re-running the skill is appropriate after a spec or implementation has materially changed. Running it repeatedly against the same inputs in the same session does not produce new insight.

## In more detail

The skill's input is two artifacts and its output is a stakeholder-readable report. The judgment-heavy work (identifying comparison areas, mapping correspondences, classifying gaps into the Missing / Partial / Divergent / Implicit taxonomy, gathering evidence pairs from both inputs) happens inside the `gap-analyzer` agent. The skill orchestrates that agent, runs a validator-and-augmenter swarm by default, then translates the analyzer's structured output into the IA-designed template.

**Default-on swarm posture.** The swarm runs by default for three reasons. First, `gap-analyzer` is generalist by design — it identifies feature-and-behavior correspondences across two artifacts. It reports the actor types and modes it observed in the desired state, and the skill seeds `junior-developer` with that list, but the analyzer does not itself reason about whether each gap holds per actor. `junior-developer`'s actor sweep catches the failure mode where a gap is correct for human users but a *different* gap exists for API callers or AI agents that the analyzer never considered, expanding past the observed-actor floor. Second, the swarm produces per-gap confidence signals (High / Medium / Low) that change how stakeholders prioritize, and stakeholder-readable reports benefit from confidence even when the gap list is small. Third, contradictions surfaced by `adversarial-validator` are decision-bearing — they need adjudication before remediation — and waiting for a stakeholder to opt in to discover them is the wrong default. The lightweight (`no swarm`) path remains available for rapid first-pass scoping where confidence is not yet a decision input.

**Required swarm roles.** At every size, the swarm includes `adversarial-validator` (attacks gap-analyzer's findings with counter-evidence) and `junior-developer` (runs the actor-perspective sweep across human users, API callers, AI agents, integration partners, batch processes, and internal services). `evidence-based-investigator` is required when the current state is concrete enough to verify against — effectively always at medium and large. `project-manager` is required at medium and large to consolidate Section 4 content from the four-or-more specialist outputs; at small (two or three agents) the skill consolidates deterministically without PM.

**Sizing rule.** Small analyses (0-3 gaps, single domain, no security / data / cross-service signals) ship the minimum viable swarm (2–3 agents, no PM). Medium analyses (4-10 gaps, two or three adjacent domains, may touch one cross-cutting concern) ship a 4–6 agent swarm with PM. Large analyses (11+ gaps, multi-domain cross-cutting concerns, security or data implications, or explicit user request) ship a 6–8 agent swarm with PM. Augmenters are drawn from the standard han specialist roster based on what the gaps touch.

**Conditional second round.** Single-round parallel fan-out captures most of the value. The one failure mode it can miss is the analyzer systematically excluding an actor type — for example, comparing a spec written for human users against an implementation also serving API callers, where every gap-shaped finding actually has a parallel API-caller-shaped finding the analyzer never considered. When the first-round swarm surfaces ≥ 3 `proposed_new_gap` entries (Trigger A) or contradictions on ≥ 20% of gaps (Trigger B), the skill re-dispatches `gap-analyzer` once with the new actor context and merges the delta into the source file. A fired trigger is a proxy for an under-covered actor or behavior class; the proposed gaps are a symptom of it. So the round re-scans that class for *additional* gaps and surfaces recategorizations and withdrawals, and is explicitly told not to spend the pass re-confirming gaps the swarm already corroborated. Bounded to one extra round.

**Plain-language translation.** The `gap-analyzer` agent produces structured output rich in technical detail: file paths, line numbers, document anchors, code identifiers. The skill's render step translates each gap's `Expected`, `Current`, and `Why it matters` content into plain language for Sections 1 and 2 by stripping every code or document-mechanic reference and replacing it with a capability-or-behavior description. Technical fidelity is preserved in `gap-analysis-source.md` and, when you opt in, surfaces in Section 3 with full evidence pairs intact.

**Append-only `G-NNN` IDs.** Gap IDs are assigned in the order the analyzer surfaced the gaps, including any `proposed_new_gap` entries the swarm added. IDs are stable for the life of the report and not renumbered if a re-run produces a different gap set. Re-running creates a new report, with its own ID space, rather than editing the prior report in place.

**Optional sections are physically omitted.** When Section 3 or Section 4 is not requested or generated, the skill removes the section from the rendered output entirely (and removes the corresponding `sections_included` entry from the front matter). The "How to Read This Report" frame at the top of the template is rewritten to reflect what was included so a reader is never promised a section that does not exist.

## Sources

The skill draws on two distinct provenance lines: the gap-analysis vocabulary itself, and the IA frameworks the report template was designed against.

### Gap-analysis taxonomy and protocol

The four-category taxonomy (Missing / Partial / Divergent / Implicit) and the evidence-pair requirement come from the `gap-analyzer` agent's protocol, which is itself grounded in software-engineering specification practice. The taxonomy is the agent's own vocabulary. The skill renders gap entries using that taxonomy verbatim because translating *"Missing"* or *"Partial"* into looser language would degrade the precision a stakeholder needs to decide what kind of remediation each gap requires.

URL: see [`gap-analyzer` agent definition](../../../han-core/agents/gap-analyzer.md)

### Rosenfeld & Morville: *Information Architecture* (4th edition)

The four IA systems (organization, labeling, navigation, search) are the foundation of the report's structure. The four-section progressive-disclosure design is an *organization system*. The gap categories and severity vocabulary are a *labeling system*. The index table at the top of Section 2 plus the `G-NNN` cross-references throughout Sections 3 and 4 form the *navigation system*. The stable, append-only IDs make `Cmd-F` search durable across the report's lifetime.

URL: https://www.oreilly.com/library/view/information-architecture-4th/9781491913529/

### JoAnn Hackos: Audience-Task Mapping and DITA Topic Typing

Hackos's audience-and-task mapping informs the section split. Section 1 serves stakeholders doing a triage task. Section 2 serves PMs and leads doing a discuss-and-prioritize task. Section 3 serves engineers doing an implement task. Section 4 serves anyone doing a trust-and-adjudicate task. DITA's concept / task / reference distinction informs the topic-type discipline within sections: Section 1 is concept, Section 2 is a reference list of concept entries, Section 3 is reference + task, Section 4 is reference.

URL: https://www.xmlpress.net/publications/dita-third-edition/

### Mark Baker: *Every Page is Page One* (EPPO)

Baker's EPPO discipline shapes the per-gap entry format in Section 2. Each entry is self-contained: a reader landing on a single gap via search or a deep link gets oriented (what it is, what was expected vs. current, why it matters, how confident we are) without needing to read the rest of the report. The "How to Read This Report" frame at the top of the template is the EPPO orientation for cold arrivals to the report itself.

URL: https://everypageispageone.com/

### Richard Saul Wurman: LATCH

Wurman's LATCH (Location, Alphabet, Time, Category, Hierarchy) framework drove the choice of indexing scheme for gaps. The IDs use the *Location* / sequence dimension (assigned in discovery order, append-only, stable for the report's life) rather than *Category* (Missing/Partial/Divergent/Implicit) because grouping by category fragments the index and prevents a single citable list. Category appears as a *facet* on each entry, not as the grouping axis.

URL: https://www.wurman.com/books/

### John Carroll: Minimalism

Carroll's minimalism principles inform the template's "no throat-clearing" stance. There is no meta-introduction. The "How to Read" frame replaces it. Tables replace prose where lookup is the task. Optional sections are physically omitted (not collapsed) when they are not generated, so a reader scanning the report never reads *"Section 3 was not included"* when they could read nothing instead.

URL: https://mitpress.mit.edu/9780262531313/the-nurnberg-funnel/

### Dan Brown: *Eight Principles of Information Architecture*

Brown's principle of Disclosure underpins the section ordering and the optional-section placement. Sections 1 and 2 are load-bearing. Sections 3 and 4 sit *below* them so removing the optional sections never breaks the sections above. The principle of Multiple Classification supports the indexing decision: each gap is *classified* by category but *located* by sequence ID, so readers who want to scan by category use the index table, and readers who want to cite a gap use the ID.

URL: https://eightprinciples.com/

### Adversarial Review and Devil's Advocate Practice

The default-on swarm's role mirrors the same red-team / devil's-advocate practice that powers `/code-review` and `/iterative-plan-review` team mode. `adversarial-validator` attacks each `gap-analyzer` finding with counter-evidence. `evidence-based-investigator` verifies each gap against the current state. `junior-developer` runs an actor-perspective sweep to catch gaps the analyzer missed because it only considered one actor type. Augmenters add domain context the generalist gap-analyzer may have missed. The pattern is documented in Klein's pre-mortem literature and the broader red-teaming tradition.

URLs: https://hbr.org/2007/09/performing-a-project-premortem and https://en.wikipedia.org/wiki/Red_team

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [Sizing](../../sizing.md). The cross-skill sizing model. Explains the small / medium / large bands, the default-to-small rule, and the `$size` override.
- [Evidence](../../evidence.md). The canonical evidence rule the skill applies when characterizing each gap's evidence pair. Trust classes, the corroboration gate for web-source claims, and the no-evidence label for silent desired-state evidence.
- [`gap-analyzer`](../../agents/han-core/gap-analyzer.md). The agent that performs the underlying gap analysis. The skill always dispatches it once and reads its full output.
- [`adversarial-validator`](../../agents/han-core/adversarial-validator.md). Required swarm role at every size. Attacks each gap with counter-evidence to produce per-gap `confirmed` / `contradicted` / `inconclusive` verdicts.
- [`junior-developer`](../../agents/han-core/junior-developer.md). Required swarm role at every size. Runs the actor-perspective sweep — enumerates every actor the desired state addresses or implies, checks each gap against every actor type, surfaces gaps the analyzer missed because it only considered one actor.
- [`evidence-based-investigator`](../../agents/han-core/evidence-based-investigator.md). Required swarm role when the current state is concrete (codebase, document on disk, fetchable URL). Verifies each gap against the current state with file-level evidence.
- [`project-manager`](../../agents/han-core/project-manager.md). Required swarm role at medium and large. Consolidates the four-or-more specialist outputs into Section 4 of the report and produces per-gap confidence values. Not called at small.
- [`readability-editor`](../../agents/han-core/readability-editor.md). Dispatched on the consolidated reports (medium and large, where `project-manager` ran) to rewrite the report against the shared readability standard, preserving every fact and gap ID. Skipped at small and on the `no swarm` path.
- [`information-architect`](../../agents/han-core/information-architect.md). The agent that designed the report template. The template is a one-time IA design output. The agent is not dispatched at runtime.
- [`/iterative-plan-review`](../han-planning/iterative-plan-review.md). Pair upstream when the desired-state artifact is itself a plan you do not yet trust. Hardening the desired state before comparing produces sharper gaps.
- [`/plan-implementation`](../han-planning/plan-implementation.md). Pair downstream when the gap report will drive remediation work. The gap report's Section 2 IDs become work items. Section 3 (when present) feeds the implementation plan's Implementation Approach.
- [`/investigate`](../han-coding/investigate.md). The sibling skill for runtime bug investigation. Use `/investigate` when the question is *"why is this broken"*. Use `/gap-analysis` when the question is *"how does this compare to what was specified."*
- [`/code-review`](../han-coding/code-review.md). The sibling skill for code-level quality review. Use `/code-review` when the question is about correctness, style, or security. Use `/gap-analysis` when the question requires a comparison against a specification.
- [Report template](../../../han-core/skills/gap-analysis/references/gap-analysis-report-template.md). The IA-designed template the skill renders. The template's front matter, "How to Read This Report" frame, and section structure are the canonical reference for the report's shape.

# /iterative-plan-review

Operator documentation for the `/iterative-plan-review` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.core/skills/iterative-plan-review/SKILL.md`](../../han.core/skills/iterative-plan-review/SKILL.md).

> See also: [Plugin landing page](../../README.md) · [All skills](./README.md) · [All agents](../agents/README.md) · [YAGNI](../yagni.md) · [Evidence](../evidence.md)

## TL;DR

- **What it does.** Stress-tests an already-written plan through multiple codebase-grounded review passes, editing the plan in place.
- **When to use it.** A plan has been drafted and you want it refined, verified, or proven sound before implementation.
- **What you get back.** The plan file, edited in place, plus `artifacts/review-findings.md` and `artifacts/review-iteration-history.md`.
- **Size-aware.** The skill classifies the plan as small / medium / large, defaults to small (lightweight mode, no team), and only escalates to team mode when concrete signals require it. Pass the size as the first positional argument to override (`/iterative-plan-review large path/to/plan.md`). See [Sizing](#sizing).

## Key concepts

- **Lightweight mode vs team mode.** Simple plans get a checklist-based iteration loop (no sub-agents). Complex or cross-cutting plans get a team of specialists (`junior-developer`, `evidence-based-investigator`, `adversarial-validator` always, plus three to five more sized to what the plan touches).
- **Iteration caps with early stopping.** Caps scale with plan size: small (1 iteration), medium (2 rounds), large (3 rounds). Lightweight mode runs the iteration loop solo against the plan; team mode runs the same loop but every round is a multi-specialist parallel review. Both modes stop early when the most recent pass produced two or fewer new findings and zero major findings.
- **Edits the plan in place.** No separate review document. Non-obvious, finding-driven edits carry inline `([F#](...))` markers linking to the finding that drove them.
- **Numbering is stable across runs.** Re-run the skill on a plan that was already reviewed and new `F#` / `R#` entries append from the highest existing ID. Resolved findings do not re-surface.
- **Verification framing is first-class.** *"Can you verify this will work?", "is this sound?",* and *"check for correctness"* all route to this skill, which treats the goal as critical evaluation rather than drafting.

## When to use it

**Invoke when:**

- You have a plan file on disk and the team wants it stress-tested, refined, tightened, or improved before implementation. *"Iterate on this plan," "refine it," "iterate for correctness,"* or the one-word command *"iterate"* when a plan is obviously in context.
- A plan has been drafted (by a human, by `/plan-implementation`, by an earlier `/investigate` session, or by ad-hoc conversation) and the team wants multiple review passes that challenge assumptions and make concrete edits to the plan file rather than producing a separate review document.
- You ask to **verify, validate, or confirm feasibility** of an approach. *"Can you verify this will work," "check this for correctness," "is this sound," "will this actually ship."* The defining signal is that you want *critical evaluation* of a proposed approach, not execution of it.
- A plan touches multiple systems or cross-cutting concerns (shared state, API contracts, database migrations, authentication, concurrency, user-facing flows) and the team wants a multi-specialist team mode review with `junior-developer`, `evidence-based-investigator`, and `adversarial-validator` at minimum, plus additional specialists sized to what the plan touches.
- The team wants each pass to produce real structural change. Not commentary, not review notes in a separate document. And wants the iteration to stop automatically once the plan converges rather than running a fixed number of passes regardless of value.
- A prior planning skill has landed a draft and the natural next step is hardening it. `/plan-implementation` produces a committable plan and this skill iterates on it. `/investigate` produces a fix approach and this skill stress-tests it before the fix is executed.

**Do not invoke for:**

- **Implementing plan steps.** This skill refines and stress-tests plans. It does not execute them. When the plan is ready, hand it to the implementation phase.
- **Generating new plans from scratch.** Use `/plan-a-feature` for a new behavioral specification or `/plan-implementation` for a new implementation plan. This skill improves a plan that already exists.
- **Writing test plans.** Use `/test-planning` to produce a standalone test plan. This skill does not generate one, though it may surface test gaps when iterating on a plan that fails to address testing.
- **Code review.** Use `/code-review` for correctness, style, and maintainability review of committed or pending code, or `/post-code-review-to-pr` to post the review to a GitHub PR. This skill reviews plans, not code diffs.
- **Bug investigation.** Use `/investigate` for evidence-based root-cause work on a bug or failure. This skill iterates on a plan that might come out of an investigation, not on the investigation itself.
- **Architectural analysis of existing code.** Use `/architectural-analysis` to assess coupling, cohesion, data flow, concurrency, and SOLID alignment of an already-built module. This skill iterates on a forward-looking plan, not on retrospective architectural assessment.

## How to invoke it

Run `/iterative-plan-review` directly in Claude Code. Point it at the plan file in the same message, or let the skill locate the most recent plan under `~/.claude/plans/*.md` if no path is given (Glob returns files sorted by modification time, so the most recent plan is the first result).

Give it:

1. **The plan file, strongly preferred.** A concrete path to the plan (for example, `docs/features/bulk-export/feature-implementation-plan.md` or `~/.claude/plans/my-plan.md`) is the preferred input. Without a path, the skill searches `~/.claude/plans/` for the most recently modified plan.
2. **Review mode override, optional.** The skill evaluates complexity and chooses lightweight or team mode automatically, and states the choice with justification before proceeding. If you know you want team mode regardless of apparent complexity (for example, the plan touches auth even though it looks small), say so. The skill honors explicit user requests for team mode.
3. **Team composition override, optional (team mode only).** The three required specialists (`junior-developer`, `evidence-based-investigator`, `adversarial-validator`) are always included. If you already know which additional specialists should be in the team (for example, *"include `adversarial-security-analyst` and `data-engineer`"*), name them. The skill picks three to five additional specialists by default from the roster: `user-experience-designer`, `adversarial-security-analyst`, `devops-engineer`, `on-call-engineer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `software-architect`, `system-architect`, `risk-analyst`, `test-engineer`, `edge-case-explorer`, `data-engineer`, `gap-analyzer`, `content-auditor`, `codebase-explorer`.
4. **Specific sections or concerns to emphasize, optional.** If you want the review to focus on a particular section of the plan (for example, *"pay extra attention to the rollback section"* or *"I'm worried about the concurrency story"*), say so. The skill still runs full passes but biases its attention toward named areas.

Example prompts that work well:

- `/iterative-plan-review`. *"Refine the feature plan for the new notification system."* (Skill locates the most recent plan under `~/.claude/plans/` and iterates.)
- `/iterative-plan-review docs/features/webhook-retry/feature-implementation-plan.md`. *"Stress-test this implementation plan. Team mode, please include `adversarial-security-analyst` because it touches signature verification."*
- `/iterative-plan-review`. *"Iterate on the refactoring plan for the auth module I just wrote. I'm most worried about the coupling between the auth service and the session store."*
- `/iterative-plan-review ~/.claude/plans/db-migration.md`. *"Can you verify this migration plan will work? I want the adversarial-validator to attack it hard."*
- `iterate`. When a plan is obviously in context from the prior message, the terse command is enough for the skill to locate and iterate on it.

The skill names the chosen review mode and the team composition (if team mode) in a single line with justification before the first iteration begins. If you want to correct the composition or the mode, say so and the skill adjusts.

## What you get back

The plan file edited in place, two companion files in `artifacts/` next to it, and an in-channel summary:

- The **plan file on disk, edited in place.** The skill does not produce a separate review document or a side-by-side diff file. It rewrites the plan so the committed version reflects every accepted change. Non-obvious, finding-driven edits carry inline `([F#](artifacts/review-findings.md#...))` markers so a reader can click from the edit to the finding that drove it.
- A **`## Review History` section appended to the plan**, pointing to the two companion files. This section is the only standardized structural change the skill makes to the plan itself. It records the review mode (lightweight or team), the iterations or rounds completed, the team composition and one-line justification per specialist (team mode only), a one-line summary of assumptions challenged / consolidations made / ambiguities resolved, and the open items remaining with whether each blocks implementation. All pointing into the companion files for full detail. If a prior review already populated this section, the skill appends new counts rather than overwriting.
- An **`artifacts/review-findings.md`** companion file. One `F#` entry per refuted assumption, overlap finding, ambiguity, or unhandled edge case raised across the review. Each entry records the agent that raised it (`self-review` in lightweight mode, or the specialist name in team mode), the category, the finding text, the evidence considered, the resolution, what resolved it (`Resolved by:` evidence / user input / deferred), the `R#` round it was raised in (`Raised in round:`), and the plan sections that changed in response (`Changed in plan:`). This is where the review's full record lives. The plan file references entries by ID rather than inlining them.
- An **`artifacts/review-iteration-history.md`** companion file. One `R#` entry per iteration (lightweight) or round (team). Each entry records the mode, the specialists engaged, the `F#` findings raised that pass (`Findings raised:`), the plan sections changed that pass (`Changed in plan:`), the stability assessment (lightweight iteration 3+ or team round 2+), and the next-step recommendation. This captures how the review progressed without bloating the plan.
- **Lightweight-mode details inside the findings.** Assumption verdicts (Verified / Refuted / Uncertain / Invalidated), the primary/secondary classification (when a primary is refuted, dependent secondaries collapse), overlap findings distinguishing internal overlap (redundant steps within the plan) from external overlap (steps that duplicate existing codebase patterns or utilities; consolidation proposed when overlap exceeds 80%), and ambiguity resolutions.
- **Team-mode details inside the findings.** Every specialist's output recorded as `F#` entries: assumptions refuted with counter-evidence, overlap with existing code or utilities, ambiguities needing resolution, and unhandled edge cases or failure modes. Round 2+ feeds prior findings back into agent prompts so the team does not re-raise resolved issues.
- **Contextual ambiguity questions** surfaced to you when a decision genuinely needs your judgment. Each with the impact, tradeoffs, and room for nuanced follow-up rather than binary choice. Answers flow back onto the matching `F#` entry's `Resolution:` / `Resolved by: user input` fields.
- **A final user review summary** in-channel. The plan file path, the two companion file paths, the review mode, the team composition (if applicable), the number of iterations or rounds, the findings resolved by evidence vs. user input vs. deferred, and any remaining open items. Followed by an explicit question asking whether you want further revisions on specific sections or consider the plan ready.

The three files interlock through shared IDs. Every `F#` lists the `R#` round that raised it and the plan sections that changed. Every `R#` lists the `F#` findings it produced and the sections changed. Every non-obvious plan edit carries its inline `([F#](...))` marker. The skill maintains these invariants as it writes, so cross-references stay consistent even across multiple review sessions on the same plan.

For plan folders produced before the `artifacts/` layout was introduced, the companion files may sit at the plan folder's root instead of under `artifacts/`. The skill detects the legacy layout, continues appending to the existing files rather than migrating, and uses the legacy paths in the `## Review History` section and inline markers to keep cross-references stable.

Every change written to the plan is traceable to a specific trigger: a `self-review` finding in lightweight mode, or a specialist agent finding and its evidence in team mode. The skill does not make silent edits.

## How to get the most out of it

- **Pair with `/plan-implementation` upstream.** `/plan-implementation` produces the committable implementation plan; this skill stress-tests it. Running the two in sequence is the intended flow when you want a thoroughly hardened plan before implementation, and the iteration count on this skill is usually small (1–2 rounds) when the upstream plan is already high-quality.
- **Point it at a path.** A concrete path is faster than letting the skill search `~/.claude/plans/`. It also eliminates ambiguity about which plan is being iterated when multiple are on disk.
- **Trust the mode selection.** The skill evaluates complexity and chooses lightweight or team mode with a justification. Override only when the apparent complexity understates the real risk (for example, a three-file plan that happens to touch auth or data migration). Running team mode on a simple plan burns tokens; running lightweight mode on a complex plan misses the cross-cutting review the team provides.
- **Name the specialists you know you want.** If the plan touches security, data, or operations, naming `adversarial-security-analyst`, `data-engineer`, or `devops-engineer` explicitly ensures they are included regardless of what the skill's heuristic selection would have picked. The three required specialists (`junior-developer`, `evidence-based-investigator`, `adversarial-validator`) are always there.
- **Fewer additional specialists is usually better.** The team always has `junior-developer`, `evidence-based-investigator`, and `adversarial-validator`. Adding three more on top of those is usually enough. Going to five additional specialists is appropriate for cross-cutting plans but produces more findings to reconcile per round.
- **Let the iteration stop early.** The skill's stability assessment is designed to stop iterating when additional passes would only produce cosmetic changes. Trust the stop. If the plan isn't converging within the size-based cap (1 iteration for small, 2 for medium, 3 for large), the real problem is scope or decomposition, not iteration count.
- **Answer surfaced ambiguities succinctly.** The skill surfaces ambiguity as contextual questions with impact, tradeoffs, and room for nuanced follow-up. Accept or amend the implied recommendation. Do not re-litigate from scratch. The skill will not re-surface resolved questions in later rounds (team mode feeds prior-round findings back in so agents don't re-raise them).
- **Re-run after major plan rewrites.** If the plan is substantially rewritten between iterations (for example, the scope changes, a new section is added, a fundamental decision reverses), re-run the skill. The companion `artifacts/review-findings.md` and `artifacts/review-iteration-history.md` files capture the prior review sessions. The new run reads them, continues `F#` / `R#` numbering from the highest existing ID, and avoids re-raising resolved issues.
- **Use *"verify this will work"* framing when that's the intent.** The skill explicitly handles verification and feasibility-check requests (*"is this sound," "can you validate this," "check for correctness"*). Phrasing the request that way (rather than *"review this plan"*) ensures the skill treats the goal as critical evaluation rather than drafting, and surfaces open items as first-class output.

## Sizing

Size determines whether the skill runs lightweight (checklist-based, no sub-agents) or team mode (multi-specialist parallel review), and caps the iteration depth. The skill defaults to small (lightweight) and only escalates when concrete signals require it.

| Size | Files | Other signals | Mode | Team cap | Round cap |
|---|---|---|---|---|---|
| **Small** *(default)* | 2–3 files | Single system; no cross-cutting concerns. | Lightweight (no sub-agents) | n/a (self-review only) | 1 |
| **Medium** | 3–5 files | One or two adjacent systems; may touch a single cross-cutting concern (for example, one API contract or one new permission check). | Team | 3–4 | 2 |
| **Large** | More than 5 files | Multiple systems; architectural changes; security or data implications; or you explicitly request full agent review. | Team | 4–5 | 3 |

How the size is chosen:

- **Default to small.** Unless the plan touches multiple systems or cross-cutting concerns, the skill stays at small and runs the checklist-based lightweight loop in-process.
- **Required team roster.** When team mode is selected, three specialists are always in the room: `junior-developer`, `evidence-based-investigator`, `adversarial-validator`. The size cap sets the upper bound on additional specialists chosen by signal.
- **Early stopping inside the cap.** The round cap is the upper bound, not a target. The skill stops earlier when stability assessment shows the next pass would only produce cosmetic changes.

How to override the size:

- Pass `small`, `medium`, or `large` as the first positional argument: `/iterative-plan-review medium docs/plans/refactor-cache.md`.
- Promoting from small to team mode pulls in the required team roster automatically.
- Conversational overrides (*"run team mode anyway, the plan touches auth"*) still work and are equivalent.

For the cross-skill sizing model and design principles, see [Sizing](../sizing.md).

## Cost and latency

The skill orchestrates either a checklist-based iteration loop (lightweight mode) or a multi-round team conversation (team mode), with caps on both to prevent runaway cycles.

Lightweight mode runs in-process against the plan file: each iteration reads the plan, evaluates assumptions, checks overlap with codebase searches (Grep/Glob), surfaces ambiguities, and writes edits. No sub-agents are dispatched. Cost is roughly equivalent to a focused in-model loop plus codebase reads per iteration. The iteration cap is five, with early stopping based on the stability assessment starting at iteration 3.

Team mode dispatches three required specialists (`junior-developer`, `evidence-based-investigator`, `adversarial-validator`) plus three to five additional specialists in parallel per round. Each round fans out to six to eight sub-agents concurrently, collects verbatim output, consolidates findings, and writes edits to the plan. Round 2+ feeds prior-round findings into agent prompts so agents do not re-raise resolved issues. Sub-agent model selection follows each agent's own default (most han analysis agents default to `sonnet`; exceptions follow their own definitions). For a medium-complexity plan in team mode, expect two rounds (roughly twelve to sixteen sub-agent dispatches plus consolidation and edit passes). The round cap is four, with early stopping based on the stability assessment starting at round 2.

The skill is designed for plan-hardening cadence (once per plan, occasionally re-run after major rewrites), not for tight-loop iteration on the same plan within a single session. If a plan is churning across many iterations, the issue is usually scope or decomposition, not review count.

## In more detail

The skill's input is a plan document on disk (a feature implementation plan, migration plan, refactoring plan, fix plan, or any other structured work plan the team is preparing to execute) and its output is the same file after assumptions have been challenged, overlap has been identified, ambiguities have been surfaced, and concrete structural changes have been made. Two companion files (`artifacts/review-findings.md` and `artifacts/review-iteration-history.md`) capture every `F#` finding raised and every `R#` round run without cluttering the plan itself.

**Lightweight mode** runs a checklist-based iteration loop: Assumptions (primary/secondary), Overlap Check (internal and external to the codebase), Changes Made, Ambiguity Surfaced, and a Stability Assessment starting at iteration 3. No sub-agents are dispatched.

**Team mode** runs parallel rounds of specialist review. Three specialists are always in the room: `junior-developer` for generalist stress-testing, `evidence-based-investigator` for codebase grounding, `adversarial-validator` for counter-evidence. Three to five additional specialists are chosen to match what the plan touches: security, data, UX, DevOps, architecture, concurrency, testing. Round 2+ feeds prior findings back into agent prompts so agents don't re-raise resolved issues.

Plan folders produced before the `artifacts/` layout was introduced may have these companions at the folder root instead. The skill detects that layout and continues appending to the existing files rather than migrating.

## YAGNI

YAGNI is a first-class review pillar alongside correctness, completeness, risk, and feasibility. Every committed item in the plan under review (every step, abstraction, infrastructure addition, observability hook, configuration knob, test, ADR, or coding standard) must cite acceptable evidence that it is needed *now*. Items without evidence raise a `Category: YAGNI candidate` finding. Resolution paths are: cite the missing evidence (finding closes), replace with a strictly simpler version (the larger version moves to deferred), or move to `## Deferred (YAGNI)` with a named *reopen-when* trigger. Anti-patterns from the named list (single-implementation interfaces, runbooks for alerts that have never fired, indexes for queries that don't run, and so on) force a finding regardless of severity rules.

See [YAGNI](../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.

Evidence quality is a first-class review pillar alongside YAGNI. The companion [evidence rule](../evidence.md) characterizes how strong the evidence is once YAGNI has gated inclusion: name the trust class of each citation a plan item rests on (codebase, web, provided); apply the corroboration gate to web-source claims that drive a recommendation (single-source web claims get marked and cannot stand alone); label claims with no evidence at any tier as a distinct state rather than treating them as weak evidence. The proximity-to-origin principle is a heuristic, not a strict tier list; findings should not be raised purely because a plan item cites docs instead of running code.

## Sources

The skill's posture and protocols draw on established practice in iterative refinement, adversarial review, and evidence-based planning. Each source below is cited because the skill draws specific, named artifacts from it. Not as a reading list, but as the provenance of the stance the skill takes.

### Iterative and Incremental Development

The skill's loop (rounds of review plus facilitated edits until convergence, capped at four or five iterations) draws on the broader iterative-and-incremental tradition documented by Craig Larman and Victor Basili and embedded in every modern Agile framework. Iteration gives review input the chance to influence later review input (a finding from `adversarial-validator` in round 1 may sharpen what `evidence-based-investigator` looks for in round 2). The cap prevents runaway cycles when review has plateaued. The stability-assessment gate stops iteration early when further passes would only produce cosmetic change.

URL: https://ieeexplore.ieee.org/document/1204375

### The Five Whys and Root-Cause Discipline

Root-cause analysis via repeated "why" questioning, popularized at Toyota and adopted widely in software and design practice, underpins the skill's assumption-evaluation step. The skill's iteration checklist classifies assumptions as primary (stand on their own) or secondary (depend on primaries), and requires primaries to be evaluated first. When a primary is refuted, dependent secondaries collapse without independent evaluation. This is the Five Whys applied to plan assumptions: a refutation at the root propagates through the tree, so cosmetic debate about a dependent assumption does not paper over the real problem at the parent.

URL: https://www.toyota-industries.com/company/history/toyoda_precepts/

### Adversarial Review and Devil's Advocate Practice

Adversarial review (deliberately assigning the role of "the case against" to a reviewer so the plan's weaknesses surface before execution) traces to military red-teaming, Roman Catholic *Advocatus Diaboli* practice, and modern decision-analysis literature (for example, Klein's pre-mortem). The skill enforces this through team mode's required roster: `adversarial-validator` assumes the plan will fail and searches for counter-evidence, and `junior-developer` reframes the plan in plain language to surface assumptions a specialist might miss. The three required specialists (`junior-developer`, `evidence-based-investigator`, `adversarial-validator`) are the red team. Adding domain specialists deepens the attack surface.

URLs: https://hbr.org/2007/09/performing-a-project-premortem and https://en.wikipedia.org/wiki/Red_team

### Gojko Adzic: Specification by Example

Adzic's *Specification by Example* formalizes the practice of grounding specifications and plans in concrete, testable examples and evidence drawn from real scenarios rather than abstract claims. The skill's overlap check and assumption evaluation reflect this discipline: assumption verdicts must cite code, docs, or existing patterns; overlap findings must reference specific utilities or prior work in the codebase; and vague claims (*"this assumes the API returns JSON"*) are not actionable until grounded in a concrete file and line (*"the API handler at `src/api/handler.go:47` returns XML, not JSON"*).

URL: https://gojko.net/books/specification-by-example/

### Rubber-Duck Debugging (Hunt and Thomas)

Andy Hunt and Dave Thomas's "rubber duck" practice (explaining a problem out loud in plain language to surface the gaps in your own reasoning) informs the skill's `junior-developer` role in team mode. When the specialist findings get technical and the trade-offs get entangled, `junior-developer` reframes the question in plain terms a generalist would ask, which frequently exposes an unstated assumption or a simpler question the team can answer without escalating to you. The rubber duck applied to plan review is the resolution step that turns "escalate to user" into "resolve inside the team."

URL: https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/

### Acceptance Criteria and Definition of Done

Acceptance criteria and Definition of Done are the standard project-management artifacts for making "done" testable rather than subjective. The skill's stability assessment encodes this discipline: iteration continues only if the next pass has at least an 80% chance of producing a *meaningful structural* improvement, and cosmetic changes (rewording, reformatting) explicitly do not count. The skill stops when the plan meets its implicit definition of done: evidence-grounded assumptions, documented overlap, resolved ambiguities, and no further structural improvement available.

URLs: https://www.atlassian.com/work-management/project-management/acceptance-criteria and https://www.projectmanager.com/blog/acceptance-criteria-project-management

### RAID Log and Decisions Log

The RAID log (Risks, Assumptions, Issues, Decisions) and the Agile-era decision log are the standard project-management artifacts for recording the *what* and the *why* of a decision so a future reader can reopen it cleanly if evidence changes. The skill's iteration summary section encodes these directly into the plan: assumptions challenged with evidence, consolidations made, ambiguities resolved and how, and open items remaining with block/non-block classification. Every edit records the trigger (checklist section in lightweight, agent finding in team mode), so the plan carries its own review history forward.

URLs: https://asana.com/resources/raid-log and https://projectmanagementcompass.substack.com/p/building-decision-logs-that-protect

## Related documentation

- [Plugin landing page](../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Evidence](../evidence.md). The companion review pillar. Trust classes, the corroboration gate for web-source claims, and the no-evidence label.
- [Skills Index](./README.md). All skills, grouped by purpose.
- [Sizing](../sizing.md). The cross-skill sizing model. Explains the small / medium / large bands, the default-to-small rule, and the `$size` override.
- [`/plan-a-feature`](./plan-a-feature.md). The upstream skill for producing a feature specification from scratch. This skill can iterate on that spec, but the typical handoff is spec → `/plan-implementation` → this skill.
- [`/plan-implementation`](./plan-implementation.md). The upstream skill for producing a committable implementation plan. This skill is the natural next step when the team wants the implementation plan stress-tested across multiple review passes.
- [`junior-developer`](../agents/junior-developer.md). The generalist stress-tester the skill always includes in team mode.
- [`software-architect`](../agents/software-architect.md). Engaged in team mode when the plan contains intra-codebase refactoring, module/class/interface decisions, or SOLID-grounded recommendations. Excluded from the default roster in spec-aware mode.
- [`system-architect`](../agents/system-architect.md). Engaged in team mode when the plan crosses a service or bounded-context seam (context-map relationships, integration patterns, data ownership, failure-domain containment). Excluded from the default roster in spec-aware mode.
- [iteration-checklist.md](../../han.core/skills/iterative-plan-review/references/iteration-checklist.md). The lightweight-mode checklist used from iteration 1 through 5.
- [multi-agent-economics.md](../guidance/agent-building-guidelines/multi-agent-economics.md). Why team mode is reserved for plans with cross-cutting concerns and why the team size is capped.
- [skill-decomposition.md](../guidance/skill-building-guidance/skill-decomposition.md). Why this skill owns the "iterate on a plan" slice and hands off to sibling skills.

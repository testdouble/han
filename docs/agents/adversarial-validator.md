# adversarial-validator

Operator documentation for the `adversarial-validator` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/adversarial-validator.md`](../../han.core/agents/adversarial-validator.md).

> See also: [Plugin landing page](../../README.md) · [All agents](./README.md) · [All skills](../skills/README.md)

## TL;DR

- **What it does.** Assumes investigation evidence is wrong and the planned fix will fail. Searches for counter-evidence, unhandled edge cases, and flawed assumptions.
- **When to dispatch it.** An investigation has produced a root cause and a fix plan, and you want the analysis adversarially validated before code lands. Always dispatched by `/investigate`. Required by `/gap-analysis` swarms at every size (which run by default) and by `/iterative-plan-review` team mode.
- **What you get back.** Numbered `V#` validation items, each with a strategy, hypothesis, investigation steps, result (Confirmed / Refuted / Partially Refuted), and an impact statement. Plus a confidence assessment and remaining risks.

## Key concepts

- **Default posture: everything is wrong until proven right.** The agent assumes the investigation reached the wrong conclusion and the fix will fail. The work is to *try to disprove* the analysis, not confirm it.
- **Four strategies, three always required.** Challenge the evidence, challenge the fix, challenge the assumptions — the agent must attempt all three. A fourth, challenge the evidence-gathering integrity, applies whenever the inputs include gathered evidence, external sources, or research artifacts (always for an investigation evidence summary or a research run): was any item planted, injected, astroturfed, stale, or single-sourced. Skipping an applicable strategy makes the validation incomplete.
- **Counter-evidence has the same rigor as evidence.** A refutation requires the same `file_path:line_number` plus snippet plus reasoning that the original investigation required. *"Looks wrong"* is not a refutation.
- **Stale-evidence check is mandatory.** The agent verifies that cited files and line numbers still match the codebase. Evidence from an old branch is not evidence.
- **Confidence assessment is not optional.** Every run closes with a High / Medium / Low confidence level and a rationale grounded in what the validation found.

## When to use it

**Dispatch when:**

- An investigation has produced a root cause analysis and a planned fix, and you want it challenged before code is written. `/investigate` dispatches this agent automatically.
- A gap analysis has produced gaps with claimed evidence and you want each gap challenged for confirmability. `/gap-analysis` dispatches this agent by default at every swarm size.
- An iterative plan review is in team mode and you want the plan's assumptions attacked. `/iterative-plan-review` dispatches this agent in team mode.
- A team member has proposed a fix or change and you want a second adversarial opinion before merging.
- A high-stakes incident response is winding down and you want to confirm the post-mortem's root cause and remediation hold up under challenge.

**Do not dispatch for:**

- Discovering the root cause in the first place. Use `evidence-based-investigator` or `/investigate`.
- Drafting a fix or plan. Use `/plan-implementation` or write the plan yourself; this agent validates plans, it does not write them.
- Code review. Use `/code-review` for correctness, style, and compliance. The validator focuses on whether the *reasoning* holds, not whether the code is clean.
- Architectural assessment. Use `/architectural-analysis`. The validator does not synthesize architectural recommendations.
- Self-evaluation of an agent's own output. The validator must run against another agent's output, not its own.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:adversarial-validator`. Give it:

1. **The evidence summary.** The full numbered evidence list from the investigation (`E1, E2, …`) or the gap list from a gap analysis (`G-NNN`).
2. **The root cause analysis.** A short statement of the root cause the investigation reached.
3. **The planned fix.** Per-file changes, function signatures, logic adjustments. Without a planned fix the agent cannot attack what is going to ship.
4. **Project context, optional.** Coding standards, ADRs, framework conventions the fix should respect.

Example prompts:

- *"Validate this investigation: [paste evidence summary, root cause, and planned fix]. Try to break the fix and find unhandled edge cases."*
- *"Adversarially validate the gap analysis at `gap-analysis-source.md`. For each gap, search the current state for counter-evidence."*
- *"The team is about to ship this auth-rotation plan. Challenge the assumptions before we commit."*

## What you get back

- A minimum of 5 numbered `V#` validation items spread across the applicable strategies (Challenge the Evidence, Challenge the Fix, Challenge the Assumptions, and — when the inputs include gathered or external evidence — Challenge the Evidence-Gathering Integrity). Each item names the strategy, the hypothesis under test, what was investigated (files read, commands run, greps performed), the result (Confirmed / Refuted / Partially Refuted), and the impact.
- A **Confidence Assessment** (High / Medium / Low) with a rationale that points at the validation items behind the call.
- A **Remaining Risks** section listing known unknowns, areas not fully validated, and assumptions the agent could not verify.

Every refutation includes counter-evidence at the same rigor as the original investigation. Every confirmation includes what was checked and why it supports the finding.

## How to get the most out of it

- **Feed it the full evidence list, not a summary.** The agent attacks evidence item by item. A summary collapses the attack surface.
- **Include the planned fix in detail.** Without per-file changes and signatures the agent cannot run the fix-blast-radius checks (searching for callers, hunting for race conditions, verifying error paths).
- **Run it before, not after, implementation.** The whole point is to catch flawed reasoning before code lands. Re-running it after a fix has shipped is a different exercise (post-mortem confirmation).
- **Take refutations seriously.** A refuted evidence item is the most valuable output the agent produces. It means the original investigation was wrong at that point and the fix likely would have shipped a wrong answer.
- **Honor the confidence level.** When confidence is Medium or Low, the agent has flagged that something is unresolved. Push back on the original investigation rather than overriding the validator.

## Cost and latency

The agent runs on `sonnet`. A single validation pass typically runs in a few minutes (scope-dependent). The agent is designed to run once per investigation or gap analysis, not iteratively. If validation surfaces a refutation, fix the underlying investigation and re-run end-to-end rather than asking the validator to re-validate its own findings.

## Sources

The agent's posture and protocols draw on falsification-first scientific method and the broader red-team / pre-mortem tradition.

### Karl Popper: Falsificationism

Popper's argument that scientific claims are only meaningful if they can be falsified shapes the agent's posture. The agent's job is to attempt falsification of every claim, not to gather confirmation.

URL: https://plato.stanford.edu/entries/popper/

### Gary Klein: Pre-Mortem

Klein's pre-mortem technique (imagining the plan has failed and asking why, before it ships) maps directly to the agent's `Challenge the Fix` strategy. Assume the fix will fail; hunt for why.

URL: https://hbr.org/2007/09/performing-a-project-premortem

### Red Teaming

The military and intelligence tradition of red teaming (deliberately assigning the role of "the case against" to a reviewer) underpins the agent's structural opposition to whatever it is reviewing. Adversarial review is a discipline, not an attitude.

URL: https://en.wikipedia.org/wiki/Red_team

## Related documentation

- [Plugin landing page](../../README.md). The front door.
- [Agents Index](./README.md). All agents, grouped by role.
- [`evidence-based-investigator`](./evidence-based-investigator.md). The sibling agent the validator usually attacks. Investigators gather, validators falsify.
- [`/investigate`](../skills/investigate.md). Always dispatches this agent after the fix plan is drafted.
- [`/gap-analysis`](../skills/gap-analysis.md). Required swarm role at every size. The swarm runs by default.
- [`/iterative-plan-review`](../skills/iterative-plan-review.md). Dispatches this agent in team mode.
- [agent-domain-focus.md](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/agent-domain-focus.md). Why the agent uses precise falsification vocabulary and named anti-patterns.
- [multi-agent-economics.md](../../han.plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md). Why this agent is the canonical second-opinion pattern across the plugin.

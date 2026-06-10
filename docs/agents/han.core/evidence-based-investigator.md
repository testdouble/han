# evidence-based-investigator

Operator documentation for the `evidence-based-investigator` agent in the han plugin. This document helps you decide *when* and *how* to dispatch the agent. For what the agent does internally, read the agent definition at [`han.core/agents/evidence-based-investigator.md`](../../../han.core/agents/evidence-based-investigator.md).

> See also: [Plugin landing page](../../../README.md) · [All agents](../README.md) · [All skills](../../skills/README.md) · [Evidence](../../evidence.md)

## TL;DR

- **What it does.** Gathers concrete, verifiable evidence about a codebase issue. File paths, line numbers, code snippets, error messages, git history, test coverage. Every claim is backed by an artifact you can open and read.
- **When to dispatch it.** A bug, failure, or unexpected behavior needs evidence-based root-cause work. Always dispatched by `/investigate` (often two or more in parallel from different angles). Dispatched by `/gap-analysis` swarms (which run by default) to verify each gap against current state, whenever the current state is concrete. Dispatched by `/iterative-plan-review` team mode for codebase grounding.
- **What you get back.** Numbered `E#` evidence items, each with source (path, line, or git commit), verbatim code or error in a fenced block, and a relevance note connecting the evidence to the issue.

## Key concepts

- **Evidence, not solutions.** The agent gathers facts. It does not propose fixes. That separation keeps investigation honest: the fix is designed against the gathered evidence, not built around a pre-decided answer.
- **Canonical evidence rule applies.** The agent reads the canonical [evidence rule](../../evidence.md) at runtime. Codebase findings carry the trust-class label "codebase" and stand on their citation. Web-source context (RFCs, vendor docs, third-party explanations) carries the trust-class label "web" and is subject to the corroboration gate before driving a conclusion. When the investigation hits a question no evidence at any tier resolves, the agent labels the no-evidence state rather than fabricating an answer.
- **Multi-angle by design.** `/investigate` typically dispatches two or more investigators in parallel, each from a different angle (the error path, the data flow, recent commits). Their evidence merges into a unified `E#` list.
- **Negative results count.** When an angle is searched and finds nothing, the agent reports *"searched X, found no evidence."* That signal is part of the investigation.
- **All five protocols are required.** Direct evidence search, code-path tracing, related-system identification, git history check, test-coverage examination. Skipping a protocol makes the investigation incomplete.
- **Symptom is not cause.** The agent traces backward from symptoms. Reporting the visible symptom as the root cause without further tracing is the canonical anti-pattern.

## When to use it

**Dispatch when:**

- `/investigate` is running. The skill dispatches this agent (usually two or more in parallel) as its primary evidence-gathering step.
- `/gap-analysis` is running with the swarm (the default). The skill dispatches this agent to verify each gap against the current state with file-level evidence whenever the current state is concrete (codebase, document on disk, fetchable URL).
- `/iterative-plan-review` is in team mode. The skill dispatches this agent for codebase grounding of assumptions in the plan.
- You want a structured evidence pass on a specific bug, integration failure, or unexpected behavior independent of a full investigation skill.
- An incident postmortem needs evidence-grounded reconstruction of what happened in the code.

**Do not dispatch for:**

- Proposing fixes or root-cause hypotheses. The agent gathers evidence; `/investigate` and downstream agents propose the fix.
- Validating a fix. Use `adversarial-validator` (which attacks both evidence and fix).
- Architectural analysis. Use the architectural analysts.
- Coverage gap analysis. Use `test-engineer`.
- Documentation preservation audits. Use `content-auditor`.

## How to invoke it

Dispatch via the `Agent` tool with `subagent_type: han.core:evidence-based-investigator`. Give it:

1. **The symptom or issue.** What is observed: error message, unexpected value, failed deploy, intermittent timeout. The more concrete, the sharper the search.
2. **An angle of investigation.** *"Trace the error path,"* *"follow the data flow,"* *"check recent commits."* This lets you dispatch multiple investigators in parallel without overlap.
3. **Reproduction context, optional.** Environment, branch, specific data, recent deploy. Helps the agent scope the git checks.

Example prompts:

- *"Investigate why webhook deliveries are failing intermittently. Trace the data flow from inbound POST to the delivery worker. Report numbered `E#` evidence."*
- *"Examine the error path for the stale-data bug in user profiles. Check git history for changes in the last 90 days under `src/users/`."*

## What you get back

- Numbered `E#` evidence items, each with: source (path:line or git commit), verbatim code or error in a fenced block, and a relevance note connecting the evidence to the issue.
- Negative results explicitly listed (*"searched `src/auth/` for token rotation paths, found none."*).
- No proposed fix. The agent stops at evidence.

## How to get the most out of it

- **Dispatch multiple investigators in parallel.** Different angles surface different evidence. `/investigate` dispatches at least two for this reason.
- **Name the angle.** *"Error path,"* *"data flow,"* *"recent commits"* prevents two investigators from doing the same work.
- **Drop in real artifacts.** Production log excerpts, stack traces, alert payloads. The agent reads the codebase but cannot see your production observability.
- **Trust the negative results.** *"Searched and found nothing"* is real signal. It usually means the assumption that drove the search was wrong.
- **Feed the output to `adversarial-validator`.** That is the canonical second-opinion pattern. The investigator gathers; the validator attacks.

## Cost and latency

The agent runs on `sonnet`. A single investigation pass runs in a few minutes. The cost scales with the number of investigators dispatched in parallel (typically two to four for a complex bug).

## Sources

The agent's protocols are grounded in established root-cause analysis and debugging practice.

### Toyota Production System: The Five Whys

Root-cause analysis via repeated *"why"* questioning. The agent applies a softer version: every claim of a root cause must trace back to at least one piece of `E#` evidence.

URL: https://www.toyota-industries.com/company/history/toyoda_precepts/

### Hunt and Thomas: Rubber-Duck Debugging and Bisection

The Pragmatic Programmer formalized bisection as a debugging discipline. The agent's parallel-angle dispatch is evidence-bisection applied at the agent level.

URL: https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/

### John Allspaw: Blameless Post-Mortems

Allspaw's work at Etsy reframed incident analysis around understanding cause rather than assigning blame. The agent's evidence-only posture follows directly: findings cite code and behavior, never people.

URL: https://www.etsy.com/codeascraft/blameless-postmortems

## Related documentation

- [Plugin landing page](../../../README.md). The front door.
- [Agents Index](../README.md). All agents, grouped by role.
- [`adversarial-validator`](./adversarial-validator.md). The canonical pairing. Investigator gathers, validator attacks.
- [`codebase-explorer`](./codebase-explorer.md). Sibling agent for general codebase discovery (not bug-focused).
- [`/investigate`](../../skills/han.core/investigate.md). Always dispatches this agent (usually two or more in parallel).
- [`/gap-analysis`](../../skills/han.core/gap-analysis.md). Required swarm role when the current state is concrete. The swarm runs by default.
- [`/iterative-plan-review`](../../skills/han.core/iterative-plan-review.md). Dispatches this agent in team mode.
- [Evidence](../../evidence.md). The canonical evidence rule the agent reads at runtime. Trust classes, the corroboration gate for web sources, and the no-evidence label.

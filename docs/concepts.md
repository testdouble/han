# Concepts

Han is built out of two kinds of things: **skills** and **agents**. If you read this page once before you pick a slash command, the rest of the documentation will make sense.

> See also: [Plugin landing page](../README.md) · [Quickstart](./quickstart.md) · [All skills](./skills/README.md) · [All agents](./agents/README.md)

## TL;DR

- A **skill** is a deterministic process you run with a slash command (like `/code-review`). Think: flowchart.
- An **agent** is a specialist persona with judgment, dispatched by a skill or by you (like `adversarial-security-analyst`). Think: teammate.
- Skills dispatch agents. The skill follows its flowchart, sends the agent off to do a judgment-heavy subtask (investigate a bug, review architecture, critique a plan), then folds the finding back into its output.
- **Sizing** decides how many agents get dispatched. The skills that fan out to a swarm classify the work as small, medium, or large first, default to small, and scale the team and the iteration depth from there. See [Sizing](./sizing.md) for the full model.
- **YAGNI** decides what survives. Every skill that produces an artifact and every agent that reviews one applies an evidence-based rule before committing items: features, plan steps, code recommendations, ADRs, coding standards, runbooks, alerts, indexes, tests, abstractions. Items without evidence get deferred (recorded for later, not silently dropped). See [YAGNI](./yagni.md).

That is the whole model. Everything else is vocabulary.

## Skills: the process layer

A skill is a fixed sequence of steps that Claude Code runs when you type its slash command.

- You invoke it: `/code-review`, `/plan-a-feature`, `/investigate`.
- It follows a defined protocol. Every reader who runs the same skill gets the same shape of output.
- It is documented by a `SKILL.md` file inside `plugin/skills/{name}/`.
- It may dispatch one or more agents for the steps that need judgment.

**The test:** could you draw the whole thing as a flowchart? If yes, it is a skill.

## Agents: the judgment layer

An agent is a specialist teammate. A model with a persona, a narrow domain, and an explicit posture.

- An agent has a name like `adversarial-security-analyst`, `project-manager`, or `junior-developer`.
- An agent applies contextual judgment. *Is this finding really a problem? Does the plan address the risk? Should we ask another specialist?*
- An agent is documented by a single `.md` file inside `plugin/agents/`.
- You can dispatch an agent directly with the `Agent` tool, but most agents get dispatched *for you* when a skill needs their input.

**The test:** does this require reasoning about context rather than following a script? If yes, it is an agent.

## How they compose

A skill runs its protocol and, at the steps that need judgment, dispatches an agent. The agent returns findings; the skill folds them into the final output.

```
You → /plan-a-feature → (interview loop, codebase discovery)
                     → dispatches → junior-developer
                                  → project-manager
                                  → 3-5 specialist agents
                     ← folds findings back in
      ←  feature-specification.md, decision-log.md, team-findings.md
```

A few concrete pairings from the han plugin:

- **`/plan-a-feature` dispatches `junior-developer` and `project-manager` plus three to five specialists.** The specialists are chosen based on what the feature touches. A data-heavy feature brings in `data-engineer`. A feature with a production surface brings in `devops-engineer`. A user-visible flow brings in `user-experience-designer`.
- **`/code-review` always dispatches `junior-developer` and `adversarial-security-analyst`, plus the rest of the roster conditionally** (`test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `devops-engineer`) based on what the changed files touch. The roster scales with the [size](./sizing.md): a small change runs the minimum roster; a large change runs the full conditional roster. Each agent reviews the branch changes from its own lens, and the skill classifies their findings into the review output.
- **`/architectural-analysis` always dispatches a spine of `structural-analyst`, `behavioral-analyst`, `risk-analyst`, and `software-architect`, plus the rest of the roster by signal** (`concurrency-analyst` when concurrency primitives are present; `adversarial-security-analyst`, `data-engineer`, `devops-engineer` when the focus area touches auth/PII, data contracts, or operational surface; `codebase-explorer` for large unfamiliar areas; `system-architect` at large size when a cross-service or bounded-context seam is present). The roster scales with the [size](./sizing.md): small runs the spine plus concurrency; large runs every signalled specialist. The discovery analysts run first, `risk-analyst` scores their findings, and the architects synthesize. When `system-architect` is not dispatched, cross-service and bounded-context concerns are surfaced as deferred so you can dispatch it separately.
- **`/investigate` dispatches `evidence-based-investigator` plus conditional specialists** (`concurrency-analyst`, `behavioral-analyst`, `data-engineer`) based on the symptom, and follows up with `adversarial-validator` to prove the proposed fix will fix the bug rather than mask it.
- **`/gap-analysis` dispatches `gap-analyzer` once for the primary analysis, then fans out a validator-and-augmenter swarm by default.** `adversarial-validator` and `junior-developer` (running an explicit actor-perspective sweep across human users, API callers, AI agents, and other actor types) are required at every size; `evidence-based-investigator` is required when the current state is concrete; `project-manager` is required at medium and large to consolidate Section 4 of the report. Domain specialists (`adversarial-security-analyst`, `data-engineer`, `user-experience-designer`, and others) are added based on what the gaps touch. Reply `no swarm` to opt out and fall back to a lightweight gap-analyzer-only pass.
- **`/plan-a-phased-build` dispatches `information-architect` once at runtime** against the rendered build-phase outline, to verify findability, EPPO standalone-ness of phase entries, and progressive comprehension before presenting the document to you. The skill applies plain-language leak findings as required edits, and structural findings when they preserve the document's contract.

You do not need to memorize these pairings to run a skill. You do need to know that they exist, so that when the skill's output references "finding from `project-manager`" or "the architectural analysts flagged coupling," you know what that means.

## Sizing: the dispatch lever

Every skill that dispatches an agent swarm classifies the work as **small**, **medium**, or **large** before dispatching, then uses the band to cap the team or swarm size, the iteration depth, and the severity bands the agents escalate.

- **Default is small.** Every sizing-aware skill starts the classification at small and only escalates when concrete signals require it.
- **Auto-classified, with a `$size` override.** Skills read signals (file count, subsystems touched, security/data/infra surface) and announce the chosen size with a one-line justification. Pass `small`, `medium`, or `large` as the first positional argument to override (`/code-review medium`, `/plan-a-feature large "describe the feature"`).
- **Seven sizing-aware skills.** [`/architectural-analysis`](./skills/architectural-analysis.md), [`/code-review`](./skills/code-review.md), [`/gap-analysis`](./skills/gap-analysis.md), [`/iterative-plan-review`](./skills/iterative-plan-review.md), [`/plan-a-feature`](./skills/plan-a-feature.md), [`/plan-implementation`](./skills/plan-implementation.md), [`/research`](./skills/research.md).

Read the full [Sizing](./sizing.md) reference for the bands, the auto-classification process, and the per-skill rules.

## YAGNI: the inclusion gate

Every skill that produces an artifact and every agent that reviews one runs an evidence-based YAGNI rule before committing items. The rule has two gates: an evidence test (*is this needed now?*) and a simpler-version test (*is there a strictly simpler version that satisfies the same evidence?*). Items without evidence get deferred, recorded under a `## Deferred (YAGNI)` section in the artifact with a named *reopen-when* trigger. Never silently dropped.

YAGNI applies to the planning skills (`/plan-a-feature`, `/plan-implementation`, `/plan-a-phased-build`, `/iterative-plan-review`), to review and standards (`/code-review` advisory-only, `/coding-standard`, `/test-planning`, `/architectural-decision-record`), and to several agents (`project-manager`, `junior-developer`, `software-architect`, `system-architect`, `test-engineer`, `edge-case-explorer`, `data-engineer`, `devops-engineer`).

Read the full [YAGNI](./yagni.md) reference for the gates, the acceptable-evidence list, the named anti-patterns, and the per-skill / per-agent application table.

## When would you invoke an agent directly?

Most of the time you will not. A skill calling an agent is the typical flow.

You might invoke an agent directly when:

- The judgment you want is narrower than any existing skill. *"Give me a security audit of `src/auth/` with `adversarial-security-analyst`"*. No full `/code-review` needed.
- You want a second opinion after a skill has run. Dispatch `adversarial-validator` against the plan a planning skill produced.
- You are composing a custom workflow that does not match any slash command cleanly.

Direct invocation uses the `Agent` tool with `subagent_type: han:{agent-name}` (for example, `han:adversarial-security-analyst`).

## What does the plugin include?

- **20 skills.** The [skills index](./skills/README.md) groups them by purpose (planning, building, investigation and research, review, discovery, conventions, reporting).
- **23 agents.** The [agents index](./agents/README.md) groups them by role (planning and facilitation, adversarial reviewers, investigation, architecture, testing, gap and content).

Skim the indexes after you read this page. Pick the one skill you need right now. Come back later to learn the rest.

## Where to go next

- **Want to get something done?** → [Quickstart](./quickstart.md). Picks a starting skill based on what you are trying to do.
- **Want a specific skill?** → [Skills Index](./skills/README.md).
- **Want a specific agent?** → [Agents Index](./agents/README.md).
- **Want to know how dispatch scales?** → [Sizing](./sizing.md).
- **Want to know what survives a review?** → [YAGNI](./yagni.md).
- **Writing your own skill or agent?** → [Contributing](../CONTRIBUTING.md).

## Related reading

- [`docs/guidance/plugin-entity-taxonomy.md`](./guidance/plugin-entity-taxonomy.md). The taxonomy this plugin follows. Applies across all plugins in this repo.
- [Claude Code Skills reference](https://code.claude.com/docs/en/skills). How skills are defined and invoked in Claude Code itself.
- [Claude Code Subagents reference](https://code.claude.com/docs/en/sub-agents). How agents are dispatched from inside skills.

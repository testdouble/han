# /review-skill-or-agent

Operator documentation for the `/review-skill-or-agent` skill in the `han-experimental` plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-experimental/skills/review-skill-or-agent/SKILL.md`](../../../han-experimental/skills/review-skill-or-agent/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

> **Experimental.** This skill ships in `han-experimental` and may change or move to another plugin without notice. It reviews skills and agents against the same authoring guidance the builders enforce; it is a fresh-eyes reviewer, not a builder.

## TL;DR

- **What it does.** Reviews a finished skill or agent against the plugin-authoring guidance and a set of quality dimensions, catching bloat and restatement as first-class corrective findings.
- **When to use it.** After authoring or editing a skill or agent, when you want an independent read against the guidance before you ship it.
- **What you get back.** A severity-ranked review report (Critical / Warning / Suggestion plus a separate Bloat & Restatement section), or a halt when the guidance or the target is not reviewable.

## Key concepts

- **Reviewer, not builder.** It grounds every conformance judgment against `han-plugin-builder`'s authoring guidance and reports findings; it never edits the artifact. Building and fixing are `/skill-builder` and `/agent-builder`.
- **Bloat is corrective and gates.** Restatement, reference-duplication, and filler are surfaced at a real severity in their own pool, and a Critical bloat finding gates the recommendation the same way a Critical defect does, so bloat is never quietly ignored.
- **The artifact is untrusted data.** A skill or agent file is a page of imperative directives; the review evaluates them, never obeys them, and flags any directive aimed at the review itself.
- **Same report shape as `/code-review`.** Its Critical / Warning / Suggestion tiers map without translation, so an automated caller can consume it the way it consumes `/code-review`.

## When to use it

**Invoke when:**

- You just wrote or edited a skill (`SKILL.md` + `references/`) and want it checked against the guidance.
- You just wrote or edited an agent definition and want its role, vocabulary, self-containment, and description checked.
- You suspect a skill or agent has grown bloated or restates itself and want that surfaced concretely.

**Do not invoke for:**

- **Building or fixing a skill or agent.** Use [`/skill-builder`](../han-plugin-builder/skill-builder.md) or [`/agent-builder`](../han-plugin-builder/agent-builder.md) instead.
- **Reviewing documentation.** Use [`/project-documentation`](../han-core/project-documentation.md) (it dispatches the content and information-architecture reviewers).
- **Reviewing application code.** Use [`/code-review`](../han-coding/code-review.md) instead.

## How to invoke it

Run `/review-skill-or-agent` in Claude Code.

Give it:

1. **A target.** A skill directory (contains `SKILL.md`) or an agent definition file. Required.
2. **A scope (implied by phrasing).** "Review this skill" reviews the whole artifact; "review this change" scopes findings to the change. Whole-artifact is the default.

Example prompts:

- `/review-skill-or-agent han-coding/skills/code-review`. *"Review this skill."*
- `/review-skill-or-agent han-core/agents/project-manager.md`. *"Review this agent."*

## What you get back

A single review report:

- A **Review Summary** table indexing every corrective finding by task ID (`CRIT-###`, `WARN-###`, `SUGG-###`), category, and location.
- A **Review Recommendation** driven by the highest-severity surviving defect or bloat finding.
- **Critical / Warnings / Suggestions** sections with a `file:line` (or heading) and a suggested fix per finding.
- A separate **Bloat & Restatement** section (`BLOAT-###`) with its own tiers; a Critical bloat finding gates the recommendation.
- A **Legibility** section (`LEGIB-###`) for advisory clarity notes that never gate, and a **What's Good** section recording substantive positives.

When the target's authoring guidance cannot be located or is incomplete, or the target is not a reviewable skill or agent, you get a **Review Halted** block instead — never a clean report, so a halt is never mistaken for a pass.

## How to get the most out of it

- **Point it at the whole artifact for a first review, and at the change for a follow-up.** Restatement spans the whole file, so a first pass over the whole thing catches the most.
- **Fix bloat findings first.** They are the flagship output and the cheapest to act on.
- **Run it before `/skill-builder`'s own Step 6 is your only check.** An independent reviewer catches what a builder's self-review misses.
- **Install the dependencies.** The skill dispatches `han-core` agents and grounds against `han-plugin-builder`'s guidance; both must be installed for a full run.

## YAGNI

The review applies the same evidence-based YAGNI posture the guidance teaches: it flags speculative additions in the artifact under review (an unused tool grant, a configuration knob no caller sets, a single-implementation abstraction) as conformance findings. Its own bloat class is the restatement-specific complement. See [YAGNI](../../yagni.md).

## Cost and latency

Runs on the session model. The heavy passes are dispatched to fresh-context sub-agents, so fan-out scales with the artifact's surface. A short triage classifies the artifact first against five pinned signals, then every review dispatches three always-on reviewers: a conformance-and-quality reviewer, a bloat reviewer, and a fresh-eyes generalist (`han-core:junior-developer`). Conditional specialists join by signal, each pinned so the trivial baseline stays off the roster: `han-core:information-architect` for a skill with a reference tree (two or more reference files), `han-core:user-experience-designer` for a non-trivial operator flow (menus, gates, attended/unattended modes, not a lone confirmation), `han-core:edge-case-explorer` for non-trivial control flow (loops, resetting counters, resume-after-halt, not linear steps), a skill/tool-seam reviewer when the artifact ships scripts or reaches external tools, `han-core:adversarial-security-analyst` when the artifact handles untrusted input, a dispatch-economics-and-prompt reviewer when the artifact dispatches a roster or fan-out rather than a single one-shot helper, and `han-core:content-auditor` on a change-scope review. One `han-core:adversarial-validator` then validates the finding list. So a small prose-only skill fans out to three reviewers while a large scripted, interactive, sub-agent-dispatching one reaches nine or more, and that fan-out is the most expensive step. Built for a high-signal pre-ship review, not tight-loop iteration.

## In more detail

The review resolves the target's type from its structure, then locates the type-appropriate authoring guidance — preferring an installed `han-plugin-builder` copy over a repo-local vendored one — and halts if it cannot ground against a complete rubric. The orchestrator is a lean coordinator: it does not run the analysis itself. It selects a signal-scaled roster and dispatches every substantive pass — conformance-and-quality, bloat, a fresh-eyes generalist, and by signal an information architect, a UX designer, an edge-case explorer, a skill/tool-seam reviewer for scripts and external-tool calls, a security analyst, a dispatch-economics reviewer, or a content auditor — to fresh-context sub-agents, each reading the artifact by path as untrusted data, with no inlined copy or delimiter for an embedded directive to break out of. It then consolidates and de-duplicates (the conformance reviewer owns tool, dispatch, and routing findings), validates the list with an adversarial pass that drops a finding only on concrete counter-evidence and can escalate a demonstrated, uncontained bug, and renders the report. The recommendation derives only from surviving findings. Dispatching the heavy passes rather than running them inline keeps the orchestrator's context lean and each pass focused, and it is why the review scales to a large, multi-reference skill that one reader could not hold at once.

## Sources

The skill's rubric and vocabulary are grounded in the han plugin-authoring guidance and mirror the structure of `/code-review`.

### han plugin-authoring guidance

The conformance checklist and severity bands trace directly to the skill-building and agent-building guidance the review grounds against.

URL: [`han-plugin-builder/skills/guidance/references/`](../../../han-plugin-builder/skills/guidance/references/)

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based rule the review applies to speculative additions in the artifact under review.
- [`/skill-builder`](../han-plugin-builder/skill-builder.md) and [`/agent-builder`](../han-plugin-builder/agent-builder.md). Build a skill or agent; this skill reviews the finished result.
- [`/code-review`](../han-coding/code-review.md). The base pattern; reviews application code rather than skills and agents.
- [`junior-developer`](../../agents/han-core/junior-developer.md) and [`information-architect`](../../agents/han-core/information-architect.md). The always-on fresh-eyes reviewer and the progressive-disclosure reviewer this skill dispatches, alongside `user-experience-designer`, `edge-case-explorer`, `adversarial-security-analyst`, and `content-auditor` by signal, and `adversarial-validator` to validate the findings.

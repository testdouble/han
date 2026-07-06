# /issue-triage

Operator documentation for the `/issue-triage` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-core/skills/issue-triage/SKILL.md`](../../../han-core/skills/issue-triage/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Converts a raw, vague issue or bug report into a structured triage document: issue type, known behavior, missing information, severity, reproducibility, and a recommended next skill.
- **When to use it.** You have an incoming issue that is too vague or incomplete to hand directly to `/investigate` or `/plan-a-feature`.
- **What you get back.** A triage report file with a structured breakdown of the issue and a single recommended next han skill.


## Key concepts

- **Work only from what the reporter wrote.** This is the load-bearing constraint. The skill does not infer facts the report omits. If the report does not state it, the triage marks it missing rather than guessing from project context or prior knowledge. Inference would turn the triage into a hallucinated narrative instead of a record of what is known and what is absent.
- **Issue type drives the gap list.** Different issue types have different missing-information profiles. A bug needs reproduction steps and environment details. A feature request needs use case and success criteria. The skill classifies first, then determines what is absent for that type.
- **Severity is an estimate.** The skill cannot assess severity with certainty from a vague report. It makes the best judgment from what is in the report and marks severity Unknown when impact is not inferable.
- **Triage stops before investigation.** The skill does not read the codebase for root cause. It reads the report and project context only enough to suggest suspected areas. Investigation starts after triage completes.
- **The recommended next step is a single skill.** The report ends with one recommendation: the skill most appropriate to run next, given what is now known about the issue.


## When to use it

**Invoke when:**

- An incoming issue, bug report, or problem description is too vague to hand directly to `/investigate` or `/plan-a-feature`.
- A report is missing information you would need to reproduce or plan against.
- You want to classify an issue and document gaps before investigation or planning starts.
- You received a terse ticket, a one-line Slack message, or a forwarded user complaint and need a structured handoff document.


**Do not invoke for:**

- **Root cause analysis.** Use [`/investigate`](../han-coding/investigate.md) to trace symptoms to code-level evidence.
- **Feature planning.** Use [`/plan-a-feature`](../han-planning/plan-a-feature.md) when the problem is well-defined and you are ready to spec the solution.
- **Implementation planning.** Use [`/plan-implementation`](../han-planning/plan-implementation.md) when you have a feature spec and are ready to plan the build.


## How to invoke it

Run `/issue-triage` in Claude Code with the raw issue text.

Give it:

1. **The raw issue or report.** Paste the text directly: a Slack message, a GitHub issue body, a user complaint, a support ticket. The skill works from what the reporter wrote. Do not clean the text up before handing it over.
2. **An output path, optional.** Defaults to `~/.claude/triages/{kebab-case-summary}.md` if no path is given.


Example prompts:

- `/issue-triage`. *"Uploading large PDFs freezes the app sometimes. Happened to two people already."*
- `/issue-triage`. *"Users are complaining the dashboard is slow. Here's what one of them wrote: [paste]"*
- `/issue-triage docs/triages/pdf-freeze.md`. Triage the issue and write the report to a specific path.


## What you get back

A triage report file with these sections:

- **Summary.** One sentence naming the problem in plain terms.
- **Issue Type.** One of: Bug, Feature Request, Performance, Security, Regression, Question, Other.
- **Reported Behavior.** What the reporter said happened, in their words or close paraphrase.
- **Expected Behavior.** What the reporter said should happen, or Unknown if not stated.
- **Missing Information.** A list of what is absent from the report but needed to proceed. States "None - report has enough to proceed." when nothing is missing.
- **Suspected Areas.** Code or system areas the issue plausibly touches, based on the report and project context. Omitted when nothing is inferable.
- **Severity.** An estimate: Critical, High, Medium, Low, or Unknown. Omitted entirely for a feature request, question, or other issue when it is not inferable, rather than rendering Unknown noise.
- **Reproducibility.** An estimate: Always, Intermittent, Rare, or Unknown. Omitted on the same rule as Severity.
- **Recommended Next Step.** The single most appropriate han skill to run next, or "Clarify with reporter before proceeding" when critical reproduction or scope details are missing. When the gap is a problem-space unknown (which options are in play, prior art, build-vs-buy, or which direction to take), the recommendation routes to `/research` so the problem can be researched before it is specified.

## Output contract

This is the exact output contract the skill follows. It is intentionally strict to prevent inference from vague reports.

```md
# {one-sentence summary of the issue in plain terms}

## Issue Type

{Bug | Feature Request | Performance | Security | Regression | Question | Other}

## Reported Behavior

{what the reporter said happened}

## Expected Behavior

{what the reporter said should happen, or Unknown}

## Missing Information

{bulleted list, or "None - report has enough to proceed."}

## Suspected Areas

{bulleted list. Omitted entirely when nothing is inferable}

## Severity

<!-- Omitted entirely for a Feature Request, Question, or Other issue when not inferable (Step 4) -->
{Critical | High | Medium | Low | Unknown}

## Reproducibility

<!-- Omitted entirely for a Feature Request, Question, or Other issue when not inferable (Step 4) -->
{Always | Intermittent | Rare | Unknown}

## Recommended Next Step

{"Clarify with reporter before proceeding", "Answer the question directly; no han skill needed", or one of: /investigate, /research, /plan-a-feature, /plan-implementation}
```


## How to get the most out of it

- **Paste the raw text.** The skill is designed to work on incomplete, messy input. Editing the report before passing it in changes what counts as missing information.
- **Use the output as a handoff document.** The triage report is the input for the next skill. Pass it to the recommended skill (`/investigate`, `/research`, `/plan-a-feature`, or `/plan-implementation`) rather than re-summarizing the issue from scratch. The skill says so explicitly when the recommendation is a han skill; there is no separate brief to produce.
- **Run it before `/investigate` on ambiguous issues.** Investigation works best with a sharp problem statement. Triage produces one. A few seconds of triage avoids a wasted investigation run on a problem that was not yet well-defined.
- **Follow the Recommended Next Step.** When the report still has critical gaps, the recommendation will say so explicitly. That is the signal to go back to the reporter before running the next skill.

## Minimal example

Input:

```
"Uploads fail sometimes. Not sure why."
```

Output:

```md
# Uploads fail intermittently.

## Issue Type

Bug

## Reported Behavior

Uploads fail sometimes.

## Expected Behavior

Unknown

## Missing Information

- Reproduction steps
- Environment details (OS, browser, version)
- User-impact scope

## Severity

Unknown

## Reproducibility

Intermittent

## Recommended Next Step

"Clarify with reporter before proceeding"
```


## Cost and latency

The skill dispatches no sub-agents. It reads the report and, only to sharpen the Suspected Areas section, the project context (`CLAUDE.md` and `project-discovery.md` when present, with `project-discovery.md` treated as the richer system map), then produces the triage document in a single pass. Expect fast turnaround relative to investigation or planning skills. Use it at the start of any incoming issue before deciding which deeper skill to run.


## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/investigate`](../han-coding/investigate.md). The natural next skill when the issue is a bug or failure with enough context to trace.
- [`/research`](./research.md). The natural next skill when the gap is a problem-space unknown (options, prior art, build-vs-buy, or which direction to take) rather than a missing user-supplied fact.
- [`/plan-a-feature`](../han-planning/plan-a-feature.md). The natural next skill when the issue is a feature request with enough context to spec.
- [`/plan-implementation`](../han-planning/plan-implementation.md). The next skill when triage confirms a well-defined problem and a spec already exists.
- [How to provide feedback on Han](../../how-to/provide-feedback.md). Uses this skill to shape an idea or vague observation about Han into a postable GitHub issue.
- [`SKILL.md` for /issue-triage](../../../han-core/skills/issue-triage/SKILL.md). The internal process definition.
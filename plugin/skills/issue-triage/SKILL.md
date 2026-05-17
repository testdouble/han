| name | issue-triage |
| --- | --- |
| description | Triage a raw, vague issue or bug report into a structured document that names what is known, what is missing, and what to do next. Use when an incoming issue, bug report, or problem description is too vague or incomplete for investigation or planning: classify the issue type, identify missing information, assess severity and reproducibility, and recommend the right next han skill. Does not investigate root causes or trace code paths; use investigate for debugging, diagnosis, and root cause analysis. Does not plan features or build solutions; use plan-a-feature or plan-implementation for that. |
| allowed-tools | Read, Write |

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`

## Triage Approach

- Work only from what the reporter wrote. Do not infer facts that are not stated.
- Classify the issue type before doing anything else. The type drives what counts as missing information.
- Severity is an estimate based on what is known. Mark it Unknown when impact is not inferable from the report.
- The recommended next step is the single most appropriate han skill to run after triage completes.
- Read CLAUDE.md only to inform Suspected Areas. Do not use it to fill gaps the reporter did not provide.

# Issue Triage

## Step 1: Read Project Context

Read CLAUDE.md if present. Use it to identify relevant system areas when populating Suspected Areas. Do not use it to supply information the reporter omitted.

## Step 2: Classify the Issue

Determine the issue type from the report text:

- **Bug** — something is broken or behaving unexpectedly
- **Feature Request** — something new is being asked for
- **Performance** — the system is too slow, uses too much memory, or degrades under load
- **Security** — a vulnerability, exposure, or access control concern
- **Regression** — the reporter explicitly says it used to work and no longer does
- **Question** — the reporter is asking how something works, not reporting a problem
- **Other** — none of the above apply

## Step 3: Extract What Is Known

From the report, identify:

- **Summary** — one sentence describing the problem in plain terms
- **Reported Behavior** — what the reporter said happened, in their words or close paraphrase
- **Expected Behavior** — what the reporter said should happen; if not stated, mark Unknown

## Step 4: Identify Missing Information

List what a developer would need to reproduce or investigate this issue that is absent from the report. Common gaps by issue type:

- **Bug / Regression** — reproduction steps, environment (OS, browser, version), error messages or stack traces, affected data or user accounts, frequency of occurrence
- **Performance** — scale or load at which the problem occurs, baseline measurements, environment
- **Security** — affected endpoints or data, attack surface description, access level required to trigger
- **Feature Request** — use case or job to be done, success criteria, constraints

List only what is genuinely absent. Do not list information already present in the report.

If nothing is missing, write: `None — report has enough to proceed.`

## Step 5: Assess Severity and Reproducibility

**Severity** (estimate from what is known):

- **Critical** — data loss, system down, security breach, or blocks all users
- **High** — major feature broken, significant user impact, no workaround known
- **Medium** — feature degraded, workaround exists, or affects a subset of users
- **Low** — cosmetic, edge case, or minor inconvenience
- **Unknown** — not enough information to assess

**Reproducibility** (estimate from what is known):

- **Always** — happens consistently under described conditions
- **Intermittent** — happens sometimes; conditions unclear
- **Rare** — reported once or infrequently; hard to reproduce
- **Unknown** — not stated in the report

## Step 6: Identify Suspected Areas

If the report or project context points to specific system areas, list them. Examples: upload pipeline, authentication middleware, database migrations, frontend state management. If nothing in the report or CLAUDE.md points to a specific area, omit this section.

## Step 7: Write the Triage Report

Write the report to `~/.claude/triages/{kebab-case-summary}.md` unless the user specified a path.

Use this structure:

```md
# Summary

{one sentence}

# Issue Type

{type}

# Reported Behavior

{what the reporter said happened}

# Expected Behavior

{what should happen, or Unknown}

# Missing Information

{bulleted list, or "None — report has enough to proceed."}

# Suspected Areas

{bulleted list — omit section if nothing is inferable}

# Severity

{Critical | High | Medium | Low | Unknown}

# Reproducibility

{Always | Intermittent | Rare | Unknown}

# Recommended Next Step

{If any critical reproduction or scope details are missing, write "Clarify with reporter before proceeding". Otherwise choose the single most appropriate skill: /investigate, /plan-a-feature, or /plan-implementation.}
```

Present the triage report to the user.
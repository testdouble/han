---
name: issue-triage
description: >
  Triage a raw, vague issue or bug report into a structured document that names
  what is known, what is missing, and what to do next. Use when an incoming
  issue, bug report, or problem description is too vague or incomplete for
  investigation or planning: classify the issue type, identify missing
  information, assess severity and reproducibility, and recommend the right next
  han skill. Does not investigate root causes or trace code paths — use
  investigate for debugging, diagnosis, and root cause analysis. Does not plan
  features or build solutions — use plan-a-feature or plan-implementation for
  that.
argument-hint: "[issue text, bug report, or path to a report file; optional output path]"
allowed-tools: Read, Write, Bash(find *), Bash(mkdir *)
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Triage Approach

- Work only from what the reporter wrote. Do not infer facts that are not stated. This is the single most important constraint in this skill.
- Classify the issue type before doing anything else. The type drives what counts as missing information.
- Severity and reproducibility are estimates based on what is known. For a Bug, Regression, Performance, or Security issue, mark them Unknown when not inferable. For a Feature Request, Question, or Other issue, omit them entirely when they are not inferable (see Step 4) rather than rendering Unknown.
- The recommended next step is the single most appropriate han skill (or "clarify with reporter") to run after triage completes.
- Project context (CLAUDE.md, project-discovery.md) is read only to identify Suspected Areas. Never use it to supply information the reporter omitted.

# Issue Triage

## Step 0: Resolve the Issue Text

Determine the issue text from the argument:

- If the argument is a path to an existing file, read that file; its contents are the issue text.
- Otherwise the argument text itself is the issue text.
- If no argument was given and no issue text is present in the conversation, ask the reporter to paste the issue or bug report, then stop until they provide it.

## Step 1: Classify the Issue

Determine the issue type from the report text. Choose exactly one:

- **Bug** — something is broken or behaving unexpectedly
- **Feature Request** — something new is being asked for
- **Performance** — the system is too slow, uses too much memory, or degrades under load
- **Security** — a vulnerability, exposure, or access control concern
- **Regression** — the reporter explicitly says it used to work and no longer does; quote or paraphrase that statement
- **Question** — the reporter is asking how something works, not reporting a problem
- **Other** — none of the above apply

## Step 2: Extract What Is Known

From the report, identify:

- **Summary** — one sentence describing the problem in plain terms
- **Reported Behavior** — what the reporter said happened, in their words or a close paraphrase
- **Expected Behavior** — what the reporter said should happen; if not stated, mark Unknown

## Step 3: Identify Missing Information

List what a developer would need to reproduce or investigate this issue that is absent from the report. Common gaps by issue type:

- **Bug / Regression** — reproduction steps, environment (OS, browser, version), error messages or stack traces, affected data or user accounts, frequency of occurrence
- **Performance** — scale or load at which the problem occurs, baseline measurements, environment
- **Security** — affected endpoints or data, attack surface description, access level required to trigger
- **Feature Request** — use case or job to be done, success criteria, constraints
- **Feature Request / Question (problem space not yet decided)** — which options or approaches are in play, prior art, a build-vs-buy choice, or which direction to take, when the reporter is asking to define or scope the problem rather than supplying a missing fact about a direction already chosen

List only what is genuinely absent. Do not list information already present in the report. If nothing is missing, write exactly: `None - report has enough to proceed.`

## Step 4: Assess Severity and Reproducibility

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

**Omit when inapplicable.** Severity and Reproducibility describe a problem that is occurring. When the issue type is Feature Request, Question, or Other **and** neither is inferable from the report, omit both sections entirely rather than rendering `Unknown` — the same omit-when-not-inferable pattern Step 5 applies to Suspected Areas. For a Bug, Regression, Performance, or Security issue, always render both (as `Unknown` if needed); they are core to triaging a problem.

## Step 5: Identify Suspected Areas

If the report points to a specific system area, list it. Then, only to sharpen those areas, consult project context: if the `CLAUDE.md` label is non-empty, read it; if the `project-discovery.md` label is non-empty, read it (it is the richer system map when present). Use them to name relevant areas such as upload pipeline, authentication middleware, database migrations, or frontend state management.

Do not infer areas the report does not point to, and never use project context to supply information the reporter omitted. If both `CLAUDE.md` and `project-discovery.md` are absent or empty, or nothing in the report points to a specific system area, omit the Suspected Areas section entirely and continue.

## Step 6: Determine the Recommended Next Step

Decide the single recommendation using the issue type from Step 1 and the gaps from Step 3:

- **Bug, Regression, Performance, or Security** — if reproduction steps, environment details (OS, browser, version), or user-impact scope are missing, the recommendation is `Clarify with reporter before proceeding`. Otherwise it is `/investigate`.
- **Feature Request** — if the Step 3 Missing Information names a problem-space gap (which options or approaches are in play, prior art, a build-vs-buy choice, or which direction to take) rather than a missing user-supplied fact, the recommendation is `/research` — the problem space must be researched before the feature can be specified. Otherwise, if the use case (job to be done) or success criteria are missing, the recommendation is `Clarify with reporter before proceeding`. Otherwise, if the feature is described but not yet specified, it is `/plan-a-feature`; if requirements are already specified, it is `/plan-implementation`.
- **Question** — if the Step 3 Missing Information names a problem-space gap (options, approaches, prior art, a build-vs-buy choice, or which direction to take), the recommendation is `/research`. Otherwise, if the report plus project context is enough to answer it, the recommendation is `Answer the question directly; no han skill needed`; if not, it is `Clarify with reporter before proceeding`.
- **Other** — the recommendation is `Clarify with reporter before proceeding`.

## Step 7: Write the Triage Report

Resolve the output path:

- If the user specified an output path, use it.
- Otherwise use `$HOME/.claude/triages/{kebab-case-summary}.md`, where `{kebab-case-summary}` is the Step 2 Summary lowercased with non-alphanumeric runs replaced by single hyphens.

Run `mkdir -p` on the directory that will contain the file (for the default, `mkdir -p "$HOME/.claude/triages"`). Write the report using the template at [template.md](references/template.md), filling every section from Steps 1-6 and writing the Step 6 result verbatim into Recommended Next Step. Omit the Suspected Areas section if Step 5 determined nothing is inferable, and omit Severity and Reproducibility per the Step 4 omit rule.

Present the completed triage report to the user. When the Recommended Next Step is a han skill (`/investigate`, `/research`, `/plan-a-feature`, or `/plan-implementation`), state plainly that this triage report is the handoff document — the operator passes the report itself to that skill rather than re-summarizing the issue. No separate brief is produced; the report already serves as the handoff.

---
name: code-review
description: "Run a comprehensive code review on local source files. Use this skill when the user asks to review, audit, inspect, evaluate, or check code — or when they ask to make sure, verify, or validate that code follows good coding standards, is free of errors or bugs, has sufficient test coverage, or meets best practices, even if they never use the word \"review.\" Triggers for any request to assess code quality, correctness, or security of specific files, directories, or the current branch. Also use when the user invokes /code-review directly. Works on git branches (reviewing changed files against the default branch) or on specified files and directories when git is not available. Does not post comments to GitHub pull requests — use post-code-review-to-pr for that. Does not analyze architectural structure or module boundaries — use architectural-analysis for that. Does not capture feedback on Han's own skills — use han-feedback for that."
arguments: size
argument-hint: "[size: small | medium | large] [optional context about changes or areas to focus on]"
allowed-tools: Bash(git *), Bash(gh *), Bash(make *), Bash(npm *), Read, Grep, Glob, Agent
---

When running a code review, follow the process outlined here.

## Project Context

- git installed: !`which git`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Review Constraints

Severity levels:
- **Critical** — Must fix before merge. Security vulnerabilities, data corruption risk, breaking API changes, data isolation failures.
- **Warning** — Should fix. Bugs that don't corrupt data, significant performance issues, missing required tests, missing error handling.
- **Suggestion** — Consider improving. Style improvements, optional performance gains, documentation gaps, refactoring opportunities.

Severity calibration is governed by **Step 3.3** (the authoritative home for size-based demotion). Manual findings from Steps 4 to 6 follow the same size-based rules as agent findings classified at Step 7: Small changes escalate only Critical findings and default uncertain ones to the lower severity, Medium changes escalate Critical and Warning, Large changes prefer the higher severity when in doubt. Read `{size}` from Step 3.1. Include `file_path:line_number` references and code examples for suggested fixes.

**Finding caps:** Manual review findings (Steps 4-6) and agent findings (Step 7) are each capped at 30 items. Prioritize by severity: all CRIT first, then WARN, then SUGG. If either cap is exceeded, note that additional items were omitted and another code review is recommended after addressing current items. Security findings are not capped (see classification rubric).

**Project pattern deference:** A pattern that differs from general best practices but is consistent within the project is not a review finding. Only flag deviations from the project's own conventions.

**YAGNI findings are a separate, non-correcting class.** Apply the two-pass YAGNI procedure documented in [`references/review-checklist.md`](references/review-checklist.md) (Pass 1 runs the evidence test from [../../references/yagni-rule.md](../../references/yagni-rule.md) Gate 1; Pass 2 matches against the named anti-patterns) to every change in the diff. **YAGNI findings are listed in their own `### 🟡 YAGNI` section, separate from Critical / Warning / Suggestion**, and **do not appear under CRIT / WARN / SUGG**. The YAGNI section opens with this exact statement: *"These findings will not be corrected unless explicitly requested. They are documented so the team can decide consciously whether to keep, simplify, or defer the items."* Each YAGNI finding records (a) the failing evidence type from Pass 1, (b) the matched anti-pattern from Pass 2, and (c) the simpler form considered. Severity calibration (the directive in Step 3.3, the authoritative home) does NOT apply to YAGNI; these findings are surfaced regardless of change size and are advisory, not corrective.

**Automated tool boundary:** If the project has a linter or formatter, trust it. Only flag style issues that automated tools can't catch.

### Task ID Assignment

Assign a unique task ID to each review item:
- **CRIT-###** for critical items (e.g., CRIT-001, CRIT-002)
- **WARN-###** for warnings (e.g., WARN-001, WARN-002)
- **SUGG-###** for suggestions (e.g., SUGG-001, SUGG-002)
- **YAGNI-###** for YAGNI candidates (e.g., YAGNI-001, YAGNI-002) — these are advisory and listed in their own section; they are not corrected unless the user explicitly requests it

IDs are sequential within each category, starting at 001. Assign IDs in the order files are reviewed (alphabetically).

**Category Assignment:** When an issue fits multiple categories, use the **first matching category** from the checklist order in [review-checklist.md](references/review-checklist.md).

## Step 1: Identify Changes

Resolve project config: read CLAUDE.md's `## Project Discovery` section for docs, ADR, and coding-standards directories plus test, lint, and build commands (look under `### Commands and Tests`, not `### Frameworks and Tooling`); fall back to project-discovery.md; fall back to Glob defaults (`docs/`, `docs/adr/`, `docs/coding-standards/`). Store found values for use in Steps 2, 5, and 6. Continue without any keys that remain unfound.

### Detect review context

Check the `git installed` value from Project Context above. If it is empty, skip directly to **Mode C** below.

1. Run `${CLAUDE_SKILL_DIR}/scripts/detect-review-context.sh` to detect the git environment. Capture the output — it contains key-value pairs describing git availability, branch name, default branch, and changed files.

Use the script output to determine the review mode. If the script reports `git-available: false`, skip to **Mode C**.

**Mode A: Full git context** — script reports `git-available: true` and `changed-files-start` block has content.
- Use the changed files list from the script output as the review scope
- Run `git diff {default-branch}...HEAD` to retrieve the full diff (fetch as a separate Bash command so large diffs are handled incrementally)
- Store the branch name from the script output for use in Step 3

**Mode B: Git but no branch changes** — script reports `git-available: true` but `changed-files: none`.
- Run `git diff` (unstaged) and `git diff --cached` (staged) to check for uncommitted work
- Run `git status --short` to identify modified, added, and untracked files
- If files are found, use those as the review scope (review files directly by reading them — no base-branch diff is available)
- Store the branch name from the script output for use in Step 3
- If no files found, fall through to **Mode C**

**Mode C: No git / no changes found**
- If the user provided file paths, glob patterns, or directories as arguments, use those to build the file list (expand with Glob)
- If no arguments provided, use Glob to discover source files in the current directory, excluding: `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`, `__pycache__/`, `*.min.js`, `*.min.css`, lock files
- Present the discovered files and ask the user to confirm the review scope
- Note: In Mode C, review files by reading them in full rather than comparing against a diff (no diff is available)

**Bind `$focus_areas`.** Read the user's free-form argument string from the invocation (everything after the optional `$size` positional). If non-empty, bind `$focus_areas` to that string verbatim. If empty, bind `$focus_areas` to the literal string `none provided`. This binding is consumed by every Step 3.5 agent prompt and by the Step 4 manual review.

## Step 1.5: Load Branch Context

Load PR-level and branch-level context that the agents at Step 3.5 will need. Skip this step in **Mode C** (no git); for Mode A and Mode B, attempt the four sources below in order and combine what loads into a single `$branch_context` binding.

1. **PR description (Mode A only).** If `gh` is available, run `gh pr view --json title,body,headRefName,baseRefName 2>/dev/null` for the current branch and capture the body. If `gh` is not available or no PR exists for this branch, skip to source 2.
2. **Local `pr-body` file.** Look for a file named `pr-body`, `PR_BODY.md`, or `.pr-body` at the repo root. If present, read it.
3. **Branch commit messages.** Run `git log {default-branch}..HEAD --pretty=format:%B` (Mode A) or `git log -n 20 --pretty=format:%B` (Mode B) and capture the messages.
4. **Implementation plan in the planning directory.** Resolve the planning directory using this order:
   - Read CLAUDE.md's `## Project Discovery` section for a `plans:` or `planning:` key naming the directory (e.g., `plans: docs/plans/`). Use that path if present.
   - If no key, Glob `docs/plans/*/feature-implementation-plan.md` and `plans/*/feature-implementation-plan.md`.
   - When the Glob returns multiple matches, pick the directory whose name matches the current branch name (treat `-` and `_` as interchangeable). If no directory matches, log `no planning artifact found for branch {branch}` and skip this source.
   - Read the matched plan file if found.

**Summarize loaded content into a Branch Context block of at most 200 words** covering: scope of the change, deferred items the team named, premises the team has already locked in, focus areas the author called out. Bind the summary to `$branch_context`.

**Fail-open behavior.** When none of the four sources returns content, emit this single-line warning to the orchestrator's output: `Branch Context: no PR or planning artifact found; agents will run without branch-level context.` Bind `$branch_context` to the literal string `none provided` and proceed.

## Step 2: Automated Quality Checks

Using the file list from Step 1, run automated checks from the project root directory. **Do not fix any errors** — report each failure in the review output.

Use the test, lint, and build commands from Step 1's project config lookup. If a command was not found, silently skip that check.

Run each command **one at a time, sequentially**, scoped to changed areas when possible. Record each failure (command + relevant error output) as a **CRIT** item with category **[Automated Check]**, then continue to the next command.

## Step 3: Classify Change Size and Dispatch Review Agents

Agents analyze source code to identify coverage gaps, edge cases, security vulnerabilities, structural problems, runtime-behavior risks, concurrency hazards, and clarity issues — they do not execute tests. (The test command gate applies only to Step 2's automated checks.) The classification below decides which agents are dispatched and how their briefs are scoped, so agents do not produce findings disproportionate to the change.

Determine the output directory for agent reports: if the project has an existing documentation folder (e.g., `docs/`), use it; otherwise use the current working directory.

### Step 3.1: Classify the change

**Default to small.** Start the classification at **small** and only escalate to medium or large when the signals below clearly require it. When a signal is borderline, stay at the smaller band. Use these signals on the file list from Step 1:

- **Small** *(default)* — 1–3 files affected, single subsystem, no cross-cutting concerns. No new module boundaries. No schema, migration, or infrastructure changes. No auth/PII surface added.
- **Medium** — 3–10 files, one or two adjacent subsystems. May touch a single cross-cutting concern (one API contract, one schema migration, one new permission check, one new index).
- **Large** — more than 10 files, multiple subsystems, architectural changes, security or data implications, multi-service coordination, or the user explicitly requests full agent review.

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, or `large` as the first argument), use that value as the size and skip the signal-based classification. If `$size` is empty, classify from the signals above. Anywhere else in this skill body that mentions a "user override" of size, this argument is the override.

State the chosen size in one line with the justification (e.g., "Medium: 6 files touched, adds one index and a query for it" or "Medium: passed via `$size`"). Also draft a one-line summary of what the change does — this is reused in agent briefs below.

**This step is the authoritative source for `{size}`.** Every later consumer reads `{size}` from here: the Review Constraints rule above, the Step 3.3 calibration directive, the Step 3.5 agent prompts, the Step 7.2 demotion gate, and the rubric in `references/agent-finding-classification.md`. Do not re-derive size at any of those sites.

### Step 3.2: Select agents

**Always dispatch — minimum roster across all sizes:**

1. `han.core:junior-developer` — generalist clarity and standards check, applicable to any change.
2. `han.core:adversarial-security-analyst` — security findings have a non-negotiable evidence standard that already prevents theoretical reports; the agent stays silent when the standard is not met.

**Conditionally dispatch the rest based on signals in the file list.** Skip any whose signal does not appear:

| Agent | Include when... |
|---|---|
| `han.core:test-engineer` | source files with logic or behavior were added or modified (skip for docs-only or pure config changes) |
| `han.core:edge-case-explorer` | code processes inputs with boundaries, parses external data, or handles multiple states (skip for trivial edits, renames, or docs-only changes) |
| `han.core:structural-analyst` | the change introduces new files, new modules, or modifies dependency direction across modules (skip for single-file in-place edits) |
| `han.core:behavioral-analyst` | the change modifies runtime data flow across module boundaries, error propagation paths, or state management (skip for self-contained changes within a single function or class) |
| `han.core:concurrency-analyst` | the file list touches threads, async/await, goroutines, actors, shared mutable state across requests, timers, locks, or message queues |
| `han.core:data-engineer` | the change touches a schema definition, migration file, query, ORM model, index definition, document shape, stream contract, or data-access module |
| `han.core:devops-engineer` | the change touches Dockerfiles, IaC (Terraform/Pulumi/CloudFormation), Kubernetes manifests, CI/CD pipeline files, deployment scripts, observability config, feature-flag config, or rollout-affecting code paths |
| `han.core:on-call-engineer` | the change adds or modifies application source that runs in production with runtime resilience surface — outbound calls (HTTP, RPC, database, cache, queue, lock), retry logic, queue or buffer handling, async/await or goroutine/thread-pool code, error-handling on the failure path, fan-out loops, idempotency checks, schema migrations co-deployed with dependent application code, or new production code paths. Skip for pure config, docs, generated files, and `han.core:devops-engineer`-territory changes (Dockerfiles, IaC, manifests, pipeline files, observability platform config) — the hard boundary lives at the application source line. |

**Selection rules:**

- Honor any agent the user named explicitly.
- For each conditional agent included, justify in one line — name the file or signal that triggered inclusion.
- Fewer is better. If a signal is borderline, **skip** the agent rather than include it. A small change that nominally touches a query but is not modifying its behavior does not require `han.core:data-engineer`.

State the selected roster to the user in one line per agent before launching.

### Step 3.3: Scope every agent brief to the change

**Step 3.3 is the authoritative home for size-based demotion.** Every other site that needs the size-based rule references this step by name rather than restating it: the Review Constraints rule for manual findings, the Step 7.2 demotion gate for agent findings, the rubric in `references/agent-finding-classification.md`, and the YAGNI two-pass procedure in `references/review-checklist.md`.

Every dispatched agent receives — alongside its domain-specific prompt — the following calibration directive verbatim. This directive overrides the default review-wide "prefer the higher severity" rule for agent-dispatched findings:

> **Calibrate findings to the change being reviewed.** This is a **{size}** change touching {N} files. The change does the following: {one-line summary from Step 3.1}.
>
> Raise a finding only when **at least one** of these holds:
> 1. The change actively introduces or worsens the issue.
> 2. The issue is critical irrespective of who introduced it — proven security exploit, data corruption, data isolation break, or data loss with no recovery.
>
> Do **not** raise:
> - Theoretical concerns the change does not touch.
> - Pre-existing best-practice gaps the change did not make worse.
> - Multi-instance, scale-out, replay, or migration-coordination concerns whose worst-case outcome is **benign** — meaning the second attempt no-ops, the user can retry without harm, the side effect is already in place, or the operation is naturally idempotent at the storage layer (e.g., `CREATE INDEX IF NOT EXISTS`, idempotent upserts, the same row reconciled twice).
> - Hypothetical scaling problems for workloads the project does not currently have.
>
> Severity calibration scales with size:
> - **Small change**: only Critical findings escalate. Raise Warnings only when the finding is directly introduced by this change. Omit Suggestions entirely.
> - **Medium change**: Critical and Warning findings escalate. Raise Suggestions only when directly introduced by this change.
> - **Large change**: all severities are in scope.
>
> When uncertain about severity, prefer the **lower** severity. If the worst-case impact is "an operator sees an error and retries," that is not Critical.
>
> **YAGNI findings are separate from severity.** Apply the two-pass YAGNI procedure documented in [`references/review-checklist.md`](references/review-checklist.md) (Pass 1: evidence test against [`../../references/yagni-rule.md`](../../references/yagni-rule.md) Gate 1; Pass 2: named anti-pattern match) to every change in the diff regardless of size. The size-based demotion in this Step 3.3 directive does NOT apply to YAGNI findings; they are advisory at every size, listed in a separate section, and not corrected unless the user explicitly requests it. Each finding's body must name (a) the failing evidence type, (b) the matched anti-pattern, and (c) the simpler form considered.

### Step 3.4: Domain-scoped file lists

Pass each agent only the slice of the file list relevant to its domain:

| Agent | File-list slice |
|---|---|
| `han.core:junior-developer` | full file list (generalist) |
| `han.core:adversarial-security-analyst` | full file list plus dependency manifests |
| `han.core:test-engineer` | source files plus their related test files |
| `han.core:edge-case-explorer` | source files containing logic or input handling |
| `han.core:structural-analyst` | source files only (skip configs, schemas, docs) |
| `han.core:behavioral-analyst` | source files containing runtime logic |
| `han.core:concurrency-analyst` | source files matching the concurrency signal |
| `han.core:data-engineer` | schema, migration, query, ORM, and data-access files only |
| `han.core:devops-engineer` | infra, deploy, CI/CD, observability files only |
| `han.core:on-call-engineer` | application source files only (no Dockerfiles, IaC, manifests, pipeline files, observability platform config) |

### Step 3.5: Dispatch

Launch all selected agents **in parallel** using the `Agent` tool with `run_in_background: true`, in a single message so they run concurrently. Each agent's prompt has four parts: the domain-specific question, the calibration directive verbatim from Step 3.3, the domain-scoped file list from Step 3.4, and two named-binding blocks for user focus areas and branch context. Include the branch name only if one was detected (Mode A or Mode B). Do not wait for results; continue immediately to Step 4.

**Two named-binding blocks ship with every agent prompt.** Append the following to every prompt below, after the calibration directive and before the domain-specific instructions:

> **Focus areas from the user.** $focus_areas.
>
> **PR / branch context.** $branch_context.
>
> Findings in the focus area receive extra scrutiny and additional detail. Findings outside the focus area must still satisfy the calibration directive above; do not raise minor findings outside the focus area when a focus area is provided. Use the branch context to avoid re-raising items the PR description or implementation plan has already deferred or resolved.

Substitute the values of `$focus_areas` (bound at Step 1) and `$branch_context` (bound at Step 1.5) literally. Do not paraphrase or summarize either binding inside the prompt.

**Per-agent dispatcher directives.** Add the following directive to each named agent's prompt in addition to the shared blocks above. Other agents do not receive these directives.

- **`han.core:structural-analyst` and `han.core:behavioral-analyst`.** Add: *"Default the severity of every finding you raise to SUGG. Escalate to WARN only when the change actively introduces or worsens the issue described, and to CRIT only when the issue is critical irrespective of who introduced it. A false positive at SUGG is cheaper than a missed real issue; a false positive at WARN erodes trust."* This dispatcher directive is the `/code-review` skill's tailoring; it does not modify the agent's general behavior outside `/code-review`.
- **`han.core:junior-developer`.** Add: *"Outward reads (adjacent code, callers) are for context only; findings must concern code on the scoped file list above. A finding about code outside the file list is permitted only when it directly demonstrates that the changed code on the file list cannot be safely interpreted without the out-of-scope context. Otherwise, omit the finding."* This dispatcher directive is the `/code-review` skill's tailoring; it does not modify the agent's general behavior outside `/code-review`.
- **`han.core:edge-case-explorer`.** Add: *"Findings must ultimately trace to a failure mode in code on the scoped file list above, even when callers outside the file list provide the evidence for that failure mode. Read callers as evidence per your Protocol 1, but the failure-mode target of every finding stays on the file list."* This narrower wording preserves the agent's caller-read protocol; it is the `/code-review` skill's tailoring and does not modify the agent's general behavior outside `/code-review`.

Domain-specific prompts (the `{size}`, `{N}`, `{change summary}`, `{file list}`, and `{branch}` placeholders are filled from earlier steps):

1. `han.core:test-engineer` — "Analyze test coverage for the following files{if branch available: ' on branch {branch}'}: {file list}. Focus your analysis on these files and their related test files. Write your output to {output_directory}/test-plan.md"

2. `han.core:edge-case-explorer` — "Explore edge cases for the following files{if branch available: ' on branch {branch}'}: {file list}. Focus your analysis on these files and their inputs, integration points, and error paths. Write your output to {output_directory}/edge-case-analysis.md"

3. `han.core:adversarial-security-analyst` — "Perform adversarial security analysis on the following files{if branch available: ' on branch {branch}'}: {file list}. Locate all dependency manifests in the project (package.json, requirements.txt, go.mod, Gemfile, *.lock, pom.xml, build.gradle) and include them in your analysis. Write your output to {output_directory}/security-analysis.md"

4. `han.core:structural-analyst` — "Analyze the static structure of the following files{if branch available: ' on branch {branch}'}: {file list}. Focus on coupling across module seams, dependency direction, duplication, and missing or leaky abstractions introduced or worsened by these changes. Write your output to {output_directory}/structural-analysis.md"

5. `han.core:behavioral-analyst` — "Analyze runtime behavior for the following files{if branch available: ' on branch {branch}'}: {file list}. Focus on data flow across module boundaries, error propagation and loss, state-management hazards, and integration-boundary assumptions that these changes introduce or break. Write your output to {output_directory}/behavioral-analysis.md"

6. `han.core:junior-developer` (artifact-review mode) — "Review the following files{if branch available: ' on branch {branch}'} as a respected junior-to-mid teammate reading this code for the first time: {file list}. Surface hidden assumptions, muddied scope, unclear naming, baked-in prerequisites, and places where the change conflicts with existing coding standards, ADRs, or CLAUDE.md. Every finding must cite a specific file and line and either name the assumption challenged or the standard violated. Write your output to {output_directory}/junior-developer-review.md"

7. `han.core:concurrency-analyst` — "Analyze concurrency and async patterns for the following files{if branch available: ' on branch {branch}'}: {file list}. Focus on race conditions, lock ordering, shared-resource contention, deadlock potential, and async error handling. Write your output to {output_directory}/concurrency-analysis.md"

8. `han.core:data-engineer` — "Audit the following data-related files{if branch available: ' on branch {branch}'}: {file list}. Focus on the data-engineering principles violated by what this change actually introduces — schema-design fit, index strategy, migration safety, query correctness, data-contract evolution. Apply the calibration directive: do not raise findings for benign-outcome concerns like duplicate-create-index attempts where the storage layer is naturally idempotent. Write your output to {output_directory}/data-analysis.md"

9. `han.core:devops-engineer` — "Audit the following infrastructure and deployment files{if branch available: ' on branch {branch}'}: {file list}. Focus on production-readiness concerns this change actually introduces — rollout safety, observability coverage, scale and cost impact, secret handling. Apply the calibration directive: do not raise findings for theoretical scale problems the project does not currently have. Write your output to {output_directory}/devops-analysis.md"

10. `han.core:on-call-engineer` — "Audit the following application source files{if branch available: ' on branch {branch}'} for the named code-level resilience anti-patterns that wake on-call engineers at 3am: {file list}. Focus on what the change actually introduces — missing timeouts, retries without backoff and jitter, non-idempotent operations in retry paths, catch-and-swallow exceptions, unbounded queues or buffers, blocking I/O in async execution contexts, missing bulkheads, missing correlation-id propagation, assuming dependencies are always available, ODD-gate failures (no observable signal on the new path), schema migrations co-deployed with dependent code, eventual-consistency violations, data integrity hazards. Hard boundary: application source only — defer infrastructure, pipeline, IaC, observability platform, and alert configuration concerns to `han.core:devops-engineer`. Apply the calibration directive. Run the four named tone anti-pattern sweeps against your own findings before emitting (sugarcoated criticism, thin blame, tourist citation, bibliographic empathy). Write your output to {output_directory}/on-call-analysis.md"

Continue to Step 4 immediately. Results will be collected in Step 7.

## Step 4: Review All Changes

Review each file from the Step 1 file list **in alphabetical order**. For each file:
1. **Skip generated files** (lock files, compiled output, vendor directories, auto-generated code) — note them as skipped in the review
2. **Skip binary files** — note them as skipped
3. **Read the full file** to understand context. For very large files (over 1000 lines), focus reads on the changed regions and their surrounding context
4. **Examine the diff** to understand what changed. If no diff is available (Mode B uncommitted review or Mode C non-git review from Step 1), skip this sub-step — the full file read from sub-step 3 provides all necessary context. Apply the review checklist to the entire file content.
5. **Apply the review checklist** at [review-checklist.md](references/review-checklist.md)

If the user provided focus areas in their arguments (the `$focus_areas` binding from Step 1), apply extra scrutiny to those areas and include additional detail in findings for matching categories.

**Mode B and Mode C scope note.** In Mode B (uncommitted changes) and Mode C (no git), the skill cannot distinguish introduced code from pre-existing code; the diff signal that drives the calibration directive is absent. In these modes, apply the review checklist conservatively:

- Raise findings only for items the user explicitly named in the focus areas (`$focus_areas`), items in source files (skip generated and vendored content), and items at file boundaries (imports, exports, public API).
- **Skip the YAGNI checklist entirely in Mode B and Mode C unless the user explicitly requests it in `$focus_areas`.** YAGNI requires distinguishing introduced code from pre-existing code; without a diff, every speculative addition predating the change would surface as if introduced now.
- The size-based demotion in Step 3.3 still applies, but treat the change as Small unless the user passed `$size`.

## Step 5: Documentation Compliance Analysis

After reviewing all changed files, analyze the changes against the project's documented patterns and conventions. **Skip this step if Step 1's project config lookup did not find any of the three directories (docs, ADR, coding standards).**

### Documentation Sources

| Source | Config Key | Category Prefix | Exclude Templates? |
|--------|-----------|----------------|-------------------|
| ADRs | ADR directory | [ADR: filename] | Yes |
| Coding Standards | coding standards directory | [Standard: filename] | Yes |
| General Docs | docs directory | [Docs: filename] | No |

For each source where Step 1's project config lookup returned a path:

1. Scan filenames in the directory to identify documents relevant to the changed files
2. Read each relevant document in full
3. **Verify the standard's premise applies before raising a "violates standard X" finding.** Read at least one architectural file in this codebase that demonstrates the standard's premise: an entry-point file for runtime-shape standards, a router or navigation surface for routing standards, a config file for configuration standards, an integration boundary for cross-service standards. When the architectural file confirms the premise, proceed with the violation analysis. When the file does not confirm the premise (e.g., the standard assumes SPA-style company switching but the codebase uses full-page redirects; the standard assumes rich-error API responses but the codebase uses type-system-closed contracts), do not raise the finding. Log a single line in the orchestrator's notes: `premise not verified for {standard}; finding omitted`. The "infer the premise from the standard's own examples" path is not a forward path; it is a reason to omit the finding.
4. Evaluate whether the changes contradict, circumvent, deviate from, or are inconsistent with the document
5. Report violations as review items using the category prefix from the table above

#### Compliance severity guidance

- **CRIT**: Directly contradicts or violates an accepted decision, standard, or documented convention
- **WARN**: Partially deviates or introduces a pattern not covered by existing documentation
- **SUGG**: Minor inconsistency with documented guidance

Documentation compliance findings merge into the same output sections as the file-by-file review findings.

## Step 6: Documentation Freshness Review

After the compliance analysis, evaluate whether documentation files are still accurate given the code changes. **Skip this step if Step 1's project config lookup did not find a docs directory.**

1. **Identify relevant docs** based on the domains, packages, and features touched by the diff
2. **Skip irrelevant docs**
3. **Read and evaluate each relevant doc** against the current state of the code. Look for:
   - Incorrect behavior descriptions
   - Stale references (renamed/moved/removed file paths, functions, fields)
   - Missing coverage for new features added by this branch
   - Incorrect code examples
4. **Report findings** using **[Docs Update: filename]** as the category prefix

Severity: **CRIT** if the doc describes behavior that is now wrong and would mislead developers. **WARN** if incomplete — a significant change should be documented. **SUGG** for minor staleness unlikely to cause confusion.

Documentation freshness findings merge into the same output sections as the other findings.

## Step 7: Collect and Classify Agent Results

Wait for all agents dispatched in Step 3 to complete. Each agent returns a summary with finding counts and a file path. **Skip this step if no agents were dispatched in Step 3.**

This step runs in three numbered sub-steps. Order matters: read the agent output, then apply the reachability demotion gate, then apply the size-aware rubric.

### Step 7.1: Read agent output files

Read only the output files for agents that were actually dispatched in Step 3. Skip the read for any agent that was not selected:

- `{output_directory}/test-plan.md` — han.core:test-engineer findings (T-series)
- `{output_directory}/edge-case-analysis.md` — han.core:edge-case-explorer findings (EC-series)
- `{output_directory}/security-analysis.md` — han.core:adversarial-security-analyst findings (SEC-series)
- `{output_directory}/structural-analysis.md` — han.core:structural-analyst findings (S-series)
- `{output_directory}/behavioral-analysis.md` — han.core:behavioral-analyst findings (B-series)
- `{output_directory}/junior-developer-review.md` — han.core:junior-developer findings (JD-series)
- `{output_directory}/concurrency-analysis.md` — han.core:concurrency-analyst findings (C-series)
- `{output_directory}/data-analysis.md` — han.core:data-engineer findings (D-series)
- `{output_directory}/devops-analysis.md` — han.core:devops-engineer findings (DV-series)
- `{output_directory}/on-call-analysis.md` — han.core:on-call-engineer findings (OCE-series)



Extract the items from the Findings sections of each file that was read.

### Step 7.2: Apply the reachability phrase-match demotion gate

For each finding read at Step 7.1, scan the rationale text (the agent's own explanation of why the finding matters) for any of these reachability phrases:

- `theoretical`
- `hypothetical`
- `defense-in-depth`
- `effectively impossible`
- `in case the upstream`
- `could happen`
- `should never happen`
- `edge case that does not occur`

When a finding's rationale contains any of these phrases, the agent itself signaled that the failure mode is not reachable in production. Demote the finding by one severity: CRIT becomes WARN, WARN becomes SUGG, SUGG is omitted entirely. Apply the demotion exactly once per finding regardless of how many phrases match.

This gate is the merged form of the reachability and "directly introduced" filters; the size-aware rubric in Step 7.3 is the single later pass and does not re-demote on these phrases. The phrase list is the only signal the gate uses; do not infer reachability from other text.

Security findings (SEC-series) are exempt from this gate because the security agent's evidence standard already requires a demonstrated exploit path or CVE reference before any finding is raised.

### Step 7.3: Classify with the size-aware rubric

Classify the surviving findings using the rubrics at [agent-finding-classification.md](references/agent-finding-classification.md). The rubric defines what each severity means in each agent category; Step 3.3's size-based demotion (read `{size}` from Step 3.1) governs which findings escalate to those bands. Continue task ID numbering sequentially from Steps 4-6 (see Task ID Assignment above).

### Deferred tests

If the han.core:test-engineer produced Deferred/Skipped items, include them as a note after the testing findings (not counted toward the cap):

> **Deferred tests:** The following test cases were considered but excluded because brittleness risk outweighs value: {list of skipped item titles and brief reasons}

## Step 8: Generate Review Output

Use the template at [template.md](references/template.md) for the output structure. Include all sections even when empty — the template shows the empty-state text for each. Include the Security Improvement Summary verbatim from the agent.

## Step 9: Verify Review Output

Before presenting the review, run the self-consistency check first, then verify the structural items below.

### Step 9.0: Self-consistency check

Detect contradictory recommendations on overlapping code. Run two passes:

1. **Extraction pass.** For every finding (manual and agent), extract a tuple: `{task-id, file-path, line-range, recommended-action-summary}`. The recommended-action-summary is a one-line summary of what the finding tells the developer to do (e.g., "remove the className.toMatch assertion", "add a className.toMatch assertion", "wrap the call in try/catch", "remove the try/catch wrapper"). Skip findings that have no actionable recommendation.
2. **Comparison pass.** For every pair of tuples on the same `file-path` whose `line-range` overlaps, check whether the two `recommended-action-summary` values prescribe opposite actions on the same code (one says add X, the other says remove X; one says split, the other says merge; one says inline, the other says extract). For each contradictory pair found:
   - Demote both findings by one severity (CRIT → WARN, WARN → SUGG, SUGG stays at SUGG and is annotated rather than dropped).
   - Append a `Tension with {other-task-id}:` note to each finding's body, naming the contradicting task ID and the opposite action it prescribes. The human reviewer must adjudicate.

Scope is overlapping line ranges in a single file only. Cross-file semantic contradictions are out of scope for this check.

### Step 9.1: Structural verification

Then verify:

1. Task IDs are sequential within each category (CRIT-001, CRIT-002, ...; WARN-001, WARN-002, ...)
2. Agent findings from every dispatched agent (testing, edge-case, structural, behavioral, concurrency, data, devops, han.core:junior-developer) have valid task IDs continuing from manual review IDs. Findings from agents that were not dispatched in Step 3 must not appear.
3. Agent findings have valid `file_path:line_number` references
4. Deferred tests note is present if the han.core:test-engineer produced skipped items
5. The Review Summary table includes every finding and matches the detailed sections
6. All `file_path:line_number` references point to real files from the file list determined in Step 1
7. SEC-### IDs are sequential starting at SEC-001
8. Every SEC-### finding has an `EXPLOIT:` field populated
9. Every SEC-### finding has a corresponding CRIT-### cross-reference in `### 🔴 Critical`
10. Junior-developer findings that overlap with a specialist agent's finding reference the specialist finding instead of duplicating it
11. The review output is the COMPLETE and FINAL response. Do not append a trailing summary, commentary, sign-off, or follow-up message after the review. The structured review document IS the deliverable — nothing follows it.
12. The `### 🟡 YAGNI` section, when present, opens with the verbatim statement: *"These findings will not be corrected unless explicitly requested. They are documented so the team can decide consciously whether to keep, simplify, or defer the items."* YAGNI findings appear ONLY in this section — they are not duplicated under CRIT/WARN/SUGG and are not included in the Review Summary table.
13. Any `Tension with {other-task-id}:` notes added by Step 9.0 appear on both members of each contradictory pair.


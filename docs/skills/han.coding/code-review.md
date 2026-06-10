# /code-review

Operator documentation for the `/code-review` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han.coding/skills/code-review/SKILL.md`](../../../han.coding/skills/code-review/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Comprehensive code review of the current branch's changes, or of specified files when git is not available.
- **When to use it.** You want a principled review of what changed before merge: correctness, testing, security, documentation compliance, and project-pattern deference.
- **What you get back.** A structured review with findings classified as CRIT / WARN / SUGG, each with `file_path:line_number` references and suggested fixes.
- **Size-aware.** The skill classifies the change as small / medium / large, defaults to small, and dispatches a roster proportional to scope. Pass the size as the first positional argument to override (`/code-review medium`). See [Sizing](../../sizing.md) for the full model.

## Key concepts

- **Three severity levels.** CRIT (must fix before merge: security, data corruption, breaking API), WARN (should fix: bugs, missing error handling, missing tests), SUGG (consider: style, refactoring, docs). Severity calibration is governed by Step 3.3 in the skill body, the authoritative home for size-based demotion. Manual findings (Steps 4 to 6) and agent findings (Step 7) follow the same rules: small changes escalate only Critical and prefer the lower severity on uncertainty; medium escalates Critical and Warning; large prefers the higher severity when in doubt.
- **Three review modes.** Mode A uses the full git branch diff. Mode B reviews uncommitted work when no branch diff exists. Mode C reviews specified files when git is absent. **In Mode B and Mode C the YAGNI checklist is skipped unless explicitly requested**, because no diff exists to distinguish introduced code from pre-existing code.
- **Size-aware agent dispatch.** Two agents always run on every review (`junior-developer` for clarity and standards, `adversarial-security-analyst` for exploit-path security). The rest of the roster (`test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `devops-engineer`, `on-call-engineer`) is dispatched conditionally based on what the changed files touch. Larger sizes raise the upper bound on the roster; smaller sizes prefer fewer agents producing higher-signal findings. See the [Sizing](#sizing) section below.
- **Calibration directive.** Every dispatched agent receives a calibration directive that requires findings to be either introduced or worsened by the change, or critical irrespective of who introduced it. Theoretical concerns, pre-existing best-practice gaps, and benign-outcome scaling worries are excluded. Severity scales with size: small change → only Critical findings escalate; medium → Critical and Warning; large → all severities.
- **Per-agent dispatcher tailoring.** When `/code-review` dispatches `structural-analyst` and `behavioral-analyst`, it appends a default-SUGG directive so those agents start at the lowest severity and escalate only when the change introduces or worsens the issue. When it dispatches `junior-developer` and `edge-case-explorer`, it appends a file-list scoping directive so findings concern code on the scoped file list (with a narrower wording for `edge-case-explorer` that preserves its caller-read protocol while keeping the failure-mode target on the file list). These directives are `/code-review`'s tailoring; the agents' default behavior in other skills is unchanged.
- **Reachability phrase-match gate (Step 7.2).** When an agent's own rationale contains phrases like *theoretical*, *hypothetical*, *defense-in-depth*, *effectively impossible*, *in case the upstream*, *could happen*, *should never happen*, or *edge case that does not occur*, the finding is demoted by one severity before the rubric is applied. Security findings are exempt because the security agent's evidence standard already requires a demonstrated exploit path.
- **Branch context loaded at Step 1.5.** Before agents are dispatched, the skill loads four sources of branch-level context in order: PR description (via `gh pr view` when `gh` is available, Mode A only), a local `pr-body`, `PR_BODY.md`, or `.pr-body` file at the repo root, branch commit messages, and an implementation plan from the planning directory. The planning directory resolves first to the `plans:` (or `planning:`) key under CLAUDE.md's `## Project Discovery` section; otherwise the skill globs `docs/plans/*/feature-implementation-plan.md` and `plans/*/feature-implementation-plan.md`, picking the directory whose name matches the current branch (treating `-` and `_` as interchangeable). The loaded content is summarized into a `$branch_context` block of at most 200 words and plumbed, alongside the user's `$focus_areas` argument, into every agent prompt so agents avoid re-raising items the team has already deferred or resolved. Step 1.5 is skipped in Mode C; in Mode A and Mode B, when none of the four sources returns content the skill emits a single fail-open warning and proceeds with `$branch_context` set to `none provided`.
- **Self-consistency check at Step 9.0.** Before the structural verification, the skill scans every pair of findings on the same file with overlapping line ranges, detects contradictory recommendations, demotes both, and adds a `Tension with {other-task-id}:` note for the human reviewer. Cross-file semantic contradictions are out of scope.
- **Premise verification before standards-compliance findings.** Step 5 requires reading at least one architectural file in the codebase that demonstrates a standard's premise before the skill raises a "violates standard X" finding. When the file does not confirm the premise, the finding is omitted with a logged note rather than raised on inferred premises.
- **Project-pattern deference.** A pattern that differs from general best practices but is consistent within the project is *not* a finding. Only deviations from the project's own conventions count.
- **Automated tool boundary.** If the project has a linter or formatter, trust it. Only flag style issues that tooling cannot catch.
- **Documentation compliance and freshness.** ADRs, coding standards, and general docs are read and checked against the diff. Stale docs that misdescribe current behavior become CRIT findings.

## When to use it

**Invoke when:**

- You are about to merge a branch and want a principled pre-merge review covering correctness, tests, security, and doc compliance.
- A change has landed that you want audited against the project's ADRs, coding standards, or general docs.
- You want the exploit-path, coverage-gap, edge-case, structural, behavioral, clarity, and (when relevant) concurrency dimensions covered *in parallel* rather than one at a time.
- You are working without a GitHub PR (local code, experimental branch, personal fork) and want the full review without posting to a PR.
- You want review findings on files you specify by name even when git is not available. The skill gracefully degrades to file-based review.

**Do not invoke for:**

- **Posting the review to a GitHub PR.** Use [`/post-code-review-to-pr`](../han.github/post-code-review-to-pr.md). It delegates to this skill and then posts the review as PR comments.
- **Architectural analysis.** Use [`/architectural-analysis`](../han.coding/architectural-analysis.md) for coupling, data flow, concurrency, and SOLID assessment across a module.
- **Bug investigation.** Use [`/investigate`](./investigate.md) to find a root cause with evidence and adversarial validation.
- **Test planning in isolation.** Use [`/test-planning`](./test-planning.md) when you want a prioritized test plan without a full correctness review.
- **Plan review.** Use [`/iterative-plan-review`](../han.core/iterative-plan-review.md) for reviewing a work plan, not code.
- **Feedback on Han's own skills.** Use [`/han-feedback`](../han.feedback/han-feedback.md) to capture post-session feedback on the Han skills you ran.

## How to invoke it

Run `/code-review` in Claude Code. Pass an optional size override and/or context.

Give it:

1. **A size override, optional.** Pass `small`, `medium`, or `large` as the first positional argument to override auto-classification. Without an override, the skill defaults to small and escalates only when signals clearly require it. See the [Sizing](#sizing) section.
2. **A focus-area or context hint, optional.** *"Focus on the security implications of the new auth endpoints,"* or *"review with extra attention to the database migration."* Focus hints bias the manual review toward the named area; the parallel agents still run on their domain-scoped slice of files.
3. **A branch (implied).** If you are on a feature branch, the skill reviews changed files against the default branch (Mode A). If you are on the default branch with uncommitted work, Mode B kicks in. If there is no git, Mode C reviews what you point it at.
4. **Specific files or globs, optional.** In Mode C (or when you want to scope a git-mode review), pass file paths or glob patterns.

Example prompts:

- `/code-review`. Full review of the current branch's changes; auto-classifies size, defaulting to small.
- `/code-review medium`. Override the size to medium.
- `/code-review large "focus on the new auth endpoints"`. Override to large with a focus hint.
- `/code-review`. *"Focus on the security implications of the new auth endpoints."*
- `/code-review src/billing/`. Scope the review to the billing directory.

## What you get back

A structured review in-channel. Each finding's prose appears exactly once (its finding block, or its full security block — the summary-table row is an index, not a copy), and sections render only when they have content: a review of a small change produces a small document. The Review Summary table and the Review Recommendation are always present; every other section appears only when it has at least one item, and when several are present they keep a fixed order (Critical, Warnings, Suggestions, YAGNI, Security Vulnerabilities, Remediation, What's Good). The document can contain:

- **A Review Summary table** indexing every corrective finding and every security finding across categories (automated checks, correctness, testing, security, ADR/standard/docs compliance, documentation freshness), ordered by severity. A corrective finding's tier is carried by its task-ID prefix; a security finding shows its tier inline in the row (for example, `SEC-001 (Critical)`) so the table stands alone as the complete severity index.
- **Critical findings** (🔴). Each with task ID (`CRIT-001`, `CRIT-002`, …), `file_path:line_number`, the issue, and the recommended fix. The `[Category]` label is kept on a block only when it names content a standalone reader needs (an ADR violation naming the record, a standards violation naming the standard, or a security finding) and dropped for generic categories the table already carries.
- **Warnings** (🟡). Same structure with task ID `WARN-NNN`.
- **Suggestions** (🔵). Same structure with task ID `SUGG-NNN`.
- **Agent findings.** Coverage gaps (`T#`), edge cases (`EC#`), security findings (`SEC-NNN`), structural findings (`S#`), behavioral findings (`B#`), clarity findings (`JD#`), concurrency findings (`C#` when the concurrency analyst was dispatched), data findings (`D#` when the data engineer was dispatched), devops findings (`DV#` when the devops engineer was dispatched), and on-call resilience findings (`OCE#` when the on-call engineer was dispatched). Each is classified into the main severity tiers using the classification rubric. Security findings are the exception — they are not folded into a severity section (see below).
- **YAGNI findings.** Listed in their own `### 🟡 YAGNI` section with task IDs `YAGNI-NNN`. The section opens with the verbatim statement *"These findings will not be corrected unless explicitly requested. They are documented so the team can decide consciously whether to keep, simplify, or defer the items."* Each finding is one line naming the failing evidence type, the matched anti-pattern, and a single reopen-trigger clause. YAGNI findings are advisory; they are not counted under CRIT / WARN / SUGG, do not appear in the summary table, and do not block a clean review.
- **Security vulnerabilities** (🔐). One full `SEC-NNN` block per proven vulnerability — OWASP category, location, evidence, `EXPLOIT:` path, and severity — followed by a single short **Remediation** note that references the `SEC-NNN` IDs and states the actionable fix in one or two sentences. Security findings are not cross-referenced into the Critical section; instead the Review Recommendation reflects their severity (a Critical-severity security finding yields a do-not-merge recommendation). The whole section is omitted when no proven vulnerabilities exist.
- **What's Good** (✅). Rendered only when there is a specific, substantive positive worth recording; omitted entirely otherwise rather than filled with generic praise.
- **Deferred tests note.** Test cases the `test-engineer` considered but excluded as brittle, listed for transparency (not counted toward the finding cap).
- **ADR / coding-standard / documentation compliance findings.** Violations of project-specific docs, tagged with the source (for example, `[ADR: 0042]`, `[Standard: error-handling]`, `[Docs Update: payments.md]`).

Finding caps are 30 items each for the manual review pass and the agent pass; security findings are not capped. If a cap is exceeded, the skill says so and recommends another review after fixes land.

## How to get the most out of it

- **Run `/project-discovery` first.** The skill reads CLAUDE.md and `project-discovery.md` to find the ADR, coding-standards, and documentation directories. Without them, the compliance and freshness steps degrade to best-effort discovery.
- **Keep docs, ADRs, and standards up to date.** Every reference the skill finds sharpens the compliance check. Stale docs that contradict current behavior become CRIT findings, which is the signal to update the doc, not to bypass the skill.
- **Use focus hints for deep-dive branches.** When a branch touches a load-bearing surface (auth, billing, data migrations), name it in the prompt. The skill biases manual attention toward the area while the parallel agents still cover the full scope.
- **Pair with `/investigate` when findings reveal a bug.** If the review surfaces a CRIT finding whose root cause needs deeper analysis, dispatch `/investigate` next. It produces a fix plan with adversarial validation.
- **Pair with `/architectural-analysis` when findings reveal coupling or structural issues.** The review runs per-file; the architectural analysis runs per-module. Use both when the branch touches boundaries.
- **Re-run after fixes.** The skill is cheap to re-dispatch. Fix the findings, run again, confirm the count drops.
- **Use `/post-code-review-to-pr` if you want it posted to the PR.** `/post-code-review-to-pr` invokes this skill end-to-end, then posts the review to GitHub. If you already ran this one locally, you can run `/post-code-review-to-pr` next to publish.

## Sizing

Size is the primary lever the skill uses to decide how aggressively to review the change. The skill defaults to small and only escalates when concrete signals require it.

| Size | Files | Other signals | Roster (max) | Severity bands in scope |
|---|---|---|---|---|
| **Small** *(default)* | 1–3 files | Single subsystem; no cross-cutting concerns; no new module boundaries; no schema, migration, or infra changes; no auth/PII surface added. | The two required agents (`junior-developer`, `adversarial-security-analyst`) plus any conditional agent whose signal clearly fires (for example, a new test boundary triggers `test-engineer`). | Only Critical findings escalate. Raise Warnings only when the finding is directly introduced by the change. Suggestions are omitted. Same rule for manual findings (Steps 4–6) and agent findings (Step 7). |
| **Medium** | 3–10 files | One or two adjacent subsystems; may touch a single cross-cutting concern (one API contract, one schema migration, one new permission check, one new index). | Required two plus the conditional agents whose signals fire. Typically `test-engineer`, `edge-case-explorer`, and one of `structural-analyst` / `behavioral-analyst` / `data-engineer` / `devops-engineer`. | Critical and Warning findings escalate. Raise Suggestions only when directly introduced by the change. Same rule for manual and agent findings. |
| **Large** | More than 10 files | Multiple subsystems, architectural changes, security or data implications, multi-service coordination, or you explicitly request full agent review. | Required two plus all conditional agents whose signals fire. | All severities are in scope. Same rule for manual and agent findings. |

How the size is chosen:

- **Default to small.** Unless the file list and signals push the change into medium or large, the skill stays at small.
- **Conditional roster.** Agents are dispatched only when their signal appears in the file list. `concurrency-analyst` only when the files touch threads / async / shared state. `data-engineer` only when the files touch schemas, migrations, queries, or ORM models. `devops-engineer` only when the files touch infra, CI/CD, or deployment. Larger sizes do not force agents whose signals are absent.
- **Calibration directive.** Every dispatched agent receives a directive scoped to the size. The smaller the size, the narrower the severity bands the agent escalates, and the more aggressively benign-outcome concerns are dropped.

How to override the size:

- Pass `small`, `medium`, or `large` as the first positional argument: `/code-review medium`, `/code-review large "focus on the new auth endpoints"`.
- When the size is overridden via `$size`, the skill announces the override (`Medium: passed via $size`) and uses the chosen band for the roster cap and the calibration directive.
- Conversational overrides (*"treat this as a large review"*) work as well and are equivalent.

For the cross-skill sizing model and design principles, see [Sizing](../../sizing.md).

## Cost and latency

Cost scales with the chosen size. The two required agents (`junior-developer`, `adversarial-security-analyst`) always run; the rest of the roster is dispatched conditionally and capped by size. Automated checks (lint/build/tests from the project config), a file-by-file manual review, a documentation compliance pass, and a freshness pass run alongside.

- **Small change.** Typically 2–4 agents in parallel plus the manual pass. Minutes for the agents; manual pass scales with file count.
- **Medium change.** Typically 4–6 agents plus the manual pass.
- **Large change.** Typically 6–9 agents plus the manual pass.

Agents run on their default models. Finding caps of 30 per pass keep output bounded. Security findings are uncapped. The skill is built for per-branch cadence, not tight-loop iteration over the same code. Fix the findings and re-run.

## In more detail

The skill walks a ten-step process (Step 1.5 is a context loader inserted between Steps 1 and 2):

1. **Identify changes.** Detect git mode (A/B/C), resolve project config, enumerate changed files. Bind `$focus_areas` from the user's free-form argument.
1.5. **Load branch context.** Attempt PR description via `gh pr view --json title,body,headRefName,baseRefName` (Mode A only, when `gh` is available); a local `pr-body`, `PR_BODY.md`, or `.pr-body` file at the repo root; branch commit messages via `git log {default-branch}..HEAD --pretty=format:%B` (Mode A) or `git log -n 20 --pretty=format:%B` (Mode B); and an implementation plan resolved through the CLAUDE.md `plans:` / `planning:` key or, failing that, a Glob over `docs/plans/*/feature-implementation-plan.md` and `plans/*/feature-implementation-plan.md` that prefers the directory matching the current branch name (with `-` and `_` interchangeable). Summarize loaded content into `$branch_context` (at most 200 words). When nothing loads, emit a single fail-open warning, set `$branch_context` to `none provided`, and proceed. Skipped in Mode C.
2. **Automated quality checks.** Run the project's lint, build, and test commands. Report each failure as a CRIT finding with category `[Automated Check]`. Do not fix; report.
3. **Classify size and dispatch review agents in parallel.** Step 3.1 classifies the change as small / medium / large, defaulting to small, and binds `{size}` for every later consumer. Step 3.2 selects agents: the required two (`junior-developer`, `adversarial-security-analyst`) plus any conditional agents whose signals appear in the file list. Step 3.3 is the authoritative home for size-based demotion and attaches the calibration directive verbatim to every brief. Step 3.4 narrows each agent's brief to a domain-scoped slice of the file list (for example, `structural-analyst` receives source files only; `data-engineer` receives schema, migration, query, ORM, and data-access files only; `junior-developer` and `adversarial-security-analyst` receive the full list). Step 3.5 launches all selected agents in parallel, appending the shared `$focus_areas` and `$branch_context` blocks to every prompt and the per-agent dispatcher directives to `structural-analyst`, `behavioral-analyst`, `junior-developer`, and `edge-case-explorer`.
4. **Manual file-by-file review.** Every changed file (alphabetical) against the review checklist: correctness, data isolation, performance, error handling, testing, API design, maintainability, organization, docs, style, database, ADR compliance. In Mode B and Mode C, the YAGNI checklist is skipped unless the user requests it in `$focus_areas`.
5. **Documentation compliance analysis.** Read ADRs, coding standards, and docs relevant to the change. Verify each standard's premise applies by reading at least one architectural file in this codebase before raising a "violates standard X" finding; omit findings whose premise is not verified.
6. **Documentation freshness review.** Check whether docs describing the changed code are now stale.
7. **Collect and classify agent results in three sub-steps.** 7.1 reads each dispatched agent's output file. 7.2 applies the reachability phrase-match demotion gate (CRIT → WARN → SUGG → omitted) when a finding's rationale contains a documented reachability phrase; security findings are exempt. 7.3 classifies the surviving findings using the size-aware rubric in `agent-finding-classification.md`, governed by Step 3.3's size rules. Junior-developer findings that overlap with a specialist's finding reference the specialist instead of duplicating.
8. **Generate review output.** Assemble the final review using the review template, rendering each section only when it has content and keeping the fixed section order.
9. **Verify.** Step 9.0 runs the self-consistency check (extract `{task-id, file-path, line-range, recommended-action-summary}` tuples, then compare overlapping pairs and demote contradictory recommendations with a `Tension with {other-task-id}:` note). Step 9.1 then verifies task IDs are sequential, `file_path:line_number` references are valid, exploit fields are populated for security findings, the summary table indexes every corrective and security finding (with security tiers shown inline) and matches the sections present, no section is rendered empty, security findings carry no Critical cross-reference while the recommendation still reflects their severity, and the YAGNI section's verbatim opening is preserved.

## YAGNI

YAGNI in `/code-review` is **advisory-only** and runs as a two-pass procedure. **Pass 1, evidence test:** for every speculative addition (defensive code, single-implementation interfaces, configuration knobs no caller sets, instrumentation for non-flowing telemetry), check whether the diff contains evidence of need from one of the acceptable evidence types in [`yagni-rule.md`](../../../han.coding/references/yagni-rule.md). When evidence is present, do not flag. **Pass 2, anti-pattern check:** only items that fail Pass 1 are matched against the named anti-patterns; matches become `YAGNI-###` findings whose body names the failing evidence type, the matched anti-pattern, and the simpler form considered.

A YAGNI finding alone does not block a clean review; the posture is *make the cost of inclusion visible*, not *reject the change*. Critical-path correctness, security, and data-integrity findings are unaffected by this advisory posture and follow the standard severity rules. In Mode B and Mode C, the YAGNI checklist is skipped unless the user explicitly requests it, since the diff signal that distinguishes introduced code from pre-existing code is absent.

See [YAGNI](../../yagni.md) for the two gates, the acceptable-evidence list, the named anti-patterns, and why review skills make the cost of inclusion visible rather than enforce inclusion bans.

## Sources

The skill's protocols are grounded in established practice for pre-merge code review, parallel adversarial specialist review, and documentation-compliance checking.

### Karl E. Wiegers: Peer Reviews in Software

Wiegers's *Peer Reviews in Software* (2001) formalized inspection-style peer review as a distinct engineering discipline: a structured, checklist-driven pass that finds defects earlier and cheaper than testing alone. The skill's manual review step uses a structured checklist for exactly this reason.

URL: https://www.processimpact.com/books/PeerReviews.html

### Smartbear: State of Code Review

Smartbear's annual surveys of code-review practice document the measurable effect of structured reviews on defect density and time-to-fix. The skill's severity scheme (CRIT/WARN/SUGG) and its finding cap reflect the consistently measured finding that reviews of more than ~400 LoC per hour lose effectiveness. Caps prevent flood and prioritization drift.

URL: https://smartbear.com/resources/ebooks/the-state-of-code-review/

### Gene Kim, Jez Humble, et al.: Accelerate

*Accelerate* documents DORA research showing that high-performing teams rely on fast, automated, continuous review practices as part of their delivery flow. The skill's parallel agent dispatch during the manual review reflects this. Specialists and the reviewer work concurrently rather than in sequence.

URL: https://itrevolution.com/product/accelerate/

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule this skill applies before committing items. The two gates, the acceptable-evidence list, the named anti-patterns, and the deferral format.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [`/post-code-review-to-pr`](../han.github/post-code-review-to-pr.md). Wraps this skill and posts the review to a GitHub PR.
- [`/investigate`](./investigate.md). Next step when a CRIT finding hides a bug whose root cause needs deeper analysis.
- [`/architectural-analysis`](../han.coding/architectural-analysis.md). Run alongside when the change touches module boundaries.
- [Sizing](../../sizing.md). The cross-skill sizing model. Explains the small / medium / large bands, the default-to-small rule, and the `$size` override.
- [`junior-developer`](../../agents/han.core/junior-developer.md), [`adversarial-security-analyst`](../../agents/han.core/adversarial-security-analyst.md). The two agents this skill always dispatches.
- [`test-engineer`](../../agents/han.core/test-engineer.md), [`edge-case-explorer`](../../agents/han.core/edge-case-explorer.md), [`structural-analyst`](../../agents/han.core/structural-analyst.md), [`behavioral-analyst`](../../agents/han.core/behavioral-analyst.md), [`concurrency-analyst`](../../agents/han.core/concurrency-analyst.md). Conditional dispatches that join the roster when their signal appears in the file list.
- [`data-engineer`](../../agents/han.core/data-engineer.md), [`devops-engineer`](../../agents/han.core/devops-engineer.md). Conditional dispatches for changes touching schemas/migrations/queries (data) or infra/CI/observability (devops).
- [`on-call-engineer`](../../agents/han.core/on-call-engineer.md). Conditional dispatch when the change adds or modifies application source with runtime resilience surface (outbound calls, retry logic, queue/buffer handling, async/await code, error-handling on failure paths, idempotency, schema migrations co-deployed with dependent code, new production code paths). Hard boundary against `devops-engineer`: this agent reads application source only.
- [`SKILL.md` for /code-review](../../../han.coding/skills/code-review/SKILL.md). The internal process definition.

---
name: test-planning
description: >
  Produce a standalone test plan by analyzing code for test coverage gaps and
  edge cases. Use when you need to create, generate, or draft a test plan for a
  branch, need to analyze test coverage, or need to identify what tests to write
  for specific files or directories. Does not write test code — produces a plan
  document only; use tdd to implement behavior test-first through a
  red-green-refactor loop. Does not refine or iterate on existing plans — use
  iterative-plan-review to improve a previously drafted work plan. Does not review
  code quality, security, or style — use code-review for full code review.
  Does not evaluate architectural testability or structural coupling — use
  architectural-analysis for architectural assessment.
argument-hint: "[optional: file paths, directories, or description of what to test]"
allowed-tools: Bash(git *), Bash(find *), Bash(ls *), Read, Grep, Glob, Agent
---

## Operating Principles

- **Test behavior through the public API, never internals.** Every recommended test verifies observable behavior at a public seam: the inputs a real caller supplies, the outputs and side effects they observe, and the interactions the unit has with the other objects and services it collaborates with. Do not recommend tests that reach into private methods, internal state, or implementation structure — those tests pin the *how* and break on every refactor. When two designs would produce the same observable behavior, the test must pass for both. If a behavior can only be observed by inspecting internals, that is a signal the behavior belongs at a different seam, not a license to test the internal; note it and move the recommendation to the public boundary that exposes it. This is the depth ceiling: cover the critical behaviors a caller depends on, and stop. Do not specify tests for every branch, every private helper, or every intermediate value.
- **YAGNI is a first-class operating principle for tests.** Apply the evidence-based YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md). A test is worth recommending only when (a) the code under review commits to a behavior the test verifies and (b) the failure mode the test would catch is realistic for this codebase. Tests for code paths that don't exist yet, hypothetical adversaries the code doesn't face, hypothetical scaling problems the workload doesn't have, "completeness" with existing tests, or symmetry ("we have a test for create, so we should have one for delete") are YAGNI candidates and go to the Deferred Tests section with the trigger that would justify writing them. When many speculative low-level tests can be replaced by one durable behavioral test that catches the same realistic failure modes, recommend the single test instead. Every test is ongoing maintenance and a brittleness surface.

## Project Context

- git installed: !`which git`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Step 1: Determine Scope

Resolve project config: read CLAUDE.md's `## Project Discovery` section for test command (under `### Commands and Tests`, not `### Frameworks and Tooling`), language, and framework; fall back to project-discovery.md. Store found values for use in later steps.

**Scope determination:** Check `git installed` from Project Context. If empty, skip to **Mode C** below.

Run `${CLAUDE_SKILL_DIR}/scripts/detect-test-context.sh` and parse its output. If `git-available: false`, skip to **Mode C** below.

**Mode A: Full git context** — `git-available: true` and the output contains a `changed-files-start` block with content.
- If the user provided file paths, directories, or a description: use those as scope (do not go searching for plan files or try to locate plans)
- Otherwise: use the changed files list from the script output as scope

**Mode B: Uncommitted changes** — `git-available: true` but output contains `changed-files: none`.
- If the user provided scope: use it as-is
- Otherwise: run `git diff` (unstaged changes), `git diff --cached` (staged changes), and `git status --short` (untracked files) to identify changed files; if any files are found, use those as scope
- If no files found in any of those commands, fall through to **Mode C**

**Mode C: No git / no changes found** — git missing, not in a repo, or no changes detected in any state.
- If the user provided file paths, directories, or a description of what to test: use those as-is
- Otherwise: use Glob to discover source files in the current directory, excluding `node_modules/`, `.git/`, `vendor/`, `dist/`, `build/`, `__pycache__/`, lock files; present the discovered files and ask the user to confirm scope

Build a list of source files to analyze: expand directories to find source files; identify relevant source files from branch changes or project structure for descriptions.

## Step 2: Dispatch Testing Agents

Launch the testing agents **in parallel** using the `Agent` tool with `run_in_background: true`. Pass each agent the file list from Step 1. In Mode A or Mode B, include `on branch {branch}` in agent prompts if a branch name was detected by the script; in Mode C or when no branch was detected, omit the branch reference entirely. If the user described what they want tested, include that description in every agent prompt so they can focus their analysis.

### Always dispatch

1. **Launch han.core:test-engineer agent** — prompt: "Analyze test coverage for the following files{on branch {branch} if applicable}: {file list}. Recommend tests only at the public API: the inputs a real caller supplies, the outputs and side effects they observe, and the interactions the unit has with the objects and services it collaborates with. Do not recommend tests that reach into private methods, internal state, or implementation structure — if two implementations would produce the same observable behavior, the test must pass for both. Cover the critical behaviors a caller depends on and stop; do not specify a test for every branch, private helper, or intermediate value. Apply the YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md) — recommend a test only when the code commits to a behavior the test verifies AND the failure mode is realistic for this codebase. Symmetry, completeness, and hypothetical scaling are YAGNI; defer those to the Deferred Tests section with the trigger that would justify writing them. {any additional context from user arguments}"

2. **Launch han.core:edge-case-explorer agent** — prompt: "Explore edge cases for the following files{on branch {branch} if applicable}: {file list}. Focus on inputs, integration points, and error paths observable through the public API and through interactions with collaborating objects and services — not internal state or private implementation. Apply the YAGNI rule from [../../references/yagni-rule.md](../../references/yagni-rule.md) — raise an edge case only when a real caller produces the input, the failure mode has plausible production trigger, or the case is critical-path correctness regardless of caller. Hypothetical adversaries the code doesn't face and symmetry-driven boundaries go to Dropped Edge Cases with the trigger that would justify revisiting. {any additional context from user arguments}"

### Conditional dispatch

Inspect the file list before launching. Skip any that do not apply.

3. **Launch han.core:concurrency-analyst agent** — only if the file list touches threads, async/await, goroutines, actors, shared mutable state across requests, timers, locks, or message queues. Prompt: "Identify concurrency test gaps for the following files{on branch {branch} if applicable}: {file list}. Focus on race conditions, lock ordering, shared-resource contention, deadlock potential, and async error handling that should be covered by tests. {any additional context from user arguments}"

4. **Launch han.core:adversarial-security-analyst agent** — only if the file list touches authentication, authorization, input validation, data isolation, session handling, crypto, file uploads, external API calls with secrets, or SQL/ORM query construction. Prompt: "Identify negative security tests that should exist for the following files{on branch {branch} if applicable}: {file list}. Focus on exploit paths that tests could catch before production — authorization bypass, injection, broken isolation, insecure defaults. Return test recommendations, not general threat modeling. {any additional context from user arguments}"

Wait for every dispatched agent to complete and collect full output for processing in Step 3.

## Step 3: Merge and Prioritize

Combine findings from every dispatched agent into a unified, prioritized test plan:

1. **Classify findings** —
   - **han.core:test-engineer items** (T1, T2, ...): map High to CRIT or HIGH depending on the code path (security, data integrity, auth = CRIT; business logic, error handling = HIGH), Medium to MED, Low to LOW.
   - **han.core:edge-case-explorer items** (EC1, EC2, ...): map directly — Critical to CRIT, High to HIGH, Medium to MED, Low to LOW.
   - **han.core:concurrency-analyst items** (C1, C2, ...) when dispatched: races on auth/billing/isolation = CRIT; realistic load contention, async error swallowing = HIGH; theoretical interleaving = MED.
   - **han.core:adversarial-security-analyst items** (SEC-NNN) when dispatched: every item lands at CRIT. Retain the SEC-### cross-reference in the unified item so the source is visible.
2. **Apply the behavioral sweep** — walk every surviving recommendation and confirm it verifies observable behavior at a public seam (caller-supplied inputs, observed outputs and side effects, interactions with collaborating objects and services). Rewrite any item that asserts on private methods, internal state, or implementation structure so it tests the same behavior through the public boundary; if no public seam exposes it, drop the item and note that the behavior should be observed at a higher level rather than pinned to internals. Collapse multiple low-level items that protect the same observable behavior into the single behavioral test that catches the same realistic failure modes.
3. **Assign unified IDs** — sequential IDs: TP-001, TP-002, TP-003, etc. Include the original agent ID as a cross-reference (e.g., "TP-001 (from T3)", "TP-002 (from C1, concurrency)", "TP-003 (from SEC-001, security)").
4. **Order by priority** — interleave items from every agent by priority: all CRIT items first, then HIGH, then MED, then LOW. Within each priority level, order by the agent's own ranking.
5. **Cap at 40 items** — keep a maximum of 40 items total, prioritized by severity. Security items (SEC-derived) are exempt from the cap. If more than 40 non-security items exist, note how many were omitted and recommend running the skill again after addressing high-priority items.
6. **Apply the YAGNI sweep** — walk every test recommendation that survived classification and apply [../../references/yagni-rule.md](../../references/yagni-rule.md). Demote any test whose justification reduces to "completeness", "best practice", "for future flexibility", symmetry with another test, or hypothetical scaling/adversaries the change doesn't touch — these go to the Deferred Tests section with a `Reason: YAGNI — {gate failure}` and the trigger that would justify writing the test (a third real customer hits the edge case, the feature actually ships the path, a measured production failure occurs, etc.). When several recommended low-level tests can be replaced by one durable behavioral test that catches the same realistic failure modes, replace them with the single test and record the dropped low-level tests under Deferred with `Reason: YAGNI — single behavioral test catches the same realistic failure modes`.

## Step 4: Generate Output

Use the template at [template.md](references/template.md) for the output structure. The test plan leads with plain language and defers the implementation detail.

**Writing rules:**

Lead with behavior. These rules make the plan a human-readable overview first and an implementation outline second:

1. **Lead with the why.** Write the Summary, What Needs Testing and Why, and What Each Test Covers in plain language before the `## Technical Reference` region. Describe what needs testing and what would break without it, in functional terms a reader who has not seen the code can follow. Name files, types, and test levels only where they aid understanding.
2. **Summary is prose plus bullets.** Open with a 2-4 sentence plain-language paragraph: what was analyzed, the overall state of coverage, where the biggest risk sits, and what to test first. No file paths, no TP-IDs, no framework jargon in the paragraph. Then the scannable orienting bullets.
3. **What Needs Testing and Why groups the work into themes.** Cover the 2-4 themes a reader can hold in their head (e.g. "Authorization", "Payment edge cases", "Concurrent writes"), not every item. For each, explain in everyday terms what behavior needs coverage and why it matters — what could break, who is affected. End each theme by naming the test IDs that fall under it so the reader can jump to detail.
4. **What Each Test Covers narrates the tests in plain language.** Walk the tests in priority order. Lead each line with its test ID so it cross-links to the Technical Reference, then state what behavior it protects and what would break untested — not how to write it. Summarize a long low-priority tail in one line rather than listing each.
5. **Technical Reference is supporting detail.** Place the per-item Test Plan (with test level, code paths, test approach, priority justification), Deferred Tests, Dropped Edge Cases, Coverage Summary counts, and Scope under the `## Technical Reference` region, below the plain-language spine. A reader who only needs to know what to test and why can stop above.

**Fill in all sections:**

1. **Summary** — Plain-language paragraph plus orienting bullets (scope, coverage health, most significant gap, where to start). This is the qualitative coverage assessment, promoted to the top and written for a non-author.
2. **What Needs Testing and Why** — The themes, in plain language, each ending with the test IDs it covers.
3. **What Each Test Covers** — Every meaningful test as a plain-language line led by its TP-ID.
4. **Technical Reference → Test Plan** — All items from Step 3, grouped by priority tier. Every test plan item should include file:line references from the agent output, and preserve agent detail — carry through the test approach, code paths, and risk assessments into the merged output.
5. **Technical Reference → Deferred Tests** — Items the han.core:test-engineer excluded due to brittleness risk.
6. **Technical Reference → Dropped Edge Cases** — Items the han.core:edge-case-explorer intentionally excluded.
7. **Technical Reference → Coverage Summary** — Counts by priority tier.
8. **Technical Reference → Scope** — Scope type, file count, branch, language, test framework, and the list of files.

## Step 5: Review the Output

Dispatch two reviewers against the generated test plan, **in parallel**, using the `Agent` tool. The plan is produced in-channel, so embed the full plan text in each agent's prompt (in place of `{plan text}` below). If the plan was written to a file, pass that path instead and let the agent read it.

1. **Launch han.core:information-architect agent** — prompt: "Audit the following test plan for findability, orientation, and comprehension. The intended audience is an engineer or technically-literate stakeholder who needs to understand what needs testing and why before reading the implementation detail. Check: (1) Do the plain-language Summary, What Needs Testing and Why, and What Each Test Covers sections appear before the `## Technical Reference` region? If the plain-language content is missing or sits below the reference detail, that is a finding. (2) Does the Summary paragraph read for someone who has not seen the code — no file paths, TP-IDs, or framework jargon? (3) Does the heading list let a scanning reader see where the plain-language overview ends and the deep Technical Reference begins? (4) Do the What Each Test Covers lines cross-link to their TP-IDs so a reader can move from plain language to detail? Return a list of structural edits; do not return an empty list unless the plan leads with plain language and defers the implementation detail.\n\n{plan text}"

2. **Launch han.core:junior-developer agent** — prompt: "Review the following test plan as a generalist teammate who has not seen this code. Reading only the plain-language sections (Summary, What Needs Testing and Why, What Each Test Covers), can you understand what needs testing and why it matters without dropping into the Technical Reference? Flag any plain-language line that is unclear, leans on undefined jargon, assumes context a reader would not have, or states a test without conveying what would break if it were missing. Return a list of clarity findings with the section and line they apply to; return an empty list only if the plain-language layer stands on its own.\n\n{plan text}"

Apply every actionable edit the agents return. For findings that require author judgment (scope or audience ambiguity), surface them to the user with a recommended resolution; do not silently resolve.

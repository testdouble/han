# /work-the-issue-queue

Operator documentation for the `/work-the-issue-queue` skill in the han plugin. This document helps you decide *when* and *how* to use the skill. For what the skill does internally, read the skill definition at [`han-github/skills/work-the-issue-queue/SKILL.md`](../../../han-github/skills/work-the-issue-queue/SKILL.md).

> See also: [Plugin landing page](../../../README.md) · [All skills](../README.md) · [All agents](../../agents/README.md) · [YAGNI](../../yagni.md)

## TL;DR

- **What it does.** Works a queue of planned GitHub issues (the ones [`/work-items-to-issues`](./work-items-to-issues.md) published) in dependency order, one at a time, on a single shared branch. Each issue is implemented test-first by a fresh teammate session, reviewed by the lead, gate-checked, and closed.
- **When to use it.** You have a repo full of labeled, dependency-linked issues from `/work-items-to-issues` and you want them ground down hands-off, not picked up one by one.
- **What you get back.** Commits on the shared branch (one per slice, plus any lead fix commits), a `code-review` comment on each issue, closed issues, and a summary of what landed and what is still blocked or waiting. It never opens a pull request.

## Requirements

- **Agent Teams enabled.** The skill runs as an Agent-Teams lead that spawns one teammate per issue. It requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your `settings.json` and Claude Code 2.1.32 or newer. The skill stops hard at preflight if either is missing.
- **`gh` authenticated.** All GitHub reads and writes go through the `gh` CLI.
- **Permission rules for mid-run writes and gates.** The loop closes and comments on issues and runs the repo's gate commands while it runs. The auto-mode classifier prompts on those unless you allow-list them ahead of time, and a rule added mid-run needs a session reload to take effect. Add `Bash(gh issue close:*)`, `Bash(gh issue comment:*)`, and your repo's gate runner (for example `Bash(make *)` or `Bash(npm run *)`) to your `settings.json` allow list before you start.

## Key concepts

- **The fourth pipeline step.** The han planning pipeline runs `/plan-implementation` to `/plan-work-items` to `/work-items-to-issues` to this skill. The GitHub issues, not the `work-items.md` file, are the source of truth this skill consumes.
- **The queue label.** Membership in the queue is the label the issues carry, `ralph` by default, overridable with `--label`. Pass the same label you gave `/work-items-to-issues` when you published the issues. Issues without the label are not in the queue.
- **Dependency order from native blockers.** The skill reads each issue's `blocked_by` links (which `/work-items-to-issues` records as native, within-repo GitHub dependencies) and walks the queue so an issue runs only when every blocker is already closed. A dependency cycle stops the run rather than guessing an order.
- **One branch, sequential.** Every slice lands on one shared branch in one working tree, so exactly one teammate edits at a time. The skill works the queue strictly in order; parallelism would need a worktree per item and is out of scope.
- **Fresh teammate per item, lead reviews.** Each issue gets a brand-new teammate session that drives `/tdd` and commits when the mechanical gates are green. The teammate does not review its own work. The lead runs the one `/code-review` pass itself, because only the lead session can fan out the review's analyst sub-agents. A teammate's `code-review` would degrade to a single-session manual pass.
- **Critical-only auto-fix.** When the lead's review finds Critical findings, the lead fixes only those and commits the fix (with a covering test per behavioral fix). Warnings, suggestions, and YAGNI findings are reported, never silently changed.
- **The lead verifies before it closes.** Before closing an issue, the lead re-runs the canonical gates itself from clean committed state and confirms every named test exists. It never closes on a teammate's self-report alone.
- **Autonomous until done or blocked.** The run works the whole queue without pausing. It stops when the queue drains or a teammate reports a blocker it cannot clear, and on a blocker it stops the whole run rather than skipping ahead.
- **No pull requests.** The skill commits to the shared branch only. You open the PR.

## When to use it

**Invoke when:**

- You have a repo of `/work-items-to-issues` issues, labeled and dependency-linked, and you want them implemented, reviewed, and closed hands-off.
- You want each slice implemented test-first and reviewed with a real fanned-out `code-review`, not a rubber-stamp.
- You want the queue walked in dependency order with a per-issue audit trail on GitHub.

**Do not invoke for:**

- **Breaking a plan into issues.** Use [`/work-items-to-issues`](./work-items-to-issues.md) to publish the queue first. This skill consumes issues; it does not create them.
- **Opening a pull request.** The skill commits to the shared branch only. Open the PR yourself once the run finishes.
- **Reviewing code without implementing it.** Use [`/code-review`](../han-coding/code-review.md) for a local review, or [`/post-code-review-to-pr`](./post-code-review-to-pr.md) to post one to a PR.
- **Writing a single feature test-first.** Use [`/tdd`](../han-coding/tdd.md) directly when you are working one change by hand rather than draining a queue.

## How to invoke it

Run `/work-the-issue-queue` in Claude Code. It requires Agent Teams enabled and the `gh` CLI authenticated (see Requirements).

Arguments, all optional:

1. **`org/repo`.** The target repo. Inferred from the working tree's `git remote` when omitted.
2. **`--worktree <path>`.** The working tree teammates operate in. Defaults to the current directory.
3. **`--branch <name>`.** The shared branch to land commits on. Defaults to the current branch. The skill stops hard if this resolves to the repo's default or a protected branch, because it commits many times with no PR; pass a feature branch or re-confirm explicitly.
4. **`--label <name>`.** The queue-membership label. Defaults to `ralph`. Pass the label you gave `/work-items-to-issues`.
5. **`--assignee <user>`.** Scopes the queue to that assignee. Defaults to `@me`, so the run never picks up someone else's work. `--assignee any` includes every assignee and unassigned issues.
6. **`--dry-run`.** Print the ordered plan and the waiting list, then exit without creating a team or writing anything.

Example prompts:

- `/work-the-issue-queue --dry-run`. Show the ordered queue for the current repo and branch without touching anything.
- `/work-the-issue-queue org/repo --branch my-feature`. Work the `ralph`-labeled issues assigned to you, landing on the `my-feature` branch.
- `/work-the-issue-queue org/repo --branch my-feature --label backlog --assignee any`. Work every `backlog`-labeled open issue regardless of assignee.

## What you get back

- **Commits on the shared branch.** One implementer commit per slice, each referencing its issue (`(#NNN)`), plus any follow-up fix commits the lead added for Critical findings. The skill does not squash across a close; the fix history is intentional.
- **A `code-review` comment on each issue.** The lead posts its review as a comment for the audit trail: the gate results, each Critical finding, and the warning, suggestion, and YAGNI counts.
- **Closed issues.** Each issue is closed with a plain-language one-liner naming the commit it landed in and any residual non-critical findings.
- **A teardown summary.** A table of every item worked (done or blocked), its commit SHA, and its residual findings, plus any items still waiting on open blockers, and the branch and commit range so you can open the PR.

## How to get the most out of it

- **Set up permissions before you start.** Add the `gh issue close`, `gh issue comment`, and gate-runner allow rules to `settings.json` up front. A rule added mid-run needs a session reload, so a missing one stalls the loop after the first item.
- **Publish the queue with a clean label.** Run [`/work-items-to-issues`](./work-items-to-issues.md) with the label you intend to work, and pass the same label here. A sharp, dependency-linked breakdown makes the queue walk clean.
- **Land on a feature branch.** The skill commits many times with no PR. Give it a feature branch with `--branch`; it stops hard before landing on the default or a protected branch.
- **Dry-run first.** `--dry-run` shows the order it will take and what is waiting on open blockers, without creating a team. Use it to sanity-check the dependency graph before the real run.
- **Write real acceptance criteria into the issues.** Each teammate drives `/tdd` from the issue's Acceptance criteria and Tests sections. An issue that names no testable behavior makes the teammate stop and report blocked rather than invent criteria, so the sharper those sections are upstream, the further the run gets unattended.
- **Re-run to resume.** Closed issues are skipped, so a re-run after a stop resumes where it left off.

## YAGNI (when applicable)

YAGNI does not gate this skill's output directly. The issues are an already-committed decomposition, and this skill implements them. The place YAGNI belongs is upstream: if the plan behind the issues has not been through a YAGNI sweep, run [`/iterative-plan-review`](../han-planning/iterative-plan-review.md) on the plan before `/plan-work-items` breaks it into work items. The one YAGNI-adjacent gate inside this skill is the review pass: the lead's `code-review` surfaces YAGNI findings on the implemented slice, reported but never auto-fixed. See [YAGNI](../../yagni.md) for the two gates and the named anti-patterns.

## Cost and latency

This is the most expensive skill in the GitHub layer, because it runs a full implement-and-review cycle per issue. Each issue spawns a fresh teammate session that drives `/tdd`, and the lead then runs a fanned-out `/code-review` (its analyst sub-agents) plus the repo's gate commands. Cost scales with the number of issues and the size of each slice. The run is sequential by design (one shared branch, one working tree), so wall-clock time is the sum of the per-issue cycles, not a parallel fan-out. Use `--dry-run` to see the queue size before committing to a full pass, and expect a run to be a background, walk-away operation rather than an interactive one.

## In more detail

The skill walks a five-step process:

1. **Preflight.** Resolve the arguments, then verify Agent Teams is enabled, `gh` is authenticated, the permission rules are present, the working tree is clean, and the target branch is safe to land on. Load the target repo's `CLAUDE.md`, rules, coding standards, and CI config, and extract the canonical test, build, lint, and format-gate commands plus the protected paths. Stop hard on any failure.
2. **Build the queue.** List the open, labeled, in-scope issues, read each one's `blocked_by` links, and topologically sort. Runnable issues are those whose blockers are all closed; the rest go on a waiting list. A cycle stops the run. An empty result is disambiguated before stopping: the skill re-checks with `--state closed` under the same scope. If issues carrying the label are all closed, it reports the queue complete (the resumability case, when you re-run after the queue is drained). Only when no issues exist under the scope at all does it stop with the label or scope mismatch note, naming the resolved label and assignee and the two likely fixes (published without a matching label, or the work is assigned to someone else). `--dry-run` prints the plan and exits here.
3. **Create the team and a status ledger.** Create the Agent Team with this session as lead, and record each runnable issue as a status task. The task list is a ledger only; the lead is the sole dispatcher and enforces order from live GitHub state, never from the task list.
4. **The loop.** For each item in order, re-check the working tree, spawn a fresh implementer teammate with the slice brief, wait for its report, run the lead `code-review` pass, fix any Critical findings, re-run the gates from clean committed state, and close the issue. A blocker stops the whole loop.
5. **Teardown.** Print the summary table, shut down the team, and hand you the branch and commit range so you can open a PR. Re-running is safe, because closed issues are skipped.

The design rests on one Agent-Teams fact: a teammate session does not get the `Agent` tool, so it cannot spawn sub-agents. That is why `code-review` runs at the lead (where it fans out its analysts) and not inside the implementer teammate (where it would degrade to a single-session pass). The [teammate brief](../../../han-github/skills/work-the-issue-queue/references/teammate-brief.md) carries both the implementer instructions and the lead review checklist, and the [dependency-graph reference](../../../han-github/skills/work-the-issue-queue/references/dependency-graph.md) carries the exact `gh api` recipe for reading `blocked_by` and ordering the queue.

## Related documentation

- [Plugin landing page](../../../README.md). The front door. Start here if you arrived from outside the docs tree.
- [Skills Index](../README.md). All skills, grouped by purpose.
- [YAGNI](../../yagni.md). The evidence-based "You Aren't Gonna Need It" rule. This skill does not gate on it; enforcement belongs upstream.
- [`/work-items-to-issues`](./work-items-to-issues.md). Pair upstream to publish the issue queue this skill works.
- [`/plan-work-items`](../han-planning/plan-work-items.md). Two steps upstream: break a trusted plan into the work items that become issues.
- [`/tdd`](../han-coding/tdd.md). The skill each implementer teammate runs to build its slice test-first.
- [`/code-review`](../han-coding/code-review.md). The review the lead runs on each committed slice.
- [`/post-code-review-to-pr`](./post-code-review-to-pr.md). The sibling GitHub skill for posting a code review to a pull request.
- [Teammate brief](../../../han-github/skills/work-the-issue-queue/references/teammate-brief.md). The per-issue implementer brief and the lead review checklist.
- [Dependency graph reference](../../../han-github/skills/work-the-issue-queue/references/dependency-graph.md). How the skill reads `blocked_by` and orders the queue.
- [`SKILL.md` for /work-the-issue-queue](../../../han-github/skills/work-the-issue-queue/SKILL.md). The internal process definition.

---
name: work-the-issue-queue
description: >
  Autonomously work a queue of planned GitHub issues (those published by
  work-items-to-issues) in dependency order, one at a time, on a single shared
  branch. For each issue it spawns a fresh teammate session that implements the
  slice test-first with the `tdd` skill and commits once the gates are green, then
  the lead runs the `code-review` skill itself (the one fanned-out review pass),
  fixes any Critical findings and commits them, verifies the gates, and closes the
  issue — moving on until the queue is empty or it hits a blocker it cannot clear.
  Use when the user wants to "work the issues", "run the queue", "burn down the
  planned work items", or grind through a published work breakdown hands-off.
  Requires Agent Teams (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1, Claude Code 2.1.32
  or newer). Does not break a plan into issues — that is work-items-to-issues. Does
  not open pull requests. Runs against one repo and one branch per pass.
argument-hint: "[org/repo] [--worktree PATH] [--branch NAME] [--label ralph] [--assignee @me] [--dry-run]"
allowed-tools: Read, Grep, Glob, Agent, SendMessage, TaskCreate, TaskList, TaskGet, TaskUpdate, TaskStop, TaskOutput, Bash(gh *), Bash(git *), Bash(make *), Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(yarn *), Bash(task *), Bash(just *), Bash(go *)
---

## Project Context

- claude version: !`claude --version 2>/dev/null`
- agent teams flag: !`echo "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-unset}"`
- gh auth: !`gh auth status 2>&1 | head -1`
- cwd: !`pwd`
- current branch: !`git branch --show-current 2>/dev/null`
- working tree clean: !`git status --porcelain 2>/dev/null | head -1 | grep -q . && echo "DIRTY" || echo "clean"`

## What this skill is

This is the **fourth** step of the han planning pipeline:

```
plan-implementation → plan-work-items → work-items-to-issues → work-the-issue-queue
   (the plan)          (work-items.md)     (GitHub issues)        (←— this skill)
```

`work-items-to-issues` has already published each plan slice as a GitHub issue. Those
issues are the source of truth this skill consumes — **not** the `work-items.md` file. By
the time you run this, each issue:

- carries the **queue label** (the `--label` value, `ralph` by default — the queue-membership
  signal; pass the same label you gave `work-items-to-issues`),
- holds the full slice body in its **issue body** (Summary / Description / References /
  Tests / Acceptance criteria) — this is the teammate's brief,
- has its `Depends on` relationships recorded as **native GitHub `blocked_by`** links
  (within-repo only, since `work-items-to-issues` never links a native blocker across repos).

So the queue is: *open labeled issues in the target repo, walked in `blocked_by` order.*
Closing each issue when its work lands is how the board stays truthful.

## Why Agent Teams (read before changing the architecture)

This skill runs as an Agent-Teams **lead** that spawns one teammate at a time. The reason it is
a team and not a flat loop is that an Agent-Teams **teammate is a full Claude Code session** —
it can invoke the han `tdd` skill, read the repo's rules, and drive a slice test-first with
clean, scoped context — a persistent session the lead can nudge mid-flight, one per item.

**What a teammate can NOT do — verified by direct test:** teammates don't get the `Agent` tool
(the subagent-nesting limit — a subagent cannot spawn its own subagents). A spawned teammate's
entire toolset is `Bash, Edit, Read, Skill, ToolSearch, Write` — `Agent` is absent and not even
loadable via `ToolSearch`, and wrapping the spawn in a skill (`allowed-tools: Agent`) does **not**
grant it. So `code-review` run *inside* a teammate **cannot** fan out its analyst sub-agents — it
degrades to a single-session manual pass, every time. Only the **lead** (the main thread) holds
the `Agent` tool, so a fanned-out `code-review` can run **only** at the lead. That is why the
review below is the lead's own job, not a teammate's.

How this skill gets a real review gate anyway — **the lead reviews, plus a lead gate**:

1. An **implementer teammate** drives `tdd` and commits once the mechanical gates are green
   (test, build, lint, format). It does **not** review its own code — marking your own homework
   adds little (in previous trials implementers reported clean while real CRITs remained), so
   review authority lives entirely with the lead below.
2. The **lead itself runs `code-review`** on the implementer's commit (Step 4) — a fanned-out,
   independent pass, possible because the lead is the one session that can spawn the analysts. The
   lead fixes any CRIT findings directly and commits the fixes. (An earlier design used a separate
   reviewer teammate here; that was a mistake — a teammate can't fan out, so it neutered exactly
   the review we depend on.)
3. Before closing, the **lead independently runs the canonical gates** from clean committed
   state (Step 4, step 5) — it never closes on a teammate's self-report alone.

Two more consequences that shape everything below:

- **Sequential, not parallel.** All items land on **one shared branch** in **one working
  tree**, so only one teammate may edit at a time. This skill works the queue strictly in
  order. (Parallelism would require a worktree per item — out of scope for v1.)
- **Fresh teammate per item.** Each issue gets a brand-new teammate session so its context
  is clean and scoped to one slice. Do not reuse one long-lived teammate across items.

## Constraints (these override any instinct to move faster)

- **Critical-only auto-fix.** The **lead** runs the one `code-review` pass; when it finds
  **Critical (CRIT)** findings ("must fix before merge"), the lead fixes **only** those itself and
  commits the fixes (with a covering test per behavioral fix). Warning / Suggestion / YAGNI
  findings are **reported, never silently changed** — surfaced to the user and recorded as an
  issue comment.
- **One issue, one close — commits may be more than one.** An item is done only when the
  mechanical gates pass and the lead's `code-review` leaves zero CRIT; then — and only then — the
  lead closes the issue. The happy path is one implementer commit per slice, but a lead CRIT fix
  (Step 4, step 4) legitimately adds a follow-up commit on the same issue. The invariant is **one
  close per issue**, not one commit. Do not squash across the close — the fix history is intentional.
- **Autonomous until done or blocked.** Run the whole queue without pausing. Stop only when
  the queue drains or a teammate reports a blocker it cannot clear. On a blocker, **stop the
  whole run** — do not skip ahead to unrelated items.
- **Plain language for anything needing a human.** Every blocker comment and every summary
  item that asks for human input leads with a non-technical sentence, then the minimal
  technical detail.
- **Respect the target repo's guidelines.** Before any work, read the target repo's root
  `CLAUDE.md` and any `.claude/rules/`, plus the coding standards and CI config that apply to the
  work, and pass the **canonical test / build / lint / format commands** into every teammate brief.
- **No pull requests.** This skill commits to the shared branch only. The user opens PRs.
- **No throwaway scripts.** Inline the `gh` / `git` calls; do not write helper scripts to disk.

---

## Step 1 — Preflight (stop hard on any failure)

Resolve arguments first:

- **`org/repo`** — passed explicitly, or inferred from the worktree's `git remote`.
- **`--worktree`** — the working tree teammates operate in (defaults to cwd).
- **`--branch`** — the shared branch (defaults to the current branch).
- **`--label`** — the queue-membership label; defaults to `ralph`. Pass the same label you gave
  `work-items-to-issues` when you published the queue.
- **`--assignee`** — defaults to `@me`, so the run never picks up work assigned to someone else.
  `--assignee any` includes every assignee and unassigned issues; a specific login scopes to that
  person. State the resolved assignee in the Step 2 plan announcement.

Then verify every line below. If any fails, print the problem and **stop** — do not start a team.

1. **Agent Teams enabled.** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` must equal `1` and
   `claude --version` must be ≥ `2.1.32`. If not, print this and stop (a restart is required
   after editing settings):

   ```jsonc
   // ~/.claude/settings.json
   { "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
   ```

2. **`gh` authenticated** and the target repo reachable (`gh repo view <org/repo>`).
3. **GitHub-write and gate-runner permission rules present.** This skill closes and comments on
   issues *mid-run* (Step 4), and the lead runs the repo's gate commands itself (Step 4, step 5).
   Even with those tool shapes in `allowed-tools`, the auto-mode classifier **denies or prompts on
   those calls** without an explicit permission rule in `settings.json` — and a rule added mid-run
   only takes effect after a session reload, so the run stalls after the first item. Confirm these
   rules exist in `~/.claude/settings.json` (or the project's `.claude/settings.json`) **before**
   starting; if absent, print this and stop:

   ```jsonc
   // settings.json → "permissions" → "allow"
   "Bash(gh issue close:*)",
   "Bash(gh issue comment:*)",
   // plus the target repo's gate runner, whichever it is, e.g.:
   "Bash(make *)"          // or "Bash(npm run *)", "Bash(task *)", "Bash(just *)", ...
   ```

   (Read-only `gh issue list` / `gh issue view` / `gh api ... GET` are not writes and are not
   affected.) The skill's `allowed-tools` already permits the common gate runners
   (`make`/`npm`/`npx`/`pnpm`/`yarn`/`task`/`just`/`go`), so the lead *can* call them — but the
   `settings.json` allow rule is what keeps the autonomous loop from pausing for approval on every
   gate run. If the repo's runner is not in the `allowed-tools` list above, add it there too. If you
   cannot edit settings, fall back to running in a mode where the user approves each prompt — but
   warn that the loop will pause for approval after every item.
4. **Clean working tree, and `--branch` is safe to land on.** The tree at `--worktree` must be
   clean and on `--branch`. If the branch does not exist, create it from the repo's default
   branch and say so. If the tree is dirty, stop.
   - **Guard the default/protected branch.** This skill lands many commits directly on the
     shared branch with no PR. Resolve the repo's default branch
     (`gh repo view <org/repo> --json defaultBranchRef -q .defaultBranchRef.name`); if
     `--branch` equals it (or a branch the repo marks protected), **stop hard** and tell the
     user, in plain language: "About to commit N items straight onto `<branch>`, the repo's
     default branch — that bypasses review. Pass `--branch <feature-name>` to land on a feature
     branch, or re-run with explicit confirmation to target the default branch." Proceed onto
     the default branch only on that explicit re-confirmation.
5. **Target-repo guidelines loaded.** Read the target repo's `CLAUDE.md`, any `.claude/rules/`,
   coding-standard filenames (list them; load only what relates to the work), and CI config.
   Extract the canonical **test**, **build**, **lint**, and **format-gate** commands into a
   `$repo_commands` binding reused in every teammate brief. The format gate is separate from
   lint: a passing linter does **not** imply a clean formatter, and in a previous trial it was
   exactly the format gate (a formatter reordering a `//nolint` directive) that failed the merge
   build. Resolve it from the target repo's CI config — whatever the merge gate runs to
   assert formatting (for example `go fmt ./... && git diff --exit-code`, or `prettier --check`).
   If you cannot determine the commands, ask the user once.

   **Gates that cannot run locally.** Some merge gates need env vars or secrets the local tree
   does not have — e.g. a build whose SSR step exits without an API target set. For each
   canonical gate, determine up front whether it can truly run green locally. If one cannot, do
   **not** let the lead silently substitute a weaker check ("it compiles") for it. Either
   (a) obtain the required env from the user/devops and run it for real, or (b) record it as a
   **disclosed skip** — the gate name, why it can't run locally, and the weaker check actually
   performed — and surface that in every brief and in the Step 5 teardown. A gate the lead could
   not truly verify is never reported as green.

   **Declare protected / out-of-scope paths.** Identify directories the queue must not touch
   (e.g. `design/`, generated artifacts, sibling-owned files) and bind them as `$protected_paths`.
   Inject this list into every teammate brief, and require **path-scoped commits** (`git add` only
   the slice's files, never `git add -A`/`git add .`) so an out-of-scope stray can't be swept into
   a slice commit.

   **The lead runs these gate commands itself before closing each item (Step 4, step 5)**, so it
   needs Bash permission for them. `allowed-tools` pre-authorizes the common runners
   (`make`/`npm`/`npx`/`pnpm`/`yarn`/`task`/`just`/`go`); if the target repo's gate runner is not
   among them, confirm it is allow-listed before starting, or the lead's gate verification will
   stall on a permission prompt mid-run (see step 3).

## Step 2 — Build the queue from GitHub

1. List candidates: `gh issue list --repo <org/repo> --label <label> --state open
   --assignee <assignee> --json number,title,assignees,body --limit 200`. The default
   `<assignee>` is `@me`. When `--assignee any` was passed, **omit** the `--assignee` flag
   entirely (so every assignee and unassigned issues are included).
   - **Empty result → inform and stop.** If the list comes back with **zero** open issues, do not
     report an empty queue as success — that reads as "all done" when the real cause is almost
     always a label or scope mismatch. Stop and say so in plain language, naming the resolved
     `--label` and `--assignee`: "No open issues carry the `<label>` label"
     (for `@me`, add "assigned to you"). Then name the two likely fixes: the queue was published
     without a matching label (re-run `work-items-to-issues` with `--label <label>`, or re-run
     this skill with the `--label` you actually used), or the work is assigned to someone else
     (try `--assignee any`). Do **not** create a team.
2. For each issue, read its native blockers (see
   [references/dependency-graph.md](references/dependency-graph.md) for the exact `gh api`
   recipe): `GET repos/<org/repo>/issues/<N>/dependencies/blocked_by`.
3. **Topologically sort** by `blocked_by`. An issue is **runnable** only when every blocker is
   already **closed** (a blocker that is still open but outside this scoped set — wrong label, or
   assigned to someone else under `--assignee @me` — means the queue is incomplete; surface it,
   do not treat the item as runnable). Drop runnable-blocked items to a "waiting" list and report them.
4. If a dependency **cycle** is detected, stop and report the cycle in plain language — do not
   guess an order.
5. **`--dry-run`:** print the ordered plan — `#NNN — title (blocked_by: …)` per line, plus the
   waiting list — and **exit without creating a team or writing anything.**

## Step 3 — Create the team and a status ledger (the lead owns dispatch and order)

The shared task list is a **status ledger only** — what's queued, in progress, and done, for
visibility and resumability. It is **not** the dispatcher.

The Agent-Teams runtime auto-assigns open tasks to teammates. So if the lead *also* spawns a
teammate for the same item (Step 4), the runtime dispatches it a second time. To keep one
dispatch channel, the lead is the **sole dispatcher**: it spawns each teammate explicitly
(Step 4) and enforces order in its own pick logic by re-reading live `blocked_by` from GitHub —
never delegating order or dispatch to the task list.

1. Create the Agent Team with this session as lead.
2. For each **runnable** issue, `TaskCreate` one task whose subject is `#NNN — title`, with the
   issue number in `metadata.issue` and the worktree/branch/commands in the description. This
   records the queue; it does not assign work.
   - **Do not** call `addBlockedBy` to encode the dependency graph here. Mirroring `blocked_by`
     into the task list invites the runtime to auto-assign an item the instant it unblocks — the
     exact second dispatch channel this skill must avoid. Ordering lives in the lead's Step 4
     pick logic, which re-reads live `blocked_by` from GitHub, not in the task list.
3. Announce the plan to the user: N items queued, the order, M waiting on still-open blockers.

## Step 4 — The loop (sequential)

Walk the topologically sorted queue from Step 2. Repeat until every queued item is either done or
already-closed, or until a teammate reports `blocked`:

**Before each pick, re-check the working tree.** Cleanliness is verified at preflight, but files
can go dirty *between* items from outside any slice (a stale design-doc conflict, an editor
writing a sidecar file). At the top of every iteration, run `git status --porcelain` at
`--worktree`. If anything outside the current slice's scope is dirty, **stop the loop** and
surface it in plain language rather than letting the next teammate sweep it in — the next teammate
runs the formatter and a path-broad commit, so an out-of-scope stray would be committed silently.
See the contamination playbook in "Failure modes" for the stash-aside recipe.

1. **Pick** the next item in topological order whose **live** `blocked_by` on GitHub are all
   closed and whose own issue is still open (`gh issue view #NNN --json state`; re-read blockers
   per [references/dependency-graph.md](references/dependency-graph.md)). Skip-and-mark-done any
   item whose issue is already closed (resumability). Order is decided here, in the lead's code —
   not by the task list.
2. **Spawn a fresh implementer teammate** and hand it the brief verbatim from
   [references/teammate-brief.md](references/teammate-brief.md), interpolating: the issue body,
   `--worktree`, `--branch`, `$repo_commands` (incl. the format gate), `$protected_paths`, and `#NNN`. The brief
   instructs the teammate to: run `tdd` against the Acceptance criteria + listed Tests → confirm
   test/build/lint/format-gate pass (with the fidelity check) → commit on `--branch` with a
   message referencing `#NNN` → **report back** a structured result. The implementer does **not**
   run `code-review`; the **lead** runs the one review pass itself (step 4).
3. **Wait for the implementer's report.** Primary signal is the teammate's SendMessage report,
   but reports are unreliable on first send (in previous trials several teammates only reported
   after a nudge, and one never did). If the teammate goes idle without reporting: **verify the
   `(#NNN)` commit landed (`git log --oneline` on `--branch`), then nudge it via SendMessage to
   re-send its report verbatim.** Don't fall back to `TaskGet`/`TaskOutput` — teammates
   self-complete their task, so it's gone by the time you look (`TaskUpdate` → "Task not found").
   The committed `(#NNN)` on the branch is the real signal.
   - **How the lead waits.** Don't busy-poll. Background any lead-run gate command
     (`run_in_background`) so waiting doesn't block, treat the teammate's SendMessage report as
     the primary wake signal, and use a `ScheduleWakeup` heartbeat (≈ the target repo's CI
     duration) only as a fallback for a report that never arrives. The committed `(#NNN)` on the
     branch stays the source of truth.
   - On implementer `blocked` → go to step 6 (blocked handling). Do **not** run the review.
4. **The lead runs `code-review` itself** once the implementer's `(#NNN)` commit is on the branch.
   This is the **only** review pass, and it runs at the lead because the lead is the one session
   that can fan out the analyst sub-agents — a teammate cannot (see "Why Agent Teams"). Follow the
   lead review checklist in
   [references/teammate-brief.md](references/teammate-brief.md) (the "Lead review pass" section):
   review the `(#NNN)` commit against the slice's Acceptance criteria, run `code-review` (it fans
   out here), check for acceptance-criteria seam gaps, and **post the review as a comment on issue
   #NNN** (audit trail; covered by the Step 1 `Bash(gh issue comment:*)` rule).
   - **Fix any CRIT findings directly, then commit the fixes.** The lead already has the findings
     in hand, so it fixes the Criticals itself and commits them on `--branch` with a message
     referencing `#NNN` (a follow-up commit — expected, per Constraints). Add or update a test that
     proves each behavioral fix; do not fix a CRIT blind. Then proceed to step 5. There is **no
     re-review loop** — the lead's gate run (step 5) is the backstop.
   - If a CRIT cannot be cleanly fixed (genuinely ambiguous, or needs a decision only the user can
     make) → treat the item as **blocked** (step 6) with a plain-language note; do not guess.
5. **On `done` — lead independently verifies the gates before closing.** Do not close on the
   teammates' self-reports alone. From clean committed state at `--worktree` on `--branch`, the
   **lead itself** runs the canonical gates (`$repo_commands`: test, build, lint, **and the
   format gate**) and confirms green.
   - For any gate marked a **disclosed skip** in Step 1 (can't run locally for want of env/
     secrets), the lead runs the agreed weaker check instead and records it as
     `<gate>: skipped (reason)` in the close comment and teardown — never as `pass`.
   - **Every named test exists.** Before closing, confirm each test the slice's **Tests** /
     **Acceptance criteria** sections name by description has a corresponding real test in the
     commit. A required-but-absent test (behavior correct, test missing) is a close blocker, not
     a suggestion: treat the item as **blocked** (step 6) with a plain-language note naming the
     missing test — do not close with it recorded as a mere residual finding.
   - If the lead's gate run fails → treat as `blocked` (step 6); the self-reports were wrong.
   - If green: `gh issue close #NNN --comment "<plain-language one-liner> — landed in <commit
     SHA> on \`<branch>\`. Residual non-critical findings: <WARN/SUGG/YAGNI counts, or 'none'>."`
   - `TaskUpdate #task completed` (ignore "Task not found" — the teammate may have self-completed);
     ask the implementer teammate to shut down; continue to the next item.
6. **On `blocked`:**
   - Leave the issue **open**. Post the plain-language blocker as an issue comment
     (`gh issue comment #NNN`), leading with one non-technical sentence, then the minimal detail.
   - Ask any live teammates to shut down.
   - **Stop the loop** and go to teardown with a blocked status.

## Step 5 — Teardown

1. Print a summary table: `#NNN | title | done/blocked | commit SHA | residual WARN/SUGG/YAGNI`.
   Name any items still **waiting** on open blockers.
2. Ask any remaining teammates to shut down; end the team.
3. **Do not** open a PR. Tell the user the shared branch and commit range so they can open one.
4. Note that re-running is safe: closed issues are skipped, so the run resumes where it stopped.

## Failure modes to handle explicitly

- **Teammate cannot make tests pass** → it reports `blocked` with the failing command + output
  excerpt. Lead stops (Step 4, step 6).
- **Lead's own gate run fails after a teammate reported `done`** → the self-report was wrong;
  the lead treats it as `blocked` (Step 4, step 5 → 6) rather than closing the issue.
- **Lead's `code-review` finds CRITs** → the lead fixes them itself and commits the fixes (with a
  covering test per behavioral fix), then proceeds to the gate run and close. There is no
  re-review loop; the gate run (Step 4, step 5) is the backstop. A CRIT the lead cannot cleanly
  fix → `blocked`.
- **Issue body lacks acceptance criteria / tests** → teammate reports `blocked` asking for the
  missing detail; do not invent acceptance criteria.
- **Branch diverged / merge needed mid-run** → lead stops and reports; this skill does not rebase.
- **Out-of-scope file goes dirty mid-run (working-tree contamination)** → a file unrelated to any
  slice (e.g. a `design/` doc with a stale merge conflict, or an editor sidecar) appears between
  items. Do **not** let it ride into the next slice's commit. Stop the loop, show the user the
  dirty paths in plain language, and offer to stash it aside. `git stash` refuses unmerged paths,
  so for a conflicted file the recipe is: back up first (`cp <path> /tmp/<name>.bak`), then
  `git add <path>` and `git stash push -- <path>`. Resume only once the tree is clean. Pair this
  with declared **protected paths** (Step 1) so strays can't be `git add -A`'d in.
- **Runtime may re-dispatch an already-finished item.** Across trials this has ranged from "every
  completed item at least once" to "never once in 8 items" — it is not reliably predictable, so
  don't architect around either its presence or its absence. The Step 3 single-dispatch design (no
  `addBlockedBy`, lead as sole dispatcher) does not guarantee its absence — don't rely on it for
  that. The actual protection is the
  **teammate idempotency guard** (Step 1 of the brief): every re-dispatched teammate confirms the
  `(#NNN)` commit already exists, no-ops, and reports `done` without a second commit. Keep the
  guard; the lead still never spawns a fresh teammate for an issue it has already closed.

## Provenance

Built as the queue-runner companion to `work-items-to-issues`, the third step of the han planning
pipeline. Keep all target-specific assumptions (repo names, the queue label, the gate commands,
protected paths) in the *invocation arguments and the target repo's own config*, not hard-coded in
this body.

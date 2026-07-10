# Reading the `blocked_by` graph and ordering the queue

`work-items-to-issues` records each `Depends on` relationship as a **native GitHub issue
dependency** via `POST repos/<repo>/issues/<N>/dependencies/blocked_by` (see that skill's
`scripts/link-blockers.sh`). Those links are always **within-repo** — a cross-repo `Depends on`
is a format error `work-items-to-issues` refuses, so every blocker you read back lives in the
same repo as the issue it blocks. This skill reads the same relationships back to order the queue.

## Read an issue's blockers

```bash
# Issues that BLOCK issue N (i.e. N is blocked_by these), all within the target repo.
gh api "repos/<org/repo>/issues/<N>/dependencies/blocked_by" \
  --jq '.[] | {number: .number, state: .state}'
```

Each returned issue has at least `number` and `state` (`open` / `closed`). An empty array
means no blockers — the issue is a queue root.

> If this endpoint returns 404/410 on a given GitHub plan or the dependencies feature is
> unavailable, fall back to parsing `Depends on` SYMs from the source `work-items.md`
> (the `## SYM-N (#NNN) — title` headings map SYM→issue number). Surface that you fell back.

## Build the order

1. Collect open queue-labeled issues scoped to the run's assignee
   (`gh issue list --label <label> --state open --assignee @me`; omit `--assignee` only when the
   caller passed `--assignee any`). The default `<label>` is `ralph`.
2. For each, fetch `blocked_by` (above). Build a directed graph: edge `blocker → blocked`.
3. **Runnable now** = every blocker is `closed`. Closed blockers are satisfied dependencies;
   the run earlier in this same session will have closed upstream items, so re-fetch state
   each loop iteration rather than caching it.
4. **Waiting** = has at least one `open` blocker. Report these; they become runnable as their
   blockers close during the run.
5. **Topological order** among runnable items: lowest issue number breaks ties (issues are
   created in slice order by `work-items-to-issues`, so number order already approximates plan
   order).
6. **Cycle** = a strongly-connected component of size > 1. Stop and report it in plain language;
   never guess an order through a cycle.

## Record runnable issues in the shared task list (status ledger only)

For each runnable issue, create one team task as a **status record** — not a dispatch instruction:

```
TaskCreate  subject="#<N> — <title>"  metadata.issue=<N>  description=<worktree/branch/commands>
```

**Do NOT call `addBlockedBy`.** Mirroring the `blocked_by` graph into the task list makes the
Agent-Teams runtime auto-assign an item the instant it unblocks — a second dispatch channel that
fights the lead's sole-dispatcher design (see SKILL.md Step 3). Ordering lives only in the lead's
Step 4 pick logic, which re-reads live `blocked_by` from GitHub each iteration.

Because closed-blocker issues are skipped on re-run, the construction is idempotent: a second run
rebuilds the task list from whatever is still open and resumes cleanly.

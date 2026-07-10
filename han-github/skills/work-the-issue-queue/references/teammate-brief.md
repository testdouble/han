# Teammate brief — one work item

The lead spawns a **fresh teammate session per issue** and sends this brief, interpolating the
bracketed placeholders. The teammate is a full Claude Code session — it can invoke skills like
`tdd`, but it can NOT spawn its own sub-agents. (Code review is **not** the implementer's job; the
lead runs it once, independently — see the "Lead review pass" section below.) Everything in this
first section is addressed to that implementer teammate.

---

You are implementing **exactly one** planned work item and reporting back. Do not touch any
other issue or any work outside this slice.

## Your work item

- **Issue:** #[NNN] — [TITLE]
- **Repository working tree:** `[WORKTREE_PATH]` — do all work here.
- **Shared branch:** `[BRANCH]` — you are already on it. Commit here. Do **not** create a new
  branch, do **not** open a PR, do **not** push unless the lead's repo guidelines require it.
- **Canonical commands for this repo** (use these exact ones, not guesses):
  - test: `[TEST_CMD]`
  - build: `[BUILD_CMD]`
  - lint: `[LINT_CMD]`
  - format gate: `[FMT_CMD]` — the merge gate's formatter check, separate from lint. A passing
    linter does **not** mean the formatter is clean; this gate is what fails the merge build if
    code is unformatted. Run it as part of every green-check below.
- **Out-of-scope / protected paths** (do not create, edit, or stage these): `[PROTECTED_PATHS]`.

## The slice (verbatim issue body)

[ISSUE_BODY]

## What to do, in order

1. **Confirm this item is not already done (idempotency check).** Before doing any work, check
   whether issue #[NNN] is already finished:
   - `gh issue view [NNN] --json state` — if it is already **closed**, do nothing and report
     `done` immediately (commit: the existing one if you can identify it, else `n/a — already
     closed`). Do not re-implement and do not create a second commit.
   - `git log --oneline -20` on `[BRANCH]` — if a commit already references `(#[NNN])`, the slice
     is already committed; do nothing and report `done` citing that commit.
   This is a deliberate guard: the team runtime can hand you a work item that was already
   completed by an earlier dispatch. A second commit for the same slice is a defect — never
   produce one.

2. **Read the repo's rules first.** `CLAUDE.md`, any `.claude/rules/`, relevant coding standards,
   and any ADR or contract the slice's **References** section names. The slice is the *what*;
   the repo's standards are the *how*. They win over your defaults.

3. **Implement test-first with the `tdd` skill.** Invoke `tdd`, driven by this slice's
   **Acceptance criteria** and **Tests** sections as the behavior list. Honor the
   observed-failure gate — no production change without a failing test first. If the slice has
   no acceptance criteria or no testable behavior stated, **stop and report `blocked`** asking
   for it; do not invent criteria.

4. **Confirm green — and confirm the green means what you think.**
   Run test, build, lint, **and the format gate** (the exact commands above). All must pass —
   the format gate included; `lint` passing does not cover it.

   If this slice is a **consolidated or cross-cutting test suite** (it pulls together coverage
   spanning several earlier slices), first **inventory the existing integration tests** and do
   not duplicate coverage an earlier slice already owns — extend or reference it instead.

   Then, before you trust those passes, apply the **fidelity check**: a passing test only
   proves the path it actually ran. For each test you are relying on as evidence an acceptance
   criterion is met, confirm it drives the behavior the way the *running application* does —
   same startup/initialization, same entry point, same wiring — not through a setup shortcut
   the real system never takes. If a test reaches its starting state by a different route than
   the deployed app would, green proves the shortcut works, not the feature. When they differ,
   route the test through the real path (or add one that does) before reporting `done`.

   If you cannot make them pass, **report `blocked`** with the failing command and an output
   excerpt — do not mark the item done.

5. **Commit** on `[BRANCH]`. One logical commit for the slice. Message:
   - subject references the issue: `<concise change> (#[NNN])`
   - body: one plain-language sentence on what changed and why.
   **Stage by path — `git add <the files this slice changed>`, never `git add -A` or `git add .`.**
   Do not commit unrelated files; the **Out-of-scope / protected** paths above are off-limits.
   Do not amend or rewrite other commits on the branch.

## Report back (your final message to the lead — make it the literal return value)

**Send your report to the lead via SendMessage.** Reports sometimes don't arrive on the first
send. If you go idle without the lead acknowledging your report, expect a nudge — when nudged,
**re-send the report verbatim**. Do not assume your first send landed.

Report one of these two shapes, nothing else:

**Done:**
```
status: done
issue: #[NNN]
commit: <full SHA>
tests: pass | build: pass | lint: pass | format-gate: pass
notes: <one plain-language line; "none" if nothing noteworthy>
```

**Blocked:**
```
status: blocked
issue: #[NNN]
stage: tdd | green-check | commit
plain_language: <1–2 sentences a non-coder can act on — what is stuck and what you need>
detail: <the failing command + output excerpt, or the outstanding CRIT findings>
```

The lead independently re-runs every gate before closing, so the gate lines above are a
self-check, not the trusted result. Report them honestly — but a wrong "pass" will be caught and
will cost a round-trip, so verify before you claim it.

Then update your task in the shared task list: `completed` if done, leave `in_progress` if
blocked. The lead handles closing the GitHub issue and the team task list — you do not.

---

# Lead review pass — the single, fanned-out review

This is **not** a teammate brief — it is the checklist the **lead runs itself**. After an
implementer teammate commits a slice, the lead reviews that commit. The review lives at the lead
because the lead is the one session that holds the `Agent` tool, so `code-review` **fans out** its
analyst sub-agents here; a teammate's would not (see SKILL.md "Why Agent Teams"). This is the
**only** review pass — the implementer does not self-review — so nothing else will catch what this
misses.

## Review target

- **Issue:** #[NNN] — the committed slice.
- **Working tree / branch:** `--worktree` on `--branch`; the implementer's `(#[NNN])` commit is here.
- **Canonical commands:** `$repo_commands` — test, build, lint, format gate.
- The slice's **Acceptance criteria** and **Tests** are in the issue body the lead already holds.

## What to do, in order

1. **Locate the commit.** `git log --oneline -10` on `--branch`; find the `(#[NNN])` commit and
   `git show` it. Review *that* change against the slice's **Acceptance criteria**.
2. **Run `code-review`** over the change. It **fans out** here (the lead has the `Agent` tool) —
   this is the whole reason the review lives at the lead. Judge each finding's severity.
3. **Check the acceptance criteria for seam gaps.** Confirm every acceptance criterion is actually
   met on the **real running path**, not just the preview/read path or a test shortcut. A guard
   wired into one path but absent on the write/save path is a CRIT. Cross-check that a
   cap/validation/permission added for this slice is enforced everywhere the criterion implies, not
   only where it was convenient to add. A named Test or Acceptance-criteria test that is simply
   **absent** (behavior correct, test missing) is a **CRIT**, not a suggestion — the slice required it.
4. **Run the gates** (test, build, lint, **format gate**) from the committed state to confirm the
   implementer's green is real. The format gate is a frequent miss — run it.
5. **Post the review as a comment on issue #[NNN]** for the audit trail:
   `gh issue comment [NNN] --body "<review>"`. Lead with one plain-language sentence (clean, or the
   headline problem a non-coder can act on), then the structured outcome: the four gate results,
   each CRIT finding (`file:line` + what's wrong + why it must be fixed, or "none"), and the
   warning / suggestion / yagni counts.
   - **Idempotency:** on a resumed run, if a review comment from this pass is already on the issue
     (`gh issue view [NNN] --comments`), do **not** post a duplicate.
6. **Fix CRITs directly, then commit.** For each CRIT, make the fix and add or update a test that
   proves it — do not fix blind. Commit on `--branch` referencing `#[NNN]` (a follow-up commit is
   expected). There is **no re-review loop**; the lead's gate run before close is the backstop. A
   CRIT that can't be cleanly fixed — genuinely ambiguous, or needing a user decision — means mark
   the item **blocked** with a plain-language note; do not guess.

Then return to SKILL.md Step 4, step 5 (gate run + close).

# Change Set Formats

## Contents

- Change-log skeleton
- Entry format
- Decision format
- Unit format
- Closing sections

Use these formats so every restructure change set reads the same way, and so a later run can read an earlier one as
precedent. `{folder}` is the change-set folder Step 1 resolved.

## Change-log skeleton (`{folder}/change-log.md`)

```markdown
# Change Log: {the goal, in the person's words}

This is the running log of every change made in this change set, in the order it was made. After the start gate the run
continued without the person, so every decision is made and justified here. Each entry says what changed and why, and
links the decision (D-N) behind it.

**Where to read more:**

- [change-plan.md](change-plan.md): the plan these changes carry out.
- [artifacts/change-decision-log.md](artifacts/change-decision-log.md): every decision, with its reasoning and the
  alternatives rejected.
- [artifacts/architectural-analysis.md](artifacts/architectural-analysis.md): the analysis that found the risks.
- [artifacts/mikado-graph.md](artifacts/mikado-graph.md): the prerequisites discovered for units that stalled. Present
  only when a unit stalled.

**Branch:** `{branch}`. Every step below is one commit on it.

**Structure rules:** {each source of the rules the run applied, as a path, plus the goal itself}.

**Commands:** test `{command}`, type-check `{command or none}`, lint `{command or none}`, build `{command or none}`.

**Completion check:** `{the check}`, which listed {N} items out of place before any change.

**Discovery round cap:** {N} per stalled unit.

**Baseline before any change:** {the test runner's summary line, with counts}.
```

## Entry format

Add one numbered section per step, in order: the analysis, the plan, each unit, each discovery round, and the
documentation update.

```markdown
## {n}. Unit {k}: {what the unit does} (`refactor` or `tdd`)

- **Commit:** the commit message. The short hash is not known until after the commit, so fill it in with the next
  entry's commit, or at the finish for the last one.
- **What:** the files moved, created, or edited, as `old path` → `new path` where files moved.
- **Why:** the structure rule or the analysis finding this unit serves.
- **Decisions:** D-{n}, D-{n}, each with one line on what it settled.
- **Tests:** the suite's counts after the unit, compared with the baseline.
```

A discovery round gets a shorter entry:

```markdown
## {n}. Discovery round {r} for G-{g}: {the node attempted}

- **Attempt:** what was tried.
- **Broke:** the failing checks, one line each.
- **Prerequisites added:** G-{id}, G-{id}, with D-{n} for how the failures were grouped.
- **Undo:** the files `undo-attempt.sh` removed, and the suite's counts after the undo.
```

## Decision format (`{folder}/artifacts/change-decision-log.md`)

Number decisions D-1, D-2, and so on in the order they were made. Never renumber, BECAUSE the change log, the plan, and
the graph link to them by number. Answers the person gave at the start gate are decisions too; record them first, with
the person as the rationale.

```markdown
### D-{n}: {the decision, stated as a sentence}

- **Question:** what had to be decided.
- **Decision:** what was chosen.
- **Rationale:** the evidence behind it: a file path, a rule, a finding, an earlier change set's precedent, or the
  person's answer at the start gate.
- **Alternatives rejected:** each alternative and why it lost.
```

## Unit format

Use this when the skill writes `{folder}/change-plan.md` itself because `plan-a-change` is not available. When
`plan-a-change` writes the plan, ask it for the same fields on each unit.

```markdown
### Unit {k}: {what the unit does, stated as a change}

- **Kind:** `refactor` (moves or renames existing code) or `tdd` (adds new code a move needs, such as a shared module
  or a path anchor, driven by a test).
- **Files:** every file the unit may touch. This is the declared scope `refactor` holds the unit to.
- **Depends on:** the earlier units that must be done first, or "none".
- **Why:** the structure rule or analysis finding it serves, with the misplaced items it fixes.
- **Done when:** the observable result, such as the completion check no longer listing these items.
```

Order units so the ones that make moving safe come first, and every unit comes after the units it depends on.

## Closing sections

Add these to the end of the change log at the finish, in this order:

- `## Where things ended up`: the top-level layout of the area after the change, the completion check's result, and
  the final test counts compared with the baseline.
- `## Decisions to look at first`: the D-N entries that were closest calls, departed from precedent, overrode an
  analysis recommendation, or grouped discovery failures, each with one line on why it matters.
- `## Units not done`: each unit that failed, stalled past the round cap, or was not started, with the failing output,
  the graph section, or the unit it depended on. Write "None" if every unit finished.
- `## Follow-ups not done here (behavior changes)`: the behavior-changing findings the run deferred.

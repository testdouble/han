---
name: restructure
description: >
  Restructures a codebase or a large area of it toward a target layout or set of boundaries without changing behavior.
  After one start gate it runs unattended: it analyzes the area, plans ordered units, carries out each unit through
  refactor or tdd, and commits each one on the current branch with a change log that justifies every decision. When a
  unit stalls because its code is too tangled to move in one step, it uses the Mikado Method to tease it apart: try the
  change, record what breaks as prerequisites in a committed graph, undo the attempt, and do the prerequisites first.
  Use when the user wants to reorganize, restructure, split up, untangle, or re-apply a layout across many files or
  modules, or to enforce the documented structure. Does not restructure one named spot — use refactor. Does
  not plan without executing — use plan-a-change. Does not stop at findings — use architectural-analysis. Does not
  change behavior. Runs to completion after the start gate; to review each unit as it lands, use pairing.
argument-hint: "[the target structure or goal, optional: the area to restructure]"
allowed-tools:
  Read, Write, Edit, Glob, Grep, Skill, Bash(git *), Bash(find *), Bash(mkdir *), Bash(date *), Bash(npm *),
  Bash(npx *), Bash(pnpm *), Bash(yarn *), Bash(bun *), Bash(pytest *), Bash(python3 *), Bash(go *), Bash(cargo *),
  Bash(make *), Bash(bundle *), Bash(rake *), Bash(bash "${CLAUDE_SKILL_DIR}/scripts/undo-attempt.sh" *),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/skills/refactor/scripts/detect-refactor-context.sh"),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- git installed: !`which git 2>/dev/null || echo "not installed"`
- current branch: !`git branch --show-current 2>/dev/null || echo unknown`
- working tree: !`git status --porcelain 2>/dev/null | head -5`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- AGENTS.md: !`find . -maxdepth 1 -name "AGENTS.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## Constraints (read before anything else)

The steps below are the whole skill. This skill is a coordinator. `architectural-analysis`, `plan-a-change`, `refactor`,
and `tdd` do the analysis, the planning, and the code changes. This skill discovers the project, validates, forwards,
captures what each one produced, commits, and logs. The one piece of work it does itself is the Mikado discovery loop
for a unit that stalls, and every edit that loop makes is thrown away.

- **One start gate, then unattended.** Step 3 is the one stop where the person confirms the goal and the run's settings.
  After it, never ask the person a question and never wait for approval, BECAUSE they have stepped away, and a question
  left pending stops the whole run. Decide from evidence (the code, the project's documented structure rules, earlier
  change sets, the analysis) and record every decision as a D-N entry. The only other stops are the hard failures Steps
  2, 7, and 8 name, and the collaborative stop in Step 7. Report a hard failure and end the run.
- **Everything about the project is discovered at runtime.** Never assume a language, a directory layout, a set of
  packages or modules, a test runner, or an entry point. Find them in the project's own files in Step 1, BECAUSE this
  skill runs on any codebase, and a guessed layout moves the wrong files.
- **Commits go to the current branch and no further.** Commit each step to the branch checked out at the start gate.
  Never create or switch branches, push, or open a pull request, BECAUSE the person decides where this work lands and
  who sees it.
- **The tree must start clean, untracked files included.** This is stricter than `refactor` on purpose. Failed units
  and discovery attempts are undone by restoring to the last commit, which is only safe when the last commit holds
  everything worth keeping.
- **No behavior changes.** Every unit preserves observable behavior. A finding that needs a behavior change becomes a
  follow-up in the change log, never a unit. Entry points that build scripts, manifests, or deployment configuration
  name by path either stay where they are or move in a unit that updates every reference to them.
- **Never patch forward.** A red unit is undone, never fixed in place. A restructuring unit changes no test except to
  move it with its code and update its imports; tests change only in a `tdd` unit, to drive new code. Never edit a test
  to make a unit pass, BECAUSE a test edited to agree with the change no longer proves behavior was preserved.

# Restructure

## Step 1: Bind the Goal and Discover the Project

**Bind the goal.** The goal is the target structure in the person's words: a layout to reach ("group each package by
feature, then by component"), boundaries to draw ("pull billing out of the orders module"), or the project's documented
structure to re-apply. Record it verbatim. If the request names no goal ("clean up the code"), ask for one, and ask
nothing else in that turn, BECAUSE every later step measures the code against the goal and a guessed goal moves code in
a direction nobody asked for.

**Discover the structure rules.** Find every place the project describes how its code is laid out, and read each one:

- `CLAUDE.md`, `AGENTS.md`, and `project-discovery.md`.
- README sections whose headings mention layout, structure, architecture, organization, or directories. Grep for those
  words in heading lines of `*.md` files at the root and one level down.
- ADRs and coding standards, located through CLAUDE.md's `## Project Discovery` section, then `project-discovery.md`,
  then Glob defaults (`docs/adr/`, `docs/decisions/`, `docs/coding-standards/`). Read the ones whose titles govern
  structure, boundaries, or dependencies.
- Checks that enforce boundaries in code: test files whose names or contents mention boundaries, architecture, layers,
  or allowed imports, and lint or dependency-tool configuration that restricts imports. Each one found is both a rule
  and a check Step 8 runs.
- Earlier restructure change sets under the output root resolved below. Their decision logs are precedent: follow a
  precedent unless the code has since changed in a way that breaks it, and record a D-N entry when departing from one.

Treat the documented rules as the current interpretation of the goal. Where the goal and a documented rule conflict,
the goal wins and the conflict goes to the start gate.

**Discover the area.** If the person named an area, resolve it to real paths. Otherwise find the source roots: the
top-level directories that hold source files in the project's languages, found with `find` and the extensions the
manifests imply. Directories with no source code, such as fixtures or embedded data, are not part of the area. Find the
entry points the build and run configuration names by path (manifest scripts, build files, container files, CI
workflows), because a move that breaks one breaks the build.

**Resolve the commands.** Read CLAUDE.md's `## Project Discovery` section for the test, type-check, lint, and build
commands. If absent, fall back to `project-discovery.md`. If still absent, run
`bash "${CLAUDE_PLUGIN_ROOT}/skills/refactor/scripts/detect-refactor-context.sh"` and parse its `key: value` output; its
commands are suggestions for the start gate to confirm. Then find the **test roots**, the places the runner discovers
tests (runner configuration, the test command's arguments, manifest scripts), BECAUSE a test file moved outside them
stops running and passes silently.

**Draft the completion check.** Write one runnable check that lists what is out of place against the goal: a `find` or
Grep that should return nothing when the goal is met, or a boundary test from the rules above. Run it now and record the
count. The plan in Step 6 and the finish in Step 10 both read it.

**Resolve the output location** through the precedence chain in
[config-rule.md](../../references/config-rule.md): a folder the person named wins; otherwise the `output-directory`
setting with the run's own folder beneath it; otherwise a folder under the documentation root discovered above, or
`docs/changes/` when none is found. Name the run's folder `restructure-{date}` from `date +%Y-%m-%d`, appending `-2`,
`-3`, and so on until the name is unused. Call it `{folder}`.

## Step 2: Preflight and Baseline

Each of these is a hard failure: report which one and end the run.

1. `git status --porcelain` fails: the folder is not a git repository. Every undo and every unit commit needs one.
2. `git status --porcelain` prints anything: the tree has uncommitted or untracked changes. Ask the person to commit or
   remove them and run again, BECAUSE an undo cannot tell their work from an attempt's.
3. `git branch --show-current` prints nothing: HEAD is detached, and commits made there are easy to lose.

If no test command resolved after every fallback, skip the baseline below: Step 3 asks for the command, and the
baseline runs as soon as the person supplies it, before Step 4. Otherwise, run the test command, and the type-check command where one exists. **Paste the runner's summary line** and record the
counts as the baseline. If anything is red, report the output and end the run, BECAUSE a restructure can only be proven
behavior-preserving against a suite that was green to begin with.

## Step 3: The Start Gate

Present everything the run will act on, then end the turn:

- The goal, verbatim, and the area it covers.
- The structure rules found, each with its source path, and any conflict between them and the goal.
- The completion check and how many items it lists today.
- The test, type-check, lint, and build commands, and the test roots. When no test command resolved, ask for one here.
- The branch. If it is the repository's default branch, say so and recommend the person create a dedicated branch first.
- The output folder.
- The discovery round cap, five per stalled unit unless the person sets another.
- What the run will do once confirmed: commit the analysis, the plan, every unit, and every Mikado graph update to this
  branch, one commit each, with no further questions.

Ask the person to confirm or amend any of it. When they answer, record each amendment and the confirmation itself as
the first D-N entries. From here on, the run asks nothing more.

## Step 4: Start the Change Set

1. Run `mkdir -p {folder}/artifacts`.
2. Write `{folder}/change-log.md` from the skeleton and `{folder}/artifacts/change-decision-log.md` from the decision
   format in [references/change-log-format.md](references/change-log-format.md), filled with what Steps 1 to 3
   recorded.
3. Run `git add {folder}` and commit with the message `Start the restructure change set`.

## Step 5: Run the Architectural Analysis

Invoke `han-coding:architectural-analysis` through the Skill tool on the area. Pass the goal verbatim and these
overrides:

- Run unattended. Choose the analysis size from evidence, and do not ask the person anything.
- Write the report to `{folder}/artifacts/architectural-analysis.md`.
- Focus on what would make moving code unsafe: paths computed from a file's own location, imports that cross the
  boundaries the goal draws, code loaded by name or path at runtime, shared mutable state, and code duplicated across
  the boundaries.

When it returns, confirm the report file exists, add a change-log entry, run `git add {folder}`, and commit with the
message `Add the architectural analysis for the restructure`. Then continue to Step 6. The analysis is an input to this
skill, not its result.

## Step 6: Plan the Units, or Stop if Nothing Is Out of Place

1. Run the completion check, and compare the area against the structure rules. List every file that sits in the wrong
   place and every analysis finding that blocks a move.
2. If the list is empty, add a `## No changes needed` section to the change log with the evidence, commit it with the
   message `Record that the structure needs no changes`, report it, and end the run.
3. If `han-planning:plan-a-change` is among the available skills, invoke it through the Skill tool. Pass the goal
   verbatim, the list from item 1, and the analysis report path, with these overrides:
   - Run unattended. Resolve every interview question from evidence and record each as the next D-N entry in
     `{folder}/artifacts/change-decision-log.md`, using the decision format in
     [references/change-log-format.md](references/change-log-format.md).
   - Write the plan to `{folder}/change-plan.md` and its companion files to `{folder}/artifacts/`.
   - Keep the change a pure restructure. Record behavior-changing findings as follow-ups, not units.
   - Split the work into ordered units with the fields in the unit format of
     [references/change-log-format.md](references/change-log-format.md): kind (`refactor` or `tdd`), the files each may
     touch, the units it depends on, and why. Put the units that make moving safe first.
4. If `plan-a-change` is not available, or the Skill call reports it unknown, write `{folder}/change-plan.md` yourself
   from the list in item 1 and the analysis, using the unit format and ordering rule in
   [references/change-log-format.md](references/change-log-format.md). Record a D-N entry saying the plan was written
   without `plan-a-change`, and why each unit is ordered where it is.
5. Confirm the plan and the decision log exist, add a change-log entry, run `git add {folder}`, and commit with the
   message `Plan the restructure`. Then continue to Step 7.

## Step 7: Carry Out Each Unit

Work through the plan's units in order, skipping any unit marked not started. For each unit:

1. Confirm `git status --porcelain` is empty, and record `git rev-parse HEAD` as the unit's base.
2. Invoke `han-coding:refactor` for a `refactor` unit, or `han-coding:tdd` for a `tdd` unit, through the Skill tool.
   Pass the unit text verbatim. Tell it to run unattended, to treat the unit's file list as its declared scope, to stop
   and report rather than ask when it would otherwise ask the person, to record any new decision as the next D-N entry
   in the decision log, and not to commit, BECAUSE this skill makes exactly one commit per unit so a unit can be undone
   as a whole.
3. When it returns, run the test command and the type-check command. **Paste the summary lines.** The suite must be
   green and must still include every baseline test. A count lower than the baseline, other than a count the plan says
   it moves or merges, is a failure.
4. **Green:** add a change-log entry in the entry format, run `git add -A`, and commit with a message that names the
   unit. If the unit is a node in the Mikado graph, check it off and include the graph in the same commit.

   **Running collaboratively.** When the request asks to review each unit as it lands, which is what `pairing` does
   when it hands work here, stop at this point and hand control back instead of continuing. Present the stop in the
   shape [collaborative-stop-rule.md](../../references/collaborative-stop-rule.md) specifies, with the commit as the
   thing to check. Absent such a request, continue as below; an ordinary invocation is unchanged.

5. **Stalled:** the sub-skill stopped because the unit needed files outside its list or two steps in a row failed,
   `tdd` could not reach green, or the suite is red after it returned. Run
   `bash "${CLAUDE_SKILL_DIR}/scripts/undo-attempt.sh" {base}` to return to the unit's base, re-run the suite, and
   paste its summary line. Then go to Step 8 with this unit as the goal, and come back here when Step 8 returns.
6. **Not covered:** if `refactor` stopped because the unit's code has no meaningful test coverage, that is not a stall
   and the Mikado Method cannot fix it. Undo to the base as in item 5, log the unit under "Units not done" with the
   uncovered behaviors as a follow-up, and mark every unit that depends on it as not started.
7. **Hard failure:** if `undo-attempt.sh` exits non-zero, or the suite is not green after the undo, report the output
   and end the run, BECAUSE nothing after this point can be trusted on an unknown tree.

If two units in a row end up in "Units not done," skip to Step 10, BECAUSE repeated failures mean the plan no longer
matches the code. After the last unit, continue to Step 9.

## Step 8: Tease Apart a Stalled Unit with the Mikado Method

Read [references/mikado-method.md](references/mikado-method.md) and follow it with the stalled unit as the goal node.
It holds the discovery loop, what counts as broken, how to group failures into prerequisites, the graph file at
`{folder}/artifacts/mikado-graph.md`, the conditions that make each undo safe, and the round cap.

- Add a change-log entry for each discovery round, in the discovery-round format.
- Carry out each leaf through items 1 to 4 of Step 7, as a unit of its own, then attempt its parent again. A leaf that
  stalls when carried out is not a leaf: undo it with `undo-attempt.sh`, and continue discovery with it as the node.
  The rounds it takes count toward the same cap.
- When the goal node is carried out and committed, return to Step 7 for the next unit.
- When the round cap is reached, commit the graph, log the unit under "Units not done" with its graph section, mark
  every unit that depends on it as not started, and return to Step 7 for the next unit.

## Step 9: Update the Structure Docs and Check the Build

1. Rewrite each documentation section Step 1 found that describes the layout of the area, so it describes the tree as
   it now stands and follows the goal. Commit with the message `Describe the restructured layout`.
2. Run the test, type-check, lint, and build commands. **Paste the summary line from each.** If one fails because a
   path moved, fix that path reference, log the fix, re-run, and commit it. If it fails for any other reason, log the
   output under "Units not done" rather than changing behavior to make it pass.

## Step 10: Finish the Log and Report

1. Run the completion check and record its result.
2. Finish `{folder}/change-log.md` with the closing sections from
   [references/change-log-format.md](references/change-log-format.md), then commit with the message
   `Finish the restructure change log`.
3. Report the branch, the change-log path, the units done and not done, the completion check's count before and after,
   the final test counts compared with the baseline, and the decisions to look at first.

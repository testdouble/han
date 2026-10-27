# The Mikado Method, as This Skill Runs It

## Contents

- When the method takes over
- The discovery loop
- What counts as broken
- Grouping failures into prerequisites
- The graph file
- The undo, and the conditions that make it safe
- Working the leaves back up
- The round cap
- Never patch forward

The Mikado Method is a loop for a change too big or too tangled to make in one step. Ola Ellnestam and Daniel Brolund
described it in _The Mikado Method_ (Manning, 2014): try the change the simple way, write down what breaks, undo the
attempt, fix the blockers first, and work back up to the goal. This skill does not run it on every unit. It runs it on a
unit that stalled, because a stall is the signal that the unit has prerequisites the plan did not find by reading the
code.

## When the method takes over

A unit stalls when any of these happens:

- `refactor` stopped because a step needed files outside the unit's declared file list. The files it reached for are
  the first clue to the prerequisites.
- `refactor` stopped because two steps in a row failed.
- `tdd` could not bring the unit's behavior to green.
- The full suite is red after the unit returns, or a baseline test stopped being discovered.

Each of these means the same thing: the unit depends on a change nobody has made yet. The stalled unit becomes the goal
node of a new graph.

## The discovery loop

Work one node at a time, depth first, starting from the goal node:

1. **Check the tree is clean** with `git status --porcelain`, and record `git rev-parse HEAD` as the attempt's base.
   Never start an attempt on a dirty tree, BECAUSE the undo cannot tell an attempt's edit from anything else.
2. **Try the node the simple, direct way.** Make the change as if nothing stood in the way: move the files, update the
   imports, split the module. Go wide on purpose. This attempt is thrown away, so its job is to surface breaks, not to
   be clean.
3. **Run every check** named in "What counts as broken" and capture the failures.
4. **Group the failures into prerequisites** and add each one to the graph under the node, as the next section
   describes.
5. **Commit the graph file alone**, with `git add` on the graph path and `git commit` naming that path, so the attempt's
   code edits stay out of the commit. Then confirm HEAD moved by exactly that one commit, and record the new HEAD as the
   undo base.
6. **Undo the attempt** with `bash "${CLAUDE_SKILL_DIR}/scripts/undo-attempt.sh" {base}`, then run the full suite and
   confirm it is green with the baseline count.
7. **Descend.** Take the first new prerequisite that is not done and repeat from 1 with it as the node. A node whose
   attempt surfaces no failures is a **leaf**.

When an attempt is green, it is still undone. The leaf is then carried out through `refactor` or `tdd` like any planned
unit, BECAUSE their gates (a green suite before the first edit, one named step at a time, the observed failing test) are
what make the committed change trustworthy, and the attempt had none of them.

## What counts as broken

Broken means any of these, run in this order so a cheap failure is found before an expensive one:

1. The build or compile command fails.
2. The type-check command fails, where the project has one.
3. The test command fails, or reports fewer tests than the baseline. A moved test that stops being discovered fails
   silently otherwise.
4. The lint command fails on a file the attempt touched.
5. A check the project uses to enforce its own boundaries fails, such as an architecture test or an import-restriction
   rule, when Step 1 found one.

Nothing else counts. A hunch that something "looks wrong" is not a failure. Record it in the decision log instead,
BECAUSE the graph must hold only what an attempt proved.

## Grouping failures into prerequisites

One root cause usually produces many failures. Group the failures by the change that would remove them, not by the file
they appear in:

- Failures that name the same symbol, module, or path, and would all go away with one change, are one prerequisite.
- A failure that would go away only after another prerequisite is done is a child of that prerequisite, not a sibling.
- State each prerequisite as a change to make ("Move the shared formatting helpers out of the reporting module"), never
  as the failure ("Import error in three files").

Record how each group was formed as a D-N entry in the decision log. Grouping is the judgment call in this loop, and the
person reviews it when they return.

## The graph file

The graph is the method's one lasting artifact. It survives every undo because it is committed before the undo runs.
Keep it at `{folder}/artifacts/mikado-graph.md`, one section per stalled unit, as a nested checklist:

```markdown
## Goal G-{n}: {the stalled unit, stated as a change}

- [ ] G-{n}: {the stalled unit}
  - [ ] G-{n}.1: {prerequisite, stated as a change}. Found by attempt {k}: {one-line summary of the failures}.
    - [ ] G-{n}.1.1: {its prerequisite}. Found by attempt {k}: {summary}.
  - [x] G-{n}.2: {prerequisite}. Done in commit `{short sha}`.
```

- Each node carries an ID that encodes its parent, so the order is readable without a drawing.
- A node is checked only after its change is committed with a green suite. Never check a node that is merely attempted.
- A node with no unchecked children is ready. Leaves go first.
- When two branches need the same prerequisite, list it once and refer to its ID from the other branch, BECAUSE a
  duplicated node gets done twice or marked done in only one place.

## The undo, and the conditions that make it safe

Restoring to the last commit is safe here only because every one of these holds. Check each before every undo:

- The project is a git repository and the run is on the branch the start gate confirmed.
- The tree was clean, untracked files included, when the attempt started.
- The graph update is committed before the code is restored, or the restore discards the prerequisites just found.
- Nothing was committed since the attempt started except the graph. `undo-attempt.sh` refuses to run when HEAD has
  moved from the base it is given.
- The full suite runs after every undo. A restore does not revert ignored or generated state such as build output,
  installed packages, or caches, and that state can make the next run pass or fail for the wrong reason. If the suite is
  not green after the undo, clear the project's build output with its own clean command if it has one, and run again.
  If it is still not green, that is a hard failure: report it and end the run.

## Working the leaves back up

Once a node is a leaf, carry it out the way Step 7 of the skill carries out any unit: one invocation of `refactor` (or
`tdd`, when the leaf adds new code the move needs), the full suite, one commit. Then check the node in the graph and
commit the graph with it.

Then return to the node's parent and attempt it again from step 1 of the loop. With its prerequisites done, it either
goes green (and becomes a leaf) or surfaces new prerequisites, which become new branches. New obstacles turning up on the
way back is normal, not a sign the loop failed.

The loop ends when the goal node itself is carried out and committed.

## The round cap

Every attempt counts as one round. Stop discovery for a goal after five rounds, unless the start gate set a different
cap, BECAUSE the method has no natural end and a graph that keeps growing means the unit is larger than the plan
assumed. When the cap is reached:

- Commit the graph as it stands.
- Log the unit under "Units not done" with the graph section's link and the last attempt's failures.
- Mark every unit that depends on it as not started.

The right cap is a judgment, not an evidenced number. Record the cap in effect in the change log so the person can
adjust it next time.

## Never patch forward

An attempt that breaks is always undone, never fixed in place. Patching forward turns a discovery into an unplanned
change with no test gate, which is the failure this method exists to prevent.

A restructuring leaf changes no test, except to move a test file along with the code it tests and update its imports.
Tests change only in a `tdd` leaf, and only to drive new code. Never edit a test to make an attempt or a leaf pass,
BECAUSE a test edited to agree with the change no longer proves the change preserved behavior.

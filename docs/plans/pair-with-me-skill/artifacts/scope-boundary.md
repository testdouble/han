# Scope Boundary: pair-with-me collaborative working-mode skill

## Work Item

No ticket, issue, or pull request exists. The operator's typed request across this session is the only boundary this run
has. The request was refined over three turns and is backed by a research report the same session produced at
`docs/research/collaborative-output-style.md`.

## Stated Scope

Quoted from the operator, in the order stated.

The original goal:

> the goal is for me to let claude loose on implementation, have it build out the first chunk, walk me through it like
> the code-walkthrough skill, let me review and ask questions to help guide it's implementation, have it make
> adjustments based on my feedback and questions, have it use that feedback in the next steps to help guide it better,
> and then loop this whole process for the next chunk of work it's going to do. i want to collaborate with claude, not
> just direct it. think "human in the lead", not "human in the loop"

The decision on shape:

> i'm ok with an opt-in workflow. i'd rather have that, than force tdd or any other skill into this mode.

The decision on naming and handoff:

> i would prever to go with option 2. tdd gains the opt-in collaborative flag. i'd also like to call this new skill
> `/han-coding:pair-with-me` with the intent of a prompt like "pair with me on tdd for this", "pair with me on
> refactoring", "pair with me on implementing", etc.

## Stated Exclusions

Quoted from the operator.

> force tdd or any other skill into this mode

The operator ruled out any mandatory change to an existing skill's default behavior. The flag added to `tdd` is opt-in.

The operator also accepted the research report's recommendation of one skill and no output style, which excludes
building a new output style, a session-start hook, or a post-edit hook as part of this work.

## Operator-Stated Scope

> run /plan-a-feature with that context. commit and push as you go

The operator asked for a feature specification, not an implementation. Committing and pushing as the run proceeds is a
process instruction rather than a scope statement, and it is recorded here so a later skill does not read it as feature
behavior.

## Direction of Travel

Answered. The operator stated:

> All four stay, nothing is being replaced.

The four are `tdd`, `refactor`, `code-walkthrough`, and the wider set of skills someone might pair on. None is being
deprecated, replaced, or migrated away from. `pair-with-me` therefore borrows `code-walkthrough`'s pacing without
changing it, and the flag added to `tdd` leaves every existing invocation behaving as it does today.

The operator also asked, in the same turn, which other skills across the suite should gain a collaboration flag like
`tdd`'s, ruling out `han-reporting`, `han-feedback`, and `han-plugin-builder` up front. That survey is a scope question
for this run and its answer is recorded in the decision log.

## Visual Material Received

None received.

## Record Provenance

Established by `han-planning:plan-a-feature` in this run. Not inherited from another folder.

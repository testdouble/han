# Scope Boundary: pair-with-me collaborative working-mode skill

## Work Item

No ticket, issue, or pull request exists. The operator's typed request across this session is the only boundary this run
has. The request was refined over five turns, widened materially at the fifth, and is backed by a research report the
same session produced at `docs/research/collaborative-output-style.md`.

## Stated Scope

Quoted from the operator, in the order stated. The last quote governs where it widens the earlier ones.

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

The decision on which skills gain the flag, answering a survey of every skill in the plugins not ruled out:

> Both, in this spec

That is `tdd` and `refactor`. The operator ruled out `han-reporting`, `han-feedback`, and `han-plugin-builder` from the
survey up front.

**The widening.** At the fifth turn the operator established that the mode is not specific to writing code:

> consider, for example, "pair with me on designing an API for {thing i'm working on}" - this isn't an implementation
> pairing. instead, it's an api design pairing that would be followed up by an implementation (either pairing or claude
> running on it's own). also, consider "pair with me on writing a response to this question ..." - this is more open
> ended. generally, though, "pair with me on implementing {thing}" shouldn't assume tdd vs refactoring vs prototyping
> the shape of the code and then doing the full tdd or refactoring, etc.

The scope is therefore a collaborative working mode over any kind of work, with code as one case among several. Three
kinds are named: pairing backed by an existing skill, pairing on design work that produces a decision rather than code,
and open-ended pairing with no backing skill at all. The front door does not choose the discipline for the operator.

## Stated Exclusions

Quoted from the operator.

> force tdd or any other skill into this mode

No mandatory change to any existing skill's default behavior. Every flag added is opt-in, and an existing invocation
behaves exactly as it does today.

The operator accepted the research report's recommendation of one skill and no output style, which excludes building an
output style, a session-start hook, or a post-edit hook as part of this work. The widening above reopens the reasoning
behind that choice, because a mode covering any kind of work has a larger surface than a code-only mode. The operator's
decision stands until they revisit it; it is recorded here as a known input change rather than a settled re-decision.

## Operator-Stated Scope

> run /plan-a-feature with that context. commit and push as you go

and, on the widened scope:

> The general one, with a narrow research pass first.

The operator asked for a feature specification, not an implementation, and directed that a narrow research pass on one
open question run before planning resumes. Committing and pushing as the run proceeds is a process instruction rather
than feature behavior, and is recorded here so a later skill does not read it as scope.

## Direction of Travel

Answered. The operator stated:

> All four stay, nothing is being replaced.

The four are `tdd`, `refactor`, `code-walkthrough`, and the wider set of skills someone might pair on. None is being
deprecated, replaced, or migrated away from. `pair-with-me` borrows `code-walkthrough`'s pacing without changing it, and
the flags added to `tdd` and `refactor` leave every existing invocation behaving as it does today.

## Visual Material Received

None received.

## Record Provenance

Established by `han-planning:plan-a-feature` in this run. Not inherited from another folder.

Rewritten once, at the fifth turn, when the operator widened the scope from a code-only collaborative loop to a general
collaborative working mode. The narrower first version is in this file's git history. No conflict was resolved between
two work items, because only one exists: the operator's own request.

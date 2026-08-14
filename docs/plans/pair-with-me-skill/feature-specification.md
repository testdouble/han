# Feature Specification: pair-with-me

A collaborative working mode where Claude builds your work in reviewable pieces and hands each one back to you before
starting the next, so you stay in the lead rather than reviewing a finished result.

## Outcome

You get the work done, in pieces you actually reviewed, with your feedback shaping every piece after the one that
prompted it.

Today a Han skill either interviews you before it works or runs to completion and reports afterward. Neither lets you
steer while the work is happening. This mode fills that gap: you see a piece, react to it, and your reaction changes what
gets built next. Your feedback is written down as it arrives, so a correction you gave at the second stop still applies at
the seventh.

The mode works on any kind of work, not only code
([D1](artifacts/decision-log.md#d1-the-mode-covers-any-kind-of-work-not-only-code)). Pairing on a design decision,
a written response, or a test-driven build are all the same loop with a different sense of what counts as a piece.

## Actors and Triggers

- **Actor** — one person doing their own work, who wants to stay in the lead while an assistant does the building. Han
  targets solo and small-team engineers, and this mode assumes a single reviewer rather than a group.
- **Trigger** — you invoke `/han-core:pair-with-me` ([D12](artifacts/decision-log.md#d12-the-skill-lives-in-han-core)) and
  say what you want to pair on. The phrasing is open: "pair with me
  on tdd for this", "pair with me on refactoring", "pair with me on designing an API for the export flow", "pair with me
  on writing a response to this question."
- **Precondition** — none beyond a task you can describe. When the work needs something the mode cannot supply on its
  own, the backing skill's own preconditions apply.

The mode is opt-in and changes nothing about how any skill behaves when you do not invoke it
([D2](artifacts/decision-log.md#d2-every-existing-skill-keeps-its-current-default-behavior)).

## Primary Flow

1. **You say what you want to pair on.** The mode reads your request and sorts the work into one of four kinds: work a
   Han skill already covers, work that produces a decision, work that produces written prose, or open-ended work that
   fits none of the first three
   ([D3](artifacts/decision-log.md#d3-the-mode-sorts-the-work-into-four-kinds-before-planning-anything)).

2. **The mode proposes where it will stop, and why.** Before any work starts, you get a short plan naming the pieces it
   intends to build and the reason for each boundary. You accept it, change it, or replace it. Either side can renegotiate
   later as the work reveals its actual shape
   ([D4](artifacts/decision-log.md#d4-the-mode-proposes-the-plan-of-stopping-points-rather-than-asking-you-to-supply-one)).

3. **The mode builds one piece.** What counts as one piece depends on the kind of work, and the rule differs for each
   ([D5](artifacts/decision-log.md#d5-a-piece-ends-where-the-kind-of-feedback-changes-not-at-a-size-threshold)):

   | Kind of work            | One piece is                                                                        |
   | ----------------------- | ----------------------------------------------------------------------------------- |
   | Backed by a Han skill   | Whatever that skill already treats as one unit                                       |
   | Produces a decision     | One decision, with its context, the options weighed, and what it commits you to      |
   | Produces written prose  | One rung of a fidelity ladder: the shape, then a rough draft, then the language      |
   | Open-ended              | Whatever the plan from step 2 named                                                  |

4. **The mode hands the piece back for checking.** You get the specific things you can verify and what changed, stated
   plainly. The reasoning behind the choices is available but does not lead
   ([D6](artifacts/decision-log.md#d6-a-stop-hands-you-checkable-claims-rather-than-a-case-for-the-work)).

   When the piece contains a choice that is expensive to walk back, the stop first asks what you expected, before showing
   what it did ([D7](artifacts/decision-log.md#d7-the-mode-asks-for-your-read-first-only-where-a-mistake-is-expensive-to-undo)).

5. **The mode stops and waits.** The turn ends. Nothing further is built until you respond.

6. **You respond, and the mode writes your response down.** Every piece of feedback goes into a running record before it
   is acted on ([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-written-record-rather-than-being-carried-in-memory)).

7. **The mode acts on your feedback, then continues.** Feedback about the piece in hand gets fixed in that piece and shown
   to you again before anything new is built
   ([D9](artifacts/decision-log.md#d9-feedback-condemning-the-piece-in-hand-is-fixed-in-place-and-re-shown)). Feedback
   about what comes next shapes the next piece. Either way, the mode returns to step 3.

8. **The loop ends when the plan is finished or you end it.** The mode reports what was built, what your feedback changed,
   and anything the plan named but did not reach.

## Alternate Flows and States

### The backing skill owns the piece boundary

- **Entry condition:** You named work a Han skill already covers, and that skill has been given the collaborative flag.
- **Sequence:** The mode hands the work to that skill. The skill does its own job unchanged, and stops at the point it
  already treats as the end of a unit rather than looping onward on its own
  ([D10](artifacts/decision-log.md#d10-two-skills-gain-an-opt-in-collaborative-flag-tdd-and-refactor)). Control returns to
  the pairing loop at step 4 of the primary flow.
- **Exit:** The backing skill's own work is complete, or you end the loop.

Two skills gain this flag: `tdd`, which already ends each cycle by crossing one behavior off its list, and `refactor`,
which already ends each step by crossing off one named refactoring. Neither gains a new boundary; the flag changes only
what happens when the existing boundary is reached.

### You asked to pair on implementing, without naming a discipline

- **Entry condition:** Your request says to build something but does not say whether to drive it from tests, restructure
  what is there, or sketch a shape first.
- **Sequence:** The mode does not guess. Step 2's proposed plan names which approach it intends and why, and that
  proposal is the thing you accept or redirect
  ([D11](artifacts/decision-log.md#d11-the-front-door-never-picks-the-discipline-for-you)). A single request may span more
  than one approach, such as sketching a shape and then building it test-first.
- **Exit:** You accept or replace the proposed approach, and the loop proceeds from step 3.

### Your feedback reaches outside the piece in hand

- **Entry condition:** You ask for a change that would alter work outside the piece just built.
- **Sequence:** The mode does not patch it in place. It reopens the plan of stopping points from step 2, says what your
  feedback changes about that plan, and proposes a revised one
  ([D9](artifacts/decision-log.md#d9-feedback-condemning-the-piece-in-hand-is-fixed-in-place-and-re-shown)).
- **Exit:** You accept or change the revised plan, and the loop resumes.

### You end the loop early

- **Entry condition:** You say to stop, or to finish the rest without stopping.
- **Sequence:** The mode reports what was built and what remains. When you asked it to finish without stopping, it
  continues from the current plan and reports at the end rather than at each piece.
- **Exit:** The loop is over. The feedback record stays where it was written.

## Edge Cases and Failure Modes

| Condition                                                                     | Required Behavior                                                                                                                                                                             |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Your request is too vague to sort into a kind of work                          | The mode asks what you want to pair on, once, before proposing any plan. It does not guess a kind and it does not begin building.                                                              |
| The work turns out to have no natural pieces                                   | The proposed plan says so and names a boundary it chose for a stated reason, so you have something concrete to redirect rather than a blank question.                                          |
| You respond to a stop with a question rather than a direction                  | The mode answers the question and stops again at the same place. A question holds your place; it never advances the work.                                                                      |
| You approve several pieces in a row without comment                            | The loop continues unchanged. Approval is a valid response, and the guard against nodding through is built into how a stop is presented, not into pressure to comment.                         |
| A backing skill hits one of its own stop conditions                            | That skill's stop wins and is reported to you as-is. The pairing loop does not override or soften it.                                                                                          |
| The proposed plan turns out to be wrong once work starts                       | The mode says so at the next stop, names what it learned, and proposes a revised plan rather than silently working to a plan it no longer believes.                                            |
| You give feedback that contradicts feedback you gave earlier                   | The mode names the contradiction, cites both entries from the running record, and asks which governs. It does not silently apply the newer one.                                                |
| The session is compacted or interrupted mid-loop                               | The running record of your feedback survives, because it is written down rather than remembered ([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-written-record-rather-than-being-carried-in-memory)). |

## User Interactions

- **Affordances.** One invocation, in whatever words you prefer, naming what to pair on. At each stop, an ordinary
  conversational turn: you say what you think, ask a question, redirect, or approve.
- **Feedback.** Each stop names what was built, what you can check, and what the plan says comes next. At a stop over a
  hard-to-reverse choice, it asks for your read before showing its own.
- **Error states.** A request too vague to act on produces one question rather than a guess. A backing skill's own
  blocking condition is reported in that skill's own words.

The pacing is the deliverable. The mode ends its turn at each stop rather than continuing, which is the same convention
`code-walkthrough` already uses.

## Coordinations

| Coordinating System        | Direction | Interaction                                                                                     | Ordering / Consistency Requirement                                                                                       |
| -------------------------- | --------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `tdd`                      | outbound  | Runs the test-driven loop; returns control at the end of each behavior rather than continuing     | The flag takes effect only when `pair-with-me` sets it. An ordinary `tdd` invocation runs exactly as it does today.       |
| `refactor`                 | outbound  | Runs the refactoring sequence; returns control at the end of each named refactoring               | Same condition. An ordinary `refactor` invocation runs exactly as it does today.                                          |
| The running feedback record | both      | Written after each stop, read before planning each piece                                          | A stop's feedback is written before the next piece is planned, so no piece is built against feedback not yet recorded.    |

## Out of Scope

- **Choosing the discipline for you.** The mode proposes and you decide. It never silently picks test-driven development
  over restructuring, or either over sketching a shape first.
- **Changing how any skill behaves by default.** Every flag is opt-in. This is the operator's stated exclusion, quoted in
  the scope boundary record.
- **Group review.** The mode assumes one reviewer. Nothing here coordinates several people reviewing the same piece.
- **Automatic invocation.** The mode runs when you ask for it. Nothing triggers it on your behalf.
- **A stop rule computed from counts.** Two Han skills decide when to stop reviewing by counting and grading findings.
  Work being built produces no such countable signal, so this mode has nothing to compute over.

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Making the collaborative mode the default for a whole session, rather than something you invoke per task

- **Why cut:** The scope boundary records the operator's acceptance of one skill and no output style, which excludes
  building an output style, a session-start hook, or a post-edit hook as part of this work. The record also notes that
  widening the mode beyond code reopens the input behind that choice, and that the decision stands until the operator
  revisits it.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### Carrying the feedback record across separate sessions

- **Why deferred:** No stated need. The evidence supporting a written record is about surviving within a working session,
  where the measured comparison was six percent of critical steps missed with a written checklist against twenty-three
  percent from memory. Nothing establishes that feedback from a previous week should shape today's pieces, and doing so
  risks applying a correction whose reason has expired.
- **Reopen when:** You describe re-giving the same feedback across sessions, or a session's record is lost and costs you
  a repeat of work already reviewed.
- **Source:** Conversation context during specification.

### Giving the collaborative flag to skills beyond `tdd` and `refactor`

- **Why deferred:** A survey of every skill in the nine plugins the operator did not rule out found only these two that
  change files on their own across a sequence where each step builds on the last. The operator confirmed both and named
  no others. Planning skills already interview, publishing skills already stop before writing to shared systems, and
  analysis skills hand you one document.
- **Reopen when:** A new skill ships that changes files across a sequence, or you find yourself wanting to pair on a
  skill that runs to completion today.
- **Source:** Operator survey during specification.

## Open Items

None recorded at draft time. Review findings land here if they cannot be resolved.

## Summary

- **Outcome delivered:** Work gets built in pieces you reviewed, with your feedback shaping every piece after it.
- **Primary actors:** One person doing their own work, pairing with Claude on any kind of task.
- **Decisions settled by evidence:** 5 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending review — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0

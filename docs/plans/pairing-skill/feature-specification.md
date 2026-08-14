# Feature Specification: pairing

A collaborative working mode where Claude builds your work in reviewable pieces and hands each one back to you before
starting the next, so you stay in the lead rather than reviewing a finished result.

## Outcome

You get the work done, in pieces you reviewed, with your feedback shaping every piece after the one that
prompted it.

This mode fills a gap in how Han skills work today. A skill either interviews you before it starts or runs to
completion and reports afterward, and neither lets you steer while the work is happening. Here, you see a piece,
react to it, and your reaction changes what gets built next.

Your feedback is written down as it arrives, so a correction you gave at the second stop still applies at
the seventh ([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-readable-written-record-rather-than-being-carried-in-memory)).

The mode works on any kind of work, not only code
([D1](artifacts/decision-log.md#d1-the-mode-covers-any-kind-of-work-not-only-code)). Pairing on a design decision,
a written response, or a test-driven build are all the same loop with a different sense of what counts as a piece.

## Actors and Triggers

- **Actor** — one person doing their own work, who wants to stay in the lead while an assistant does the building. Han
  targets solo and small-team engineers, and this mode assumes a single reviewer rather than a group.
- **Triggers** — two entry paths, and the mode supports both
  ([D20](artifacts/decision-log.md#d20-both-entry-paths-are-supported-and-the-phrase-path-has-to-win-its-collisions)):
  - **Naming the mode outright.** You invoke `/han-core:pairing` and say what you want to pair on. Nothing competes
    for the request.
  - **Saying it in your own words.** "Pair with me on tdd for this", "pair with me on refactoring", "pair with me on
    designing an API for the export flow", "pair with me on writing a response to this question." Here, the mode
    matches your request against every skill available in the session, and the first three of those sentences each name
    another skill's strongest trigger word. The fourth names no competing skill, so nothing contests it.
- **Precondition** — none beyond a task you can describe. The mode works on its own for prose, decisions, and
  open-ended work, and gains the skill-backed paths only when the skills behind them are installed
  ([D12](artifacts/decision-log.md#d12-the-skill-lives-in-han-core-and-its-backing-skills-are-optional)).
  When the work needs something the mode cannot supply on its own, the backing skill's own preconditions apply.

The mode is opt-in and changes nothing about how any skill behaves when you do not invoke it
([D2](artifacts/decision-log.md#d2-every-existing-skill-keeps-its-current-default-behavior)).

### Which Skill Answers When You Say It In Your Own Words

The rule in every case: whichever skill answers, the person gets what they asked for
([D20](artifacts/decision-log.md#d20-both-entry-paths-are-supported-and-the-phrase-path-has-to-win-its-collisions)).
Because the second entry path competes, this mode's arrival changes what several existing skills have to say about
themselves.

| You say something like                     | What should answer                    | What each side has to say about itself                                                                                                                                              |
| ------------------------------------------ | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| "pair with me on tdd", "pair on refactoring" | This mode, which then runs the skill | This mode says it runs those skills collaboratively. Each of those skills says it otherwise runs to completion without pausing, and names this mode as the way to review as it goes. |
| "do TDD on this", "refactor this module"     | The skill, running as it does today  | Unchanged behavior, stated so the person who wanted an uninterrupted run keeps getting one.                                                                                          |
| "pair with me on designing an API for this"  | This mode, which then runs `design-an-api` | Same delegating shape as the first row. That skill already runs discovery, an options document, a question round, and a validation round, and the mode gets those rather than re-deriving them. |
| "walk me through this code"                  | `code-walkthrough`                   | That skill paces you through work that already exists and builds nothing. This mode builds work while pacing you through it. Both have to say which side they are on.                |
| "help me understand this module"             | Not this mode                        | A request to understand something produces no artifact, so this mode declines it and names where it goes.                                                                            |

The delegating relationship in the first row has no precedent in the suite. Every existing boundary between two skills
is exclusive: one does the job and the other does not. This one is not exclusive, because this mode runs the very skill
it competes with. Saying so on only one side leaves a gap the request can fall through, so both sides say it.

## How Confident Each Part of This Design Is

The research behind this specification does not support every part of it equally, and the difference is large enough that
an implementation should know about it.

- **High confidence.** Stopping where the kind of feedback changes rather than at a size threshold. Four independent
  directions converge on it.
- **Medium confidence.** The specific unit for each kind of work. One decision per decision record is well corroborated.
  The fidelity ladder for prose is a reconciliation the research performed itself, not a practice any single source
  documents.
- **Low confidence.** Open-ended work. No source defines a unit for it, which is why the mode negotiates rather than
  applying a rule ([D13](artifacts/decision-log.md#d13-three-kinds-of-work-plus-a-fall-through-not-four-kinds)).

## Primary Flow

1. **You say what you want to pair on, and the mode sorts the work.** It applies a fixed test, in this order, and stops
   at the first match
   ([D3](artifacts/decision-log.md#d3-the-mode-sorts-the-work-before-planning-anything-using-a-named-test),
   [D13](artifacts/decision-log.md#d13-three-kinds-of-work-plus-a-fall-through-not-four-kinds)):

   1. Does a Han skill carrying the collaborative flag cover this work? Then the work is **skill-backed**.
   2. Does the work produce a choice among options that commits you to something? Then it is **decision work**.
   3. Does the work produce prose someone will read? Then it is **prose work**.
   4. Otherwise it is **open-ended**, and the plan in step 2 supplies the boundaries with no rule behind them.

   The order is the tie-break. A request that fits more than one kind sorts as the earliest match, so drafting a decision
   record sorts as decision work rather than prose work.

2. **The mode proposes where it will stop, and why.** Before any work starts, you get a short plan. It names which kind
   the work sorted into, the pieces it intends to build, the reason for each boundary, and which of those pieces it
   expects to contain a choice that is expensive to walk back
   ([D4](artifacts/decision-log.md#d4-the-mode-proposes-the-plan-of-stopping-points-rather-than-asking-you-to-supply-one),
   [D14](artifacts/decision-log.md#d14-the-reversibility-call-is-announced-in-the-plan-and-the-ask-precedes-the-build)).
   You accept it, change it, or replace it. Either side can renegotiate later as the work reveals its actual shape.

   Naming the sort matters because the sort determines everything downstream. It is the one part of the plan you cannot
   correct if you cannot see it.

   For skill-backed work the plan names the backing skill, the unit that skill stops at, and the reason. The backing
   skill's own list of units does not exist yet at this point. Instead, the mode surfaces it as the plan of pieces at
   the first stop, where you can still redirect it
   ([D15](artifacts/decision-log.md#d15-for-skill-backed-work-the-pre-work-plan-names-the-unit-and-the-first-stop-carries-the-list)).

3. **For a piece the plan marked expensive to walk back, the mode asks for your read before it builds.** The ask names
   the dimension the choice turns on and stops there, rather than posing a blank question or offering candidate answers
   that would anchor your guess. You say what you expect, or you decline. Declining is a first-class answer and advances
   the stop exactly as a considered one does
   ([D7](artifacts/decision-log.md#d7-the-mode-asks-for-your-read-first-only-where-a-mistake-is-expensive-to-undo)).

   The ask comes before the build, not after. The studies behind it work because you commit before the answer exists. An
   ask that arrives once the work is already on disk buys the cost and none of the benefit.

4. **The mode builds one piece.** What counts as one piece depends on the kind of work
   ([D5](artifacts/decision-log.md#d5-a-piece-ends-where-the-kind-of-feedback-changes-not-at-a-size-threshold)):

   | Kind of work | One piece is                                                                     |
   | ------------ | -------------------------------------------------------------------------------- |
   | Skill-backed | Whatever that skill already treats as one unit                                   |
   | Decision     | One decision, with its context, the options weighed, and what it commits you to  |
   | Prose        | One rung of a fidelity ladder: the shape, then a rough draft, then the language  |
   | Open-ended   | Whatever the plan from step 2 named                                              |

5. **The mode hands the piece back for checking.** You get which piece this is against the plan and what remains, the
   specific things you can verify, and what changed. The reasoning behind the choices does not lead, and the stop says in
   one line that it is available for the asking
   ([D6](artifacts/decision-log.md#d6-a-stop-hands-you-checkable-claims-rather-than-a-case-for-the-work),
   [D16](artifacts/decision-log.md#d16-every-stop-names-your-position-in-the-plan-and-the-plan-stays-available)).

   When you gave a read in step 3, the reveal presents what was done in the same form as any other stop. It does not
   restate your read, score it, or defend a divergence from it.

6. **The mode stops.** The turn ends and nothing further is built. This is a directive the mode follows, not a guarantee
   anything enforces ([D17](artifacts/decision-log.md#d17-the-stop-is-a-directive-the-mode-follows-not-a-guarantee)).

7. **You respond, and the mode writes your response down.** Every piece of feedback goes into a running record before it
   is acted on. You can read that record whenever you ask, and when the mode applies a recorded entry to a later piece it
   names which entry it applied
   ([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-readable-written-record-rather-than-being-carried-in-memory)).

8. **The mode acts on your feedback.** The two kinds take different routes
   ([D9](artifacts/decision-log.md#d9-feedback-condemning-the-piece-in-hand-is-fixed-in-place-and-re-shown)):
   - **About the piece in hand.** The mode fixes it within that same piece and shows it again, naming the correction it
     applied and what it touched before restating the piece. That re-show is a stop like any other, so the loop returns
     to step 6 and waits. It does not return to step 3, because step 3 asks for your read before a build, and this piece
     is already built.
   - **About what comes next.** It shapes the next piece, and the loop returns to step 3 for that piece.

   Accepting a re-shown piece with nothing further to say also moves to the next piece, at step 3.

9. **The loop ends when the plan is finished or you end it.** Ending is your call by design; nothing computes a stopping
   point for you ([D18](artifacts/decision-log.md#d18-ending-the-loop-is-the-persons-call-and-nothing-computes-it)). The
   mode reports what was built, what your feedback changed, anything the plan named but did not reach, and the state of
   any work a backing skill left unfinished.

## Alternate Flows and States

### The backing skill owns the piece boundary

- **Entry condition:** The work sorted as skill-backed, meaning a Han skill covers it and carries the collaborative flag.
- **Sequence:** The mode hands the work to that skill. The skill does its own job unchanged, and stops at the point it
  already treats as the end of a unit rather than looping onward on its own
  ([D10](artifacts/decision-log.md#d10-five-skills-gain-an-opt-in-collaborative-flag)). Control returns to
  the pairing loop at step 5 of the primary flow.
- **Exit:** The backing skill's own work is complete, or you end the loop.

Five skills gain this flag, and none of them gains a new boundary. `tdd` already ends each cycle by crossing one
behavior off its list. `refactor` already ends each step by crossing off one named refactoring. `design-an-api` already
runs in distinct rounds and already surfaces its open items one at a time. `iterative-plan-review` already runs review
rounds with a stop rule computed from finding counts, and `plan-implementation` already runs resolution rounds. In every
case the flag changes only what happens when that existing boundary is reached: control returns to you instead of the
skill continuing on its own
([D10](artifacts/decision-log.md#d10-five-skills-gain-an-opt-in-collaborative-flag)).

The last two are the ones most worth naming, because neither stops for you today. `iterative-plan-review` surfaces a
disagreement between two reviewers and then keeps going without waiting for your answer. `plan-implementation` holds its
only question until every round is already finished.

### You want to move faster without giving up review

- **Entry condition:** You ask for more than one piece at a time, in whatever words: "show me the next three", "do the
  rest of the setup and stop before the interesting part."
- **Sequence:** The mode honors the request as asked, builds the pieces you named, and presents them together
  ([D19](artifacts/decision-log.md#d19-you-can-ask-for-several-pieces-at-once-and-the-loop-returns-to-its-normal-pace-after)).
- **Exit:** The loop returns to its normal pace at the following stop, without you having to ask for that.

This is the middle gear. Without it your only options are full ceremony on every piece or turning review off for the
remainder, and the second is what the mode exists to prevent.

### You asked to pair on implementing, without naming a discipline

- **Entry condition:** Your request says to build something but does not say whether to drive it from tests, restructure
  what is there, or sketch a shape first.
- **Sequence:** The mode does not guess. Step 2's proposed plan names which approach it intends and why, and that
  proposal is the thing you accept or redirect
  ([D4](artifacts/decision-log.md#d4-the-mode-proposes-the-plan-of-stopping-points-rather-than-asking-you-to-supply-one),
  [D11](artifacts/decision-log.md#d11-the-front-door-never-picks-the-discipline-for-you)). A single request may span more
  than one approach, such as sketching a shape and then building it test-first. When the plan sequences more than one
  backing skill, it orders them so each skill's own preconditions hold when its turn arrives.
- **Exit:** You accept or replace the proposed approach, and the loop proceeds from step 3.

### Your feedback reaches outside the piece in hand

- **Entry condition:** You ask for a change that would alter work outside the most recently built piece.
- **Sequence:** The mode names its reading before acting on it: it says that your feedback looks like it reaches past this
  piece, and what it would change about the plan. You then have three ways out
  ([D9](artifacts/decision-log.md#d9-feedback-condemning-the-piece-in-hand-is-fixed-in-place-and-re-shown)).
- **Exit:** You accept a revised plan, change it, or decline the reopening entirely. If you decline, your feedback is
  recorded as scoped to later work, and the plan you already agreed to continues.

The third exit exists because thinking out loud is the working style this mode is built for, and an offhand remark should
not silently replace a plan you agreed to.

### You end the loop early

- **Entry condition:** You say to stop, or to finish the rest without stopping.
- **Sequence:** The mode acknowledges the change in the same turn you ask for it, naming what remains that will now go
  unreviewed. When you asked it to finish without stopping, it continues from the current plan and reports at the end
  rather than at each piece.
- **Exit:** The loop is over. The mode reports the state of any work a backing skill left mid-cycle, and it names where
  the feedback record was written, in terms you can act on
  ([D18](artifacts/decision-log.md#d18-ending-the-loop-is-the-persons-call-and-nothing-computes-it)).
  A record that survives a session but that you cannot find is not a record.

## Edge Cases and Failure Modes

| Condition                                                                     | Required Behavior                                                                                                                                                                                                                     |
| ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Your request is too vague to sort                                              | The mode asks once, naming what was ambiguous and offering candidate readings of your request rather than posing a blank question. If the answer is still not enough, it proposes a plan against the most likely reading and says so.  |
| The work turns out to have no natural pieces                                   | The proposed plan says so and names a boundary it chose for a stated reason, so you have something concrete to redirect rather than a blank question ([D4](artifacts/decision-log.md#d4-the-mode-proposes-the-plan-of-stopping-points-rather-than-asking-you-to-supply-one)).                                                                                 |
| You respond to a stop with a question rather than a direction                  | The mode answers the question and stops again at the same place. A question holds your place; it never advances the work.                                                                                                             |
| You approve several pieces in a row without comment                            | The loop continues unchanged, and the mode adds no pressure to comment. Approval is a valid response, and a run of approvals is not read as a lapse in care. The mode does not volunteer anything in response to it ([D19](artifacts/decision-log.md#d19-you-can-ask-for-several-pieces-at-once-and-the-loop-returns-to-its-normal-pace-after)).                     |
| A backing skill hits one of its own stop conditions                            | That skill's stop wins and is reported to you as-is. The pairing loop does not override or soften it.                                                                                                                                 |
| The proposed plan turns out to be wrong once work starts                       | The mode says so at the next stop, names what it learned, and proposes a revised plan rather than silently working to a plan it no longer believes ([D4](artifacts/decision-log.md#d4-the-mode-proposes-the-plan-of-stopping-points-rather-than-asking-you-to-supply-one)).                                                                                   |
| The mode builds past a stop                                                    | The next thing it says names the overrun, states which pieces were built without review, and offers to walk back through them before continuing. It does not present the extra work as though you had approved it ([D17](artifacts/decision-log.md#d17-the-stop-is-a-directive-the-mode-follows-not-a-guarantee)).                    |
| The session is compacted or interrupted mid-loop                               | The running record of your feedback survives, because it is written down rather than remembered. On resuming, the mode restates the piece in hand and its position in the plan before continuing, so your continuity is restored alongside its own ([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-readable-written-record-rather-than-being-carried-in-memory), [D16](artifacts/decision-log.md#d16-every-stop-names-your-position-in-the-plan-and-the-plan-stays-available)). |
| You ask to understand something rather than produce something                  | The mode says this is not its work and names where it goes: paced explanation of code that already exists, a written overview, or an open research question. It does not sort the request as open-ended and propose a plan to build things. |
| The work maps to a backing skill that is not installed                         | The mode names the missing skill and offers you the choice between the open-ended path and installing it. It never substitutes silently, because hand-rolling a refactoring skips the passing-test gate that skill exists to enforce ([D12](artifacts/decision-log.md#d12-the-skill-lives-in-han-core-and-its-backing-skills-are-optional)). |

## User Interactions

- **Affordances.** One invocation, in whatever words you prefer, naming what to pair on. At each stop, an ordinary
  conversational turn: you say what you think, ask a question, redirect, approve, or ask for several pieces at once
  ([D19](artifacts/decision-log.md#d19-you-can-ask-for-several-pieces-at-once-and-the-loop-returns-to-its-normal-pace-after)).
  You can ask to read the feedback record
  ([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-readable-written-record-rather-than-being-carried-in-memory))
  or the current plan
  ([D16](artifacts/decision-log.md#d16-every-stop-names-your-position-in-the-plan-and-the-plan-stays-available))
  at any point.
- **Feedback.** Each stop names which piece this is against the plan and what remains, what was built, what you can
  check, and what changed
  ([D6](artifacts/decision-log.md#d6-a-stop-hands-you-checkable-claims-rather-than-a-case-for-the-work)). At a stop over
  a hard-to-reverse choice, the ask comes first, and declining it advances the stop unchanged
  ([D7](artifacts/decision-log.md#d7-the-mode-asks-for-your-read-first-only-where-a-mistake-is-expensive-to-undo)).
- **Error states.** A request too vague to act on produces one question with candidate readings rather than a guess. A
  backing skill's own blocking condition is reported in that skill's own words. An overrun past a stop is named rather
  than absorbed.

The pacing is the deliverable. The mode ends its turn at each stop rather than continuing, and every stop says where you
are in the plan. Asking for more than one piece at a time is part of the pacing, not an escape from it.

## Coordinations

| Coordinating System         | Direction | Interaction                                                                                 | Ordering / Consistency Requirement                                                                                                          |
| --------------------------- | --------- | -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `tdd`                       | outbound  | Runs the test-driven loop; returns control at the end of each behavior rather than continuing | The collaborative behavior applies only to an invocation made through `pairing`. An ordinary `tdd` invocation runs exactly as it does today. |
| `refactor`                  | outbound  | Runs the refactoring sequence; returns control at the end of each named refactoring           | Same condition. An ordinary `refactor` invocation runs exactly as it does today.                                                            |
| `design-an-api`             | outbound  | Runs its design rounds; returns control at the end of each round                              | Same condition. An ordinary `design-an-api` invocation runs exactly as it does today.                                                       |
| `iterative-plan-review`     | outbound  | Runs its review rounds; returns control at the end of each round                              | Same condition. An ordinary invocation runs its rounds to the computed stop rule exactly as it does today.                                  |
| `plan-implementation`       | outbound  | Runs its resolution rounds; returns control at the end of each round                          | Same condition. An ordinary invocation holds its single question until after every round, exactly as it does today.                         |
| The running feedback record | both      | Written after each stop, read before planning each piece, readable by you on request          | A stop's feedback is written before the next piece is planned, so no piece is built against feedback not yet recorded.                      |
| `code-walkthrough`          | neither   | No handoff. The two share their whole pacing vocabulary, so each has to say which side of produced-versus-existing work it is on | Nothing runs. This is a routing relationship only, and it exists because the shared words would otherwise send a request to the wrong skill.  |
| Han's configuration file    | inbound   | Supplies the output location the feedback record is written under                             | Read once at the start of the loop, so the record's location does not move mid-session.                                                     |

The five skill rows are the opt-in flag and nothing more
([D10](artifacts/decision-log.md#d10-five-skills-gain-an-opt-in-collaborative-flag)):
the flag applies to an invocation made through this mode, and every ordinary invocation of those skills is untouched
([D2](artifacts/decision-log.md#d2-every-existing-skill-keeps-its-current-default-behavior)). The feedback-record row is
what makes a correction given early still apply late
([D8](artifacts/decision-log.md#d8-your-feedback-goes-into-a-readable-written-record-rather-than-being-carried-in-memory)).
The `code-walkthrough` row runs nothing, and exists because the shared vocabulary would otherwise send a request to the
wrong skill
([D20](artifacts/decision-log.md#d20-both-entry-paths-are-supported-and-the-phrase-path-has-to-win-its-collisions)).

## What Else Has To Change When This Ships

Shipping this mode is not only building the mode. Four groups of material change the moment it lands, and all four are
part of the work rather than follow-up
([D21](artifacts/decision-log.md#d21-the-surfaces-that-stop-being-accurate-are-part-of-this-work)).

1. **`han-core` stops being what it says it is.** Its front door, the plugin index entry, and its manifests all describe
   it as the specialist agents, project discovery, and the shared rule files. It now also carries a working mode a person
   invokes directly, and every one of those descriptions needs to say so. The plugin index goes further and offers an
   install described as "only the shared agents and project discovery, with no other skills," which becomes untrue
   ([D12](artifacts/decision-log.md#d12-the-skill-lives-in-han-core-and-its-backing-skills-are-optional)).
2. **Five skills gain user-visible behavior.** `tdd`, `refactor`, `design-an-api`, `iterative-plan-review`, and
   `plan-implementation` each get a collaborative mode, so each one's own operator manual and its own routing text change
   alongside this mode's ([D10](artifacts/decision-log.md#d10-five-skills-gain-an-opt-in-collaborative-flag)). Three of
   the five live in `han-coding` and two in `han-planning`, so both plugins change, not only the one this mode ships in.
3. **A new shared rule file.** The stopping convention this mode follows is owned by `han-core` as a canonical rule file,
   beside the YAGNI, evidence, and configuration rules it already owns, because five skills consume the handoff contract
   rather than one ([D22](artifacts/decision-log.md#d22-the-stopping-convention-is-a-canonical-rule-file-owned-by-han-core)).
4. **The usual surfaces a new skill needs.** The skill itself, its long-form documentation, a line on its plugin's front
   door, an entry in the skills index, the project map, the workflow chains, and the version history.

Two things this mode does not need, stated so nobody adds them: it takes no size argument and dispatches no team, so the
sizing documentation does not apply to it.

## Out of Scope

- **Choosing the discipline for you.** The mode proposes and you decide. It never silently picks test-driven development
  over restructuring, or either over sketching a shape first
  ([D11](artifacts/decision-log.md#d11-the-front-door-never-picks-the-discipline-for-you)).
- **Changing how any skill behaves by default.** Every flag is opt-in
  ([D2](artifacts/decision-log.md#d2-every-existing-skill-keeps-its-current-default-behavior)). This is the operator's
  stated exclusion, quoted in the scope boundary record.
- **Group review.** The mode assumes one reviewer. Nothing here coordinates several people reviewing the same piece.
- **Automatic invocation.** The mode runs when you ask for it. Nothing triggers it on your behalf.
- **A stop rule computed from counts.** The Han skills that run review rounds, `iterative-plan-review` and
  `plan-implementation`, decide when to stop by counting and grading findings. Work being built produces no such
  countable signal, so this mode has nothing to compute over, and ending the loop stays your call ([D18](artifacts/decision-log.md#d18-ending-the-loop-is-the-persons-call-and-nothing-computes-it)).

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Making the collaborative mode the default for a whole session, rather than something you invoke per task

- **Why cut:** The scope boundary records the operator's acceptance of one skill and no output style. That excludes
  building an output style, a session-start hook, or a post-edit hook as part of this work. The record also notes that
  widening the mode beyond code reopens the input behind that choice, and that the decision stands until the operator
  revisits it.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### Carrying the feedback record across separate sessions

- **Why deferred:** No stated need. The evidence supporting a written record is about surviving within a working session.
  There, the measured comparison was six percent of critical steps missed with a written checklist against twenty-three
  percent from memory. Nothing establishes that feedback from a previous week should shape today's pieces, and doing so
  risks applying a correction whose reason has expired.
- **Reopen when:** You describe re-giving the same feedback across sessions, or a session's record is lost and costs you
  a repeat of work already reviewed.
- **Source:** Conversation context during specification.

### Detecting when your new feedback contradicts feedback you gave earlier

- **Why deferred:** Evidence test failed. No user-described need, incident, or measurement supports it. It is also the
  most expensive behavior anyone proposed for this mode: a comparison of every new remark against the whole record, at
  every stop. Its failure modes cut both ways. A false positive costs you a turn defending feedback you never
  contradicted, and a false negative protects nothing. A strictly simpler behavior satisfies the same concern and is in
  the spec instead. When the mode applies a recorded entry, it names which one, so you catch the conflict yourself with
  the entry in front of you.
- **Reopen when:** You give contradictory feedback in a run and the mode applies the wrong one.
- **Source:** Review findings F5 and F6 in [artifacts/team-findings.md](artifacts/team-findings.md).

### Offering the faster gear when you approve several pieces without comment

- **Why deferred:** Evidence test failed, and the premise was already removed. Synthesis struck the claim that a run of
  approvals signals a wish for a different pace, because no evidence in either research report speaks to what approvals
  mean. The offer resting on that claim survived the claim's removal. Nothing else supports it: no stated need, no
  incident, no measurement. It also costs a conditional and a once-per-session counter the mode would otherwise not need.
  You can ask for several pieces at any time, which is the behavior the evidence does support.
- **Reopen when:** You ask for several pieces at once more than once in a single run, or say you wished the faster pace
  had been offered.
- **Source:** Implementation review finding I3 in
  [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md).

### Giving the collaborative flag to any skill beyond the five that have it

- **Why deferred:** No candidate has evidence behind it. The widened test asks whether a skill produces its result across
  a sequence of units, where each unit stands on its own and later units build on earlier ones. Running it across every
  skill in every plugin the operator did not rule out found exactly the five that carry the flag. The rest fail in four
  groups: the inline guidance skills produce no result of their own, the publishing and export skills already stop before
  writing to a shared system, the one-document skills hand you a single synthesized artifact rather than a sequence, and
  `plan-a-feature` and `code-walkthrough` already stop for you so the flag would be a no-op.
- **Reopen when:** A new skill ships that produces its result across a sequence of units where each unit stands on its
  own, or you find yourself wanting to pair on a skill that runs to completion today.
- **Source:** Operator survey during specification, widened by review finding F10 and re-run across the suite at
  escalations E7 and E8, both in [artifacts/team-findings.md](artifacts/team-findings.md).

## Open Items

None. All three items this specification opened were settled before it closed, and each is recorded as a decision with
its rejected alternatives:

- Which convention owns the stops, settled as a canonical rule file owned by `han-core`
  ([D22](artifacts/decision-log.md#d22-the-stopping-convention-is-a-canonical-rule-file-owned-by-han-core)).
- Which further skills qualify for the flag, settled by running the widened test across every skill in the plugins the
  operator did not rule out ([D10](artifacts/decision-log.md#d10-five-skills-gain-an-opt-in-collaborative-flag)).
- Whether the skill keeps its original name, settled by renaming it
  ([D23](artifacts/decision-log.md#d23-the-skill-is-named-pairing-and-the-phrase-people-type-lives-in-its-description)).

## Summary

- **Outcome delivered:** Work gets built in pieces you reviewed, with your feedback shaping every piece after it.
- **Primary actors:** One person doing their own work, pairing with Claude on any kind of task.
- **Decisions settled by evidence:** 14 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 9 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `junior-developer`, `user-experience-designer`, `information-architect` — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** The guard against nodding through now asks before the build rather than after, which is
  what its evidence requires. The mode now tells you where you are in the plan, lets you read the feedback record, and
  lets you ask for several pieces at once. The skill stays in `han-core` with its backing skills treated as optional, the
  flag reaches five skills rather than two, and the skill is named `pairing` rather than for the phrase people type.
- **Remaining open items:** 0

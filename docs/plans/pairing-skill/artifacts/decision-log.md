# Decision Log: pairing

This file records every decision settled while specifying `pairing`. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file carries the history, rationale, evidence, and
rejected alternatives.

Two research reports back this specification. Both were produced in the same session, adversarially validated, and are
cited below by their titles rather than repeated:

- **The collaborative-mode report** — whether the mode belongs in an output style or a skill. Recommends one skill and no
  output style, at High confidence for the mechanism.
- **The chunk-boundary report** — what makes a reviewable stopping point when the work is not code. Recommends stopping
  where the kind of feedback changes, at High confidence for staging by concern, Medium for the per-kind units, and Low
  for open-ended work.

## Trivial decisions

None. Every decision was classified once, here, after the review round returned. Each one carries at least one promotion
signal: a driving finding, a dependent decision that rests on it, or evidence beyond the operator's framing. The seven
settled by operator input are not trivial for that reason alone, because each is either depended on by a later decision
or was reshaped by review. No D# number moved, so every inline link in the specification still resolves.

## Full decisions

### D1: The mode covers any kind of work, not only code

- **Question:** Is this a code-pairing mode, or a general working mode?
- **Decision:** A general collaborative working mode. Code is one case among several.
- **Rationale:** The operator widened the scope explicitly, giving two examples the code-only framing could not hold: a
  design pairing that produces a decision rather than code, and an open-ended request to pair on writing a response.
- **Evidence:** User input. The operator's exact words are quoted in
  [scope-boundary.md](scope-boundary.md) under "The widening."
- **Rejected alternatives:**
  - A code-only pairing mode — rejected because two of the operator's three named examples produce no code.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D5, D11, D12
- **Referenced in spec:** Outcome

### D2: Every existing skill keeps its current default behavior

- **Question:** Do the skills this mode builds on change how they run when invoked normally?
- **Decision:** No. Every collaborative flag is opt-in, and an existing invocation behaves exactly as it does today.
- **Rationale:** The operator stated this as an exclusion, preferring an opt-in workflow over changing any skill's
  defaults. It also keeps the change reversible: nothing about this work degrades an existing workflow if the mode turns
  out to be wrong.
- **Evidence:** User input, recorded in [scope-boundary.md](scope-boundary.md) under "Stated Exclusions."
- **Rejected alternatives:**
  - Making the collaborative loop the default for the skills that gain it — rejected because the operator excluded it in
    the same sentence that accepted the opt-in shape.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D10, D15
- **Referenced in spec:** Actors and Triggers, Out of Scope, Coordinations

### D3: The mode sorts the work before planning anything, using a named test

- **Question:** How does the mode know what shape the work has, and what happens when a request fits more than one shape?
- **Decision:** It applies a fixed ordered test and stops at the first match: skill-backed, then decision work, then prose
  work, then a fall-through to open-ended. The order is the tie-break, so drafting a decision record sorts as decision work
  rather than prose work. The sort result is named in the plan, so you can correct it.
- **Rationale:** The chunk-boundary report found a different established unit for each kind of work and no single unit that
  spans them, so sorting first is what lets one loop serve them all. Review found two problems with the first draft, both
  now fixed. The kinds were not mutually exclusive and nothing broke a tie, which meant two runs on the same request could
  sort differently and produce different loops; an ordered test with a first-match rule settles that the way this suite
  already settles it elsewhere, by naming the test rather than saying the mode identifies the right answer. And the sort
  was never disclosed, which made the single largest determinant of your experience the one thing you could not correct.
- **Evidence:** The chunk-boundary report's recommendation for the per-kind units. D1 established that more than one kind of
  work is in scope. The named-test form follows `code-walkthrough`, which does not ask for important steps but names what
  earns one. Review findings F7 and F8 drove the ordered test and the disclosure.
- **Rejected alternatives:**
  - One universal unit across all work — rejected because no source defines one, and the report searched for one.
  - Asking you which kind it is — rejected because the request usually says, and D4's reasoning applies.
  - Four kinds with open-ended as a peer category — rejected on review as a distinction that changed no behavior. The
    open-ended branch produces whatever the plan named, which is what the plan does regardless, so it is a fall-through
    rather than a kind. Keeping it as a fourth kind made the sort harder for no gain.
- **Linked technical notes:** —
- **Driven by findings:** F7, F8, F9
- **Dependent decisions:** D5, D11, D13
- **Referenced in spec:** Primary Flow

### D4: The mode proposes the plan of stopping points rather than asking you to supply one

- **Question:** Who decides where the work stops, and how is that decision reached?
- **Decision:** The mode proposes a plan naming the pieces and the reason for each boundary. You accept, change, or
  replace it, and either side can renegotiate as the work reveals itself.
- **Rationale:** Fifty years of goal-setting research finds that when difficulty is held constant, an assigned goal
  reaches commitment equivalent to a negotiated one as long as it comes with a rationale. So a proposal costs little
  against asking first, and buys a cheap early correction. A proposal also gives you something concrete to react to,
  where a blank question at the start asks you to plan work you have not seen.
- **Evidence:** The chunk-boundary report's option 2, resting on the goal-setting research and on `design-an-api`, which
  already surfaces open items one at a time on the stated reasoning that each answer reshapes the ones behind it.
- **Rejected alternatives:**
  - Asking you where to stop before proposing anything — rejected on judgment rather than evidence. The same research
    shows participation's real effect is that people set themselves harder targets, which licenses asking first too. The
    report says plainly that preferring a proposal is a judgment call, and this decision inherits that caveat.
  - Fixed-cadence stops decoupled from the work's shape — rejected because a cadence rule never says what should be ready
    at the stop, and its supporting sources describe visual design critique rather than this.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D5, D9, D11
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes
- **Known gap:** No study compares how carefully someone reviews at a checkpoint they helped choose against one imposed
  on them. The claim that negotiation improves review quality is not evidenced and is not part of this rationale.

### D5: A piece ends where the kind of feedback changes, not at a size threshold

- **Question:** What makes one piece of work one piece?
- **Decision:** The boundary falls where the kind of feedback changes. One unit of a backing skill's own work, one
  decision, one rung of a fidelity ladder for prose, or whatever the negotiated plan named for open-ended work.
- **Rationale:** This is the strongest-evidenced finding in either report, and it converges from four independent
  directions. Reviewing the shape before the surface matters because polish applied before the shape is settled gets
  thrown away when the shape changes.
- **Evidence:** The chunk-boundary report's option 1. Two national editing bodies define the same stages in the same
  order, one in the United States and one in the United Kingdom. Two peer-reviewed composition studies find that
  inexperienced writers revise at the word level while experienced writers revise for meaning and structure first. Design
  practice reaches the same conclusion from an unrelated field: low-fidelity work draws structural feedback, high-fidelity
  work draws only cosmetic feedback. For the decision unit, the originating architectural-decision-record source states
  that one record describes one significant decision, and an independently maintained community reference says the same.
- **Rejected alternatives:**
  - A word count, line count, or file count — rejected because no source supports a size threshold, and every source that
    addresses the question defines the unit by concern instead.
  - One concern pass over a whole finished draft, which is what the editorial evidence literally prescribes — rejected
    because it requires a finished draft before the first review, and this loop produces work in pieces. Adversarial
    validation caught this as the chunk-boundary report's sharpest internal contradiction, and the fidelity ladder is the
    resolution: it keeps the order of concerns the editorial evidence establishes while dropping the finished-draft
    precondition.
  - A bounded whole artifact reviewed in one piece — rejected for the same precondition, though it names a real risk this
    decision must live with: parts reviewed in isolation can each look right while the whole does not.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow
- **Known gap:** The prose unit is a reconciliation the report performed, not a practice any single source documents. Its
  confidence is Medium, and for open-ended work the report found no unit at all, which is why D4 carries that case.

### D6: A stop hands you checkable claims rather than a case for the work

- **Question:** What does a stop actually present?
- **Decision:** The specific things you can verify and what changed, stated plainly, with the reasoning available but not
  leading.
- **Rationale:** Explaining your reasoning to a reviewer does not reliably make them more careful and can make them less
  so. Explanations act as a signal of competence regardless of whether their content holds up, and a polished one invites
  agreement. What works instead is lowering the cost of checking a claim independently.
- **Evidence:** The chunk-boundary report's option 6. One study of five experiments with 731 participants found
  explanations reduce over-reliance only when they lower the cost of checking the claim; hard-to-parse explanations make
  things worse. A second study found passive explanations do not reduce over-reliance and sometimes increase it.
- **Rejected alternatives:**
  - A narrative walkthrough leading with why each choice was made — rejected because that is precisely the shape the
    studies found ineffective or harmful.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D7
- **Referenced in spec:** Primary Flow, User Interactions
- **Known gap:** Adversarial validation established that the two supporting studies are not independent of each other.
  They belong to the same research conversation about over-reliance and explanation, in the same venue, with one
  reframing the other's line of findings. Discounting both would leave this decision resting only on general habituation
  research, which addresses a different question.

### D7: The mode asks for your read first only where a mistake is expensive to undo

- **Question:** Should a stop require your own judgment before showing its work, and if so, how often?
- **Decision:** Only for a piece the plan marked as containing a choice that is expensive to walk back. The ask comes
  before the build. Declining to answer is a first-class response that advances the stop unchanged, and the reveal
  afterward presents the work in the same form as any other stop, without restating your read, scoring it, or defending a
  divergence from it.
- **Rationale:** Asking the reviewer to commit to their own judgment before seeing the assistant's reasoning was the one
  intervention that measurably reduced over-reliance, and the same study measured its cost in reduced satisfaction.
  Amazon's reversibility framework says where to spend that cost: slow, deliberate review for irreversible choices and
  fast review for ones you can walk back. Paying the friction on every stop of a long session is how a mode stops getting
  used.

  Three details came out of review and matter as much as the frequency. The ask has to precede the build, because both
  studies work by having the person commit before the answer exists; an ask arriving after the work is on disk buys the
  cost and none of the benefit. A non-answer has to be accepted, because the study's benefit concentrated in people
  already inclined toward effortful thinking, and a mandatory guess taxes the fatigued, the second-language, and the
  newly-arrived reader hardest while returning them the least. And the reveal must not grade the guess, because a stop
  that scores you teaches you to answer noncommittally, and a stop that defends itself leads with the fluent case D6
  rules out on evidence.
- **Evidence:** User input, choosing this option over never asking and over asking at every stop. The options presented
  rested on the chunk-boundary report's options 5 and 6. The three refinements come from review findings F1, F2, and F3.
- **Rejected alternatives:**
  - Never asking first — rejected because it drops the one intervention controlled studies found effective, leaving the
    expensive stops unguarded too.
  - Asking at every stop — rejected because the measured satisfaction cost applies at every stop, and the operator judged
    that too high a price for a mode meant to be lived in.
  - Keeping the ask at the stop after the build, as first drafted — rejected because it inverts the mechanism its own
    evidence depends on.
- **Linked technical notes:** —
- **Driven by findings:** F1, F2, F3
- **Dependent decisions:** D14
- **Referenced in spec:** Primary Flow, User Interactions

### D8: Your feedback goes into a readable written record rather than being carried in memory

- **Question:** How does feedback given at an early stop still apply at a much later one?
- **Decision:** Every piece of feedback is written into a running record before it is acted on, and the record is read
  before each piece is planned. You can read that record whenever you ask, and when the mode applies a recorded entry to a
  later piece it names which entry it applied.
- **Rationale:** Model accuracy drops substantially when relevant information sits in the middle of a long context, which
  is exactly where a correction given at the second stop sits by the seventh. A written record also survives a session
  compaction, which memory does not.
- **Evidence:** The chunk-boundary report. The strongest empirical anchor is surgical: teams using a written checklist
  missed about 6 percent of critical steps against about 23 percent working from memory, in simulated crisis scenarios.
  Professional editing implements the same idea as the style sheet, a running record of decisions and reasons kept so a
  decision is not re-argued or misremembered. Han already carries an equivalent convention in the escalation register.
- **Rejected alternatives:**
  - Relying on the conversation itself to carry feedback forward — rejected because a compaction destroys it and because
    mid-context information is the least reliably retrieved.
  - Keeping the record as the mode's private notes, as first drafted — rejected on review. A misrecorded correction would
    then govern every later piece and surface only as work that feels subtly wrong, which is the failure this decision
    exists to prevent, inverted onto the person.
  - Detecting contradictions across the record automatically — rejected as the expensive way to reach the same place.
    Naming which entry was applied lets you catch the conflict yourself, with the entry in front of you, and has no false
    positives. The detection behavior moved to the deferred list.
- **Linked technical notes:** —
- **Driven by findings:** F5, F6
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, User Interactions, Edge Cases and Failure Modes, Coordinations
- **Known gap:** No study tests written-versus-remembered feedback for this kind of work. The surgical evidence is an
  analogy from an adjacent domain, and is labeled as such.

### D9: Feedback condemning the piece in hand is fixed in place and re-shown

- **Question:** When your feedback says the piece just built is wrong, does it get fixed now or become the next piece?
- **Decision:** Fixed now, and shown to you again before anything new is built, with the re-show naming the correction
  it applied and what it touched before it restates the piece. When the feedback would change work outside the piece in
  hand, the mode says it reads the feedback that way before acting on it, and you can accept the reopened plan, change
  it, or decline the reopening and have the feedback recorded as scoped to later work.
- **Rationale:** Nothing gets layered on top of work you already flagged. The reopening clause is what stops one piece
  from absorbing an unbounded fix loop: feedback that reaches outside the piece is a signal the plan was wrong, not that
  the piece needs more patching. Review added the two halves that keep the person in the lead through it. A re-show that
  only says "here it is again" makes you re-read reviewed material to confirm the fix landed, which raises the cost of
  checking at the moment you are most invested, against the evidence behind D6. And a reopening the mode decided on its
  own replaces a plan you agreed to, which is the wrong answer for someone thinking out loud.
- **Evidence:** User input, choosing this over deferring the correction to the next piece and over asking each time.
  Review findings F24 and F25 added the declined reopening and the named correction.
- **Rejected alternatives:**
  - Recording the correction and fixing it as the next piece — rejected because the corrected version would not reach you
    until a full round later, and anything built in between would rest on work you had already called wrong.
  - Asking each time whether it is an in-place fix or the next piece — rejected because it adds a second question at
    exactly the stops that are already slowest.
- **Linked technical notes:** —
- **Driven by findings:** F24, F25
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D10: Five skills gain an opt-in collaborative flag

- **Question:** Which existing skills hand control back to the pairing loop at their own boundaries?
- **Decision:** `tdd`, `refactor`, `design-an-api`, `iterative-plan-review`, and `plan-implementation`. All five already
  have a unit and already close it explicitly. The flag changes only what happens at that existing close, and none of them
  gains a new boundary.
- **Rationale:** This was settled in three passes, and the test widened at each one.

  The first survey asked whether a skill changes files on its own, across a sequence, where each step builds on the last.
  Only `tdd` and `refactor` passed, and the operator confirmed both.

  Review then found the mode's own founding example falling outside that answer. The skill covering an API design runs
  discovery, an options document, a question round, and a validation round, and sorting past it would have handed you a
  thinner hand-rolled loop instead, silently. The operator gave it the flag rather than accept that trade, which widened
  the test to: does the skill produce its result across a sequence of units, where each unit stands on its own and later
  units build on earlier ones?

  Running the widened test across every skill in the plugins the operator did not rule out found two more. Both fail for
  the same reason `tdd` did, which is that they have a real unit boundary and run straight past it.
  `iterative-plan-review` runs review rounds against a stop rule computed from finding counts, and between rounds it
  surfaces a disagreement between two reviewers and then continues without waiting for the answer.
  `plan-implementation` runs resolution rounds and holds its only user escalation until after all of them are finished.

  The rest fail in four groups. The inline guidance skills produce no result of their own. The publishing and export
  skills push a finished artifact to a shared system and already gate before writing. The one-document skills hand you a
  single synthesized artifact rather than a sequence of standalone units. And `plan-a-feature` and `code-walkthrough`
  would gain nothing from the flag, because the first already interviews one question per turn through its design tree
  and the second already stops after every step.
- **Evidence:** User input at all three points, each time confirming a survey result. The two additions were verified
  against the skills themselves: `iterative-plan-review`'s round loop states that it surfaces a finding and continues if
  the user answers before the next round, and `plan-implementation` places its user escalation pass after its iterative
  resolution loop. D2 constrains every flag to be opt-in.
- **Rejected alternatives:**
  - `tdd` only — rejected because the operator confirmed both after the first survey.
  - Routing API-design work to `design-an-api` unpaired — rejected because it answers a founding example with "here is the
    right skill, but you are not pairing on it."
  - Letting the mode's own decision loop supersede that skill — rejected because it silently drops a discovery pass and an
    adversarial validation round the person would otherwise have had.
  - Stopping at three skills — rejected because the original reason for ruling out planning skills was that they already
    interview, and neither of these two stops between its rounds, so that reasoning does not reach them.
  - Flagging `plan-implementation` alone — rejected because `iterative-plan-review` is the one that currently continues
    past a disagreement it has already surfaced to you, which is the sharper of the two problems.
- **Linked technical notes:** —
- **Driven by findings:** F10
- **Dependent decisions:** D21, D22
- **Referenced in spec:** Alternate Flows and States, Coordinations, Open Items, What Else Has To Change When This Ships

### D11: The front door never picks the discipline for you

- **Question:** When you ask to pair on implementing something, does the mode decide whether to drive it from tests,
  restructure what is there, or sketch a shape first?
- **Decision:** No. The proposed plan names which approach it intends and why, and that proposal is what you accept or
  redirect. A single request may span more than one approach, and when the plan sequences more than one backing skill it
  orders them so each skill's own preconditions hold when its turn arrives.
- **Rationale:** The operator established this directly, correcting an earlier framing that treated the request as a
  routing problem to be solved by guessing. It also follows from D4: the mode proposes rather than decides, and the
  approach is one more thing the proposal names.
- **Evidence:** User input. The operator's exact words are quoted in [scope-boundary.md](scope-boundary.md) under "The
  widening." Review finding F27 added the ordering requirement: `refactor` refuses to run alongside an in-flight
  test-driven loop, so a plan that sequences the two in the wrong order trips that skill's own precondition and reads as
  the mode contradicting its own plan.
- **Rejected alternatives:**
  - Inferring the discipline from the request's wording and proceeding silently — rejected because the operator named it
    as the thing not to do, and because sketching a shape before a full test-driven build is a legitimate answer no
    keyword match would find.
- **Linked technical notes:** —
- **Driven by findings:** F27
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States, Out of Scope

### D12: The skill lives in han-core, and its backing skills are optional

- **Question:** Which plugin carries a pairing mode that covers prose, decisions, and code alike, given that the skills it
  hands work to live in a different plugin?
- **Decision:** `han-core`, invoked as `/han-core:pairing`. The backing skills are an optional enhancement rather than
  a requirement: the mode works on its own for prose, decisions, and open-ended work, and gains the skill-backed paths only
  when the plugin carrying that skill is installed. Three of the five live in `han-coding` and two in `han-planning`, so
  the two plugins go missing independently. When a backing skill is absent, the mode names it and offers you the choice rather than
  substituting silently.
- **Rationale:** D1 established that the mode covers any kind of work, and `han-core` is the shared foundation every Han
  install already carries. Reaching into the coding plugin to pair on a stakeholder email reads wrong.

  Review found the placement had a problem the original reasoning never checked. `han-coding` already depends on
  `han-core`, so a `han-core` skill that requires `han-coding` would close a dependency cycle, and `han-core`'s stated
  invariant is that it depends on no other Han plugin. Treating the backing skills as optional resolves it honestly rather
  than by omission: nothing is undeclared, because nothing is required. The general path is the point of the mode, and the
  skill-backed paths are the enhancement.

  Two consequences follow and are part of the work. The plugin's own front door, index entry, and manifests describe it as
  the agents, project discovery, and the rule files, and all of them must now say it carries a working mode. The plugin
  index also offers an install described as having no other skills, which stops being true.
- **Evidence:** User input at both points: choosing `han-core` on fit, then confirming it after review finding F11 named
  the dependency cycle and the labeling mismatch. The cycle was verified directly against the plugin manifests.
- **Rejected alternatives:**
  - `han-coding`, as originally named — rejected because the mode covers work with no code in it, and that plugin's front
    door groups it with `tdd`, `refactor`, and `code-review`.
  - A new `han-collaboration` plugin — rejected twice. First as a whole plugin for one skill on no evidence a second is
    coming, then again after the cycle was found, because treating the backing skills as optional achieves the same
    correctness without the new plugin.
  - Requiring `han-coding` from `han-core` — rejected because it is a dependency cycle and breaks a stated invariant.
- **Linked technical notes:** —
- **Driven by findings:** F11
- **Dependent decisions:** D21
- **Referenced in spec:** Actors and Triggers, Edge Cases and Failure Modes, What Else Has To Change When This Ships

### D13: Three kinds of work plus a fall-through, not four kinds

- **Question:** Is open-ended work a category the mode sorts into, or the place a request lands when nothing else matches?
- **Decision:** A fall-through. The sort has three tests and anything failing all three is open-ended, where the plan
  supplies the boundaries with no rule behind them.
- **Rationale:** Naming it a fourth kind implied a rule existed. None does: the research searched for a unit for
  open-ended work and found none, at Low confidence, which is the lowest rating in either report. Treating it as a
  fall-through says the same thing honestly and makes the sort simpler at no cost, because the open-ended branch produces
  whatever the plan named, which is what the plan does for every kind anyway.
- **Evidence:** The chunk-boundary report's Low confidence rating and its explicit statement that no source defines a unit
  for this case. Review finding F9 raised the no-op branch under the YAGNI rule.
- **Rejected alternatives:**
  - Four peer kinds — rejected because the fourth changed no behavior and made the sort harder.
  - Dropping the loop entirely for open-ended work and simply conversing — rejected because it gives you nothing to
    redirect before the work exists, which is the one thing a proposed plan buys.
- **Linked technical notes:** —
- **Driven by findings:** F9, F23
- **Dependent decisions:** —
- **Referenced in spec:** How Confident Each Part of This Design Is, Primary Flow

### D14: The reversibility call is announced in the plan, and the ask precedes the build

- **Question:** Who judges that a choice is expensive to walk back, when, and can you argue with the call?
- **Decision:** The plan proposed before work starts names which pieces it expects to carry such a choice. That makes the
  call visible and contestable at plan time, when contesting is cheap, and it means the ask in D7 can come before the
  build rather than after.
- **Rationale:** The framework this rests on treats reversibility as an explicit shared classification whose whole value is
  in being visible and arguable. Left silent, the friction arrives unpredictably, you cannot budget attention around it,
  and you can neither wave off a call that is wrong nor flag a piece the mode missed. The person who knows which choices
  are expensive in their own codebase is you, and without this there is no channel for you to say so.
- **Evidence:** The reversibility framework in the chunk-boundary report, which that report records as corroborated by
  an independent secondary source describing it identically. Review findings F1 and F4 established that the call was
  silent and that the ask was ordered wrongly against its own evidence.
- **Rejected alternatives:**
  - Judging reversibility silently at each stop — rejected because it makes the promise that friction arrives only where
    it is warranted unverifiable from your seat.
- **Linked technical notes:** —
- **Driven by findings:** F1, F4
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D15: For skill-backed work the pre-work plan names the unit, and the first stop carries the list

- **Question:** How can the mode promise a plan of pieces before a backing skill has produced its own list?
- **Decision:** It cannot, so the promise splits. For skill-backed work, the plan before any work starts names the backing
  skill, the unit it will stop at, and the reason. That skill's own list of units is surfaced as the plan of pieces at the
  first stop, where you can still redirect it.
- **Rationale:** The backing skills build their lists partway into their own runs and report them without stopping. At the
  moment the pre-work plan is made, the list does not exist. The original promise was therefore either unmet or a silent
  change to a backing skill's gating, and D2 forbids the second. Splitting the promise keeps both intact.
- **Evidence:** The structure of `tdd` and `refactor`, both of which report their plan and continue immediately rather than
  gating on it. D2 forbids changing that. Review finding F12.
- **Rejected alternatives:**
  - Making the backing skills gate on their list so the plan can include it — rejected because it changes their default
    behavior, which D2 excludes.
  - Promising the full list up front anyway — rejected because it is a promise the mode cannot keep.
- **Linked technical notes:** —
- **Driven by findings:** F12
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow

### D16: Every stop names your position in the plan, and the plan stays available

- **Question:** How does the person know where they are, how much is left, and what the plan currently says?
- **Decision:** Each stop names which piece this is against the plan and what remains. The current plan is available on
  request, and a revised plan is named as revised. On resuming after a compaction or interruption, the mode restates the
  piece in hand and its position before continuing.
- **Rationale:** The person agreed at plan time to a queue depth they then could not see. Without it they cannot answer
  "do I have the attention for two more, or should I stop cleanly here", which is the decision the faster gear in D19
  exists to serve, and after a renegotiation they cannot answer "what did I agree to" at all. Two conventions already in
  this suite carry exactly this and were dropped in translation: the walkthrough keeps a step counter, and the escalation
  rule states how many questions are pending so the operator knows the queue depth they are agreeing to.
- **Evidence:** The two in-repo conventions above. The measured cost of an interruption, at an average of 23 minutes and 15
  seconds to return to full focus, is what makes the resume case worth specifying rather than assuming. Review findings
  F13 and F14.
- **Rejected alternatives:**
  - Naming only what comes next, as first drafted — rejected because a one-step lookahead is not a position.
- **Linked technical notes:** —
- **Driven by findings:** F13, F14
- **Dependent decisions:** D19
- **Referenced in spec:** Primary Flow, User Interactions, Edge Cases and Failure Modes
- **Known gap:** The interruption figure is one study, which the research marks single-source and caveats for this
  application. It is why the resume case was specified rather than assumed; no part of the behavior depends on the
  number being exact.

### D17: The stop is a directive the mode follows, not a guarantee

- **Question:** Can the mode be prevented from building past a stop?
- **Decision:** No, and the specification says so rather than claiming otherwise. When an overrun happens, the next thing
  the mode says names it, states which pieces were built without review, and offers to walk back through them.
- **Rationale:** The collaborative-mode research is explicit that nothing can force a stop at a chunk boundary; every
  option it examined ultimately relies on the assistant following an instruction, and they differ in how much weight the
  instruction carries rather than in whether it can be enforced. Claiming a guarantee the mechanism cannot provide is
  worse than naming the limit, because it leaves the most likely real failure of this feature unspecified. The tendency is
  real in exactly the skill being flagged: `tdd` today runs to completion without further human input.
- **Evidence:** The collaborative-mode report's finding on enforceability. The structure of `tdd`. Review finding F15.
- **Rejected alternatives:**
  - Stating the stop as a hard guarantee, as first drafted — rejected because no mechanism backs it and no behavior was
    specified for the case where it fails.
- **Linked technical notes:** —
- **Driven by findings:** F15
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D18: Ending the loop is the person's call, and nothing computes it

- **Question:** What ends the loop, given that the plan can be reopened at any point?
- **Decision:** You do. The mode reports when the plan is finished, but with the plan reopenable on any out-of-piece
  feedback, "finished" is not a fixed target, and no rule computes a stopping point. However the loop ends, the report
  covers the state of any work a backing skill left mid-cycle and names where the feedback record was written.
- **Rationale:** The suite's review-round skills, `iterative-plan-review` and `plan-implementation`, end their rounds on
  a rule computed from finding counts and the number of specialists raising them, which is the only pattern where "are
  we done" has an answer nobody argues about. It needs a countable signal to gate on, and work being built produces
  none. Rather than invent one, the specification states that ending is deliberate rather than an oversight.
- **Evidence:** The chunk-boundary report's option 7 and its stated reason for not transferring. Review findings F16 and
  F26, the second of which found that a loop ended mid-cycle leaves edited and possibly failing files with nothing said
  about them.
- **Rejected alternatives:**
  - A computed stop rule — rejected because there is nothing to compute over.
  - Leaving it unstated — rejected because a reader would read it as a gap rather than a choice.
- **Linked technical notes:** —
- **Driven by findings:** F16, F26
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Out of Scope

### D19: You can ask for several pieces at once, and the loop returns to its normal pace after

- **Question:** What can the person do when full ceremony on every piece is more than they want, but turning review off is
  less than they want?
- **Decision:** Ask for more than one piece, in whatever words. The mode honors it as asked and returns to its normal pace
  at the following stop without being asked to.
- **Rationale:** Without this, the only two gears are full ceremony and no review at all, and the person who is tired at
  their eleventh stop has to choose between them. That is the failure the whole mode exists to prevent, reached through
  the mode's own controls. The walkthrough convention this specification claims to inherit already carries the exception
  and honors an explicit request for more than one step; it was dropped in translation.
- **Evidence:** The walkthrough skill's stated exception. Two practitioner sources describing review quality decaying into
  rubber-stamping past a volume threshold. Review finding F17.
- **Rejected alternatives:**
  - Only stop-or-finish-unattended, as first drafted — rejected because the middle case is the common one.
  - Requiring the person to re-request normal pace afterward — rejected as friction on the person already economizing.
- **Linked technical notes:** —
- **Driven by findings:** F17
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes, User Interactions

### D20: Both entry paths are supported, and the phrase path has to win its collisions

- **Question:** Does the mode start only when named outright, or also when described in the person's own words?
- **Decision:** Both. Naming it outright bypasses competition entirely. Saying it in your own words competes against every
  skill available in the session, and this mode's arrival therefore changes what several existing skills say about
  themselves.
- **Rationale:** Three of the four phrasings the operator offered as founding examples name another skill's strongest
  trigger word, and the fourth names no competing skill at all. For the three that collide, left unmanaged the person
  types their own sentence and gets the uninterrupted run this mode exists to replace, or gets stopped at every step
  when they wanted a straight run.

  The relationship needing description has no precedent here. Every existing boundary between two skills is exclusive: one
  does the job and the other does not. This one is not, because the mode runs the very skills it competes with. Stating it
  on one side only leaves a gap the request falls through, so both sides state it.
- **Evidence:** The four phrasings quoted in the scope boundary record, each checked against the routing text of the
  skill it names, which found a competing skill for three of them and none for the fourth. The suite's own guidance that
  one-way disambiguation is a gap. Review findings F18, F19, and F20.
- **Rejected alternatives:**
  - Supporting only the named invocation — rejected because the operator's own examples are all phrase-shaped.
  - Copying the existing exclusive boundary form — rejected because it cannot express a delegating relationship.
- **Linked technical notes:** —
- **Driven by findings:** F18, F19, F20
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers, Which Skill Answers When You Say It In Your Own Words, Coordinations

### D21: The surfaces that stop being accurate are part of this work

- **Question:** Is updating the documentation and manifests this mode invalidates part of shipping it, or a follow-up?
- **Decision:** Part of it. The specification names the three groups: the plugin's own identity in its front door, index
  entry, and manifests; the operator manuals and routing text of the five skills gaining the flag; and the usual surfaces
  a new skill needs.
- **Rationale:** The placement in D12 changes what `han-core` is, and the flag in D10 changes user-visible behavior of three
  existing skills. Both make existing text false on the day this ships. This repository's own rule is that a skill's
  long-form documentation lands in the same pull request as the skill, not as a follow-up. Naming the surfaces in the
  specification is what stops them being discovered one review comment at a time.
- **Evidence:** The repository's contribution guide and its documentation coverage rule. Review findings F11 and F22:
  F22 found the specification named no documentation surface at all, and F11 is where the plugin's own identity stopped
  matching what it carries.
- **Rejected alternatives:**
  - Leaving the surface list to the implementation plan — rejected because two of the three groups exist only as
    consequences of decisions made here, and would not be obvious to someone reading the implementation plan alone.
- **Linked technical notes:** —
- **Driven by findings:** F11, F22
- **Dependent decisions:** —
- **Referenced in spec:** What Else Has To Change When This Ships

### D22: The stopping convention is a canonical rule file owned by han-core

- **Question:** What owns the convention for how this mode stops and asks questions?
- **Decision:** A new canonical rule file owned by `han-core`, beside the YAGNI, evidence, and configuration rules that
  plugin already owns.
- **Rationale:** Han has an escalation rule already, and it does not fit. That rule assumes a single stop per run, because
  it exists to minimize interruptions in work meant to run on its own. This mode treats stopping as the deliverable. The
  research reached the same conclusion independently, saying a collaborative loop would need its own convention rather
  than an exception to that one.

  Owning it as a shared file rather than carrying it inline clears the evidence bar on a named direct dependency rather
  than on speculation. Five skills consume the handoff contract, not one: this mode needs the whole convention, and each
  flagged skill needs to know what returning control means at its own boundary. `han-core` is where the suite's canonical
  rule files already live, so the file has a home that matches what it is.
- **Evidence:** User input, choosing this over carrying the convention inline and over extending the existing escalation
  rule. The mismatch with the existing rule is stated in the collaborative-mode report and confirmed against that rule,
  whose named consumers are four planning skills and no coding or core skill.
- **Rejected alternatives:**
  - Carrying it inline in each skill — rejected because the handoff contract would then exist in five places with nothing
    canonical, which is the drift problem in a different shape. Simpler on the day it ships and worse afterward.
  - Extending the existing escalation rule to cover both — rejected because bending a rule built around a single stop to
    also serve a loop that stops constantly weakens it for the four planning skills depending on it today.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Open Items, What Else Has To Change When This Ships

### D23: The skill is named pairing, and the phrase people type lives in its description

- **Question:** Does the skill keep the name the operator first gave it?
- **Decision:** No. It is `pairing`, invoked as `/han-core:pairing`. "Pair with me on" stays as wording in the skill's
  description, so nothing about how a person asks for the mode changes.
- **Rationale:** The original name was a sentence addressed to the assistant, where every other skill in the suite is
  named for an activity or an artifact. The suite's own naming guidance asks for a gerund process name, which `pairing`
  is. Nothing about routing depends on the change, because a request is matched against a skill's description rather than
  its name, and the phrase that makes this mode easy to ask for stays exactly where it does its work.
- **Evidence:** User input, choosing this over keeping the original name with a recorded exception and over a name
  describing the loop. The naming convention is a checked-in rule in the plugin-building guidance, with a stated heuristic
  the original name violated. Review finding F34.
- **Rejected alternatives:**
  - Keeping `pair-with-me` and recording why the convention was set aside — rejected in favor of following the convention
    rather than carving an exception into it.
  - A name describing the loop, such as `collaborative-build` — rejected because `build` pulls back toward code, which is
    the framing this mode was deliberately widened away from.
- **Known gap:** The rename fixes the convention complaint and does not fix the scent complaint. `pairing` carries the
  same pair-programming associations the original name did, so someone scanning the skills index for help drafting a
  stakeholder response is no likelier to stop at it. That load falls on the skill's description, which has to carry the
  non-code triggers regardless of what the skill is called.
- **Linked technical notes:** —
- **Driven by findings:** F34
- **Dependent decisions:** —
- **Referenced in spec:** Open Items

# Decision Log: pair-with-me

This file records every decision settled while specifying `pair-with-me`. Behavioral statements live in
[../feature-specification.md](../feature-specification.md); this file carries the history, rationale, evidence, and
rejected alternatives.

Two research reports back this specification. Both were produced in the same session, adversarially validated, and are
cited below by their titles rather than repeated:

- **The collaborative-mode report** — whether the mode belongs in an output style or a skill. Recommends one skill and no
  output style, at High confidence for the mechanism.
- **The chunk-boundary report** — what makes a reviewable stopping point when the work is not code. Recommends stopping
  where the kind of feedback changes, at High confidence for staging by concern, Medium for the per-kind units, and Low
  for open-ended work.

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
- **Dependent decisions:** D10
- **Referenced in spec:** Actors and Triggers, Out of Scope, Coordinations

### D3: The mode sorts the work into four kinds before planning anything

- **Question:** How does the mode know what shape the work has?
- **Decision:** It sorts the request into work a Han skill already covers, work that produces a decision, work that
  produces written prose, or open-ended work fitting none of the first three.
- **Rationale:** The chunk-boundary report found a different established unit for each kind of work, and no single unit
  that spans them. Sorting first is what lets one loop serve all four. The four kinds are exactly the cases the evidence
  distinguishes: one where a backing skill already owns the boundary, two where an outside body of practice defines a
  unit, and one where nothing does.
- **Evidence:** The chunk-boundary report's recommendation, resting on the architectural-decision-record sources for the
  decision unit and on professional editing practice plus two composition studies for the prose unit. D1 established that
  more than one kind of work is in scope.
- **Rejected alternatives:**
  - One universal unit across all work — rejected because no source defines one, and the report searched for one
    specifically.
  - Asking you which kind it is — rejected because the request usually says, and D4's reasoning applies: a proposal you
    can correct beats a question you have to answer before seeing anything.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D5, D11
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
- **Decision:** Only at a stop containing a choice that is expensive to walk back. Every other stop hands you checkable
  claims without demanding a judgment first.
- **Rationale:** Asking the reviewer to commit to their own judgment before seeing the assistant's reasoning was the one
  intervention that measurably reduced over-reliance, and the same study measured its cost in reduced satisfaction. Amazon's
  reversibility framework says where to spend that cost: slow, deliberate review for irreversible choices and fast review
  for ones you can walk back. Paying the friction on every stop of a long session is how a mode stops getting used.
- **Evidence:** User input, choosing this option over never asking and over asking at every stop. The options presented
  rested on the chunk-boundary report's options 5 and 6.
- **Rejected alternatives:**
  - Never asking first — rejected because it drops the one intervention controlled studies found effective, leaving the
    expensive stops unguarded too.
  - Asking at every stop — rejected because the measured satisfaction cost applies at every stop, and the operator judged
    that too high a price for a mode meant to be lived in.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, User Interactions

### D8: Your feedback goes into a written record rather than being carried in memory

- **Question:** How does feedback given at an early stop still apply at a much later one?
- **Decision:** Every piece of feedback is written into a running record before it is acted on, and the record is read
  before each piece is planned.
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
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes, Coordinations
- **Known gap:** No study tests written-versus-remembered feedback for this kind of work. The surgical evidence is an
  analogy from an adjacent domain, and is labeled as such.

### D9: Feedback condemning the piece in hand is fixed in place and re-shown

- **Question:** When your feedback says the piece just built is wrong, does it get fixed now or become the next piece?
- **Decision:** Fixed now, and shown to you again before anything new is built. When the feedback would change work
  outside the piece in hand, it reopens the plan of stopping points instead of being patched in place.
- **Rationale:** Nothing gets layered on top of work you already flagged. The reopening clause is what stops one piece
  from absorbing an unbounded fix loop: feedback that reaches outside the piece is a signal the plan was wrong, not that
  the piece needs more patching.
- **Evidence:** User input, choosing this over deferring the correction to the next piece and over asking each time.
- **Rejected alternatives:**
  - Recording the correction and fixing it as the next piece — rejected because the corrected version would not reach you
    until a full round later, and anything built in between would rest on work you had already called wrong.
  - Asking each time whether it is an in-place fix or the next piece — rejected because it adds a second question at
    exactly the stops that are already slowest.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D10: Two skills gain an opt-in collaborative flag: tdd and refactor

- **Question:** Which existing skills hand control back to the pairing loop at their own boundaries?
- **Decision:** `tdd` and `refactor`. Both already have a unit and already close it explicitly. The flag changes only what
  happens at that existing close, and neither skill gains a new boundary.
- **Rationale:** A survey of every skill in the nine plugins the operator did not rule out applied one test: does this
  skill change files on its own, across a sequence, where each step builds on the last. Only these two pass. `tdd` ends
  each cycle by crossing one behavior off its list; `refactor` ends each step by crossing off one named refactoring. The
  planning skills already interview, the publishing skills already stop before writing to shared systems, and the analysis
  skills hand you one document.
- **Evidence:** User input confirming both after the survey, together with the structure of the two skills themselves.
  D2 constrains the flag to be opt-in.
- **Rejected alternatives:**
  - `tdd` only — rejected because the operator confirmed both when asked.
  - A flag on every file-changing skill — rejected because the survey found no others meeting the test.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States, Coordinations

### D11: The front door never picks the discipline for you

- **Question:** When you ask to pair on implementing something, does the mode decide whether to drive it from tests,
  restructure what is there, or sketch a shape first?
- **Decision:** No. The proposed plan names which approach it intends and why, and that proposal is what you accept or
  redirect. A single request may span more than one approach.
- **Rationale:** The operator established this directly, correcting an earlier framing that treated the request as a
  routing problem to be solved by guessing. It also follows from D4: the mode proposes rather than decides, and the
  approach is one more thing the proposal names.
- **Evidence:** User input. The operator's exact words are quoted in [scope-boundary.md](scope-boundary.md) under "The
  widening."
- **Rejected alternatives:**
  - Inferring the discipline from the request's wording and proceeding silently — rejected because the operator named it
    as the thing not to do, and because sketching a shape before a full test-driven build is a legitimate answer no
    keyword match would find.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Alternate Flows and States, Out of Scope

### D12: The skill lives in han-core

- **Question:** Which plugin carries a pairing mode that covers prose, decisions, and code alike?
- **Decision:** `han-core`, invoked as `/han-core:pair-with-me`.
- **Rationale:** D1 established that the mode covers any kind of work. `han-core` is the shared foundation every Han
  install already carries, and it depends on no other Han plugin, so a mode spanning several kinds of work sits at the
  right layer there. Reaching into the coding plugin to pair on a stakeholder email reads wrong.
- **Evidence:** User input, choosing this over the two alternatives below. The operator had named `/han-coding:pair-with-me`
  before widening the scope, and [scope-boundary.md](scope-boundary.md) records that the widening reopens inputs settled
  under the narrower framing.
- **Rejected alternatives:**
  - `han-coding`, as originally named — rejected because the mode covers work with no code in it, and the coding plugin's
    front door groups it with `tdd`, `refactor`, and `code-review`.
  - A new `han-collaboration` plugin — rejected as a whole plugin, marketplace entry, front-door document, and dependency
    wiring for one skill, on no evidence a second working-mode skill is coming.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Actors and Triggers

# Change Decision Log: Pre-build ask timing (issue #201)

<!--
This file records every decision committed while planning the pre-build ask timing change.
The plan itself lives in [../change-plan.md](../change-plan.md) — this file captures the
question, rationale, evidence, and rejected alternatives behind each decision.
Evidence about the text as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.

Every decision is classified as full or trivial. A decision is full when it has a rejected
alternative, rests on evidence beyond the user's framing, settles a Changing delta entry,
has a dependent decision, or carries dissent. Every decision settling a behavior-changing
delta entry is full, with no exception.
-->

## Trivial decisions

- D-9: The three rule copies stay byte-identical by copying the canonical file over the other two after every edit,
  checked with `md5 -q` printing one hash three times, and the rule edit ships as one change unit with its copies. —
  Referenced in plan: Change Units, Risks.
- D-10: Nothing is cut for scope. The five backing skills are outside the boundary and need no edit, because the one
  clause they can act on (S-1) lands in a section they already read (C-12). — Referenced in plan: Cut for Scope.
- D-11: The reason is classed as a finding already established, with issue #201 as its source; the issue is not a findings
  report in the Step 2 sense, so this run ran its own discovery round. — Referenced in plan: Why This Change, Current
  State.

## Full decisions

### D-1: Place each clause by the section whose responsibility it is

- **Question:** Where in `collaborative-stop-rule.md` does the sequencing rule live: a new `##` section, a subsection of
  "Asking before building, and when", or additions to the sections whose gaps the findings name?
- **Decision:** No new section and no subsection. The clause about a stop's scope goes into "What a stop presents". The
  clauses about the ask's turn, what a decline is and is not, and a bundled ask go into "Asking before building, and
  when", as bold-lead-in paragraphs, the device that section already uses (`**The test.**`, `**The ask itself**`,
  `**Declining is a first-class answer.**`). "Acting on the answer", "Pace", "Who reads this", and `## Contents` are
  unchanged.
- **Rationale:** C-3 locates the one-piece gap inside "What a stop presents"; fixing it elsewhere leaves the indicted
  section silent and makes a stop's shape depend on a section five of its six readers never open (C-12). C-1 locates the
  timing gap in a section titled "and when" that delivers only "before"; the fix makes the section deliver its title. C-5's
  gap is a missing negative definition beside the positive one at line 96. A new `##` would be a second home for a
  responsibility that already has one and would force a Contents edit (C-13).
- **Evidence:** C-1, C-3, C-5, C-12, C-13; software-architect proposal A1.
- **Behavior impact:** Changing, carried by the entries this decision places (see D-7).
- **Rejected alternatives:**
  - A new `##` section "Sequencing the ask" — rejected because it splits one responsibility across two sections, adds a
    Contents entry (C-13), and leaves "What a stop presents" silent on C-3.
  - One paragraph in the ask section only — rejected because it does not touch the section C-3 indicts and leaves C-5's
    decline clause with no negative definition, which is the misread the issue reports.
- **Revisit criterion:** A second rule about the ask's timing appears and the section grows past what a reader can hold.
- **Dissent (if any):** None.
- **Settles delta entry:** S-1, S-2
- **Dependent decisions:** D-2, D-3, D-4
- **Referenced in plan:** Target State, Surface Delta

### D-2: The sequencing rule's sentences, pinned

- **Question:** What are the exact sentences the rule and pairing Step 5 must agree on?
- **Decision:** Four pinned texts. The rule and the skill carry them; the plan's Target State section holds the full text
  under "R1", "R2", "P1", and "P2". In short:
  - R1, in "What a stop presents", after the reasoning-last paragraph: a stop covers what just closed and asks nothing
    about a later piece; naming the work that comes next is a report, not a question; the one question posed about an
    unbuilt piece is the pre-build ask, which has a turn of its own.
  - R2, in "Asking before building, and when", after "The ask itself": `**The ask is a turn of its own.**` It opens the
    marked piece's turn after the person has responded to the previous piece's stop, is the whole turn, and is never
    appended to the previous stop, BECAUSE a reply to a stop is a reply to that stop's piece only.
  - P1, pairing Step 5 item 1, replaced whole: the same four points in the loop's own terms (own turn after the previous
    reply; ends the turn; a reply to the previous stop answers that piece only; a bundled ask is unanswered and is
    presented now, on its own, before building).
  - P2, pairing Step 5 item 3, one sentence appended after "their review matters most": naming the next concern is a
    report about what comes next, never a question about it. A second sentence restating P1 and R1 was dropped at review
    (JD-007); see D-16.
- **Rationale:** R1 is worded "what just closed" rather than "one piece" so it does not contradict "Pace" ("Honor a
  request for more than one piece as asked") and leaves C-8 untouched. R1's second sentence keeps C-4's next-concern
  naming standing by distinguishing a report from a question. P2 pins the mechanical location C-2 found only implied by
  list order.
- **Evidence:** C-1, C-2, C-3, C-4; issue #201 "Suggested fix"; software-architect pins R1, R2, S1, S2.
- **Behavior impact:** Changing. A person sees the ask arrive as its own turn after their reply to the previous stop,
  never inside it. User's answer: "accept as described" (D-7).
- **Rejected alternatives:**
  - "A stop presents exactly one piece", the issue's wording — rejected because "Pace" already lets a person ask for
    several pieces at once and a stop then presents them together (C-8); "what just closed" holds in both gears.
  - Leaving Step 5 item 3 alone — rejected because C-4's next-concern sentence would then be the one forward-looking
    instruction in the file with no line saying it is a report, not a question.
  - A second P2 sentence, "A stop asks nothing about a later piece; a marked piece's ask waits for its own turn, at the
    top of the next pass through this step" — rejected at review (JD-007) because R1 and P1 already say both.
- **Revisit criterion:** A report that a run still bundles the ask after these sentences land (reopens D-7 and the
  deferred third repeated constraint).
- **Dissent (if any):** None.
- **Settles delta entry:** S-1, S-2, S-4
- **Dependent decisions:** D-4, D-6, D-7, D-12, D-16
- **Referenced in plan:** Target State, Surface Delta, Change Units

### D-3: A reply to a stop answers that stop's piece, and a decline has a negative definition

- **Question:** How does the text stop a reply aimed at piece N−1's stop from being read as declining piece N's ask, and
  what happens to "never require an answer before building"?
- **Decision:** Rewrite the rule's decline paragraph (lines 96–97) as pinned under "R3" in the plan's Target State:
  keep "Declining is a first-class answer" and its two examples; scope "Never re-prompt" to "once the person has
  replied to the ask" (review finding JD-002, so R4's re-presentation is not a re-prompt); replace "never require an
  answer before building" with "never hold the build for a fuller answer than the one given"; add "A decline is a reply
  to the ask. A reply to the previous stop, or to the plan, is a reply to that alone, and never counts as declining an
  ask the person has not yet answered." and "A question about the ask holds it open: answer the question and end the
  turn again." (D-13). The long-form doc's tip at lines 99–100 changes to match (pinned as "L4"), including "advances
  the piece" in place of "advances the stop" and "an ask you have not answered" in place of "have not seen" (review
  finding UX-001, so the doc promises the same condition the rule delivers).
- **Rationale:** C-5 finds the decline clause defines what counts as a decline and never what does not, and routes
  replies by content alone. The literal "never require an answer before building" licenses building with no reply, which
  contradicts R2; the replacement keeps what the sentence meant (a decline is enough) and drops what it accidentally
  allowed. C-9's "advances the stop" tells the person the ask and the stop are one thing, which is the conflation the
  issue reports.
- **Evidence:** C-5, C-9; issue #201 corollary; software-architect R3 and D4; pairing decision log D7 ("a non-answer has
  to be accepted").
- **Behavior impact:** Changing. Nothing is built until the person replies to the ask itself; "I don't know" still
  advances the piece. User's answer: "accept as described" (D-7).
- **Rejected alternatives:**
  - Keep "never require an answer before building" — rejected because read literally it permits the exact build the
    issue reports, and it contradicts R2.
  - Put the attribution rule in "Acting on the answer" as a fourth route — rejected because the three routes classify
    what the person volunteers, and the corollary restricts the run's reading of the run's own question, not the
    person's content (architect A1).
- **Revisit criterion:** A report that a run held the build waiting for a fuller answer after a decline.
- **Dissent (if any):** None.
- **Settles delta entry:** S-2, S-6
- **Dependent decisions:** D-6, D-7, D-12, D-13
- **Referenced in plan:** Target State, Surface Delta

### D-4: A bundled ask is handled at Step 5's re-entry, and Step 6 gains no route

- **Question:** Where does the issue's fourth clause (re-present a bundled ask) live, and what does a run do when it
  learns after the build that the ask was never engaged?
- **Decision:** The rule gains one paragraph, pinned as "R4" in the plan's Target State: `**A bundled ask is an
  unanswered ask.**` When an earlier turn put the ask into a stop and the reply spoke only to that stop's piece, present
  the ask again, on its own, before building; if the piece was already built when this comes to light, do not ask now,
  say that the ask went unanswered, and continue from the stop in hand. Pairing carries the before-build half as the
  last sentence of Step 5 item 1 (P1). Step 6 is unchanged: its re-show sentence "Do not return to the pre-build ask;
  this piece is already built" already states the after-build half.
- **Rationale:** Step 6 routes the reply to piece N−1 and returns "to the top of Step 5", where item 1 fires the ask.
  That re-entry already exists (C-2); item 1 was silent about an ask already mis-posed. C-7 finds no handler for the
  after-build case; R4's second sentence supplies it and agrees with both Step 6 and the rule's own reason that an ask
  after the build "collects the cost and none of the benefit".
- **Evidence:** C-2, C-7; issue #201 clause four; software-architect A4.
- **Behavior impact:** Changing. A run that bundled the ask asks again before building; a run that learns after the
  build says so and moves on. User's answer: "accept as described" (D-7).
- **Rejected alternatives:**
  - A fourth Step 6 route for "the ask was misread" — rejected because the loop already re-enters Step 5 item 1 before
    building, so the route exists; a fourth route would restate it.
  - Echo the after-build say-so sentence in Step 6 — rejected because Step 6 lines 186–187 carry the do-not-ask half
    and pairing reads the whole rule for the rest; a third restatement has no finding behind it.
- **Revisit criterion:** A run re-asks after the build despite R4.
- **Dissent (if any):** None.
- **Settles delta entry:** S-2, S-4
- **Dependent decisions:** D-7, D-14
- **Referenced in plan:** Target State, Surface Delta

### D-5: The record holds the person's words, and the run's reading is marked as the run's

- **Question:** What stops a run's interpretation ("ask declined") from entering the feedback record as the person's
  decision?
- **Decision:** The rule's "Recording what the person says" gains one paragraph, pinned as "R5" in the plan's Target
  State: an entry holds the person's words and names the stop or ask they answered; a reading the run adds follows the
  words and is marked as the run's, never written as what the person decided; an ask with no entry is an ask with no
  answer. R5 carries one worked example of an entry, because the entry's form is a contract the rule, Step 6, and the
  doc must agree on and the contract-pinning rule closes one with an example, not a description (review finding JD-006;
  D-15). Pairing Step 6's first sentence becomes "Write the response into the record, in the person's words and against
  the stop or ask it answers, before acting on it." (P3), and a reply to the ask is recorded against the ask by P1
  (D-13). The doc's line 85 changes to match and says any reading the skill adds is labeled as its own (L3, review
  finding UX-007). No new field, schema, or three-state marker.
- **Rationale:** C-6 finds the record instruction never says the record holds the person's words rather than the run's
  label, and the doc already promises "which piece prompted it" with nothing delivering it. The issue reports the wrong
  label reaching the record. Two sentences make the promise true and make "ask declined" unwritable as the person's
  decision. "No entry, no answer" closes the never-presented state by derivation, not by a field.
- **Evidence:** C-6, C-9; issue #201 "What didn't work" second bullet; software-architect A3. Unverified: the 2026-09-03
  record itself could not be inspected; whether "ask declined" was a label or a paraphrase is taken from the issue.
- **Behavior impact:** Changing. A person reading the record sees their own words with the run's reading labeled as
  such. User's answer: "accept the change as described" (D-8).
- **Rejected alternatives:**
  - Nothing, relying on the sequencing rule — rejected because doc lines 30 and 85 would keep promising what no text
    delivers, and a future misread of any kind could still land as the person's decision.
  - A three-state marker per ask (answered, declined, never presented) — rejected by the simpler-version test; deferred
    with its trigger in the plan.
- **Revisit criterion:** A second report of the record misstating an ask outcome after R5 lands.
- **Dissent (if any):** None.
- **Settles delta entry:** S-3, S-5, S-6
- **Dependent decisions:** D-6, D-8, D-13, D-15
- **Referenced in plan:** Target State, Surface Delta

### D-6: The long-form doc promises exactly what the rule delivers

- **Question:** What does the person get told, so the expectation the issue reports matches a promise the doc makes?
- **Decision:** Five edits to `han-core/docs/skills/pairing.md`, pinned as "L1" to "L5" in the plan's Target State,
  each delivering one rule sentence: "A stop" gains "and the stop asks you nothing about a later piece" (R1); "The
  pre-build ask" gains the own-turn promise (R2, R3); line 85 gains "in your words, and which stop or ask prompted it"
  (R5); the tip at lines 99–100 says "advances the piece" and that approving the previous piece never declines an ask
  you have not answered (R3); and the "Cost and latency" line at 117–118 adds one more turn for each marked piece,
  because R2 makes the existing "plus one turn per stop" false for a marked piece (review finding UX-006). An earlier
  L5, one sentence appended to "Why the ask comes before the build", was dropped at review as a second delivery of R2
  with an uncited mechanism claim (JD-008; D-16).
- **Rationale:** C-9 finds the doc's commitment is narrower than the expectation the issue reports and that its tip
  blurs the ask into the stop. A doc that promises more than the rule delivers, or less, is a broken contract with the
  reader.
- **Evidence:** C-9, C-6; software-architect D1–D5.
- **Behavior impact:** Preserving. The doc changes no run's behavior; it describes what S-1 through S-5 make true.
- **Rejected alternatives:**
  - Leave the doc and let the rule speak — rejected because the doc is the surface the person reads (C-9), and the
    issue's expectation came from a reader, not from the rule.
  - Leave the cost line alone — rejected because an existing sentence becomes false under R2, which is evidence in its
    own right, not an addition.
- **Revisit criterion:** Any later edit to R1–R5.
- **Dissent (if any):** None.
- **Settles delta entry:** S-6
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Change Units

### D-7: The user accepted the sequencing change at the behavior gate

- **Question:** Does the user accept that the ask becomes its own turn, a stop never carries it, a bundled ask is
  re-presented before the build, an after-build discovery is named rather than re-asked, and "never require an answer
  before building" goes?
- **Decision:** Accepted in full.
- **Rationale:** The gate escalates every behavior-changing entry whether or not it looks desirable. The question led
  with what the person sees at piece 2's stop and piece 3's turn, offered accepting without the after-the-fact clause and
  declining as alternatives, and recommended accepting.
- **Evidence:** User input, verbatim: "accept as described".
- **Behavior impact:** Changing, as described in D-2, D-3, D-4.
- **Rejected alternatives:**
  - Accept without the after-the-fact clause — offered and not chosen.
  - Decline — offered and not chosen.
- **Revisit criterion:** The user reopens it.
- **Dissent (if any):** None.
- **Settles delta entry:** S-1, S-2, S-4
- **Dependent decisions:** —
- **Referenced in plan:** Behavior Changes

### D-8: The user accepted the record change at the behavior gate

- **Question:** Does the user accept that the record holds their words with the run's reading marked as the run's, a
  step past the issue's "Suggested fix" paragraph?
- **Decision:** Accepted.
- **Rationale:** The question said plainly that this goes one step past the suggested fix and why it was planned (the
  issue's second effect, and the doc's undelivered promise), and offered declining as the alternative.
- **Evidence:** User input, verbatim: "accept the change as described".
- **Behavior impact:** Changing, as described in D-5.
- **Rejected alternatives:**
  - Decline — offered and not chosen.
- **Revisit criterion:** The user reopens it.
- **Dissent (if any):** None.
- **Settles delta entry:** S-3, S-5
- **Dependent decisions:** —
- **Referenced in plan:** Behavior Changes

### D-12: A marked first piece takes its ask after the plan, and the plan is treated like a stop for attribution

- **Question:** When the first piece of a plan is the marked one, there is no "previous piece's stop"; the previous turn
  is the plan proposal. Can a run append piece 1's ask to the plan and read "looks good" as declining it?
- **Decision:** R2, R3, P1, and L2 say "the previous stop, or the plan when the marked piece is the first", and "a reply
  to a stop or a plan is a reply to that alone". R4 says "a stop or the plan". R1 is unchanged; the plan turn is not a
  stop and does not gain the four elements.
- **Rationale:** Step 4 ends "Then wait. The person accepts the plan, changes it, or replaces it", so the plan is a turn
  the person replies to, and the rule's test at line 77 ("later pieces in the plan would have to be redone to undo it")
  makes piece 1 the likeliest marked piece. Without this clause the incident's shape recurs with a different host turn.
  The user accepted "the ask becomes its own turn, and a stop never carries it" (D-7); this extends the same behavior to
  the one turn that precedes piece 1. Settled from evidence as a necessity of the accepted change, not re-escalated; the
  Step 10 summary names it so the user can strike it.
- **Evidence:** Review findings JD-005 and UX-008 (merged); `pairing/SKILL.md` line 145; rule line 77.
- **Behavior impact:** Changing, within D-7's scope: the plan-approval turn carries no ask for piece 1, and "looks
  good" never declines one.
- **Rejected alternatives:**
  - Say "the previous turn" without naming the plan — rejected because the person reads L2, and "turn" is not a term the
    doc has given them; "stop" and "plan" both are.
  - Leave piece 1 uncovered — rejected because the reversibility test makes it the likeliest marked piece.
- **Revisit criterion:** The user strikes it, or a report shows the plan turn carrying an ask after this lands.
- **Dissent (if any):** None.
- **Settles delta entry:** S-2, S-4, S-6
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta, Behavior Changes

### D-13: A reply to the ask is recorded against the ask and then the build begins; it is not routed through Step 6

- **Question:** P1 ends the turn after the ask. The reply lands somewhere. Step 6's three routes all presuppose a built
  piece ("Fix it within that piece and show it again"), and a question in reply to the ask has two handlers ("Never
  re-prompt" in R3; "A question holds the person's place" at Step 6 line 193).
- **Decision:** P1 gains a paragraph: "When the reply arrives, write it into the record in the person's words, against
  this ask, then build. A declined answer is a complete one, and a question about the ask holds it open: answer it and
  end the turn again. The reply is not routed through Step 6, which handles replies to a stop." R3 gains the matching
  clause "A question about the ask holds it open: answer the question and end the turn again."
- **Rationale:** C-2 shows the loop's re-entry is by list order; once item 1 ends the turn, the executing run needs the
  next step named or it will either route the reply through Step 6 (nonsense for an unbuilt piece) or skip recording it
  (the record defect D-5 fixes). The question clause is a necessity of taking ask replies out of Step 6, because line
  193 then no longer covers them.
- **Evidence:** Review findings JD-001 and UX-005 (merged), JD-009; C-2, C-6; `pairing/SKILL.md` line 193.
- **Behavior impact:** Changing, within D-7 and D-8: the person's reply to the ask is recorded in their words, a
  question about the ask gets an answer and the ask stays open.
- **Rejected alternatives:**
  - A fourth Step 6 route for ask replies — rejected because the three routes are about a built piece and a fourth would
    carry an exception to each of them.
  - Leave the question case to line 193 — rejected because P1 takes ask replies out of Step 6, so 193 no longer applies.
- **Revisit criterion:** A report of a run building on a clarifying question, or of an ask reply missing from the
  record.
- **Dissent (if any):** None.
- **Settles delta entry:** S-2, S-4
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Surface Delta

### D-14: The after-build message names the run as the cause

- **Question:** R4's "say that the ask went unanswered" names no cause. The person did answer the turn in front of them;
  "unanswered" lands on them, which is the attribution defect the issue's second effect reports on another surface.
- **Decision:** R4's after-build sentence reads "say that the run put the ask under an earlier turn so it went
  unanswered, and continue from the stop in hand." No offer to re-ask.
- **Rationale:** The overrun clause at rule lines 67–69 is the precedent: it names cause, extent, and offer. The
  smallest form that names the cause is one clause. Not re-asking matches lines 73–75.
- **Evidence:** Review finding UX-002; rule lines 67–69, 73–75; issue #201 second effect.
- **Behavior impact:** Changing, within D-7: the after-build message says the run caused the loss.
- **Rejected alternatives:**
  - Keep the passive — rejected because it reads as the person's omission.
  - Add an offer to re-ask — rejected because an ask after the build "collects the cost and none of the benefit".
- **Revisit criterion:** A report that the message still reads as blame.
- **Dissent (if any):** None.
- **Settles delta entry:** S-2
- **Dependent decisions:** —
- **Referenced in plan:** Target State

### D-15: One worked example pins the record entry's form

- **Question:** R5 says a run's reading is "marked as the run's". Marked how? The rule, P3, and L3 must agree on an
  entry's shape.
- **Decision:** R5 gains one example: an entry reads, for example, "Piece 2 stop: 'commit and next' (run's reading:
  approved)". No field, no template, no marker syntax beyond the example.
- **Rationale:** The contract-pinning rule closes a contract with a worked example; a prose description does not. D-5
  rejected a field by the simpler-version test, and an example is not a field. Without it, "ask declined" beside the
  quote, unlabeled, still satisfies a loose reading.
- **Evidence:** Review finding JD-006; UX-007 (which found the form rightly unpinned as a schema and the doc silent on
  the marking); `han-planning/references/contract-pinning-rule.md`.
- **Behavior impact:** Changing, within D-8.
- **Rejected alternatives:**
  - Pin a marker syntax — rejected as over-specification with no incident behind it (UX-007).
- **Revisit criterion:** A report that a person could not tell their words from the run's in the file.
- **Dissent (if any):** None.
- **Settles delta entry:** S-3, S-6
- **Dependent decisions:** —
- **Referenced in plan:** Target State

### D-16: Two restatements are dropped as YAGNI

- **Question:** P2's second sentence restates R1 and P1; the original L5 delivers R2 a second time with an uncited
  mechanism claim. Does the reason justify either?
- **Decision:** P2 keeps only "That is a report about what comes next, never a question about it." The original L5 is
  dropped and recorded under Deferred (YAGNI); the L5 label now names the cost-line edit (UX-006).
- **Rationale:** The simpler-version test. The issue asks for one echo in Step 5, and P1 is it. L2 already delivers R2
  to the person.
- **Evidence:** Review findings JD-007, JD-008; `han-planning/references/yagni-rule.md` Gate 2.
- **Behavior impact:** Preserving; nothing observable changes by dropping a repeat.
- **Rejected alternatives:**
  - Keep both — rejected because neither has a finding of its own.
- **Revisit criterion:** A report of a run posing the ask from item 3's next-concern line, or a reader asking why the
  ask is a separate turn.
- **Dissent (if any):** None.
- **Settles delta entry:** S-4, S-6
- **Dependent decisions:** —
- **Referenced in plan:** Target State, Deferred (YAGNI)

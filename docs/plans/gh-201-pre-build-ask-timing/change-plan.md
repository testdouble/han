# Change Plan: Pre-build ask timing (issue #201)

## Why This Change

A pairing session on 2026-09-03 built a piece the plan had marked expensive to walk back without ever collecting the
person's own read of it. The run had tucked the pre-build ask for piece 3 under piece 2's stop, then read "commit and
next" as declining it. The feedback record then said "ask declined" as if the person had decided that. GitHub issue
#201 reports this and says the skill text permits it. The rule says the ask comes before the build, and pairing Step 5
says "ask first", but neither forbids folding the ask into the tail of the previous stop. The reason class is a finding
already established, with the issue as its source
([D-11](artifacts/change-decision-log.md#trivial-decisions)).

## What Changes, In One Paragraph

After this change, the collaborative stop rule says three things it does not say today. A stop covers what just closed
and asks nothing about a later piece. The pre-build ask is a turn of its own: it opens the marked piece's turn after the
person has replied to the previous stop. A reply to a stop answers that stop's piece only, so it never counts as
declining an ask the person has not seen. And the feedback record holds the person's words, with any reading the run
adds labeled as the run's. The pairing skill's loop echoes the first two in Step 5 and the third in Step 6. The
long-form doc promises each one to the person in the same terms. Nothing new is added to the rule's list of sections,
and the five backing skills are not touched.

## Current State

The rule's only timing constraint on the ask is "before the build, not at the stop afterward", where "the stop
afterward" is the marked piece's own stop
([C-1](artifacts/current-state-findings.md#c-1-the-rule-requires-the-ask-to-precede-the-build-and-says-nothing-about-which-turn-carries-it)).
Pairing Step 5 says "ask first" and gets turn separation only from its list order. Item 1 asks, item 4 ends the turn,
and Step 6 returns "to the top of Step 5"
([C-2](artifacts/current-state-findings.md#c-2-pairing-step-5-echoes-the-ask-as-ask-first-and-gets-turn-separation-only-from-the-loops-item-order)).
The definition of a stop never scopes it to one piece or forbids a question about a later one
([C-3](artifacts/current-state-findings.md#c-3-what-a-stop-presents-does-not-scope-a-stop-to-one-piece-or-forbid-forward-looking-content)).
One kind of forward-looking content is already required: naming the next concern when a piece closes one
([C-4](artifacts/current-state-findings.md#c-4-step-5-already-authorizes-one-kind-of-forward-looking-content-in-a-stop-naming-the-next-concern)).

A reply is routed by what it touches, never by which question it answers, and "Declining is a first-class answer"
defines a decline without saying what is not one
([C-5](artifacts/current-state-findings.md#c-5-a-reply-is-routed-by-what-it-touches-never-by-which-question-it-answers-and-the-decline-clause-has-no-negative-definition)).
The record holds whatever the run writes, and the doc promises "which piece prompted it" with nothing delivering it
([C-6](artifacts/current-state-findings.md#c-6-the-record-holds-whatever-the-run-writes-and-nothing-distinguishes-an-answered-ask-from-a-declined-one-from-one-never-presented)).
No error path covers a build made on a misread ask. The overrun clause fires only when a stop is skipped, and the
re-show route says not to return to the ask
([C-7](artifacts/current-state-findings.md#c-7-no-existing-error-path-covers-a-build-made-on-a-misread-ask-and-the-re-show-route-forbids-returning-to-the-ask)).
The doc promises "before it builds" and its tip says declining "advances the stop" where the rule says "the piece"
([C-9](artifacts/current-state-findings.md#c-9-the-long-form-doc-promises-before-it-builds-and-says-declining-advances-the-stop)).

Three facts bound the change. The rule is vendored byte-identical into two other plugins
([C-11](artifacts/current-state-findings.md#c-11-the-three-rule-copies-are-byte-identical-and-two-places-record-the-obligation-to-keep-them-so)).
The backing skills read only "Detecting the flag" and "What a stop presents"
([C-12](artifacts/current-state-findings.md#c-12-the-backing-skills-required-reading-excludes-the-ask-section-and-all-five-read-only-the-stops-shape)).
And the rule opens with a Contents list a new section would have to join
([C-13](artifacts/current-state-findings.md#c-13-the-rule-file-carries-a-contents-list-that-a-new-section-must-join)).

## Target State

Each clause lands in the section whose responsibility it is
([D-1](artifacts/change-decision-log.md#d-1-place-each-clause-by-the-section-whose-responsibility-it-is)). "What a
stop presents" owns the scope of a stop. "Asking before building, and when" owns the ask's turn, what a decline is and
is not, what happens to the reply, and what to do with a bundled ask. "Recording what the person says" owns the entry's
form. "Acting on the answer", "Pace", "Who reads this", and the Contents list are unchanged. Pairing Step 5 and Step 6
echo the rule; the doc promises it.

The sentences below are the contract. The rule, the skill, and the doc must agree on them, so the builder copies them
rather than paraphrasing. Wrap by hand at 120 columns; Prettier runs with `proseWrap: preserve` and will not reflow
them. Line numbers are as of 2026-09-11 and locate the insertion; the builder reads the current file.

### The rule: `han-core/references/collaborative-stop-rule.md`

**R1.** In "What a stop presents", a new paragraph between the paragraph ending "suppresses scrutiny." (line 63) and
"Then end the turn." (line 65)
([D-2](artifacts/change-decision-log.md#d-2-the-sequencing-rules-sentences-pinned)):

```markdown
A stop covers what just closed and asks nothing about a later piece. Its position line reports what remains, and naming
the work that comes next is a report, not a question. The one question this convention poses about a piece not yet
built is the pre-build ask, and it has a turn of its own.
```

**R2.** In "Asking before building, and when", a new paragraph after the one ending "the point is an independent read."
(line 94) ([D-2](artifacts/change-decision-log.md#d-2-the-sequencing-rules-sentences-pinned),
[D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution)):

```markdown
**The ask is a turn of its own.** It opens the marked piece's turn, after the person has responded to the previous
stop, or to the plan when the marked piece is the first, and it is the whole turn: pose it and end the turn. Never
append it to that stop or plan, BECAUSE a reply to a stop or a plan is a reply to that alone, and answers nothing about
a later piece.
```

**R3.** The decline paragraph (lines 96–97) is replaced whole
([D-3](artifacts/change-decision-log.md#d-3-a-reply-to-a-stop-answers-that-stops-piece-and-a-decline-has-a-negative-definition),
[D-13](artifacts/change-decision-log.md#d-13-a-reply-to-the-ask-is-recorded-against-the-ask-and-then-the-build-begins-it-is-not-routed-through-step-6)):

```markdown
**Declining is a first-class answer.** "I don't know" and "just show me" advance the piece exactly as a considered
answer does. Never re-prompt once the person has replied to the ask, and never hold the build for a fuller answer than
the one given. A decline is a reply to the ask. A reply to the previous stop, or to the plan, is a reply to that alone,
and never counts as declining an ask the person has not yet answered. A question about the ask holds it open: answer
the question and end the turn again.
```

**R4.** A new paragraph after R3 and before "**After the build, the reveal is an ordinary stop.**" (line 99)
([D-4](artifacts/change-decision-log.md#d-4-a-bundled-ask-is-handled-at-step-5s-re-entry-and-step-6-gains-no-route),
[D-14](artifacts/change-decision-log.md#d-14-the-after-build-message-names-the-run-as-the-cause)):

```markdown
**A bundled ask is an unanswered ask.** When an earlier turn put the ask into a stop or the plan and the reply spoke
only to that, the ask was never posed on its own: present it now, on its own, before building. That is the first ask,
not a re-prompt. If the piece was already built when this comes to light, do not ask now; say that the run put the ask
under an earlier turn so it went unanswered, and continue from the stop in hand.
```

**R5.** In "Recording what the person says", a new paragraph after the one ending "least reliably recalled." (line 106)
([D-5](artifacts/change-decision-log.md#d-5-the-record-holds-the-persons-words-and-the-runs-reading-is-marked-as-the-runs),
[D-15](artifacts/change-decision-log.md#d-15-one-worked-example-pins-the-record-entrys-form)):

```markdown
An entry holds the person's words and names the stop or ask they answered. A reading the run adds, such as "declined"
or "approved", follows the words and is marked as the run's, never written as what the person decided. An entry reads,
for example, "Piece 2 stop: 'commit and next' (run's reading: approved)". An ask with no entry is an ask with no answer.
```

### The skill: `han-core/skills/pairing/SKILL.md`

**P1.** Step 5 item 1 (lines 152–154) is replaced whole, as one list item with two paragraphs beneath it, the shape item
2 already uses. It must agree with R2, R3, and R4 on five points. The ask opens piece N's turn after the reply to the
previous stop or the plan, and the ask ends the turn. The reply is recorded against the ask, and then the build
begins. A reply to a stop or the plan answers that alone. A bundled ask was never posed, and it is presented on its own
before building ([D-2](artifacts/change-decision-log.md#d-2-the-sequencing-rules-sentences-pinned),
[D-4](artifacts/change-decision-log.md#d-4-a-bundled-ask-is-handled-at-step-5s-re-entry-and-step-6-gains-no-route),
[D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution),
[D-13](artifacts/change-decision-log.md#d-13-a-reply-to-the-ask-is-recorded-against-the-ask-and-then-the-build-begins-it-is-not-routed-through-step-6)):

```markdown
1. **If the plan marked this piece expensive to walk back, ask first, in a turn of its own.** The ask opens this piece's
   turn, after the person has responded to the previous stop, or to the plan when this is the first piece. Name the
   dimension the choice turns on, offer no candidate answers, and end the turn. Never append the ask to that stop or
   plan, BECAUSE a reply to it is a reply to that alone and answers nothing about this piece.

   When the reply arrives, write it into the record in the person's words, against this ask, then build. A declined
   answer is a complete one, and a question about the ask holds it open: answer it and end the turn again. The reply is
   not routed through Step 6, which handles replies to a stop.

   When an earlier turn already bundled the ask into a stop or the plan and the reply spoke only to that, the ask was
   never posed on its own: present it now, on its own, before building.
```

**P2.** Step 5 item 3, one sentence appended after "their review matters most." (line 173), so the one forward-looking
instruction in the file says it is a report
([D-2](artifacts/change-decision-log.md#d-2-the-sequencing-rules-sentences-pinned),
[D-16](artifacts/change-decision-log.md#d-16-two-restatements-are-dropped-as-yagni)):

```markdown
   That is a report about what comes next, never a question about it.
```

**P3.** Step 6, first sentence (line 180), replaced
([D-5](artifacts/change-decision-log.md#d-5-the-record-holds-the-persons-words-and-the-runs-reading-is-marked-as-the-runs)):

```markdown
Write the response into the record, in the person's words and against the stop or ask it answers, before acting on it.
```

Step 6's re-show sentence, "Do not return to the pre-build ask; this piece is already built.", stands unchanged. It
carries the do-not-ask half of R4's after-build case. The say-so half lives in the rule only, which pairing reads in
full ([D-4](artifacts/change-decision-log.md#d-4-a-bundled-ask-is-handled-at-step-5s-re-entry-and-step-6-gains-no-route)).

### The doc: `han-core/docs/skills/pairing.md`

Each edit delivers one rule sentence, and the plan names which
([D-6](artifacts/change-decision-log.md#d-6-the-long-form-doc-promises-exactly-what-the-rule-delivers)).

**L1.** The "A stop" key concept (lines 26–27), delivering R1:

```markdown
- **A stop.** The end of a turn. You get your position in the plan, what was built, what you can check, and what
  changed. The reasoning does not lead, and the stop asks you nothing about a later piece.
```

**L2.** The "The pre-build ask" key concept (lines 28–29), delivering R2 and R3
([D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution)):

```markdown
- **The pre-build ask.** For a piece the plan marked expensive to walk back, the skill asks what you expect before it
  builds. The ask is a turn of its own: it arrives after you have responded to the previous stop, or to the plan when
  the marked piece is the first, and nothing is built until you answer it or decline. Declining is a complete answer.
```

**L3.** Line 85, delivering R5
([D-15](artifacts/change-decision-log.md#d-15-one-worked-example-pins-the-record-entrys-form)):

```markdown
The record holds each piece of feedback you gave, in your words, and which stop or ask prompted it, and any reading the
skill adds is labeled as its own. When the skill applies a recorded entry to a later piece, it names which entry, so a
misrecorded correction surfaces while it is still cheap to fix.
```

**L4.** The tip at lines 99–100, delivering R3 and replacing "advances the stop"
([D-3](artifacts/change-decision-log.md#d-3-a-reply-to-a-stop-answers-that-stops-piece-and-a-decline-has-a-negative-definition)):

```markdown
- **Answer the pre-build ask honestly, including with "I don't know."** Declining advances the piece exactly as a
  considered answer does, and only a reply to the ask counts as one: approving the previous piece never declines an ask
  you have not answered. The ask exists to get an independent read, and a manufactured guess is worth less than none.
```

**L5.** The "Cost and latency" sentence at lines 117–118, because R2 makes "plus one turn per stop" false for a marked
piece ([D-6](artifacts/change-decision-log.md#d-6-the-long-form-doc-promises-exactly-what-the-rule-delivers)):

```markdown
Runs on the session model with no dispatch fan-out of its own. The skill itself is thin: the cost is whatever the
backing skill would have cost, plus one turn per stop, and one more for each piece the plan marked expensive to walk
back.
```

## Surface Delta

Every entry is Re-scoped: each element keeps its name and home and gains a responsibility. The three copies of the rule
are one element in three homes, so S-1 through S-3 each cover all three files
([D-9](artifacts/change-decision-log.md#trivial-decisions)).

### S-1: `collaborative-stop-rule.md` § "What a stop presents" — Re-scoped

**Target state.** The section defines the four elements of a stop, the reasoning-last ordering, the overrun clause, and
the scope of a stop. The scope covers what just closed, asks nothing about a later piece, and reports what comes next
without asking about it. The pre-build ask is named here as the one question posed about an unbuilt piece, with its own
turn (R1). Every skill that presents a stop, backing skills included, is bound by this section as before.

**Behavior.** Changing. A person never sees a question about a later piece inside a stop. Backing skills observe no
change, because none of them poses an ask (C-12). Settled by
[D-7](artifacts/change-decision-log.md#d-7-the-user-accepted-the-sequencing-change-at-the-behavior-gate).

**Why.** C-3 locates the one-piece gap here, and C-12 makes this the one section every reader of the rule opens.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-place-each-clause-by-the-section-whose-responsibility-it-is),
[D-2](artifacts/change-decision-log.md#d-2-the-sequencing-rules-sentences-pinned)

### S-2: `collaborative-stop-rule.md` § "Asking before building, and when" — Re-scoped

**Target state.** The section owns why the ask precedes the build, the reversibility test, and the ask's content. It
also owns the ask's turn (R2) and what a decline is and is not, including what a question about the ask does (R3). It
owns what to do with a bundled ask before and after the build (R4), and the reveal. "Never require an answer before
building" does not exist; the build waits for a reply to the ask, and a decline is a full reply. The plan turn counts
like a stop for attribution: a reply to it answers nothing about piece 1.

**Behavior.** Changing. The ask arrives as its own turn after the person's reply to the previous stop, or to the plan
for a marked first piece. A reply to that stop or plan never counts as declining it. A question about the ask keeps it
open. A bundled ask is asked again before the build. An ask discovered unanswered after the build is named, with the
run as the cause, not re-asked. Settled by
[D-7](artifacts/change-decision-log.md#d-7-the-user-accepted-the-sequencing-change-at-the-behavior-gate), extended at
review by [D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution).

**Why.** C-1, C-5, and C-7 locate the timing gap, the missing negative definition, and the missing after-build handler
here.

**Depends on.** S-1, so "has a turn of its own" in R1 points at a paragraph that exists.

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-place-each-clause-by-the-section-whose-responsibility-it-is),
[D-2](artifacts/change-decision-log.md#d-2-the-sequencing-rules-sentences-pinned),
[D-3](artifacts/change-decision-log.md#d-3-a-reply-to-a-stop-answers-that-stops-piece-and-a-decline-has-a-negative-definition),
[D-4](artifacts/change-decision-log.md#d-4-a-bundled-ask-is-handled-at-step-5s-re-entry-and-step-6-gains-no-route),
[D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution),
[D-13](artifacts/change-decision-log.md#d-13-a-reply-to-the-ask-is-recorded-against-the-ask-and-then-the-build-begins-it-is-not-routed-through-step-6),
[D-14](artifacts/change-decision-log.md#d-14-the-after-build-message-names-the-run-as-the-cause)

### S-3: `collaborative-stop-rule.md` § "Recording what the person says" — Re-scoped

**Target state.** The section owns when the record is written and the form of an entry. That form is the person's
words, the stop or ask they answered, and any reading the run adds marked as the run's, with one worked example (R5).
An ask with no entry is unanswered.

**Behavior.** Changing. A person reading the record sees their own words and sees the run's reading labeled as such.
Settled by [D-8](artifacts/change-decision-log.md#d-8-the-user-accepted-the-record-change-at-the-behavior-gate).

**Why.** C-6 finds the record holds whatever the run writes, and the issue reports the wrong label reaching it.

**Decision.**
[D-5](artifacts/change-decision-log.md#d-5-the-record-holds-the-persons-words-and-the-runs-reading-is-marked-as-the-runs),
[D-15](artifacts/change-decision-log.md#d-15-one-worked-example-pins-the-record-entrys-form)

### S-4: `pairing/SKILL.md` Step 5 — Re-scoped

**Target state.** Step 5 item 1 carries the ask's own turn, the reply-attribution rule, what happens to the reply, and
the bundled-ask handler in the loop's terms (P1). Item 3 says naming the next concern is a report, never a question
(P2). Items 2 and 4 are unchanged.

**Behavior.** Changing, the same observation as S-1 and S-2; this is the echo the driving loop reads. Settled by
[D-7](artifacts/change-decision-log.md#d-7-the-user-accepted-the-sequencing-change-at-the-behavior-gate).

**Why.** C-2 finds the loop's turn separation implied by list order and never stated, and its re-entry after an ask
turn unnamed. The issue asks for the echo.

**Depends on.** S-1, S-2. The skill must never say more than the rule delivers.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-the-sequencing-rules-sentences-pinned),
[D-4](artifacts/change-decision-log.md#d-4-a-bundled-ask-is-handled-at-step-5s-re-entry-and-step-6-gains-no-route),
[D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution),
[D-13](artifacts/change-decision-log.md#d-13-a-reply-to-the-ask-is-recorded-against-the-ask-and-then-the-build-begins-it-is-not-routed-through-step-6),
[D-16](artifacts/change-decision-log.md#d-16-two-restatements-are-dropped-as-yagni)

### S-5: `pairing/SKILL.md` Step 6 — Re-scoped

**Target state.** Step 6 opens by writing the response into the record in the person's words and against the stop or
ask it answers (P3). Its three routes and its re-show sentence are unchanged. Replies to an ask do not pass through it.

**Behavior.** Changing, the same observation as S-3. Settled by
[D-8](artifacts/change-decision-log.md#d-8-the-user-accepted-the-record-change-at-the-behavior-gate).

**Why.** C-6 finds Step 6's "Write the response into the record" never says whose words the record holds.

**Depends on.** S-3.

**Decision.**
[D-5](artifacts/change-decision-log.md#d-5-the-record-holds-the-persons-words-and-the-runs-reading-is-marked-as-the-runs)

### S-6: `docs/skills/pairing.md` — Re-scoped

**Target state.** The doc promises the person exactly what R1, R2, R3, and R5 deliver. A stop asks nothing about a later
piece (L1). The ask is its own turn after their reply to the previous stop or the plan, and nothing is built until they
answer or decline (L2). The record holds their words and which stop or ask prompted them, with the skill's reading
labeled as its own (L3). Declining advances the piece, and approving the previous piece never declines an ask they have
not answered (L4). A marked piece costs one more turn (L5).

**Behavior.** Preserving. The doc changes no run's behavior; it describes what S-1 through S-5 make true. The review
confirmed no run reads the doc.

**Why.** C-9 finds the doc's promise narrower than the expectation the issue reports, and its tip blurs the ask into
the stop.

**Depends on.** S-1, S-2, S-3. The doc must never promise more than the rule delivers.

**Decision.** [D-6](artifacts/change-decision-log.md#d-6-the-long-form-doc-promises-exactly-what-the-rule-delivers),
[D-3](artifacts/change-decision-log.md#d-3-a-reply-to-a-stop-answers-that-stops-piece-and-a-decline-has-a-negative-definition),
[D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution),
[D-15](artifacts/change-decision-log.md#d-15-one-worked-example-pins-the-record-entrys-form),
[D-16](artifacts/change-decision-log.md#d-16-two-restatements-are-dropped-as-yagni)

## Behavior Changes

Two things change for a person pairing, and the user accepted both. The review widened the first in three small ways,
each settled from evidence and named here so the user can strike any of them.

**The ask is its own turn, and a stop never carries it** (S-1, S-2, S-4). Today a run may show piece 2's stop with the
piece-3 question at the bottom and read "commit and next" as declining it. Afterwards, piece 2's stop ends the turn
with no question about piece 3; the next turn is the piece-3 question alone; nothing is built until the person answers
or declines. A run that bundles the ask anyway asks again on its own before building. A run that learns after the
build that the ask went unanswered says so and continues from the stop in hand. The line "never require an answer
before building" goes, because the build now waits for a reply to the ask, though "I don't know" is a full reply.
Decision: "accept as described"
([D-7](artifacts/change-decision-log.md#d-7-the-user-accepted-the-sequencing-change-at-the-behavior-gate)).

Three extensions from the review, within that decision:

- When the marked piece is the first one, the turn before it is the plan, and the plan carries no ask either; "looks
  good" never declines one ([D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution)).
- A question about the ask keeps it open: the run answers and ends the turn again. The reply to the ask is written into
  the record in the person's words before the build ([D-13](artifacts/change-decision-log.md#d-13-a-reply-to-the-ask-is-recorded-against-the-ask-and-then-the-build-begins-it-is-not-routed-through-step-6)).
- The after-build message names the run as the cause: "the run put the ask under an earlier turn so it went unanswered"
  ([D-14](artifacts/change-decision-log.md#d-14-the-after-build-message-names-the-run-as-the-cause)).

**The record holds the person's words, and the run's reading is labeled as the run's** (S-3, S-5). Today the run can
write "ask declined" as if the person decided it. Afterwards, each entry holds what the person typed and names the stop
or ask they answered. A reading the run adds follows their words and is marked as the run's. An ask with no entry is
unanswered. One example entry in the rule pins the shape. This goes one step past the issue's "Suggested fix"
paragraph, and the question said so. Decision: "accept the change as described"
([D-8](artifacts/change-decision-log.md#d-8-the-user-accepted-the-record-change-at-the-behavior-gate)).

## Change Units

Three units, in order. Each leaves every file consistent with the rule, because at every step the skill and the doc say
no more than the rule delivers. Ship them as one commit. The risk analyst found that Units 1 and 2 landing without Unit
3 would leave the doc contradicting the corrected rule, which is worse than today's narrower promise.

### Unit 1: The rule and its two copies

**What it does.** Applies R1 through R5 to the canonical rule, then copies it over the two vendored copies.

**Delta entries.** S-1, S-2, S-3.

**Justification.** Issue #201 "Suggested fix": "Add an explicit rule to `collaborative-stop-rule.md`".

**How you know it worked.** `md5 -q` over the three paths prints one hash three times, and it is no longer
`29db7843077527d17ff7c515b8b062fc`. `npm run lint` passes. The Contents list is unchanged. Reading the file, every
sentence of R1 through R5 is present verbatim, and "never require an answer before building" is absent
([D-9](artifacts/change-decision-log.md#trivial-decisions)).

### Unit 2: The pairing skill

**What it does.** Applies P1, P2, and P3 to `han-core/skills/pairing/SKILL.md`.

**Delta entries.** S-4, S-5.

**Ordering constraint.** After Unit 1, so the skill never says more than the rule delivers.

**Justification.** Issue #201 "Suggested fix": "(and echo it in pairing Step 5)".

**How you know it worked.** Step 5 item 1 agrees with R2, R3, and R4 on the five points named under P1. Step 5 keeps
four numbered items, because Prettier renumbers ordered lists, and item 1's two trailing paragraphs are indented three
spaces so they stay inside the item. `npm run lint` passes, and `wc -l` stays under 500. The
md5 check from Unit 1 still prints one hash three times.

### Unit 3: The long-form doc

**What it does.** Applies L1 through L5 to `han-core/docs/skills/pairing.md`.

**Delta entries.** S-6.

**Ordering constraint.** After Unit 1, so the doc never promises more than the rule delivers.

**Justification.** A necessity of Units 1 and 2: the doc is the surface the person reads (C-9), and the expectation the
issue reports came from a reader.

**How you know it worked.** Each of L1 through L5 reads beside the rule sentence it delivers and says nothing the rule
does not. `npm run lint` passes. The md5 check still prints one hash three times.

## Risks

**A paraphrase where a copy was needed.** The sentences above are contracts across three files. A builder who rewords
one side breaks the agreement the plan exists to pin. Detect it by reading each pair side by side at the end of Units 2
and 3.

**A copy that drifts.** Editing a vendored copy directly, or forgetting to copy after a late edit to the canonical file,
leaves the three copies unequal. The md5 check at the end of every unit catches it.

**Three plugins change.** The rule lives in `han-core`, `han-coding`, and `han-planning`, so a release after this
change touches all three. The plan bumps no version; that is the release skill's call.

**R1 is read by six skills.** "What a stop presents" is the whole contract for the five backing skills (C-12), so R1
changes what every collaborative stop may contain, not only pairing's. C-12 verified that none of the five poses an
ask, so they observe no change. The builder still reads R1 once against each of their "Running collaboratively"
paragraphs before closing Unit 1; they are outside the boundary and nobody downstream checks them.

**No ADR links the rule to its design record.** "Never require an answer before building" traces to the pairing plan's
decision D7. That record will name a sentence the rule no longer has, and nothing links the two. D-3 records why it
went; a reader of the old record has to find this plan. Writing an ADR is outside the boundary.

**Prettier will not reflow prose.** `proseWrap: preserve` means a line over 120 columns stays over. Wrap the pinned
text by hand as shown. Prettier does renumber ordered lists and trim inline code spans, so P1 stays item 1 and no new
code span carries leading or trailing spaces.

## Deferred (YAGNI)

- **A three-state marker per ask in the record** (answered, declined, never presented). R5's quote-and-attribute form
  covers the incident with no field, and "no entry, no answer" derives the third state. Reopen when a second report
  shows the record misstating an ask outcome after R5 lands.
- **Ask behavior inside a batch or a finish-without-stopping run** (C-8). The issue's run used neither gear. R1 is
  worded "what just closed" so it holds in both. R2 and P1 describe the normal gear, one stop per piece, and say
  nothing about a marked piece inside a batch. Reopen when a report shows a marked piece going unasked
  inside either gear.
- **A third repeated constraint in the SKILL.md preamble** (C-10). P1 carries the constraint with a BECAUSE at its one
  point of execution. Reopen when a bundled ask is reported after P1 lands.
- **An instruction for correcting a disputed record entry in place.** The issue reports the person corrected the record,
  and under R5 the correction lands as a quote against the ask beside the attributed run label. Reopen when a stale run
  label governs a later piece despite a recorded correction.
- **An echo of the after-build say-so in Step 6** (C-7). Step 6's re-show sentence carries the do-not-ask half, and
  pairing reads the whole rule for the rest. Reopen when a run re-asks after the build despite R4, or stays silent
  about an unanswered ask.
- **A piece anchor on the ask turn** (review finding UX-003), such as a leading "Before piece 3 is built:". The ask
  names the dimension the choice turns on and nothing else; a person returning to scrollback reconstructs which piece
  from the plan. No incident shows a person misidentifying it. Reopen when a person answers an ask about the piece just
  approved, or asks which piece the question concerns.
- **An acknowledgment on a re-presented ask** (review finding UX-004), saying why the same question appears twice. The
  re-ask happens once and a one-word decline ends it. Reopen when a person answers a re-presented ask with "I already
  answered that" or the like.
- **A sentence in the doc's "Why the ask comes before the build" on why the ask is its own turn** (review finding
  JD-008). L2 already delivers R2, and the sentence's mechanism claim has one incident behind it. Reopen when a reader
  asks why the ask is a separate turn.

## Cut for Scope

Nothing was cut. The boundary excludes the five backing skills, and the plan needed nothing from them. The one clause a
backing skill can act on (R1) lands in a section they already read, and none of them poses an ask
([D-10](artifacts/change-decision-log.md#trivial-decisions)).

## Open Items

None block the change. One non-blocking item the builder inherits. The 2026-09-03 session's feedback record was not
inspected, so whether "ask declined" was written as a label or a paraphrase is taken from the issue's wording. R5
covers both.

## Review Findings

One round, at the medium cap of two. `han-core:junior-developer`, `han-core:user-experience-designer`, and
`han-core:risk-analyst` ran in parallel against the draft plan. Nothing blocked. Every finding resolved from evidence,
so no question reached the user; the extensions to accepted behavior are named in Behavior Changes.

Findings that changed the plan, merged by substance:

- **A marked first piece has no previous stop** (JD-005, UX-008). R2, R3, R4, P1, and L2 now name the plan turn.
  [D-12](artifacts/change-decision-log.md#d-12-a-marked-first-piece-takes-its-ask-after-the-plan-and-the-plan-is-treated-like-a-stop-for-attribution).
- **The ask's reply had no route** (JD-001, UX-005, JD-009). P1 gained a paragraph: record the reply against the ask,
  then build; a question holds the ask open; not routed through Step 6. R3 gained the question clause.
  [D-13](artifacts/change-decision-log.md#d-13-a-reply-to-the-ask-is-recorded-against-the-ask-and-then-the-build-begins-it-is-not-routed-through-step-6).
- **"Never re-prompt" sat beside "present the ask again"** (JD-002, UX-004). R3 scopes re-prompting to after a reply;
  R4 says the bundled ask was never posed, so this is the first ask. UX-004's acknowledgment line is deferred.
  [D-3](artifacts/change-decision-log.md#d-3-a-reply-to-a-stop-answers-that-stops-piece-and-a-decline-has-a-negative-definition),
  [D-4](artifacts/change-decision-log.md#d-4-a-bundled-ask-is-handled-at-step-5s-re-entry-and-step-6-gains-no-route).
- **The after-build message read as the person's omission** (UX-002). R4 names the run as the cause.
  [D-14](artifacts/change-decision-log.md#d-14-the-after-build-message-names-the-run-as-the-cause).
- **The record entry's form was described, not pinned** (JD-006, UX-007). R5 carries one worked example; L3 says the
  skill's reading is labeled as its own. [D-15](artifacts/change-decision-log.md#d-15-one-worked-example-pins-the-record-entrys-form).
- **The doc and the rule pinned different conditions** (UX-001). L4 says "have not answered", matching R3.
  [D-3](artifacts/change-decision-log.md#d-3-a-reply-to-a-stop-answers-that-stops-piece-and-a-decline-has-a-negative-definition).
- **The doc's cost line became false** (UX-006). L5 now edits "Cost and latency" instead of adding a second delivery
  of R2. [D-6](artifacts/change-decision-log.md#d-6-the-long-form-doc-promises-exactly-what-the-rule-delivers).
- **Two restatements failed the simpler-version test** (JD-007, JD-008). P2's second sentence and the original L5 are
  gone. [D-16](artifacts/change-decision-log.md#d-16-two-restatements-are-dropped-as-yagni).
- **The claim that Step 6 carried both halves of R4 was overstated** (JD-003). The plan, D-4, and the deferred entry now
  say Step 6 carries the do-not-ask half only.
- **Three risks were missing** (risk-analyst): R1's reach across six skills, the lost link to the pairing plan's D7, and
  Unit 3 shipping late. All three are in Risks; the units now ship as one commit.

Findings closed against the findings file (Pass C): the risk analyst's concern that R1's effect on the five backing
skills was unverified is answered by C-12, which read all five. Findings that stayed as recommendations only: JD-004
(R2 and P1 describe the normal gear; the C-8 deferral now says so). The risk analyst scored every deferral's trigger as
right and promoted none.

Unverified, and never presented as blocking: every specialist reasoned from the issue's account of the 2026-09-03
session, because the transcript and its record are not in the repository. That is the plan's one open item.

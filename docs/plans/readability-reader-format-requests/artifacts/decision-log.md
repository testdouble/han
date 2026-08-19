# Decision Log: The readability standard honors what the reader asked for

Every decision behind [../feature-specification.md](../feature-specification.md), with the evidence it rests
on and the alternatives that were rejected.

## Full decisions

### D1: The standard gains a check for the shape the reader asked for

- **Question:** Does the readability standard get an enforcement point for a format constraint the reader
  states, and if so what does it check?
- **Decision:** Yes. The check compares the draft against the reader's stated shape in three respects: count,
  format, and register.
- **Rationale:** The work item names this as its first proposal and names the failure it fixes. Two format
  constraints were stated in the first turn and neither had anywhere to be checked, so the run recovered them
  over three more turns.
- **Evidence:** GitHub issue testdouble/han#177, `## Proposal` item 1: "the draft matches the shape the
  reader asked for in count, format, and register." Its `## What didn't work` section records the cost: "four
  turns for a request fully specified in turn one." Trust class: direct user-described need, the strongest
  class the evidence rule recognizes.
- **Alternatives rejected:**
  - Leave the standard alone and rely on the drafting instructions. Rejected because the drafting
    instructions were already in force during the failing session and did not hold.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** evidence

### D2: An explicit reader request outranks every other criterion

- **Question:** When the reader's stated shape collides with another rule in the standard, which one wins?
- **Decision:** The reader's request wins over every other criterion, including the banned-word list. It wins
  only where an actual collision exists.
- **Rationale:** The user chose this directly. It matches the work item's own wording, which says the reader
  constraint "outranks the other six when they conflict." The "only where an actual collision exists" limit
  comes from that same clause: a request for a plain-language summary collides with nothing, so nothing is
  unlocked.
- **Evidence:** The user's answer on 2026-08-19, quoted in full: "Your request wins on everything." The
  bounding clause is the work item's own "when they conflict."
- **Alternatives rejected:**
  - The request wins on shape but never on words, keeping the banned-word list absolute. Rejected by the user.
  - The request wins on words only when the reader names the specific word. Rejected by the user.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** user input

### D3: The shape check is a numbered criterion, not a governing principle

- **Question:** Does the shape check join the numbered check, or sit above it as a governing principle beside
  the fidelity clause and the clumsy-prose escape?
- **Decision:** It joins the numbered check as a criterion of its own. The line declaring the set closed is
  reopened.
- **Rationale:** The work item asks for this in words and states that reopening the closure is deliberate. The
  failure analysis supports it: the standard's governing principles were in force during the failing session
  and one of them fired in the wrong direction, so a principle without an enforcement point is what produced
  the failure.
- **Evidence:** Issue #177 `## Proposal` item 1: "This requires reopening the 'these six criteria are the
  whole check' line, which is deliberate closure, so it is a real decision and not a typo fix." The closure
  line itself is at `han-communication/references/readability-rule.md:130` and again in
  `han-communication/output-styles/han-readability.md:87`.
- **Alternatives rejected:**
  - Add it as a governing principle above the check, which is the shape a prior plan chose for a comparable
    addition (`docs/plans/orwell-six-rules/artifacts/implementation-decision-log.md:78-85`, decision D-4).
    Rejected because that prior decision was made to avoid falsifying the count on downstream surfaces, and
    D6 removes that cost by making the count-bearing references count-free.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** evidence

### D4: A simplification request lets facts move or drop, and the drop is silent

- **Question:** When the reader asks for less than the source carries, what happens to a fact that will not
  fit, and is the reader told?
- **Decision:** The fact moves to a place the reader can still reach when one exists, and is dropped when none
  does. The drop is not announced.
- **Rationale:** The user chose silence directly. The move-first preference survives from the work item's
  proposal, which offers moving as the first option.
- **Evidence:** The user's answer on 2026-08-19, quoted in full: "Drop it silently." This departs from the
  work item's own proposal text, which reads "or is dropped with the drop named. It stays absolute against
  silent loss, which is the failure the section was written to prevent." The user was shown that the option
  meant no note and chose it. Their direction governs over the work item's wording.
- **Alternatives rejected:**
  - Name the drop in one short line below the requested shape. Rejected by the user. This was the recommended
    option and the one the work item's own text describes.
  - Count the note against the requested shape. Rejected by the user.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** user input

### D5: Fidelity stays absolute whenever the reader asked for nothing

- **Question:** Does the fidelity clause weaken for every draft, or only when the reader asked for less?
- **Decision:** Only when the reader asked for less. With no stated request, the clause is unchanged and every
  fact is carried at full precision.
- **Rationale:** The work item scopes its own proposal this way and names the failure the clause exists to
  prevent. Widening it further would trade a narrow fix for the exact loss the clause was written to stop, and
  no evidence asks for that.
- **Evidence:** Issue #177 `## Proposal` item 2: "It stays absolute against silent loss, which is the failure
  the section was written to prevent." The clause under change is `## Fidelity wins` at
  `han-communication/references/readability-rule.md:97-102` and `han-readability.md:71-75`.
- **Alternatives rejected:**
  - Weaken the clause generally, so any draft may shed a fact for readability. Rejected: no evidence supports
    it and the work item argues against it.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** evidence

### D6: References to the check's size stop naming a number

- **Question:** Twenty-one skills and two operator-facing documents describe the check by its size. Adding a
  criterion makes each of those wrong. Do they get renumbered, or stop naming a number?
- **Decision:** They stop naming a number. Each becomes a reference to the standardized self-check with no
  count attached.
- **Rationale:** Renumbering fixes today's break and rebuilds the same trap for the next change. Going
  count-free fixes it once. One skill in the repository is already written this way and reads fine, so the
  target wording exists and does not have to be invented. The repository states the same principle for its
  own indexes.
- **Evidence:** A repository-wide search on 2026-08-19 found the phrase in 21 `SKILL.md` files across seven
  plugins, listed in `.discovery-notes.md`, and in `docs/readability.md:105` and
  `han-communication/docs/output-styles/han-readability.md:72`.
  `han-communication/skills/readability-guidance/SKILL.md` already says "the standardized self-check" and
  "the fidelity criterion" with no number. The project's own convention in `CLAUDE.md` reads: "Indexes stay
  complete, not counted."
- **Alternatives rejected:**
  - Renumber every reference to the new size. Rejected: it costs the same edit today and repeats in full on
    the next change to the check.
  - Leave the references stale. Rejected: each one would instruct a reader to run a check of a size that does
    not exist.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** evidence

### D7: The readability editor is left unchanged

- **Question:** Does the readability editor agent gain the shape criterion, the fidelity scope note, or both?
- **Decision:** Neither. The agent is untouched.
- **Rationale:** The editor cannot check a request it never receives. Every skill that dispatches it passes a
  file path and a named audience and nothing else. Its own rubric is a separate set from the standard's check
  and its statement about that set's size stays true, so nothing there goes stale either.
- **Evidence:** `han-communication/agents/readability-editor.md:95` carries its own rubric and the sentence
  "They are the whole rubric." The rubric's sixth item is progressive disclosure, where the standard's sixth
  is fact preservation, so the two sets already differ. The dispatch brief in
  `han-planning/skills/plan-a-feature/SKILL.md:435` is representative: "Pass the editor the file path ... and
  the named audience."
- **Alternatives rejected:**
  - Add the shape criterion to the editor's rubric. Rejected: the editor has no access to the request the
    criterion checks against.
  - Add the fidelity scope note to the editor. Rejected: the scope note only fires on a reader's request to
    simplify, which the editor never sees.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** evidence

### D8: A simplicity test beside the sentence-length ceiling is deferred

- **Question:** Does the sentence-length criterion gain a simplicity test, as the work item's third proposal
  asks the run to consider?
- **Decision:** No. It is deferred with a named reopening trigger.
- **Rationale:** The motivating case is already covered. The failing session's sentences were short and not
  simple, and the reader had asked for simple, so the new shape criterion catches it. The remaining case needs
  a subjective reading the standard rules out by name.
- **Evidence:** Issue #177 frames the item as "Consider whether", not a commitment. The standard's own
  constraint is at `han-communication/references/readability-rule.md:117-118`: the check "evaluates concrete,
  behaviorally-anchored yes/no criteria, never 'is this clear?'"
- **Alternatives rejected:**
  - Add a simplicity test now. Rejected on the evidence test and on the standard's own bar for what a
    criterion may ask.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** evidence

### D9: The heading-placement and self-introduced-count failures are deferred

- **Question:** The work item names two more failures from the same session: a fact filed under a heading that
  contradicts it, and a count the draft itself got wrong. Do they get checks?
- **Decision:** No. Both are deferred with named reopening triggers.
- **Rationale:** Both are real and neither is proposed for a fix. Each rests on a single observation, and the
  standard states that it keeps its check small on purpose.
- **Evidence:** Issue #177 lists both under `## What didn't work` and neither under `## Proposal`. The
  keep-it-small principle is stated at `han-communication/references/readability-rule.md:130-131`: the set
  "is kept small on purpose so it applies as one focused pass rather than decaying under its own weight."
- **Alternatives rejected:**
  - Add both as criteria. Rejected on the evidence test and against the stated keep-it-small principle.
- **Driven by findings:** —
- **Linked technical notes:** —
- **Settled by:** evidence

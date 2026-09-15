# Current State Findings: Pre-build ask timing (issue #201)

## Provenance

Produced by this run's own discovery round on 2026-09-11. `han-core:structural-analyst` and `han-core:behavioral-analyst`
were each given the area named in [scope-boundary.md](scope-boundary.md): the canonical
`han-core/references/collaborative-stop-rule.md` with its two vendored copies, `han-core/skills/pairing/SKILL.md`, and
`han-core/docs/skills/pairing.md`. `han-core:concurrency-analyst` was not dispatched; the area holds no concurrent
access. The structural analyst read the five backing skills' "Running collaboratively" paragraphs only to confirm which
sections of the rule they depend on (C-12). GitHub issue #201 is the recorded reason, not a findings report; nothing here
was extracted from it.

The project-context items below come from this run's own sweep, not from the specialists.

## Project Context

- **Stack:** Markdown skill, agent, and rule text executed by Claude Code, plus Bash under `scripts/`. No application
  build. `npm run lint` runs Prettier, ShellCheck, and file-hygiene hooks; `npm test` runs Bats over `*.bats` files
  (from CLAUDE.md `## Project Discovery`).
- **Conventions source:** `CLAUDE.md` at the repo root. The authoring guidance for skills lives under
  `han-plugin-builder/skills/guidance/references/`.
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md` only. It does not concern pairing or the
  stop rule.
- **Coding standards found:** `han-communication/references/writing-voice.md` and `readability-rule.md` govern every
  doc's prose. `han-plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md` line 53
  keeps a SKILL.md body under 500 lines, and `skill-reference-files.md` lines 114–116 require a `## Contents` list on any
  reference file over roughly 100 lines.
- **Recent churn:** In the last 90 days the three rule copies changed twice (2026-08-14 `432d1b9` creation, 2026-08-20
  `33ed427` contents-list sweep). `pairing/SKILL.md` changed three times (2026-08-14 creation `2ac091e`, 2026-08-14
  `66fd62b` concern splitting, 2026-08-19 `0e5f44f` config script). `docs/skills/pairing.md` changed three times, all on
  2026-08-14. No commit since 2026-08-20 has touched the area.
- **Design record:** `docs/plans/pairing-skill/artifacts/decision-log.md` carries the decisions that shaped the ask
  protocol. D7 settled "the ask comes before the build" and "declining is a first-class response", and rejected "keeping
  the ask at the stop after the build, as first drafted — rejected because it inverts the mechanism its own evidence
  depends on". D14 settled that the plan announces the reversibility marking so the ask can precede the build.

## Gaps

- No ADR records the collaborative stop rule or the pre-build ask. The design rationale exists only in the pairing plan's
  decision log (above) and in the long-form doc's "Why it works this way" section.
- No automated test covers any prose in the area. Bats tests exist only beside shell scripts; a wording change here is
  verified by reading, and by `npm run lint` for formatting.
- `CONTRIBUTING.md` does not mention `collaborative-stop-rule.md` or the byte-identical vendoring requirement (C-11).
- No file in the area, and no file elsewhere, states what a reply to a stop is a reply to (C-5).

## Findings

### C-1: The rule requires the ask to precede the build, and says nothing about which turn carries it

- **Claim:** The canonical rule's only timing constraint on the pre-build ask is that it comes before the build; it does
  not require the ask to be its own turn or to follow the previous piece's stop. "Not at the stop afterward" refers to the
  marked piece's own stop.
- **Location:** `han-core/references/collaborative-stop-rule.md`, lines 71–75, section "Asking before building, and when"
- **Evidence:**

  ```markdown
  For a piece carrying a choice that is expensive to walk back, the ask comes **before** the build, not at the stop
  afterward. Committing to your own expectation before the answer exists is the mechanism; an ask arriving once the work
  is on disk collects the cost and none of the benefit.
  ```

- **Raised by:** structural-analyst S-1, behavioral-analyst B-1
- **Confidence:** Verified
- **Bears on:** S-1, S-2, D-1, D-2

### C-2: Pairing Step 5 echoes the ask as "ask first" and gets turn separation only from the loop's item order

- **Claim:** Step 5 places the ask at item 1 and "End the turn" at item 4. Followed mechanically, the ask for piece N fires
  after Step 6 has routed the reply to piece N−1's stop and returned "to the top of Step 5". That ordering is implied by
  the list, never stated as a rule, and nothing forbids appending the ask to the tail of the previous stop, which still
  precedes the build. Step 5 also says "a complete one" where the rule says "first-class answer".
- **Location:** `han-core/skills/pairing/SKILL.md`, lines 152–154 and 175–176; Step 6 line 188
- **Evidence:**

  ```markdown
  1. **If the plan marked this piece expensive to walk back, ask first.** Follow the ask protocol in the stop rule: name
     the dimension the choice turns on, offer no candidate answers, and accept a declined answer as a complete one. The ask
     comes before the build, never after.
  ```

  ```markdown
  4. **End the turn.** Nothing further is built until the person responds. **Starting the next concern is not an
     exception**, however directly it follows from the one that just closed.
  ```

  ```markdown
  - **What comes next.** Carry it into the next piece and return to the top of Step 5.
  ```

- **Raised by:** structural-analyst S-2, behavioral-analyst B-1
- **Confidence:** Verified
- **Bears on:** S-2, S-4, D-2, D-13

### C-3: "What a stop presents" does not scope a stop to one piece or forbid forward-looking content

- **Claim:** The four required elements of a stop, and the "Then end the turn" instruction, never say a stop presents
  exactly one piece or carries no question about a later one. The Position element is forward-looking by design ("what
  remains"), scoped to reporting, not asking.
- **Location:** `han-core/references/collaborative-stop-rule.md`, lines 51–65
- **Evidence:**

  ```markdown
  1. **Position.** Which piece this is against the plan, and what remains. A person deciding whether they have the
     attention for two more pieces cannot answer that without it.
  ...
  Then end the turn. Nothing further is built until the person responds.
  ```

- **Raised by:** structural-analyst S-3
- **Confidence:** Verified
- **Bears on:** S-1, D-1, D-2

### C-4: Step 5 already authorizes one kind of forward-looking content in a stop: naming the next concern

- **Claim:** The stop's position line is told to name the concern that comes next when a piece closes a concern. That is
  a report about the future, not a question about it, and any new rule against forward-looking questions has to leave it
  standing.
- **Location:** `han-core/skills/pairing/SKILL.md`, lines 172–173
- **Evidence:**

  ```markdown
  When the piece closes a concern, say so in the position line and name the concern that comes next. That tells the
  person the next response starts different work, which is the moment their review matters most.
  ```

- **Raised by:** structural-analyst S-4
- **Confidence:** Verified
- **Bears on:** S-1, S-4, D-2, D-16

### C-5: A reply is routed by what it touches, never by which question it answers, and the decline clause has no negative definition

- **Claim:** Step 6 and the rule's "Acting on the answer" classify a reply by its content into three routes. Neither says
  which piece a reply belongs to. "Declining is a first-class answer" defines what counts as a decline and never what does
  not, so a reply aimed at piece N−1's stop has no textual barrier to being read as declining a bundled piece-N ask. The
  one adjacent guard, "A question holds the person's place", governs the person's questions, not the run's.
- **Location:** `han-core/references/collaborative-stop-rule.md`, lines 96–97 and 112–125;
  `han-core/skills/pairing/SKILL.md`, lines 178–193
- **Evidence:**

  ```markdown
  **Declining is a first-class answer.** "I don't know" and "just show me" advance the piece exactly as a considered
  answer does. Never re-prompt, and never require an answer before building.
  ```

  ```markdown
  Three routes, by what the feedback touches.
  ```

  ```markdown
  **A question holds the person's place; it never advances the work.** Answer it and stop again at the same place.
  ```

- **Raised by:** structural-analyst S-5, behavioral-analyst B-2
- **Confidence:** Verified
- **Bears on:** S-2, S-6, D-3

### C-6: The record holds whatever the run writes, and nothing distinguishes an answered ask from a declined one from one never presented

- **Claim:** Both files say to write the response into the record before acting on it, and neither says the record holds
  the person's words rather than the run's label. A label like "ask declined" enters persisted state at that step. The
  only detection is passive (the person reads the record), and the provenance clause fires only after a later piece is
  built on the entry. The long-form doc says the record holds "which piece prompted it", a property the rule and SKILL.md
  never describe as a mechanism.
- **Location:** `han-core/references/collaborative-stop-rule.md`, lines 105–110; `han-core/skills/pairing/SKILL.md`,
  lines 180–181; `han-core/docs/skills/pairing.md`, line 85
- **Evidence:**

  ```markdown
  Write every piece of feedback into the running record before acting on it. A correction given at the second stop has to
  still apply at the seventh, and mid-context material is the least reliably recalled.

  The person can read the record whenever they ask. When a recorded entry shapes a later piece, name which entry it was,
  ```

  ```markdown
  The record holds each piece of feedback you gave and which piece prompted it.
  ```

- **Raised by:** behavioral-analyst B-3, structural-analyst S-6
- **Confidence:** Verified
- **Bears on:** S-3, S-5, S-6, D-5, D-15

### C-7: No existing error path covers a build made on a misread ask, and the re-show route forbids returning to the ask

- **Claim:** The overrun clause fires when a stop is skipped; in the issue's scenario no stop was skipped. The re-show
  route is the only defined correction for a built piece and says "Do not return to the pre-build ask; this piece is
  already built." The text names no handler for learning, later, that the ask was never engaged.
- **Location:** `han-core/references/collaborative-stop-rule.md`, lines 67–69; `han-core/skills/pairing/SKILL.md`,
  lines 185–187
- **Evidence:**

  ```markdown
  That last instruction is a directive, not a guarantee. Nothing in the platform enforces it. When a run does build past a
  stop, the next thing it says names the overrun, states which pieces went unreviewed, and offers to walk back through
  them. Never present unreviewed work as though it had been approved.
  ```

  ```markdown
  - **The piece in hand.** Fix it within that piece and show it again, naming the correction and what it touched. That
    re-show is a stop, so return to Step 5's fourth instruction and wait. Do not return to the pre-build ask; this piece is
    already built.
  ```

- **Raised by:** behavioral-analyst B-4
- **Confidence:** Verified
- **Bears on:** S-2, D-4, D-14

### C-8: The batching and finish-without-stopping paths never mention the ask

- **Claim:** "More than one piece at a time" and "finish without stopping" say nothing about a marked piece inside the
  batch or the remainder, so the text does not say whether the ask fires, is absorbed, or goes unreviewed.
- **Location:** `han-core/skills/pairing/SKILL.md`, lines 195–199; `han-core/references/collaborative-stop-rule.md`,
  lines 129–131
- **Evidence:**

  ```markdown
  **When the person asks for more than one piece at a time**, honor it as asked, present the pieces together, and return
  to the normal pace at the following stop without being asked to.

  **When the person says to finish without stopping**, acknowledge it in the same turn and name what will now go
  unreviewed, then continue from the current plan and report at the end.
  ```

- **Raised by:** behavioral-analyst B-5
- **Confidence:** Verified
- **Bears on:** Deferred (YAGNI), D-2

### C-9: The long-form doc promises "before it builds" and says declining advances "the stop"

- **Claim:** The doc's commitment to the person is narrower than the expectation the issue reports. It says the ask
  arrives before the build, not that it arrives as its own turn after the previous piece is approved. Its tips section says
  declining "advances the stop" where the rule says "advance the piece", blurring the ask and the stop.
- **Location:** `han-core/docs/skills/pairing.md`, lines 28–29, 99–100, 144–147
- **Evidence:**

  ```markdown
  - **The pre-build ask.** For a piece the plan marked expensive to walk back, the skill asks what you expect before it
    builds. Declining is a complete answer.
  ```

  ```markdown
  - **Answer the pre-build ask honestly, including with "I don't know."** Declining advances the stop exactly as a
    considered answer does. The ask exists to get an independent read, and a manufactured guess is worth less than none.
  ```

- **Raised by:** behavioral-analyst B-6, structural-analyst S-8
- **Confidence:** Verified
- **Bears on:** S-6, D-3, D-6

### C-10: The two constraints pairing repeats from the rule do not include ask timing

- **Claim:** SKILL.md's preamble repeats two constraints it calls "the ones most easily lost": the pacing and the stop's
  ordering. Ask timing is not among them and is paraphrased once, at Step 5 item 1.
- **Location:** `han-core/skills/pairing/SKILL.md`, lines 36–42
- **Evidence:**

  ```markdown
  Two constraints from that file govern every step below and are repeated here because they are the ones most easily lost:

  - **The pacing is the deliverable.** ...
  - **A stop hands over something to check, never a case for the work.** ...
  ```

- **Raised by:** structural-analyst S-7
- **Confidence:** Verified
- **Bears on:** Deferred (YAGNI)

### C-11: The three rule copies are byte-identical, and two places record the obligation to keep them so

- **Claim:** `md5` of all three copies is `29db7843077527d17ff7c515b8b062fc`. The rule's own line 20 and `CLAUDE.md`
  line 266 state the byte-identical requirement. `CONTRIBUTING.md` does not mention it.
- **Location:** `han-core/references/collaborative-stop-rule.md`, line 20; `CLAUDE.md`, lines 120, 127, 266–267
- **Evidence:**

  ```markdown
  Every vendored copy of this file is byte-identical to the canonical `han-core/references/collaborative-stop-rule.md`.
  ```

  ```markdown
  `iterative-plan-review`, and `plan-implementation`. Vendored byte-identical into `han-coding/references/` and
  `han-planning/references/`; edit the canonical copy and re-sync the others.
  ```

- **Raised by:** structural-analyst S-9, this run's sweep
- **Confidence:** Verified
- **Bears on:** Change Unit 1, D-9

### C-12: The backing skills' required reading excludes the ask section, and all five read only the stop's shape

- **Claim:** "Who reads this" makes "Detecting the flag" and "What a stop presents" the whole contract for a backing skill.
  All five backing skills' "Running collaboratively" paragraphs cite the rule only for the shape of the stop. A new rule
  placed under "Asking before building, and when" binds `pairing` alone unless "Who reads this" changes.
- **Location:** `han-core/references/collaborative-stop-rule.md`, lines 26–30; `han-coding/skills/tdd/SKILL.md`
  253–256; `han-coding/skills/refactor/SKILL.md` 136–139; `han-coding/skills/design-an-api/SKILL.md` 206–209;
  `han-planning/skills/iterative-plan-review/SKILL.md` 357–362; `han-planning/skills/plan-implementation/SKILL.md`
  359–364
- **Evidence:**

  ```markdown
  **A skill that gains the collaborative flag** reads "Detecting the flag" and "What a stop presents." Those two sections
  are the whole contract for a backing skill. Nothing else here is required reading to add the flag correctly.
  ```

  ```markdown
  **Running collaboratively.** When the request asks to review each behavior as it lands, which is what `pairing` does
  when it hands work here, stop at this point and hand control back instead of continuing. Present the stop in the shape
  [collaborative-stop-rule.md](../../references/collaborative-stop-rule.md) specifies.
  ```

- **Raised by:** structural-analyst S-10
- **Confidence:** Verified
- **Bears on:** S-1, D-1, D-10, Risks

### C-13: The rule file carries a Contents list that a new section must join

- **Claim:** The rule is 137 lines and opens with a `## Contents` list of its seven `##` headings, as the authoring
  guidance requires for a reference file over roughly 100 lines. `pairing/SKILL.md` is 207 lines, well under the 500-line
  body guideline, so an added paragraph needs no relocation into `references/`.
- **Location:** `han-core/references/collaborative-stop-rule.md`, lines 3–11;
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-reference-files.md`, line 116
- **Evidence:**

  ```markdown
  ## Contents

  - Who reads this
  - Detecting the flag
  - What a stop presents
  - Asking before building, and when
  - Recording what the person says
  - Acting on the answer
  - Pace
  ```

- **Raised by:** this run's sweep
- **Confidence:** Verified
- **Bears on:** D-1

## Findings No Agent Could Audit

Every evidence class was covered. The area is prose on disk, read in full by both analysts and by this run. The one
thing no one can inspect is the 2026-09-03 session transcript the issue describes; the issue's account of it is taken as
the recorded reason, not as a finding about the text.

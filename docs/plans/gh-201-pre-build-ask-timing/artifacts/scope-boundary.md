# Scope Boundary: Pre-build ask timing (issue #201)

## Work Item

GitHub issue #201 in `testdouble/han`, "Han Feedback: pairing-tdd-han-feedback (2026-09-03)", read through
`gh issue view 201 --repo testdouble/han` on 2026-09-11. It is a feedback report from a pairing session that drove a
four-behavior TDD rewrite. The issue is open, unlabeled, and has no comments.

## Stated Scope

The issue's "Suggested fix" paragraph, quoted word for word:

> Add an explicit rule to `collaborative-stop-rule.md` (and echo it in pairing Step 5): the pre-build ask for piece N is
> its own turn, presented only after the person has responded to the piece N−1 stop. A stop presents exactly one piece
> and asks nothing about future pieces. Corollary: a response to a stop is a response to that stop's piece only — it
> must never be read as answering, or declining, a question about a later piece. If a run has already bundled the ask
> and the reply addresses only the previous piece, the ask is unanswered: re-present it in its own turn before building.

The issue's "Overall" paragraph restates the fix as:

> The fix is a sequencing rule: one stop, one piece, no forward-looking questions; the ask for a marked piece opens that
> piece's turn, after the previous piece is approved, and a reply to a stop never answers a question about a later
> piece.

The issue also names a second effect of the defect, under "What didn't work":

> The misread compounded silently. The run recorded "ask declined" in the feedback record as if it were the person's
> decision, so the record itself carried the wrong fact until the person corrected it.

## Stated Exclusions

None stated.

## Operator-Stated Scope

The operator invoked `/han-planning:plan-a-change for https://github.com/testdouble/han/issues/201` and, at the
confirmation turn, accepted the area as proposed with "looks good". The proposed area was:

- `han-core/references/collaborative-stop-rule.md`, the canonical rule, plus its two byte-identical vendored copies in
  `han-coding/references/` and `han-planning/references/`
- `han-core/skills/pairing/SKILL.md`, Steps 5 and 6
- `han-core/docs/skills/pairing.md`, the long-form doc

The five backing skills (`tdd`, `refactor`, `design-an-api`, `iterative-plan-review`, `plan-implementation`) were
proposed as outside the area, on the ground that they read only the "Detecting the flag" and "What a stop presents"
sections of the rule and the ask belongs to the driving loop. The operator accepted that exclusion.

## Direction of Travel

Unanswered. The confirmation turn did not ask whether the pre-build ask or the collaborative stop rule is being
deprecated, replaced, or migrated away from. Nothing in the issue or the conversation suggests it is: the issue asks for
the ask protocol's timing to be tightened, not for the protocol to go.

## Visual Material Received

None received.

## Record Provenance

Established by `plan-a-change` in this run on 2026-09-11. Not inherited.

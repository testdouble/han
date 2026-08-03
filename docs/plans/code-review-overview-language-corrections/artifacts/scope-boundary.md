# Scope Boundary: code-review and code-overview reader-facing corrections

## Work Item

GitHub issue <https://github.com/testdouble/han/issues/170>, "Han Feedback: code-review-code-overview (2026-08-03)",
read with `gh issue view 170`. It is a `han-feedback` retrospective across roughly twenty `code-review` and
`code-overview` runs from 2026-07-06 through 2026-08-03. The issue body is quoted below rather than paraphrased.

## Stated Scope

The issue's "Suggested improvements" section, quoted word for word, is the stated scope. Eight items, ordered by how
many follow-up turns each removes:

1. "**Give each finding a second prose slot: what goes wrong, for whom, and whether it can happen.** Add to
   `template.md` a required plain-language line per WARN and SUGG (and per CRIT), written for a reader who will not open
   the file, carrying three things: the observable consequence, the preconditions that must all hold, and an honest
   likelihood — including \"this may be a no-op if X\". Publish Step 7.2's reachability reasoning here instead of
   discarding it. Invoke `han-communication:explanation-guidance` before drafting findings; the standard for this reader
   already exists and neither skill uses it. This alone removes the most-repeated request in the corpus."

2. "**Add a Present step to `code-review`, and resolve the output location in both skills.** For `code-review`: write the
   report, then close with the path, the recommendation, and the count by severity — and stop pasting the full review
   into the conversation, which `code-overview` already gets right. For both: resolve the destination through the config
   precedence chain so a configured `output-directory` is honored, and drop `code-overview` Step 6's \"outside the
   repository\" prescription, which overrides it. Name the file from the branch or ticket
   (`code-review-{branch-or-ticket}.md`, not `code-review-draft.md`) so consecutive runs stop colliding."

3. "**Let a pass own diagram legibility.** The prose exemption is correct for accuracy and wrong for reading load, and
   the result is the only formatting complaint that recurred. Add a diagram rule to `overview-template.md`: nodes name
   components and boundaries, not fields, types, or annotations; detail belongs in the prose beneath. Then have Step 7
   check node-label length and count against it. Diagram bodies stay exempt from the prose rewrite; legibility stops
   being nobody's job."

4. "**Extend the gloss rule to cover coined and external terms.** Any term a reader cannot resolve from the target's own
   code gets a half-sentence gloss at first use — external technologies and language runtimes, statistical or numerical
   methods, and compound nouns the document invents for its own convenience. Coined phrases matter most: the reader has
   nowhere to look them up. All four questions in the corpus were of these three kinds and all four passed the current
   rule."

5. "**End every overview with a plain-language restatement, and name the remediation route for every finding.** The
   overview should close with three or four sentences a non-author could read aloud, with no file paths or type names,
   because the user's next action is reliably to paste that somewhere — a PR description, a comment to a reviewer. And
   each `code-review` finding should name the route to fix it (`tdd` for a missing behavior, `refactor` for
   restructuring, manual for a one-line change), because the user asks anyway: \"would `/tdd` or `/refactor` be better
   for sugg-003?\" and \"would /refactor or /tdd be better suited for this?\""

6. "**Make \"Where to start\" an ordered path, and add an example call for API surfaces.** Number the entry points in
   reading order with one line on what the reader learns at each. When the target is an API surface — GraphQL, REST, a
   public interface — include one runnable example call. Both were asked for explicitly after an overview that already
   listed the right files."

7. "**Let PR mode report an unsupported why.** When the code shows the stated motivation is already satisfied, or shows
   the change is not needed for the reason given, say so in the why section as a fact about the why. Keep the quality
   boundary; this is not a finding about the code's quality, and it is the highest-value sentence such an overview could
   carry."

8. "**Apply main-point-first to the closing message in both skills.** Lead with the answer: the recommendation and
   severity counts for a review, the why and any divergence from the ticket for an overview. Mode, size, validator
   reconciliation, and self-check results go last or into the file. The report is held to progressive disclosure; the
   message the user reads first should be too."

The issue also carries a "What worked well" section naming behavior that must survive unchanged: the
`han-core:adversarial-validator` pass and its counter-evidence bar for dropping a finding, the stable `CRIT-/WARN-/SUGG-`
task-ID scheme the user works as a queue, `code-overview`'s refusal to paste itself into the conversation, and the
lazy-section rule that keeps clean reviews short.

## Stated Exclusions

`None stated`. The issue rules nothing out in words. Two boundaries are stated as constraints on how a change may be
made rather than as exclusions, and both are recorded here as scope conditions:

- On improvement 3: "Diagram bodies stay exempt from the prose rewrite."
- On improvement 7: "Keep the quality boundary; this is not a finding about the code's quality."

## Operator-Stated Scope

Quoted from the invocation and the follow-up turn:

- "https://github.com/testdouble/han/issues/170 commit and push as you go"
- "open draft mode pr against han-v5.0.0-alpha-1 as the merge target"

Both statements govern how the work is delivered rather than what it covers. The operator named no scope narrowing or
widening beyond the issue.

## Direction of Travel

Asked in the opening confirmation turn: whether `code-review`, `code-overview`, their template files, or the
Mermaid-body exemption in the readability rewrite are being deprecated, replaced, or migrated away from. The operator
answered: "all four stay. we're correcting the output so it's understandable and usable."

Nothing in scope is on its way out. The work is corrective on the output of two skills that keep their current shape.

## Visual Material Received

`None received`.

| Item | What state it depicts | Kept at |
| ---- | --------------------- | ------- |
| —    | —                     | —       |

## Record Provenance

Established by `han-planning:plan-a-feature` on 2026-08-03. Not inherited from another folder. No conflicting record was
found at this path.

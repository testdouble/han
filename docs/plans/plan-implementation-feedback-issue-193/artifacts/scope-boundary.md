# Scope Boundary: plan-implementation feedback (issue #193)

## Work Item

GitHub issue [testdouble/han#193](https://github.com/testdouble/han/issues/193), "Han Feedback:
plan-implementation (2026-08-23)". Read in full via `gh issue view 193`. The issue has no comments.

## Stated Scope

The issue's `## What didn't work` section, quoted word for word:

1. "**The three specialists cannot measure, and several of the questions put to them were empirical.** The dispatched
   agents hold read-only tools with no network access. Questions about output size, upstream data shape, and data
   fragmentation could only be answered by reasoning from figures the specification asserted, which means a finding
   inherits any error in the specification rather than testing it. The orchestrating thread does have execution tools,
   and answering the three decisive questions directly took under two minutes and changed several plan decisions.
   Suggestion: add a measurement step before briefs are written, so specialists are handed measured numbers rather than
   asked to estimate quantities they cannot obtain."

2. "**A decision log's rejected alternatives are quotable as if they were the decision.** This is the root of the wrong
   recommendation above. The template puts the chosen option and the rejected ones in one entry, each carrying its own
   evidence, and a specialist quoted the rejected half. Both the correct and the incorrect finding cited the same
   decision identifier, so a citation check cannot separate them. Two suggestions: state in the brief that figures
   quoted from a `Rejected alternatives` block must be attributed to the rejected option; and treat two specialists
   disputing a point while citing the _same_ identifier as a signal that one has misread it, since a genuine
   disagreement usually cites different evidence."

3. "**The deferred list is written during planning and consulted in no later phase.** See the flag above. A single line
   in the Definition of Done asserting that nothing in the deferred section was built would have caught it without a
   re-read."

4. "**`han-core:plan-synthesizer` hit a session limit mid-run** and terminated after writing the decision log but before
   the plan. The decision log it had produced was complete and high quality, so the work was recoverable, but there is
   no resume path and the primary artifact had to be written by hand. A synthesis step that writes three
   cross-referenced files might be more robust if it wrote the primary plan first, since that is the artifact the other
   two point into."

5. "**`han-communication:readability-editor` added an explanatory gloss for a coined term.** The wording was drawn from
   a later section of the same document and was reasonable, but it was an addition to a draft that had already been
   fact-checked, not a rephrasing. Its own fact-preservation ledger also claimed to have preserved a figure that was
   never in the file. Both are small; the pattern worth naming is that a rewrite pass authorised to reshape prose can
   introduce content, and its self-report is not an independent check on that."

6. "**The `Referenced in plan:` fields were written before the plan existed.** The synthesizer wrote decision entries
   naming plan sections, including one naming a section (`Cut for Scope`) that a later user decision removed. Nothing
   detected the dangling reference; it was caught by a link check run by hand."

The issue's `## What worked well` section is a constraint rather than a request. It names six mechanics that were
working in the reported run, and a change that breaks one of them fails the boundary even if it satisfies a numbered
finding above. Those mechanics, in the issue's own headline words:

- "The deterministic aggregation caught a wrong specialist recommendation that voting would have accepted."
- "The blind-spot directive earned its place." (the per-finding `Unverified:` line)
- "Domain-scoped briefs kept three reports genuinely different."
- "Every YAGNI deferral survived implementation except one, and the plan is why."
- "`han-core:junior-developer` found the highest-value structural finding in the round."
- "The scope gate cutting an item, and then surfacing the cut in the summary, worked exactly as designed."

## Stated Exclusions

`None stated.` The issue rules nothing out in words.

## Operator-Stated Scope

The operator invoked `/han-planning:plan-a-change for https://github.com/testdouble/han/issues/193` with no further
scope statement, then answered the confirmation turn's three asks:

- Asked whether the area named is the whole area the change may touch: "that is the whole area".
- Asked whether the boundary includes the sibling planning skills carrying the same mechanics, so findings 2, 3, and 6
  apply to `plan-a-change` and `plan-a-feature` verbatim: "yes".
- Asked to confirm the plan folder name `docs/plans/plan-implementation-feedback-issue-193`: "yes that's fine".

The area the operator confirmed as whole:

| Finding | Files |
| ------- | ----- |
| 1, 2 | `han-planning/skills/plan-implementation/SKILL.md`, `han-planning/skills/plan-implementation/references/round-aggregation.md` |
| 2, 6 | `han-planning/skills/plan-implementation/references/implementation-decision-log-template.md` |
| 3 | `han-planning/skills/plan-implementation/references/feature-implementation-plan-template.md` |
| 4, 6 | `han-planning/skills/plan-implementation/references/synthesis-directives.md`, `han-core/agents/plan-synthesizer.md` |
| 5 | `han-communication/agents/readability-editor.md` |

Plus, by the operator's answer to the second ask, the sibling planning skills carrying the same decision-log,
deferred-section, and cross-reference mechanics: `han-planning/skills/plan-a-change/` and
`han-planning/skills/plan-a-feature/`.

**Boundary widened once during the run.** At Step 5 the run established that a fourth skill,
`han-planning/skills/plan-a-phased-build/SKILL.md:383-395`, carries the same readability-editor consumption block as
the three already in scope, and that these four are the only carriers among the twenty-one skills that dispatch the
editor. That skill was in none of the files the operator confirmed at the opening turn. Asked whether the fix should
reach it, the operator answered: include it. `han-planning/skills/plan-a-phased-build/` is therefore in scope for
finding 5 only, and for nothing else.

## Direction of Travel

`Unanswered.` The operator was not asked whether any of the named skills, agents, or templates are being deprecated,
replaced, or migrated away from, and did not volunteer it. Nothing in the issue or the repository suggests any of them
is on the way out; `plan-a-change` shipped in the most recent commit on `main`.

## Visual Material Received

`None received.`

## Record Provenance

Established by `han-planning:plan-a-change` in this run. Not inherited from any earlier record; no
`artifacts/scope-boundary.md` existed for issue #193 before this run, and the issue names no source plan folder.

One prior-work note, recorded because it narrows finding 5 rather than resolving it. Commit `6327462`
("fix(han-communication): check the readability editor's own insertions") added a step 4 to
`han-communication/agents/readability-editor.md` that re-reads the editor's own new sentences against the vocabulary
blocklist and the em-dash positions. That addresses a voice violation the editor introduces. It does not address either
half of what finding 5 reports: content the editor invents, and a fact-preservation ledger asserting a fact the source
never carried. Finding 5 stands, narrowed to those two.

No conflict between an incoming work item and this record arose.

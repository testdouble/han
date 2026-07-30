# Scope Boundary: han-planning Cost Reduction

## Work Item

No ticket or issue exists for this work. The boundary is two things the operator supplied: the research report at
`docs/research/han-planning-cost-reduction.md`, which this run was pointed at by path, and the operator's own invocation
text. The report was produced earlier in this same session by `han-research:research`, so its Recommendation section is
the closest thing to a stated scope this run has. Recorded from the report's own text, read from disk, not from a tracker.

## Stated Scope

Quoted word for word from the report's Recommendation section:

> Adopt **O1** (cut the top-band rosters and sequential round caps) as the primary change, then **O2** (script the
> mechanical gates) and **O3** (delete the redundant self-check). Treat **O4** as a scoped follow-up that begins with an
> audit rather than an edit. Treat O5, O6, and O7 as low-payoff or unsupported, and adopt **O8** by leaving the
> escalation cadence alone. This is not a single-winner landscape; the changes compose.

The three options the report adopts, quoted from their own entries:

> **O1:** Reduce the specialist count and the sequential round cap at the larger bands, starting with
> `plan-implementation` (six to eight agents across up to three rounds) and `iterative-plan-review` team mode. Keep the
> parallel first wave, which is the part that buys wall-clock time, and shrink the sequential rounds, which are the part
> that buys least.

> **O2:** Replace the narrated deterministic checks with scripts the skill runs: the completeness gate's file-existence
> check, Pass B's "Unverified:" strip, and the cross-reference verification in `iterative-plan-review` Step 6.

> **O3:** Drop the six-criterion self-check from `plan-a-feature`, `plan-implementation`, and `plan-a-phased-build`, which
> each dispatch `readability-editor` and then run the check on the text the editor produced. Keep the check in
> `plan-work-items`, which runs no editor.

## Stated Exclusions

Quoted word for word from the report:

> Two things not to change. Asking the user one question per turn has no evidence against it, and cheaper model routing is
> already in place: every dispatched agent already declares which model tier it runs on, and the mechanical ones already
> run on the cheapest.

> **O8:** Make no change to the escalation cadence.

The report also rules three further options out of the adopted set, in the Recommendation quoted above: O5 (collapse the
duplicated prose), O6 (compress the prose in place), and O7 (downtier the judgment agents). O7 is recorded as resting on
no evidence for the specific agents involved. O5 and O6 are recorded as low-payoff rather than as harmful.

O4 (split the oversized instruction files) is excluded from this run's editing scope by the report's own wording, which
scopes it to "a scoped follow-up that begins with an audit rather than an edit."

## Operator-Stated Scope

Quoted from the invocation:

> for docs/research/han-planning-cost-reduction.md - commit and push on current branch as you go. open draft mode PR
> against han-v5.0.0-alpha-1 as merge target.

The operator named the report as the source and set two delivery conditions: commit and push to the current branch
(`han-planning-cost-reduction`) as the run proceeds, and open the pull request in draft with `han-v5.0.0-alpha-1` as the
merge target. No scope was added or removed beyond the report's own recommendation.

## Direction of Travel

Answered. Asked whether the review teams, the hand-run checks, or the readability self-check in the planning skills are
being deprecated, replaced, or migrated away from in the v5 line. The operator answered:

> no, they stay as-is in v5

All three surfaces this run changes are staying in the v5 line, so the run specifies against the current structure and
carries no deprecation risk on any of them.

## Visual Material Received

`None received`.

| Item | What state it depicts | Kept at |
| ---- | --------------------- | ------- |
| —    | —                     | —       |

## Record Provenance

Established by `han-planning:plan-a-feature` in this run. Not inherited from another folder.

**The source option was adopted in part.** The Stated Scope above quotes `O1` as reducing both the specialist count and
the sequential round cap. The operator chose, from four named candidates, to reduce the count and leave the repeat
ceiling alone. The declined half is recorded in the specification's Out of Scope section rather than in the cut list,
because the boundary asks for it and the operator declined it on evidence; a cut-list entry would misreport it as
something the boundary excluded.

**One skill inside the reduction's subject area was cut.** `plan-a-feature` convenes a review team of the same size as
`iterative-plan-review`, and the Stated Scope names only the other two skills. The scope gate cut it rather than
escalating, and the cut is recorded in the specification's Cut for Scope section where the operator can reinstate it.

**A second check inside the conversion's subject area was cut.** The Stated Scope names the cross-reference check by
skill and step, quoting the source option as "the cross-reference verification in `iterative-plan-review` Step 6."
`plan-a-feature` and `plan-implementation` each carry an equivalent check over their own companion files. The scope gate
cut those two rather than escalating, and the cut is recorded in the specification's Cut for Scope section where the
operator can reinstate either. Found during synthesis, after the review round closed.

Adjacent work noted, not treated as scope: `docs/plans/reduce-context-footprint/investigation.md` (issue #51) targets the
always-loaded `description:` frontmatter of agents and skills, which is a different surface from the SKILL.md bodies,
dispatch rosters, gates, and self-checks this run addresses. No conflict, and no overlap to resolve, but the two should
not be merged into one scope.

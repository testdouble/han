# Evidence: PR #299 (gearjot-v2-web, gear map foundation)

Source bundle: `tmp/gearjot-v2-web-pr-299/` (May 7, 2026).

Two `han:code-review` passes ran on this PR. The second pass opened with the explicit statement that "7 of the prior 11 warnings were downgraded to suggestions on a second pass". The existence of the second pass is itself the single strongest piece of evidence in this investigation: the skill's first-pass output was so over-classified that the user had to re-run it with a reclassification mode.

Each finding below is keyed E1...E23 and cited verbatim where possible. Findings are grouped by which of the four symptoms they demonstrate.

---

## Symptom 1: Goes too deep / off the rails

### E1: Structural agent flagged code outside the change surface
Source: `tmp/gearjot-v2-web-pr-299/artifacts/github/pr-299-review-2.md:155`
> Structural agent surfaced what is now SUGG-005/SUGG-006/SUGG-007: duplication, mock-type drift, SDK-type leak: none of which block merge.

The three findings were filed as warnings on the first pass against code outside the touched diff. Reclassification was needed only because they did not concern code introduced by this change.

### E2: SUGG-005 cited a defect case that the team had already deferred
Source: `pr-299-review-2.md:117`
> SUGG-005: Three duplicated announcement stores (`announcement-store.svelte.ts` plus 2 siblings). Real duplication; the cited defect-propagation case is the deferred `_interruptingMessage` issue, itself accepted as intentional. Refactoring opportunity.

The skill examined two sibling stores not touched by the branch, and the only defect path it could attach to the duplication had already been documented as intentionally deferred.

### E3: SUGG-007 flagged an architectural concern with acknowledged zero current impact
Source: `pr-299-review-2.md:119`
> SUGG-007: `google.maps.Map` as popover prop (`GearMarkerPopover.svelte:13-14, 71`). Architectural concern with no current user impact. Refactor candidate.

Filed as warning on the first pass even though the review itself, on reclassification, acknowledged "no current user impact".

### E4: SUGG-001 was filed against a theoretical race
Source: `pr-299-review-2.md:113`
> SUGG-001: `loadSDK` silent skip when `mapEl` unbound. In Svelte 5, `bind:this` resolves before `onMount`; the navigate-away-back hazard writes to instance-scoped `$state` (harmless). The race window is theoretical.

The first pass treated framework-internal sequencing on minimally-changed code as a warning. Reclassification labeled the race window "theoretical".

### E5: Hidden depth in suppressed suggestions
Source: `pr-299-review-1.md:124`
> Suppressed per reviewer instruction. (Junior-developer raised toast omission, `DEMO_MAP_ID` comment, `sed`-key escaping; behavioral raised silent `mapEl` skip: all dropped.)

The first pass generated at least four extra findings that were suppressed only because the user explicitly passed a SUGG-suppress flag. Without that flag, three of them would have appeared as warnings about code clearly outside the change surface. The default mode produces deeper findings than the user wants.

### E6: SUGG-003 was filed even though its originating agent flagged it as unreachable
Source: `pr-299-review-2.md:115`
> SUGG-003: `await goto()` inside `catch` racing rapid retry. The concurrency agent itself noted this is "effectively impossible in production" because `goto` removes the page from the DOM before re-click is feasible. Structural deviation from the `finally` standard, not a reachable bug.

The agent that produced the finding documented that it knew the failure was unreachable. The classification step did not honor that signal and the finding still came through as a warning.

### E7: Feature overview directly names off-scope review comments
Source: `feature-overview-plain-language.md:114`
> It is not slice 2, 3, 4, 5, or 6. Several review comments were "you should add filtering / a list pane / a current-location button" and the team consistently said: that's a different slice.

The author of the overview explicitly recorded that the review surfaced features belonging to future slices. The scope context "this is slice 1, not slices 2 to 6" did not constrain the review.

---

## Symptom 2: YAGNI under-applies

### E8: One YAGNI finding in the first pass despite many candidates
Source: `process-conversation-log.md:51`
> 2026-05-07 20:41Z | First `han:code-review` posted | 6 warnings + 1 YAGNI; all but WARN-002 resolved in working tree.

The first pass produced exactly one YAGNI finding. SUGG-001 through SUGG-007 (later reclassified) are all candidates by the YAGNI rule's criteria but were issued as warnings, not as YAGNI items.

### E9: YAGNI was applied to obvious dead code but not to speculative or refactor-only findings
Source: `pr-299-review-1.md:130-144`
> YAGNI-001: `maybeAnnouncePhase2` / `phase2Announced` is dead-or-misordered code.
> Trigger that would justify keeping it: A documented UX requirement that the cat-4 "Loading gear locations" announcement is distinct from the skeleton's `aria-busy`/`aria-label` and must fire even after data resolves first.

The skill correctly applied YAGNI to dead code and named a reopen trigger. The same rigor was not applied to SUGG-005 (three stores, no documented evidence for three), SUGG-007 (architectural choice with no documented requirement), or SUGG-006 (mock-type drift with no failing behavior). All three meet the YAGNI evidence test for deferral. None were YAGNI-classified.

### E10: Process log explicitly names the first-pass gap
Source: `process-conversation-log.md:244`
> 5. Reachability gate in adversarial review. The second-pass reclassification was the right call: explicitly demoting "theoretical races" and "defensive refinements" to suggestions. Bake this into the first pass instead of needing a second pass to catch it.

The user's own post-mortem identifies the absence of a first-pass reachability gate as a root cause.

---

## Symptom 3: Severity inflation

### E11: The second review exists because the first pass over-classified
Source: `pr-299-review-2.md:3`
> Supersedes the previous review comment. Re-run with reclassification: 7 of the prior 11 warnings were downgraded to suggestions on a second pass: they were defensive refinements or refactoring opportunities, not reachable defects.

7 of 11 warnings were inflated. 64 percent of warnings on the first pass were not warnings at all.

### E12: Process log confirms a wider initial sweep produced unrationalized warnings
Source: `process-conversation-log.md:170-171`
> Mode: Re-run with reclassification: 7 of the prior 11 warnings (from a wider initial sweep, presumably) were downgraded to suggestions on a second pass; they were "defensive refinements or refactoring opportunities, not reachable defects."

"From a wider initial sweep, presumably" admits the user could not reconstruct exactly how the first pass produced 11 warnings. The classification path was opaque.

### E13: SUGG-003 was a first-pass warning even though the agent labeled it unreachable
See E6.

### E14: SUGG-004 was first-pass warning despite hypothetical threat
Source: `pr-299-review-2.md:116`
> SUGG-004: `sed` redact with unescaped API key. Google-issued keys never contain sed metacharacters; the operator-passes-bad-key path is hypothetical. Defense-in-depth.

A finding whose threat model is "hypothetical" and whose category is "defense-in-depth" should not have been a warning.

### E15: Process log calls out reachability gate as the missing first-pass step
Source: `process-conversation-log.md:183`
> Lesson for `han` improvement: A second pass that demotes warnings is as important as the first pass that creates them. The reclassification rationale was specific and traceable in every case. Without it, the user would either (a) waste time fixing things that aren't real bugs, or (b) lose trust in the agent's signal-to-noise ratio. Good adversarial review must include a "is this actually reachable in production?" gate.

### E16: Process log #5 explicitly asks for first-pass reachability gate
Source: `process-conversation-log.md:244`
See E10.

### E17: Default mode produces severity inflation; users compensate via mode flags
Source: `pr-299-review-1.md:3`
> Size: Medium (8 files, +1009/-107). Mode: WARN-justified, SUGG suppressed per reviewer instruction.

The user passed an explicit "SUGG suppress" instruction. Without it, SUGG-001 through SUGG-007 would have been warnings. The default behavior is to inflate.

---

## Symptom 4: Context not forwarded to sub-agents

### E18: Mode flag is the only user context the review references
Source: `process-conversation-log.md:150-151`
> Mode: WARN-justified, SUGG suppressed per reviewer instruction.

There is no record of scope context, focus areas, PR description, or feature overview being passed to the sub-agents.

### E19: Feature overview records reviewers ignored available scope context
Source: `feature-overview-plain-language.md:112-115`
> ## What this PR is not trying to be
> - It is not slice 2, 3, 4, 5, or 6. Several review comments were "you should add filtering / a list pane / a current-location button" and the team consistently said: that's a different slice.

The PR description and feature overview both clearly scoped the work. The agents flagged out-of-scope features anyway.

### E20: PR description documented deferred items the agents still flagged
Source: `pr-299-description.md:28`
> T31 / G2.7: Sentry PII stripping for `/v1/gear/locations` and `/gear/map` deferred 2026-05-07 to a follow-up.

The PR description has a Deferred section listing Sentry PII work as out of scope. The security section of the review re-raised it.

### E21: Both review passes independently re-discovered the deferred Sentry gap
Source: `pr-299-review-1.md:163-165` and `pr-299-review-2.md:142-143`
> The deferred Sentry PII stripping for `/v1/gear/locations` (T31/G2.7) remains the only known PII gap. Explicitly tracked outside this PR; gates first deploy per Operational Readiness gate item 6.

Both passes re-surfaced the deferral. Neither could read the PR's own Deferred section and skip the finding. The deferral context did not reach the security sub-agent.

### E22: Test-gap chaining requires context the agents don't have
Source: `process-conversation-log.md:242-243`
> 4. Test-gap chaining in code review. When a code-review fix adds new code, automatically check whether the new code is covered by tests. Three of four second-pass warnings here were exactly this pattern.

Three of four second-pass warnings rediscovered test gaps for code added as a fix to first-pass findings. The new agents had no record that the new code was a fix; the test-coverage analysis ran from scratch.

### E23: Triple-corroboration language confirms agents do not share intermediate findings
Source: `process-conversation-log.md:247`
> 8. Triple-corroboration framing in review output. Keep the practice of explicitly naming "agents X, Y, Z independently converged on this finding." It's signal the user can act on.

Agents converge independently. They cannot consult each other's outputs nor a prior review's outputs.

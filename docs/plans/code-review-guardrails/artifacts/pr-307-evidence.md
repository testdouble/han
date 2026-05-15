# Evidence: PR #307 (gearjot-v2-web, sidebar shell + viewport flag)

Source bundle: `tmp/gearjot-v2-web-pr-307/` (May 8, 2026).

PR #307 raised 4 WARN findings and 1 YAGNI. The user adjudicated 3 of 4 WARN findings as "Won't fix" with multi-paragraph evidence pointing at code the review never examined: a separate repository, a database CHECK constraint, an entire navigation model. The 3:1 ratio of won't-fix to accepted WARN findings is direct evidence that the review's classification logic over-fires.

Findings are grouped by symptom and keyed E1...E22.

---

## Symptom 1: Goes too deep / off the rails

### E1: WARN-002 raised a failure mode the architecture makes unrepresentable
Source: `pr-307-review.md:13-15`
> If the API ever returns a gear record with a missing or invalid latitude/longitude, the map quietly fails to center instead of skipping the bad record and showing the rest. The user sees a default "zoomed-out US" view with no explanation. This violates our internal "errors must never be silently swallowed" rule.

The constraints that make this finding moot (database CHECK, non-nullable Go DTO, JSON serializer behavior) live in a separate repository (`gearjot-v2/`) that the review never examined.

### E2: WARN-003 applied a standard whose premise does not hold in this app
Source: `pr-307-review.md:17-19`
> The "user already moved the map" flag lives at the module level and isn't cleared when a user switches companies. So if a user pans the map at Company A and then switches to Company B, the map for Company B may refuse to auto-center on Company B's fleet. We have a written standard requiring this kind of state to be cleared on company switch, and it isn't being followed here.

The standard cited (`svelte-store-company-switch-clear.md`) targets SPA-style company switching with module-level Map/Set caches. The user's resolution comment cites four code locations proving every company-switch path in this app is a full-document redirect, which tears down all module-level state, including this flag.

### E3: Process log names the pattern
Source: `process-conversation-log.md:184-189`
> WARN-002 and WARN-003 are textbook applications of "errors must never be silently swallowed" and "module-level state must clear on company switch." Both rules are real and appropriate elsewhere in the codebase. Both fail to apply here, and the resolution comments prove it with evidence the review either didn't gather or didn't weigh:
> - WARN-002 didn't check whether the upstream API can produce the failure mode at all.
> - WARN-003 didn't check whether company-switch in this app is even an SPA navigation.
>
> The review was defensible against a generic frontend but not against this specific frontend.

### E4: User adjudication of WARN-003 cites four files the review never touched
Source: `pr-307-resolutions.md:22-27`
> Every switch entry point uses full-document navigation, not SvelteKit `goto`: `src/routes/+layout.svelte:150` (`window.location.href`), `src/routes/select-org/+page.svelte:9`, `src/routes/+layout.server.ts:49` (302 redirect), and `src/routes/api/switch-org/+server.ts` (post-WorkOS redirect). A full-document redirect tears down the JS bundle, wiping all module-level state including `userViewportFlag`.

None of these four files were changed by PR #307. The finding rests on assumptions about navigation behavior that the review never verified by reading these files.

### E5: User adjudication of WARN-002 cites cross-repo files the review never examined
Source: `pr-307-resolutions.md:12-17`
> - Database CHECK constraint `gear_locations_coords_valid` (see `gearjot-v2/db/client.go:154` and the migration in `ensureGearLocationsCoordsCheck`) rejects any row where `lat` is outside [-90, 90], `lng` is outside [-180, 180], or both are exactly 0. Bad coordinates can't be stored.
> - API contract is non-nullable: `GearLocationItem.Lat` / `.Lng` are `float64` (not pointers) in `gearjot-v2/gear/dto.go:155-156`...

`gearjot-v2/db/client.go` and `gearjot-v2/gear/dto.go` live in a different repository.

### E6: Process log names cross-repo blindness
Source: `process-conversation-log.md:209-210`
> Cross-repo evidence for "silent failure" findings. WARN-002 hinged on whether the backend can produce the bad state. The review didn't look at `gearjot-v2/`. The resolution comment cited a CHECK constraint, a Go DTO, and Go's JSON serializer: three pieces of cross-repo evidence the review should have weighed before posting.

### E7: The won't-fix pattern is consistent across three of four findings
Source: `process-conversation-log.md:133-135`
> Pattern that emerges: the review fires generic "this looks like the standard you should follow" warnings, and the user pushes back with load-bearing architectural evidence the review didn't have access to. All four pushbacks cite specific files, line numbers, or system-level facts: not opinion.

---

## Symptom 2: YAGNI under-applies

### E8: YAGNI-001 was correct in principle but the review then accepted the developer's rationale in the same comment
Source: `pr-307-review.md:25-33`
> Finding: The sidebar shell itself needs to stay: the auto-centering math depends on that space being reserved on screen. But the placeholder copy inside it ("More map tools coming soon.") is user-visible work-in-progress messaging that takes up 40% of the screen on mobile and adds zero value today.
>
> Decision: not accepted: the placeholder stays.
>
> Rationale: The app needs to be demoable end-to-end while the centering controls are still being built.

The YAGNI rule's "zero value today" test does not account for demoware. The review identified a candidate, then dismissed it in the same comment by accepting a rationale the YAGNI test should have solicited from a project-manager-style agent before firing.

### E9: Process log names the missing demo-posture question
Source: `process-conversation-log.md:212-213`
> YAGNI findings should ask the demo-posture question first. "This text adds zero value today" is true for product code; for in-progress demoware it's wrong. Either a `han:user-experience-designer` or a `han:project-manager` agent should weigh in on whether the surface is internal/demo before YAGNI fires.

### E10: PR description pre-acknowledged the placeholder rationale 21 seconds before YAGNI fired
Source: `pr-307-description.md:39` and `process-conversation-log.md:84-86`
> Adds the Gear Map sidebar shell (placeholder copy is intentional: see commit `9e97505`)

PR description named the intent. The review fired YAGNI-001 anyway.

### E11: WARN-002 and WARN-003 are themselves YAGNI-shaped findings classified as warnings
Source: `pr-307-resolutions.md:28-29`
> Adding `clearForCompanySwitch()` would be defensive code for a code path that does not exist: same reasoning applied to WARN-002.

Both findings ask the team to add defensive code at a trusted internal boundary for a failure mode that cannot occur. This is the YAGNI rule's named anti-pattern "Defensive guard at a trusted internal boundary the caller fully controls". They were filed as WARN instead.

---

## Symptom 3: Severity inflation

### E12: WARN-002 rated WARN when the failure mode is architecturally unrepresentable
Source: `pr-307-review.md:13`
> WARN-002: Bad coordinates from the server cause a silently broken map

### E13: WARN-003 rated WARN when the navigation model assumed does not exist in this app
Source: `pr-307-review.md:17`
> WARN-003: Switching companies can leak the previous company's map state

### E14: WARN-004 is rated WARN solely because it depends on WARN-003
Source: `pr-307-review.md:21-23`
> WARN-004: A test is missing that would catch a regression in the cleanup above
> The test for page cleanup verifies most things get cleared on unmount, but doesn't verify the user-viewport flag itself gets cleared.

WARN-004 is a derivative finding. The user's adjudication: "Moot, given WARN-003 won't-fix; there is no cleanup line to guard against regression."

### E15: Confidence labels are missing
Source: `process-conversation-log.md:211`
> Confidence labels on findings. Each WARN should carry a confidence indicator: did the reviewer find evidence the failure can occur, or did they pattern-match a smell? The current output reads as equally confident across all four, when in fact WARN-001 was real and reproducible (it got fixed) and WARN-002/003 were generic-frontend pattern matches that didn't apply.

### E16: 3 of 4 WARNs were won't-fixed
Source: `process-conversation-log.md:128-134`
> | WARN-001 | Done |
> | WARN-002 | Won't fix |
> | WARN-003 | Won't fix |
> | WARN-004 | Won't fix |

A 3:1 won't-fix ratio on WARN findings is direct quantitative evidence of severity inflation.

---

## Symptom 4: Context not forwarded to sub-agents

### E17: PR description pre-acknowledged context, review fired YAGNI anyway
See E10.

### E18: Implementation plan in issue #304 explicitly resolved WARN-003 before code was written
Source: `tmp/gearjot-v2-web-pr-307/artifacts/github/issue-304.md`, "Reusable patterns" section
> Module-level `$state` store with `_resetForTest()`: established by `src/routes/gear/map/announcement-store.svelte.ts:1` and the `clearForCompanySwitch()` standard. The viewport flag does not need `clearForCompanySwitch()` because a company switch hard-navigates; it just needs `_resetForTest()`.

The argument the user later wrote into the resolution comment was already in the implementation plan. The review's sub-agent had no record of the plan.

### E19: Process log names premise-checking as the missing step
Source: `process-conversation-log.md:208-210`
> Before raising a "violates standard X" warning, prove the standard's premise applies. The standard `svelte-store-company-switch-clear.md` exists for SPA-style company switches with module-level Map/Set caches. The reviewer needs to verify the app has SPA-style switches and that the offending state is a session-scoped cache. WARN-003 raised the standard without checking either premise.

### E20: Process log names the multi-repo CLAUDE.md as missing context
Source: `process-conversation-log.md:223-224`
> Skill prompts should know this is a multi-repo project. WARN-002's premise required reading `gearjot-v2/`. The reviewer either didn't have access or didn't reach across. The CLAUDE.md cross-repo rules document is exactly the kind of input the reviewer needed; whether it was loaded is unknown from the PR alone.

### E21: Review fired 21 seconds after PR open
Source: `process-conversation-log.md:84-86`
> The first review comment was posted at 19:42:56Z: 21 seconds later: which strongly suggests the review was queued to fire immediately on PR open.

21 seconds is consistent with the agents starting before the PR description's context (including the explicit "placeholder copy is intentional" note) could reach them.

### E22: Plan's "Decisions this plan locks in" section was the context the review needed
Source: `tmp/gearjot-v2-web-pr-307/artifacts/github/issue-304.md`, "Decisions this plan locks in" section
> Plan-D3: Sidebar component is empty in this slice. Just a simple "coming soon" text placeholder.

This and the surrounding plan content was the context that would have prevented WARN-002, WARN-003, and YAGNI-001 from firing. It existed at PR-open time and was linked from the PR. It did not reach the review sub-agents.

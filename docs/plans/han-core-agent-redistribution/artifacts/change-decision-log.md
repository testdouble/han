# Change Decision Log: han-core Agent Redistribution

<!--
This file records every decision committed while planning the han-core agent redistribution.
The plan itself lives in [../change-plan.md](../change-plan.md). Evidence about the code as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.
-->

## Trivial decisions

## Full decisions

### D-1: The user-experience-designer moves to han-planning

- **Question:** Where does `user-experience-designer` live, given that one `han-coding` review type requires it and
  five planning and research skills use it optionally?
- **Decision:** `han-core:user-experience-designer` becomes `han-planning:user-experience-designer` and claims the
  `ux-review` role. `han-coding`'s code-review fills that role in its default-run dispatch table and in the `ux` review
  type. When no installed agent fills it, the default run marks usability `not swept` through the existing
  manual-only coverage disclosure, and `/code-review ux` states that the type has no reviewer installed rather than
  reporting a clean pass. The placement rule gains an exception: a reviewer lives where most of the skills that use it
  live, provided every other consumer can name what is missing when it is absent.
- **Rationale:** UX review is mostly pre-build work on specs and plans. Five consumers (plan-a-feature,
  plan-a-change, plan-implementation, iterative-plan-review, gap-analysis) against one (code-review, through two entry
  points) means a partial install loses fewer skills' coverage this way. Code-review already discloses an absent
  reviewer as `not swept`, so its degraded path exists.
- **Evidence:** C-13 (code-review `ux` type: Always `user-experience-designer`); C-14 (manual-only substitution list,
  `han-coding/skills/code-review/references/agent-dispatch.md:334`: "nothing substitutes. No checklist category covers
  usability or accessibility"); C-19 and C-20 (dispatch map); user input.
- **Behavior impact:** Changing. With `han-coding` installed but not `han-planning`, `/code-review` on a UI change
  reports usability as `not swept`, and `/code-review ux` reports that no reviewer is installed. With `han-planning`
  installed but not `han-coding`, planning skills keep UX review. User's answer, verbatim: "move it to han-planning".
- **Rejected alternatives:**
  - Move to han-coding, as the software architect proposed — rejected because planning-only installs would lose UX
    review in five skills to keep it in one.
  - Stay in han-core — rejected by the operator; it keeps an agent in the foundation that no core skill uses.
- **Revisit criterion:** If a `han-coding` skill other than code-review comes to require UX review, or code-review's
  `ux` type gains a second reviewer.
- **Dissent (if any):** The software architect's proposal placed it in han-coding under the strict "plugin that
  requires it" rule.
- **Settles delta entry:** pending
- **Dependent decisions:** pending (the content-auditor deferral reason weakens, since `han-coding` now fills a role)
- **Referenced in plan:** pending

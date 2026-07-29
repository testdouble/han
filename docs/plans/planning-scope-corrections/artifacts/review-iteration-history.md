# Review Iteration History: Planning Scope Corrections Implementation Plan

<!--
Round-by-round record of reviews of [../feature-implementation-plan.md](../feature-implementation-plan.md).
Findings live in [review-findings.md](review-findings.md).

Round IDs continue the plan's own build history, which used R1 through R3 in
[implementation-iteration-history.md](implementation-iteration-history.md). This review begins at R4 so the IDs stay
globally unique across both files.
-->

## R4: Team review of the amended plan

- **Mode:** team
- **Spec-aware mode:** not engaged. The file is `feature-implementation-plan.md` and carries none of the feature-spec
  heading set, so general-mode rules applied.
- **Size:** large. The plan touches twenty-one agent definitions in the shared foundation plugin plus four other
  plugins and more than five files. Round cap 3.
- **Specialists engaged:** `han-core:junior-developer`, `han-core:adversarial-validator`,
  `han-core:evidence-based-investigator`, `han-core:structural-analyst`. Launched in parallel with domain-scoped briefs.
  `han-core:evidence-based-investigator` was included under the conditionally-mandatory rule: the plan carries file
  paths with line references throughout.

- **New input provided:** The plan as amended, its decision log, its build-round history, and the source specification.
  Each brief named the amendment explicitly as the freshest and least-tested reasoning, and asked for the stale-edit
  surface it left behind.

- **Findings raised:** F1 through F24. Eighteen major, six minor.

- **What the round turned on:** Three factual claims the plan presented as verified were refuted by direct check. The
  blast-radius count was wrong by roughly half and concealed a scope contradiction (F1). The insert point is not
  uniform (F2). The agent roster is twenty-four, not twenty-two (F3). Separately, the amendment left six statements
  describing the pre-amendment world (F13), and the review found one defect predating the amendment entirely: widening
  the accepted file set breaks a working script in a plugin nobody had scoped (F5).

- **Resolution source:** evidence for F1, F2, F4, F6 through F15, and F17 through F24. User input for F3 and F5.
  Deferred to an open item for F16.

- **Changed in plan:** Outcome, User Stories, Constraints and Boundaries, Implementation Approach (all subsections),
  Work Units and Sequencing, Definition of Done, Testing Strategy, Risks and Assumptions, Open Items, Specialist
  Handoffs for Implementation, Recommendation.

- **Decisions produced:** D-20, D-21. Corrections applied to D-1, D-15, and D-19.

- **Stability assessment:** The plan's reasoning held; its bookkeeping did not. No decision was reversed by this round.
  Two were extended by user input, and three carried claims that a repository check refuted. The eighteen major
  findings are concentrated in two causes: an amendment applied by hand without a full consistency pass, and a set of
  counts asserted rather than measured.

- **Next-step recommendation:** Go to synthesis. The deterministic stop rule is not yet met, since this round produced
  well over two findings and many were major, so a second round is warranted under the large-size cap of three.

## R5: Verification of the corrections

- **Mode:** team
- **Spec-aware mode:** not engaged.
- **Specialists engaged:** `han-core:evidence-based-investigator`, re-engaged on the corrected claims only.
- **New input provided:** The corrected plan and decision log, with each figure, exclusion, and file reference R4
  changed, plus a directive to hunt for errors introduced while fixing the old ones.

- **Findings raised:** F25, F26. Both major.

- **What the round turned on:** Nine of the eleven corrections verified clean, including the two counts, the roster
  arithmetic, the renumbered dependency graph, and the absence of any surviving refuted figure. Two did not. The
  correction to the GitHub screenshot chain was itself incomplete, naming two hardcoded locations where a third exists
  (F25). And renumbering the work units broke ten cross-references in the decision log that the plan's own edit pass
  did not sweep (F26).

- **Resolution source:** evidence for both.

- **Changed in plan:** Implementation Approach (Visual material, producer and consumer). The decision-log corrections
  changed no plan section.

- **Decisions produced:** none. Corrections applied to D-20, and to the cross-reference fields of D-3, D-5, D-6, D-7,
  D-8, D-9, D-10, D-14, D-16, D-18, and D-19.

- **Stability assessment:** The round found two real defects, both of them artifacts of R4's own corrections rather
  than pre-existing. That is the expected failure mode of a large hand-applied edit pass, and it is why the round was
  run rather than assumed. Neither finding changed a decision or a behavior; both were bookkeeping the corrections
  themselves introduced or left behind.

- **Next-step recommendation:** Stop. The deterministic stop rule is met after these two are applied: the round
  produced two findings, and neither touches security, a committed mechanic, a coordination, or a failure mode in a
  primary path. A third round under the size cap would be re-checking bookkeeping already checked twice.

## R6: User dispositions on the non-blocking open items

- **Mode:** team, no specialists dispatched. The round records two user decisions that closed open items after the
  review converged.
- **Spec-aware mode:** not engaged.
- **Specialists engaged:** none.
- **New input provided:** OI-1 and OI-2 presented to the user one at a time in plain language, each with its failure
  mode, its cost either way, and a recommendation.

- **Findings raised:** none.

- **Resolution source:** user input, three times.
  - OI-1 closed as ignored. The proportionality signal ships as the specification requires and its effectiveness is not
    measured.
  - OI-2 closed by accepting the recommendation. In `plan-work-items` the completeness gate covers only material that
    run itself received.
  - OI-3 closed by accepting the recommendation. The explanation standard carries guidance only, so no planning skill
    gains a check step.

- **Changed in plan:** Constraints and Boundaries, Implementation Approach (Where the shared rules live, The explanation
  standard), Risks and Assumptions, Open Items, Specialist Handoffs for Implementation, Review History, Recommendation.

- **Decisions produced:** D-22, D-23, D-24. Assumption A3 retired, its ID left recorded rather than reused.

- **Stability assessment:** Stable. No finding was reopened, and the only behavior touched is one gate's scope. The plan
  carries zero open items where it carried three, and one accepted unowned risk where a tracked question used to be.
  Two of the three closures took the smaller of two available implementations, and each names the gap it accepts rather
  than claiming none exists.

- **Next-step recommendation:** Stop. The plan is ready to build.

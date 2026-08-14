# Implementation Decision Log: pairing

Every implementation decision settled while planning how to build `pairing`. Behavioral commitments live in
[../feature-specification.md](../feature-specification.md) and its own decision log; this file records how the work gets
done, not what it does.

Round-by-round discussion is in
[implementation-iteration-history.md](implementation-iteration-history.md).

## D-1: The flag travels in the invocation, not as a named caller

- **Question:** What carries "invoked through the pairing mode" into a backing skill?
- **Decision:** An invocation-scoped argument, in the same shape three of the five skills already use for their size
  argument. No backing skill names the mode in its own text.
- **Rationale:** `design-an-api`, `iterative-plan-review`, and `plan-implementation` already declare an `arguments` key
  and branch on a selector passed at invocation, without knowing who passed it. Reusing that shape means the
  coupling is "this skill accepts an argument," which every reader of this suite recognizes, rather than "this skill
  knows a specific other skill can call it."

  The alternative reading of the specification's wording, that each skill's prose says "when invoked through pairing,"
  is tighter and more fragile. The mode's name already changed once during specification, and five files naming it would
  each have needed editing again.
- **Evidence:** Verified directly. `design-an-api`, `iterative-plan-review`, and `plan-implementation` carry
  `arguments: size`; `tdd` and `refactor` carry only `argument-hint` and gain an `arguments` key as part of this work.
  The suite's composition guidance points the same way twice: it tells an orchestrator to forward the user's request and
  the `size` argument through a sub-skill call unchanged, and it tells the orchestrator to state any behavior change as
  an explicit instruction in the call rather than assuming the sub-skill will infer it.
- **Rejected alternatives:**
  - Prose in each skill naming the mode — rejected as tighter coupling that breaks on a rename, which has already
    happened once here.
  - A marker file on disk — rejected as invisible state in a working tree that two of the backing skills actively inspect.
  - A new frontmatter field or shared detection script — rejected under the YAGNI rule as inventing a mechanism where a
    proven one exists. Reopening trigger: the flag needs to carry more than a yes-or-no value.
- **Corrected during implementation.** The argument form did not survive contact with the three skills that already
  carry one. Each of them uses the second positional slot for free text — the goal and interface for `design-an-api`,
  the plan path for `iterative-plan-review`, the specification path for `plan-implementation` — so a second named
  positional argument would collide with the subject the person actually types. The known gap recorded here anticipated
  the risk and named the fallback, which is what shipped: the flag rides in the invocation text, and each skill checks
  whether the request asks to review each unit as it lands.

  That turned out better than the argument form on two counts beyond avoiding the collision. It is what the composition
  guidance prescribes, which is to state an override in the invocation rather than let the sub-skill infer it. And `tdd`
  and `refactor` already carry an exception of exactly this shape, gating when the request explicitly asks to review
  before implementation, so the flag extends a mechanism those skills have rather than adding a parallel one.

  It also answers OI-1, which asked whether a pairing invocation trips that existing exception. It does, and that is the
  intended behavior rather than a conflict. A person who types the same request directly gets the same collaborative
  behavior, which is consistent with what those skills already promise rather than a violation of the opt-in rule.

  No skill gained an `arguments` key. The five insertions are one short paragraph each, purely additive, totalling
  thirty-three lines across five files.
- **Referenced in plan:** What you are building
- **Driven by rounds:** R1

## D-2: The backing skill performs the stop, and the shared rule file is why both sides agree on its shape

- **Question:** When a backing skill reaches its unit boundary, which skill performs the stop?
- **Decision:** The backing skill does. It owns the boundary and knows when it has reached one. What it presents at that
  stop is specified by the shared rule file, which the mode also follows, so a stop looks the same whoever performed it.
- **Rationale:** The mode cannot detect when a behavior has been driven to green or a refactoring has completed; only the
  skill doing the work can. Having the mode reach back in would require it to track state inside another skill's loop.

  The suite's composition guidance names this general shape as supported, calling it orchestration composition, and
  carries two warnings. The moment after a sub-skill call is when the calling model is most likely to stop and treat the
  sub-skill's output as its own final answer, so continuation is instructed explicitly rather than assumed. And the more
  the caller carries across the call, the more likely it loses its own workflow.

  The second warning runs against this design rather than supporting it, and the plan says so rather than claiming the
  guidance endorses what it does not. The guidance's discipline is a thin orchestrator with little state to lose; this
  mode carries a plan, a running feedback record, and the person's position across every stop. What makes that
  survivable is that the state is written to a file rather than held in the thread, which the specification already
  commits to at D8. Treat the thin-orchestrator rule as a named risk with a named mitigation, not as evidence for the
  design.

  This is what makes the rule file load-bearing rather than a convenience. If the five skills each performed a stop in
  their own words, a stop would mean five different things.
- **Evidence:** The suite's skill-composition guidance, which names orchestration composition as supported with care and
  gives both the thin-orchestrator rule and the explicit-continuation rule. The structure of the five skills, each of
  which already closes a unit explicitly. Specification decision D8 for the written feedback record.
- **Rejected alternatives:**
  - The mode performs every stop by inspecting the backing skill's progress — rejected because it requires tracking
    another skill's internal state, and the guidance says to keep the caller thin for exactly that reason.
  - Re-invoking the backing skill once per unit — rejected because none of the five accepts a resume-from-here input, so
    each invocation would rebuild its list from scratch.
- **Known gap:** The specific mechanic this decision needs is outside what the guidance covers. Both of its working
  examples call a sub-skill once and let it run to completion; neither has a sub-skill that ends its turn partway
  through its own run and later resumes with its own instructions still governing. Unverified: could not inspect
  whether a skill can end its turn mid-run and resume under its own instructions, because no running session exists in
  this repository. Phase 3 observes it on the lowest-churn skill before the contract reaches the two hardest ones.
- **Referenced in plan:** The one thing to get right first
- **Driven by rounds:** R1

## D-3: Flag the five skills lowest-churn first

- **Question:** In what order do the five flag edits land?
- **Decision:** `design-an-api`, `refactor`, `tdd`, `iterative-plan-review`, `plan-implementation`.
- **Rationale:** Two reasons point the same way. Ascending churn puts the edits most likely to collide with in-flight
  work last, and the two highest-churn files are also the two whose stop contract is least obvious, because a review
  round produces findings rather than a built artifact. Proving the contract on three skills that build something real
  means the harder two are written against a pattern that already works.
- **Evidence:** Ninety-day commit counts against each skill file, re-run at synthesis: `plan-implementation` 22,
  `iterative-plan-review` 15, `tdd` 12, `refactor` 8, `design-an-api` 3. The discovery pass omitted `design-an-api` from
  its churn table because it sat below the table's cutoff, not because it had no commits.
- **Rejected alternatives:**
  - Highest-churn first, to get the risky edits over with — rejected because it writes the least-defined contract first.
  - All five together — rejected because a mistake in the shared paragraph then exists in five files before anyone sees
    it once.
- **Referenced in plan:** Build order, Phase 3, Phase 4
- **Driven by rounds:** R1

## D-4: Vendor the rule file, following the established han-core pattern

- **Question:** Does the new rule file get vendored into the consuming plugins, or reached some other way?
- **Decision:** Vendored, byte-identical, into `han-coding/references/` and `han-planning/references/`, matching how the
  shared configuration, evidence, and YAGNI rules already work.
- **Rationale:** This follows the pattern the consuming skills already use. `tdd` links the YAGNI rule at a path
  resolving inside its own plugin, not across into the foundation plugin, and both consuming plugins already declare a
  dependency on the foundation, so the direction is sound and declared.

  The competing pattern is real and was weighed. The communication plugin keeps a single canonical copy of its
  readability and explanation rules and exposes them through inline skills other plugins invoke by name, with no
  vendoring anywhere. That is a genuine alternative and it avoids the re-sync obligation.

  Vendoring won on two grounds. It matches what the five consuming skills already do for every other shared rule, so a
  reader meets one pattern rather than two. And the invoke-by-name route would mean adding another skill purely to serve
  five consumers, where the existing example serves far more: the discovery pass counted twenty-nine invocations of the
  readability-guidance skill alone.
- **Evidence:** The root project map states the vendoring convention and the edit-canonical-then-re-sync obligation
  outright. Verified that the three existing shared rules are byte-identical across both consuming plugins. Verified the
  communication plugin has no vendored copies of its two canonical rules.
- **Rejected alternatives:**
  - An inline guidance skill invoked by name — rejected as adding a skill for five consumers when the proven analogue
    serves an order of magnitude more, though it is the better answer if the consumer count ever grows.
  - One canonical file with no copies, read across plugin boundaries — rejected because no skill in this repository reads
    a reference file from another plugin's installed tree, and the suite's own recorded finding on cross-plugin sourcing
    is that `${CLAUDE_PLUGIN_ROOT}` and every relative path resolve inside the reading skill's own plugin, so a
    cross-plugin path read would not resolve at all.
  - One canonical file consumed only by the mode, with each flagged skill carrying a single inline sentence — rejected
    once D-2 settled that the backing skill performs the stop, which means it needs the whole contract rather than one
    sentence.
- **Known gap:** Nothing in the repository re-syncs a vendored copy after its canonical file changes, and the only trace
  of past sync effort is a manual sweep. D-9 commits a byte-equality check across the copies, which catches a divergence
  once it lands but does not prevent one and does not perform the re-sync. Separately, the rule file joins a directory in
  the planning plugin that already mixes owned and vendored files, and the project map warns against overwriting an owned
  file during a re-sync sweep. The new file is vendored, not owned, and should carry the same header the vendored copies
  carry so a future sweep can tell.
- **Referenced in plan:** Build order, Phase 1
- **Driven by rounds:** R1

## D-5: The mode does not declare AskUserQuestion

- **Question:** Which tools does the mode declare?
- **Decision:** It declares the `Skill` tool, because it invokes others. It does not declare `AskUserQuestion`.
- **Rationale:** The authoring guidance bars `AskUserQuestion` from every skill's `allowed-tools`, not only a parent's.
  `allowed-tools` is an auto-approve list, and the permission evaluator returns early on a match, handing back empty
  answers without ever rendering the question. Declaring it therefore breaks the tool for the declaring skill outright.

  A parent's always-allow rules also stack onto the skills it calls, so declaring it here would break questions asked
  underneath as well. That consequence is concrete rather than hypothetical: `design-an-api` surfaces its open items one
  at a time through `AskUserQuestion`, and it works today precisely because no skill in the chain declares the tool.

  Nothing is lost by leaving it out. The mode stops by ending its turn, which needs no tool. Where the specification does
  call for candidate options, such as the one question it asks about a request too vague to sort, the tool still works
  undeclared; the person sees a one-time permission prompt before the question renders.
- **Evidence:** The suite's authoring guidance on this tool, which states the rule as universal, explains the early
  return in the permission evaluator, records the stacking behavior for child skills, and notes that removing the tool
  from `allowed-tools` does not break it. Verified that `design-an-api` calls `AskUserQuestion` and that the tool is
  absent from its `allowed-tools`.
- **Rejected alternatives:**
  - Declaring it for the pre-build ask — rejected because the guidance's rule is universal, that ask is an ordinary turn
    ending anyway, and declaring the tool would silently break both the mode's own questions and `design-an-api`'s.
- **Revisit criterion:** The upstream Claude Code bug the guidance cites ships a fix and the guidance is updated to allow
  the declaration.
- **Referenced in plan:** Build order, Phase 2
- **Driven by rounds:** R1

## D-6: For a review round, the findings are the checkable claims

- **Question:** What does a stop present when the backing skill produces findings rather than a built artifact?
- **Decision:** The findings are what you can check, and the plan edits the round made are what changed. The stop keeps
  the same shape as any other; only what fills it differs.
- **Rationale:** The stop contract asks for the specific things you can verify and what changed. A review round supplies
  both, just not as a file diff. A finding with its citation is precisely a checkable claim, which is the property the
  contract is built around.

  Two consequences follow and are settled here rather than left to the implementer. A person's redirect at a stop does
  not consume a round against the size-band cap, because a round is a unit of review work and a redirect is not. And at
  the smallest size band, `plan-implementation` runs one round and then escalates to the person anyway, so the flag adds
  a stop beside one that already exists. That is acceptable rather than a defect: the existing escalation asks a
  question, and the flag's stop presents the round's findings, which are different things.
- **Evidence:** Both planning skills cap rounds by size band at one to three. `plan-implementation` places its user
  escalation pass immediately after its resolution loop.
- **Rejected alternatives:**
  - A separate stop contract for review rounds — rejected because the shared contract already fits once findings are
    recognized as checkable claims, and a second contract would defeat the rule file's purpose.
- **Referenced in plan:** Build order, Phase 4
- **Driven by rounds:** R1

## D-7: code-walkthrough's description is tightened to fit its boundary clause

- **Question:** How do seven descriptions absorb new routing text under a hard character cap?
- **Decision:** Four have room and take the clause as written. `code-walkthrough` does not, so its existing description
  is tightened to make room before the clause is added.
- **Rationale:** The authoring standard holds every description to 1024 characters, which is the stricter of the two real
  limits: a hard cap where a skill is uploaded rather than listed, against a looser per-entry cap in the listing path.
  Measured headroom against that target: `code-walkthrough` 69, `design-an-api` 137, `tdd` 169, `refactor` 315,
  `iterative-plan-review` 482, `plan-implementation` 544. The clause `code-walkthrough` needs, distinguishing pacing
  through work that already exists from building work while pacing you through it, runs roughly twice its remaining
  budget.

  This is worth settling in the plan rather than discovering mid-edit, because the obvious reaction to hitting the cap is
  to shorten the new clause, and the new clause is the entire point of the change.
- **Evidence:** Measured against all six existing descriptions with the measurement script the description-length
  guidance ships, so the numbers are reproducible by the same method the standard prescribes.
- **Rejected alternatives:**
  - Shortening the new boundary clause to fit — rejected because the clause is what prevents a request landing on the
    wrong skill, and it is already the shorter half of a bidirectional pair.
  - Leaving `code-walkthrough` unchanged — rejected because one-sided disambiguation leaves a gap the request falls
    through, which is the failure the pairing has to prevent.
- **Referenced in plan:** Build order, Phase 5
- **Driven by rounds:** R1

## D-8: Three plugins bump, and the meta-plugin follows its existing rule

- **Question:** Which plugin versions change?
- **Decision:** The three plugins gaining user-visible behavior bump: the foundation plugin gains a skill and a rule
  file, and the two plugins carrying flagged skills gain a new argument on those skills. The meta-plugin bumps only if
  the repository's existing release practice requires it when a bundled child bumps.
- **Rationale:** Each of the three has a version string appearing in more than one file, so the bump is a multi-file edit
  per plugin rather than one. Naming this in the plan prevents the common failure of updating a plugin manifest and
  forgetting the marketplace entry carrying the same number.

  The meta-plugin question is deliberately deferred to the release skill rather than answered here. That skill owns
  version policy and reads each plugin's manifest to propose bumps, so duplicating its rule in a feature plan is how the
  two drift apart.
- **Evidence:** Each plugin's version appears in both its own manifest and the marketplace manifest. The repository has a
  dedicated release skill that owns per-plugin versioning and tagging.
- **Rejected alternatives:**
  - Deciding the meta-plugin bump here — rejected as duplicating a rule another skill owns.
  - One bump covering all three — rejected because the plugins version independently, which is what their separate tags
    exist for.
- **Referenced in plan:** Build order, Phase 6
- **Driven by rounds:** R1

## D-9: Seven mechanical checks, and no prose snapshot

- **Question:** What gets automated?
- **Decision:** Seven checks: the foundation plugin still declares no dependency on the two plugins whose skills it
  calls; each changed description stays under its character budget; the rule file resolves from all five consumers; the
  vendored copies match the canonical file byte for byte; the four manifests mention the mode; the standard skill
  surfaces exist; and each colliding pair names the other in both directions. No snapshot test pins existing prose.
- **Rationale:** Each of the seven can genuinely fail and each failure would mean something real. The dependency check
  guards the invariant the whole placement decision rests on, and today that invariant is enforced only by the absence of
  a key in a file. The byte-equality check is the only automated guard on the drift D-4 accepts as its cost.

  The snapshot test is the tempting one to add and the right one to skip. It would pin the sentences in each flagged
  skill that promise an uninterrupted run, catching a deletion. But the four files it would guard changed twenty-two,
  fifteen, twelve, and eight times in ninety days, so it would fire on routine unrelated edits far more often than on a
  real regression. A check that cries wolf gets ignored, then deleted.
- **Evidence:** The repository already has a working cross-reference check in Bats to model the resolution check on, and
  the description-length guidance ships its own measurement script. Churn figures from the discovery pass.
- **Rejected alternatives:**
  - A prose snapshot on the five flagged skills — rejected on the churn evidence above. Running each skill directly plus
    ordinary diff review covers the same concern. Reopening trigger: a flagged skill's default behavior actually
    regresses into a release.
  - A structural additive-only diff check — rejected as tooling that reproduces what review already does at merge time.
- **Referenced in plan:** How anyone knows it worked
- **Driven by rounds:** R1

## D-10: No detection script; the mode reacts rather than predicts

- **Question:** How does the mode know whether a backing skill's plugin is installed?
- **Decision:** It does not check in advance. It names the backing skill it intends to use in the plan it proposes, and
  if that skill does not resolve when invoked, it says so and offers the choice between the open-ended path and
  installing the plugin.
- **Rationale:** No precedent exists for what a check would even do. Every availability probe in the suite tests for an
  external command-line tool; nothing anywhere detects another Han plugin, and the install path such a probe would
  inspect is not referenced anywhere in this repository.

  The manifest format cannot express the relationship either. A plugin's `dependencies` entries carry a name, an
  optional version range, and an optional marketplace, and every declared dependency is required and auto-installed on
  install. There is no optional-dependency form, which is why the specification's "optional backing skills" has to be a
  runtime posture rather than a declaration.

  The graceful-degradation guidance that would otherwise apply is about environment state, meaning a missing git history
  or configuration file, not about sibling plugins. Stretching it here would mean inventing a path probe on no evidence.
  The composition guidance's preflight rule does not reach this either: it says to validate hard requirements before an
  expensive sub-skill call, and the specification makes the backing skills explicitly not a requirement.

  Reacting satisfies the same commitment more simply. The specification requires that the mode never substitute
  silently, and a failed invocation reported plainly does that. The person also learns the same thing at the same
  moment, because the plan named the intended skill one step earlier.
- **Evidence:** Verified that every availability check in the suite probes for an external binary. No plugin-detection
  example exists in any plugin. The plugin-manifest reference documents `dependencies` with no optional form. The two
  plugins carrying flagged skills go missing independently, so a predictive check would need to run twice.
- **Rejected alternatives:**
  - A detection script exiting zero on all paths, per the degradation guidance — rejected under the YAGNI rule as
    building a mechanism with no precedent to serve a case the reactive path already handles. It would also need a Bats
    test, making it two new artifacts. Reopening trigger: the reactive path proves confusing in real use, or a platform
    surface for querying installed plugins appears.
  - Declaring the two plugins as manifest dependencies — rejected because the format has no optional form, so declaring
    them would make them required and close the dependency cycle the specification's D12 exists to avoid.
  - Asking the person up front which plugins they have — rejected because it adds a question to the top of every run and
    breaks the specification's promise that the mode needs no precondition beyond a task you can describe.
- **Referenced in plan:** Deferred (YAGNI)
- **Driven by rounds:** R1

## D-11: The prose ladder climbs per section once the work is long enough

- **Question:** Does the fidelity ladder apply to a whole piece of writing or to each of its sections?
- **Decision:** Short work climbs the ladder once, whole. Longer work agrees the shape for the whole artifact first, then
  climbs the remaining rungs section by section, with the plan naming the sections up front so they can be redirected.
- **Rationale:** A fixed three-stop ladder breaks at both extremes. On a four-sentence reply it means three stops on four
  sentences. On a long document the middle rung is one piece the size of the whole job, which is the unreviewable lump
  the mode exists to prevent. The operator's own founding example, pairing on writing a response, could land on either
  side of that.

  Agreeing the shape for the whole artifact before sectioning preserves what the evidence actually supports, which is
  that structural feedback has to come before surface feedback. Sectioning only the later rungs keeps that order intact.
- **Evidence:** User input, choosing this over a fixed three stops and over letting each plan decide case by case.
- **Rejected alternatives:**
  - Always three stops per artifact — rejected because it produces an unreviewable middle rung on long work.
  - Letting the proposed plan decide each time — rejected because it drops prose to the same footing as the case the
    research rates Low confidence, when prose has a Medium-confidence unit available.
- **Known gap:** Neither the section boundary nor the length threshold has evidence behind it. The underlying prose unit
  is already the Medium-confidence part of this design, described in the research as a reconciliation rather than a
  documented practice, and this decision adds a second judgment on top of it. Both should be treated as provisional and
  revisited after real use. This is also the one commitment in this file that is behavioral rather than procedural: it
  answers a question the specification left open rather than deciding how to build something the specification already
  settled, so it is written into the mode in Phase 2 and belongs upstream if the specification is ever reopened.
- **Referenced in plan:** Build order, Phase 2
- **Driven by rounds:** R1

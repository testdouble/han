# Research: Should Han add a design-time algorithmic-efficiency specialist?

## Summary

The gap is real, and Han should close it by extending an agent it already has, not by building a new one. Give the job
to the agent that already reads code the way this job needs it read.

Issue [#153](https://github.com/testdouble/han/issues/153) reports that Han's agent roster has no owner for design-time
algorithmic and computational-complexity review, and proposes filling it in stages. This report tests whether Han
should add that agent, using strict evidence mode: every claim carries a checkable source, and a claim resting on a
single web source is marked and cannot by itself justify the recommendation.

Nothing in Han today asks whether a piece of code picked the right algorithm or the right data structure. I checked
that against every agent definition and every skill that could dispatch one, and the gap holds. The three agents that
come closest each own something else: one watches the line between code and the database, one watches for missing size
limits, one watches how software gets shipped and run.

The cheapest real fix is to add a cost dimension to Han's static-structure analyst, the agent that already reads code as
written rather than watching it run. That agent already runs on every architectural analysis, and it feeds the architect
agent that currently has nothing to say on this topic because nobody hands it anything. Han's own authoring guidance
tells you to do exactly this: improve an existing agent before you add another one.

Two things are worth knowing about the proposal as written. Its first stage ends in a measurement this repository
cannot run, because the method it names does not exist here.

Its central worry about model capability is also softer than the first draft of this report claimed. Models get the
running-time cost of unfamiliar code right somewhere between two in five and seven in ten times, depending on the
model. That is well short of reliable, but it is not the disqualifier I first wrote it up as. It shapes how you word
the finding rather than whether you build anything.

- **Confidence:** Medium

## Research Results

### The gap is real, and it survives a direct check against every agent

No agent in Han's roster owns algorithmic-complexity review of application logic (A1). Where the words "algorithm" or
"complexity" appear, they mean something else in each agent's charter:

- The concurrency analyst uses "lock-free algorithms" to mean synchronization primitives (A7).
- The structural analyst uses "complexity" to mean code organization and coupling (A5).
- The behavioral analyst mentions memoization only as a kind of state cache (A6).

The three agents that come closest each own a genuinely different concern:

- The data engineer fires at the boundary between code and the database, on in-memory work a query should have done
  (A2). A pure in-memory quadratic loop with no database involved gives it nothing to grip.
- The on-call engineer keys on the absence of a size limit. Its anti-pattern is "any in-memory queue or buffer with no
  size limit" (A3). A triple-nested loop over a capped thousand-item list never trips it.
- The DevOps engineer audits delivery and operations against DORA metrics, the Twelve-Factor App, and the Four Golden
  Signals, three published frameworks for measuring delivery speed, structuring services, and monitoring them (A4). None
  of that is per-function algorithm choice.

The software architect synthesizes what upstream discovery agents produce and does no discovery of its own (A8). Because
none of its upstream agents produces a complexity finding, the gap propagates. Even when the architect is dispatched, it
has nothing to recommend on this axis.

The skills that could dispatch such an agent have no hook for it either:

- The code-review skill's entire efficiency checkpoint is a five-line section shaped around databases and frontends
  (A9), and its dispatch roster contains no complexity specialist (A10).
- The architectural-analysis signal table has seven rows and no complexity row (A11).
- The plan-implementation specialist menu lists thirteen specialists and no efficiency one (A12).
- Feature planning routes implementation mechanics downstream on purpose (A13).
- The investigate skill dispatches three conditional specialists, none for complexity (A14).

### How reliably a model judges complexity, corrected

My first draft of this report got this wrong, and the correction matters enough to state plainly.

BigO(Bench), a benchmark from Meta's research group, ran twelve models over 3,105 coding-contest problems and reported
three separate accuracy columns (A21). The loosest asks whether the model found the correct complexity at all. The
strictest asks whether it got every complexity class in a problem right at once. My first draft quoted the strictest
column and labeled it as the loosest.

Here is what the paper reports for the four models it highlights:

- On running-time complexity, the loosest measure ranges from 40.4% for Llama 3.1 405B to 70.1% for DeepSeek-R1 Llama
  70B; the strictest ranges from 33.1% to 41.4%.
- On memory complexity, the loosest measure ranges from 39.5% to 68.8%, and the strictest from 8.1% to 14.0% (A21).

So the honest reading is narrower than "unreliable." A model asked to judge the cost of one piece of code lands
somewhere between two in five and seven in ten. That beats guessing and falls well short of a verdict you would act on
without checking. Getting a whole problem's classes right at once is much harder, and memory cost is the weakest area
under every measure.

CodeComplex, a separate benchmark of 4,900 Java and 4,900 Python programs labeled across seven complexity classes,
adds the failure shape (A22). Models confuse neighboring classes, calling an O(n log n) routine linear or quadratic. The
errors cluster near the right answer instead of scattering.

That shape is the part that should change a design. A near-miss produces a review comment that sounds right, names a
specific complexity class, and is wrong. A reader has no cheap way to tell it from a correct one. The fix is to ask any
agent for the pattern it can see in the code, not for the complexity class. That is a design constraint, not a reason to
build nothing.

The paper also notes that reasoning models spend extra tokens thinking before answering. On complexity tasks, though,
they sit "much closer" to other models than their general coding scores would predict, and they are outperformed by
Llama 3.1 405B on memory complexity (A21). Being good at writing code does not carry over to reasoning about its cost.

Sound automated analysis exists, but only inside restricted settings. The pymwp tool computes guaranteed worst-case
bounds for a constrained subset of the C language (A26, [single-source]). I found nothing comparable for general
application code.

The "complexity" mainstream tooling measures cheaply is a different quantity: cyclomatic complexity, a count of
independent paths through a program's control flow (A27). It does not measure how cost grows with input size. A flat
loop and a nested loop can carry the same cyclomatic score and very different costs.

### Human review does not name this concern either, and real defects slip through

Google's public reviewer guidance enumerates twelve concerns, and its "Complexity" item is explicitly about code a
reader cannot understand quickly, not about running-time cost (A23). Nothing in it names algorithmic complexity, Big-O,
or data-structure fit.

The most detailed defect taxonomy I found, Mäntylä and Lassenius's classification of defects across 32 review sessions,
reports that 75% of what reviewers flag concerns maintainability rather than behavior (A24, [single-source, not read
directly]). The performance-shaped categories sit inside the smaller remainder.

Meanwhile the defects are demonstrably there. Jin and colleagues studied 110 real performance bugs across Apache,
Chrome, GCC, Mozilla, and MySQL, and derived efficiency rules from 25 of them. Applying those rules surfaced 332
previously unknown performance problems in the then-current versions of MySQL, Apache, and Mozilla (A25,
[single-source, not read directly]). Those inefficiencies had passed through mature review processes undetected.

I found no source that names algorithmic complexity as its own review category, distinct from general code complexity on
one side and runtime profiling on the other. The three-way split the issue draws is a useful distinction to work with,
and it is not established terminology in the review literature I could reach.

### Specialist agents produce non-overlapping findings, but no study tests this comparison

The evidence on whether a dedicated specialist beats a broadened generalist is split, and the split tracks task type.

Broad persona injection does not reliably help. A study of 162 personas over 2,410 factual questions across four model
families found no benefit, or a small penalty. Automated persona selection did no better than picking at random (A29).
A follow-up over 1,140 questions and 38 roles found the effect depends on domain: persona framing raised expertise
depth and lowered clarity, helping in advisory domains and hurting in explanatory ones (A30).

The findings that favor specialization come from adjacent domains:

- Splitting scientific-paper review across dimension-specific agents cut generic comments from over half to 29% and
  roughly doubled useful comments per paper (A32, [single-source]).
- The one study that tested persona specialization on code review directly found that 51% of specialist findings were
  entirely absent from a generic reviewer's output on the same model, over 50 merged pull requests (A31,
  [single-source]). Its authors flag two limits: no independent rater checked the findings, and cross-model validation
  covered only three pull requests.
- The c-CRAB benchmark converted human review comments into executable tests. Four automated review tools together
  passed only 41.5% of them, so their findings were largely complementary rather than duplicated (A34, [single-source]).

Against that, essay grading with three specialists plus an arbiter beat a single generalist by about 2.9 points of
agreement, at four times the compute. The advantage concentrated at the weakest essays (A33, [single-source]).

No study I found compares the pair this decision needs: a broadened existing reviewer against that reviewer plus a new
specialist, on the same task and the same scoring harness.

### Han's own guidance says to improve an existing agent before adding one

This is the constraint that decides the recommendation, and it is a codebase anchor rather than a web claim.

Han's authoring guidance states the rule directly: ask whether the current setup already reaches more than 45% of
optimal quality on the dimension you want to improve. If it does, improve the existing agent's instructions, vocabulary,
or tool access first. Adding an agent is justified only after a single agent has been optimized and still falls short
(A15).

Two readings of that rule pull in different directions, and both deserve to be stated. On the coverage dimension Han
sits at zero, so the 45% number does not block adding an agent. But the rule's instruction is a sequence, not a
threshold test alone: optimize first, add second. Nobody has tried the optimize-first step here.

The guidance also caps a concurrently dispatched team at roughly five agents, and labels that cap "a practical operating
limit, not a platform rule" (A15). The architectural-analysis skill already runs six to nine agents in its large band by
design (A17), so a strict five-agent ceiling is not an argument the codebase itself honors. I over-weighted that ceiling
in my first draft.

The guidance attributes its 45% figure to Google Research, Google DeepMind, and MIT's 2025 scaling work, and that
attribution checks out. The paper reports that tasks where a single agent already exceeds 45% accuracy see negative
returns from additional agents (A28). Its public summary reports large coordination gains on tasks that split into
independent pieces: +80.9% on a financial-reasoning benchmark. It also reports sharp losses on tasks that must run in
order: −39% to −70% on planning (A28b).

### The static-structure analyst is the natural home, and it already runs everywhere

Han's structural analyst reads "code as it is written, not how it behaves at runtime" (A5). Asymptotic cost is a
property of code as written: you find a quadratic loop by reading two nested loops, not by running them. That fits this
agent's charter better than it fits any other.

Its reach is the stronger argument. The structural analyst runs in the always-on spine of every architectural analysis,
at every band, not behind a signal gate (A40). It is a conditional reviewer in code-review, a menu option in
plan-implementation and iterative-plan-review, and signal-selected in design-an-api (A40). A new agent would start
behind a signal and a minimum band. This one already arrives.

It also fixes the propagation problem. The software architect has nothing to recommend on cost because no upstream agent
hands it a cost finding (A8). Give the structural analyst a cost dimension and the architect gets an input it can act
on.

Two honest costs come with this.

The structural analyst's five existing dimensions all concern relationships between modules. Adding cost inside a
function widens the analyst's altitude, the level of code it looks at, from relationships between modules down to what
happens inside one function. That is the generalist trap Han's own domain-focus guidance warns about.

Its code-review trigger also explicitly skips single-file in-place edits (A40), which is exactly where a quadratic loop
is most likely to be introduced.

### The proposal's own gating plan cannot run in this repository

The issue's Stage 0 ends by running "the project's existing A/B unique-survivor-yield method" over real changes to see
whether a broadened checklist misses complexity findings. That method does not exist here. Repository-wide searches for
it return nothing (A16). The two prior plans the issue cites as its source for the method have no directories under
`docs/plans/` either (A16).

Two published methodologies could be adapted if someone wanted to build one:

- The c-CRAB benchmark converts human review comments into executable tests and reports both a per-reviewer pass rate
  and union coverage across reviewers (A34).
- The code-review persona study reports the share of a treatment's findings absent from the control's output on the
  same input, alongside a tracked false-positive rate (A31).

Neither is described as blinded or multiply rated.

### Where the proposal's citations have drifted

The issue was filed on 2026-07-28 and its file references have gone stale as content moved. Its substantive claims
survive; the pointers do not. The code-review checklist moved within its file, the architectural-analysis signal table
moved within its file, and the plan-implementation specialist menu moved out of the skill file into a reference file
(A9, A11, A12).

One number changed under it rather than being wrong. The issue reports that plan-implementation caps its team at "6 to
8," and that string was in the file when the issue was written. Commit `47ccdfeb`, on 2026-07-30, replaced it with three
to four chosen specialists on a team of five to six (A18). The correction belongs to the codebase, not to the
investigation.

## Options to Consider

### O1: Close the issue and change nothing

- **What it is:** Accept that the gap is structural rather than felt, and leave the roster and the checklists alone.
- **Trade-offs:** Costs nothing and adds no noise. It leaves a verified hole, and there is evidence that efficiency
  defects survive mature review processes (A25). It also discards a cheap, reversible option without trying it.
- **Rests on:** (A1, A24, A25)
- **Evidence status:** corroborated on the gap (codebase anchors A1-A14); the "defects slip through" support is
  single-source and was not read directly

### O2: Broaden the code-review checklist only

- **What it is:** Add algorithmic and data-structure items to the code-review Performance checklist, and leave the agent
  roster alone.
- **Trade-offs:** The smallest possible change, touching one file. Against it: it reaches only one of the four skills
  that could carry this concern. And it reaches the one that runs after the code is already written, which is the
  opposite of the design-time framing the issue argues for. Checklist efficacy is also contested for human reviewers
  (A38 against A39), and instruction-load research says added items do not reliably fire (A35, A36, A37). My first draft
  paired this with a change to the software architect's charter; that pairing does not work, because that agent's own
  charter forbids it from discovering findings (A8).
- **Rests on:** (A8, A9, A35, A36, A37, A38, A39)
- **Evidence status:** corroborated

### O3: Build a dedicated algorithmic-efficiency agent and wire it in

- **What it is:** The issue's Stages 1 and 2. Build a discovery agent in the same mold as the structural, behavioral,
  and concurrency analysts, roughly 130 to 145 lines (A19), then wire it conditionally into plan-implementation and
  architectural-analysis, and later code-review and investigate.
- **Trade-offs:** The only option that gives the concern its own name and its own vocabulary, and specialization does
  produce findings a generically prompted reviewer misses (A31, A32, A34). The 45% number does not block it, since
  coverage today is zero (A15). Against it: Han's own guidance sequences optimize-first before add-second, and the
  optimize-first step has not been tried (A15). A new agent also starts behind a signal gate and a minimum band, so it
  reaches less than an agent already in the spine does (A40).
- **Rests on:** (A15, A19, A31, A32, A34, A40)
- **Evidence status:** corroborated

### O4: Run the proposal's staged plan as written

- **What it is:** Do Stage 0, measure with the A/B unique-survivor-yield method, and build the agent only if the
  measurement shows a real miss.
- **Trade-offs:** The most rigorous shape on paper, and it is what the 45% rule asks for. The method it depends on does
  not exist in this repository, and neither do the two plans the issue cites as its source (A16). So the plan stalls at
  its own gate. Adapting c-CRAB's test-oracle design (A34) or the persona study's unique-finding metric (A31) would mean
  building an evaluation harness first, which is more work than either fill it exists to choose between.
- **Rests on:** (A15, A16, A31, A34)
- **Evidence status:** corroborated

### O5: Add a cost dimension to the existing static-structure analyst

- **What it is:** Give Han's structural analyst a sixth analysis dimension covering algorithmic cost and data-structure
  fit, with matching vocabulary and named anti-patterns. Scope its findings to observable patterns and forbid it from
  naming a complexity class.
- **Trade-offs:** It is the optimize-first step Han's own guidance asks for before adding an agent (A15). It adds no new
  roster slot, so it does not compete for a seat in an already-full band (A17). It reaches further than a new agent
  would, because this analyst runs in the architectural-analysis spine at every band rather than behind a signal (A40).
  It fixes the propagation gap that leaves the software architect with nothing to say (A8). Against it: the analyst's
  five existing dimensions are all about relationships between modules, so intra-function cost widens its altitude
  toward the generalist trap. And its code-review trigger skips single-file in-place edits (A40), which is where a
  quadratic loop is most likely to appear.
- **Rests on:** (A5, A8, A15, A17, A19, A40)
- **Evidence status:** corroborated

## Recommendation

- **Recommendation:** **O5.** Add a cost dimension to the existing static-structure analyst rather than building a new
  agent. Word it around patterns you can see in the code:

  - a loop nested inside another loop over the same collection
  - a linear scan where a keyed lookup fits
  - a value recomputed on every pass
  - a sort inside a loop

  Forbid the agent from stating a Big-O class as a finding, because that is the judgment the benchmarks measure it doing
  badly (A21, A22). Have it report a negative result when it finds nothing, the way the concurrency analyst already
  does.

  Two follow-ons belong with it:

  - Widen the code-review Performance checklist with the same pattern language, since that checklist is the only
    efficiency checkpoint that skill has (A9) and its structural-analyst dispatch skips single-file edits (A40).
  - Treat building a dedicated agent as deferred, with a concrete reopen trigger. Reopen it if a merged change carries
    an algorithmic or data-structure inefficiency that caused a felt problem, and a Han run over that change with the
    new dimension did not raise it. One documented case is enough to revisit, per the evidence rule's deferral pattern.

- **Evidence basis:** The gap is established on codebase evidence at file and line across fourteen artifacts (A1-A14).
  The evidence rule treats codebase evidence as the trusted current-state anchor, so it is not subject to the
  corroboration gate.

  Choosing O5 over O3 rests on two codebase anchors. Han's own authoring guidance sequences optimize-first before
  add-second, and nobody has tried the first step (A15). The structural analyst's dispatch footprint also reaches
  further than a signal-gated new agent would, because it sits in the architectural-analysis spine at every band (A40).

  The unavailability of the proposal's measurement step, which rules out O4, is also a codebase negative result (A16).

  The capability benchmarks (A21, A22) are corroborated web sources that clear the corroboration gate, and they shape
  the wording constraint rather than the build decision. They do not discriminate between O3 and O5, since both would
  face the same measured accuracy. My first draft treated them as decisive against building anything, which
  misrepresented the strictest of three reported columns as the standard one.

  What the recommendation does not rest on: any claim that broadening an existing surface reliably works. That is
  contested (A38 against A39) and undercut by instruction-load research (A35, A36, A37). O5 is recommended because it is
  the step Han's guidance asks for first and it reaches the most surfaces for the least new machinery, not because
  broadening is proven.

  The pattern-not-class constraint is an inference from what A21 and A22 measure. Both scored models on naming a
  complexity class; neither tested pattern recognition. Treating pattern spotting as the easier task is reasoning from
  the scope of the evidence rather than a measured finding. It is a design constraint, not a claim.

## Validation

An adversarial validation pass attacked the evidence, the options framing, the recommendation, and the integrity of the
evidence-gathering. It landed two hits that changed the recommendation and several that corrected the record.

### V1: The load-bearing capability numbers quoted the wrong column

- **Strategy:** Challenge the Evidence
- **Investigation:** Fetched BigO(Bench) and extracted its full results table. It reports three columns per task. The
  draft's "33-41%" and "10-14%" figures matched the strictest column while the text labeled them as the loosest.
- **Result:** Confirmed. I re-fetched the paper independently and confirmed both the mislabeling and the validator's own
  correction being off by one column. The loosest measure runs 40.4% to 70.1% on running-time complexity and 39.5% to
  68.8% on memory complexity.
- **Impact:** The capability argument no longer carries the recommendation. The Research Results section now reports all
  three columns, and the recommendation rests on Han's own guidance and dispatch reach instead.

### V2: The recommended fix targeted an agent whose charter forbids it

- **Strategy:** Challenge the Recommendation
- **Investigation:** The draft's O2 asked the software architect to flag complexity. That agent's charter states it
  "works from findings other agents produced, not its own discovery," a fact the draft's own A8 already established.
- **Result:** Confirmed.
- **Impact:** That pairing is removed. O2 is now the checklist change alone.

### V3: A better option was never evaluated

- **Strategy:** Challenge the Options Framing
- **Investigation:** The draft named the structural and behavioral analysts only as evidence the gap exists, never as
  candidate homes. The structural analyst is static-only by charter, already produces file-and-line findings, and is
  already dispatched across four skills.
- **Result:** Confirmed.
- **Impact:** Added as O5, verified against the dispatch points, and adopted as the recommendation.

### V4: The proposal's "6 to 8" claim was accurate when filed

- **Strategy:** Challenge the Evidence
- **Investigation:** Git history shows "Team cap: 6 to 8" in the file, replaced by commit `47ccdfeb` on 2026-07-30, two
  days after the issue was filed.
- **Result:** Partially refuted. The draft's statement of current file content was right; calling it a claim that "does
  not hold" was wrong.
- **Impact:** Reframed as a codebase change rather than an investigation error.

### V5: No measurement method exists, and the plans cited for it do not either

- **Strategy:** Challenge the Evidence
- **Investigation:** Independent repository-wide searches for the method returned only unrelated hits. The two prior
  plans the issue cites as its source have no directories under `docs/plans/`.
- **Result:** Confirmed and strengthened.
- **Impact:** O4 stays ruled out, on firmer ground.

### V6: The unusual arXiv identifiers are real

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Every cited identifier resolved to a live paper whose title matched the claimed topic. A
  deliberately fabricated control identifier returned a genuine 404.
- **Result:** Refuted (the suspicion was unfounded).
- **Impact:** None. Recorded so it is not re-litigated.

### V7: The 45% figure is not in the page the draft cited

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The cited public summary confirms the +80.9% and −70% figures but never states 45%. The underlying
  paper does, in its body.
- **Result:** Partially refuted. The number holds; the locator did not.
- **Impact:** The registry now cites the paper for the threshold and the summary separately for the coordination
  figures.

### V8: One source is unreachable at its cited link

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** The Mäntylä and Lassenius link returns a bot-check page, and the DOI resolves to an IEEE journal
  rather than the cited host. Author and title are correct; the specific figures could not be confirmed from the link.
- **Result:** Partially refuted.
- **Impact:** Marked as not read directly. It supports a secondary point, so discounting it does not move the
  recommendation.

### V9: The five-agent cap is weaker than the draft treated it

- **Strategy:** Challenge the Assumptions
- **Investigation:** The guidance labels the cap "a practical operating limit, not a platform rule," and
  architectural-analysis already runs six to nine agents by design.
- **Result:** Partially refuted.
- **Impact:** Roster strain is no longer an argument against O3. The recommendation rests on the guidance's
  optimize-first sequence and on dispatch reach instead.

### V10: The capability evidence does not separate the options

- **Strategy:** Challenge the Recommendation
- **Investigation:** If both a checklist item and an agent are scoped to pattern flagging, the benchmarks apply to
  neither differently.
- **Result:** Confirmed.
- **Impact:** The recommendation now says this outright, and the Summary no longer leans on capability as the reason to
  prefer one fill over another.

### V11: The signal table has seven rows, not six

- **Strategy:** Challenge the Evidence
- **Investigation:** The table includes an on-call resilience row the draft's A11 omitted.
- **Result:** Partially refuted. The substantive claim, that no complexity row exists, holds.
- **Impact:** A11 corrected.

### Adjustments Made

The recommendation changed from broadening the checklist to extending the existing structural analyst.

- Three of the draft's supports were removed or downgraded: the capability argument (V1, V10), the roster-strain
  argument (V9), and the software-architect fix location (V2).
- One new option was added and adopted (V3).
- Four citations were corrected (V4, V7, V8, V11), and two sources are now marked as not read directly.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** The recommendation now rests mainly on codebase anchors, which is firmer footing than the first
  draft had. Three risks still stand:

  - The optimize-first step is untested, so nobody knows whether a sixth dimension on an existing agent will produce
    findings rather than dilute the five it already has.
  - Widening that agent's altitude from between-module to inside-function is exactly the generalist trap Han's own
    guidance names, and no evidence here says where that line sits.
  - The evidence base is also a fast-moving snapshot. One cited cap changed two days after the issue was filed, and the
    roster shrank from 24 to 22 agents in the same window. Any count-based or cap-based argument here may be stale by
    the time you read it.

  Four web sources (A25, A26, A32 through A37) were not re-fetched and checked line by line against their numbers in the
  validation pass. Each supports a secondary point; none carries the recommendation.

## Sources

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
| --- | ------ | --------------- | --------- | ----------- | ------------------ | --------------- |
| A1 | No agent claims algorithmic-complexity review | `han-core/agents/*.md` | n/a | codebase | Search across every agent definition finds no Big-O, asymptotic-cost, or data-structure-fit charter | anchor (codebase) |
| A2 | data-engineer scope | `han-core/agents/data-engineer.md:3-10` | n/a | codebase | Scoped to schema, query, and pipeline concerns; disclaims resilience, infra, and concurrency | anchor (codebase) |
| A3 | on-call-engineer anti-pattern | `han-core/agents/on-call-engineer.md:158` | n/a | codebase | "Any in-memory queue or buffer with no size limit" keys on missing bounds, not asymptotic cost | anchor (codebase) |
| A4 | devops-engineer scope | `han-core/agents/devops-engineer.md:4-10` | n/a | codebase | Audits DORA, Twelve-Factor, Four Golden Signals; disclaims code-level correctness and schema design | anchor (codebase) |
| A5 | structural-analyst is static-only | `han-core/agents/structural-analyst.md:4-5,15-16` | n/a | codebase | "You analyze code as it is written, not how it behaves at runtime"; five dimensions, none is cost | anchor (codebase) |
| A6 | behavioral-analyst's four dimensions | `han-core/agents/behavioral-analyst.md:46-98` | n/a | codebase | Data flow, error propagation, state management, integration boundaries; none is cost | anchor (codebase) |
| A7 | concurrency-analyst's "algorithms" | `han-core/agents/concurrency-analyst.md:101` | n/a | codebase | "Lock-free algorithms" means compare-and-swap and memory ordering, not Big-O | anchor (codebase) |
| A8 | software-architect synthesizes only | `han-core/agents/software-architect.md:8-9,21` | n/a | codebase | "Works from findings other agents produced, not its own discovery" | anchor (codebase) |
| A9 | code-review Performance checklist | `han-coding/skills/code-review/references/review-checklist.md:52-58` | n/a | codebase | Five lines: N+1, frontend re-renders, pagination, indexes, over-fetching | anchor (codebase) |
| A10 | code-review dispatch roster | `han-coding/skills/code-review/references/agent-dispatch.md:9-26` | n/a | codebase | Ten named agents, no complexity specialist | anchor (codebase) |
| A11 | architectural-analysis signal table | `han-coding/skills/architectural-analysis/SKILL.md:144-153` | n/a | codebase | Seven signal rows (concurrency, security, data, devops, on-call, unfamiliar-area, system-seam); no complexity row | anchor (codebase) |
| A12 | plan-implementation specialist menu | `han-planning/skills/plan-implementation/references/team-selection.md:38-59` | n/a | codebase | Thirteen specialists listed; none for efficiency or complexity | anchor (codebase) |
| A13 | plan-a-feature defers mechanics | `han-planning/skills/plan-a-feature/references/mechanic-routing.md:18-19` | n/a | codebase | Pure implementation questions are routed to plan-implementation by rule | anchor (codebase) |
| A14 | investigate's conditional specialists | `han-coding/skills/investigate/SKILL.md:54-85` | n/a | codebase | Three conditional specialists (concurrency, behavioral, data); none for complexity | anchor (codebase) |
| A15 | The 45% threshold and team cap | `han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md:74-88` | n/a | codebase | Optimize an existing agent first, add second; cap of "about 5 agents" labeled a practical operating limit, not a platform rule | anchor (codebase); corroborated by A28 |
| A16 | No A/B unique-survivor-yield method exists | repository-wide search; `docs/plans/` | n/a | codebase | Neither the method nor the two plans the issue cites as its source exist anywhere in the repo | anchor (codebase, negative result) |
| A17 | architectural-analysis band caps | `han-coding/skills/architectural-analysis/SKILL.md:155-163` | n/a | codebase | Small 3-4, medium 4-6, large 6-9 agents; the large band exceeds the ~5 heuristic by design | anchor (codebase) |
| A18 | plan-implementation team cap changed after filing | `han-planning/skills/plan-implementation/references/team-selection.md:13-18`; commit `47ccdfeb` | n/a | codebase | "6 to 8" was replaced by 3-4 specialists on a team of 5-6 on 2026-07-30, two days after the issue was filed | anchor (codebase) |
| A19 | Discovery agent size | `han-core/agents/{structural,behavioral,concurrency}-analyst.md` | n/a | codebase | 128, 137, and 144 lines respectively | anchor (codebase) |
| A20 | Issue #153 and its investigation | https://github.com/testdouble/han/issues/153 | 2026-08-10 | provided | The proposal, its E1-E17 evidence, V1-V7 validation, and staged recommendation | corroborated by A1-A14 on the gap; superseded by A18 on one number |
| A21 | BigO(Bench) (Meta/FAIR, 2025) | https://arxiv.org/abs/2503.15242 | 2026-08-10 | web | Complexity prediction across three accuracy columns; loosest 40.4-70.1% time and 39.5-68.8% space, strictest 33.1-41.4% and 8.1-14.0% | corroborated by A22 |
| A22 | CodeComplex (2024/2025) | https://arxiv.org/abs/2401.08719 | 2026-08-10 | web | 9,800 labeled programs; models confuse adjacent complexity classes rather than erring randomly | corroborated by A21 |
| A23 | Google reviewer guidance | https://google.github.io/eng-practices/review/reviewer/looking-for.html | 2026-08-10 | web | Twelve named concerns; "Complexity" means readability, and no item names asymptotic cost | corroborated by A24 |
| A24 | Mäntylä & Lassenius (2009) | https://dl.acm.org/doi/10.1109/TSE.2008.71 | 2026-08-10 | web | Defects across 32 review sessions; 75% concern maintainability, not behavior | single source (caveated); link unreachable, not read directly |
| A25 | Jin et al., PLDI 2012 | https://pages.cs.wisc.edu/~shanlu/paper/pldi118-jin.pdf | 2026-08-10 | web | Rules from 25 known bugs surfaced 332 unknown performance problems in reviewed code | single source (caveated); not read directly |
| A26 | pymwp complexity bounds | https://arxiv.org/pdf/2107.00097 | 2026-08-10 | web | Sound worst-case bounds, but only for a restricted subset of C | single source (caveated) |
| A27 | Cyclomatic complexity | https://en.wikipedia.org/wiki/Cyclomatic_complexity | 2026-08-10 | web | Counts independent control-flow paths, a different quantity from asymptotic growth | single source (definitional) |
| A28 | Towards a Science of Scaling Agent Systems | https://arxiv.org/abs/2512.08296 | 2026-08-10 | web | "Tasks where single-agent performance already exceeds 45% accuracy experience negative returns from additional agents" | corroborates A15 |
| A28b | Google Research summary of A28 | https://research.google/blog/towards-a-science-of-scaling-agent-systems-when-and-why-agent-systems-work/ | 2026-08-10 | web | +80.9% on parallelizable tasks, −39% to −70% on sequential; states diminishing returns without the 45% figure | corroborates A28 |
| A29 | Personas do not improve LLM performance | https://arxiv.org/abs/2311.10054 | 2026-08-10 | web | 162 personas, 2,410 questions, 4 model families: no benefit or small penalty | corroborated by A30 |
| A30 | When persona prompting helps | https://arxiv.org/html/2605.29420v1 | 2026-08-10 | web | 1,140 questions, 38 roles: raises expertise depth, lowers clarity; helps advisory domains | corroborated by A29 |
| A31 | Dispositions in AI code review | https://arxiv.org/abs/2605.23108 | 2026-08-10 | web | 50 merged PRs: 51% of specialist findings absent from the generic baseline; no independent rater | single source (caveated) |
| A32 | MARG multi-agent paper review | https://arxiv.org/abs/2401.04259 | 2026-08-10 | web | Generic comments fell from over 50% to 29%; useful comments per paper rose 1.7 to 3.7 | single source (caveated) |
| A33 | Specialists or generalists (essay grading) | https://arxiv.org/html/2601.22386v1 | 2026-08-10 | web | 450 essays: specialists beat a generalist by ~2.9 agreement points at 4x compute | single source (caveated) |
| A34 | c-CRAB code review benchmark | https://arxiv.org/html/2603.23448v1 | 2026-08-10 | web | 184 PRs, 234 tests; four tools passed only 41.5% as a union, so findings are complementary | single source (caveated) |
| A35 | Instruction stacking collapse | https://arxiv.org/html/2608.02639 | 2026-08-10 | web | Compliance degrades as up to 24 verifier-checked instructions accumulate in one prompt | corroborated by A36, A37 |
| A36 | IFScale instruction density | https://arxiv.org/pdf/2507.11538 | 2026-08-10 | web | Performance cliffs appear at high instruction density that low-count tests do not reveal | corroborated by A35 |
| A37 | Lost in the Middle | https://arxiv.org/abs/2307.03172 | 2026-08-10 | web | Mid-prompt information is used over 30% less reliably; replicated across six model families | corroborated by A35, A36 |
| A38 | Explicit review strategies and cognitive load | https://link.springer.com/article/10.1007/s10664-022-10123-8 | 2026-08-10 | web | Professional developers: checklists help, guided checklists help more | contradicted by A39; not read directly (paywall) |
| A39 | Checklist vs ad hoc code reading | https://arxiv.org/abs/0909.4260 | 2026-08-10 | web | 20 students: no significant difference in defect detection, time, or false positives | contradicts A38 |
| A40 | structural-analyst dispatch footprint | `han-coding/skills/architectural-analysis/SKILL.md:131-137`; `han-coding/skills/code-review/references/agent-dispatch.md:21`; `han-planning/skills/plan-implementation/references/team-selection.md:47`; `han-planning/skills/iterative-plan-review/references/team-selection.md:39`; `han-coding/skills/design-an-api/SKILL.md:172` | n/a | codebase | Always-on spine in architectural-analysis at every band; conditional in code-review (skipping single-file in-place edits); menu option in plan-implementation and iterative-plan-review; signal-selected in design-an-api | anchor (codebase) |

### A21: BigO(Bench) (Meta/FAIR, 2025) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2503.15242 (results table read from https://arxiv.org/html/2503.15242v2)
- **Retrieved:** 2026-08-10
- **Trust class:** web (outside the trust boundary)
- **Summary:** A benchmark of 3,105 coding-contest problems and roughly 1.19 million solutions, carrying inferred time
  and space complexity labels. It tests twelve models on three tasks: predicting the complexity of existing code,
  generating code to a target complexity, and ranking solutions by efficiency. The prediction task matches a review use
  case. The paper reports three accuracy columns: Pass@1 ("accuracy of finding the correct complexity"), Best@1
  ("accuracy only across the most optimized complexity class of each problem"), and All@1 ("requires correct complexity
  output across all complexity classes at once per problem"). For time complexity the reported values are GPT-4o 51.0 /
  57.7 / 33.1,
  o1-mini 62.5 / 58.3 / 35.6, DeepSeek-R1 Llama 70B 70.1 / 64.2 / 41.4, and Llama 3.1 405B 40.4 / 60.9 / 38.3. For space
  complexity they are GPT-4o 51.6 / 43.4 / 11.0, o1-mini 58.0 / 42.7 / 8.1, DeepSeek-R1 Llama 70B 68.8 / 44.4 / 10.4,
  and Llama 3.1 405B 39.5 / 44.8 / 14.0. The paper states that reasoning models, "though they largely outperform other
  LLMs on pure program synthesis," are "much closer in terms of performance on complexity-related tasks, and even
  outperformed by Llama 3.1 405B on space complexity prediction."
- **Evidence status:** corroborated by A22

### A22: CodeComplex (2024/2025) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2401.08719
- **Retrieved:** 2026-08-10
- **Trust class:** web (outside the trust boundary)
- **Summary:** A dataset of 4,900 Java and 4,900 Python programs labeled with worst-case time complexity across seven
  classes, built to test model reasoning about complexity where earlier benchmarks under-specified input assumptions.
  Its reported failure mode is that models confuse hierarchically adjacent classes, mistaking O(n log n) for O(n) or
  O(n²). The errors cluster near the correct answer rather than scattering, so a model often gets the general shape
  right and the specific class wrong.
- **Evidence status:** corroborated by A21

### A15: The optimize-first rule and the team cap — recommendation-bearing

- **Link / location:**
  `han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md:74-88`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Han's authoring guidance instructs that before adding another agent you ask whether the current
  architecture already reaches more than 45% of optimal quality on the dimension you want to improve. If it does,
  improve the existing agent's instructions, vocabulary, or tool access first; adding an agent is justified only when a
  single agent has been optimized and still falls short. The same file caps a concurrently dispatched team at about five
  agents and explicitly calls that cap "a practical operating limit, not a platform rule." It attributes the 45% figure
  to Google Research, Google DeepMind, and MIT's 2025 scaling work.
- **Evidence status:** anchor (codebase); corroborated by A28

### A40: structural-analyst dispatch footprint — recommendation-bearing

- **Link / location:** `han-coding/skills/architectural-analysis/SKILL.md:131-137`;
  `han-coding/skills/code-review/references/agent-dispatch.md:21`;
  `han-planning/skills/plan-implementation/references/team-selection.md:47`;
  `han-planning/skills/iterative-plan-review/references/team-selection.md:39`;
  `han-coding/skills/design-an-api/SKILL.md:172`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The structural analyst sits in the architectural-analysis synthesis spine, described there as "dispatched
  at every size," rather than behind a signal gate. In code-review it is a conditional reviewer, added when "the change
  introduces new files, new modules, or modifies dependency direction across modules," and explicitly skipped for
  single-file in-place edits. It is a menu option in plan-implementation and in iterative-plan-review, and it is
  signal-selected in design-an-api on a consumer-spread signal. That footprint reaches four skills without any new
  roster slot.
- **Evidence status:** anchor (codebase)

### A16: No measurement method exists for the proposal's gate — recommendation-bearing

- **Link / location:** repository-wide search of `/Users/riverbailey/dev/testdouble/han`; `docs/plans/`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The issue's Stage 0 ends by running "the project's existing A/B unique-survivor-yield method" over real
  changes. Searches across every markdown file in the repository for that method, and for the terms it would use, find
  nothing. The two prior plans the issue cites as the method's source have no directories under `docs/plans/` either.
  The staged plan therefore cannot execute its own gate without first building an evaluation harness.
- **Evidence status:** anchor (codebase, negative result)

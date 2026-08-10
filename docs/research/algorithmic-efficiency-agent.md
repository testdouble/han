# Research: Should Han add a design-time algorithmic-efficiency specialist?

Issue [#153](https://github.com/testdouble/han/issues/153) proposes that Han's agent roster has no owner for design-time
algorithmic and computational-complexity review, and recommends a staged fill. This report researches whether Han should
add that agent. Evidence mode: **strict** (every claim carries a checkable source; single-source web claims are marked
and cannot stand alone as the basis for the recommendation).

## Summary

The gap the issue reports is real. Nothing in Han today reviews whether a piece of code picked the right algorithm or
the right data structure, and I verified that against every agent definition and every skill that could dispatch one.

But building a specialist agent for it is the wrong next move, because the judgment that agent would exist to make is
one language models are measured to get wrong more often than right. Two independent benchmarks tested exactly this
task, asking a model to name the complexity class of code it did not write, and the strongest models scored between a
third and two-fifths correct on running-time cost and worse on memory. The errors are near-misses that read as
confident and plausible, which is the worst shape for a review comment.

So the recommendation is the cheap fill: add algorithmic items to the code-review checklist that already exists, add
complexity vocabulary to the architect agent, and hold the dedicated agent until there is a reason to build it. Word
those additions around patterns a reader can see in the code, not around naming a complexity class, because pattern
spotting is not the thing the benchmarks found models bad at.

One practical thing to know about the issue's own plan: its first stage ends in a measurement step that this repository
cannot run. The A/B method it names does not exist here, and building one is a larger project than the agent it was
meant to gate.

- **Confidence:** Medium

## Research Results

### The gap is real, and it survives a direct check against every agent

No agent in Han's roster owns algorithmic-complexity review of application logic (A1). I checked every agent
definition. Where the words "algorithm" or "complexity" appear, they mean something else: `concurrency-analyst` uses
"lock-free algorithms" to mean synchronization primitives (A7), `structural-analyst` uses "complexity" to mean code
organization and coupling (A5), and `behavioral-analyst` mentions memoization only as a kind of state cache (A6).

The three agents that come closest each own a genuinely different concern:

- `data-engineer` fires at the boundary between code and the database, on in-memory work that a query should have done
  (A2). A pure in-memory quadratic loop with no database involved gives it nothing to grip.
- `on-call-engineer` keys on the absence of a size limit. Its anti-pattern is "any in-memory queue or buffer with no
  size limit" (A3). A triple-nested loop over a capped thousand-item list never trips it.
- `devops-engineer` audits delivery and operations against DORA metrics, the Twelve-Factor App, and the Four Golden
  Signals (A4). None of that is per-function algorithm choice.

`software-architect` synthesizes what upstream discovery agents produce and does no discovery of its own (A8). Because
none of its upstream agents produces a complexity finding, the gap propagates: even when dispatched, it has nothing to
recommend on this axis.

The skills that could dispatch such an agent have no hook for it either. The `code-review` skill's entire efficiency
checkpoint is a five-line Performance section shaped around databases and frontends (A9), and its dispatch roster
contains no complexity specialist (A10). The `architectural-analysis` signal-to-specialist table has no complexity row
(A11). The `plan-implementation` specialist menu lists thirteen specialists and no efficiency one (A12).
`plan-a-feature` routes implementation mechanics downstream on purpose (A13), and `investigate` dispatches three
conditional specialists, none for complexity (A14).

### Where the issue's line citations have drifted, and one claim that does not hold

The issue was filed on 2026-07-28 and its file references have gone stale as content moved between files. Its
substantive claims survive; the pointers do not. The `code-review` Performance checklist now sits at
`review-checklist.md:52-58` rather than the cited `:35-40`, the `architectural-analysis` signal table at `SKILL.md:145-153`
rather than `:65-84`, and the `plan-implementation` specialist menu has moved out of `SKILL.md` into
`references/team-selection.md:38-59`.

One substantive claim does not hold. The issue's validation finding V6 states that both proposed homes already exceed
the roughly five-agent soft cap, citing `plan-implementation` as capping its team at "6 to 8." The current file caps the
large band at three to four chosen specialists, a team of five to six (A18). Only `architectural-analysis` reaches
six to nine in its large band (A17). So the roster-economics objection applies to one home, not both.

### Language models are measured to be unreliable at exactly this judgment

This is the finding that changes the decision, and the issue's investigation did not have it.

Two independent benchmarks were built to test whether a model can name the complexity of code it did not write.
BigO(Bench), from Meta's research group, ran twelve models over 3,105 coding-contest problems: on running-time
complexity prediction the strongest models (GPT-4o, o1-mini, DeepSeek-R1-Llama-70B, Llama-3.1-405B) landed between
roughly 33% and 41% correct, and on memory-complexity prediction between roughly 10% and 14% (A21). Reasoning models
held only a slim edge over non-reasoning ones, about 3 percentage points, which the authors read as evidence that being
good at writing code does not transfer to reasoning about its cost (A21).

CodeComplex, a separate benchmark of 4,900 Java and 4,900 Python programs labeled across seven complexity classes,
corroborates the unreliability and adds the failure shape: models confuse neighboring classes, calling an O(n log n)
routine linear or quadratic (A22). The errors cluster near the right answer instead of scattering randomly.

That failure shape matters more than the raw accuracy number. A near-miss produces a review comment that sounds right,
names a specific complexity class, and is wrong. A reader has no cheap way to tell it from a correct one.

Sound automated complexity analysis does exist, but only inside restricted settings. The pymwp tool computes guaranteed
worst-case bounds for a constrained subset of C using type-system and abstract-interpretation techniques (A26,
[single-source]). Nothing comparable was found for general application code in general-purpose languages. And the
"complexity" that mainstream tooling measures cheaply is cyclomatic complexity, a count of independent paths through the
control-flow graph, which is a different quantity from asymptotic growth (A27). A flat loop and a nested loop can carry
the same cyclomatic score and different costs.

### Human review does not name this concern either, and real defects slip through

Google's public reviewer guidance enumerates twelve concerns, and its "Complexity" item is explicitly about code a
reader cannot understand quickly, not about running-time cost (A23). Nothing in it names algorithmic complexity,
Big-O, or data-structure fit. The most detailed defect taxonomy located, Mäntylä and Lassenius's classification of 759
defects across 32 review sessions, found that 75% of what reviewers flag concerns maintainability rather than behavior
(A24); the performance-shaped categories sit inside the smaller remainder.

Meanwhile the defects are demonstrably there. Jin and colleagues studied 110 real performance bugs across Apache,
Chrome, GCC, Mozilla, and MySQL, derived efficiency rules from 25 of them, and used those rules to surface 332
previously unknown performance problems in the then-current versions of MySQL, Apache, and Mozilla (A25). Those
inefficiencies had passed through mature review processes undetected.

I found no source that names algorithmic complexity as its own review category, distinct from general code complexity on
one side and runtime profiling on the other. The three-way split the issue draws is a useful analytic distinction, but
it is not established terminology in the review-practice literature I could reach.

### Specialist agents produce non-overlapping findings, but the studies do not test this comparison

The evidence on whether a dedicated specialist beats a broadened generalist is split, and the split tracks task type.

Broad persona injection does not reliably help. A study of 162 personas over 2,410 factual questions across four model
families found no benefit or a small penalty, and found that automated persona selection did no better than picking at
random (A29). A follow-up over 1,140 questions and 38 roles found the effect depends on domain: persona framing raised
expertise depth and lowered clarity, helping in advisory domains and hurting in explanatory ones (A30).

The findings that favor specialization come from adjacent domains. Splitting scientific-paper review across
dimension-specific agents cut generic comments from over half to 29% and roughly doubled useful comments per paper
(A32, [single-source]). The one study that tested persona specialization on code review directly reported that 51% of
specialist findings were entirely absent from a generic reviewer's output on the same model, over 50 merged pull
requests (A31), though its authors flag that no independent rater checked the findings and cross-model validation
covered three pull requests. The c-CRAB benchmark converted human review comments into executable tests and found that
four automated review tools together passed only 41.5% of them, meaning their findings were largely complementary rather
than duplicated (A34, [single-source]).

Against that, essay grading with three specialists plus an arbiter beat a single generalist by about 2.9 points of
agreement at four times the compute, with the advantage concentrated at the weakest essays (A33, [single-source]).

No study located compares the exact pair this decision needs: a generalist with a broadened checklist against a
generalist plus one specialist, on the same task and the same scoring harness.

### The 45% rule is real, corroborated outside the repo, and points toward adding

Han's own authoring guidance states the rule: if the current setup already reaches more than 45% of optimal quality on
the dimension you want to improve, optimize the existing agent first; adding an agent is justified only after a single
agent has been optimized and still falls short (A15). It caps a concurrently dispatched team at roughly five.

The guidance cites Google Research's scaling work, and that source checks out independently. Coordination gains were
large on parallelizable tasks (+80.9% on a financial-reasoning benchmark) and sharply negative on sequential ones (−39%
to −70% on planning), with diminishing returns appearing once a single-agent baseline already cleared roughly 45% (A28).

On the coverage dimension Han is currently at zero, so the 45% gate does not block adding an agent. That reading points
toward the issue's conclusion. It is the capability measurement (A21, A22) that pulls the other way.

### Adding items to a long prompt is not free either

The cheap fill has its own evidence problem, and it should be stated rather than assumed away. Instruction compliance
degrades as constraints accumulate in one prompt, measured across three production-tier models over as many as 24
verifier-checked instructions (A35), with performance cliffs invisible at low instruction counts (A36). Information
placed mid-prompt is used more than 30% less reliably than information near the start or end, replicated across six
model families (A37).

For human reviewers the checklist evidence is contested outright. A controlled study with professional developers found
checklists helpful but beaten by a more structured variant (A38, [single-source]), while a separate controlled study with
twenty students found no significant difference between checklist and ad hoc review on defect detection, time, or false
positives (A39, [single-source]).

Two things bound how much this weighs against the cheap fill here. The `code-review` Performance section is five lines
in a separate reference file, not a constraint buried in a 24-item prompt (A9), and the instruction-load studies test a
different regime. But the direction is real, and "just add it to the checklist" is not a guaranteed fix.

### The issue's own gating plan cannot run in this repository

The issue's Stage 0 ends in a measurement: run "the project's existing A/B unique-survivor-yield method" over real
changes and see whether the broadened checklist misses complexity findings. That method does not exist here. A search
across the repository for it returns nothing (A16). Building an evaluation harness of that kind is a larger project than
the agent it was meant to gate.

Two published methodologies could be adapted if someone wanted to build one. c-CRAB converts human review comments into
executable tests and reports both a per-reviewer pass rate and union coverage across reviewers (A34). The code-review
persona study reports the share of a treatment's findings absent from the control's output on the same input, alongside
a tracked false-positive rate (A31). Neither is described as blinded or multiply rated.

## Options to Consider

### O1: Close the issue and change nothing

- **What it is:** Accept that the gap is structural rather than felt, and leave the roster and the checklists alone.
- **Trade-offs:** Costs nothing and adds no noise. But it leaves a verified hole, and there is direct evidence that
  efficiency defects survive mature review processes (A25). It also discards a cheap, reversible option without trying
  it.
- **Rests on:** (A1, A24, A25)
- **Evidence status:** corroborated

### O2: Broaden the existing surfaces and defer the agent

- **What it is:** Add algorithmic and data-structure items to the `code-review` Performance checklist, and add
  complexity vocabulary plus a flag instruction to `software-architect`'s charter. Word both around observable code
  patterns rather than around naming a complexity class. Record the dedicated agent as deferred with a concrete reopen
  trigger.
- **Trade-offs:** Small, reversible, and it touches two files. It does not create a new competitor for a slot in
  `architectural-analysis`'s already-strained large band (A17). Against it: checklist efficacy is contested for humans
  (A38, A39), and instruction-load research says added items do not reliably fire (A35, A36, A37). The five-line
  Performance section is a much lighter prompt than the regimes those studies tested (A9), which bounds but does not
  erase the concern.
- **Rests on:** (A9, A15, A17, A21, A22, A35, A36, A37, A38, A39)
- **Evidence status:** corroborated

### O3: Build the dedicated algorithmic-efficiency agent now and wire it in

- **What it is:** The issue's Stages 1 and 2. Build a discovery agent in the `structural`/`behavioral`/`concurrency`
  mold, roughly 130 to 145 lines (A19), scoped to asymptotic cost, data-structure fit, and memoization, then wire it
  conditionally into `plan-implementation` and `architectural-analysis`, and later `code-review` and `investigate`.
- **Trade-offs:** It is the only option that gives the concern an owner with its own vocabulary, and specialization does
  produce findings a generically prompted reviewer misses (A31, A32, A34). The 45% gate does not block it, since
  coverage today is zero (A15). Against it: the agent's core judgment is measured unreliable, at 33-41% on running-time
  complexity and 10-14% on memory, with errors that look like confident near-misses (A21, A22). It adds a competitor for
  a slot in a band already running six to nine agents (A17). And no study tests specialization against the
  broadened-checklist alternative on the same harness.
- **Rests on:** (A15, A17, A19, A21, A22, A31, A32, A34)
- **Evidence status:** corroborated

### O4: Run the issue's staged plan as written

- **What it is:** Do Stage 0, measure with the A/B unique-survivor-yield method, and build the agent only if the
  measurement shows a real miss.
- **Trade-offs:** The most rigorous shape on paper, and it is what the 45% rule asks for. But the method it depends on
  does not exist in this repository (A16), so the plan stalls at its own gate. Adapting c-CRAB's test-oracle design
  (A34) or the persona study's unique-finding metric (A31) would mean building an evaluation harness first, which is
  more work than either fill it exists to choose between.
- **Rests on:** (A15, A16, A31, A34)
- **Evidence status:** corroborated

## Recommendation

- **Recommendation:** **O2.** Broaden the two existing surfaces and defer the dedicated agent behind a concrete reopen
  trigger. Word the additions around observable patterns rather than around naming a complexity class: a loop nested
  inside another loop over the same collection, a linear scan where a keyed lookup fits, the same value recomputed on
  every pass, a sort inside a loop. Do not ask any agent to state a Big-O class as a finding.

  The reopen trigger for building the agent is a real miss you can point to: a merged change where an algorithmic or
  data-structure inefficiency caused a felt problem and a Han review of that change did not raise it. One documented
  case is enough to justify revisiting, per the evidence rule's deferral pattern.

- **Evidence basis:** The gap is established on codebase evidence at file and line across fourteen artifacts (A1-A14),
  which the evidence rule treats as the trusted current-state anchor and does not subject to the corroboration gate. The
  case against building the agent now rests on two independent, purpose-built benchmarks that agree with each other
  (A21, A22), which clears the corroboration gate. The roster-economics constraint rests on Han's own guidance (A15)
  corroborated by the outside study it cites (A28). The unavailability of the issue's measurement step is a codebase
  negative result (A16).

  What the recommendation does not rest on: the claim that a broadened checklist will work. That is contested (A38
  against A39) and undercut by instruction-load research (A35, A36, A37). O2 is recommended because it is cheap and
  reversible while the expensive option is measured unreliable, not because the checklist route is proven.

  The wording constraint (patterns, not complexity classes) is an inference from what A21 and A22 measure. Both scored
  models on naming a complexity class. Neither tested pattern recognition, so treating that as the easier task is
  reasoning from the scope of the evidence rather than a measured finding. It is a design constraint, not a claim.

## Validation

<!-- Populated after the adversarial-validator pass. -->

## Sources

| ID  | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
| --- | ------ | --------------- | --------- | ----------- | ------------------ | --------------- |
| A1 | No agent claims algorithmic-complexity review | `han-core/agents/*.md` | n/a | codebase | Search across every agent definition finds no Big-O, asymptotic-cost, or data-structure-fit charter | anchor (codebase) |
| A2 | data-engineer scope | `han-core/agents/data-engineer.md:3-10` | n/a | codebase | Scoped to schema, query, and pipeline concerns; disclaims resilience, infra, and concurrency | anchor (codebase) |
| A3 | on-call-engineer anti-pattern | `han-core/agents/on-call-engineer.md:158` | n/a | codebase | "Any in-memory queue or buffer with no size limit" keys on missing bounds, not asymptotic cost | anchor (codebase) |
| A4 | devops-engineer scope | `han-core/agents/devops-engineer.md:4-10` | n/a | codebase | Audits DORA, Twelve-Factor, Four Golden Signals; disclaims code-level correctness and schema design | anchor (codebase) |
| A5 | structural-analyst is static-only | `han-core/agents/structural-analyst.md:4-5` | n/a | codebase | "Does not trace runtime behavior or data flow"; no complexity axis among its dimensions | anchor (codebase) |
| A6 | behavioral-analyst's four dimensions | `han-core/agents/behavioral-analyst.md:46-98` | n/a | codebase | Data flow, error propagation, state management, integration boundaries; none is cost | anchor (codebase) |
| A7 | concurrency-analyst's "algorithms" | `han-core/agents/concurrency-analyst.md:101` | n/a | codebase | "Lock-free algorithms" means compare-and-swap and memory ordering, not Big-O | anchor (codebase) |
| A8 | software-architect synthesizes only | `han-core/agents/software-architect.md:4-11` | n/a | codebase | "Works from findings other agents produced, not its own discovery" | anchor (codebase) |
| A9 | code-review Performance checklist | `han-coding/skills/code-review/references/review-checklist.md:52-58` | n/a | codebase | Five lines: N+1, frontend re-renders, pagination, indexes, over-fetching | anchor (codebase) |
| A10 | code-review dispatch roster | `han-coding/skills/code-review/references/agent-dispatch.md:9-26` | n/a | codebase | Ten named agents, no complexity specialist | anchor (codebase) |
| A11 | architectural-analysis signal table | `han-coding/skills/architectural-analysis/SKILL.md:145-153` | n/a | codebase | Six signal rows (concurrency, security, data, devops, system-seam, unfamiliar-area); no complexity row | anchor (codebase) |
| A12 | plan-implementation specialist menu | `han-planning/skills/plan-implementation/references/team-selection.md:38-59` | n/a | codebase | Thirteen specialists listed; none for efficiency or complexity | anchor (codebase) |
| A13 | plan-a-feature defers mechanics | `han-planning/skills/plan-a-feature/references/mechanic-routing.md:18-19` | n/a | codebase | Pure implementation questions are routed to plan-implementation by rule | anchor (codebase) |
| A14 | investigate's conditional specialists | `han-coding/skills/investigate/SKILL.md:54-85` | n/a | codebase | Three conditional specialists (concurrency, behavioral, data); none for complexity | anchor (codebase) |
| A15 | The 45% threshold and team cap | `han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md:80-88` | n/a | codebase | Optimize an existing agent first above 45%; team cap of roughly five | anchor (codebase); corroborated by A28 |
| A16 | No A/B unique-survivor-yield method exists | repository-wide search | n/a | codebase | The measurement the issue's Stage 0 depends on is not present anywhere in the repo | anchor (codebase, negative result) |
| A17 | architectural-analysis band caps | `han-coding/skills/architectural-analysis/SKILL.md:155-163` | n/a | codebase | Small 3-4, medium 4-6, large 6-9 agents | anchor (codebase) |
| A18 | plan-implementation band caps | `han-planning/skills/plan-implementation/references/team-selection.md:13-18` | n/a | codebase | Large band is 3-4 chosen specialists, team of 5-6; refutes the issue's "6 to 8" | anchor (codebase); contradicts A20 |
| A19 | Discovery agent size | `han-core/agents/{structural,behavioral,concurrency}-analyst.md` | n/a | codebase | 128, 137, and 144 lines respectively | anchor (codebase) |
| A20 | Issue #153 and its investigation | https://github.com/testdouble/han/issues/153 | 2026-08-10 | provided | The proposal, its E1-E17 evidence, V1-V7 validation, and staged recommendation | contradicted by A18 on one claim; corroborated by A1-A14 on the gap |
| A21 | BigO(Bench) (Meta/FAIR, 2025) | https://arxiv.org/abs/2503.15242 | 2026-08-10 | web | 12 models over 3,105 problems: 33-41% on time-complexity prediction, 10-14% on space | corroborated by A22 |
| A22 | CodeComplex (2024/2025) | https://arxiv.org/abs/2401.08719 | 2026-08-10 | web | 9,800 labeled programs; models confuse adjacent complexity classes rather than erring randomly | corroborated by A21 |
| A23 | Google reviewer guidance | https://google.github.io/eng-practices/review/reviewer/looking-for.html | 2026-08-10 | web | Twelve named concerns; "Complexity" means readability, and no item names asymptotic cost | corroborated by A24 |
| A24 | Mäntylä & Lassenius (2009) | https://dl.acm.org/doi/10.1109/TSE.2008.71 | 2026-08-10 | web | 759 defects over 32 review sessions; 75% concern maintainability, not behavior | corroborated by A23 |
| A25 | Jin et al., PLDI 2012 | https://pages.cs.wisc.edu/~shanlu/paper/pldi118-jin.pdf | 2026-08-10 | web | Rules from 25 known bugs surfaced 332 unknown performance problems in reviewed code | single source (caveated) |
| A26 | pymwp complexity bounds | https://arxiv.org/pdf/2107.00097 | 2026-08-10 | web | Sound worst-case bounds, but only for a restricted subset of C | single source (caveated) |
| A27 | Cyclomatic complexity | https://en.wikipedia.org/wiki/Cyclomatic_complexity | 2026-08-10 | web | Counts independent control-flow paths, a different quantity from asymptotic growth | single source (definitional) |
| A28 | Google Research, scaling agent systems | https://research.google/blog/towards-a-science-of-scaling-agent-systems-when-and-why-agent-systems-work/ | 2026-08-10 | web | +80.9% on parallelizable tasks, −39% to −70% on sequential; diminishing returns above ~45% | corroborates A15 |
| A29 | Personas do not improve LLM performance | https://arxiv.org/abs/2311.10054 | 2026-08-10 | web | 162 personas, 2,410 questions, 4 model families: no benefit or small penalty | corroborated by A30 |
| A30 | When persona prompting helps | https://arxiv.org/html/2605.29420v1 | 2026-08-10 | web | 1,140 questions, 38 roles: raises expertise depth, lowers clarity; helps advisory domains | corroborated by A29 |
| A31 | Dispositions in AI code review | https://arxiv.org/abs/2605.23108 | 2026-08-10 | web | 50 merged PRs: 51% of specialist findings absent from the generic baseline; no independent rater | single source (caveated) |
| A32 | MARG multi-agent paper review | https://arxiv.org/abs/2401.04259 | 2026-08-10 | web | Generic comments fell from over 50% to 29%; useful comments per paper rose 1.7 to 3.7 | single source (caveated) |
| A33 | Specialists or generalists (essay grading) | https://arxiv.org/html/2601.22386v1 | 2026-08-10 | web | 450 essays: specialists beat a generalist by ~2.9 agreement points at 4x compute | single source (caveated) |
| A34 | c-CRAB code review benchmark | https://arxiv.org/html/2603.23448v1 | 2026-08-10 | web | 184 PRs, 234 tests; four tools passed only 41.5% as a union, so findings are complementary | single source (caveated) |
| A35 | Instruction stacking collapse | https://arxiv.org/html/2608.02639 | 2026-08-10 | web | Compliance degrades as up to 24 verifier-checked instructions accumulate in one prompt | corroborated by A36, A37 |
| A36 | IFScale instruction density | https://arxiv.org/pdf/2507.11538 | 2026-08-10 | web | Performance cliffs appear at high instruction density that low-count tests do not reveal | corroborated by A35 |
| A37 | Lost in the Middle | https://arxiv.org/abs/2307.03172 | 2026-08-10 | web | Mid-prompt information is used over 30% less reliably; replicated across six model families | corroborated by A35, A36 |
| A38 | Explicit review strategies and cognitive load | https://link.springer.com/article/10.1007/s10664-022-10123-8 | 2026-08-10 | web | Professional developers: checklists help, guided checklists help more | contradicted by A39 |
| A39 | Checklist vs ad hoc code reading | https://arxiv.org/abs/0909.4260 | 2026-08-10 | web | 20 students: no significant difference in defect detection, time, or false positives | contradicts A38 |

### A21: BigO(Bench) (Meta/FAIR, 2025) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2503.15242
- **Retrieved:** 2026-08-10
- **Trust class:** web (outside the trust boundary)
- **Summary:** A benchmark of 3,105 coding-contest problems and roughly 1.19 million solutions carrying inferred time
  and space complexity labels, used to test twelve major models on three tasks: predicting the complexity of existing
  code, generating code to a target complexity, and ranking solutions by efficiency. The prediction task is the one that
  matches a review use case. On it, pass@1 accuracy for time complexity ran roughly 33% to 41% across GPT-4o, o1-mini,
  DeepSeek-R1-Llama-70B, and Llama-3.1-405B, and space-complexity accuracy ran roughly 10% to 14%. Reasoning models held
  about a 3-percentage-point edge over Llama-3.1-405B despite much stronger general code-generation scores, which the
  authors read as evidence that coding ability does not transfer to complexity reasoning.
- **Evidence status:** corroborated by A22

### A22: CodeComplex (2024/2025) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2401.08719
- **Retrieved:** 2026-08-10
- **Trust class:** web (outside the trust boundary)
- **Summary:** A dataset of 4,900 Java and 4,900 Python programs labeled with worst-case time complexity across seven
  classes, built specifically to test model reasoning about complexity where earlier benchmarks under-specified input
  assumptions. Its consistent reported failure mode is that models confuse hierarchically adjacent classes, mistaking
  O(n log n) for O(n) or O(n²). The errors cluster near the correct answer rather than scattering, so a model often gets
  the general shape right and the specific class wrong.
- **Evidence status:** corroborated by A21

### A15: The 45% threshold and team cap — recommendation-bearing

- **Link / location:**
  `han-plugin-builder/skills/guidance/references/agent-building-guidelines/multi-agent-economics.md:80-88`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Han's own authoring guidance instructs that before adding another agent you ask whether the current
  architecture already reaches more than 45% of optimal quality on the dimension you want to improve. If it does,
  improve the existing agent's instructions, vocabulary, or tool access first; adding an agent is justified only when a
  single agent has been optimized and still falls short. The same file caps a concurrently dispatched team at roughly
  five agents. It attributes the threshold to Google Research, Google DeepMind, and MIT's 2025 scaling work.
- **Evidence status:** anchor (codebase); corroborated by A28

### A16: No A/B unique-survivor-yield method exists — recommendation-bearing

- **Link / location:** repository-wide search of `/Users/riverbailey/dev/testdouble/han`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** The issue's Stage 0 ends by running "the project's existing A/B unique-survivor-yield method" over real
  changes. A search across every markdown file in the repository for that method, and for the terms it would use, finds
  nothing. No documented, runnable evaluation procedure of that kind exists here. The issue's staged plan therefore
  cannot execute its own gate without first building an evaluation harness.
- **Evidence status:** anchor (codebase, negative result)

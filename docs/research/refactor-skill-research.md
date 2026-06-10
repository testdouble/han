# Research: How should the `han.coding:refactor` skill be designed?

GitHub issue [testdouble/han#52](https://github.com/testdouble/han/issues/52) requests a new `refactor` skill. The operator has directed that it live in `han.coding` as a code-writing skill alongside `tdd`. This research answers the open questions the issue's triage left: the job to be done, the distinction from existing skills, the workflow shape, and the guardrails. Evidence mode: strict.

## Summary

Build the refactor skill as a disciplined, behavior-preserving execution skill: it takes a named target (a file, a module, a named code smell, or findings from a prior code review or architectural analysis), refuses to start without a passing test suite covering that target, plans the sequence of small named refactorings before touching code, runs the tests after every step, stops hard when changes start spreading beyond the declared scope, and never changes behavior. The strongest evidence in both the classic refactoring literature and the newer studies of AI coding agents points the same direction: open-ended "clean this up" runs perform poorly and often make things worse, while named targets, a plan-before-edit step, and incremental test gates are what make agent-driven refactoring safe. In the Han suite this fills a real gap: the review skills recommend refactorings but nothing executes them, and the `tdd` skill's refactor step only cleans up the code of the current test cycle. The skill must declare a clear boundary with `tdd` (never run it on code under an active TDD cycle) and treat its test-suite gate as enforced by shown evidence, the same honest limitation `tdd` documents. The recommendation is well-corroborated across the practice literature, the agentic studies, and the codebase, with caveats on the Java-leaning study base noted below.

- **Confidence:** Medium

## Research Results

### What disciplined refactoring means

Refactoring has a precise meaning: a change to internal structure that does not alter observable behavior, applied as a sequence of small steps (A1, A2, A4). Practitioner consensus on preconditions is strong and multi-source: automated tests covering the target's behavior before anything changes (A6, A9, A10, A17); tests green before and green after each individual step, with the green-to-green window measured in minutes (A2, A10); small named steps drawn from a known catalog rather than ad-hoc large transformations (A1, A6, A19); the "two hats" rule that refactoring and behavior change never happen at the same time (A3, A5, A6, A7); and refactoring commits kept separate from feature commits (A11, A14, A15). One minority position holds that strictly structural refactors can skip unit tests when static analysis stands in [single-source] (A18); its own author documents that the required constraint is routinely violated in practice, so it does not inform the design.

### When and how much

Fowler names six refactoring workflows; the opportunistic ones (litter-pickup, comprehension, and preparatory, with Beck's "make the change easy, then make the easy change") are the primary vehicles, and heavy reliance on planned-only refactoring sessions is itself a warning sign (A5, A7, A8, A16). Scope control is the other half of the discipline: when changes spread beyond the initial subject, the work has stopped being refactoring and become rewriting (A13), and code with no reason to change repays no refactoring investment; the high-value targets are code that is both complex and frequently changed (A6, A17).

### What the agentic evidence adds

The newer studies of LLM and agent refactoring independently confirm the classic discipline and sharpen it:

- **Named targets beat open-ended prompts decisively.** With generic prompts, GPT-class models identify only 15.6% of refactoring opportunities; naming the refactoring type and subcategory raises that to 86.7% (A21). Smell-specific playbooks raise partial repair rates from 21.3% to 60-82%, while minimal prompting produces zero false-positive differentiation (A25) [recent source, see Validation].
- **Unguided agents make things worse in the field.** A 14,998-commit study found agents bias toward low-level renames and type changes, produce no significant reduction in design smells despite maintainability framing, and tangle 53.9% of their refactorings into unrelated commits (A22; consistent reporting by A23, an interested party, see Validation). Aggressive agents resolve some smells while introducing far more (net -109); conservative, tightly-scoped agents come out net positive (A25).
- **Incremental feedback loops are the most reliable correctness improver.** Compile-and-test feedback iteration raises correctness by 40-65 points over single-shot output (A21), recursive criticism prompting adds 8-14 points (A26), and a planner/generator/compiler/tester pipeline reaches a 90% median test pass rate on real projects (A24).
- **Plan-then-execute converges across source types.** Academic frameworks (A24), vendor documentation from Cursor and Aider (A28, A35), and an enterprise practitioner account from Atlassian (A33) all separate understanding-the-scope from executing-the-changes.
- **Tests plus type checkers and linters form the right dual oracle.** Tests verify behavior; static checks catch a distinct class of unsafe edits, and a detect-with-LLM, execute-with-deterministic-tooling hybrid eliminated all unsafe edits in one study (A21, A24, A28, A37).
- Caveated, single-source claims that did not drive conclusions: a vendor's "two of three AI refactors break code" figure (A27), a 200-300-line chunk-size heuristic (A36), and the warning that AI-generated tests written from the code being refactored defeat verification (A27), though the underlying characterization-test tradition for uncovered code is established prior art (A9, A39).

### What Han already has, and the gap

The `tdd` skill's refactor step is non-skippable but deliberately narrow: it runs only when every test is green and cleans up only what the current red-green cycle created (A41, A42). The `code-review` skill emits refactoring opportunities as advisory findings and never modifies code; `architectural-analysis` dispatches the software-architect agent, which produces pseudocode sketches only (A43, A44). No refactor skill or prior plan for one exists anywhere in the repo (A45). The gap is concrete: the suite can recommend refactorings spanning existing code but has no skill that executes those recommendations safely. Suite conventions bind any new skill: the YAGNI evidence gate (A46), a long-form doc shipped in the same PR (A47), and the honest enforcement limitation that the plugin model cannot physically prevent a premature write, only require shown evidence (A48). Issue #52 itself records the request and the open design questions; it documents no specific operator friction beyond the request (A49).

## Options to Consider

### O1: Do not build it

- **What it is:** Rely on `tdd`'s refactor step for cycle-local cleanup and apply review findings by hand.
- **Trade-offs:** Honors YAGNI with the least work, but leaves the corroborated gap standing: review skills produce refactoring recommendations that no skill can execute, and `tdd` cannot touch code outside its current cycle (A41, A43, A44). The operator's directive in this session settles the build decision.
- **Rests on:** (A41, A43, A44, A46, A49)
- **Evidence status:** corroborated (the gap); the decision to build now rests on operator direction

### O2: Open-ended cleanup skill

- **What it is:** "Clean up this module" as a skill: point the agent at code and let it improve quality as it sees fit.
- **Trade-offs:** Contradicted by the sharpest quantitative evidence in the set: 15.6% opportunity recall with generic prompts (A21), zero false-positive differentiation under minimal prompting (A25), no net smell reduction in the field (A22), and net-negative outcomes from aggressive agents (A25).
- **Rests on:** (A21, A22, A25)
- **Evidence status:** corroborated (against)

### O3: Disciplined behavior-preserving execution skill

- **What it is:** The skill takes a named scope or target (file, module, named smell, or findings from `/code-review` or `/architectural-analysis` output). It gates on a green test suite covering the target, offering a characterization-test path when coverage is missing. It plans the refactoring sequence before editing, executes small named refactorings one at a time with tests (plus type check and lint where available) run after each step, applies a hard stop when changes spread beyond the declared scope, keeps refactoring commits separate from any behavior change, applies the YAGNI evidence gate to each refactoring, and never changes behavior.
- **Trade-offs:** Slower per change than one-shot edits; depends on a runnable test suite; the test-suite gate is enforced by shown evidence and discipline, not physically (A48); the characterization-test path for uncovered code is established practice for humans (A9) but unstudied for agentic workflows [single-source] (A39).
- **Rests on:** (A1-A19 practice consensus; A21, A24, A25, A26, A28, A33, A35 agentic convergence; A41, A43, A44 codebase gap)
- **Evidence status:** corroborated

### O4: Sizing-aware multi-agent analysis and execution pipeline

- **What it is:** The skill dispatches structural and behavioral analysts plus the software-architect agent to discover and design refactorings, then executes them, RefAgent-style.
- **Trade-offs:** The research pipeline it imitates posts strong numbers (A24), but in Han it duplicates `/code-review` and `/architectural-analysis`, which already produce exactly those findings. O3 consumes their output as input instead. YAGNI rejects the duplication (A46).
- **Rests on:** (A24, A43, A44, A46)
- **Evidence status:** corroborated (against, within Han)

### O5: Plan-only refactor skill (added during validation)

- **What it is:** A skill that produces a refactoring plan artifact and changes no code, parallel to `/plan-implementation`.
- **Trade-offs:** Sidesteps every execution risk in the agentic evidence, but the operator's directive places the skill in `han.coding`, the plugin defined as code-writing and execution. A plan-only skill also overlaps the existing recommendation artifacts: `/code-review` findings and the software-architect's pseudocode sketches already are refactoring plans (A43, A44). The unmet need is execution, not another plan.
- **Rests on:** (A43, A44, A45)
- **Evidence status:** corroborated (against, within Han)

## Recommendation

- **Recommendation:** O3, with four design constraints carried in from validation: (1) an explicit boundary with `tdd`, stated in the skill's description and gates: never run `/refactor` on code under an active TDD cycle, where `tdd`'s own refactor step owns the job (V7); (2) the test-suite precondition enforced the way `tdd` enforces its observed-failure gate, by required shown runner output and stop rules, with an explicit halt when coverage of the target cannot be established and a clearly-labeled lower-confidence characterization-test path (V4); (3) named refactorings used as a working vocabulary resolved against the project's language and conventions at runtime, not a hardcoded Java-centric catalog (V3); (4) the refactor-only-commit guardrail carried as established practice whose effectiveness as an agent instruction is not independently validated (V5).
- **Evidence basis:** The precondition set rests on corroborated multi-source practice consensus (A1-A19) independently confirmed by the agentic evidence: named targets (A21, A25), plan-then-execute (A24, A28, A33, A35), incremental gates (A21, A24, A26), conservative scope over aggressive sweep (A25), and separate refactor commits (A11, A14, A15, with the tangling harm documented in A22). The gap O3 fills rests on codebase evidence (A41, A43, A44). Single-source elements that inform but do not carry the recommendation: the characterization-test path for agentic workflows (A39), the test-circularity warning (A27), and chunk-size heuristics (A36).

## Validation

### V1: The decision to build rests on unverified issue content

- **Strategy:** Challenge the Evidence
- **Investigation:** The validator noted the research record did not quote issue #52, so the YAGNI gate for the skill's own existence was unverified.
- **Result:** Partially Refuted
- **Impact:** Resolved: the issue content is in the record (A49). It is a triaged feature request that itself says the job-to-be-done needs settling, with no documented friction. The build decision therefore rests on the operator's explicit directive in this session plus the corroborated capability gap (A41, A43, A44), and the report says so plainly rather than claiming the issue alone satisfies the evidence gate.

### V2: A plan-only option was missing from the framing

- **Strategy:** Challenge the Options Framing
- **Investigation:** The validator found the option space conflated "a refactoring skill" with "an executing refactoring skill" and proposed a plan-only artifact skill in `han.core`.
- **Result:** Refuted (the framing was incomplete)
- **Impact:** O5 was added and evaluated. It is rejected on its merits: the operator placed the skill in the code-writing plugin, and the suite already produces refactoring-plan artifacts through its review skills. The unmet need is safe execution.

### V3: The quantitative agentic evidence is Java-leaning

- **Strategy:** Challenge the Assumptions
- **Investigation:** The load-bearing studies (A21, A22, A24, A25, A26) are predominantly Java or JVM-adjacent; their specific figures may not transfer to TypeScript, Python, or Go codebases.
- **Result:** Partially Refuted
- **Impact:** The direction of the findings (specificity, gates, conservatism) is treated as transferable; the specific numbers are not load-bearing thresholds in the design. Design constraint 3 in the Recommendation follows from this finding.

### V4: The green-tests precondition is unenforceable in the plugin model

- **Strategy:** Challenge the Fix
- **Investigation:** Han's own `tdd` long-form doc documents that no skill can physically enforce "you must have observed X before doing Y" (A48). A refactor skill faces a harder version: it must run and interpret a suite it did not write, and may need coverage tooling permissions.
- **Result:** Partially Refuted
- **Impact:** Design constraint 2: the gate is enforced by required shown evidence and stop rules, the skill halts when target coverage cannot be established, and self-written characterization tests are labeled a lower-confidence oracle.

### V5: The tangling evidence does not validate the proposed commit guardrail

- **Strategy:** Challenge the Evidence
- **Investigation:** A22/A23 are observational; no cited study tests whether instructing an agent to make refactor-only commits reduces tangling.
- **Result:** Partially Refuted
- **Impact:** The guardrail stays (it is established human practice, A11, A14, A15) but is carried as best practice with an explicit caveat that its agentic effectiveness is unvalidated. Design constraint 4.

### V6: LinearB (A23) is an interested party, not independent corroboration

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** LinearB sells commit-analytics tooling; a finding that agents produce tangled commits favors its product narrative, and its post reports the same dataset as A22.
- **Result:** Partially Refuted
- **Impact:** A23 was reclassified from corroboration to consistent reporting by an interested party. The 53.9% tangling figure rests on A22 alone and is labeled accordingly.

### V7: The boundary with `tdd` creates a scope collision

- **Strategy:** Challenge the Fix
- **Investigation:** O3 as first drafted could be invoked on code under an active TDD cycle, violating the two-hats rule the suite already enforces (A41, A42).
- **Result:** Partially Refuted
- **Impact:** Design constraint 1: the skill's description and gates must state it operates on existing code outside any running `tdd` cycle.

### V8: A key arXiv source might be confabulated

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** SmellBench (A25) carries a May 2026 arXiv ID, weeks old at research time, raising the possibility of a hallucinated ID. The ID was verified directly after validation: `https://arxiv.org/abs/2605.07001` returns HTTP 200 with the exact title "SmellBench: Evaluating LLM Agents on Architectural Code Smell Repair".
- **Result:** Refuted (the source is real)
- **Impact:** The confabulation concern is closed. A recency caveat stands: the paper is not peer-reviewed and weeks old, so claims resting solely on A25 (the κ=0.00 baseline and the net +16 / -109 conservative-versus-aggressive contrast) are labeled accordingly and the case against O2 also stands on A21 and A22 independently.

### Adjustments Made

Validation added O5 to the options and rejected it on its merits, demoted A23 to interested-party status, attached a recency caveat to A25 after verifying it exists, restated the build justification as operator direction plus the codebase gap rather than the issue alone, and folded four design constraints into the recommendation (the `tdd` boundary, the shown-evidence test gate, the language-agnostic catalog, and the caveated commit guardrail). The recommendation survived.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** The agentic study base leans Java, so specific figures may not transfer to other stacks. The characterization-test path for uncovered code is unstudied in agentic workflows. The refactor-only-commit guardrail's effectiveness as an agent instruction is unvalidated. A25 is real but weeks old and not peer-reviewed. The test-gate enforcement shares `tdd`'s honest limitation: discipline and shown evidence, not physical prevention.

## Sources

| ID | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
|---|---|---|---|---|---|---|
| A1 | Fowler, Definition of Refactoring | https://martinfowler.com/bliki/DefinitionOfRefactoring.html | 2026-06-10 | web | Canonical definition: behavior-preserving structural change, applied in sequence | corroborated by A2, A3, A5, A6 |
| A2 | Fowler, Refactoring Malapropism | https://martinfowler.com/bliki/RefactoringMalapropism.html | 2026-06-10 | web | True refactoring keeps the system unbroken for more than a few minutes at a time | corroborated by A1, A3 |
| A3 | Fowler, Preparatory Refactoring Example | https://martinfowler.com/articles/preparatory-refactoring-example.html | 2026-06-10 | web | Beck's "make the change easy, then make the easy change"; the two-hats principle | corroborated by A1, A5, A6, A7 |
| A4 | Opdyke 1992 thesis | https://www.laputan.org/pub/papers/opdyke-thesis.pdf | 2026-06-10 | web | Formal behavior-preservation definition and per-refactoring preconditions | definition corroborated by A1, A2; primary text single source (PDF unrendered) |
| A5 | Fowler, Workflows of Refactoring | https://martinfowler.com/articles/workflowsOfRefactoring/fallback.html | 2026-06-10 | web | Six workflows; planned-only refactoring is a bad smell | corroborated by A3, A6, A7, A8 |
| A6 | understandlegacycode.com, Key Points of Refactoring | https://understandlegacycode.com/blog/key-points-of-refactoring/ | 2026-06-10 | web | Independent summary confirming two hats, tests-first, small named steps | corroborated by A1, A3, A5, A7 |
| A7 | nipafx.dev, Workflows of Refactoring | https://nipafx.dev/workflows-refactoring/ | 2026-06-10 | web | Independent commentary confirming the six-workflow model | corroborated by A5, A6 |
| A8 | Fowler, Opportunistic Refactoring | https://martinfowler.com/bliki/OpportunisticRefactoring.html | 2026-06-10 | web | Camp-site rule; avoid rabbit-hole cascades; tests green before starting | corroborated by A5, A6, A7 |
| A9 | understandlegacycode.com, Key Points of WEWLC | https://understandlegacycode.com/blog/key-points-of-working-effectively-with-legacy-code/ | 2026-06-10 | web | Feathers: characterization tests first, then refactor; legacy code = code without tests | corroborated by A10, A13 |
| A10 | qualitycoding.org, Don't Refactor Without Tests | https://qualitycoding.org/dont-refactor-without-tests/ | 2026-06-10 | web | Tests green at start and after every step; coverage numbers can deceive | corroborated by A9, A13 |
| A11 | codewithjason.com, Don't Mix Refactorings with Behavior Changes | https://www.codewithjason.com/dont-mix-refactorings-behavior-changes/ | 2026-06-10 | web | Mixing breaks bug attribution and review; separate branches | principle corroborated by A3, A14, A15; specific workflow single source |
| A12 | andreigridnev.com, Four Tips to Avoid Scope Creep | https://andreigridnev.com/blog/2019-01-20-four-tips-to-avoid-scope-creep-during-refactoring/ | 2026-06-10 | web | Goal-tying, planning, scope-holding, time-boxing | principles corroborated by A13, A16; formulation single source |
| A13 | ben-morris.com, When Does Refactoring Become Rewriting? | https://www.ben-morris.com/when-does-refactoring-become-rewriting/ | 2026-06-10 | web | Changes spreading beyond the initial subject mean you have left refactoring | corroborated by A5, A12 |
| A14 | graphite.com, Best Practices for Refactoring PRs | https://graphite.com/guides/best-practices-refactoring-prs | 2026-06-10 | web (interested party) | Separate refactoring PRs, atomic commits, CI validation | workflow principles corroborated by A11, A15 |
| A15 | kyleshevlin.com, My Git Workflow for Refactoring | https://kyleshevlin.com/my-git-workflow-for-refactoring/ | 2026-06-10 | web | Two-PR workflow keeping refactor and feature review separate | principle corroborated by A11; mechanics single source |
| A16 | Mountain Goat Software, Fitting Refactoring into Sprints | https://www.mountaingoatsoftware.com/blog/three-strategies-for-fitting-refactoring-into-your-sprints | 2026-06-10 | web | Three planned-refactoring models; technical backlog most vulnerable to pressure | taxonomy corroborated by A5, A12; preference single source |
| A17 | thoughtbot.com, Reasons Not to Refactor | https://thoughtbot.com/blog/reasons-not-to-refactor | 2026-06-10 | web | Stopping conditions: no tests, code unlikely to change, hidden risk | corroborated by A6, A9, A10 |
| A18 | Matthias Noback, Refactoring Without Tests Should Be Fine | https://matthiasnoback.nl/2022/10/refactoring-without-tests-should-be-fine/ | 2026-06-10 | web | Minority position: structural-only refactors can skip unit tests under static analysis | single source (caveated); contradicted by A9, A10, A17 |
| A19 | refactoring.com, Catalog of Refactorings | https://refactoring.com/catalog/ | 2026-06-10 | web | ~72 named refactorings as a shared vocabulary of small safe steps | corroborated by A1, A6 |
| A20 | artima.com, Refactoring with Martin Fowler | https://www.artima.com/articles/refactoring-with-martin-fowler | 2026-06-10 | web | Interview context for the catalog approach; no unique claims | corroborated by A1, A5 |
| A21 | arXiv 2411.04444, LLMs in Automated Refactoring | https://arxiv.org/html/2411.04444v1 | 2026-06-10 | web | Named type/subcategory prompts: 15.6% to 86.7% recall; ~8% unsafe outputs; detect-and-reapply eliminates unsafe edits | corroborated by A25, A26 (direction) |
| A22 | arXiv 2511.04824, Agentic Refactoring field study | https://arxiv.org/html/2511.04824v1 | 2026-06-10 | web | 14,998 commits: low-level bias, no smell reduction, 53.9% tangled refactorings | tangling figure single source after A23 reclassification (V6) |
| A23 | LinearB, AI agents and refactoring | https://linearb.io/blog/ai-coding-agents-code-refactoring | 2026-06-10 | web (interested party) | Reports the A22 dataset; recommends separate refactoring PRs | consistent reporting of A22, not independent (V6) |
| A24 | arXiv 2511.03153, RefAgent | https://arxiv.org/html/2511.03153v1 | 2026-06-10 | web | Planner/generator/compiler/tester pipeline: 90% median test pass on 8 projects | corroborated by A21, A26 (feedback loops) |
| A25 | arXiv 2605.07001, SmellBench | https://arxiv.org/html/2605.07001v1 | 2026-06-10 | web | Smell-specific playbooks 21.3% to 60-82%; conservative agents net +16, aggressive net -109 | real (verified, V8) but weeks old, not peer-reviewed; specificity direction corroborated by A21 |
| A26 | arXiv 2510.26480, Extract Method with open LLMs | https://arxiv.org/html/2510.26480 | 2026-06-10 | web | RCI iteration adds 8-14 points across all models tested | corroborated by A21, A24 |
| A27 | CodeScene, Guardrails for AI-assisted coding | https://codescene.com/blog/implement-guardrails-for-ai-assisted-coding | 2026-06-10 | web (interested party) | "2 of 3 AI refactors break code"; AI-generated tests from the code defeat verification | single source (caveated) |
| A28 | Cursor, Agent best practices | https://cursor.com/blog/agent-best-practices | 2026-06-10 | web (vendor docs) | Plan before coding; tests, types, linters as verifiable signals; revert-and-restart | corroborated by A33, A35, A37 |
| A29 | arXiv 2510.03914, Refactoring with LLMs | https://arxiv.org/pdf/2510.03914 | 2026-06-10 | web | Confirms named-prompt superiority and detect-and-reapply | corroborated by A21, A25; full text inaccessible |
| A30 | Junction blog, Supervising long-running refactors | https://junctionpanel.dev/blog/long-running-refactor-supervision/ | 2026-06-10 | web | Stop rules: out-of-scope diffs, behavior-altering structural changes; silent scope creep | stop-rule formulation single source; pattern corroborated by A22, A31 |
| A31 | ceaksan.com, LLM agentic failure modes | https://ceaksan.com/en/llm-agentic-failure-modes | 2026-06-10 | web | Task drift, mode collapse; goal reanchoring and step limits | corroborated by A22, A30 |
| A32 | FlorianBruniaux, TDD with Claude | https://github.com/FlorianBruniaux/claude-code-ultimate-guide/blob/main/guide/workflows/tdd-with-claude.md | 2026-06-10 | web | TDD as the strongest agentic pattern; red-green gives unambiguous feedback | "strongest" claim single source; rationale corroborated by A28, A34 |
| A33 | Atlassian, AI for large-scale refactoring | https://www.atlassian.com/blog/developer/how-to-effectively-utilise-ai-to-enhance-large-scale-refactoring | 2026-06-10 | web (interested party) | Small batches, CI per iteration, human review gates at enterprise scale | corroborated by A24, A28, A30 |
| A34 | codemanship, Why TDD works with AI | https://codemanship.wordpress.com/2026/01/09/why-does-test-driven-development-work-so-well-in-ai-assisted-programming/ | 2026-06-10 | web | Small steps prevent context pollution; per-smell refactoring in green | framing single source; corroborated in direction by A28, A32 |
| A35 | Aider, Architect/editor separation | https://aider.chat/2024/09/26/architect.html | 2026-06-10 | web (vendor docs) | Separating reasoning from editing improves edit benchmarks | separation corroborated by A24, A33; figures vendor-reported |
| A36 | codenotary.com, Refactoring Rust with Aider | https://codenotary.com/blog/step-by-step-guide-refactoring-a-large-rust-codebase-with-aiderdev-and-custom-llms | 2026-06-10 | web | 200-300 line chunks; explicit file scope control | chunk figure single source; batching corroborated by A30, A33 |
| A37 | GitHub, Copilot Agent Mode 101 | https://github.blog/ai-and-ml/github-copilot/agent-mode-101-all-about-github-copilots-powerful-mode/ | 2026-06-10 | web (vendor docs) | Tests, builds, and terminal output as autonomous feedback; human diff review essential | corroborated by A27, A28 |
| A38 | Meta Engineering, LLM mutation testing | https://engineering.fb.com/2025/09/30/security/llms-are-the-key-to-mutation-testing-and-better-compliance/ | 2026-06-10 | web (interested party) | LLMs as behavior oracles via mutation testing | figures single source; concept established in testing literature |
| A39 | NimblePros, Characterization tests with snapshots | https://blog.nimblepros.com/blogs/characterization-tests-with-snapshot-testing/ | 2026-06-10 | web | Snapshot-based characterization tests as a refactoring baseline for legacy code | concept corroborated by A9; agentic application unstudied |
| A40 | Towards Data Science, Large refactors in Cursor | https://towardsdatascience.com/how-to-perform-large-code-refactors-in-cursor/ | 2026-06-10 | web | Discovery/plan/execute/verify phases; post-hoc diff review keeps finding bugs | diff-review observation single source; phases corroborated by A28, A30 |
| A41 | tdd refactor step | `han.coding/skills/tdd/SKILL.md:189-209` | n/a | codebase | Non-skippable, green-only, scoped to the current cycle, YAGNI-gated | corroborated by A42 |
| A42 | tdd two-hats canon | `han.coding/skills/tdd/references/tdd-loop.md:58-64` | n/a | codebase | "Refactor only when every test is green"; structural change on red is not a refactor | corroborated by A41 |
| A43 | code-review scope | `han.core/skills/code-review/SKILL.md` | n/a | codebase | Emits advisory refactoring findings; never modifies code | corroborated by A44 |
| A44 | architectural-analysis and software-architect scope | `han.core/skills/architectural-analysis/SKILL.md`, `han.core/agents/software-architect.md` | n/a | codebase | Recommendations and pseudocode sketches only; never refactors | corroborated by A43 |
| A45 | han.coding plugin manifest | `han.coding/.claude-plugin/plugin.json` | n/a | codebase | Code-writing plugin, depends on han.core; no refactor skill exists anywhere in the repo | corroborated by repo-wide search |
| A46 | YAGNI rule | `docs/yagni.md`, `han.core/references/yagni-rule.md` | n/a | codebase | Evidence gate every skill applies before committing items | corroborated by suite-wide references |
| A47 | Doc coverage rule | `docs/templates/coverage-rule.md` | n/a | codebase | Every skill ships a long-form doc in the same PR, no exceptions | corroborated by docs tree |
| A48 | tdd enforcement limitation | `docs/skills/han.coding/tdd.md:87-91` | n/a | codebase | The plugin model cannot physically enforce observed-X-before-Y; discipline plus shown evidence | corroborated by A41 |
| A49 | GitHub issue #52 | https://github.com/testdouble/han/issues/52 | 2026-06-10 | provided | Triaged feature request for a refactor skill; open questions on scope; no documented friction | single source (the request itself) |

### A21: arXiv 2411.04444, LLMs in Automated Refactoring (recommendation-bearing)

- **Link / location:** https://arxiv.org/html/2411.04444v1
- **Retrieved:** 2026-06-10
- **Trust class:** web
- **Summary:** Studies GPT-4o and Gemini 1.5 Pro on 180 refactoring opportunities across 5 Java projects. Generic prompts identify 15.6% of opportunities; naming the refactoring type and subcategory raises that to 86.7%. About 8% of solutions are unsafe, and behavior-changing semantic bugs make up 81.8% of those. The detect-and-reapply pattern (LLM identifies, IDE executes) eliminated every unsafe case. This is the strongest single source for the named-target and dual-oracle design elements.
- **Evidence status:** corroborated by A25, A26 in direction

### A22: arXiv 2511.04824, Agentic Refactoring field study (recommendation-bearing)

- **Link / location:** https://arxiv.org/html/2511.04824v1
- **Retrieved:** 2026-06-10
- **Trust class:** web
- **Summary:** Analyzes 14,998 commits from 1,613 Java repositories. Agents favor low-level operations over design changes, produce no significant smell reduction despite maintainability framing, and tangle 53.9% of refactorings into commits with no declared refactoring intent. The strongest field evidence that unguided agent refactoring does not deliver structural improvement, motivating the named-target and refactor-only-commit constraints.
- **Evidence status:** tangling figure single source after V6; low-level bias consistent with A25

### A24: arXiv 2511.03153, RefAgent (recommendation-bearing)

- **Link / location:** https://arxiv.org/html/2511.03153v1
- **Retrieved:** 2026-06-10
- **Trust class:** web
- **Summary:** A planner/generator/compiler/tester pipeline reaching a 90% median unit-test pass rate and 50-53.5% smell reduction across 8 Apache Java projects, significantly outperforming single-agent baselines. The strongest evidence for separating planning from execution and for incremental compile-and-test feedback gates.
- **Evidence status:** corroborated by A21, A26 on feedback loops; A28, A33, A35 on plan-then-execute

### A41: tdd refactor step (recommendation-bearing)

- **Link / location:** `han.coding/skills/tdd/SKILL.md:189-209`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** The suite's only existing refactoring automation. Non-skippable, runs only on green, scoped to the code the current red-green cycle touched, applies coding standards and ADRs, defers speculative abstraction. Defines the boundary the new skill must respect and the enforcement style (shown evidence, stop rules) it should reuse.
- **Evidence status:** corroborated by A42, A48

### A43 and A44: review skills' scope (recommendation-bearing)

- **Link / location:** `han.core/skills/code-review/SKILL.md`, `han.core/skills/architectural-analysis/SKILL.md`, `han.core/agents/software-architect.md`
- **Retrieved:** n/a
- **Trust class:** codebase
- **Summary:** Both review skills explicitly never modify code: code review emits advisory findings, and architectural analysis ends at the software-architect's pseudocode sketches. Together with A41 they establish the gap the new skill fills and the input artifacts it should accept.
- **Evidence status:** corroborated by each other and the agent definitions

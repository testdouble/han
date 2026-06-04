# Implementation Decision Log: canonical-evidence-resource

## Trivial decisions

- D-1: File names — `docs/evidence.md` and `plugin/references/evidence-rule.md`, paralleling the YAGNI pair. Driver: research O7 + IA controlled-vocabulary argument (noun, not adjective; not "hierarchy"). — Referenced in plan: Source Specification, Outcome, Decomposition and Sequencing.
- D-9: CLAUDE.md index entry sits in `### Core mental model` immediately after the `docs/yagni.md` line, following the existing `**[docs/FILE.md](./docs/FILE.md).** {scent}. Use when {scenario}.` pattern. — Referenced in plan: Decomposition and Sequencing.
- D-13: Both new files follow `docs/writing-voice.md` (direct second person, plainspoken mentor tone, no em-dashes, no hype). Self-review against the voice doc before commit. — Referenced in plan: Testing Strategy, Definition of Done.
- D-14: Ship all phases on this branch (`canonical-evidence-resource`). One or more commits acceptable; the canonical pair + extraction + selective retrofit ship together. — Referenced in plan: Decomposition and Sequencing.

## Full decisions

### D-2: Long-form / rule-file content split

- **Question:** What content lives in `docs/evidence.md` versus `plugin/references/evidence-rule.md`, and how strictly does the split mirror the YAGNI pair?
- **Decision:** Mirror the YAGNI split. Long-form doc carries Why, context, named conditions where principles invert, and the application table. Rule file carries prescriptive imperative content only — principle names, trust-class definitions, the corroboration gate, the no-evidence-label instruction, and minimal cross-references. Rule file capped at 80 lines.
- **Rationale:** YAGNI rule (101 lines) and long-form doc (135 lines) are the established pattern; consumers of the rule file expect prescriptive content without Why-prose. The evidence rule has less surface area than YAGNI (no thirteen anti-patterns, no two gates) so 80 lines is sufficient and serves context hygiene given 10+ consumer skills will load it.
- **Evidence:** `plugin/references/yagni-rule.md` (101 lines, zero explanatory content); `docs/yagni.md:17–24` (Why section absent from rule file); `han.plugin-builder/skills/guidance/references/skill-building-guidance/context-hygiene.md` ("focused context outperforms accumulated context"); `han.plugin-builder/skills/guidance/references/skill-building-guidance/progressive-disclosure.md` (Level 3 references load on demand).
- **Rejected alternatives:**
  - Single combined doc — rejected: violates the established two-file pattern; mixes operator-facing context with agent-loaded prescription, burning context for every skill that loads it.
  - Three-file split (concept / rule / examples) — rejected: no precedent in the plugin; YAGNI does fine with two files; adds an additional cross-reference surface without adding clarity.
- **Specialist owner:** information-architect
- **Revisit criterion:** rule file approaches 100 lines (signal: content from long-form is bleeding into rule file).
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-3, D-4, D-5, D-6, D-7, D-8
- **Referenced in plan:** Implementation Approach; Decomposition and Sequencing.

### D-3: Three structural principles, named not numbered

- **Question:** Which structural principles from the research's five (proximity-to-origin, corroboration, no-evidence labeling, certainty-vs-recommendation separation, source-vs-information-vs-evidence independence) land in the canonical pair, and how are they framed?
- **Decision:** Three principles in the pair: proximity-to-origin (directional heuristic with named inversions), corroboration multiplier (with single-source caveat), and explicit no-evidence labeling. Principles 4 and 5 from the research are noted in the long-form doc as related cross-domain principles but not operationalized as Han rules.
- **Rationale:** O7 explicitly authorizes only the three Han already has fragments of (per `/research`'s existing trust-class and corroboration-gate language). Importing Principle 4 (GRADE-style certainty/recommendation separation) requires calibrated judgment Han does not have; importing Principle 5 (Evidence Explained framework) duplicates what trust classes already encode.
- **Evidence:** `docs/research/evidence-hierarchy.md#recommendation` (O7 scope); `plugin/skills/research/SKILL.md:108` (existing operational primitives); research validator finding A25 (ACM SIGSOFT rejection of gold-standard hierarchies for software).
- **Rejected alternatives:**
  - All five principles — rejected: violates O7; introduces GRADE-style tier labels (High/Moderate/Low/Very Low) without calibrated judgment to apply them.
  - Two principles (corroboration + no-evidence only, skip proximity-to-origin) — rejected: the reporter's request named "running code > documentation" and "primary > secondary" as the central examples; omitting proximity-to-origin would not answer the issue.
- **Specialist owner:** information-architect
- **Revisit criterion:** a documented Han failure attributable to absence of Principle 4 or 5 surfaces.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-5, D-6, D-7
- **Referenced in plan:** Implementation Approach; Runtime Behavior.

### D-4: Trust-class vocabulary, copied verbatim

- **Question:** How are trust classes (codebase / web / provided) defined in the new rule file?
- **Decision:** Copy the exact phrasing from `plugin/skills/research/SKILL.md:108` into the rule file: "codebase = trusted current-state anchor, web = outside the trust boundary, provided = operator-supplied (interested-party scrutiny)." Same words, same meaning. The long-form doc adds context on why the boundary exists.
- **Rationale:** Rosenfeld/Morville controlled-vocabulary principle: same term, same meaning everywhere. Drifting the phrasing between `/research/SKILL.md` and the new rule file is the failure mode the extraction is meant to prevent.
- **Evidence:** `plugin/skills/research/SKILL.md:108` (current operational language); IA recommendation cites the principle by name.
- **Rejected alternatives:** Paraphrase for clarity — rejected: a paraphrase creates two definitions that can drift.
- **Specialist owner:** information-architect
- **Revisit criterion:** a consumer skill needs a trust class not in the current set (codebase / web / provided).
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-10 (the extraction edit to `/research/SKILL.md`)
- **Referenced in plan:** Implementation Approach; Runtime Behavior.

### D-5: Proximity-to-origin framed as directional heuristic, never as a strict ranked list

- **Question:** How is the proximity-to-origin principle stated in the rule file, given the research's strong warning (V5, V8) against strict tier ordering?
- **Decision:** State the principle as one named heuristic in the rule file: "evidence drawn from closer to the originating event or data carries more weight than evidence at greater remove — apply this as a heuristic, not a ranked tier list. See `docs/evidence.md` for the named conditions where it inverts." The long-form doc enumerates the inversion conditions (formal-methods, specification-compliance, regulatory contexts where the specification is the authoritative artifact) and names the passing-test asymmetry (Dijkstra) as the reason a numbered list cannot work even within tests.
- **Rationale:** A numbered list in the rule file will be applied as a strict rule by skills, regardless of any "directional" qualifier nearby. The rule file gives agents the principle name and a pointer; the long-form doc carries the conditions.
- **Evidence:** `docs/research/evidence-hierarchy.md#v5` (not flowchartable without judgment rules); `docs/research/evidence-hierarchy.md#v8` (formal-methods and spec-compliance inversion); A36/A37 (Dijkstra: passing vs failing tests are asymmetric).
- **Rejected alternatives:**
  - Numbered tier list in the rule file — rejected: produces inconsistent outputs across skill invocations (V5); inverts in formal-methods contexts the list does not anticipate (V8).
  - Omit the principle entirely from the rule file — rejected: leaves the reporter's central example ("running code > documentation") unrepresented in the canonical source.
- **Specialist owner:** information-architect
- **Revisit criterion:** a documented case of an agent producing inconsistent verdicts because the heuristic was unclear.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-12 (cross-link statement)
- **Referenced in plan:** Implementation Approach; Runtime Behavior.

### D-6: Corroboration gate scoped to web sources only

- **Question:** Does the corroboration gate in the new rule file apply to all evidence or only to web sources?
- **Decision:** The corroboration gate applies to web sources that bear on a recommendation. Codebase evidence is not subject to the gate — a single file path at a specific line number is not weakened by being a single source. The rule file states this scope explicitly. Extending the gate to codebase evidence is deferred work, reopened when a specific failure forces it.
- **Rationale:** Research validator finding V9 found the gate does not transfer cleanly to codebase evidence. Forcing it would either be vacuous or reject valid single-file root-cause findings. The web-source scope is exactly what `/research/SKILL.md:110` already enforces; the extraction preserves that scope.
- **Evidence:** `docs/research/evidence-hierarchy.md#v9`; `plugin/skills/research/SKILL.md:110` (gate's existing scope).
- **Rejected alternatives:**
  - Gate applies to all evidence — rejected: V9; would break valid single-file findings in `/investigate`.
  - Gate applies to web + codebase with adaptation — rejected: the adaptation has not been specified; committing to it now is YAGNI.
- **Specialist owner:** information-architect
- **Revisit criterion:** an `/investigate` or `/iterative-plan-review` output produces a bad conclusion attributable to acceptance of a single-source codebase claim that an independent check would have caught.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-12
- **Referenced in plan:** Implementation Approach; Deferred (YAGNI).

### D-7: No-evidence state — defer with reopening trigger named

- **Question:** What does an agent or skill do when it loads the evidence rule and encounters a claim with no evidence at any tier?
- **Decision:** The rule file instructs: "label the claim's evidence status as 'no evidence,' defer the dependent decision, and record a reopening trigger naming the concrete evidence that would justify revisiting (a measured metric, a real incident, a customer commitment, a regulation taking effect)." This parallels YAGNI's `## Deferred (YAGNI)` pattern.
- **Rationale:** Cross-domain prior art (Admiralty F-6, GRADE expert-evidence survey, law's case-of-first-impression, journalism's near-silence default) treats no-evidence as a distinct epistemic state requiring an explicit label and a named response. YAGNI's defer-with-trigger pattern is the closest in-codebase precedent and the cleanest fit for the consumer skills (most already produce `## Deferred (YAGNI)` sections).
- **Evidence:** `docs/research/evidence-hierarchy.md` Research Results §3 (no-evidence state is named, not collapsed); `docs/yagni.md:100–113` (deferred-section format); `plugin/references/yagni-rule.md:80–93`.
- **Rejected alternatives:**
  - Block the dependent decision until evidence appears — rejected: too rigid; some decisions cannot wait; consumer skills like `/plan-a-feature` need to keep moving on adjacent items.
  - Treat no-evidence as "lowest-tier evidence" — rejected: research validator and cross-domain prior art both reject collapsing no-evidence into "very weak evidence"; loses signal.
- **Specialist owner:** information-architect (rule file); project-manager (alignment with consumer-skill defer patterns).
- **Revisit criterion:** consumer skills report the defer-with-trigger pattern produces stuck states the user cannot unblock.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None.
- **Referenced in plan:** Runtime Behavior; Definition of Done.

### D-8: Bidirectional cross-link between the YAGNI pair and the evidence pair

- **Question:** How do the YAGNI pair and the new evidence pair reference each other, given the conceptual dependency (YAGNI tests inclusion; evidence-rule characterizes quality)?
- **Decision:** Add one cross-link sentence in each of the four files.
  - `docs/yagni.md` — append to the TL;DR cross-reference bullet: "See also `docs/evidence.md` for the quality dimensions — corroboration, source proximity, and the no-evidence label — that apply once an item passes the YAGNI inclusion test."
  - `plugin/references/yagni-rule.md` — add a two-sentence pointer near the top of the file: "The categories below answer whether evidence exists at all. For how confident to be in the evidence you have — corroboration, trust classes, and the no-evidence label — see `evidence-rule.md`."
  - `docs/evidence.md` — opening: "This page defines what evidence means in Han and how to characterize its strength. It supplements (does not replace) the YAGNI inclusion test in `docs/yagni.md`."
  - `plugin/references/evidence-rule.md` — opening: "This rule defines quality dimensions of evidence. For the inclusion test that determines whether an item has any evidence at all, see `yagni-rule.md`."
- **Rationale:** YAGNI's five parallel categories answer "is there evidence?" Evidence-rule answers "how strong is the evidence?" A consumer that loads one without knowing about the other will apply either an inclusion check when the actual gap is quality, or a quality check when the actual gap is existence. One sentence at the right position in each file is the minimum to prevent the failure mode without duplicating content.
- **Evidence:** IA recommendation cites Rosenfeld/Morville contextual-linking principle; JD's Q4 names the failure scenario; `plugin/references/yagni-rule.md:12` ("acceptable evidence") would collide with evidence-rule vocabulary without explicit relationship statement.
- **Rejected alternatives:**
  - No cross-links — rejected: leaves the conceptual dependency invisible; consumers can apply the wrong test.
  - Comprehensive backlink registries in each file — rejected: violates context-hygiene; mirrors the YAGNI pair's current minimal linking discipline.
- **Specialist owner:** information-architect
- **Revisit criterion:** a consumer file is observed applying YAGNI's existence test and evidence-rule's quality test in a way that produces contradictory verdicts on the same item.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-12 (the explicit "supplements" statement in the rule file).
- **Referenced in plan:** Decomposition and Sequencing; Definition of Done.

### D-10: Extract `/research/SKILL.md` trust-class block to cite the canonical pair

- **Question:** When the new rule file exists, does `plugin/skills/research/SKILL.md:108–112` keep its inline trust-class definitions, or replace them with a citation to the canonical pair?
- **Decision:** Replace the inline definitions with a citation to the new `plugin/references/evidence-rule.md`. The current trust-class block in `/research/SKILL.md` becomes a one-sentence summary plus a link. The corroboration-gate and conflict-resolution rules (lines 110 and 112) also collapse to citations.
- **Rationale:** Without this edit, the canonical pair is a parallel definition next to `/research`'s inline definitions. Future edits to one will not update the other, and the two will drift. JD-Q5 named this as the "true extraction vs addition" question; the YAGNI pair followed exactly this pattern (inline YAGNI language extracted to `plugin/references/yagni-rule.md`, inline versions removed in favor of citations). The same move is required for "canonical" to be meaningful here.
- **Evidence:** `plugin/skills/research/SKILL.md:108, 110, 112`; YAGNI extraction precedent (25+ files cite `yagni-rule.md` after its extraction).
- **Rejected alternatives:**
  - Keep both definitions — rejected: parallel definitions drift; the "canonical" claim collapses; this is the failure mode the extraction prevents.
  - Replace `/research`'s definitions and remove citations from the skill body entirely — rejected: too aggressive; `/research` needs to load the rule file for its own behavior, so the citation must remain.
- **Specialist owner:** project-manager
- **Revisit criterion:** N/A — this is the inverse of drift; the only revisit reason would be deciding to inline definitions again, which would re-create the original problem.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-11, D-12
- **Referenced in plan:** Implementation Approach; Decomposition and Sequencing; Definition of Done.

### D-11: Selective retrofit — behavioral consumers cite, descriptive-only files defer

- **Question:** Of the 20 files in `plugin/` that use "evidence-based," which receive a citation to the new canonical pair on this branch, and which are deferred?
- **Decision:** Retrofit the behavioral consumers (files where "evidence-based" appears as part of an operational instruction, evidence test, or sub-agent dispatch criterion). Defer the descriptive-only single-occurrence files (where the term is part of an agent name or descriptive prose with no behavioral consequence) as YAGNI candidates. Categorization performed during execution; recorded in the commit. Behavioral consumers retrofitted: `iterative-plan-review/SKILL.md`, `gap-analysis/SKILL.md`, `project-manager.md`, `plan-a-feature/SKILL.md`, `investigate/SKILL.md`, `junior-developer.md`, `evidence-based-investigator.md`, `coding-standard/SKILL.md`, `architectural-decision-record/SKILL.md`, `runbook/SKILL.md`, `gap-analyzer.md`. Plus the YAGNI pair (D-8 cross-links).
- **Rationale:** YAGNI Gate 2 applied — the simpler version (retrofit only files where the citation changes or anchors behavior) satisfies the same evidence (the user's request for a canonical source) without adding boilerplate to ~7 descriptive-only files. JD's Q1/Q6 explicitly raised this as verdict-changing; IA reached the same conclusion via context-hygiene argument.
- **Evidence:** `.discovery-notes.md` enumeration of 41 occurrences across 20 files; JD-Q1/Q6/Q3; IA Question 4 retrofit-sequencing recommendation.
- **Rejected alternatives:**
  - Retrofit all 20 files — rejected: ~7 descriptive uses gain no behavioral anchor from a citation; symmetry-for-its-own-sake is a named YAGNI anti-pattern (`plugin/references/yagni-rule.md:41–42`).
  - Retrofit only the top 3 by density — rejected: misses behavioral consumers at lower density (e.g., `coding-standard/SKILL.md`'s evidence test).
- **Specialist owner:** project-manager
- **Revisit criterion:** a descriptive-only file is reported as confusing or a future skill author adds operational behavior that needs the citation.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** D-12
- **Referenced in plan:** Decomposition and Sequencing; Deferred (YAGNI).

### D-12: Citation phrasing — exact yagni-rule pattern

- **Question:** What exact citation phrasing do consumer files use, to keep retrofit consistent?
- **Decision:** From `plugin/skills/*/SKILL.md`: `[../../references/evidence-rule.md](../../references/evidence-rule.md)`. From `plugin/agents/*.md`: `[../references/evidence-rule.md](../references/evidence-rule.md)`. The surrounding sentence pattern matches the YAGNI-rule citations already in the file — typically "Apply the evidence-based YAGNI rule defined in [...]." For the new rule, the form is "Apply the evidence rule defined in [...]" or, when the consumer needs both, "Apply the evidence-based YAGNI rule defined in [...] alongside the evidence rule in [...]."
- **Rationale:** IA Risk 4 — inconsistent citation phrasing across files is itself a vocabulary failure. The yagni-rule citation form is already established in the codebase and proven to work at 25+ sites.
- **Evidence:** `plugin/skills/plan-a-feature/SKILL.md:24` (yagni-rule citation example); IA recommendation.
- **Rejected alternatives:** Plain text references without the link — rejected: defeats the cross-reference purpose; the YAGNI pattern uses markdown links because readers and tools both follow them.
- **Specialist owner:** project-manager
- **Revisit criterion:** N/A — vocabulary decision, stable.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None.
- **Referenced in plan:** Decomposition and Sequencing; Definition of Done.

### D-15: No behavioral-analyst dispatch — concern is content-design

- **Question:** Should `behavioral-analyst` be dispatched for the question of whether YAGNI rule + evidence rule loaded in the same skill produce non-contradictory verdicts (JD specialist recommendation)?
- **Decision:** No. The concern is a content-design question for the new rule file, not a behavioral-analysis question requiring a specialist. The rule file's opening (per D-8 and D-12) explicitly states the supplements-not-replaces relationship and gives consumer skills the framing they need to keep the two tests separate.
- **Rationale:** The scenarios JD named (item passes YAGNI Gate 1 but has weak corroboration; item fails Gate 1 but has strong codebase evidence) resolve as soon as the rule file says "YAGNI Gate 1 is upstream of and independent from the evidence-rule quality dimensions. Apply YAGNI Gate 1 first. If it fails, defer regardless of quality. If it passes, characterize quality with the evidence rule." This is a content-design decision in scope for IA, not a behavioral-analyst question.
- **Evidence:** JD's verbatim scenarios; IA's Question 1 split (rule file carries the operational instruction; long-form carries context).
- **Rejected alternatives:** Dispatch behavioral-analyst — rejected: would re-frame a content-design question as a runtime-behavior question; the small-team cap is 3 specialists for a reason, and the IA + JD pair already covers this scope.
- **Specialist owner:** project-manager
- **Revisit criterion:** after retrofit, a consumer skill observably produces contradictory verdicts from the two rule files; that would justify the dispatch retroactively.
- **Dissent (if any):** None.
- **Driven by rounds:** R1
- **Dependent decisions:** None.
- **Referenced in plan:** Team Composition and Participation.

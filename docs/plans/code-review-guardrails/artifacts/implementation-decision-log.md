# Implementation Decision Log: Code-Review Skill Guardrails

This file records every implementation decision committed while planning the code-review guardrails work. Behavioral and implementation statements live in [../feature-implementation-plan.md](../feature-implementation-plan.md); this file captures the question, rationale, evidence, and rejected alternatives for each decision. Round-by-round history lives in [implementation-iteration-history.md](implementation-iteration-history.md).

The investigation (`../investigation.md`) already committed S1–S13 as solutions; those commitments are recorded below as trivial decisions. The full decisions below concern *how* to implement those commitments: where authoritative rules live, how Step 7 is structured, how merged sub-steps fire, what scope S3/S4 take, sequencing constraints, scope additions for docs and versioning, and the named-binding plumbing the agents require.

## Trivial decisions

- D-19: Commit S1 (size-aware rubric in `agent-finding-classification.md`), replace the "Most findings land here" WARN floor in seven rubrics with size-aware language; investigation S1 already commits the change. Referenced in plan: Implementation Approach (Runtime Behavior), Decomposition and Sequencing.
- D-20: Commit S5 (add `{focus areas}` and `{branch context}` placeholders to every Step 3.5 agent prompt template), investigation S5 already commits the change. Referenced in plan: Implementation Approach (Runtime Behavior), Decomposition and Sequencing.
- D-21: Commit S11 (document Mode B and Mode C scope limitations in Step 4), investigation S11 already commits the change. Referenced in plan: Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

## Full decisions

### D-1: Step 3.3 is the authoritative home for size-based demotion

- **Question:** Where does size-based demotion live so that every consumer site references one source of truth instead of restating the rule with drift?
- **Decision:** Step 3.3 of `plugin/skills/code-review/SKILL.md` is the single authoritative source for the size-based demotion rules. The rewritten line 24 (S13), the new Step 7 sub-steps (S2 merged with S10), the rewritten rubric sections in `agent-finding-classification.md` (S1), and the new YAGNI two-pass procedure (S7) all reference Step 3.3 by name rather than restating its content.
- **Rationale:** The investigation's central diagnosis (C1, C2, C12) is that calibration is defined once and bypassed everywhere else. Multiple authoritative sites is the structural failure; centralizing on Step 3.3 fixes the cause rather than papering over its symptoms. Centralization also makes future calibration tuning a one-file edit.
- **Evidence:** SA-1; investigation C1, C2, C12 (`../investigation.md`); `plugin/skills/code-review/SKILL.md` Step 3.3 already carries the directive text.
- **Rejected alternatives:**
  - Restate the size-based rules at each consumer site (line 24, rubric, Step 7, YAGNI). Rejected because this reproduces the failure mode the investigation documents (drift between sites); evidence: investigation C2 ("Step 7 reclassifies agent output without applying Step 3.3's size-based demotion") shows the drift is the active bug.
  - Move the authoritative home to `agent-finding-classification.md`. Rejected because the rubric is consulted only at Step 7, but the directive must also govern line 24 and the agent prompts at Step 3.5; Step 3.3 is already in scope for both.
- **Specialist owner:** `software-architect`.
- **Revisit criterion:** A future change asks consumer sites to encode different size logic from Step 3.3, in which case the rule has stopped being authoritative and the centralization should be re-examined.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-2, D-3, D-11, D-15.
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points, Runtime Behavior), Decomposition and Sequencing.

### D-2: Step 7 takes a numbered sub-step structure (7.1 read, 7.2 merged demote, 7.3 rubric)

- **Question:** Where in Step 7 do the new mechanics from S2, S10, and S1 land, and in what order?
- **Decision:** Step 7 is rewritten as three numbered sub-steps. **7.1 Read agent output files** preserves the current behavior of loading each agent's findings. **7.2 Apply size-based and reachability demotion** runs the merged S2 + S10 phrase-match gate (see D-3) against every finding before classification. **7.3 Classify with the rubric** then applies the size-aware rubric from `agent-finding-classification.md` (D-19 / S1). Original investigation language separated S2 from S10; this plan merges them per D-3 and collapses two sub-steps into one.
- **Rationale:** SA-2 named the explicit numbering as a precondition for S2 and S10 to land without ambiguity. The merge of 7.2 and 7.3 (originally proposed as separate sub-steps) tracks BA-4's finding that S2 and S10 share a phrase-list demotion signal and should not be two sequential demote passes that risk double-demotion (V5 in the investigation's adversarial validation).
- **Evidence:** SA-2; BA-4; investigation's "Note on the S1 and S2 interaction" warning about double-demotion.
- **Rejected alternatives:**
  - Leave Step 7 as a single unnumbered block with the new sub-steps inserted inline. Rejected because the order of "demote then classify" versus "classify then demote" determines the final severity and must be explicit (SA-2 evidence).
  - Keep S2 and S10 as separate sub-steps 7.2 and 7.3, with the rubric becoming 7.4. Rejected because BA-4 demonstrated that both signals demote on rationale-phrase matches and a single merged gate satisfies both with no double-demotion risk.
- **Specialist owner:** `software-architect`.
- **Revisit criterion:** Post-ship validation against PR 299 shows S2 and S10 needed to fire on different signals after all, requiring the merged gate to split back into two sub-steps.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-3.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-3: Merge S2 and S10 into a single Step 7.2 reachability phrase-match gate

- **Question:** Should S2 fire on a "directly introduced" signal (investigation's original framing) or on a reachability phrase list (S10's signal)?
- **Decision:** S2 and S10 merge into a single Step 7.2 sub-step that demotes findings on a documented reachability phrase list. The phrase list, fixed in the SKILL.md body so it can be tuned in one place, is: `theoretical`, `hypothetical`, `defense-in-depth`, `effectively impossible`, `in case the upstream`, `could happen`, `should never happen`, `edge case that does not occur`. When a finding's rationale text contains any of these phrases, the gate demotes the finding by one severity (CRIT → WARN, WARN → SUGG, SUGG → omitted). The "directly introduced" condition from the investigation's original S2 is dropped because Step 7.3's size-aware rubric already encodes change-relatedness.
- **Rationale:** OQ-3 resolution from R1. The investigation's original "skip when directly introduced" rule (the V5 interaction note) required a structured field in agent output that no agent emits; phrase-matching is the simpler version that satisfies the same evidence (PR 299 E6, E10, E13, E14, E15, E16, all of which contain at least one of the listed phrases verbatim). BA-4 supplied the phrase list; BA-5 supplied the documented limitation (this is a phrase-match gate only, not a semantic reachability analyzer).
- **Evidence:** BA-4, BA-5; PR 299 evidence file confirms the phrases appear in raw agent output for the demotion targets; investigation Note after S13 (the V5 interaction warning).
- **Rejected alternatives:**
  - Implement S2's "directly introduced" condition as a structured agent-output field. Rejected because no agent currently emits the field, and adding it across nine agents is a larger change with no evidence the structured form is needed (Gate 2 simpler-version test, recorded as YAGNI candidate in the plan's deferred section).
  - Keep S2 and S10 as separate signals firing in sequence. Rejected because both demote on rationale text and sequential firing risks double-demotion per V5 (investigation's adversarial validation).
- **Specialist owner:** `behavioral-analyst`.
- **Revisit criterion:** Post-ship validation surfaces a finding the phrase list misses that a structured "directly introduced" field would have caught, or surfaces a false-positive demotion the phrase list cannot reject without semantic analysis.
- **Dissent (if any):** None at synthesis. The R1 dispute between SA-3 (anchor to Step 3.3 vocabulary) and BA-4 (use reachability phrase list) was resolved by the merge, which references Step 3.3 for criteria when applicable while using the phrase list as the trigger.
- **Driven by rounds:** R1.
- **Dependent decisions:** None downstream; this is the leaf decision for the merged mechanic.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing, RAID Log (assumption on phrase-list completeness).

### D-4: S3 and S4 ship as Step 3.5 dispatcher directives, not as edits to the four agent definition files

- **Question:** Should S3 (default-severity adjustment for structural-analyst and behavioral-analyst) and S4 (scoped-file-list constraint for junior-developer and edge-case-explorer) be implemented as edits to the four agent definition files, or as additions to the Step 3.5 dispatch prompts in SKILL.md?
- **Decision:** Both S3 and S4 land in SKILL.md Step 3.5 as additions to the relevant agent dispatch prompts. The four agent definition files (`plugin/agents/structural-analyst.md`, `plugin/agents/behavioral-analyst.md`, `plugin/agents/junior-developer.md`, `plugin/agents/edge-case-explorer.md`) are not edited.
- **Rationale:** OQ-5 resolution from R1, with consensus across SA-4, JD-007, and JD-014. The four agents are dispatched by skills outside `/code-review` (gap-analysis, plan-implementation, plan-a-feature, investigate). Edits to the agent bodies change behavior for every caller; edits to Step 3.5 dispatch prompts change behavior only for `/code-review`. The investigation's adversarial validation (V4, V8) already accepts that the agents' general behavior is correct; the bug is that `/code-review` was not tailoring the dispatch.
- **Evidence:** SA-4; JD-007; JD-014; investigation V4 ("outward reads in junior-developer and edge-case-explorer are for context, not findings, S4's framing remains correct"); investigation V8 ("lowered default severity without removing 'include when in doubt'").
- **Rejected alternatives:**
  - Edit the four agent definition files as the investigation originally proposed. Rejected because the blast radius extends beyond `/code-review` to every skill that dispatches these agents, with no evidence the other skills exhibit the same calibration failure.
  - Implement S3 in agent bodies but S4 as a Step 3.5 directive. Rejected because the symmetric specialist consensus across all four agents argued the same scope reasoning applies to both.
- **Specialist owner:** `software-architect`.
- **Revisit criterion:** A cross-project validation run (TP-17) or a user report shows a non-`/code-review` skill exhibits the same severity-inflation or out-of-scope-read failure mode, in which case the global agent-body edit becomes the correct scope.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-18.
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points, Runtime Behavior), Decomposition and Sequencing.

### D-5: Atomic shipping pairs and sequencing

- **Question:** Which solutions must ship in the same commit to avoid partial-state regressions, and what is the overall sequence?
- **Decision:** Three atomic pairs are enforced. **Pair A: S1 + S13 ship together** (the rubric and the Review Constraints line are the two halves of the same size-based severity rule; shipping one without the other leaves either agent findings or manual findings unchanged). **Pair B: S2-and-S10-merged + the Step 7 sub-step structure (D-2) ship together** (the merged gate needs the numbered sub-step structure to be inserted into). **Pair C: S5 + S6 + the dispatcher-directive form of S3 and S4 (D-4) ship together** (all four touch Step 3.5 dispatch prompts, and S3 only has observable effect when S1 has shipped per BA-7, so Pair A must precede Pair C). The overall sequence is **Pair A → Pair B → Pair C → S7 → S8 → S9 → S11 → docs sync + version bump + CHANGELOG**.
- **Rationale:** SA-5 named the three atomic pairs and the precondition that "authoritative home" (D-1) and "Step 7 sub-step structure" (D-2) must be pre-decided before any edits begin. BA-7 added the S3-requires-S1 dependency. The investigation's "Implementation sequence" note (which JD-011 promoted into the plan) corroborates the leverage ordering.
- **Evidence:** SA-5; BA-7; investigation "Implementation sequence" note in "What the investigation does not cover".
- **Rejected alternatives:**
  - Ship every solution in a single large commit. Rejected because Pair A delivers value with no dependencies on the rest, and decoupling validates the calibration fix on PR 299 before the context-forwarding changes land.
  - Ship S3 and S4 before Pair A. Rejected because S3 has no observable effect until the rubric (S1) has been rewritten, BA-7 evidence.
- **Specialist owner:** `software-architect`.
- **Revisit criterion:** A pair fails validation independently, in which case the pair definition is wrong and the sequence is re-examined.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-6, D-7.
- **Referenced in plan:** Decomposition and Sequencing.

### D-6: Version bump is minor (2.2.0 → 2.3.0)

- **Question:** Does this branch ship as a minor or major version bump, and is a CHANGELOG entry required?
- **Decision:** Minor bump from 2.2.0 to 2.3.0 in `plugin/.claude-plugin/plugin.json`. A CHANGELOG entry is required under `## 2.3.0` summarizing the four calibration changes (size-aware rubric, merged Step 7 demotion gate, focus-area plumbing, dispatcher directives), the docs sync, and the deferred items.
- **Rationale:** OQ-2 resolution from R1. The skill name, argument signature, and output-format structure are unchanged; only behavior is calibrated. `docs/guidance/semantic-versioning.md` reserves major bumps for backward-incompatible changes to those surfaces.
- **Evidence:** JD-002; `docs/guidance/semantic-versioning.md`; `CHANGELOG.md` precedent (the 2.2.0 entry covers behavioral changes without API change).
- **Rejected alternatives:**
  - Major bump (2.2.0 → 3.0.0). Rejected because no published interface changes; users invoke `/code-review` with the same arguments and receive the same output schema.
  - Patch bump (2.2.0 → 2.2.1). Rejected because the calibration changes are behavior-shaping and a user upgrading without reading the CHANGELOG would observe different outputs.
- **Specialist owner:** `project-manager`.
- **Revisit criterion:** A post-ship user report demonstrates the behavior change broke a workflow that depended on the prior calibration, in which case the bump should retroactively have been major.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Operational Readiness, Definition of Done.

### D-7: Long-form `docs/` mirror updates are in scope

- **Question:** Does this branch update the long-form operator-facing docs (`docs/skills/code-review.md` and the four affected `docs/agents/*.md` files), or defer them to a follow-up branch?
- **Decision:** In scope. Five long-form docs are updated alongside the plugin edits: `docs/skills/code-review.md`, `docs/agents/structural-analyst.md`, `docs/agents/behavioral-analyst.md`, `docs/agents/junior-developer.md`, `docs/agents/edge-case-explorer.md`. The agent docs receive lighter edits than originally implied because D-4 keeps the agent definitions themselves unchanged; the docs note that `/code-review` now tailors dispatch via Step 3.5 directives.
- **Rationale:** OQ-1 resolution from R1. The repo's CLAUDE.md explicitly states that "long-form docs in `docs/skills/{name}.md` and `docs/agents/{name}.md` are the canonical operator-facing source." Shipping plugin behavior without the doc mirror leaves the canonical source describing behavior that no longer matches the implementation.
- **Evidence:** JD-001; `CLAUDE.md` lines on the docs convention.
- **Rejected alternatives:**
  - Defer docs to a follow-up branch. Rejected because the canonical source would be stale on `main` between the two branches, and the repo convention treats the long-form doc as authoritative for what the skill does.
  - Update only `docs/skills/code-review.md`, leave the agent docs unchanged. Rejected because D-4's dispatcher-directive scope is a notable shift in how `/code-review` uses the four agents and the agent docs need a one-paragraph note about it.
- **Specialist owner:** `project-manager`.
- **Revisit criterion:** A future branch demonstrates that splitting docs from plugin edits is operationally cheaper, in which case the convention should be re-examined.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Decomposition and Sequencing, Definition of Done.

### D-8: Add `Bash(gh *)` to SKILL.md `allowed-tools` frontmatter

- **Question:** Does S6's `gh pr view` call require a frontmatter change to `plugin/skills/code-review/SKILL.md`?
- **Decision:** Yes. Add `Bash(gh *)` to the `allowed-tools` field at SKILL.md line 6. The new value reads `allowed-tools: Bash(git *), Bash(gh *), Bash(make *), Bash(npm *), Read, Grep, Glob, Agent`.
- **Rationale:** OQ-4 resolution from R1. JD-013 verified by grep that the current frontmatter does not include `Bash(gh *)`; without the permission, S6's branch-context loader cannot call `gh pr view` and fails the Mode A path silently.
- **Evidence:** JD-013; `plugin/skills/code-review/SKILL.md:6` (verified during R1).
- **Rejected alternatives:**
  - Skip `gh pr view` and read PR descriptions only from local `pr-body` files. Rejected because Mode A (the dominant user path) routinely has no local `pr-body` file; the live PR description is what the user wants loaded.
  - Use a shell-out via `Bash(*)`. Rejected because the plugin's other skills scope tools narrowly and `Bash(*)` is a broader grant than needed.
- **Specialist owner:** `devops-engineer` (callable on dispatch); the change itself is a frontmatter edit.
- **Revisit criterion:** A user environment exists where `gh` is not installed, in which case S6's fail-open behavior (D-9) covers the gap and no further change is needed; but if the failure mode is silent and undiagnosable, revisit.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** D-9.
- **Referenced in plan:** Implementation Approach (Architecture and Integration Points), Definition of Done.

### D-9: S6 fail-open behavior prints a visible warning when no PR or branch context loads

- **Question:** When S6's branch-context loader cannot retrieve a PR description (no `gh` available, no PR open, no local `pr-body` file, no planning doc), does the skill proceed silently or warn the user?
- **Decision:** Fail open with a visible warning. When none of the four context sources (PR description via `gh pr view`, local `pr-body` file, commit messages, planning-directory implementation plan) returns content, Step 1.5 emits a single-line warning to the orchestrator's output: `Branch Context: no PR or planning artifact found; agents will run without branch-level context.` The skill proceeds with `$branch_context` bound to the literal string `none provided`.
- **Rationale:** BA-2 surfaced this. A silent fail-open reproduces the C5/C6 failure (context not forwarded) without telling the user the loader was tried and missed; a hard fail blocks the whole review when the loader is non-essential.
- **Evidence:** BA-2; investigation C5, C6.
- **Rejected alternatives:**
  - Silent fail-open. Rejected because the user has no signal that context loading was attempted and missed; the failure mode is the same as no S6 at all.
  - Hard fail. Rejected because Mode B and Mode C legitimately have no PR or planning artifact; treating that as a blocker breaks the local-review path.
- **Specialist owner:** `behavioral-analyst`.
- **Revisit criterion:** A user reports the warning is noisy in Mode B/C, in which case the warning can be gated on Mode A.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Definition of Done.

### D-10: S6 planning-directory lookup uses a structured CLAUDE.md key with Glob fallback

- **Question:** How does S6 locate an implementation plan or design doc for the current branch?
- **Decision:** S6's planning lookup reads CLAUDE.md for a structured key, then falls back to a Glob search. The lookup order: (a) parse `## Project Discovery` for a `plans:` or `planning:` key naming the planning directory (e.g., `plans: docs/plans/`); (b) if no key, Glob `docs/plans/*/feature-implementation-plan.md` and `plans/*/feature-implementation-plan.md`; (c) if Glob returns multiple, match the branch name (with `-` and `_` interchangeable) against the directory names; (d) if no match, log "no planning artifact found for branch {name}" to the agent's output and proceed.
- **Rationale:** BA-8 named the structured-key-with-fallback pattern as the closest match to the existing Step 1 project-config resolution. The two-tier approach gives projects with a CLAUDE.md a deterministic answer and degrades gracefully for projects without one.
- **Evidence:** BA-8; existing Step 1 project-config resolution pattern in SKILL.md.
- **Rejected alternatives:**
  - Glob only, no CLAUDE.md key. Rejected because projects with non-standard planning directories (e.g., `internal-docs/proposals/`) have no signal to the loader.
  - Require the CLAUDE.md key, hard fail without it. Rejected because most repos don't yet have the key; hard fail blocks adoption.
- **Specialist owner:** `behavioral-analyst`.
- **Revisit criterion:** Three or more user reports show the Glob fallback hits wrong directories, in which case the key becomes required.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior).

### D-11: S7 updates three YAGNI-bearing locations in SKILL.md, not two

- **Question:** Where does the rewritten YAGNI two-pass procedure land, in `review-checklist.md` only, or in additional SKILL.md sites?
- **Decision:** Three locations are updated. (1) `plugin/skills/code-review/references/review-checklist.md` YAGNI section: the bullet list becomes a two-pass procedure (evidence test, then anti-pattern check). (2) `plugin/skills/code-review/SKILL.md` Step 3.3 calibration directive: replace the existing YAGNI block with a reference to the two-pass procedure and a reference to Step 3.3's size-based demotion (D-1). (3) `plugin/skills/code-review/SKILL.md` Review Constraints section (lines 29–41): the YAGNI-related bullets are rewritten to reference the two-pass procedure rather than restating it.
- **Rationale:** JD-010 surfaced the third location (Review Constraints) that the investigation's S7 missed. Leaving it un-rewritten reproduces the "calibration is defined once and bypassed everywhere else" failure pattern that D-1 targets.
- **Evidence:** JD-010; investigation S7; `plugin/skills/code-review/SKILL.md` Review Constraints section.
- **Rejected alternatives:**
  - Two-location rewrite (review-checklist.md + Step 3.3 only). Rejected because the Review Constraints section also carries YAGNI-shaped rules and would drift.
  - Single-location rewrite (review-checklist.md only). Rejected because Step 3.3 governs the agent prompts at Step 3.5 and the procedure must apply there as well.
- **Specialist owner:** `junior-developer`.
- **Revisit criterion:** A future review surfaces YAGNI-shaped findings firing at one of the un-rewritten sites, indicating the rewrite missed a location.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-12: S8 runs an extraction pass before pair comparison, scoped to overlapping line ranges only

- **Question:** How does S8 (self-consistency check on findings) actually detect contradictory findings, and what is its scope?
- **Decision:** S8 runs in two passes inside Step 9. **Extraction pass:** for every finding, extract a tuple `{task-id, file-path, line-range, recommended-action-summary}`. **Comparison pass:** for every pair of tuples on the same `file-path` with overlapping `line-range`, check whether the two `recommended-action-summary` values prescribe opposite actions on the same code. If yes, both findings are demoted by one severity and each carries a `Tension with {other-task-id}:` note that the human must adjudicate. Scope is overlapping line ranges in a single file only; cross-file semantic contradictions are deferred (see plan's Deferred section).
- **Rationale:** BA-6 named the extraction pass as a precondition for the comparison; JD-015 named the scope limitation. The PR 339 WARN-002/WARN-003 case (the bundle's "most instructive single moment" per the investigation) falls inside the overlapping-line-range scope.
- **Evidence:** BA-6; JD-015; PR 339 E10–E13.
- **Rejected alternatives:**
  - Direct pairwise comparison without extraction. Rejected because BA-6 noted the unstructured finding text resists naive comparison.
  - Cross-file semantic contradiction detection. Rejected as YAGNI (Gate 1 evidence test fails; no documented incident beyond the PR 339 single-file class).
- **Specialist owner:** `behavioral-analyst`.
- **Revisit criterion:** A real review surfaces a cross-file contradictory finding pair the line-range detector misses, in which case the scope widens.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing, Deferred (YAGNI).

### D-13: S9 requires reading at least one architectural file before raising a "violates standard X" finding

- **Question:** How is S9's premise-verification actually enforced, by inferring premises from a standard's own examples (the investigation's original framing), or by a stronger requirement?
- **Decision:** Before raising any "violates standard X" finding in Step 5, the orchestrator (or the dispatched agent for documentation-compliance work) must read at least one architectural file demonstrating the standard's premise. The file class depends on the standard's topic: an entry-point file for runtime-shape standards, a router or navigation surface for routing standards, a config file for configuration standards. The "infer from examples" fallback becomes an explicit "premise not verified; finding omitted" log line rather than a forward path to raising the finding.
- **Rationale:** OQ-7 resolution from R1. JD-012 identified that "infer from examples" is the failure mechanism, not a fix, it lets the agent fabricate a premise that does not hold in the codebase (PR 307's SPA-style company switch finding against a full-page-redirect codebase).
- **Evidence:** JD-012; PR 307 E2; PR 299 E1.
- **Rejected alternatives:**
  - Keep "infer from examples" as a forward path. Rejected because PR 307's WARN-003 demonstrates this path produces false positives.
  - Require reading three architectural files. Rejected because one architectural file is sufficient to confirm or deny the premise; three is operational drag without evidence the marginal files reduce false positives.
- **Specialist owner:** `software-architect`.
- **Revisit criterion:** A post-ship review still raises a standards-compliance finding against a codebase whose architecture does not match the standard's premise, despite the architectural-file read having been logged.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-14: `$focus_areas` and `$branch_context` are explicit named bindings populated by Steps 1 and 1.5

- **Question:** How are focus-area text and branch-context text actually plumbed from Step 1 / Step 1.5 to Step 3.5's agent prompts?
- **Decision:** Two named bindings carry the values. `$focus_areas` is populated at Step 1 from the user's invocation arguments. `$branch_context` is populated at Step 1.5 by S6's branch-context loader. Both default to the literal string `none provided` when empty. Every Step 3.5 agent prompt template references the bindings by name in the new "Focus areas" and "PR / branch context" blocks added by S5.
- **Rationale:** BA-1 (and JD-003, JD-004 corroborating) noted that the plan as written relied on LLM context-window retention to carry values across three steps. Named bindings make the dependency explicit and survive context compaction.
- **Evidence:** BA-1; JD-003; JD-004.
- **Rejected alternatives:**
  - Implicit context-window retention. Rejected because the plan cannot guarantee Step 1's notes survive to Step 3.5 across long agent dispatches.
  - A single combined `$context` binding. Rejected because focus areas (user-authored) and branch context (loader-authored) have different provenance and the prompt blocks need to label them separately.
- **Specialist owner:** `behavioral-analyst`.
- **Revisit criterion:** A test run shows the bindings are still being lost across step boundaries, in which case a stronger plumbing mechanism is needed.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

### D-15: `{size}` value is read from Step 3.1; all five consumer sites reference Step 3.1 explicitly

- **Question:** Where does the `{size}` variable used by the new size-aware rubric, the rewritten line 24, Step 7's sub-steps, and the YAGNI two-pass procedure come from?
- **Decision:** `{size}` is set once at Step 3.1 (size detection) and the five consumer sites that read it (the rewritten line 24, Step 3.3 directive, Step 3.5 agent prompts, Step 7.2 sub-step, and the rewritten rubric in `agent-finding-classification.md`) all reference Step 3.1 explicitly as the source. No site reads `{size}` from ambient context.
- **Rationale:** BA-3 named the single-source-of-truth requirement. Sites reading `{size}` from ambient context risk drift when the detection logic changes.
- **Evidence:** BA-3; `plugin/skills/code-review/SKILL.md` Step 3.1.
- **Rejected alternatives:**
  - Implicit ambient `{size}`. Rejected because the rubric file is consulted across step boundaries and ambient context is unreliable.
- **Specialist owner:** `behavioral-analyst`.
- **Revisit criterion:** A future change moves size detection to a different step, in which case the reference is updated globally.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior).

### D-16: Defer S12 (default suppression for small changes) as YAGNI

- **Question:** Does the user-facing workaround "WARN-justified, SUGG suppressed per reviewer instruction" become an explicit default mode flag (S12)?
- **Decision:** Defer S12. Once S1 + S2-merged-with-S10 + S13 ship and the rubric is size-aware, S12's behavior is subsumed: small changes already produce no Suggestions per Step 3.3, and warnings already demote on reachability phrases. The dedicated suppression flag becomes redundant.
- **Rationale:** OQ-6 resolution from R1, with consensus across SA-6, BA-9, and JD-006. Gate 2 simpler-version test: S1 + S2 + S13 satisfy the same evidence (PR 299 E17's "WARN-justified, SUGG suppressed" workaround), and the simpler version is "fix the calibration so the workaround is unnecessary".
- **Evidence:** SA-6, BA-9, JD-006; PR 299 E17.
- **Rejected alternatives:**
  - Ship S12 as a dedicated mode flag. Rejected because the simpler version satisfies the same evidence.
- **Specialist owner:** `project-manager`.
- **Revisit criterion:** Post-ship validation against PR 299 still produces severity inflation that requires a SUGG-suppress mode flag, in which case S12 is reopened.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Deferred (YAGNI).

### D-17: Em-dash strip policy on verbatim copy from the investigation

- **Question:** The investigation document uses em-dashes throughout; can verbatim text be copied into shipped files (SKILL.md, agent prompts, classification rubric, review checklist) as-is?
- **Decision:** No. Every verbatim text copy from the investigation into a shipped file under `plugin/` or `docs/` must have em-dashes stripped per `docs/writing-voice.md`. The replacement uses commas, semicolons, parentheses, or restructured sentences depending on the local rhythm. A pre-commit visual review for em-dashes is added to the Definition of Done.
- **Rationale:** JD-009 surfaced the hazard. `docs/writing-voice.md` is the canonical voice rule; the investigation does not follow it because the investigation is not shipped.
- **Evidence:** JD-009; `docs/writing-voice.md`.
- **Rejected alternatives:**
  - Allow em-dashes in shipped files when the surrounding paragraph is verbatim from the investigation. Rejected because the voice rule applies to shipped content regardless of source.
- **Specialist owner:** `project-manager`.
- **Revisit criterion:** None; the voice rule is project-wide.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Definition of Done.

### D-18: S4's constraint is narrower for `edge-case-explorer` than for `junior-developer`

- **Question:** When S4 (scoped-file-list constraint) lands as a Step 3.5 dispatcher directive, is the wording identical for both `junior-developer` and `edge-case-explorer`, or differentiated?
- **Decision:** Differentiated. For `junior-developer`, the dispatcher adds the unmodified investigation rule: outward reads are for context, findings must concern files on the scoped list. For `edge-case-explorer`, the dispatcher adds a narrower rule: findings must ultimately trace to a failure mode in code on the scoped file list, even when callers outside the list provide the evidence. The narrower wording for `edge-case-explorer` preserves the agent's Protocol 1 callers-read while making the scope rule about the failure-mode target, not the evidence source.
- **Rationale:** JD-008 surfaced that the agent's Protocol 1 explicitly reads callers as evidence for the target code's edge cases; a flat "findings must concern files on the scoped list" rule would suppress legitimate findings traced from caller behavior to scoped-file failure modes.
- **Evidence:** JD-008; `plugin/agents/edge-case-explorer.md` Protocol 1.
- **Rejected alternatives:**
  - Identical wording for both agents. Rejected because the agents' protocols are not symmetric; one reads adjacent patterns as context, the other reads callers as evidence.
- **Specialist owner:** `junior-developer`.
- **Revisit criterion:** A `edge-case-explorer` dispatch under the narrower rule still produces out-of-scope findings, or suppresses legitimate ones.
- **Dissent (if any):** None.
- **Driven by rounds:** R1.
- **Dependent decisions:** None.
- **Referenced in plan:** Implementation Approach (Runtime Behavior), Decomposition and Sequencing.

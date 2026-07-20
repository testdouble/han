# Implementation Iteration History: Plugin-Centric Documentation Reorganization

<!--
Records how the implementation plan evolved across discussion rounds. Committed decisions live in
[implementation-decision-log.md](implementation-decision-log.md); the primary plan lives in
[../feature-implementation-plan.md](../feature-implementation-plan.md). Per-round aggregation was deterministic (no PM
facilitation call — the spec-maturity gate did not trip). `Decisions produced:` and `Changed in plan:` are backfilled
during synthesis.
-->

## R1: Parallel specialist review (small team, single round)

- **Specialists engaged:** `han-core:information-architect`, `han-core:junior-developer`. (`han-core:project-manager`
  reserved for Step 8 synthesis; not called this round — the spec-maturity gate did not trip.)
- **New input provided:** the feature specification, its decision log, team-findings, and technical notes (T1), plus the
  Step 2 discovery notes (current 62-doc layout, destination layout, the link-topology mapping table, the
  10-READMEs-to-create finding, the D9 update set, and the no-link-checker gap).
- **Claim ledger:**

  | # | Claim | Raised by | State | Category | Spec-maturity |
  | - | ----- | --------- | ----- | -------- | ------------- |
  | C1 | Implement in dependency tiers: standards → move+recompute → author READMEs → workflows → slim indexes → convert plugin index → update blast radius → run gate. A link target must exist at its final path before any referrer is rewritten (D15/D16). | IA (IA-IMPL-1), JD (JD-2, JD-3) | Evidenced (D16, D9, D15, F3) | sequencing/overlap | plan-level |
  | C2 | The D18 standard + template rewrite is a hard prerequisite to authoring the 11 READMEs; authoring against the on-disk heavy standard reproduces the duplication the reorg removes. | IA (IA-IMPL-4), JD (JD-2-A) | Evidenced (`docs/plugin-readme.md:107-146`, D3, D18, F1) | sequencing | plan-level |
  | C3 | The 10 fresh READMEs must exist before/with the moves, because D14 makes each moved doc's first up-link point at its adjacent plugin README — absent READMEs = broken links failing D16. | JD (JD-2-B), IA (IA-IMPL-1) | Evidenced (D14, F10) | sequencing | plan-level |
  | C4 | Three-index model resolves only if root README + both indexes explicitly label the choosing doc "the plugin index"; `docs/workflows.md` needs exactly four inbound links (root README + both indexes + plugin index) or it near-orphans. | IA (IA-IMPL-2, IA-IMPL-3) | Evidenced (F11, F8, D4, D6) | overlap | plan-level |
  | C5 | Concrete light-README skeleton (what/how/why → bundled-vs-opt-in + deps → skills scent list → agents section only for han-core/han-communication else shared-agent note → lateral nav); han-core groups by purpose (D12); meta-plugin omits skills/agents (D17). | IA (IA-IMPL-4) | Evidenced (D3, D13, D8, D12, D15, D17) | authoring model | plan-level |
  | C6 | Exact nav strings/depths verified (up-link `../../README.md` then `../../../README.md`; SKILL/refs shorten). The skill/agent long-form templates + coverage-rule encode the OLD first-bullet-to-root convention and old paths — must be updated or every future doc regresses the convention. | IA (IA-IMPL-5, IA-IMPL-6) | Evidenced (D14, F10, `coverage-rule.md:7-11`) | edge-case | plan-level |
  | C7 | Link recompute is unsafe by naive `git mv`+path-substitution; safe mechanic is resolve-each-link-to-absolute-then-re-express-relative for the doc's NEW location, accounting for targets that also moved. At ~1,500–2,500 link edits across 62 files it needs a one-time migration script (load-bearing, not YAGNI). | JD (JD-1) | Evidenced (D16 rejected alt; measured 39 links in code-review.md, 21 in project-manager.md; topology table) | mechanic | plan-level |
  | C8 | Acceptance gate = one-time verification, not a permanent CI checker. Add an orphan/reachability pass and a literal-string grep (a relative-link resolver misses absolute GitHub blob URLs like the one in the PR template). | IA (IA-IMPL-7, IA-IMPL-9), JD (JD-4) | Evidenced (D16 wording, no-tooling gap, `pull_request_template.md:5`, F8) | YAGNI-candidate + edge-case | plan-level |
  | C9 | Scent-drift (D15's three copies) stays a behavioral authoring rule; no scent-diff linter. | IA (IA-IMPL-8) | Evidenced (D15 "without tooling") | YAGNI-candidate | plan-level |
  | C10 | The change cannot be cleanly staged per-plugin (cross-plugin link web + no CI checker means a half-done state silently ships broken links). Land as one atomic PR including workflows + its inbound links. | JD (JD-3) | Evidenced (topology table, no-CI-checker gap, D6/D8/F8) | sequencing | plan-level |
  | C11 | `.github/pull_request_template.md` carries live old-path contributor guidance + an absolute blob URL and must be in the D9 update set; the regenerated scan must cover `.github/`. | JD (JD-5) | Evidenced (`pull_request_template.md:5,19,20`) | scope | plan-level |
  | C12 | The frozen-archive exclusion (D10: `docs/plans/**`, `docs/research/**`) must be enforced mechanically in both the migration file-selection and the verification grep, not left implicit. | JD (JD-5) | Evidenced (D10) | edge-case | plan-level |
  | C13 | Is `CHANGELOG.md` in scope (rewrite old paths) or frozen like the archives? D10 names only `docs/plans/`/`docs/research/`. | JD (JD-5 / OQ-1) | Resolved by evidence (see OQ-1) | scope | spec-level |

  No `Disputed` rows — the two specialists agreed everywhere they overlapped. No `Anecdotal` rows survived.
- **Open Questions raised:**
  - **OQ-1 (spec-level):** Is `CHANGELOG.md` in scope for path rewriting, or frozen as a point-in-time record?
    **Resolved by evidence — treat as frozen.** Three convergent supports: (a) D10's freeze rationale ("point-in-time
    records") applies to a changelog by definition, and its edge-case row leaves such archives' stale paths unrewritten;
    (b) the maintenance tooling already maps `CHANGELOG.md → ignore (out of scope)` in
    `.claude/skills/han-update-documentation/references/scope-mapping.md`; (c) rewriting a historical release entry's
    paths to files that did not exist at that release would falsify the record. Consequence: CHANGELOG is excluded from
    both the rewrite set AND the literal-string link gate (its old-path strings are expected and not failures). The user
    can override this scope call; it is recorded as a decision, not a silent omission.
- **Spec-maturity tags:** plan-level — C1–C12 (12). spec-level — C13/OQ-1 (1, resolved by evidence). T#-contradiction —
  none. **Spec-maturity gate did NOT trip** (needs ≥5 spec-level from ≥3 specialists, or ≥2 T#-contradictions from ≥2
  specialists; observed 1 spec-level from 1 specialist, 0 T#-contradictions).
- **Resolution source:** OQ-1 → evidence (settled in the loop by re-reading D10, the spec Out-of-Scope/edge-case rows,
  and `scope-mapping.md`). All other claims are plan-level operationalizations carried directly into synthesis; none
  required junior-developer reframing or user input.
- **Decisions produced:** ID1, ID2, ID3, ID4, ID5, ID6, ID7, ID8
- **Changed in plan:** Implementation Approach, Decomposition and Sequencing, Testing Strategy, Operational Readiness,
  Deferred (YAGNI), Open Items
- **Project-manager next-step recommendation:** Go to synthesis. (Small-team round cap = 1; gate not tripped; no
  unresolved plan-level Open Questions; the one conditional handoff JD named — `devops-engineer`, only if a permanent CI
  link-checker is chosen — is not triggered, because the YAGNI resolution keeps verification one-time.)

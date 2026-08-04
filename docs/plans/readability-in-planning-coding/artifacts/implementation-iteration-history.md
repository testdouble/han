# Implementation Iteration History

Round-by-round record for [../feature-implementation-plan.md](../feature-implementation-plan.md). Decisions live in
[implementation-decision-log.md](implementation-decision-log.md).

## R1

- **Mode:** team (small); **Round cap:** 1
- **Specialists engaged:** han-core:junior-developer, han-core:test-engineer (han-core:project-manager runs synthesis in
  Step 8)
- **New input provided:** the feature spec, decision log, and `.discovery-notes.md` (insertion points per skill, the
  canonical pattern, non-skill edits).

### Claim ledger

| # | Category | Claim | Supporting specialists | State | Spec-maturity |
|---|----------|-------|------------------------|-------|---------------|
| C1 | sequencing | Land the D9 rule-text clarification before the 7 skill edits, so the canonical standard does not textually contradict them mid-implementation. | junior-developer | Evidenced (`readability-rule.md:20-23`) | plan-level |
| C2 | sequencing | Land the D4 `han-planning` dependency no later than the five planning-skill edits (ideally first). | junior-developer | Evidenced (`han-planning/.claude-plugin/plugin.json:5`) | plan-level |
| C3 | consistency | Freeze two canonical snippets (FULL, LIGHTWEIGHT) and vary only the named reader (D5) and excluded citation-ID tokens; verify with a post-edit grep. Prevents drift across 7 files. | junior-developer | Evidenced (`investigate` Step 5, `issue-triage:30`) | plan-level |
| C4 | process | The CLAUDE.md mandate routes through han-plugin-builder **Guidance Mode** (consult skill-composition, agent-dispatch-namespacing, writing-effective-instructions, claude-marketplace-and-plugin-configuration), NOT skill-builder or `guidance init`. | junior-developer | Evidenced (guidance docs confirmed to exist) | plan-level |
| C5 | prerequisite | All 7 skills already grant `Agent`; no tool-grant change. `readability-guidance` needs no `Skill` grant (invoked from instruction text). | junior-developer, test-engineer | Evidenced (`allowed-tools` on all 7; T14) | plan-level |
| C6 | verification | Definition of done is a deterministic grep/jq acceptance checklist (T1-T17) plus one smoke run, since no test harness exists. plugin.json gets free JSON lint via prek/Prettier; Markdown is deliberately unlinted. | test-engineer | Evidenced (`.pre-commit-config.yaml`; T1-T17) | plan-level |
| C7 | correctness | Editor dispatch must sit strictly between each full-pattern skill's final-content step and its present step (D6 ordering), be absent from the 2 lightweight skills (D2), pass the named reader and no rule path (D3/D5). | test-engineer | Evidenced (T5, T6, T7) | plan-level |
| C8 | correctness | Prose-region exclusions must name each skill's own ID scheme (D-N for plan-implementation, W-N, TP-NNN, D#/T#/F#); coding-standard frontmatter untouched and self-check mode-conditional; iterative-plan-review self-check inserted once, not per loop. | test-engineer | Evidenced (T11, T12, T13) | plan-level |
| C9 | YAGNI | Do not run all-7 end-to-end dry runs (S1), build a prose-lint tool (S2), or run the full builder/init flow — a grep checklist + one smoke run + guidance consult suffice. | test-engineer, junior-developer | Evidenced (S1, S2) | plan-level |

### Open Questions

- **OQ-1 (Q4): atomic PR vs incremental commits.** Resolved by user directive "commit and push as you go" → incremental,
  sequenced so the D9 rule clarification and the D4 dependency land before the skill edits that rely on them.
  Resolution source: user input.
- Evidence checks run this round (resolving JD's residual guards): the carve-out phrase appears only in
  `readability-rule.md` (no other doc paraphrases it, so D9's two edits cover every surface); the `han` meta-plugin
  already bundles `han-planning` and declares `han-communication` directly, so no meta-plugin or marketplace change.

### Spec-maturity gate

Not tripped: 0 `T#`-contradictions (no `T#` notes exist), 0 `spec-level` findings, no security/PII surface. All findings
are `plan-level` and `Evidenced`.

### Next-step recommendation

**Go to synthesis.** One round, all findings evidenced and plan-level, the single Open Question resolved by user
directive.

- **Decisions produced:** D-1 (edit sequencing, from C1/C2/OQ-1), D-2 (two frozen snippets, from C3), D-3 (Guidance-Mode
  consult, from C4), D-4 (grep/jq checklist + one smoke run, from C6/C9), D-5 (plugin.json dep order + no version bump,
  from C2), D-6 (readability-guidance restatement is new text, from F13).
- **Changed in plan:** initial authoring of every section — Outcome, Context, Team Composition and Participation,
  Implementation Approach, Decomposition and Sequencing, RAID Log (Assumptions), Testing Strategy, Definition of Done,
  Specialist Handoffs for Implementation, Deferred (YAGNI), Open Items, Summary.

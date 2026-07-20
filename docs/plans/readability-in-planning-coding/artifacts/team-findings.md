# Team Findings: Readability Standard in the Planning and Coding Skills

Records every finding raised by the review team and how each was resolved. Behavioral outcomes live in
[../feature-specification.md](../feature-specification.md); decisions the findings affected live in
[decision-log.md](decision-log.md). Reviewers: `han-core:junior-developer` (JD-*) and `han-core:gap-analyzer` (GAP-*).

## Major findings

### F1: The standard's own scope text excludes the seven artifact types

- **Agent:** junior-developer (JD-007 restatement), gap-analyzer (GAP-001)
- **Finding:** `readability-rule.md` lines 20-23 say a "structured specification / plan / work-item / standard consumed
  mainly by downstream skills" is not reader-facing and does not apply the rule. All seven targets produce those exact
  artifact types, so the standard's own text reads as excluding them.
- **Resolution:** Escalated to the user. User chose to keep all seven in scope and add a narrow clarification to the
  scope text so a human-read plan-of-record is distinguished from a pure pipeline artifact. Captured as D9; the rule
  clarification is now an in-scope deliverable and the Out of Scope section was narrowed accordingly.
- **Resolved by:** user input
- **Affected decisions:** D9 (new)
- **Changed in spec:** Outcome, Coordinations, Out of Scope, Summary

### F2: "No dependency change" holds only for direct han-communication dependents

- **Agent:** junior-developer (JD-001), gap-analyzer (GAP-002)
- **Finding:** `han-planning` depends only on `han-core`, reaching `han-communication` transitively. Every plugin whose
  skills invoke `readability-guidance` today depends on `han-communication` directly, and Han's convention requires it.
  The original D4 ("no dependency changes") was untested for the five planning skills.
- **Resolution:** Add a direct `han-communication` dependency to `han-planning`. Verified `han-coding` already declares
  it and all seven skills already grant `Agent`. D4 rewritten from a trivial decision to a full decision.
- **Resolved by:** evidence
- **Affected decisions:** D4
- **Changed in spec:** Actors and Triggers

### F3: The "synthesis skill" classifier misclassifies plan-work-items

- **Agent:** junior-developer (JD-002), gap-analyzer (GAP-005, GAP-006)
- **Finding:** D2's original rationale keyed the full/lightweight split on running an agent or project-manager synthesis
  pass. But `plan-work-items` runs a project-manager synthesis yet was placed lightweight, and three of the five
  full-pattern skills self-author and dispatch only a review agent. The stated test contradicts the chosen split.
- **Resolution:** Kept the user's 5/2 split but reframed D2's criterion as deliverable type — a prose-heavy document read
  end to end (full) versus an itemized or in-place-edited artifact (lightweight). The split is unchanged; the rationale
  is now internally consistent.
- **Resolved by:** evidence
- **Affected decisions:** D2
- **Changed in spec:** Outcome, Primary Flow, Alternate Flows and States

### F4: Sourcing the standard into the skill's context does not reach a dispatched agent's content

- **Agent:** junior-developer (JD-003)
- **Finding:** For skills where a dispatched agent authors the final content (`plan-a-feature` Step 8 project-manager;
  `plan-work-items` Step 5 project-manager), "draft in voice" cannot be fulfilled because the standard lives in the
  skill's context, not the agent's. For lightweight `plan-work-items` the self-check is then the only lever, applied to
  content the skill returns from the agent.
- **Resolution:** Clarified that the after-the-fact pass carries voice into agent-authored content — the editor pass for
  the five prose-document skills, the self-check for the two structured-artifact skills. Captured in D6 and the Primary
  Flow (step 2) and Edge Cases.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F5: In-place skills' self-check scope was contradictory

- **Agent:** junior-developer (JD-004, JD-005)
- **Finding:** The spec said the self-check runs on the "converged plan" (whole document) but also that each skill covers
  only "the regions it authors." For in-place editors (`iterative-plan-review`; `coding-standard` update mode) those are
  different sets, and a whole-document pass would re-edit already-approved prose.
- **Resolution:** Scoped the pass to the prose the skill authors or changes this run. For in-place editing, the pass runs
  on the changed regions of the converged document. Captured in D5 and the "in-place skill edits an existing document"
  alternate flow.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Changed in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### F6: Ordering versus each skill's existing review/IA steps was unspecified

- **Agent:** gap-analyzer (GAP-007)
- **Finding:** `plan-a-phased-build`, `coding-standard`, and `test-planning` already run review or IA steps near the end
  of their workflows. The spec fixed ordering only for `plan-a-feature`'s project-manager synthesis, leaving the others
  undefined.
- **Resolution:** Generalized D6 so the readability pass runs after the skill's final content-producing step, whatever
  its name, and before presenting.
- **Resolved by:** evidence
- **Affected decisions:** D6
- **Changed in spec:** Edge Cases and Failure Modes

### F7: plan-a-phased-build already collects a per-run audience

- **Agent:** gap-analyzer (GAP-008)
- **Finding:** `plan-a-phased-build` asks the user which audience the outline targets (engineering, mixed, or
  customer-facing). The original D5 hardcoded a single "stakeholder" frame for it.
- **Resolution:** D5 updated so `plan-a-phased-build` holds the per-run audience it already collects, rather than a fixed
  frame.
- **Resolved by:** evidence
- **Affected decisions:** D5
- **Changed in spec:** Edge Cases and Failure Modes

## Minor edits

- F8: The editor is dispatched with the named reader and no rule path (it reads its own canonical rule); prose-regions
  exclusion list extended to include frontmatter and work-item IDs — gap-analyzer (GAP-003, GAP-009) — Primary Flow,
  Coordinations, D3.
- F9: Named audience (D5) threaded explicitly into the editor dispatch and self-check steps — gap-analyzer (GAP-004) —
  Primary Flow.
- F10: `markdown-to-confluence` moved to the genuinely-not-applicable bucket (republishes user prose verbatim); Out of
  Scope list marked illustrative, not exhaustive — junior-developer (JD-006), gap-analyzer (GAP-010) — Out of Scope, D8.
- F11: The 38-skill survey persisted into D8's Evidence field so scope is auditable — junior-developer (JD-007) — D8.
- F12: Softened "byte-for-byte" phrasing and moved standard-file locators out of behavioral sentences — junior-developer
  (JD-009) — Edge Cases, Coordinations.

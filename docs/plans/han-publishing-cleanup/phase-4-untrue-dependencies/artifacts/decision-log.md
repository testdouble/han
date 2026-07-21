# Decision Log: Remove the Untrue Dependency Declarations

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-4-untrue-dependencies/`, nested
  beside the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: What is removed and what stays

- **Question:** Which declarations are deleted, and what evidence gates the deletion?
- **Decision:** Three declarations are removed: the Reporting plugin's, the Feedback plugin's, and the Linear plugin's
  claims on the Core plugin. The Reporting plugin keeps its Communication dependency; the Feedback and Linear plugins
  are left depending on nothing, a supported state with two shipped precedents. A pre-start check re-confirms none of
  the three reaches the Core plugin through any path; if a real path is found, the removal stops for that plugin.
- **Rationale:** The source analysis found the first two claims decorative. Review of this phase applied the same
  evidence test to the Linear plugin and found the same absence, plus its own long-form doc stating the skill
  dispatches no agents; leaving the declaration while correcting the page that claims it would create a fresh
  docs-versus-declaration contradiction. The user chose to remove it in the same pass (2026-07-21).
- **Evidence:** Codebase: `han-reporting/.claude-plugin/plugin.json` declares `["han-communication", "han-core"]`
  while `grep -rn "han-core" han-reporting/skills/` returns nothing; `han-feedback/.claude-plugin/plugin.json`
  declares `["han-core"]` while the only `han-core` strings in `han-feedback/skills/` are naming-convention text;
  `han-linear/.claude-plugin/plugin.json` declares `["han-core"]` while
  `han-linear/skills/work-items-to-linear/SKILL.md` references no other plugin and
  `han-linear/docs/skills/work-items-to-linear.md` line 156 states "The skill dispatches no agents." Zero-dependency
  precedent: `han-communication` and `han-plugin-builder` both declare no dependencies and ship. Source analysis:
  "The dependency graph: two threads to snip" in
  [`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#the-dependency-graph-two-threads-to-snip). User
  input: the third removal (2026-07-21).
- **Rejected alternatives:**
  - Exactly two removals per the outline, Linear deferred to its own decision — rejected by the user; the evidence was
    already in hand and deferral would ship a known contradiction.
  - Keeping the Linear declaration and documenting why it is real — rejected because the review found no positive
    evidence of reality to document.
  - Also auditing and trimming other plugins' declarations — rejected because the source analysis verified the rest
    of the graph as true and this phase's review surfaced no further decorative claim.
- **Linked technical notes:** —
- **Driven by findings:** F3 (the Linear contradiction), F6 (the zero-dependency precedent citation)
- **Dependent decisions:** D3, D4
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow

### D3: Declarations and documentation change together

- **Question:** Is deleting the declaration lines enough, or do the documentation surfaces that repeat them change
  too, and which are they?
- **Decision:** They change in the same commit. The audited claiming surfaces are twenty-one locations across eight
  files, and completion is verified by searching the documentation for the Core plugin's name and reviewing every
  hit: each must be a true statement about a plugin keeping the dependency, or one of the Feedback plugin's excluded
  naming-convention examples. Grouped sentences covering removed and kept dependencies are edited so the kept ones
  stay correctly described.
- **Rationale:** The phase's payoff is trust. The initial enumeration (seven surfaces) missed fourteen; the audit
  found claims in the contributor guide, the concepts doc, the versioning doc, the dependency how-to guide, the
  marketplace listing descriptions, and second untrue dispatch claims on two front-door pages. A search-and-review
  acceptance check is repeatable; a memorized list is not.
- **Evidence:** Content audit (this phase's review): claims at `han-reporting/README.md:8,20`,
  `han-feedback/README.md:8,15`, `han-linear/README.md:8,16`, the three `.claude-plugin/plugin.json` declarations
  (and `han-linear`'s description field), `CLAUDE.md:21,100,107,142`, `CONTRIBUTING.md:129-130`,
  `docs/concepts.md:224,232`, `docs/semantic-versioning.md:100`,
  `docs/how-to/extend-han-with-plugin-dependencies.md:136,164,169,192`, `docs/choosing-a-han-plugin.md:43,45,50,64`,
  and `.claude-plugin/marketplace.json:67`. Exclusion: the naming-convention examples in
  `han-feedback/skills/han-feedback/SKILL.md` must not change.
- **Rejected alternatives:**
  - Declarations first, documentation in a follow-up — rejected because the interim state reintroduces exactly the
    docs-say-one-thing-system-does-another problem this cleanup exists to end.
  - Verifying by the enumerated list alone — rejected because the list was already proven incomplete once; the search
    is the acceptance check, the list is the work plan.
- **Linked technical notes:** —
- **Driven by findings:** F1, F2, F4, F5, F8
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; Coordinations

### D4: Linear page reconciliation

- **Question:** The Phase 1 spec handed off an open item: the Linear plugin's front-door page says its skills dispatch
  shared agents from other plugins, while its skill content dispatches none. Where does that get fixed?
- **Decision:** Here, paired with the removal of the Linear plugin's declaration under D2, so the page and the
  declaration end the phase agreeing with each other and with the skill's real behavior.
- **Rationale:** This phase is the cleanup's dependency-truth work, and the Phase 1 spec routed the item here
  explicitly. Fixing the page alone would have contradicted the surviving declaration; D2's third removal is what
  makes the reconciliation clean.
- **Evidence:** Phase 1 spec, Open Item OI-2 (`../phase-1-linear-publishing/feature-specification.md`). Codebase:
  `han-linear/README.md` lines 8 and 16; `han-linear/docs/skills/work-items-to-linear.md` line 156.
- **Rejected alternatives:**
  - Leaving it as a standing open item — rejected because the fix is a documentation edit inside a phase already
    editing the same class of documentation.
- **Linked technical notes:** —
- **Driven by findings:** F3
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Open Items

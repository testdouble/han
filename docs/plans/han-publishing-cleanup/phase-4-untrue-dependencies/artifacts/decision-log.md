# Decision Log: Remove the Two Untrue Dependency Declarations

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-4-untrue-dependencies/`, nested
  beside the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: What is removed and what stays

- **Question:** Which declarations are deleted, and what evidence gates the deletion?
- **Decision:** Exactly two declarations are removed: the Reporting plugin's claim on the Core plugin and the Feedback
  plugin's claim on the Core plugin. The Reporting plugin keeps its Communication dependency. A pre-start check
  re-confirms neither plugin reaches the Core plugin through any path; if a real path is found, the removal stops for
  that plugin.
- **Rationale:** The source analysis found both claims decorative: Reporting's is a leftover from a capability that
  moved to the Communication plugin, and Feedback is not permitted to call other plugins at all. The check-first rule
  keeps the phase honest to its own trust goal.
- **Evidence:** Codebase: `han-reporting/.claude-plugin/plugin.json` declares `["han-communication", "han-core"]`
  while `grep -rn "han-core" han-reporting/skills/` returns nothing and its skills reference `han-communication`;
  `han-feedback/.claude-plugin/plugin.json` declares `["han-core"]` while the only `han-core` strings in
  `han-feedback/skills/` are naming-convention text inside the feedback format (e.g. prefix examples), not
  invocations. Source analysis: "The dependency graph: two threads to snip" in
  [`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#the-dependency-graph-two-threads-to-snip).
- **Rejected alternatives:**
  - Also auditing and trimming other plugins' declarations — rejected because the source analysis verified the rest of
    the graph as true; widening the scope has no evidence behind it.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D4
- **Referenced in spec:** Actors and Triggers; Primary Flow

### D3: Declarations and documentation change together

- **Question:** Is deleting the two declaration lines enough, or do the documentation surfaces that repeat them change
  too?
- **Decision:** They change in the same commit. The claiming surfaces are each plugin's front-door page, the
  repository map, and the plugin index; completion is verified by searching for the removed claims rather than
  trusting memory.
- **Rationale:** The phase's payoff is trust in the record. Deleting the declaration while the documentation still
  asserts it would trade one untrue surface for another, and the repository's own convention is that dependency prose
  and declarations agree.
- **Evidence:** Codebase: `han-reporting/README.md` line 8 ("Depends on `han-communication` and `han-core`"),
  `han-feedback/README.md` line 8 ("Depends on `han-core`"), `CLAUDE.md` dependency prose, and
  `docs/choosing-a-han-plugin.md` (multiple "depends on `han-core`" scent lines) all repeat the claims today.
- **Rejected alternatives:**
  - Declarations first, documentation in a follow-up — rejected because the interim state reintroduces exactly the
    docs-say-one-thing-system-does-another problem this cleanup exists to end.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Primary Flow; Edge Cases and Failure Modes; Coordinations

### D4: Linear page reconciliation

- **Question:** The Phase 1 spec handed off an open item: the Linear plugin's front-door page says its skills dispatch
  shared agents from other plugins, while its skill content dispatches none. Where does that get fixed?
- **Decision:** Here. The Linear plugin's front-door page is reconciled with what its skill content really does, as
  part of this phase's documentation pass. The Linear plugin's own dependency declaration is examined with the same
  evidence test, and any change to it follows the same stop-if-real rule as the other two.
- **Rationale:** This phase is the cleanup's dependency-truth work, and the Phase 1 spec routed the item here
  explicitly. Fixing it in the same documentation pass costs little and closes the only known remaining
  docs-versus-behavior contradiction about dependencies.
- **Evidence:** Phase 1 spec, Open Item OI-2
  (`../phase-1-linear-publishing/feature-specification.md`). Codebase: `han-linear/README.md` lines 8 and 16 claim
  dependence on the Core plugin and agent dispatch; `han-linear/skills/work-items-to-linear/SKILL.md` dispatches no
  agent and references no other plugin.
- **Rejected alternatives:**
  - Leaving it as a standing open item — rejected because the fix is a documentation edit inside a phase already
    editing the same class of documentation.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Open Items

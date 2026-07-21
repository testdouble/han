# Decision Log: Turn On the Automated Completeness Check

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-7-automated-check/`, nested beside
  the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: One rule, two enforcement moments

- **Question:** Where does the check run, and how does it relate to the release process's own gate?
- **Decision:** One rule, enforced at two moments: automatically on every proposed change, where it blocks the change
  on failure; and inside every release, where it is the release process's presence gate. Both moments share the same
  discovery rule (plugins found from the repository), the same surface list, and the same failure reporting: each
  missing plugin, the surface it is missing from, and each version disagreement, named outright. The release's loud,
  recorded override is the only sanctioned path past it; the change-time check has no silent bypass.
- **Rationale:** The source analysis's target picture has the release ask "does every plugin appear everywhere it
  should?" and stop when not; the outline's Phase 7 extends the same question to every proposed change so a new
  plugin is caught when introduced, not twenty releases later. Two independently-written rules would eventually
  disagree, which is the drift disease this cleanup treats.
- **Evidence:** Source analysis: the After diagram's gate and "Only now, turn on the automated check"
  ([`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#what-i-would-do-in-order)). Outline: Phase 7's
  outcome and demo (`../build-phase-outline.md#phase-7`). Codebase: the repository already runs automatic checks on
  proposed changes (a continuous-integration workflow and pre-commit hooks exist), so a change-time enforcement point
  exists to join. Phase 6 spec: the release-side gate and override
  (`../phase-6-release-process/feature-specification.md`).
- **Rejected alternatives:**
  - Release-time only — rejected: a plugin added today would still land invisible until the next release; the outline
    demands the check on every proposed change.
  - A separate rule for change-time and release-time — rejected: two rules drift, then disagree, then one gets
    ignored.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D4
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Coordinations

### D3: Shared rule, shared exception record

- **Question:** How does the check know about the bundle exception without flagging it forever?
- **Decision:** The check reads the same durable exception record the release process reads, holding the single named
  allowance. An unreadable record fails closed and names the record itself as the fault. Editing the record is itself
  a change the check evaluates, so exceptions are added or removed visibly, under review.
- **Rationale:** Phase 6 settled the one-record requirement precisely so the two consumers can never disagree; this
  phase inherits it rather than restating it. Making record edits reviewed changes keeps the exception list from
  becoming a quiet side door.
- **Evidence:** Phase 6 spec and decision log: the durable record, its single allowance, and its fail-closed rule
  (`../phase-6-release-process/artifacts/decision-log.md`, its D4). Source analysis: "the check needs to know about
  it permanently rather than flagging it forever".
- **Rejected alternatives:**
  - The check carrying its own copy of the exception — rejected: duplicated knowledge drifts; Phase 6 already
    rejected the same alternative for the same reason.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Alternate Flows and States; Edge Cases and
  Failure Modes; Coordinations

### D4: Green-first arrival

- **Question:** When does the check start blocking?
- **Decision:** Only after its first run against the real tree passes. If that first run fails, the check does not
  begin blocking; the failure goes back to the earlier phases' owners. Once on, the check is not disabled to resolve
  a dispute; the tree or the exception record is fixed instead.
- **Rationale:** The source is explicit that the order is not negotiable: turned on before the tree is ready, the
  check fails on almost every plugin from day one, someone disables it, and it protects nothing. Arriving green is
  what makes staying on socially and operationally sustainable, and the no-disable rule closes the failure loop the
  source warns about.
- **Evidence:** Source analysis: "The order matters, and getting it wrong stops everything"
  ([`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#the-order-matters-and-getting-it-wrong-stops-everything)).
  Outline: Phase 7's builds-on line and precondition (`../build-phase-outline.md#phase-7`).
- **Rejected alternatives:**
  - Landing the check early in report-only mode — rejected: a warning nobody must act on trains everyone to ignore
    it, and the outline's sequencing already guarantees a green arrival without a nagging phase.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Alternate Flows and States; Edge Cases and Failure Modes;
  Coordinations

# Decision Log: Turn On the Automated Completeness Check

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-7-automated-check/`, nested beside
  the build phase outline that spawned it. — Referenced in spec: none (organizational).

## Full decisions

### D2: One verdict, two enforcement moments

- **Question:** Where does the check run, what exactly does it verify, and how does it relate to the release
  process's gate without contradicting it?
- **Decision:** The guarantee is verdict equivalence, not a shared machine: given the same tree and the same
  exception record, the change-time check and the release-time gate return the same verdict. The verdict evaluates
  the proposed tree's end state: every plugin present on every surface it belongs on, and both channels stating the
  same version per plugin. A release passes because it moves all four surfaces together in one change; a change that
  moves one surface without its partners is precisely what gets blocked. The check runs automatically on every
  proposed change, gates every release, and can be run on demand against any working tree. Its scope is presence and
  version agreement, guarding Phases 1, 3, and 6; it does not examine ticket-file marks, dependency-declaration
  truth, or version statements and markers, which the release reconciliation owns; the reopening trigger is a
  statement-marker mismatch escaping that reconciliation. The deleted-plugin orphan case is kept for verdict parity
  with the release process's symmetric rail. The release's loud recorded override is the only sanctioned bypass at
  release time.
- **Rationale:** The two moments run in different worlds, one non-interactive beside the repository's automatic
  checks and one inside an interactive release, so "one rule" could only honestly mean same-inputs-same-verdict.
  Defining the verdict on the proposed end state dissolves the apparent collision with the release's tolerance of
  pre-existing drift: the release fixes flagged drift by syncing, the check blocks changes that create drift, and
  both call the same tree state a failure. All four surfaces are files in this repository, which is the fact that
  makes a change-time verdict possible. Narrowing the guard claim keeps the spec from promising Phase 4 and Phase 5
  protection its mechanism does not provide; the outline's Phase 7 guard list was corrected to match.
- **Evidence:** Source analysis: the After diagram's gate and "Only now, turn on the automated check"
  ([`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#what-i-would-do-in-order)). Outline: Phase 7's
  outcome and demo (`../build-phase-outline.md#phase-7`). Codebase: the repository runs automatic checks on proposed
  changes (a continuous-integration workflow and pre-commit hooks exist), and all four surfaces are repository
  files. Phase 6 spec: the release-side gate, the one-change surface sync, and the override
  (`../phase-6-release-process/feature-specification.md`).
- **Rejected alternatives:**
  - Release-time only — rejected: a plugin added today would still land invisible until the next release.
  - A literally shared implementation across both moments — rejected as an overclaim across two runtimes; the
    behavioral equivalence is the commitment, the machinery is implementation planning's.
  - Extending the check to dependency-declaration truth and statement-marker consistency — rejected: declaration
    truth is not mechanically checkable, and reconciliation already owns markers and statements; widening the check
    duplicates a guard that exists.
- **Linked technical notes:** —
- **Driven by findings:** F1 (the verdict collision dissolved on the end-state definition), F2 (equivalence replaces
  "one rule"), F3 (the guard claim narrowed and the outline corrected), F5 (all four surfaces are repository files,
  stated), F6 (on-demand invocation granted), F8 (the orphan rail's parity evidence and carried caveat)
- **Dependent decisions:** D3, D4
- **Referenced in spec:** Outcome; Actors and Triggers; Primary Flow; Edge Cases and Failure Modes; Coordinations;
  Out of Scope

### D3: Shared exception record

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

### D4: Green-first arrival, and the repair door

- **Question:** When does the check start blocking, and what happens when the check itself is the broken thing?
- **Decision:** The check begins blocking only after an observable turn-on condition: a recorded green run against
  the real tree, owned by the maintainer. If that first run fails, the check does not begin blocking and the failure
  goes back to the earlier phases' owners. Once on, the check is never simply disabled. Instead, a scoped, recorded
  repair door exists for the one deadlock a no-disable rule creates: a change whose purpose is fixing the check or
  its exception record may land past the failing check, with the bypass named visibly in that change.
- **Rationale:** The source is explicit that the order is not negotiable: turned on before the tree is ready, the
  check fails on almost everything, someone disables it, and it protects nothing. But an absolute no-disable rule
  wedges the repository when the check false-fails, since the fixing change would be blocked by the bug it fixes.
  The repair door keeps the no-disable spirit, loud and auditable like the release override, while making the check
  repairable.
- **Evidence:** Source analysis: "The order matters, and getting it wrong stops everything"
  ([`../source-han-cleanup-plan.md`](../source-han-cleanup-plan.md#the-order-matters-and-getting-it-wrong-stops-everything)).
  Outline: Phase 7's builds-on line and precondition (`../build-phase-outline.md#phase-7`). Phase 6 spec: the
  loud-recorded override pattern the door mirrors.
- **Rejected alternatives:**
  - Landing the check early in report-only mode — rejected: a warning nobody must act on trains everyone to ignore
    it.
  - An absolute no-disable rule with no door — rejected: it deadlocks on a false-failing check and invites the
    out-of-band disable it forbids.
- **Linked technical notes:** —
- **Driven by findings:** F4 (the repair door), F9 (the observable turn-on condition and its owner)
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Actors and Triggers; Alternate Flows and States; Edge Cases and Failure Modes;
  Coordinations
</content>

# YAGNI and Scope Sweep

The three gates Step 7.5 runs over every committed item in the plan: the evidence test, the
simpler-version test, and the scope test.

Before synthesis, walk every committed item the iterative loop has produced and run the YAGNI rule from
[../../references/yagni-rule.md](../../../references/yagni-rule.md). Items in scope: every recommendation captured in
`artifacts/implementation-iteration-history.md`'s claim ledgers across all rounds, every Open Question that proposes
adding an artifact, and every specialist recommendation that survived the loop without explicit deferral.

For each in-scope item, apply the two gates:

1. **Evidence test.** Does the item cite at least one piece of accepted evidence per the rule (user-described need from
   the spec, named direct dependency, existing production code path that breaks, applicable regulation, documented
   incident or measured metric)? If no — the item is a YAGNI candidate.
2. **Simpler-version test.** When evidence applies, is there a strictly simpler implementation (one fewer abstraction,
   one fewer file, one fewer infrastructure component, one fewer test category, a single concrete implementation instead
   of an interface, an inline check instead of a helper, etc.) that satisfies the same evidence? If yes — the simpler
   implementation replaces the larger one.

Apply the named anti-patterns from the rule doc as auto-flags — runbooks for never-fired alerts, observability for
non-flowing telemetry, SLOs for absent traffic, single-implementation interfaces, configuration knobs no caller sets,
multi-region for unproven workloads, indexes for unrun queries, audit columns nobody reads, tests for code paths that
don't exist yet.

**The scope gate runs in the same sweep, as a third gate.** Per
[../../references/scope-justification-rule.md](../../../references/scope-justification-rule.md), and this is the one skill of
the four with a discrete sweep step for it to attach to.

3. **Scope test.** Does the recorded boundary in `artifacts/scope-boundary.md` ask for this, or exclude it by statement or
   by silence? Widen the in-scope set for this gate: it walks every subsystem, integration, and artifact the plan touches,
   **including everything inherited from the feature specification**, not only what the loop produced. Scope arriving
   pre-committed from an upstream document is otherwise never swept, and that inheritance is exactly what needed a filter.

   - A commitment no work item supports is cut, with the citation recorded, and lands in the plan's `## Cut for Scope`
     section rather than in `## Deferred (YAGNI)`. A cut carries no reopening trigger; the boundary already settled it.
     Route each entry to one section only, so a reader never meets the same item twice.
   - A recorded deprecation in the boundary record's Direction of Travel section is treated the same way a stated exclusion
     is treated.
   - **The floor holds.** Cut subsystems, integrations, and artifacts the work item never asks for. Never cut behavior
     required to deliver what the work item does ask for. A short work item does not enumerate its own necessities, and
     that silence is not exclusion. An unmentioned image subsystem is a correct cut; validation, focus behavior, error
     copy, tests, and accessibility on a card the ticket did ask for are not.
   - Do not escalate a scope cut as a choice. The work item already settled it, so cut and record the citation.

Note the asymmetry between the gates on purpose: the YAGNI gates walk what the loop produced, and the scope gate walks
that plus everything inherited.

For every item the sweep flags, record a YAGNI ledger entry that PM will absorb into synthesis:

- **Item** — what is being demoted or replaced.
- **Failure** — which gate failed (evidence, simpler-version, or scope), citing the named anti-pattern when applicable, or
  the boundary citation when the scope gate is what failed.
- **Resolution** — defer with reopening trigger | replace with simpler implementation: {one-line description} | escalate
  to user if the resolution would change a behavior the spec committed to.
- **Source** — which specialist or round originally proposed the item, plus the corresponding `R#` and claim-ledger
  entry. For a scope-gate cut on an inherited commitment, name the specification section it came from instead.

If the sweep produces YAGNI items that would change a behavior the spec committed to, surface them to the user before
synthesis with a recommended resolution and the option to override. The user always wins; the rule's job is to make the
cost of including the item visible.

The YAGNI ledger is a synthesis input — pass it to PM in Step 8 alongside the round entries and resolutions.

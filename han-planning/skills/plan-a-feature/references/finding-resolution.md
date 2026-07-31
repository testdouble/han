# Finding Resolution

How Step 7 classifies, records, and resolves each review finding, and the two gates that run in the same pass.
Step 7 of the skill performs these; it does not restate them.

Paths in this file are written from the skill directory, the same way Step 7 writes them.

1. **Classify the finding as major or minor** before recording. A finding is **major** when it changes a behavioral
   commitment, edge-case rule, alternate flow, or failure mode in the spec; touches
   security/auth/PII/secrets/supply-chain; touches a coordination across actors, services, or subsystems; surfaces a
   load-bearing mechanic (`T#` candidate); or is a "mechanics leaking into spec" finding. A finding is **minor**
   otherwise — wording, typo, naming, formatting, citation cleanup. If the finding text contains any major-list keyword
   ("auth", "PII", "race", "ordering", "coordination", "edge case", "T#"), force it to major. When in doubt, major.

2. **Record it in `artifacts/team-findings.md`** using the
   [team-findings-template.md](./team-findings-template.md) format. Carry every originating reviewer's own
   identifier on the record, and carry the unverified label from Pass B where it applies. Major findings go under
   `## Major findings` with the full structured fields. Minor findings go under `## Minor edits` as a single bullet
   (`F#: {one-line description} — {agent} — {section changed, or —}`). The F# counter is shared across both classes.
3. **Attempt evidence-based resolution first.** Re-check the codebase, docs, standards, and settled decisions. If the
   finding is resolvable without the user's judgment, update the affected files and record the resolution in the `F#`
   entry (`Resolved by: evidence`). Route any implementation mechanic surfaced by a finding through the same
   classification the interview loop uses, in [mechanic-routing.md](./mechanic-routing.md):
   - **Load-bearing mechanic** → capture as a new `T#` note in `artifacts/feature-technical-notes.md` (creating the file
     lazily if this is the first qualifying note), link it from the affected spec section, and populate the `T#`'s
     `Driven by findings:` field.
   - **Discoverable from code repo** → cite evidence on the relevant `D#` entry; do not write a `T#`.
   - **Pure implementation** → do not edit the spec, decision log, or tech-notes; surface as a
     `plan-implementation`-stage input noted in the F# resolution.
4. **Keep all files in sync (major findings only — minor findings only update `Changed in spec:` if a section actually
   changed).** For every major F# resolved:
   - Populate `Affected decisions:` on the `F#` entry with the `D#` IDs that were added or changed in
     `artifacts/decision-log.md`.
   - Populate `Affected tech-notes:` on the `F#` entry with the `T#` IDs that were added or edited in
     `artifacts/feature-technical-notes.md` (or `—` if none).
   - Populate `Changed in spec:` on the `F#` entry with the `feature-specification.md` sections that were updated.
   - On each affected `D#` entry in `artifacts/decision-log.md`, add this finding's ID to `Driven by findings:` and add
     any new `T#` IDs to `Linked technical notes:`.
   - On each affected `T#` entry in `artifacts/feature-technical-notes.md`, add this finding's ID to
     `Driven by findings:` and list affected spec sections under `Referenced in spec:`.
   - If a new decision was introduced, add an inline `([D#](artifacts/decision-log.md#...))` reference in the relevant
     section of `feature-specification.md` and list that section under the decision's `Referenced in spec:` field. Apply
     the same pattern for any new `T#` references.
5. **"Mechanics leaking into spec" findings** — findings in this class usually resolve by rewriting the offending spec
   sentence behaviorally and either extracting the mechanic to a `T#` note (if load-bearing) or removing it entirely (if
   pure implementation or discoverable from code). Do not escalate these to the user unless the rewrite would change the
   feature's meaning.

5a. **`YAGNI candidate` findings** — apply the YAGNI rule per
[../../references/yagni-rule.md](../../../references/yagni-rule.md). For each finding, three resolution paths exist: (a)
cite the missing evidence (per the rule's evidence test) and keep the spec item — record the citation in the relevant
`D#`'s `Evidence:` field and close the finding; (b) replace with the strictly simpler version that satisfies the same
evidence — update the spec sentence and the related `D#`, list the larger version under that `D#`'s
`Rejected alternatives:` with the reason "simpler version satisfies the same evidence"; (c) demote to the spec's
`## Deferred (YAGNI)` section with the reopening trigger named, removing the inline behavior from the affected sections.
Surface YAGNI deferrals to the user in the escalation pass so the user can override consciously, but do not require
user input when evidence resolves the finding directly.

5b. **The scope gate runs in this same pass.** Per
[../../references/scope-justification-rule.md](../../../references/scope-justification-rule.md), check the spec's own
commitments against the recorded boundary in `artifacts/scope-boundary.md`. This gate attaches here, to the YAGNI
reasoning path 5a already performs; no sweep step is added to this skill. Because this skill drafts from an interview
rather than from an upstream artifact, the gate reduces to a work-item check on the commitments this run authored, and
there are no inherited commitments to sweep.

Ask of each commitment: does the recorded boundary ask for this, or exclude it by statement or by silence?

- A commitment the boundary never asks for is cut, with the citation, and lands in the spec's `## Cut for Scope` section.
  It is not a YAGNI deferral and gets no reopening trigger; the boundary already settled it. Route the entry to the cut
  list and nowhere else, so a reader never meets the same item in both sections.
- A recorded deprecation in the boundary record's Direction of Travel section is treated the same way a stated exclusion
  is treated.
- **The floor holds.** Cut subsystems, integrations, and artifacts the boundary never asks for. Never cut behavior
  required to deliver what the boundary does ask for. A short work item does not enumerate its own necessities, and that
  silence is not exclusion. Validation, focus behavior, error copy, tests, and accessibility on a card the ticket did ask
  for are not cuts.
- A scope question the boundary answers is never escalated. Cut it and record why, rather than asking the user to choose
  between options their own work item already decided between.

Cut entries flow into Step 8's synthesis alongside everything else.

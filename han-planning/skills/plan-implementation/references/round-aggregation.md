# Round Aggregation

The deterministic half of Step 5: the claim ledger, the spec-maturity tagging and gate, the Open
Questions list, the next-step recommendation, and the round entry. Step 5 performs these in order.

**Build the claim ledger.** Group findings by category (assumption-refuted, overlap, ambiguity, edge-case, security,
mechanic-leak, T#-contradiction, YAGNI-candidate). For each finding, mark its state:

- `Evidenced` — the finding cites a file path with line number, an ADR ID, a coding-standard section, or another
  concrete artifact that resolves the claim.
- `Anecdotal` — the finding asserts but does not cite an artifact.
- `Disputed` — two or more specialists made conflicting claims on the same point.
- `Unverified` — the finding rests on an input its author recorded it could not inspect. Carries the reason. Never
  build-blocking, per Pass B.

When two specialists raise the same claim, consolidate into a single ledger row that names every supporting specialist and
carries every originating identifier, per Pass A.

**One exception to that consolidation.** Two findings that cite the same identifier while asserting different figures do
not merge. They become one `Disputed` row carrying both readings and both originating identifiers. A genuine
disagreement usually cites different evidence, so identical evidence with divergent figures is a signal that one
specialist has misread the source rather than a signal that the two disagree about the world. Settle it by opening the
cited entry and reading which field each figure came from.

**Tag spec-maturity.** Tag every finding as:

- `plan-level` — resolvable inside `plan-implementation` by evidence, reframing, or user input.
- `spec-level` — requires a behavioral decision the spec never committed to (e.g., "the spec doesn't say what happens
  when two users invite the same email simultaneously"). Cannot be resolved in the plan stage without fabricating
  behavior.
- `T#-contradiction` — the specialist recommends a mechanic that conflicts with a committed `T#` note. Load-bearing by
  construction.

Use simple text rules: a finding that names a spec section and says "the spec is silent" / "not specified" / "undefined
behavior" is `spec-level`. A finding that names a `T#` ID and proposes a different mechanic is `T#-contradiction`.
Everything else is `plan-level`.

**Compute the spec-maturity gate.** The gate trips when either condition holds:

- **≥ 2 `T#`-contradictions raised by ≥ 2 distinct specialists** (on any combination of `T#` notes — need not be the
  same one), or
- **≥ 5 `spec-level` findings raised by ≥ 3 distinct specialists**.

A single `T#`-contradiction does NOT trip the gate on its own — it routes through the normal Open Questions loop
(Step 6) and the user decides. One specialist raising many findings also does not trip the gate — one detailed reviewer
is not a spec-immaturity signal.

**Run the contract-pinning check.** Separately from the gate above, answer one binary question about the round's
committed content: does every contract the plan commits to carry a concrete grammar, worked example, field layout, or a
link to an artifact that already exists? Record the answer as `Contract pinning: Y` or `Contract pinning: N` in the
round entry, naming each unpinned contract when the answer is `N`.

Keep this check out of the gate's trip conditions. The gate counts findings from distinct specialists, and a binary
condition bolted onto counted logic breaks it. An `N` instead becomes an `OQ-N` Open Question, which the Step 6 loop
already knows how to settle by evidence, reframing, or escalation. What counts as pinned, and the phrases that never
close a contract, are in [contract-pinning-rule.md](../../../references/contract-pinning-rule.md).

Run it on every round, including one where no specialist raised a contract finding. That is the point of it: an
un-pinned contract is invisible to a review that nobody thought to point at it, so a check reading only the specialist
findings stays silent exactly when it is needed. This one reads the plan's own committed content instead.

**Build the Open Questions list.** Any finding that cannot be settled deterministically (claim is `Anecdotal`, two
specialists `Disputed`, or the finding is tagged `spec-level` / `T#-contradiction` and was not user-deferred) becomes an
`OQ-N` entry, as does an `N` from the contract-pinning check. Open Questions are first-class output and feed into
Step 6.

**Pick the next-step recommendation deterministically:**

- If the spec-maturity gate tripped → `pause and sharpen the spec`.
- If at least one specialist named a specific other specialist as a needed handoff → `continue iterating` (with the
  named handoffs).
- If at least one Open Question is `plan-level` and unresolved → `continue iterating` (use Step 6 to resolve via
  evidence or han-core:junior-developer reframing).
- Otherwise → `go to synthesis`.

**Write the round entry** to `artifacts/implementation-iteration-history.md` using
[implementation-iteration-history-template.md](./implementation-iteration-history-template.md). Populate the
claim ledger, Open Questions, spec-maturity tags, contract-pinning answer, and next-step recommendation fields
directly from this aggregation.

**If the spec-maturity gate tripped**, this skill makes the one and only facilitation call in the round: launch
`han-planning:discussion-facilitator` with the verbatim specialist outputs, the deterministic aggregation,
and a directive to confirm or refine the gate-trip assessment and surface anything the deterministic aggregator might
have missed before the user is asked to pause spec-stage work. Pass the directive: **do NOT write a facilitation-summary
file to disk.** Return the facilitation output verbatim. Append the facilitator's verbatim output to the round entry
under a `Facilitator review (gate-trip pass):` field.

Then surface the tripping findings to the user with:

- The list of `spec-level` findings and `T#`-contradictions that tripped the gate, grouped by the spec section they
  affect.
- A recommendation to run `han-planning:iterative-plan-review` on the source spec (for mechanic-leak cleanup and gap
  filling) or re-enter `han-planning:plan-a-feature` (for structural gaps where whole sections are missing).
- An explicit **override option**. The user may direct the skill to continue anyway — in which case
  `plan-implementation` proceeds, and the tripping findings are documented in the round entry, noting the user's
  override and the reasoning provided.

If the user overrides, the plan ships with the spec accepted as-is; if the user chooses to pause, stop the skill and
hand control back to spec-stage work.

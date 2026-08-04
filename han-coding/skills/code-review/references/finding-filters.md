# Finding Filters: the reachability gate and the independent validation pass

Two of Step 7's sub-steps filter the collected finding list. Both are specified here, and every reference to Step 7.2 or
Step 7.4 elsewhere in the skill points to this file. They run in the order below, with Step 7.3's size-aware rubric
between them.

Neither pass is a finding source. Both only demote or drop, so Step 9's verification rule against findings from
undispatched agents is unaffected by either.

## Step 7.2: Apply the reachability phrase-match demotion gate

For each finding read at Step 7.1, scan the rationale text (the agent's own explanation of why the finding matters) for
any of these reachability phrases:

- `theoretical`
- `hypothetical`
- `defense-in-depth`
- `effectively impossible`
- `in case the upstream`
- `could happen`
- `should never happen`
- `edge case that does not occur`

When a finding's rationale contains any of these phrases, the agent itself signaled that the failure mode is not
reachable in production. Demote the finding by one severity: CRIT becomes WARN, WARN becomes SUGG, SUGG is omitted
entirely. Apply the demotion exactly once per finding regardless of how many phrases match.

**Keep the reasoning that drove each demotion.** Carry it to Step 8, where it becomes the preconditions and the
likelihood in that finding's plain-language explanation ([finding-content.md](./finding-content.md)). Discarding it here
is what makes a reader ask whether a finding can happen at all, on a question this gate already answered.

This gate is the merged form of the reachability and "directly introduced" filters; the size-aware rubric in Step 7.3 is
the single later pass and does not re-demote on these phrases. The phrase list is the only signal the gate uses; do not
infer reachability from other text. The gate is a cheap, deterministic first pass and is brittle to paraphrase by
design: a finding that hedges its own reachability without using one of the literal phrases (for example, "unlikely in
practice", "would need an unusual sequence") slips through here. That paraphrased hedging is caught semantically by the
independent validation in Step 7.4, not by expanding this list.

Security findings (SEC-series) are exempt from this gate because the security agent's evidence standard already requires
a demonstrated exploit path or CVE reference before any finding is raised.

## Step 7.4: Validate the finding list (independent adversarial pass)

The specialist agents and the manual passes each filter findings on the findings' own wording. This sub-step is
different: it dispatches one critic that re-attacks the **consolidated finding list against the code itself**, in fresh
context, the way `investigate` validates a root cause and fix. It is the only pass that judges a finding by re-reading
the change rather than by trusting the producing agent's rationale.

**Run condition.** Run this sub-step whenever at least one corrective finding (CRIT / WARN / SUGG, manual or agent, plus
any SEC-### finding) has survived to this point. **Skip it when there are zero corrective findings** — a clean review
needs no validation. YAGNI findings are out of scope here: they are advisory and are never validated, demoted, or
dropped by this pass.

**Dispatch one `han-core:adversarial-validator`** via the `Agent` tool. Give it, in this order:

1. **The change under review as primary material** — the diff from Step 1 (Mode A), or the changed file list with a note
   that the files were read in full (Mode B / Mode C). The validator must judge against the code, not against the
   finding text, so it does not anchor on what the producing agents concluded.
2. **The complete corrective finding list**, with each finding's task ID, current severity, `file_path:line_number`, the
   finding's claim, and the producing agent's rationale **verbatim**.
3. **The `{size}` from Step 3.1 and the calibration directive from Step 3.3**, so it judges severity on the same scale
   the rest of the review used.

Pass this brief verbatim:

> Treat every finding as wrong until the code proves it right. For each finding, return exactly one verdict —
> **Confirmed**, **Partially Refuted**, or **Refuted** — and for anything other than Confirmed, cite concrete
> counter-evidence at `file_path:line_number`. Challenge specifically: (a) findings that misread the change's intent or
> the surrounding code; (b) findings that target pre-existing code this change did not introduce or worsen, unless the
> issue is critical irrespective of who introduced it; (c) findings whose rationale hedges its own reachability in
> paraphrase ("unlikely in practice", "would need an unusual sequence", "only under a race we don't see") that the
> literal-phrase gate did not catch; (d) severity that overstates impact, where the true worst case is "an operator sees
> an error and retries". Do not invent new findings — you are validating the list, not extending it.

**Reconcile the verdicts (orchestrator).** Apply each verdict to the finding:

- **Confirmed** → keep the finding at its current severity.
- **Partially Refuted** (real but mis-severitied or partly wrong) → demote one severity (CRIT → WARN → SUGG; a SUGG
  stays SUGG). Append the validator's one-line counter-point to the finding body.
- **Refuted** → drop the finding, **but only when the validator supplied concrete counter-evidence** (a
  `file_path:line_number` showing the code does not do what the finding claims, or that the finding targets unchanged
  pre-existing code). A refutation that asserts without counter-evidence does **not** drop the finding; demote it one
  severity instead.
- **Security findings (SEC-###)** → the validator may challenge the exploit path, but a SEC finding is dropped only when
  the validator refutes the demonstrated exploit with concrete counter-evidence. Otherwise it stands at its original
  severity; the security evidence bar is already higher.

**Overcorrection guard.** This pass exists to remove findings the code disproves, not to quiet the review. Never drop a
finding on assertion alone — counter-evidence at `file_path:line_number` is required for every drop. When the validator
is uncertain, the finding stays. Suppressing a real finding is more costly here than carrying one the human will reject.

**Record the reconciliation.** Keep a single orchestrator-log line: how many findings were Confirmed, demoted, and
dropped, plus the dropped task IDs and the counter-evidence reference for each. This makes the pass auditable; it does
not add a section to the review output.

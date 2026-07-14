# Decision Log: Verified PR Descriptions

Decisions behind [../feature-specification.md](../feature-specification.md). Full decisions carry rationale, evidence, and rejected alternatives. Trivial decisions are one-liners.

Evidence trust classes follow [the evidence rule](../../../../han-core/references/evidence-rule.md): `codebase` (read from this repository), `web` (external source, cited by ID from the research report), `provided` (stated by the user).

## Full decisions

### D2: The verification gate shows each claim against its diff evidence

- **Outcome:** Before the description is final, the skill lists each factual claim it made and pairs it with the specific diff evidence supporting it. Claims it could not tie to the diff are marked unsupported. The statement of why the change exists is always marked unprovable and must be confirmed or rewritten by the engineer.
- **Rationale:** This is the design gap the research explicitly declines to close and hands to the rebuild. A weak gate is not merely less good; the research finds a gate that is only *asked for* rather than structurally enforced is one most authors do not actually perform. Showing evidence next to the claim makes the check something the engineer does by reading, rather than something they attest to by clicking.
- **Evidence:**
  - `web` — A25: GitHub's own documentation admits a "known risk" of hallucination in generated summaries and asks for careful human review of every one.
  - `web` — A28: measured tendency for AI descriptions to claim functionality absent from the diff. Independent of A25.
  - `web` — A27: ~61% of AI-authored PRs get no recorded human review, which is what a weak gate degrades into. *Single-source, and shares a dataset with A24; carried as a risk signal, not a measurement of this design.*
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 6: today's gate is a yes/no on finished prose.
  - `provided` — the user chose this option over two weaker gates.
- **Rejected alternatives:**
  - *Confirm the intent sentence only.* Closes the intent hole but leaves A28's measured failure (claims of absent functionality) entirely unmitigated. Rejected because the intent hole is the cheaper of the two to close and the claim hole is the one with direct empirical support.
  - *Keep the yes/no gate.* Rejected as the exact failure mode the research names.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** —
- **Referenced in spec:** Outcome, Primary Flow, User Interactions

### D3: The description keeps its existing lean core

- **Outcome:** The default description stays as it is: a one-sentence bolded summary, a behavior-changes section when runtime behavior changes, and a reading-order guide only on a large change. No issue link, no desired-feedback-type prompt, and no testing note are added.
- **Rationale:** The research's recommended core would add three sections. The user chose not to. The rebuild's value is the verification gate, and each added section is a new question or a new fabrication surface at every run. The deferred items are recorded with reopening triggers rather than dropped.
- **Evidence:**
  - `provided` — the user selected "keep the existing lean core only."
  - `codebase` — `han-github/skills/update-pr-description/references/template.md`: the current lean default.
  - `web` — the research's own finding that the current default already aligns with the external evidence on why-before-what ordering and on treating reading-order guidance as conditional.
- **Rejected alternatives:**
  - *Add the issue link.* Nearly universal in the sources (A1, A3, A6, A9–A11, A13) and associated with faster first response. A genuine loss, taken knowingly. Deferred with a trigger.
  - *Add a desired-feedback-type prompt.* The largest measured effect on merge odds in A13. Rejected because it cannot come from the diff, so it costs a question on every single run. Deferred with a trigger.
  - *Add a testing note.* Rejected with the rest; used by a minority of PRs in practice (13.7%, A13).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Referenced in spec:** Outcome, Deferred (YAGNI)

### D4: Oversized changes draw a warning, not a block

- **Outcome:** Past roughly four hundred changed lines, the skill tells the engineer that reviewer defect-finding drops sharply at that size and that splitting would get a better review, then writes the description anyway.
- **Rationale:** Change size is the most corroborated finding in the research, across three independent sources over two decades. But the skill runs after the work is done. Blocking at that point costs the engineer a description they need and buys nothing, because the change is already written. A warning puts the fact in front of them at the moment it is still actionable for the *next* change.
- **Evidence:**
  - `web` — A18: defect-finding drops sharply past 200–400 lines reviewed in one sitting.
  - `web` — A20: more files in a change correlates with a lower proportion of useful review comments. Independent of A18.
  - `web` — A23: Google converges on the same order of magnitude for the same reason. Independent of both.
  - `provided` — the user chose "warn, then continue."
- **Rejected alternatives:**
  - *Warn and scale the description's structure with size.* Rejected: it adds a second threshold to tune, and the skill already scales one thing (the reading-order guide) by size. No evidence gives a second threshold.
  - *Say nothing.* Rejected: it discards the research's best-corroborated finding.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Referenced in spec:** Primary Flow, Deferred (YAGNI)

### D5: Authoring is a writing pass, not a repurposed critique pass

- **Outcome:** The description is authored by a pass whose native output is finished prose. The skill does not reach for a critique-oriented reviewer and instruct it to write instead, and it therefore carries no retry path for the case where that reviewer reverts to producing a review report.
- **Rationale:** The current skill dispatches an agent built for critique and then tells it to author. That the skill has to carry an explicit "if it returns a review report, discard and re-issue" instruction is the tell: the dispatch fights the agent's purpose, and the retry path is a workaround for a mismatch rather than a safeguard against a rare failure.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 4 carries the documented discard-and-re-issue retry path.
  - `codebase` — `han-core/agents/junior-developer.md`: the agent's stated purpose is critique output, not authoring.
  - `provided` — the user chose to commit to replacing it rather than deferring the call.
- **Rejected alternatives:**
  - *Leave the choice to implementation planning.* The ordinary home for an agent-selection mechanic, and what this skill's rules would otherwise recommend. Rejected on the user's explicit instruction to settle it now.
  - *Keep it and harden the retry path.* Rejected: hardening a workaround preserves the mismatch it works around.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Referenced in spec:** Primary Flow

### D7: A rejected claim is removed, a corrected claim is rewritten

- **Outcome:** When the engineer rejects a claim at the gate, it is removed from the description. When they correct one, their correction is used as written and the skill does not re-draft over it. The description is re-rendered from what survives.
- **Rationale:** The gate is only worth having if the engineer's verdict is binding. Any behavior that lets a rejected claim survive, or that "improves" a correction back toward the draft's original wording, reintroduces exactly the unverified text the gate exists to catch.
- **Evidence:**
  - `web` — A26: it is inappropriate to hand a reviewer text the author has not personally validated. A correction the tool overrides is text the author did not validate.
  - `provided` — implied by the user's selection of the claim-by-claim gate; the gate has no meaning without a binding verdict.
- **Rejected alternatives:**
  - *Re-draft the description after corrections, to smooth the prose.* Rejected: a re-draft can reintroduce an unverified claim, and the engineer would not see it a second time.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** —
- **Referenced in spec:** Primary Flow

## Trivial decisions

- **D1: Rebuild in place** — the existing `/update-pr-description` skill is rebuilt rather than a second skill added alongside it (considered shipping a parallel skill; rejected because two skills for one job is a routing problem, not a feature). — Referenced in spec: Outcome.
- **D6: The gate runs whether or not a pull request exists** — the claim-by-claim check runs before the description is presented as final, including when the skill has no PR to publish to and the engineer will paste the text by hand. — Referenced in spec: Alternate Flows and States.
- **D8: Repository template conformance is unchanged** — the existing rules for discovering a repository's PR template, preserving its section order, and never checking a box the diff cannot prove are carried forward as-is (`han-github/skills/update-pr-description/references/template-conformance.md`); no evidence surfaced for changing them. — Referenced in spec: Primary Flow, Edge Cases and Failure Modes.
- **D9: The reading-order guide keeps its existing threshold** — "What to look at first" still appears only past roughly eight to ten significant code files. — Referenced in spec: Primary Flow.

# Decision Log: Verified PR Descriptions

Decisions behind [../feature-specification.md](../feature-specification.md). Full decisions carry rationale, evidence, and rejected alternatives. Trivial decisions are short, but each carries a heading so the spec can link to it.

Evidence trust classes follow [the evidence rule](../../../../han-core/references/evidence-rule.md): `codebase` (read from this repository), `web` (external source, cited by ID from `docs/research/effective-pull-request-descriptions.md`), `provided` (stated by the user).

The empirical spine of this feature (A13, A24, A27, A28) is a set of 2026 arXiv preprints that have not been peer-reviewed, and A13's effect sizes are observational and associative rather than causal. Every decision resting on them carries that caveat inline rather than laundering the numbers into certainty. The two decisions most exposed to it, [D2](#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for) and [D3](#d3-the-lean-core-is-kept-and-gains-a-feedback-ask), have matching entries in the spec's Open Items.

## Full decisions

### D2: The gate shows each claim with its evidence, and blocks on what the skill cannot vouch for

- **Outcome:** Before the description is final, the skill lists every assertion it makes and shows the evidence recorded for each. Three kinds of item block: a claim the skill could not evidence, a claim about absence, and the statement of intent (with the feedback ask). Each must be individually disposed of, with no bulk path over them. Every other claim may be accepted together once the blocking items are settled. The gate does not label a claim "supported" or otherwise vouch for it; it shows the claim and the evidence and lets the engineer judge.
- **Rationale:** The research hands the rebuild this gap explicitly and declines to close it. The first draft of this spec closed it badly: it offered a "confirm the list as it stands" option, which is one action discharging every obligation on the screen. All three reviewers independently found that this reproduces the exact failure the gate exists to prevent. Making the careless path cost one keystroke while the careful path costs N is a choice architecture that guarantees the careless path, and it gets worse precisely as the diff gets larger, which is where the fabrication risk is highest. Blocking only on the items the skill genuinely cannot vouch for costs nothing on a clean change and cannot be skipped on a dirty one.

  Dropping the affirmative "supported" label came from the same review and is the sharper half. [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time) establishes that only the authoring pass can honestly say *I could not evidence this*. It does not establish that the same pass can honestly say *this one is evidenced*, and that is the identical self-assessment T1 rejects. A "supported" badge on a fabricated claim is worse than no badge: it tells the engineer which rows to skip, and a plausible-looking hunk under a fabricated claim is exactly what hides there.
- **Evidence:**
  - `web` — A25: GitHub's own documentation admits a "known risk" of hallucination in generated summaries and asks for careful human review of every one. First-party vendor documentation, and an admission against interest.
  - `web` — A28: measured tendency for AI descriptions to claim functionality absent from the diff. Independent of A25. *2026 preprint, not peer-reviewed.*
  - `web` — A27: ~61% of AI-authored PRs get no recorded human review. *2026 preprint, single-source, and shares a dataset with A24; carried as a risk signal, not a measurement of this design. See the spec's Open Items.*
  - `web` — the research's own V5 finding: the gate "must be structurally enforced ... or the option inherits A27's failure mode."
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 6.3: today's gate is a yes/no on finished prose, immediately before `gh pr edit --body`.
  - `provided` — the user chose the claim-by-claim gate over two weaker options.
- **Rejected alternatives:**
  - *A single "confirm the list as it stands" option.* What the first draft specified. Rejected on unanimous review: it makes waving through exactly one action, structurally identical to the yes/no gate being replaced, and merely longer.
  - *Confirm the intent sentence only.* Closes the intent hole and leaves A28's measured failure untouched. Rejected because the claim hole is the one with direct empirical support.
  - *Keep the yes/no gate.* Rejected as the named failure mode.
  - *Label evidenced claims "supported".* Rejected: T1 authorizes only the negative marker, and the affirmative one manufactures automation bias.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** F1, F2
- **Referenced in spec:** Outcome, Primary Flow, The Gate, Open Items

### D3: The lean core is kept, and gains a feedback ask

- **Outcome:** The description keeps its existing shape — a one-sentence bolded summary, a behavior-changes section when runtime behavior changes, a reading-order guide only on a large change — and adds one line stating what kind of feedback the engineer wants. The engineer supplies that line at the gate, and leaving it blank omits the section. When a repository template is in use, the line goes into the template's own section for it when one exists, and is appended after the template's sections when none does — the same treatment the reading-order guide already gets. No issue link and no testing note are added.
- **Rationale:** The user's original instruction was to keep the lean core untouched, and the feedback ask was deferred on the stated cost that it "adds a question to every run." The UX review observed that [D2](#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for) had already spent that cost: the gate now stops and takes free text from the engineer on every run regardless. The deferral's own reopening trigger, written into the first draft of this spec, was therefore satisfied at spec time rather than at some future date. Since the item is the single largest measured effect on merge odds in the entire research base, and it now rides on an interaction already being paid for, keeping it deferred would have been deferring it for a reason that no longer existed.

  The template case was left open by that reasoning and is settled here: a template with no home for the line does not get a new structure invented for it, it gets the line appended, because the conformance rules already prescribe exactly that for the one other section the skill adds of its own accord.

  This is the weakest-supported commitment in the spec, and it is recorded as such. A13 is a single observational preprint; the effect is associative, not causal; and it was measured on open-source pull requests, not on a solo or small-team workflow. The spec carries a matching open item that would drop the ask if engineers leave it blank in practice.
- **Evidence:**
  - `web` — A13: stating the desired feedback type shows the largest single effect of any description element (odds ratio 1.65–1.72, i.e. 64–72% higher merge odds), despite 16.2% prevalence. *2026 preprint, not peer-reviewed; single-source for the figures; observational, so associative rather than causal.*
  - `codebase` — `han-github/skills/update-pr-description/references/template.md`: the current lean default, kept.
  - `codebase` — `han-github/skills/update-pr-description/references/template-conformance.md` section 5: a section the skill adds of its own accord fills the template's equivalent when one exists, and is appended after the template's sections when none does.
  - `provided` — the user chose to keep the lean core, then chose to fold the feedback ask into the gate once its cost basis changed.
- **Rejected alternatives:**
  - *Adopt the research's full recommended core (issue link, feedback ask, testing note).* Rejected: each added section is a new question or a new fabrication surface on every run. Only the item whose cost had already been absorbed was taken.
  - *Ask the feedback question as its own interaction.* Rejected: it is one field on a stop the engineer is already making. A separate question is a separate interruption for no gain.
  - *Keep the feedback ask deferred.* Rejected: the reason for deferring it no longer held.
  - *Omit the feedback line when a repository template has no home for it.* Rejected: it makes the ask silently conditional on template shape, and the conformance rules already answer the question.
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Referenced in spec:** Outcome, The Gate, Deferred (YAGNI), Open Items

### D4: The size fact is delivered at the gate, not shouted past the engineer

- **Outcome:** The skill measures the change and tells the engineer when it is large enough that reviewer defect-finding suffers, and it does so at the gate rather than early in the run. Size is counted as added and deleted lines in significant files. "Significant" carries the definition the skill already applies to its reading-order guide — code files count, documentation and configuration do not — extended to name lockfiles, generated code, and vendored dependencies explicitly, which the existing definition does not. It warns; it never blocks.
- **Rationale:** Change size is the most corroborated finding in the research, across three independent sources over two decades, and it deserves to be said. But the first draft said it in the form guaranteed to be ignored: a non-blocking statement fired at step two of a seven-step flow, immediately before the longest silent stretch of the run, then buried under everything that followed. In a scrolling terminal, that is not a message, it is a message-shaped absence. Attaching the fact to the gate costs nothing and puts it where the engineer is already stopped and already reading.

  The unit matters as much as the placement. The first draft said "four hundred lines" without saying lines of what, which would have fired a lecture about splitting the change at every dependency bump with a large lockfile. A warning that fires on changes nobody can split is a warning engineers train themselves to ignore, and the research names irreducibly-large changes as the known gap in this lever. The existing "significant files" definition covers documentation and configuration only; naming lockfiles, generated code, and vendored dependencies is an extension of it rather than a straight reuse, and it is recorded here as one.
- **Evidence:**
  - `web` — A18: defect-finding drops sharply past 200–400 lines reviewed in one sitting. Vendor-published summary of a widely-cited Cisco study; predates modern PR workflows.
  - `web` — A20: more files in a change correlates with a lower proportion of useful review comments. Independent of A18.
  - `web` — A23: Google converges on the same order of magnitude for the same reason. Independent of both.
  - `web` — the research's O4 trade-offs: the lever "offers no guidance" for irreducibly large changes (migrations, generated code, vendored dependencies).
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 3 defines "significant" files for the reading-order threshold as code files, with documentation and configuration excluded by default. This decision extends that list; it does not restate it.
  - `provided` — the user chose "warn, then continue."
- **Rejected alternatives:**
  - *Fire the warning early, as its own message.* What the first draft specified. Rejected on review: it is unactionable at that moment by the decision's own logic, and it teaches the engineer to skim the skill's non-interactive output, which is the exact habit that later lets them skim the gate.
  - *Block on an oversized change.* Rejected: the work is already done, so blocking punishes a decision the engineer cannot cheaply reverse.
  - *Warn, and scale the description's structure with size.* Rejected: it adds a second threshold to tune, and no evidence gives one.
  - *Say nothing.* Rejected: it discards the best-corroborated finding in the research.
- **Linked technical notes:** —
- **Driven by findings:** F5, F6
- **Referenced in spec:** Primary Flow, User Interactions, Deferred (YAGNI)

### D7: The engineer's verdict is binding, and re-rendering does not re-draft

- **Outcome:** A claim the engineer corrects is used as they wrote it. A claim they reject is removed. The description is re-rendered from the assertions that survive — the surviving assertions are re-joined into readable prose, and no new assertion is introduced. The skill does not re-draft over a correction to improve its wording. The re-rendered description is shown to the engineer before anything is published, so the text a reviewer will read is text a human has seen.
- **Rationale:** The gate is worth having only if the engineer's verdict binds. Any behavior that lets a rejected claim survive, or that "improves" a correction back toward the draft's wording, reintroduces the unverified text the gate exists to catch, and the engineer would not see it a second time.

  The reviewers pressed on the difference between re-rendering and re-drafting, which the first draft left as a bare word. It is a real distinction and it is narrow: re-rendering may rearrange and re-join what survives so the prose reads as English, because deleting one assertion from a paragraph otherwise leaves a dangling connective. It may not assert anything that was not already verified. The test is whether a reader of the re-rendered description could learn a fact the engineer never approved. If yes, it is a re-draft.

  Showing the re-rendered text back is the safety net on that rule, and it closes a hole this synthesis found: [D11](#d11-nothing-rewrites-the-draft-between-authoring-and-the-gate) rejects a post-gate readability pass on the grounds that it produces "final text no human ever saw," and re-rendering is itself a change to the words after approval. The rules are consistent only if the engineer sees the result, so the spec now says they do.
- **Evidence:**
  - `web` — A26: it is inappropriate to hand a reviewer text the author has not personally validated. A correction the tool overrides is text the author did not validate, and so is a re-rendering the author never saw.
  - `provided` — implied by the user's selection of the claim-by-claim gate; the gate is meaningless without a binding verdict.
- **Rejected alternatives:**
  - *Re-draft after corrections, to smooth the prose.* Rejected: a re-draft can reintroduce an unverified claim.
  - *Purely mechanical deletion, with no re-joining.* Rejected on review: it produces orphaned fragments and dangling connectives, and a description that reads as broken invites the engineer to fix it by hand outside the gate.
  - *Re-render without showing the result.* Rejected in synthesis: it is the same objection D11 raises against a post-gate rewrite, and the fix costs one display.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** F7
- **Referenced in spec:** Primary Flow, Alternate Flows and States

### D10: Evidence is the diff, or a cited repository file

- **Outcome:** A claim is evidenced when the skill can point at the part of the diff it was written from, *or* at the repository file it was written from. Only a claim the skill can point at nothing for is marked unevidenced and blocks.
- **Rationale:** The first draft defined evidence as the diff alone while simultaneously granting the drafting pass permission to read surrounding source to understand a change the diff does not explain. Two reviewers found the contradiction independently. A claim like "the flag defaults to off," where the default lives in an unchanged file, is true, well-evidenced, and not in the diff. Under the first draft it would have been marked unevidenced and blocked, identically to a hallucination.

  That is not a cosmetic bug. False positives on the unevidenced marker are more corrosive than false negatives: if a third of the blocking items turn out to be true-but-out-of-diff, the engineer learns the marker is noise and starts clearing it reflexively, which is the wave-through habit arriving through the back door. The marker only works if it is rare and it means something.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 4 instructs the authoring agent to "Read additional source files ... when the diff alone does not explain the change," while the first draft's gate rule recognized only the diff.
  - `web` — A27: the failure mode is a gate people stop genuinely performing; a marker that cries wolf is a direct route there. *2026 preprint; see D2's caveat.*
- **Rejected alternatives:**
  - *Forbid claims resting on anything but the diff.* Rejected: it would forbid true and useful claims a reviewer needs, and the drafting pass reads surrounding source precisely because the diff alone often does not explain a change.
  - *A third "supported by repository context" category, distinct from diff-supported.* Rejected under the simpler-version test: the engineer's job at the gate is to look at the evidence, and the evidence's provenance is visible in what they are shown. A third label adds a taxonomy without adding a decision.
- **Linked technical notes:** —
- **Driven by findings:** F8
- **Referenced in spec:** Edge Cases and Failure Modes

### D11: Nothing rewrites the draft between authoring and the gate

- **Outcome:** The pass that writes the description writes it to the readability standard and to the template's required shape, and records each claim's evidence, in the same act. No pass runs over the draft afterward to improve it, correct its structure, or bring it into conformance. The text shown at the gate is the text that was authored against the evidence.
- **Rationale:** The current skill dispatches a readability editor after authoring, which rewrites the draft while preserving its facts. Under the new gate that pass becomes actively harmful, and the danger is easy to miss: a rewrite that preserves every fact still restates every claim in new words. The text shown at the gate would no longer be the text whose evidence was recorded. That is precisely the reconstruction [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time) rules out, arriving through a pass nobody thought of as generative.

  The scope of this rule is wider than the first draft's, and the widening is a synthesis finding rather than a reviewer one. The readability editor is not the only pass that rewrites the draft after it is authored: the skill also runs a readability self-check and a structural verification step, both of which end with an instruction to fix what they find. Every one of those is the same hazard wearing different clothes. Naming only the readability editor would have left two live rewrite paths in a skill whose gate depends on there being none. The rule is therefore stated over any pass that touches the words, and conformance is something the authoring pass satisfies rather than something a later pass repairs.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 4 dispatches `han-core:readability-editor` after authoring and applies its rewrite as the working description.
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 4 also runs a readability self-check that ends "fix any failure before finalizing," and Step 5 verifies structure and ends "Fix any issues directly before proceeding to Step 6." Two further rewrite paths over authored text.
  - `codebase` — `han-github/references/readability-rule.md`: the standard, which the repository applies broadly and which this decision keeps.
  - `provided` — the user chose to fold readability into authoring over the two alternatives.
- **Rejected alternatives:**
  - *Run the readability pass after the gate.* Rejected: it rewords claims the engineer had just approved, producing final text no human ever saw.
  - *Drop the readability standard.* Rejected: it abandons a house convention for no reason; the standard is not what caused the problem, the second pass was.
  - *Keep the pass where it is.* Rejected: it silently guts the gate.
  - *Name only the readability editor and leave the verification passes alone.* Rejected in synthesis: they rewrite authored text too, and the gate cannot tell the difference between a rewrite it authorized and one it did not.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** F9
- **Referenced in spec:** Primary Flow

### D12: A claim is one independently verifiable assertion, and the gate covers every assertion the reviewer will read

- **Outcome:** The unit of the gate is one independently verifiable assertion, not one sentence. A sentence carrying two assertions yields two items, so the engineer can reject one and keep the other. The gate covers the summary sentence, the behavior-changes prose, any prose filled into a repository template's sections, any note saying a template's section does not apply, and every checklist box the draft proposes to check. The reading-order guide is navigational, asserts nothing about the change, and is not gated.
- **Rationale:** All three reviewers found that the first draft never defined "claim," and that the gate's entire weight rests on that word. Left undefined, an implementer could satisfy the spec with three coarse claims each evidenced by the whole diff, which verifies nothing, or with twenty-five atomic ones, which nobody reads. The skill's own summary template makes the problem concrete: `This PR <verb> <behavior>, so that <why>` fuses an evidenced claim and an unprovable intent in one sentence, and the `<behavior>` slot alone can bundle two facts.

  Scoping the gate to the lean core is what keeps it small. The description is two to five short paragraphs by construction, so the assertion count stays in a range a person will actually read. That is a prediction, not a measurement, and it is carried as an open item.

  Checklist boxes are in scope because a checked box is an assertion made to the reviewer in the engineer's name. Leaving it out would break the gate's promise on the one item type that most looks like an attestation. The "not applicable" notes the conformance rules generate are in scope for the same reason, and this synthesis added them: the reviewers raised the question and the first resolution answered it only for the post-rejection case. A note saying a section does not apply is an assertion of absence written in the engineer's name, and it now blocks under [D15](#d15-absence-claims-are-structurally-unprovable-like-intent) like any other.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/references/template.md`: the summary sentence's fused shape, `**This PR <verb> <behavior>, so that <why>.**`
  - `codebase` — `han-github/skills/update-pr-description/references/template-conformance.md` section 4: boxes are checked on the engineer's behalf and constrained to what the diff proves; section 6: an unfillable section gets "a short honest note" written for it.
  - `web` — A26: text handed to a reviewer that the author did not validate. A checked box and an unprompted "not applicable" are both such text.
- **Rejected alternatives:**
  - *One claim per sentence.* Rejected: a sentence bundling a true and a false assertion forces the engineer to reject both or accept both.
  - *One claim per clause.* Rejected under the simpler-version test: it inflates the item count without adding decisions, and an unreadably long gate is a gate that gets skimmed.
  - *Exclude checklist boxes from the gate.* Rejected: it breaks the gate's promise where the promise matters most.
  - *Gate the reading-order guide.* Rejected: it points at where to read, and asserts nothing that can be true or false about the change.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** F10, F11
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, Open Items

### D13: The gate fails closed

- **Outcome:** If the skill cannot obtain an answer from a human at the gate, that silence is not approval. The description is delivered marked unverified, and nothing is published.
- **Rationale:** This is not a hypothetical, though the precise scope of the hazard matters and the first draft overstated it. The repository's own skill-building guidance documents that the interactive question mechanism returns empty answers, with the user never seeing the question, when the skill lists it among its auto-approved tools — and that a parent skill's auto-approval rules stack onto every child skill it invokes. The first condition is one this skill controls and must avoid. The second is one it cannot control at all: a skill that calls this one can silently disable its gate.

  A gate whose entire value is that a human answered it, running on a mechanism that can silently answer nothing whenever a caller is misconfigured, would publish unverified claims to a public pull request under the engineer's name with no human error involved at all. Failing closed costs a run; failing open costs the feature. The cost of failing closed is real and is recorded in the spec's Open Items: a skill invoked from a misconfigured parent will never publish, and nobody has yet run it that way.
- **Evidence:**
  - `codebase` — `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md`: the tool "returns immediately with empty answers. The user never sees the question," when it is listed in `allowed-tools`; and "If a parent skill has `AskUserQuestion` in its `allowed-tools`, every child skill's AskUserQuestion calls will also silently fail." The upstream bug was closed in March 2026 with a fix noted as upcoming, and the document records it still reproducing afterward.
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` frontmatter does not list the question tool in `allowed-tools`, so the failure is a caller-side risk here rather than a present defect. The rule exists because the skill cannot see its callers.
  - `web` — A27: the documented outcome of gates that do not actually get performed. *2026 preprint; see D2's caveat.*
- **Rejected alternatives:**
  - *Treat no answer as approval.* Rejected: it is the feature's failure mode, reached with zero human involvement.
  - *Leave it unspecified.* Rejected: unspecified defaults resolve to whatever is easiest, which here is failing open.
  - *Rely on the skill's own configuration being correct and say nothing.* Rejected in synthesis: the documented propagation path runs from a parent this skill cannot inspect.
- **Linked technical notes:** —
- **Driven by findings:** F3
- **Referenced in spec:** The Gate, Open Items

### D14: Replacing an existing description is disclosed before it happens

- **Outcome:** When the pull request already has a description, it is replaced rather than merged into. Before asking to publish, the skill says what is about to be lost.
- **Rationale:** The skill is called `update-pr-description`, so running it against a pull request that already has one is not an edge case, it is the name. Two reviewers flagged the same irony: the gate next door goes to great lengths to protect the reviewer from text the engineer did not validate, while the publish step silently destroys the text the engineer most certainly did — a hand-written description, reviewer notes, a ticket link. The engineer approves *claims* at the gate; they are never asked to approve a *deletion*.

  Disclosure is the proportionate fix. Merging into an existing description was considered and rejected: it would mean the skill reasoning about which human sentences to keep, which is a larger feature and a new fabrication surface. Saying plainly what is about to go, and letting the engineer decline, converts an undisclosed destructive action into a disclosed one at the cost of one sentence.

  This interacts with the deferred issue link: a re-run deletes a link the engineer added by hand and does not put one back. Disclosure makes that visible. It does not solve it, and the spec says so.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 6.3 runs `gh pr edit --body`, a whole-body replacement, on a yes/no with no disclosure of the prior content.
  - `web` — A26: the text an author personally validated is the valuable text. This flow destroyed exactly that.
- **Rejected alternatives:**
  - *Merge the generated description into the existing one.* Rejected: it requires the skill to judge which human sentences survive, which is a bigger feature and a new place to fabricate.
  - *Replace silently.* Rejected: it is a destructive write to a system of record, performed without the engineer knowing what was there.
- **Linked technical notes:** —
- **Driven by findings:** F13
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, Out of Scope, Deferred (YAGNI)

### D15: Absence claims are structurally unprovable, like intent

- **Outcome:** A claim that nothing changed — no behavior change for existing callers, no impact on a caller, a template section that does not apply — is a blocking gate item. The engineer vouches for it or it is dropped. It is not treated as an ordinary unevidenced claim.
- **Rationale:** A diff can prove what changed and can never prove that nothing else did. The first draft recognized this for the intent sentence and gave it a dedicated path, then left absence claims to the generic unevidenced bucket, which has them fire on every no-behavior-change pull request by design. A marker that fires routinely, for a reason that is structural rather than suspicious, is a marker the engineer learns to clear without reading. Naming absence as its own always-unprovable category keeps the unevidenced marker meaning what it says: *the skill wrote something it could not point at*.

  The "not applicable" note a template forces is the same shape of claim and is routed the same way, which is how [D12](#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read) and [D8](#d8-repository-template-conformance-is-carried-forward-and-its-fill-passes-through-the-gate) stay consistent with each other.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 4 conditions the behavior-changes section on whether runtime behavior changed, so the "nothing changed" judgment is one the skill routinely makes.
  - `codebase` — `han-github/skills/update-pr-description/references/template-conformance.md` section 6 has the skill write "Not applicable" notes on the engineer's behalf today.
  - `web` — A27, via the same reasoning as [D10](#d10-evidence-is-the-diff-or-a-cited-repository-file): a marker that cries wolf trains the wave-through habit.
- **Rejected alternatives:**
  - *Leave absence claims in the generic unevidenced bucket.* Rejected: it dilutes the one signal the gate depends on.
  - *Let absence claims pass unblocked.* Rejected: an unchallenged "no behavior changes for existing callers" is among the most consequential things a description can get wrong.
- **Linked technical notes:** —
- **Driven by findings:** F14
- **Referenced in spec:** The Gate, Edge Cases and Failure Modes

### D16: A section emptied by rejections returns to the engineer

- **Outcome:** When the engineer rejects every claim in a section a repository template requires, the empty section is handed back to them: they write it, or mark it explicitly not applicable. The skill does not compose an honest-sounding note on their behalf.
- **Rationale:** The template conformance rules carried forward under [D8](#d8-repository-template-conformance-is-carried-forward-and-its-fill-passes-through-the-gate) require every template section to stay present, filled with content or an honest "not applicable" note, never silently dropped. [D7](#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft) forbids the skill from drafting new text after the gate. An edge-case reviewer found these two rules collide exactly when a rejection empties a mandatory section, and that the spec named no winner, so an implementer would have silently violated one of them.

  Returning the section to the engineer honors both. The template keeps its section, the skill invents nothing, and the one person who can say what belongs there says it.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/references/template-conformance.md` section 6: every template section stays, filled or honestly noted.
  - `codebase` — this log's [D7](#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft): no re-drafting after the gate.
- **Rejected alternatives:**
  - *Auto-fill "Not applicable."* Rejected: it is an assertion to the reviewer that the engineer never made, which is the thing the gate exists to prevent.
  - *Leave the section present and empty.* Rejected: it violates the template contract and reads as an oversight.
- **Linked technical notes:** —
- **Driven by findings:** F12
- **Referenced in spec:** Edge Cases and Failure Modes, User Interactions

### D17: The engineer may state intent before the draft is written

- **Outcome:** The engineer can state why they made the change when they invoke the skill. The draft is then written against that intent rather than guessing at it. It stays optional, and the intent sentence still blocks at the gate, because the draft renders that intent in its own words.
- **Rationale:** The gate catches invented claims. Preventing them is cheaper than catching them, and the largest single source of invention is the skill guessing at a "why" that lives only in the engineer's head. A draft written against a stated intent invents less, which makes the gate shorter, which makes the gate more likely to be read. Error prevention compounds with the gate rather than competing with it.

  It costs nothing to add: the skill already accepts optional context as an argument. This decision gives that argument a job.

  Why the intent sentence still blocks even when the engineer supplied it: the draft writes *against* their intent, not verbatim from it, so the sentence a reviewer reads is the skill's rendering of what they said. [D21](#d21-editing-the-draft-directly-verifies-what-was-edited-and-nothing-else) exempts text the engineer wrote from further verification; it does not exempt text the skill wrote from text the engineer wrote. Confirming a rendering is one keystroke and it is the right one.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` frontmatter already declares `argument-hint: "[optional context about the PR]"`, and no step in the skill body consumes it.
  - `web` — A5: the "why" is the thing source code cannot reveal, and the thing the description exists to carry.
- **Rejected alternatives:**
  - *Require the intent up front.* Rejected: it puts a mandatory question before the engineer has seen anything, and the gate already blocks on intent, so the requirement would be redundant as well as annoying.
  - *Skip the intent gate item when the engineer supplied intent up front.* Rejected in synthesis: the skill rewrote their sentence, and the rewrite is what ships.
- **Linked technical notes:** —
- **Driven by findings:** F17
- **Referenced in spec:** Actors and Triggers, Primary Flow, The Gate, Edge Cases and Failure Modes

### D18: An incomplete read of the diff is disclosed as its own condition

- **Outcome:** When the skill could not read the whole diff, it says so at the gate, and says which parts it did not read. This is a separate fact from the size warning.
- **Rationale:** The first draft answered "the diff is too large to read in full" by pointing at the size warning, which two reviewers correctly called a non-answer. The size warning is about a *reviewer's* defect-finding falling off past a few hundred lines. It says nothing about the *skill's* own blindness, and the two conditions are unrelated: a two-thousand-line lockfile diff is large but perfectly readable, while a genuinely truncated read can happen without the engineer ever knowing.

  This is the gate's one silent failure surface. The gate can only show the claims that exist; it cannot show a claim about a file the skill never opened. An engineer who verifies every item on the screen would reasonably believe they verified the change, when they verified a description of an unknown subset of it. A gate that cannot be complete has to say that it is not.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` injects the full diff into its context unconditionally and interpolates it into the authoring prompt, with no size guard and no truncation signal.
  - `web` — A25: GitHub's own summarizer excludes files with more than 400 combined changed lines, evidence that a real generator hits real limits and must decide what to say about them.
- **Rejected alternatives:**
  - *Fold it into the size warning.* Rejected: the two facts are unrelated, and folding them means the skill never actually says the thing that matters.
  - *Say nothing.* Rejected: it is the one way the gate can be silently, invisibly wrong.
- **Linked technical notes:** —
- **Driven by findings:** F15
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D21: Editing the draft directly verifies what was edited, and nothing else

- **Outcome:** The engineer can edit the draft directly at the gate. Text they wrote is text they verified, and needs no further evidence. Editing is not an exit: any claim they did not touch is still theirs to dispose of, and the blocking items still block.
- **Rationale:** The first draft offered direct editing as a third option beside confirm and correct, and said nothing about what it did to the gate's state. As written it was a one-keystroke path from twenty unread claims to publish. The option is legitimate and worth keeping, for the reason [D7](#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft) already gives: text the engineer authored is text the engineer validated. It just cannot double as a bypass for the text they did not author.
- **Evidence:**
  - `web` — A26: the author must personally validate what the reviewer reads. Direct authorship is the strongest form of that validation, which is exactly why it does not extend to text they did not write.
- **Rejected alternatives:**
  - *Treat a direct edit as full verification of the description.* Rejected: it verifies the sentences they touched, and says nothing about the rest.
  - *Forbid direct editing.* Rejected: it is the fastest correct path when the draft is broadly wrong, and blocking it pushes the engineer out of the skill entirely.
- **Linked technical notes:** —
- **Driven by findings:** F16
- **Referenced in spec:** The Gate

## Trivial decisions

Short decisions, each with a heading so the spec's inline citations resolve.

### D1: Rebuild in place

The existing `/update-pr-description` skill is rebuilt rather than a second skill added alongside it. Considered a parallel skill; rejected because two skills for one job is a routing problem, not a feature.

- **Driven by findings:** —
- **Referenced in spec:** — (the rebuild is the spec's premise, not a behavior it states)

### D5: Authoring is a writing pass, not a repurposed critique pass

The description is authored by a pass whose native output is finished prose, so the skill carries no retry path for a critique agent reverting to producing a review report. Considered leaving the agent choice to implementation planning, which is its ordinary home; settled here on the user's explicit instruction, and subsumed by [D11](#d11-nothing-rewrites-the-draft-between-authoring-and-the-gate), which folds readability and conformance into the same pass. This decision is deliberately not surfaced in the spec: it is a pipeline mechanic, and the spec states behavior.

- **Evidence:** `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 4 dispatches `han-core:junior-developer` to author the description and carries a documented discard-and-re-issue retry path for when it returns a review report instead; `han-core/agents/junior-developer.md` declares an adversarial-collaboration critique purpose whose native output is a review report.
- **Driven by findings:** F9, F18
- **Referenced in spec:** — (routed out of the spec by F18)

### D6: The gate runs whether or not a pull request exists

The claim-by-claim check runs before the description is presented as final, including when there is no PR to publish to and the engineer will paste the text by hand.

- **Driven by findings:** —
- **Referenced in spec:** Alternate Flows and States

### D8: Repository template conformance is carried forward, and its fill passes through the gate

The existing rules for discovering a template, preserving its section order, checking only diff-provable boxes, and appending a section the template has no home for are kept (`han-github/skills/update-pr-description/references/template-conformance.md`); no evidence surfaced for changing them. What changes is that the fill those rules produce — section prose, checked boxes, "not applicable" notes — is not final text any more. It is a set of proposals that pass through the gate like every other assertion ([D12](#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read), [D15](#d15-absence-claims-are-structurally-unprovable-like-intent)).

- **Driven by findings:** F11, F12
- **Referenced in spec:** Outcome, Primary Flow, Edge Cases and Failure Modes

### D9: The reading-order guide keeps its existing threshold

"What to look at first" still appears only past roughly eight to ten significant code files, and it is not a gate item, because it points at where to read rather than asserting anything about the change ([D12](#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read)).

- **Driven by findings:** —
- **Referenced in spec:** Primary Flow (the one part of the description the gate does not cover). The threshold itself rides inside the lean core, which the spec's Outcome carries via [D3](#d3-the-lean-core-is-kept-and-gains-a-feedback-ask).

### D19: A re-run re-drafts and re-gates

Running the skill again on the same branch re-drafts from the current diff and re-gates from scratch; verified claims are not carried across runs, because the diff they were verified against has changed.

- **Driven by findings:** F22
- **Referenced in spec:** Alternate Flows and States, Deferred (YAGNI)

### D20: The verified description is written to a file

The deliverable is a file the engineer can take away, not a block of markdown they must select out of terminal scrollback, whether or not the skill publishes it.

- **Driven by findings:** F21
- **Referenced in spec:** Primary Flow

### D22: The existing branch-state and template-discovery guards are carried forward

The skill's current guards are kept unchanged: it stops when the branch has no commits or no file changes, it asks for the default branch when it cannot determine one, and it asks which template to conform to when the repository offers several. They are cited here so no behavior in the spec rests on nothing.

- **Evidence:** `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 1 (branch-state validation and the default-branch question) and Step 2.3 (the multiple-template question, including the "None" option).
- **Driven by findings:** — (added in synthesis to close an uncited-commitment gap)
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Edge Cases and Failure Modes

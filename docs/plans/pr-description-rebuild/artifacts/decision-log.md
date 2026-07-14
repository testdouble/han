# Decision Log: Verified PR Descriptions

Decisions behind [../feature-specification.md](../feature-specification.md). Full decisions carry rationale, evidence, and rejected alternatives. Trivial decisions are one-liners.

Evidence trust classes follow [the evidence rule](../../../../han-core/references/evidence-rule.md): `codebase` (read from this repository), `web` (external source, cited by ID from `docs/research/effective-pull-request-descriptions.md`), `provided` (stated by the user).

## Full decisions

### D2: The gate shows each claim with its evidence, and blocks on what the skill cannot vouch for

- **Outcome:** Before the description is final, the skill lists every assertion it makes and shows the evidence recorded for each. Three kinds of item block: a claim the skill could not evidence, a claim about absence, and the statement of intent (with the feedback ask). Each must be individually disposed of, with no bulk path over them. Every other claim may be accepted together once the blocking items are settled. The gate does not label a claim "supported" or otherwise vouch for it; it shows the claim and the evidence and lets the engineer judge.
- **Rationale:** The research hands the rebuild this gap explicitly and declines to close it. The first draft of this spec closed it badly: it offered a "confirm the list as it stands" option, which is one action discharging every obligation on the screen. All three reviewers independently found that this reproduces the exact failure the gate exists to prevent. Making the careless path cost one keystroke while the careful path costs N is a choice architecture that guarantees the careless path, and it gets worse precisely as the diff gets larger, which is where the fabrication risk is highest. Blocking only on the items the skill genuinely cannot vouch for costs nothing on a clean change and cannot be skipped on a dirty one.

  Dropping the affirmative "supported" label came from the same review and is the sharper half. [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time) establishes that only the authoring pass can honestly say *I could not evidence this*. It does not establish that the same pass can honestly say *this one is evidenced*, and that is the identical self-assessment T1 rejects. A "supported" badge on a fabricated claim is worse than no badge: it tells the engineer which rows to skip, and a plausible-looking hunk under a fabricated claim is exactly what hides there.
- **Evidence:**
  - `web` — A25: GitHub's own documentation admits a "known risk" of hallucination in generated summaries and asks for careful human review of every one.
  - `web` — A28: measured tendency for AI descriptions to claim functionality absent from the diff. Independent of A25.
  - `web` — A27: ~61% of AI-authored PRs get no recorded human review. *Single-source, and shares a dataset with A24; carried as a risk signal, not a measurement of this design.*
  - `web` — the research's own V5 finding: the gate "must be structurally enforced ... or the option inherits A27's failure mode."
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 6: today's gate is a yes/no on finished prose.
  - `provided` — the user chose the claim-by-claim gate over two weaker options.
- **Rejected alternatives:**
  - *A single "confirm the list as it stands" option.* What the first draft specified. Rejected on unanimous review: it makes waving through exactly one action, structurally identical to the yes/no gate being replaced, and merely longer.
  - *Confirm the intent sentence only.* Closes the intent hole and leaves A28's measured failure untouched. Rejected because the claim hole is the one with direct empirical support.
  - *Keep the yes/no gate.* Rejected as the named failure mode.
  - *Label evidenced claims "supported".* Rejected: T1 authorizes only the negative marker, and the affirmative one manufactures automation bias.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** F1, F2, F3
- **Referenced in spec:** Outcome, Primary Flow, The Gate

### D3: The lean core is kept, and gains a feedback ask

- **Outcome:** The description keeps its existing shape — a one-sentence bolded summary, a behavior-changes section when runtime behavior changes, a reading-order guide only on a large change — and adds one line stating what kind of feedback the engineer wants. The engineer supplies that line at the gate, and leaving it blank omits the section. No issue link and no testing note are added.
- **Rationale:** The user's original instruction was to keep the lean core untouched, and the feedback ask was deferred on the stated cost that it "adds a question to every run." The UX review observed that [D2](#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for) had already spent that cost: the gate now stops and takes free text from the engineer on every run regardless. The deferral's own reopening trigger, written into the first draft of this spec, was therefore satisfied at spec time rather than at some future date. Since the item is the single largest measured effect on merge odds in the entire research base, and it now rides on an interaction already being paid for, keeping it deferred would have been deferring it for a reason that no longer existed.
- **Evidence:**
  - `web` — A13: stating the desired feedback type shows the largest single effect of any description element (odds ratio 1.65–1.72, i.e. 64–72% higher merge odds), despite 16.2% prevalence. *2026 preprint, not peer-reviewed; single-source for the figures.*
  - `codebase` — `han-github/skills/update-pr-description/references/template.md`: the current lean default, kept.
  - `provided` — the user chose to keep the lean core, then chose to fold the feedback ask into the gate once its cost basis changed.
- **Rejected alternatives:**
  - *Adopt the research's full recommended core (issue link, feedback ask, testing note).* Rejected: each added section is a new question or a new fabrication surface on every run. Only the item whose cost had already been absorbed was taken.
  - *Ask the feedback question as its own interaction.* Rejected: it is one field on a stop the engineer is already making. A separate question is a separate interruption for no gain.
  - *Keep the feedback ask deferred.* Rejected: the reason for deferring it no longer held.
- **Linked technical notes:** —
- **Driven by findings:** F4
- **Referenced in spec:** Outcome, The Gate

### D4: The size fact is delivered at the gate, not shouted past the engineer

- **Outcome:** The skill measures the change and tells the engineer when it is large enough that reviewer defect-finding suffers, and it does so at the gate rather than early in the run. Size is counted as added and deleted lines in significant files, reusing the definition the skill already applies to its reading-order guide: code files count, and documentation, configuration, lockfiles, generated code, and vendored dependencies do not. It warns; it never blocks.
- **Rationale:** Change size is the most corroborated finding in the research, across three independent sources over two decades, and it deserves to be said. But the first draft said it in the form guaranteed to be ignored: a non-blocking statement fired at step two of a seven-step flow, immediately before the longest silent stretch of the run, then buried under everything that followed. In a scrolling terminal, that is not a message, it is a message-shaped absence. Attaching the fact to the gate costs nothing and puts it where the engineer is already stopped and already reading.

  The unit matters as much as the placement. The first draft said "four hundred lines" without saying lines of what, which would have fired a lecture about splitting the change at every dependency bump with a large lockfile. A warning that fires on changes nobody can split is a warning engineers train themselves to ignore, and the research names irreducibly-large changes as the known gap in this lever.
- **Evidence:**
  - `web` — A18: defect-finding drops sharply past 200–400 lines reviewed in one sitting.
  - `web` — A20: more files in a change correlates with a lower proportion of useful review comments. Independent of A18.
  - `web` — A23: Google converges on the same order of magnitude for the same reason. Independent of both.
  - `web` — the research's O4 trade-offs: the lever "offers no guidance" for irreducibly large changes (migrations, generated code, vendored dependencies).
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 3 already defines "significant" files for the reading-order threshold; reusing it avoids a second definition.
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

- **Outcome:** A claim the engineer corrects is used as they wrote it. A claim they reject is removed. The description is re-rendered from the assertions that survive — the surviving assertions are re-joined into readable prose, and no new assertion is introduced. The skill does not re-draft over a correction to improve its wording.
- **Rationale:** The gate is worth having only if the engineer's verdict binds. Any behavior that lets a rejected claim survive, or that "improves" a correction back toward the draft's wording, reintroduces the unverified text the gate exists to catch, and the engineer would not see it a second time.

  The reviewers pressed on the difference between re-rendering and re-drafting, which the first draft left as a bare word. It is a real distinction and it is narrow: re-rendering may rearrange and re-join what survives so the prose reads as English, because deleting one assertion from a paragraph otherwise leaves a dangling connective. It may not assert anything that was not already verified. The test is whether a reader of the re-rendered description could learn a fact the engineer never approved. If yes, it is a re-draft.
- **Evidence:**
  - `web` — A26: it is inappropriate to hand a reviewer text the author has not personally validated. A correction the tool overrides is text the author did not validate.
  - `provided` — implied by the user's selection of the claim-by-claim gate; the gate is meaningless without a binding verdict.
- **Rejected alternatives:**
  - *Re-draft after corrections, to smooth the prose.* Rejected: a re-draft can reintroduce an unverified claim.
  - *Purely mechanical deletion, with no re-joining.* Rejected on review: it produces orphaned fragments and dangling connectives, and a description that reads as broken invites the engineer to fix it by hand outside the gate.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** F7
- **Referenced in spec:** Primary Flow

### D10: Evidence is the diff, or a cited repository file

- **Outcome:** A claim is evidenced when the skill can point at the part of the diff it was written from, *or* at the repository file it was written from. Only a claim the skill can point at nothing for is marked unevidenced and blocks.
- **Rationale:** The first draft defined evidence as the diff alone while simultaneously granting the drafting pass permission to read surrounding source to understand a change the diff does not explain. Two reviewers found the contradiction independently. A claim like "the flag defaults to off," where the default lives in an unchanged file, is true, well-evidenced, and not in the diff. Under the first draft it would have been marked unevidenced and blocked, identically to a hallucination.

  That is not a cosmetic bug. False positives on the unevidenced marker are more corrosive than false negatives: if a third of the blocking items turn out to be true-but-out-of-diff, the engineer learns the marker is noise and starts clearing it reflexively, which is the wave-through habit arriving through the back door. The marker only works if it is rare and it means something.
- **Evidence:**
  - `codebase` — the first draft's own Coordinations section granted repository-file reads while its gate rule recognized only the diff.
  - `web` — A27: the failure mode is a gate people stop genuinely performing; a marker that cries wolf is a direct route there.
- **Rejected alternatives:**
  - *Forbid claims resting on anything but the diff.* Rejected: it would forbid true and useful claims a reviewer needs, and the drafting pass reads surrounding source precisely because the diff alone often does not explain a change.
  - *A third "supported by repository context" category, distinct from diff-supported.* Rejected under the simpler-version test: the engineer's job at the gate is to look at the evidence, and the evidence's provenance is visible in what they are shown. A third label adds a taxonomy without adding a decision.
- **Linked technical notes:** —
- **Driven by findings:** F8
- **Referenced in spec:** Edge Cases and Failure Modes

### D11: Readability and authoring are one pass

- **Outcome:** The pass that writes the description writes it to the readability standard and records each claim's evidence in the same act. No separate rewrite pass runs over the draft afterward.
- **Rationale:** The current skill dispatches a readability editor after authoring, which rewrites the draft while preserving its facts. Under the new gate that pass becomes actively harmful, and the danger is easy to miss: a rewrite that preserves every fact still restates every claim in new words. The text shown at the gate would no longer be the text whose evidence was recorded. That is precisely the reconstruction [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time) rules out, arriving through a pass nobody thought of as generative.

  Folding the standard into the authoring pass keeps it and closes the hole. Running it after the gate was considered and rejected: it would reword claims the engineer had just approved, producing final text no human ever saw.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 4 dispatches `han-core:readability-editor` after authoring and applies its rewrite as the working description.
  - `codebase` — `han-github/references/readability-rule.md`: the standard, which the repository applies broadly and which this decision keeps.
  - `provided` — the user chose to fold readability into authoring over the two alternatives.
- **Rejected alternatives:**
  - *Run the readability pass after the gate.* Rejected: it rewords verified claims, so the published text is text no human read.
  - *Drop the readability standard.* Rejected: it abandons a house convention for no reason; the standard is not what caused the problem, the second pass was.
  - *Keep the pass where it is.* Rejected: it silently guts the gate.
- **Linked technical notes:** [T1](feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)
- **Driven by findings:** F9
- **Referenced in spec:** Primary Flow

### D12: A claim is one independently verifiable assertion, and the gate covers every assertion the reviewer will read

- **Outcome:** The unit of the gate is one independently verifiable assertion, not one sentence. A sentence carrying two assertions yields two items, so the engineer can reject one and keep the other. The gate covers the summary sentence, the behavior-changes prose, any prose filled into a repository template's sections, and every checklist box the draft proposes to check. The reading-order guide is navigational, asserts nothing about the change, and is not gated.
- **Rationale:** All three reviewers found that the first draft never defined "claim," and that the gate's entire weight rests on that word. Left undefined, an implementer could satisfy the spec with three coarse claims each evidenced by the whole diff, which verifies nothing, or with twenty-five atomic ones, which nobody reads. The skill's own summary template makes the problem concrete: `This PR <verb> <behavior>, so that <why>` fuses an evidenced claim and an unprovable intent in one sentence, and the `<behavior>` slot alone can bundle two facts.

  Scoping the gate to the lean core is what keeps it small. The description is two to five short paragraphs by construction, so the assertion count stays in a range a person will actually read. That is a prediction, not a measurement, and it is carried as an open item.

  Checklist boxes are in scope because a checked box is an assertion made to the reviewer in the engineer's name. Leaving it out would break the gate's promise on the one item type that most looks like an attestation.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/references/template.md`: the summary sentence's fused shape.
  - `codebase` — `han-github/skills/update-pr-description/references/template-conformance.md`: checklist boxes are asserted on the engineer's behalf and constrained to what the diff proves.
  - `web` — A26: text handed to a reviewer that the author did not validate. A checked box is such text.
- **Rejected alternatives:**
  - *One claim per sentence.* Rejected: a sentence bundling a true and a false assertion forces the engineer to reject both or accept both.
  - *One claim per clause.* Rejected under the simpler-version test: it inflates the item count without adding decisions, and an unreadably long gate is a gate that gets skimmed.
  - *Exclude checklist boxes from the gate.* Rejected: it breaks the gate's promise where the promise matters most.
- **Linked technical notes:** —
- **Driven by findings:** F10, F11
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes

### D13: The gate fails closed

- **Outcome:** If the skill cannot obtain an answer from a human at the gate, that silence is not approval. The description is delivered marked unverified, and nothing is published.
- **Rationale:** This is not a hypothetical. The repository's own skill-building guidance documents that the question mechanism can return empty answers without the user ever seeing the question, including whenever a parent skill has already claimed it. A gate whose entire value is that a human answered it, running on a mechanism documented as capable of silently answering nothing, would publish unverified claims to a public pull request under the engineer's name with no human error involved at all. Failing closed costs a run; failing open costs the feature.
- **Evidence:**
  - `codebase` — `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md`: the tool "returns immediately with empty answers. The user never sees the question," and this propagates to child skills.
  - `web` — A27: the documented outcome of gates that do not actually get performed.
- **Rejected alternatives:**
  - *Treat no answer as approval.* Rejected: it is the feature's failure mode, reached with zero human involvement.
  - *Leave it unspecified.* Rejected: unspecified defaults resolve to whatever is easiest, which here is failing open.
- **Linked technical notes:** —
- **Driven by findings:** F12
- **Referenced in spec:** The Gate

### D14: Replacing an existing description is disclosed before it happens

- **Outcome:** When the pull request already has a description, it is replaced rather than merged into. Before asking to publish, the skill says what is about to be lost.
- **Rationale:** The skill is called `update-pr-description`, so running it against a pull request that already has one is not an edge case, it is the name. Two reviewers flagged the same irony: the gate next door goes to great lengths to protect the reviewer from text the engineer did not validate, while the publish step silently destroys the text the engineer most certainly did — a hand-written description, reviewer notes, a ticket link. The engineer approves *claims* at the gate; they are never asked to approve a *deletion*.

  Disclosure is the proportionate fix. Merging into an existing description was considered and rejected: it would mean the skill reasoning about which human sentences to keep, which is a larger feature and a new fabrication surface. Saying plainly what is about to go, and letting the engineer decline, converts an undisclosed destructive action into a disclosed one at the cost of one sentence.

  This interacts with the deferred issue link: a re-run deletes a link the engineer added by hand and does not put one back. Disclosure makes that visible. It does not solve it, and the spec says so.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` Step 6 runs `gh pr edit --body`, a whole-body replacement, on a yes/no with no disclosure of the prior content.
  - `web` — A26: the text an author personally validated is the valuable text. This flow destroyed exactly that.
- **Rejected alternatives:**
  - *Merge the generated description into the existing one.* Rejected: it requires the skill to judge which human sentences survive, which is a bigger feature and a new place to fabricate.
  - *Replace silently.* Rejected: it is a destructive write to a system of record, performed without the engineer knowing what was there.
- **Linked technical notes:** —
- **Driven by findings:** F13
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, Coordinations, Out of Scope, Deferred (YAGNI)

### D15: Absence claims are structurally unprovable, like intent

- **Outcome:** A claim that nothing changed — no behavior change for existing callers, no impact on a caller — is a blocking gate item. The engineer vouches for it or it is dropped. It is not treated as an ordinary unevidenced claim.
- **Rationale:** A diff can prove what changed and can never prove that nothing else did. The first draft recognized this for the intent sentence and gave it a dedicated path, then left absence claims to the generic unevidenced bucket, which has them fire on every no-behavior-change pull request by design. A marker that fires routinely, for a reason that is structural rather than suspicious, is a marker the engineer learns to clear without reading. Naming absence as its own always-unprovable category keeps the unevidenced marker meaning what it says: *the skill wrote something it could not point at*.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` already conditions the behavior-changes section on whether runtime behavior changed, so the "nothing changed" judgment is one the skill routinely makes.
  - `web` — A27, via the same reasoning as [D10](#d10-evidence-is-the-diff-or-a-cited-repository-file): a marker that cries wolf trains the wave-through habit.
- **Rejected alternatives:**
  - *Leave absence claims in the generic unevidenced bucket.* Rejected: it dilutes the one signal the gate depends on.
  - *Let absence claims pass unblocked.* Rejected: an unchallenged "no behavior changes for existing callers" is among the most consequential things a description can get wrong.
- **Linked technical notes:** —
- **Driven by findings:** F14
- **Referenced in spec:** The Gate

### D16: A section emptied by rejections returns to the engineer

- **Outcome:** When the engineer rejects every claim in a section a repository template requires, the empty section is handed back to them: they write it, or mark it explicitly not applicable. The skill does not compose an honest-sounding note on their behalf.
- **Rationale:** The template conformance rules carried forward under [D8](#d8-repository-template-conformance-is-carried-forward) require every template section to stay present, filled with content or an honest "not applicable" note, never silently dropped. [D7](#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft) forbids the skill from drafting new text after the gate. An edge-case reviewer found these two rules collide exactly when a rejection empties a mandatory section, and that the spec named no winner, so an implementer would have silently violated one of them.

  Returning the section to the engineer honors both. The template keeps its section, the skill invents nothing, and the one person who can say what belongs there says it.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/references/template-conformance.md` section 6: every template section stays, filled or honestly noted.
  - `codebase` — this log's [D7](#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft): no re-drafting after the gate.
- **Rejected alternatives:**
  - *Auto-fill "Not applicable."* Rejected: it is an assertion to the reviewer that the engineer never made, which is the thing the gate exists to prevent.
  - *Leave the section present and empty.* Rejected: it violates the template contract and reads as an oversight.
- **Linked technical notes:** —
- **Driven by findings:** F15
- **Referenced in spec:** Edge Cases and Failure Modes

### D17: The engineer may state intent before the draft is written

- **Outcome:** The engineer can state why they made the change when they invoke the skill. The draft is then written against that intent rather than guessing at it. It stays optional.
- **Rationale:** The gate catches invented claims. Preventing them is cheaper than catching them, and the largest single source of invention is the skill guessing at a "why" that lives only in the engineer's head. A draft written against a stated intent invents less, which makes the gate shorter, which makes the gate more likely to be read. Error prevention compounds with the gate rather than competing with it.

  It costs nothing to add: the skill already accepts optional context as an argument. This decision gives that argument a job.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` frontmatter already declares `argument-hint: "[optional context about the PR]"`.
  - `web` — A5: the "why" is the thing source code cannot reveal, and the thing the description exists to carry.
- **Rejected alternatives:**
  - *Require the intent up front.* Rejected: it puts a mandatory question before the engineer has seen anything, and the gate already blocks on intent, so the requirement would be redundant as well as annoying.
- **Linked technical notes:** —
- **Driven by findings:** F16
- **Referenced in spec:** Actors and Triggers, Primary Flow

### D18: An incomplete read of the diff is disclosed as its own condition

- **Outcome:** When the skill could not read the whole diff, it says so at the gate, and says which parts it did not read. This is a separate fact from the size warning.
- **Rationale:** The first draft answered "the diff is too large to read in full" by pointing at the size warning, which two reviewers correctly called a non-answer. The size warning is about a *reviewer's* defect-finding falling off past a few hundred lines. It says nothing about the *skill's* own blindness, and the two conditions are unrelated: a two-thousand-line lockfile diff is large but perfectly readable, while a genuinely truncated read can happen without the engineer ever knowing.

  This is the gate's one silent failure surface. The gate can only show the claims that exist; it cannot show a claim about a file the skill never opened. An engineer who verifies every item on the screen would reasonably believe they verified the change, when they verified a description of an unknown subset of it. A gate that cannot be complete has to say that it is not.
- **Evidence:**
  - `codebase` — `han-github/skills/update-pr-description/SKILL.md` injects the full diff unconditionally, with no size guard and no truncation signal.
  - `web` — A25: GitHub's own summarizer excludes files past 400 changed lines, evidence that a real generator hits real limits and must decide what to say about them.
- **Rejected alternatives:**
  - *Fold it into the size warning.* Rejected: the two facts are unrelated, and folding them means the skill never actually says the thing that matters.
  - *Say nothing.* Rejected: it is the one way the gate can be silently, invisibly wrong.
- **Linked technical notes:** —
- **Driven by findings:** F17
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
- **Driven by findings:** F18
- **Referenced in spec:** The Gate

## Trivial decisions

- **D1: Rebuild in place** — the existing `/update-pr-description` skill is rebuilt rather than a second skill added alongside it (considered a parallel skill; rejected because two skills for one job is a routing problem, not a feature). — Referenced in spec: Outcome.
- **D5: Authoring is a writing pass, not a repurposed critique pass** — the description is authored by a pass whose native output is finished prose, so the skill carries no retry path for a critique agent reverting to producing a review report (considered leaving the agent choice to implementation planning, which is its ordinary home; settled here on the user's explicit instruction, and subsumed by [D11](#d11-readability-and-authoring-are-one-pass), which folds readability into the same pass). Evidence: `han-github/skills/update-pr-description/SKILL.md` Step 4 carries a documented discard-and-re-issue retry path; `han-core/agents/junior-developer.md` states a critique purpose. — Referenced in spec: Primary Flow.
- **D6: The gate runs whether or not a pull request exists** — the claim-by-claim check runs before the description is presented as final, including when there is no PR to publish to and the engineer will paste the text by hand. — Referenced in spec: Alternate Flows and States.
- **D8: Repository template conformance is carried forward** — the existing rules for discovering a template, preserving its section order, and never checking a box the diff cannot prove are kept as-is (`han-github/skills/update-pr-description/references/template-conformance.md`); no evidence surfaced for changing them. — Referenced in spec: Primary Flow, Edge Cases and Failure Modes.
- **D9: The reading-order guide keeps its existing threshold** — "What to look at first" still appears only past roughly eight to ten significant code files. — Referenced in spec: Primary Flow.
- **D19: A re-run re-drafts and re-gates** — running the skill again on the same branch re-drafts from the current diff and re-gates from scratch; verified claims are not carried across runs, because the diff they were verified against has changed. — Referenced in spec: Alternate Flows and States, Deferred (YAGNI).
- **D20: The verified description is written to a file** — the deliverable is a file the engineer can take away, not a block of markdown they must select out of terminal scrollback, whether or not the skill publishes it. — Referenced in spec: Primary Flow.

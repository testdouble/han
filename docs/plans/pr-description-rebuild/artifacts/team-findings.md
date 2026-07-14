# Team Findings: Verified PR Descriptions

Findings from the review team on the first draft of [../feature-specification.md](../feature-specification.md), and how each was resolved.

- **Feature size:** Medium
- **Team:** `han-core:junior-developer` (generalist stress-test), `han-core:user-experience-designer` (the gate as an interaction model), `han-core:edge-case-explorer` (boundaries of claim-to-evidence pairing)

**Headline:** all three reviewers independently reached the same verdict on the first draft — the gate could be defeated with a single keystroke, and therefore reproduced the exact failure mode it was built to prevent. Every finding below is either that defect, a consequence of it, or a hole the reviewers found while pulling on it. Sixteen of the eighteen major findings were resolved from evidence and two went to the user; separately, two reviewer findings were closed without change, with reasons recorded. A synthesis reconciliation pass afterward found four further holes and is recorded at the end.

## Major findings

### F1: The gate could be waved through in one action

- **Raised by:** `junior-developer` (JD-002), `user-experience-designer` (UX-001, UX-002), independently
- **Finding:** The first draft's `## User Interactions` asserted the gate "is not a formality the engineer can wave through," and then, two sentences earlier, offered "confirm the list as it stands." Confirming cost one action regardless of claim count; scrutiny cost N. The effort ratio between the careless and careful paths widened without bound exactly as the diff grew, which is where the fabrication risk is highest. Structurally identical to the yes/no gate being replaced, only longer. The spec's own rationale quoted the research finding it was violating.
- **Resolved by:** evidence
- **Resolution:** The gate now blocks. Unevidenced claims, absence claims, and the intent statement require individual disposition with no bulk path; everything else may be accepted together once those are settled. Costs nothing on a clean change, cannot be skipped on a dirty one.
- **Affected decisions:** D2
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, The Gate, User Interactions

### F2: The "supported" label manufactures automation bias

- **Raised by:** `user-experience-designer` (UX-003)
- **Finding:** T1 argues only the authoring pass can honestly say *I could not evidence this*. It does not establish the same pass can honestly say *this one is evidenced* — that is the identical self-assessment T1 rejects. Labelling a claim "supported" tells the engineer which rows to skip, and a fabricated claim wearing a plausible-looking hunk is precisely what hides in the skipped rows. The reviewer's conclusion: this could make the gate *worse* than the yes/no gate, which at least did not pretend to have checked.
- **Resolved by:** evidence
- **Resolution:** The affirmative label is gone. The gate shows claim and evidence side by side and lets the engineer render the verdict. Only the negative marker survives, which is the only one T1 authorizes. Strictly simpler, and it satisfies the same evidence.
- **Affected decisions:** D2
- **Affected tech-notes:** T1
- **Changed in spec:** The Gate

### F3: The gate failed open on an unanswered question

- **Raised by:** `user-experience-designer` (UX-004)
- **Finding:** The spec never said what happens when the gate gets no answer. This is not hypothetical: the repository's own guidance documents that the question mechanism can return empty answers with the user never seeing the question, and that this propagates to child skills. A gate whose entire value is that a human answered it would have published unverified claims to a public pull request, under the engineer's name, with zero human error involved.
- **Resolved by:** evidence
- **Resolution:** The gate fails closed. No answer is never approval; the description is delivered marked unverified and nothing is published. The synthesis pass narrowed the evidence claim (the failure occurs when the skill or a parent skill auto-approves the question tool, not unconditionally) and recorded the cost of failing closed as an open item.
- **Affected decisions:** D13
- **Affected tech-notes:** —
- **Changed in spec:** The Gate, Open Items

### F4: D3's deferral rested on a cost D2 had already paid

- **Raised by:** `user-experience-designer` (UX-015)
- **Finding:** The feedback-type section was deferred because it "adds a question to every run." But the gate already stops on every run and already takes free text from the engineer. The deferral's own reopening trigger was satisfied at spec time, by construction. The item is the largest measured effect on merge odds in the entire research base.
- **Resolved by:** user input
- **Resolution:** The user chose to fold the feedback ask into the gate as one field beside the intent confirmation. It rides on an interaction already being paid for. Left blank, the section is omitted. The synthesis pass added where the line goes when a repository template is in use, and recorded the weakness of its single-preprint evidence base as an open item.
- **Affected decisions:** D3
- **Affected tech-notes:** —
- **Changed in spec:** Outcome, The Gate, Deferred (YAGNI), Open Items

### F5: The size warning was placed where nobody would read it

- **Raised by:** `user-experience-designer` (UX-006)
- **Finding:** A non-blocking, admittedly-unactionable message, fired at step two of seven, immediately before the longest silent stretch of the run, then buried under everything after it. The most corroborated finding in the research base, delivered in the form guaranteed to be ignored. Worse: it trains the engineer to skim the skill's non-interactive output, which is the habit that later lets them skim the gate.
- **Resolved by:** evidence
- **Resolution:** The size fact moves to the gate, where the engineer is already stopped and already reading. Same words, same non-blocking intent, placed where attention is.
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, User Interactions

### F6: The size threshold had no unit and no exclusions

- **Raised by:** `junior-developer` (JD-010)
- **Finding:** "More than roughly four hundred lines" never said lines of what, and excluded nothing. A dependency bump with a three-thousand-line lockfile diff would have triggered a lecture about splitting the change. A warning that fires on changes nobody can split is a warning engineers train themselves to ignore — and the research itself names irreducibly-large changes as the known gap in this lever. The skill already has a "significant files" definition and was not reusing it.
- **Resolved by:** evidence
- **Resolution:** Size is added and deleted lines in significant files, carrying the skill's existing definition (code files count; documentation and configuration do not) and extending it to name lockfiles, generated code, and vendored dependencies. The synthesis pass corrected D4's claim that this was a straight reuse: the existing definition does not name those three, so the decision is an extension and now says so.
- **Affected decisions:** D4
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow

### F7: "Re-rendered from what survives" was undefined and contradicted its own decision

- **Raised by:** `junior-developer` (JD-005), `edge-case-explorer` (EC1, EC4)
- **Finding:** D7 forbade re-drafting, but deleting one claim from a prose paragraph leaves dangling connectives and orphaned fragments. Purely mechanical deletion produces broken English; anything that fixes the English is a re-draft. The spec picked neither.
- **Resolved by:** evidence
- **Resolution:** The line is drawn at assertion, not wording. Re-rendering may rearrange and re-join surviving assertions into readable prose; it may not introduce an assertion the engineer did not approve. The test: could a reader of the re-rendered description learn a fact the engineer never approved? If yes, it is a re-draft. The synthesis pass added that the engineer sees the re-rendered text before publication, which is what makes this rule consistent with D11's objection to any post-approval rewrite.
- **Affected decisions:** D7
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow, Alternate Flows and States

### F8: Evidence was defined as the diff, while the spec granted repository reads

- **Raised by:** `junior-developer` (JD-006), `edge-case-explorer` (EC2), independently
- **Finding:** Coordinations let the drafting pass read source files to understand what the diff does not explain. The gate rule recognized only the diff. So a true, well-evidenced claim resting on an unchanged file ("the flag defaults to off") would be marked unevidenced, identically to a hallucination. Both reviewers reached the same conclusion about why this matters: false positives on the unevidenced marker are more corrosive than false negatives, because an engineer who finds the marker usually means nothing learns to clear it reflexively. That is the wave-through habit arriving through the back door.
- **Resolved by:** evidence
- **Resolution:** Evidence is the diff *or* a cited repository file. Only a claim the skill can point at nothing for is marked unevidenced. A third "repository context" category was considered and rejected under the simpler-version test: it adds a taxonomy without adding a decision.
- **Affected decisions:** D10
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes

### F9: The readability rewrite pass would have silently gutted the gate

- **Raised by:** `junior-developer` (JD-004)
- **Finding:** The current skill dispatches a readability editor *after* authoring. The spec neither kept nor dropped it. If kept, it runs between the pass that bound each claim to its evidence and the gate that displays the pairing — and a rewrite that "preserves every fact" still restates every claim in new words, so the text at the gate is no longer the text whose provenance was recorded. That is exactly the reconstruction T1 rules out, arriving through a pass nobody thought of as generative. The likely implementer guess (keep it, it's a house convention) would have quietly destroyed the feature.
- **Resolved by:** user input
- **Resolution:** The user chose to fold readability into the authoring pass. One pass produces the finished prose and records each claim's evidence in the same act. The standard is kept; the second dispatch is gone. The synthesis pass widened the rule to every post-authoring rewrite path, not only the readability editor (see S2).
- **Affected decisions:** D11, D5
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow

### F10: "Claim" was never defined, and the gate's entire weight rests on it

- **Raised by:** `junior-developer` (JD-001), `user-experience-designer` (UX-005), `edge-case-explorer` (EC1) — all three, independently
- **Finding:** Sentence, clause, or assertion? The spec never said. An implementer could satisfy it with three coarse claims each evidenced by the whole diff (a gate that verifies nothing) or twenty-five atomic ones (a gate nobody reads), and neither could be called wrong. The skill's own summary template makes it concrete: `This PR <verb> <behavior>, so that <why>` fuses an evidenced claim and an unprovable intent in one sentence.
- **Resolved by:** evidence
- **Resolution:** A claim is one independently verifiable assertion, so a sentence carrying two yields two items and the engineer can reject one and keep the other. The gate is bounded by scoping it to the lean core, which is two to five short paragraphs by construction. That the resulting count is small enough to be read is a prediction, and it is carried as an open item rather than asserted.
- **Affected decisions:** D12
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes, Open Items

### F11: Checklist boxes are claims and were not gated

- **Raised by:** `junior-developer` (JD-013), `edge-case-explorer` (EC7)
- **Finding:** A checked box is a factual assertion made to the reviewer in the engineer's name. The spec's promise was that the engineer sees every claim matched against evidence; a box checked by the conformance rules and never shown at the gate breaks that promise on the item type that most looks like an attestation. Same question for the "not applicable" notes the template rules generate.
- **Resolved by:** evidence
- **Resolution:** Every checklist box the draft proposes to check is a gate item, as is any prose filled into a template's sections. The reviewers' second question — the "not applicable" notes — was left unanswered by the first resolution and is closed by the synthesis pass (see S1): such a note is a claim of absence and blocks.
- **Affected decisions:** D12, D8
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F12: A rejection could empty a mandatory template section, and two rules collided

- **Raised by:** `edge-case-explorer` (EC4)
- **Finding:** The template rules (carried forward unchanged) require every section to stay present, filled or honestly noted. D7 forbids the skill from drafting new text after the gate. When a rejection empties a mandatory section, the spec named no winner — so an implementer would have silently violated one rule or the other, depending on instinct.
- **Resolved by:** evidence
- **Resolution:** The empty section returns to the engineer: they write it or mark it explicitly not applicable. The template keeps its section, the skill invents nothing.
- **Affected decisions:** D16, D8
- **Affected tech-notes:** —
- **Changed in spec:** Edge Cases and Failure Modes, User Interactions

### F13: Publishing destroyed the engineer's own hand-written description, silently

- **Raised by:** `junior-developer` (JD-008), `user-experience-designer` (UX-008), independently; JD escalated it to `devops-engineer` as a destructive write to a system of record
- **Finding:** The skill replaces the whole PR body. Running it on a pull request that already has a description is not an edge case, it is the skill's name. The confirmation asked whether to proceed, never what would be lost. Both reviewers landed on the same irony: the gate goes to great lengths to protect the reviewer from text the engineer did not validate, while the publish step destroys the text they certainly did. And because the issue link is deliberately not generated, the most common re-run outcome was: delete the engineer's ticket link, put nothing back.
- **Resolved by:** evidence
- **Resolution:** Before asking to publish, the skill says what is about to be lost. Merging into the existing description was considered and rejected: it requires the skill to judge which human sentences survive, which is a bigger feature and a new fabrication surface. The interaction with the deferred issue link is now stated in the spec rather than left to be discovered.
- **Affected decisions:** D14
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes, Out of Scope, Deferred (YAGNI)

### F14: Absence claims are unprovable by construction and had no path

- **Raised by:** `edge-case-explorer` (EC3)
- **Finding:** A diff proves what changed; it can never prove nothing else did. The spec recognized this for intent and gave it a dedicated path, then dropped absence claims ("no behavior changes for existing callers") into the generic unevidenced bucket, where the marker would fire on every no-behavior-change pull request by design. A marker that fires routinely for structural reasons is a marker the engineer learns to clear without reading.
- **Resolved by:** evidence
- **Resolution:** Absence claims are their own blocking category, alongside intent. The engineer vouches or the claim is dropped, and the unevidenced marker keeps meaning what it says. The synthesis pass extended the category to the template's "not applicable" notes, which are the same shape of claim.
- **Affected decisions:** D15
- **Affected tech-notes:** —
- **Changed in spec:** The Gate, Edge Cases and Failure Modes

### F15: A truncated diff was conflated with a large one, and never disclosed

- **Raised by:** `edge-case-explorer` (EC5), `user-experience-designer` (UX-007)
- **Finding:** The spec answered "diff too large to read in full" by pointing at the size warning. But the size warning is about a *reviewer's* defect-finding; it says nothing about the *skill's* blindness, and the two conditions are unrelated. This is the gate's one silent failure surface: the gate can only show claims that exist, so a claim about a file the skill never opened simply isn't there. An engineer who verifies every item on the screen would reasonably believe they verified the change, when they verified a description of an unknown subset of it.
- **Resolved by:** evidence
- **Resolution:** An incomplete read is its own condition, disclosed at the gate, naming what was not read. A gate that cannot be complete must say that it is not.
- **Affected decisions:** D18
- **Affected tech-notes:** —
- **Changed in spec:** Primary Flow, Edge Cases and Failure Modes

### F16: "Edit the draft directly" was an unaudited trapdoor

- **Raised by:** `user-experience-designer` (UX-009)
- **Finding:** The spec offered direct editing as a third option and said nothing about what it did to the gate's state. As written, it was a one-keystroke path from twenty unread claims to publish.
- **Resolved by:** evidence
- **Resolution:** Direct editing is kept and its rule is stated: text the engineer wrote is text they verified, but it verifies only what they touched. Any claim they did not edit is still theirs to dispose of, and the blocking items still block.
- **Affected decisions:** D21
- **Affected tech-notes:** —
- **Changed in spec:** The Gate

### F17: Rejecting everything was a dead end, and prevention was cheaper than recovery

- **Raised by:** `junior-developer` (JD-009), `user-experience-designer` (UX-013)
- **Finding:** "The skill says so rather than publishing a hollow description" leaves the engineer holding nothing, in exactly the case where the draft was worst and they most need help. The UX reviewer went further and found the cheaper fix: the skill already accepts optional context as an argument, unused. A draft written against a stated intent invents fewer claims, which shrinks the gate. Error prevention beats error recovery, using a capability that already exists.
- **Resolved by:** evidence
- **Resolution:** Both. The engineer may state intent up front, and the draft is written against it. Rejecting everything now offers a re-draft with their corrections as input. The synthesis pass settled the follow-on question the resolution left open (see S3): the intent sentence still blocks at the gate even when intent was supplied, because the draft renders it in the skill's words.
- **Affected decisions:** D17
- **Affected tech-notes:** —
- **Changed in spec:** Actors and Triggers, Primary Flow, The Gate, Edge Cases and Failure Modes

### F18: Mechanics leaked into the spec

- **Raised by:** `junior-developer` (JD-017), `user-experience-designer` (UX-014)
- **Finding:** Primary Flow step 4 described a pipeline ("rather than the pairing being reconstructed afterward from the finished text") and D5's outcome named agent selection. Both reviewers noted the leak is user-authorized, so it is not a violation — but the spec should state the behavior, not the mechanism, and should not read as precedent for putting agent selection in specs.
- **Resolved by:** evidence
- **Resolution:** The spec now states the behavior: *the skill never presents a claim as evidenced unless it held that evidence at the moment it wrote the claim,* and *nothing rewrites the description between the moment it is drafted and the moment the engineer sees it.* The mechanism stays in T1, which is its home. D5 is demoted to a trivial decision, with its rationale intact, its exceptional status noted, and no spec reference at all.
- **Affected decisions:** D5
- **Affected tech-notes:** T1
- **Changed in spec:** Primary Flow

## Minor edits

- F19: "The engineer meets the skill twice" was contradicted by the spec's own five points of contact — `junior-developer` (JD-003), `user-experience-designer` (UX-011) — User Interactions, rewritten around the gate as the one stop, with two conditional questions bracketing it and one following it.
- F20: Gate re-entry was undefined; "correct any entry" read as singular — `user-experience-designer` (UX-010) — The Gate, dispositions now accumulate and the gate holds until the engineer is done.
- F21: The no-PR deliverable had no stated form; a long markdown block in terminal scrollback is hostile to copying, and the skill already ships a temp-file script — `junior-developer` (JD-012), `user-experience-designer` (UX-012) — D20, the description is written to a file.
- F22: Re-runs were unaddressed; the natural workflow is several per pull request — `junior-developer` (JD-014) — D19, a re-run re-drafts and re-gates, and verified claims are not carried across a changed diff.
- F23: Binary-file claims have no part of the diff to point at; correct behavior fell out of the generic rule but was never named — `edge-case-explorer` (EC6) — Edge Cases and Failure Modes, named explicitly so it is not mistaken for a defect.
- F24: Open Items was empty and the spec had no statement of what would prove the gate works — `junior-developer` (JD-011), `user-experience-designer` (OQ4) — Open Items, now carries the unmeasured claim count, the observable that would reveal wave-through recurring, the untested size warning, the weakness of the feedback ask's evidence, and the untried child-skill path.

## Closed without change

- **`junior-developer` JD-015 — "diff too large to read" row is a no-op, defer it.** Not deferred. The reviewer was right that the row *as written* added no behavior, but `edge-case-explorer` (EC5) and `user-experience-designer` (UX-007) showed the underlying condition is real, distinct from the size warning, and the gate's only silent failure surface. Resolved by making the row real rather than removing it. See F15.
- **`edge-case-explorer` EC8 — merge-commit content misattributed as intentional design.** No change. The skill's existing merge-base-relative diff already excludes default-branch content. The residual case (conflict-resolution edits inside a merge commit) has no evidence of occurring against this skill's solo and small-team usage. *Reopening trigger:* an engineer reports a claim evidenced against diff content that turned out to be a conflict resolution rather than an intentional change.

## Synthesis reconciliation

Found while reconciling the four artifacts against each other and against the code and research they cite. Not reviewer findings; recorded here so the next reader can see the whole chain.

- **S1: A template's "not applicable" note was still written on the engineer's behalf.** F11 raised the question and the resolution answered it only for boxes and section prose. D16 forbids auto-filling "Not applicable" *after* a rejection, while the conformance rules carried forward under D8 have the skill write exactly that note *during* drafting, so the same assertion was banned at one end of the flow and mandated at the other. Resolved: the note is a claim of absence, so it is a gate item (D12) and it blocks (D15). D8 now records that its fill passes through the gate rather than being final text.
- **S2: Two rewrite paths survived the fix to F9.** D11 named the readability editor and stopped there. The skill also runs a readability self-check and a structural verification step, each ending with an instruction to fix what it finds — both rewrite authored text before the gate, which is the hazard T1 rules out. D11 and T1 now cover any pass that touches the words, and conformance is something the authoring pass satisfies rather than something a later pass repairs.
- **S3: D7's re-rendering was the same objection D11 raises against a post-gate rewrite.** D11 rejects running readability after the gate because it produces "final text no human ever saw," yet D7 permits the skill to re-join surviving assertions into prose after approval, and nothing said the engineer sees the result. Resolved: the re-rendered description is shown to the engineer before anything is published. Related: the intent sentence still blocks even when the engineer supplied their intent up front, because the draft renders it in the skill's words (D17).
- **S4: Two evidence claims were stronger than their sources.** D13 asserted the question mechanism "can return empty answers" as an unconditional property; the cited guidance says it fails when the skill or a parent skill lists the tool among its auto-approved tools, which this skill does not. D4 asserted it was reusing the skill's existing "significant files" definition; that definition names documentation and configuration only, so lockfiles, generated code, and vendored dependencies are an extension. Both decisions stand; both now state what their evidence actually says. The spec's Open Items likewise no longer state the 61% no-review figure as a fact about this design.

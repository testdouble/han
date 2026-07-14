# Review Findings: Verified PR Descriptions

Findings raised by `iterative-plan-review` against [../feature-specification.md](../feature-specification.md).

Numbering starts at F25. F1–F24 were raised during spec authoring and live in [team-findings.md](team-findings.md); [T1](feature-technical-notes.md) cites F2, F7, F9, and F18 from that file, so this review continues the sequence rather than restarting it.

## Major findings

### F25: The bulk-accept path on the non-blocking tier is the badge D2 deleted

- **Agent:** han-core:junior-developer, han-core:adversarial-validator, han-core:user-experience-designer (raised independently by all three)
- **Category:** contradiction
- **Finding:** The gate blocks only on claims the skill *reports* as unevidenced. A fabricated claim that arrives with a plausible-looking evidence pointer is never marked unevidenced, so it lands in the non-blocking tier and is cleared by a single bulk action. D2 removed the "supported" label because a badge "would teach the engineer to skip exactly the rows a fabricated claim hides in," but the tier structure emits that badge in the only currency the engineer feels, which is effort: one tier costs N actions, the other costs one.
- **Evidence considered:** Spec, `## The Gate`: "Every other claim is shown with the evidence recorded for it, and may be accepted together once the blocking items are settled." D2's own rationale, `decision-log.md`: "Making the careless path cost one keystroke while the careful path costs N is a choice architecture that guarantees the careless path." A25/A28, the evidence D2 rests on, describe AI descriptions asserting functionality *absent from the diff*, which in practice means a plausible tie to a nearby hunk rather than zero evidence, so the measured failure mode lands in the bulk-clearable tier.
- **Resolution:** The bulk path is kept, and made honest. The gate names each tier by what it structurally is rather than by its cost, shows the *locus* of each claim's evidence (what the skill pointed at), orders the non-blocking tier weakest-locus first, and words the bulk action as an act of authorship rather than dismissal. The spec now states plainly that the gate shows whether evidence exists, not whether it supports the claim. Separately, an adversarial pass now runs before the gate and demotes refuted claims into the blocking tier (F26), which is what actually closes the hole.
- **Resolved by:** user input
- **Raised in round:** R1
- **Changed in plan:** `## The Gate`, `## Primary Flow`, `## Outcome`
- **Changed in tech-notes:** T2

### F26: The gate has no mechanism for a citation that is real but does not support its claim

- **Agent:** han-core:adversarial-validator, han-core:junior-developer
- **Category:** flawed premise
- **Finding:** T1's asymmetry covers the *absence* of evidence and nothing else. The pass that confabulates a claim is equally capable of confabulating a citation for it, in the same generative act. A claim citing a real file at the wrong line, or a hunk tangential to the assertion, is displayed at the gate as an evidenced claim beside plausible-looking evidence. The gate structurally cannot surface it, so the Outcome's promise overclaims what the gate closes.
- **Evidence considered:** `feature-technical-notes.md`: "the only pass that can honestly say *I could not evidence this one* is the pass that tried to write it and found nothing to write from" addresses zero-evidence claims only. The spec's D10 row distinguishes only "a claim the skill can point at nothing for" from everything else; correctness of the pointer is never tested anywhere in the spec, D2, D10, or T1.
- **Resolution:** A new adversarial pass runs over every drafted claim before the gate is assembled. It attempts to refute each claim against the evidence recorded for it, and demotes any claim it refutes into the blocking tier with its challenge shown beside the claim. It reads only: it may never edit the words, so D11 and T1 hold intact. This is the structural answer to the half of the problem the authoring pass provably cannot close, because the refuting pass is not motivated to accept the text. The spec also now states the residual limitation honestly rather than implying the gate closes it.
- **Resolved by:** user input
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## The Gate`, `## Outcome`, `## Open Items`
- **Changed in tech-notes:** T2

### F27: The reading-order guide is exempted from the gate on a premise the skill's own content rule refutes

- **Agent:** han-core:evidence-based-investigator, han-core:junior-developer, han-core:adversarial-validator (raised independently by all three)
- **Category:** contradiction
- **Finding:** D9 and D12 exempt the reading-order guide from the gate because it "asserts nothing about the change." The skill's own content rule defines its bullets as pointers to a decision, tradeoff, or risk. Naming a risk in a file is a falsifiable claim about the change, and the section appears only on large diffs, which D2's rationale identifies as where fabrication risk is highest.
- **Evidence considered:** Spec, `## Primary Flow` step 3: "The guide to what to read first asserts nothing about the change and is not a gate item." Against `han-github/skills/update-pr-description/references/template.md:24`: "{Pointer to a decision, tradeoff, or risk the reviewer should weight, in suggested reading order.}" And `han-github/skills/update-pr-description/SKILL.md:110`: "a 2-4 bullet reading-order guide for a large change, pointing at decisions, tradeoffs, or risks in the order to read them." D12's rejected alternative defends the exemption on the guide's *purpose*, not its actual content.
- **Resolution:** The guide's content rule is narrowed to pure navigation. Its bullets point at files and areas in a suggested reading order and characterize nothing as risky, tradeoff-laden, or decision-bearing. D9's exemption is then true by construction, and the gate does not grow on exactly the changes where it is already largest.
- **Resolved by:** user input
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## The Gate`
- **Changed in tech-notes:** —

### F28: The repository-template path gives the smallest change the longest gate

- **Agent:** han-core:adversarial-validator, han-core:user-experience-designer
- **Category:** unhandled edge case
- **Finding:** Under D8 and D15, every template section a change does not reach produces a "does not apply" note, which is an absence claim, which blocks individually with no bulk path. A one-line docs fix against an eight-section corporate template therefore produces roughly eight blocking items before a single substantive claim is reached. D12's bound on gate size is scoped to the lean core and says nothing about the templated branch, where section count is set by the repository rather than by the skill. D15's own rationale names this hazard and then routes the most routine item type into the harder tier.
- **Evidence considered:** Spec, `## Edge Cases and Failure Modes`: "That note is a claim of absence made in the engineer's name, so it blocks at the gate like any other absence claim." Spec, `## Open Items`: "[D12] bounds the gate by scoping it to the lean core, which should keep it small." D15's rationale, `decision-log.md`: "A marker that fires routinely, for a reason that is structural rather than suspicious, is a marker the engineer learns to clear without reading."
- **Resolution:** An absence the description *asserts to the reviewer* is separated from a template section the change simply does not reach. The first keeps blocking individually. The second is one judgment about scope, not N: the engineer is shown the set of unreached sections and vouches for the set as one act, pulling any individual section out of it that deserves its own decision. The Open Items entry that predicts gate size now covers the templated branch explicitly.
- **Resolved by:** user input
- **Raised in round:** R1
- **Changed in plan:** `## The Gate`, `## Edge Cases and Failure Modes`, `## Open Items`
- **Changed in tech-notes:** —

### F29: The gh CLI guard is a hard stop in today's skill and the spec neither carries it forward nor drops it

- **Agent:** han-core:evidence-based-investigator, han-core:junior-developer
- **Category:** silently dropped behavior
- **Finding:** D22 claims to enumerate the guards carried forward "so no behavior in the spec rests on nothing," and omits the one guard that stops the skill dead. Worse, the guard is now wrong: D6 runs the gate whether or not a pull request exists and D20 makes a file the deliverable, so a missing or unauthenticated GitHub CLI no longer prevents the skill from doing its job.
- **Evidence considered:** `han-github/skills/update-pr-description/SKILL.md:12-18`: "**If the gh CLI is not found:** ... **Immediately stop** execution of this skill, as it cannot be executed." Against `decision-log.md` D22, which lists only the branch-state and template-discovery guards. A grep for "gh cli" and "prerequisite" across the spec and decision log returns zero matches.
- **Resolution:** The spec now states that the skill needs version control and the branch, and that GitHub access is needed only to publish. Its absence, whether the CLI is missing or present but unauthenticated, degrades the run to the no-pull-request flow: the gate runs and the file is delivered. The hard stop is deliberately not carried forward, and the spec says so.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## Alternate Flows and States`, `## Coordinations`
- **Changed in tech-notes:** —

### F30: The spec recognizes two template states where the conformance rules it carries forward define three

- **Agent:** han-core:junior-developer, han-core:evidence-based-investigator
- **Category:** contradiction
- **Finding:** The Outcome says "Where the repository does have a template, the template still dictates the shape." The conformance rules D8 carries forward wholesale define a replace-scaffold template, where a template file exists and the lean core wins anyway. The spec's sentence denies a state its own carried-forward rules create, and that state decides where the feedback line goes and whether "not applicable" notes exist at all, both of which the gate depends on.
- **Evidence considered:** `han-github/skills/update-pr-description/references/template-conformance.md`, section 2: "**Replace-scaffold.** If the template (or a comment in it) instructs the author to replace its content with a written PR description ... Discard the scaffold and produce the default structure instead." The word "scaffold" appears nowhere in the spec or the decision log.
- **Resolution:** The spec now states that the template is discovered and its own instructions are honored, which may mean the lean core is used even when a template file exists. In that case the feedback line and the gate behave exactly as they do when no template exists.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Outcome`, `## Primary Flow`, `## Edge Cases and Failure Modes`
- **Changed in tech-notes:** —

### F31: Direct editing has no committed interaction, and reconciling an edit needs the reconstruction T1 forbids

- **Agent:** han-core:user-experience-designer, han-core:junior-developer
- **Category:** missing interaction commitment
- **Finding:** D21 says "any claim they did not touch is still theirs to dispose of." To know which claims an engineer's free-form edit touched, something must read the edited prose and re-derive the claim-to-evidence pairing from it. That is precisely the second pass reading finished text and going looking for support that T1 rules out as structurally dishonest. The spec commits to a rule whose most obvious implementation silently guts the feature.
- **Evidence considered:** Spec, `## The Gate`: "The engineer can edit the draft directly, and text they wrote is text they verified." Against `feature-technical-notes.md` T1: "A second pass that reads finished prose and goes looking for supporting evidence is being asked to find justification for a claim it is motivated to accept."
- **Resolution:** The unit of direct editing is an *item*, not the draft. The engineer edits a claim, a section's prose, or the intent sentence, and the edited text becomes that item's disposition, verified by authorship. The skill never re-derives the item set from edited prose, and the spec says so.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## The Gate`
- **Changed in tech-notes:** T2

### F32: The file deliverable has no stated location, and Coordinations declares every disk write read-only

- **Agent:** han-core:junior-developer
- **Category:** contradiction
- **Finding:** Primary Flow step 6 writes the description to a file. Coordinations lists the repository's own files as read-only and names GitHub as the only write. The spec's one write to disk is a write it does not list. Nothing says where the file lands, and a description file dropped in the working tree is an untracked file an engineer can accidentally commit into the very pull request being described. D19 says nothing about what a re-run does to the prior run's file.
- **Evidence considered:** Spec, `## Coordinations`: "**The repository's own files.** Read-only." Against `## Primary Flow` step 6: "The description is written to a file the engineer can take away." F21 justified D20 partly on the grounds that "the skill already ships a temp-file script," but `han-github/skills/update-pr-description/scripts/create-review-tempfile.sh` is never referenced by the current SKILL.md, so it evidences a capability, not a chosen location.
- **Resolution:** Coordinations gains a write coordination. The file lands outside the repository working tree, so it can never be committed into the change it describes, and a re-run replaces the prior run's file.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Coordinations`, `## Primary Flow`, `## Alternate Flows and States`
- **Changed in tech-notes:** —

### F33: The description is written to a file on every run, including runs where the engineer never needs it

- **Agent:** han-core:junior-developer
- **Category:** YAGNI candidate
- **Finding:** D20 commits to the file "whatever happens next," including a run that ends in a successful publish, where the engineer already has the description on GitHub. The evidence behind D20 (F21) is that "a long markdown block in terminal scrollback is hostile to copying," which is a need specific to the paths where the engineer must move the text by hand. The universality is a completeness argument, and it is the version that litters a working tree on every successful run.
- **Evidence considered:** Spec, `## Primary Flow` step 6: "The description is written to a file the engineer can take away, whatever happens next ([D20])." F21 in `team-findings.md`.
- **Resolution:** Replaced with the simpler version that satisfies the same evidence: the description is written to a file whenever the skill does not publish it, which is the no-pull-request path, the declined path, and the fail-closed unverified path. *Reopening trigger:* an engineer asks for the file after a successful publish.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## Deferred (YAGNI)`
- **Changed in tech-notes:** —

### F34: "Delivered marked unverified" is undefined, and fails closed to nothing on the no-pull-request path

- **Agent:** han-core:junior-developer
- **Category:** undefined term
- **Finding:** D13's fail-closed rule says the description is "delivered marked unverified, and nothing is published." When no pull request exists, "nothing is published" is a no-op, and the engineer receives a paste-ready file exactly as they would from a successful run. The fail-closed rule has no effect precisely where D6 insists the gate still matters. The spec never says what the mark means: inside the description body it would be pasted into GitHub verbatim, and outside it, it protects nothing.
- **Evidence considered:** Spec, `## The Gate`: "The description is delivered marked unverified, and nothing is published." Against `## Alternate Flows and States`: "**No pull request exists yet.** The gate still runs, and the verified description is still written to a file."
- **Resolution:** An unverified run does not deliver a paste-ready description. It delivers the claims as an un-assembled list, each beside its evidence and its disposition, with the unevidenced and refuted ones named. The engineer can still act on it, but they cannot paste it into GitHub without doing the assembly themselves, which is the point. The fail-closed rule now bites on the no-pull-request path.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## The Gate`, `## Alternate Flows and States`
- **Changed in tech-notes:** —

### F35: A deliberately blank feedback ask and the empty answer the gate must fail closed on are the same signal

- **Agent:** han-core:junior-developer
- **Category:** contradiction
- **Finding:** D3 says leaving the feedback ask blank omits the section. D13 says an answer the skill cannot obtain from a human is not approval and the run fails closed. A blank feedback field and an unanswered question are indistinguishable, and the spec prescribes opposite behavior for the same input.
- **Evidence considered:** Spec, `## The Gate`: "leaving the feedback ask blank omits it ([D3])" and, two paragraphs later, "If the skill cannot obtain an answer from a human, that is not approval." The failure mode D13 rests on is documented in `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md`: "The tool returns immediately with empty answers. The user never sees the question."
- **Resolution:** Silence is never a valid answer to a blocking item. Skipping the feedback ask is a positive choice the engineer selects, distinct from not answering at all. The fail-closed rule then holds without exception: every blocking item requires a positive act, and an empty response set is always a failure.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## The Gate`
- **Changed in tech-notes:** —

### F36: The total-rejection re-draft is an ungated generative pass, and it cites a decision that does not contain it

- **Agent:** han-core:junior-developer
- **Category:** missing prerequisite
- **Finding:** The edge-case row for a wholly rejected draft says the skill "offers to draft again with their corrections as input ([D17])." D17 says only that the engineer may state intent before the draft is written; it contains no re-draft behavior. Meanwhile D7 forbids re-drafting over the engineer's decisions and D11 forbids any pass that touches the words before the gate. A second draft is a fresh set of unverified claims, and the spec never says it re-gates.
- **Evidence considered:** Spec, `## Edge Cases and Failure Modes`, the "engineer rejects every claim" row. Against D17's outcome in `decision-log.md`: "The engineer can state why they made the change when they invoke the skill. The draft is then written against that intent rather than guessing at it."
- **Resolution:** The spec now says explicitly that the re-draft is a fresh authoring pass that produces a fresh gate, entered from the top, with the engineer's corrections as input. It gets its own decision anchor rather than borrowing D17's, so it cannot be read as "draft again and publish."
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Edge Cases and Failure Modes`, `## Alternate Flows and States`
- **Changed in tech-notes:** —

### F37: The re-rendered description is shown to the engineer but is not a decision they can act on

- **Agent:** han-core:junior-developer, han-core:user-experience-designer
- **Category:** missing interaction commitment
- **Finding:** Primary Flow step 5 says "the engineer sees the re-rendered text before it goes anywhere," and D7 calls that the safety net that reconciles re-rendering with D11. But `## User Interactions` lists four interactions and this is not among them, and on the no-pull-request path there is no publish question either. The re-rendered text is therefore displayed and then written to a file with no human decision point after it. "Seen" and "approved" are being used interchangeably.
- **Evidence considered:** Spec, `## Primary Flow` step 5, against `## User Interactions`, which lists only branch, template, gate, and publish.
- **Resolution:** The re-render is named as an interaction in its own right, on both branches. The engineer accepts it, edits it, or returns to the gate.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## User Interactions`, `## Primary Flow`
- **Changed in tech-notes:** —

### F38: The spec claims the gate does not ask the engineer to re-derive the diff, and then asks exactly that

- **Agent:** han-core:junior-developer
- **Category:** contradiction
- **Finding:** Actors and Triggers rests the whole design on an assumption stated at its weakest point (the engineer knows their own intent) and silently extends it to its strongest (the engineer can judge whether a hunk supports a claim). Judging a claim against its evidence *is* reading the diff. In the AI-assisted workflow this suite exists to serve, the engineer may not have written or read that code either, which is precisely the population the motivating finding measured.
- **Evidence considered:** Spec, `## Actors and Triggers`: "it does not ask them to re-derive the diff, only to decide what the description is allowed to assert." Against `## The Gate`: "It shows the claim and the evidence side by side and lets the engineer judge."
- **Resolution:** The spec now states the real prerequisite: the gate requires an engineer willing to read the evidence shown beside each claim. The false reassurance is removed.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Actors and Triggers`
- **Changed in tech-notes:** —

### F39: The incomplete-read disclosure assumes a self-knowledge the skill may not have

- **Agent:** han-core:junior-developer
- **Category:** unstated assumption
- **Finding:** The spec commits the skill to saying "which parts it did not read." A skill that silently lost the tail of an oversized diff has no way to report the tail it lost. D18's evidence establishes that the hazard exists, not that the skill can detect it, and the spec closes its self-declared "one silent failure surface" with a disclosure that assumes the thing it needs to prove.
- **Evidence considered:** Spec, `## Edge Cases and Failure Modes`: "The skill says at the gate which parts it did not read." D18's evidence in `decision-log.md` establishes only that the current skill "injects the full diff into its context unconditionally ... with no size guard and no truncation signal."
- **Resolution:** The spec now states the behavior that *produces* the knowledge rather than assuming it: the skill establishes the full set of changed files before it drafts, and the disclosure is the difference between that set and the files it actually read.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## Edge Cases and Failure Modes`
- **Changed in tech-notes:** —

### F40: The gate carries a size fact the spec never defines

- **Agent:** han-core:junior-developer
- **Category:** undefined term
- **Finding:** The gate carries "how large the change is," and the spec never says what large means, what it counts, or when it fires. The unit, threshold, and exclusions live only in D4. The spec's own stated principle is that "the gate is the feature, so its rules are stated here rather than left to be inferred," and this rule is not stated here. Without it an implementer fires the warning on a lockfile bump, which is the failure F6 was raised to prevent.
- **Evidence considered:** Spec, `## Primary Flow` step 4. D4's outcome in `decision-log.md` carries the definition: "added and deleted lines in significant files," excluding "lockfiles, generated code, and vendored dependencies."
- **Resolution:** The size rule is stated in the spec at behavioral resolution: lines added and deleted in code files, with lockfiles, generated code, vendored dependencies, documentation, and configuration excluded.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## Edge Cases and Failure Modes`
- **Changed in tech-notes:** —

### F41: There is no way out of the gate except through it

- **Agent:** han-core:user-experience-designer
- **Category:** usability failure
- **Finding:** The gate "does not finish while any blocking item is undecided." Rejecting everything offers a re-draft, which re-gates from scratch. Nothing says what happens when the engineer decides mid-gate that this run was a mistake and they will write the description by hand. The only committed exit from a started gate is to complete it, and that is a trap in exactly the scenario where the skill has performed worst: a bad draft against a large diff. The rational response to a trap is to stop entering it, which retires the feature.
- **Evidence considered:** Spec, `## Primary Flow` step 4 and `## Edge Cases and Failure Modes`. The correct artifact already exists in D13, which delivers an unverified description and publishes nothing; the spec simply never lets the engineer choose it.
- **Resolution:** The engineer can abandon the gate at any point, and abandoning yields exactly what a fail-closed run yields: the claims delivered un-assembled and marked unverified, nothing published. An exit the engineer can always take is what makes the block on the way to *publication* legitimate.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## The Gate`, `## User Interactions`, `## Alternate Flows and States`
- **Changed in tech-notes:** —

### F42: Dropping a claim is the cheapest disposition and it shortens the rest of the gate

- **Agent:** han-core:user-experience-designer
- **Category:** dark pattern / effort asymmetry
- **Finding:** Correcting a claim costs typing prose. Keeping it costs reading, judging, and putting your name on it. Dropping it costs one keystroke and makes the remaining gate shorter. The lazy path is not merely cheap, it is actively rewarded with less work, and every claim the engineer drops was by construction a claim they were entitled to drop. What arrives on GitHub is a description that says less than the change did, and the likeliest casualty is the absence claim D15 itself calls "among the most consequential things a description can get wrong."
- **Evidence considered:** Spec, `## The Gate`: "The engineer keeps it, corrects it, or drops it." F1 in `team-findings.md` killed the one-keystroke *accept* and left the one-keystroke *drop* untouched.
- **Resolution:** No disposition is pre-selected or ordered first as a default. Before publishing, the engineer is shown what the description no longer says: the claims they dropped, in one short list. Hollowing out a description becomes a visible act rather than a silent by-product of taking the cheap exit at each step. This reuses the re-render moment the spec already commits to.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## The Gate`, `## Primary Flow`
- **Changed in tech-notes:** —

### F43: The gate commits to no order, no grouping, and no count

- **Agent:** han-core:user-experience-designer
- **Category:** missing interaction commitment
- **Finding:** In a scrolling transcript there is no scrollbar and no progress indicator. An engineer who has answered four items and cannot tell whether four or twenty-four remain stops answering carefully and starts optimizing for exit, which is the wave-through arriving as a time-management decision rather than a careless one. Order matters equally: if a routine "this section does not apply" is item one and a fabricated behavior claim is item eleven, attention has already been spent on the item that deserved none.
- **Evidence considered:** Spec, `## Primary Flow` step 4, which says items exist and that blocking ones must be disposed of, and stops.
- **Resolution:** The gate states how many items it holds and how many block, before the first question. Blocking items come first, grouped by kind, because the kinds ask for different judgments. The non-blocking tier is presented after the blocking tier is settled, ordered weakest-evidence-locus first.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## The Gate`
- **Changed in tech-notes:** —

### F44: The skill paraphrases an intent the engineer already stated, then blocks on confirming its own paraphrase

- **Agent:** han-core:user-experience-designer
- **Category:** YAGNI candidate
- **Finding:** D21's rule is that text the engineer wrote is text they verified. An engineer who invoked the skill with their intent has written text. The skill re-renders it "in its own words" and then charges them a blocking item to confirm the rewrite. On the run where the engineer did the right thing, the design taxes them for it.
- **Evidence considered:** Spec, `## The Gate`: "The engineer confirms the intent sentence even when they stated their intent up front. The draft renders that intent in its own words." Against `## The Gate`: "text they wrote is text they verified, so it needs no further evidence."
- **Resolution:** Kept, with the evidence cited. D17 stands as written. The summary sentence has a required shape the engineer's raw statement will not generally satisfy, and the description's voice is uniform by design, so the skill renders the intent and the engineer confirms the rendering. The cost is one blocking item on runs where intent was supplied, and it buys the guarantee that the words the reviewer reads are words a human approved.
- **Resolved by:** user input
- **Raised in round:** R1
- **Changed in plan:** — (no change; decision affirmed)
- **Changed in tech-notes:** —

### F45: Publishing destroys the existing description irreversibly, and the mechanism that would make it recoverable is already in the spec

- **Agent:** han-core:user-experience-designer, han-core:adversarial-validator
- **Category:** usability failure
- **Finding:** The engineer approves claims at the gate, answers one more question, and their hand-written description is gone from a system of record. D14's disclosure tells them what they are about to lose; it gives them no way to get it back if they say yes and regret it, or discover an hour later that the deleted text mattered. Meanwhile D20 already commits to writing text to a file *because a terminal is a bad place to keep text you might need*, and the description about to be destroyed is exactly such text.
- **Evidence considered:** Spec, `## Primary Flow` step 6 and `## Out of Scope`, which forbids *merging* the old description (a fabrication surface) in language that reads as if it also forbids preserving it. The spec's own Deferred section admits the common version: "a re-run deletes a link the engineer added by hand and does not put one back."
- **Resolution:** The description being replaced is written to a file before the replacement happens, and the disclosure names that file. An irreversible act becomes a recoverable one at the cost of one write, using a mechanism the spec already establishes. Out of Scope now distinguishes preserving the prior description as an undo artifact from merging it into the new one.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## Out of Scope`, `## Coordinations`, `## Deferred (YAGNI)`
- **Changed in tech-notes:** —

### F46: The incomplete-read disclosure dies at the terminal, and two non-actionable facts sit inside the one place the design cannot afford noise

- **Agent:** han-core:user-experience-designer
- **Category:** missing interaction commitment
- **Finding:** D18 argues that an engineer who verifies every item on the screen would wrongly believe they verified the change. Run the argument one level up: a reviewer who reads a complete-looking description of a partially-read diff wrongly believes they are reading a description of the change. The disclosure never leaves the terminal. Separately, the gate now carries two facts the engineer can do nothing with, sitting alongside N items that demand action, and two ignorable things beside N actionable things is how a human learns that the gate contains ignorable things.
- **Evidence considered:** Spec, `## Primary Flow` step 4 and the oversized-diff row of `## Edge Cases and Failure Modes`. D4's outcome: the size fact "warns; it never blocks."
- **Resolution:** The size fact and the incomplete-read fact are stated once as a preamble before the item list, and are not items. An incomplete read carries a disposition: the description carries a short disclosure to the reviewer that part of the change was not read. The engineer may remove it; the skill does not remove it on their behalf.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** `## Primary Flow`, `## The Gate`, `## Edge Cases and Failure Modes`
- **Changed in tech-notes:** —

## Minor edits

- F47: A re-run re-gates the intent sentence and the feedback ask, which are stated by the engineer and do not go stale with the diff, so D19's staleness rationale does not reach them — spec now says re-runs re-gate everything deliberately, because the description they attach to has changed — han-core:adversarial-validator — `## Alternate Flows and States`
- F48: The note that replacement destroys a hand-added issue link is scoped to links, when the same path destroys any hand-added content including the engineer's own corrections from a prior run — han-core:adversarial-validator — `## Deferred (YAGNI)`
- F49: The Outcome says the skill "produces a pull request description on GitHub," which two of its own paths contradict — han-core:junior-developer — `## Outcome`
- F50: The three dispositions (keep, correct, drop) are written for prose and do not map onto checklist boxes or "not applicable" notes, and dropping a checklist item is forbidden by the conformance rules the spec carries forward — han-core:junior-developer — `## The Gate`
- F51: D11 removes the verification step without itemizing the structural checks that go with it (nested code fences, leftover template placeholders, the "Generated with Claude Code" strip, verbatim checklist reproduction) — han-core:evidence-based-investigator — `## Primary Flow`
- F52: Coordinations assumes a GitHub read (fetching the existing description body) that today's skill does not perform, so it is new read behavior rather than carried-forward behavior — han-core:evidence-based-investigator — `## Coordinations`
- F53: The spec never commits to showing the engineer the drafted description as prose before decomposing it into gate items, so they judge atomized assertions they have never seen assembled — han-core:user-experience-designer — `## Primary Flow`

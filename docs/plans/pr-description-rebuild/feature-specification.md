# Feature Specification: Verified PR Descriptions

## Outcome

An engineer finishes work on a branch and runs the skill, which produces a pull request description they have verified. Nothing the skill could not evidence, and nothing only the engineer could know, reaches the reviewer unless the engineer decides it should. Publishing to GitHub is the optional last step, not the deliverable.

The change from today is the verification gate. Today the skill drafts a description and asks for a single yes-or-no before publishing, so a claim the draft invented can reach the pull request unchallenged. After this change, the skill shows each claim beside the evidence it recorded for that claim. It will not finish while a claim it could not evidence, a claim an adversarial pass could refute, or a statement only the engineer can vouch for, is still undecided ([D2](artifacts/decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for), [D23](artifacts/decision-log.md#d23-an-adversarial-pass-refutes-each-claim-against-its-evidence-before-the-gate)).

Be precise about what the gate does and does not close. It shows whether evidence exists for a claim, and it puts an adversary between a claim and the pull request. It does not certify that the evidence supports the claim. That judgment stays with the engineer, and the gate is built to spend their attention where invention is most likely rather than to spread it flat across every row ([D24](artifacts/decision-log.md#d24-the-gate-is-ordered-grouped-counted-and-honest-about-what-it-does-not-know), [T2](artifacts/feature-technical-notes.md#t2-refutation-is-a-separate-pass-that-reads-the-claims-and-never-touches-the-words)).

The description's shape barely changes. Where the repository has no template of its own, the description keeps the lean core the skill already produces and gains one line: what kind of feedback the engineer wants. Where the repository has a template, the template is discovered and its own instructions are honored. Usually that means the template dictates the shape. Where the template is a scaffold that tells the author to replace it, the lean core is used instead, and the feedback line and the gate behave exactly as they do when no template exists ([D3](artifacts/decision-log.md#d3-the-lean-core-is-kept-and-gains-a-feedback-ask), [D8](artifacts/decision-log.md#d8-repository-template-conformance-is-carried-forward-and-its-fill-passes-through-the-gate)).

## Actors and Triggers

- **The engineer.** Invokes the skill on a branch with commits ahead of the default branch. They are the only actor, and they are the one who verifies the result.
- **The trigger.** The engineer runs the skill, optionally stating up front why they made the change ([D17](artifacts/decision-log.md#d17-the-engineer-may-state-intent-before-the-draft-is-written)). Nothing runs it automatically.

The skill assumes the engineer knows why they made the change, and it assumes they are willing to read the evidence shown beside each claim. Both assumptions are load-bearing, and the second is the harder one. Judging whether a hunk supports a claim means reading the hunk. The skill does not pretend otherwise, and an engineer who will not do that gets a gate that launders their inattention into a verified-looking description.

## Primary Flow

1. **The skill confirms the branch has something to describe.** A branch with no commits, or with commits but no file changes, produces no description. The skill says so and stops ([D22](artifacts/decision-log.md#d22-the-existing-branch-state-and-template-discovery-guards-are-carried-forward)).

2. **The skill establishes the full set of changed files before it reads any of them.** This is what lets it know later what it did not read. A disclosure about an unread part of the diff is only honest if the skill knew the part existed ([D18](artifacts/decision-log.md#d18-an-incomplete-read-of-the-diff-is-disclosed-as-its-own-condition)).

   It also measures the change here. Size is lines added and deleted in code files. Documentation, configuration, lockfiles, generated code, and vendored dependencies do not count ([D4](artifacts/decision-log.md#d4-the-size-fact-is-delivered-at-the-gate-not-shouted-past-the-engineer)).

3. **The skill drafts the description.** The draft is written to the repository's pull request template when one applies, and to the skill's own lean shape when none does ([D8](artifacts/decision-log.md#d8-repository-template-conformance-is-carried-forward-and-its-fill-passes-through-the-gate)). Each claim records the evidence it was written from. The skill never presents a claim as evidenced unless it held that evidence at the moment it wrote the claim ([T1](artifacts/feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)).

   Nothing rewrites the description between the moment it is drafted and the moment the engineer sees it at the gate. The prose is written to the readability the repository expects, to the shape the template requires, and to the formatting a pull request body must satisfy, as it is written, not corrected into shape afterward. The text at the gate is therefore the text whose evidence was recorded ([D11](artifacts/decision-log.md#d11-nothing-rewrites-the-draft-between-authoring-and-the-gate)).

   Where the engineer stated their intent up front, the draft is written against it rather than guessing at it ([D17](artifacts/decision-log.md#d17-the-engineer-may-state-intent-before-the-draft-is-written)).

4. **An adversary tries to knock the draft down.** A separate pass reads each claim beside the evidence recorded for it and asks one question: does this evidence actually support this claim? A claim it refutes is demoted into the blocking tier and carries its challenge to the gate. This pass reads. It attaches challenges and moves claims between tiers, and it changes not one word of the description ([D23](artifacts/decision-log.md#d23-an-adversarial-pass-refutes-each-claim-against-its-evidence-before-the-gate), [T2](artifacts/feature-technical-notes.md#t2-refutation-is-a-separate-pass-that-reads-the-claims-and-never-touches-the-words)).

   This is the half of the problem the authoring pass cannot close by itself. A pass can honestly report that it found nothing to write from. It cannot honestly certify its own output, and a fabricated claim usually arrives with a confident pointer at a real hunk rather than with nothing attached.

5. **The skill assembles the gate.** Every assertion the description makes to the reviewer is a gate item. That includes:
   - the sentences of the summary and the behavior changes
   - any prose filled into a repository template's sections
   - every checklist box the draft proposes to check ([D12](artifacts/decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read))

   The guide to what to read first points at files and areas and characterizes nothing as a risk, a tradeoff, or a decision, so it asserts nothing about the change and is not a gate item ([D9](artifacts/decision-log.md#d9-the-reading-order-guide-keeps-its-existing-threshold), [D25](artifacts/decision-log.md#d25-the-reading-order-guide-points-and-characterizes-nothing)).

6. **The skill shows the gate, and holds.** The engineer sees the drafted description in full, as prose, before it is broken into items, because a claim judged out of the sentences around it is judged out of the context that makes it true or misleading.

   Then the gate opens with its preamble: how large the change is, whether the skill read all of it, how many items the gate holds, and how many of them block. These are facts, not items. The engineer disposes of each blocking item, accepts or edits the rest, and the gate does not finish while any blocking item is undecided ([D2](artifacts/decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for), [D4](artifacts/decision-log.md#d4-the-size-fact-is-delivered-at-the-gate-not-shouted-past-the-engineer), [D18](artifacts/decision-log.md#d18-an-incomplete-read-of-the-diff-is-disclosed-as-its-own-condition), [D24](artifacts/decision-log.md#d24-the-gate-is-ordered-grouped-counted-and-honest-about-what-it-does-not-know)).

7. **The skill applies the engineer's decisions.** A claim they correct is used as they wrote it. A claim they reject is removed. The description is re-rendered from what survives, without re-drafting over it ([D7](artifacts/decision-log.md#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft)).

   The engineer then sees two things: the re-rendered description, and a short list of what it no longer says. Dropping a claim is the cheapest thing they can do at the gate and it makes the rest of the gate shorter, so the description they hollowed out is shown to them as a description they hollowed out ([D24](artifacts/decision-log.md#d24-the-gate-is-ordered-grouped-counted-and-honest-about-what-it-does-not-know)). They accept it, edit it, or go back to the gate.

8. **The skill delivers the verified description, and offers to publish it.** When the branch has an open pull request, the skill offers to update it. It first writes the description that is about to be destroyed to a file, and says what that description said and where it now lives ([D14](artifacts/decision-log.md#d14-replacing-an-existing-description-is-disclosed-before-it-happens), [D28](artifacts/decision-log.md#d28-the-skills-files-live-outside-the-working-tree-and-the-description-it-replaces-is-kept)). It publishes only on the engineer's word.

   When the skill does not publish, whether because no pull request exists, the engineer declined, or the run ended unverified, the verified description is written to a file the engineer can take away. Every file the skill writes lands outside the repository's working tree, so a description can never be committed into the change it describes ([D20](artifacts/decision-log.md#d20-the-verified-description-is-written-to-a-file), [D28](artifacts/decision-log.md#d28-the-skills-files-live-outside-the-working-tree-and-the-description-it-replaces-is-kept)).

## The Gate

The gate is the feature, so its rules are stated here rather than left to be inferred.

**Blocking items.** Four kinds of item must be individually disposed of, and there is no path that accepts them in bulk:

- **A claim the skill could not evidence.** The engineer keeps it, corrects it, or drops it.
- **A claim the adversarial pass refuted.** It is shown with the challenge that refuted it. The engineer keeps it, corrects it, or drops it, in full view of why the skill's own adversary did not believe it ([D23](artifacts/decision-log.md#d23-an-adversarial-pass-refutes-each-claim-against-its-evidence-before-the-gate)).
- **A claim about absence** that the description asserts to the reviewer, such as a claim that nothing changed for existing callers or that no behavior changed. No diff can evidence an absence, so the engineer vouches for it or it goes ([D15](artifacts/decision-log.md#d15-absence-claims-are-structurally-unprovable-like-intent)).
- **The statement of why the change exists,** together with the ask for what feedback the engineer wants. Neither is in the diff. The engineer writes or confirms both. Skipping the feedback ask is something they choose, not something they achieve by staying silent, because silence is never a valid answer to a blocking item ([D3](artifacts/decision-log.md#d3-the-lean-core-is-kept-and-gains-a-feedback-ask), [D13](artifacts/decision-log.md#d13-the-gate-fails-closed)). The engineer confirms the intent sentence even when they stated their intent up front. The draft renders that intent in its own words, and those words are the ones the reviewer will read ([D17](artifacts/decision-log.md#d17-the-engineer-may-state-intent-before-the-draft-is-written)).

A template section the change simply does not reach is not one of these. It is one judgment about scope, not many. The engineer is shown the set of sections the change does not reach and vouches for the set in one act, pulling out any individual section that deserves its own decision. Confusing "the diff proves nothing changed here" with "this section plainly does not apply to a one-line docs fix" would make the smallest change draw the longest gate, which is how an engineer learns that blocking items are noise to be cleared ([D26](artifacts/decision-log.md#d26-a-template-section-the-change-does-not-reach-is-one-judgment-not-many)).

**How each item is disposed of.** A prose claim is kept, corrected, or dropped. A checklist box is confirmed checked or returned to unchecked, and it is never removed from the checklist, because the template's checklist is reproduced whole. A note that a section does not apply is vouched for or replaced with the engineer's own text, and a section left empty by rejections comes back to them ([D16](artifacts/decision-log.md#d16-a-section-emptied-by-rejections-returns-to-the-engineer)). No disposition is offered as a default or pre-selected, because dropping a claim is already the cheapest act at the gate and it does not need help.

**Non-blocking items.** Every other claim survived the adversary, and is shown with the evidence recorded for it and the locus that evidence came from: a hunk in the diff, a file the change did not touch, or nothing but a commit message. They are ordered weakest locus first, so the engineer's first and freshest attention lands where invention is most likely. They may be accepted together once the blocking items are settled, and that acceptance is worded as what it is: the engineer saying they have read these and stand behind them.

The gate does not label these claims "supported" and does not vouch for them. **The gate shows whether evidence exists, not whether the evidence supports the claim.** The skill is not in a position to certify a claim it wrote itself, and a badge saying it is would teach the engineer to skip exactly the rows a fabricated claim hides in. What the skill can honestly do is show what it pointed at, put an adversary in front of it, and order the rest so attention is spent where it buys the most ([D2](artifacts/decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for), [D24](artifacts/decision-log.md#d24-the-gate-is-ordered-grouped-counted-and-honest-about-what-it-does-not-know)).

**The gate announces its shape before the first question.** How many items it holds, and how many of them block. Blocking items come first, grouped by kind, because the four kinds ask for four different judgments. An engineer who cannot see how much gate remains stops answering carefully and starts optimizing for exit, and a wave-through that arrives as time management is still a wave-through ([D24](artifacts/decision-log.md#d24-the-gate-is-ordered-grouped-counted-and-honest-about-what-it-does-not-know)).

**The gate fails closed.** If the skill cannot obtain an answer from a human, that is not approval ([D13](artifacts/decision-log.md#d13-the-gate-fails-closed)).

**The engineer can leave at any time,** and leaving is not failing. An abandoned run and a fail-closed run deliver the same thing: the claims as an un-assembled list, each beside its evidence and its standing, with the unevidenced and refuted ones named, and nothing published. That artifact is deliberately not a description. An engineer cannot paste it into GitHub without assembling it themselves, which is exactly the point, and it is what gives the fail-closed rule teeth on a branch that has no pull request to withhold publication from ([D27](artifacts/decision-log.md#d27-the-engineer-can-always-leave-and-an-unverified-run-does-not-hand-them-paste-ready-prose)).

**The engineer can edit an item directly,** and text they wrote is text they verified, so it needs no further evidence. The unit of editing is the item, not the draft: a claim, a section's prose, the intent sentence. The skill never re-derives the item set by reading edited prose, because a pass that reads finished text and goes looking for the claims in it is the same untrustworthy reconstruction the authoring rule exists to prevent. Editing is not an exit from the gate: any item they did not touch is still theirs to dispose of ([D21](artifacts/decision-log.md#d21-editing-the-draft-directly-verifies-what-was-edited-and-nothing-else), [D30](artifacts/decision-log.md#d30-the-unit-of-direct-editing-is-an-item-not-the-draft)).

## Alternate Flows and States

- **No pull request exists yet.** The gate still runs, and the verified description is still written to a file. The engineer is taking the text somewhere regardless of whether the skill publishes it, and an unverified claim is no less wrong for being pasted by hand ([D6](artifacts/decision-log.md#d6-the-gate-runs-whether-or-not-a-pull-request-exists)).

- **GitHub is unreachable.** The GitHub CLI is missing, or it is present but unauthenticated. The run degrades to the no-pull-request flow: the gate runs and the file is delivered. The skill does not stop, because the gate and the file are worth having without GitHub ([D29](artifacts/decision-log.md#d29-github-access-is-needed-only-to-publish)).

- **The engineer declines to publish.** The verified description is written to a file and stands as the deliverable. Nothing is written to GitHub.

- **The engineer abandons the gate.** They get the un-assembled claim list, and nothing is published ([D27](artifacts/decision-log.md#d27-the-engineer-can-always-leave-and-an-unverified-run-does-not-hand-them-paste-ready-prose)).

- **The skill is run again on the same branch.** It re-drafts and re-gates from the current diff. Nothing is carried forward, including the intent sentence and the feedback ask. The diff a claim was verified against has changed, and the intent and feedback line belong to a description that no longer exists ([D19](artifacts/decision-log.md#d19-a-re-run-re-drafts-and-re-gates)). A re-run also replaces the previous run's file.

- **The repository offers several templates.** The skill cannot know which the engineer intends, so it asks, offering the option of using none ([D22](artifacts/decision-log.md#d22-the-existing-branch-state-and-template-discovery-guards-are-carried-forward)).

- **The engineer rejects the stated intent and supplies their own.** Their wording is used as written ([D7](artifacts/decision-log.md#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft)).

- **The engineer rejects every claim.** The skill offers, once, to author a fresh draft with their corrections as input. That draft is a new authoring pass and it produces a new gate, entered from the top. Declining takes the abandon path ([D31](artifacts/decision-log.md#d31-a-wholly-rejected-draft-is-re-authored-and-re-gated-from-the-top)).

## Edge Cases and Failure Modes

| Case | Behavior |
|---|---|
| A claim rests on repository context outside the diff (an existing default, code the change interacts with) | It is evidenced by the file it rests on. Evidence means the diff or a cited repository file, not the diff alone. Only a claim the skill can point at nothing for is marked unevidenced ([D10](artifacts/decision-log.md#d10-evidence-is-the-diff-or-a-cited-repository-file)). At the gate it is shown as resting on an unchanged file, which is a weaker locus than a hunk, and it is ordered accordingly ([D24](artifacts/decision-log.md#d24-the-gate-is-ordered-grouped-counted-and-honest-about-what-it-does-not-know)). |
| A claim cites real evidence that does not actually support it | The adversarial pass exists for this case and is the only thing standing in its way. When the pass refutes the claim, it is demoted into the blocking tier and shown with the challenge. When the pass fails to refute it, the claim reaches the engineer in the non-blocking tier, and the engineer is the last line. The spec does not pretend the gate closes this ([D23](artifacts/decision-log.md#d23-an-adversarial-pass-refutes-each-claim-against-its-evidence-before-the-gate), [T2](artifacts/feature-technical-notes.md#t2-refutation-is-a-separate-pass-that-reads-the-claims-and-never-touches-the-words)). |
| A sentence bundles a claim the engineer accepts with one they reject | The sentence is not the unit. Each independently verifiable assertion is disposed of on its own, and the surviving assertions are re-rendered as readable prose ([D12](artifacts/decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read)). |
| The diff is too large for the skill to read in full | The skill knows the full set of changed files before it starts reading, so it can name what it did not read. It says so in the gate's preamble, as a fact separate from the size warning, and the description itself carries a short note to the reviewer that part of the change was not read. The engineer may remove that note; the skill does not remove it for them. A claim the skill never had evidence for is not the same as a file it never opened ([D18](artifacts/decision-log.md#d18-an-incomplete-read-of-the-diff-is-disclosed-as-its-own-condition)). |
| The change touches a binary file | There is no part of the diff to point at, so a claim about what changed inside it is unevidenced and blocks like any other. This is by design, not a defect ([D10](artifacts/decision-log.md#d10-evidence-is-the-diff-or-a-cited-repository-file)). |
| A repository template has a section this change has nothing to say about | The template keeps its section and the draft proposes a note saying it does not apply. The engineer vouches for the set of such sections in one act rather than one at a time, because a section a docs fix does not reach is a fact about scope, not a claim the description is smuggling past a reviewer ([D26](artifacts/decision-log.md#d26-a-template-section-the-change-does-not-reach-is-one-judgment-not-many), [D8](artifacts/decision-log.md#d8-repository-template-conformance-is-carried-forward-and-its-fill-passes-through-the-gate)). |
| A repository template tells the author to replace it | It is a scaffold, not a structure. The lean core is used, and the run proceeds exactly as it would with no template at all ([D8](artifacts/decision-log.md#d8-repository-template-conformance-is-carried-forward-and-its-fill-passes-through-the-gate)). |
| The engineer rejects every claim in a section a repository template requires | The empty section comes back to them: they write it or mark it explicitly not applicable. The skill does not invent an honest-sounding note on their behalf ([D16](artifacts/decision-log.md#d16-a-section-emptied-by-rejections-returns-to-the-engineer)). |
| The engineer rejects every claim | There is no description left. The skill says so and offers, once, to author a fresh draft with their corrections as input. That draft re-gates from the top ([D31](artifacts/decision-log.md#d31-a-wholly-rejected-draft-is-re-authored-and-re-gated-from-the-top)). |
| A repository template carries a checklist | A box is proposed checked only when the diff proves it, and every proposed box is a gate item. An attestation of human action is never checked on the engineer's behalf. The checklist is reproduced whole, so a box is confirmed or returned to unchecked, never deleted ([D8](artifacts/decision-log.md#d8-repository-template-conformance-is-carried-forward-and-its-fill-passes-through-the-gate), [D12](artifacts/decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read)). |
| The pull request already has a description | It will be replaced. Before that happens the skill writes it to a file and says what it said and where it now lives, so replacing it is recoverable rather than merely disclosed ([D14](artifacts/decision-log.md#d14-replacing-an-existing-description-is-disclosed-before-it-happens), [D28](artifacts/decision-log.md#d28-the-skills-files-live-outside-the-working-tree-and-the-description-it-replaces-is-kept)). |
| The default branch cannot be determined | The skill asks which branch to compare against rather than guessing ([D22](artifacts/decision-log.md#d22-the-existing-branch-state-and-template-discovery-guards-are-carried-forward)). |

## User Interactions

The gate is the one place the skill genuinely stops in an ordinary run. Two questions can bracket it, and two follow it.

- **Which branch to compare against:** only when the default branch cannot be determined.
- **Which template to use:** only when the repository offers several.
- **The gate:** always. The engineer disposes of each blocking item, accepts or edits the rest, and cannot reach the end without deciding what the description is allowed to assert. They can abandon it at any point and take the un-assembled claim list instead.
- **The re-rendered description:** always. They accept it, edit it, or return to the gate. Seeing is not approving, and on a branch with no pull request this is the last decision they get.
- **Whether to publish:** always, when a pull request exists, and stating what will be replaced and where it has been saved.

Two recovery paths return to the engineer rather than adding a routine step. A mandatory template section emptied by rejections comes back for them to fill ([D16](artifacts/decision-log.md#d16-a-section-emptied-by-rejections-returns-to-the-engineer)). A wholly rejected draft is offered once more with their corrections as input ([D31](artifacts/decision-log.md#d31-a-wholly-rejected-draft-is-re-authored-and-re-gated-from-the-top)). Both are consequences of what the engineer decided at the gate, not questions the skill asks of its own accord.

The size of the change is not another interaction, and neither is the disclosure of an incomplete read. They are facts carried into the gate's preamble, where the engineer is already present and already reading. That is different from a message fired early in the run that scrolls out of sight before anyone reads it ([D4](artifacts/decision-log.md#d4-the-size-fact-is-delivered-at-the-gate-not-shouted-past-the-engineer)). They are stated once, before the items, and they are not items, because two things the engineer can do nothing about sitting among N things that demand action is how a gate teaches its own dismissal.

## Coordinations

- **The version control history.** Read-only. The branch's commits, changed files, and diff.
- **The repository's own files.** Read-only. The pull request template when one exists, and any source file a claim rests on.
- **The engineer's filesystem, outside the working tree.** Written. The verified description when the skill does not publish it, the un-assembled claim list when a run ends unverified or abandoned, and the pull request description that is about to be replaced. Never inside the working tree, so nothing the skill writes can be committed into the change it describes ([D28](artifacts/decision-log.md#d28-the-skills-files-live-outside-the-working-tree-and-the-description-it-replaces-is-kept)).
- **GitHub.** Read to find whether the branch has an open pull request, and to read the description that is about to be replaced. Reading that description is new: today the skill asks only whether a pull request exists. Written once, only to set the description, and only after the engineer approves. Needed only to publish, so its absence degrades the run rather than stopping it ([D29](artifacts/decision-log.md#d29-github-access-is-needed-only-to-publish)).

## Out of Scope

- Reviewing the code. The skill describes a change; it does not judge it.
- Posting review comments.
- Splitting an oversized change. The skill says the change is large; it does not divide it.
- Writing commit messages or issue bodies.
- Creating the pull request. The skill updates one that exists.
- Merging the existing description into the new one. The old description is replaced, and it is preserved to a file first so the replacement is recoverable. Preserving it is not merging it: reading the old text back into the new one is a fabrication surface the gate cannot cover ([D14](artifacts/decision-log.md#d14-replacing-an-existing-description-is-disclosed-before-it-happens), [D28](artifacts/decision-log.md#d28-the-skills-files-live-outside-the-working-tree-and-the-description-it-replaces-is-kept)).

## Deferred (YAGNI)

- **A link to the related issue or ticket.** Nearly universal across the sources, and associated with a faster first reviewer response. Deferred with the rest of the section set ([D3](artifacts/decision-log.md#d3-the-lean-core-is-kept-and-gains-a-feedback-ask)). *Reopening trigger:* a reviewer asks for context that lived in a ticket the description did not link, or a repository template requires the link.

- **A testing note.** In the research's recommended core, used by a minority of pull requests in practice. Deferred for the same reason ([D3](artifacts/decision-log.md#d3-the-lean-core-is-kept-and-gains-a-feedback-ask)). *Reopening trigger:* a repository template requires it, or reviewers start asking how a change was tested.

- **Conditional sections for screenshots, rollback, and migrations.** No evidence in this repository shows an engineer needing one. *Reopening trigger:* a change of that kind is described and the engineer adds the section by hand.

- **Writing the description to a file on a run that publishes successfully.** The need the file serves is that terminal scrollback is a bad place to copy text out of, and that need exists only where the engineer moves the text by hand. On a successful publish they already have it on GitHub ([D28](artifacts/decision-log.md#d28-the-skills-files-live-outside-the-working-tree-and-the-description-it-replaces-is-kept)). *Reopening trigger:* an engineer asks for the file after a successful publish.

- **Blocking on an oversized change.** Rejected: the work is done by the time the skill runs, so refusing to describe it punishes a decision the engineer can no longer cheaply reverse ([D4](artifacts/decision-log.md#d4-the-size-fact-is-delivered-at-the-gate-not-shouted-past-the-engineer)).

- **Carrying anything across re-runs.** Rejected as unsound: a claim was verified against a diff that has since changed, and the intent sentence and feedback line belong to a description that no longer exists ([D19](artifacts/decision-log.md#d19-a-re-run-re-drafts-and-re-gates)).

Replacement destroys everything a human added to the pull request description by hand: a ticket link, a screenshot, a note to a reviewer, a rollback plan, and the engineer's own corrections from an earlier run. The skill writes the old description to a file before it replaces it, so none of that is lost, but nothing puts it back into the new description automatically, and nothing is going to ([D28](artifacts/decision-log.md#d28-the-skills-files-live-outside-the-working-tree-and-the-description-it-replaces-is-kept)).

## Open Items

- **Nobody has run this gate, so nobody knows how many items it produces.** The whole design rests on the claim count being small enough that an engineer reads it rather than skims it. [D12](artifacts/decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read) bounds the gate by scoping it to the lean core, which should keep it small, but that bound does not reach the templated branch: there the section count is set by the repository, not by the skill. [D26](artifacts/decision-log.md#d26-a-template-section-the-change-does-not-reach-is-one-judgment-not-many) removes the worst of it by disposing of unreached sections as one judgment, but that is still a prediction. Resolve by drafting the gate against ten real merged pull requests, at least three of them against a repository with a multi-section template, and counting, before the design is treated as settled.

- **The adversarial pass is a new cost on every run and its hit rate is unknown.** It exists because the authoring pass structurally cannot certify its own citations ([T2](artifacts/feature-technical-notes.md#t2-refutation-is-a-separate-pass-that-reads-the-claims-and-never-touches-the-words)), and that argument is sound. What is unknown is whether it refutes anything worth refuting, or whether it refutes so much that the blocking tier fills with challenges the engineer learns to dismiss. Both failure modes retire the feature. *Resolve by watching, during dogfooding, how often it demotes a claim and how often the engineer agrees with the demotion. A pass that never fires is dead weight. A pass the engineer overrules every time is worse than dead weight, because it trains the override.*

- **The evidence that AI-authored pull requests go unreviewed is a single 2026 preprint, and the spec cannot tell whether the same thing is happening here.** The finding that motivates the gate is that most AI-authored pull requests draw no recorded human review, roughly 61%. That finding is single-source, shares a dataset with a companion study, and was measured on open-source repositories rather than this workflow ([D2](artifacts/decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for)). It is a risk signal, not a measurement of this design. The observable that would show the same failure recurring is how often an engineer corrects or rejects something at the gate. A gate that never changes anything is a gate being waved through. Watch it during dogfooding rather than building instrumentation for it.

- **The feedback ask is the largest measured effect in the research and the weakest-supported commitment in the spec.** The odds-ratio figure comes from one observational 2026 preprint. It is associative rather than causal, and was measured on human-authored pull requests across open-source projects, not on a solo or small-team workflow ([D3](artifacts/decision-log.md#d3-the-lean-core-is-kept-and-gains-a-feedback-ask)). The spec commits to asking for it on every run on that basis. *Resolve by watching whether the field is answered or routinely skipped. If it is routinely skipped, the ask is costing an interaction and buying nothing, and it should be dropped.*

- **Whether the size warning changes anyone's behavior is untested.** It is delivered where it will be read now, which is the most that can be said for it.

- **A gate that fails closed has never been run as a child of another skill.** The repository's own guidance documents that the question mechanism returns empty answers when a parent skill has auto-approved it, and that the parent's rules stack onto the child. Under [D13](artifacts/decision-log.md#d13-the-gate-fails-closed), that condition produces an unverified run and no publication. That is correct behavior, but it means the skill can be silently unusable when invoked from another skill rather than by a person. *Resolve by running the skill once as a child of another skill and observing whether the gate can be answered.*

## Summary

The skill gains a gate that shows each claim beside the evidence it was written from, after an adversary has tried and failed to refute it. The gate will not finish while an unevidenced claim, a refuted claim, an absence claim, or the statement of intent is undecided. It states honestly that it shows whether evidence exists and not whether the evidence supports the claim, and it spends the engineer's attention where invention is most likely rather than spreading it flat. It fails closed, it can be left at any time, and a run that ends unverified hands back claims rather than a description. Nothing rewrites the description between the moment it is drafted and the moment the engineer sees it, so the text they verify is the text that gets published. It discloses and preserves what it is about to destroy. The description keeps its lean core and gains an ask for the kind of feedback the engineer wants.

## Review History

- **Review mode:** team.
- **Spec-aware mode:** engaged.
- **Rounds completed:** 1 (of a 2-round cap) — see [artifacts/review-iteration-history.md](artifacts/review-iteration-history.md).
- **Team composition:**
  - `han-core:junior-developer` (required) — generalist stress-test of the gate's hidden assumptions and undefined terms.
  - `han-core:adversarial-validator` (required) — attacks on the gate's central premise and the evidence behind D2 and D3.
  - `han-core:evidence-based-investigator` (conditionally mandatory) — verification of the spec's many "carried forward from today's skill" claims against `han-github/skills/update-pr-description/`.
  - `han-core:user-experience-designer` — the gate is a human-in-the-loop interaction whose value depends on the engineer engaging rather than rubber-stamping.
- **Findings raised:** 29 (F25 through F53) — see [artifacts/review-findings.md](artifacts/review-findings.md). Numbering continues from the 24 findings raised during spec authoring in [artifacts/team-findings.md](artifacts/team-findings.md). Resolved by evidence: 22. Resolved by user input: 5. Deferred: 2.
- **YAGNI candidates:** 2 — the file written on every run including successful publishes (replaced with the simpler version: written only when the skill does not publish), and the confirmation of a paraphrased intent the engineer already supplied (kept, with the evidence cited: the summary sentence has a required shape and the description's voice is uniform by design).
- **Assumptions challenged across all passes:** that the authoring pass can be trusted to flag its own unevidenced claims (it can flag missing evidence but not wrong evidence, which is what forced the adversarial pass in D23); that the engineer is not being asked to re-derive the diff (the gate asks exactly that, and the spec now says so); that the reading-order guide asserts nothing (its own content rule refuted this, forcing D25); that the skill can name what it did not read (only if it establishes the file set first, now in Primary Flow step 2).
- **Consolidations made:** the size fact and the incomplete-read fact were pulled out of the item list into a single gate preamble; the three "not applicable" dispositions collapsed into one set-level judgment (D26); the abandon path and the fail-closed path were unified into one artifact (D27).
- **Ambiguities resolved, and how:** the bulk-accept loophole (user chose to keep the bulk path and make it honest, plus a new adversarial pass); the reading-order guide (user chose to narrow it to pure navigation); the paraphrased intent (user chose to keep D17 as written); the template N/A blowup (user chose set-level disposal).
- **Technical notes added:** 1 — [T2](artifacts/feature-technical-notes.md#t2-refutation-is-a-separate-pass-that-reads-the-claims-and-never-touches-the-words), the two constraints that make the adversarial pass sound.
- **Decisions added:** 9 — D23 through D31 in [artifacts/decision-log.md](artifacts/decision-log.md).
- **Open items remaining:** 6, listed above. None blocks implementation. The first two (gate item count, adversarial-pass hit rate) are dogfooding observations that should be made before the design is treated as settled.

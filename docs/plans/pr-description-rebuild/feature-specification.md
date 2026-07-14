# Feature Specification: Verified PR Descriptions

## Outcome

An engineer finishes work on a branch, runs the skill, and gets a pull request description on GitHub in which nothing the skill could not evidence, and nothing only the engineer could know, reached the reviewer without the engineer deciding it should.

The change from today is the verification gate. Today the skill drafts a description and asks for a single yes-or-no before publishing, so a claim the draft invented can reach the pull request unchallenged. After this change, the skill shows each claim beside the evidence it recorded for that claim, and it will not finish while a claim it could not evidence, or a statement only the engineer can vouch for, is still undecided ([D2](artifacts/decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for)).

The description's shape barely changes. It keeps the lean core the skill already produces, and gains one line: what kind of feedback the engineer wants ([D3](artifacts/decision-log.md#d3-the-lean-core-is-kept-and-gains-a-feedback-ask)).

## Actors and Triggers

- **The engineer.** Invokes the skill on a branch with commits ahead of the default branch. They are the only actor, and they are the one who verifies the result.
- **The trigger.** The engineer runs the skill, optionally stating up front why they made the change. Nothing runs it automatically.

The skill assumes the engineer knows why they made the change. That assumption is what the gate rests on: it does not ask them to re-derive the diff, only to decide what the description is allowed to assert.

## Primary Flow

1. **The skill confirms the branch has something to describe.** A branch with no commits, or with commits but no file changes, produces no description. The skill says so and stops.

2. **The skill drafts the description.** The draft is written to the repository's pull request template when one exists, and to the skill's own lean shape when it does not ([D8](artifacts/decision-log.md#d8-repository-template-conformance-is-carried-forward)). It is written in one pass that produces the finished, readable prose and records, for each claim, the evidence it wrote that claim from ([D11](artifacts/decision-log.md#d11-readability-and-authoring-are-one-pass)). The skill never presents a claim as evidenced unless it held that evidence at the moment it wrote the claim ([T1](artifacts/feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)).

   Where the engineer stated their intent up front, the draft is written against it rather than guessing at it ([D17](artifacts/decision-log.md#d17-the-engineer-may-state-intent-before-the-draft-is-written)).

3. **The skill assembles the gate.** Every assertion the description makes to the reviewer is a gate item: the sentences of the summary and the behavior changes, any prose filled into a repository template's sections, and every checklist box the draft proposes to check ([D12](artifacts/decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read)). Each item is shown with the evidence recorded for it, or marked as one the skill could not evidence.

4. **The skill shows the gate, and holds.** The engineer sees each claim beside its evidence, and disposes of each blocking item. The gate does not finish while any blocking item is undecided ([D2](artifacts/decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for)). Alongside the claims, the gate carries the facts the engineer needs in order to judge them: how large the change is, and whether the skill read all of it ([D4](artifacts/decision-log.md#d4-the-size-fact-is-delivered-at-the-gate-not-shouted-past-the-engineer), [D18](artifacts/decision-log.md#d18-an-incomplete-read-of-the-diff-is-disclosed-as-its-own-condition)).

5. **The skill applies the engineer's decisions.** A claim they correct is used as they wrote it. A claim they reject is removed. The description is re-rendered from what survives, without re-drafting over it ([D7](artifacts/decision-log.md#d7-the-engineers-verdict-is-binding-and-re-rendering-does-not-re-draft)).

6. **The skill delivers the verified description, and offers to publish it.** The description is written to a file the engineer can take away, whatever happens next ([D20](artifacts/decision-log.md#d20-the-verified-description-is-written-to-a-file)). When the branch has an open pull request, the skill offers to update it, disclosing first what the update will destroy ([D14](artifacts/decision-log.md#d14-replacing-an-existing-description-is-disclosed-before-it-happens)). It publishes only on the engineer's word.

## The Gate

The gate is the feature, so its rules are stated here rather than left to be inferred.

**Blocking items.** Three kinds of item must be individually disposed of, and there is no path that accepts them in bulk:

- **A claim the skill could not evidence.** The engineer keeps it, corrects it, or drops it.
- **A claim about absence** — that nothing changed for existing callers, that no behavior changed. No diff can evidence an absence, so the engineer vouches for it or it goes ([D15](artifacts/decision-log.md#d15-absence-claims-are-structurally-unprovable-like-intent)).
- **The statement of why the change exists,** together with the ask for what feedback the engineer wants. Neither is in the diff. The engineer writes or confirms both, and leaving the feedback ask blank omits it ([D3](artifacts/decision-log.md#d3-the-lean-core-is-kept-and-gains-a-feedback-ask)).

**Non-blocking items.** Every other claim is shown with the evidence recorded for it, and may be accepted together once the blocking items are settled. The gate does not label these claims "supported" or otherwise vouch for them. It shows the claim and the evidence side by side and lets the engineer judge. The skill is not in a position to certify a claim it wrote itself, and a badge saying it is would teach the engineer to skip exactly the rows a fabricated claim hides in ([D2](artifacts/decision-log.md#d2-the-gate-shows-each-claim-with-its-evidence-and-blocks-on-what-the-skill-cannot-vouch-for)).

**The gate fails closed.** If the skill cannot obtain an answer from a human, that is not approval. The description is delivered marked unverified, and nothing is published ([D13](artifacts/decision-log.md#d13-the-gate-fails-closed)).

**The engineer can edit the draft directly,** and text they wrote is text they verified, so it needs no further evidence. This is not an exit from the gate: any claim they did not touch is still theirs to dispose of ([D21](artifacts/decision-log.md#d21-editing-the-draft-directly-verifies-what-was-edited-and-nothing-else)).

## Alternate Flows and States

- **No pull request exists yet.** The gate still runs, and the verified description is still written to a file. The engineer is taking the text somewhere regardless of whether the skill publishes it, and an unverified claim is no less wrong for being pasted by hand ([D6](artifacts/decision-log.md#d6-the-gate-runs-whether-or-not-a-pull-request-exists)).

- **The engineer declines to publish.** The verified description stands as the deliverable. Nothing is written to GitHub.

- **The skill is run again on the same branch.** It re-drafts and re-gates from the current diff. Claims verified on an earlier run are not carried forward, because the diff they were verified against has changed ([D19](artifacts/decision-log.md#d19-a-re-run-re-drafts-and-re-gates)).

- **The repository offers several templates.** The skill cannot know which the engineer intends, so it asks, offering the option of using none.

- **The engineer rejects the stated intent and supplies their own.** Their wording is used as written.

## Edge Cases and Failure Modes

| Case | Behavior |
|---|---|
| A claim rests on repository context outside the diff — an existing default, code the change interacts with | It is evidenced by the file it rests on. Evidence means the diff or a cited repository file, not the diff alone. Only a claim the skill can point at nothing for is marked unevidenced ([D10](artifacts/decision-log.md#d10-evidence-is-the-diff-or-a-cited-repository-file)). |
| A sentence bundles a claim the engineer accepts with one they reject | The sentence is not the unit. Each independently verifiable assertion is disposed of on its own, and the surviving assertions are re-rendered as readable prose ([D12](artifacts/decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read)). |
| The diff is too large for the skill to read in full | The skill says at the gate which parts it did not read, as a fact separate from the size warning. A claim the skill never had the evidence for is not the same as a claim about a file it never opened ([D18](artifacts/decision-log.md#d18-an-incomplete-read-of-the-diff-is-disclosed-as-its-own-condition)). |
| The change touches a binary file | There is no hunk to point at, so a claim about what changed inside it is unevidenced and blocks like any other. This is by design, not a defect. |
| The engineer rejects every claim in a section a repository template requires | The empty section comes back to them: they write it or mark it explicitly not applicable. The skill does not invent an honest-sounding note on their behalf ([D16](artifacts/decision-log.md#d16-a-section-emptied-by-rejections-returns-to-the-engineer)). |
| The engineer rejects every claim | There is no description left. The skill says so and offers to draft again with their corrections as input, rather than leaving them holding nothing. |
| A repository template carries a checklist | A box is proposed checked only when the diff proves it, and every proposed box is a gate item. An attestation of human action is never checked on the engineer's behalf. |
| The pull request already has a description | It will be replaced. The skill says what is about to be lost before it asks to publish ([D14](artifacts/decision-log.md#d14-replacing-an-existing-description-is-disclosed-before-it-happens)). |
| The default branch cannot be determined | The skill asks which branch to compare against rather than guessing. |

## User Interactions

The engineer is asked to act at most four times. Two are conditional and two are not.

- **Which branch to compare against** — only when the default branch cannot be determined.
- **Which template to use** — only when the repository offers several.
- **The gate** — always. The one place the skill genuinely stops. The engineer disposes of each blocking item, accepts or edits the rest, and cannot reach the end without deciding what the description is allowed to assert.
- **Whether to publish** — always, when a pull request exists, and stating what will be replaced.

The size of the change is not a fifth interaction. It is a fact carried into the gate, where the engineer is already present and already reading, rather than a message fired early in the run that scrolls out of sight before anyone reads it ([D4](artifacts/decision-log.md#d4-the-size-fact-is-delivered-at-the-gate-not-shouted-past-the-engineer)).

## Coordinations

- **The version control history.** Read-only. The branch's commits, changed files, and diff.
- **The repository's own files.** Read-only. The pull request template when one exists, and any source file a claim rests on.
- **GitHub.** Read to find whether the branch has an open pull request, and to read the description that is about to be replaced. Written once, only to set the description, and only after the engineer approves.

## Out of Scope

- Reviewing the code. The skill describes a change; it does not judge it.
- Posting review comments.
- Splitting an oversized change. The skill says the change is large; it does not divide it.
- Writing commit messages or issue bodies.
- Creating the pull request. The skill updates one that exists.
- Preserving or merging into the description already on the pull request. It is replaced, with disclosure.

## Deferred (YAGNI)

- **A link to the related issue or ticket.** Nearly universal across the sources, and associated with a faster first reviewer response. Deferred with the rest of the section set. *Reopening trigger:* a reviewer asks for context that lived in a ticket the description did not link, or a repository template requires the link. Note this interacts with replacement: a re-run deletes a link the engineer added by hand and does not put one back, which the disclosure in [D14](artifacts/decision-log.md#d14-replacing-an-existing-description-is-disclosed-before-it-happens) makes visible but does not solve.

- **A testing note.** In the research's recommended core, used by a minority of pull requests in practice. *Reopening trigger:* a repository template requires it, or reviewers start asking how a change was tested.

- **Conditional sections for screenshots, rollback, and migrations.** No evidence in this repository shows an engineer needing one. *Reopening trigger:* a change of that kind is described and the engineer adds the section by hand.

- **Blocking on an oversized change.** Rejected: the work is done by the time the skill runs, so refusing to describe it punishes a decision the engineer can no longer cheaply reverse ([D4](artifacts/decision-log.md#d4-the-size-fact-is-delivered-at-the-gate-not-shouted-past-the-engineer)).

- **Carrying verified claims across re-runs.** Rejected as unsound: a claim was verified against a diff that has since changed ([D19](artifacts/decision-log.md#d19-a-re-run-re-drafts-and-re-gates)).

## Open Items

- **Nobody has run this gate, so nobody knows how many items it produces.** The whole design rests on the claim count being small enough that an engineer reads it rather than skims it. [D12](artifacts/decision-log.md#d12-a-claim-is-one-independently-verifiable-assertion-and-the-gate-covers-every-assertion-the-reviewer-will-read) bounds the gate by scoping it to the lean core, which should keep it small, but that is a prediction. Resolve by drafting the gate against ten real merged pull requests in this repository and counting, before the design is treated as settled.

- **The gate exists to defeat a measured 61% no-review rate, and the spec commits to nothing that would reveal that rate recurring.** The observable to watch is how often an engineer actually corrects or rejects something. A gate that is never used to change anything is a gate being waved through. Watch it during dogfooding rather than building instrumentation for it.

- **Whether the size warning changes anyone's behavior is untested.** It is delivered where it will be read now, which is the most that can be said for it.

## Summary

The skill gains a gate that shows each claim beside the evidence it was written from, and that will not finish while an unevidenced claim, an absence claim, or the statement of intent is undecided. It fails closed, discloses what it is about to destroy, and delivers the description to a file whether or not it publishes. It folds readability into the pass that authors the prose, so nothing rewrites a claim after its evidence was recorded. The description keeps its lean core and gains an ask for the kind of feedback the engineer wants.

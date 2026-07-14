# Feature Specification: Verified PR Descriptions

## Outcome

An engineer finishes work on a branch, runs the skill, and gets a pull request description on GitHub whose every factual claim they have seen matched against the evidence in the diff, and whose statement of intent they wrote or approved themselves.

The change from today is the verification step. Today the skill drafts a description and asks for a single yes-or-no before publishing it, which means a claim the draft invented can reach the pull request unchallenged. After this change, the engineer sees each claim beside the diff evidence that supports it, and is asked separately to confirm or correct the one thing a diff can never prove: why the change exists ([D2](artifacts/decision-log.md#d2-the-verification-gate-shows-each-claim-against-its-diff-evidence)).

The description's shape does not change. It stays the lean core the skill already produces ([D3](artifacts/decision-log.md#d3-the-description-keeps-its-existing-lean-core)).

## Actors and Triggers

- **The engineer.** Invokes the skill on a branch that has commits ahead of the default branch. They are the only actor, and they are the one who verifies the result.
- **The trigger.** The engineer runs the skill. Nothing runs it automatically.

The skill assumes the engineer knows why they made the change. That assumption is what the verification gate is built on: it does not ask them to re-derive the diff, only to vouch for what the draft says about it.

## Primary Flow

1. **The skill confirms the branch has something to describe.** A branch with no commits or no file changes relative to the default branch produces no description; the skill says so and stops.

2. **The skill measures the change and warns when it is too large to review well.** When the branch changes more than roughly four hundred lines, the skill tells the engineer that a reviewer's ability to find defects drops sharply past that size and that splitting the change would get it a better review. It then continues and writes the description anyway ([D4](artifacts/decision-log.md#d4-oversized-changes-draw-a-warning-not-a-block)).

3. **The skill finds the repository's pull request template, if it has one.** When the repository defines a template, the description conforms to it. When it does not, the description takes the skill's own lean shape ([D8](artifacts/decision-log.md#d8-repository-template-conformance-is-unchanged)).

4. **The skill drafts the description, and every factual claim it writes is recorded together with the diff evidence that supports it.** The draft is written by a pass whose job is authoring prose, not critiquing it ([D5](artifacts/decision-log.md#d5-authoring-is-a-writing-pass-not-a-repurposed-critique-pass)). As each claim is written, it is paired with the specific part of the diff it rests on, rather than the pairing being reconstructed afterward from the finished text ([T1](artifacts/feature-technical-notes.md#t1-claim-provenance-is-captured-at-authoring-time)).

5. **The skill shows the engineer each claim beside its evidence, and asks them to confirm the intent.** Claims that the diff supports are shown with the evidence. Any claim the draft could not tie to the diff is shown as unsupported and called out as such. The statement of why the change exists is always shown as unprovable, because no diff can prove intent, and the engineer either confirms it or rewrites it ([D2](artifacts/decision-log.md#d2-the-verification-gate-shows-each-claim-against-its-diff-evidence)).

6. **The skill applies what the engineer decided, and re-renders.** A claim the engineer corrects is rewritten as they said. A claim they reject is removed. The description is re-rendered from what survives ([D7](artifacts/decision-log.md#d7-a-rejected-claim-is-removed-a-corrected-claim-is-rewritten)).

7. **The skill presents the verified description, and offers to publish it.** When the branch has an open pull request, the skill offers to update its description and does so on the engineer's word. When it does not, the description is the deliverable and the skill stops there.

## Alternate Flows and States

- **No pull request exists yet.** The verification gate still runs, and the description is still shown claim by claim. The engineer is taking the text somewhere regardless of whether the skill is the one to publish it, so an unverified claim is no less wrong for being pasted by hand ([D6](artifacts/decision-log.md#d6-the-gate-runs-whether-or-not-a-pull-request-exists)).

- **The engineer declines to publish.** The verified description is shown and the skill stops. Nothing is written to GitHub.

- **The repository offers several templates to choose from.** The skill cannot know which one the engineer intends, so it asks, and offers the option of using no template at all.

- **The engineer rejects the stated intent and supplies their own.** Their wording is used as written. The skill does not re-draft over it.

## Edge Cases and Failure Modes

| Case | Behavior |
|---|---|
| A claim cannot be tied to any part of the diff | It is shown to the engineer as unsupported, not silently kept. They keep it, correct it, or drop it. |
| The engineer rejects every claim | The description is empty of substance, and the skill says so rather than publishing a hollow description. |
| The change is so large the diff cannot be read in full | The size warning has already fired. The draft describes what it could read, and any claim it could not evidence is surfaced as unsupported like any other. |
| The branch has commits but no file changes | Nothing to describe. The skill says so and stops. |
| The default branch cannot be determined | The skill asks the engineer which branch to compare against, rather than guessing. |
| The repository template carries a checklist | Only a box the diff unambiguously proves is checked. An attestation of human action is never checked on the engineer's behalf. |
| The pull request already has a description | It is replaced by the verified one. The skill does not merge into or preserve the old text. |

## User Interactions

The engineer meets the skill twice.

The **size warning** is a statement, not a question. It fires only when the change is large, and it does not wait for an answer.

The **verification gate** is the one place the skill genuinely stops and waits. It presents the draft's claims as a list, each paired with the diff evidence behind it, with unsupported claims and the statement of intent marked as needing a human. The engineer can confirm the list as it stands, correct any entry, or edit the draft directly. The gate is not a formality the engineer can wave through without seeing what they are agreeing to: the evidence is on the screen next to the claim, which is the whole point of showing it that way rather than showing finished prose and asking whether it looks right ([D2](artifacts/decision-log.md#d2-the-verification-gate-shows-each-claim-against-its-diff-evidence)).

## Coordinations

- **The version control history.** Read-only. The branch's commits, changed files, and diff are the evidence every claim is checked against.
- **The repository's own files.** Read-only. The pull request template, when one exists, and any source file the draft needs to understand a change the diff alone does not explain.
- **GitHub.** Read to find whether the branch has an open pull request. Written only once, only to set the description, and only after the engineer approves.

## Out of Scope

- Reviewing the code. The skill describes a change; it does not judge it.
- Posting review comments to the pull request.
- Splitting an oversized change. The skill says the change is large; it does not divide it.
- Writing commit messages or issue bodies.
- Creating the pull request. The skill updates one that exists.

## Deferred (YAGNI)

- **A link to the related issue or ticket.** The research finds this nearly universal across templates and associated with a faster first reviewer response. It was deferred because the lean core was kept as-is. *Reopening trigger:* an engineer reports a reviewer asking for context that lives in a ticket the description did not link, or a repository template the skill encounters requires the link.

- **A statement of what feedback the author wants.** The research measures this as the single largest effect on merge odds of any description element. It was deferred because it cannot be derived from the diff, so adding it means adding a question to every run. *Reopening trigger:* an engineer asks for it, or the verification gate's interaction proves cheap enough that a second question is no longer a meaningful cost.

- **A testing note.** In the research's recommended core, but used by a minority of pull requests in practice. Deferred with the rest of the section set. *Reopening trigger:* a repository template requires it, or an engineer reports reviewers asking how the change was tested.

- **Conditional sections for screenshots, rollback, and migrations.** The research recommends these fire only when the change calls for them. No evidence in this repository shows an engineer needing one. *Reopening trigger:* a change of that kind is described and the engineer adds the section by hand.

- **Blocking on an oversized change.** Considered and rejected: the work is already done by the time the skill runs, so refusing to describe it punishes the engineer for a decision they can no longer cheaply reverse ([D4](artifacts/decision-log.md#d4-oversized-changes-draw-a-warning-not-a-block)).

## Open Items

*Populated during synthesis.*

## Summary

The skill gains a verification gate that shows each claim beside its evidence, and a warning when the change is too large to review well. It replaces its authoring pass with one built for writing rather than critique. Everything else about the description it produces stays as it is.

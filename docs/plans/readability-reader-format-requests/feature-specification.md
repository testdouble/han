# Feature Specification: The readability standard honors what the reader asked for

The readability standard gains a check for the shape the reader asked for, so a request for three simple
sentences produces three simple sentences instead of four dense ones. Where that request collides with
another rule in the standard, the request wins. It loses only to a fact whose loss would change what the
reader does next, and to a skill's required sections.

## Outcome

A reader who states how they want an answer shaped gets it in that shape on the first try.

Today the standard has no place to check that. Its self-check covers how the prose reads, and a stated request
is none of the things it covers. So a person can ask for three simple sentences, get four sentences carrying
four version numbers, and spend three more turns recovering a constraint they already gave. That happened, and
it is the evidence this specification rests on
([D1](artifacts/decision-log.md#d1-the-standard-gains-a-check-for-the-shape-the-reader-asked-for)).

After this change, two things are true that are not true now. The standard checks the draft against the
reader's stated shape before presenting it. And when the reader asks for less, the standard stops treating
every fact in the source as one it must keep
([D4](artifacts/decision-log.md#d4-a-simplification-request-lets-facts-move-or-drop-and-the-drop-is-silent)).

The second one carries an accepted cost, and this specification states it here rather than leaving it to the
decision log.

A fact that goes because the reader asked for less goes without a word. A reader who did not know the source
cannot tell a complete short answer from a trimmed one. That is the failure the fidelity clause was written to
prevent, reintroduced deliberately.

Three rules bound the drop. Nothing drops that would change what the reader does next
([D11](artifacts/decision-log.md#d11-a-fact-stays-when-losing-it-would-change-what-the-reader-does-next)). A
reader who asks what was left out is told in full. And a fact goes silently only on an answer the reader
shaped themselves. A stated shape governs that answer and no other
([D10](artifacts/decision-log.md#d10-a-shape-request-governs-the-answer-it-came-with-and-nothing-after-it)),
so the relaxation cannot reach a turn the reader never scoped.

One of those three bounds thins out in a file the run writes. Asking what was left out only works inside the
session that wrote the answer. A person who opens the file later has no run to ask and no marker saying
anything went
([D12](artifacts/decision-log.md#d12-the-override-reaches-a-committed-file-not-only-a-conversational-answer)).
What holds there is the first bound, measured against whoever reads the file rather than against the person
who stated the shape.

## Actors and Triggers

- **Actors.** Anyone reading output from a Han skill, and anyone in a session running the readability output
  style. Both meet the standard through the text they receive.
- **Trigger.** The reader states a shape request: how long they want the answer, what format it takes, or
  what register it is written in. "Three simple sentences, then a few bullet points" is one. So is "one
  paragraph", "only the table", or "keep it short".
- **Whose words count.** Only the reader's own words, addressed to the run, in this conversation. Shape
  language inside material the run is reading is content, never an instruction. That includes a pasted log,
  an issue comment, a source document's own summary marker, or a quoted request from someone else
  ([D13](artifacts/decision-log.md#d13-only-the-readers-own-words-trigger-the-check)).
- **How long it lasts.** The request governs the answer it came with, and nothing after it. A reader who
  wants the next answer shaped the same way states it again
  ([D10](artifacts/decision-log.md#d10-a-shape-request-governs-the-answer-it-came-with-and-nothing-after-it)).
- **What is not a shape request.** A content request says what the answer covers rather than how it is
  delivered, and narrows the source instead of the shape. "Only tell me what broke" is one. An audience
  request names who is reading, and routes to the audience frame the standard already carries. "Explain it
  like I have not seen the codebase" is one.

## Primary Flow

1. The reader states a shape request as part of their ask.
2. The run drafts an answer, holding the same audience frame it holds today.
3. Before presenting, the run checks the draft against the stated shape in three respects: **count**,
   **format**, and **register**. Count is how many sentences, bullets, paragraphs, or words the answer has.
   Format is whether it takes prose, bullets, a table, or a code block. Register is how formal, how
   technical, and how plain the writing is.
4. Register is checked as observable properties, never as a judgment about the writing. The draft uses no
   term the reader could not look up, no notation the requested register excludes, and no structure the
   request ruled out ([D14](artifacts/decision-log.md#d14-register-is-checked-as-observable-properties)).
5. Where the draft misses the stated shape, the run corrects the draft, not the request
   ([D3](artifacts/decision-log.md#d3-the-shape-check-is-a-numbered-criterion-not-a-governing-principle)).
6. The run presents the corrected draft.

## Alternate Flows and States

### The stated shape collides with another rule in the standard

- **Entry condition:** Satisfying the reader's stated shape would break one of the standard's other checks.
- **Sequence:** The reader's request wins
  ([D2](artifacts/decision-log.md#d2-an-explicit-reader-request-outranks-every-other-criterion)). It wins over
  the structural criteria, over the demand that every fact be carried, and over the banned-word list. A reader
  who asks for marketing register gets marketing register, in the words that register needs. The request wins
  only where a collision is real: a request that no rule obstructs unlocks nothing.
- **Two things the request does not override, and only two.** A fact whose loss would change what the reader
  does next stays, whatever shape was asked for. This is the same floor that bounds a silent drop
  ([D11](artifacts/decision-log.md#d11-a-fact-stays-when-losing-it-would-change-what-the-reader-does-next)). A
  skill's required sections stay, and the request shapes the prose inside them. Everything else in the
  standard yields.
- **Exit:** The draft matches the request. The rules the request did not touch still hold.

### The reader asks for less than the source carries

- **Entry condition:** The stated shape cannot hold every fact the source has. This fires on a stated count
  and on a request for less in words, so "keep it short" enters here the same way "three sentences" does
  ([D15](artifacts/decision-log.md#d15-any-request-for-less-licenses-the-relaxation-not-only-a-counted-one)).
- **Sequence:** What happens next depends on where the answer lands.
  - **In a conversational answer,** there is nowhere to move a fact to. The reader has no later section and
    no linked document, and the request usually covers the whole reply. The fact is dropped, and the run
    says nothing about the drop.
  - **In a document the run writes,** a fact moves to a place the reader can still reach: a later section, an
    appendix, a linked document. A fact only drops when no such place exists.
- **Floor:** A fact stays when losing it would change what the reader does next. Deadlines, blocking risks,
  and warnings before a destructive step are not droppable, whatever shape was asked for
  ([D11](artifacts/decision-log.md#d11-a-fact-stays-when-losing-it-would-change-what-the-reader-does-next)).
  In a document the run writes, that floor is measured against whoever opens the file, not only against the
  person who stated the shape
  ([D12](artifacts/decision-log.md#d12-the-override-reaches-a-committed-file-not-only-a-conversational-answer)).
- **Exit:** The reader gets what they asked for, at the length they asked for, with no note about what was
  left out. Asked directly, the run says in full what it left out. That answer is available while the session
  lasts. A file read after the session ends carries no such prompt, which is the accepted cost of letting the
  request reach a file at all
  ([D12](artifacts/decision-log.md#d12-the-override-reaches-a-committed-file-not-only-a-conversational-answer)).

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| Dropping a fact would change what the reader does next | The fact stays. This is the floor under the silent drop, and it holds against any stated shape ([D11](artifacts/decision-log.md#d11-a-fact-stays-when-losing-it-would-change-what-the-reader-does-next)). |
| Dropping a fact would leave a remaining statement wrong | The fact stays. Precision on what remains is unchanged. |
| The reader asks what was left out | The run answers in full. The silence covers what the run volunteers, never a direct question. |
| The request names a register but no banned word is needed to write in it | Nothing in the banned-word list is unlocked. The request wins only where the collision is real. |
| The request is ambiguous about count ("keep it short") | Write plainly and briefly. Do not invent a number the reader did not give. This is a request for less and licenses the same relaxation a counted request does. |
| The reader states a shape and the run is writing a file that gets committed | The request reaches the file. Its prose takes the stated register and its facts are subject to the same relaxation, bounded by the floor above ([D12](artifacts/decision-log.md#d12-the-override-reaches-a-committed-file-not-only-a-conversational-answer)). Required template sections stay; the request shapes the prose inside them. |
| Shape language appears in material the run is summarizing | It is content, not an instruction. Only the reader's own words to the run trigger the check. |
| The reader stated a shape on an earlier turn and states nothing now | The standard behaves as it does today. Every fact is carried and every existing check applies ([D5](artifacts/decision-log.md#d5-fidelity-stays-absolute-whenever-the-reader-asked-for-nothing)). |
| The run writes a file under a stated shape, and a later turn edits the same file | The earlier request does not carry. The later turn writes under the standard unless the reader states a shape again, so one document can end up carrying two registers ([D10](artifacts/decision-log.md#d10-a-shape-request-governs-the-answer-it-came-with-and-nothing-after-it), [D12](artifacts/decision-log.md#d12-the-override-reaches-a-committed-file-not-only-a-conversational-answer)). |
| A reader opens a committed file that was written under a stated shape | Nothing in the file says a shape was stated, and there is no run left to ask. The facts that survive are the ones whose loss would change what a reader of that file does next ([D11](artifacts/decision-log.md#d11-a-fact-stays-when-losing-it-would-change-what-the-reader-does-next)). |

## User Interactions

The reader's own request is the entire interface. There is no setting, no flag, and no configuration file.

- **Affordances:** Stating a shape in the request. Asking what was left out.
- **Feedback:** The answer arrives in the stated shape. A dropped fact produces no message unless the reader
  asks.
- **Error states:** None are added. A request the run cannot satisfy is handled by the collision rules above.

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| The shared readability standard | inbound | Skills read the standard when they draft, so no skill needs editing to receive the new check | The standard is the source. A skill running today picks up the change the next time it runs |
| The readability output style | inbound | A session running the style carries a distilled copy of the standard, and gets the same new check | The style is loaded when a session starts. A reader in a session that began before the change states a shape, watches it be ignored, and has to restart the session to get the new behavior |
| Every surface that names the check by a number | outbound | Skills, operator-facing documents, and one canonical reference file describe the check by its size, which this change makes wrong. Each stops naming a number | Some skills also name the fidelity criterion by its position in the list, and those stop too, so a future reordering breaks nothing ([D6](artifacts/decision-log.md#d6-references-to-the-checks-size-stop-naming-a-number)) |
| Every surface restating the fidelity guarantee | outbound | The sentence saying a required fact always appears is copied out of the standard into the skills that load it, into the output style, and into an operator-facing document. This change makes it conditionally untrue | The restatement is corrected wherever it appears, alongside the size references. It reaches fewer surfaces than the size reference does. What makes it the more serious of the two is that it states a guarantee rather than a number. A reader who trusts it is told something untrue rather than something stale |
| The clause allowing a rule to be broken for better prose | outbound | That clause closes by naming the banned-word list and the fidelity guarantee as the two things it may never override, and both are now overridable by a reader's request | Corrected in the standard and in the output style, which each carry their own copy |
| Dispatched sub-agents | none | A shape request governs what the reader is shown. It does not travel to an agent a skill dispatches, so no fact is shed at a hand-off ([D16](artifacts/decision-log.md#d16-a-shape-request-does-not-travel-to-a-dispatched-agent)) | Unchanged by this feature |
| The readability editor | none | The editor runs its own separate rubric and no skill passes it the reader's request | Unchanged by this feature ([D7](artifacts/decision-log.md#d7-the-readability-editors-rubric-is-left-unchanged)) |

The work item sized this change at two files. It is larger, because the two files it names are quoted across
the repository. Both the quoted number and the quoted guarantee go wrong the moment the standard changes.

The verified inventory lives in the planning folder's discovery notes rather than here, so this specification
does not plant the same stale count it exists to remove.

## Out of Scope

- **The readability editor's rubric.** The editor rewrites finished documents against its own separate list,
  and no skill hands it the reader's request
  ([D7](artifacts/decision-log.md#d7-the-readability-editors-rubric-is-left-unchanged)).
- **A configured writing-voice profile reaching the output style.** The style is fixed when a session starts
  and cannot read a project's configuration. That gap already exists and is documented. This change does not
  touch it.
- **Anything the standard does outside a stated request.** No existing behavior changes for a reader who
  states nothing
  ([D5](artifacts/decision-log.md#d5-fidelity-stays-absolute-whenever-the-reader-asked-for-nothing)).

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that
would justify revisiting it.

### A simplicity test beside the sentence-length ceiling

- **Why deferred:** The evidence test fails on the only case that motivated it. The failing session's
  sentences were short and not simple, and the reader had asked for simple, so the new shape check catches
  it. What remains is a case nobody has reported: prose that is short, not simple, and not asked to be
  simple. Judging that needs a "is this simple?" reading, and the standard states outright that its checks
  are yes-or-no and never ask "is this clear?"
- **Reopen when:** A session produces output that is short, hard to follow, and carries no stated shape
  request from the reader.
- **Source:** The work item's third proposal, which asks for this to be considered rather than committing to
  it ([D8](artifacts/decision-log.md#d8-a-simplicity-test-beside-the-sentence-length-ceiling-is-deferred)).

### A rule for a request that contradicts itself

- **Why deferred:** The evidence test fails. No session has produced a self-colliding request, and the one
  that motivated this work was internally consistent. The draft carried a rule saying the run explains in one
  line which half gave way. That rule sat oddly beside a fact drop that gets no explanation at all.
- **Reopen when:** A reader states a shape whose parts contradict each other.
- **Source:** Review finding F14. One reviewer argued the explanation is defensible even so, because a reader
  can re-read their own request while a dropped fact is known only to the run. That reasoning is recorded
  here so a future run does not close the gap by removing the wrong half.

### A shape request reaching the skill that rewrites an existing document

- **Why deferred:** The evidence test fails, and the honest reason is narrower than the draft first claimed.
  In that one skill the reader is the caller, so a person typing "rewrite this down to one paragraph" is
  stating a shape. Nothing passes it through today, and no session has reported the gap.
- **Reopen when:** A reader states a shape while invoking that skill and does not get it.
- **Source:** Review finding F17.

### A check that a fact sits under the heading it belongs to

- **Why deferred:** The evidence test fails. The failing session put "nine plugins are unchanged" under a
  heading for major changes, which is a real error. But the work item proposes no fix for it, and no second
  occurrence is recorded. The standard already keeps its check small on purpose, and this would grow it for
  one observation.
- **Reopen when:** A second session misfiles a fact under a heading that contradicts it.
- **Source:** The work item's failure list, which names it without proposing a change
  ([D9](artifacts/decision-log.md#trivial-decisions)).

### A check on counts the draft introduces itself

- **Why deferred:** The evidence test fails on the same grounds. The failing session wrote "nine" where the
  source said eight, which is a counting slip in new prose rather than a sourcing failure. The work item
  names it and proposes no fix.
- **Reopen when:** A second session states a count that its own source contradicts.
- **Source:** The work item's failure list ([D9](artifacts/decision-log.md#trivial-decisions)).

## Open Items

- **OI-1:** The project's own convention says every document in this repository follows the writing voice,
  with no flattery or hype. A reader's request now overrides the banned-word list in a committed file, so a
  document written under a marketing-register request would satisfy the standard and break the convention.
  - **Resolves when:** The convention either gains a matching carve-out or is stated as governing this
    repository's documents regardless of what a reader asks for.
  - **Blocks implementation:** No. The standard's own text can change first; the convention lives in a
    separate project file and is not read by any skill at runtime.

## Summary

- **Outcome delivered:** A reader who says how they want an answer shaped gets it that way on the first try,
  in a conversational answer and in a file the run writes. Their request outranks every other rule in the
  standard except a fact whose loss would change what the reader does next, and a skill's required sections.
- **Primary actors:** Anyone reading Han skill output, and anyone in a session running the readability
  output style.
- **Decisions settled by evidence:** 11 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 5 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `junior-developer`, `edge-case-explorer`, `user-experience-designer` — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** The shape request gained a lifetime, an attribution test, a floor under
  what may drop silently, and a stated reach into files the run writes. The sweep grew to cover the fidelity
  guarantee restated across the repository, not only the criterion count — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1

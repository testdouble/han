# Feature Specification: The readability standard honors what the reader asked for

The readability standard gains a check for the shape the reader asked for, so a request for three simple
sentences produces three simple sentences instead of four dense ones. Where that request collides with any
other rule in the standard, the request wins.

## Outcome

A reader who states how they want an answer shaped gets it in that shape on the first try.

Today the standard has no place to check that. It checks six things, and a stated request is none of them.
So a person can ask for three simple sentences, get four sentences carrying four version numbers, and spend
three more turns recovering a constraint they already gave. That happened, and it is the evidence this
specification rests on ([D1](artifacts/decision-log.md#d1-the-standard-gains-a-check-for-the-shape-the-reader-asked-for)).

After this change, two things are true that are not true now. The standard checks the draft against the
reader's stated shape before presenting it. And when the reader asks for less, the standard stops treating
every fact in the source as one it must keep
([D4](artifacts/decision-log.md#d4-a-simplification-request-lets-facts-move-or-drop-and-the-drop-is-silent)).

## Actors and Triggers

- **Actors.** Anyone reading output from a Han skill, and anyone in a session running the readability output
  style. Both meet the standard through the text they receive, never by opening a file.
- **Trigger.** The reader states a shape request: how long they want the answer, what format it takes, or
  what register it is written in. "Three simple sentences, then a few bullet points" is one. So is "one
  paragraph", "just the table", or "explain it like I have not seen the codebase".
- **Precondition.** The request is stated. The standard does not guess at an unstated preference, and an
  absent request changes nothing about how the standard behaves today
  ([D5](artifacts/decision-log.md#d5-fidelity-stays-absolute-whenever-the-reader-asked-for-nothing)).

## Primary Flow

1. The reader states a shape request as part of their ask.
2. The run drafts an answer, holding the same audience frame it holds today.
3. Before presenting, the run checks the draft against the stated shape in three respects: **count** (how
   many sentences, bullets, paragraphs, or words), **format** (prose, bullets, a table, a code block), and
   **register** (how formal, how technical, how plain).
4. Where the draft misses the stated shape, the run corrects the draft, not the request
   ([D3](artifacts/decision-log.md#d3-the-shape-check-is-a-numbered-criterion-not-a-governing-principle)).
5. The run presents the corrected draft.

## Alternate Flows and States

### The stated shape collides with another rule in the standard

- **Entry condition:** Satisfying the reader's stated shape would break one of the standard's other checks.
- **Sequence:** The reader's request wins
  ([D2](artifacts/decision-log.md#d2-an-explicit-reader-request-outranks-every-other-criterion)). It wins over
  the structural rules, over the demand that every fact be carried, and over the banned-word list. A reader
  who asks for marketing register gets marketing register, in the words that register needs.
- **Exit:** The draft matches the request. The rules the request did not touch still hold.

### The reader asks for less than the source carries

- **Entry condition:** The stated shape cannot hold every fact the source has.
- **Sequence:** A fact either moves somewhere the reader can still reach it, or it goes. Moving is preferred
  when a place to move it to exists: a later section, a linked document, a following paragraph the shape
  request did not cover. When neither fits, the fact is dropped and the run says nothing about the drop
  ([D4](artifacts/decision-log.md#d4-a-simplification-request-lets-facts-move-or-drop-and-the-drop-is-silent)).
- **Exit:** The reader gets what they asked for, at the length they asked for, with no note about what was
  left out.

### No shape request was stated

- **Entry condition:** The reader stated nothing about count, format, or register.
- **Sequence:** The standard behaves exactly as it does today. Every fact is carried, and every existing
  check applies unchanged.
- **Exit:** The output is what the current standard would already have produced
  ([D5](artifacts/decision-log.md#d5-fidelity-stays-absolute-whenever-the-reader-asked-for-nothing)).

## Edge Cases and Failure Modes

| Condition | Required Behavior |
| --------- | ----------------- |
| Dropping a fact would leave a remaining statement wrong | The fact stays. Dropping is licensed for facts the reader asked to shed, never for facts another sentence depends on to be true. Precision on what remains is unchanged. |
| The request names a register but no banned word is needed to write in it | Nothing in the banned-word list is unlocked. The request wins only where it actually collides with a rule. |
| The request is ambiguous about count ("keep it short") | Treat it as a register request, not a count request. Write plainly and briefly. Do not invent a number the reader did not give. |
| Two parts of the request collide with each other | Satisfy the more specific one and say in one line which one gave way. A collision inside the request is not the standard overriding the reader. |
| The reader states a shape and the deliverable is a structured document with a fixed template | The template's required sections stay. The request shapes the prose inside them. |
| A skill dispatches the readability editor on a finished document | The editor's behavior is unchanged. It never receives the reader's request, so it has nothing new to check ([D7](artifacts/decision-log.md#d7-the-readability-editor-is-left-unchanged)). |

## User Interactions

The reader's own request is the entire interface. There is no setting, no flag, and no configuration file.

- **Affordances:** Stating a shape in the request. Nothing else is added.
- **Feedback:** The answer arrives in the stated shape. A dropped fact produces no message
  ([D4](artifacts/decision-log.md#d4-a-simplification-request-lets-facts-move-or-drop-and-the-drop-is-silent)).
- **Error states:** None are added. A request the run cannot satisfy is handled by the collision rules above.

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
| ------------------- | --------- | ----------- | ---------------------------------- |
| The shared readability standard | inbound | Skills read the standard when they draft, so the new check reaches them without any edit to the skills themselves | The standard is the source. A skill running today picks up the change the next time it runs |
| The readability output style | inbound | A session running the style carries a distilled copy of the standard, and gets the same new check | The style is loaded when a session starts, so a running session keeps the old copy until it restarts |
| The skills that name the check's size | outbound | Twenty-one skills and two operator-facing documents describe the check by a number that this change makes wrong | Every one of them stops naming a number, so no future change to the check touches them again ([D6](artifacts/decision-log.md#d6-references-to-the-checks-size-stop-naming-a-number)) |
| The readability editor | none | The editor runs its own separate rubric and never receives the reader's request | Unchanged by this feature ([D7](artifacts/decision-log.md#d7-the-readability-editor-is-left-unchanged)) |

## Out of Scope

- **The readability editor's rubric.** The editor is the rewrite pass for finished documents. Every skill
  that dispatches it hands over a file and an audience, never the reader's request, so a shape check there
  would have nothing to read.
- **A configured writing-voice profile reaching the output style.** The style is a static block loaded at
  session start and cannot read a project's configuration. That gap already exists and is documented. This
  change does not touch it.
- **Anything the standard does outside a stated request.** No existing behavior changes for a reader who
  states nothing.

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
  it.

### A check that a fact sits under the heading it belongs to

- **Why deferred:** The evidence test fails. The failing session put "nine plugins are unchanged" under a
  heading for major changes, which is a real error, but the work item proposes no fix for it and no second
  occurrence is recorded. The standard already keeps its check small on purpose, and this would grow it for
  one observation.
- **Reopen when:** A second session misfiles a fact under a heading that contradicts it.
- **Source:** The work item's failure list, which names it without proposing a change.

### A check on counts the draft introduces itself

- **Why deferred:** The evidence test fails on the same grounds. The failing session wrote "nine" where the
  source said eight, which is a counting slip in new prose rather than a sourcing failure. The work item
  names it and proposes no fix.
- **Reopen when:** A second session states a count that its own source contradicts.
- **Source:** The work item's failure list.

## Open Items

None. Every question this specification raised was settled by evidence or by the user.

## Summary

- **Outcome delivered:** A reader who says how they want an answer shaped gets it that way on the first try,
  and their request outranks every other rule in the standard.
- **Primary actors:** Anyone reading Han skill output, and anyone in a session running the readability
  output style.
- **Decisions settled by evidence:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0

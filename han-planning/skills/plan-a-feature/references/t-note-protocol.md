# The `T#` Technical Note Protocol

## Contents

- What a `T#` note is for
- Capture: the in-message accumulator
- Flush: writing the file
- When no candidate qualifies
- Related references

A `T#` note carries a mechanic the specification cannot state behaviorally but a reader needs in order to get the
behavior right. The spec sentence still states the behavioral consequence on its own; the `T#` link only supplies the
mechanic underneath it.

Notes are captured during the interview and written to disk once, later. This file owns both halves, because splitting a
capture rule from its flush rule is how the two drift apart. Step 4 applies the capture half, Step 5 the flush half, and
Step 7 the flush half again when finding resolution produces the first qualifying note.

## What a `T#` note is for

A candidate qualifies on two tests, both from
[mechanic-routing.md](./mechanic-routing.md):

- It is **load-bearing**: the mechanic changes what the user or system observably experiences, such as ordering,
  durability, delivery guarantees, consistency, visibility timing, or error visibility.
- It is **not discoverable in the code repo**: no existing pattern, in-use library, or documented convention already
  answers it. A discoverable mechanic is cited as evidence on the `D#` instead, and no note is created.

A mechanic that fails either test is pure implementation and belongs to `plan-implementation`, with the one contract
exception `mechanic-routing.md` names.

## Capture: the in-message accumulator

`feature-technical-notes.md` is not written during the interview. Track candidates in-message instead, by stating each
one plainly as it is identified:

> **T-note candidate captured — T(pending #N): {short title}. Supports D{n}; section {spec section}; mechanic: {one-line
> summary}.**

Stating it makes the accumulator visible in the conversation history, which is what gives the user a chance to redirect
before anything reaches disk. Two redirections are common: "that is discoverable from code" and "that is not
load-bearing". When the user redirects, drop the candidate from further consideration.

A candidate can also stop qualifying on its own. A review specialist proving in Step 6 that the mechanic is discoverable
from code retires it the same way. Nothing needs undoing, because the flush re-validates every candidate before writing.

## Flush: writing the file

Write `{folder}/artifacts/feature-technical-notes.md` from
[feature-technical-notes-template.md](./feature-technical-notes-template.md), in this order:

1. Review every candidate the accumulator holds.
2. Re-validate each one against the two tests above. Drop the ones the user redirected and the ones later evidence
   retired.
3. Assign `T1..Tn` in the order captured, not the order validated. Capture order is what the conversation history shows,
   so a reader tracing a note back to the turn that raised it finds it where they expect.
4. Write one entry per qualifying candidate, carrying `Title`, `Context`, `Technical detail`, `Supports decisions:` (the
   `D#` IDs), `Driven by findings:` (`—` during the initial draft), and `Referenced in spec:` (the spec section
   headings).
5. Populate each supported `D#`'s `Linked technical notes:` field with the `T#` IDs.
6. Add an inline `([T#](artifacts/feature-technical-notes.md#t#-slug))` link to each spec sentence a note supports. Link
   only sentences where the mechanic changes observable behavior, never as a gratuitous "see also".

## When no candidate qualifies

Do not create the file. The artifacts folder gains no empty file and no stub, and every reference to
`feature-technical-notes.md` in the other artifacts is absent rather than pointing at nothing.

An absent file records that the interview captured no load-bearing mechanic. It never records that the specification is
incomplete.

## Related references

- [mechanic-routing.md](./mechanic-routing.md), for the three-way classification a candidate is tested against, and the
  one contract case that is recorded as an Open Item instead.
- [feature-technical-notes-template.md](./feature-technical-notes-template.md), for the file's own structure.
- [decision-log-template.md](./decision-log-template.md), for the `Linked technical notes:` field the flush populates.

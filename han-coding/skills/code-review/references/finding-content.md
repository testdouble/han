# Finding Content: the plain-language explanation

## Contents

- Which findings carry it
- What the explanation answers
- Where the answers come from
- The fix route
- Both cues reach the summary table
- Security findings

Every finding a reader is expected to act on opens with a plain-language explanation written for someone who will not
open the file. This file says which findings carry it, what it answers, and where the answers come from. The block
format it renders into is in [template.md](./template.md).

The register comes from Han's standard for explaining technical work to a non-implementer, sourced by invoking
`han-communication:explanation-guidance` before any finding is drafted. Give a concrete outcome the reader could
observe, not the mechanism that produces it.

## Which findings carry it

**Carry it:** every CRIT, WARN, and SUGG finding, and every SEC finding. These are the findings the report asks someone
to act on.

**Do not carry it:** YAGNI findings. Each one already ends with the concrete circumstance that would justify keeping the
code as written, which is the same content the explanation exists to supply. Requiring both would print the same thing
twice and lengthen a section whose brevity is the point.

Both skills say this in the report's own vocabulary. "Corrective" and "advisory" are not words a reader of a report
sees.

## What the explanation answers

Three questions, always all three:

1. **What goes wrong that someone could observe.** The message, the wrong number, the state they would encounter. Not
   the function that produces it.
2. **What has to be true for it to happen.** The preconditions, all of them, stated plainly.
3. **How likely that is.** An honest answer, including "this may never fire if X" when that is the honest answer.

**Answer all three; do not print three fixed slots.** Where an answer is not in doubt, it is a clause rather than a
sentence. On a finding whose failure is certain and unconditional, the preconditions and the likelihood both collapse to
"always", and spending a sentence on each is padding. Requiring the questions to be answered keeps the whole of the
evidence; requiring three sentences does not.

**The explanation leads the finding**, ahead of the existing guidance written for the person who will open the file.
That guidance keeps its detail: the location, the mechanism, the suggested fix. The two registers serve different
readers, and the reader this one is written for should not have to read past prose addressed to someone else to reach
their own.

## Where the answers come from

**When Step 7.2 already produced the reasoning, publish it.** That gate reads a finding's rationale for signals that the
failure mode is not reachable, and demotes the finding when it finds one. Today it computes that reasoning and throws it
away. It is exactly what questions 2 and 3 ask for, so it goes into the explanation instead.

**Otherwise, derive the answers from the evidence the finding already carries.** The gate matches a fixed list of
phrases, so it produces reasoning on the findings it matched and nothing on the rest. That is not the same population as
the findings a reader cannot judge unaided, so the rest are worked out at drafting time from what the finding already
shows.

**Deriving them NEVER changes the finding's severity.** Not the finding's severity, not its task ID, not its position in
the report. This is writing work, and it runs after every pass that sets severity. A finding whose explanation comes out
reading "this may be a no-op if the upstream never returns nil" keeps the severity those passes gave it. BECAUSE
re-deciding severity here would silently reopen the discovery and validation passes this content is written on top of,
and those passes see evidence this step does not.

## The fix route

Every CRIT, WARN, and SUGG finding also names how it gets fixed. The reader asks anyway, and the finding already carries
what decides the answer, so naming it costs a clause.

Pick exactly one of three:

| Route           | Pick it when                                                                                      | Rendered as                   |
| --------------- | ------------------------------------------------------------------------------------------------- | ----------------------------- |
| **test-first**  | A behavior is missing or wrong. The fix is new or corrected behavior, and a test should drive it. | `test-first (\`/tdd\`)`       |
| **restructure** | The behavior is right and the shape is wrong. The fix changes design without changing behavior.   | `restructure (\`/refactor\`)` |
| **by hand**     | The fix is a small local edit. No skill is worth spinning up for it.                              | `by hand`                     |

**The route is named, never started.** The review points at the route and stops. It does not invoke `/tdd`, `/refactor`,
or anything else on the reader's behalf, BECAUSE the reader decides what to act on and in what order, and a review that
starts fixing things stops being a review.

**Security findings carry no route** — see below. **YAGNI findings carry no route**, on the same grounds as the
explanation: they are not corrected unless somebody asks for them.

## Both cues reach the summary table

The report's only index is one summary row per finding, and every finding a reader must act on just got longer. Two
things travel up into that row, BECAUSE the complaint this content answers is comparative: a finding that will probably
never fire reads as a behavior change when it sits at the same visual weight as the two findings beside it, and a longer
finding body leaves that weight exactly where it was while adding reading load on top.

1. **The fix route**, in its own `Fix` column. Security rows show `—`.
2. **The may-never-fire cue**, opening the row's Description cell, on any finding the review established may not be
   reachable.

The same cue opens the finding's own body. When the honest answer to question 3 is that the finding may never fire, that
answer leads the explanation rather than trailing it, so a reader who opens the finding meets it first.

This changes what sits inside existing rows and nothing else. **No severity band changes, no row order changes, and no
finding identifier changes.** People work those identifiers as a queue across sessions, and the row order is
severity-ordered by design.

## Security findings

A SEC finding carries the explanation on the same terms as every other finding a reader must act on. Its exemption from
the Step 7.2 demotion gate is about the evidence bar the security agent already meets, not about what the reader needs.
A security finding is the one a non-implementer can least evaluate unaided, so it is the last one that should quietly
skip the explanation.

It does not gain a separately-labelled fix route. Its section already ends with a single Remediation note naming what to
do, and a second answer to the same question in one block is worse than either alone.

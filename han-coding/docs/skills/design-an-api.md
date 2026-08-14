# /design-an-api

Operator documentation for the `/design-an-api` skill in the han plugin. This document helps you decide _when_ and _how_
to use the skill. For what the skill does internally, read the skill definition at
[`han-coding/skills/design-an-api/SKILL.md`](../../skills/design-an-api/SKILL.md).

> See also: [Plugin README](../../README.md) · [Repo root](../../../README.md) ·
> [All skills](../../../docs/skills/README.md) · [All agents](../../../docs/agents/README.md) ·
> [YAGNI](../../../docs/yagni.md)

## TL;DR

- **What it does.** Designs the contract for an API change inside one codebase, running the design past a question round
  and an adversarial validation round before you commit to it.
- **When to use it.** You know what the capability should do, and you need to decide the shape of the interface that
  delivers it, sized for roughly one pull request.
- **What you get back.** A run folder holding a context brief, a design-options document, and the final design document
  that a `/tdd` run implements against.

## Key concepts

- **The stated goal.** One ticket, issue, or written requirement the whole design answers to. The skill will not run
  without one, because it is the only thing the design can be justified against.
- **The justification field.** Every parameter, field, type, default, precedence rule, and failure behavior names either
  the goal language it descends from or the asked-for behavior it is a necessity of.
- **The cut list.** Anything the interface could plausibly carry that the goal never asks for, recorded with what it
  would have done so you can put it back.
- **The two gates.** You pick the design option, and later you answer each open item one at a time. Everything else
  runs unattended.

## When to use it

**Invoke when:**

- A ticket asks for a capability and the real work is deciding the interface: a component's props, a function surface,
  URL or query parameters, an event payload, or a module boundary.
- You are about to change a shared surface and want the consumer audit and the failure behavior settled before anyone
  writes code.
- A branch already carries a half-built attempt and you want the contract redesigned from the merge base instead.

**Do not invoke for:**

- **Deciding what a feature should do.** Use [`/plan-a-feature`](../../../han-planning/docs/skills/plan-a-feature.md)
  instead; it settles behavior, this settles contract shape.
- **Planning how to deliver the work.** Use
  [`/plan-implementation`](../../../han-planning/docs/skills/plan-implementation.md) instead.
- **Judging the architecture already in the codebase.** Use
  [`/architectural-analysis`](./architectural-analysis.md) instead; it assesses what exists rather than designing what
  comes next.
- **Writing the code.** Use [`/tdd`](./tdd.md) to implement the design, or [`/refactor`](./refactor.md) to restructure
  existing code without changing its behavior.

## How to invoke it

Run `/design-an-api` in Claude Code.

Give it:

1. **The goal.** A ticket reference, issue URL, file path, or one paragraph describing what this change is for. A sharp
   goal names the user-visible outcome ("a link can prefill the first two steps of the signup flow"). A thin goal names
   only the mechanism ("add query param support"), which gives the justification field nothing to cite.
2. **The interface.** Which component, function, module, route, or payload is being designed, and where it lives. A new
   surface with no file yet is fine; name the module it will live in.
3. **A size, optionally.** `small`, `medium`, `large`, or `dynamic` as the first argument. Leave it off and the skill
   classifies from signals it detects in the interface and its consumers.

Example prompts:

- `/design-an-api`. _"Design the change to FlowProvider that lets URL query values prefill a flow's steps, per
  ticket ABC-142."_
- `/design-an-api medium https://github.com/acme/app/issues/88 the exported cache client surface in src/cache/`.

## What you get back

Three files in one run folder, placed under your configured `output-directory` or a folder named for the interface
under the project's documentation root:

- **`context-brief.md`.** Numbered findings `F1`, `F2`, `F3`, … from the discovery wave. Each finding carries a
  `file:line` citation or the label `inferred`, plus the agent that reported it. Conflicting findings stay as separate
  entries with both citations rather than being resolved silently.
- **`design-options.md`.** The two or three options the architect produced, with one recommendation, the rejected
  alternatives and why, and pseudocode sketches of each option's signatures.
- **`api-design.md`.** The deliverable. It holds the designed contract in three parts (surface, invariants, failure
  behavior), the justification table, the options considered, the questions resolved (`Q1`, `Q2`, … each with its
  answer's source), the validation findings (`V1`, `V2`, … each accepted or rejected), the cut list, and the open
  risks.

If any of the three files already exists in the folder, the run date-suffixes all three so one run's files stay
together, and tells you which names it wrote. It never overwrites.

## How to get the most out of it

- **Paste the ticket, do not paraphrase it.** The justification field quotes the goal. A paraphrase you wrote from
  memory becomes the scope authority, and it drifts.
- **Answer the open items with the consequence in mind.** Each one is surfaced with candidate answers and what changes
  in the contract; the answer you give becomes the recorded justification for those elements.
- **Read the cut list before you approve.** It is the only place the design tells you what it deliberately left out.
  Reinstating an entry is one sentence, and your direction becomes its justification.
- **Re-run larger when the closing summary names an omitted domain.** The band cap can drop a signalled specialist. The
  summary says which one.
- **Pair with `/tdd` next.** The design document is written to be the input to a test-first implementation run.

## Sizing

| Size                  | Typical target                                                                                                          | Roster                                |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| **Small** _(default)_ | One interface with a contained consumer set inside one module, and none of the cross-cutting signals                    | Spine only (4 agents)                 |
| **Medium**            | A consumer-spread signal, or exactly one ordering, data-contract, trust-boundary, failure-path, or boundary-data signal | Spine + up to 2 specialists (up to 6) |
| **Large**             | Two or more of those cross-cutting signals together, or a system-seam signal                                            | Spine + up to 4 specialists (up to 8) |

The four-agent spine runs at every size: `codebase-explorer`, `software-architect`, `junior-developer`, and
`adversarial-validator`. Specialists join only when their signal is present, so a band you set by hand can sit well
under its ceiling. When more specialists are signalled than the cap allows, the run keeps the band's count, prefers the
strongest signals, and names the omitted domains in the design document's summary so you can re-run larger. See
[Sizing](../../../docs/sizing.md) for the cross-skill model.

## YAGNI

This skill is enforcing, not advisory. An element that cannot fill its justification field does not enter the design at
all; it moves to the cut list with what it would have done and why it was cut. The cut list appears in the closing
message as well as the document, so a wrong cut is visible in the turn rather than buried in a file you have no reason
to open.

One floor bounds that discipline: silence never cuts a necessity. A goal that never mentions a caching layer justifies
cutting one, but the same goal's silence about invalid input, error behavior, and types cuts nothing, because those are
necessities of the surface it did ask for. See [YAGNI](../../../docs/yagni.md) for the shared evidence and
simpler-version gates this sits beside.

## Cost and latency

A small run dispatches four agents in sequence-with-one-parallel-wave: the discovery wave, then the architect, the
junior developer, and the adversarial validator. A large run adds as many as four signalled specialists to the discovery
wave, for up to eight agents total. Only signalled specialists are added, so a run at a size you set by hand can sit
under its band's ceiling. The architect is the most expensive single participant, because it runs up to four times: once
for options and once after each of the question round, the open items, and the validation round.

This is an infrequent, high-signal run. It sits before implementation, not inside a tight loop.

## In more detail

The skill exists because the arrangement it packages was already working by hand. A session documented in
[issue #173](https://github.com/testdouble/han/issues/173) dispatched `han-core:software-architect`,
`han-core:junior-developer`, and `han-core:adversarial-validator` directly, against a hand-assembled context brief, to
design a query-parameter prefill contract on a shared React flow provider. The designed API shipped essentially as
specified and survived a later code review. One junior-developer question reversed a naming decision before any code
existed.

What the skill adds to that arrangement is the discovery step the session assembled ad hoc, the size band that scales
the roster, and the two gates in fixed positions. What it deliberately does not add is the full analyst fan-out that
`/architectural-analysis` runs: that roster is built to assess an existing module across every dimension, and it is
oversized for shaping one contract.

## Related documentation

- [Plugin README](../../README.md). The plugin's front door: its skills, agents, and how they fit together.
- [Repo root README](../../../README.md). The Han suite landing page. Start here if you arrived from outside the docs
  tree.
- [`/pairing`](../../../han-core/docs/skills/pairing.md). Drive these rounds collaboratively, stopping after each one so
  you review it as it lands. Invoking `/design-an-api` directly runs the rounds to completion without pausing between
  them.
- [YAGNI](../../../docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule: the two gates, the
  acceptable-evidence list, the named anti-patterns, and the deferral format.
- [`/tdd`](./tdd.md). The implementation run this design document feeds.
- [`/architectural-analysis`](./architectural-analysis.md). Assesses the module you are about to change, when you want
  the existing structure judged before designing into it.

The four spine agents run at every size:

- [`codebase-explorer`](../../../han-core/docs/agents/codebase-explorer.md). Discovers the current surface, its
  consumers, and the constraints the design has to live inside.
- [`software-architect`](../../../han-core/docs/agents/software-architect.md). Produces the options and every
  amendment.
- [`junior-developer`](../../../han-core/docs/agents/junior-developer.md). Questions the chosen option as a generalist
  who was not in the room.
- [`adversarial-validator`](../../../han-core/docs/agents/adversarial-validator.md). Attacks the amended design and the
  evidence under it.

These specialists join the discovery wave when the interface shows their signal and the band allows:

- [`structural-analyst`](../../../han-core/docs/agents/structural-analyst.md). Added on a consumer-spread signal.
- [`behavioral-analyst`](../../../han-core/docs/agents/behavioral-analyst.md). Added on a boundary-data signal.
- [`concurrency-analyst`](../../../han-core/docs/agents/concurrency-analyst.md). Added on an ordering signal.
- [`data-engineer`](../../../han-core/docs/agents/data-engineer.md). Added on a data-contract signal.
- [`on-call-engineer`](../../../han-core/docs/agents/on-call-engineer.md). Added on a failure-path signal.
- [`adversarial-security-analyst`](../../../han-core/docs/agents/adversarial-security-analyst.md). Added on a
  trust-boundary signal.
- [`system-architect`](../../../han-core/docs/agents/system-architect.md). Added on a system-seam signal, at the large
  band only.

One more agent runs after the design document exists:

- [`readability-editor`](../../../han-communication/docs/agents/readability-editor.md). Audits and rewrites the
  finished document for the engineer who will implement the contract and the reviewer who will approve it.

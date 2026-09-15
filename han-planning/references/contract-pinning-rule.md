# Contract Pinning Rule (What a Contract Is, What Pinned Means, and Who Pins It)

## Contents

- What counts as a contract
- What counts as pinned
- Phrases that never close a contract
- Who pins it, stage by stage
- Related rules

**Owned by `han-planning`.** This file is authored here and is not a vendored copy of a shared rule. Do not overwrite it
from another plugin's `references/` folder during a re-sync sweep, and do not treat a difference between it and any
similarly-named file elsewhere as drift to correct.

When two components have to agree on a form and nobody wrote the form down, each one invents it. The component that
writes and the component that reads then drift apart quietly, and the drift surfaces as a bug long after both were
built. This file says which forms carry that risk, what it takes to settle one, and which stage of the planning chain
owns settling it.

The rule is binary on purpose. A contract is pinned or the plan is not finished. There is no deferred-with-reason
state, because an author who has one writes "the grammar depends on the serialization library, so it is TBD at build"
and passes the check while leaving the same hole.

Consumers: `plan-a-feature`, `plan-a-change`, `plan-implementation`, `plan-work-items`, and `iterative-plan-review`.

## What counts as a contract

A contract is any form two or more components must independently agree on. When one component produces it and another
consumes it, and neither can see the other's code at the moment it is written, the form is a contract.

These are contracts:

- A file or wire format, including the line-level grammar of anything appended to a log or ledger.
- A persisted schema: a table, a document shape, a serialized record.
- An API or event payload, in either direction.
- A module or CLI signature that another component calls.
- A configuration schema, including the keys and their accepted values.
- An error or exit contract: the codes, the statuses, and what each one means to a caller.
- An identity or naming convention that more than one component derives or parses.

The common thread is independent agreement, not formality. A grammar for one internal function that one file calls is
not a contract. The same grammar becomes one the moment a second component parses it.

## What counts as pinned

Pinned means an implementer can build against the form without inventing any part of it.

A contract is pinned when the plan carries one of these:

- A literal worked example: an actual line, an actual payload, an actual row.
- A grammar line stating the syntax, with its variable parts named.
- A field layout naming each field, its type, and its order or key.
- A link to an artifact that already exists concretely, at a path that resolves today.

None of these count as pinned:

- A list of field names with no layout, syntax, or example.
- A prose description of what the form conveys.
- A name for a document that does not exist yet, however precisely the document is described.
- An entry type list with no statement of how an entry is written.

The distinction that matters is the one the incident behind this rule turned on. Naming the five entry types a ledger
carries is a description. Showing one written line is a pin.

Pinning a contract does not mean inlining a file. The planning altitude rule already treats a decision-bearing value
such as a key name, a flag default, or a threshold as belonging in the plan, and a format grammar is the same class of
value: one line, not a file block. A contract that genuinely needs more than a paragraph goes in its own artifact and
the plan links it, which is why an existing concrete artifact counts as a pin.

## Phrases that never close a contract

A contract item stays open when its resolution reads as any of these, whatever else the entry says:

- "authored during the build"
- "TBD at build"
- "authored later"
- "defined during implementation"
- "to be authored"
- a `Resolves when:` value that restates its own question rather than naming a falsifiable condition

Each one names a future author rather than a form. They are listed here so a skill can check for them mechanically
rather than judging tone, and so the check and the rule never disagree about the list.

## Who pins it, stage by stage

Each stage has one duty. The duties are additive: a stage doing its own does not excuse the next one.

- **`plan-a-feature` records the delegation.** A pure-implementation mechanic that is a contract becomes an Open Item
  naming what is delegated and to which stage, rather than being dropped as implementation detail.
- **`plan-implementation` pins it.** The decision that resolves a contract carries the concrete form inline, or links
  an artifact that already exists concretely.
- **`plan-work-items` keeps it whole.** A contract more than one work item touches is pinned in the item that
  introduces it, ahead of every consumer, and the consumers depend on that item.
- **`iterative-plan-review` backstops it.** An un-pinned contract in a plan under review is a major finding.

`plan-implementation` is the primary owner because it is the one stage whose job is resolving what the specification
deliberately left open. A stage upstream of it cannot pin a contract without inventing behavior, and a stage downstream
of it cannot invent a form the plan never carried.

## Related rules

- [`planning-boundary-rule.md`](./planning-boundary-rule.md), for the boundary record a contract decision fits inside.
- [`scope-justification-rule.md`](./scope-justification-rule.md), for the cut list a contract-bearing unit goes to when
  it cannot name what it descends from.
- [`operator-escalation-rule.md`](./operator-escalation-rule.md), for the plain language an escalation about an
  un-pinned contract borrows.
- `yagni-rule.md`, for the evidence test. Pinning a contract the plan already commits to is not new scope; introducing
  a contract nothing needs is, and the evidence test governs that.

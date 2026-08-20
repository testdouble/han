# Planning Boundary Rule (Scope Boundary and Visual Material)

## Contents

- The boundary record
- Visual material
- Related rules

**Owned by `han-planning`.** This file is authored here and is not a vendored copy of a shared rule. Do not overwrite it
from another plugin's `references/` folder during a re-sync sweep, and do not treat a difference between it and any
similarly-named file elsewhere as drift to correct.

Every planning run descends from something: a ticket, an issue, a pull request, or a written request the operator typed.
That thing is the outer boundary of the run, and this file says how you record it and how you keep the visual material
that arrives with it. Two rules that look separate live here together because one gate spans both: you note each piece
of visual material into the boundary record as it arrives, and the completeness gate reads that record back against the
folder on disk.

Consumers: `plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, and `plan-work-items`.

## The boundary record

### Where it lives, under one name

Write the record to `artifacts/scope-boundary.md` inside the resolved plan folder. Every planning skill uses that same
path, so a later skill in the chain reads it instead of asking the operator again.

The name is not dot-prefixed on purpose. The record is content the operator reads: you restate it back to them in the
confirmation turn, and downstream skills cite it. That makes it unlike the internal run notes a skill keeps for itself.

### What "beside the plan" resolves to

"Beside the plan" means the folder the skill resolves for its own primary deliverable. Each skill already has a rule for
choosing that folder, and this rule adds nothing to it: whatever folder your deliverable lands in is the folder that
gets the `artifacts/scope-boundary.md` and the `ui-designs/` beside it.

That matters most in `plan-work-items`, which can run on its own against a plan in one folder while writing its own
`work-items.md` somewhere else. When the two differ:

1. Read any existing record from the input plan's folder, and treat it as the recorded boundary rather than establishing
   a new one.
2. Write your own record beside your own deliverable, and name the path you inherited it from in the Record Provenance
   section.

Reading from one place and writing to the other is what keeps a reader of your deliverable able to find the boundary it
was built against. Naming the source is what keeps two records from disagreeing silently.

### The sections the record carries

The record has named sections, because four separate mechanics read it back. The confirmation turn restates it, the
completeness gate iterates the visual items it lists, `plan-work-items` reads it in place of re-asking, and the conflict
rule compares an incoming work item against it. A freeform paragraph leaves the gate nothing to iterate.

Write every section, every time. A section with nothing in it says so in words rather than being left out, because an
absent section and an empty one are different states and only one of them is a recorded finding.

```markdown
# Scope Boundary: {plan or feature name}

## Work Item

The item this work descends from, and how you reached it: a file path, a URL, text the operator pasted, or the statement
that no work item exists and the operator's request is the only boundary this run has.

## Stated Scope

What the work item asks for, quoted word for word. When the boundary is the operator's own request, quote what they
said.

## Stated Exclusions

What the work item rules out, quoted word for word, or `None stated`.

## Operator-Stated Scope

Scope the operator stated out loud when invoking the skill, quoted, or `None`. This is a boundary statement in its own
right, the same as the work item's text.

## Direction of Travel

The operator's answer about whether the things the work item named are being deprecated, replaced, or migrated away
from. One of: the answer they gave, `Not known` when they said they do not know, or `Unanswered` when they did not
answer. Those three are different states. A recorded answer of any kind is never re-asked by a later skill.

## Visual Material Received

One row per piece of visual material, written as the item arrives rather than at the end of the run. `None received`
when the run received none. In that case `None received` stands alone and the table below is omitted, because the
completeness gate reads every row as an item claimed on disk and refuses a placeholder row.

| Item | What state it depicts | Kept at |
| ---- | --------------------- | ------- |
| card-empty-state.png | The card before any entry exists | `ui-designs/card-empty-state.png` |
| Figma board | Every state of the card, as a URL | (not a file) https://figma.com/... |

## Record Provenance

Which skill established this record, and the path it was inherited from when it was inherited rather than established
here.
```

### When you find no record

Establish the boundary yourself, exactly as the first step describes, and write the record. Do not proceed unbounded,
and do not read an absent record as a recorded statement that no work item exists. Those are two different situations:
one is a folder that predates this convention or a skill invoked on its own, and the other is a finding you wrote down
on purpose.

This is the most likely state you will meet, because a skill gets invoked against folders written by hand and by
earlier versions of its siblings. It is also what makes a partly-adopted repository safe.

### When you are handed a work item that conflicts with the record

Surface the conflict in your confirmation turn and ask which one governs. Do not silently overwrite the record, and do
not silently trust it. Record the answer, and name in the Record Provenance section that a conflict was resolved and
which way.

### The read does not traverse outward

Read the item itself. Read a parent only far enough to confirm it exists and note its name. A linked item, a sibling, or
a closed item is not scope evidence for the item in hand, and its description is not evidence about the current item's
platform, status, or intent.

You will often be recording the operator's own words rather than the work item's verbatim text, because these skills
have no tool that reads a tracker. That is expected. Record what you were given and say which it was.

## Visual material

### Persist it when it arrives

Write every piece of visual material the operator supplies into a `ui-designs/` folder beside the plan as soon as it
arrives. Not when you write the document. The session context is the only copy until you do, and "later" does not
survive a compaction or a session boundary.

Name each file for the state it depicts, so a reader who never saw the conversation can tell the files apart.
`card-empty-state.png` earns its place; `image-2.png` does not.

Note each item into the boundary record's Visual Material Received section as you keep it. That record, not your memory
of the run, is what the completeness gate reads.

### The accepted file set

These file types count as visual material:

- Raster images: `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`
- Vector images: `.svg`
- Mockup and design documents: `.pdf`

This is the set every consumer honors. Where another file in this repository restricts itself to one extension, it cites
this list instead of restating an extension of its own.

A URL is not a file and cannot be copied. A Figma board, a hosted prototype, or any other link the operator supplies is
recorded as a row in the boundary record with the URL in place of a kept path, and cited by URL wherever a kept file
would be cited by path. Do not fetch it, and do not report it as kept on disk.

### When you cannot keep it

Sometimes the host never made a supplied item reachable as a file, so there is nothing to copy. That is a different
situation from having no material at all, and it is recoverable while the operator is still in the conversation. Name
which items you could not keep and ask for them through the single stop in
[`operator-escalation-rule.md`](./operator-escalation-rule.md), while they can still be supplied.

### The completeness gate

Before you declare your artifact finished, confirm that every item the boundary record lists as received exists on disk
beside the plan.

Read the record, not your memory. A gate reading what the run remembers passes vacuously after a compaction, because
the run no longer remembers receiving anything. Reading the record also catches partial loss, where five items were
received and three were saved.

### How the material is cited

Producer and consumer share these three strings exactly. Writing a different one breaks the handoff.

- The folder is `ui-designs/`, beside the plan.
- The reference table's heading is `Visual Reference`. It lists every item and the state it shows.
- An inline embed takes the form `![alt text](ui-designs/card-empty-state.png)`, placed beside the prose describing the
  state it depicts.

The inline placement is not decoration. The downstream inventory maps an image to a work item by reading the prose the
embed sits next to, so an embed with no surrounding description of the state gives the consumer nothing to map.

## Related rules

- [`scope-justification-rule.md`](./scope-justification-rule.md), for the justification field, the cut list, and the
  scope gate that reads this boundary.
- [`operator-escalation-rule.md`](./operator-escalation-rule.md), for the confirmation turn's shape, the single stop,
  and how questions reach the operator.

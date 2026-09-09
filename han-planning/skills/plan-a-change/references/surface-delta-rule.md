# Surface Delta Rule

## Contents

- What counts as a surface element
- The five delta verbs
- Every entry carries a target-state statement
- Migration guidance is additional, never a substitute
- The entry format
- Common failures

The surface delta is the part of the plan that answers **what is changing**. It is a record of the target state, element
by element. A reader who knows nothing about the current code can read the delta and describe the code that will exist
after the change.

That is a different question from **how do I update my call sites**, which a migration table answers. Both are useful.
Only the first is what the delta is for, and a plan that carries only the second leaves the target state unstated for
every element it touches.

## What counts as a surface element

An element belongs in the delta when something outside its own body depends on it by name. That test covers:

- A module, package, or file that other code imports.
- A class, type, struct, interface, protocol, or trait other code names.
- A public method, function, or property other code calls.
- A constructor or factory, and the shape of what it takes.
- An exported constant, enum member, or error type.
- A configuration key, environment variable, or CLI flag the code reads.
- A persisted format, a wire payload, or a schema the code writes or reads.

An element does not belong in the delta when its every user lives inside the same unit that changes. A private helper
that moves along with the type that owns it is part of one entry, not an entry of its own.

The boundary of "outside" is set by the area recorded in Step 1. When a change stays inside one module, the module's own
public surface is the outside boundary and its internals are not. When a change splits a module in two, what crosses the
new seam becomes surface that did not exist before, so it enters the delta as an addition even though no caller outside
the module can see it. A seam nobody wrote down is a seam invented during the build.

## The five delta verbs

Every entry takes exactly one verb. When two seem to apply, the element is really two entries or the wrong altitude.

| Verb          | What it means                                                                |
| ------------- | ---------------------------------------------------------------------------- |
| **Removed**   | The element exists today and does not exist after the change.                |
| **Added**     | The element does not exist today and exists after the change.                |
| **Moved**     | The element keeps its identity and responsibility, and changes its home.     |
| **Renamed**   | The element keeps its identity and home, and changes its name.               |
| **Re-scoped** | The element keeps its name and home, and changes what it is responsible for. |

Two clarifications the verbs are routinely stretched past:

- **A rename plus a move is two entries, or one Moved entry naming both.** Pick one and be consistent across the plan.
  Splitting them is the safer default, because a reader searching for the old name finds the rename.
- **Re-scoped is the verb that carries a responsibility shift.** It is the most common verb in an architecture-driven
  change and the easiest to under-report, because the type's declaration often barely changes while what it is
  answerable for changes completely. When a type keeps its name and loses half its job, that is a Re-scoped entry, not
  silence.

## Every entry carries a target-state statement

**Each entry states what is true after the change, in its own right, without reference to what a reader should do about
it.** This is the rule the whole file exists for.

The statement is written so it would still be correct and complete if every other entry were deleted. It names the
element, and it names where the responsibility sits afterwards.

- **Removed.** "`LegacyPromptReader` does not exist. Reading a prompt from the terminal is `TerminalChannel`'s
  responsibility." A removal whose responsibility genuinely goes away says so and says why: "`retryCount` does not
  exist; the caller no longer retries, because the transport does."
- **Added.** "`TerminalChannel` exists and owns reading a prompt from the terminal. It takes a `Device` and returns a
  `Response`."
- **Moved.** "`resolveDestination` is on `Channel` rather than `Session`, and does the same thing it did before."
- **Renamed.** "`Response` is the name; the type formerly called `Result` is unchanged in every other respect."
- **Re-scoped.** "`Session` owns the lifecycle of a connection and nothing else. Destination resolution and prompt
  reading are no longer its responsibility."

A removal with no target-state statement is the specific failure this rule was written to stop. The responsibility went
somewhere, or it went away on purpose; an entry that says neither leaves the reader unable to tell which.

## Migration guidance is additional, never a substitute

An entry may carry a `Migration:` line telling a caller what to write instead. That line is a convenience. It does not
discharge the target-state statement, and a table of "write this instead of that" is not a delta.

The distinction is not stylistic. Migration guidance is written from the call site inward, so it describes only the
elements that happen to have call sites, in only the respects a caller notices. A responsibility that moves between two
internal collaborators produces no migration row at all, and disappears entirely from a document built that way.

## The entry format

```markdown
### S-4: `Session.resolveDestination` — Moved

**Target state.** `resolveDestination` is a method on `Channel`. It takes the same arguments and returns the same
`Destination` it does today.

**Behavior.** Preserving. Every caller receives the same value for the same input; only the receiver changes.

**Why.** `Session` owned destination resolution only because it held the config reference. `Channel` holds it after
S-2, so the coupling that justified the placement is gone.

**Depends on.** S-2.

**Migration.** Call `channel.resolveDestination(...)` where you called `session.resolveDestination(...)`.

**Decision.** [D-6](change-decision-log.md#d-6-destination-resolution-owner)
```

`Target state`, `Behavior`, `Why`, and `Decision` are required on every entry. `Depends on` appears when the entry has
an ordering constraint. `Migration` appears when a caller outside the area has to change.

`Behavior` carries the Step 6 classification verbatim: `Preserving`, `Changing`, or `Unknown`. A `Changing` or `Unknown`
entry names the escalation that settled it.

## Common failures

| Failure                                            | Why it costs the reader                                                                     |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| A removal with only a migration row                | The reader learns what to write instead, and never learns where the responsibility went     |
| A migration table standing in for the whole delta  | Elements with no call sites vanish from the record entirely                                 |
| Re-scoped entries reported as unchanged            | The declaration barely moves, so the responsibility shift goes unrecorded and gets rebuilt  |
| Two verbs on one entry                             | The reader cannot tell which fact is the commitment                                         |
| A target-state statement written as an instruction | "Move the method to `Channel`" describes the work, not the code that exists when it is done |
| A new internal seam left out                       | The contract across it gets invented during the build, differently on each side             |

Cross-references:

- [contract-pinning-rule.md](../../../references/contract-pinning-rule.md) — what counts as a contract two parts must
  agree on, and what counts as pinning one. A new seam in the delta usually creates one.
- [scope-justification-rule.md](../../../references/scope-justification-rule.md) — the cut list an out-of-boundary entry
  lands in instead of the delta.

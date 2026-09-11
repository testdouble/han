# Synthesis Failure Rule (Confirming the Plan Landed)

## Contents

- Why the caller owns this check
- The check
- What the stop says
- Related rules

**Owned by `han-planning`.** This file is authored here and is not a vendored copy of a shared rule. Do not overwrite it
from another plugin's `references/` folder during a re-sync sweep, and do not treat a difference between it and any
similarly-named file elsewhere as drift to correct.

Consumers: `plan-implementation` and `plan-a-feature`, the two skills that dispatch `han-core:plan-synthesizer` to write
files.

## Why the caller owns this check

A dispatched agent is a subprocess with its own session budget, and it can terminate part-way through a multi-file
write. That is not hypothetical: it happened, and the run finished anyway, dispatching the readability editor against a
plan that was never written and summarizing a document nobody confirmed existed.

The check belongs to the caller rather than to the agent, because the caller owns the artifact set and the agent does
not know what that set is. `plan-synthesizer` has four callers and two of them ask it to write no files at all, so a
completion report from the agent would be undefined for half of them.

## The check

After the synthesizer returns, and before any later step reads the plan, confirm the plan file exists and holds
content:

```
find {folder} -maxdepth 1 -name {plan filename} -size +1k
```

The size predicate is not decoration. `find` exits `0` whether or not it matches, so an existence test with no size
test puts the verdict in stdout rather than in the exit status, and a plan file created and then abandoned at zero
bytes would pass.

A match means the synthesis produced its primary artifact; continue. No match means it did not; stop.

## What the stop says

The stop message is the entire operator-facing output of a halted run, so it names three things: what did not happen,
what is on disk, and what to do next.

```
Synthesis did not produce {plan path}.
On disk: {the artifacts that did land, by name}.
To recover: re-run this skill and answer the Step 1 prompt with overwrite. The artifacts above stay
readable in artifacts/ until you do.
```

Do not run the readability pass, and do not summarize the run as though it produced a plan. A run that stops here has
done real work whose record survives in `artifacts/`, and saying so is what makes the stop recoverable rather than
merely blocking.

## Related rules

- [`contract-pinning-rule.md`](./contract-pinning-rule.md), for why the command and the message are pinned here rather
  than described in each consuming skill.
- [`operator-escalation-rule.md`](./operator-escalation-rule.md), for the shape of what a stop says to a person.

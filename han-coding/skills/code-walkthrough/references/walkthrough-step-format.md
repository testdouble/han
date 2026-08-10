# Walkthrough Step Format

This file carries two things the walkthrough needs: how to order the itinerary, and how to render a single step. The
skill's `SKILL.md` owns the process; this file owns the shape of what the learner sees.

## Ordering the Itinerary

Order stops by the path the code actually executes, not by the order files appear in a diff, not alphabetically, and not
by layer.

1. **Start where control enters.** The entry point is where a request, command, event, or user action first reaches the
   changed code — a route handler, a CLI command, a message consumer, an exported function another package calls, a
   slash command's first instruction. When a change has no runtime entry point (a pure data or configuration change),
   start at the thing that reads it.
2. **Follow one hop per step.** Each subsequent step is the next place control or data goes. A step earns its place when
   the behavior turns there: a branch, a transformation, a dispatch, a boundary crossing, a persisted write.
3. **Fold pass-through hops into their neighbors.** A file that only forwards a call to the next one is not a stop; name
   it inside the step it forwards into.
4. **Keep each step to one idea.** If a step needs two paragraphs to explain because two unrelated things changed in one
   file, split it into two steps against the same file.
5. **Put the off-flow files in the closing step.** Tests, documentation, index entries, configuration, lockfiles, and
   mechanical renames get one line each at the end, never a step of their own.

When two changed files sit at the same depth with no ordering between them, walk the one whose behavior the other
depends on first.

## Anatomy of One Step

Every step renders these four parts, in this order.

### 1. The heading: position and full path

```markdown
### Step 2 of 6 — `han-coding/skills/code-review/SKILL.md`
```

The path is always **repository-root-relative and complete**. Never a bare filename, never a fragment, never a path
relative to some other directory. A learner reading `SKILL.md` cannot find the file; a learner reading
`han-coding/skills/code-review/SKILL.md` can open it in one move.

When a step targets a specific symbol, name it after the path: `` `src/billing/invoice.ts` — `applyProration()` ``.

### 2. The explanation: why first, then what

A short paragraph — usually two to four sentences — that leads with the problem being solved or the goal being served,
then says what the code does about it. Written for someone who did not do this work and does not yet know the codebase.

Say what changed in terms of behavior a person could observe, not in terms of the mechanism. Where an outside
technology, a runtime, or a term coined inside this codebase has to appear, explain it in half a sentence at first use.

### 3. The excerpt: the smallest chunk that carries the point

A few lines up to roughly thirty. For a change, prefer a diff excerpt so the before and after are both visible. For
existing code, a plain fenced excerpt.

Trim aggressively. Cut imports, boilerplate, unrelated lines, and untouched context that does not help. Replace elided
regions with a comment marker rather than pasting them. The excerpt illustrates the sentence above it; it is not the
evidence for it.

### 4. The handoff: one line naming what is next

One line that says what the next step covers, then invites either an advance or a question. It ends the turn.

## Worked Example

````markdown
### Step 2 of 6 — `han-coding/skills/code-review/SKILL.md`

A review used to pick its specialists from the file types in the diff, so a change to a retry loop got a style
reviewer and nobody who thinks about what happens when the retry never succeeds. This step is where that choice is
made, and it now reads what the code does rather than what kind of file it lives in.

```diff
- Select agents by the file extensions present in the diff.
+ Select agents by what the changed code does. When the diff touches
+ a retry, timeout, or queue path, dispatch han-core:on-call-engineer.
```

Next: where that dispatch list is actually built and handed to the agents. Say **next**, or ask me anything about this
step.
````

## What a Step Never Does

- **Never judges the code.** No findings, no severities, no "this should have been extracted". Navigational notes are
  fine: "this is the part that is hard to follow, and here is why" teaches; "this is badly factored" grades.
- **Never states diff statistics.** No lines changed, files changed, or commit counts. They go stale immediately and
  teach nothing.
- **Never pastes a whole file.** If a step seems to need one, the step is really two or three steps.
- **Never claims a flow it did not read.** An unverified hop is an invented one. Where the order or the reason is
  inferred rather than found in the code, its commits, or its tests, say that it is inferred.

---
name: code-walkthrough
description: >
  Walks a person through code changes one step at a time in conversation, starting at the entry point and following the
  flow that changes, showing a small chunk per step and explaining it in plain language. Defaults to the current
  branch's changes, and walks the code from the perspective of any context provided instead — a file, directory,
  symbol, pull request, plan, or ticket. Use when someone wants to be walked through, taught, paced through, or shown
  around code or a branch step by step, or to learn how a change works before reviewing or extending it. Stops after
  every step and waits, so the learner sets the pace. Paces through code that already exists and builds nothing — to
  build new work while being paced through it, use pairing. Does not produce a written overview to read alone — use
  code-overview. Does not review code quality — use code-review. Does not diagnose bugs — use investigate.
arguments: size
argument-hint:
  "[size: small | medium | large | dynamic] [target: a file, directory, symbol, PR reference, or plan — defaults to the
  current branch's changes]"
allowed-tools:
  Read, Glob, Grep, Agent, Bash(git *), Bash(gh *), Bash(find *),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- git installed: !`which git 2>/dev/null || echo "not installed"`
- gh installed: !`which gh 2>/dev/null || echo "not installed"`
- current branch: !`git branch --show-current 2>/dev/null || echo "no git branch"`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown`
- repository root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## Operating Principles

Read these before doing anything. They constrain every step below.

- **One step per turn, then stop and wait.** Present exactly one walkthrough step, then end the turn. Never chain two
  steps together, never run ahead to finish the itinerary, and never treat a short acknowledgement as permission to
  batch. BECAUSE the pacing _is_ the deliverable: a learner who receives six steps at once is reading a document, which
  is `code-overview`'s job, and the understanding this skill exists to build comes from stopping long enough to ask a
  question. The single exception is an explicit request for more than one step ("show me the rest", "give me the next
  three"), which you honor as asked.
- **A question holds your place; it never advances it.** When the learner asks about the step just presented instead of
  moving on, answer at the same plain-language level, then re-offer the same next step. The step counter does not move.
  BECAUSE the question is the learning happening, and advancing past it silently abandons the reason they asked.
- **Every step names the full path from the repository root.** Each step's heading carries the complete
  repository-root-relative path (`han-coding/skills/code-review/SKILL.md`), never a bare filename (`SKILL.md`) and never
  a path fragment. BECAUSE a bare filename is unsearchable and ambiguous in any repository with a `SKILL.md`, an
  `index.ts`, or a `README.md` in more than one directory, and the learner's next move is reliably to open the file
  themselves.
- **Small chunks, always.** Each step shows a few lines up to roughly thirty — the smallest excerpt that carries the
  point — never a whole file and never an entire diff hunk pasted for completeness. BECAUSE the excerpt is an
  illustration of the sentence you just wrote, not the evidence for it; a wall of code moves the reading work back onto
  the person the walkthrough is supposed to be teaching.
- **Plain language, and the why before the what.** Explain each step as a problem being solved or a goal being served,
  then what the code does about it. Keep the explanation to a short paragraph a person could read aloud. Source the
  standard by invoking `han-communication:explanation-guidance` (Step 3) and hold it for every turn of the session.
- **Follow the flow, then name the rest.** The itinerary follows the execution path from the entry point through the
  change. Files off that path — tests, docs, index entries, config, mechanical renames — are named together in the
  closing step with one line each on why they changed. BECAUSE a flow the learner can follow is worth more than
  file-by-file completeness, and silently dropping a changed migration or test file is the gap that bites them later.
- **Teaching, never judging.** The walkthrough raises no findings, no severities, and no recommended changes, and it
  never grades the code it is explaining. BECAUSE judging the change is `code-review`'s job, and a learner who cannot
  yet follow the flow has no basis to evaluate a critique of it. Saying "this is the part people find confusing" as
  navigation is fine; saying "this should have been extracted" is not.
- **Accurate to the code, always.** Every claim — the entry point, the order of the flow, what each chunk does, why it
  changed — must be grounded in code you actually read. Never infer a step you did not verify, and never invent a
  rationale the evidence does not support; where the why is inferred rather than stated anywhere, say it is inferred.
  BECAUSE a confidently wrong walkthrough builds a mental model the learner will trust and act on for months.
- **Read-only, and writes nothing.** The skill explains; it never edits the target and never writes a file. The
  conversation is the whole deliverable. BECAUSE a durable written artifact is `code-overview`'s output, and the absence
  of one here is what keeps the two skills distinct.
- **Default to small.** Start size classification at small and escalate only on a clear signal. BECAUSE under-dispatching
  is recoverable by exploring more mid-walk, while over-dispatching burns the context this session needs to survive
  across many turns.
- **The step format lives at [references/walkthrough-step-format.md](./references/walkthrough-step-format.md).** Render
  that format; do not invent a structure inline.

# Walk Someone Through Code

## Step 1: Resolve the Scope

**Bind `$size`.** If the first positional argument is `small`, `medium`, `large`, or `dynamic`, bind `$size` to it.
Anything else is part of the target, not a size; bind `$size` to the literal `none provided`.

**Note tool availability.** Read `git installed` and `gh installed` from Project Context. If `git installed` is empty or
reads `not installed`, git is unavailable — see the degraded paths below.

**Resolve the target by this fixed precedence**, so an ambiguous string never silently selects the wrong scope:

1. **No target given** → the current branch's changes against the default branch. This is the default and the most
   common invocation. It needs git, not a remote pull request.
2. **A pull request reference or URL** (`#82`, `https://github.com/owner/repo/pull/82`) → that pull request's changes.
   Requires `gh`.
3. **An existing file or directory path** (confirm it resolves with Glob or find) → that code, walked as it stands
   rather than as a change.
4. **A symbol** (a function, class, type, or other named entity) → that symbol, resolved with Grep across the
   repository.
5. **Any other context** — a plan file, a ticket, a described capability, a conversation above — → walk the code from
   that context's perspective, covering the code that context concerns and ordering the walk by what that context cares
   about.

**Handle the unresolvable and empty cases** (state the problem plainly and stop; never guess):

- No target given and the working tree is clean with no branch changes → say the branch has no changes to walk and ask
  for a target.
- No target given and git is unavailable → say the branch default needs git, and ask for a file, directory, or symbol,
  which still works without it.
- A pull request reference with `gh` unavailable or unreachable → say so and offer a local target instead.
- A path or symbol that resolves to nothing, or a symbol ambiguous across several definitions → report exactly what
  could not be resolved and ask the learner to disambiguate.

**Resolve project context.** If `CLAUDE.md` is present, read its `## Project Discovery` section for conventions; fall
back to `project-discovery.md`. These settle language and framework questions so the explorers infer less. If neither
exists, note that surrounding-code inference applies and pass that into the briefs.

## Step 2: Classify Size and Trace the Flow

**Classify the target's size. Default to small**, and stay at the smaller band when a signal is borderline.

- **Small** _(default)_ — one file, one symbol, or a change touching a few files in one subsystem.
- **Medium** — a directory or module, or a change across one or two adjacent subsystems.
- **Large** — several subsystems, or a change spanning many files across them.

**Apply the size override.** If `$size` is not `none provided`, use it: a band value is the band and skips the
signal-based classification, while `dynamic` forces the signal-based classification even when the project config sets a
default band. If `$size` is `none provided` and the project config supplies a band via `default-swarm-size` (per
[../../references/config-rule.md](../../references/config-rule.md)), use that band and name the config as the source in
Step 3's announcement. A conversational override ("walk me through it in detail") is equivalent.

**Gather the input.** For a branch or pull request, capture the change set and its intent:

- **Current branch**: determine the default branch from Project Context (`default branch`), falling back to `main` or
  `master`. Capture `git diff {default-branch}...HEAD` for committed work, then `git diff` and `git diff --cached` for
  uncommitted work, each as its own Bash command so a large diff streams incrementally. Capture
  `git log {default-branch}..HEAD --pretty=format:%B` for intent. When `gh` is available, also run
  `gh pr view --json title,body` to pick up the change's stated purpose; if no pull request exists for the branch, skip
  this without failing.
- **A named pull request**: run `gh pr view {ref} --json title,body` for intent and `gh pr diff {ref}` for the change
  set.
- **A file, directory, symbol, or other context**: read the target and enough of its neighbors to know its boundary —
  what it imports and what imports it.

**Dispatch `han-core:codebase-explorer` to trace the flow.** Scale the count to the band and launch every agent in a
single message so they run concurrently:

- **Small** — one explorer over the target or the changed files.
- **Medium** — two or three explorers, each over a coherent slice.
- **Large** — three to five explorers, each scoped to one subsystem or one area of the change.

Each brief must contain the resolved target (and, for a change, the changed-file set and the captured intent), the
project conventions from Step 1 or a note that surrounding-code inference applies, and the instruction to report **where
the flow starts and the order it runs in** — the entry point a request, command, or event actually arrives at, each
subsequent hop, and which changed files sit on that path versus off it — as concrete findings citing
**repository-root-relative paths**. Instruct each explorer to report what it found and **not to assess quality**, and to
say so plainly where the entry point or the why is not recoverable rather than inferring one.

Wait for the whole wave before building the itinerary. Dispatching to trace the flow rather than reading everything
inline keeps the main context lean, which matters here BECAUSE this session runs across many turns and a context
exhausted at step 2 cannot finish the walk.

## Step 3: Build the Itinerary and Announce It

Invoke `han-communication:explanation-guidance` to surface Han's standard for explaining technical work to a reader who
will not implement it. It runs inline and hands control straight back. That standard governs every turn of this session,
BECAUSE every turn goes to a person who is trying to learn the code rather than write it.

**Order the itinerary by the flow, starting at the entry point.** Read
[references/walkthrough-step-format.md](./references/walkthrough-step-format.md) and apply its ordering rules. Each step
is one stop on the execution path, identified by its full repository-root-relative path and the one idea it teaches.
Bound the length to the band: roughly three to five steps at small, five to eight at medium, and eight to twelve at
large. Where the flow is longer than the band allows, keep the stops where the change's behavior actually turns and fold
the pass-through hops into the neighboring step.

**Reserve the closing step for everything off the flow** — tests, documentation, index entries, configuration,
mechanical renames — with one line each on why it changed. Every changed file lands either on the flow or in that
closing step; none is dropped.

**Announce the walk in one short turn, then present step 1 in that same turn.** The announcement states what is being
walked, the size band and why, and the number of steps ahead — for example,
`Walking the current branch, size medium: 6 steps following a review request from the slash command through agent
dispatch.` Name tool degradation in the same line when it applies, and name the config when it supplied the band. Do NOT
stop for approval here: this skill is read-only and re-runnable, so a gate on a reversible operation only trains the
learner to approve without reading. Honor any adjustment they make.

## Step 4: Walk One Step Per Turn

This is the loop the whole skill exists for. Repeat it until the itinerary is done.

1. **Present exactly one step**, rendered per
   [references/walkthrough-step-format.md](./references/walkthrough-step-format.md): the position and the full
   repository-root-relative path, a short plain-language explanation leading with why, a small code or diff excerpt, and
   a one-line handoff naming what the next step covers and inviting a question.
2. **End the turn.** Wait for the learner. Do not continue, do not summarize what is coming, and do not present the next
   step in the same turn.
3. **Read what comes back and route it:**
   - An advance (`next`, `continue`, `go on`) → present the next step.
   - A request to go deeper → read more of the current file or its neighbors and expand on the current step, still as
     one step, then re-offer the next one.
   - A request to skip, jump to a named file, or go back → move the position there, say in one line where you moved to,
     and continue from there.
   - A request for several steps or the rest of the walk → honor it as asked; this is the one case where more than one
     step goes out in a turn.
   - A request to stop → stop, and say where in the itinerary they stopped so they can resume later.
   - **Anything else is a question, and a question never advances the walk.** Answer it at the same plain-language
     level, then re-offer the same next step with the counter unmoved. This is the case to get right: the instinct is to
     answer and roll straight into the next step, which silently spends the stop the learner just used to ask.
4. **Revise the itinerary when the code contradicts it.** If tracing reveals the flow goes somewhere the plan did not
   predict, change the remaining steps, say so in one line, and carry on. NEVER walk a step you now know is wrong just
   because it was in the plan.

If a step's file cannot be read or a symbol no longer resolves, say exactly what failed, skip that step, and continue
the walk. NEVER abandon the session over one unreadable file, BECAUSE the learner keeps the value of every step already
walked and every step still ahead.

## Step 5: Close the Walk

After the last flow step, present the closing turn:

1. **The off-flow changes**, as the itinerary reserved them: each remaining changed file by its full
   repository-root-relative path, with one line on why it changed. Omit this entirely when the walk was not of a change
   set, or when every changed file sat on the flow.
2. **A short recap** — three or four plain sentences tying the steps back together into what the change does and why it
   exists. Carry no file paths, no type names, and no symbol names in these sentences, and write them under the
   explanation standard sourced in Step 3, BECAUSE the learner's reliable next move is to repeat this summary to someone
   else in their own words.
3. **One line on where to go next**, naming the sibling skill that fits what they said they wanted the understanding
   for: `code-review` to audit the change, `code-overview` for a written document they can keep or share, `investigate`
   to chase a bug they spotted. Recommend nothing about the code itself.

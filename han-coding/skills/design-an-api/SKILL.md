---
name: design-an-api
description: >
  Designs the contract for an API change inside one codebase — a component's props, a function surface, URL or query
  parameters, an event payload, or a module boundary — through a discovery pass, an options document with one
  recommendation, a question round, and an adversarial validation round, with every element of the contract justified
  from one stated goal. Use when you want to design, shape, decide, or nail down an interface, contract, signature, or
  API change for a capability you can already describe, sized for roughly one pull request. Produces a design document
  and changes no code. Does not specify what a feature should do — use plan-a-feature. Does not plan delivery or
  sequencing — use plan-implementation. Does not assess the architecture of existing code — use
  architectural-analysis. Does not write the code — use tdd. Does not restructure existing code — use refactor. Runs its rounds without
  pausing for review; to review each round as it lands, use pairing.
arguments: size
argument-hint:
  "[size: small | medium | large | dynamic] [the goal or ticket this serves, and the interface to design]"
allowed-tools:
  Read, Write, Glob, Grep, Agent, Bash(git *), Bash(find *), Bash(mkdir *),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- git installed: !`which git 2>/dev/null || echo "not installed"`
- current branch: !`git branch --show-current 2>/dev/null || echo "no git branch"`
- default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo unknown`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## Operating Principles

Read these before dispatching anything. They constrain every step below.

- **A stated goal is required, and it is the scope governor.** This skill designs a contract in service of one named
  goal: a ticket, an issue, a written requirement, or a described capability. If no goal resolves, stop and ask for one
  BECAUSE without a goal there is nothing to justify the design against, and the run degrades into designing a
  general-purpose framework for a single consumer.
- **Every element of the contract carries a justification.** Each named parameter, field, type, default, precedence
  rule, and failure behavior states exactly one of two things: the part of the stated goal it descends from, quoted or
  named; or the asked-for behavior it is a necessity of. An element that can fill neither does not enter the design. It
  moves to the cut list with what it would have done and why it was cut.
- **Silence never cuts a necessity.** The goal is short and does not enumerate what it depends on. A goal that never
  mentions a caching layer justifies cutting one. The same goal's silence about invalid input, error behavior, and
  types does not cut those, because they are necessities of the surface it did ask for.
- **The agents own the judgment; the skill orchestrates.** The skill resolves the goal and the interface, classifies
  size, selects the roster, fans agents out and in, runs the two human gates, and renders the design document. It
  produces no design content of its own.
- **The four-agent spine always runs; specialists are signal-selected.** `han-core:codebase-explorer`,
  `han-core:software-architect`, `han-core:junior-developer`, and `han-core:adversarial-validator` run at every size
  BECAUSE evidence, design, questioning, and attack are the irreducible core of a contract that survives contact. Every
  other specialist is added only when the interface's signals warrant it and the band allows it, BECAUSE dispatching an
  agent whose domain the contract never touches burns tokens and pulls the design toward concerns the goal did not ask
  for.
- **Default to small.** Start classification at small and escalate only when a higher-band signal is clearly present.
  Borderline signals stay at the smaller band. Under-dispatching is recoverable by re-running at a larger size;
  over-dispatching is not.
- **This skill changes no code.** It produces a design document. Implementation is a separate, later step, normally a
  `tdd` run against this document.
- **Options before commitment.** The architect produces two or three real options with one recommendation, not a single
  design with alternatives invented afterward to justify it. The user picks before three further agent rounds are spent
  refining one.
- **The design document template lives at
  [references/api-design-template.md](./references/api-design-template.md).** The skill renders that template by filling
  its sections. It does not invent a structure inline.
- **The document is written for a named reader.** As the skill writes the design document's synthesized prose, it
  sources the shared standard by invoking `han-communication:readability-guidance` and applies it, holding one audience
  above the writing: the engineer who will implement this contract and the reviewer who will approve it. Scope that
  frame per section so the specifics that reader needs — exact signatures, types, precedence rules, file paths — are
  preserved, never simplified away.

# Design an API

## Step 1: Resolve the Goal, the Interface, and the Starting Point

**Bind `$size`.** If the user passed `small`, `medium`, `large`, or `dynamic` as the first positional argument, bind
`$size` to it. Anything else is part of the goal-and-interface context, not a size; bind `$size` to the literal
`none provided`.

**Resolve the goal.** Take the remaining argument and conversation context as the goal this design serves. A ticket
reference, issue URL, file path, or a described capability all qualify. Read the referenced material if it names a file
or is fetchable from the conversation. Record the goal verbatim where it is quotable — the justification field in every
later step cites it. If no goal resolves, stop and ask the user for the ticket, issue, or one-paragraph statement of
what this change is for. Do not proceed without it.

**Resolve the interface.** Identify what is being designed: which component, function, module, route, or payload, and
where it lives. Confirm it resolves to real files using `Glob` and `Read`. If the interface is genuinely new and has no
file yet, resolve instead the module or directory it will live in and the consumers that will call it. If neither
resolves, ask the user to name the surface before going further.

**Resolve the starting point.** Read the `current branch` and `default branch` values from Project Context. When
`default branch` reads `unknown`, `origin/HEAD` is unset and there is no base to compare against: the working tree is
the starting point, no question is asked, and the run continues. Otherwise run
`git diff --name-only {default branch}...HEAD` and check whether any interface file resolved above appears in the
output. Only when one does, ask the user in one short message whether to design from the branch as it stands or from
the merge base, ignoring the branch's changes; read the merge-base state with `git show` when they choose the merge
base. In every other case — no interface file changed on the branch, git unavailable, or the command fails — the
working tree is the starting point and no question is asked. State the chosen starting point in one line.

**Resolve project context.** If `CLAUDE.md` is present, read its `## Project Discovery` section for conventions. Fall
back to `project-discovery.md`. These resolve language, framework, and convention questions so the agents infer less. If
neither exists, the agents fall back to surrounding-code inference — note this in the briefs.

**Resolve the output folder.** The run writes three files: `{folder}/context-brief.md`, `{folder}/design-options.md`,
and `{folder}/api-design.md`. Resolve `{folder}` in this order:

1. If the user specified an output folder, use it.
2. If the project or personal config sets an `output-directory`, place the run folder under it, per
   [config-rule.md](../../references/config-rule.md).
3. Otherwise, choose a 2-to-4-word kebab-case folder named for the interface, under a documentation root surfaced via
   `CLAUDE.md`, `project-discovery.md`, or a Glob fallback (`docs/plans/`, `docs/`).

Create the folder with `mkdir -p`. Check all three names with `Glob` before writing anything. If any of the three
already exists there, write every file this run produces to a date-suffixed name (for example `api-design-2026-08-07.md`
alongside `context-brief-2026-08-07.md` and `design-options-2026-08-07.md`) so one run's files stay together, and state
which files were written; never silently overwrite. State the chosen folder in one short line and proceed without
waiting for confirmation.

## Step 2: Detect Signals and Classify Size

Run targeted `Grep` and `Glob` over the interface and its consumers to detect which domains the contract actually
touches. These signals drive both the band and the roster:

- **Consumer-spread signal:** the interface has call sites beyond the module being changed — several components, several
  routes, or an exported surface other packages import.
- **Ordering signal:** async, lifecycle, mount-order, retry-order, or event-order behavior is part of the contract, not
  an implementation detail behind it.
- **Data-contract signal:** the interface carries persisted data, a schema or migration, a wire or event payload, or a
  document shape that another system reads.
- **Trust-boundary signal:** the interface accepts untrusted input (URL and query parameters, request bodies, uploads)
  or carries auth, tokens, secrets, or PII across the surface.
- **Failure-path signal:** the contract has to state what happens on failure — outbound calls, timeouts, retries,
  idempotency, partial writes, or a failure that would page someone.
- **Boundary-data signal:** the contract moves data across a module boundary, or how errors propagate across that
  boundary is itself part of what the design has to decide.
- **System-seam signal:** the interface crosses a deployable unit or bounded-context boundary — an RPC or HTTP contract
  with a sibling service, a message broker topic, or a shared store across services.

**Classify the size.** Default to small. Escalate only when a band's signal is clearly present; when a signal is
borderline, stay at the smaller band.

- **Small** _(default)_ — one interface with a contained consumer set inside one module, and none of the ordering,
  data-contract, trust-boundary, failure-path, boundary-data, or system-seam signals.
- **Medium** — a consumer-spread signal, OR exactly one of the ordering, data-contract, trust-boundary, failure-path,
  or boundary-data signals.
- **Large** — two or more of those cross-cutting signals together, OR a system-seam signal is present, OR `$size` is
  `large`.

**Apply the size override.** If `$size` is not `none provided`, use it: a band value is the band and skips the
signal-based classification above, while `dynamic` forces the signal-based classification even when the project config
sets a default band. If `$size` is `none provided` and the project config supplies a band via `default-swarm-size` (per
[config-rule.md](../../references/config-rule.md)), use that band, skip the signal-based classification, and announce
the config as the source. In every case still select specialists by signal: a `large` band does not dispatch agents
whose domain the contract never touches. A conversational override ("design this large") is equivalent to `$size`.

## Step 3: Build the Roster and Announce It

**Spine — dispatched at every size:**

- `han-core:codebase-explorer` — discovers the current surface, its consumers, and the constraints the design has to
  live inside. Feeds the context brief. Runs in Step 4.
- `han-core:software-architect` — produces the options document and every later amendment. Runs in Steps 5, 7, 8, and 9.
- `han-core:junior-developer` — questions the chosen option as a generalist who was not in the room. Runs in Step 7.
- `han-core:adversarial-validator` — attacks the amended design and the evidence under it. Runs in Step 9.

**Signal-selected specialists — added to the discovery wave when the signal is present and the band allows:**

| Specialist                              | Add when               | Min band |
| --------------------------------------- | ---------------------- | -------- |
| `han-core:structural-analyst`           | Consumer-spread signal | Medium   |
| `han-core:behavioral-analyst`           | Boundary-data signal   | Medium   |
| `han-core:concurrency-analyst`          | Ordering signal        | Medium   |
| `han-core:data-engineer`                | Data-contract signal   | Medium   |
| `han-core:on-call-engineer`             | Failure-path signal    | Medium   |
| `han-core:system-architect`             | System-seam signal     | Large    |
| `han-core:adversarial-security-analyst` | Trust-boundary signal  | Medium   |

Roster caps by band are ceilings, not quotas: **small** runs the spine only (4 agents); **medium** adds at most two
signalled specialists (up to 6 agents); **large** adds at most four, including `han-core:system-architect` when a
system-seam signal is present (up to 8 agents). A band reached by override rather than by signal can sit well under its
ceiling; add no specialist whose signal is absent just to fill the band. If more specialists are signalled than the cap
allows, keep the band's count, prefer the specialists covering the strongest signals, and name the omitted domains in
the design document's summary so the user can re-run larger.

Extra agents named in the project config's `## Extra Agents` list join the signal-selected pool and compete under the
same signals and band caps, per [config-rule.md](../../references/config-rule.md): add one only when a signal in the
interface matches its stated specialty, count it against the band's cap, and skip an entry that does not resolve to a
dispatchable agent with a one-line note.

**Announce the decision in one line before dispatching**, with per-specialist justification — for example:

> **Size: medium.** Designing the query-parameter prefill contract on `FlowProvider`; consumer-spread signal (7 call
> sites) and a trust-boundary signal (values arrive from the URL). **Roster (6):** `han-core:codebase-explorer`,
> `han-core:structural-analyst` (consumer audit), `han-core:adversarial-security-analyst` (untrusted URL input), then
> `han-core:software-architect`, `han-core:junior-developer`, and `han-core:adversarial-validator`.

State git availability in the same message if git is absent. Proceed without a blocking confirmation; discovery is
read-only and re-runnable, so a gate here would gate a reversible operation. If the user objects to the roster, honor
the adjustment.

**Running collaboratively.** When the request asks to review each round as it lands, which is what
`pairing` does when it hands work here, stop at this point and hand control back instead of continuing. Present the stop
in the shape [collaborative-stop-rule.md](../../references/collaborative-stop-rule.md) specifies. Absent such a request,
continue as below; an ordinary invocation is unchanged.

For this skill a round is one dispatch step: the discovery wave, the options round, the question round, and the
validation round. The two human gates below are unchanged and still fire regardless.

## Step 4: Dispatch the Discovery Wave and Write the Context Brief

Launch `han-core:codebase-explorer` and every signalled specialist in a single message with one `Agent` call per agent
so they run concurrently. Each brief must contain:

- The stated goal, verbatim.
- The resolved interface, its file paths, and its known consumers.
- The starting point from Step 1, so an agent reading a branch-modified file knows whether those changes count.
- The resolved project-context conventions, or a note that none were found and surrounding-code inference applies.
- The instruction to report findings with provenance: every finding carries a file path and line number, or is labelled
  as an inference.

Wait for the whole wave to return. Then write `{folder}/context-brief.md`: a numbered list of findings (F1, F2, F3, …),
each carrying the finding, its provenance (a `file:line` citation, or the label `inferred`), and the agent that reported
it. Merge duplicates and keep conflicting findings as separate numbered entries with both citations, rather than
picking a winner. Apply the evidence rule from [../../references/evidence-rule.md](../../references/evidence-rule.md) to
every finding. When a question the design depends on has no evidence at any tier, record it as an open item rather than
guessing, and carry it into Step 8 alongside the open items the question round produces.

If a specialist returns nothing usable or fails, record a one-line note in the context brief naming the agent and the
domain left uncovered, and continue. A missing specialist narrows the design's evidence; it does not stop the run. If
`han-core:codebase-explorer` returns nothing usable, relaunch it once with the interface's file paths spelled out. If
the second attempt also returns nothing, stop and tell the user the interface could not be discovered, naming the paths
that were searched.

## Step 5: Dispatch the Architect for Options

Launch `han-core:software-architect` with one `Agent` call. Pass it the stated goal verbatim, the full context brief,
and the resolved project conventions. Its brief must ask for:

1. **Two or three real options** for the contract, each one a design someone could implement, not a strawman.
2. **One recommendation** with the reasoning that selects it over the others.
3. **The rejected alternatives** with the reason each was rejected.
4. **For every element of every option** — each parameter, field, type, default, precedence rule, lifecycle rule, and
   failure behavior — the justification defined in the Operating Principles: the part of the goal it descends from, or
   the asked-for behavior it is a necessity of.
5. **A cut list** of anything the interface could plausibly carry but the goal does not ask for, with what it would have
   done and why it was cut.
6. **Pseudocode sketches** of each option's signatures and types.

Write the returned options to `{folder}/design-options.md`.

If the architect returns one option, or returns options whose elements carry no justification, relaunch it once with the
missing requirement restated. If the second attempt still returns one option, carry that option forward and record in
the design document that only one viable option was produced, with the architect's stated reason. If the second attempt
still leaves elements unjustified, do not carry those elements: move each one to the cut list with what it would have
done and the note that no justification was produced for it, so the gap reaches the user in Step 6 rather than passing
as designed.

## Step 6: Human Gate — The User Picks an Option

Before writing the question, invoke `han-communication:explanation-guidance` to source the shared explanation standard
into your context. After that skill returns, proceed immediately to the question below — do not stop there. The
standard stays in context for Step 8, so do not invoke it a second time.

Present the options to the user with `AskUserQuestion`: one option per choice, the recommendation named first and
labelled as recommended, each with its one-line reasoning. Apply the explanation standard to the wording, so each option
reads as an outcome the user could observe rather than a mechanism. Include the cut list in the surrounding message so
the user sees what the design is giving up.

Handle the response:

- **User picks the recommendation or another option** — carry it forward as the chosen design.
- **User picks a rejected alternative or amends an option** — carry their choice forward, and record their direction as
  the justification for the elements it changes. Operator direction is itself a valid justification.
- **User asks for a different option entirely** — return to Step 5 with their feedback, once. If a second round still
  does not produce an acceptable option, present what exists and ask for the constraint that is missing.

## Step 7: Dispatch the Question Round and Amend

Launch `han-core:junior-developer` with one `Agent` call. Pass it the stated goal verbatim, the context brief, and the
chosen option in full. Its brief must ask it to reframe the contract in simpler terms and raise the clarifying questions
a generalist who was not in the room would ask: unstated prerequisites, conflicts with the project's own conventions,
names that do not say what they hold, and behavior the contract leaves undefined. Ask for numbered questions.

Sort the returned questions into three buckets:

1. **Settled by the goal** — the stated goal already answers it. Answer it, cite the goal, and do not escalate.
   Re-deciding a question the goal already decided wastes the user's turn.
2. **Settled by the context brief** — a finding answers it. Answer it, cite the finding number.
3. **Open** — neither the goal nor the brief settles it, and the answer changes the contract. These go to Step 8.

Then relaunch `han-core:software-architect` with one `Agent` call, passing the chosen option, every question, and the
answers from buckets 1 and 2, and ask it to amend the design accordingly. Hold the open items until Step 8 answers
them.

## Step 8: Human Gate — Open Items, One at a Time

If Step 7 and Step 4 left no open item, say so in one line, skip this gate, and go straight to Step 9. The gate exists
to settle open items; with none to settle it has nothing to ask and no answer to fold in.

Otherwise surface the open items — those the question round produced in Step 7, plus any no-evidence item recorded in
Step 4 — **one at a time**, each as its own `AskUserQuestion` call. Never batch them BECAUSE
each answer routinely settles or reshapes the ones behind it, and a batch asks the user to decide in an order the design
does not follow.

Apply the explanation standard already in your context from Step 6 to each question's wording. Each question leads with
the plain-language consequence of the choice, names two to four candidate answers, and says what changes in the contract
depending on the answer. After each answer, re-check the remaining open items: drop the ones the answer just settled,
and re-word the ones it changed.

When every open item is answered, relaunch `han-core:software-architect` with one `Agent` call carrying the answers, and
have it fold them into the amended design. Record each answer in the design document as the justification for the
elements it settles.

## Step 9: Dispatch the Adversarial Validation Round

Launch `han-core:adversarial-validator` with one `Agent` call. Pass it, verbatim and unsummarized, the stated goal, the
full context brief with every finding and its citation, the amended design with its justifications, and the cut list.
Do not summarize — the validator needs the detail to attack effectively. Its job is to try to break the contract: find
the consumer the design forgets, the input state it does not define behavior for, the invariant a caller can violate,
the justification that does not actually follow from the goal, and the finding whose evidence does not support what the
design built on it.

Record its output as numbered validation findings (V1, V2, V3, …), and mark each one:

- **Rejected** — the finding does not hold. Record why, citing the goal, a context-brief finding, or a user decision
  from Step 6 or Step 8.
- **Accepted** — the finding holds. Once every finding is marked, relaunch `han-core:software-architect` a single time
  carrying all accepted findings together, and record what changed for each.

If the validator finds nothing, record what it checked and why that supports the design. A clean validation round is a
result, not an empty section.

Cap the revision at one round. If the revised design would open new open items, list them in the design document's Open
Risks section rather than starting another gate cycle.

## Step 10: Render the Design Document and Rewrite It for Readability

Read [references/api-design-template.md](./references/api-design-template.md) and render it into
`{folder}/api-design.md`. Render rules:

1. **Fill the front matter.** The goal and where it came from, the interface, the chosen size and its one-line
   justification, the dispatched roster, the starting point, and git availability.
2. **Carry the justification for every element.** The justification table is the section that makes the scope discipline
   auditable; an element with an empty justification is a rendering bug, not a formatting choice.
3. **Keep the cut list.** Render it even when short. It is what tells the reader what the design deliberately does not
   carry.
4. **Omit sections that have no content**, keeping the remaining sections in the template's order. Never emit a heading
   with placeholder or "N/A" content. A clean validation round is content, not an empty section.
5. **Write the Summary last**, after every other section is filled: the contract in two or three sentences, the option
   chosen and what it was chosen over, the decisions the user made at each gate that ran, the validation outcome, and
   any signalled domain the band cap omitted.

Then invoke `han-communication:readability-guidance` to source the shared readability standard into your context. After
that skill returns, proceed immediately to the rewrite below — do not stop there. Dispatch
`han-communication:readability-editor` with one `Agent` call to audit and rewrite the document. Pass it the
file path and the named audience: the engineer who will implement this contract and the reviewer who will approve it.
The editor reads han-communication's own canonical rule, so pass no rule path. It preserves every fact and edits prose
regions only — never inside code fences, pseudocode sketches, type signatures in code blocks, or finding-ID and
`file:line` citation identifiers. Apply its rewrite to the file.

Then run the readability rule's standardized self-check, which is in your context from the `readability-guidance`
invocation above, over the document's prose regions only. Correct every failure before presenting. Its fidelity
criterion is not optional: the standard governs how the content is said, and drops a required fact only when the reader
asked for less and losing it would not change what they do next.

## Step 11: Present the Design

Present the design to the user in a short closing message covering:

- The three file paths written.
- The contract in two or three sentences.
- The size band and roster used, and git availability if git was absent.
- The cut list, in the same plain language the design document uses, so the user can reinstate anything they disagree
  with. Any entry they reinstate re-enters the design with their direction as its justification.
- The open risks the validation round left standing, and any signalled domain the band cap omitted that would justify a
  re-run at a larger size.
- The next step: this document is the input to a `tdd` run that implements the contract.

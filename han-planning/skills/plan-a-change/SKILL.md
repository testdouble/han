---
name: "plan-a-change"
description: >
  Plans an architecture-driven change to code that already exists: module boundaries, type responsibilities, layering,
  coupling, and the public surface a revision moves. Produces a buildable change plan that names the types, modules, and
  methods involved and records the surface delta each change makes. Use when the user wants to plan, scope, or sequence
  a restructure, extraction, split, consolidation, responsibility shift, or API revision of existing code, including
  "these responsibilities are wrong, plan the fix". Does not assess an area and stop at findings — use
  architectural-analysis. Does not specify new behavior — use plan-a-feature. Does not diagnose a bug — use investigate.
  Does not write the code — use refactor to restructure it or tdd to build it.
arguments: size
argument-hint: "[size: small | medium | large | dynamic] [what needs to change, optional: source findings path]"
allowed-tools:
  Read, Write, Edit, Glob, Grep, Agent, Bash(find *), Bash(git *), Bash(mkdir *),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`
- personal config directory: !`bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh" 2>/dev/null || echo "$HOME/.claude"`
- project .han/config.md: !`cat .han/config.md 2>/dev/null || echo ""`

As your first action, use the Read tool on `.han/config.md` inside the `personal config directory` path above. A read
that returns no file is no personal configuration: continue silently. When that file or the `project .han/config.md`
probe supplies content, apply it per [config-rule.md](../../references/config-rule.md), which governs precedence
between the two files, relative-path resolution, and what to do with a file that reads but cannot be used.

## Operating Principles

- **Code-level names are the subject of this plan, not a leak into it.** Types, modules, files, methods, and public
  signatures are what the plan is about. A sibling skill forbids them because it specifies behavior a user observes;
  this one plans a structure an engineer works in, so name the thing. The altitude limit is different in kind: carry the
  names, the responsibilities, and the contracts between them, and never inline whole file bodies or prescribe
  line-level edits, BECAUSE the plan is executed after the codebase has moved on and the builder reads the current code
  at build time.
- **The change is justified against a recorded reason, and the reason is not assumed.** Step 1 reads the supplied
  context to establish why a change is being planned at all. A reported defect is one possible reason among several, and
  so is a prior findings report; neither is presumed to exist. With no reason recorded there is no evidence test to
  apply, so the run does not proceed to a plan.
- **Behavior is preserved unless the plan says otherwise, entry by entry.** An architecture-driven change moves
  responsibility between parts. Every entry in the surface delta is classified as behavior-preserving or
  behavior-changing at Step 6, and a behavior-changing entry cannot be committed silently.
- **The surface delta is a target-state record, not migration advice.** Every element the change removes, adds, moves,
  renames, or re-scopes carries a statement of what is true after the change, in its own right. Migration guidance is
  additional and never substitutes for it. Per [surface-delta-rule.md](./references/surface-delta-rule.md).
- **A contract two parts must independently agree on is pinned here, not invented during the build.** Splitting one
  type's responsibilities across three creates contracts between them: a call signature, a payload shape, an error
  contract, a lifecycle order. Each is a decision-bearing value the plan carries in concrete form. See
  [../../references/contract-pinning-rule.md](../../references/contract-pinning-rule.md).
- **The run stays inside the boundary it descends from.** Step 1.5 records the work item's stated scope and exclusions,
  per [../../references/planning-boundary-rule.md](../../references/planning-boundary-rule.md). The scope gate at Step 8
  reads that record. Anything the boundary excludes lands in a visible cut list, per
  [../../references/scope-justification-rule.md](../../references/scope-justification-rule.md).
- **YAGNI gates every part the change introduces.** Apply [../../references/yagni-rule.md](../../references/yagni-rule.md)
  to each new type, interface, abstraction layer, extension point, configuration seam, and adapter the target state
  proposes. A new abstraction with one implementation and no named second caller is the signature failure of this skill's
  domain: it is the easiest thing to justify from taste and the hardest to remove later. Items failing the evidence test
  land in `## Deferred (YAGNI)` with the reopening trigger named.
- **Evidence quality is the companion principle.** Apply
  [evidence-rule.md](../../references/evidence-rule.md) alongside YAGNI. YAGNI gates whether a part is included; this one
  characterizes what each claim about the current code rests on.
- **Questions to the user arrive one at a time, led by the consequence.** Per
  [../../references/operator-escalation-rule.md](../../references/operator-escalation-rule.md). The Step 1.5 confirmation
  turn is the one exception, and the one turn that carries more than one ask.
- **The plan lives in three cross-referenced files.** `change-plan.md` is the deliverable and sits at the root of
  `{folder}/`; `artifacts/change-decision-log.md` and `artifacts/current-state-findings.md` sit beneath it. The plan
  cites decisions with inline `([D-N](artifacts/change-decision-log.md#...))` links and cites current-state evidence with
  `([C-N](artifacts/current-state-findings.md#...))` links. Any edit to one file updates the matching cross-reference
  fields in the others.

# Plan a Change

## Step 1: Establish the Reason and the Output Location

Read the user's argument and the conversation context, then answer one question before anything else: **why is a change
being planned?** Do not assume a prior report exists, and do not assume something is broken. Classify the reason into
one of these, and record which:

- **A finding already established.** An `architectural-analysis` report, an `investigate` report, a code review, or an
  ADR names the structural problem. Capture its path.
- **A constraint arriving.** A new requirement, a scale change, a platform move, or a dependency change the current
  structure cannot absorb as it stands.
- **A decision already taken.** An ADR or a team agreement settled the target; this run plans its execution.
- **Friction the user reports.** The code is hard to change, hard to test, or hard to reason about, and the user is
  describing that directly rather than citing a document.
- **A defect whose root cause is structural.** A specific failure that keeps recurring because of how the code is
  arranged.
- **A deliberate improvement with no triggering event.** The user wants the structure to be better and says so.

When the context supplies none of these, ask for one, and ask for nothing else in that turn. A run with no recorded
reason has nothing to apply the YAGNI evidence test against, so it produces taste rather than a plan. This is the one
place the skill stops before doing any work.

**Resolve the area.** Name the modules, directories, or types the change concerns. If no area resolves to real files,
ask the user to name one. "Restructure the codebase" is not a valid input.

**Resolve the output location** through the precedence chain in
[../../references/config-rule.md](../../references/config-rule.md):

- A folder the user named wins.
- Otherwise, the `output-directory` setting from the project or personal `.han/config.md`, with the run's own folder
  structure created beneath it.
- Otherwise, propose a folder name of three to five words in kebab-case under a documentation root discovered via
  CLAUDE.md's `## Project Discovery` section, `project-discovery.md`, or a Glob fallback (`docs/changes/`, `docs/plans/`,
  `docs/`). Confirm the name with the user before creating files.

Three files will be written. The plan sits at the root of `{folder}/`; the companions sit in `{folder}/artifacts/`:

- `{folder}/change-plan.md` — the deliverable. Always written.
- `{folder}/artifacts/change-decision-log.md` — every committed decision with rationale, evidence, and rejected
  alternatives. Always written.
- `{folder}/artifacts/current-state-findings.md` — what the code does today, as numbered `C-N` findings with file paths
  and verbatim code. Always written, whether this run produced the findings or read them from a prior report.

One more is written by Step 1.5:

- `{folder}/artifacts/scope-boundary.md` — the boundary record.

Create the `artifacts/` subfolder before writing the companions. If any file already exists, ask whether to overwrite or
append before proceeding.

## Step 1.5: Read and Record the Scope Boundary

Read [../../references/planning-boundary-rule.md](../../references/planning-boundary-rule.md) for the record's name and
its sections. Establish the boundary before Step 2 discovery begins. This skill plans code structure rather than
screens, so the rule's visual-material convention does not apply to it: write no `ui-designs/` folder and run no
completeness gate. A diagram the user supplies is ordinary context.

**A record already exists** at `{folder}/artifacts/scope-boundary.md`, or in the folder of a source report Step 1
captured. Read it and use it. Do not re-ask anything it answers.

**No record exists.** Identify the work item this change descends from — a ticket, an issue, a pull request, or a
written request the user typed — and read it. Record its stated scope and its stated exclusions word for word. When no
work item exists, record that explicitly along with the statement that the user's request is the only boundary this run
has.

The read does not traverse outward. A linked item, a sibling, or a closed item is not scope evidence for the item in
hand.

Then take one confirmation turn before Step 2. It restates the recorded boundary in the user's own terms, restates the
reason recorded in Step 1, and asks whether the area named is the whole area the change may touch. This turn is a
confirmation rather than an escalation, and the one turn that carries more than one ask.

Source the explanation standard by invoking `han-communication:explanation-guidance` before you write the confirmation
turn, and again before any escalation later in the run.

When the user hands you a work item that conflicts with the recorded one, surface the conflict in the confirmation turn
and ask which governs.

## Step 2: Establish the Current State

The plan's target state is only as good as the account of what exists today. Two paths reach that account, and which one
runs depends on what Step 1 recorded.

**A prior findings report exists.** Read it in full. Extract its findings into
`{folder}/artifacts/current-state-findings.md` as numbered `C-N` entries, preserving each finding's file paths and
verbatim code. Note which findings the report left unverified, and carry that label forward. Do not re-run the analysis
the report already performed.

**No prior findings report exists.** Dispatch the discovery round yourself. This is the orchestration this skill exists
to own:

- `han-core:structural-analyst` — always. Module boundaries, coupling, dependency direction, duplication, abstractions.
- `han-core:behavioral-analyst` — always. Data flow, error propagation, state, integration boundaries at runtime.
- `han-core:concurrency-analyst` — only when the area actually contains concurrent access, async coordination, or shared
  mutable state.

Brief each with the area from Step 1, the reason from Step 1, the boundary record's path, and a report-length target
matched to the size of the area rather than a size word. Ask each for numbered findings with file paths and verbatim
code. Launch them in parallel, in a single message.

Either path, then: **run one Glob and Grep sweep of your own** for the project context the specialists do not cover, and
fold it into the same file — CLAUDE.md and `project-discovery.md` for stack and conventions, ADRs under `docs/adr/`,
coding standards, and, when git is available, `git log --since="90 days ago" --name-only --pretty=format:""` over the
area's directories to surface churn and recent precedent.

Write `{folder}/artifacts/current-state-findings.md` using
[current-state-findings-template.md](./references/current-state-findings-template.md). It is the single source of truth
for the current state across the rest of the run. **Every later agent is told to read it first and not to re-grep for
what is already there.**

Enumerate the gaps explicitly: what you searched for and did not find. A missing ADR or absent coding standard is itself
a finding the plan should note.

## Step 3: Select the Team

Read [team-selection.md](./references/team-selection.md). It carries the size bands with their specialist and round
caps, the size-override rule, the seats every team fills, and the roster to draw the rest from.

Default to small and escalate only when the signals clearly require it. State the chosen size, the recommended team, and
the reason in one short message before launching agents. If the user disagrees, accept their override of the size, the
specialists, or both.

## Step 4: Propose the Target State

Dispatch `han-core:software-architect` with the current-state findings, the recorded reason, the boundary record, and
the project conventions from Step 2. Ask it for the target structure: which responsibilities live where, which module
and interface boundaries change, and the refactoring path between the two states.

Add `han-core:system-architect` only when the area crosses a service boundary, changes a context-map relationship, or
shifts data ownership between services. When it is not dispatched, its deferrals from the software architect are
surfaced in the plan rather than absorbed.

Both get the YAGNI directive in full: every new type, interface, abstraction layer, extension point, and adapter must
cite evidence per [../../references/yagni-rule.md](../../references/yagni-rule.md), and a proposal whose concern is
satisfied by a strictly simpler structure returns the simpler structure. Both also get the contract directive: every
contract two parts must independently agree on is specified to a concrete signature, field layout, or worked example,
per [../../references/contract-pinning-rule.md](../../references/contract-pinning-rule.md).

The architect proposes; this skill decides. Where the proposal and the recorded reason do not line up — a restructure
larger than the reason justifies, or one that leaves the reason unaddressed — that gap is a decision to settle at Step
5, not a recommendation to adopt.

## Step 5: Settle the Surface Delta

Read [surface-delta-rule.md](./references/surface-delta-rule.md) before writing a single entry. It defines what counts
as a surface element, the five delta verbs, and the target-state statement every entry carries.

Walk the target state element by element and commit each one as a delta entry. For each:

1. **Try evidence first.** The current-state findings, the ADRs, the coding standards, and the codebase settle most of
   these. Record the resolution and its citation.
2. **When evidence is insufficient, ask `han-core:junior-developer` to reframe.** Launch it in conversational mode with
   the question and the input that raised it, and a directive to restate the issue in plain language and surface the
   clarifying questions a three-to-five-year generalist would ask. The reframing frequently exposes an unstated
   assumption and settles the question without the user.
3. **When the reframing does not resolve it, escalate to the user**, one question per turn, per
   [../../references/operator-escalation-rule.md](../../references/operator-escalation-rule.md). Lead with the
   consequence a person who will not read the code would describe, carry named candidate answers, and put the type
   names, paths, and evidence below the question. State how many are pending on the first. Capture the answer verbatim.

Never escalate a question the recorded boundary already answers. When the boundary places an element outside scope, cut
it and record why, rather than asking the user to choose between options their own work item already decided between.

Record every settled entry as a `D-N` decision in `artifacts/change-decision-log.md` with its rationale, evidence, and
rejected alternatives.

## Step 6: Behavior-Preservation Gate

Classify every delta entry from Step 5 as one of two, and record the classification on the entry:

- **Behavior-preserving.** After the change, every observable input-to-output relationship the entry touches is
  unchanged. Callers outside the area see what they saw before. State what makes that true.
- **Behavior-changing.** Something a caller, a user, or an operator can observe is different afterwards: a return shape,
  an error type or message, a timing or ordering guarantee, a default, a persisted format, an exit code.

Every behavior-changing entry is escalated to the user before it is committed, one per turn under the Step 5 escalation
rules, whether or not the change looks obviously desirable. An architecture-driven change is planned on the premise that
it is safe to make, and this gate is where that premise is checked rather than assumed. Record the user's answer as its
own `D-N` decision.

An entry you cannot classify from the evidence available is recorded as **behavior-unknown** and escalated the same way.
Do not resolve an unknown by assuming preservation.

## Step 7: Review Round

Launch the specialists selected in Step 3 in parallel, in a single message, with domain-scoped briefs as
[team-selection.md](./references/team-selection.md) specifies. Give each the current-state findings path, the target
state, the delta with its behavior classifications, the boundary record, and a report-length target matched to the size
of the area.

Aggregate their verbatim output into the plan's review record. Three passes run first, in this order:

**Pass A: merge by substance.** Two specialists often raise one finding in different words. Merge those into a single
record carrying every originating specialist's identifier.

**Pass B: strip blocking severity from findings resting on an uninspected input.** A specialist that could not inspect
something says so on the finding itself. Every such finding, and every finding depending on that same input, is labeled
`Unverified` and **cannot carry build-blocking severity**. Keep it — it may be real, and you can often verify it
yourself. What it cannot do is reach the user looking like a blocker on the strength of something nobody read.

**Pass C: close what the current-state findings already answer.** A finding the `C-N` record answers directly is closed
with the citation rather than promoted to an open question.

Then resolve what remains under the Step 5 order: evidence, then `han-core:junior-developer` reframing, then escalation.
A finding that changes a delta entry sends that entry back through the Step 6 gate.

The round cap from Step 3 bounds this: small runs one round, medium two, large three. Re-engage specialists only when a
finding names a specialist whose domain was not covered. At the cap, surface what remains to the user with
recommendations and a note that the review has reached a plateau.

## Step 8: YAGNI and Scope Sweep

Run three gates over every part the target state introduces.

1. **The evidence test.** Each new type, interface, abstraction layer, extension point, configuration seam, and adapter
   cites evidence per [../../references/yagni-rule.md](../../references/yagni-rule.md): a named finding it resolves, an
   existing code path that breaks without it, three current concrete uses, or a measured workload. A new abstraction
   with one implementation and no named second caller fails this test by default. Failures land in
   `## Deferred (YAGNI)` with the reopening trigger named.
2. **The simpler-version test.** Where a strictly simpler structure satisfies the same evidence, the simpler structure
   is the decision and the larger one goes under `Rejected alternatives:` in its `D-N` entry.
3. **The scope test.** Every entry is checked against `artifacts/scope-boundary.md` per
   [../../references/scope-justification-rule.md](../../references/scope-justification-rule.md). Entries the boundary
   excludes land in `## Cut for Scope` with the citation.

An item lands in one section or the other, never both, and never silently disappears.

## Step 9: Write the Change Plan

Invoke `han-communication:readability-guidance` to source the shared readability standard into your context, then apply
it to the plan's prose. Hold the named audience: the engineer who will make the change. The standard governs how a fact
is said, never whether a required fact appears — keep the type names, paths, and contracts the plan depends on.

Write `{folder}/change-plan.md` using [change-plan-template.md](./references/change-plan-template.md), and
`{folder}/artifacts/change-decision-log.md` using
[change-decision-log-template.md](./references/change-decision-log-template.md). Read each template in full and copy its
structure whole.

Sequence the change units so each one leaves the codebase working. A unit that only compiles once a later unit lands is
not a unit; merge it into the one it depends on, or split the dependency out first. This is the property that makes the
plan buildable directly rather than needing a second planning pass, so state the ordering constraint on every unit that
has one.

Then wire the cross-references: inline `([D-N](artifacts/change-decision-log.md#...))` citations in the plan for every
non-obvious claim, `([C-N](artifacts/current-state-findings.md#...))` for every claim about the code as it stands today,
and the `Referenced in plan:` field back from each decision.

## Step 9.5: Readability Pass

Dispatch `han-communication:readability-editor` (one Agent call) to audit and rewrite the plan's prose. Pass it the file
path `{folder}/change-plan.md` and the named audience: the engineer who will make the change. The editor reads
han-communication's own canonical rule, so pass no rule path. It must preserve every fact and operate on prose regions
only — never inside code fences, tables, or the `D-N` and `C-N` citation identifiers, which must survive unchanged so
they still resolve. Apply its rewrite to the plan file.

It must also leave every plan section heading unchanged, because the decision log names those headings as text in its
`Referenced in plan:` field. The editor is otherwise free to make a heading descriptive, and here that would break a
link.

Then read the editor's fact-preservation report. **Do not walk the self-check over the text the editor produced.** The
canonical readability rule says the dedicated editor replaces a skill's own readability pass rather than stacking a
second one on top.

The editor's report has three shapes that need no repair, and one that does:

- The fact-preservation ledger names nothing it could not preserve. Nothing further is needed.
- The ledger names a fact it kept in the original wording to satisfy fidelity. Leave that wording alone rather than
  re-editing it.
- `Insertions` names nothing, or names a line whose quoted `source=` span you find in the plan. Nothing further is
  needed.
- `Insertions` names a line whose quoted `source=` span is **not** in the plan. The editor wrote that sentence from
  something the draft does not carry. Name it in the Step 10 summary and record it in `artifacts/`, quoting the inserted text
  and the span the editor claimed. Change no text: there is no pre-edit draft on disk to restore, because the rewrite
  was applied in place. Check nothing else.

**When no usable report comes back** — the editor could not be reached, returned nothing, or returned something you
cannot read as any of those shapes — run the readability rule's standardized self-check yourself over the plan's prose regions
only. Say in the Step 10 summary that you did so and why. With no report, that check is the only fidelity guard the
output has.

## Step 10: Present the Change Plan

Summarize for the user:

- The output paths: `change-plan.md`, `artifacts/change-decision-log.md`, `artifacts/current-state-findings.md`, and
  `artifacts/scope-boundary.md`.
- **The recorded reason for the change**, in one line, and whether the plan addresses it in full.
- **Every behavior-changing entry**, in plain language, with the user's decision on each. Show these in the message
  rather than pointing at a section: a behavior change the user never reads is a behavior change nobody agreed to.
- **The cut list**, when the scope gate cut anything: what each entry would have done, in plain language, and why. Say
  that the user can reinstate any of it, and that their saying so is itself a valid justification the reinstated entry
  records.
- The YAGNI deferrals in `## Deferred (YAGNI)`, kept distinct from the cut list. Omit this line if nothing qualified.
- Whether the current state came from a prior report (with its path) or from this run's own discovery round.
- Any finding that stayed `Unverified` because a specialist could not inspect its input. Neither these nor the
  deferrals are presented as blocking.
- Any remaining open items and whether they block the change. A non-blocking one is still an unanswered question the
  builder inherits, so name it rather than counting it.

Then name what comes next: `plan-work-items` to break the change units into independently-grabbable work, `tdd` to build
a unit test-first, or `refactor` to carry out a behavior-preserving unit directly. Ask whether the user wants to iterate
on specific sections or considers the plan ready.

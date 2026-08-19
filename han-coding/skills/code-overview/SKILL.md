---
name: "code-overview"
description: >
  Produces a human-readable, progressive-disclosure overview of unfamiliar code or a pull request's changes — why it
  exists (the real problem it solves or goal it serves for the business or a user), and from there what it does, how it
  flows, and where to start — so you can get up to speed before working on or reviewing it. Use when you want to
  understand, get oriented in, make sense of, explain, or get up to speed on a chunk of code, a file, a directory, a
  symbol, or a PR's changes. Writes the overview to a scratch file and changes no code. Does not review code quality or
  raise findings — use code-review for auditing changes or post-code-review-to-pr for posting them. Does not produce
  durable feature or system documentation — use project-documentation. Does not assess architecture or structural risk —
  use architectural-analysis. Does not diagnose bugs or root-cause failures — use investigate. Does not pace a person
  through the code one step at a time in conversation — use code-walkthrough.
arguments: size
argument-hint:
  "[size: small | medium | large | dynamic] [target: file, directory, symbol, or PR reference — defaults to the current branch's
  changes]"
allowed-tools:
  Read, Glob, Grep, Agent, Write, Bash(git *), Bash(gh *), Bash(find *),
  Bash(bash "${CLAUDE_PLUGIN_ROOT}/scripts/han-config-dir.sh")
---

## Project Context

- git installed: !`which git 2>/dev/null || echo "not installed"`
- gh installed: !`which gh 2>/dev/null || echo "not installed"`
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

- **"Why" is the organizing question.** The overview exists to answer one question first: _why does this code exist?_ —
  and the answer is the real problem it solves or the goal it accomplishes for the business or a user, never the
  technical mechanics. Why it exists, why it works the way it does, why it is the current solution to a real need: that
  is the spine of the whole document. Everything else the overview carries — what it does, how it flows, where it
  connects, where to start — flows out of the why and exists to give the reader the context to understand it. "What",
  "how", "where", and "when" are not dropped or diminished; they are framed by and subordinated to the "why" they serve.
  BECAUSE a reader who knows what code does but not why it exists cannot make sound decisions about it — the why is the
  load-bearing understanding, and the rest is scaffolding around it. State the why as a solution to a need, and never
  invent a business rationale the evidence does not support; when the why can only be inferred, mark it as inferred.
- **The skill orchestrates and synthesizes; the agents discover, validate, then refine.** The skill resolves the target,
  classifies size, dispatches exploration, and writes the overview. `han-core:codebase-explorer` agents gather the
  surrounding code and context the synthesis draws on — they do not write the overview. After the draft is written,
  `han-core:adversarial-validator` re-reads the code to challenge the draft's claims for accuracy, and
  `han-communication:readability-editor` rewrites the corrected draft against the shared readability standard,
  preserving every fact; the skill applies the validator's corrections and the editor's rewrite. The skill itself
  produces the grouping, the charts, the orientation, and the final rewrite.
- **The overview applies the shared readability standard.** As it writes and refines the overview, the skill sources the
  standard by invoking `han-communication:readability-guidance` (Step 5) and applies it, holding the default audience
  frame: a capable reader who did not do this work and lacks the author's context. The standard governs how the overview
  reads (main point first, descriptive headings, one idea per paragraph, progressive disclosure), never whether a
  required fact about the code appears. Its dedicated `han-communication:readability-editor` pass (Step 7) replaces the
  older information-architect / junior-developer readability review; the accuracy validator is a separate pass and
  stays.
- **Diagram legibility is this skill's job, not the editor's.** The readability rewrite pass is barred from touching
  diagram bodies, so nothing but this skill checks whether a chart can be read. Apply the template's diagram rule as
  you draw each chart: boxes name components and boundaries, and fields, types, and technical annotations go into the
  prose beneath. BECAUSE the exemption is right for accuracy — an editor free to reword a box could silently change
  what the chart claims about the code — and the reading load it leaves behind has to land on someone.
- **Read-only, always.** The skill explains; it never edits the target. It writes only its own scratch overview file.
  BECAUSE the job is understanding, not modification — this keeps the skill safe to point at unfamiliar code.
- **Accurate to the code, always.** Every claim the overview makes — the why it states (grounded in commit and PR/issue
  intent, comments, and what the code visibly does toward a goal), what the code does, each flow step, each named entry
  point, each change grouped by intent — must be grounded in the actual code and its intent, never inferred past the
  evidence or invented. BECAUSE a confidently wrong overview is worse than none: it sends the reader to the wrong file
  with false confidence and silently corrupts the mental model the skill exists to build. The adversarial validation
  pass (Step 7) exists to catch this. It is accuracy control on the _description_, NOT a quality judgment about the code
  — the two are different lines, and crossing into the second is still forbidden.
- **No quality judgment, ever.** The overview raises no findings, severities, or recommended changes — including in the
  PR-mode "what to watch" section, which is navigational only. BECAUSE reviewing a PR's quality is `code-review`'s job;
  this skill only helps the reader understand the PR before they review it. Crossing this line collapses the boundary
  between the two skills. Saying the code does not support a change's stated reason is not a crossing: the claim under
  test there is the document's own leading claim about the reason, which this skill already owns and already validates,
  not a judgment about the code's quality.
- **No PR statistics, ever.** The overview never states lines changed, files changed, additions/deletions, commit
  counts, or any other diff-stat figure — not in the intro, not in a section, not anywhere. BECAUSE these numbers go
  stale the instant the PR is updated and add no understanding; describe what changed and why, never how big the diff
  is.
- **Every overview cites its context.** The overview lists every source it drew on in a `Context used` section placed
  directly after the lead why section — linked directly when the source has an address (a repository file path, a PR /
  issue / commit URL), stated in one plain sentence when it does not (an uncommitted diff, the branch's commit messages,
  context supplied in conversation). BECAUSE the reader should be able to walk the same evidence the overview was built
  from, and a fabricated or broken link poisons that trust — never invent a URL or link a path that does not exist.
- **Ephemeral, not documentation.** The overview is an understand-now orientation aid, not durable documentation,
  BECAUSE durable feature and system docs are `project-documentation`'s job. That is why the skill's own default
  destination sits outside the repository, and why the skill never commits the file. This principle governs the
  skill's default only, not what a person configures: a configured output directory wins wherever it points, and the
  run says nothing about it (Step 6).
- **Default to small.** Start size classification at small and escalate only when a higher-band signal is clearly
  present. BECAUSE under-dispatching is recoverable by re-running larger; over-dispatching burns tokens and dilutes the
  overview.
- **Minimal technical detail, scoped per section.** Keep the why, flow, and context sections at the level of why the
  code exists and what it does — the why is told as a problem solved or goal met, not as technical mechanics. The
  where-to-start / what-to-watch handoff is the one exception — it must name concrete entry points or it is not
  actionable.
- **The output template lives at [references/overview-template.md](./references/overview-template.md).** Render that
  template; do not invent a structure inline.

# Produce a Code Overview

## Step 1: Resolve the Target and Select the Mode

**Bind `$size`.** If the user passed `small`, `medium`, `large`, or `dynamic` as the first positional argument, bind
`$size` to it. Anything else is part of the target, not a size; bind `$size` to the literal `none provided`.

**Note tool availability.** Read `git installed` and `gh installed` from Project Context. If `git installed` is empty or
reads `not installed`, git is unavailable — see the degraded paths below.

**Resolve the target and mode by this fixed precedence**, so an ambiguous string never silently selects the wrong mode:

1. **An explicit pull request reference or URL** (e.g. `#82`, `https://github.com/owner/repo/pull/82`) → **PR mode**
   against that pull request. Requires `gh`; if `gh installed` is empty or reads `not installed`, tell the user `gh` is
   needed to read a named pull request and offer code mode against a local target instead.
2. **An existing file or directory path** (confirm it resolves with Glob or find) → **code mode** on that path.
3. **A symbol** (a function, class, type, or other named code entity) → **code mode** on that symbol. Resolve it with
   Grep across the repository.
4. **No target string given** → **PR mode** against the current branch's changes (the local diff). This requires git,
   not a remote pull request.

**Handle the unresolvable and empty cases** (state the problem plainly and stop; never guess):

- A path or symbol that resolves to nothing, or a symbol ambiguous across several definitions → report what could not be
  resolved and ask the user to disambiguate.
- No target given and the working tree is clean with no branch changes → ask the user for a code target rather than
  producing an empty overview.
- No target given and git is unavailable → tell the user PR mode and the bare-invocation default need git to read
  changes, and ask for a named code target (code mode still runs without git).

**Resolve project context.** If `CLAUDE.md` is present, read its `## Project Discovery` section for conventions; fall
back to `project-discovery.md`. These resolve language and framework questions so the explorers infer less. If neither
exists, note that surrounding-code inference applies and pass that into the briefs.

## Step 2: Classify Size and Announce

**Classify the target's size. Default to small**; escalate only on a clear signal, and stay at the smaller band when a
signal is borderline.

- **Small** _(default)_ — a single file, a single symbol, or a small change set (a few files in one subsystem).
- **Medium** — a directory or module, or a moderate change set (several files across one or two adjacent subsystems).
- **Large** — multiple subsystems, or a large change set (many files across several subsystems).

**Apply the size override.** If `$size` is not `none provided`, use it: a band value is the band and skips the
signal-based classification, while `dynamic` forces the signal-based classification even when the project config sets
a default band. If `$size` is `none provided` and the project config supplies a band via `default-swarm-size` (per the
config rule in [../../references/config-rule.md](../../references/config-rule.md)), use that band, skip the
signal-based classification, and name the config as the source in the announcement below. A conversational override
("give me a large overview") is equivalent.

**Announce the chosen mode and size in one line before dispatching any exploration** — for example,
`Code mode, size medium: directory \`src/auth/\` spanning the session and token
subsystems.` State tool degradation in the same line when it applies (`git unavailable — code mode only`). Proceed
without a blocking confirmation; this skill is read-only and re-runnable, so a gate here would gate a reversible
operation. Honor any adjustment the user makes.

## Step 3: Gather the Input

**Code mode.** Read the target file, directory, or symbol and enough of its immediate neighbors to know its boundary —
what it imports and what imports it.

**PR mode.** Gather the change set:

- **Current branch's changes** (no target given): determine the default branch
  (`git symbolic-ref refs/remotes/origin/HEAD` or fall back to `main`/`master`), then capture
  `git diff {default-branch}...HEAD` for committed work and `git diff` plus `git diff --cached` for uncommitted work.
  Run each diff as its own Bash command so large diffs stream incrementally. Also capture
  `git log {default-branch}..HEAD --pretty=format:%B` for the change's intent. When `gh` is available, also run
  `gh pr view --json title,body,comments` (no ref — resolves the PR for the current branch) so the change's stated
  intent and any screenshots are in scope; if no PR exists for the branch, skip this without failing.
- **A named pull request** (explicit reference): run `gh pr view {ref} --json title,body,comments` for intent and
  screenshots, and `gh pr diff {ref}` for the change set. If the pull request cannot be reached (it does not exist, or
  access is unavailable), say so and offer code mode against a local target instead.

**Capture screenshots.** When a PR body or a comment contains embedded images — Markdown `![alt](url)` or
`<img src="url">`, typically GitHub-hosted (`user-attachments`, `githubusercontent.com`) — record each image's URL
together with the nearby caption or heading that says what it shows. These let the overview show a visual next to the
text that describes it, so the reader does not have to switch back to the PR. If the PR has no images, capture nothing
here.

Identify the set of files the change touches; that set scopes the exploration in Step 4.

**Start the context ledger.** From this step on, record every context source consulted — the files and directories read,
the PR reference and its URL, the commit range and log, CLAUDE.md or project-discovery.md, and any material the user
supplied in conversation — noting for each whether it has a direct address (a repository file path, a PR / issue /
commit URL) or not (an uncommitted diff, the branch's commit messages, conversational context). Step 5 renders this
ledger into the overview's `Context used` section, so an unrecorded source here is a missing citation there.

## Step 4: Dispatch Exploration Scaled to Size

Dispatch `han-core:codebase-explorer` agents to discover the surrounding code and context — **the evidence of why the
code exists** (the problem it solves or goal it serves), plus entry points, directly-related context, uses, and the main
process flow — that the synthesis draws on. **Scale the count to size, and launch every agent in a single message** so
they run concurrently:

- **Small** — one explorer over the target (or the changed files).
- **Medium** — two or three explorers, each over a coherent slice of the target (or the change), so coverage is
  parallelized rather than serialized.
- **Large** — three to five explorers, each scoped to one subsystem or one area of the change.

Each brief must contain: the resolved target (and, in PR mode, the changed-file set and the captured intent from Step
3); the project-context conventions from Step 1, or a note that surrounding-code inference applies; and the instruction
to report **the evidence of why the code exists** — the problem it solves or goal it serves, drawn from commit messages,
PR/issue intent, code comments, naming, and tests — alongside entry points, directly-related context, uses, and the main
flow, as concrete, file-grounded findings. Instruct each explorer to **list the files and sources its findings rest
on** (paths, commits, PR or issue references) so the skill can fold them into the context ledger from Step 3. Instruct
each explorer to **report what it found, not to assess quality** — this skill raises no findings — and, where the why is
not stated anywhere in the evidence, to say so rather than infer one.

When the wave returns, merge each explorer's reported sources into the context ledger, deduplicated.

Wait for the whole wave to return before synthesizing. If the target proves too large to cover fully at the chosen size,
the explorers cover the highest-signal areas; carry that into the coverage note in Step 5.

## Step 5: Synthesize the Overview

Invoke `han-communication:readability-guidance` to surface the shared readability standard into your context before you
write. Then invoke `han-communication:explanation-guidance`, which surfaces Han's standard for explaining technical work
to a reader who will not implement it: that standard governs the closing restatement this step writes and the closing
message Step 8 prints, BECAUSE both go to someone who will not open the code. Both run inline and hand control straight
back; continue with this step as soon as they return. Then draft the overview against both. Read [references/overview-template.md](./references/overview-template.md) and
render the structure for the resolved mode, drawing on the explorers' findings and the input from Step 3. The skill
writes the overview; the explorers' raw findings are not pasted in.

Open the document with a title and a short **intro paragraph naming what is being examined** — the file, directory,
symbol, pull request, or branch, and the part of the system it belongs to. Do NOT emit a `Mode:`, `Generated:`, or bare
`Target:` metadata block; that metadata does not help the reader. **Never state PR statistics** — lines changed, files
changed, additions/deletions, or commit counts — anywhere in the document; they go stale the moment the PR changes and
add no understanding. Fold anything worth keeping into the intro sentence.

**Lead with the why, and let everything else flow from it.** The first section after the intro answers _why this code
(or this change) exists_ — the real problem it solves or the goal it accomplishes for the business or a user, then why
it works the way it does and why it is the current solution to that need. Tell the why as a solution to a need, not as
technical mechanics. Then frame every section that follows as serving that why: the flow shows how the code delivers on
it, the context shows what it depends on to meet the need, the handoff shows where to start working on it. When the why
is not recoverable from the code and its intent (commit messages, PR/issue text, comments, naming, tests), state what
the code demonstrably does toward a goal and mark the inferred why as inferred — never invent a business rationale the
evidence does not support.

**Say when the code does not support the stated reason (PR mode).** You already read the code to ground the why. When
that reading shows the code already satisfies the stated motivation, or shows the change is not needed for the reason
given, say so in the why section itself, in one or two sentences, as a fact about the stated reason. Raise no finding,
assign no severity, recommend no change; the rest of the overview proceeds as normal. Three states, and only the first
gets the sentence:

1. You checked and the code contradicts the stated reason. Say so.
2. You checked and the code supports it. Say nothing extra.
3. The code says nothing either way. That is the inferred-why case above: mark the reason as inferred and claim no
   discrepancy.

NEVER report a contradiction you did not check and find, BECAUSE that is a stronger claim than the evidence carries and
the honest weaker claim already has a home in state 3. This is the highest-value sentence a change overview can carry,
and it is also the easiest one to get wrong by reaching.

**Code mode** renders, in order: the title and intro paragraph; a coverage note **only if** coverage was partial; **Why
it exists** (the problem the code solves or goal it serves, then briefly what it is and why it works the way it does —
all flowing from the why); **Context used** (the context ledger, rendered per the rules below); **Main flow** (a Mermaid
chart with a one-line scope label, read as how the code delivers on the why); **Context and uses** (context and uses
kept distinguishable, framed as what it depends on to meet the need and where that need is served from); **Where to
start** (the entry points numbered in the order a reader opens them, each with one line on what the reader learns there,
and one runnable example call on any entry point that is an interface other code calls); **What this code does, in plain
language** (the closing restatement).

**PR mode** renders, in order: the same title and intro paragraph; the same conditional coverage note; **Why this change
exists** (the problem the change solves or goal it advances, then briefly the bottom line of what it does, plus the
unsupported-reason sentence when it applies — see below); **Context used** (the context ledger, rendered per the rules
below); **Changes by intent** (grouped by the reader-visible outcome
each group delivers — the why each group serves — not by file, layer, or author motivation; a single logical change is
one narrative with no grouping header); **How the change flows** (a Mermaid chart with a scope label, placed after the
grouped changes BECAUSE the reviewer must know what changed before that chart is meaningful); **What to watch when
reviewing** (navigational only — where the change is hardest to follow and why; never a quality or risk judgment);
**What this change does, in plain language** (the closing restatement).

**Render the `Context used` section from the context ledger** built in Steps 3 and 4, directly after the lead why
section in both modes. One line per source, each with a short note on what it contributed. Link every source that has a
direct address: a repository file or directory as a Markdown link whose target is its absolute path (the overview file may
sit outside the repository, so a relative path would not resolve); a pull request, issue, or commit as its URL (in PR
mode with a remote, prefer the remote's file URLs at the PR's head so the links work for a reader outside this machine).
A source with no address — the uncommitted diff, the branch's commit messages, context the user supplied in conversation
— gets one plain sentence stating what the context was. Never fabricate a URL or link a path that does not exist;
deduplicate the list and keep it a reference list, not prose.

**Place any captured screenshots inline next to the text they illustrate** — embedded as `![caption](url)` directly
under the Changes-by-intent item or the flow step they depict, BECAUSE a visual next to its description spares the
reader a trip back to the PR. Keep the image URL exactly as captured. Omit screenshots entirely when the PR had none;
never invent or placeholder an image.

**Close with a restatement a person can paste.** Both modes end with three or four plain sentences a reader who did not
do this work could read aloud, carrying no file paths, no type names, and no symbol names. Write them under the
explanation standard sourced above. These sentences are the canonical text: Step 8's message repeats them rather than
composing its own version, BECAUSE the reader's next move after an overview is reliably to paste a plain summary into a
pull request description or a message to a reviewer, and two texts saying the same thing in different words teach them
to distrust the shorter one.

Apply the per-section detail rule from the template: minimal technical detail in the why, flow, and context sections —
the why told as a problem solved or goal met, not technical mechanics; concrete named entry points in the handoff
section. Give every chart a scope label, and apply the template's diagram rule to every chart you draw: each box names
a component or a boundary, and the fields, types, and annotations go into the prose beneath the chart. When coverage is partial, place the coverage note immediately after the intro
paragraph so the reader calibrates before investing in the charts.

## Step 6: Resolve the Destination and Write the File

The file is named `code-overview-{short-target-slug}.md` wherever it lands. Only the directory is resolved here.

**Resolve the directory in this order:**

1. **A configured `output-directory`.** When the config read at the top of this skill supplied one, write the overview
   beneath it. Honor it even when it points inside the repository, and say nothing about that, BECAUSE the person who
   configured a destination chose it, and this skill's own default is not a veto over their choice. Relative-path
   resolution, `~` expansion, and precedence between the personal and project files are governed by
   [config-rule.md](../../references/config-rule.md); do not re-derive them here.
2. **No configured value.** Write outside the repository — for example
   `${TMPDIR:-/tmp}/code-overview-{short-target-slug}.md` — BECAUSE an unconfigured overview is an orientation aid
   rather than documentation, and a default inside the repository would land it in a commit sooner or later.

**When the resolved directory cannot be written**, write to the unconfigured default in 2 instead and record which
destination you could not use, so Step 8's message can name it. NEVER abandon the run over this, BECAUSE everything the
run produced is finished by the time it writes, and losing all of it to a directory that does not exist is the worse
outcome by far.

The next step reviews and rewrites this file in place.

## Step 7: Validate Accuracy, then Rewrite for Readability

This step runs two distinct passes, in order: the accuracy validator first, then the readability rewrite. Accuracy is
settled before readability so the editor never polishes a claim that is about to be cut.

**Pass 1 — accuracy.** Dispatch `han-core:adversarial-validator` over the draft overview. Pass it the overview file's
path from Step 6 and the resolved target (and, in PR mode, the changed-file set) so it knows what to re-read.

- **`han-core:adversarial-validator`** — assume every claim the overview makes about the code is WRONG until the code
  and its intent prove it right. Re-read the target (and the diff, in PR mode) and challenge each material claim,
  starting with the one the document leads on: is the stated **why** — the problem the code solves or the goal it serves
  — grounded in real evidence (commit messages, PR/issue intent, code comments, what the code visibly does toward that
  goal), or is it an invented business rationale, and where the why is inferred rather than stated, is it marked as
  inferred; does the code actually do what _Why it exists_ / _Why this change exists_ says; where the overview claims
  the code already satisfies the stated reason or does not support it, does the code show that, or is the code merely
  silent on the point — silence is not a contradiction, and a discrepancy claimed on silence is an inaccuracy to cut; does the **Main flow** /
  **How the change flows** chart match the real control flow, in the right order, with no invented or missing steps; do
  the named **Where to start** entry points exist and are they the right ones; does each **Changes by intent** grouping
  describe what that change actually does and the why it claims to serve; does every entry in **Context used** point at
  a source that exists (the file path resolves, the PR / issue / commit reference is real) — a fabricated or broken link
  is an inaccuracy like any other. Surface every claim that is unsupported,
  overstated, contradicted by the code, or hallucinated — the why most of all, since it is the load-bearing claim —
  citing the file, line, or commit that disproves it. **Validate the accuracy of the description only — do not assess
  the code's quality and do not raise findings about the code itself.** Return a list of inaccurate or unsupported
  claims, each with the corrected fact or a note that the claim should be cut.

Apply the validator's corrections to the overview file first: fix or cut every claim it disproved. A sentence that reads
beautifully but describes a flow the code does not follow must still be corrected or removed. If validation removed so
much that coverage is now meaningfully partial, add or update the coverage note.

**Pass 2 — readability rewrite.** Dispatch `han-communication:readability-editor` over the corrected draft. This
dedicated pass replaces the older information-architect / junior-developer readability review; the deliverable gets one
readability rewrite, not two overlapping reviews.

- **`han-communication:readability-editor`** — rewrite the overview against the shared readability standard for the
  default reader (a capable reader who did not do this work and lacks the author's context), preserving every fact. Pass
  it the overview file's path; the editor reads han-communication's own canonical rule, so pass no rule path. It operates
  on **prose regions only**: it does not touch the Mermaid chart bodies, code fences, or the embedded screenshot markup,
  and it leaves every named file, symbol, entry point, and `Context used` link target exact. It applies the rewrite to
  the overview file in place and returns a rubric verdict and a fact-preservation ledger. Tell it: **rewrite the
  overview document for readability only — do not review the underlying code, and do not raise findings about it.**
  This skill makes no quality judgment about the code; the validator guards truth, the editor guards clarity, and
  neither crosses into evaluating the work itself.

Keep the spec-content discipline through both passes: the result is still an orientation aid with no quality findings,
led by the why with everything flowing from it, minimal technical detail in the why/flow/context sections, and concrete
entry points in the handoff section.

**Readability self-check.** After the rewrite, run the standardized readability self-check (the shared standard is in
your context from `han-communication:readability-guidance`) over the overview's prose regions only — never inside the
Mermaid chart bodies, code fences, screenshot markup, or file/symbol references. Confirm each criterion and fix any
failure before presenting:

Run the readability rule's standardized self-check, which is already in your context from the
`readability-guidance` invocation above. Correct every failure before presenting. Its fidelity criterion is not
optional: the standard governs how the content is said, never whether a required fact about the code appears.

For this skill, the main point the opening line must state is what is being examined and why it exists.

**Required-content check.** Run this after the readability self-check, and after the accuracy pass, BECAUSE a check that
runs before the accuracy pass can confirm content that is about to be corrected or cut. Each item is a yes/no question
about the finished document. Fix every failure before presenting; never present a failure as a caveat.

1. **Diagrams.** Every chart's boxes name components and boundaries, with fields, types, signatures, and annotations in
   the prose beneath rather than inside a box. This is the one check that reads **inside** the chart bodies, which the
   readability self-check leaves alone by design.
2. **Starting points.** The entry points are numbered in reading order, each carries one line on what the reader learns
   there, and every entry point that is an interface other code calls carries one runnable example call.
3. **Terms the reader cannot look up.** Criterion 5 of the readability self-check above carries this one: every outside
   technology, language runtime, named method, and coined compound noun has its half-sentence explanation at first use.
   Confirm it passed rather than re-running it.
4. **The closing restatement.** The final section is present, runs three or four sentences, and carries no file paths,
   no type names, and no symbol names.

## Step 8: Present

Present a short message in this fixed order. The answer leads and the run's own bookkeeping comes last, BECAUSE this
message is the first thing the user reads and facts about how the run went are the last thing they need from it:

1. **The closing restatement**, copied from the overview's own final section. Repeat those sentences; never compose a
   second version of them.
2. **Any divergence from the change's stated purpose**, when the overview reported one (PR mode only).
3. **The path** to the overview file. When Step 6 fell back because the resolved destination could not be written, name
   the destination it could not use.
4. **The run's own facts, last:** the mode and size used and why, plus any coverage gap the overview noted.

Do not paste the whole overview into the conversation; point the user at the file, where the Mermaid charts render.

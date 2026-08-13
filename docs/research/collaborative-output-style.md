# Research: A Collaborative "Human in the Lead" Output Style

Can a custom output style carry a collaborative working mode where Claude builds one chunk of an implementation, walks
you through it, stops for your review, and folds your feedback into the next chunk? Evidence mode: strict.

## Summary

Build this as two pieces, not one. A short output style should carry the always-on stance: work in chunks, explain each
one as you finish it, stop and hand control back, and treat what comes back as direction for the next chunk. A companion
skill should carry the detailed procedure, because a style file is fixed text that cannot read your settings, pull in
other files, or hand work to a helper, and a skill can do all three. This mirrors the split this project already uses
for its readability standard.

One constraint shapes everything else: only one output style runs at a time. A collaboration style replaces the
readability style rather than sitting alongside it, so you have to decide whether to fold a condensed readability layer
into the new style or move readability into a file that loads on its own.

The biggest open question is whether an output style is a supported home for working-mode instructions at all.
Anthropic's documentation says output styles set role, tone, and format. But Anthropic's own code repository shows the
two styles closest to what you want, called Explanatory and Learning, were pulled out of the output-style mechanism and
rebuilt as startup hooks. Those two sources contradict each other and I could not settle which one is current.

No study anywhere measures how often stopping for review is worth the interruption. That part of the design rests on
converging practitioner guidance, not on measurement.

- **Confidence:** Medium

## Research Results

### What an output style is and what it is documented to do

An output style is a markdown file whose text gets added to the end of the system prompt at session start (A1, A8).
Anthropic's blog says output styles "carry the highest instruction-following weight of any method" for changing behavior
globally, and warns they "should be used judiciously" (A8). That is a point in favor of using one here.

Two limits matter immediately. First, a custom style drops Claude Code's built-in software-engineering instructions
(how to scope changes, comment conventions, security handling, verification habits) unless the file sets a flag to keep
them (A1, A8). Han's existing readability style already sets that flag (A31). Second, output styles reach the main
conversation only, because a subagent runs its own system prompt (A1).

The documentation scopes output styles to "role, tone, and output format," and its own comparison table separates them
from skills, which it describes as the mechanism for a reusable workflow (A1). Turn-taking and work sequencing sit on
the skill side of that line.

### Anthropic pulled the two closest styles off this mechanism

The strongest evidence against building the whole loop into an output style is what Anthropic did with its own similar
styles. The Explanatory style's plugin README states it "recreates the deprecated Explanatory output style as a
SessionStart hook" (A9). The Learning style's README states it "combines the unshipped 'Learning' output style with the
deprecated 'Explanatory' output style," also as a startup hook (A10). A startup hook is a script that fires when a
session begins and appends text to the default system prompt.

Learning is close kin to what you described: it pauses at decision points and asks the person to contribute code (A10).
That behavior did not ship as an output style.

This directly conflicts with the current documentation page, which still lists Explanatory and Learning as built-in
output styles (A1). Two Anthropic-controlled sources disagree, and the research did not find a changelog entry or
maintainer statement that resolves it. I record the conflict rather than picking a side.

### What Han already learned about output-style limits

Prior research in this repository established four hard limits, and they constrain the design directly (A38):

- An output style is fixed text added to the system prompt at session start. Nothing documents a way to include other
  files or run commands from it.
- The plugin path variable does not resolve inside an output-style file.
- Output styles do not reach subagents.
- Copying a whole standard into one block contradicts how that standard is meant to be applied, in stages.

That last point rests on a measured effect: instruction compliance falls from roughly 85 to 90 percent at one
instruction to between 15 and 44 percent when many are stacked (A39). The readability style is already 98 lines (A31).
A style that also carried a full collaborative procedure would roughly double that.

### Han's code-walkthrough skill already implements the pacing you want

The `code-walkthrough` skill runs exactly the turn-taking loop you described, through prose instruction alone (A33). It
directs one step per turn, then a stop, with the reasoning stated inline: "the pacing _is_ the deliverable." It also
handles the case where you ask a question instead of moving on, holding position rather than advancing.

This is local evidence that prose instruction can carry turn-taking in practice, which cuts against the pure
documentation-scope argument. What `code-walkthrough` does not do is run while code is being written. It is read-only,
retrospective, and walks through code that already exists (A33).

### Nothing in Han stops mid-implementation for collaborative review

The `tdd` skill runs autonomously after the initial request and states plainly that it "does not stop for confirmation"
(A34). Its one gate fires before implementation starts, and only when you explicitly ask to review the plan first. The
`code-overview` skill is read-only and writes a file without an interactive loop (A35).

The repository has a rule for stopping, but it is scoped narrowly. The operator-escalation rule allows exactly one stop
per run, and only when a missing input is something only you can supply (A36). A collaborative loop stops after every
chunk, which is a different thing entirely, so that rule does not govern it and would need a stated exception.

### Nothing can force a stop at a chunk boundary

Hooks are the one mechanism documented to apply "regardless of what Claude decides" (A5, A8). A pre-tool hook can block
a tool call outright. A post-tool hook fires after an edit but cannot undo or block it, because the tool already ran
(A2).

None of the hook events corresponds to "one logical chunk of implementation is finished." That is a judgment about
meaning, not a mechanical event. Plan mode is the only enforced stop in the product, and it gates the boundary between
planning and executing, once, not repeated review during a build (A7). Checkpointing is undo, not a review gate (A6).

So every option here ultimately relies on Claude following an instruction to stop. The options differ in how much
weight that instruction carries and how well it survives a long session, not in whether it can be enforced.

### How big a chunk should be

Practitioner and vendor guidance converge on task-shaped chunks rather than line counts (A12, A13, A14, A15). Anthropic's
own best-practices page says to skip the checkpoint for a change describable in one sentence and use it for anything
spanning multiple files or unfamiliar code (A12).

There is one empirical anchor on the review side. The Cisco code-review study found reviewers catch 70 to 90 percent of
defects when examining 200 to 400 lines over 60 to 90 minutes, with effectiveness dropping sharply past roughly 400
lines (A18). That study came to me through a blog's paraphrase rather than the original document [single-source].

Thoughtworks proposes a two-tier design worth borrowing: a frequent mechanical gate after each small test cycle, and a
coarser human gate at milestone boundaries where you review design and configuration choices (A13) [single-source].

### Feedback does not carry forward reliably on conversation history alone

This is the best-evidenced finding in the whole report, and it argues for writing feedback down. A peer-reviewed study
found model accuracy drops by more than 30 percent when the relevant information sits in the middle of a long context
rather than at either end, replicated across six model families (A23).

Anthropic's own documentation says the same thing in practical terms: after two failed corrections on the same point,
the context is "polluted with failed approaches," and a fresh session with a better opening prompt beats continuing to
correct in place (A12). The same docs distinguish conversation memory from a written file that reloads fresh each
session (A5).

One preprint claims a single explicit mid-session correction achieved complete repair in 30 of 30 sessions (A26). That
source is a single-author, unreviewed paper with promotional framing and no independent replication, so I carry it as a
directional hint only [single-source].

### The loop itself has a documented failure mode: you stop reading

Two recent studies measure how humans review AI-written code, and they disagree on direction. One found that among 400
repeat reviewers over 207 days, approval rates rose from 30.1 to 36.8 percent while inline comment volume fell 22
percent, which the authors read as habituation rather than earned trust (A16). A separate study using different data
found the share of merged agent pull requests receiving no human review fell from over half in mid-2025 to about 13
percent by February 2026, the opposite trend (A17).

Both authors flag that the underlying data is unstable under different but defensible analysis choices. There is no
settled answer on whether scrutiny is rising or falling.

What both agree on is the mechanism. Review load pushes toward either shallower reading or reviewer burnout, and
AI-written code's surface polish lowers your guard because it looks clean and idiomatic (A16, A17). Separately, frequent
approval prompts train people to stop reading and approve reflexively (A25), and vendor telemetry claims users approve
about 93 percent of permission prompts, with players in a threat-detection game missing one injected threat in three
(A30) [single-source, vendor telemetry].

That risk lands squarely on this design. A loop that narrates every chunk and asks for approval could produce the same
reflexive approval it was built to prevent.

### Narration might help you catch problems, or might not

The one data point on whether explaining a change improves the reviewer's catch rate is the Cisco study's finding that
author-annotated code showed lower defect density, never exceeding 30 defects per thousand lines (A18). The original
researchers were themselves unsure whether annotation caught defects early or made reviewers less critical by walking
them through a narrative (A18) [single-source].

Two collaboration models support narration on principle. Pair programming's driver and navigator split works because
articulating reasoning out loud "pushes us to reflect if we really have the right understanding" (A19), and an empirical
study found paired code cost about 15 percent more time while passing a significantly higher share of acceptance tests
(A22). Cognitive apprenticeship names articulation and reflection as two of six methods for making expert thinking
visible to a learner (A21).

What does not transfer: strong-style pairing exists to coach a junior human who retains the skill (A20), and cognitive
apprenticeship's other methods assume the expert can fade support as the learner improves (A21). Neither has an
equivalent when the party doing the explaining is an AI with no memory of what you already learned.

### Nobody has measured whether stopping is worth the interruption

I searched for a study comparing checkpoint frequencies in human-AI coding and found none. That is a negative result
worth stating plainly.

The nearest evidence is general interruption research: a field study of knowledge workers measured an average
23-minute-15-second lag to return to a task at the same focus level after an interruption (A24). That is not a study of
AI pairing, so applying it here is inference, not measurement.

## Options to Consider

### O1: One combined output style carrying readability and the collaborative loop

- **What it is:** A single new style file holding the readability standard plus the full chunk-explain-stop-incorporate
  procedure, replacing the current readability style.
- **Trade-offs:** Simplest to install and always on with nothing to invoke. But it stacks two full standards in one
  block, which is the pattern measured to drop compliance from 85 to 90 percent down to 15 to 44 percent (A39). It also
  contradicts the staged-application design the readability rule states for itself (A38), and it cannot read your
  configuration, pull in the writing-voice profile, or dispatch the readability editor (A38).
- **Rests on:** (A1, A8, A31, A38, A39)
- **Evidence status:** corroborated

### O2: A thin collaboration output style plus a companion skill

- **What it is:** A short style file carrying only the always-on stance (chunk the work, explain each chunk as you
  finish it, stop, absorb feedback), paired with a skill that owns the detailed procedure and does the runtime work a
  style cannot.
- **Trade-offs:** Mirrors the split this repository already uses and validated for readability, where the style carries
  the always-on layer and the guidance skill does the runtime work (A31, A38). Keeps the instruction count low enough to
  survive. The cost is two artifacts to build and keep in sync, and the deep behavior only arrives when the skill is
  invoked.
- **Rests on:** (A1, A3, A8, A31, A33, A38, A39)
- **Evidence status:** corroborated

### O3: A skill only, with no new output style

- **What it is:** Encode the whole loop as a skill you invoke when you want this working mode.
- **Trade-offs:** Skills are the mechanism the documentation names for a reusable workflow (A1, A3), and this is what
  `code-walkthrough` already does successfully for pacing (A33). But it is opt-in per session, which is the opposite of
  the always-on working mode you asked for, and the documentation warns a loaded skill's influence can quietly fade over
  a long session (A3).
- **Rests on:** (A1, A3, A33)
- **Evidence status:** corroborated

### O4: An output style plus a session-start hook

- **What it is:** Follow the pattern Anthropic used for Explanatory and Learning: implement the behavior as a script
  that fires at session start and appends instructions to the default system prompt (A9, A10).
- **Trade-offs:** This is the pattern Anthropic itself moved to for exactly this class of behavior, which is the
  strongest prior-art signal available. It also adds to the default prompt rather than replacing it, so built-in
  engineering instructions survive without a flag (A9). Against it: Han ships no hooks today, it adds a script to
  maintain, and the hook still only appends text, so it enforces nothing more than a style file does.
- **Rests on:** (A2, A5, A8, A9, A10)
- **Evidence status:** corroborated

### O5: A collaboration output style with readability moved into an imported memory file

- **What it is:** Let the new style own the collaborative loop alone, and carry the readability standard through an
  import in your own memory file so both apply at once.
- **Trade-offs:** Solves the one-style-at-a-time constraint directly, and Han's prior research already named this import
  route as a viable option (A38). The cost is real: memory content is documented as "context, not enforced
  configuration," with no guarantee of strict compliance (A5), so readability would carry less weight than it does in
  the system prompt today.
- **Rests on:** (A1, A5, A38)
- **Evidence status:** corroborated

### O6: Extend `code-walkthrough` to run concurrently during implementation

- **What it is:** Change the existing walkthrough skill from retrospective to concurrent, so it walks you through code
  as it is written rather than after.
- **Trade-offs:** Reuses a loop that already works and is already documented. But `code-walkthrough` is explicitly
  read-only and "never edits the target" (A33), so this inverts its stated contract and collides with its declared
  boundary against sibling skills. It also remains opt-in rather than always-on.
- **Rests on:** (A33, A35)
- **Evidence status:** corroborated

### O7: An output style plus a post-edit hook that injects a checkpoint reminder

- **What it is:** Add a hook after file edits that injects a reminder to pause and explain.
- **Trade-offs:** Hooks are the only mechanism that applies regardless of what Claude decides (A5, A8). But no hook
  event corresponds to a logical chunk boundary, and a post-tool hook cannot block or undo the edit that already ran
  (A2). Firing after every edit would interrupt far more often than the chunk boundary you want.
- **Rests on:** (A2, A5, A8)
- **Evidence status:** corroborated

## Recommendation

- **Recommendation:** O2, paired with the O5 decision on where readability lives. Build a short collaboration output
  style carrying the always-on stance, and a companion skill carrying the loop procedure and the runtime work a style
  file cannot do. Then decide separately whether readability rides along in a condensed form inside the new style, or
  moves into an imported memory file so it survives the style switch.

- **Evidence basis:** The split rests on corroborated evidence from three directions. The documentation separates output
  styles (role, tone, format) from skills (reusable workflow) as different mechanisms (A1), and Anthropic's blog
  independently describes styles as the highest-weight but judiciously-used global lever (A8). Han's own prior research
  independently established the four things a style cannot do, and its own readability implementation already proves the
  thin-style-plus-skill pattern works in this repository (A31, A38). The instruction-stacking measurement that rules out
  the one-big-style option is corroborated across Han's two prior research reports (A38, A39).

  Two supporting design choices rest on weaker footing and should be treated that way. The chunk-size target of roughly
  200 to 400 lines comes from a single study I could only read through a blog's paraphrase (A18) [single-source]. The
  two-tier gate structure comes from one vendor's writing with no independent replication (A13) [single-source]. The
  task-shaped chunk heuristic is convergent practitioner guidance with no outcome data behind it (A12, A13, A14, A15).

  Writing feedback into a durable file rather than trusting conversation history is the best-evidenced single design
  decision here, resting on peer-reviewed research on long-context attention (A23) plus vendor documentation that states
  the same limit against its own product's convenience (A5, A12).

  What the recommendation does not settle: whether an output style is a currently-supported home for this behavior at
  all. Anthropic's documentation (A1) and Anthropic's code repository (A9, A10) contradict each other on whether the two
  closest styles were deprecated. If A9 and A10 reflect current reality, O4's session-start hook is the pattern Anthropic
  itself landed on, and O2's style half should become a hook instead. The skill half of the recommendation is unaffected
  either way. The evidence that would settle it is a changelog entry, release note, or maintainer statement on the status
  of the built-in Explanatory and Learning styles.

## Validation

<!-- adversarial-validator findings pending -->

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:** Pending validation.

## Sources

| ID  | Source                                       | Link / location                                                                                        | Retrieved  | Trust class | Summary (one line)                                                                                          | Evidence status                                    |
| --- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ---------- | ----------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| A1  | Claude Code docs: Output styles              | https://code.claude.com/docs/en/output-styles                                                          | 2026-08-13 | web         | Styles append to the system prompt, set role/tone/format, drop built-in coding instructions by default, main conversation only. | corroborated by A8; contradicted by A9, A10        |
| A2  | Claude Code docs: Hooks                      | https://code.claude.com/docs/en/hooks                                                                  | 2026-08-13 | web         | ~30 hook events; pre-tool can block, post-tool cannot because the tool already ran.                          | corroborated by A3, A5, A8                         |
| A3  | Claude Code docs: Skills                     | https://code.claude.com/docs/en/skills                                                                 | 2026-08-13 | web         | Skills are loaded instructions for reusable workflows; influence can fade over a session without error.      | corroborated by A2, A5                             |
| A4  | Claude Code docs: Subagents                  | https://code.claude.com/docs/en/sub-agents                                                             | 2026-08-13 | web         | Subagents run their own system prompt and return only a final message.                                        | corroborated by A1, A8                             |
| A5  | Claude Code docs: Memory                     | https://code.claude.com/docs/en/memory                                                                 | 2026-08-13 | web         | CLAUDE.md is context, not enforced configuration; use hooks for anything that must run at a fixed point.      | corroborated by A2, A8, A12                        |
| A6  | Claude Code docs: Checkpointing              | https://code.claude.com/docs/en/checkpointing                                                          | 2026-08-13 | web         | Snapshots for undo and rewind; not a pause-for-review gate.                                                   | single source (primary doc for the feature)        |
| A7  | Claude Code docs: Permission modes           | https://code.claude.com/docs/en/permission-modes                                                       | 2026-08-13 | web         | Plan mode is a real enforced stop, but gates planning versus executing, once.                                 | single source (primary doc for the feature)        |
| A8  | Anthropic blog: Steering Claude Code         | https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more                     | 2026-08-13 | web         | Output styles carry the highest instruction-following weight; hooks are for deterministic behavior.            | corroborated by A1, A2, A5                         |
| A9  | anthropics/claude-code: explanatory plugin   | https://github.com/anthropics/claude-code/tree/main/plugins/explanatory-output-style                   | 2026-08-13 | web         | States it recreates the "deprecated Explanatory output style" as a SessionStart hook.                         | contradicts A1; corroborated by A10                |
| A10 | anthropics/claude-code: learning plugin      | https://github.com/anthropics/claude-code/tree/main/plugins/learning-output-style                      | 2026-08-13 | web         | States it combines the "unshipped Learning" and "deprecated Explanatory" styles as a SessionStart hook.        | contradicts A1; corroborated by A9                 |
| A11 | GitHub issue: output styles ignored (#6450)  | https://github.com/anthropics/claude-code/issues/6450                                                  | 2026-08-13 | web         | One user reports a custom style's tone instructions being overridden; closed "not planned".                     | single source (caveated, community anecdote)       |
| A12 | Claude Code docs: Best practices             | https://code.claude.com/docs/en/best-practices                                                         | 2026-08-13 | web         | Skip checkpoints for one-sentence changes; after two failed corrections, context is polluted, start fresh.     | corroborated by A5, A23                            |
| A13 | Thoughtworks: review gates for AI dev        | https://www.thoughtworks.com/insights/blog/generative-ai/how-to-implement-effective-review-gates-for-ai-assisted-development | 2026-08-13 | web | Two-tier gate: mechanical inner gate per cycle, human outer gate at milestones.                              | single source (caveated) for the two-tier design   |
| A14 | Addy Osmani: LLM coding workflow 2026        | https://addyo.substack.com/p/my-llm-coding-workflow-going-into                                          | 2026-08-13 | web         | Two or three human checkpoints per feature; trim older context to keep pause-and-resume clean.                 | corroborated by A13, A15                           |
| A15 | systemdesign.one: AI coding workflow         | https://newsletter.systemdesign.one/p/ai-coding-workflow                                               | 2026-08-13 | web         | Implement one step at a time; asking for too much at once produces output that is hard to untangle.            | corroborated by A13, A14                           |
| A16 | Habituation at the Gate (arXiv 2606.22721)   | https://arxiv.org/pdf/2606.22721                                                                       | 2026-08-13 | web         | 400 repeat reviewers over 207 days: approval up 30.1% to 36.8%, inline comments down 22%.                       | contradicted in direction by A17                   |
| A17 | 3100 Opinions on Code Review (arXiv 2607.07980) | https://arxiv.org/pdf/2607.07980                                                                    | 2026-08-13 | web         | Grounded theory from 3,100 documents; AI code's surface polish lowers scrutiny; unreviewed merges fell to ~13%. | contradicts A16 on trend; corroborates mechanism   |
| A18 | Cisco / SmartBear code review study          | https://mikeconley.ca/blog/2009/09/14/smart-bear-cisco-and-the-largest-study-on-code-review-ever/       | 2026-08-13 | web         | 70-90% defect discovery at 200-400 LOC over 60-90 min; author annotation lowered defect density.               | single source (caveated, read as paraphrase)       |
| A19 | Martin Fowler: On Pair Programming           | https://martinfowler.com/articles/on-pair-programming.html                                             | 2026-08-13 | web         | Driver and navigator roles; articulating reasoning forces you to check your own understanding.                 | corroborated by A20, A22                           |
| A20 | Llewellyn Falco: strong-style pairing        | http://llewellynfalco.blogspot.com/2014/06/llewellyns-strong-style-pairing.html                        | 2026-08-13 | web         | An idea must pass through someone else's hands; originally a coaching technique for juniors.                   | single source (caveated, practitioner blog)        |
| A21 | Cognitive Apprenticeship (Collins et al.)    | https://www.isls.org/research-topics/cognitive-apprenticeship/                                          | 2026-08-13 | web         | Six methods including articulation and reflection for making expert thinking visible.                          | single source (caveated, read via summaries)       |
| A22 | Cockburn & Williams, XP2000                  | https://www.cs.utexas.edu/~ans/classes/cs439/projects/XPSardinia.PDF                                   | 2026-08-13 | web         | Pairing costs ~15% more time; paired code passed a significantly higher share of acceptance tests.              | corroborated by A19                                |
| A23 | Lost in the Middle (Liu et al., TACL)        | https://arxiv.org/abs/2307.03172                                                                       | 2026-08-13 | web         | Accuracy drops >30% when relevant information sits mid-context; replicated across six model families.          | corroborated by A5, A12                            |
| A24 | Gloria Mark: Cost of Interrupted Work        | https://ics.uci.edu/~gmark/chi08-mark.pdf                                                              | 2026-08-13 | web         | Average 23-minute-15-second resumption lag after an interruption in general knowledge work.                     | single source (caveated for this application)      |
| A25 | WorkOS: approval fatigue in agent governance | https://workos.com/blog/approval-fatigue-agent-governance                                              | 2026-08-13 | web         | Frequent approval prompts lead users to stop reading and approve reflexively.                                  | single source (caveated, vendor writing)           |
| A26 | The Compliance Gap (arXiv 2605.01771)        | https://arxiv.org/abs/2605.01771                                                                       | 2026-08-13 | web         | Claims one explicit mid-session correction repaired compliance in 30 of 30 sessions.                            | single source (caveated, low confidence)           |
| A27 | Parasuraman & Riley, Human Factors 1997      | https://journals.sagepub.com/doi/10.1518/001872097778543886                                            | 2026-08-13 | web         | Names automation misuse (over-reliance, complacency) as a distinct human-automation failure mode.               | corroborated (cited by A16 and A26)                |
| A28 | Collaborator or Assistant? (arXiv 2605.08017)| https://arxiv.org/html/2605.08017                                                                      | 2026-08-13 | web         | Agents initiate ≥96% of PRs but approve merges in <0.1%; humans retain terminal authority.                      | single source (caveated for exact figures)         |
| A29 | Reddit threads on shipping in small chunks   | https://www.reddit.com/r/ClaudeAI/comments/1ro12vz/how_to_tell_your_coding_agent_to_ship_features_in/  | 2026-08-13 | web         | Confirms this exact workflow is a live named practitioner concern.                                              | single source (caveated, community anecdote)       |
| A30 | Scale X: AI agent permission telemetry       | https://scalex.dev/blog/ai-agent-permissions-stats/                                                    | 2026-08-13 | web         | Reports users approve ~93% of permission prompts; game players missed 1 injected threat in 3 (66.3% accuracy).   | single source (caveated, vendor telemetry)         |
| A31 | Han readability output style                 | `han-communication/output-styles/han-readability.md:1-98`                                              | n/a        | codebase    | 98 lines directing prose properties only; sets the keep-coding-instructions flag; no behavioral direction.       | corroborated by A32, A38                           |
| A32 | han-communication plugin manifests           | `han-communication/.claude-plugin/plugin.json`                                                          | n/a        | codebase    | Output styles are auto-discovered from `output-styles/`; no manifest field declares them.                       | corroborated by A31                                |
| A33 | code-walkthrough skill                       | `han-coding/skills/code-walkthrough/SKILL.md:1-234`                                                     | n/a        | codebase    | One step per turn then stop; a question holds position; read-only and never edits the target.                    | corroborated by A34, A35                           |
| A34 | tdd skill                                    | `han-coding/skills/tdd/SKILL.md:75-87`                                                                  | n/a        | codebase    | Runs autonomously and does not stop for confirmation; one gate, only before implementation, only on request.     | corroborated by A35                                |
| A35 | code-overview skill                          | `han-coding/skills/code-overview/SKILL.md:1-100`                                                        | n/a        | codebase    | Read-only, writes a scratch file, no interactive loop; defers pacing to code-walkthrough.                        | corroborated by A33                                |
| A36 | operator-escalation rule                     | `han-planning/references/operator-escalation-rule.md:16-100`                                            | n/a        | codebase    | One question per turn; exactly one stop per run, only for input only the operator can supply.                    | corroborated by A37                                |
| A37 | explanation rule                             | `han-communication/references/explanation-rule.md:1-89`                                                 | n/a        | codebase    | Concrete outcome over mechanism; no shorthand terms; consequence before detail; no self-check.                   | corroborated by A36                                |
| A38 | Prior research: readability in output styles | `docs/research/readability-guidance-in-output-styles.md:27-113`                                         | n/a        | codebase    | Styles are fixed text: no file includes, no path variable, no subagent reach, no runtime config reads.           | corroborated by A1, A39                            |
| A39 | Prior research: human-readable standard      | `docs/research/human-readable-output-standard.md:37-41`                                                 | n/a        | codebase    | Compliance falls from 85-90% at one instruction to 15-44% when many are stacked; audience framing is strongest.  | corroborated by A38                                |
| A40 | Prior research: LLM code understanding       | `docs/research/llm-accelerated-code-understanding.md:1-71`                                               | n/a        | codebase    | AI speeds tasks without improving comprehension; high-comprehension users verified output 4.7x more often.       | corroborated by A17                                |
| A41 | Han documentation obligations                | `CLAUDE.md:80-81,301-302`                                                                               | n/a        | codebase    | A new output style needs the style file, a long-form doc, and a plugin README scent line; no repo-root index yet. | single source (project convention)                 |

### A1: Claude Code documentation on output styles — recommendation-bearing

- **Link / location:** https://code.claude.com/docs/en/output-styles
- **Retrieved:** 2026-08-13
- **Trust class:** web (outside the trust boundary)
- **Summary:** States output styles "change how Claude responds, not what Claude knows" and "modify the system prompt to
  set role, tone, and output format." A custom style is a markdown file in a personal, project, or plugin
  `output-styles/` directory, and Claude Code "adds each output style's custom instructions to the end of the system
  prompt." Unless the file sets `keep-coding-instructions: true`, the style leaves out the built-in software-engineering
  instructions covering how to scope changes, when to add comments, security concerns, and verification habits. Styles
  apply to the main conversation only, because subagents run their own system prompt. The page's comparison table places
  output styles apart from skills, which it describes as the mechanism for a reusable workflow. It lists Proactive,
  Explanatory, and Learning as built-in styles beyond Default.
- **Evidence status:** corroborated by A8 on the injection mechanics and the role/tone/format scope; contradicted by A9
  and A10 on whether Explanatory and Learning are currently shipped as output styles

### A8: Anthropic blog on steering Claude Code — recommendation-bearing

- **Link / location:** https://claude.com/blog/steering-claude-code-skills-hooks-rules-subagents-and-more
- **Retrieved:** 2026-08-13
- **Trust class:** web (vendor writing, outside the trust boundary)
- **Summary:** Describes output styles as files that "inject instructions into the system prompt," never get compacted,
  and "carry the highest instruction-following weight of any method," with the caution that they "should be used
  judiciously" and that a custom style "drops all of this" (the built-in engineering instructions) unless configured to
  keep them. Directs hooks at "anything that should happen deterministically" and notes a pre-tool hook can inspect a
  call and block it. Describes CLAUDE.md as loading into context at session start and staying for the session, and
  subagents as returning only a final message to the main session.
- **Evidence status:** corroborated by A1 on output-style mechanics, and by A2 and A5 on hook determinism

### A9: Anthropic's explanatory-output-style plugin — recommendation-bearing

- **Link / location:** https://github.com/anthropics/claude-code/tree/main/plugins/explanatory-output-style
- **Retrieved:** 2026-08-13
- **Trust class:** web (Anthropic's own repository, but a plugin artifact rather than canonical documentation)
- **Summary:** The README states verbatim that the plugin "recreates the deprecated Explanatory output style as a
  SessionStart hook," authored by an Anthropic employee per the plugin manifest. It implements the behavior through a
  session-start hook rather than the `output-styles/` directory, and frames that pattern as "roughly equivalent to
  CLAUDE.md, but more flexible and allows for distribution through plugins." It adds that behavior involving tasks
  besides software development is "better expressed as subagents, not as SessionStart hooks," because "Subagents change
  the system prompt while SessionStart hooks add to the default system prompt."
- **Evidence status:** contradicts A1's listing of Explanatory as a current built-in output style; corroborated by A10

### A10: Anthropic's learning-output-style plugin — recommendation-bearing

- **Link / location:** https://github.com/anthropics/claude-code/tree/main/plugins/learning-output-style
- **Retrieved:** 2026-08-13
- **Trust class:** web (Anthropic's own repository, plugin artifact)
- **Summary:** The README states verbatim that the plugin "combines the unshipped 'Learning' output style with the
  deprecated 'Explanatory' output style," again implemented as a session-start hook. Its behavior is close kin to the
  requested loop: it identifies "meaningful 5-10 line code contributions at decision points" for the person to write,
  implements boilerplate directly, and adds periodic explanations. By this source, the collaborative pause-at-decision-
  points behavior that Anthropic's documentation describes as a built-in output style was never shipped that way.
- **Evidence status:** contradicts A1's listing of Learning as a current built-in output style; corroborated by A9

### A23: Lost in the Middle (Liu et al., TACL) — recommendation-bearing

- **Link / location:** https://arxiv.org/abs/2307.03172
- **Retrieved:** 2026-08-13
- **Trust class:** web (peer-reviewed journal paper, the strongest-tier source in this report)
- **Summary:** Model performance on long-context tasks follows a U-shaped curve by position. Accuracy is highest when
  the relevant information sits at the beginning or the end of the context and degrades by more than 30 percent when it
  sits in the middle. The finding was replicated across six model families. This is the load-bearing evidence for
  writing feedback into a durable file rather than relying on it surviving in the middle of a long conversation. I read
  secondary write-ups rather than the primary journal article, though the finding is consistently reported across
  independent summaries.
- **Evidence status:** corroborated by A5 and A12, which state the same practical limit in vendor documentation

### A31: Han's existing readability output style — recommendation-bearing

- **Link / location:** `han-communication/output-styles/han-readability.md:1-98`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** A 98-line file with frontmatter carrying a name, a description, and the keep-coding-instructions flag,
  followed by prose directives. It directs prose properties only, never behavior or working mode: main point first, one
  idea per paragraph, descriptive headings, short active sentences, common words, numbered lists for steps, progressive
  disclosure, and technical detail after the prose. Its closing section scopes everything to prose, excluding code
  fences, diagram bodies, rendered markup, and citation identifiers. This is the working example of the thin-style
  pattern the recommendation extends.
- **Evidence status:** corroborated by A32 on how it is wired, and by A38 on the design reasoning behind its scope

### A33: Han's code-walkthrough skill — recommendation-bearing

- **Link / location:** `han-coding/skills/code-walkthrough/SKILL.md:1-234`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Implements the turn-taking loop the request describes, through prose instruction alone. It directs
  "One step per turn, then stop and wait," forbids chaining two steps, and states the reasoning inline: "the pacing _is_
  the deliverable." A question about the current step holds position rather than advancing, and the step counter does
  not move. It is read-only and "never edits the target and never writes a file," which is why it covers retrospective
  walkthroughs rather than walking through code as it is written. It sources the explanation standard and dispatches
  codebase-explorer agents, both of which a style file could not do.
- **Evidence status:** corroborated by A34 and A35, which show the neighboring skills carry no comparable loop

### A38: Prior Han research on readability guidance in output styles — recommendation-bearing

- **Link / location:** `docs/research/readability-guidance-in-output-styles.md:27-113`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Establishes four limits on what an output style can carry in this project. A style is fixed text added
  to the system prompt at session start, with nothing documented for including other files or running commands. The
  plugin path variable does not resolve inside a style file. Styles do not reach subagents. And copying a whole standard
  into one block contradicts the standard's own staged design, because compliance drops when instructions stack. It
  records that the readability rule and writing-voice profile together run 33,439 bytes, and recommends a short style
  carrying the always-on layer only, leaving runtime work to the skill. It also names an import in the personal memory
  file as a route to reach subagents.
- **Evidence status:** corroborated by A1 on style mechanics, and by A39 on the instruction-stacking measurement

### A39: Prior Han research on the human-readable output standard — recommendation-bearing

- **Link / location:** `docs/research/human-readable-output-standard.md:37-41`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Reports that instruction compliance drops from 85 to 90 percent at one instruction to between 15 and 44
  percent when many are stacked, and that the fix is to split work across passes rather than issuing one block. It also
  records that audience targeting is the single most-evidenced instruction for plain output, backed by three independent
  clinical studies, and that few-shot examples beat abstract instructions. These findings are why the recommendation
  keeps the new style short rather than folding a full procedure into it.
- **Evidence status:** corroborated by A38, which applies the same finding to output-style design

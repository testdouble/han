# Han Release Notes

## v5.4.0

han 5.4.0 fixes the personal-config probe that broke in every skill at once, and adds a second output style to the
communication layer. On Claude Code 2.1.228 the inline probe carried by every Project Context block stopped loading and
reported a "Contains expansion" error, which [@VikiAnn](https://github.com/VikiAnn) reported in issue #178 and PR #184
fixed by moving the probe into a shared `scripts/han-config-dir.sh` that every plugin symlinks to. That one change is
why all twelve children move this release. `han-communication` (1.2.0) ships the `han-concise` output style and promotes
technical-detail separation into the canonical readability rule. `han-coding` (3.3.0) gates out-of-scope production
changes in `/tdd` and `/automated-test-planning`. `han-plugin-builder` (2.2.0) adds an authoring rule for reaching an
environment variable, and gives the guidance corpus tables of contents. `han-core` (3.1.1), `han-documentation` (1.0.1),
`han-research` (1.0.1), `han-planning` (2.2.1), `han-github` (2.3.1), `han-reporting` (2.2.1), `han-feedback` (2.0.2),
`han-atlassian` (2.3.1), and `han-linear` (1.1.1) carry the config-script change, the re-synced rule files, and their own
small fixes.

### han v5.4.0

#### One shared script replaces the inline config probe

Every skill carrying a Project Context block read the personal configuration directory with an inline
`echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"`. Claude Code 2.1.228 refused that form with a "Contains expansion" error,
so the block failed to load and the skill lost its personal configuration.
[@VikiAnn](https://github.com/VikiAnn) reported it in issue #178, and PR #184 replaced the inline probe with
`scripts/han-config-dir.sh` at the repository root. Every plugin carries a symlink to that one script, and
`scripts/han-config-dir.bats` tests it beside it.

`CLAUDE.md` and `CONTRIBUTING.md` record the script, the symlink each plugin carries, and where its tests live.
`CONTRIBUTING.md` also gains an "Adding an output style" checklist, so a second style cannot ship without a long-form
doc and a plugin README scent line, and `docs/templates/coverage-rule.md` extends the coverage rule to output styles for
the same reason.

#### The readability docs describe the reworked standard

`docs/readability.md` covers the reworked standard: the new technical-detail-separation property, the criterion for
honoring a shape the reader asked for, and the `han-concise` output style beside `han-readability`.
`docs/configuration.md`, `docs/concepts.md`, and `docs/choosing-a-han-plugin.md` thread the new style and the shared
config script through the catalogs, and `docs/local-development.md` corrects the local setup steps.

#### The planning artifacts behind the readability work

`docs/plans/readability-reader-format-requests/` records the specification, the implementation plan, the decision logs,
the team findings, the test plan, the scope boundary, and the discovery notes behind this release's readability changes.

#### A closing sweep corrected documentation drift

Commit `cf60c24` fixed drift across the long-form docs: the `han-atlassian` dependency list in six docs, the dispatch
lists in four agent docs, the missing sibling boundaries in two more, and the plugin map in `CONTRIBUTING.md`.

### han-communication v1.2.0

#### han-concise is a second output style that rolls detail up

`han-communication/output-styles/han-concise.md` carries the readability rule and the writing voice, plus two departures
that belong to it alone. A turn drops preamble and recap and spends no sentence carrying neither a fact nor a needed
transition. And in place of `Fidelity wins`, detail rolls up into the statement it supports, on the assumption that the
reader wants less than the source holds.

A floor bounds the roll-up. It keeps a fact whose loss would change what you do next, a number you will act on, and a
stated condition that bounds a claim. The self-check keeps the readability rule's eight criteria with the seventh
rewritten for the roll-up, so everything else stays in sync with `han-readability`. A long-form doc ships beside the
style at `han-communication/docs/output-styles/han-concise.md`.

#### Technical detail now sits after the prose, not inside it

`references/readability-rule.md` gains technical-detail separation as a property of the canonical standard. Prose says
what happens in plain sentences, and symbol names, file paths, flags, and snippets come after it rather than threaded
through it. `han-readability` and the `readability-editor` agent gained the same property, so all three surfaces apply
it the same way.

#### The shape you asked for wins

The self-check gained a criterion for matching a shape you stated: the count, the format, and the register you asked
for. When it genuinely collides with another criterion, your stated shape wins.
[@mxriverlynn](https://github.com/mxriverlynn) reported the gap in issue #177, and PR #186 fixed it. The self-check also
stopped naming a fixed number of criteria, so the standard can grow without every consuming skill going stale.

`references/writing-voice.md` adds stale figures of speech and foreign, Latinate, and archaic diction to the blocklist.
The three skills (`edit-for-readability`, `explanation-guidance`, `readability-guidance`) and `references/config-rule.md`
pick up the shared config-directory script.

### han-coding v3.3.0

#### /tdd and /automated-test-planning stop at the edge of their scope

Both skills could change production code the request never asked about, on the way to making a test pass.
[@mxriverlynn](https://github.com/mxriverlynn) reported it in issue #188, and PR #191 added a scope gate to `/tdd` and
carried the supporting detail into `tdd/references/failure-modes.md`, `tdd/references/test-selection.md`, and
`automated-test-planning/references/template.md`.

`/code-review` gained material across five reference files: `agent-dispatch.md`, `agent-finding-classification.md`,
`finding-content.md`, `output-verification.md`, and `review-checklist.md`. Every skill picked up the shared
config-directory script, and the four vendored rule files (`collaborative-stop-rule.md`, `config-rule.md`,
`evidence-rule.md`, `yagni-rule.md`) re-synced with their canonical copies.

### han-plugin-builder v2.2.0

#### Reach an environment variable through a script, not through probe text

`skill-building-guidance/context-injection-commands.md` documents the new rule with a results table measured on Claude
Code 2.1.234, showing which probe forms the loader accepts and which it refuses. That is the same failure Han's own
skills hit in issue #178, written down so a new skill does not repeat it. `skill-reference-files.md` and
`troubleshooting.md` both expand substantially.

#### The guidance corpus carries tables of contents

[@kasparovabi](https://github.com/kasparovabi) reported in issue #182 that 111 reference files had no table of contents
and one description ran 411 characters over the 1024-character limit. PR #192 gave every reference file that lacked one
a table of contents.

### han-planning v2.2.1

Two defects in the visual-material reference material are fixed. The truncated `Visual Reference` invariant is restored,
and the empty visual table is now bounded. [@mxriverlynn](https://github.com/mxriverlynn) reported both in issue #187,
and PR #190 fixed them.

`references/operator-escalation-rule.md`, `references/planning-boundary-rule.md`, and
`references/scope-justification-rule.md` gained small clarifications, the vendored rules re-synced, and all five skills
picked up the shared config-directory script.

### han-core v3.1.1

`/pairing` resolves its config directory through the shared script instead of an inline probe, and both skills pick up
that script. The four canonical rule files (`collaborative-stop-rule.md`, `config-rule.md`, `evidence-rule.md`,
`yagni-rule.md`) gained the config-script contract and this release's readability changes, which is what the other
plugins re-synced against.

### han-documentation v1.0.1

`project-documentation` had a generation-time sentence restored that an earlier edit dropped. Skills picked up the
shared config-directory script, and the vendored rules re-synced.

### han-research v1.0.1

Every skill picked up the shared config-directory script, and the vendored rule files re-synced with their canonical
copies.

### han-github v2.3.1

Every skill picked up the shared config-directory script, and the vendored rule files re-synced.
`update-pr-description/references/screenshot-embed-rules.md` gained material.

### han-reporting v2.2.1

Every skill picked up the shared config-directory script, and the vendored rule files re-synced. The `html-summary`
references `layout-principles.md` and `report-style.md` both gained material.

### han-feedback v2.0.2

The skill picked up the shared config-directory script, and the vendored rule files re-synced.

### han-atlassian v2.3.1

Every skill picked up the shared config-directory script, and the vendored rule files re-synced. The six long-form docs
had their dependency list corrected to name all five dependencies.

### han-linear v1.1.1

The skill picked up the shared config-directory script, and the vendored rule files re-synced.

### Issues closed in this release

- Personal-config context probe fails to load on Claude Code 2.1.228, "Contains expansion", breaks every skill with a Project Context block (#178) — opened by [@VikiAnn](https://github.com/VikiAnn); fixed in #184 by [@mxriverlynn](https://github.com/mxriverlynn)
- Han Feedback: han-readability (2026-08-11) (#177) — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #186 by [@mxriverlynn](https://github.com/mxriverlynn)
- Skill guidance check: one description 411 characters over the 1024 limit, 111 reference files without a table of contents (#182) — opened by [@kasparovabi](https://github.com/kasparovabi); fixed in #192 by [@mxriverlynn](https://github.com/mxriverlynn)
- Han Feedback: plan-a-feature-readability-guidance-explanation-guidance (2026-08-19) (#187) — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #190 by [@mxriverlynn](https://github.com/mxriverlynn)
- Han Feedback: automated-test-planning-tdd (2026-08-19) (#188) — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #191 by [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- Han config expansion fix (#184) — [@mxriverlynn](https://github.com/mxriverlynn)
- feat(han-communication): honor the shape the reader asked for (#186) — [@mxriverlynn](https://github.com/mxriverlynn)
- feat(han-communication): add the han-concise output style and tighten technical-detail separation (#189) — [@mxriverlynn](https://github.com/mxriverlynn)
- fix(han-planning): correct two defects in the visual-material reference material (#190) — [@mxriverlynn](https://github.com/mxriverlynn)
- fix(han-coding): gate out-of-scope production changes in tdd and automated-test-planning (#191) — [@mxriverlynn](https://github.com/mxriverlynn)
- fix(han): bring skills back under Anthropic's authoring limits (#192) — [@mxriverlynn](https://github.com/mxriverlynn)
- V5.4.0 beta (#185) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/han--v5.4.0/CHANGELOG.md#v540

## v5.3.0

han 5.3.0 adds a collaborative working mode to the suite. `/pairing` builds work in reviewable pieces and hands each one
back before starting the next, so you steer while the work happens instead of reviewing a finished result, and it covers
code, design decisions, and writing alike. `han-core` (3.1.0) ships the skill and the shared stop contract behind it.
`han-coding` (3.2.0) and `han-planning` (2.2.0) wire five existing skills to hand control back at boundaries they
already had, so `/pairing` drives them without either side inventing a second mechanism. The suite-level docs thread the
new mode through every catalog, and this release also repairs three defects the pairing branch left in its own
documentation. `han-communication` (1.1.1), `han-documentation` (1.0.0), `han-research` (1.0.0), `han-github` (2.3.0),
`han-reporting` (2.2.0), `han-feedback` (2.0.1), `han-atlassian` (2.3.0), `han-linear` (1.1.0), and `han-plugin-builder`
(2.1.0) are unchanged.

### han v5.3.0

#### The cross-plugin catalogs carry the pairing mode

`docs/skills/README.md` gains a scent line for `/pairing`. `docs/concepts.md` and `README.md` add it to the sentence
describing what `han-core` carries, and `docs/choosing-a-han-plugin.md` adds it in four places, including the install
table row for the shared agents and project discovery. That page also promised an install of `han-core` alone gave you
"no other skills", which stopped being true the moment `/pairing` landed there.

`docs/workflows.md` draws `/pairing` into both diagrams as a dotted `drives` edge rather than a solid arrow, because it
wraps the skills it runs rather than chaining after them. The planning diagram draws it driving `/plan-implementation`,
`/iterative-plan-review`, and `/tdd`; the code-quality diagram draws it driving `/refactor`, `/tdd`, and
`/design-an-api`. The prose beside each says the same thing in words, and names the wrapper relationship explicitly so
the dotted edge is not read as a chain.

`CLAUDE.md` adds `/pairing` to the `han-core` catalog and gains a Collaborative working mode section pointing at the
canonical stop rule and naming the skills that consume it.

#### The planning and research artifacts behind the skill

`docs/plans/pairing-skill/` records the specification, the implementation plan, and the decision, scope, and iteration
artifacts, including the rename from `pair-with-me` and the boundary widening from code work to any kind of work.
`docs/research/collaborative-output-style.md` and `docs/research/non-code-chunk-boundaries.md` carry the evidence the
design rests on, both adversarially validated.

### han-core v3.1.0

#### /pairing builds work in reviewable pieces you steer

`/pairing` splits a request into concerns, sorts each one, proposes a plan before any work starts, then builds one piece
at a time and ends the turn after each. The pacing is the deliverable rather than an interruption in it, so the skill
never continues past a stop to be helpful.

Splitting comes before sorting. Two asks that produce two things you would check separately are two concerns, and
changing code and answering a question about it are always separate however small either one is, because checking an
edit means reading a diff and checking an answer means reading the answer. Bundled, the answer arrives before the edit
it rests on has been verified. When the split is genuinely unclear the skill splits anyway and says so in the plan,
where merging the two back costs you nothing.

Each concern then sorts through an ordered test, first match winning: skill-backed when a flagged skill covers it,
decision work when it produces a choice that commits you to something, prose work when it produces prose someone will
read, and open-ended otherwise, where the plan supplies the boundaries with no rule behind them. Concerns sort
independently, so one request routinely yields a skill-backed concern and a prose concern side by side. The skill never
guesses the discipline for skill-backed work; it proposes an approach and waits.

A stop leads with what you can check and keeps the reasoning below it, because a fluent explanation raises agreement
without raising scrutiny, which is the failure the whole loop exists to prevent. For a piece the plan marked expensive
to walk back, the skill asks what you expect before it builds, and declining is a complete answer. A running feedback
record lands under your configured output directory, or beside the work under `.han/pairing/` when you have none, and
the skill names which recorded entry shaped a later piece.

#### The collaborative stop rule

`han-core/references/collaborative-stop-rule.md` is the canonical contract behind the mode: how a skill detects the
flag, what a stop presents and in what order, when the pre-build ask fires and what makes a choice expensive to walk
back, how the response is recorded, and what to do with the answer. It is what makes a stop feel the same whichever
skill performed it. `han-core/README.md` now separates the two kinds of thing the plugin carries, material other plugins
consume and one working mode you invoke directly, and says that `/pairing` names a missing backing skill rather than
substituting for it.

### han-coding v3.2.0

#### /tdd, /refactor, and /design-an-api hand control back when asked

Each of the three gains one paragraph at a boundary it already had. `/tdd` stops after each behavior, `/refactor` after
each named refactoring, and `/design-an-api` after each of its four dispatch rounds, with its two existing human gates
untouched. Absent such a request an ordinary invocation is unchanged, so invoking any of them directly still runs
straight through.

The flag travels as a stated override in the invocation rather than as a named argument. All three skills carrying
`arguments: size` already use the second positional slot for free text, so a second named positional would have collided
with the subject you type. `/tdd` and `/refactor` already gated when a request asked to review before implementation,
so the flag extends a mechanism they had rather than adding a parallel one.

`/code-walkthrough` sharpens its boundary against the new mode: it paces through code that already exists and builds
nothing, and its description now names `/pairing` for building new work while being paced through it. The two share
their whole pacing vocabulary, which is what makes the boundary worth stating.

`han-coding/references/collaborative-stop-rule.md` is vendored byte-identical from `han-core`.

#### Three defects repaired in the documentation

The reverse link threaded into `/design-an-api`'s long-form doc landed inside the "Repo root README" bullet rather than
after it, splitting that sentence across two list items and orphaning the word "tree." below the pairing bullet. The
spine-agent lead-in in the same file had been indented as a continuation of the preceding bullet since the dispatch
pairings were recorded, so it rendered as part of the `/architectural-analysis` entry instead of introducing the list
under it.

`/design-an-api`'s collaborative paragraph carried both endings of a reworded sentence, reading "review each round as it
closes as it lands". The other four flagged skills all read "as it lands", which is what it now says.

### han-planning v2.2.0

#### /iterative-plan-review and /plan-implementation stop between rounds

Both skills run their rounds to completion today. Under the collaborative flag each stops at the end of a round and
hands control back instead of starting the next, so you see each round's findings as they land rather than only the
finished plan. The round's findings are what you can check and the plan edits it made are what changed. A redirect at
such a stop does not consume a round against the cap, because a round is a unit of review work and a redirect is not.

This is where the wrapper changes the most, since neither skill paused at all before. Both descriptions now say they run
straight through when invoked directly and name `/pairing` for the round-by-round path.
`han-planning/references/collaborative-stop-rule.md` is vendored byte-identical from `han-core`.

### Pull requests in this release

- feat(han-core): add the pairing collaborative working mode by
  [@mxriverlynn](https://github.com/mxriverlynn) in https://github.com/testdouble/han/pull/179

Full changelog:
[CHANGELOG.md#v530](https://github.com/testdouble/han/blob/main/CHANGELOG.md#v530)

## v5.2.0

han 5.2.0 adds two skills to the coding layer. `/design-an-api` designs the contract for an API change before anyone
writes code, and `/code-walkthrough` paces you through a set of changes one step at a time in conversation.
`han-coding` (3.1.0) ships both. `han-core` (3.0.1), `han-planning` (2.1.1), and `han-communication` (1.1.1) record the
dispatch pairings and skill boundaries the two new skills create. The suite-level docs place both in the sizing,
concepts, workflow, and how-to catalogs, and the repo's own `/han-release` skill gets the fix that unblocked this
release. `han-documentation` (1.0.0), `han-research` (1.0.0), `han-github` (2.3.0), `han-reporting` (2.2.0),
`han-feedback` (2.0.1), `han-atlassian` (2.3.0), `han-linear` (1.1.0), and `han-plugin-builder` (2.1.0) are unchanged.

### han v5.2.0

#### /han-release stops reading an unchanged plugin's tag as a collision

Step 9 of `.claude/skills/han-release/SKILL.md` computed a tag name for every plugin in the marketplace and stopped the
run on any `remote-at-other-commit` state. An unchanged child keeps its version, so it keeps the tag an earlier release
gave it, and that tag points at that earlier release commit by design. Read literally, the gate stopped every release
after the first: cutting v5.1.0 tripped it on 11 of 13 plugins.

Step 9.1 now splits plugins into two sets from the version plan. Being tagged this release covers every plugin whose
target differs from its baseline, plus every new plugin from Step 3a. Carried forward covers every unchanged child.
Step 9.3 reads `remote-at-other-commit` against the set the plugin is in, since the state means opposite things for the
two. A carried-forward tag passes when `git merge-base --is-ancestor` puts it inside this release's own history, and
stops otherwise. A plugin being tagged now stops unconditionally with no ancestor check, which leaves the original
collision protection intact.

Step 11.1 carried the same rule at the publish gate and would have blocked the run after the tags were already pushed,
so it now holds each set to its own rule and rejects `absent` or `local-only` in either. Step 10 gains the
carried-forward skip, and Step 12 distinguishes it from a `remote-at-commit` skip when reporting.
`.claude/skills/han-release/scripts/remote-tag-state.sh` is unchanged in behavior: its header comment no longer calls
`remote-at-other-commit` unrecoverable, and says the caller decides, because the script cannot see the version plan.

#### The cross-plugin catalogs list both new skills

`docs/sizing.md` adds `/code-walkthrough` and `/design-an-api` to the sizing-aware list, to the at-a-glance table with
each band's roster and output, and to the per-skill Sizing link list. `docs/concepts.md` adds both to the sizing-aware
list and to the sentence describing what `han-coding` carries. `docs/quickstart.md` names `/code-walkthrough` in its
sizing note. `docs/skills/README.md` gains a scent line for each. `CLAUDE.md` names both in the `han-coding` catalog and
completes the vendored reference lists in the layout tree, which had omitted `config-rule.md` from the `han-core`,
`han-documentation`, `han-research`, and `han-coding` entries.

`docs/workflows.md` adds two chains. `/architectural-analysis` → `/design-an-api` → `/tdd` joins the code-quality
diagram and its prose: judge the structure you are designing into, shape the contract against one stated goal, then
implement it test-first, with the analysis step optional because `/design-an-api` runs its own discovery wave.
`/code-walkthrough` → `/code-review` joins the linear chains as the taught-rather-than-handed-a-document
counterpart to `/code-overview` → `/code-review`.

`CONTRIBUTING.md` gains the two checklist steps whose absence let `/design-an-api` ship without reaching those catalogs:
a sizing-aware skill must be added to the sizing and concepts lists and given a `## Sizing` section in its long-form
doc, and a skill that chains with others must be added to `docs/workflows.md` in both the prose and the mermaid diagram.
The same pass corrects the links-up rule to match the plugin-first layout: a long-form doc's first Related Documentation
bullet points at its own plugin README, and the second at the repository root.

#### The understanding how-to covers both orientation skills

`docs/how-to/accelerate-understanding-of-unfamiliar-code.md` now runs Phase 1 on two skills instead of one, and frames
them as differing in shape rather than depth: `/code-overview` hands you a finished map to keep and share, and
`/code-walkthrough` takes you through the code one step at a time and stops after each. Neither raises findings. The
verification step is rewritten to cover both paths, telling you to open the entry points an overview names and to open
the file the current walkthrough step names before you say `next`. The partial-coverage step gains the walkthrough's
"go deeper" alternative to re-running, and the pitfalls section records that `/code-walkthrough` writes no file at all,
so the understanding lives only in your head once the session ends.

### han-coding v3.1.0

#### /design-an-api designs an interface contract against one stated goal

`/design-an-api` designs the contract for an API change inside one codebase: a component's props, a function surface,
URL or query parameters, an event payload, or a module boundary, sized for roughly one pull request. It runs on one
stated goal, and will not start without one, because the goal is the only thing the design can be justified against.
Every parameter, field, type, default, precedence rule, and failure behavior names either the goal language it descends
from or the asked-for behavior it is a necessity of. Anything the interface could plausibly carry that the goal never
asks for moves to a cut list, recorded with what it would have done, and the cut list appears in the closing message as
well as in the document. One floor bounds that: silence never cuts a necessity, so a goal that says nothing about
invalid input, error behavior, or types cuts none of them.

A run writes three files to one folder under your configured `output-directory`: `context-brief.md` with numbered
findings carrying `file:line` citations, `design-options.md` with the two or three options and one recommendation, and
`api-design.md`, the deliverable that a `/tdd` run implements against. It never overwrites; when the names are taken it
date-suffixes all three together. Two gates stop for you, choosing the design option and answering the open items one at
a time, and everything else runs unattended.

The skill is sizing-aware over a fixed four-agent spine that runs at every band: `codebase-explorer`,
`software-architect`, `junior-developer`, and `adversarial-validator`. Specialists join the discovery wave only when the
interface shows their signal and the band allows, up to two at medium and four at large, and the design document's
summary names any domain the cap dropped so you can re-run larger. It closes with a `readability-editor` pass over the
finished document.

The skill packages an arrangement that was already working by hand. Issue
[#173](https://github.com/testdouble/han/issues/173), opened by [@mxriverlynn](https://github.com/mxriverlynn), recorded
a session that dispatched `software-architect`, `junior-developer`, and `adversarial-validator` directly against a
hand-assembled brief to design a query-parameter prefill contract, and the designed API shipped essentially as
specified. What the skill adds is the discovery step that session assembled ad hoc, the size band that scales the
roster, and the two gates in fixed positions. Shipped in [#175](https://github.com/testdouble/han/pull/175) by
[@mxriverlynn](https://github.com/mxriverlynn), which closed that issue.

#### /code-walkthrough paces you through a change one step at a time

`/code-walkthrough` walks you through a set of code changes in conversation, starting at the entry point and following
the flow that changes. It writes no file and changes no code; the conversation is the whole deliverable. With no
argument it walks the current branch against the default branch, and it also takes a file, a directory, a symbol, a pull
request reference or URL, or a plan or ticket to walk the code from that context's perspective.

Each step carries a heading with your position and the complete repository-root-relative path, two to four sentences
leading with the problem being solved, an excerpt of up to roughly thirty lines (a diff for a change, a plain fence for
existing code), and a one-line handoff naming what comes next. Then the turn ends. Say `next` to advance, ask a question
to stay put and get an answer at the same plain-language level with the counter unmoved, say "go deeper" to expand the
current step, name a file to jump there, or say "stop" to end the walk and be told where you left off. The itinerary
runs in flow order rather than diff order, and the closing step names every changed file that sits off the execution
path with one line each on why it changed, so nothing is dropped silently. The walkthrough raises no findings, no
severities, and no recommended changes; judging the code is `/code-review`'s job.

The skill classifies the target as small, medium, or large, defaulting to small, and scales both the parallel
`han-core:codebase-explorer` wave that traces the flow and roughly how many steps the walk runs, from 3 to 5 at small up
to 8 to 12 at large. Tracing is dispatched rather than done inline because the session runs across many turns, and a
context exhausted at step 2 cannot finish the walk. There is no approval gate before it starts, because the skill is
read-only and re-runnable. Shipped in [#176](https://github.com/testdouble/han/pull/176) by
[@mxriverlynn](https://github.com/mxriverlynn).

#### The existing coding skills name their new siblings

The `description:` fields that route work now send it to the right new skill. `code-review` sends orientation to
`/code-overview` for a written overview or `/code-walkthrough` to be paced through the change; `code-overview` sends
step-by-step pacing to `/code-walkthrough`; `architectural-analysis` sends new interface or contract design to
`/design-an-api`. The long-form docs carry the matching pairings: `architectural-analysis` points at `/design-an-api` as
the next step when a finding is a contract to redesign, `refactor` points there when the restructuring you want is
really a new contract, `tdd` points there as the run whose design document feeds it, `code-overview` and `code-review`
point at `/code-walkthrough` as the paced counterpart, and `investigate` points at it as the learning-shaped sibling for
when nothing is broken. `code-overview`'s long-form doc also corrects its size argument to include `dynamic`, which the
skill already accepted.

### han-core v3.0.1

Eleven agent long-form docs under `han-core/docs/agents/` gain the dispatch pairing for the new skills in their Related
documentation lists, so an agent's doc names every skill that dispatches it. `codebase-explorer` records both:
`/design-an-api` dispatches it in the four-agent spine at every size to discover the current surface and its consumers,
and `/code-walkthrough` dispatches it scaled to the band to trace the flow the itinerary is built from.
`software-architect`, `junior-developer`, and `adversarial-validator` record their spine seats in `/design-an-api`, and
`structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `on-call-engineer`,
`adversarial-security-analyst`, and `system-architect` each record the signal that adds them to its discovery wave. No
agent definition changed.

### han-planning v2.1.1

`plan-a-feature` and `plan-implementation` gain a boundary against the new coding skill, in both their `SKILL.md`
`description:` fields and their long-form docs: neither designs the contract for an interface, and both send that work
to `/design-an-api`. The long-form docs say what the split is. `plan-a-feature` settles what the feature does and
`/design-an-api` settles the contract that delivers it; `/design-an-api` is the narrower sibling of
`plan-implementation` for when the open question is the shape of one interface rather than how to deliver the whole
feature.

### han-communication v1.1.1

`han-communication/docs/agents/readability-editor.md` records one more skill that dispatches the agent: `/design-an-api`
sends it the finished design document to audit and rewrite for the engineer who will implement the contract and the
reviewer who will approve it.

### Issues closed in this release

- Han Feedback: software-architect-junior-developer-adversarial-validator (2026-08-06) (#173) — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #175 by [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- add skill: /han-coding:design-an-api (#175) — [@mxriverlynn](https://github.com/mxriverlynn)
- feat(han-coding): add the code-walkthrough skill (#176) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/han--v5.2.0/CHANGELOG.md#v520

## v5.1.0

han 5.1.0 adds a selectable output style that holds the readability standard across a whole session, not only inside the
skills that source it. `han-communication` (1.1.0) ships the style and its long-form doc; the suite-level docs gain the
coverage rule and the operator guidance that make an output style a first-class component of the repo. `han-core`
(3.0.0), `han-documentation` (1.0.0), `han-research` (1.0.0), `han-planning` (2.1.0), `han-coding` (3.0.0), `han-github`
(2.3.0), `han-reporting` (2.2.0), `han-feedback` (2.0.1), `han-atlassian` (2.3.0), `han-linear` (1.1.0), and
`han-plugin-builder` (2.1.0) are unchanged.

### han v5.1.0

Output styles are a new component kind for this repo, so the shared surfaces that describe what a plugin ships had
nowhere to name one. This release adds that place.

#### Coverage rule extended to output styles

`docs/templates/coverage-rule.md` now requires a long-form doc for every output style, in
`{plugin}/docs/output-styles/{name}.md`, alongside the existing requirement for every skill and every agent. The rule
gains an output-style variant section describing the heading deviations, following the precedent set by the
inline-guidance variant: the deviations are described in the rule itself rather than in a fourth template file. The
variant renames `When to use it` and `How to invoke it` to `When to select it` and `How to select it` (a style is
selected once in `/config`, not called per task), replaces `What you get back` with `What it changes` (no artifact comes
back), and adds `What it does not reach` for the boundaries that surprise people. It drops
`How to get the most out of it`, `YAGNI`, and `Sources`. There is no repo-root output-styles index; add one when a second
plugin ships a style.

#### Operator docs name the style and its limits

`docs/readability.md` gains a section on applying the standard to a whole session, naming the three limits: the style
does not reach dispatched subagents, it carries the built-in voice only because a static system prompt cannot run the
`.han/config.md` probe, and it is a derived copy that can drift from the canonical rule and voice files.
`docs/choosing-a-han-plugin.md` and `CONTRIBUTING.md` name the style in the `han-communication` scent. `CLAUDE.md` gains
the `output-styles/` layout line and a doc-map entry warning that the style is derived from
`han-communication/references/readability-rule.md` and `han-communication/references/writing-voice.md`, so an edit to
either one needs a matching check against the style.

The new `docs/research/readability-guidance-in-output-styles.md` is the standalone research report behind the change. It
is not tied to a plan and changes no skill behavior. Contributed by [@mxriverlynn](https://github.com/mxriverlynn).

### han-communication v1.1.0

The plugin ships a new component kind: the `Han Readability` output style, in
`han-communication/output-styles/han-readability.md`. Select it under **Output style** in `/config` and every turn of the
session is written to the readability standard, instead of only the turns inside a skill that invokes
`readability-guidance`. It takes effect on the next session or after `/clear`, because Claude Code reads the output style
once at session start. The style lives in the auto-discovered default `output-styles/` directory, so `plugin.json` needs
no `outputStyles` field.

The style distills the audience frame, output properties, fidelity guard, and six-criterion self-check from
`han-communication/references/readability-rule.md` together with the blocklist from
`han-communication/references/writing-voice.md`. It sets `keep-coding-instructions: true`, so Claude Code's software
engineering behavior is unchanged: the style changes how work is written up, not how it is done.

Three boundaries are stated in the style's long-form doc at
`han-communication/docs/output-styles/han-readability.md`. The style does not reach a dispatched subagent, which runs its
own system prompt, so skills remain the mechanism that brings the standard to agent output and the `readability-editor`
remains the rewrite pass for synthesis skills. The configured `writing-voice` override does not port, because an output
style is static system-prompt text loaded at session start and cannot probe `.han/config.md`; the built-in Han voice is
hardcoded, and `/readability-guidance` remains the path that honors a configured profile. The style is a derived copy, so
the canonical rule and voice files stay authoritative and nothing propagates an edit to the style for you.

`han-communication/README.md` gains an Output styles section, and the scent line points at the long-form doc rather than
at the style file, per the canonical-source convention. Contributed by [@mxriverlynn](https://github.com/mxriverlynn).

### Pull requests in this release

- feat(han-communication): add the han-readability output style (#174) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/han--v5.1.0/CHANGELOG.md#v510

## v5.0.0

han 5.0.0 restructures the suite. The readability capability becomes a new foundational plugin, `han-core` sheds its
documentation and research skills into two more new plugins, configuration becomes two files instead of one, and
documentation goes plugin-first with a front door and long-form docs inside every plugin. This release carries breaking
changes; see the section below before upgrading. New this release: `han-communication` (1.0.0), `han-documentation`
(1.0.0), and `han-research` (1.0.0). Changed: `han-core` (3.0.0), `han-coding` (3.0.0), `han-github` (2.3.0),
`han-atlassian` (2.3.0), `han-reporting` (2.2.0), `han-planning` (2.1.0), `han-plugin-builder` (2.1.0), `han-linear`
(1.1.0), and `han-feedback` (2.0.1).

### Breaking changes

- **`han-core` 3.0.0 sheds skills and agents to other plugins.** `project-documentation`,
  `architectural-decision-record`, and `runbook` now live in `han-documentation`; `research`, `gap-analysis`,
  `issue-triage`, and the `research-analyst` agent now live in `han-research`; `edit-for-readability` and the
  `readability-editor` agent now live in `han-communication`. The `project-manager` agent is removed outright, split
  into `plan-synthesizer` in `han-core` and `discussion-facilitator` in `han-planning`. Any `han-core:`-namespaced
  reference to a moved or removed entity no longer resolves. Repoint each one at its new plugin, and replace
  `han-core:project-manager` with `han-core:plan-synthesizer` or `han-planning:discussion-facilitator`.
- **`han-coding` 3.0.0 renames `test-planning` to `automated-test-planning`.**
  `han-coding/skills/test-planning/SKILL.md` is deleted and `han-coding/skills/automated-test-planning/SKILL.md` takes
  its place, so the `/test-planning` invocation no longer exists. Call `/automated-test-planning` instead.
- **`han` 5.0.0 changes what the meta-plugin installs.** Installing `han` now also pulls in `han-communication`,
  `han-documentation`, and `han-research` alongside the existing children. If you installed the child plugins
  individually rather than through the meta-plugin, add those three.

### han v5.0.0

The meta-plugin's `dependencies` grow to cover the three new plugins, and both marketplace manifests
(`.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json`) list them.

Documentation goes plugin-first, closing #115, opened by [@mxriverlynn](https://github.com/mxriverlynn) with a
substantive design comment from [@taminomara](https://github.com/taminomara). Long-form docs move out of repo-root
`docs/` into each plugin's own `docs/skills/` and `docs/agents/`, every plugin gains a light front-door `README.md`, the
skills and agents indexes slim to alphabetized scent lists, `docs/choosing-a-han-plugin.md` becomes the plugin index,
and the new `docs/workflows.md` maps which skills chain together. The new `docs/configuration.md` is the operator guide
for the two-file configuration layer.

That layer is the other suite-wide change, and it touches every plugin. Configuration becomes two files instead of one.
A person can carry a personal `.han/config.md` inside their Claude Code configuration directory holding the settings
that follow them into every project, and a project's own `.han/config.md` overrides it setting by setting. Every skill
reads both: each resolves the configuration directory with a probe, then reads the personal file with the Read tool as
its first action, while the project file stays a probe because it sits in the working directory. That split is
deliberate, because a probe runs at skill load where it cannot prompt and cannot fall back, so a permission decision
against one aborts the skill outright. New settings are `default-swarm-size`, honored by the sizing-aware skills, and a
`writing-voice` override. Config-named extra agents join each dispatching skill's candidate pool.

Repo tooling lands too: npm-managed lint and test tooling (prek, Prettier, and Bats), CI workflows, and Dependabot;
Prettier made safe over Markdown and re-enabled; and Bats tests discovered repo-wide and relocated beside the scripts
they cover. Contributed by [@taminomara](https://github.com/taminomara). Per-plugin release tags land as direct commits
on the alpha branch, closing #162, opened by [@taminomara](https://github.com/taminomara).

### han-communication v1.0.0 (new)

The new foundational plugin owns the suite's writing standard and depends on nothing. It ships the canonical
`readability-rule.md`, `writing-voice.md`, and `explanation-rule.md`; the `readability-editor` agent; the
`edit-for-readability` skill; and two inline skills, `readability-guidance`, which surfaces the readability standard and
the voice profile into a calling skill's context, and `explanation-guidance`, the standard for explaining work to a
reader who will not implement it.

The vendored duplicates in `han-coding`, `han-github`, and `han-reporting` and the `han-core` originals are deleted,
leaving exactly one copy of each reference. Consumer skills source the standard by invoking
`han-communication:readability-guidance`, and synthesis skills additionally dispatch
`han-communication:readability-editor`. The readability standard also absorbs Orwell's six rules of writing. Contributed
by [@mxriverlynn](https://github.com/mxriverlynn).

### han-core v3.0.0

Beyond the extraction described under breaking changes, `project-manager` splits into `plan-synthesizer`, which produces
the final plan or decision record, and `discussion-facilitator` in `han-planning`, which audits a live discussion
without deciding anything. The agent that audits a discussion is no longer the agent that writes the plan.

An agent-conformance sweep runs across the roster: every agent is made self-contained, role identities and body sections
are brought into conformance, model tiers are audited, dead tool grants are removed, every agent description is brought
under the 1024-character target, and self-verification sweeps become authoring guidance. `han-core` now depends on no
other Han plugin, owns the new canonical `config-rule.md`, and `project-discovery` offers to add and remove the
`CLAUDE.md` pointer to `.han/config.md`.

### han-documentation v1.0.0 (new)

The documentation skills move here out of `han-core`: `project-documentation`, `architectural-decision-record`, and
`runbook`. The plugin depends on `han-communication` and `han-core`, and the `han` meta-plugin bundles it.

### han-research v1.0.0 (new)

The pre-planning knowledge-work skills move here out of `han-core`: `research`, `gap-analysis`, and `issue-triage`,
along with the `research-analyst` agent. The plugin depends on `han-communication` and `han-core`, and the `han`
meta-plugin bundles it.

### han-planning v2.1.0

`han-planning` gains the `discussion-facilitator` agent from the `project-manager` split, plus three owned reference
files: `planning-boundary-rule.md` (the scope boundary record and the visual-material convention),
`scope-justification-rule.md` (the per-unit justification field, the cut list, and the scope gate), and
`operator-escalation-rule.md` (one question per turn, named candidate answers, a single stop). Applying them,
`plan-a-feature` bounds the run, keeps the designs, and asks one question at a time; `plan-implementation` sweeps
inherited scope and bounds the plan; `plan-a-phased-build` phases inside the recorded boundary; and `plan-work-items`
reads the scope boundary, justifies every work item, and leads with plain language, with acceptance criteria at the
bottom. This closes #155, #156, #157, and #158, all opened by [@mxriverlynn](https://github.com/mxriverlynn).

Planning runs also get cheaper and faster: review teams are smaller and sized in specialists, the design-image check is
executed rather than described, and the skills stop proofreading text the readability editor already rewrote.
`plan-a-feature`, `plan-implementation`, and `iterative-plan-review` are brought under the 500-line skill-body ceiling
by extracting references.

### han-coding v3.0.0

Beyond the `test-planning` rename, the new `manual-test-planning` skill produces a plain-language test plan a person
runs by hand, organizing plans that hold more than five tests into categories.

`code-review` explains every actionable finding in plain language, names how each finding gets fixed, puts the route and
the may-never-fire cue in the summary table, writes its report to a resolved run-specific path, and closes with the
recommendation instead of the whole report. `code-overview` lists the context it used with direct links, gives
where-to-start an order and an example call, gives diagram legibility an owner, reports a stated reason the code does
not support, honors a configured output directory, and ends with a restatement a person can paste. Both close #170,
opened by [@mxriverlynn](https://github.com/mxriverlynn). Diff-base detection in `code-review` and
`automated-test-planning` now works across multiple remotes and git-flow layouts and covers second-parent base
detection, contributed by [@taminomara](https://github.com/taminomara). `code-review` is brought under the 500-line
skill-body ceiling.

### han-github v2.3.0

`han-github` declares its `han-coding` dependency. `post-code-review-to-pr` reads the review from the report file and
states its deliverable scope. `work-items-to-issues` accepts the whole visual-material file set rather than PNG alone,
and its issue template aligns with the new plain-language work items. Angle brackets are removed from `argument-hint`
fields.

### han-reporting v2.2.0

`han-reporting` reads the two-file configuration and sources the readability standard cross-plugin from
`han-communication` instead of a vendored copy. Its docs and manifest entries are synced with the restructure.

### han-feedback v2.0.1

`han-feedback` updates today's feedback file in place rather than creating a second one, and names a blocked publish
instead of failing silently.

### han-atlassian v2.3.0

The Atlassian wrappers pass explicit output paths, so temp files outrank the configured output base, and the Jira ticket
template aligns with the new plain-language work items. `markdown-to-confluence` gains the `plan-a-feature` boundary,
and the dependency list is corrected.

### han-linear v1.1.0

The Linear issue template aligns with the new plain-language work items, with acceptance criteria at the bottom, and
`work-items-to-linear` reads the two-file configuration.

### han-plugin-builder v2.1.0

A new per-model authoring guidance reference lands, updated for Claude Opus 5, along with a new rule that a context
probe reads only inside the project working directory, with anything further out gathered using the Read tool during the
run. The plugin-README standard and its templates are rewritten to the light front-door model, two verbatim
duplications are removed from the reference set, and inline resource-surfacing is recorded as a data-fetch exception.
Contributed by [@mxriverlynn](https://github.com/mxriverlynn).

### Issues closed in this release

- Reorganize documentation to be plugin-centric: a README per plugin, slimmer indexes, and a plugin index (#115) —
  opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #137 by
  [@mxriverlynn](https://github.com/mxriverlynn); thanks to [@taminomara](https://github.com/taminomara)
- Han Feedback: plan-work-items (2026-07-28) (#158) — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in
  #160 by [@mxriverlynn](https://github.com/mxriverlynn)
- Han Feedback: plan-a-feature-readability-guidance (2026-07-28) (#155) — opened by
  [@mxriverlynn](https://github.com/mxriverlynn); fixed in #160 by [@mxriverlynn](https://github.com/mxriverlynn)
- Han Feedback: plan-implementation (2026-07-28) (#156) — opened by [@mxriverlynn](https://github.com/mxriverlynn);
  fixed in #160 by [@mxriverlynn](https://github.com/mxriverlynn)
- Han Feedback: plan-implementation (2026-07-28) (#157) — opened by [@mxriverlynn](https://github.com/mxriverlynn);
  fixed in #160 by [@mxriverlynn](https://github.com/mxriverlynn)
- Han Feedback: code-review-code-overview (2026-08-03) (#170) — opened by
  [@mxriverlynn](https://github.com/mxriverlynn); fixed in #171 by [@mxriverlynn](https://github.com/mxriverlynn)
- Use `claude plugin tag --push` to tag new releases (#162) — opened by [@taminomara](https://github.com/taminomara);
  fixed in #130 by [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- chore(CI): lint, Bats tests, CI, and Dependabot (#120) — [@taminomara](https://github.com/taminomara)
- fix(CI): add required patterns key to Dependabot ecosystem entries (#123) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- fix(CI): repair shellcheck findings and stale rules symlink (#126) — [@mxriverlynn](https://github.com/mxriverlynn)
- chore(CI): stop running Prettier over Markdown (#127) — [@mxriverlynn](https://github.com/mxriverlynn)
- plugin: han-communication - extracting a new plugin from han-core, and consolidating guidance (#114) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- Model specific guidance (#134) — [@mxriverlynn](https://github.com/mxriverlynn)
- Integrate readability planning coding (#136) — [@mxriverlynn](https://github.com/mxriverlynn)
- Plan: plugin-centric documentation reorganization (#115) (#137) — [@mxriverlynn](https://github.com/mxriverlynn)
- feat(han-coding): add the manual-test-planning skill (#138) — [@mxriverlynn](https://github.com/mxriverlynn)
- Planning readability improvements (#139) — [@mxriverlynn](https://github.com/mxriverlynn)
- Apply Orwell's six rules of writing to the han-communication guidance (#140) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- feat(han-coding): list the context used, with direct links, in code-overview output (#142) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- han-core restructure: split into han-documentation and han-research (#141) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- feature: han-config for project-specific configuration (#143) — [@mxriverlynn](https://github.com/mxriverlynn)
- docs(plans): specify the default-swarm-size project-config setting (#144) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- feature(manual-test-planning): categorize plans with more than five tests (#145) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- feature(config): add writing-voice override to .han/config.md (#146) — [@mxriverlynn](https://github.com/mxriverlynn)
- chore(lint): make Markdown Prettier-safe and re-enable it (stage one: no line wrapping) (#129) —
  [@taminomara](https://github.com/taminomara)
- chore(test): discover Bats tests repo-wide, not just test/ (#132) — [@taminomara](https://github.com/taminomara)
- feat(code-review, test-planning): detect the diff base across multiple remotes and git-flow (#151) —
  [@taminomara](https://github.com/taminomara)
- chore(deps): bump the dev-tooling group with 4 updates (#154) — [@taminomara](https://github.com/taminomara)
- chore(test): relocate Bats tests next to the scripts they cover (#161) — [@taminomara](https://github.com/taminomara)
- han-planning: reducing scope creep, requiring justification, and other corrections (#160) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- feat(han-planning): cheaper, faster planning runs (#163) — [@mxriverlynn](https://github.com/mxriverlynn)
- feat: read a personal .han/config.md beneath the project one (#164) — [@mxriverlynn](https://github.com/mxriverlynn)
- docs(guidance): update per-model authoring for Claude Opus 5 (#165) — [@mxriverlynn](https://github.com/mxriverlynn)
- investigating agent producer vs reviewer split (#167) — [@mxriverlynn](https://github.com/mxriverlynn)
- feat(code-review, code-overview): answer the reader's questions inside the run (#171) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- Han v5.0.0 alpha 1 (#130) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/han--v5.0.0/CHANGELOG.md#v500

## v4.6.0

han 4.6.0 adds TPP and ZOMBIES next-test selection to `/tdd`, stops `work-items-to-issues` from resetting an existing
label's color, keeps human-in-the-loop gating off assumptions the plan has already settled, and corrects the permission
model documented for context-injection commands. `han-coding` (2.6.0) gains the new `references/test-selection.md`
reference and wires it into `/tdd`; `han-github` (2.2.2) fixes the label-color bug in `work-items-to-issues`;
`han-planning` (2.0.4) tightens HITL marking in `plan-work-items` and defines the assumption status vocabulary in
`plan-implementation`'s template; and `han-plugin-builder` (2.0.5) corrects the context-injection command rules and adds
two new rules on token locality and point-of-use variation. `han-core` (2.2.1), `han-reporting` (2.1.1), `han-feedback`
(2.0.0), `han-atlassian` (2.2.0), and `han-linear` (1.0.2) are unchanged.

### han v4.6.0

The suite-level work is documentation plus the per-plugin version syncs in `.claude-plugin/marketplace.json`.
`README.md` adds [Tamika Nomara](https://github.com/taminomara) and [Aaron Frerichs](https://github.com/afrerich) to the
core contributors list, along with a link to the repository's full contributor graph. The new
`docs/research/effective-pull-request-descriptions.md` is a standalone research report on what makes a pull request
description effective, drafted and then finalized with a validation and readability pass; it is not tied to a plan and
changes no skill behavior. The long-form docs `docs/skills/han-coding/tdd.md` and
`docs/skills/han-github/work-items-to-issues.md` are synced with the test-selection addition and the label-color fix
respectively. Contributed by [@mxriverlynn](https://github.com/mxriverlynn).

### han-coding v2.6.0

`/tdd` now answers "which test do I write next" explicitly. The new `han-coding/skills/tdd/references/test-selection.md`
is the canonical reference for the Transformation Priority Premise (TPP) and ZOMBIES heuristics: it carries the
fourteen-transformation TPP ranking table (from `{} → nil` through `case`) and the ZOMBIES ordering, both resolving to
the same answer, that the next test is the one satisfiable by the simplest transformation of the code. The reference
frames Robert C. Martin's core principle: as the tests get more specific, the code gets more generic. It is explicit
that these are heuristics for choosing what to test next, never a menu for hacking an implementation to green after the
test is chosen.

`han-coding/skills/tdd/SKILL.md` wires the reference in at two points. When ordering the behavior test list, a behavior
that expands into several candidate tests (the empty case, the single case, the many case, the boundaries) is ordered
simplest-first, Zero then One then Many, so each test forces the smallest generalization of the code, pulling
`references/test-selection.md` when the order is not obvious. When picking the next item, the skill prefers the item
whose passing requires the simplest transformation (a test needing only a constant return before one forcing a
conditional, and a conditional before a loop), and when every remaining item forces a big leap with no smaller test in
between, the skill treats that as a missing test and adds it to the list. The skill's `description` gains the TPP and
ZOMBIES trigger wording. The reference is ported from Dale Stewart's `nw-tpp-methodology` skill for nWave
(`nWave-ai/nWave#67`) and his write-up "The Next Test". Contributed by [@Hyperman012](https://github.com/Hyperman012) in
#108.

### han-github v2.2.2

`work-items-to-issues` no longer resets an existing label's color and description.
`han-github/skills/work-items-to-issues/scripts/create-issues.sh` previously upserted the label passed via
`--label <name>` with `gh label create "$LABEL" --force`, and `--force` overwrites the color and description of a label
that already exists; passing an existing `enhancement` label reset its color from `#a2eeef` to gh's default. The script
now creates the label without `--force`, and when creation fails because the label already exists, it confirms the label
through an exact name match against `gh label list` and reuses it as-is, leaving its color and description intact. It
errors out only when the label can be neither created nor found. `han-github/skills/work-items-to-issues/SKILL.md` is
updated to describe the new behavior. Contributed by [@afrerich](https://github.com/afrerich) in #116.

### han-planning v2.0.4

Work items no longer get gated on a human when the plan has already settled the question. `plan-work-items` directs the
dispatched `han-core:project-manager` not to mark a work item HITL merely because the plan labels an assumption
unverified. The agent first checks whether the assumption can be settled by reading the code (if it can, it does that
and moves on) and whether getting the assumption wrong actually breaks something or merely falls back to a safe default.
A work item is HITL only when the assumption cannot be settled from code and getting it wrong causes real breakage;
otherwise it is AFK. HITL stays reserved for genuine architectural and design calls.

`plan-implementation`'s `references/feature-implementation-plan-template.md` defines the status vocabulary for the
Assumptions table, so the plans feeding that decision are unambiguous: a status is exactly one of `Verified` (a source
cite settles it, whether a `file:line`, an ADR, or a standard), `Runtime-only` (it cannot be known until the code runs),
or `Open` (not yet checked). Each assumption carries one status, an assumption confirmed from source is `Verified` with
no "but unverified at runtime" qualifier attached, and a separate runtime unknown gets its own row. Mixing the two hid a
settled fact and made later steps gate on it for no reason. Contributed by [@afrerich](https://github.com/afrerich) in
#109, with [@mxriverlynn](https://github.com/mxriverlynn) and [@taminomara](https://github.com/taminomara).

### han-plugin-builder v2.0.5

Three changes to the skill-building references served by the `guidance` skill.

#### Context-injection commands: the permission model, corrected

The old rule in `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`
("Keep commands simple, single commands only") claimed that pipes, `&&`-chains, and redirects fail the loader's prefix
match. That is not what the loader does. The rule is now "Keep every command an auto-approvable read-only form", and it
describes the real behavior: context injection runs at skill load and never prompts, so a command that is not
auto-approvable hard-rejects and stops the skill from loading, and only the first failing command surfaces an error
while every command after it is masked. A command auto-approves when every part of it, including each stage of a pipe or
chain, is either a built-in read-only command on the loader's fixed allowlist (`cat`, `ls`, `head`, `tail`, `wc`,
`grep`, `find` without dangerous predicates, `which`, `echo`, `date`, and read-only `git` and `gh` subcommands) or
matched by an explicit `Bash()` rule in `allowed-tools`. Pipes and chains are therefore not forbidden. Four constructs
are refused every time, and an `allowed-tools` rule does not rescue them: command substitution `$(...)`, process
substitution, subshells and background `&`, and dangerous sub-forms of otherwise-safe tools (`find -exec`,
`find -delete`, `sed -i`), where the danger check overrides the grant. The rule still prefers one flag-driven command
over a pipe, because each extra stage is one more part that has to stay on the allowlist. New guidance covers keeping
each injected value small: bound the output at the source with `-n`, `--stat`, `--name-only`, or `-maxdepth` rather than
piping into `head`, since injected output persists in context for the whole run, making `| head -N` a last resort rather
than a ban. The reference also documents the `git config --get` edge, where the bare `git config user.name` form is
accepted as a lone command but not as part of a chain, and the "What NOT to Use" table is rewritten from "Why It Fails"
to "What happens" to match.

#### Token locality: build a self-sufficient region at the point of use

`context-hygiene.md` gains the rule "Build a self-sufficient region at the point of use": give each step a region that
already carries what it needs, so the model is not left reconstructing which reference applies where. A single
instruction applied to the data in front of it is cheap. What is costly is a step that makes the model hold several
references at once and route each to a different, overlapping set of targets. A region is self-sufficient when that
routing is already resolved. The rule distinguishes a loadable pointer (one `references/` file Read and applied
uniformly, which is fine) from an in-head reference (three references plus a mapping of which applies where, which
should be collapsed before the model sees it). It adds an "in-head join" row to the anti-pattern table and
cross-references Multi-Agent Economics.

#### Point-of-use variation resolution

`writing-effective-instructions.md` gains the rule "Resolve variation at the point of use": when a step drives several
similar items that each take a slightly different set of inputs (dispatching sub-agents with different reference files,
or applying rules scoped to different files), do not express the variation as a matrix the model has to join against a
separate list, because that forces an in-head join. Keep the source normalized, but denormalize it into the point of
use, resolving the variation with a deterministic step (a script, or the driver that assembles each dispatch) where one
exists. The rule includes a before-and-after example (a reviewer-by-file matrix versus one self-contained block per
reviewer) and states its own limit: at small scale (two or three items and inputs, with no growth ahead) a compact table
is fine, and the claim that the join trips the model is a reasoned bet by analogy to documented weaknesses in
large-table lookup and multi-hop binding, not something a study tests at this scale.

Contributed by [@taminomara](https://github.com/taminomara) in #118 and #121, and by
[@mxriverlynn](https://github.com/mxriverlynn).

### Pull requests in this release

- feat(tdd): add TPP + ZOMBIES next-test selection to the /tdd skill (#108) —
  [@Hyperman012](https://github.com/Hyperman012)
- Prevent HITL over-gating on already-verified assumptions (#109) — [@afrerich](https://github.com/afrerich)
- Don't reset an existing label's color when publishing issues (#116) — [@afrerich](https://github.com/afrerich)
- docs(plugin-builder): add rule about token locality to skill-building references (#118) —
  [@taminomara](https://github.com/taminomara)
- docs(plugin-builder): correct context-injection command permission model (#121) —
  [@taminomara](https://github.com/taminomara)

Full changelog: https://github.com/testdouble/han/blob/v4.6.0/CHANGELOG.md#v460

## v4.5.1

han 4.5.1 is a maintenance release that guards context-injection commands against absent tools and references,
normalizes user-reference wording, and sweeps the operator-facing documentation for readability. `han-core` (2.2.1)
guards the `project-discovery`, `research`, and `runbook` skills and normalizes wording in the `research-analyst` agent,
`issue-triage`, and `research`; `han-planning` (2.0.3) normalizes wording in its references; `han-coding` (2.5.1) guards
six skills and normalizes wording in `code-overview` and `code-review`; `han-github` (2.2.1) guards
`post-code-review-to-pr` and `update-pr-description` and normalizes its references; `han-reporting` (2.1.1) normalizes
its references; `han-linear` (1.0.2) normalizes `work-items-to-linear` and its templates; and `han-plugin-builder`
(2.0.4) guards the `guidance` skill and finishes the guarding in its command-example references. `han-feedback` (2.0.0)
and `han-atlassian` (2.2.0) are unchanged.

### han v4.5.1

The suite-level work is documentation plus the per-plugin version syncs in `.claude-plugin/marketplace.json`. The `user`
normalization reaches the long-form docs under `docs/agents/` and `docs/skills/han-coding/`. A readability sweep applies
the suite's Human-Readable Output Standard across `docs/` (skill docs, agent docs, how-to guides, templates, and
top-level docs such as `docs/concepts.md`, `docs/why-solo-and-small-teams.md`, and `docs/semantic-versioning.md`),
`README.md`, and `CONTRIBUTING.md`, and syncs the skill and agent docs with the current rosters and dispatchers; it
changes no SKILL.md or agent behavior. Contributed by [@taminomara](https://github.com/taminomara) in #104 and
[@mxriverlynn](https://github.com/mxriverlynn) in #106.

### han-core v2.2.1

The `project-discovery`, `research`, and `runbook` skills guard their context-injection commands so an absent tool or
referenced file cannot abort the skill. Text in the `research-analyst` agent, the `references/`, and the `issue-triage`
and `research` skills normalizes references to "the Claude Code user" to "user". Contributed by
[@taminomara](https://github.com/taminomara) in #103 and #104.

### han-planning v2.0.3

The `han-planning/references/` normalize references to "the Claude Code user" to "user". Contributed by
[@taminomara](https://github.com/taminomara) in #104.

### han-coding v2.5.1

The `architectural-analysis`, `code-overview`, `code-review`, `refactor`, `tdd`, and `test-planning` skills guard their
context-injection commands so an absent tool or referenced file cannot abort the skill. Text in `code-overview`,
`code-review`, and the `references/` normalizes references to "the Claude Code user" to "user". Contributed by
[@taminomara](https://github.com/taminomara) in #103 and #104.

### han-github v2.2.1

The `post-code-review-to-pr` and `update-pr-description` skills guard their context-injection commands so an absent tool
or referenced file cannot abort the skill. The `references/` normalize references to "the Claude Code user" to "user".
Contributed by [@taminomara](https://github.com/taminomara) in #103 and #104.

### han-reporting v2.1.1

The `han-reporting/references/` normalize references to "the Claude Code user" to "user". Contributed by
[@taminomara](https://github.com/taminomara) in #104.

### han-linear v1.0.2

The `work-items-to-linear` skill and its reference templates normalize references to "the Claude Code user" to "user".
Contributed by [@taminomara](https://github.com/taminomara) in #104.

### han-plugin-builder v2.0.4

The `guidance` skill guards its context-injection commands so an absent tool or referenced file cannot abort the skill,
and the guidance references finish the same guarding for the command examples in `context-injection-commands.md` and
`dynamic-project-discovery.md`. Contributed by [@taminomara](https://github.com/taminomara) in #103 and
[@mxriverlynn](https://github.com/mxriverlynn) in #105.

### Pull requests in this release

- fix(skills): guard context-injection commands so absent tools or refs can't abort a skill (#103) —
  [@taminomara](https://github.com/taminomara)
- docs(guidance): finish guarding context-injection command examples (#105) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- docs: normalize the Claude Code user reference to "user" (#104) — [@taminomara](https://github.com/taminomara)
- Readability edits across all documentation (#106) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.5.1/CHANGELOG.md#v451

## v4.5.0

han 4.5.0 lands a shared Human-Readable Output Standard across the suite: a single readability rule plus a dedicated
`readability-editor` agent, wired into the reader-facing synthesis skills so their drafts lead with the main point, use
descriptive headings, keep one idea per paragraph, and use short active sentences, while preserving every fact. The
canonical `writing-voice.md` also moved out of `docs/` and into plugin `references/`. The release bumps `han-core`
(2.2.0) with the new agent, the new `edit-for-readability` skill, and the shared `readability-rule.md` and
`writing-voice.md` references; `han-coding` (2.5.0), `han-github` (2.2.0), and `han-reporting` (2.1.0) each vendor those
two references and wire the standard into their reader-facing skills; and `han-plugin-builder` (2.0.3) fixes two
guidance rules. `han-planning` (2.0.2), `han-feedback` (2.0.0), `han-atlassian` (2.2.0), and `han-linear` (1.0.1) are
unchanged.

### han v4.5.0

The suite-level work is the readability standard's documentation, the `writing-voice.md` relocation, the supporting
research and plan artifacts, and the per-plugin version syncs in `.claude-plugin/marketplace.json`.

New `docs/readability.md` is the operator-facing Human-Readable Output Standard, and new
`docs/agents/han-core/readability-editor.md` and `docs/skills/han-core/edit-for-readability.md` document the new agent
and skill. `docs/concepts.md` gained a readability section, `README.md` links the standard from its documentation list,
and `docs/agents/README.md` and `docs/skills/README.md` register the new entries. A doc sweep brought the reader-facing
skill docs across han-coding, han-core, han-github, and han-reporting current with the readability pass and added the
`readability-editor` to their rosters. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #102.

The canonical `writing-voice.md` moved from `docs/writing-voice.md` into `han-core/references/writing-voice.md`,
vendored byte-identical into `han-coding/`, `han-github/`, and `han-reporting/` references, with live references
repointed to the new location. `CLAUDE.md` gained rules enforcing the guidance and standards.

New `docs/research/human-readable-output-standard.md` is the research report backing the standard, and the
`docs/plans/human-readable-output-standard/` folder holds the feature specification and the decision-log and
team-findings artifacts. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #97.

### han-core v2.2.0

The new `readability-editor` agent (`han-core/agents/readability-editor.md`) rewrites a draft's prose to lead with the
main point, use descriptive headings, carry one idea per paragraph, and keep sentences short and active, while
preserving every fact. The new `edit-for-readability` skill (`han-core/skills/edit-for-readability/SKILL.md`) dispatches
that agent against a file, pasted text, or an in-conversation draft. Two new shared references back the standard:
`han-core/references/readability-rule.md` (the canonical readability rule) and `han-core/references/writing-voice.md`
(the canonical voice profile, moved here from `docs/`).

The readability standard is wired into the six reader-facing han-core skills: `architectural-decision-record`,
`gap-analysis`, `issue-triage`, `project-documentation`, `research`, and `runbook`. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #102.

### han-coding v2.5.0

Vendored `han-coding/references/readability-rule.md` and `han-coding/references/writing-voice.md` byte-identical from
han-core, and wired the readability standard into the four reader-facing han-coding skills: `architectural-analysis`,
`code-overview`, `code-review`, and `investigate`. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in
#102.

### han-github v2.2.0

Vendored `han-github/references/readability-rule.md` and `han-github/references/writing-voice.md` byte-identical from
han-core, and wired the readability standard into `update-pr-description`. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #102.

### han-reporting v2.1.0

Vendored `han-reporting/references/readability-rule.md` and `han-reporting/references/writing-voice.md` byte-identical
from han-core, and wired the readability standard into `html-summary` and `stakeholder-summary`. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #102.

### han-plugin-builder v2.0.3

Guidance fixes in the agent-building references. The subagent-dispatch rule is reframed as a justified default rather
than an absolute, and the stale "subagents cannot spawn subagents" rule was corrected, fixing an issue opened by
[@taminomara](https://github.com/taminomara) (#99). Also removed an em-dash from `agent-builder`'s tool-set step.
Contributed by [@taminomara](https://github.com/taminomara) in #100.

### Issues closed in this release

- Stale "subagents cannot spawn subagents" rule in agent-building guidance (#99) — opened by
  [@taminomara](https://github.com/taminomara); fixed in #100 by [@taminomara](https://github.com/taminomara)

### Pull requests in this release

- Research: human readable output (#97) — [@mxriverlynn](https://github.com/mxriverlynn)
- docs: reframe the subagent-dispatch rule as a justified default (#100) — [@taminomara](https://github.com/taminomara)
- human-readable output standards (#102) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.5.0/CHANGELOG.md#v450

## v4.4.0

han 4.4.0 adds an independent adversarial validation pass to the `code-review` skill and hardens it against untrusted
branch context (han-coding 2.4.0), reworks the `project-discovery` skill to write a concise section directly into the
project's `AGENTS.md` or `CLAUDE.md` (han-core 2.1.0), and lands three documentation and frontmatter fixes: a `Write`
permission for `post-code-review-to-pr` (han-github 2.1.2), missing frontmatter for `html-summary` (han-reporting
2.0.1), and corrected agent names in the skill-building guidance (han-plugin-builder 2.0.2). `han-planning` (2.0.2),
`han-feedback` (2.0.0), `han-atlassian` (2.2.0), and `han-linear` (1.0.1) are unchanged.

### han v4.4.0

The suite-level work is documentation plus the per-plugin version syncs in `.claude-plugin/marketplace.json` for this
release.

New `docs/research/effective-ai-code-reviews.md` is a research report validating the claims behind effective AI code
reviews, and new `docs/how-to/run-an-effective-code-review.md` is a how-to guide built on it. Both are surfaced in
`docs/how-to/README.md`, and both back the `code-review` work in han-coding. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #92.

A documentation sweep brought the skill and agent docs current with this release:
`docs/skills/han-coding/code-review.md`, `docs/skills/han-core/project-discovery.md`,
`docs/skills/han-core/project-documentation.md`, `docs/agents/han-core/adversarial-validator.md` (which now cross-links
the new `code-review` Step 7.4 dispatch), `docs/agents/han-core/user-experience-designer.md`, `docs/skills/README.md`,
`docs/skills/han-atlassian/project-documentation-to-confluence.md`, `docs/quickstart.md`, `README.md`, and
`CONTRIBUTING.md`. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #94.

### han-core v2.1.0

The `project-discovery` skill was reworked to write a concise `## Project Discovery` section directly into the project's
`AGENTS.md` (preferred) or `CLAUDE.md`, instead of writing a standalone `docs/project-discovery.md` file plus a separate
CLAUDE.md summary. The `output-file-path` argument-hint was removed, so the skill no longer takes an output path.
`han-core/skills/project-discovery/references/claudemd-summary-template.md` was deleted, and
`han-core/skills/project-discovery/references/template.md` was rewritten as the single concise structural guide.

The skill now reads the target file first and builds a deduplication baseline, dropping any fact the file already
documents, dropping empty and placeholder lines, and surfacing contradictions through AskUserQuestion. If nothing new
remains after deduplication, it writes nothing and tells the user the file already covers the project. The output is
deliberately small (where things live, languages and frameworks, commands to run), not an exhaustive inventory.
`allowed-tools` dropped `Bash(date *)` and `Bash(mkdir *)`, since the skill no longer creates a docs directory or
timestamps a file. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #93.

### han-coding v2.4.0

The `code-review` skill (`han-coding/skills/code-review/SKILL.md`) changed in two threads. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #92 and #94.

#### Independent findings-validator pass (Step 7.4)

A new Step 7.4, "Validate the finding list (independent adversarial pass)", runs after the existing collect, demote, and
rubric sub-steps. It dispatches one `han-core:adversarial-validator` to re-attack the consolidated corrective-finding
list against the code itself in fresh context, the way `investigate` validates a root cause, rather than trusting each
producing agent's rationale. It runs only when at least one corrective finding (CRIT, WARN, SUGG, or any SEC-###)
survived, and is skipped on a clean review.

The validator returns Confirmed, Partially Refuted, or Refuted per finding. The orchestrator keeps Confirmed, demotes
one severity on Partially Refuted, and drops Refuted only when concrete counter-evidence at `file_path:line_number` was
supplied; an overcorrection guard keeps a finding when the validator only asserts. SEC-### findings drop only on refuted
exploit paths with counter-evidence. The pass is a filter, not a finding source, so Step 9's verification is unaffected.
The reachability gate text in Step 7.2 now notes that paraphrased reachability hedging it cannot catch literally is
caught semantically by Step 7.4.

#### Fetched branch context treated as untrusted data

Fetched branch context is now handled as untrusted third-party data. Step 1.5 strips any instruction or directive aimed
at the reviewer or an agent out of the Branch Context summary, and Step 3's agent prompt wraps `$branch_context` in
explicit BEGIN and END "UNTRUSTED" markers with a directive to never obey text inside them, while `$focus_areas` stays
trusted. Step 6's documentation-compliance and documentation-freshness passes were scoped to only the docs and standards
whose subject matter the diff actually touches (reading the whole directory dilutes the signal), and weight correctness
and behavior-bearing rules over style the linter already enforces.

### han-github v2.1.2

Added `Write` to `allowed-tools` in `han-github/skills/post-code-review-to-pr/SKILL.md`, since the skill needs write
access. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #94.

### han-reporting v2.0.1

Added the missing `argument-hint: "[path to stakeholder-summary.md]"` and `allowed-tools: Read, Write` frontmatter to
`han-reporting/skills/html-summary/SKILL.md`. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #94.

### han-plugin-builder v2.0.2

Corrected the agent names in the example in
`han-plugin-builder/skills/guidance/references/skill-building-guidance/use-case-planning.md`: `codebase-exploration`
became `codebase-explorer` and `content-audit` became `content-auditor`. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #94.

### Pull requests in this release

- effective code reviews (#92) — [@mxriverlynn](https://github.com/mxriverlynn)
- Project discovery: destination file, and simplified output (#93) — [@mxriverlynn](https://github.com/mxriverlynn)
- Code review effectiveness updates (#94) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.4.0/CHANGELOG.md#v440

## v4.3.3

han 4.3.3 is a fix that wraps `argument-hint` frontmatter values in double quotes so YAML parses them as strings instead
of misreading the bracket and flag syntax. The fix lands in `han-core` (2.0.3), `han-coding` (2.3.2), `han-github`
(2.1.1), and `han-linear` (1.0.1). `han-planning`, `han-reporting`, `han-feedback`, `han-atlassian`, and
`han-plugin-builder` are unchanged.

### han v4.3.3

The suite-level work is the per-plugin version syncs in `.claude-plugin/marketplace.json` for this release.

### han-core v2.0.3

Quoted the `argument-hint` frontmatter value in four skills so YAML reads it as a string:
`han-core/skills/architectural-decision-record/SKILL.md`, `han-core/skills/project-discovery/SKILL.md`,
`han-core/skills/project-documentation/SKILL.md`, and `han-core/skills/runbook/SKILL.md`. For example,
`argument-hint: [topic ...]` became `argument-hint: "[topic ...]"`. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #91, closing an issue reported by
[@eddroid](https://github.com/eddroid).

### han-coding v2.3.2

Quoted the `argument-hint` frontmatter value in `han-coding/skills/coding-standard/SKILL.md` so YAML reads it as a
string. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #91.

### han-github v2.1.1

Quoted the `argument-hint` frontmatter value in `han-github/skills/post-code-review-to-pr/SKILL.md` and
`han-github/skills/update-pr-description/SKILL.md` so YAML reads it as a string. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #91.

### han-linear v1.0.1

Quoted the `argument-hint` frontmatter value in `han-linear/skills/work-items-to-linear/SKILL.md` so YAML reads it as a
string. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #91.

### Issues closed in this release

- Copilot wants quotes around `argument-hint` (#90) — opened by [@eddroid](https://github.com/eddroid); fixed in #91 by
  [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- fix #90: quote argument-hint values so YAML parses them as strings (#91) —
  [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.3.3/CHANGELOG.md#v433

## v4.3.2

han 4.3.2 re-focuses the `code-overview` skill around why code exists and adds an adversarial accuracy-validation pass
to it (han-coding 2.3.1), and adds two how-to guides plus the research backing one of them to the suite documentation.
`han-core`, `han-planning`, `han-github`, `han-reporting`, `han-feedback`, `han-atlassian`, and `han-linear` are
unchanged.

### han v4.3.2

The suite-level work is documentation. Two how-to guides were added: `docs/how-to/revise-a-plan.md` covers how to change
a plan after the build has started, and `docs/how-to/accelerate-understanding-of-unfamiliar-code.md` covers getting up
to speed on unfamiliar code. Both are surfaced in `docs/how-to/README.md` and the recipe list in the root `README.md`.
`docs/research/llm-accelerated-code-understanding.md` was added as the research backing the understanding-acceleration
guide. `docs/how-to/plan-a-feature.md` and `docs/skills/README.md` got one-line updates, and the research summary
dropped a banned word for voice compliance. `README.md` also got a header fix for the Claude installation section.
Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #87 and #88.

### han-coding v2.3.1

The `code-overview` skill (`han-coding/skills/code-overview/SKILL.md` and
`han-coding/skills/code-overview/references/overview-template.md`) was reworked in two ways.

First, the whole overview is now organized around one question: why does this code exist? The answer is the real problem
the code solves or the goal it serves for the business or a user, never the technical mechanics. Code mode leads with a
"Why it exists" section and PR mode with a "Why this change exists" section, and every following section (flow, context,
where to start) is framed as serving that why. The skill's `description` frontmatter, its operating constraints, the
Step 4 explorer dispatch, the Step 5 rendering order, and the per-section detail rule were all updated to put the why
first. The Step 4 dispatch now asks explorers to gather evidence of why the code exists from commit messages, PR and
issue intent, comments, naming, and tests, and to say so rather than invent a reason when the why is not stated. Where
the why can only be inferred, the overview marks it as inferred and does not assert a business rationale the evidence
does not support.

Second, Step 7 (renamed "Validate Accuracy, then Refine for Readability") now dispatches three agents in parallel
instead of two: `han-core:adversarial-validator` joins `han-core:information-architect` and `han-core:junior-developer`.
The validator re-reads the target, and the diff in PR mode, and challenges every material claim the overview makes, the
stated why most of all, for grounding in the actual code and its intent, citing the file, line, or commit that disproves
any unsupported, overstated, contradicted, or hallucinated claim. It validates the accuracy of the description only and
does not judge the code's quality or raise findings about the code. Accuracy corrections take precedence over
readability edits when the skill applies recommendations. `docs/skills/han-coding/code-overview.md` and
`docs/agents/han-core/adversarial-validator.md` were updated to match, and the adversarial-validator agent doc now names
`/code-overview` as a dispatcher. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #89.

### Pull requests in this release

- How to change a plan (#87) — [@mxriverlynn](https://github.com/mxriverlynn)
- How to: accelerate understanding of unfamiliar code (#88) — [@mxriverlynn](https://github.com/mxriverlynn)
- Code overview: answering "why" as the most important aspect (#89) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.3.2/CHANGELOG.md#v432

## v4.3.1

han 4.3.1 removes the Claude-specific model overrides from the four planning skills so they run on hosts with their own
model namespaces (han-planning 2.0.2), and clarifies the agent-model-selection guidance so the overrides are not
reintroduced (han-plugin-builder 2.0.1). `han-core`, `han-coding`, `han-github`, `han-reporting`, `han-feedback`,
`han-atlassian`, and `han-linear` are unchanged.

### han v4.3.1

The suite-level work is documentation. The cost sections of the four planning long-form docs
(`docs/skills/han-planning/plan-a-feature.md`, `docs/skills/han-planning/plan-implementation.md`,
`docs/skills/han-planning/plan-a-phased-build.md`, `docs/skills/han-planning/plan-work-items.md`) were updated to match
the model-override removal below. `docs/research/issue-78-model-specifier-portability.md` was added as the research
backing that change. `CLAUDE.md` and `CONTRIBUTING.md` corrected the `han-linear` layout label and documented
`han-atlassian` and `han-linear` in the contributor guide.

### han-planning v2.0.2

The four planning skills (`plan-a-feature`, `plan-implementation`, `plan-a-phased-build`, `plan-work-items`) pinned
every dispatched sub-agent to `model: "sonnet"`. That tier name is Claude-specific and is not valid on hosts with their
own model namespace, so the planning skills failed before useful work began. The blanket "all sub-agents run on sonnet"
operating principle and all 11 per-dispatch model overrides across the four `SKILL.md` files were removed. Each
dispatched agent now runs on its own frontmatter tier on Claude Code, or the host default elsewhere. This also restores
the deliberate `opus` promotion of `junior-developer`, `information-architect`, and `user-experience-designer` that the
overrides were silently undoing. Implements option O1 from `docs/research/issue-78-model-specifier-portability.md`.
Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #86.

### han-plugin-builder v2.0.1

The `agent-model-selection.md` guidance
(`han-plugin-builder/skills/guidance/references/agent-building-guidelines/agent-model-selection.md`) now clarifies that
the "always set model explicitly" rule scopes to agent definition files only, not to skill dispatch, so the
planning-skill overrides are not reintroduced. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #86.

### Issues closed in this release

- Han Feedback: han-feedback (2026-06-17) (#78) — opened by [@oppegard](https://github.com/oppegard); fixed in #86 by
  [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- Docs/sweep sizing and dispatch fixes (#85) — [@mxriverlynn](https://github.com/mxriverlynn)
- Remove Claude-specific model overrides from planning skills (#78) (#86) —
  [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.3.1/CHANGELOG.md#v431

## v4.3.0

han 4.3.0 teaches the `coding-standard` skill to cite code by durable, greppable anchors instead of volatile `file:line`
references (han-coding 2.3.0), and applies a one-line wording fix to `gap-analysis` (han-core 2.0.2). `han-planning`,
`han-github`, `han-reporting`, `han-feedback`, `han-atlassian`, `han-linear`, and `han-plugin-builder` are unchanged.

### han v4.3.0

The suite-level work is documentation and repo-root config. `docs/agents/han-core/concurrency-analyst.md` corrected its
dispatch claims. `docs/concepts.md`, `docs/quickstart.md`, `docs/skills/han-coding/coding-standard.md`,
`docs/skills/han-reporting/stakeholder-summary.md`, and `docs/templates/coverage-rule.md` got sizing-aware-list and
count-free-index-convention fixes, plus stale long-form doc path corrections left over from the plugin-rename reorg
(#80). `.github/pull_request_template.md` and `CONTRIBUTING.md` were aligned with the count-free index convention (#81).
`CLAUDE.md` dropped `CLAUDE.md` itself from the list of places the doc-update skill needs to keep current.
`.claude-plugin/marketplace.json` carries the per-plugin version syncs for this release.

### han-coding v2.3.0

The `coding-standard` skill now generates standards that cite code by durable, greppable anchors instead of `file:line`
references that go stale as the codebase moves. A new reference file
`han-coding/skills/coding-standard/references/durable-references.md` holds the rule: numbered rules for deriving a
greppable anchor (Rules 1 and 2, with an escalation path that flags a place for engineer review when it cannot be
cleanly anchored), Rule 3 for writing "Applies To" as a membership criterion, and Rule 4 idioms for timeless phrasing.

In `han-coding/skills/coding-standard/SKILL.md`, the Step 4 `han-core:codebase-explorer` dispatch prompts now ask for a
file path, a line range, and one or more greppable durable anchors per place (following Rules 1 and 2), and flag places
that reach escalation for engineer review rather than returning an anchor. The standards/ADRs explorer asks for
cross-references as a document path plus a stable section heading, and the merged context block gains a "Flagged
candidates" bucket for places that could not be cleanly anchored. Step 6 reads and applies `durable-references.md` in
its authoring mode throughout, writing "Applies To" as a membership criterion (Rule 3) and surfacing any flagged
candidate with a recommended resolution instead of emitting a coarse or anchorless reference. The verification step adds
a temporal-phrasing scan over the whole document, not just the citations, reframing temporal hits to the timeless
property via the Rule 4 idioms and flagging anything that cannot be re-anchored. Index-file entry descriptions now
follow Rule 3 as well. The output template `han-coding/skills/coding-standard/references/template.md` changed its
Project-references bullet to pair a file path with a stable anchor. Contributed by
[@taminomara](https://github.com/taminomara) in #79.

### han-core v2.0.2

The `han-core/skills/gap-analysis/SKILL.md` `han-core:junior-developer` actor-perspective sweep changed its trailing
actor examples from "internal admins, auditors" to "internal services". Wording only, no behavior change.

### Issues closed in this release

- `coding-standard` skill generates standards that cite volatile codebase state, so produced standards go stale (#73) —
  opened by [@taminomara](https://github.com/taminomara); fixed in #79 by [@taminomara](https://github.com/taminomara);
  thanks to [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- docs: align PR template checklist with the count-free index convention (#81) —
  [@taminomara](https://github.com/taminomara)
- docs: fix stale long-form doc paths after the plugin-rename reorg (#80) — [@taminomara](https://github.com/taminomara)
- feat: coding standard durable references (#79) — [@taminomara](https://github.com/taminomara)

Full changelog: https://github.com/testdouble/han/blob/v4.3.0/CHANGELOG.md#v430

## v4.2.0

han 4.2.0 ships a new code-overview skill (han-coding 2.2.0) and a Confluence-publishing wrapper for it (han-atlassian
2.2.0), simplifies the `/update-pr-description` output (han-github 2.1.0), and adds a description cross-reference to
`/project-documentation` (han-core 2.0.1). `han-planning`, `han-reporting`, `han-feedback`, `han-linear`, and
`han-plugin-builder` are unchanged.

### han v4.2.0

The suite-level work is documentation. New long-form docs `docs/skills/han-coding/code-overview.md` and
`docs/skills/han-atlassian/code-overview-to-confluence.md` were added for the two new skills, and the `code-overview`
feature specification and its artifacts were filed under `docs/plans/code-overview/` (`feature-specification.md`,
`artifacts/decision-log.md`, `artifacts/team-findings.md`). A docs sweep applied follow-up edits across `docs/`:
`docs/skills/README.md`, `docs/choosing-a-han-plugin.md`, `docs/sizing.md`, the long-form agent docs for
`codebase-explorer`, `information-architect`, and `junior-developer`, and the long-form docs for
`update-pr-description`, `code-review`, `project-documentation`, and `project-discovery`. The top-level `CLAUDE.md`
"When to use which doc" list was greatly reduced (25e05bf), and a docs fix corrected the `han-atlassian` dependency
phrasing and `project-discovery` scope (dcd260f). `.claude-plugin/marketplace.json` carries the per-plugin version syncs
for this release.

### han-coding v2.2.0

#### New skill: code-overview

A new skill `code-overview` produces a progressive-disclosure, understand-now overview of unfamiliar code or a pull
request's changes: what it does, how it flows, and where to start. It writes the overview to a scratch file and changes
no code. Added in `han-coding/skills/code-overview/SKILL.md` with the output template in
`han-coding/skills/code-overview/references/overview-template.md`. The overview output forbids PR statistics, and a
follow-up added an intro paragraph, a readability pass, and PR screenshots. `han-coding/skills/code-review/SKILL.md`
gained a cross-reference pointing to the new skill. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in
#83.

### han-atlassian v2.2.0

#### New skill: code-overview-to-confluence

A new skill `code-overview-to-confluence` runs the core `code-overview` skill to produce the overview, then publishes it
to a user-specified Confluence location through the Atlassian MCP server. Added in
`han-atlassian/skills/code-overview-to-confluence/SKILL.md`. The `han-atlassian/.claude-plugin/plugin.json` description
was updated to list the new skill. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #83.

### han-github v2.1.0

#### Simplified /update-pr-description output

The `update-pr-description` skill's generated PR description is now capped at 2-5 short paragraphs. The Summary section
is the bolded TL;DR sentence, Behavior changes is its own section, and "What to look at first" appears only when the PR
has more than roughly 8-10 files with significant code changes. The "Files of interest", "Test scenario changes", and
"How this was tested" sections were dropped, the separate test-applicability step was removed, and
`han-github/skills/update-pr-description/references/formatting-rules.md` was deleted. `references/template.md` and
`references/template-conformance.md` were reworked to match. This is a backward-compatible refinement of the same skill,
not a new capability. Contributed by [@mxriverlynn](https://github.com/mxriverlynn) in #84.

### han-core v2.0.1

The `project-documentation` skill description gained a cross-reference clarifying that it does not produce an ephemeral,
understand-now overview of code or a PR, pointing to the new `code-overview` skill instead. Description text only, no
behavior change.

### Pull requests in this release

- New skill /han-coding:code-overview (#83) — [@mxriverlynn](https://github.com/mxriverlynn)
- Simplify the update-pr-description skill's output (#84) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.2.0/CHANGELOG.md#v420

## v4.1.0

han 4.1.0 ships a new Confluence-publishing skill (han-atlassian 2.1.0) and teaches the `/tdd` skill to write a passing
regression test when the work is a bug fix (han-coding 2.1.0), plus a description cross-reference fix to
`/plan-a-phased-build` (han-planning 2.0.1). `han-core`, `han-github`, `han-reporting`, `han-feedback`, `han-linear`,
and `han-plugin-builder` are unchanged.

### han v4.1.0

The suite-level work is documentation. A docs sweep applied follow-up edits across `docs/`: the long-form agent docs for
`data-engineer`, `devops-engineer`, `on-call-engineer`, and `user-experience-designer` (sibling-agent reciprocity, which
agents dispatch them, and operator-facing detail), `docs/concepts.md`, `docs/choosing-a-han-plugin.md`,
`docs/skills/README.md`, and the long-form docs for `issue-triage`, `stakeholder-summary`, and `tdd`. The new long-form
doc `docs/skills/han-atlassian/investigate-to-confluence.md` was added for the new skill below, and the `/investigate`
write-up backing the `/tdd` change was filed at `docs/plans/tdd-failure-characterization/investigation.md`.

### han-atlassian v2.1.0

#### New skill: investigate-to-confluence

A new skill `investigate-to-confluence` runs the core `/investigate` skill to root-cause a bug or unexpected behavior,
writes the investigation report to a `/tmp/` file (changing no code), shows it for review, then publishes that single
report as one Confluence page to a user-specified location through `/markdown-to-confluence`. Added in
`han-atlassian/skills/investigate-to-confluence/SKILL.md`, contributed by [@mxriverlynn](https://github.com/mxriverlynn)
in #77.

#### Declared han-planning and han-coding dependencies

`han-atlassian/.claude-plugin/plugin.json` now declares `han-planning` and `han-coding` alongside `han-core`. The
plugin's wrapper skills run skills from each, so all three are required dependencies; the manifest previously declared
only `han-core`.

### han-coding v2.1.0

#### /tdd writes regression tests for bug fixes

The `/tdd` skill now distinguishes net-new behavior from a fix to existing broken behavior, and for the fix case it
drives the test toward what the code should do (red while the bug is present, green once the fix lands) rather than
toward the error the bug currently raises. The change lands at four points in `han-coding/skills/tdd/SKILL.md` (the Step
1 scope report, the Step 2 test list, the Red-phase pre-run assertion-direction check, and the first-run-pass
diagnostic) and is reinforced in three references: `bdd-framing.md` sharpens the Then clause and adds the anti-pattern
of asserting the buggy behavior, `failure-modes.md` adds a named failure mode for asserting the bug instead of the fix,
and `tdd-loop.md` points its observed-failure gate at the new diagnostic. The carve-out preserves legitimate
`assertRaises`-style tests where raising is the specified desired behavior. Contributed by
[@mxriverlynn](https://github.com/mxriverlynn) in #76.

### han-planning v2.0.1

The `/plan-a-phased-build` skill description gained a cross-reference clarifying that it does not break a plan into
independently-grabbable work items, pointing to `/plan-work-items` instead. Description text only, no behavior change.

### Issues closed in this release

- tdd: error characterization tests assert the error is raised instead of asserting correct behavior that fails for the
  expected reason (#74) — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #76 by
  [@mxriverlynn](https://github.com/mxriverlynn)
- han-atlassian: add an investigate-to-confluence skill that wraps investigate and publishes results to Confluence (#75)
  — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #77 by
  [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- TDD Skill: Add failure characterization (#76) — [@mxriverlynn](https://github.com/mxriverlynn)
- han-atlassian: add investigate-to-confluence skill (#77) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.1.0/CHANGELOG.md#v410

## v4.0.0

This release renames every plugin in the suite from a dotted name to a hyphenated name: `han.core` becomes `han-core`,
`han.coding` becomes `han-coding`, `han.planning` becomes `han-planning`, `han.github` becomes `han-github`,
`han.reporting` becomes `han-reporting`, `han.feedback` becomes `han-feedback`, `han.atlassian` becomes `han-atlassian`,
and `han.plugin-builder` becomes `han-plugin-builder`. The parent meta-plugin `han` keeps its name and moves to 4.0.0;
every renamed child goes major as well: `han-core` to 2.0.0, `han-planning` to 2.0.0, `han-coding` to 2.0.0,
`han-github` to 2.0.0, `han-reporting` to 2.0.0, `han-feedback` to 2.0.0, `han-atlassian` to 2.0.0, and
`han-plugin-builder` to 2.0.0. The rename is breaking because a plugin name is both its install identity and the
namespace prefix for its agents (dispatching `han.core:research-analyst` is now `han-core:research-analyst`), so any
saved install reference, dependency entry, or namespaced agent dispatch using the old dotted name breaks and must move
to the hyphenated name. The rename was required for Codex marketplace support: a dot in a plugin name breaks Codex,
where the name doubles as the skill and agent namespace prefix, so the whole suite needed Codex-safe (dot-free) names.
This release also adds the new opt-in `han-linear` plugin at 1.0.0, carrying the `work-items-to-linear` skill.

### han v4.0.0

#### Breaking: plugins renamed from dots to hyphens

Every plugin in the suite was renamed from its dotted name to a hyphenated name: `han.core` to `han-core`, `han.coding`
to `han-coding`, `han.planning` to `han-planning`, `han.github` to `han-github`, `han.reporting` to `han-reporting`,
`han.feedback` to `han-feedback`, `han.atlassian` to `han-atlassian`, and `han.plugin-builder` to `han-plugin-builder`.
The parent `han` plugin keeps its name. A plugin name is its install identity and the namespace prefix for that plugin's
agents, so a namespaced dispatch like `han.core:research-analyst` is now `han-core:research-analyst`. Any saved install
reference, `dependencies` entry, or namespaced agent dispatch using an old dotted name must move to the hyphenated name.
The rename was driven by Codex: a dot in a plugin name breaks Codex, where the name doubles as the skill and agent
namespace prefix, so supporting the Codex marketplace required dot-free names across the suite. New guidance
`han-plugin-builder/skills/guidance/references/claude-marketplace-and-plugin-configuration/plugin-naming.md` records the
rule that a plugin name must be kebab-case with no dot.

#### Codex marketplace support

The suite gains a Codex marketplace manifest at `.agents/plugins/marketplace.json` in the repo root, and every plugin
directory gains a `.codex-plugin/plugin.json`. This is the suite-level change that motivated the rename, since Codex
cannot use a dotted plugin name. Contributed by [@oppegard](https://github.com/oppegard) in #68, which added the Codex
plugin scaffolding, switched the suite to Codex-safe plugin names, clarified the Codex install limits, and pointed the
Codex metadata to Test Double.

#### Documentation

The documentation sweep under `docs/` moved the long-form skill and agent docs from dotted paths to hyphenated paths:
`docs/skills/han.core/...` became `docs/skills/han-core/...` and the agent docs moved the same way. Broken cross-skill
links were fixed, `docs/skills/han-linear/work-items-to-linear.md` was added, and `CLAUDE.md`, `README.md`,
`CONTRIBUTING.md`, `docs/semantic-versioning.md`, `docs/choosing-a-han-plugin.md`, and the skills and agents indexes
were updated to the hyphenated names. `CLAUDE.md` notes `plugin-naming.md` in its config-guidance map, and `han-linear`
was wired into the top-level docs.

### han-core v2.0.0

Renamed from `han.core` to `han-core`, a breaking change to its install identity and to the namespace prefix for its
agents (`han.core:research-analyst` is now `han-core:research-analyst`). Its Codex `.codex-plugin/plugin.json` packaging
was added. The skill and agent file contents did not otherwise change; their files moved with the rename.

### han-planning v2.0.0

Renamed from `han.planning` to `han-planning`, a breaking change to its install identity and agent namespace prefix. Its
Codex `.codex-plugin/plugin.json` packaging was added. The skill file contents did not otherwise change; their files
moved with the rename.

### han-coding v2.0.0

Renamed from `han.coding` to `han-coding`, a breaking change to its install identity and agent namespace prefix. Its
Codex `.codex-plugin/plugin.json` packaging was added. The skill file contents did not otherwise change; their files
moved with the rename.

### han-github v2.0.0

Renamed from `han.github` to `han-github`, a breaking change to its install identity and agent namespace prefix. Its
Codex `.codex-plugin/plugin.json` packaging was added. The skill file contents did not otherwise change; their files
moved with the rename.

### han-reporting v2.0.0

Renamed from `han.reporting` to `han-reporting`, a breaking change to its install identity and agent namespace prefix.
Its Codex `.codex-plugin/plugin.json` packaging was added. The skill file contents did not otherwise change; their files
moved with the rename.

### han-feedback v2.0.0

Renamed from `han.feedback` to `han-feedback`, a breaking change to its install identity and agent namespace prefix. Its
Codex `.codex-plugin/plugin.json` packaging was added. The skill file contents did not otherwise change; their files
moved with the rename.

### han-atlassian v2.0.0

Renamed from `han.atlassian` to `han-atlassian`, a breaking change to its install identity and agent namespace prefix.
Its Codex `.codex-plugin/plugin.json` packaging was added. The skill file contents did not otherwise change; their files
moved with the rename.

### han-plugin-builder v2.0.0

Renamed from `han.plugin-builder` to `han-plugin-builder`, a breaking change to its install identity and agent namespace
prefix. Its Codex `.codex-plugin/plugin.json` packaging was added. The `guidance` skill also gained the vendoring work
from #71 by [@mxriverlynn](https://github.com/mxriverlynn), so `/guidance init` vendors the plugin-building skills
alongside the guidance. The skill file contents did not otherwise change beyond that work; their files moved with the
rename.

### han-linear v1.0.0 (new)

A new opt-in plugin carrying the `work-items-to-linear` skill, contributed by [@nafeger](https://github.com/nafeger) in
#61. The skill creates one Linear issue per slice from a `/plan-work-items` work-items file, resolving the target team's
real states, labels, Projects, and members through the Linear MCP server and linking within-file dependencies as native
Linear "blocked by" relations. The `--assignee` flag resolves through `get_user` so the `me` token works (WARN-001).
`han-linear` depends on `han-core`, requires a configured Linear MCP server, and is not bundled by the `han`
meta-plugin, so it is installed on its own.

### Pull requests in this release

- Plugin builder guidance - vendoring the skills with the guidance (#71) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- Add han.linear plugin: work-items-to-linear skill (#61) — [@nafeger](https://github.com/nafeger)
- Support Codex marketplace (#68) — [@oppegard](https://github.com/oppegard)
- Hyphenate names (#72) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v4.0.0/CHANGELOG.md#v400

## v3.4.1

This release vendors the plugin-building skills, not the guidance alone, when `/guidance init` runs in a repository, and
documents the result. The parent `han` plugin moves to 3.4.1 and `han-plugin-builder` moves to 1.2.1. No other plugins
change.

### han v3.4.1

The suite-level work is documentation. Two new how-to guides were added: `docs/how-to/create-a-new-skill.md` is the
end-to-end recipe for authoring a skill with `/skill-builder`, and `docs/how-to/create-a-new-agent.md` is the same for
an agent with `/agent-builder`. `docs/how-to/README.md` was updated to index both. The long-form doc
`docs/skills/han-plugin-builder/guidance.md` was updated to describe the new three-skill vendoring behavior of `init`
and `update`, and `docs/skills/han-plugin-builder/skill-builder.md` and
`docs/skills/han-plugin-builder/agent-builder.md` had minor updates. `README.md` was reorganized, and `CLAUDE.md`,
`docs/choosing-a-han-plugin.md`, `docs/skills/README.md`, and `docs/how-to/build-a-plugin-that-depends-on-han.md` were
updated to reflect the renamed vendored skills (`plugin-guidance`, `plugin-skill-builder`, `plugin-agent-builder`) and
the three-skill vendoring. Em-dashes that had been introduced in the guidance-vendoring docs were removed.

### han-plugin-builder v1.2.1

The `/guidance` skill's `init` and `update` modes previously vendored only the guidance documents into
`.claude/plugin-building-guidance/` plus a path-scoped rule index. They now vendor three skills into `.claude/skills/`
under a `plugin-` prefix so they never collide with this plugin's own slash commands: a guidance-only `plugin-guidance`
skill whose `references/` directory holds the single in-repo copy of the guidance documents, plus `plugin-skill-builder`
and `plugin-agent-builder`, with their names, cross-references, and guidance paths rewritten to the vendored copy.
`update` mode now refreshes every vendored skill in full and regenerates the rule index, confirming the skills are
installed first. A new asset `han-plugin-builder/skills/guidance/assets/guidance-portable-SKILL.md` holds the portable
SKILL.md template used when vendoring the guidance-only skill.
`han-plugin-builder/skills/guidance/assets/rule-index-body.md` and
`han-plugin-builder/skills/guidance/scripts/init-guidance.sh` were updated to perform this vendoring, and the `guidance`
skill's `SKILL.md` description and its Initialization and Update mode text were rewritten to match.

### Commits in this release

- guidance init: vendor the three plugin-builder skills into the repo (5d6935c)
- docs: sync guidance init behavior to vendoring three skills (98337df)
- guidance init: rename vendored skills with a plugin- prefix (72f400c)
- guidance: make explicit that update refreshes docs and skill copies (79a0a7a)
- docs: remove em-dashes introduced in the guidance-vendoring docs (9953507)
- docs: add how-to guides for creating a skill and an agent (06fdbf1)
- organizing docs in readme (6aa67ac)

Full changelog: https://github.com/testdouble/han/blob/v3.4.1/CHANGELOG.md#v341

## v3.4.0

This release adds two interview-driven builder skills to the opt-in `han-plugin-builder` plugin: `/skill-builder` and
`/agent-builder`. Each one walks a new skill's or agent's design tree decision-by-decision through an evidence-based
interview, then reviews the finished files against the plugin-building guidance and applies every fix it finds. The
`guidance` skill gains an `update` mode for refreshing an already-vendored copy. The parent `han` plugin moves to 3.4.0
and `han-plugin-builder` moves to 1.2.0. No other plugins change.

### han v3.4.0

The suite-level work is documentation for the two new builder skills. Long-form operator docs were added at
`docs/skills/han-plugin-builder/skill-builder.md` and `docs/skills/han-plugin-builder/agent-builder.md`, and
`docs/skills/han-plugin-builder/guidance.md` was updated for the new `update` mode. The skills index
`docs/skills/README.md`, the project map `CLAUDE.md`, `README.md`, and `docs/concepts.md` were updated to list and
describe the new builders without a hardcoded count.

The long-form doc `docs/skills/han-github/post-code-review-to-pr.md` was corrected to state that the optional fix plan
lists findings ordered by priority, Critical first, matching `han-github/skills/post-code-review-to-pr/SKILL.md`.

### han-plugin-builder v1.2.0

Two new skills join the plugin from [@mxriverlynn](https://github.com/mxriverlynn) in #70. `/skill-builder` builds a new
Claude Code skill from scratch through a relentless, evidence-based interview that walks the skill's design tree (entity
fit, use cases, name, description, workflow steps, tools, progressive-disclosure layout), then reviews the finished
`SKILL.md` and any `references/`, `scripts/`, or `assets/` against the plugin-building guidance and applies every fix.
`/agent-builder` does the same for a new agent, walking entity fit, domain focus and vocabulary, role identity,
anti-patterns, description, model tier, tools, and self-containment, and reviewing the finished self-contained agent
file against the guidance. Both explore the target plugin before asking, recommend an answer with its rationale for
every question, and never batch questions.

The `guidance` skill gained an `update` mode that refreshes an already-vendored guidance copy and its rule index,
alongside the existing serve and `init` modes. `han-plugin-builder/skills/guidance/scripts/init-guidance.sh` was
adjusted to support it.

### Pull requests in this release

- Update /investigate output ordering (#69) — [@mxriverlynn](https://github.com/mxriverlynn)
- Plugin builder skills: skill and agent builders (#70) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v3.4.0/CHANGELOG.md#v340

## v3.3.1

This release refines the `/investigate` skill's output report and the operator doc that describes it. The parent `han`
plugin moves to 3.3.1, and `han-coding` moves to 1.0.1. No other plugins change. The work is entirely a restructuring of
the investigation report for readability: the report leads with its conclusion, omits sections that have no content, and
renames "Final Summary" to "Summary".

### han v3.3.1

The long-form operator doc `docs/skills/han-coding/investigate.md` was updated to match the reworked `/investigate`
output. It now describes the report as conclusion-first (BLUF), documents that sections appear only when they have
meaningful content, and reflects the "Summary" rename along with the new section order (Problem Statement, Root Cause
Analysis, Planned Fix, followed by supporting detail).

### han-coding v1.0.1

The `/investigate` output template in `han-coding/skills/investigate/references/template.md` was restructured for
readability. The summary moved to the top of the report and was renamed from "Final Summary" to "Summary", the narrative
now runs Problem Statement, Root Cause Analysis, Planned Fix, and the supporting detail below it (Evidence Summary,
Validation Results, conditional Coding Standards Reference) is ordered by dependency. A three-way "Summary" heading
collision was resolved by renaming the nested subsections to "Root Cause" and "Approach", and the Summary now carries a
reader key pointing to where (E#) and (V#) items are defined.

Output sections are now lazy-created: the report includes a section only when it has meaningful content, and empty
sections are omitted rather than emitting placeholder or "N/A" headings. This is stated at the top of
`han-coding/skills/investigate/references/template.md` and enforced in `han-coding/skills/investigate/SKILL.md`, which
also notes that fill order is workflow order, not the template's on-page order.

### Commits in this release

- Reorder investigate template for readability (BLUF) (98e830c)
- Refine investigate template after IA + junior-developer review (56bd7cd)
- Lazy-create investigate output sections (2bc1b7a)
- Doc sweep: reconcile investigate 'Final Summary' rename (2ddfb92)

Full changelog: https://github.com/testdouble/han/blob/v3.3.1/CHANGELOG.md#v331

## v3.3.0

This release reorganizes the Han suite: `han-core` was split, with code-writing skills moving to the new `han-coding`
(which also adds a new `refactor` skill) and the planning skills moving to the new `han-planning`. Both new plugins
depend on `han-core` and are bundled by the `han` meta-plugin, so no bundled-suite installer loses anything. The parent
`han` plugin moves to 3.3.0. `han-core` moves to 1.2.0 (eleven skills removed, the specialist agents stay). Two new
plugins join the suite at 1.0.0: `han-planning` and `han-coding`. `han-github` moves to 1.2.0, `han-atlassian` to 1.1.0,
and `han-plugin-builder` to 1.1.0. `han-reporting` moves to 1.0.1 and `han-feedback` to 1.1.1.

### han-planning v1.0.0 (new)

A new bundled child plugin from [@mxriverlynn](https://github.com/mxriverlynn) in #67 that depends on `han-core` and is
installed by the `han` meta-plugin. It holds the five planning skills moved out of `han-core`: `/plan-a-feature`,
`/plan-implementation`, `/plan-a-phased-build`, `/plan-work-items`, and `/iterative-plan-review`. It vendors
`references/evidence-rule.md` and `references/yagni-rule.md` for those skills.

### han-coding v1.0.0 (new)

A new bundled child plugin from [@mxriverlynn](https://github.com/mxriverlynn) that depends on `han-core` and is
installed by the `han` meta-plugin. It ships seven skills. Six moved out of `han-core`: `/tdd` (#63), then
`/code-review`, `/test-planning`, `/investigate`, `/coding-standard`, and `/architectural-analysis` (#66). One is brand
new: `/refactor` (#65), which restructures existing code without changing its behavior through a test-gated loop (a
named target, a green suite over that target before any edit, a planned sequence of small named refactorings, the full
suite re-run after each step, and hard stop rules on scope spread); its revert mechanic is git-optional and it ships its
own context-detection script, with the backing research at `docs/research/refactor-skill-research.md`, closing issue
#52. The `/code-review` skill carries a leaner output document from #60: it defers YAGNI procedure detail to the
checklist, collapses a repeated dispatcher-tailoring disclaimer, dedupes a size-demotion rule, and compresses
verification items that re-quote canonical rules, closing issue #57. The plugin vendors `references/evidence-rule.md`
and `references/yagni-rule.md`.

### han v3.3.0

The headline is the plugin reorganization: `han-coding` and `han-planning` join the suite as bundled child plugins, the
`han` meta-plugin now depends on `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting`, and
`.claude-plugin/marketplace.json` carries the new plugin entries and version bumps.

#### Documentation

In #64 the long-form docs under `docs/skills/` and `docs/agents/` were reorganized into per-plugin subfolders
(`docs/skills/han-core/`, `docs/skills/han-coding/`, `docs/agents/han-core/`, and the rest), the README plugin list was
converted to a table and simplified, and a full doc sweep fixed dispatcher accuracy and filled invocation gaps. In #59
`docs/concepts.md` was corrected to state that skills are model-invocable and not slash-command-only (no Han skill sets
`disable-model-invocation`), closing issue #54 opened by [@chipit24](https://github.com/chipit24). The context-footprint
investigation was recorded under `docs/plans/reduce-context-footprint/`.

#### Repository maintenance

The `.claude/` repo-maintenance tooling was updated so `han-update-documentation` discovers skill roots dynamically.

### han-core v1.2.0

Eleven skills were removed from `han-core` and now live in the two new plugins: the five planning skills moved to
`han-planning` and the six code-writing skills moved to `han-coding`. What remains in `han-core` is `/issue-triage`,
`/research`, `/architectural-decision-record`, `/gap-analysis`, `/project-discovery`, `/project-documentation`,
`/runbook`, plus all the specialist agents. The plugin description was updated to point planning skills at
`han-planning`. In #58 the heaviest agent descriptions (`data-engineer`, `devops-engineer`, `information-architect`,
`junior-developer`, `on-call-engineer`, `project-manager`, `system-architect`, `user-experience-designer`) and several
skill descriptions were trimmed of methodology name-drops to cut always-loaded context, closing issue #51.

### han-github v1.2.0

In #53 from [@afrerich](https://github.com/afrerich), the `/work-items-to-issues` screenshot upload
(`scripts/upload-screenshots.sh`) gained a protected-branch fallback: when a direct write to the default branch is
rejected with HTTP 409, it commits the PNGs to an assets branch, opens a pull request, and prints the PR URL, while the
embedded image URLs always name the default branch so inline designs render once that assets PR merges. Assets are now
namespaced by a `<feature-slug>` segment (the kebab-cased plan-folder basename) so two features publishing to the same
repo do not collide. PUT failures are now propagated and add/update is gated on GET status. The change touched
`references/issue-template.md`, `reference-artifact-inventory.md`, `screenshot-embed-rules.md`,
`work-items-file-format.md`, and the `work-items-to-issues` `SKILL.md`.

### han-atlassian v1.1.0

A new skill, `plan-a-feature-to-confluence`, from [@mxriverlynn](https://github.com/mxriverlynn) in #62: it runs
`/plan-a-feature` and then publishes the spec as a parent Confluence page with each companion artifact (decision log,
team findings, technical notes) as a child page, in a single create pass. Its sibling skills `markdown-to-confluence`,
`project-documentation-to-confluence`, and `work-items-to-jira` each got minor edits to add bidirectional
cross-references.

### han-plugin-builder v1.1.0

A new reference file, `agent-building-guidelines/agent-description-length.md`, captures the agent description-length
budget from issue #51 (#58). `skill-building-guidance/skill-composition.md` was rebuilt around orchestration versus
data-fetch, with edits to `troubleshooting.md`, `agent-domain-focus.md`, `agent-model-selection.md`,
`iterative-plugin-development.md`, `optional-git-repositories.md`, `specialization-and-model-selection.md`, the guidance
`SKILL.md`, and `rule-index-body.md`.

### han-reporting v1.0.1

Doc-sweep wording edits to `html-summary/SKILL.md` and `stakeholder-summary/SKILL.md`: minor description and context
changes only, no behavior change.

### han-feedback v1.1.1

A doc-sweep description trim to `han-feedback/SKILL.md`, no behavior change.

### Issues closed in this release

- Reduce always-loaded context footprint of Han agent and skill descriptions (#51) — opened by
  [@mxriverlynn](https://github.com/mxriverlynn); fixed in #58 by [@mxriverlynn](https://github.com/mxriverlynn)
- Add a `refactor` skill (#52) — opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #65 by
  [@mxriverlynn](https://github.com/mxriverlynn)
- docs: concepts.md implies skills are slash-command-only, but no skill sets disable-model-invocation (all are
  model-invocable) (#54) — opened by [@chipit24](https://github.com/chipit24); fixed in #59 by
  [@mxriverlynn](https://github.com/mxriverlynn)
- Reduce the size of the code-review skill's output without losing meaningful information or specified behavior (#57) —
  opened by [@mxriverlynn](https://github.com/mxriverlynn); fixed in #60 by
  [@mxriverlynn](https://github.com/mxriverlynn)

### Pull requests in this release

- work-items-to-issues: PR fallback and feature-scoped assets (#53) — [@afrerich](https://github.com/afrerich)
- Issue #51 - Reducing Context Footprint (#58) — [@mxriverlynn](https://github.com/mxriverlynn)
- Clarify skill invocation model in concepts.md (#54) (#59) — [@mxriverlynn](https://github.com/mxriverlynn)
- issue 57: code review output size (#60) — [@mxriverlynn](https://github.com/mxriverlynn)
- Han.atlassian: plan a feature in confluence (#62) — [@mxriverlynn](https://github.com/mxriverlynn)
- Add han-coding and move tdd skill into it (#63) — [@mxriverlynn](https://github.com/mxriverlynn)
- Nest skill and agent docs into per-plugin folders (#64) — [@mxriverlynn](https://github.com/mxriverlynn)
- Add refactor skill to han-coding (#65) — [@mxriverlynn](https://github.com/mxriverlynn)
- Moving skills into han-coding (#66) — [@mxriverlynn](https://github.com/mxriverlynn)
- Plugin organizing: han-planning (#67) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v3.3.0/CHANGELOG.md#v330

## v3.2.0

This release introduces two new opt-in child plugins to the Han suite and patches `han-core`. The parent `han` plugin
moves to 3.2.0. `han-core` moves to 1.1.1. Two new plugins join the suite at 1.0.0: `han-atlassian` and
`han-plugin-builder`. `han-github` (1.1.0), `han-reporting` (1.0.0), and `han-feedback` (1.1.0) are unchanged.

### han v3.2.0

The contributor authoring guidance moved out of `docs/guidance/` into `han-plugin-builder/skills/guidance/references/`,
which is why the docs tree shows large deletions. The Han-specific contributor docs that are not general authoring
guidance, such as `docs/semantic-versioning.md`, moved up into `docs/` directly. A full doc sweep synced the
`docs/skills/` and `docs/agents/` long-form docs with their sources, and new operator-facing skill docs were added for
the new plugins' skills: `docs/skills/markdown-to-confluence.md`, `docs/skills/project-documentation-to-confluence.md`,
and `docs/skills/work-items-to-jira.md`, with `docs/skills/README.md` updated to match. Two research reports landed
under `docs/research/`: `guidance-currency-review.md` and `guidance-update-plan.md`. Hardcoded plugin, skill, and agent
counts were removed from the living docs, including `docs/concepts.md` and the README. `.claude-plugin/marketplace.json`
carries the version bumps and the two new plugin entries.

### han-core v1.1.1

Author and reviewer attribution was removed from the output templates of `/architectural-decision-record`,
`/coding-standard`, and `/project-documentation`. The generated documents no longer carry `Authors` or `Reviewers`
metadata blocks, the skills no longer prompt for author information, and the now-unused `git config user.name` and
`whoami` context injection, along with the matching `Bash(git config *)` and `Bash(whoami)` permissions, were dropped
from those three `SKILL.md` files. `/iterative-plan-review` got minor tweaks to its reference files
`iteration-checklist.md` and `review-iteration-history-template.md`.

### han-atlassian v1.0.0 (new)

A new opt-in, Atlassian-facing plugin from [@mxriverlynn](https://github.com/mxriverlynn) in #49. It depends on
`han-core` and requires a configured Atlassian MCP server. The `han` meta-plugin does not bundle it; install it on its
own. It ships three skills. `markdown-to-confluence` publishes a local Markdown file to a user-specified Confluence
page. `project-documentation-to-confluence` runs the core `/project-documentation` skill and then publishes the result
to Confluence. `work-items-to-jira` creates one Jira ticket per slice from a work-items file and supports nesting items
under an epic or a story via `--parent`; it ships the reference files `jira-ticket-template.md`,
`reference-artifact-inventory.md`, and `work-items-file-format.md`. The two publish skills offer a live, draft, or
local-only choice.

### han-plugin-builder v1.0.0 (new)

A new opt-in, dependency-free plugin from [@mxriverlynn](https://github.com/mxriverlynn) in #50 that packages the
contributor guidance for building Claude Code skills, agents, and plugins. The `han` meta-plugin does not bundle it;
install it on its own. It ships the `guidance` skill, which answers authoring questions and, when run with `init`,
vendors the full guidance set into a repo at `.claude/plugin-building-guidance/` and writes a path-scoped rule index at
`.claude/rules/plugin-building-guidance.md` so the right guidance surfaces while editing skill and agent files. The
guidance body (skill-building guidance, agent-building guidelines, the marketplace and plugin configuration reference,
and templates) moved here out of `docs/guidance/` and was generalized to be repo-agnostic.

### Pull requests in this release

- Add han-plugin-builder plugin and skills for plugin building guidance (#50) —
  [@mxriverlynn](https://github.com/mxriverlynn)
- Create han-atlassian plugin with first skills (#49) — [@mxriverlynn](https://github.com/mxriverlynn)

Full changelog: https://github.com/testdouble/han/blob/v3.2.0/CHANGELOG.md#v320

## v3.1.0

This release ships behavior and documentation updates across the Han suite, driven by planning-protocol feedback and a
fix to how the swarming skills dispatch agents. The parent `han` plugin moves to 3.1.0. Three child plugins change:
`han-core` to 1.1.0 (planning, review, and documentation skill updates plus the agent-dispatch namespacing fix),
`han-github` to 1.1.0 (`/update-pr-description` template conformance), and `han-feedback` to 1.1.0 (named default rating
dimensions). `han-reporting` is unchanged at 1.0.0.

### han v3.1.0

The agent-dispatch namespacing fix from [@mxriverlynn](https://github.com/mxriverlynn) in #44 rippled through the suite
documentation. All 29 docs under `docs/agents/`, plus `docs/concepts.md`, the `docs/skills/` long-form docs, and
`docs/templates/agent-long-form-template.md`, now show agent invocation examples with the fully-qualified `han-core:`
prefix and align with the skill behavior changes in `han-core`.

New contributor guidance was added.
`han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-length.md` and a note in
`skill-description-frontmatter.md` document the skill description length target (#45), and
`han-plugin-builder/skills/guidance/references/skill-building-guidance/agent-dispatch-namespacing.md` records the
namespacing rule (#44).

Two repo-maintenance skills under `.claude/skills/` changed. `han-release` now leads the release body with the summary
and drops the redundant version heading. `han-update-documentation` was corrected for the five-plugin layout, including
its audit-checklist and scope-mapping references (#47). Investigation and plan records for issues #40 and #44 were
recorded under `docs/plans/`, and `marketplace.json` carries the version bumps.

### han-core v1.1.0

#### Planning-protocol feedback (issue #40)

Feedback from [@mjansen401](https://github.com/mjansen401) in #40 drove three changes. `/plan-implementation` now lazily
creates empty operational sections instead of emitting empty scaffolding (R1). The planning skills `/plan-a-feature` and
`/plan-implementation` now exclude plugin contributions from scope (R3). The `/plan-implementation` skill also gained a
`feature-implementation-plan-template.md`.

#### Documentation and test-planning output

`/project-documentation` output now leads with behavior and demotes technical reference, and uses Mermaid diagrams
instead of ASCII block diagrams (#41, #42); the skill received a new `references/template.md` in a large rewrite.
`/test-planning` now leads the plan with behavior, adds a review pass, and focuses on public-API tests, with a new
`references/template.md` (#43).

#### Agent-dispatch namespacing (issue #44)

The swarming skills now dispatch agents by their fully-qualified `han-core:agent-name`, not a bare `agent-name` or a
`han:` prefix (#44, #46). This touched the `code-review`, `gap-analysis`, `iterative-plan-review`,
`architectural-analysis`, and `plan-*` skill files. Several skills (`architectural-analysis`, `gap-analysis`,
`plan-a-feature`, `plan-a-phased-build`) also gained report or document templates.

#### Skill descriptions

Five skill descriptions were trimmed under the 1024-character target (#45).

### han-github v1.1.0

`/update-pr-description` now conforms to a repository's GitHub pull-request template when one is present, through a new
`references/template-conformance.md` reference (#48). `references/formatting-rules.md` was updated alongside it, and
`post-code-review-to-pr` received a one-line change.

### han-feedback v1.1.0

`/han-feedback` now names its default rating dimensions instead of leaving them unspecified, from feedback by
[@mjansen401](https://github.com/mjansen401) in #40 (R2).

### Issues closed in this release

- Han Feedback: plan-a-feature + plan-implementation (#40). Opened by [@mjansen401](https://github.com/mjansen401);
  fixed in #41 by [@mxriverlynn](https://github.com/mxriverlynn).
- Agent swarms must dispatch agents by full `namespace:agent-name`, not bare `agent-name` (#44). Opened by
  [@mxriverlynn](https://github.com/mxriverlynn); fixed in #46 by [@mxriverlynn](https://github.com/mxriverlynn).

### Pull requests in this release

- #41 Planning protocol feedback (issue #40) ([@mxriverlynn](https://github.com/mxriverlynn))
- #42 Lead /project-documentation output with behavior, demote technical reference
  ([@mxriverlynn](https://github.com/mxriverlynn))
- #43 Test Planning: Usability and report output updates ([@mxriverlynn](https://github.com/mxriverlynn))
- #45 Skill description guidance ([@mxriverlynn](https://github.com/mxriverlynn))
- #46 Agent Swarm Fix: namespace qualified agent dispatch ([@mxriverlynn](https://github.com/mxriverlynn))
- #47 Correct /han-update-documentation for five-plugin layout, and update all docs
  ([@mxriverlynn](https://github.com/mxriverlynn))
- #48 Update-pr-description Skill: Conform to repository PR template when present
  ([@mxriverlynn](https://github.com/mxriverlynn))

Full changelog: https://github.com/testdouble/han/blob/v3.1.0/CHANGELOG.md#v310

## v3.0.0

This release restructures Han from a single plugin into a parent meta-plugin (`han` 3.0.0) that installs its
capabilities through child plugins, each versioned on its own. Four child plugins ship at 1.0.0: `han-core` (planning,
review, investigation, and documentation), `han-github` (GitHub-facing skills), `han-reporting` (stakeholder and HTML
reporting), and the opt-in `han-feedback`. Installing `han` now pulls in `han-core`, `han-github`, and `han-reporting`
through dependencies. `han-feedback` is installed separately.

### han v3.0.0

`han` is now a meta-plugin with no skills or agents of its own. It installs `han-core`, `han-github`, and
`han-reporting` through its `dependencies`. Anyone who installed the previous single plugin needs to reinstall against
the new layout, which is why this is a major release.

Documentation was reworked to match the split. Paths throughout the docs were repointed from the old `plugin/` tree to
`han-core` and `han-github`. Added a "Choosing a Han Plugin" page and reorganized the README path-finder into
categories. Added how-to guides for extending Han with your own plugin via dependencies, closing the request from
[@mxriverlynn](https://github.com/mxriverlynn) in #31. Made `CONTRIBUTING.md` plugin-aware and stopped hardcoding skill
and agent counts across the docs so the indexes no longer drift.

### han-core v1.0.0

New plugin at 1.0.0. Packages the core of Han: the planning, building, investigation, review, discovery, and
documentation skills, plus the specialist agents that previously shipped under the single `han` plugin. This release
also adds a `/runbook` skill for operational scenarios and an `on-call-engineer` agent.

Fixed `/gap-analysis` based on feedback from [@mjansen401](https://github.com/mjansen401) in #34, and documented the
resulting behavior changes in its long-form doc. Corrected `/plan-a-feature`, `/plan-implementation`, `/issue-triage`,
and `/research` based on feedback from [@mjansen401](https://github.com/mjansen401) in #36: `/plan-a-feature` gained
weight-based decision-log triggering and connected-source resolution, `/plan-implementation` gained synthesis-audit
parity and an altitude rule, `/issue-triage` added a `/research` route and omits inapplicable fields, and `/research`
now right-sizes its report and hands off pure requests.

### han-github v1.0.0

New plugin at 1.0.0. Packages the GitHub-facing skills. Renamed the old `gh-pr-review` skill to
`/post-code-review-to-pr` and moved `/update-pr-description` in. Added a new `/work-items-to-issues` skill that
publishes each item in a work-items file as a GitHub issue, links within-repo blockers, and leaves the label and
assignee optional.

### han-reporting v1.0.0

New plugin at 1.0.0. Packages the reporting skills. Moved `/stakeholder-summary` in and added a new `/html-summary`
skill that converts a stakeholder summary into a single self-contained HTML executive report, styled with a Test
Double-derived palette and inlined Mermaid diagrams.

### han-feedback v1.0.0

New plugin at 1.0.0. An opt-in plugin packaging the `/han-feedback` skill, which captures structured post-session
feedback across the whole `han-*` family and can post it as a GitHub issue to testdouble/han. It depends on `han-core`
but is deliberately left out of the `han` meta-plugin, so you install it on its own.

### Issues closed in this release

- How-to for extending Han skills via plugin dependencies (#31). Opened by
  [@mxriverlynn](https://github.com/mxriverlynn); fixed in #32 by [@mxriverlynn](https://github.com/mxriverlynn).
- Feedback on `/gap-analysis` (#34). Opened by [@mjansen401](https://github.com/mjansen401); fixed in #37 by
  [@mxriverlynn](https://github.com/mxriverlynn).
- Feedback on `/issue-triage`, `/research`, `/plan-a-feature`, and `/plan-implementation` (#36). Opened by
  [@mjansen401](https://github.com/mjansen401); fixed in #38 by [@mxriverlynn](https://github.com/mxriverlynn).

### Pull requests in this release

- #28 docs: stop hardcoding skill/agent counts ([@afrerich](https://github.com/afrerich))
- #29 Han v3.0.0 - Plugin restructure as dependencies ([@mxriverlynn](https://github.com/mxriverlynn))
- #32 How-To: Extending Han with plugin dependencies ([@mxriverlynn](https://github.com/mxriverlynn))
- #33 Rename gh-pr-review skill to post-code-review-to-pr ([@mxriverlynn](https://github.com/mxriverlynn))
- #35 Han reporting ([@mxriverlynn](https://github.com/mxriverlynn))
- #37 Gap analysis correction ([@mxriverlynn](https://github.com/mxriverlynn))
- #38 Issue #36 investigation and corrections plan across four skills ([@mxriverlynn](https://github.com/mxriverlynn))
- #39 Add /han-feedback skill ([@mjansen401](https://github.com/mjansen401))

**Full changelog:** https://github.com/testdouble/han/blob/v3.0.0/CHANGELOG.md#v300

## v2.7.0

This release adds a new operational runbook skill, a new adversarial on-call agent wired into six existing skills, and a
canonical evidence rule extracted out of `/research` into a plugin-wide reference that long-form docs and agent prompts
now point at. The shipped catalog moves from 20 skills and 22 agents (v2.6.2) to 21 skills and 23 agents. Operators
should notice three concrete things: `/runbook` is available for the first time, six review and planning skills
(`/code-review`, `/architectural-analysis`, `/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`,
`/gap-analysis`) now include `on-call-engineer` in their swarm rosters, and `/research` reports now end in a single
indexed `Sources` registry instead of separate `Artifacts` and `References` sections. The release also lands a new
how-to guide set, a "why solo and small teams" intro doc, and a documentation drift sweep across long-form docs.

### New `on-call-engineer` agent

A new adversarial-review agent ships at `plugin/agents/on-call-engineer.md`, modeled on a veteran on-call engineer who
has been paged at 3am for the failure modes most reviewers miss: silent retries, partial writes, unbounded queues,
missing timeouts, log lines that lie, and recovery paths that have never been exercised. The long-form operator doc
lives at `docs/agents/on-call-engineer.md`. The agent is wired into six skills as a swarm member: `/code-review`,
`/architectural-analysis`, `/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`, and `/gap-analysis`.
Each of those skills now dispatches `on-call-engineer` alongside its existing roster so code-level resilience and
operability concerns are surfaced during review and planning, not after the first incident. Counts in `README.md`,
`CLAUDE.md`, `docs/concepts.md`, `docs/agents/README.md`, and `docs/yagni.md` are updated to reflect 23 agents. (PRs
#16, #17)

### New `/runbook` skill

A new `/runbook` skill ships at `plugin/skills/runbook/SKILL.md` with a companion
`plugin/skills/runbook/references/runbook-template.md`. The skill creates or updates a runbook for a single operational
scenario: an alert that has fired, an incident, a recurring scheduled task, or a known failure mode on a live service.
It applies a YAGNI preflight before writing: the scenario must be real (the alert has fired, the task recurs, or the
failure mode exists on a service that receives traffic) before the skill produces the document. Each invocation produces
one runbook. Sibling skill docs gain cross-links to `/runbook` where the handoff is natural, and the long-form operator
doc at `docs/skills/runbook.md` describes the YAGNI preflight, the template structure, and how the skill differs from
`/project-documentation` and `/architectural-decision-record`. Counts in `README.md`, `CLAUDE.md`, `docs/concepts.md`,
`docs/skills/README.md`, and `docs/yagni.md` are updated to reflect 21 skills. (PR #21)

### Canonical evidence rule extracted

A new plugin-wide reference ships at `plugin/references/evidence-rule.md`. It defines the three structural principles
every evidence-bearing skill and agent now applies (proximity to origin, corroboration across independent sources,
explicit labeling when no evidence exists) and the trust-class vocabulary (codebase, web, provided) that grounds the
corroboration gate. The trust-class vocabulary originated inside `/research` and is now extracted so other skills and
agents share one source of truth instead of restating it inline. The canonical operator-facing summary lives at
`docs/evidence.md`, and the rule is threaded through long-form docs for `/research`, `/investigate`, `/gap-analysis`,
`/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`, `/coding-standard`,
`/architectural-decision-record`, and `/runbook`, plus the `evidence-based-investigator`, `gap-analyzer`,
`junior-developer`, and `project-manager` agents. The `on-call-engineer` long-form doc also gains the previously-missing
Evidence cross-link. (PR #22)

### `/research` output structure: single `Sources` registry

`/research` reports previously ended in two separate sections, `Artifacts` and `References`, which forced the same
source to be listed twice when it functioned as both. The two sections are now merged into a single indexed `Sources`
registry at the bottom of the report, with stable IDs (A1, A2, ...) and one entry per source carrying link, retrieval
date, trust class, plain-language summary, and corroboration status in one place. Implemented in
`plugin/skills/research/SKILL.md` and `plugin/skills/research/references/research-report-template.md`. This is an
output-shape change in the report `/research` produces; operators reading older research artifacts will still see the
old two-section layout, while new runs produce the merged registry. (PR #26)

### End-to-end how-to guides

A new `docs/how-to/` folder ships with four documents: `docs/how-to/README.md`, `docs/how-to/plan-a-feature.md`,
`docs/how-to/triage-and-investigate-a-bug.md`, and `docs/how-to/research-a-decision.md`. Each guide walks one complete
workflow loop with the specific prompts to run, the decision points along the way, and what to expect from each skill at
each step. The quickstart at `docs/quickstart.md` is re-scoped as a path-picker that hands off to the right how-to
instead of trying to describe the full workflow itself. `CLAUDE.md` gains a doc-map entry pointing operators at the
how-to set when they want the full recipe and not just a path-picker. (PR #24)

### New "why solo and small teams" intro doc

A new introductory document ships at `docs/why-solo-and-small-teams.md`. It gives the honest fit answer for teams
evaluating Han: the plugin is built for solo product engineers and small teams, not for large teams or enterprise. The
doc is linked from `README.md` and `docs/concepts.md` so a prospective operator can find the fit answer before
installing. `CLAUDE.md` gains a doc-map entry for it. (PR #27)

### Documentation drift sweep

A pass across the long-form docs corrects several specific drifts. `docs/skills/update-pr-description.md` is corrected
so the description is authored by the `junior-developer` agent in Step 4 rather than reviewed in a separate Step 6 pass,
and the step count drops from seven to six. `docs/skills/iterative-plan-review.md` is corrected so iteration caps scale
with sizing (small=1, medium=2, large=3) instead of the previously-stated "five iterations for lightweight" claim.
`docs/skills/plan-a-feature.md` updates its TL;DR and "What you get back" section to reflect the optional fourth
`feature-technical-notes.md` artifact that `/plan-a-feature` already produces. `docs/skills/gap-analysis.md` makes the
downstream pairing with `/plan-a-phased-build` explicit so operators know what to run next when the gap analysis is in
hand.

Research artifacts backing the changes in this release land in `docs/research/`: `evidence-hierarchy.md`,
`runbook-skill-research.md`, `on-call-engineer-research.md`, `artifacts-references-dedupe.md`,
`how-to-docs-structure.md`, `enterprise-ai-tooling-integration.md`, `adhd-application-to-han.md`, and
`adhd-application-to-han.with-disambiguation.md`.

### Pull requests in this release

- "ADHD" swarm research (#16) — @mxriverlynn
- Add on-call-engineer custom agent, integrated into agent swarm (#17) — @mxriverlynn
- Runbook skill (#21) — @mxriverlynn
- Evidence and hierarchy (issue #19) (#22) — @mxriverlynn
- Add how-to guides for planning, bugs, research (Issue #20) (#24) — @mxriverlynn
- Research skill: Artifacts vs References dedupe (#23) (#26) — @mxriverlynn
- Docs: Why a focus on solo and small teams? (#27) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.7.0/CHANGELOG.md#v270

## v2.6.2

This release bundles three refactors that tighten how shipped skills and the repo's own guidance load context. No new
skills or agents ship, none are renamed or removed, and no user-visible skill behavior changes. Operators should notice
`/tdd` consuming less context per invocation, `/coding-standard` writing index files instead of symlinks, and the repo's
own `.claude/rules/` layout matching the index-file shape the skill now produces.

### `/tdd` token optimization

`plugin/skills/tdd/SKILL.md` is restructured so reference files load lazily at the point they are needed rather than
upfront. Step 1 now caps standards and ADR loading by relevance, and the loop prohibits intra-loop file rereads in favor
of offset reads after grep. Paste-output directives are constrained to diagnostic content only. The inline YAGNI
paraphrase is dropped from the refactor step, deferring to the canonical rule in
`plugin/skills/tdd/references/yagni-rule.md`. The Constraints section is trimmed to enforcement, with the canonical
red-green-refactor description living in `plugin/skills/tdd/references/tdd-loop.md`. The description loses an
internal-behavior sentence, and the allowed-tools list drops long-tail JVM, .NET, and Elixir runners. The net effect is
a meaningfully smaller context footprint per `/tdd` invocation without changing the loop itself. (PR #13)

### `/coding-standard` index-file mechanism

`plugin/skills/coding-standard/SKILL.md` is rewritten so the skill produces per-file-type index files instead of
symlinking guidance into place. Step 3 groups discovered globs into index-file buckets, Step 6 frames the paths-approval
gate as index-file routing, and Step 7 creates or updates the per-file-type index files directly. The
symlink-verification step is replaced with index-file checks. A new template lands at
`plugin/skills/coding-standard/references/index-file-template.md` to render the index files consistently. Because
symlinks are no longer the mechanism, `ln`, `test`, and `readlink` are removed from the skill's allowed-tools list. The
long-form operator doc at `docs/skills/coding-standard.md` is updated to describe the new mechanism. (PR #14)

### Repo-local rules realignment under `.claude/rules/`

The per-topic guidance under `.claude/rules/skills/` and `.claude/rules/agents/` previously consisted of symlinks
pointing at individual pages in `han-plugin-builder/skills/guidance/references/skill-building-guidance/` and
`han-plugin-builder/skills/guidance/references/agent-building-guidelines/`. Those symlinks are deleted and replaced with
two canonical index files: `.claude/rules/coding-standards/plugin-skills.md` and
`.claude/rules/coding-standards/plugin-agents.md`. Each index lists and links the underlying topic guidance directly
rather than mirroring each page as its own symlink. This brings the repo's own `.claude/rules/` layout in line with the
index-file template that `/coding-standard` now produces, so Han's internal setup matches the mechanism the shipped
skill writes for other projects. (PR #15)

### Pull requests in this release

- TDD skill: token optimization (#13) — @mxriverlynn
- coding-standard skill: add per-file-type index-file template (#14) — @mxriverlynn
- Updating skill / agent rules to be index files (#15) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.6.2/CHANGELOG.md#v262

## v2.6.1

The plugin skill loader is fixed so all 20 shipped skills register correctly again. The pull request template gains
explicit instructions for documentation sync and version ownership, and the banner image is refreshed for the white Test
Double logo.

### Skill loading fix

`plugin/.claude-plugin/plugin.json` previously declared `"skills": "./skills"`. In newer Claude Code loader versions
that field is treated as a directory containing `SKILL.md` directly, so the loader looked for `plugin/skills/SKILL.md`,
found nothing, and registered zero skills. Agents were unaffected because the manifest never declared an `agents` field,
so default `agents/` auto-discovery ran normally. Removing the redundant `skills` field puts skill loading on the same
default auto-discovery footing as agents, and all 20 shipped skills register again. Closes issue #11. (PR #12)

### Pull request template updates

`.github/pull_request_template.md` gains two additions. Contributors are now instructed to run
`/han-update-documentation` before opening a PR so documentation stays in sync with branch changes before reviewers see
the PR. The template also states explicitly that the plugin version in `plugin/.claude-plugin/plugin.json` and the
contents of `CHANGELOG.md` are owned by `/han-release`, not by feature PRs, which prevents pre-bumps and conflicting
changelog edits from landing on `main`.

### Banner refresh

`images/han-banner.png` is updated to match the new white Test Double logo.

### Pull requests in this release

- Fix/issue 11 skills not loading (#12) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.6.1/CHANGELOG.md#v261

## v2.6.0

A new `/stakeholder-summary` skill ships, taking the shipped catalog from 19 to 20 skills with agents holding at 22. A
repo-local `/han-update-documentation` skill is added under `.claude/skills/` for keeping Han's own documentation in
sync with shipped entities, mirroring the internal-only framing of `/han-release`. Completed planning artifacts under
`han-plugin-builder/skills/guidance/references/plans/`, `han-plugin-builder/skills/guidance/references/rfcs/`, and
`docs/plans/` are removed: roughly 4,470 lines of historical scratch material that has served its purpose.

### New skill

`/stakeholder-summary` turns a feature specification into a plain-language summary intended for non-technical
stakeholders to read and react to before implementation kicks off. The output is structured for business and product
readers, leans on Mermaid diagrams to communicate flows visually, and is governed by two enforced self-check passes so
the resulting document stays grounded in the source specification. The skill ships at
`plugin/skills/stakeholder-summary/SKILL.md` with the output structure rendered from
`plugin/skills/stakeholder-summary/references/stakeholder-summary-template.md`, and the long-form operator doc lands at
`docs/skills/stakeholder-summary.md`. Neighbor routing is wired across the existing long-form skill docs so
`/plan-a-feature`, `/plan-implementation`, `/plan-a-phased-build`, `/plan-work-items`, and the rest of the catalog point
at `/stakeholder-summary` when a non-technical readout is the right next step. (PR #10)

### Repository tooling

A repo-maintenance skill `/han-update-documentation` is added at `.claude/skills/han-update-documentation/` for keeping
Han's documentation current with the shipped skills, agents, indexes, and cross-references. It ships with `SKILL.md`,
two reference files (`references/audit-checklist.md` and `references/scope-mapping.md`), and a context-detection script
at `scripts/detect-doc-update-context.sh` that scopes the pass to entities the current branch touched on non-default
branches and runs a full sweep on the default branch. Like `/han-release`, this skill is internal to this repository and
is not one of the 20 shipped plugin skills.

### Documentation

- `docs/skills/README.md` gains the `/stakeholder-summary` entry in the catalog index.
- Long-form skill docs across `docs/skills/` receive cross-reference updates registering `/stakeholder-summary` as a
  neighbor where the routing applies.
- `docs/quickstart.md` and `docs/concepts.md` are touched to thread `/stakeholder-summary` through the operator-facing
  mental model.
- `README.md` receives a small touch tied to the new skill.
- The banner image at `images/han-banner.png` is refreshed.
- The "Current version" line is removed from `CLAUDE.md` so the project-map document does not drift against
  `plugin/.claude-plugin/plugin.json` on every bump.

### Repository cleanup

Completed planning artifacts are deleted from the repo now that the work they tracked has shipped or been superseded:

- `han-plugin-builder/skills/guidance/references/plans/agentic-plugin-support/research.md`
- `han-plugin-builder/skills/guidance/references/plans/han/planning-token-burn-reduction.md`
- `han-plugin-builder/skills/guidance/references/rfcs/rename-plugin-marketplace-dist.md`
- `docs/plans/code-review-guardrails/` (full directory)
- `docs/plans/research-skill/` (full directory)

These were internal scratch material, not operator-facing documentation, and their removal cuts roughly 4,470 lines of
stale context from the repository.

### Pull requests in this release

- Add /stakeholder-summary skill (#10) — @afrerich

Full changelog: https://github.com/testdouble/han/blob/v2.6.0/CHANGELOG.md#v260

## v2.5.0

A new `/research` skill and its `research-analyst` agent ship, taking the catalog to 19 skills and 22 agents.
`/coding-standard` now writes its output as path-scoped Claude Code rules under `.claude/rules/` rather than a
freestanding document, and the same path-scoped-rules pattern is applied repo-wide so contributor guidance under
`han-plugin-builder/skills/guidance/references/` reaches Claude Code automatically. A GitHub pull request template lands
with a review checklist that hands off to `/update-pr-description`, and the README drops its duplicated skills list in
favor of the canonical catalog under `docs/skills/`.

### New skill

`/research` answers open-ended questions (options, prior art, trade-offs, how something works) and produces a durable,
evidence-backed, adversarially-validated report that recommends an option without committing the team to any artifact.
It reaches the codebase, the open web, and any material the operator provides, and ships with
`plugin/skills/research/SKILL.md` and a fixed report structure rendered from
`plugin/skills/research/references/research-report-template.md`. The skill operates in an evidence mode that forces
every recommendation to carry traceable citations (decision D23), and the report layout is fixed rather than freeform
(decision D24). YAGNI is intentionally not applied inside `/research` or `research-analyst`: research surfaces options
the operator may or may not pursue, so the deferral rule that gates planning and review skills would cut signal rather
than noise. `/research` is the question-shaped sibling of `/investigate`: `/investigate` diagnoses a known failure,
`/research` surveys an open question. Neighbor routing is wired bidirectionally across `/architectural-analysis`,
`/gap-analysis`, `/investigate`, and `/plan-a-feature`, and the long-form catalog at `docs/skills/research.md` documents
when to reach for it. (PR #8)

### New agent

`research-analyst` is the specialist `/research` dispatches for codebase, web, and operator-supplied evidence gathering.
It ships at `plugin/agents/research-analyst.md` with a long-form doc at `docs/agents/research-analyst.md`, and is
cross-referenced from every neighboring agent's "Related Documentation" section. (PR #8)

### Coding standards as path-scoped rules

`/coding-standard` now writes its output as a path-scoped Claude Code rule under `.claude/rules/` and symlinks the
canonical document from `docs/` rather than producing a standalone markdown file.
`plugin/skills/coding-standard/SKILL.md` and `plugin/skills/coding-standard/references/template.md` are updated to the
new output contract, and `docs/skills/coding-standard.md` documents the canonical-doc + rules-symlink layout in plain
language so operators can read the rule in either location. A step-count error in the operator doc is fixed in the same
pass. (PR #9)

### Contributor guidance as Claude Code rules

A new `.claude/rules/` directory contains roughly 28 symlinks mirroring
`han-plugin-builder/skills/guidance/references/skill-building-guidance/*.md`,
`han-plugin-builder/skills/guidance/references/agent-building-guidelines/*.md`, and
`han-plugin-builder/skills/guidance/references/plugin-entity-taxonomy.md`. Path-scoped rules let Claude Code load the
relevant guidance automatically when an operator edits a skill or agent under `plugin/`, so contributor conventions
reach the model without the operator pasting them into context.

### Pull request template

`.github/pull_request_template.md` adds a review checklist for new pull requests against the Han repo and hands off to
`/update-pr-description` for generating the body. The template is internal to this repository and does not change plugin
behavior.

### Documentation

- `README.md`: the duplicated skills list is removed; the canonical catalog at `docs/skills/README.md` is now the single
  source.
- `CLAUDE.md`: project map updated for the 19-skill, 22-agent counts and the new `/research` entry.
- `docs/concepts.md`, `docs/quickstart.md`, `docs/sizing.md`: cross-reference updates for `/research`.
- All 22 long-form agent docs under `docs/agents/` and 18 long-form skill docs under `docs/skills/` gain
  neighbor-routing entries pointing at `/research` and `research-analyst` where the relationship is real.
- `plugin/agents/adversarial-validator.md` is updated alongside the cross-skill cross-referencing pass.

### Pull requests in this release

- Add a /research skill (#8) — @mxriverlynn
- Coding standards skill update: symlink as rules (#9) — @mxriverlynn

Full changelog: https://github.com/testdouble/han/blob/v2.5.0/CHANGELOG.md#v250

## v2.4.0

Three new plugin skills ship, taking the catalog from 15 to 18: `/issue-triage` for turning a vague report into a
structured triage document, `/tdd` for a BDD-framed red-green-refactor loop, and `/plan-work-items` for breaking a
trusted implementation plan into grabbable work items. `/architectural-analysis` is rebuilt as the sixth sizing-aware
swarming skill, and three synthesis agents move to the opus tier so their shipped frontmatter matches the documented
design intent.

### New skills

- `/issue-triage` classifies a vague issue or bug report into a structured document covering issue type, missing
  information, severity, reproducibility, and the recommended next han skill. Single pass, no sub-agents. (PR #5)
- `/tdd` drives a feature or behavior through a BDD-framed red-green-refactor loop with an enforced observed-failure
  gate. It is the plugin's only execution skill: it writes code, applies coding standards and ADRs during green and
  refactor, enforces YAGNI during refactor, and ships a `plugin/skills/tdd/scripts/detect-tdd-context.sh` discovery
  script. It runs autonomously after the initial request. (PR #7)
- `/plan-work-items` breaks a trusted implementation plan into independently-grabbable, atomic work items in a single
  `work-items.md` file, dispatching `project-manager` once and running autonomously without confirmation gates. (PR #2)
  The skill was developed under the working name `implementation-plan-to-issues` and renamed to `plan-work-items` before
  it ever shipped, so there is no breaking rename for v2.3.0 users.

### Architectural analysis rebuild

`/architectural-analysis` is rebuilt as a signal-selected, sizing-aware agent swarm. A synthesis spine
(`structural-analyst`, `behavioral-analyst`, `risk-analyst`, `software-architect`) always runs; signal-selected
specialists (`concurrency-analyst`, `adversarial-security-analyst`, `data-engineer`, `devops-engineer`,
`codebase-explorer`, `system-architect`) are added by signal and size band; and the report is rendered from an extracted
`plugin/skills/architectural-analysis/references/architectural-analysis-report-template.md`. This makes it the sixth
sizing-aware swarming skill alongside `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, and
`/plan-implementation`, and the shared sizing docs are updated to register it. (PR #6)

### Agent model tiers

`junior-developer`, `information-architect`, and `user-experience-designer` move from `model: sonnet` to `model: opus`
in their agent frontmatter. All three perform synthesis over unbounded input, and
`han-plugin-builder/skills/guidance/references/specialization-and-model-selection.md` already listed them under "Keep
opus" with an opus rationale in their long-form docs, but their frontmatter had shipped as `sonnet` since the initial
repo extraction. This aligns the implementation with the documented design intent. It is a real behavior and cost change
whenever any of these three agents is dispatched.

### Documentation

- [`docs/skills/issue-triage.md`](./docs/skills/han-core/issue-triage.md): output-contract block now mirrors
  `plugin/skills/issue-triage/references/template.md` (an H1 summary title with H2 section headers), and the
  cost-and-latency note now reflects that the skill reads both `CLAUDE.md` and `project-discovery.md` to sharpen
  Suspected Areas.
- [`docs/skills/plan-work-items.md`](./docs/skills/han-core/plan-work-items.md): adds the missing
  `reference-artifact-inventory.md` link.
- `README.md`: the "Maintenance" heading typo is fixed.
- `plugin/.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`: descriptions synced; they now mention
  planning and issue triage.
- `CLAUDE.md`: the "Current version" line is corrected.

### Repository tooling

- A repo-maintenance skill `/han-release` is added at `.claude/skills/han-release/` for cutting Han releases. It is
  internal to this repository and is not one of the 18 shipped plugin skills.

### Pull requests in this release

- Add /issue-triage skill (#5) — @spken
- Rebuild architectural-analysis skill: sizing-aware agent swarm (#6) — @mxriverlynn
- Add a /tdd skill (#7) — @mxriverlynn
- Add the plan-work-items skill (#2) — @kadams54

Full changelog: https://github.com/testdouble/han/blob/v2.4.0/CHANGELOG.md#v240

## v2.3.0

The `/code-review` skill is recalibrated so its first pass produces the output the user has been getting only by running
a manual second-pass reclassification: severity inflation is removed at the structural level, user-provided focus areas
and branch-level context reach every dispatched sub-agent, and contradictory same-file findings are detected internally
rather than landing for the human to adjudicate without a flag.

### Calibration

- The agent-finding classification rubric in `plugin/skills/code-review/references/agent-finding-classification.md` no
  longer carries a "Most findings land here" WARN floor across seven of the nine agent rubrics. The rubric defines each
  severity; size-based demotion is governed by `SKILL.md` Step 3.3, the new authoritative home.
- `SKILL.md` Step 3.3 is now the single source of truth for size-based demotion. The Review Constraints rule for manual
  findings (line 24), the Step 7.2 demotion gate for agent findings, the size-aware rubric, and the YAGNI two-pass
  procedure all reference Step 3.3 by name rather than restating its content.
- `SKILL.md` Step 7 is restructured into three numbered sub-steps. 7.1 reads agent output; 7.2 applies the merged
  reachability phrase-match demotion gate (CRIT → WARN → SUGG → omitted) when a finding's rationale contains
  `theoretical`, `hypothetical`, `defense-in-depth`, `effectively impossible`, `in case the upstream`, `could happen`,
  `should never happen`, or `edge case that does not occur`; 7.3 classifies the surviving findings using the size-aware
  rubric. Security findings are exempt from the gate because the security agent's evidence standard already requires a
  demonstrated exploit path.

### Context plumbing

- New `Step 1.5: Load Branch Context` runs after Step 1 (Mode A and Mode B only). It attempts the PR description via
  `gh pr view`, local `pr-body` files, branch commit messages, and an implementation plan from the planning directory
  (resolved via the `plans:` key in CLAUDE.md or by Glob fallback). The loaded summary binds to `$branch_context`. When
  nothing loads, the skill warns once and binds `$branch_context` to `none provided`.
- `$focus_areas` and `$branch_context` are explicit named bindings. Step 1 binds the user's free-form argument to
  `$focus_areas` (defaulting to `none provided` when empty); Step 1.5 binds the loader output to `$branch_context`.
  Every Step 3.5 agent prompt includes both bindings verbatim so the agents can deprioritize work the team has already
  deferred or resolved.
- `Bash(gh *)` is added to the skill's `allowed-tools` frontmatter so Step 1.5 can call `gh pr view`.

### Per-agent dispatcher tailoring at Step 3.5

- `structural-analyst` and `behavioral-analyst` receive a default-SUGG dispatcher directive: every finding starts at
  SUGG; escalation to WARN or CRIT requires the change to actively introduce or worsen the issue. The agents' general
  behavior outside `/code-review` is unchanged.
- `junior-developer` receives a file-list scoping directive: outward reads are for context only; findings must concern
  code on the scoped file list. The agents' general behavior outside `/code-review` is unchanged.
- `edge-case-explorer` receives a narrower file-list directive that preserves Protocol 1's caller-read pattern: callers
  can be read as evidence, but the failure-mode target of every finding stays on the file list.

### YAGNI two-pass procedure

- `references/review-checklist.md`, the Step 3.3 calibration directive's YAGNI block, and the Review Constraints YAGNI
  rule are all rewritten to run YAGNI in two passes: Pass 1 evidence test against `yagni-rule.md` Gate 1, then Pass 2
  named anti-pattern match. Each YAGNI finding's body names the failing evidence type, the matched anti-pattern, and the
  simpler form considered. The YAGNI section's verbatim opening statement is preserved.
- In Mode B (uncommitted changes) and Mode C (no git), the YAGNI checklist is skipped unless the user explicitly
  requests it via `$focus_areas`, since the diff signal that separates introduced code from pre-existing code is absent.

### Self-consistency check

- New `Step 9.0: Self-consistency check` runs before structural verification. An extraction pass collects
  `{task-id, file-path, line-range, recommended-action-summary}` tuples for every finding, then a comparison pass flags
  overlapping-line-range pairs whose recommendations prescribe opposite actions on the same code. Both findings are
  demoted by one severity and each receives a `Tension with {other-task-id}:` note for the human reviewer. Cross-file
  semantic contradictions are out of scope.

### Premise verification before standards-compliance findings

- Step 5 now requires reading at least one architectural file in the codebase that demonstrates a standard's premise
  before raising a "violates standard X" finding. When the file does not confirm the premise (e.g., the standard assumes
  SPA-style company switching but the codebase uses full-page redirects), the finding is omitted with a logged note. The
  "infer the premise from the standard's own examples" path is now a reason to omit, not a forward path to raise.

### Documentation

- [`docs/skills/code-review.md`](./docs/skills/han-core/code-review.md) is updated to mirror the new step structure
  (Step 1.5, the Step 7 sub-steps, Step 9.0), the per-agent dispatcher tailoring, the size-based demotion model, the
  YAGNI two-pass procedure, the full agent task ID format set, and the new YAGNI section in the output description.
- The four affected agent docs ([`docs/agents/structural-analyst.md`](./docs/agents/han-core/structural-analyst.md),
  [`docs/agents/behavioral-analyst.md`](./docs/agents/han-core/behavioral-analyst.md),
  [`docs/agents/junior-developer.md`](./docs/agents/han-core/junior-developer.md),
  [`docs/agents/edge-case-explorer.md`](./docs/agents/han-core/edge-case-explorer.md)) each carry a one-paragraph note
  explaining the `/code-review` Step 3.5 dispatcher tailoring and confirming the agents' default behavior in other
  skills is unchanged.
- [`docs/yagni.md`](./docs/yagni.md) `/code-review` table row is updated to reflect the two-pass procedure and the Mode
  B / Mode C YAGNI skip.
- [`docs/skills/gh-pr-review.md`](./docs/skills/gh-pr-review.md) gains a Key Concept noting that the wrapped
  `/code-review` Step 1.5 plumbs the PR description into every agent's `$branch_context`.

### Deferred (YAGNI)

- A dedicated S12 mode flag for default-SUGG suppression is deferred. The size-aware rubric (Pair A) plus the merged
  Step 7.2 demotion gate (Pair B) plus the rewritten Review Constraints rule subsume the workaround the user has been
  running manually.
- A structured "directly introduced" field in agent output formats is deferred in favor of phrase-matching at Step 7.2.
- Cross-file semantic contradiction detection in Step 9.0 is deferred; only single-file overlapping-line-range
  contradictions are checked.
- An automated test harness, per-agent unit tests, and Mode C standalone tests are deferred.
- Edits to the four affected agent definition files are deferred; `/code-review`'s tailoring lives in Step 3.5
  dispatcher directives so the agents remain general-purpose for other callers.

## v2.2.0

The `/gap-analysis` swarm flips from opt-in to opt-out, `junior-developer` is promoted to a required swarm role at every
size to run an explicit actor-perspective sweep, and `project-manager` joins the swarm at medium and large to
consolidate Section 4 of the report.

### Default-on swarm

The validator-and-augmenter swarm now runs by default at every size. Reply `no swarm` to opt out and fall back to the
lightweight gap-analyzer-only pass; reply `lightweight` to drop to the minimum two required roles without domain
specialists.

- **Small** _(default)_: 2–3 agents — `adversarial-validator` and `junior-developer` always, plus
  `evidence-based-investigator` when the current state is concrete. No PM at small.
- **Medium**: 4–6 agents — the required three plus 1–2 domain specialists plus `project-manager` for Section 4
  synthesis.
- **Large**: 6–8 agents — the required three plus 2–4 domain specialists plus `project-manager`.

### Actor-perspective sweep

`junior-developer` is now a required swarm member at every size. Its job in `/gap-analysis` is to enumerate every actor
the desired state addresses or implies (human end users and sub-roles, API callers, AI agents, integration partners,
batch processes, internal services), check whether each gap holds for every actor type, and surface gaps the analyzer
missed because it only considered one actor.

### Conditional second round

When the first-round swarm surfaces ≥ 3 `proposed_new_gap` entries (Trigger A) or contradictions on ≥ 20% of the
analyzer's original gaps (Trigger B), the skill runs one additional `gap-analyzer` pass with the new actor context and
merges the delta into the source file. Bounded to one extra round.

### Section 4 default-on; augmentations inline into Section 2

Section 4 (Swarm Findings) is now rendered by default and is omitted only when the user passed `no swarm`. Swarm
augmentations (added risks, secondary effects, refined framing, actor-perspective notes from `junior-developer`) inline
into Section 2 entries as `Additional context (swarm):` lines so they land where the gap lives, while Section 4 retains
the audit-trail listing.

### Documentation

- [`docs/skills/gap-analysis.md`](./docs/skills/han-core/gap-analysis.md) — updated TL;DR, key concepts, sizing table,
  cost-and-latency model, "In more detail" section, and Sources / Related Documentation to reflect the opt-out posture.
- Cross-references updated in [`docs/concepts.md`](./docs/concepts.md), [`docs/quickstart.md`](./docs/quickstart.md),
  [`docs/sizing.md`](./docs/sizing.md), [`docs/skills/README.md`](./docs/skills/README.md), and the agent docs for
  `adversarial-validator`, `evidence-based-investigator`, `junior-developer`, `project-manager`, and `gap-analyzer`.

## v2.0.1

The "this codebase is a startup" framing is removed from the YAGNI rule and every skill and agent that inherits it. The
evidence-based YAGNI mechanic is unchanged — only the rationale prose is reframed so the rule reads as project-agnostic
guidance rather than advice contingent on company stage.

Affected files: `docs/yagni.md`, `references/yagni-rule.md`, the `project-manager` and `junior-developer` agents, and
the `iterative-plan-review`, `plan-a-feature`, `plan-a-phased-build`, `plan-implementation`, and `test-planning` skills.
Every removal preserves the surrounding "every X is ongoing maintenance and a pattern future agents will copy" sentence
that does the actual work.

## v2.0.0

Two skills are renamed and a YAGNI (You Aren't Gonna Need It) discipline is woven through the planning, review, and
architecture skills and agents.

### Breaking changes

Two skills have been renamed. Update any scripts, slash-command invocations, agent prompts, or documentation that
referenced the old names.

| Old name                | New name                            |
| ----------------------- | ----------------------------------- |
| `han:gh-pr-description` | `han:update-pr-description`         |
| `han:create-adr`        | `han:architectural-decision-record` |

The skill behavior is unchanged — only the names and their on-disk directories. Old names will not resolve; the slash
commands are now `/update-pr-description` and `/architectural-decision-record`.

### YAGNI evidence requirements across planning, review, and architecture

Every place where the plugin proposes new code, new tests, new infrastructure, or new abstractions now requires concrete
evidence that the work is needed today — not speculation about the future. Added to:

- Planning skills: `/plan-a-feature`, `/plan-implementation`, `/plan-a-phased-build`, `/iterative-plan-review`
- Review and standards: `/code-review` (advisory-only), `/coding-standard`, `/test-planning`,
  `/architectural-decision-record` (forcing-function requirement)
- Agents: `project-manager`, `junior-developer`, `software-architect`, `system-architect`, `test-engineer`,
  `edge-case-explorer`, `data-engineer`, `devops-engineer`

Each skill or agent applies the rule to its own surface area — speculative tests, premature operational machinery,
speculative data machinery, speculative edge cases, abstractions without a forcing function, and so on. Plans now
include a **Deferred** section to capture explicitly-rejected speculative work.

## v1.7.0

Filename naming for `/coding-standard` and `/architectural-decision-record` outputs changes from a timestamp prefix to a
discovered, hierarchical prefix so related documents sort together.

### Hierarchical filenames for coding standards and ADRs

Both skills replace the `{YYYYMMDDHHmmss}-{name}.md` pattern with `{top-level}[-{second-level}]-{name}.md`.

- The hierarchy prefix is one or two levels (e.g., `svelte-stores-state-shape.md`, `auth-tokens-rotation.md`).
- The taxonomy is **discovered at runtime**, not hardcoded — both skills parse existing standards/ADRs in the project's
  directory and read CLAUDE.md / project-discovery.md to identify the project's languages, frameworks, runtimes,
  subsystems, and bounded contexts as candidate top-level prefixes.
- When existing prefixes fit, they are reused; new top-levels are introduced only when nothing existing applies.
- When the discovered taxonomy offers more than one reasonable placement, the skill asks the user before writing.
- The unused `Bash(date *)` permission has been dropped from both skills' `allowed-tools`.

### Documentation

- [`docs/skills/coding-standard.md`](./docs/skills/han-core/coding-standard.md) and
  [`docs/skills/architectural-decision-record.md`](./docs/skills/han-core/architectural-decision-record.md) updated to
  describe the hierarchical filename pattern, the discovery step, and the new shape of the produced filename.

## v1.6.1

Sizing becomes a foundational dispatch lever across the swarming skills.

### Size-aware code-review agent dispatch

`/code-review` now classifies the change as small / medium / large before dispatching agents, defaults to small, and
scales the roster proportionally.

- Two agents always run on every review: `junior-developer` and `adversarial-security-analyst`.
- The rest of the roster — `test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`,
  `concurrency-analyst`, `data-engineer`, `devops-engineer` — is dispatched conditionally based on what the changed
  files actually touch.
- Every agent brief carries a calibration directive that requires findings to be either introduced/worsened by the
  change or critical irrespective of who introduced it. Severity scales with size.
- `data-engineer` and `devops-engineer` join the conditional roster with finding-classification rubrics for data-side
  and operational concerns.

### Cross-skill `$size` argument

All five sizing-aware skills — `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`,
`/plan-implementation` — now declare a positional `size` argument in their frontmatter per the Claude Code skills spec.

- Pass `small`, `medium`, or `large` as the first positional argument to override the auto-classification:
  `/code-review medium`, `/plan-a-feature large "describe the feature"`, etc.
- When `$size` is non-empty, the skill uses that value as the size and scales its team / swarm caps and finding
  calibration accordingly.
- Without `$size`, the skill auto-classifies from concrete signals (file count, subsystems touched,
  security/data/integration surface).

### Default to small across all sizing-aware skills

Every sizing-aware skill now starts the classification at small and only escalates when concrete signals clearly require
it. Borderline signals stay at the smaller band — fewer agents producing higher-signal findings is the goal.

### New sizing reference doc

[`docs/sizing.md`](./docs/sizing.md) is the canonical cross-skill sizing reference.

- The three bands (small / medium / large) and what they mean.
- The auto-classification process and the `$size` override.
- A per-skill at-a-glance table covering all five sizing-aware skills.
- Cross-references in every sizing-aware skill's long-form doc back to the reference and vice versa.
- Discoverable from the front-door `README.md`, `docs/concepts.md`, `docs/quickstart.md`, and `docs/skills/README.md`.

### Documentation refreshes

- `docs/skills/code-review.md` — refreshed for the size-aware dispatch model (was still describing the old "six agents
  always run" shape).
- New **Sizing** section in each of `docs/skills/code-review.md`, `docs/skills/gap-analysis.md`,
  `docs/skills/iterative-plan-review.md`, `docs/skills/plan-a-feature.md`, `docs/skills/plan-implementation.md`.
- `docs/concepts.md`, `docs/quickstart.md`, `docs/skills/README.md`, and `docs/skills/gh-pr-review.md` updated to
  reflect the new code-review roster shape.

## v1.6.0

Two new skills land in the `han` plugin, both producing plain-language reports that stakeholders (not just engineers)
can read.

### `/gap-analysis` — compare two artifacts and find what's missing

Run a gap analysis between a _current state_ and a _desired state_ — for example a PRD vs. the shipped feature, a spec
vs. its implementation, or any "what's missing from X compared to Y" question.

- Delegates the heavy analysis to the `gap-analyzer` agent, then synthesizes a stakeholder-readable report indexed by
  stable `G-NNN` gap IDs.
- Default output is plain language only — no file paths, line numbers, or code references in the main sections.
  Technical detail is opt-in.
- Optionally launches a swarm of validator/augmenter agents to corroborate or enrich findings. Swarm size (small /
  medium / large) is recommended based on gap count and category mix, but it never runs without the user opting in.
- Ships with a report template (`references/gap-analysis-report-template.md`) designed by the `information-architect`
  agent.

See [`/gap-analysis` documentation](./docs/skills/han-core/gap-analysis.md).

### `/plan-a-phased-build` — turn context into a sequenced build plan

Take any source of context (a gap analysis, PRD, design doc, feature spec, conversation notes, ADR, etc.) and produce a
`build-phase-outline.md` that splits the work into vertical-slice phases.

- Every phase is **demonstrable to a real person** end-to-end — not "we shipped a service" but "you can do X and Y
  happens".
- Phases sequence for earliest demoable value. Foundational/prerequisite phases only come first when dependencies
  actually require it.
- Plain-language throughout: product-level subsystem names, user-facing vocabulary, behavioral verbs. A non-technical
  stakeholder can read it cover to cover.
- Each phase cross-references back to the source artifact for traceability.
- The `information-architect` agent reviews the rendered document for findability and progressive comprehension.

See [`/plan-a-phased-build` documentation](./docs/skills/han-core/plan-a-phased-build.md).

### Documentation

- New skill docs: [`gap-analysis.md`](./docs/skills/han-core/gap-analysis.md),
  [`plan-a-phased-build.md`](./docs/skills/han-core/plan-a-phased-build.md)
- [Skills Index](./docs/skills/README.md) and [Quickstart](./docs/quickstart.md) updated to surface both
- Minor link/version touch-ups across existing skill docs

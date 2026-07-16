# Decision Log: Han Publishing Cleanup

Spec: [../feature-specification.md](../feature-specification.md) · Findings: [team-findings.md](team-findings.md) ·
Technical notes: [feature-technical-notes.md](feature-technical-notes.md)

Trust classes used in `Evidence:` fields, per [evidence-rule.md](../../../../han-planning/references/evidence-rule.md):
**codebase** (read directly from files here), **provided** (supplied by the user, including the source artifact), **web**
(external).

## Full decisions

### D1: The check lands last, because a check that blocks everything gets disabled

**Outcome.** The automated check becomes blocking only after every problem it detects has been fixed. This governs one
adjacency — everything before the check — not the whole sequence
([D18](#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

**Rationale.** The check is correct on day one; the repository is not ready for it. Landing it first fails it on nearly
every plugin and blocks every release and pull request immediately. The realistic response is to disable it, leaving the
repository with all the original problems plus one disabled check.

Rescoped after review. The original entry generalized this argument into a total order over all seven steps, which it
does not support. It supports exactly this one constraint. See D18.

Also clarified after review: this is about when the rule becomes **blocking**, not when it comes into existence. The
rule exists from the release repair onward, because the release runs it ([D14](#d14-the-release-runs-the-check-rather-than-restating-it)).

**Evidence.** provided — the source artifact states it directly and records that an adversarial reviewer caught the
original ordering error. codebase — the check would fail today on `han-linear` (absent from
`.agents/plugins/marketplace.json`, no `.codex-plugin/`) and on all eight drifted codex version records.

**Rejected alternatives.**

- _Land the check first to prevent regressions during the work._ Rejected: it blocks the very pull requests that fix the
  problems it detects.
- _Land the check disabled, enable it at the end._ Rejected: a disabled check is indistinguishable from no check, and
  adds a step that can be forgotten. See also [D28](#d28-the-check-ships-with-no-disable-switch).

**Driven by findings:** F1, F3
**Linked technical notes:** —
**Dependent decisions:** D18, D28
**Referenced in spec:** Outcome, Primary flow (Step 7), Alternate flows and states

### D2: Step 2 closes the silent hole only; annotation namespacing is separate

**Outcome.** Step 2 guarantees that no work item leaves a run unaccounted for. It does not change the annotation format
and requires no migration. Making each tracker's annotations name their tracker is a separate specification.

**Rationale.** Two distinct defects share a neighborhood. The first is that two trackers write indistinguishable
annotations, so one skips the other's work — a trap, but a reported one: the skipped count surfaces it twice to a person
paying attention. The second is that the GitHub publisher matches neither pattern and drops the work items with no
signal at all. Only the second is silent, and only the second is step 2. The simpler version — account for every work
item — satisfies the evidence that drove the step here, without a format change or a migration for files already in
people's repositories.

**Evidence.** codebase — `han-github/skills/work-items-to-issues/scripts/create-issues.sh` creates by matching
`^## [A-Z][A-Z0-9]*-[0-9]+ — ` and counts skipped by matching `^## [A-Z][A-Z0-9]*-[0-9]+ \(#[0-9]+\) — `. A heading
annotated `## W-1 (ACME-142) — title` matches neither, so it is never created and never counted. codebase —
`han-atlassian/.../work-items-file-format.md` writes `(<PROJECT-KEY-NNN>)` and `han-linear/.../work-items-file-format.md`
writes `(<LINEAR-ID>)`; both are `[A-Z]+-[0-9]+`, hence mutually indistinguishable. provided — the user selected this
scope explicitly.

**Rejected alternatives.**

- _Namespace all three trackers' annotations in step 2._ Rejected: the simpler version satisfies the same evidence, and
  the larger version adds a format change plus a migration for files already in people's repositories.
- _Fix nothing until namespacing is designed._ Rejected: the silent loss is live and closing it does not depend on the
  format decision.

**Driven by findings:** —
**Linked technical notes:** —
**Dependent decisions:** D3, D17, D30
**Referenced in spec:** Primary flow (Step 2), Edge cases, Out of scope

### D3: A foreign annotation stops the run before anything is created

**Outcome.** When the GitHub publisher meets a work item annotated by a different tracker, it surfaces a format error
and stops. The whole file is examined before the first item is published, so "before anything is created" means nothing
in the entire run — not "nothing further from here on".

**Rationale.** Settled from evidence: the skill already has this convention for this class of problem. A foreign
annotation almost certainly means the file was published to another tracker, so publishing it again would duplicate real
tickets — the more expensive error.

Strengthened after review. The original entry said "stops before creating anything" without saying at what scope. The
create loop re-scans from the top each iteration for the first unannotated heading, so the natural incremental fix —
detect the foreign shape when the scan reaches it — would create every item *ahead* of it in file order and then halt.
Real tickets would exist, contradicting the all-or-nothing intent. Examining the whole file first is what makes the
commitment true.

**Evidence.** codebase — `han-github/skills/work-items-to-issues/SKILL.md` establishes the convention: "A cross-repo
`Depends on` is a format error to surface for repair." codebase — the Linear and Jira format references establish the
same posture: self-blocks and dependency cycles are "surfaced for repair before any issue is created, never published".
codebase — `create-issues.sh`'s loop structure (`grep -nE ... | head -n 1` re-scanning per iteration) is what makes the
scope ambiguity real rather than theoretical. provided — the source artifact notes the existing posture "errs toward
stopping and asking rather than guessing".

**Rejected alternatives.**

- _Publish the work item anyway._ Rejected: it most likely already exists elsewhere, so this creates duplicates across
  two trackers — worse than the silent drop it replaces.
- _Skip it and count it in the skipped total._ Rejected: conflates "already published here" with "already published
  somewhere else", which is the exact confusion that produced the bug.
- _Warn and continue._ Rejected: contrary to the skill's all-or-nothing convention, and a warning inside a long run is
  close to the signal-lessness being fixed.
- _Detect the foreign shape as the scan reaches it._ Rejected: simpler to implement, but it creates real tickets before
  halting, which breaks the commitment the step exists to make.

**Driven by findings:** F7
**Linked technical notes:** —
**Dependent decisions:** D17, D30
**Referenced in spec:** Primary flow (Step 2), Alternate flows and states

### D4: The check blocks on every pull request, and runs locally where hooks are installed

**Outcome.** The check blocks on every pull request. It additionally runs before a commit for contributors who have
installed the optional local hooks. The guarantee rests on the pull-request half; the local half is a convenience.

**Rationale.** Rewritten after review. The original entry claimed the check "runs both before a commit lands and on
every pull request" and that a contributor therefore learns while still working. That is false for anyone who has not
opted in, and this repository's hooks are opt-in. Claiming the local half as a delivered behavior would have made the
spec promise something it cannot.

The pull-request half is the real guarantee precisely because it does not depend on anyone's local setup. Adding the
check to the existing lint path means it rides both surfaces for free, so contributors who did install hooks get the
faster loop at no extra cost.

**Evidence.** codebase — `package.json` defines `"lint": "prek run --all-files"` and `.github/workflows/ci.yml`'s lint
job runs `npm run lint` on every pull request and every push to `main`. codebase — `CONTRIBUTING.md:59` reads "If you
want pre-commit hooks, run `npx prek install`", so hooks are opt-in and absent from a fresh clone. codebase —
`.pre-commit-config.yaml` already carries local hooks and shellcheck, so a new local hook is the established pattern.
codebase — `test/sanity.bats` and `"test": "bats --recursive test/"` give the check a testing home. provided — the user
selected this option.

**Rejected alternatives.**

- _Claim the local half as a guarantee._ Rejected on evidence: hooks are opt-in, so the claim is false for the default
  contributor.
- _Make hook installation mandatory._ Rejected: no evidence anyone wants it, and it changes the contributor setup
  contract to buy a faster loop the pipeline already provides more reliably.
- _Pipeline only, with no local hook._ Rejected: the local run is free once the check is in the lint path, and it does
  help the contributors who opted in.
- _Inside the release process only._ Rejected: drift could still land on the default branch between releases.

**Driven by findings:** F11
**Linked technical notes:** —
**Dependent decisions:** D14, D24
**Referenced in spec:** Primary flow (Step 7), Coordinations

### D5: The check derives the plugin list from the repository

**Outcome.** Both the check and the release derive the set of plugins from what is actually in the repository, not from
a storefront listing.

**Rationale.** This is the root cause, not a symptom. The release currently takes its plugin list from one of the targets
it also writes, which makes the list self-confirming: a plugin missing from that listing is invisible to the process
meant to notice it is missing. No amount of care during a release surfaces a problem the release cannot see. A plugin
added today is invisible on channel two by default, which is why this is a standing defect rather than a one-time slip.

**Evidence.** codebase — `.claude/skills/han-release/SKILL.md` sources its plugin list from
`jq -r '.plugins[] | ...' .claude-plugin/marketplace.json` and instructs "Enumerate the plugins from `plugins` in Project
Context". Its Step 4 writes only `{source}/.claude-plugin/plugin.json` and that same `marketplace.json`; it contains zero
references to `.codex-plugin/` or `.agents/plugins/marketplace.json`. codebase — `han-linear` is absent from
`.agents/plugins/marketplace.json` and has no `.codex-plugin/`, and no release has ever reported it. provided — the
source artifact's "Before" diagram: "DISK -.-> |never consulted directly| REL".

**Rejected alternatives.**

- _Keep reading channel one's listing and cross-check the others against it._ Rejected: it preserves the self-confirming
  list, so a plugin missing from that listing stays invisible to both the release and the check.
- _Maintain a separate hand-written list of plugins._ Rejected: a third list to keep in sync and a fifth thing that can
  go stale.

**Driven by findings:** —
**Linked technical notes:** —
**Dependent decisions:** D6, D12, D14, D19, D24
**Referenced in spec:** Outcome, Primary flow (Step 3), Coordinations

### D6: The bundle is a permanently named exception on the second channel

**Outcome.** The bundle is a named, permanent exception. Its absence from channel two is never flagged, **and the
version-agreement rule does not apply to it** — a plugin published on one channel has nothing to disagree with.

**Rationale.** The limitation is real, external, and documented with a specific upstream tracking issue. An exception the
rule does not know about would fire on every run forever, and a check that always reports one known failure trains people
to ignore it.

Extended after review. The original entry stated the exception as presence-only. The bundle is also structurally exempt
from version agreement, which was implied rather than stated.

**Evidence.** codebase — `README.md:74` states "Codex does not yet support meta-plugins like `han@han` (see
openai/codex#23531,) and it resolves no dependencies", and the Codex install instructions list every plugin individually
rather than the bundle. codebase — `.agents/plugins/marketplace.json` omits `han` and there is no `han/.codex-plugin/`,
consistent with a deliberate exclusion. codebase — `han/.claude-plugin/plugin.json` exists with no `skills/` directory at
all, which is what makes the bundle permanently zero-skill (see [D19](#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)).
provided — the source artifact: "the check needs to know about it permanently rather than flagging it forever."

**Rejected alternatives.**

- _A general exception mechanism configurable per plugin per target._ Rejected under YAGNI: one known exception does not
  justify a mechanism.
- _Publish a bundle to channel two anyway._ Rejected: the channel does not support it.
- _Let the check flag it and have people ignore that one line._ Rejected: a permanently red check is a disabled check
  with extra steps, which is the failure D1 exists to avoid.

**Driven by findings:** F5
**Linked technical notes:** —
**Dependent decisions:** D14, D19, D20
**Referenced in spec:** Channels and targets, Primary flow (Step 3), Edge cases, Deferred (YAGNI)

### D7: A document is in scope when this work falsifies it

**Outcome.** The document correction's scope is a rule, not a list: a document is in scope when this work falsifies it.
Not "mentions a plugin", not "narrates topology", not "sits nearby". The step that falsifies a document owns it, so the
rule spans step 6 and step 3 rather than sitting inside step 6
([D21](#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).

**Rationale.** The source plan said "the two documents that describe a behavior the system does not have" without naming
them. The first survey found seven locations across six documents. Review found five more, including the orientation
document new readers are told to read first — so the enumeration was wrong twice and would likely be wrong a third time.
A rule survives that; a list does not.

The step's stated purpose is "so nobody makes a change based on them and gets it wrong". That purpose is served by the
set of falsified documents, not by a count. The rule also draws the exclusion cleanly: documents already stale for
unrelated reasons stay out, because "the editor is already open" is convenience, not evidence.

**Evidence.** codebase — locations falsified by the declaration deletion, all verified verbatim. First survey:
`README.md:95`; `CLAUDE.md:19`, `:85`, `:119`; `CONTRIBUTING.md:128`; `docs/semantic-versioning.md:98`, `:100`;
`docs/choosing-a-han-plugin.md:119`; `docs/skills/README.md:167`; and
`docs/how-to/extend-han-with-plugin-dependencies.md` throughout. Found in review: `docs/concepts.md:221` ("Each of these
four depends on `han-core`") and `:229` ("Each of these three depends on `han-core` like the other layers");
`docs/skills/han-feedback/han-feedback.md:66` ("it pulls `han-core` along the way");
`docs/choosing-a-han-plugin.md:141` ("Both pull `han-core` along the same way the other layers do");
`CONTRIBUTING.md:129` (the feedback plugin "may dispatch any `han-core` agent freely"); `docs/semantic-versioning.md:153`
("Every dependency in `han`'s and `han-feedback`'s `plugin.json` is a bare string"). codebase — correctly **excluded**:
`docs/semantic-versioning.md:114` describes the parent's dependencies, which this work does not touch, so it stays true.
codebase — `docs/plans/CLAUDE.md` states plan documents "should not be updated during documentation reviews and updates",
so `docs/plans/` and `docs/research/` are correctly frozen and narrate the pre-deletion topology permanently. provided —
the source artifact, which names a count but not the documents.

**Rejected alternatives.**

- _Fix literally two documents, as written._ Rejected: leaves ten locations wrong, including a tutorial and the
  orientation doc.
- _Fix only the documents a user is likely to read._ Rejected: the contributor guide and the agent-facing project map are
  read by exactly the audience whose wrong change the step exists to prevent. (Note the first survey's instinct was right
  and its execution was not — it skipped the most-read document in the set.)
- _Enumerate the locations in the spec._ Rejected: the enumeration has been wrong twice already. It lives here, where it
  is expected to move.

**Driven by findings:** F8, F17
**Linked technical notes:** —
**Dependent decisions:** D8, D9, D21, D25, D26
**Referenced in spec:** Primary flow (Step 6), Out of scope

### D8: The tutorial's worked example repoints to surviving real edges

**Outcome.** `docs/how-to/extend-han-with-plugin-dependencies.md` keeps its worked-example structure and repoints it at
edges that remain true. The opt-in-leaf role passes from `han-feedback` to `han-linear`; the layer-on-top-of-core role
passes from `han-reporting` to `han-coding`.

**Rationale.** The tutorial does not merely mention the two edges; it teaches by walking through them. The roles those
plugins play are still filled by real plugins, so the lesson survives intact with different subjects. `han-linear` is a
structural identity for `han-feedback`'s role: it depends on `han-core`, is not in the bundle's dependencies, and is
installed on its own.

Rationale corrected after review. The original entry justified keeping real plugin names by citing the tutorial's claim
to print real on-disk versions. That claim is itself false, so it could not support anything. The real justification is
narrower and still sufficient: the tutorial teaches a topology, the topology still exists, and a reader can still go read
the real manifests being described. What the tutorial should stop claiming is handled separately in
[D27](#d27-the-tutorial-teaches-shape-and-stops-promising-real-version-numbers).

**Evidence.** codebase — `han-linear/.claude-plugin/plugin.json` declares `"dependencies": ["han-core"]` and is absent
from `han/.claude-plugin/plugin.json`'s dependencies, matching the tutorial's ":169" role ("a leaf that nothing else
points to: it depends on core, but the meta-plugin does not bundle it"). codebase —
`han-coding/.claude-plugin/plugin.json` declares `["han-communication", "han-core"]`, matching the ":108"
"second layer on top of core" role. codebase — the tutorial never mentions Codex; it teaches `.claude-plugin/plugin.json`
and `/plugin install …@han` throughout, so `han-linear`'s channel-two absence does not undercut it as an exemplar — and
step 1 publishes it there before step 6 runs anyway. provided — the user selected this option.

**Rejected alternatives.**

- _Rewrite around invented plugin names._ Rejected: more durable against future topology changes, but it removes the
  reader's ability to go read the real manifests, which is the tutorial's whole method.
- _Leave it and add a correction note._ Rejected: a tutorial with a note saying its example is wrong is a tutorial nobody
  should follow.
- _Delete the tutorial._ Rejected: no evidence it is unwanted; the topology it teaches still exists.

**Driven by findings:** F9
**Linked technical notes:** —
**Dependent decisions:** D27
**Referenced in spec:** Primary flow (Step 6)

### D9: The already-false contributor claim is in scope

**Outcome.** `CONTRIBUTING.md:128` ("Every plugin depends on `han-core`") and the sentence it governs at `:129` are
corrected as part of step 6, though both were already false before the declaration deletion.

**Rationale.** Re-grounded after review. The original rationale was "correcting it while already editing the same file
set is cheaper than a separate pass" — a convenience argument that generalizes straight into "and while we're here, fix
everything nearby", which is the symmetry reasoning D7's rule exists to reject.

The actual evidence is simpler and sufficient: the claim is false, and contributors read it before changing a plugin.
`:129` is the more dangerous of the two and was missed by the first survey: it is the operative sentence a contributor
acts on, and it tells them the feedback plugin "may dispatch any `han-core` agent freely" — which it structurally cannot.

**Evidence.** codebase — `CONTRIBUTING.md:128` reads "**Every plugin depends on `han-core`,**" and `:129` continues "so a
skill in `han-planning`, `han-coding`, `han-github`, `han-reporting`, or `han-feedback` may dispatch any `han-core` agent
freely". codebase — `han-communication/.claude-plugin/plugin.json` and `han-plugin-builder/.claude-plugin/plugin.json`
declare no `dependencies` key at all, so `:128` is already false for two plugins. codebase —
`han-feedback/skills/han-feedback/SKILL.md:9` has no `Agent` tool, so `:129` is already false for the feedback plugin.
provided — the user selected this option.

**Rejected alternatives.**

- _Out of scope; file a separate issue._ Rejected: the step's purpose is "so nobody makes a change based on them and gets
  it wrong", and this is the document that tells people how to make changes.

**Driven by findings:** F8, F10
**Linked technical notes:** —
**Dependent decisions:** D26
**Referenced in spec:** Primary flow (Step 6)

### D10: The two channels publish one version per plugin

**Outcome.** Each plugin has one version. Channel two's published version for a plugin is set to match channel one's for
that same plugin, and the check enforces agreement from then on.

**Rationale.** Two independent version lines for one plugin means two things to keep in sync and two ways to answer "what
version am I running?". The plugin is the same on both channels; the version describes the plugin, not the channel.

**Evidence.** provided — the source artifact's "After" diagram labels channel two's version record "Version numbers,
copied from channel one". codebase — every codex version currently disagrees with its claude counterpart, and in the same
direction (all lower): `han-core` 1.2.0 vs 2.2.1, `han-coding` 1.0.0 vs 2.6.0, `han-github` 1.2.0 vs 2.2.2,
`han-reporting` 1.0.1 vs 2.1.1, `han-planning` 1.0.0 vs 2.0.4, `han-atlassian` 1.1.0 vs 2.2.0, `han-feedback` 1.1.1 vs
2.0.0, `han-plugin-builder` 1.1.0 vs 2.0.5. Only `han-communication` agrees (1.0.0), and only because it is new enough
never to have drifted — which corroborates that the drift is neglect rather than an intentional separate line.

**Rejected alternatives.**

- _Keep independent version lines and let the release bump each._ Rejected: no evidence anyone wants two lines, and
  `han-communication` agreeing at 1.0.0 shows the lines only ever diverge through neglect.
- _Reset both channels to a common lower version._ Rejected: channel one is healthy and already published; moving it
  backward breaks the healthy channel to tidy the broken one.

**Driven by findings:** —
**Linked technical notes:** T1
**Dependent decisions:** D20, D22
**Referenced in spec:** Primary flow (Step 4)

### D11: Step 1 goes first because it is a live broken promise

**Outcome.** Publishing the Linear plugin to channel two is the first step. Unaffected by the reorder at D18.

**Rationale.** It is the only step where a person following the project's own written instructions hits an error right
now. Every other step is a latent defect: a trap not yet sprung, a silence not yet noticed, a document not yet acted on.
This one fails on contact, in the first thing a new Linear user tries.

**Evidence.** codebase — `README.md:87` tells channel-two users "Install `han-feedback`, `han-atlassian`, `han-linear`,
or `han-plugin-builder` separately", but `han-linear` has no `.codex-plugin/` and does not appear in
`.agents/plugins/marketplace.json`, so the documented command errors. codebase — the eight other plugins each have a
`.codex-plugin/plugin.json`, so `han-linear` is the only advertised-but-unpublished one. provided — the source artifact:
"It was added two days before the pass that would have published it, and that pass simply missed it."

**Rejected alternatives.**

- _Fix the release process first, then let it publish the Linear plugin._ Rejected: it makes the live user-facing error
  wait on the largest step in the plan. Step 1 is a version record plus a listing entry.

**Driven by findings:** —
**Linked technical notes:** —
**Dependent decisions:** D18, D22
**Referenced in spec:** Primary flow (Step 1)

### D12: A missing plugin stops the release, and every gap is named

**Outcome.** When the release's gate finds a plugin missing from a target it belongs in, or version records that
disagree, it stops and names every gap it found rather than the first.

**Rationale.** The failure being fixed is that the process shipped around a gap for roughly twenty releases. A warning is
what shipping around a gap looks like when someone has been told about it.

Evidence corrected after review. The original entry justified "name every gap" by citing today's state — one missing
plugin plus eight version mismatches. But steps 1 and 4 eliminate that state before the behavior exists, so the evidence
retired itself. The surviving evidence is the routine case: one omitted new plugin produces three simultaneous gaps (its
absence from two listings and one version record), which is exactly the "a new plugin is added" flow.

**Evidence.** provided — the source artifact: "If something is missing, it stops and says so instead of shipping around
the gap." codebase — `.claude/skills/han-release/SKILL.md` already hard-stops rather than warns for unsafe
preconditions: "Releasing an unknown working state is unsafe and a pushed tag is hard to reverse. This is a hard stop,
not a pause gate." codebase — a plugin omitted from both storefront listings and its channel-two version record produces
three gaps at once, so the multi-gap case is the routine one, not a relic of today's state.

**Rejected alternatives.**

- _Warn and continue._ Rejected: reproduces the current failure with a log line. The evidence that warnings do not work
  here is the twenty releases that went by.
- _Stop on the first gap._ Rejected: makes the maintainer rediscover the set one release attempt at a time, when the
  process already knows all of them.

**Driven by findings:** F2, F15
**Linked technical notes:** —
**Dependent decisions:** D24
**Referenced in spec:** Primary flow (Step 3), Alternate flows and states, User interactions

### D13: Both untrue declarations are deleted rather than made true

**Outcome.** The reporting plugin's and the feedback plugin's declarations on the core plugin are deleted. Neither is
made true by introducing a use.

**Rationale.** Neither plugin uses the core plugin, and neither wants to. The reporting plugin's use genuinely moved to
the communication plugin and the declaration is a leftover. The feedback plugin cannot invoke another plugin even in
principle, so no edit short of changing what it is permitted to do could make its declaration true. Deleting is the change
that makes the declaration match reality; anything else changes reality to match a leftover.

**Evidence.** codebase — `grep -rn "han-core" han-reporting/` outside its manifest returns nothing; its skills reference
only `han-communication:readability-guidance` and `han-communication:readability-editor`. codebase —
`han-feedback/skills/han-feedback/SKILL.md:9` declares
`allowed-tools: Read, Write, Bash(ls *), Bash(mkdir *), Bash(gh *), Bash(date *)` — no `Agent` and no `Skill`, so it
structurally cannot invoke `han-core`. Its every "han-core" mention is a string literal it writes into a report. provided
— the source artifact: "it is not permitted to call other plugins at all, so its claim cannot possibly be true."

**Rejected alternatives.**

- _Leave them; the cost is only a needless install._ Rejected: the cost is trust. Once two declarations are decorative,
  none of them answers "what actually breaks if I change this?"
- _Give the feedback plugin the ability to invoke the core plugin so its declaration becomes true._ Rejected: inventing a
  use to justify a leftover.

**Driven by findings:** —
**Linked technical notes:** —
**Dependent decisions:** D7, D18
**Referenced in spec:** Primary flow (Step 5)

### D14: The release runs the check rather than restating it

**Outcome.** The release holds no copy of the rule. It runs the check and reports what the check says. The bundle
exception is stated once, where the rule lives.

**Rationale.** Rewritten after review. The original entry said the two "must answer it identically" — a wish with no
bearer. Nothing enforced it and nothing would detect when it stopped being true.

This matters more than ordinary duplication, because the root cause at D5 *is* an unverified prose instruction that told
an agent to read the wrong file for twenty releases. Rewriting that prose to read four files instead of two leaves the
same defect class in place, now with more files to forget, and puts the bundle exception in two places — a second copy of
a rule whose entire purpose is to not be ignorable.

This also settles when the rule exists: from the release repair onward, because the release runs it. The last step makes
it blocking, not existent (see D1).

**Evidence.** provided — the source artifact's "After" diagram routes the release through the same gate ("Does every
plugin appear everywhere it should?") that the check enforces. codebase — `.claude/skills/han-release/SKILL.md` is prose
instructions to an agent while the check is executable, so a shared bearer is a real design constraint rather than a
refactoring preference. codebase — the same skill's Step 4.2 ("Sync that plugin's `marketplace.json` entry… Select by
name, not by index") is an existing hand-sync of exactly the class that drifted, which is what a prose restatement would
reproduce.

**Rejected alternatives.**

- _Implement the rule separately in each and keep them in sync by care._ Rejected: two rules to keep in sync is the same
  defect class as the two version lines at D10 and the duplicated rule files noted as out of scope. Care is what failed
  for twenty releases.
- _Assert "they must answer identically" and leave the bearer unspecified._ Rejected: that was the original entry, and it
  committed to nothing.

**Driven by findings:** F3
**Linked technical notes:** —
**Dependent decisions:** D1, D24
**Referenced in spec:** Primary flow (Steps 3 and 7), Coordinations

### D17: The foreign-annotation category exists at every layer that inspects a heading

**Outcome.** Step 2 changes both the publisher's script and the publisher's prose repair pass. A foreign annotation is a
distinct category at each, and the repair pass must not silently repair it.

**Rationale.** Promoted from trivial to full after review, because the original entry was wrong in a way that would have
shipped a fix that does not fix the documented workflow.

The original said step 2 "changes nothing about what any publisher writes… which keeps the blast radius inside the GitHub
publisher". True but insufficient. The real user path runs the skill's prose-driven repair pass *before* the script ever
executes. That pass recognizes exactly two valid heading shapes and would bucket a foreign annotation as a generic
"Malformed heading", then route it to "propose the corrected shape based on the surrounding text" — potentially stripping
or reformatting the annotation and applying the fill before the gate sees it. The gate would then protect only a direct
script invocation, not the way anyone actually runs it.

**Evidence.** codebase — `han-github/skills/work-items-to-issues/SKILL.md:65-115` runs an evidence-based repair pass at
Step 3, before the publish pipeline at Step 6. codebase — the same file's `:71-72` names only two valid shapes (bare and
GitHub-annotated), so a Jira- or Linear-annotated heading matches neither. codebase — the same file's `:89` lists
"Malformed heading — propose the corrected shape based on the surrounding text" as the handling for anything unmatched.

**Rejected alternatives.**

- _Change only the script._ Rejected: protects standalone invocation and leaves the documented workflow unprotected,
  which is the majority path.
- _Change only the repair pass._ Rejected: leaves the script silently lossy when invoked directly, which its own usage
  header invites.

**Driven by findings:** F7
**Linked technical notes:** —
**Dependent decisions:** D30
**Referenced in spec:** Primary flow (Step 2)

### D18: The execution order is a partial order, and the repair precedes the correction

**Outcome.** The steps execute as 1, 2, 6, 3, 4, 5, 7 in the source plan's numbering — that is: publish the Linear
plugin, close the work-items hole, repair the release, correct the versions, delete the declarations, correct the
documents, turn on the check. The binding constraints are named; the rest are free.

**Rationale.** Two problems with the original total order.

First, it was not a total order. The source plan's ordering argument is entirely about the check (D1), which forces one
adjacency. Presenting six others as equally load-bearing made the one that genuinely bites invisible — rigidity
everywhere is rigidity nowhere.

Second, and materially: correcting the versions before repairing the release opens a window in which any release
re-freezes the correction. The plan's own work triggers it, because deleting the declarations edits two plugin
directories, which forces both plugins to bump at the next release. The check would then land red — the exact outcome D1
exists to prevent. Moving the repair ahead of the correction closes the window structurally rather than by asking a
maintainer to promise not to release.

The real constraints: the check is last; the release repair precedes the version correction; the declaration deletion and
the document correction ship as one unit (the intermediate state is what the document correction exists to prevent); the
work-items fix is independent of everything.

**Evidence.** codebase — `.claude/skills/han-release/SKILL.md` contains zero references to `.codex-plugin` or
`.agents/plugins`, so it provably writes only channel one until repaired. codebase — `docs/semantic-versioning.md`'s "A
child bumps only when its own directory changed in `{range}`" means editing `han-reporting/` and `han-feedback/` forces
both to bump at the next release. provided — the user chose the reorder over the alternative after both were surfaced
with their trade-offs, consciously overriding the source plan's listing order.

**Rejected alternatives.**

- _Keep the source's listing order and add a precondition that no release is cut in the window._ Rejected by the user
  after being recommended: it preserves the source order and closes the window with one sentence, but it relies on a
  maintainer honoring a promise with nothing enforcing it. The reorder makes the window impossible instead of forbidden.
- _Keep the order and fold the version correction into the release repair._ Rejected: blurs what each step owns for no
  gain over the reorder.
- _Present all seven as a chain, as the source plan does._ Rejected: five of the six adjacencies have no dependency
  behind them, and asserting them hid the one that did.

**Driven by findings:** F1
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** header, Primary flow (intro, Steps 3 and 4, and the source-position annotations throughout),
Coordinations

### D19: A plugin, and the targets it belongs in, are defined positively

**Outcome.** A plugin is a directory the suite ships as an installable unit. Every plugin belongs in all four targets,
except the bundle, which belongs only in channel one's two. Detection is the implementation plan's business.

**Rationale.** The rule was previously defined only by subtraction from its exception, and "plugin" was not defined at
all. Two edge-case rows depended on the missing definition, and D14 asks two consumers to answer one question
identically — an ambiguous question cannot have one answer.

The definition has to avoid one specific trap: "has skills" cannot be part of it, because the bundle has a manifest and
no skills at all, permanently and legitimately. And if the rule were "has a channel-one manifest", a plugin published
only to channel two would be invisible — today's bug mirrored onto the other channel.

**Evidence.** codebase — `han/.claude-plugin/plugin.json` exists with no `skills/` directory, and `CLAUDE.md` describes
the bundle as having "no components of its own", so zero-skill is a permanent legitimate state. codebase — no stray
`plugin.json` exists outside the ten real plugin directories today (`han-plugin-builder`'s templates are named
`plugin-example.json`, avoiding collision), so no false positive exists to design around. codebase — every current
listing entry resolves to a real directory.

**Rejected alternatives.**

- _Define a plugin as a directory with a channel-one manifest._ Rejected: makes a channel-two-only plugin invisible,
  which is the current bug mirrored.
- _Define a plugin as a directory with skills._ Rejected: the bundle has none and is permanent.
- _Leave "belongs in" defined by its exception._ Rejected: stating a rule only by its exception leaves the next exception
  nowhere to attach.

**Driven by findings:** F5, F26
**Linked technical notes:** —
**Dependent decisions:** D20, D29
**Referenced in spec:** Channels and targets, Edge cases

### D20: Version agreement covers every record that publishes a version

**Outcome.** The version-agreement rule covers every record that publishes a version — there are three, not two. Listing
membership covers both storefronts. Channel two's storefront listing carries no version, so the rule does not reach it.

**Rationale.** Correcting a factual error. The spec said the release updates "two version records and two storefront
listings", which is wrong: channel one's storefront listing also carries a version per plugin, so one target is both a
listing and a version record. The four targets do not partition into two and two.

This matters beyond tidiness. Channel one's listing-versus-manifest version pair is hand-synced by the release today and
nothing verifies it — a hand-sync of exactly the class that drifted on channel two. Stating "two version records" would
have left it outside the check.

Worth naming the mechanism: the spec's channel-neutral vocabulary is correct and should stay, but the euphemism is what
let a miscount survive drafting. The remedy is a more accurate abstraction, not file paths in the spec.

**Evidence.** codebase — `.claude-plugin/marketplace.json` carries a `version` field per plugin for all eleven entries
and is also the channel-one storefront listing. codebase — `.agents/plugins/marketplace.json` carries no `version` field
for any of its nine entries. codebase — `.claude/skills/han-release/SKILL.md` Step 4.2 hand-syncs the channel-one
manifest version to the channel-one listing entry, unverified.

**Rejected alternatives.**

- _Keep "two version records and two listings."_ Rejected: factually false, and it leaves the channel-one hand-sync
  outside the rule.
- _Name the four files in the spec._ Rejected: that is what the decision log and the Channels-and-targets glossary are
  for.

**Driven by findings:** F4
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Channels and targets, Edge cases

### D21: The release-procedure documents are owned by the step that falsifies them

**Outcome.** The documents describing the release procedure are corrected by the release-repair step, not by the
document-correction step. The Outcome carries a distinct bullet for them.

**Rationale.** Review found that the release repair and the check falsify two more documents, and the
document-correction step's charter did not cover them. The instinct was to widen that charter to "topology or release
procedure". The better fix is narrower: the gap was in the **Outcome**, which had exactly one documentation bullet
(topology) and none for the procedure. That is why those documents had no home.

Widening the document-correction step would make it a grab-bag of two unrelated jobs, sequenced against the declaration
deletion when half of it depends on the release repair instead. Under D7's rule — a document is in scope when this work
falsifies it — the falsifying step owns it. The release repair falsifies them, so it owns them.

This is load-bearing for the spec's own promise. The "a new plugin is added → the check fails on the pull request" flow
is only defensible behavior if the contributor guide told them the four places. Today it tells them one.

**Evidence.** codebase — `CONTRIBUTING.md:157` instructs "Update the marketplace registry at
[`.claude-plugin/marketplace.json`]… if the new skill ships in a different plugin's component set" — one of four targets.
codebase — `docs/semantic-versioning.md:4`, `:92`, and `:172` each instruct syncing the version to "the plugin's entry in
`marketplace.json`", singular, and the file contains **zero** occurrences of "codex". codebase —
`docs/how-to/extend-han-with-plugin-dependencies.md:150` teaches "The plugins are all listed in one `marketplace.json`",
which the repair falsifies; it sits in the same paragraph block the document-correction step is already rewriting, so the
two steps coordinate there.

**Rejected alternatives.**

- _Widen the document-correction step to cover both._ Rejected: two unrelated jobs in one step, sequenced against the
  wrong dependency.
- _Leave them; they are about procedure, not topology._ Rejected: the check blocks a contributor for following the guide
  the project gave them, which is a worse broken promise than the one at D11.

**Driven by findings:** F8
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Outcome, Primary flow (Step 3 owns the documents; Step 6 points at that ownership),
Alternate flows and states

### D22: The new version record is created at the plugin's channel-one version

**Outcome.** Step 1 creates the Linear plugin's channel-two version record at the version channel one already publishes
for it.

**Rationale.** Step 1 must choose a version and the spec did not say which. The choice determines whether a step 1 to
step 4 dependency exists at all: create it at the channel-one version and the correction step never touches it; create it
at some "matching the other codex manifests" value and step 1 has deliberately introduced a defect for a later step to
repair. This follows directly from D10, and it dissolves the coupling rather than managing it.

**Evidence.** codebase — `han-linear/.claude-plugin/plugin.json` is at `1.0.2`. codebase — every other plugin's
`.codex-plugin/plugin.json` was created at some `1.x` unrelated to its channel-one number, which is the pattern that
produced the drift D10 fixes; repeating it here would manufacture a ninth instance.

**Rejected alternatives.**

- _Create it at 1.0.0 to match the other codex manifests._ Rejected: manufactures a defect for step 4 to repair, and
  perpetuates the pattern D10 exists to end.
- _Leave it unstated._ Rejected: it is the single most concrete inter-step coupling in the plan.

**Driven by findings:** F13
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 1)

### D23: Step 2 is a distinct concern retained by instruction

**Outcome.** Step 2 stays in this specification. The spec records that it shares no actor, artifact, target, or failure
mode with the other six steps, and that it is independently schedulable.

**Rationale.** Review established that "publish" means two different things across this plan: Han-the-product being
published to marketplaces, and a user's work-items file being published to an issue tracker. Step 2 belongs to the
second and everything else to the first. The check does not check it; the release does not touch it; no decision argued
for its inclusion, and D15 argues the other way by naming the folder for the publishing pipeline.

The honest justification is that the user asked for all seven steps in order. That is a legitimate reason to keep it and
not a reason to pretend the coupling is real. Recording the seam costs a sentence and keeps the spec truthful about its
own shape.

**Evidence.** provided — the user's instruction to include all seven steps, reaffirmed after the seam was surfaced with
the alternative of splitting it out. codebase — step 2 touches only `han-github/skills/work-items-to-issues/`, which no
other step touches.

**Rejected alternatives.**

- _Split step 2 into its own specification._ Rejected by the user after being offered: it would make the remaining six a
  single coherent feature with one actor, but it departs from the instruction to include all seven.
- _Argue the coupling is real ("both are Han losing track of something it published")._ Rejected outright: no evidence
  supports it beyond shared provenance, and manufacturing a coupling to justify a grouping is exactly the reasoning this
  spec's YAGNI rule exists to catch.

**Driven by findings:** F12
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 2)

### D24: The gate runs after all targets are written and before anything irreversible

**Outcome.** One gate. It runs after the release has written all four targets and before it commits, tags, pushes, or
publishes.

**Rationale.** The original spec said the release "stops before publishing anything". In the release skill's own
vocabulary "publish" names its final step, so that sentence permitted stopping *after* the tag was pushed — the
irreversible act D12's rationale says it exists to prevent.

The placement is forced from both sides. It cannot run earlier than the writes: at release start the versions agree, and
the release itself is what breaks the agreement when it writes the new channel-one version, so a pre-flight gate passes
trivially and says nothing about the state being released. It cannot run later than the commit: everything after is hard
to reverse. Between the writes and the commit is the only window where the gate can see the real state and still fail
harmlessly.

This also makes partial failure a non-event: every write precedes anything irreversible, so a failure mid-write leaves
local modifications and nothing published. Recovery is discarding them. No compensation or rollback machinery is needed,
and specifying any would be building for an incident that cannot happen.

And it settles what stops a release cut from a branch where a step has not landed: the gate, not a pull-request check
that may never have run.

**Evidence.** codebase — `.claude/skills/han-release/SKILL.md` Step 9 is titled "Publish the GitHub release", so
"publish" is a defined term naming the last step. codebase — its irreversible actions are Step 8.3 (`git push origin
v{parent target}`) and Step 9 (`gh release create`); all target writes happen at Step 4. codebase — the same skill's
Step 1.2 sets the precedent: "This is a hard stop, not a pause gate", reasoned from "a pushed tag is hard to reverse".
codebase — Steps 8.2 and 9 are already re-entrant ("do **not** recreate it"; "do not create a second one"), so a stopped
release is safely re-runnable. codebase — Step 1.3 explicitly permits cutting from a non-default branch ("do not
stop… surface the fact, do not block"), and `.github/workflows/ci.yml` triggers only on `pull_request` and pushes to
`main`, so a branch with no pull request gets no pipeline run.

**Rejected alternatives.**

- _A pre-flight gate before the release does its work._ Rejected: cannot see the version agreement it is meant to check,
  because the release has not written the new version yet. Offered in review as an ergonomic addition; the reviewer
  themselves marked it as not a correctness concern and said not to add it here.
- _Gate after the tag, before the GitHub release._ Rejected: the tag is the hard-to-reverse thing.
- _Two gates, one for membership and one for versions._ Rejected: two placements, two things to keep aligned, no benefit
  over one gate placed where both questions are answerable.

**Driven by findings:** F2, F11, F23
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 3), Alternate flows and states, Coordinations

### D25: Manifest descriptions are documents; the declarations are the record

**Outcome.** A plugin manifest's description field is a document and is in scope for D7's rule. A manifest's dependency
declarations are the record itself, not a description of it, and are the deletion step's business.

**Rationale.** The spec said "no document describes a dependency the suite does not have" without saying whether
manifests count. Description fields are user-facing prose rendered in the storefront, so they can be false in exactly the
way the rule cares about. The sweep came back clean, so this costs nothing today — but the next person applying the rule
needs to know whether manifests are in it, and "we checked and it was fine" is a real result worth recording.

**Evidence.** codebase — `han-reporting/.claude-plugin/plugin.json` and `han-feedback/.claude-plugin/plugin.json`
description fields do not narrate dependencies. codebase — `.claude-plugin/marketplace.json`'s description for the bundle
narrates only the bundle's own dependencies, which this work does not change, so it stays true. codebase —
`.agents/plugins/marketplace.json` carries no dependency narration at all.

**Rejected alternatives.**

- _Leave it unstated because the sweep was clean._ Rejected: the rule outlives this sweep and the next reader needs its
  boundary.

**Driven by findings:** F27
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 6)

### D26: Corrected documents state the rule and point at the record

**Outcome.** The corrected documents state the dependency rule and point at the manifests as the record, rather than
restating manifest contents in prose. Hardcoded counts in the affected passages go with them.

**Rationale.** The contributor-guide claim in scope fails as a universal quantifier that outlived its truth. The obvious
fix — swap it for an enumeration of the plugins that do depend on core — has the same half-life: it is false the day
someone adds a plugin, and nothing in the repository will notice. That is the standing-defect shape D5 diagnoses in the
release process, relocated into prose. Fixing a stale claim with a differently-stale claim is not a fix.

The repository already models the alternative and already has the convention.

**Evidence.** codebase — `CLAUDE.md` § Conventions: "**Indexes stay complete, not counted.** …Verify the indexes list
every entity when editing them, rather than tracking a running total." codebase — `docs/concepts.md:221` ("Each of these
**four** depends on `han-core`") and `:229` ("Each of these **three** depends on `han-core`") are hardcoded counts in the
exact passages the correction must edit. codebase — `docs/concepts.md:238` already models the target pattern ("For which
one to install and the dependency that surprises people, read [Choosing a Han plugin]"): one canonical location,
everything else pointing at it.

**Rejected alternatives.**

- _Swap the universal claim for an enumeration._ Rejected: same defect, longer fuse.
- _Also de-duplicate the topology narration in the agent-facing project map, which states it three times in one file._
  Rejected: real, but not falsified by this work and therefore outside D7's rule. The correction should not deepen it
  either.

**Driven by findings:** F10
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 6)

### D27: The tutorial teaches shape and stops promising real version numbers

**Outcome.** The tutorial's claim to print the real on-disk version numbers is deleted. Its existing "describing the
shape, not pinning the numbers" caveat covers the document, including the child plugins' dependency arrays.

**Rationale.** The claim is already false — every version number it names is wrong — and the repointing at D8 would
otherwise rewrite the plugin names in that very paragraph while leaving the promise standing. An untouched lie is a bug;
a lie a maintainer edited around and left is a signal the doc is unmaintained.

The document already argues for this answer against itself. The same sentence that makes the promise immediately
withdraws it: "If you are reading the manifests and the numbers differ, the manifests are right; this guide is describing
the shape, not pinning the numbers." Deleting the first half and keeping the second is the edit the document is already
asking for.

**Evidence.** codebase — `docs/how-to/extend-han-with-plugin-dependencies.md:212-214` claims `han-core`, `han-github`,
`han-reporting`, and `han-feedback` "are at 1.0.0 and `han` is at 3.0.0 as written"; on disk they are 2.2.1, 2.2.2,
2.1.1, 2.0.0, and 4.6.0. All five are wrong. codebase — the same sentence carries its own escape hatch, quoted above.
codebase — the tutorial's `:114-118` prints the reporting plugin's manifest as `["han-core"]` when it is really
`["han-communication", "han-core"]`, so the printed manifests are already inexact in a second, unrelated direction, and
substituting the coding plugin reproduces it. codebase — `:84-86` already carves out a "simplified example" caveat for
the core plugin's own dependency, establishing the pattern.

**Rejected alternatives.**

- _Keep the promise and print the real manifests, syncing every release._ Rejected under YAGNI: no evidence any reader
  wanted the numbers real, and it creates a per-release maintenance obligation nobody asked for. The reviewer who raised
  this flagged the option as a YAGNI candidate themselves.
- _Leave the promise; it is not what this work falsified._ Rejected: D7's rule excludes documents this work does not
  falsify, but D8 rewrites this exact paragraph. Editing around a known falsehood in the sentence you are already
  changing is the D9 situation again.

**Driven by findings:** F9, F19
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 6)

### D28: The check ships with no disable switch

**Outcome.** No disable mechanism, no configuration to skip it, no bypass flag. Recorded as a deliberate non-decision so
the implementation plan does not add one.

**Rationale.** A disable mechanism is the "land it disabled" alternative D1 already rejects, and it is the same shape as
the configurable exception mechanism D6 rejects. Reversibility already exists: the check lands in one commit, so
reverting that commit is the escape hatch. D18's ordering is engineered so the check is green on arrival, which is the
real mitigation.

Building a bypass "for safety" before the check has ever run once is a feature flag with no kill-switch criteria and no
owner.

**Evidence.** codebase — the check does not exist yet, so no false positive exists to design around. codebase — every
other hook in `.pre-commit-config.yaml` ships without a bypass. provided — D1's own rationale, which establishes that the
failure mode is people turning checks off, not checks being too strict.

**Rejected alternatives.**

- _Add a documented bypass for emergencies._ Rejected under YAGNI: no incident, no evidence, and it recreates the
  disabled-check failure D1 is built around. **Reopening trigger:** the check produces its first false positive on a
  pull request that is actually correct.

**Driven by findings:** F24
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 7), Deferred (YAGNI)

### D29: A listing entry with no plugin behind it fails the check

**Outcome.** The check fails when a storefront listing names a plugin that does not exist in the repository, not only
when the repository holds a plugin no listing names.

**Rationale.** Promoted from an uncited spec table row after review. The row was the only one in the table with no
decision behind it, and its entire justification was "a listing entry pointing at nothing is the same class of defect" —
which is the symmetry anti-pattern verbatim, and would have failed the evidence test as written.

The behavior is right and real evidence exists; it simply was not cited. A listing entry resolving to nothing breaks the
Outcome's own first promise directly: the documented install command errors, which is precisely the D11 failure this work
starts by fixing.

**Evidence.** codebase — both storefront listings reference plugins by relative path
(`"source": "./han-core"`-style), so a moved or removed directory leaves the entry dangling. codebase — this repository
has already renamed every plugin directory in a single commit (`d94daa2`, "Rename all plugins to use hyphens instead of
dots"), which is mechanically identical to delete-old-path-add-new; that commit updated the listings atomically, but it
establishes that the repository does move plugin directories. codebase — every listing entry resolves today, so this is
prevention of a demonstrated-possible edit, not a fix for a live break.

**Rejected alternatives.**

- _Defer it; nothing is broken today._ Rejected: it is the same set comparison as the direction already being built, the
  rename precedent is real, and the failure it prevents is the Outcome's headline promise.
- _Keep it justified by "same class of defect."_ Rejected: that is the reasoning the spec's own YAGNI rule names as an
  anti-pattern. The behavior survives; the justification did not.

**Driven by findings:** F16
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Edge cases

### D30: "Accounted for" is defined so the promise is not circular

**Outcome.** Every heading in a work-items file is either published, skipped-and-counted, or surfaced. "Accounted for"
means one of those three happened to it — not "it matched a pattern we recognize".

**Rationale.** The original promise was circular. A work item was defined as a heading matching a recognized pattern, so
"every work item is accounted for" reduced to "every item we recognize is accounted for", which was already true. The
foreign-annotation fix would have closed one way of not matching and left every other way silent.

The other ways are not hypothetical. The separator is an em-dash, which needs a special input method; most editors and
copy-paste produce a plain hyphen. A hand-edited file with `## W-1 - title` fails every pattern and vanishes exactly like
a foreign annotation does. The publisher's own skill already lists "Malformed heading" as an expected finding, so its
author expected this.

Defining the promise by outcome rather than by pattern is also what makes the user-facing commitment achievable: a person
can only tell "already published to another tracker" from "file is malformed" if malformed is a detectable category
rather than a residue.

**Evidence.** codebase — `han-github/skills/work-items-to-issues/references/work-items-file-format.md:55` defines a slice
as "one slice per `## <SYM-N> — <title>` heading", which is the circularity. codebase — `create-issues.sh:60`, `:72`,
`:95`, `:102` all anchor on the literal em-dash (U+2014) with a space either side. codebase —
`han-github/skills/work-items-to-issues/SKILL.md:89` already lists "Malformed heading — propose the corrected shape based
on the surrounding text" as a Step 3 validation finding, so malformed headings are an expected category one layer up.

**Rejected alternatives.**

- _Promise only that foreign annotations are surfaced._ Rejected: narrower than the step's stated outcome and leaves the
  hyphen case silent, which is the most likely malformation in practice.
- _Enumerate every malformation to detect._ Rejected: the outcome-shaped definition covers them without a list that will
  be incomplete.

**Driven by findings:** F7
**Linked technical notes:** —
**Dependent decisions:** —
**Referenced in spec:** Primary flow (Step 2), Edge cases, User interactions

## Trivial decisions

- **D15: Output location** — `docs/plans/han-publishing-cleanup/`, alongside the existing plan folders. Named for the
  publishing pipeline because that is the actual problem, not the dependency graph (considered `docs/plans/han-cleanup/`
  to match the source artifact's filename; rejected because it names the investigation rather than the work). —
  Referenced in spec: (header).
- **D16: Channel one is left alone** — it is healthy, and every change here brings channel two up to it. — Referenced in
  spec: Out of scope.

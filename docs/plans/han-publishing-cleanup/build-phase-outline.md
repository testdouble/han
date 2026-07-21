---
title: "Han Publishing Cleanup: Build Phase Outline"
source_artifact: "./source-han-cleanup-plan.md"
audience: "mixed engineering, product, and leadership"
generated: "2026-07-21"
generated_by: "han-planning:plan-a-phased-build"
---

<!--
Plain-language contract: the body of this document contains no file paths, line
numbers, function or class names, library mechanics, or internal flag names.
The one exception is each phase's "Source citations" list, which may name
source-artifact sections by their actual heading text.

Anchor stability: phase headings carry an explicit {#phase-N} anchor and
open-question headings carry {#oq-N}. Renaming a phase never breaks a deep link.
-->

# Han Publishing Cleanup: Build Phase Outline

This document describes the order in which the Han publishing cleanup will be built. The work is broken into a sequence
of **phases**, where each phase is a thin end-to-end deliverable that can be demonstrated to a real person, and each
phase builds on the one before it. The cleanup repairs how Han is published to the people who install it: a missing
plugin, work items that vanish without a trace, frozen version numbers, untrue dependency declarations, and a release
process that only sees half the places it ships to.

This document is the companion to [source-han-cleanup-plan.md](./source-han-cleanup-plan.md). The source artifact
describes _what is broken in Han's publishing pipeline today and the seven fixes it recommends, in order_. This
document describes _the order in which the work will be built to close that picture_. Every phase below cites the
source-artifact sections it covers, so anyone can trace a phase back to source.

## Table of Contents

- [Executive Summary](#executive-summary)
- [Build Phase Index](#build-phase-index)
- [Phase Kinds](#phase-kinds)
- [Build Phases](#build-phases)
  - [Phase 1: Publish the Linear plugin to the second channel](#phase-1)
  - [Phase 2: Close the GitHub publisher's silent gap](#phase-2)
  - [Phase 3: Unfreeze the second channel's version numbers](#phase-3)
  - [Phase 4: Remove the two untrue dependency declarations](#phase-4)
  - [Phase 5: Correct the two documents that describe behavior the system does not have](#phase-5)
  - [Phase 6: Teach the release process about all four publishing surfaces](#phase-6)
  - [Phase 7: Turn on the automated completeness check](#phase-7)
  - [Phase 8 (Deferred): Consolidate the duplicated rule documents](#phase-8)
- [Open Questions](#open-questions)
  - [OQ-1: How far does the ticket-file fix go in Phase 2?](#oq-1)
  - [OQ-2: Should plugins declare which versions of each other they work with?](#oq-2)
  - [OQ-3: Does the format-checking step really catch a mismatched ticket file?](#oq-3)

---

## Executive Summary {#executive-summary}

**The goal:** Every Han plugin is published, current, and honestly described on both of the channels people install it
from, and an automated check makes it impossible to quietly break that again.

Han ships through two install channels. Following the source artifact, this document calls them the first channel and
the second channel. The first channel is healthy; the second channel is the one that has been quietly rotting, and it
is where most of this cleanup lands.

**The shape of the build (plain language):**

- Phases 1 through 3 repair what users hit today: a plugin that is advertised but missing, work items that vanish from
  a publishing run with no trace, and version numbers so stale that nobody is ever offered an update.
- Phases 4 and 5 clean up the record: two dependency declarations that are not true, and two documents that describe a
  behavior the system does not have.
- Phase 6 teaches the release process to start from what is really in the repository and to update all four publishing
  surfaces instead of two.
- Phase 7 turns on the automated check that keeps every earlier fix fixed. It comes last on purpose.
- One piece of work is deferred: consolidating the duplicated rule documents, with a named trigger for reopening it.

**Sequencing rationale, in plain language:**

The order comes from the source artifact, and the source is explicit that it is not negotiable. The user-facing harms
come first because someone following the documented instructions hits an error today. The record cleanup and the
release-process fix come next because the automated check depends on them. If the check were turned on first, it would
fail on almost every plugin from day one, someone would disable it, and it would protect nothing. Fixed first, then
guarded: that is the whole sequencing argument.

**Phases deliberately deferred:**

Consolidating the three plugins' duplicated copies of the same two rule documents is listed as Phase 8 but not built
now. The source artifact strengthens the case for consolidation, yet it is not one of the seven ordered fixes, and none
of the seven depend on it. It reopens the next time one of those shared rules changes.

**Where to look next:** The [Build Phase Index](#build-phase-index) lists every phase in order. Detailed write-ups
follow under [Build Phases](#build-phases). Decisions the team must resolve before work starts are at
[Open Questions](#open-questions).

---

## Build Phase Index {#build-phase-index}

> The scan view. One row per phase, in build order. Each "Outcome" cell is one short sentence. Detailed write-ups
> follow under [Build Phases](#build-phases); use the link in the Phase column.

| #   | Phase                                                                                  | Kind          | Outcome (one sentence)                                                       |
| --- | -------------------------------------------------------------------------------------- | ------------- | ---------------------------------------------------------------------------- |
| 1   | [Publish the Linear plugin to the second channel](#phase-1)                            | Feature slice | Following the second channel's setup instructions for Linear now works.      |
| 2   | [Close the GitHub publisher's silent gap](#phase-2)                                    | Feature slice | No work item can vanish from a GitHub publishing run without a trace.        |
| 3   | [Unfreeze the second channel's version numbers](#phase-3)                              | Feature slice | People on the second channel are offered updates again.                      |
| 4   | [Remove the two untrue dependency declarations](#phase-4)                              | Feature slice | Installing Reporting or Feedback no longer drags in a plugin they never use. |
| 5   | [Correct the two documents that describe behavior the system does not have](#phase-5)  | Polish        | Both documents now match what the system really does.                        |
| 6   | [Teach the release process about all four publishing surfaces](#phase-6)               | Feature slice | A release starts from the repository and updates all four surfaces.          |
| 7   | [Turn on the automated completeness check](#phase-7)                                   | Feature slice | Every release and change is blocked if any plugin is missing anywhere.       |
| 8   | [Consolidate the duplicated rule documents (deferred)](#phase-8)                       | Deferred      | Three plugins share one copy of each rule instead of hand-synced copies.     |

> Numbers are assigned in build order and are stable for the life of this outline. Cite them as `Phase N` in tickets,
> comments, and follow-up reports.

---

## Phase Kinds {#phase-kinds}

Every phase is tagged with one of four kinds. The taxonomy is used in the Build Phase Index and on each phase entry's
`**Kind.**` line.

- **Foundation** — A capability that does not deliver new user-facing features on its own, but is required for later
  phases. Must still be demoable in its own right (e.g., "an admin can edit and persist a new setting"). No phase in
  this plan uses the Foundation kind.
- **Feature slice** — A thin end-to-end strip of new behavior that a real user can experience.
- **Polish** — Branding, refinement, observability, or quality-of-life work that enriches a working core.
- **Deferred** — Listed for traceability; not built in the current plan. Slotted at the end of the index.

---

## Build Phases {#build-phases}

### Phase 1: Publish the Linear plugin to the second channel {#phase-1}

**Kind.** Feature slice.

**Builds on.** Nothing. This is the starting phase.

**What we build.** The Linear integration is published to the second install channel, the one place it is advertised
but missing. Today the setup instructions for that channel tell people to install it, and anyone who follows them gets
an error. After this phase, the instructions work as written.

**Why this is Phase 1.** This is the only fix where a new user hits a hard error in the first thing they try, so it
carries the most immediate harm. It needs nothing else in place first. The source artifact ranks it first for the same
reason: the plugin exists and works, and only the publishing step was missed.

**Outcome to demonstrate.**

1. Open the second channel's setup instructions for the Linear integration.
2. Follow them exactly, as a new user would.
3. The installation succeeds instead of returning an error.
4. Run the installed integration's work-item publishing skill and confirm it is the current version.

**Source citations.**

- ["The publishing pipeline: the actual problem"](./source-han-cleanup-plan.md#the-publishing-pipeline-the-actual-problem),
  the "One plugin is not there at all" finding.
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 1.

**Connects to.**

- [Phase 7](#phase-7): the automated check cannot land green while this plugin is missing from the channel.

**Preconditions to verify before starting.**

- Confirm the second channel accepts a first-time publication of a plugin that was never listed there, rather than only
  updates to existing listings.

---

### Phase 2: Close the GitHub publisher's silent gap {#phase-2}

**Kind.** Feature slice.

**Builds on.** Nothing from Phase 1. It holds position 2 because the source ranks the remaining fixes by user harm, and
this is the only one where work silently disappears.

**What we build.** Three plugins publish work items to three different trackers, and all three record what they
published by marking up the same shared file. When the GitHub publisher meets a file marked up by a different tracker,
those items match none of the patterns it looks for, so they are neither published nor counted as skipped. They vanish
from the run with no error and no signal. After this phase, every work item in a GitHub publishing run is accounted
for: published, skipped with a count, or reported as belonging to another tracker.

**Why this is Phase 2.** Silent data loss outranks every remaining problem: the other two tracker publishers at least
report a skipped count that an attentive person would notice, while this one leaves no trace at all. The source calls
it "the one worth fixing first" among the ticket-file problems. It depends on nothing else in this plan.

**Outcome to demonstrate.**

1. Take a work-items file that another tracker's publisher has already marked up.
2. Run the GitHub publisher against it.
3. Every item in the file appears in the run's output: published, skipped, or flagged as marked by another tracker.
4. Confirm the flagged items were not silently dropped and the run says what to do about them.

**Source citations.**

- ["The shared ticket file: a real bug, described more carefully than I first described it"](./source-han-cleanup-plan.md#the-shared-ticket-file-a-real-bug-described-more-carefully-than-i-first-described-it).
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 2.

**Connects to.**

- No later phase depends on it. It is sequenced here purely by severity.

**Preconditions to verify before starting.**

- Resolve [OQ-1](#oq-1): whether this phase also adopts tracker-labeled marks across all three publishers, or only
  closes the GitHub publisher's gap.

---

### Phase 3: Unfreeze the second channel's version numbers {#phase-3}

**Kind.** Feature slice.

**Builds on.** Nothing from earlier phases. It holds position 3 in the source's harm-first ordering.

**What we build.** The second channel decides whether an update is available by reading a version number that has not
moved since the day it was written, so it never offers anyone an update. This phase corrects every frozen version
number on that channel to match the versions that actually shipped, so people stuck on old copies start being offered
updates again.

**Why this is Phase 3.** Everyone on the second channel is affected, but nothing errors: they quietly run old skills.
That makes it less urgent than a hard install failure (Phase 1) or silent data loss (Phase 2), and more urgent than
record cleanup. It is also one of the named prerequisites for the automated check: turned on before this fix, the check
would fail on almost every plugin.

**Outcome to demonstrate.**

1. Set up a machine with an older copy of a Han plugin installed from the second channel.
2. Check for updates on that channel.
3. An update is offered, where before this phase none ever was.
4. Accept the update and confirm the installed version now matches the latest release.

**Source citations.**

- ["The publishing pipeline: the actual problem"](./source-han-cleanup-plan.md#the-publishing-pipeline-the-actual-problem),
  the "People on the second channel are stuck on old versions and cannot tell" finding.
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 3.

**Connects to.**

- [Phase 6](#phase-6): once the release process owns all four surfaces, it keeps these numbers moving.
- [Phase 7](#phase-7): the check cannot land green while these numbers are stale.

**Preconditions to verify before starting.**

- Confirm which released version each plugin on the second channel should be corrected to, so the fix does not guess.

---

### Phase 4: Remove the two untrue dependency declarations {#phase-4}

**Kind.** Feature slice.

**Builds on.** Nothing from earlier phases. The user-facing repairs come first; this begins the record cleanup.

**What we build.** Two plugins, Reporting and Feedback, declare that they need the Core plugin and never touch it.
Reporting's declaration is a leftover from a capability that moved to the Communication plugin; Feedback's cannot be
true because that plugin is not permitted to call other plugins at all. This phase deletes both declarations. Two
lines removed, nothing added.

**Why this is Phase 4.** The direct cost is small: people installing either plugin quietly get a large plugin they
never use. The real damage is to trust in the declarations as a whole, since nobody can rely on them to answer "what
breaks if I change this?" while two of them are decorative. It lands after the user-facing repairs because nobody hits
an error from it, and before Phase 5 so the corrected documents describe the cleaned-up state.

**Outcome to demonstrate.**

1. On a clean machine, install the Reporting plugin.
2. Confirm the Core plugin is not pulled in alongside it.
3. Run a Reporting skill end to end and confirm it still works, including its writing pass.
4. Repeat steps 1 through 3 for the Feedback plugin.

**Source citations.**

- ["The dependency graph: two threads to snip"](./source-han-cleanup-plan.md#the-dependency-graph-two-threads-to-snip).
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 4.

**Connects to.**

- [Phase 5](#phase-5): the corrected documents should describe the dependency picture as it stands after this phase.

**Preconditions to verify before starting.**

- Re-confirm neither plugin reaches the Core plugin through any path the analysis did not cover, so removing the
  declarations cannot break a working flow.

---

### Phase 5: Correct the two documents that describe behavior the system does not have {#phase-5}

**Kind.** Polish.

**Builds on.** Phase 4, so the corrected documents describe the dependency picture after the cleanup rather than
before it.

**What we build.** Two documents describe a behavior the system does not have. Anyone making a change based on either
one would get it wrong. This phase corrects both so they match what the system really does.

**Why this is Phase 5.** Wrong documentation causes harm only when someone acts on it, so it sequences after every fix
a user can hit directly. It comes immediately after Phase 4 because documentation should be corrected once, against the
cleaned-up state, rather than corrected twice.

**Outcome to demonstrate.**

1. Open each of the two corrected documents.
2. For each behavior the document describes, exercise that behavior in the system.
3. Confirm the document and the system agree, where before this phase they did not.

**Source citations.**

- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 5.

**Connects to.**

- No later phase depends on it. It closes out the record cleanup that Phase 4 started.

**Preconditions to verify before starting.**

- Confirm from the underlying analysis exactly which two documents item 5 refers to, and which described behavior each
  one gets wrong. The source artifact names the count and the harm, not the titles.

---

### Phase 6: Teach the release process about all four publishing surfaces {#phase-6}

**Kind.** Feature slice.

**Builds on.** Phases 1 and 3 in practice: teaching the release process to see the second channel is far simpler when
that channel's contents are already correct.

**What we build.** Today the release process updates two publishing surfaces and does not know the other two exist,
which is why roughly twenty releases went by without anyone noticing the rot. After this phase the release process
starts from the plugins as they actually exist in the repository, rather than trusting a list that can go stale, and
updates all four surfaces. It also knows the one deliberate exception permanently: the all-in-one bundle cannot be
published to the second channel because that channel does not support bundles yet.

**Why this is Phase 6.** This is the root-cause fix: every earlier publishing problem grew from a release process that
could not see half the world. It lands after Phases 1 and 3 so it maintains a correct state instead of inheriting a
broken one, and immediately before Phase 7 because the automated check enforces exactly the behavior this phase
teaches.

**Outcome to demonstrate.**

1. Run the release process in a rehearsal mode against the current repository.
2. Confirm it lists every plugin found in the repository as its starting point.
3. Confirm it updates, or reports it would update, all four publishing surfaces.
4. Confirm the all-in-one bundle's absence from the second channel is reported as a known, documented exception rather
   than an error.

**Source citations.**

- ["The publishing pipeline: the actual problem"](./source-han-cleanup-plan.md#the-publishing-pipeline-the-actual-problem),
  the "Before", "After", and root-cause findings.
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 6.

**Connects to.**

- [Phase 7](#phase-7): the check turns the behavior this phase teaches into something that cannot regress.

**Preconditions to verify before starting.**

- Confirm the full list of four publishing surfaces and what "up to date" means for each.
- Confirm the bundle exception is recorded somewhere durable the release process and the check can both consult.

---

### Phase 7: Turn on the automated completeness check {#phase-7}

**Kind.** Feature slice.

**Builds on.** Phases 1, 3, and 6. The source is explicit that this order is not negotiable: the check must land on a
tree that already passes it.

**What we build.** An automated check that asks one question on every release and every proposed change: does every
plugin appear everywhere it should, at the right version? If anything is missing, it stops the release or flags the
change and says exactly what is absent. It knows about the all-in-one bundle exception permanently, so that one
deliberate gap is never flagged.

**Why this is Phase 7.** The first six fixes are small; this is what makes them stay fixed. Turned on before the tree
is ready, the check fails on almost every plugin from day one, someone disables it, and it protects nothing. Turned on
last, it lands green, stays green, and makes every problem above impossible to reintroduce, including the "plugin added
today lands invisible by default" failure that caused the Linear gap.

**Outcome to demonstrate.**

1. Run the check against the current repository and watch it pass.
2. On a throwaway branch, add a new plugin without publishing it anywhere.
3. Run the check again and watch it fail, naming the new plugin and each surface it is missing from.
4. Confirm the all-in-one bundle's known exception is not flagged in either run.

**Source citations.**

- ["The order matters, and getting it wrong stops everything"](./source-han-cleanup-plan.md#the-order-matters-and-getting-it-wrong-stops-everything).
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 7 and its closing
  paragraph.

**Connects to.**

- This is the final phase. It guards the outcomes of [Phase 1](#phase-1), [Phase 3](#phase-3), [Phase 4](#phase-4), and
  [Phase 6](#phase-6) from regressing.

**Preconditions to verify before starting.**

- Confirm Phases 1, 3, and 6 are complete and the check's first run against the real tree passes before it is allowed
  to block anything.

---

### Phase 8 (Deferred): Consolidate the duplicated rule documents {#phase-8}

**Kind.** Deferred.

**Builds on.** Not applicable until built.

**What we build.** Three plugins each carry their own copy of the same two rule documents. When one rule changed, a
person had to remember to make the identical edit in three separate places, and so far has gotten it right. This phase
would consolidate each rule into one shared copy so that manual synchronization stops being a job.

**Why this is deferred.** The source artifact strengthens the case for consolidation, reversing the earlier analysis
that said to leave the copies alone. But it is not one of the seven ordered fixes, none of the seven depend on it, and
the copies are correct today. Building it now would be work the cleanup does not need; listing it here gives the team a
place to slot it when the trigger fires.

**Reopen when.** The next time either of the two shared rules needs an edit, consolidate before or alongside that edit
instead of hand-copying the change into three places again.

**Outcome to demonstrate (when or if built).**

1. Edit the shared rule in its one canonical location.
2. Confirm all three plugins that follow the rule pick up the change.
3. Confirm no plugin still carries a private copy that could drift.

**Source citations.**

- ["Two places the reviewer changed my mind entirely"](./source-han-cleanup-plan.md#two-places-the-reviewer-changed-my-mind-entirely),
  the "On duplicated rule files" finding.

---

## Open Questions {#open-questions}

> Decisions the team must resolve before the corresponding phase starts. Cite open questions as `OQ-N` in follow-up.
> Verification steps that need no decision stay on each phase's "Preconditions to verify" list.

### OQ-1. How far does the ticket-file fix go in Phase 2? {#oq-1}

**Blocks phase(s).** Phase 2.

The source describes two related problems with the shared ticket file. The GitHub publisher silently drops items
marked by another tracker; that is Phase 2's committed scope. Separately, the other two publishers can mistake each
other's marks and skip work that was never published to their tracker, and the source names the fix: make every
publisher's marks say which tracker they came from. That fix changes the file format, so files marked up the old way
need a migration path, one that stops and asks rather than guesses.

- **Option A — Adopt tracker-labeled marks across all three publishers now.** Closes the silent gap and the
  cross-tracker trap in one pass, since it is the fix the source itself names. Costs more: a format change, a
  migration path, and coordinated changes to three plugins instead of one.
- **Option B — Only close the GitHub publisher's gap now.** The GitHub publisher learns to recognize marks that are
  not its own and reports them instead of dropping them. Smallest change that ends the silent data loss. The
  cross-tracker trap remains, though it is visible in the skipped counts rather than silent.
- **Recommendation: Option A.** The source presents the tracker-labeled format as the fix, not an option, and Option B
  would leave the two other publishers able to skip each other's unpublished work. The migration path already errs
  toward stopping and asking, which contains the format change's risk. If the team wants the thinnest possible Phase
  2, Option B is defensible, but the trap then needs its own reopening trigger so it is not forgotten.

### Carry-over notes {#carry-over-notes}

The two questions below block no phase in this plan. They are carried over from the source artifact so they stay
visible, and each names the trigger that would put it back on the table.

### OQ-2. Should plugins declare which versions of each other they work with? {#oq-2}

**Blocks phase(s).** None — carry-over note.

The source reverses the earlier analysis that closed this question. Plugins are installed and updated one at a time,
so someone can update the Core plugin today while running a months-old Coding plugin, and nothing anywhere notices or
complains. The source deliberately proposes no fix because the right one is not obvious. The question stays open here
so it is not lost: it deserves a real decision of its own, outside this cleanup. Note that the source's own confidence
caveat applies: its conclusion rests on the project's description of how installation works being accurate.

**Reopen when.** The first time a user reports breakage from mismatched plugin versions, or the next time a change to
one plugin knowingly alters behavior another plugin relies on.

### OQ-3. Does the format-checking step really catch a mismatched ticket file? {#oq-3}

**Blocks phase(s).** None — carry-over note, though it informs Phase 2's demo.

The source's reviewer could not test whether the step that is supposed to catch a mismatched ticket file catches one
in practice, because that depends on judgment at the time rather than anything written down. Phase 2's demonstration
script exercises exactly this path, so running that demo honestly, with a file marked by another tracker, doubles as
the missing test.

**Reopen when.** Phase 2's demonstration runs. If the mismatched file is caught, this note closes; if not, the gap
becomes part of Phase 2's fix.

---

_End of outline. If you need to cite a specific phase elsewhere, use its `Phase N` number — those numbers are stable
for the life of this document. If you need to cite a specific open question, use its `OQ-N` ID._

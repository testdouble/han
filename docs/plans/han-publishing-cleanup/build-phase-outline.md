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
of **phases**. Each phase is a thin end-to-end deliverable that can be demonstrated to a real person, and each phase
builds on the one before it.

The cleanup repairs how Han is published to the people who install it: a missing plugin, work items that vanish without
a trace, frozen version numbers, untrue dependency declarations, plugins that never say which versions of each other
they work with, and a release process that only sees half the places it ships to.

This document is the companion to [source-han-cleanup-plan.md](./source-han-cleanup-plan.md). The source artifact
describes _what is broken in Han's publishing pipeline today and the seven fixes it recommends, in order_. This
document describes _the order in which the work will be built to close that picture_. Every phase below cites the
source-artifact sections it covers, so anyone can trace a phase back to source.

## Table of Contents

- [Executive Summary](#executive-summary)
- [Build Phase Index](#build-phase-index)
- [How This Build Differs from the Cleanup Analysis](#departures)
- [Phase Kinds](#phase-kinds)
- [Build Phases](#build-phases)
  - [Phase 1: Publish the Linear plugin to the second channel](#phase-1)
  - [Phase 2: Label every tracker's marks and close the silent gap](#phase-2)
  - [Phase 3: Unfreeze the second channel's version numbers](#phase-3)
  - [Phase 4: Remove the untrue dependency declarations](#phase-4)
  - [Phase 5: Declare the plugin versions that work together](#phase-5)
  - [Phase 6: Teach the release process about all four publishing surfaces](#phase-6)
  - [Phase 7: Turn on the automated completeness check](#phase-7)
  - [Phase 8 (Deferred): Consolidate the duplicated rule documents](#phase-8)
- [Open Questions](#open-questions)
  - [OQ-1 (resolved): How far does the ticket-file fix go in Phase 2?](#oq-1)
  - [OQ-2 (resolved): Should plugins declare which versions of each other they work with?](#oq-2)
  - [OQ-3 (resolved): Does the format-checking step really catch a mismatched ticket file?](#oq-3)

---

## Executive Summary {#executive-summary}

**The goal:** Every Han plugin is published, current, and honestly described on both of the channels people install it
from. An automated check makes it impossible to quietly break that again.

Han ships through two install channels. Following the source artifact, this document calls them the first channel and
the second channel. The first channel is healthy; the second channel is the one that has been quietly rotting, and it
is where most of this cleanup lands.

**The shape of the build (plain language):**

- Phases 1 through 3 repair what users hit today: a plugin that is advertised but missing, work items that vanish from
  a publishing run or get mistakenly skipped, and version numbers so stale that nobody is ever offered an update.
- Phases 4 and 5 make the declarations honest and complete: the dependency claims that are not true are removed (two
  named by the source, a third found in Phase 4's review), and every plugin then states which versions of its
  companions it works with.
- Phase 6 teaches the release process to start from what is really in the repository and to update all four publishing
  surfaces instead of two.
- Phase 7 turns on the automated check that keeps every earlier fix fixed. It comes last on purpose.
- One piece of work is deferred: consolidating the duplicated rule documents, with a named trigger for reopening it.

**Sequencing rationale, in plain language:**

The order comes from the source artifact, and the source is explicit that it is not negotiable. The user-facing harms
come first because someone following the documented instructions hits an error today.

The record cleanup and the release-process fix come next because the automated check depends on them. If the check were
turned on first, it would fail on almost every plugin from day one, someone would disable it, and it would protect
nothing. Fixed first, then guarded: that is the whole sequencing argument.

**Departures from the source artifact:**

- The source's fifth fix, correcting two documents that describe a behavior the system does not have, is dropped: the
  source never names the documents, so the work cannot be picked up.
- Version compatibility between plugins, which the source left as an open question with no proposed fix, is now
  committed work: Phase 5 has every plugin state which versions of its companions it works with.
- The ticket-file fix is built at full width: all three tracker publishers label their marks, not only the GitHub
  repair the source's ordered list named.

The [departures section](#departures) explains each one.

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
| 2   | [Label every tracker's marks and close the silent gap](#phase-2)                       | Feature slice | No publisher can lose or mistakenly skip another tracker's work items.       |
| 3   | [Unfreeze the second channel's version numbers](#phase-3)                              | Feature slice | People on the second channel are offered updates again.                      |
| 4   | [Remove the untrue dependency declarations](#phase-4)                                  | Feature slice | Installing Reporting, Feedback, or Linear no longer drags in a plugin they never use. |
| 5   | [Declare the plugin versions that work together](#phase-5)                             | Feature slice | Every plugin states which versions of its companions it works with.          |
| 6   | [Teach the release process about all four publishing surfaces](#phase-6)               | Feature slice | A release starts from the repository and updates all four surfaces.          |
| 7   | [Turn on the automated completeness check](#phase-7)                                   | Feature slice | Every release and change is blocked if any plugin is missing anywhere.       |
| 8   | [Consolidate the duplicated rule documents (deferred)](#phase-8)                       | Deferred      | Three plugins share one copy of each rule instead of hand-synced copies.     |

> Numbers are assigned in build order and are stable for the life of this outline. Cite them as `Phase N` in tickets,
> comments, and follow-up reports.

---

## How This Build Differs from the Cleanup Analysis {#departures}

The build deliberately departs from [source-han-cleanup-plan.md](./source-han-cleanup-plan.md) in three ways, decided
on 2026-07-21. Each departure is summarized once here so the rest of the document can refer to it by name.

### 1. The document-correction fix is dropped

The source's fifth ordered fix corrects two documents that describe a behavior the system does not have. The source
names the count and the harm but never the documents themselves, so there is no detail to work from. Rather than carry
an unworkable phase, this build drops it. If the underlying analysis ever surfaces which two documents were meant, the
fix comes back as its own small piece of work.

### 2. Version declarations are promoted from open question to committed work

The source deliberately proposed no fix for version compatibility between plugins, holding that the right answer needs
a real decision. That decision has now been made: every plugin will state explicitly which versions of its companions
it works with. The work lands as [Phase 5](#phase-5), immediately after the dependency declarations are made truthful
in [Phase 4](#phase-4).

### 3. The ticket-file fix is built at full width

The source's ordered list committed only to repairing the GitHub publisher's silent gap, while its prose named the
fuller fix: make every publisher's marks say which tracker they came from. This build adopts the fuller fix in
[Phase 2](#phase-2), so all three publishers change together and old-format files get an upgrade path that stops and
asks rather than guesses.

---

## Phase Kinds {#phase-kinds}

Every phase is tagged with one of four kinds. The taxonomy is used in the Build Phase Index and on each phase entry's
`**Kind.**` line.

- **Foundation:** A capability that does not deliver new user-facing features on its own, but is required for later
  phases. Must still be demoable in its own right (e.g., "an admin can edit and persist a new setting"). No phase in
  this plan uses the Foundation kind.
- **Feature slice:** A thin end-to-end strip of new behavior that a real user can experience.
- **Polish:** Branding, refinement, observability, or quality-of-life work that enriches a working core.
- **Deferred:** Listed for traceability; not built in the current plan. Slotted at the end of the index.

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

### Phase 2: Label every tracker's marks and close the silent gap {#phase-2}

**Kind.** Feature slice.

**Builds on.** Nothing from Phase 1. It holds position 2 because the source ranks the remaining fixes by user harm, and
this is the only one where work silently disappears.

**What we build.** Three plugins publish work items to three different trackers, and all three record what they
published by marking up the same shared file. Today the GitHub publisher can silently lose items marked by another
tracker, and the other two publishers can mistake each other's marks and skip work that was never published to their
tracker. After this phase, every publisher's marks say which tracker they came from, so no publisher can misread
another's, and every work item in any publishing run is accounted for: published, skipped with a count, or reported as
belonging to another tracker. Files marked up in the old format get an upgrade path that stops and asks rather than
guesses. This is the full fix chosen in [OQ-1](#oq-1) and named as [departure 3](#departures).

**Why this is Phase 2.** Silent data loss outranks every remaining problem: the other two tracker publishers at least
report a skipped count that an attentive person would notice, while the GitHub one leaves no trace at all. The source
calls it "the one worth fixing first" among the ticket-file problems. It depends on nothing else in this plan.

**Outcome to demonstrate.**

1. Take a work-items file that another tracker's publisher has already marked up.
2. Run the GitHub publisher against it.
3. Every item in the file appears in the run's output: published, skipped, or reported as belonging to another
   tracker, and the run says what to do about the reported ones.
4. Repeat with the other two publishers and confirm neither skips items that were never published to its tracker.
5. Feed in a file marked up in the old format and confirm the run stops and asks instead of guessing.

**Source citations.**

- ["The shared ticket file: a real bug, described more carefully than I first described it"](./source-han-cleanup-plan.md#the-shared-ticket-file-a-real-bug-described-more-carefully-than-i-first-described-it).
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 2.

**Connects to.**

- No later phase depends on it. It is sequenced here purely by severity.

**Preconditions to verify before starting.**

- Run the safety-net trial from [OQ-3](#oq-3): feed a mismatched file through the GitHub publisher in a throwaway
  project and confirm the run stops at its checking step, so this phase starts from tested facts about today's
  behavior.
- Confirm no known user files in the old mark format would be stranded by the upgrade path's stop-and-ask behavior.

---

### Phase 3: Unfreeze the second channel's version numbers {#phase-3}

**Kind.** Feature slice.

**Builds on.** Nothing from earlier phases. It holds position 3 in the source's harm-first ordering.

**What we build.** The second channel decides whether an update is available by reading a version number. That number
has not moved since the day it was written, so it never offers anyone an update. This phase corrects every frozen version
number on that channel to match the versions that shipped, so people stuck on old copies start being offered
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

### Phase 4: Remove the untrue dependency declarations {#phase-4}

**Kind.** Feature slice.

**Builds on.** Nothing from earlier phases. The user-facing repairs come first; this begins the record cleanup.

**What we build.** Two plugins, Reporting and Feedback, declare that they need the Core plugin and never touch it.
Reporting's declaration is a leftover from a capability that moved to the Communication plugin; Feedback's cannot be
true because that plugin is not permitted to call other plugins at all. This phase deletes both declarations, plus a
third found during this phase's own review: the Linear plugin's declaration on the Core plugin fails the same
evidence test, and the team chose on 2026-07-21 to remove it in the same pass. Three lines removed, nothing added,
and every documentation surface repeating the claims is corrected in the same change.

**Why this is Phase 4.** The direct cost is small: people installing either plugin quietly get a large plugin they
never use. The real damage is to trust in the declarations as a whole, since nobody can rely on them to answer "what
breaks if I change this?" while two of them are decorative. It lands after the user-facing repairs because nobody hits
an error from it, and immediately before Phase 5, which adds version statements to the declarations this phase makes
truthful.

**Outcome to demonstrate.**

1. On a clean machine, install the Reporting plugin.
2. Confirm the Core plugin is not pulled in alongside it.
3. Run a Reporting skill end to end and confirm it still works, including its writing pass.
4. Repeat steps 1 through 3 for the Feedback plugin and the Linear plugin.

**Source citations.**

- ["The dependency graph: two threads to snip"](./source-han-cleanup-plan.md#the-dependency-graph-two-threads-to-snip).
- ["What I would do, in order"](./source-han-cleanup-plan.md#what-i-would-do-in-order), item 4.

**Connects to.**

- [Phase 5](#phase-5): version statements are added on top of the declarations this phase makes truthful.

**Preconditions to verify before starting.**

- Re-confirm none of the three plugins reaches the Core plugin through any path the analysis did not cover, so
  removing the declarations cannot break a working flow.

---

### Phase 5: Declare the plugin versions that work together {#phase-5}

**Kind.** Feature slice.

**Builds on.** Phase 4: version statements are only worth adding to declarations that are true.

**What we build.** Every plugin states explicitly which versions of the other plugins it works with. Today plugins are
installed and updated one at a time, so someone can update one plugin while running a months-old copy of another, and
nothing anywhere notices or complains. After this phase, each plugin's requirements are written down where the person
installing it can see them. This work is [departure 2](#departures): the source left the question open, and the team
decided it on 2026-07-21.

**Why this is Phase 5.** It follows directly from Phase 4: first the dependency declarations are made truthful, then
each one gains a version statement, so the record is corrected once rather than twice. It lands before the release
process work because Phase 6 is where the statements start being kept current as new versions ship.

**Outcome to demonstrate.**

1. Open any plugin's listing and see which versions of its companion plugins it states it works with.
2. On a clean machine, install that plugin and confirm compatible companions arrive with it.
3. Set up a machine with an out-of-date companion and confirm the mismatch is surfaced instead of silently accepted.

**Source citations.**

- ["Two places the reviewer changed my mind entirely"](./source-han-cleanup-plan.md#two-places-the-reviewer-changed-my-mind-entirely),
  the "On version compatibility between plugins" finding.
- ["How much of this to trust"](./source-han-cleanup-plan.md#how-much-of-this-to-trust), the caveat that this finding
  rests on the project's description of how installation works.

**Connects to.**

- [Phase 6](#phase-6): the release process keeps these version statements current as new versions ship.

**Preconditions to verify before starting.**

- Confirm whether the install channels read and enforce version statements. If they do not, decide whether the
  statements start as visible information for people until the channels can act on them.
- Decide how strict the statements are: an exact version, a minimum version, or a range.

---

### Phase 6: Teach the release process about all four publishing surfaces {#phase-6}

**Kind.** Feature slice.

**Builds on.** Phases 1 and 3 in practice: teaching the release process to see the second channel is far simpler when
that channel's contents are already correct. It also picks up upkeep of the version statements Phase 5 introduces.

**What we build.** Today the release process updates two publishing surfaces and does not know the other two exist,
which is why roughly twenty releases went by without anyone noticing the rot. After this phase the release process
starts from the plugins as they exist in the repository, rather than trusting a list that can go stale, and
updates all four surfaces. It keeps the companion version statements from Phase 5 current as new versions ship. It
also knows the one deliberate exception permanently: the all-in-one bundle cannot be published to the second channel
because that channel does not support bundles yet.

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

- This is the final phase. It guards the outcomes of [Phase 1](#phase-1), [Phase 3](#phase-3), and
  [Phase 6](#phase-6) from regressing. Phase 7's spec review corrected an earlier claim here: the check does not
  examine dependency declarations, so [Phase 4](#phase-4)'s outcome is not among its guards.

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

> All three questions raised while shaping this plan were resolved on 2026-07-21. The decisions are recorded here, with
> their original anchors, so citations of `OQ-N` in tickets and threads still resolve.

### OQ-1 (resolved). How far does the ticket-file fix go in Phase 2? {#oq-1}

**Blocked phase(s).** Phase 2. **Decision: the full fix.**

The source described two related problems with the shared ticket file: the GitHub publisher silently drops items
marked by another tracker, and the other two publishers can mistake each other's marks and skip work that was never
published to their tracker. The choice was between the fix the source itself named, making every publisher's marks say
which tracker they came from, and a smaller change that only stopped the GitHub publisher's silent loss.

The team chose the full fix. All three publishers label their marks, and files marked up the old way get an upgrade
path that stops and asks rather than guesses. The decision is folded into [Phase 2](#phase-2) and recorded as
[departure 3](#departures).

### OQ-2 (resolved). Should plugins declare which versions of each other they work with? {#oq-2}

**Blocked phase(s).** None when raised. **Decision: yes, explicitly.**

The source reversed the earlier analysis that closed this question: plugins are installed and updated one at a time,
so someone can update the Core plugin today while running a months-old Coding plugin, and nothing anywhere notices or
complains. The source deliberately proposed no fix because the right one is not obvious.

The team decided that all plugins should state which versions of each other they depend on, explicitly. The work lands
as [Phase 5](#phase-5) and is recorded as [departure 2](#departures). The open sub-questions, whether the install
channels enforce the statements and how strict each statement is, live on Phase 5's preconditions list.

### OQ-3 (resolved). Does the format-checking step really catch a mismatched ticket file? {#oq-3}

**Blocked phase(s).** None when raised. **Decision: test it right away, before the phases start.**

The source's reviewer could not confirm that the step meant to catch a mismatched ticket file works in practice,
believing it rested on in-the-moment judgment rather than anything written down. A first inspection after the decision
found the rule is written down after all: the GitHub publisher's instructions explicitly say a file carrying another
tracker's marks must stop the run and be reported to the user, never repaired, because repairing it would publish
duplicates.

What remains untested is whether a live run follows that instruction. The remaining trial, feeding a mismatched file
through the GitHub publisher in a throwaway project, is now the first precondition on [Phase 2](#phase-2). If the run
stops as written, the note closes; if not, the gap becomes part of Phase 2's fix.

---

_End of outline. If you need to cite a specific phase elsewhere, use its `Phase N` number: those numbers are stable
for the life of this document. If you need to cite a specific open question, use its `OQ-N` ID._

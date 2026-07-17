---
title: "Han Publishing Cleanup — Build Phase Outline"
source_artifact: "feature-specification.md"
audience: "Engineering — Han maintainers and contributors"
generated: "2026-07-17"
generated_by: "han-planning:plan-a-phased-build"
---

# Han Publishing Cleanup — Build Phase Outline

This document describes the order in which the Han publishing cleanup will be built. The work is broken into a sequence
of **phases**, where each phase is a thin end-to-end deliverable that can be demonstrated to a real person, and each
phase builds on the one before it. The cleanup repairs how Han is published to the two places it ships to, so that
everything advertised as installable actually installs, everyone who installed it is offered updates again, and no
future release can quietly stop either being true.

This document is the companion to [feature-specification.md](feature-specification.md). The source artifact describes
_what is broken today, what each of its seven steps changes, and why they are ordered the way they are_. This document
describes _the order in which the work will be built, and what you can put in front of a person at the end of each
phase_. Every phase below cites the source-artifact sections it covers, so anyone can trace a phase back to source.

## Table of Contents

- [Vocabulary](#vocabulary)
- [Executive Summary](#executive-summary)
- [Build Phase Index](#build-phase-index)
- [Phase Kinds](#phase-kinds)
- [Build Phases](#build-phases)
  - [Phase 1: Make the Linear plugin installable on channel two](#phase-1)
  - [Phase 2: Stop the work-items publisher dropping work silently](#phase-2)
  - [Phase 3: Make a release bring every publishing target up to date](#phase-3)
  - [Phase 4: Unfreeze channel two's version numbers](#phase-4)
  - [Phase 5: Delete the untrue dependencies and correct what described them](#phase-5)
  - [Phase 6: Show the gap on the pull request that introduces it](#phase-6)
- [Open Questions](#open-questions)

---

## Vocabulary {#vocabulary}

The source artifact stays deliberately neutral about which storefront is which, and this document inherits that. Four
words carry the whole outline.

- **Channel one** and **channel two** — the two places Han is published. Channel one is healthy; nothing here changes
  what it publishes. Channel two is the one that has been rotting.
- **A storefront listing** — the per-channel catalogue saying which plugins exist. One per channel.
- **A version record** — a place that states a plugin's published version. There are three: each channel carries one per
  plugin, and channel one's listing also carries a version per plugin.
- **A target** — any of the four places a release must keep current: the two storefront listings and the two per-plugin
  records.
- **The bundle** — the meta-plugin that installs the suite in one command. It exists on channel one only.

The full grounding, including what each target carries besides a version, is in the source artifact's
[Channels and targets](feature-specification.md#channels-and-targets).

---

## Executive Summary {#executive-summary}

**The goal:** Han is published completely and honestly to both of the places it ships to, and no release can quietly
stop it being so. Concretely: every plugin advertised as installable on a channel actually installs there, people who
installed Han on channel two are offered updates again, every dependency a plugin declares is one it really uses, every
document describing the suite describes the suite that exists, and every release brings all four publishing targets up
to date rather than two of them.

**The shape of the build:**

- **Phases 1 and 2 fix two live, independent breakages** — a documented install command that errors today, and a
  work-items publisher that drops work with no signal. Neither waits on anything.
- **Phase 3 is the hinge.** It teaches the release to derive its plugin list from the repository rather than from a file
  it also writes, to bring all four targets up to date, and to refuse rather than guess when it meets a gap only a person
  can close. Everything after it is either made durable by it or made honest by it.
- **Phase 4 unfreezes the version numbers by hand**, and it is durable only because phase 3 already landed. A release cut
  before phase 3 would have re-frozen them.
- **Phase 5 removes three dependency declarations that were never true, and corrects every document that narrated them,
  in a single change.** Shipping half of that pair is the exact state the phase exists to prevent.
- **Phase 6 puts the answer in front of a contributor** on the pull request that introduces a gap, rather than in front
  of a maintainer on release day. It lands last, and it lands green.

**Sequencing rationale:** Four constraints bind, and the rest of the order is free. The check goes last, because a
signal that is red from birth is a signal people learn to scroll past. Phase 1 precedes phase 3, because a repaired
release meeting a plugin whose storefront presence nobody has written refuses to proceed — so shipping phase 3 first
would stop every release until someone did phase 1 under release pressure. Phase 3 precedes phase 4, so the correction
is durable rather than something the next release undoes. Phases 5 and 6 of the source are one change, which is this
document's phase 5. The work-items fix shares no actor, artifact, or failure mode with any of it, and sits at position 2
because that is where the source put it and nothing argues for moving it.

**Phases deliberately deferred:** None are added here. The source artifact already carries six deferrals under
[Deferred (YAGNI)](feature-specification.md#deferred-yagni), each with the trigger that would reopen it, and re-listing
them as phases would create a second place to maintain the same decisions. That section is canonical; this outline does
not restate it.

**Where to look next:** The [Build Phase Index](#build-phase-index) lists every phase in order. Detailed write-ups
follow under [Build Phases](#build-phases). Decisions the team still owes itself are at [Open Questions](#open-questions)
— none of them blocks phase 1 from starting.

---

## Build Phase Index {#build-phase-index}

> The scan view. One row per phase, in build order. Each "Outcome" cell is one short sentence. Detailed write-ups follow
> under [Build Phases](#build-phases); use the link in the Phase column.

| #   | Phase                                                                    | Kind          | Outcome (one sentence)                                                           |
| --- | ------------------------------------------------------------------------ | ------------- | -------------------------------------------------------------------------------- |
| 1   | [Make the Linear plugin installable on channel two](#phase-1)            | Feature slice | The documented install command for the Linear plugin succeeds instead of erroring. |
| 2   | [Stop the work-items publisher dropping work silently](#phase-2)         | Feature slice | Every work item in a file is published, skipped-and-counted, or surfaced.          |
| 3   | [Make a release bring every publishing target up to date](#phase-3)      | Feature slice | A release repairs all four targets, reports what it changed, and refuses real gaps. |
| 4   | [Unfreeze channel two's version numbers](#phase-4)                       | Feature slice | Channel two publishes each plugin's real version, so updates are offered again.    |
| 5   | [Delete the untrue dependencies and correct what described them](#phase-5) | Feature slice | Three plugins stop dragging in a plugin they never use, and the docs agree.       |
| 6   | [Show the gap on the pull request that introduces it](#phase-6)          | Polish        | A contributor sees a missing target on their pull request, and it lands green.     |

> Numbers are assigned in build order and are stable for the life of this outline. Cite them as `Phase N` in tickets,
> comments, and follow-up reports. They do not match the source artifact's step numbers — each phase names its source
> step in its write-up.

---

## Phase Kinds {#phase-kinds}

Every phase is tagged with one of four kinds. The taxonomy is used in the Build Phase Index and on each phase entry's
`**Kind.**` line.

- **Foundation** — A capability that does not deliver new user-facing features on its own, but is required for later
  phases. Must still be demoable in its own right.
- **Feature slice** — A thin end-to-end strip of new behavior that a real user can experience.
- **Polish** — Branding, refinement, observability, or quality-of-life work that enriches a working core.
- **Deferred** — Listed for traceability; not built in the current plan. Slotted at the end of the index.

---

## Build Phases {#build-phases}

### Phase 1: Make the Linear plugin installable on channel two {#phase-1}

**Kind.** Feature slice.

**Builds on.** Nothing — this is the starting phase.

**What we build.** The Linear plugin gets its entry in channel two's storefront listing and its own version record on
that channel, created at the version channel one already publishes for it, so it is correct the moment it exists.

A person writes that record, and that is the point rather than an inconvenience. The record is not a version with some
description attached to it — it **is** the plugin's storefront presence: what it is called, how it is described, what
someone would ask it to do. None of that can be derived from anything the repository already holds. This is the same
boundary phase 3's release stops at, met here by the one actor who can cross it.

**Why this is Phase 1.** Two reasons, and the second is the binding one. First, this is the only place where a person
following Han's own published instructions hits an error right now: channel two's setup instructions advertise the Linear
plugin, and it was never published there. Second, and this is easy to miss, phase 3 cannot safely land before it. Once a
release derives its plugins from the repository it sees the Linear plugin, finds no authored presence for it on channel
two, and refuses — so a repository with phase 3 and without phase 1 stops every release until someone writes that
presence by hand, which is this phase performed under release pressure instead of on purpose.

**Outcome to demonstrate.**

1. Run channel two's documented install command for the Linear plugin, as written in Han's own setup instructions, and
   watch it error. This is today.
2. Ship the phase.
3. Run the same command again, unchanged. It succeeds and the plugin installs.
4. Look at what channel two now publishes for the plugin, and see the same version channel one publishes for it — not a
   placeholder, and not a version behind.

If channel two's client resolves from the latest release tag rather than the default branch, step 3 succeeds at the next
release rather than on merge; the demo is the same, the clock is different. See [OQ-1](#oq-1).

**Source citations.**

- [Step 1: Publish the Linear plugin to channel two](feature-specification.md#step-1-publish-the-linear-plugin-to-channel-two) — source position 1.
- [Channels and targets](feature-specification.md#channels-and-targets) — what a listing entry and a record each carry.
- [Outcome](feature-specification.md#outcome) — the install-succeeds promise this phase delivers first.

**Connects to.**

- Unblocks [Phase 3](#phase-3), which refuses to run against a plugin whose presence nobody has written.
- Feeds [Phase 4](#phase-4): the record this phase creates already agrees, so it is not one of the eight gaps phase 4
  closes.
- Creates one instance of the drift [Phase 4](#phase-4) repairs, if a release is cut before [Phase 3](#phase-3) lands.
  Small, named, and healed by the same repair as the rest.

**Preconditions to verify before starting.**

- Confirm which revision channel two's client resolves from — the default branch or the latest release tag. It does not
  change what this phase builds, only when it reaches anyone. See [OQ-1](#oq-1).
- Confirm nobody has written the Linear plugin's channel-two presence somewhere unpublished, so this phase is authoring
  it rather than duplicating it.

---

### Phase 2: Stop the work-items publisher dropping work silently {#phase-2}

**Kind.** Feature slice.

**Builds on.** Nothing. This phase is independent of every other phase in this outline — it shares no actor, no
artifact, and no failure mode with the publishing work, and it is here because the source artifact retained it, not
because anything depends on it.

**What we build.** Today, when the GitHub work-items publisher meets a work item already marked as published by a
different tracker, that item is neither published nor reported as skipped. It vanishes from the run with no error and no
count. After this phase, every work item in a file is accounted for in every run: published, skipped-and-counted, or
surfaced.

Two properties make that promise real rather than circular:

- **The whole file is examined before the first item is published.** A marking the publisher does not recognize, sitting
  near the end of a file, cannot be preceded by items it already created. The run stops before creating anything at all.
- **Every heading the publisher cannot place is covered, not only the ones that look foreign.** The publisher cannot
  tell "another tracker's marking in a shape I don't know" from "a hand-edited line with the wrong kind of dash" until it
  has looked, and both need the same answer. The cheaper answer — publish what you understood, then complain — is the one
  that creates tickets in a file that may already have been published somewhere else.

The protection lives at every layer that inspects a heading, so a foreign marking reaches the stop rather than being
tidied away before it. The marking format itself does not change, and no migration is needed.

**Why this is Phase 2.** Its position is free, and it is here because that is where the source artifact put it. It
blocks nothing and nothing blocks it, so moving it would trade traceability against the source for a tidier narrative
arc. What earns it an early slot rather than a late one is that it is a live defect losing people's work today, on the
same footing as phase 1.

**Outcome to demonstrate.**

1. Take a work-items file and publish it to one tracker, so its items are marked as published there.
2. Point the GitHub publisher at that same file. Today it reports some number published and some number skipped, and the
   marked items are in neither count — they are simply gone, with no error.
3. Ship the phase.
4. Point the GitHub publisher at the same file again. It stops before creating anything, names the specific work items
   whose markings it does not recognize and what they appear to be marked by, and creates nothing.
5. Add the two numbers it reports on an ordinary run to the number it surfaces, and get the number of work items in the
   file. Nothing is unaccounted for.

**Source citations.**

- [Step 2: Close the GitHub publisher's silent hole](feature-specification.md#step-2-close-the-github-publishers-silent-hole) — source position 2.
- [Edge cases and failure modes](feature-specification.md#edge-cases-and-failure-modes) — the work-items rows.
- [User interactions](feature-specification.md#user-interactions) — what a format error names.
- [Out of scope](feature-specification.md#out-of-scope) — marking-namespacing is a separate specification, not this
  phase.

**Connects to.**

- Nothing. This is the outline's one genuinely independent phase, and saying so is more useful than manufacturing a
  connection.

**Preconditions to verify before starting.**

- Confirm the three work-items publishers all read and mark the same file in the way the source artifact assumes, since
  this phase changes only how one of them responds to markings it does not recognize.
- Decide nothing about telling one tracker's markings from another's — that trap is real, is named in the source
  artifact, and is deliberately not this phase's.

---

### Phase 3: Make a release bring every publishing target up to date {#phase-3}

**Kind.** Feature slice.

**Builds on.** [Phase 1](#phase-1). A release repaired by this phase refuses to run against a plugin whose channel-two
presence nobody has written, and that is the Linear plugin's shape until phase 1 lands.

**What we build.** A release today updates two of the four targets, and takes its list of plugins from one of the targets
it also writes. It therefore cannot see that the other two have fallen behind, which is exactly why the drift went
unnoticed across eleven releases. After this phase a release derives the set of plugins from what is really in the
repository, and brings all four targets up to date.

Bringing a target up to date has two halves, and today's release has neither:

- **It corrects a version that has fallen behind**, including for a plugin it did not bump. Today a release writes a
  version only for the plugins it bumps, which is why a record that drifted stays drifted no matter how many releases
  run.
- **It creates a channel-two listing entry that does not exist yet.** Today's release can only write a version onto an
  entry already present, so a plugin absent from a target stays absent forever.

**The release creates what it can derive and stops at what must be authored,** and that line falls in exactly one place.
A channel-two listing entry says a plugin exists, where it lives, and the terms on which it installs — all derivable
from the plugin itself, none of it written prose. A per-plugin record on either channel is a different animal: it **is**
the plugin's storefront presence, so a release that created one would be inventing the prose rather than deriving a
version. This is the boundary phase 1 describes from the other side.

**A release refuses to proceed when it meets a gap it cannot close:** a plugin with no record on a channel it belongs
in; a listing naming a plugin that is not in the repository; a record or listing it cannot read; a version value it
cannot make sense of; a plugin whose publishing version it cannot determine. Every one of them is a person's decision
wearing a release's clothes.

Three more properties come with the phase:

- **The gate runs on the state being released** — after all four targets are brought up to date, and before anything is
  committed, tagged, pushed, or published. When it stops, it names every gap it found rather than the first.
- **Everything the release wrote travels into the commit it tags**, so the state the gate passed is the state that
  ships.
- **A release reports what it created and what it changed** — which plugin, which targets, at what version — alongside
  the version plan it already reports. The whole defect being repaired is that something quietly stopped happening to
  what Han publishes; a repair that quietly starts happening is the same shape wearing better clothes.

The release holds no copy of the rule. It runs the check and reports what the check says. One exception is permanent and
named: the bundle cannot be published to channel two, so on that channel the rule does not flag its absence, does not
ask it to agree with a record it does not have, and **does not create one for it** — it is the one plugin a helpful
release would publish to a channel that cannot install it. That exception stops at channel two; the bundle's two
channel-one records are held to agreement like any other plugin's. This phase also corrects the documents describing the
release procedure, because this phase is what makes them wrong.

**Why this is Phase 3.** It is the hinge, and it lands here rather than earlier or later for two separate reasons. It
cannot come before phase 1, because a repaired release meeting the Linear plugin's unwritten presence refuses rather
than repairs, which stops every release until a person writes it. It must come before phase 4, because the repair is
what makes the correction durable — a version fixed by hand before the release is repaired is a version the next release
re-freezes. Everything downstream either depends on it or is made honest by it.

**Outcome to demonstrate.**

1. Point at a plugin whose channel-two version has fallen behind, and note the number channel two currently publishes for
   it.
2. Delete that plugin's channel-two listing entry, so the repository is in the exact shape a contributor leaves behind
   when they add a plugin and forget a target.
3. Cut a release. Watch it read the plugin list from the repository rather than from a listing, name its version plan,
   and ask for confirmation.
4. Watch it report what it changed and what it created: the stale version corrected, the missing listing entry recreated
   at the version being published, both named explicitly rather than happening quietly.
5. Look at all four targets and see them agree. Look at the commit the release tagged and see all four inside it — the
   state the gate passed is the state that shipped.
6. Now delete a plugin's channel-two record instead, and cut a release again. It stops before committing anything, names
   that gap and every other gap it found in the same run, and publishes nothing. Nothing is tagged and nothing is pushed.
7. Add a fake entry to a listing for a plugin that does not exist in the repository, and cut a release. It stops for that
   too, rather than deciding on its own whether the plugin or the entry is the mistake.

**Source citations.**

- [Step 3: Teach the release process about every target](feature-specification.md#step-3-teach-the-release-process-about-every-target) — source position 6, moved ahead of the version correction.
- [Coordinations](feature-specification.md#coordinations) — the release and the repository, the release and both
  storefronts, the release and the commit it tags, the check and the release.
- [Alternate flows and states](feature-specification.md#alternate-flows-and-states) — what a release does when it meets
  each gap, and what recovery from a stop costs.
- [Edge cases and failure modes](feature-specification.md#edge-cases-and-failure-modes) — the bundle rows, the unreadable
  listing and record rows, the half-finished removal row.

**Connects to.**

- Depends on [Phase 1](#phase-1) having written the Linear plugin's presence.
- Makes [Phase 4](#phase-4)'s hand correction durable rather than something the next release undoes.
- Corrects the contributor guide that makes [Phase 6](#phase-6)'s signal fair — a contributor cannot be told they missed
  a target the guide never named.
- Puts the rule into service four phases before [Phase 6](#phase-6) makes it visible on a pull request, because the
  release runs it from here onward.

**Preconditions to verify before starting.**

- Confirm [Phase 1](#phase-1) has landed on the branch this work builds from. Without it, the first release after this
  phase stops rather than repairs.
- Confirm what a release should do when the operator's approved version plan and a target's repair disagree, since the
  plan is confirmed before the targets are written and the gate cannot run until after.
- Decide who owns re-running a release after a gate stop, given that recovery costs a separate commit: the release's own
  local work is discarded first, then the gap is corrected and committed on its own, then the release is planned from
  scratch.

---

### Phase 4: Unfreeze channel two's version numbers {#phase-4}

**Kind.** Feature slice.

**Builds on.** [Phase 3](#phase-3), which is what makes this correction durable rather than something the next release
re-freezes. Also [Phase 1](#phase-1), whose record arrives already agreeing and so is not one of the gaps this phase
closes.

**What we build.** Channel two's published version numbers have not moved since the day they were created. This phase
corrects each of them by hand, so every plugin's channel-two version matches what channel one publishes for that same
plugin. Eight plugins carry a version that has fallen behind, and eight is the whole set.

**Why this is Phase 4.** It comes after the repair rather than before it, and the reason is durability: had it come
first, any release cut before phase 3 would have undone it. It is worth doing by hand at all even though phase 3 makes a
release do it, and the honest reason is not the obvious one. The obvious reason — the numbers are right on merge rather
than whenever someone next cuts a release — is contingent on an unknown. If channel two's client resolves from the
release tag, the only revision anyone resolves is one a release produced, and a release corrects these numbers itself; the
user-facing benefit is then not smaller but nothing, and what survives is that the repository stops publishing numbers it
knows are wrong ([OQ-1](#oq-1)). The reason that does not depend on that unknown is that **this phase is what makes phase
6's check green on the day it arrives.** Without it, and absent a release cut in between, the check lands red against
eight disagreements, and a signal that is red from birth is one people learn to scroll past.

**Outcome to demonstrate.**

1. Line up what channel one publishes for each plugin against what channel two publishes for the same plugin. Eight
   pairs disagree, and channel two's side of each has not moved since the day it was written.
2. Ship the phase.
3. Line them up again. Every pair agrees.
4. Take a client that has Han installed from channel two and check for updates. An update is offered, which is what this
   whole channel has stopped doing — confirming [OQ-2](#oq-2) along the way, since this is the demo that answers it.
5. Cut a release. Watch the numbers stay corrected rather than re-freeze, which is what phase 3 bought.

Step 4 rests on an unverified assumption about how channel two decides an update exists. If it turns out to be wrong,
steps 1 through 3 and 5 still hold and the update claim comes out. See [OQ-2](#oq-2).

**Source citations.**

- [Step 4: Correct the frozen version numbers](feature-specification.md#step-4-correct-the-frozen-version-numbers) — source position 3, moved after the release repair.
- [Outcome](feature-specification.md#outcome) — the update-availability promise, and its hedge.
- [Open items](feature-specification.md#open-items) — items 1 and 2, both of which shape how this phase's benefit is
  worded.

**Connects to.**

- Depends on [Phase 3](#phase-3) for durability, and on [Phase 1](#phase-1) for the ninth pair not existing.
- Makes [Phase 6](#phase-6) green on arrival, which is the reason that does not depend on any unknown.

**Preconditions to verify before starting.**

- Confirm whether channel two decides update availability from the published version number. The correction is worth
  making either way, but the user-facing claim depends on it. See [OQ-2](#oq-2).
- Confirm no release was cut between [Phase 1](#phase-1) and [Phase 3](#phase-3). If one was, the Linear plugin's
  channel-one version moved while its new record stayed put, and this phase closes nine gaps rather than eight.

---

### Phase 5: Delete the untrue dependencies and correct what described them {#phase-5}

**Kind.** Feature slice.

**Builds on.** Nothing in this outline. Its position among the other phases is free; what is not free is that its two
halves ship as one change.

**What we build.** Three plugins declare that they need the core plugin and never touch it. The reporting plugin's use
moved elsewhere and the declaration was left behind. The feedback plugin and the Linear plugin are not permitted to
invoke other plugins at all, so their declarations cannot be true — neither is granted the means to call one. This phase
deletes all three, and in the same change corrects every document that described them.

After it, the reporting plugin declares only what it uses, the feedback and Linear plugins declare nothing, installing
any of them no longer drags in a large plugin the installer will never use, and every remaining declaration in the suite
is one the declaring plugin actually uses.

**The two halves are one change, and that is the whole reason this is one phase.** A merged state where the declarations
are gone and the documents still narrate them is precisely the state the document correction exists to prevent. Nothing
in the repository enforces that they land together, so it is a commitment about how the work ships rather than a property
of the work.

The documents in scope are decided by a rule, not a list: **a document is in scope when this work falsifies it.** Not
"mentions a plugin", not "narrates topology", not "sits nearby". That reaches the contributor guide, the orientation
document new readers are told to read first, the canonical long-form docs for the affected plugins, the plugin-selection
guide, the agent-facing project map, and the tutorial that teaches plugin dependencies. Two refinements matter:

- **A document making a universal claim about the dependency graph states the rule and points at the manifests as the
  record.** That remedy stops at universal claims, because no rule generates this suite's graph — it is irregular on
  purpose. A document whose job is to orient a reader legitimately enumerates it, so those documents keep the
  enumeration, drop any hardcoded count, and name the manifests as the record.
- **An already-false statement inside a passage this work rewrites is corrected; one elsewhere is not.** A passage is
  the paragraph. That boundary is what keeps the rule from collapsing into either uselessness or an open-ended audit.

The tutorial that teaches dependencies by walking through the deleted edges has its worked example repointed at edges
that remain real. The replacement must be an edge this work leaves standing **and** one that is actually true — the
plugin the rewrite originally planned to point at turned out to carry the third untrue declaration, so repointing there
would have taught the lesson using a counter-example to itself.

**Why this is Phase 5.** Its position is free and it lands here because nothing argues for it landing earlier. It does
not block the publishing repair, and the publishing repair does not block it. What matters is that it precedes
[Phase 6](#phase-6) only incidentally — the check does not inspect dependency declarations or documents at all, so this
phase is not what makes the check green. One dependency of a different kind is real: the survey behind the document half
originally ran against a two-plugin premise and must be re-run against the third declaration, which is the same rule
applied to a corrected set rather than a change to the rule.

**Outcome to demonstrate.**

1. Install the reporting plugin on its own, and watch the core plugin arrive with it, unasked for and unused.
2. Ship the phase.
3. Install the reporting plugin again. The core plugin does not come with it, and the reporting plugin still works.
4. Do the same with the feedback plugin and the Linear plugin. Neither drags anything in, and both still work.
5. Open the contributor guide, the orientation document, the plugin-selection guide, and the agent-facing project map,
   and find no description of a dependency the suite does not have — and no hardcoded count where an enumeration used to
   claim one.
6. Read the dependency tutorial end to end. Its worked example walks an edge that still exists and is actually true, and
   it no longer promises to print real version numbers.

**Source citations.**

- [Step 5: Delete the three untrue dependency declarations](feature-specification.md#step-5-delete-the-three-untrue-dependency-declarations) — source position 4.
- [Step 6: Correct every document the declaration deletion falsifies](feature-specification.md#step-6-correct-every-document-the-declaration-deletion-falsifies) — source position 5, shipped with step 5.
- [Coordinations](feature-specification.md#coordinations) — step 5 and step 6 as a single change.
- [Deferred (YAGNI)](feature-specification.md#deferred-yagni) — a standing check for decorative dependencies is
  deliberately not built here.

**Connects to.**

- Independent of [Phase 3](#phase-3) and [Phase 4](#phase-4): a release repairs targets and does not inspect
  declarations.
- Not a precondition for [Phase 6](#phase-6). The check does not look at dependency declarations, so this phase neither
  reddens nor greens it.
- Documents the release procedure falsifies are [Phase 3](#phase-3)'s, not this phase's. Each step owns the documents it
  breaks.

**Preconditions to verify before starting.**

- Re-run the document survey against all three declarations rather than the two the original survey assumed. The rule
  already reaches the extra locations; the list from the earlier pass does not.
- Confirm the replacement edge for the tutorial's worked example is both surviving and true, since the obvious candidate
  was one of the three being deleted.
- Agree that the two halves ship in a single change, because nothing in the repository enforces it.

---

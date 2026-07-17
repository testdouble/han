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

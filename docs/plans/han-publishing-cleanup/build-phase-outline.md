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

---

## Executive Summary {#executive-summary}

**The goal:** Every Han plugin is published, current, and honestly described on both of the channels people install it
from, and an automated check makes it impossible to quietly break that again.

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
  phases. Must still be demoable in its own right (e.g., "an admin can edit and persist a new setting").
- **Feature slice** — A thin end-to-end strip of new behavior that a real user can experience.
- **Polish** — Branding, refinement, observability, or quality-of-life work that enriches a working core.
- **Deferred** — Listed for traceability; not built in the current plan. Slotted at the end of the index.

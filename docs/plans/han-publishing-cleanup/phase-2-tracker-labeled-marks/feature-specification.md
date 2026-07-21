# Feature Specification: Label Every Tracker's Marks and Close the Silent Gap

All three work-item publishers record tracker-identifying marks in the one shared work-items file, so no publisher can
mistake another tracker's published work for its own, and no work item can leave a publishing run unaccounted for.

## Outcome

A person can publish the same work-items file to any of the three trackers, in any order, and every slice in the file
is accounted for on every run. Each publisher writes marks that name their tracker, and the shared file becomes the
complete publishing record for all three trackers, including the GitHub publisher, which today records its marks only
in derived copies ([D6](artifacts/decision-log.md#d6-one-shared-publishing-record)). Every run classifies all marks
before creating anything and tells the person what it published, what it skipped, and what belongs to another tracker
([D2](artifacts/decision-log.md#d2-full-fix-scope)). Files marked before this phase shipped get a migration path that
asks rather than guesses ([D4](artifacts/decision-log.md#d4-migration-behavior)).

## Actors and Triggers

- **Actors** — A person running any of the three work-item publishers (GitHub, Jira, or Linear) against a shared
  work-items file.
- **Triggers** — The person invokes a publisher skill against a work-items file. The file may be unpublished, already
  published to this tracker, already published to another tracker, marked in the format that predates this phase, or
  any mix.
- **Preconditions** — The work-items file exists in the format the planning skill produces. Two checks run before this
  phase starts. First, the safety-net trial from the outline's resolved open question: feed a file marked by another
  tracker through the GitHub publisher in a throwaway project and record whether the run stops at its checking step as
  its instructions say ([OI-1](#open-items)). Second, confirm no known user files in the old mark format would be
  stranded by the migration path's ask-first behavior ([OI-2](#open-items)).

## Primary Flow

1. The person runs a publisher against a work-items file.
2. The publisher classifies every slice's mark before creating anything: no mark, its own labeled mark, an old-format
   mark, another tracker's labeled mark, or a mark it cannot recognize
   ([D3](artifacts/decision-log.md#d3-mark-recognition-taxonomy)).
3. If classification finds anything other than "no mark" and "its own labeled mark", the run pauses and presents the
   full picture in one place: what would publish, what is already published here, what belongs to another tracker,
   what is ambiguous or unrecognized, each with the raw mark text so the person can double-check. The person answers
   once: publish only the unmarked slices, also publish another tracker's slices here, or stop. Nothing is created
   before the answer ([D7](artifacts/decision-log.md#d7-pause-and-ask)).
4. Slices approved for publishing are created on this tracker, and each published slice's heading in the shared file
   gains a mark naming this tracker ([D6](artifacts/decision-log.md#d6-one-shared-publishing-record)).
5. Slices with this tracker's own labeled mark are skipped, and the skip count is reported, preserving each
   publisher's resume-on-re-run behavior.
6. The run's closing report accounts for every slice in the file by category: published, skipped as already published
   here, another tracker's, or upgraded from the old format ([D5](artifacts/decision-log.md#trivial-decisions)).

## Alternate Flows and States

### First run against a file published before this phase shipped

Every file published before this phase carries old-format marks, so this flow is the expected first encounter for
existing files, not a rarity.

- **Entry condition:** The file carries marks in the old, unlabeled format.
- **Sequence:** Old marks whose shape identifies their tracker without doubt are upgraded in place to the labeled
  format by whichever publisher meets them, and the run reports each upgrade; naming the owner outright is not
  guessing ([D4](artifacts/decision-log.md#d4-migration-behavior)). Old marks whose shape could belong to more than
  one tracker are held for the pause-and-ask step: the publisher shows each ambiguous mark's raw text and asks the
  person which tracker owns it. The classification is asymmetric by nature: only the tracker whose old shape is unique
  can be identified without asking, and the two trackers whose old shapes are identical always require the ask.
- **Exit:** Every mark in the file is in the labeled format, and the run proceeds with the primary flow's
  classification.

### A mark the publisher cannot recognize

- **Entry condition:** A slice heading carries an annotation that matches no known mark shape, current or old.
- **Sequence:** The publisher treats it exactly like another tracker's mark: never repaired automatically, shown to
  the person with the annotation text it found, and excluded from publishing until the person decides. When the
  annotation is a near-miss of a known shape, the report proposes the manual correction, but never applies it
  ([D3](artifacts/decision-log.md#d3-mark-recognition-taxonomy)).
- **Exit:** The person resolves the annotation; the run never guesses.

### Publishing succeeds but marking fails

This protection exists today only in the Linear publisher; this phase makes it a required behavior of all three
([D9](artifacts/decision-log.md#trivial-decisions)).

- **Entry condition:** A tracker accepts a new item, but writing the mark back to the shared file fails.
- **Sequence:** The run stops immediately and reports the orphaned tracker item so the person can mark the heading by
  hand or delete the item. It does not continue creating items.
- **Exit:** The person reconciles the file with the tracker before re-running.

## Edge Cases and Failure Modes

| Condition                                                                    | Required Behavior                                                                                                        |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| The file carries marks from two or three different trackers at once           | Each mark is classified by its named tracker; the pause presents them grouped per tracker; nothing is dropped.            |
| The same file is published to a second tracker on purpose                     | The pause step's explicit go-ahead publishes the other tracker's slices here as well; without it, they are left alone.    |
| A file mixes old-format and labeled marks                                     | Migration runs first, so classification always operates on labeled marks only.                                            |
| An old mark's key text collides with a tracker's name or another tracker's key | The mark is treated as ambiguous and held for the ask; text that could read two ways is never classified on shape alone ([D4](artifacts/decision-log.md#d4-migration-behavior)). |
| A slice's dependency points at a slice published to a different tracker       | The dependency-linking pass skips that one relation and reports it; it never fails the run and never drops the relation silently ([D10](artifacts/decision-log.md#trivial-decisions)). |
| A re-run after a partial failure                                              | Already-marked slices are skipped with a count; approved unmarked slices publish; the file ends consistent with the tracker. |
| The person cannot say which tracker owns an ambiguous mark                    | That slice stays unresolved and unpublished; the publisher never assigns a tracker by guess.                              |

## Coordinations

| Coordinating System                      | Direction | Interaction                                                          | Ordering / Consistency Requirement                                               |
| ---------------------------------------- | --------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| The shared work-items file               | both      | Carries the complete publishing record all three publishers read and write | The mark format is one contract shared by all three publishers; they change together ([D2](artifacts/decision-log.md#d2-full-fix-scope), [D6](artifacts/decision-log.md#d6-one-shared-publishing-record)). |
| The three tracker services               | outbound  | Receive published work items                                         | An item is created before its mark is written; a failed mark stops the run.        |
| The planning skill that writes the file  | inbound   | Produces unmarked slices in the agreed heading shape                 | Unmarked headings remain valid input to every publisher, unchanged.                |

## Out of Scope

- Changing the planning skill's authoring format. Unmarked slice headings stay exactly as they are today.
- Changing what any publisher sends to its tracker: titles, bodies, and dependency links within one tracker are
  untouched.
- Detecting a mark that was deleted by hand or lost in a merge. A slice whose mark disappears looks unpublished, and
  the next run will create a duplicate; this is a named, accepted limitation of a file-carried record.
- Detecting duplicates created by two people publishing diverged copies of the same file and merging afterward. Also a
  named, accepted limitation.
- Verifying at classification time that a marked item still exists on its tracker. A mark pointing at a deleted
  tracker item keeps its slice skipped; only the dependency-linking pass checks liveness today, and that stays as it
  is. Named, accepted limitation.
- The publishing-channel work of the other phases: the Linear listing (Phase 1), version numbers (Phase 3), the
  release process (Phase 6), and the automated check (Phase 7).

## Open Items

- **OI-1:** The pre-start safety-net trial. The GitHub publisher's written instructions say a file carrying another
  tracker's marks must stop the run and be reported, while the source analysis observed those slices vanishing
  silently. The trial settles which is true today. If the trial shows the publisher already stops as written, this
  phase's scope shrinks to tracker labeling, the unified shared-file record, and migration; the target behavior in
  this spec stays the same either way.
  - **Resolves when:** The trial runs in a throwaway project, per the outline's resolved open question OQ-3.
  - **Blocks implementation:** No.
- **OI-2:** Confirm no known user files in the old mark format would be stranded by the migration path's ask-first
  behavior. Files annotated by earlier releases are believed to exist only in users' own repositories, where they
  cannot be inspected from here, so this resolves by choice of default rather than by census.
  - **Resolves when:** The team accepts the ask-first default as the protection for unknown files, or evidence of a
    stranded file arrives.
  - **Blocks implementation:** No — asking is the safe default for exactly the files that cannot be counted.

## Summary

- **Outcome delivered:** One shared file records all three trackers' publishing, marks name their tracker, every run
  classifies before creating and accounts for every slice, and old files migrate by asking.
- **Primary actors:** A person running any of the three work-item publishers.
- **Decisions settled by evidence:** 6 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 4 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, edge-case-explorer, gap-analyzer — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the shared-file record was unified across all three publishers after review showed
  the GitHub publisher never marks the shared file today; the foreign-mark response became a single pause-and-ask
  step; migration was reframed as the expected first encounter for every existing published file; three
  file-carried-record limitations were named and accepted. — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 2

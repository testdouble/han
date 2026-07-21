# Feature Specification: Label Every Tracker's Marks and Close the Silent Gap

All three work-item publishers mark the shared work-items file with tracker-identifying marks, so no publisher can
mistake another tracker's published work for its own, and no work item can vanish from a publishing run without a
trace.

## Outcome

A person can publish the same work-items file to any of the three trackers, in any order, and every slice in the file
is accounted for on every run. Each publisher writes marks that name their tracker, recognizes its own marks and every
other tracker's marks as distinct things, and tells the person exactly what it published, what it skipped, and what
belongs to another tracker ([D2](artifacts/decision-log.md#d2-full-fix-scope)). Files marked up in the old, unlabeled
format get an upgrade path that stops and asks rather than guesses
([D4](artifacts/decision-log.md#d4-migration-behavior)).

## Actors and Triggers

- **Actors** — A person running any of the three work-item publishers (GitHub, Jira, or Linear) against a shared
  work-items file; the file itself, which carries the publishing record between runs.
- **Triggers** — The person invokes a publisher skill against a work-items file. The file may be unpublished, already
  published to this tracker, already published to another tracker, marked in the old format, or any mix.
- **Preconditions** — The work-items file exists in the format the planning skill produces. Before this phase starts,
  the safety-net trial from the outline's resolved open question runs: feed a file marked by another tracker through
  the GitHub publisher in a throwaway project and record whether the run stops at its checking step as its
  instructions say ([D3](artifacts/decision-log.md#d3-mark-recognition-taxonomy)).

## Primary Flow

1. The person runs a publisher against a work-items file.
2. The publisher classifies every slice's mark before creating anything: no mark, its own current mark, its own
   old-format mark, another tracker's mark, or a mark it cannot recognize
   ([D3](artifacts/decision-log.md#d3-mark-recognition-taxonomy)).
3. Slices with no mark are published to this tracker, and each published slice's heading gains a mark naming this
   tracker ([D2](artifacts/decision-log.md#d2-full-fix-scope)).
4. Slices with this tracker's own mark are skipped, and the skip count is reported, preserving each publisher's
   existing resume-on-re-run behavior.
5. Slices carrying another tracker's mark are reported as belonging to that tracker: never repaired, never republished,
   and never silently dropped. The run says what it found and asks the person to decide whether those slices should
   also be published to this tracker ([D3](artifacts/decision-log.md#d3-mark-recognition-taxonomy)).
6. The run's closing report accounts for every slice in the file by category: published, skipped as already published
   here, reported as another tracker's, or upgraded from the old format
   ([D5](artifacts/decision-log.md#trivial-decisions)).

## Alternate Flows and States

### Old-format marks found in the file

- **Entry condition:** The file carries marks in the old, unlabeled format from a run made before this phase shipped.
- **Sequence:** Marks whose old shape identifies their tracker without doubt are upgraded in place to the labeled
  format, and the run reports each upgrade. Marks whose old shape could belong to more than one tracker stop the run;
  the publisher names each ambiguous mark and asks the person which tracker it belongs to before anything else
  happens ([D4](artifacts/decision-log.md#d4-migration-behavior)).
- **Exit:** Every mark in the file is in the labeled format, and the run proceeds with the primary flow's
  classification.

### A mark the publisher cannot recognize

- **Entry condition:** A slice heading carries an annotation that matches no known mark shape, current or old.
- **Sequence:** The publisher treats it exactly like another tracker's mark: never repaired, reported to the person
  with the annotation text it found, and excluded from publishing until the person decides
  ([D3](artifacts/decision-log.md#d3-mark-recognition-taxonomy)).
- **Exit:** The person resolves the annotation; the run never guesses.

### Publishing succeeds but marking fails

- **Entry condition:** A tracker accepts a new item, but writing the mark back to the file fails.
- **Sequence:** The run stops immediately and reports the orphaned tracker item so the person can mark the heading by
  hand or delete the item. It does not continue creating items, preserving the existing protection against duplicate
  publication.
- **Exit:** The person reconciles the file with the tracker before re-running.

## Edge Cases and Failure Modes

| Condition                                                                   | Required Behavior                                                                                                       |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| The file carries marks from two or three different trackers at once          | Each mark is classified by its named tracker; the closing report groups slices per tracker; nothing is dropped.          |
| The same file is published to a second tracker on purpose                    | Slices marked by the first tracker are reported, and the person's explicit go-ahead publishes them here as well.         |
| A file mixes old-format and labeled marks                                    | The upgrade path runs first, so classification always operates on labeled marks only.                                    |
| A re-run after a partial failure                                             | Already-marked slices are skipped with a count; unmarked slices publish; the file ends consistent with the tracker.      |
| An ambiguous old-format mark, and the person cannot say which tracker owns it | The run stays stopped for that slice; the publisher never assigns a tracker by guess.                                    |

## Coordinations

| Coordinating System            | Direction | Interaction                                                                  | Ordering / Consistency Requirement                                              |
| ------------------------------ | --------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| The shared work-items file     | both      | Carries the publishing record all three publishers read and write            | The mark format is one contract shared by all three publishers; they change together ([D2](artifacts/decision-log.md#d2-full-fix-scope)). |
| The three tracker services     | outbound  | Receive published work items                                                 | An item is created before its mark is written; a failed mark stops the run.       |
| The planning skill that writes the file | inbound | Produces unmarked slices in the agreed heading shape                 | Unmarked headings remain valid input to every publisher, unchanged.               |

## Out of Scope

- Changing the planning skill's authoring format. Unmarked slice headings stay exactly as they are today.
- Changing what any publisher sends to its tracker: titles, bodies, and dependency links are untouched.
- The publishing-channel work of the other phases: the Linear listing (Phase 1), version numbers (Phase 3), the
  release process (Phase 6), and the automated check (Phase 7).

## Open Items

- **OI-1:** The pre-start safety-net trial. The GitHub publisher's written instructions say a file carrying another
  tracker's marks must stop the run and be reported, while the source analysis observed those slices vanishing
  silently. The trial settles which is true today, and its result shapes how much of the classification behavior is
  new versus already written down.
  - **Resolves when:** The trial runs in a throwaway project, per the outline's resolved open question OQ-3.
  - **Blocks implementation:** No — the target behavior in this spec is the same either way; the trial only changes
    the size of the gap being closed.

## Summary

- **Outcome delivered:** Every publishing run accounts for every slice, marks name their tracker, and old files
  migrate by asking, not guessing.
- **Primary actors:** A person running any of the three work-item publishers.
- **Decisions settled by evidence:** 3 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** — (pending review) — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1

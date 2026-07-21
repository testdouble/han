# Decision Log: Label Every Tracker's Marks and Close the Silent Gap

## Trivial decisions

- D1: Spec location — the spec lives at `docs/plans/han-publishing-cleanup/phase-2-tracker-labeled-marks/`, nested
  beside the build phase outline that spawned it. — Referenced in spec: none (organizational).
- D5: Closing report accounts for every slice by category — published, skipped as already published here, another
  tracker's, or upgraded from the old format (considered keeping each publisher's existing count-only report; rejected
  because the outline's Phase 2 outcome requires every item accounted for, not only a skip count). — Referenced in
  spec: Primary Flow.
- D9: The stop-on-marking-failure protection becomes a required behavior of all three publishers — an item created on
  a tracker whose mark cannot be written stops the run with the orphan reported (generalizes the Linear publisher's
  existing written rule; the GitHub and Jira publishers have no such rule today, so for them this is a new commitment,
  not a preserved one). — Driven by findings: F4. — Referenced in spec: Alternate Flows and States; Coordinations.
- D10: A dependency pointing at a slice published to a different tracker is skipped as a single relation and reported;
  the linking pass never fails the whole run over it and never drops it silently (considered failing the run;
  rejected because one cross-tracker relation would then block every within-tracker link). — Driven by findings: F10.
  — Referenced in spec: Edge Cases and Failure Modes.

## Full decisions

### D2: Full-fix scope

- **Question:** Does this phase adopt tracker-labeled marks across all three publishers, or only close the GitHub
  publisher's silent gap?
- **Decision:** The full fix. All three publishers write marks that name their tracker, and all three change together
  because the mark format is one shared contract on the work-items file.
- **Rationale:** The user resolved this as OQ-1 in the build phase outline on 2026-07-21, choosing the fix the source
  analysis itself named. A GitHub-only change would leave the Jira and Linear publishers able to mistake each other's
  marks and skip work that was never published to their tracker.
- **Evidence:** User input (OQ-1, `../build-phase-outline.md#oq-1`, resolved 2026-07-21). Codebase: the Jira
  publisher's annotation shape (`## <SYM-N> (<KEY>) — <title>`, `han-atlassian/skills/work-items-to-jira/SKILL.md`
  lines 127-128) and the Linear publisher's (`## <SYM-N> (<LINEAR-ID>) — <title>`,
  `han-linear/skills/work-items-to-linear/SKILL.md` lines 117-118) are the same letter-key-number shape and cannot be
  told apart; the GitHub publisher's is `(#NNN)`
  (`han-github/skills/work-items-to-issues/SKILL.md` lines 71-75).
- **Rejected alternatives:**
  - GitHub-only detection fix — rejected by the user in OQ-1 because it leaves the cross-tracker skip trap between the
    other two publishers in place.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D3, D4, D5, D6, D7
- **Referenced in spec:** Outcome; Primary Flow; Coordinations

### D3: Mark-recognition taxonomy

- **Question:** What must a publisher do with each kind of mark it can meet in a file?
- **Decision:** Every slice is classified before anything is created: no mark (publish and mark), own current mark
  (skip and count), own old-format mark (upgrade path), another tracker's mark (report, never repair, never publish
  without the person's explicit go-ahead), unrecognizable mark (treated exactly like another tracker's mark). Nothing
  falls outside these categories, so nothing can vanish from a run.
- **Rationale:** The GitHub publisher already has a written rule that a foreign annotation is "a distinct category from
  a malformed heading and is never repaired" with stop-and-report handling; this decision generalizes that rule to all
  three publishers and makes the unrecognized case explicit, closing the hole where unmatched marks fell through every
  pattern.
- **Evidence:** Codebase: `han-github/skills/work-items-to-issues/SKILL.md` lines 73-75 and 93-100 (the
  never-repaired, stop-and-report rule and the note that an unparseable heading "may be another tracker's annotation in
  a shape you do not know"). Source analysis: the silent-vanish finding in
  `../source-han-cleanup-plan.md` ("The shared ticket file").
- **Rejected alternatives:**
  - Treating unrecognized marks as malformed headings to repair — rejected because repairing an annotation that
    records a publication elsewhere would publish duplicates; the existing written rule names exactly this danger.
- **Linked technical notes:** —
- **Driven by findings:** F3 (the classification is asymmetric: only the tracker whose old shape is unique can be
  recognized as "own old-format"; the two shape-identical trackers always reach the ask), F7 (a near-miss annotation
  gets a proposed manual correction, never an automatic repair)
- **Dependent decisions:** D4, D7
- **Referenced in spec:** Primary Flow; Alternate Flows and States; Edge Cases and Failure Modes

### D4: Migration behavior

- **Question:** What happens to files marked up in the old, unlabeled format?
- **Decision:** Old marks whose shape identifies their tracker without doubt are upgraded in place, with each upgrade
  reported. Old marks whose shape could belong to more than one tracker stop the run, and the publisher asks the
  person which tracker owns each one. The publisher never assigns a tracker by guess.
- **Rationale:** The outline commits the migration path to "stops and asks rather than guesses." Upgrading an
  unambiguous mark is not guessing: the old number-sign shape belongs to exactly one tracker, while the old
  letter-key shape is shared by two trackers and is exactly the ambiguity that caused the original bug.
- **Evidence:** User input (OQ-1 resolution and the outline's Phase 2 entry, `../build-phase-outline.md#phase-2`).
  Codebase: the three mark shapes cited under D2 show the asymmetry — `(#NNN)` is unique to the GitHub publisher;
  `(<KEY>)` and `(<LINEAR-ID>)` are the same shape.
- **Rejected alternatives:**
  - Stop and ask for every old mark, including unambiguous ones — rejected because it adds interruptions without
    protecting anything; the simpler version satisfies the same evidence. This deliberately refines the outline's
    blanket "stops and asks" wording: upgrading a mark whose owner is certain is not guessing, which is what the
    outline's wording guards against.
  - Auto-assign ambiguous marks by probing both trackers — rejected because a lookup that happens to match in both
    trackers still cannot decide ownership, and the outline requires asking over guessing.
  - Only the owning tracker's publisher may upgrade its old marks — rejected because a team that stopped using that
    tracker would then carry old-format marks forever; naming a certain owner is safe from any publisher.
- **Linked technical notes:** —
- **Driven by findings:** F3, F6 (migration is the expected first encounter for every file published before this
  phase, not an edge case), F7 (key text that collides with a tracker name or another tracker's key is treated as
  ambiguous and held for the ask), F12 (the divergence from the outline's blanket wording is recorded here)
- **Dependent decisions:** —
- **Referenced in spec:** Outcome; Alternate Flows and States; Edge Cases and Failure Modes

### D6: One shared publishing record

- **Question:** The GitHub publisher records its marks only in derived per-repo copies today, leaving the shared file
  untouched; the other two publishers mark the shared file in place. Where does the publishing record live?
- **Decision:** The shared work-items file is the complete publishing record for all three trackers. The GitHub
  publisher changes to also write its tracker-labeled marks into the shared file; its derived per-repo copies stay
  internal.
- **Rationale:** The whole fix rests on one contract all three publishers read and write. With two carriers, the
  shared file could never answer "was this published to the GitHub tracker?", and cross-tracker classification would
  stay asymmetric forever.
- **Evidence:** User input (2026-07-21). Codebase: `han-github/skills/work-items-to-issues/SKILL.md` Step 5 states the
  source file is not modified by the publish step, while the Jira and Linear skills edit the source file in place
  (their Step 6 annotation passes).
- **Rejected alternatives:**
  - Model two carriers (shared file plus derived copies) — rejected by the user because the shared file could never
    answer whether a slice was published to the GitHub tracker, defeating the one-contract goal.
- **Linked technical notes:** —
- **Driven by findings:** F1
- **Dependent decisions:** D7
- **Referenced in spec:** Outcome; Primary Flow; Coordinations

### D7: Pause and ask

- **Question:** When a run finds marks belonging to another tracker (or ambiguous or unrecognized marks), does it
  pause for an in-run decision or stop outright for a hand-edit and re-run?
- **Decision:** The run classifies everything first, pauses once, presents the full picture with each raw mark text,
  and asks one question. The person chooses: publish only the unmarked slices, also publish another tracker's slices
  here, or stop. Nothing is created before the answer.
- **Rationale:** The publishers run inside a conversation, so an informed in-run question is natural and cheaper than
  a hand-edit-and-re-run loop. Presenting the whole picture before anything is created keeps the safety of the old
  hard stop while removing its friction. Showing the raw mark text lets the person double-check before an
  irreversible answer.
- **Evidence:** User input (2026-07-21). Codebase: the GitHub publisher's current hard-stop rule
  (`han-github/skills/work-items-to-issues/SKILL.md` Step 3: only Stop is offered for foreign annotations) is the
  behavior this deliberately replaces.
- **Rejected alternatives:**
  - Keep the hard stop with hand-edit and re-run — rejected by the user for friction; the pause preserves the same
    protection (nothing created before a decision) without the re-run loop.
  - Publish unmarked slices unconditionally and only report the rest — rejected because it removes the person's
    chance to catch a wrong classification before items are created.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow; Edge Cases and Failure Modes

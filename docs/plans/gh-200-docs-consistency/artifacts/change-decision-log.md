# Change Decision Log: GitHub issue #200 documentation consistency

<!--
This file records every decision committed while planning this change.
The plan itself lives in [../change-plan.md](../change-plan.md) — this file captures the
question, rationale, evidence, and rejected alternatives behind each decision.
Evidence about the code as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.
-->

## Trivial decisions

- D-6: Output location — the plan lands in `docs/plans/gh-200-docs-consistency/`, matching the repository's existing
  `docs/plans/{name}/` convention and the operator's branch `gh-200-quick-start-docs`. Approved in the opening
  confirmation turn. — Referenced in plan: none; recorded here for the record.

## Full decisions

### D-1: How the size-accepting list stops drifting

- **Question:** Three pages each carry an independent copy of the list of skills that classify their own work as small,
  medium, or large, and the three disagree. Should the copies be brought into agreement, or should two of them be
  replaced by a pointer to the third?
- **Decision:** Sync the copies. `docs/quickstart.md` gains four names and `docs/concepts.md` gains one, so all three
  pages name the same 13 skills. `docs/sizing.md` is unchanged. The concrete membership, which is the decision-bearing
  value two pages must now independently agree on:

  ```
  /architectural-analysis   /design-an-api            /plan-a-feature
  /automated-test-planning  /gap-analysis             /plan-implementation
  /code-overview            /iterative-plan-review    /research
  /code-review              /plan-a-change
  /code-walkthrough         /ddd-analysis
  ```

  The test that produces this membership, so a future contributor can regenerate it rather than copy it: a skill
  belongs when its `SKILL.md` frontmatter declares `arguments: size` **and** it classifies its own work, evidenced by a
  `## Sizing` section in its long-form doc. Fourteen skills declare the field; `plan-a-feature-to-confluence` fails the
  second half of the test (see D-5).

- **Rationale:** The operator's direction. Offered three named options and the reasoning behind each, they chose to
  sync. Their direction is itself a valid justification, and this entry records it as one.
- **Evidence:** Operator answer, verbatim: "sync the copies". Supporting current-state evidence:
  [C-1](current-state-findings.md#c-1-three-documentation-pages-independently-enumerate-the-sizing-aware-skills-with-three-different-memberships),
  [C-2](current-state-findings.md#c-2-fourteen-skills-declare-a-size-argument-and-that-frontmatter-is-the-ground-truth),
  [C-3](current-state-findings.md#c-3-docssizingmd-is-correct-and-complete-and-the-issue-never-mentions-it),
  [C-5](current-state-findings.md#c-5-the-quickstarts-list-has-not-been-updated-in-almost-four-months-and-four-skills-entered-the-catalogs-in-that-window).
  Specialist input: `han-core:information-architect` `I-2` and `I-3`; `han-core:junior-developer` conversational
  reframing.
- **Behavior impact:** Preserving. No skill, plugin manifest, or command changes; the prose catches up to the
  frontmatter it describes.
- **Rejected alternatives:**
  - **Retire the duplicate enumerations.** `docs/sizing.md` keeps the list; the other two pages get one sentence plus
    the link each already carries. Recommended by `han-core:information-architect` (`I-2`, `I-3`) on the grounds that
    three independently-maintained copies will drift again, that the quickstart's job is routing rather than reference,
    and that the page already links to Sizing two lines below the list. Rejected because the operator chose to sync
    after being shown this option and its reasoning. It remains the option with the lower maintenance surface, and the
    reopening condition is recorded under `## Deferred (YAGNI)` in the plan.
  - **Make the quickstart's list an explicitly non-exhaustive example.** Word it "skills like `/code-review` and
    `/plan-a-feature`, see Sizing for the full list", so drift cannot make it wrong, only stale in a way nobody acts
    on. Surfaced by `han-core:junior-developer`. Rejected for the same reason: the operator chose to sync, and this
    option leaves `docs/concepts.md` needing a separate decision anyway.
- **Revisit criterion:** A second drift incident lands on any of the three catalogs after D-2 ships, or a fourth page
  starts carrying the membership. Either turns "a human forgot once" into a pattern the checklist demonstrably does not
  hold, and reopens both rejected alternatives alongside the deferred automated check.
- **Dissent (if any):** `han-core:information-architect` recommended the first rejected alternative and its reasoning is
  recorded above rather than absorbed. Disagree and commit: the maintenance argument is sound, and the operator holds
  the call on how much of their own documentation to restructure in response to a defect report.
- **Settles delta entry:** S-1, S-2.
- **Dependent decisions:** D-2.
- **Referenced in plan:** Target State, Surface Delta (S-1, S-2), Review Findings.

### D-2: What the contributor checklist says

- **Question:** Step 6 of the skill-addition checklist names the two pages a contributor must update when adding a skill
  that classifies its own work. A third page carries the same list and is not named. Should the step name it?
- **Decision:** Yes. Step 6 names three pages: Sizing, Concepts, and Quickstart, in that order. The step's opening
  condition is unchanged, and it is what keeps a forwarding wrapper out of the catalogs:

  ```markdown
  6. If the skill classifies its work as small / medium / large, add it to the sizing-aware list and the at-a-glance
     table in [Sizing](./docs/sizing.md), to the sizing-aware list in [Concepts](./docs/concepts.md), to the sizing-aware
     list in [Quickstart](./docs/quickstart.md), and give its long-form doc a `## Sizing` section. A sizing-aware skill
     that never lands in those catalogs is invisible to anyone reading them to learn which skills scale.
  ```

- **Rationale:** This step is the mechanism behind the drift D-1 corrects. Four skills entered the sizing catalogs
  between 2026-08-10 and 2026-09-09; every one of those commits updated a page the checklist names, and none updated the
  quickstart, which it does not name. Correcting the list without correcting the step fixes the symptom and leaves the
  cause.
- **Evidence:**
  [C-5](current-state-findings.md#c-5-the-quickstarts-list-has-not-been-updated-in-almost-four-months-and-four-skills-entered-the-catalogs-in-that-window)
  establishes the four commits and which pages each touched.
  [C-6](current-state-findings.md#c-6-contributingmd-step-6-names-two-catalogs-and-not-the-quickstart)
  quotes the step verbatim. Operator approval recorded in
  [scope-boundary.md](scope-boundary.md#operator-stated-scope): "Issue scope plus the checklist."
- **Behavior impact:** Changing. Someone adding a skill that scales its team follows step 6 and updates three pages
  where they update two today. The observer is the next contributor to add such a skill; the cost is one more page in
  the same edit. Operator answer, verbatim, from the opening confirmation turn: "looks good", selecting the option
  stated as "**Issue scope plus the checklist.** Same four pages, plus `CONTRIBUTING.md` step 6 gains the quickstart.
  One extra line, and the drift stops recurring." Reaffirmed by the answer to D-1, because syncing the copies is the
  option under which this edit's shape is the one already approved.
- **Rejected alternatives:**
  - **Leave the checklist alone and fix only the lists.** Rejected because the four-month drift in
    [C-5](current-state-findings.md#c-5-the-quickstarts-list-has-not-been-updated-in-almost-four-months-and-four-skills-entered-the-catalogs-in-that-window)
    would resume on the next skill added, with nothing changed to prevent it.
  - **Drop the Concepts instruction and name Sizing alone.** This is the shape step 6 would take under D-1's first
    rejected alternative. Rejected as a consequence of D-1: with three copies kept, all three need naming.
- **Revisit criterion:** D-1 is revisited and its outcome changes, or an automated check ships that makes the human
  reminder redundant.
- **Dissent (if any):** None. `han-core:junior-developer` flagged that this edit's direction depends on D-1's outcome,
  which is why the two decisions were put to the operator together rather than assumed to carry over.
- **Settles delta entry:** S-5.
- **Dependent decisions:** None.
- **Referenced in plan:** Surface Delta (S-5), Behavior Changes, Change Units (Unit 1).

### D-3: How the `han-reporting` exception is stated

- **Question:** Two pages state correctly that `han-reporting` depends on `han-communication` alone, and each then
  contradicts that statement a few lines later. What replaces the contradicting text?
- **Decision:** On the plugin-choosing page, the exception moves into the bold sentence rather than staying only in the
  parenthetical above it:

  ```markdown
  That means **every layer install except `han-reporting` comes with the shared agents.** The real choice comes down to:
  ```

  On the concepts page, the list of installs that do not exist drops `reporting-only` and says what that install
  actually gives you:

  ```markdown
  The practical choice is core only, the bundled suite, or the suite plus whichever opt-in plugins you want. There is no
  planning-only, coding-only, or GitHub-only install. Reporting-only is possible: installing `han-reporting` gives you
  `/stakeholder-summary` and `/html-summary` plus `han-communication`, without the `han-core` agent roster.
  ```

- **Rationale:** Both pages already carry the correct statement, so this is not a question of what is true but of where
  the truth sits. On the plugin-choosing page the correct half is a trailing parenthetical and the wrong half is bold
  under the heading "The one thing that surprises people", which is exactly what a skimming reader stops on. Putting the
  exception in the bold sentence is what the issue asked for and what the information architect's reasoning supports.
- **Evidence:**
  [C-7](current-state-findings.md#c-7-han-reporting-declares-only-han-communication-and-it-is-the-only-layer-plugin-that-does)
  for the manifest,
  [C-8](current-state-findings.md#c-8-docschoosing-a-han-pluginmd-states-the-exception-correctly-and-then-denies-it-two-lines-later-in-bold)
  and
  [C-9](current-state-findings.md#c-9-docsconceptsmd-states-the-exception-correctly-and-then-denies-it-seventeen-lines-later)
  for the two contradictions,
  [C-10](current-state-findings.md#c-10-no-other-page-in-the-repo-states-the-layer-dependency-claim-incorrectly)
  for the blast radius. `han-core:information-architect` `I-1` for why typographic weight decides which half a reader
  takes away. The issue's own suggested fix, quoted in [scope-boundary.md](scope-boundary.md#stated-scope).
- **Behavior impact:** Preserving. No plugin's declared dependencies change.
- **Rejected alternatives:**
  - **Delete the bold sentence entirely.** Rejected because it carries a true and useful claim about the other five
    layer plugins; the defect is its universality, not its existence.
  - **Fix the bold sentence and delete the parenthetical as redundant.** Rejected because the parenthetical states what
    `han-reporting` depends on and the bold sentence states what that means for an install. They answer different
    questions and now agree.
- **Revisit criterion:** `han-reporting` gains a `han-core` dependency, or a second layer plugin drops one. Either makes
  both sentences wrong again.
- **Dissent (if any):** `han-core:structural-analyst` reported as its `S-4` that it could not find the concepts-page
  contradiction and that the file states the fact consistently. Overruled on evidence: the contradiction is at line 265,
  not the line 261 its brief named, and a statement about which installs exist is a statement about dependencies. See
  [C-9](current-state-findings.md#c-9-docsconceptsmd-states-the-exception-correctly-and-then-denies-it-seventeen-lines-later).
- **Settles delta entry:** S-3, S-4.
- **Dependent decisions:** None.
- **Referenced in plan:** Target State, Surface Delta (S-3, S-4), Change Units (Unit 2), Review Findings.

### D-4: What the banner alt text says

- **Question:** The front-door banner has no `alt` attribute. The image renders a wordmark, a tagline, the phrase
  "agent - swarm - skills", and four labeled workflow stages. How much of that does the alt text carry?
- **Decision:** The wordmark and the tagline, and nothing else:

  ```html
  <img src="images/han-banner.png" alt="Han: your agentic ally for solo product engineers">
  ```

- **Rationale:** Alt text replaces what a sighted reader gets from the image at that position, which is identity, not
  content. The four stage labels name skills the README describes in prose immediately below, so carrying them into the
  alt text would make a screen-reader user hear the same list twice before reaching the orienting paragraph.
- **Evidence:**
  [C-11](current-state-findings.md#c-11-the-banner-image-is-at-readmemd3-not-5-and-it-is-the-only-image-embed-in-the-repos-prose)
  for the location and the rendered text. `han-core:information-architect` `I-4` for what the alt text needs to convey
  and its note that it need not restate the paragraph that follows. The issue's own wording, quoted in
  [scope-boundary.md](scope-boundary.md#stated-scope): "Worth a short description for screen readers and for anyone
  whose images do not load."
- **Behavior impact:** Preserving. The rendered page is unchanged for a reader whose images load.
- **Rejected alternatives:**
  - **Describe the full banner, stages included.** Rejected as duplication of the prose below it, per `I-4`.
  - **Use `alt=""` to mark it decorative.** Rejected because the banner is not decorative: it carries the project's name
    and its one-line identity, and it is the first element on the page.
- **Revisit criterion:** The banner image is replaced with one whose rendered text differs.
- **Casing, recorded rather than silent:** The banner renders "Solo" with a capital S, set in a different color from the
  words around it. The alt text lowercases it. Both review agents flagged the mismatch
  (`han-core:gap-analyzer` `GAP-004`, `han-core:junior-developer`), so the choice is recorded here instead of made
  quietly. The capital is a design accent rather than a claim about the word: the repository's own prose writes "solo
  (or small-team) product engineers" in lower case at `README.md:5` and `CLAUDE.md:3`, and the only capital "Solo" in
  any prose file is title case in the `README.md` H1. Alt text is read as a sentence, so it follows the prose.
- **Dissent (if any):** None.
- **Settles delta entry:** S-6.
- **Dependent decisions:** None.
- **Referenced in plan:** Target State, Surface Delta (S-6), Change Units (Unit 3).

### D-5: The Atlassian wrapper stays out of the catalogs

- **Question:** Fourteen skills declare `arguments: size`, and every documentation catalog names at most 13.
  `plan-a-feature-to-confluence` is the omitted one. Is that an error the change should fix?
- **Decision:** No. It is correctly absent, and no wording change is needed to keep it absent. The catalogs list skills
  that classify their own work; this one accepts the argument and forwards it to `plan-a-feature`.
- **Rationale:** The distinction is already drawn by the checklist's own opening condition, "If the skill classifies its
  work as small / medium / large". A forwarding wrapper does not classify. The corroborating signal is that it carries
  no `## Sizing` section in its long-form doc, which the same checklist step requires of a skill that does classify.
- **Evidence:** `han-atlassian/skills/plan-a-feature-to-confluence/SKILL.md` declares `arguments: size` and forwards it
  at lines 63 and 75 ("together with the `size` argument ... is forwarded to"). `han-atlassian/docs/skills/plan-a-feature-to-confluence.md`
  has no `## Sizing` heading.
  [C-2](current-state-findings.md#c-2-fourteen-skills-declare-a-size-argument-and-that-frontmatter-is-the-ground-truth)
  records the fourteen. Raised by `han-core:structural-analyst` as its `S-2`.
- **Behavior impact:** Preserving. Nothing changes.
- **Rejected alternatives:**
  - **Add the wrapper to all three catalogs.** Rejected because a reader looking for skills that scale their own team
    would find one that does not, and because it would then need a `## Sizing` section describing behavior it does not
    have.
  - **Add a sentence to the checklist excluding forwarding wrappers.** Rejected as unnecessary: the existing condition
    already excludes it. Reopen if a second forwarding wrapper appears and a contributor gets it wrong.
- **Revisit criterion:** `plan-a-feature-to-confluence` starts classifying its own work, or a contributor adds a
  forwarding wrapper to a catalog, showing the existing condition does not read as clearly as this decision assumes.
- **Dissent (if any):** `han-core:structural-analyst` raised this as a drift between `docs/sizing.md` and the frontmatter
  and argued that a page-to-page sync leaves it in place. Closed rather than carried: the frontmatter field alone is not
  the membership test, and the agent did not have the long-form-doc half of the test.
- **Settles delta entry:** — (shapes the plan without committing one entry; it bounds the membership S-1 and S-2 commit
  to)
- **Dependent decisions:** D-1.
- **Referenced in plan:** Target State, Review Findings.

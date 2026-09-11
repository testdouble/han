# Change Plan: GitHub issue #200 documentation consistency

## Why This Change

An outside reader worked through Han's documentation end to end and found pages that disagree with each other and with
the skill definitions. They filed [testdouble/han#200](https://github.com/testdouble/han/issues/200) with three fixes.
This is a **finding already established**: the reader did the discovery, and this run verified every claim against the
frontmatter and the plugin manifests before planning anything.

Verification widened one of the three. The reader reported a single skill missing from the quickstart's list of
size-accepting skills. Four are missing ([C-1](artifacts/current-state-findings.md#c-1-three-documentation-pages-independently-enumerate-the-sizing-aware-skills-with-three-different-memberships)).

## What Changes, In One Paragraph

After this change, four documentation pages state what the code does. The quickstart and the concepts page
name every skill that classifies its own work as small, medium, or large. The plugin-choosing page and the concepts page
stop claiming that installing any layer brings the shared agent roster, because installing `han-reporting` does not. The
contributor checklist names all three pages that carry the size-accepting list, so the next skill to gain sizing lands
in all of them. And the front-door banner carries a text description for anyone whose screen reader or browser does not
render it.

Nothing about how any skill behaves changes. The prose catches up to the system it describes.

## Current State

Three pages each carry an independent copy of the list of skills that accept a size argument, and the three disagree.
The Sizing page names 13, the concepts page 12, and the quickstart 9
([C-1](artifacts/current-state-findings.md#c-1-three-documentation-pages-independently-enumerate-the-sizing-aware-skills-with-three-different-memberships)).
The authoritative membership is the `arguments: size` field in each skill's frontmatter
([C-2](artifacts/current-state-findings.md#c-2-fourteen-skills-declare-a-size-argument-and-that-frontmatter-is-the-ground-truth)).
The Sizing page is correct and needs no content change
([C-3](artifacts/current-state-findings.md#c-3-docssizingmd-is-correct-and-complete-and-the-issue-never-mentions-it)).

**The specific structural property this change addresses is an unowned duplicated fact.** One fact lives in three places
with nothing designating an owner and nothing enforcing agreement. The quickstart's copy last changed on 2026-05-29.
Four skills entered the sizing catalogs between then and 2026-09-09, and not one of those four commits touched the
quickstart
([C-5](artifacts/current-state-findings.md#c-5-the-quickstarts-list-has-not-been-updated-in-almost-four-months-and-four-skills-entered-the-catalogs-in-that-window)).
The mechanism is one line: the contributor checklist names the Sizing page and the concepts page, and not the quickstart
([C-6](artifacts/current-state-findings.md#c-6-contributingmd-step-6-names-two-catalogs-and-not-the-quickstart)).
Nothing in the test suite or the lint hooks reads skill frontmatter and compares it against any documentation list, so
the four-month drift was invisible to CI
([C-12](artifacts/current-state-findings.md#c-12-nothing-automated-checks-that-a-sizing-aware-skill-reaches-the-documentation-catalogs)).

The same shape appears on a second fact. `han-reporting` is the only layer plugin that does not declare `han-core`
([C-7](artifacts/current-state-findings.md#c-7-han-reporting-declares-only-han-communication-and-it-is-the-only-layer-plugin-that-does)).
Two pages each state the exception correctly and then deny it a few lines later
([C-8](artifacts/current-state-findings.md#c-8-docschoosing-a-han-pluginmd-states-the-exception-correctly-and-then-denies-it-two-lines-later-in-bold),
[C-9](artifacts/current-state-findings.md#c-9-docsconceptsmd-states-the-exception-correctly-and-then-denies-it-seventeen-lines-later)).
On the plugin-choosing page, the correct half sits in a trailing parenthetical and the wrong half sits in bold under
the heading "The one thing that surprises people." Typographic weight points a skimming reader at the false claim
(`I-1`). No other page in the repository states the claim incorrectly
([C-10](artifacts/current-state-findings.md#c-10-no-other-page-in-the-repo-states-the-layer-dependency-claim-incorrectly)).

The banner is the only image embed in any README or documentation file, and it has no `alt` attribute
([C-11](artifacts/current-state-findings.md#c-11-the-banner-image-is-at-readmemd3-not-5-and-it-is-the-only-image-embed-in-the-repos-prose)).
The issue cites `README.md:5`; the line is now 3. The reader warned that their line numbers might drift and said the
quoted text was the reliable anchor. It did, and it was.

## Target State

**The Sizing page owns the size-accepting membership, and two other pages mirror it.** That is a change of degree rather
than of kind: the Sizing page already held the correct list. This change makes the mirrors correct and names all three
in the contributor checklist, so they stay that way
([D-1](artifacts/change-decision-log.md#d-1-how-the-size-accepting-list-stops-drifting)).

Three pages carry the membership after this change, and one contributor checklist step governs all three. The membership
is the 13 skills that classify their own work:

```
/architectural-analysis   /design-an-api            /plan-a-feature
/automated-test-planning  /gap-analysis             /plan-implementation
/code-overview            /iterative-plan-review    /research
/code-review              /plan-a-change
/code-walkthrough         /ddd-analysis
```

**A fourteenth skill declares `arguments: size` and is correctly absent from all three pages.**
`plan-a-feature-to-confluence` accepts the argument and forwards it to `plan-a-feature`; it classifies nothing itself
and carries no `## Sizing` section in its long-form doc. The checklist step already draws this line in its own opening
words, "If the skill classifies its work as small / medium / large." No wording change is needed to keep the wrapper out
([D-5](artifacts/change-decision-log.md#d-5-the-atlassian-wrapper-stays-out-of-the-catalogs)).

**The `han-reporting` exception is stated where a skimming reader will meet it.** The bold sentence on the
plugin-choosing page carries the exception rather than contradicting it, and the concepts page names reporting-only as
an install that exists ([D-3](artifacts/change-decision-log.md#d-3-how-the-han-reporting-exception-is-stated)).

**The banner describes itself.** The `alt` text carries the wordmark and the one-line identity the banner renders, which
is what a sighted reader gets from it at that position
([D-4](artifacts/change-decision-log.md#d-4-what-the-banner-alt-text-says)).

### Pinned replacement text

Every entry below commits to exact text, because the value of this plan is the wording and not the intent behind it.
Each pinned block replaces a whole paragraph or a whole list item, never a line range, because several of these
sentences share a line with the sentence after them.

Two mechanical constraints apply throughout. Prettier runs with `proseWrap: "preserve"` and `printWidth: 120`, so it
will not rewrap prose. Wrap new lines by hand at 120 columns. Over-length lines already exist in these files and are not
this change's to fix.

**What the `Behavior` field on each entry means.** It answers whether the documented system behaves differently
afterwards, not whether the page reads differently. Every entry changes what a reader sees; that is the deliverable.
[Behavior Changes](#behavior-changes) states the reader-visible change for all six, so the classification does not
quietly absorb it.

## Surface Delta

### S-1: The size-accepting skill list in `docs/quickstart.md` — Re-scoped

**Target state.** The list in the "A note on sizing" section names all 13 skills that classify their own work, in
alphabetical order. Replace the whole paragraph, currently `docs/quickstart.md:196-200`, with:

```markdown
The sizing-aware skills (`/architectural-analysis`, `/automated-test-planning`, `/code-overview`, `/code-review`,
`/code-walkthrough`, `/ddd-analysis`, `/design-an-api`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-change`,
`/plan-a-feature`, `/plan-implementation`, `/research`) classify the work as **small**, **medium**, or **large** before
dispatching agents. They default to small, and scale the team and iteration depth to the chosen band. Pass the size as
the first positional argument to override (`/code-review medium`, `/plan-a-feature large "describe the feature"`). See
[Sizing](./sizing.md) for the full model.
```

The paragraph is pinned whole because the replaced sentence ends part-way through line 198 and the next sentence begins
on the same line. Replacing a line range here deletes text that is not part of this change.

**Behavior.** Preserving. No skill, plugin manifest, or command changes. The page states the membership the frontmatter
already declares.

**Why.** The list is four skills short and four months stale
([C-1](artifacts/current-state-findings.md#c-1-three-documentation-pages-independently-enumerate-the-sizing-aware-skills-with-three-different-memberships),
[C-5](artifacts/current-state-findings.md#c-5-the-quickstarts-list-has-not-been-updated-in-almost-four-months-and-four-skills-entered-the-catalogs-in-that-window)).

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-how-the-size-accepting-list-stops-drifting)

### S-2: The size-accepting skill list in `docs/concepts.md` — Re-scoped

**Target state.** The **Sizing-aware skills** bullet names all 13, each linked to its long-form doc, in alphabetical
order. Replace the whole list item, currently `docs/concepts.md:136-145`, with:

```markdown
- **Sizing-aware skills.** [`/architectural-analysis`](../han-coding/docs/skills/architectural-analysis.md),
  [`/automated-test-planning`](../han-coding/docs/skills/automated-test-planning.md),
  [`/code-overview`](../han-coding/docs/skills/code-overview.md), [`/code-review`](../han-coding/docs/skills/code-review.md),
  [`/code-walkthrough`](../han-coding/docs/skills/code-walkthrough.md),
  [`/ddd-analysis`](../han-ddd/docs/skills/ddd-analysis.md),
  [`/design-an-api`](../han-coding/docs/skills/design-an-api.md),
  [`/gap-analysis`](../han-research/docs/skills/gap-analysis.md),
  [`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md),
  [`/plan-a-change`](../han-planning/docs/skills/plan-a-change.md),
  [`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md),
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md), [`/research`](../han-research/docs/skills/research.md).
```

The only difference from today is the `/ddd-analysis` line, inserted between `/code-walkthrough` and `/design-an-api`.
Two lines exceed 120 columns and are reproduced exactly as they stand, because Prettier preserves them and rewrapping
them is not this change's business.

**Behavior.** Preserving. Same reason as S-1.

**Why.** `/ddd-analysis` declares `arguments: size`, classifies its own work, and carries a `## Sizing` section, so it
belongs in the catalog by the checklist's own test
([C-2](artifacts/current-state-findings.md#c-2-fourteen-skills-declare-a-size-argument-and-that-frontmatter-is-the-ground-truth)).

**Decision.** [D-1](artifacts/change-decision-log.md#d-1-how-the-size-accepting-list-stops-drifting)

### S-3: The shared-agents claim in `docs/choosing-a-han-plugin.md` — Re-scoped

**Target state.** The bold sentence carries the exception rather than erasing it:

```markdown
That means **every layer install except `han-reporting` comes with the shared agents.** The real choice comes down to:
```

The parenthetical two lines above it is unchanged and now agrees with it.

**Behavior.** Preserving. No plugin's declared dependencies change.

**Reader impact.** Someone deciding whether to install `han-reporting` on its own reads the opposite of what they read
today, and today's version is the false one.

**Why.** The bold sentence contradicts the true statement four lines above it, and bold under a "surprises people"
heading is what a skimming reader stops on
([C-8](artifacts/current-state-findings.md#c-8-docschoosing-a-han-pluginmd-states-the-exception-correctly-and-then-denies-it-two-lines-later-in-bold), `I-1`).

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-how-the-han-reporting-exception-is-stated)

### S-4: The non-existent-installs list in `docs/concepts.md` — Re-scoped

**Target state.** The sentence names the three installs that do not exist and says what the fourth gives you:

```markdown
The practical choice is core only, the bundled suite, or the suite plus whichever opt-in plugins you want. There is no
planning-only, coding-only, or GitHub-only install. Reporting-only is possible: installing `han-reporting` gives you
`/stakeholder-summary` and `/html-summary` plus `han-communication`, without the `han-core` agent roster.
```

**Behavior.** Preserving. No plugin's declared dependencies change.

**Reader impact.** Someone who wants only the two reporting skills learns that install exists, where today the page
tells them it does not.

**Why.** Three of the four named installs genuinely do not exist. Reporting-only does
([C-7](artifacts/current-state-findings.md#c-7-han-reporting-declares-only-han-communication-and-it-is-the-only-layer-plugin-that-does),
[C-9](artifacts/current-state-findings.md#c-9-docsconceptsmd-states-the-exception-correctly-and-then-denies-it-seventeen-lines-later)).

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-how-the-han-reporting-exception-is-stated)

### S-5: Step 6 of the skill-addition checklist in `CONTRIBUTING.md` — Re-scoped

**Target state.** Step 6 names three pages rather than two:

```markdown
6. If the skill classifies its work as small / medium / large, add it to the sizing-aware list and the at-a-glance
   table in [Sizing](./docs/sizing.md), to the sizing-aware list in [Concepts](./docs/concepts.md), to the sizing-aware
   list in [Quickstart](./docs/quickstart.md), and give its long-form doc a `## Sizing` section. A sizing-aware skill
   that never lands in those catalogs is invisible to anyone reading them to learn which skills scale.
```

**Behavior.** Changing. A contributor adding a sizing-aware skill updates one more page than the checklist asks for
today. See [Behavior Changes](#behavior-changes).

**Why.** This step is the mechanism behind the drift S-1 corrects. Without it, the quickstart falls behind again the
next time a skill gains sizing
([C-5](artifacts/current-state-findings.md#c-5-the-quickstarts-list-has-not-been-updated-in-almost-four-months-and-four-skills-entered-the-catalogs-in-that-window),
[C-6](artifacts/current-state-findings.md#c-6-contributingmd-step-6-names-two-catalogs-and-not-the-quickstart)).

**Depends on.** S-1. The step should not name the quickstart as a tracked catalog until the quickstart's list is
correct.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-what-the-contributor-checklist-says)

### S-6: The `alt` attribute on the banner in `README.md` — Added

**Target state.** The banner embed carries a text description:

```html
<img src="images/han-banner.png" alt="Han: your agentic ally for solo product engineers">
```

**Behavior.** Preserving. Nothing about the rendered page changes for a reader whose images load.

**Reader impact.** Someone using a screen reader on the front page hears the project's name and what it is, where today
they hear the filename or nothing at all. That reader is the entire point of this entry, so it is stated here rather
than left inside a classification that excludes them.

**Why.** The banner is the first element on the repository's front door and carries text a sighted reader receives and a
screen-reader user does not
([C-11](artifacts/current-state-findings.md#c-11-the-banner-image-is-at-readmemd3-not-5-and-it-is-the-only-image-embed-in-the-repos-prose), `I-4`).

**Decision.** [D-4](artifacts/change-decision-log.md#d-4-what-the-banner-alt-text-says)

## Behavior Changes

**What "behavior" means here.** Every entry in this plan changes what a reader sees, because changing what these pages
say is the entire deliverable. The `Behavior` field answers a narrower question: does the documented system behave
differently afterwards? For all six entries the answer is no. No skill, agent, plugin manifest, or command changes.

Read alone, that classification would define away the thing these edits exist to do, so the reader-visible change is
stated below for every entry. `han-core:junior-developer` raised this in the review round, pointing out that the first
draft of this section excluded the exact reader S-6 exists for.

**One entry changes what a person is instructed to do, and you approved it twice.**

**S-5, the contributor checklist.** Today someone adding a skill that scales its team follows step 6 and updates two
pages. After this change they update three. The observer is the next contributor to add such a skill, and the cost is
one more page in the same edit. You approved this in the opening confirmation turn, choosing "Issue scope plus the
checklist", and reaffirmed it by choosing to sync the copies rather than retire them
([D-2](artifacts/change-decision-log.md#d-2-what-the-contributor-checklist-says)).

**What a reader sees differently under the other five.**

- **S-1 and S-2.** Someone looking up which skills take a size argument gets 13 names instead of 9 on the quickstart and
  12 on the concepts page. Four of those names were reachable only from the Sizing page before.
- **S-3 and S-4.** Someone deciding whether to install `han-reporting` alone currently reads that every layer install
  brings the shared agents, and that no reporting-only install exists. Both are false, and a reader acting on either
  would install more than they need. This is the most consequential reader-visible change in the plan.
- **S-6.** Someone using a screen reader on the front page hears the project's name and what it is, where today they
  hear the filename or nothing.

## Change Units

Three units. Each leaves the repository working, and the tests and lint pass after each one. The units are independent,
so they can land in any order or as one commit; only the ordering **inside** unit 1 is constrained.

### Unit 1: Bring the size-accepting lists to 13 and put the quickstart under the checklist

**What it does.** Adds the four missing skills to the quickstart and the one missing skill to the concepts page, then
adds the quickstart to the contributor checklist step that governs them.

**Delta entries.** S-1, S-2, S-5.

**Ordering constraint.** Prefer S-1 before S-5, so the checklist never names a catalog that is still wrong. This is
authorial ordering rather than a hard constraint: nothing enforces it, nothing fails if it is reversed, and the three
edits are expected to land in one commit. Raised as overstated by `han-core:junior-developer` in the review round.

**How you know it worked.** Every skill whose `SKILL.md` frontmatter declares `arguments: size` and whose long-form doc
carries a `## Sizing` section appears on all three pages. Thirteen names on each, matching `docs/sizing.md:6-9`.
`plan-a-feature-to-confluence` appears on none of them.

### Unit 2: Make both `han-reporting` statements agree with the manifest

**What it does.** Rewrites the bold claim on the plugin-choosing page and the non-existent-installs sentence on the
concepts page.

**Delta entries.** S-3, S-4.

**How you know it worked.** Searching the repository for a claim that every layer install brings the shared agents
returns nothing outside `docs/plans/`. Both pages now say what `han-reporting/.claude-plugin/plugin.json` declares.

### Unit 3: Describe the banner

**What it does.** Adds the `alt` attribute to the only image embed in the repository's prose.

**Delta entries.** S-6.

**How you know it worked.** The rendered README is visually unchanged, and the banner announces "Han: your agentic ally
for solo product engineers" to a screen reader rather than the filename or nothing.

## Risks

The blast radius is six passages in five files, all prose. No unit changes a skill, an agent, a manifest, or a script,
so nothing can break at runtime.

**The one real risk is that the corrected text is itself wrong.** The membership in S-1 and S-2 comes from frontmatter
that changes whenever a skill is added. A list that is right today is right only until the next skill ships. That is
the same failure this change is fixing, one turn later. S-5 is what makes it detectable: a contributor following the
checklist updates all three. Nothing automated catches it
([C-12](artifacts/current-state-findings.md#c-12-nothing-automated-checks-that-a-sizing-aware-skill-reaches-the-documentation-catalogs)),
which is the subject of the deferral below.

**A smaller one: `docs/sizing.md` is the reference every corrected page now mirrors, which this change does not touch.**
If the Sizing page is wrong, three pages are wrong together instead of separately. It was verified correct against the
frontmatter during discovery
([C-3](artifacts/current-state-findings.md#c-3-docssizingmd-is-correct-and-complete-and-the-issue-never-mentions-it)),
and it restates the membership three times internally with all three agreeing
([C-4](artifacts/current-state-findings.md#c-4-docssizingmd-restates-the-same-membership-three-times-inside-one-file-and-all-three-agree)).

## Deferred (YAGNI)

**An automated check that a skill declaring `arguments: size` appears in every documentation catalog.** This is the
structurally complete fix: it would have caught the four-month drift on the day it started, where the checklist edit in
S-5 only reminds a human
([C-12](artifacts/current-state-findings.md#c-12-nothing-automated-checks-that-a-sizing-aware-skill-reaches-the-documentation-catalogs)).
It is deferred because the recorded boundary covers the pages the issue named and the checklist step that governs them,
and because the evidence for it is one incident.

**Reopen when** a second drift incident lands on any of the three catalogs after S-5 ships, or when someone adds a
fourth page carrying the membership. Either one turns "a human forgot once" into a pattern the checklist demonstrably
does not hold.

## Cut for Scope

Nothing was cut. Every entry the target state proposed sits inside the recorded boundary
([`artifacts/scope-boundary.md`](artifacts/scope-boundary.md), "In-Scope Files").

## Open Items

**Non-blocking: the plugin dependency graph is hand-copied across four files.** `CONTRIBUTING.md`, `docs/concepts.md`,
`docs/choosing-a-han-plugin.md`, and `README.md` each narrate independently which plugins depend on `han-core` and
`han-communication`, with no cross-reference to the manifests or to each other. After this change they agree. Nothing
enforces that they keep agreeing, and this is the same failure mode as the size-accepting list on a different fact.
Raised by `han-core:structural-analyst` as `S-6` in its report. It does not block any unit here; it is the next instance
of this problem, latent rather than active.

`han-core:junior-developer` asked in the review round why this change fixes the mechanism behind one duplicated fact and
not the other. The plan itself calls them the same failure mode. The answer is that the size-accepting list already had
a contributor checklist step governing it and needed one page added to it. That is a one-line edit inside the recorded
boundary. The dependency graph has no such step, so giving it one means authoring a new checklist item about four files
the issue never raised. That is a larger change than the boundary covers, and it is the operator's call rather than this
run's.

**Non-blocking: `han-reporting/README.md` does not state its own dependencies at all.** A reader who opens that plugin's
front door learns the install command and nothing about what comes with it. Outside the recorded boundary and noted so
the builder does not mistake its silence for a contradiction.

## Review Findings

Specialists engaged, and what each changed.

**Discovery round.** `han-core:structural-analyst` and `han-core:information-architect`. Two agents the skill names as
always-dispatched were deliberately skipped, with the reason recorded in
[`artifacts/current-state-findings.md`](artifacts/current-state-findings.md) rather than left silent.
`han-core:behavioral-analyst` analyzes runtime data flow, and this area has no runtime.
`han-core:concurrency-analyst` was gated out by its own condition. `han-core:information-architect` was dispatched in
the behavioral analyst's place, because reader impact is the closest analogue to runtime behavior that a documentation
set has.

**Findings that changed the plan.**

- `I-1` reshaped S-3. The issue's suggested fix was to scope the bold claim. The information architect established
  **why** the bold sentence specifically is the one that must carry the exception, rather than a parenthetical near it.
- `I-3` recommended dropping the quickstart's enumeration entirely rather than syncing it. That recommendation was put
  to you as a named option and you chose to sync. Recorded as a rejected alternative in
  [D-1](artifacts/change-decision-log.md#d-1-how-the-size-accepting-list-stops-drifting).
- `han-core:junior-developer` surfaced that the two duplicate pages serve different readers and might warrant different
  answers, and that retiring the copies would invert the checklist edit you had already approved. The second point
  shaped how the question was put to you.

**Findings closed by the current-state record.**

- `han-core:structural-analyst` `S-4` reported that it could not find the contradiction in `docs/concepts.md` and that
  the file states the `han-reporting` fact consistently. Closed by
  [C-9](artifacts/current-state-findings.md#c-9-docsconceptsmd-states-the-exception-correctly-and-then-denies-it-seventeen-lines-later):
  the contradiction is at line 265, not the line 261 the brief named. The agent read the surrounding lines and judged
  that a statement about which installs exist was not a statement about dependencies. It is both.
- `han-core:structural-analyst` `S-2` reported that `docs/sizing.md` itself drifts from the frontmatter because it omits
  `plan-a-feature-to-confluence`. Closed by
  [D-5](artifacts/change-decision-log.md#d-5-the-atlassian-wrapper-stays-out-of-the-catalogs): that skill forwards the
  argument rather than classifying, and the checklist's own wording already excludes it.

**Review round.** One round, the small band's cap. `han-core:junior-developer` stress-tested the plan, and
`han-core:gap-analyzer` verified every pinned replacement against the frontmatter, the manifests, and the live edit
sites, writing [`artifacts/verification-gaps.md`](artifacts/verification-gaps.md). `han-core:gap-analyzer` was chosen in
place of a roster specialist because the roster is written for code changes. The real risk on this one is that the
corrected text is itself wrong.

Four findings changed the plan:

- **S-2 pinned no exact text** while every other entry did. It now pins the whole list item. Raised by
  `han-core:gap-analyzer` as `GAP-001`.
- **S-1's replaced sentence ends part-way through a line that the next sentence also begins on.** A builder replacing
  the line range would have deleted text outside this change. S-1 now pins the whole paragraph and says why. Raised as
  `GAP-003`.
- **The behavior classification excluded the reader each entry exists for.** [Behavior Changes](#behavior-changes) now
  states what the field means and names the reader-visible change for all six entries. Raised by
  `han-core:junior-developer`, and it is the sharpest finding of the run.
- **Unit 1's ordering constraint was overstated.** It is authorial preference, not a constraint anything enforces.
  Raised by `han-core:junior-developer`.

Two more were resolved without changing the plan's substance. `GAP-004` and `han-core:junior-developer` both flagged
that the banner renders "Solo" capitalized while the alt text lowercases it; that is now a recorded decision rather than
a silent choice ([D-4](artifacts/change-decision-log.md#d-4-what-the-banner-alt-text-says)). Both agents also reported
`artifacts/change-decision-log.md` as empty or missing and treated every `D-N` citation as unverifiable. Both read the
folder before that file was written. The file exists and carries D-1 through D-6; no citation is affected.

Everything else the verification pass checked came back clean:

- All 13 names on both pages declare `arguments: size` and carry a `## Sizing` section.
- The alphabetical order holds.
- Every link resolves.
- S-4's claim matches `han-reporting/skills/` and its manifest.
- The pinned HTML survives this repository's Prettier config unchanged.
- All three of the issue's asks are covered.
- Every pinned line fits inside 120 columns.

**Findings labeled `Unverified`.** None. Every claim in this plan rests on a file in this repository that was read
directly, or on `git log` output from it. One class of evidence is outside the run's reach and is named rather than
implied. The reader-impact findings `I-1` through `I-4` are design reasoning from established practice applied to the
text, not measurements of reader behavior.

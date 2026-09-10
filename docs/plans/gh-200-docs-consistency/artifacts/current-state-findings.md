# Current State Findings: GitHub issue #200 documentation consistency

## Provenance

Produced by this run's own discovery round on 2026-09-10. No prior findings report existed.

The area given to every agent: `docs/quickstart.md`, `docs/concepts.md`, `docs/choosing-a-han-plugin.md`,
`docs/sizing.md`, `README.md`, `CONTRIBUTING.md`, and the ground-truth sources those pages describe
(`han-*/skills/*/SKILL.md` frontmatter, `han-*/.claude-plugin/plugin.json`).

Agents dispatched:

- `han-core:structural-analyst` — duplicated facts across documentation surfaces, drift direction against ground truth,
  and which checklist governs updates.
- `han-core:information-architect` — reader impact of the contradictions, against the named audience of a new reader
  choosing a plugin.

Two agents named "always" by the skill's Step 2 were deliberately not dispatched, and the reason is recorded here rather
than left silent:

- `han-core:behavioral-analyst` analyzes runtime data flow, error propagation, and state. The area is a set of markdown
  files with no runtime, so the agent's domain has no subject here. `han-core:information-architect` was dispatched in
  its place, because reader impact is the closest analogue to "behavior" that this area actually has.
- `han-core:concurrency-analyst` was not dispatched because the area contains no concurrent access, async coordination,
  or shared mutable state. The skill already gates this agent on that condition.

Findings C-1 through C-12 were established by the run's own Glob, Grep, and `git log` sweep before the agents returned.
Agent findings are folded in below with the originating identifier on each.

## Project Context

- **Stack:** Markdown for skill, agent, and documentation content; Bash for skill `scripts/` and the shared repo-root
  `scripts/`. No application build and no dev server.
- **Conventions source:** `CLAUDE.md`, `## Project Discovery` and `## Conventions` sections. The governing convention
  for this change is stated there: "One canonical source per concept."
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md`. It covers the project-configurable default
  swarm size and does not bear on which pages enumerate the sizing-aware skills.
- **Coding standards found:** `CONTRIBUTING.md` carries the numbered checklist for adding a skill.
  `docs/templates/coverage-rule.md` carries the long-form documentation coverage rule. Neither is a code standard in the
  usual sense; the repo's content is prose.
- **Recent churn:** All six in-scope files changed within the last 90 days. `CONTRIBUTING.md` 35 commits,
  `docs/concepts.md` 27, `README.md` 20, `docs/choosing-a-han-plugin.md` 19, `docs/sizing.md` 15,
  `docs/quickstart.md` 13. This is a high-churn documentation set, which is the condition under which duplicated facts
  drift.
- **Test tooling:** `npm test` runs Bats over every `*.bats` file outside `node_modules`. `npm run lint` runs
  `prek run --all-files` (Prettier, ShellCheck, file hygiene). No test in the repo asserts anything about the
  documentation catalogs; see C-12.

## Gaps

What was searched for and not found:

- **No test or lint check covers catalog membership.** Searched the Bats suites under `test/` and beside each script.
  Nothing asserts that a skill declaring `arguments: size` appears in any documentation list. The consistency this
  change restores is maintained by human discipline alone.
- **No accessibility standard in this repo covers image alt text.** The personal rule set at
  `~/.claude/references/the-book/general/accessibility.md` covers descriptive page titles and semantic HTML tables. It
  does not mention `alt` attributes, so the fix in C-11 rests on general practice rather than on a project standard.
- **No ADR records why three pages each enumerate the sizing-aware skills.** Searched `docs/adr/`. The duplication
  appears to be accretion rather than a recorded decision, which means no prior decision has to be reversed to remove
  it.
- **No alt-text precedent exists in the repo.** `README.md:3` is the only image embed in any README or doc file
  (C-11), so there is no house style to match.

## Findings

### C-1: Three documentation pages independently enumerate the sizing-aware skills, with three different memberships

- **Claim:** The list of skills that accept a size argument is stated as settled fact on three pages, and the three
  disagree. `docs/sizing.md` names 13, `docs/concepts.md` names 12, `docs/quickstart.md` names 9.
- **Location:** `docs/sizing.md:6-9`, `docs/concepts.md:136-145`, `docs/quickstart.md:196-198`. The quickstart's
  sentence ends part-way through line 198, and the next sentence begins on that same line; the paragraph runs to
  line 200. Corrected from `196-197` by `han-core:gap-analyzer` (`GAP-003`).
- **Evidence:**

  ```
  docs/sizing.md:6   The sizing-aware skills are `/architectural-analysis`, `/automated-test-planning`,
                     `/code-overview`, `/code-review`, `/code-walkthrough`, `/ddd-analysis`, `/design-an-api`,
                     `/gap-analysis`, `/iterative-plan-review`, `/plan-a-change`, `/plan-a-feature`,
                     `/plan-implementation`, and `/research`.

  docs/concepts.md:136  - **Sizing-aware skills.** [`/architectural-analysis`](...),
                        [`/automated-test-planning`](...), [`/code-overview`](...), [`/code-review`](...),
                        [`/code-walkthrough`](...), [`/design-an-api`](...), [`/gap-analysis`](...),
                        [`/iterative-plan-review`](...), [`/plan-a-change`](...), [`/plan-a-feature`](...),
                        [`/plan-implementation`](...), [`/research`](...).

  docs/quickstart.md:196  The sizing-aware skills (`/architectural-analysis`, `/code-overview`, `/code-review`,
                          `/code-walkthrough`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`,
                          `/plan-implementation`, `/research`) classify the work as **small**, **medium**, or
                          **large** before dispatching agents.
  ```

- **Raised by:** This run's own sweep; independently confirmed by `han-core:information-architect` as `I-2`.
- **Confidence:** Verified.
- **Bears on:** S-1, S-2, D-1.

### C-2: Fourteen skills declare a size argument, and that frontmatter is the ground truth

- **Claim:** The authoritative membership is the `arguments: size` field in each skill's frontmatter. Fourteen skills
  declare it. No documentation page lists all fourteen, and none is expected to: `plan-a-feature-to-confluence` is a
  wrapper in the opt-in `han-atlassian` plugin.
- **Location:** `han-*/skills/*/SKILL.md` frontmatter.
- **Evidence:**

  ```
  $ for f in han-*/skills/*/SKILL.md; do grep -qE '^arguments:.*size' "$f" && basename $(dirname $f); done | sort
  architectural-analysis        gap-analysis
  automated-test-planning       iterative-plan-review
  code-overview                 plan-a-change
  code-review                   plan-a-feature
  code-walkthrough              plan-a-feature-to-confluence
  ddd-analysis                  plan-implementation
  design-an-api                 research
  ```

- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** S-1, S-2, D-1.

### C-3: `docs/sizing.md` is correct and complete, and the issue never mentions it

- **Claim:** `docs/sizing.md` lists every sizing-aware skill in the installable suite. It omits only
  `plan-a-feature-to-confluence`, the opt-in Atlassian wrapper. It needs no content change.
- **Location:** `docs/sizing.md:6-9`.
- **Evidence:** The 13 names at `docs/sizing.md:6-9` match C-2's fourteen minus `plan-a-feature-to-confluence`.
- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** D-1.

### C-4: `docs/sizing.md` restates the same membership three times inside one file, and all three agree

- **Claim:** The canonical page carries the membership in three forms: a prose list, an at-a-glance comparison table
  with one row per skill, and a per-skill link list under "See also". All three name the same 13 skills.
- **Location:** `docs/sizing.md:6-9` (prose), `docs/sizing.md:113-125` (table rows), `docs/sizing.md:154-163` (links).
- **Evidence:**

  ```
  $ sed -n '108,130p' docs/sizing.md | grep -oE '^\| \[`/[a-z-]+`\]'
  | [`/architectural-analysis`]   | [`/design-an-api`]        | [`/plan-a-feature`]
  | [`/automated-test-planning`]  | [`/gap-analysis`]         | [`/plan-implementation`]
  | [`/code-overview`]            | [`/iterative-plan-review`]| [`/research`]
  | [`/code-review`]              | [`/plan-a-change`]
  | [`/code-walkthrough`]         | [`/ddd-analysis`]
  ```

- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** D-1. This matters because it bounds the target state: consolidating onto `sizing.md` does not mean one
  list in the repo, it means one _page_ that owns the membership.

### C-5: The quickstart's list has not been updated in almost four months, and four skills entered the catalogs in that window

- **Claim:** The last commit to touch the quickstart's sizing list was 2026-05-29. Between then and 2026-09-09, four
  skills were added to the sizing catalogs. None of those four commits touched `docs/quickstart.md`.
- **Location:** Git history over `docs/quickstart.md`, `docs/concepts.md`, `docs/sizing.md`.
- **Evidence:**

  ```
  $ git log -1 --format="%h %ad %s" --date=short -S"sizing-aware skills (\`/architectural-analysis\`" -- docs/quickstart.md
  b82f702 2026-05-29 docs: document work-items-to-issues and scrub skill counts

  # Commits that added a skill to a sizing catalog since then, and which pages each touched:
  f4dc3d8 2026-08-10 docs: list design-an-api as a sizing-aware skill
      docs/concepts.md | 1 +      docs/sizing.md | 27 +-        (quickstart.md untouched)
  c5b4b91 2026-09-09 feat(han-coding): size automated-test-planning runs to the question asked
      docs/sizing.md | 32 +-                                    (concepts.md, quickstart.md untouched)
  9f8a8eb 2026-09-09 docs: wire plan-a-change and ddd-analysis into the cross-plugin surfaces
      docs/concepts.md | 15 +-    docs/sizing.md | 6 +-         (quickstart.md untouched)
  1c19171 2026-09-09 docs: close the documentation gaps the branch left open
      docs/sizing.md | 37 +-                                    (concepts.md, quickstart.md untouched)
  ```

- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** C-6, D-1, D-2.

### C-6: `CONTRIBUTING.md` step 6 names two catalogs and not the quickstart

- **Claim:** The checklist a contributor follows when adding a sizing-aware skill names `docs/sizing.md` and
  `docs/concepts.md`. It does not name `docs/quickstart.md`. This is the mechanism behind C-5.
- **Location:** `CONTRIBUTING.md:194-197`.
- **Evidence:**

  ```
  6. If the skill classifies its work as small / medium / large, add it to the sizing-aware list and the at-a-glance
     table in [Sizing](./docs/sizing.md), to the sizing-aware list in [Concepts](./docs/concepts.md), and give its
     long-form doc a `## Sizing` section. A sizing-aware skill that never lands in those catalogs is invisible to anyone
     reading them to learn which skills scale.
  ```

- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** S-5, D-2.

### C-7: `han-reporting` declares only `han-communication`, and it is the only layer plugin that does

- **Claim:** Every other layer plugin declares both `han-communication` and `han-core`. `han-reporting` declares
  `han-communication` alone, so installing it alone does not bring the shared agent roster.
- **Location:** `han-*/.claude-plugin/plugin.json`.
- **Evidence:**

  ```
  han-coding         ['han-communication', 'han-core']
  han-documentation  ['han-communication', 'han-core']
  han-planning       ['han-communication', 'han-core']
  han-research       ['han-communication', 'han-core']
  han-github         ['han-communication', 'han-core', 'han-coding']
  han-reporting      ['han-communication']
  ```

- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** S-3, S-4, D-3.

### C-8: `docs/choosing-a-han-plugin.md` states the exception correctly and then denies it two lines later, in bold

- **Claim:** Line 82 carries the correct exception in a trailing parenthetical. Line 84 generalizes over it in bold,
  directly under the heading "The one thing that surprises people".
- **Location:** `docs/choosing-a-han-plugin.md:82` and `:84`.
- **Evidence:**

  ```
  82: readability standard either way. (`han-reporting` is the exception: it depends on `han-communication` alone.)
  83:
  84: That means **every layer install comes with the shared agents.** The real choice comes down to:
  ```

- **Raised by:** This run's own sweep; reader impact established by `han-core:information-architect` as `I-1`.
- **Confidence:** Verified.
- **Bears on:** S-3, D-3.

### C-9: `docs/concepts.md` states the exception correctly and then denies it seventeen lines later

- **Claim:** Line 248 states the `han-reporting` exception correctly. Line 265 lists "reporting-only" among installs
  that do not exist. Reporting-only is exactly the install that is possible.
- **Location:** `docs/concepts.md:248` and `:265`.
- **Evidence:**

  ```
  247: along; `han-reporting` depends only on `han-communication`.
  ...
  264: The practical choice is core only, the bundled suite, or the suite plus whichever opt-in plugins you want.
  265: There is no planning-only, coding-only, GitHub-only, or reporting-only install.
  ```

  The other three named in line 265 are correct: `han-planning`, `han-coding`, and `han-github` all declare `han-core`
  per C-7.

- **Raised by:** This run's own sweep. The issue reports line 265 but does not note that the same file already states
  the correct version at line 248.
- **Confidence:** Verified.
- **Bears on:** S-4, D-3.

### C-10: No other page in the repo states the layer-dependency claim incorrectly

- **Claim:** Outside the two passages in C-8 and C-9, every statement about `han-reporting`'s dependencies is correct,
  including the one in `CLAUDE.md`. The blast radius of the fix is two lines in two files.
- **Location:** Repo-wide grep over `docs/`, `README.md`, `CLAUDE.md`, and every plugin `README.md`, excluding
  `docs/plans/`.
- **Evidence:** 24 matches for `han-reporting` across those files. The only two asserting that every layer brings
  `han-core` are `docs/choosing-a-han-plugin.md:84` and `docs/concepts.md:265`.
- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** S-3, S-4.

### C-11: The banner image is at `README.md:3`, not `:5`, and it is the only image embed in the repo's prose

- **Claim:** The front-door banner carries no `alt` attribute. The issue cites `README.md:5`; the current line is 3.
  The issue warned that its line numbers may have drifted and that the quoted text is the reliable anchor, and it has.
- **Location:** `README.md:3`.
- **Evidence:**

  ```
  $ grep -rn "<img\|!\[" README.md CONTRIBUTING.md docs/*.md han-*/README.md
  README.md:3:<img src="images/han-banner.png">
  ```

  The image itself carries text a sighted reader receives and a screen-reader user does not: the wordmark "Han", the
  tagline "your agentic ally for Solo product engineers", the phrase "agent - swarm - skills", and four labeled
  workflow stages reading PLAN, REVIEW, BUILD, INVESTIGATE.

- **Raised by:** This run's own sweep; reader impact established by `han-core:information-architect` as `I-4`.
- **Confidence:** Verified.
- **Bears on:** S-6, D-4.

### C-12: Nothing automated checks that a sizing-aware skill reaches the documentation catalogs

- **Claim:** `npm test` runs Bats over the repo's scripts, and `npm run lint` runs Prettier, ShellCheck, and file
  hygiene. No check reads skill frontmatter and compares it against any documentation list. C-5's four-month drift was
  therefore invisible to CI.
- **Location:** `package.json` scripts; the Bats suites under `test/` and beside each script.
- **Evidence:** No Bats file references `arguments: size`, `sizing-aware`, `docs/sizing.md`, `docs/concepts.md`, or
  `docs/quickstart.md`.
- **Raised by:** This run's own sweep.
- **Confidence:** Verified.
- **Bears on:** The YAGNI section. An automated check is the structurally complete fix and is out of the recorded
  boundary; see `change-plan.md#deferred-yagni`.

## Findings No Agent Could Audit

Every claim above rests on a file in this repository that was read directly, or on `git log` output from this
repository. Nothing in the area depends on a runtime that could not be executed, a data shape that exists only in
production, or a dependency whose source is not vendored.

One class of evidence is outside the run's reach and is named here rather than left implicit: how a reader actually
moves through these pages. The reader-impact findings from `han-core:information-architect` (`I-1` through `I-4`) are
reasoned from established information-architecture practice applied to the text, not from observed reader behavior.
They are sound as design reasoning and are not presented as measurements.

# Change Decision Log: Codex Marketplace Catalog Consistency

<!--
This file records every decision committed while planning the Codex marketplace
catalog consistency change. The plan itself lives in
[../change-plan.md](../change-plan.md) — this file captures the question,
rationale, evidence, and rejected alternatives behind each decision. Evidence
about the code as it stands today lives in
[current-state-findings.md](current-state-findings.md) as numbered C-N findings.
-->

## Trivial decisions

- D-12: `README.md` needs no edit — its Codex section already names all thirteen packages correctly, eight in the
  install block and five in the prose sentence, so the file the operator named as in-scope requires no change
  ([C-1](current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets)). —
  Referenced in plan: Target State.
- D-13: No version is bumped anywhere by this change — the plan adds a new file at its baseline and edits no existing
  version field. — Referenced in plan: Risks.

## Full decisions

### D-1: The directory tree is the authority

- **Question:** Which of the four lists that enumerate Codex-installable packages is authoritative, so the other files
  can be checked against it?
- **Decision:** The `han-*` directory tree. Every `han-*` directory except `han/` must carry a Codex manifest and a
  catalog entry. The check's subject is the tree, expressed as the glob `han-*/`, which excludes the `han` meta-plugin
  structurally rather than by an exception list.
- **Rationale:** The operator chose this reading over the alternative, that the README's install list decides, because
  it is the reading that would have caught the defect when `han-linear` and `han-ddd` landed. A README-driven check
  would also need a machine-readable marker inside prose that has none.
- **Evidence:** Operator answer, quoted in [scope-boundary.md](scope-boundary.md) Operator-Stated Scope: "directory
  tree". Supported by
  [C-1](current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets), which
  shows no list currently derives from another.
- **Behavior impact:** Preserving on its own. It shapes S-5, whose classification is Changing.
- **Rejected alternatives:**
  - The README's install list decides — rejected because the operator chose otherwise, and because the five opt-in
    packages appear in a prose sentence with no marker a check could read.
  - The catalog decides — rejected because it is the file that was wrong; making it authoritative would make the defect
    correct by definition.
- **Revisit criterion:** If a `han-*` directory is ever added that deliberately ships to Claude Code and not to Codex,
  the glob stops being the right expression of the authority and needs an explicit exclusion list.
- **Dissent (if any):** None.
- **Settles delta entry:** —
- **Dependent decisions:** D-5, D-6, D-10.
- **Referenced in plan:** What Changes, In One Paragraph; Surface Delta S-1, S-2.

### D-2: New catalog entries take the existing form and the existing order position

- **Question:** What shape does a new catalog entry take, and where in the array does it go?
- **Decision:** The four-key form every existing entry uses, with `name` and `source.path` supplied per plugin and
  `policy` and `category` copied verbatim:

  ```json
  {
    "name": "han-linear",
    "source": { "source": "local", "path": "./han-linear" },
    "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
    "category": "Developer Tools"
  }
  ```

  Position: `han-documentation` and `han-research` go after `han-core` and before `han-planning`; `han-linear` goes
  between `han-atlassian` and `han-ddd`.

- **Rationale:** All ten existing entries are identical in shape, and two of their three non-identity fields never vary,
  so a new entry has exactly one correct form. The position is not cosmetic guesswork: the Codex catalog's order is the
  Claude marketplace's order with its four omissions removed, so restoring the omitted names to their Claude positions
  is the only placement consistent with the file as it stands.
- **Evidence:**
  [C-5](current-state-findings.md#c-5-every-catalog-entry-carries-the-same-four-keys-with-the-same-constant-values) for
  the form;
  [C-17](current-state-findings.md#c-17-the-codex-catalogs-entry-order-is-the-claude-marketplaces-order-with-its-omissions-removed)
  for the position.
- **Behavior impact:** Changing. A Codex user who runs `codex plugin add han-documentation@han` sees an error today and
  an installed package afterwards. Settled by the recorded boundary rather than by escalation: items 1 and 3 of the
  issue's suggested fix ask for exactly these entries, quoted word for word in
  [scope-boundary.md](scope-boundary.md) Stated Scope.
- **Rejected alternatives:**
  - Alphabetical placement — rejected because neither marketplace file is alphabetical; both follow the suite's
    dependency order.
  - Appending to the end of the array — rejected for the same reason; it would put a foundational plugin after the
    opt-in ones.
- **Revisit criterion:** If the catalog schema gains a field that varies per plugin, the "copy the constants" rule stops
  holding.
- **Dissent (if any):** None.
- **Settles delta entry:** S-1, S-2, S-4.
- **Dependent decisions:** D-6.
- **Referenced in plan:** Target State; Surface Delta S-1, S-2, S-4.

### D-3: The `han-linear` Codex manifest's field layout

- **Question:** What does the new `han-linear/.codex-plugin/plugin.json` contain, field by field?
- **Decision:** The full manifest is written out in [../change-plan.md](../change-plan.md) under Surface Delta S-3. Nine
  fields are copied verbatim from any sibling manifest because they are byte-identical across all twelve: `author`,
  `homepage`, `repository`, `license`, `skills`, and the `interface` keys `developerName`, `category`, `capabilities`,
  and `websiteURL`. Eight fields are supplied by the package: `name`, `version`, `description`, `keywords`, and the
  `interface` keys `displayName`, `shortDescription`, `longDescription`, and `defaultPrompt`. The `keywords` array
  follows the suite's own pattern, `"han"` first and the package's topic second: `["han", "linear", "work-items",
"issues"]`.
- **Rationale:** A manifest two tools read independently is a contract, so it is pinned as a worked example rather than
  a field list. The prose is drawn from `han-linear/README.md` and the skill's own description, matching the length
  register of the existing twelve: a one-sentence `shortDescription`, a `longDescription` naming what the skill does,
  and three `defaultPrompt` entries, which eleven of twelve use.
- **Evidence:** [C-6](current-state-findings.md#c-6-all-twelve-codex-manifests-carry-an-identical-key-set) for the key
  set; the nine constant values re-derived across all twelve manifests by this run;
  `han-linear/skills/work-items-to-linear/SKILL.md` and `han-linear/README.md` for the prose.
- **Behavior impact:** Changing. A Codex user gains a package that has never been installable. Settled by the recorded
  boundary's item 2, quoted word for word in [scope-boundary.md](scope-boundary.md) Stated Scope.
- **Rejected alternatives:**
  - Copying the Claude manifest's description verbatim — rejected because the Codex manifest carries three
    description-like strings at three deliberate lengths, and the Claude text is written for a different surface
    ([C-9](current-state-findings.md#c-9-the-same-plugins-description-is-authored-independently-in-three-places-and-has-drifted-in-all-twelve)).
  - A minimal manifest carrying only `name`, `version`, and `skills` — rejected because it would be the only manifest of
    the thirteen missing the storefront fields, and the check would not catch that.
- **Revisit criterion:** If the Codex manifest schema gains a required field, all thirteen manifests need it, not just
  this one.
- **Dissent (if any):** None.
- **Settles delta entry:** S-3.
- **Dependent decisions:** D-4.
- **Referenced in plan:** Target State; Surface Delta S-3.

### D-4: The new Codex manifest ships at `1.0.0`

- **Question:** Should `han-linear`'s Codex manifest carry `1.0.0`, or mirror its Claude manifest's `1.1.1`?
- **Decision:** `1.0.0`.
- **Rationale:** Three reasons, in order of weight. First, the repository's own release rule says so: "A brand-new
  plugin is not bumped by the release that introduces it. Its `plugin.json` version is its established baseline." A
  Codex manifest that has never existed on any commit is exactly that case. Second, there is nothing to be compatible
  with, so no installed user can be stranded by starting at `1.0.0`. Third, the two version fields are separate
  lineages: the release skill bumps `{source}/.claude-plugin/plugin.json` and the Claude marketplace and contains no
  reference to Codex at all, so seeding `1.1.1` would manufacture a parity the next release destroys, and would invite
  someone to later "fix" the other eleven to match.
- **Evidence:** `.claude/skills/han-release/SKILL.md` lines 165 through 168 for the baseline rule, and the same file's
  Step 4 for the paths it bumps, both read directly by this run;
  [C-4](current-state-findings.md#c-4-han-linear-fails-one-layer-earlier-because-no-codex-manifest-exists-at-all) for the
  file never having existed;
  [C-8](current-state-findings.md#c-8-the-version-field-differs-between-the-two-manifests-for-eleven-of-twelve-plugins)
  for the drift table.
- **Behavior impact:** Part of S-3's Changing classification rather than a separate observable change. `han-linear` has
  never been installable under Codex, so no user has a prior version to compare against.
- **Rejected alternatives:**
  - Mirror the Claude `1.1.1` — rejected because it manufactures a parity nothing maintains, and the argument for it
    (avoiding a downgrade) protects against a break that cannot happen for a package never published.
  - Bump `han-linear`'s Claude version alongside — rejected outright. Nothing asked for a version bump, and the release
    skill owns that decision at release time.
- **Revisit criterion:** If Codex is found to compare a manifest version against an installed one in a way that gates
  upgrades. This could not be inspected, because no Codex CLI was available; the choice is arranged to hold either way.
- **Dissent (if any):** None.
- **Settles delta entry:** S-3.
- **Dependent decisions:** None.
- **Referenced in plan:** Surface Delta S-3; Risks.

### D-5: The check is one Bats file in `test/`, using bash and grep only

- **Question:** What form should the consistency check take, and where does it live?
- **Decision:** A single Bats file at `test/codex-packaging.bats`, depending on bash, grep, POSIX file tests, and Bats,
  and on nothing else. No companion shell script, no prek hook, no generator. Its header comment states the invariant,
  names the commit that broke it, and records the Prettier formatting dependency the literal greps rest on.
- **Rationale:** The repository has one worked example of a cross-file consistency check and it uses bash and grep only.
  Placement in `test/` follows the repository's own stated convention: script tests sit beside the script they cover,
  and `test/` holds checks whose subject is the repository rather than any one script. This check covers no script. The
  file is discovered by `npm test` with no registration step and runs in CI on every pull request.
- **Evidence:**
  [C-11](current-state-findings.md#c-11-scriptshan-config-dirbats-is-the-repos-one-worked-example-of-a-cross-file-consistency-check)
  for the pattern and the convention;
  [C-12](current-state-findings.md#c-12-npm-test-discovers-every-bats-file-in-the-tree-with-no-registration-step) for
  discovery;
  [C-13](current-state-findings.md#c-13-node-is-guaranteed-to-the-test-job-jq-is-not-pinned-anywhere) for the tool
  constraint; [C-10](current-state-findings.md#c-10-nothing-in-the-test-lint-or-ci-chain-reads-any-manifest-or-marketplace-file)
  and [C-15](current-state-findings.md#c-15-the-drift-entered-on-a-commit-that-updated-the-claude-marketplace-and-not-the-codex-catalog)
  for why a check is needed at all.
- **Behavior impact:** Changing. A contributor who adds a `han-*` directory without both files sees `npm test` fail
  where it passed before. Settled by the recorded boundary's item 4, quoted word for word in
  [scope-boundary.md](scope-boundary.md) Stated Scope.
- **Rejected alternatives:**
  - A shell script plus a Bats file, matching the `han-config-dir.sh` and `.bats` pairing — rejected because that
    pairing exists for a script a skill invokes at runtime, so the script has a second caller. This check has exactly
    one caller, `npm test`. A script here is a single-implementation abstraction with no named second use.
  - A prek hook — rejected because it duplicates a signal CI already gives on every pull request, and adds a second
    place a contributor's failure can originate. No evidence of commit-time friction is recorded.
  - Generating the catalog from the tree — rejected on cost. It needs a generator, a freshness check, and a JSON writer
    in a repository whose tooling is Prettier, ShellCheck, and Bats, with `jq` pinned nowhere. The catalog has changed
    five times in its whole history.
  - Reaching for `node -e` to parse the JSON — rejected because it introduces a second language into a Bats suite that
    has none, for a check two `grep -F` calls satisfy. `node` is available; that is cost avoided, not evidence.
- **Revisit criterion:** Each rejected alternative carries its own trigger, recorded in the plan's Deferred (YAGNI)
  section.
- **Dissent (if any):** None.
- **Settles delta entry:** S-5.
- **Dependent decisions:** D-6, D-7, D-9.
- **Referenced in plan:** Target State; Surface Delta S-5; Change Units Unit 3.

### D-6: The check asserts three things, and not six others

- **Question:** Which invariants does the check assert, and which tempting ones does it leave alone?
- **Decision:** Three assertions. First, the `han-*/` enumeration is non-empty, so the other two cannot pass over an
  empty set. Second, for every package, `<package>/.codex-plugin/plugin.json` is a regular file. Third, for every
  package, the catalog holds the literals `"name": "han-x"` and `"path": "./han-x"` **within one entry**, matched with a
  three-line window rather than tested for presence anywhere in the file.

  Not asserted: version parity between the Claude and Codex manifests; description parity; the manifest key set;
  constant-value assertions on the catalog's `policy`, `category`, and `source.source`; agreement between the README's
  install list and the tree; and JSON validity.

- **Rationale:** Each assertion maps to a symptom the issue reports. The first catches the `han-linear` class, the
  third catches the `han-documentation` and `han-research` class. The third asserts both literals rather than one
  because the realistic authoring error is copying an existing entry and changing only one of the two fields, and either
  single-field slip leaves the other literal absent. It scopes them to a single entry because two independent greps
  would pass on a catalog holding the name in one entry and the path in another.

  The non-empty assertion is required rather than optional. Three reviewers raised it independently, and it needs
  pinning because the safe-looking implementation is the dangerous one. Two shapes pass vacuously: piping into
  `while read`, whose loop body runs in a subshell where `return 1` cannot fail the test, and setting `shopt -s
nullglob`, which turns zero matches into zero iterations. Neither hazard is present today, which is exactly why a
  builder would introduce one without noticing.

  The exclusions divide into two groups. Version and description parity are false today, for eleven of twelve and
  twelve of twelve pairs, so asserting either would fail the build the day it landed, and neither is a latent goal: the
  release skill touches only the Claude side, so forced parity would break again at the next release. The key-set,
  constant-value, README, and JSON-validity assertions would all pass today and are rejected as symmetry, a named YAGNI
  anti-pattern. Prettier already parses these files, which is why `.pre-commit-config.yaml` omits `check-json` by its
  own stated reasoning.

- **Evidence:**
  [C-1](current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets) for
  the symptom mapping;
  [C-8](current-state-findings.md#c-8-the-version-field-differs-between-the-two-manifests-for-eleven-of-twelve-plugins)
  and [C-9](current-state-findings.md#c-9-the-same-plugins-description-is-authored-independently-in-three-places-and-has-drifted-in-all-twelve)
  for the two that would fail;
  [C-5](current-state-findings.md#c-5-every-catalog-entry-carries-the-same-four-keys-with-the-same-constant-values) and
  [C-6](current-state-findings.md#c-6-all-twelve-codex-manifests-carry-an-identical-key-set) for the two that would pass
  and are rejected anyway;
  [C-10](current-state-findings.md#c-10-nothing-in-the-test-lint-or-ci-chain-reads-any-manifest-or-marketplace-file) for
  Prettier's ownership of JSON parsing.
- **Behavior impact:** Part of S-5's Changing classification.
- **Rejected alternatives:**
  - Assert version parity — rejected because it fails for eleven of twelve pairs today
    ([C-8](current-state-findings.md#c-8-the-version-field-differs-between-the-two-manifests-for-eleven-of-twelve-plugins)).
  - Assert the manifest key set — rejected as symmetry; it needs field-level JSON reading with no `jq`, and no reported
    failure was caused by a missing field.
  - Assert only manifest presence, dropping the catalog assertions — rejected because that is the simpler version and it
    does not catch the reported error, which is a catalog miss
    ([C-3](current-state-findings.md#c-3-han-documentation-and-han-research-fail-at-the-catalog-step-with-correct-manifests-never-reached)).
- **Revisit criterion:** Recorded per-alternative in the plan's Deferred (YAGNI) section.
- **Dissent (if any):** None.
- **Settles delta entry:** S-5.
- **Dependent decisions:** D-10.
- **Referenced in plan:** Surface Delta S-5; Deferred (YAGNI).

### D-7: The check's failure output names the package and the repair

- **Question:** What does a contributor see when the check fails?
- **Decision:** Each failing test prints one line per offending package before returning 1. The literal forms:

  ```
  codex manifest missing: han-linear/.codex-plugin/plugin.json (copy han-ddd/.codex-plugin/plugin.json and edit the package-specific fields)
  catalog entry missing: add "name": "han-linear" with "path": "./han-linear" to .agents/plugins/marketplace.json
  ```

- **Rationale:** What the check says is a contract between the check and the person reading a failed CI run, and they
  cannot see each other. A message naming only "consistency check failed" makes the reader re-derive the repair from a
  file they have probably never opened. Both lines name the file to create or edit and what to put in it.
- **Evidence:** [C-14](current-state-findings.md#c-14-contributingmd-has-no-section-for-adding-a-plugin-and-never-names-the-codex-surface)
  makes this load-bearing: there is no written process for adding a plugin, so the failure message is the only guidance
  a contributor gets.
- **Behavior impact:** Part of S-5's Changing classification. The observer is a contributor reading a failed CI run.
- **Rejected alternatives:**
  - A bare assertion with no message — rejected because Bats would print only the failing line number, and the repair
    lives in two files the reader has no reason to know about.
- **Revisit criterion:** If the check fires on a real contributor branch and the message proves insufficient.
- **Dissent (if any):** None.
- **Settles delta entry:** S-5.
- **Dependent decisions:** None.
- **Referenced in plan:** Target State, "The check's failure output"; Surface Delta S-5.

### D-8: `CLAUDE.md` line 83 is inside the recorded area

- **Question:** The operator confirmed an area that did not name `CLAUDE.md`. Does correcting its statement that
  `han-linear` carries no Codex manifest belong in this change or in separate work?
- **Decision:** In this change. S-6 rewrites line 83 to say every `han-*` plugin carries a Codex manifest, with `han/`
  excluded because Codex has no meta-plugins.
- **Rationale:** Three things settle it without the operator. The line goes false the moment S-3 lands, so this is not
  a stale line the change happens to pass by; the change is what makes it wrong. The repository has a worked precedent:
  `556b49e` added `han-ddd` and updated the Codex catalog, the Claude marketplace, and `CLAUDE.md` in one commit, while
  `2c09799`, the commit that caused this defect, updated neither the Codex catalog nor the map. And the operator's
  "yes" was given to a four-item list this run proposed; a yes to four named things is weak evidence that a fifth was
  excluded, since it was never in front of them.

  One correction to the reasoning that reached this decision: an earlier framing of mine held that line 83 is how the
  defect arose. It is not. The wording entered on `d62e1eb`, five days after the drift commit, in a documentation audit
  that saw the gap and recorded it as intent. It documents the defect rather than causing it. The decision does not
  depend on the causal claim, and the claim is dropped.

- **Evidence:** [C-16](current-state-findings.md#c-16-claudemd-records-the-han-linear-manifest-gap-as-though-it-were-the-intended-design)
  for the current wording; `git show --stat 556b49e` and `git log -S` on the line's text, both run by this run, for the
  precedent and the chronology; [scope-boundary.md](scope-boundary.md) Operator-Stated Scope for what the operator
  actually answered; `han-core:junior-developer` reframing for the "yes to a proposed list" argument and the chronology
  correction.
- **Behavior impact:** Changing. The observer is an agent or contributor reading the repository map, who is told a Codex
  manifest is required rather than optional. No install, command, or test outcome differs, and no automated reader is
  affected: no `.bats` file in the repository greps `CLAUDE.md`'s content. An earlier draft labeled this Preserving,
  which was too broad, because the entry's whole justification is that a reader acts differently afterwards.
- **Rejected alternatives:**
  - Leave line 83 and raise it as separate work — rejected because it leaves the file every agent reads each session
    asserting that a file this change just created does not exist, in the same form that recorded the last gap as
    intent.
  - Escalate to the operator — rejected because the precedent and the "your own edit makes it false" argument settle it,
    and the boundary excludes nothing here.
- **Revisit criterion:** If the operator says `CLAUDE.md` is out of bounds for this change.
- **Dissent (if any):** None. `han-core:junior-developer` initially framed this as the one question worth the
  operator's time, then concluded on the precedent that line 83 specifically does not need them.
- **Settles delta entry:** S-6.
- **Dependent decisions:** D-11.
- **Referenced in plan:** Surface Delta S-6; Change Units Unit 2.

### D-9: The `sanity.bats` header is amended rather than the check relocated

- **Question:** `test/sanity.bats` states that `test/` keeps only harness-level checks. Adding `test/codex-packaging.bats`
  contradicts it. Amend the comment, or put the check somewhere else?
- **Decision:** Amend the comment. It becomes: `test/` holds harness-level checks and repository-wide structural
  invariants that cover no single script.
- **Rationale:** The convention that comment states has a real basis, that a script's tests sit beside the script. This
  check covers no script, so the alternative locations are worse: beside a JSON file it reads, or in `scripts/` next to
  nothing. The comment describes a two-category directory as a one-category one; the check is the second category
  arriving.
- **Evidence:** [C-11](current-state-findings.md#c-11-scriptshan-config-dirbats-is-the-repos-one-worked-example-of-a-cross-file-consistency-check)
  for the stated convention and the sibling pattern.
- **Behavior impact:** Changing. The observer is a contributor deciding where to put a new test: a class of test that
  had no stated home now has one. No test outcome differs. Corrected from Preserving for the same reason as D-8.
- **Rejected alternatives:**
  - Put the check at `.agents/plugins/codex-packaging.bats`, beside the file it reads — rejected because it drops a
    non-manifest file into a directory a third-party CLI scans, and whether Codex tolerates that could not be inspected.
  - Leave the comment stale — rejected for the same reason as D-8: a written statement contradicting the file beside it.
- **Revisit criterion:** None foreseen.
- **Dissent (if any):** None.
- **Settles delta entry:** S-7.
- **Dependent decisions:** None.
- **Referenced in plan:** Surface Delta S-7.

### D-10: The reverse check is deferred

- **Question:** Should the check also assert the other direction, that every catalog entry names something that exists?
- **Decision:** Deferred, with the reopening trigger recorded, and with a note that the stronger form is the one to
  build if it is reopened.
- **Rationale:** The issue's item 4 is one-directional: every package advertised for Codex has a manifest and a catalog
  entry. "The tree is the authority" answers which file wins when the two disagree; it does not say the catalog holds
  nothing else. Set equality is an additional commitment rather than an entailment of authority. On evidence, the
  orphan-entry failure has never occurred here, while the failure that did occur ran tree to catalog. "It costs one
  grep" is cost, not evidence.

  If reopened, assert the stronger form. The architect proposed checking that an entry names an existing directory. The
  failure that actually breaks a user is an entry resolving to a directory with no Codex manifest, because that is what
  an install reads second.

- **Evidence:**
  [C-1](current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets) shows
  zero orphan entries today;
  [C-15](current-state-findings.md#c-15-the-drift-entered-on-a-commit-that-updated-the-claude-marketplace-and-not-the-codex-catalog)
  shows the direction the real failure ran;
  [C-2](current-state-findings.md#c-2-a-codex-install-reads-the-catalog-first-and-the-per-plugin-manifest-second) for
  why the entry-to-manifest form is the stronger one; `han-core:junior-developer` reframing for the authority-versus-set-equality
  distinction and for identifying the stronger form.
- **Behavior impact:** Preserving. Deferring an assertion changes nothing observable.
- **Rejected alternatives:**
  - Include the reverse check now — rejected on the evidence test: it protects a failure mode with no occurrences in
    this repository.
  - Put it on the cut list instead of the deferred list — rejected because the two lists differ by whether a trigger
    exists to reopen. The boundary is silent here rather than excluding it, and a plugin rename or deletion is a
    concrete trigger, so it belongs in the deferred list.
- **Revisit criterion:** An orphan entry reaches `main`, or a plugin is renamed or removed.
- **Dissent (if any):** `han-core:software-architect` recommended including it as a third assertion, arguing it is one
  grep and covers the rename case that the forward direction structurally cannot see. Recorded and not adopted, on the
  evidence test.
- **Settles delta entry:** S-5.
- **Dependent decisions:** None.
- **Referenced in plan:** Deferred (YAGNI).

### D-11: `CLAUDE.md` line 73 is cut for scope

- **Question:** Line 73 calls the Codex catalog "the Codex-compatible subset of the plugins". Should this change reword
  it?
- **Decision:** Cut. Recorded in the plan's Cut for Scope section, where the operator can reinstate it.
- **Rationale:** Unlike line 83, this line does not become false. After the change the catalog still excludes `han`, so
  it is still a subset. The reason to reword it is to stop a future reader concluding that some plugins legitimately sit
  outside the Codex surface, which is prevention work, and the recorded boundary already chose a mechanism for
  prevention in item 4: a test rather than prose.
- **Evidence:** [C-16](current-state-findings.md#c-16-claudemd-records-the-han-linear-manifest-gap-as-though-it-were-the-intended-design)
  for the wording; [scope-boundary.md](scope-boundary.md) Stated Scope item 4 for the chosen prevention mechanism;
  `han-core:junior-developer` reframing for the distinction between a line the change falsifies and a characterization
  it does not.
- **Behavior impact:** Preserving.
- **Rejected alternatives:**
  - Reword it alongside line 83 — rejected because the two lines are not the same case, and treating them as one is how
    a four-item bug fix becomes a documentation pass.
  - Escalate it as its own question — rejected because the cut list is the channel for exactly this, and it reaches the
    operator either way.
- **Revisit criterion:** The operator asks for it, which is itself a valid justification the reinstated entry records.
- **Dissent (if any):** `han-core:junior-developer` held that this one either goes to the operator or to the cut list,
  and did not choose between them. The cut list is the choice, and it surfaces to the operator in the closing summary.
- **Settles delta entry:** —
- **Dependent decisions:** None.
- **Referenced in plan:** Cut for Scope.

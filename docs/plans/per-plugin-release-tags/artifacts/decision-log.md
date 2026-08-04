# Decision Log: Per-Plugin Release Tags

Classification into full and trivial ran once, after the review round returned. Every decision carries at least one
promotion signal — a rejected alternative a reasonable engineer would plausibly have chosen, evidence beyond the
operator's framing, a driving finding, a linked technical note, or a dependent decision — so every decision stays in full
form. D# numbers were not changed by the pass.

## Trivial decisions

None.

## Full decisions

### D1: Replace the suite tag with per-plugin tags

- **Question:** Should the per-plugin `{name}--v{version}` tags be added alongside the existing single `vX.Y.Z` suite
  tag, or replace it?
- **Decision:** Replace it. From this release forward, `/han-release` creates one tag per plugin and creates no `vX.Y.Z`
  tag. The parent plugin's tag is `han--v{version}`, so the release that ships this is `han--v5.0.0`.
- **Rationale:** The operator chose replacement when the trade was put to them. Dual-writing both schemes would mean
  every release carries two names for the same commit, and the second one exists only to keep old links looking
  consistent.
- **Evidence:** User input, recorded verbatim in
  [scope-boundary.md](scope-boundary.md#direction-of-travel): "go with the second option - replace vX.Y.Z with
  han--vX.Y.Z". Upstream requirement from
  [`docs/en/plugin-dependencies`](https://code.claude.com/docs/en/plugin-dependencies#tag-plugin-releases-for-version-resolution):
  "Tag each release as `{plugin-name}--v{version}`, where `{version}` matches the `version` field in that commit's
  `plugin.json`."
- **Rejected alternatives:**
  - Keep `vX.Y.Z` and add the per-plugin tags beside it — rejected by the operator. It would have preserved every
    existing release link and comparison link unchanged, at the cost of two tags naming the same thing on every release.
  - Do nothing, since no Han plugin pins a version range today — rejected because the work item asks for the tagging,
    and tags have to exist before any plugin can pin against them.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** D2, D4, D6, D7, D8, D9, D13
- **Referenced in spec:** Outcome, What Changes and What Does Not

### D2: What the GitHub release attaches to

- **Question:** With `vX.Y.Z` gone, which tag does the published GitHub release hang off?
- **Decision:** The parent plugin's tag, `han--v{parent version}`. The release title stays the plain version string
  (`v5.0.0`), so the releases page still reads as a continuous list.
- **Rationale:** The release is a release of the suite, and the parent plugin is what carries the suite version. Its tag
  is the only per-plugin tag that tracks the same number the release has always tracked.
- **Evidence:** The skill already defines the release as named for the parent version
  (`.claude/skills/han-release/references/release-notes-format.md`: "The release is named for the parent `han` plugin's
  version, so the tag and the body title are both `v{parent target}`"). D1 renames that tag and nothing else about the
  statement changes. Verified that the parent resolves to `han--v5.0.0`: `claude plugin tag --dry-run ./han` prints
  `Tag: han--v5.0.0`.
- **Rejected alternatives:**
  - Attach the release to no tag and publish it against a commit — rejected because GitHub releases are keyed by tag,
    and the comparison links between releases would have nothing to name.
  - Rename the release title to `han--v5.0.0` as well — rejected under D8. The title is display text a person reads, not
    a reference anything resolves.
- **Linked technical notes:** —
- **Driven by findings:** F9
- **Dependent decisions:** D8
- **Referenced in spec:** Outcome, Primary Flow

### D3: How the tags get created

- **Question:** Create the tags with Claude Code's `claude plugin tag --push`, or with plain `git tag` and `git push`?
- **Decision:** Use `claude plugin tag --push`, passing each plugin's source folder as the path argument, run from the
  repository root.
- **Rationale:** The command validates something plain `git tag` cannot: that the plugin's `plugin.json` version and its
  entry in `marketplace.json` agree. The release's own version-application step writes both files separately, so a
  half-applied bump is a real failure mode this catches before a tag exists. The work item names this command by title.
- **Evidence:** Work item title: "Use `claude plugin tag --push` to tag new releases". Upstream docs: "Before creating
  the tag, it validates the plugin contents, checks that `plugin.json` and the marketplace entry agree on the version,
  requires a clean working tree under the plugin directory, and refuses if the tag already exists." Verified in this
  repository at Claude Code 2.1.221: `claude plugin tag --dry-run ./han-core` resolves `Marketplace entry: plugins[2] in
  .claude-plugin/marketplace.json (version: 3.0.0)` and would create `han-core--v3.0.0`. The command accepts a path
  argument, so the run never has to change directory. It reads `.claude-plugin/marketplace.json` and ignores the
  Codex-format manifest at `.agents/plugins/marketplace.json`, which carries no versions.
- **Rejected alternatives:**
  - Plain `git tag -a {name}--v{version}` plus `git push` — the upstream docs call this equivalent ("Running `git tag
    secrets-vault--v2.1.0` directly is equivalent if you keep `plugin.json` and the marketplace entry in sync
    yourself"), and it adds no new prerequisite. Rejected because "if you keep them in sync yourself" is exactly the
    invariant the release's own version-application step can break, and the command checks it for free.
  - Run the command from inside each plugin directory — rejected because the path argument does the same job without
    changing directory, and the release's other commands all run from the repository root.
- **Linked technical notes:** T1
- **Driven by findings:** —
- **Dependent decisions:** D5, D9, D10, D11, D14
- **Referenced in spec:** Actors and Triggers, Primary Flow

### D4: Which plugins get a tag

- **Question:** Does each release tag every plugin in the marketplace, or only the plugins whose version changed?
- **Decision:** Walk every plugin in the marketplace on every release. A plugin whose version did not change is walked
  too, and its already-existing tag is skipped.
- **Rationale:** A version is installable only if a tag names it. A plugin that stays at one version across several
  releases needs that version tagged once, and "only tag what changed" never tags it if it was unchanged the first time
  the new scheme ran. Walking everything makes the first release under the new naming tag the whole suite, with no
  separate backfill step, and every release after that is a cheap no-op for the unchanged plugins.
- **Evidence:** Every plugin listed in `.claude-plugin/marketplace.json` lacks a per-plugin tag today (`git tag -l` shows
  only the suite tags `v2.1.0` through `v4.6.0`). The upstream resolution behavior requires a tag per installable
  version: "Claude Code lists the marketplace's tags, filters to those starting with `secrets-vault--v`, and fetches the
  highest version satisfying `~2.1.0`." A brand-new plugin is not bumped by the release that introduces it
  (`docs/semantic-versioning.md`, rule 3), so its first tag carries its introduction version.
- **Rejected alternatives:**
  - Tag only the plugins whose version changed this release — rejected because it leaves unchanged plugins with no tag
    at all until they happen to change, which is the opposite of what tag-based resolution needs.
  - Tag everything on the first release only, then switch to changed-only — rejected as two rules where one works. The
    skip path makes the general rule free.
- **Linked technical notes:** T2
- **Driven by findings:** F14, F17, F19
- **Dependent decisions:** D5, D14
- **Referenced in spec:** What Changes and What Does Not, Primary Flow, Alternate Flows and States, Edge Cases and
  Failure Modes

### D5: A tag already on GitHub is a skip

- **Question:** The tagging command refuses when the tag already exists. Since D4 walks unchanged plugins on every
  release, that refusal is the common case. Does it stop the release?
- **Decision:** A tag already **on GitHub** at the release commit is reported as present and the run continues. A tag
  that exists only on the maintainer's machine is not a skip: it must reach GitHub before the run may publish. Every
  other refusal stops the run.
- **Rationale:** Under D4 the refusal is the expected outcome for most plugins in most releases, so treating every
  refusal as a failure would make a normal release abort on its second plugin. But the command's refusal is a statement
  about the local tag list, and treating it as a statement about GitHub is what let a re-run after a failed push publish
  a release with tags missing from GitHub (F2).
- **Evidence:** Verified in this repository: creating `han-core--v3.0.0` and re-running the command produces `Tag
  "han-core--v3.0.0" already exists locally.` and exit status 1. The same exit status 1 covers genuine failures (a dirty
  tree under the plugin directory, a missing manifest, a bad path), all verified in the same session. The word "locally"
  is load-bearing, and testing confirmed the command does not consult the remote at all (see T2).
- **Rejected alternatives:**
  - Treat every already-exists refusal as a skip regardless of GitHub — rejected under F2. It merges two states with
    different consequences, and the dangerous one is invisible in the report.
  - Pass `--force` so the command never refuses — rejected under D10.
- **Linked technical notes:** T2, T4
- **Driven by findings:** F2, F7, F22
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Alternate Flows and States, Coordinations

### D6: When tagging happens

- **Question:** Does tagging run before or after the release commit that carries the version bumps and the changelog?
  And when does that commit reach GitHub?
- **Decision:** After. The commit lands first, is pushed to GitHub, and only then is any plugin tagged. Publishing comes
  last. The commit reaches GitHub before the first tag does.
- **Rationale:** A tag has to point at the commit holding the versions being released, and the tagging command refuses
  to run against a dirty working tree, so the bumps must be committed first. Pushing the commit before the tags matters
  for a separate reason: pushing a tag transfers the commit it reaches, so tags pushed first would leave GitHub holding
  permanent tags on a commit no branch contains. Under D10 those tags cannot be moved afterwards.
- **Evidence:** Verified: adding an untracked file under a plugin folder makes the command exit 1 with `Uncommitted
  changes affecting this release — commit them first so the tag points at the version you intend to release`. The
  command tags `HEAD`, confirmed by its dry-run output: `would create tag han-core--v3.0.0 at HEAD`. The skill's
  existing step pushes the branch and the tag adjacently (`git push origin HEAD` then `git push origin v{parent
  target}`), so the branch push exists today and only needs its position stated.
- **Rejected alternatives:**
  - Tag before committing and pass `--force` to bypass the dirty-tree check — rejected because the tag would point at
    the commit before the version bumps, so the tagged version would not be the version in the tagged tree.
  - Leave the branch push where it falls — rejected under F1. The ordering is now a committed behavior rather than an
    inherited accident.
- **Linked technical notes:** —
- **Driven by findings:** F1, F3
- **Dependent decisions:** D14
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, Coordinations

### D7: Finding the previous release

- **Question:** The release finds the previous release tag to work out which commits, pull requests, and issues it
  covers, **and** to read the version the parent plugin is bumping from. With the naming changing, how does it find that
  tag and read a version out of it?
- **Decision:** Refresh the view of GitHub's tags, then look for the newest parent-plugin tag. When none exists, fall
  back to the newest tag under the old suite naming. When neither exists, treat the run as a first release, as today.
  Read the parent's baseline version out of whichever tag was found, stripping the plugin-name prefix as well as the
  leading `v`. The fallback arm is removed once a parent-plugin tag exists on GitHub, since it is unreachable after
  that.
- **Rationale:** The two naming schemes do not match each other's patterns, so a single lookup finds nothing on the
  transition release. Without the fallback, the first release under the new scheme would treat the entire repository
  history as its range. The baseline half is the more dangerous one: the previous tag is not only a range endpoint, and
  a version read by stripping only a leading `v` yields the whole tag string once the tag is `han--v5.0.0`.
- **Evidence:** The skill reads the previous tag with `git tag -l 'v*.*.*' --sort=-v:refname | head -n1`
  (`.claude/skills/han-release/SKILL.md:40`), which does not match `han--v5.0.0`. The same file defines the parent's
  baseline as "the number without the leading `v`" (line 55) and sets `baseline = prev#` for the parent (line 163), and
  that baseline feeds the `sort -V` comparison at line 204 that chooses between using the manifest version as-is and
  computing a bump. Verified in this repository that `git tag -l 'han--v*' --sort=-v:refname` isolates the parent (it
  does not match `han-core--v3.0.0`) and orders correctly across double-digit versions (`han--v10.0.0` sorted above
  `han--v5.10.0`), and that the old pattern still returns `v4.6.0`.
- **Rejected alternatives:**
  - Use one pattern matching both schemes — rejected because a pattern loose enough to match both also matches every
    child plugin's tags, so the newest match could be a child rather than the parent.
  - Hard-code `v4.6.0` as the predecessor for the transition release — rejected because it puts a one-time value into a
    skill that runs on every release.
  - Keep the fallback arm permanently — rejected under F15. Its entry condition is true exactly once, so it carries a
    stated expiry rather than becoming a permanent fork nobody remembers the reason for.
- **Linked technical notes:** T3
- **Driven by findings:** F4, F7, F15
- **Dependent decisions:** —
- **Referenced in spec:** What Changes and What Does Not, Primary Flow, Alternate Flows and States, Edge Cases and
  Failure Modes, Out of Scope

### D8: Human-facing version labels stay unprefixed

- **Question:** The changelog's section headings, the release title, and the changelog anchor links all carry `v{X.Y.Z}`
  today. Do they become `han--v{X.Y.Z}` too?
- **Decision:** No. Headings, the release title, and the anchor stay as `v{X.Y.Z}`. Only the two links that name a git
  ref change: the link pinning a changelog section to a release, and the comparison link between releases.
- **Rationale:** A tag is a reference something resolves; a heading is a label a person reads. Renaming every past release's
  heading style to match a tag scheme changes nothing about resolution and breaks the anchors of every link
  already pointing at those sections.
- **Evidence:** The anchor is computed from the heading text
  (`.claude/skills/han-release/references/release-notes-format.md`: "Compute `{anchor}` from the heading text
  `v{parent target}`"), so leaving the heading alone leaves every historical anchor valid. The pinned link and the
  comparison link both embed a git ref (`blob/v{parent target}/CHANGELOG.md#{anchor}` and
  `compare/{prev tag}...v{parent target}`), and a ref that no longer exists resolves to nothing.

  On the transition release the comparison link spans both schemes, reading
  `compare/v4.6.0...han--v5.0.0`. That form is correct and GitHub resolves it, because a comparison link takes any two
  refs. Every release after it compares two parent-plugin tags.

  Two statements in the release skill's own reference material become false and are corrected with the links: one says
  the tag and the release title are both the plain version, and the other calls that version "the version the git tag
  tracks". Under this decision the title stays plain and the tag does not.
- **Rejected alternatives:**
  - Rename the changelog headings to match the tags — rejected because it invalidates existing anchors for no
    resolution benefit.
  - Leave the two links pointing at `v{X.Y.Z}` — rejected because those refs will not exist for new releases, so the
    links would resolve to nothing.
- **Linked technical notes:** —
- **Driven by findings:** F8, F9
- **Dependent decisions:** —
- **Referenced in spec:** Outcome, What Changes and What Does Not, Out of Scope

### D9: What happens when a push fails

- **Question:** Every plugin's tag is created and pushed one at a time. What does the release do when one push fails,
  and what does it report on the way out?
- **Decision:** Stop at the failure and do not publish. Report which tags reached GitHub, which exist only on the
  maintainer's machine, and the command that pushes the rest. The parent plugin is tagged first, so the tag the release
  itself needs is the one most likely to be present when a walk stops partway. The closing report always names the
  commit every tag points at, whether that commit is on the default branch, and each plugin's final state.
- **Rationale:** Continuing past a push failure publishes a release whose tags are partly absent from GitHub, which is
  harder to diagnose than stopping. Stopping leaves a state a person can finish by hand, because the local tags are
  correct and only the push is missing. The report has to carry more than "created" and "skipped", because those two
  words cannot tell a clean release apart from one whose tags never left the maintainer's machine (F12).
- **Evidence:** Upstream docs: "If the push fails, the tag is still created locally and the command exits with an
  error." Confirmed by testing: a push rejected by the remote produced `✘ Tag created locally but push failed (exit 1)`
  and left the local tag in place. The failure is therefore recoverable by pushing, **except** when the remote already
  holds that tag at a different commit, where pushing fails identically every time (see D10 and T4).
- **Rejected alternatives:**
  - Push every tag in one command at the end, so it succeeds or fails as a unit — rejected because the tagging command
    creates and pushes together, and splitting them means giving up the validation D3 exists for.
  - Continue through failures and report them all at the end — rejected because the release would publish against a tag
    that may itself have failed to push.
  - Report only created and skipped counts — rejected under F12. A maintainer reading a green report needs to be able to
    tell a clean release from the state F2 describes without opening a terminal.
- **Linked technical notes:** T4
- **Driven by findings:** F1, F2, F12, F16, F17
- **Dependent decisions:** D14
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, User Interactions

### D10: Never move an existing tag

- **Question:** Should the release ever pass the force flag, which skips the dirty-tree and tag-exists checks?
- **Decision:** Never. The release does not force-move a tag under any condition.
- **Rationale:** A moved tag changes what a version means after people may already have installed it. Both checks the
  flag skips are checks the release wants: a dirty tree means the tag would not match the released versions, and an
  existing tag means the version is already published.
- **Evidence:** Upstream docs describe the consequence of moving a tag: "if a maintainer force-moves a tag to a
  different commit, the next install gets a fresh cache directory instead of reusing stale content", which is upstream
  handling the damage rather than endorsing the move. The flag is confirmed present in this version
  (`-f, --force  Skip the dirty-working-tree and tag-already-exists checks`).

  This decision is what makes the tag already on GitHub at a different commit an unrecoverable state rather than a
  retryable one. Verified by testing: pushing against a remote that already holds the tag is rejected with
  `! [rejected] ... (already exists)`, and the rejection repeats identically on every attempt. The only ways out are
  moving the tag, which this decision forbids, or abandoning that version number.
- **Rejected alternatives:**
  - Force when re-cutting a release for the same version — rejected because re-cutting exists to correct the notes, and
    the notes are not what the tag points at.
- **Linked technical notes:** T4
- **Driven by findings:** F7
- **Dependent decisions:** D14, D15
- **Referenced in spec:** Alternate Flows and States, Edge Cases and Failure Modes

### D11: The new prerequisite

- **Question:** The release checks for its required tools before doing anything. Does the Claude Code command line join
  that check?
- **Decision:** Yes. It is checked alongside the GitHub and JSON tools, and a missing one stops the run before anything
  is written.
- **Rationale:** D3 makes the release depend on it. Discovering it is missing after the version bumps are committed
  leaves a half-finished release, and the existing check exists precisely to avoid that.
- **Evidence:** The skill already performs this check for two tools and stops immediately when either is missing
  (`.claude/skills/han-release/SKILL.md` pre-requisites block). The skill's description names its requirements as "the
  gh CLI, jq, and a clean git checkout", so the description changes too.
- **Rejected alternatives:**
  - Check for it only at the tagging step — rejected because by then the version bumps and the changelog are committed.
- **Linked technical notes:** T1
- **Driven by findings:** F11
- **Dependent decisions:** —
- **Referenced in spec:** What Changes and What Does Not, Actors and Triggers, Primary Flow, Edge Cases and Failure
  Modes

### D12: Correcting the versioning guide

- **Question:** The repository's versioning guide currently states that Han does not need per-plugin tags and that the
  single suite tag is sufficient. Does this work correct it?
- **Decision:** Yes. The guide's note on per-plugin tags is rewritten to describe the new scheme as what the repository
  does, and its statements that the release tag tracks the parent version as `vX.Y.Z` are updated to the new naming.
- **Rationale:** The guide is the repository's own statement of tagging policy, and it currently says the opposite of
  what the release will do. Leaving it would leave a maintainer reading it a documented reason to undo this change.
- **Evidence:** `docs/semantic-versioning.md` section "A note on per-plugin tags and version constraints" states: "Han
  does **not** need them today... The single suite tag `vX.Y.Z` is sufficient." The same file states at line 103 that
  "the git tag for a release tracks the **parent** version" and at line 145 that a release "is tagged `v3.1.0` (the
  parent version)". The release skill reads this file to classify each plugin's bump level, so it is a file the skill
  depends on rather than unrelated documentation.
- **Rejected alternatives:**
  - Leave the guide alone, since the operator scoped the work to the release skill — rejected, but recorded as a
    judgment call. The narrowing was to the skill rather than an exclusion of the guide, and the guide's note is
    specifically about this decision. The operator's own scope statement puts other repository surfaces in scope "where
    the skill's behavior depends on them", and the release skill reads this guide to classify each plugin's bump level.
    Flagged in the closing summary so the operator can cut it.
- **Linked technical notes:** —
- **Driven by findings:** F10
- **Dependent decisions:** —
- **Referenced in spec:** Out of Scope, Summary

### D13: Existing tags stay

- **Question:** Do the existing `vX.Y.Z` tags get deleted, renamed, or duplicated under the new naming?
- **Decision:** None of those. They stay exactly as they are.
- **Rationale:** Every one of them is the tag a published GitHub release attaches to. Deleting or moving them breaks
  those releases and every link into them.
- **Evidence:** Recorded boundary: "The deprecation governs what new releases create; it does not direct the removal of
  existing tags" ([scope-boundary.md](scope-boundary.md#direction-of-travel)). The repository holds 27 suite tags, from
  `v2.1.0` through `v4.6.0`, each with a published release.
- **Rejected alternatives:**
  - Create matching `han--v{version}` tags for past releases — cut for scope, see the specification's cut list.
- **Linked technical notes:** —
- **Driven by findings:** F21
- **Dependent decisions:** —
- **Referenced in spec:** Out of Scope

### D14: Validate every plugin before the release commit

- **Question:** The tagging command checks each plugin's version agreement and folder cleanliness as that plugin is
  tagged. Is checking mid-walk good enough?
- **Decision:** No. The release checks every plugin in the marketplace, for both conditions, before it commits anything.
  A failure stops the run while nothing has been written and nothing pushed. The per-plugin checks still run during the
  walk, reclassified as an unexpected stop rather than a routine one.
- **Rationale:** The parent plugin is first in the marketplace list, so a disagreement found at the ninth plugin stops a
  run that has already committed the bumps and pushed several permanent tags including the parent's. Fixing a
  disagreement needs a new commit, and under D10 the pushed tags cannot follow it, so the maintainer's only exits are
  deleting remote tags or abandoning the version. A check that costs nothing before the commit removes the whole class.
- **Evidence:** The failure is reachable without any bug in the run. A plugin nobody changed can carry version drift
  introduced by an earlier merge, and the version-application step touches only plugins whose target differs from their
  current version, so it never corrects an unchanged plugin's drift. Feasibility is established by direct test at Claude Code
  2.1.221, in an isolated clone: `claude plugin tag --dry-run ./han-core` refuses a dirty plugin folder (`✘ Uncommitted
  changes affecting this release`) and refuses a version disagreement (`✘ Version mismatch: plugin.json says "3.0.1" but
  .claude-plugin/marketplace.json plugins[2].version says "3.0.0"`), each at exit status 1 and without creating a tag,
  while a clean and agreeing plugin exits 0 and reports the tag it would create. Both checks the walk relies on are
  therefore available before the commit.
- **Rejected alternatives:**
  - Rely on the mid-walk checks alone — rejected under F3. The check is correct; its timing is what makes the failure
    expensive.
  - Re-order the walk so the parent is tagged last, limiting the damage — rejected because it protects only the parent
    and still leaves child tags stranded, and it conflicts with D9's reason for tagging the parent first.
- **Linked technical notes:** —
- **Driven by findings:** F1, F3
- **Dependent decisions:** —
- **Referenced in spec:** What Changes and What Does Not, Primary Flow, Edge Cases and Failure Modes, Coordinations

### D15: The release always stops before the first tag push

- **Question:** Where does the maintainer see and approve the tag names before they become permanent?
- **Decision:** At a stop that always happens, immediately before the first tag is pushed. It lists every plugin split
  into tags to create and tags already on GitHub, names the commit they will point at, and names the branch that commit
  is on. It is separate from the existing version-plan confirmation, which stays conditional.
- **Rationale:** The existing confirmation cannot carry this. It prompts only when a plugin's version still needs
  computing, and every plugin in this repository is currently ahead of its baseline or newly introduced, so it will not
  fire on the release that ships this change. Without a stop of its own, that release would push a permanent tag for
  every plugin having asked the maintainer nothing. Under D10 none of them can be moved afterwards.
- **Evidence:** User input, in answer to the escalation recorded as E1 in
  [team-findings.md](team-findings.md#escalation-register): "agreed", accepting a stop on every release over a stop only
  when a tag name is new. The skill's existing gate states its own condition: "**If no plugin needs confirmation** ...
  the plan is fully determined. Do not prompt." Verified against `v4.6.0` that every plugin is strictly ahead (`han`
  4.6.0 to 5.0.0, `han-core` 2.2.1 to 3.0.0, and so on) or newly introduced, so zero need confirmation. The existing
  pre-publish pause does not cover this either: it is opt-in and defaults off, and it sits after the tags are already
  pushed.
- **Rejected alternatives:**
  - Stop only when at least one tag name is new for that plugin — rejected by the operator. It would have spared the
    keystroke on a re-run that creates nothing, but the rule is harder to hold in your head than the stop it saves.
  - Print the tag list and keep running, leaving the existing opt-in pause for when the maintainer wants a gate —
    rejected by the operator. It leaves the default invocation creating permanent tags unattended.
  - Move the existing pre-publish pause earlier instead of adding a stop — rejected because that pause is opt-in, so
    moving it changes when it fires without changing whether it fires.
- **Linked technical notes:** —
- **Driven by findings:** F6
- **Dependent decisions:** —
- **Referenced in spec:** What Changes and What Does Not, Primary Flow, Edge Cases and Failure Modes, User Interactions

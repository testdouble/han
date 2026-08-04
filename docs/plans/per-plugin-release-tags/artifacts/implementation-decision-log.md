# Implementation Decision Log: Per-Plugin Release Tags

Every implementation decision committed while planning this change, with rationale, evidence, and rejected
alternatives. Behavioral decisions live in the specification's own
[decision-log.md](decision-log.md) and are not re-opened here. The plan lives in
[../feature-implementation-plan.md](../feature-implementation-plan.md); the round record lives in
[implementation-iteration-history.md](implementation-iteration-history.md).

## D-1: Remove `AskUserQuestion` from the skill's auto-approve list

- **Decision:** Delete `AskUserQuestion` from `.claude/skills/han-release/SKILL.md`'s `allowed-tools` line. Nothing else
  on that line changes for this reason.
- **Rationale:** The specification's mandatory approval stop is the only thing standing between a default release run
  and a permanent tag for every plugin. Listing the question tool in the auto-approve list makes that stop return an
  empty answer without ever showing the maintainer anything. The stop would exist in the document and not in the run.
- **Evidence:** The repository's own guidance says so in one line:
  `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-AskUserQuestion.md:14`, "Do not
  add `AskUserQuestion` to the `allowed-tools` frontmatter in any skill file", with the mechanism at line 40, "The tool
  returns immediately with empty answers. The user never sees the question." The current line is at `SKILL.md:16-18`.
  `han-release` is the only skill in the repository that lists it; every other skill that calls the tool does so
  without listing it. Removing it does not break the call: unlisted tools still work and prompt once.
- **Why nobody has noticed:** both stops the skill has today sit behind gates that do not open on a default run. The
  version-plan confirmation is skipped when no plugin needs one (`SKILL.md:221`), which is the current state of every
  plugin, and the pre-publish pause is opt-in and defaults off (`SKILL.md:66-67`).
- **Rejected alternatives:**
  - Leave it and rely on the printed preview — rejected. A printed list is not an approval, and the decision the
    specification records is an approval.
- **Driven by rounds:** R1 (`C1`; `JD-001`, `DOR-1`)
- **Referenced in plan:** Outcome, Implementation Approach (making the approval stop real), Work Units and Sequencing (unit 1), Definition of Done

## D-2: An unreadable answer at the tag stop is a decline

- **Decision:** At the tag-approval stop only, an empty or unreadable answer is treated as a decline. The run stops and
  tags nothing.
- **Rationale:** The upstream defect behind `D-1` is still live, and removing the frontmatter entry is a workaround
  rather than a fix. A guard costs one sentence, and the thing it guards cannot be undone.
- **Evidence:** The same guidance file records upstream issue #29547 as closed but "still reproducing as of March 4",
  and notes that the `alwaysAllowRules` early return survives the fix applied to issue #9846.
- **Rejected alternatives:**
  - Apply the same guard to all three stops — rejected as a strictly larger version that buys nothing. The version-plan
    confirmation and the pre-publish pause are both recoverable; only this stop gates something permanent.
- **Driven by rounds:** R1 (`C2`; `JD-002`)
- **Referenced in plan:** Implementation Approach (making the approval stop real), Work Units and Sequencing (unit 5), Deferred (YAGNI)

## D-3: Validate with file comparison, not with the tagging command's dry run

- **Decision:** Implement the specification's pre-commit validation as two plain checks rather than by invoking the
  tagging command. Version agreement is a comparison of each plugin's manifest version against its marketplace entry,
  selected by name. Cleanliness is a single working-tree status check. Run the pair **before** the version-application
  step, while the tree is still clean, and re-run the version comparison alone after that step and before the commit.
- **Rationale:** The version-application step writes a manifest for every plugin whose version changed. A dry-run sweep
  placed where the specification puts the gate would find those folders dirty by construction and refuse exactly the
  plugins the release just bumped, and it could not tell that refusal apart from the drift it is hunting. Running the
  cheap checks before the writes keeps the specification's promise literal: the run has written and pushed nothing. The
  second, narrower re-check covers the one failure the writes themselves can create, a half-applied bump, which is the
  case the specification's `D3` names as the reason a check exists at all.
- **Evidence:** The version-application step is `SKILL.md:228-238`. The tagging command's refusal on a dirty plugin
  folder was verified during specification work: `✘ Uncommitted changes affecting this release`. Both tools this
  decision uses are already prerequisites and already covered by the skill's existing `Bash(jq *)` and `Bash(git *)`
  entries.
- **This does not contradict the specification.** Its `D14` decides when the check happens and what it checks, and
  cites the dry run as feasibility evidence rather than as the required mechanism.
- **Rejected alternatives:**
  - Run the dry-run sweep before the version-application step — rejected. It works, but it launches one process per
    plugin to answer a question two file reads answer, and it still cannot cover the half-applied bump.
  - Run the sweep after the writes — rejected. It refuses every release on the release's own edits.
- **Driven by rounds:** R1 (`C3`; `JD-003`, `DOR-5`)
- **Referenced in plan:** Implementation Approach (validating before the commit), Work Units and Sequencing (unit 3)

## D-4: Invoke the tagging command through the shell's `command` builtin

- **Decision:** Call `command claude plugin tag {source} --push` in the walk, and add `Bash(command claude *)` to the
  skill's `allowed-tools`. Keep the new prerequisite probe in the shape the skill already uses for its other tools.
- **Rationale:** `T1` requires bypassing a shell function or alias wrapping the tool. Of the two forms it names, the
  resolved binary path is machine-specific and cannot be written into a shipped permission rule, while the `command`
  builtin is a fixed literal that both bypasses function lookup and can be named by a rule.
- **Evidence:** Verified in this repository. With a shell function named `claude` defined, `command claude --version`
  returned `2.1.221` while the bare call ran the function. The machine this was authored on wraps `claude` in a zsh
  function that blocks on a profile picker, which is `T1`'s recorded observation. The probe shape is constrained
  separately: context-injection commands refuse command substitution outright
  (`context-injection-commands.md`), so the probe cannot resolve a path at load time.
- **Unverified:** whether Claude Code's permission matcher honors a `Bash()` prefix containing the `command` builtin is
  not observable from this repository and was not inspected. This does not block: the worst case is a single approval
  prompt for the prefix, which the maintainer accepts once.
- **Fallback if the matcher does not honor it:** move the walk into a script beside the skill and invoke it once, so at
  most one prompt appears instead of one per plugin. Recorded as a fallback rather than the default, per the YAGNI
  simpler-version test.
- **Rejected alternatives:**
  - Declare `Bash(claude *)` and call `claude` bare — rejected. It matches a rule but runs the shell function, which is
    the failure `T1` exists to prevent.
  - Hard-code the resolved binary path — rejected. It is specific to one machine.
- **Driven by rounds:** R1 (`C4`; `JD-004`, `DOR-8`)
- **Referenced in plan:** Implementation Approach (tagging each plugin), Work Units and Sequencing (unit 1), Definition of Done, Risks and Assumptions

## D-5: Establish remote tag state once, in a script, peeling annotated tags

- **Decision:** Add one script beside the skill that takes the release commit and the expected tag names, performs one
  remote tag listing and one local tag listing, and prints one line per tag classifying it as absent, on GitHub at the
  release commit, on GitHub at a different commit, or present only locally. It peels annotated tags to their commit
  before comparing. It never creates or pushes anything. Invoke it twice: once before the approval stop and once after
  the walk. Add a test file beside it.
- **Rationale:** Three of the states the specification's report commits to have no source otherwise, because `T2`
  establishes that the tagging command never consults the remote. Fetching tags does not supply it either: a fetch
  merges remote tags into the local list, after which a tag that was on GitHub and one that was only local become
  indistinguishable, which is exactly the distinction the specification's `F2` exists to preserve. The peel is the part
  that makes this a script rather than a line of prose.
- **Evidence:** Verified in this repository. `git ls-remote --tags origin v4.6.0` returns `4814987`, while
  `git rev-list -n1 v4.6.0` returns `fdafcb6`, and `git cat-file -t v4.6.0` returns `tag`. The listing reports the tag
  object, not the commit. The tagging command creates annotated tags, confirmed from its own dry-run output, which
  prints `git tag -a`. So a comparison reading the unpeeled value would classify **every** tag as sitting at a
  different commit, and under the specification's failure table that state stops the run and declares recovery
  impossible. The release process would halt on its first plugin, every time.
- **Why a script earns its place here:** the repository's precedent is a script with a test file beside it, used by four
  skills. The justification is not the string handling, which prose can carry, but a verified silent-failure mode with
  an irreversible consequence, exercised by the same code at three points: the approval stop's split, the walk's
  per-plugin classification, and the publish gate.
- **Rejected alternatives:**
  - One remote check per plugin, matching the shape at `SKILL.md:331` — rejected. It is one network round trip per
    plugin to answer a question one listing answers.
  - Keep the classification in skill prose — rejected. The peel is the kind of detail prose gets wrong silently, and the
    consequence of getting it wrong is a release that cannot proceed.
- **Driven by rounds:** R1 (`C5`, `C9`, `C10`; `JD-005`, `JD-009`, `DOR-2`)
- **Referenced in plan:** Outcome, Implementation Approach (knowing what is on GitHub, and what changes and what stays), Work Units and Sequencing (unit 4), Testing Strategy

## D-6: Stop before the walk when any tag is on GitHub at a different commit

- **Decision:** Take the remote-state snapshot immediately after the release commit is pushed and before the approval
  stop. Any tag classified as on GitHub at a different commit stops the run there, naming both commits.
- **Rationale:** That state is unrecoverable, and it is detectable before a single tag exists. Discovered mid-walk, the
  parent's tag is already pushed, so the maintainer's only exit is abandoning the version they have already burned.
  Discovered before the walk, nothing has been created and they pick a different version with nothing to unwind.
- **Evidence:** `T4` verified the push rejection repeats identically, so it is permanent. GitHub enforces this
  independently: `gh release create --help` states that once a release is published, "Git tags associated with a
  release cannot be modified or deleted." The state is reachable by an ordinary correction, re-cutting a release after
  amending the release commit. The snapshot `D-5` already takes answers the question at no extra cost.
- **Rejected alternatives:**
  - Let the walk discover it — rejected. Same information, worse moment, unrecoverable consequence.
- **Driven by rounds:** R1 (`C11`; `DOR-3`)
- **Referenced in plan:** Implementation Approach (knowing what is on GitHub), Work Units and Sequencing (unit 4)

## D-7: Re-check the commit after the approval stop

- **Decision:** Record the release commit right after it is made, show it at the approval stop, and re-read it
  immediately after approval. If it changed, stop.
- **Rationale:** The approval stop is an unbounded wait between pushing the commit and creating the first tag, and the
  tags are created against whatever the checkout currently points at. The tagging command's own dirty-tree refusal
  catches uncommitted edits but not a new commit, an amend, or a rebase. A maintainer who spots a changelog typo at the
  prompt and fixes it would otherwise tag a commit that was never pushed, which is the exact state the commit-before-tag
  ordering exists to prevent.
- **Evidence:** The tagging command tags the current checkout, confirmed by its dry-run output: `would create tag
  han-core--v3.0.0 at HEAD`. The specification already requires the stop to name the commit, so half the work is
  committed to already.
- **Rejected alternatives:**
  - Trust the dirty-tree refusal — rejected. It does not see a commit that was made cleanly.
- **Driven by rounds:** R1 (`C12`; `DOR-4`)
- **Referenced in plan:** Implementation Approach (tagging each plugin), Work Units and Sequencing (unit 5)

## D-8: Make the publish step refuse to create a tag

- **Decision:** Pass the flag that aborts publishing when the tag does not already exist, and require the post-walk
  remote snapshot to show every tag on GitHub at the release commit before publishing.
- **Rationale:** The publishing tool creates a missing tag by itself, at the default branch's head, rather than
  failing. A walk that missed the parent's push would end with a permanent tag minted at a commit nobody released, and
  under the same immutability rule it could never be corrected.
- **Evidence:** Verified from the tool's own help text: "If a matching git tag does not yet exist, one will
  automatically get created from the latest state of the default branch," and, separately, `--verify-tag` "abort the
  release if the tag doesn't already exist."
- **Rejected alternatives:**
  - Rely on the walk's exit statuses — rejected. They report what the local machine did, not what GitHub holds, which
    is the distinction `D-5` exists to draw.
- **Driven by rounds:** R1 (`C13`; `DOR-6`)
- **Referenced in plan:** Implementation Approach (publishing), Work Units and Sequencing (unit 5)

## D-9: Two separate previous-tag probes, never one combined pattern

- **Decision:** Add a second labeled probe for the parent-plugin tag and keep the existing suite-tag probe. Apply
  precedence in the step that reads them: parent tag first, suite tag as the fallback, neither meaning a first release.
  Fetch tags once, on the first probe only.
- **Rationale:** A single pattern covering both schemes returns the wrong tag, and it does so silently on every release
  after the transition.
- **Evidence:** Verified in this repository. With per-plugin tags present alongside the suite tags,
  `git tag -l 'han--v*' 'v*.*.*' --sort=-v:refname | head -n1` returns `v4.6.0`, because the version-sorted refname
  comparison starts at `h` versus `v`. The separate probes return `han--v5.10.0` and `v4.6.0` correctly, and `han--v*`
  correctly excludes `han-core--v3.0.0`.
- **One consequence to state in the plan:** a context-injection probe is a fixed string and cannot interpolate the
  parent's name from the marketplace, so the probe carries the literal parent tag pattern. If the parent is ever
  renamed, the probe returns nothing, the run reads that as a first release, and the changelog silently covers the
  whole repository history. One sentence in the step handles it: when the parent's name is not the one the probe
  assumes, redo the lookup with the actual name before using it.
- **Rejected alternatives:**
  - One combined pattern — rejected by the test above.
  - Fetch tags on both probes — rejected. It runs the fetch twice for nothing.
- **Driven by rounds:** R1 (`C6`; `JD-006`)
- **Referenced in plan:** Implementation Approach (finding the previous release), Work Units and Sequencing (unit 2)

## D-10: State the baseline parse rule as "the part after the last `v`"

- **Decision:** Replace the skill's definition of the parent's baseline number with a rule that reads the part of the
  tag after its last `v`, and give both worked examples in the vocabulary block.
- **Rationale:** This is the whole fix for the specification's most consequential review finding, and it needs no
  script. One rule is correct under both naming schemes.
- **Evidence:** The current rule at `SKILL.md:55` is "the number without the leading `v`", and the parent's baseline is
  set from it at `SKILL.md:163`, then compared at `SKILL.md:204` to choose between using the manifest version as-is and
  computing a bump. Under the new naming that rule returns the whole tag string.
- **Rejected alternatives:**
  - Strip a known prefix — rejected. It hard-codes the parent's name in a second place, on top of the probe.
- **Driven by rounds:** R1 (`C19`; `DOR-10`)
- **Referenced in plan:** Outcome, Implementation Approach (finding the previous release), Work Units and Sequencing (unit 2), Definition of Done

## D-11: Carry an explicit list of which occurrences change and which do not

- **Decision:** The plan carries a two-column list naming every occurrence that becomes the prefixed tag name and every
  occurrence that keeps the plain version. The commit subject and the release-notes temporary filename are named
  explicitly.
- **Rationale:** The version string appears far more often than the tag does, and most occurrences are headings, the
  release title, the anchor computation, a filename, and a commit subject, none of which are git refs. A blind
  find-and-replace would invalidate every historical changelog anchor, which is exactly what the specification's `D8`
  rejects.
- **Evidence:** counted on disk: `v{parent target}` appears twenty-nine times in `SKILL.md`, twelve times in
  `references/release-notes-format.md`, and eight times in `references/changelog-rules.md`. Every one of the eight in
  `changelog-rules.md` is a section heading, and none of them changes. Across the other two files fourteen occurrences
  are git refs or name the tag to the operator: the existing-tag check (two), tag creation and its message (two), the
  tag push, the three publishing calls in `SKILL.md`, two of those calls again in `references/release-notes-format.md`,
  the blob and compare links, and the two places the version plan names the tag. Every remaining occurrence is a
  heading, the release title, the anchor computation, or the temporary filename.
- **Rejected alternatives:**
  - Describe the rule and let the implementer apply it — rejected. The rule is easy to state and easy to misapply, and
    the two most confusable cases are the ones a reader skims past.
- **Driven by rounds:** R1 (`C7`; `JD-007`)
- **Referenced in plan:** Implementation Approach (what changes and what stays), Work Units and Sequencing (unit 6), Definition of Done

## D-12: Walk the parent by name, not by position

- **Decision:** Walk the marketplace entry whose name matches the parent, then the rest in listed order.
- **Rationale:** The specification requires the parent to be tagged first. Today the parent happens to be listed first,
  so the requirement would be satisfied by coincidence and would break silently if the file were reordered.
- **Evidence:** The skill already identifies the parent by name rather than position, in its own vocabulary block
  (`SKILL.md:45-47`).
- **Rejected alternatives:**
  - Walk in listed order and rely on the parent being first — rejected. It is true today and nothing holds it true. A
    reordering of the marketplace file would break the ordering the specification's `D9` depends on, silently and with
    no test to catch it.
- **Driven by rounds:** R1 (`C17`; `JD-011`)
- **Referenced in plan:** Implementation Approach (tagging each plugin), Work Units and Sequencing (unit 5)

## D-13: The report prints the command that actually recovers

- **Decision:** For every plugin whose tag exists only locally, the closing report prints the literal push command for
  that tag.
- **Rationale:** `T4` established that re-running the release does not retry a failed push: it meets the
  already-exists refusal and stops. A report that says "re-run" would send the maintainer into a loop that reports
  success while tags are still missing.
- **Evidence:** `T4`, verified during specification work.
- **Rejected alternatives:**
  - Tell the maintainer to re-run the release — rejected by `T4`. The re-run meets the already-exists refusal and stops,
    so it reports success while the tag is still missing from GitHub.
  - Have the run retry the push itself — rejected as a strictly larger version. The failure the report covers is one the
    maintainer has to look at anyway, and an automatic retry hides which tags reached GitHub, the distinction `D-5`
    exists to preserve.
- **Driven by rounds:** R1 (`C15`; `DOR-9`)
- **Referenced in plan:** Implementation Approach (the closing report), Work Units and Sequencing (unit 5)

## D-14: Make the changelog augment replace its bookkeeping rather than append

- **Decision:** When a generated bookkeeping subsection already exists under the release's changelog section, replace it
  instead of appending a second copy.
- **Rationale:** Before this change the only abort point came before the commit, so a re-run never met its own earlier
  changelog edit. The mandatory approval stop sits after the commit, which makes "decline, then run again later" an
  ordinary path. The second run takes the augment branch and appends a duplicate bookkeeping subsection, and the release
  body assembled from it inherits the duplication.
- **Evidence:** The augment branch is at `SKILL.md:248-255` and says to leave existing lines untouched and append. The
  specification's failure table commits the decline path to naming "what a later run would pick up".
- **Rejected alternatives:**
  - Leave the append behavior and name the duplication in the decline message — rejected. It moves a defect the run
    creates onto the maintainer to clean up by hand, on the path this change makes ordinary rather than rare.
  - Skip the changelog step entirely on a re-run — rejected as strictly larger. It changes when the changelog is
    written, which the specification puts out of scope, to fix a duplication that replacing one subsection fixes.
- **Scope note:** the specification puts the changelog's structure, headings, and prose out of scope. This changes none
  of those; it changes how the skill writes a subsection it generates. Recorded here so the boundary call is visible
  rather than assumed.
- **Driven by rounds:** R1 (`C14`; `DOR-7`)
- **Referenced in plan:** Implementation Approach (the decline path), Work Units and Sequencing (unit 7)

## D-15: Merge to the default branch, then cut the release from it

- **Decision:** Merge the change to the default branch before cutting the release, and cut from there.
- **Rationale:** The specification deferred *refusing* a non-default branch, because refusing would block this release.
  It said nothing about where to cut this release from. Cutting from the default branch removes the whole class the
  deferral describes at no cost, and it is what every recent release already did.
- **Evidence:** Verified in this repository: the three most recent release tags are all ancestors of the default
  branch. The skill lives in the checked-out tree, so the change is exercised by the release it ships in.
- **Rejected alternatives:**
  - Cut from the topic branch and rely on the approval stop naming the branch — rejected. The stop is the deferral's
    mitigation for a release that has to be cut from a topic branch, not a reason to choose one.
- **Driven by rounds:** R1 (`C16`; `DOR-10`)
- **Referenced in plan:** Work Units and Sequencing (unit 8)

## D-16: Keep three separate stops, with distinct headers

- **Decision:** The version-plan confirmation, the pre-publish pause, and the new tag-approval stop all stay, each with
  a header naming what it approves.
- **Rationale:** A maintainer who asks for the pre-publish pause now meets two prompts close together. Merging them
  would mean new conditional logic and would change what an existing opt-in flag means; distinct headers cost nothing
  and make each prompt legible.
- **Evidence:** The pre-publish pause sits at `SKILL.md:317-318`, before the commit-tag-push step at `SKILL.md:322-335`,
  not after it as the specification's `D15` evidence states. That misplacement does not change `D15`'s conclusion,
  which rests on the pause being opt-in, but it does change where the new stop goes relative to it.
- **Rejected alternatives:**
  - Merge the pre-publish pause into the new tag stop — rejected. It needs new conditional logic and it changes what the
    existing opt-in flag means for a maintainer who already uses it, to save one prompt on an opt-in path.
- **Driven by rounds:** R1 (`C8`; `JD-008`)
- **Referenced in plan:** Implementation Approach (making the approval stop real), Work Units and Sequencing (unit 5)

## D-17: One test file and one rehearsal, no release harness

- **Decision:** Testing is a test file beside the new script covering its four classifications and both tag kinds, plus
  a dry-run rehearsal across every plugin in a throwaway clone before the release. No mock tagging binary, no mock
  publishing tool, no marketplace fixtures, no tag-triggered automation.
- **Rationale:** The skill body is prose a model executes and is not unit-testable, so a test work unit with nothing to
  point at would produce nothing. The script is real code with a verified silent-failure mode, so it gets a test. A
  harness would be the largest artifact in the change, built for one maintainer cutting a release every few weeks, with
  no recorded incident behind it.
- **Evidence:** The repository has no tests for the release skill and no fixture. Recent history over the skill shows
  documentation and formatting churn only, with no functional change to the release logic and no incident. The
  dry-run form already exists and already validates without creating anything, and it is the instrument the
  specification's own evidence was gathered with.
- **Rejected alternatives:**
  - Build the release harness with mock tagging and publishing tools and marketplace fixtures — rejected on the evidence
    test and carried in the plan's `Deferred (YAGNI)` section with its reopening trigger.
  - Add tag-triggered automation that checks a pushed tag is well-formed — rejected the same way, and deferred with its
    own trigger.
- **Reopen when:** a release produces a tag at an unintended commit, or the skill grows a second script the first one's
  tests do not cover.
- **Driven by rounds:** R1 (`C18`; `JD-010`, `DOR-11`)
- **Referenced in plan:** Constraints and Boundaries, Testing Strategy, Deferred (YAGNI)

## D-18: Schedule the fallback arm's removal as a named follow-up

- **Decision:** Record removing the old-naming fallback as a named follow-up work unit whose trigger is met the moment
  this release pushes the parent's tag.
- **Rationale:** The specification commits to the fallback being removed once a parent-plugin tag exists on GitHub. Left
  unscheduled, a branch that can never be reached again stays in the skill indefinitely, which is the debt the
  specification's own review objected to.
- **Evidence:** The specification's `D7` states the expiry. The trigger is satisfied by this release itself.
- **Rejected alternatives:**
  - Remove the fallback in this same change — rejected. The fallback is what makes this release read its own predecessor
    correctly; removing it before the release makes the transition release find no previous tag and cover the whole
    repository history.
  - Leave the removal unscheduled — rejected. That is the debt the specification's own review objected to, and the
    trigger is met by this release, so there is nothing to wait for.
- **Driven by rounds:** R1 (`C16`; `DOR-10`)
- **Referenced in plan:** Work Units and Sequencing (unit 9), Open Items

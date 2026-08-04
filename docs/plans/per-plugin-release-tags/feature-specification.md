# Feature Specification: Per-Plugin Release Tags

Cutting a Han release stops creating one tag for the whole suite and starts creating one tag per plugin, named for that
plugin and its own version. This is what lets Claude Code install a Han plugin at a specific version instead of always
taking the newest one.

## Outcome

After a release finishes, every plugin in the Han marketplace has a git tag carrying its own name and its own version,
and those tags are on GitHub. A person or a tool asking "which versions of `han-core` can I install?" gets a real answer
from the tag list.

Today they cannot. One tag per release, named for the suite, says only which suite version shipped. Claude Code reads
tags to resolve a plugin dependency that asks for a version range, and there is nothing for it to read
([D1](artifacts/decision-log.md#d1-replace-the-suite-tag-with-per-plugin-tags)).

The suite tag goes away for new releases. The release that ships this change is tagged `han--v5.0.0`, not `v5.0.0`
([D1](artifacts/decision-log.md#d1-replace-the-suite-tag-with-per-plugin-tags)), and the GitHub release page hangs off
that tag ([D2](artifacts/decision-log.md#d2-what-the-github-release-attaches-to)). That name comes from `han` itself,
the parent plugin: the one that ships no skills of its own and exists to install the others, and whose version is the
number every release has been named for. The release keeps its plain title,
so the releases page still reads `v5.0.0` under a tag named `han--v5.0.0`
([D8](artifacts/decision-log.md#d8-human-facing-version-labels-stay-unprefixed)).

Nothing about this reaches anyone installing Han today. No Han plugin asks for a version range, so nothing resolves
against these tags yet. The tags have to exist before anything can.

## Actors and Triggers

- **Actors** — the Han maintainer cutting a release. Downstream, Claude Code reads the tags when someone installs a Han
  plugin whose dependency asks for a version range.
- **Triggers** — running `/han-release`.
- **Preconditions** — a clean checkout, the tools the release already checks for, and the Claude Code command line
  itself, which is what creates the tags
  ([D3](artifacts/decision-log.md#d3-how-the-tags-get-created), [D11](artifacts/decision-log.md#d11-the-new-prerequisite)).

## What Changes and What Does Not

The tagging step is the visible change, but it is not the only one. Six things change:

- The check for required tools gains one tool ([D11](artifacts/decision-log.md#d11-the-new-prerequisite)).
- Finding the previous release now spans two naming schemes, and that lookup feeds the parent's version baseline as well
  as the range of commits the release covers
  ([D7](artifacts/decision-log.md#d7-finding-the-previous-release)).
- Every plugin's version agreement is checked before anything is committed, rather than as each tag is created
  ([D14](artifacts/decision-log.md#d14-validate-every-plugin-before-the-release-commit)).
- The maintainer approves the tag names before any tag is pushed
  ([D15](artifacts/decision-log.md#d15-the-release-always-stops-before-the-first-tag-push)).
- One tag per plugin replaces the single suite tag
  ([D1](artifacts/decision-log.md#d1-replace-the-suite-tag-with-per-plugin-tags), [D4](artifacts/decision-log.md#d4-which-plugins-get-a-tag)).
- Both links that name a git ref are rebuilt: the link pinning a changelog section to a release, and the comparison link
  between releases ([D8](artifacts/decision-log.md#d8-human-facing-version-labels-stay-unprefixed)).

What does not change: how each plugin's version is worked out, the changelog's structure and prose, and the release
notes' layout.

## Primary Flow

1. The release checks up front that it can create tags at all, alongside its existing checks for the GitHub and JSON
   tools. A missing tool stops the run before anything is written
   ([D11](artifacts/decision-log.md#d11-the-new-prerequisite)).
2. The release refreshes its view of the tags on GitHub, then works out which release came before this one. It looks for
   the newest parent-plugin tag first and falls back to the old suite-tag naming, which is what the release before this
   one used. That tag supplies two things: the range of commits, pull requests, and issues the changelog covers, and the
   version the parent plugin is bumping from
   ([D7](artifacts/decision-log.md#d7-finding-the-previous-release), [T3](artifacts/feature-technical-notes.md#t3-reading-a-previous-release-across-both-naming-schemes)).
3. The release works out each plugin's version and confirms the plan, exactly as it does today.
4. Before committing anything, the release checks every plugin in the marketplace: that its manifest version and its
   marketplace entry version agree, and that nothing in its folder is uncommitted. A disagreement stops the run here,
   while nothing has been written and nothing pushed
   ([D14](artifacts/decision-log.md#d14-validate-every-plugin-before-the-release-commit)).
5. The release commits the version bumps and the changelog, then pushes that commit to GitHub. The commit reaches GitHub
   before any tag does, so no tag can point at a commit GitHub does not already hold on a branch
   ([D6](artifacts/decision-log.md#d6-when-tagging-happens), [D14](artifacts/decision-log.md#d14-validate-every-plugin-before-the-release-commit)).
6. The release shows the maintainer every tag it is about to create, the commit they will all point at, and which branch
   that commit is on. Then it waits for approval. This stop always happens
   ([D15](artifacts/decision-log.md#d15-the-release-always-stops-before-the-first-tag-push)).
7. The release then walks every plugin in the marketplace and creates and pushes that plugin's tag
   ([D4](artifacts/decision-log.md#d4-which-plugins-get-a-tag)). The parent plugin is tagged first, so the tag the
   release itself attaches to is the one most likely to exist if the walk stops partway
   ([D9](artifacts/decision-log.md#d9-what-happens-when-a-push-fails)). A plugin whose version did not change is walked
   too, so a plugin that has never been tagged picks up its first tag.
8. Each tag is created through Claude Code's own plugin tagging command, not by hand. That command re-checks that the
   plugin's manifest and its marketplace entry agree before the tag exists
   ([D3](artifacts/decision-log.md#d3-how-the-tags-get-created), [T1](artifacts/feature-technical-notes.md#t1-resolving-the-claude-code-executable)).
9. The release publishes the GitHub release against the parent plugin's tag, but only once every plugin's tag is
   confirmed on GitHub ([D2](artifacts/decision-log.md#d2-what-the-github-release-attaches-to), [D5](artifacts/decision-log.md#d5-a-tag-already-on-github-is-a-skip)).
10. The closing report names the commit every tag points at and whether that commit is on the default branch. For each
    plugin, it also names whether that plugin's tag was newly pushed, already on GitHub, or exists only on the
    maintainer's machine, and it gives the release URL ([D9](artifacts/decision-log.md#d9-what-happens-when-a-push-fails)).

## Alternate Flows and States

### A plugin's tag is already on GitHub at the release commit

- **Entry condition:** the release reaches a plugin whose name and version already have a tag on GitHub, pointing at the
  commit being released. This is the normal state for a plugin nobody changed since the last release.
- **Sequence:** the release notes the tag as already present and moves to the next plugin. It does not move the existing
  tag, and it does not treat the refusal as a failure
  ([D5](artifacts/decision-log.md#d5-a-tag-already-on-github-is-a-skip), [D10](artifacts/decision-log.md#d10-never-move-an-existing-tag), [T2](artifacts/feature-technical-notes.md#t2-telling-an-existing-tag-apart-from-a-failure)).
- **Exit:** the run continues. The closing report lists the plugin as already on GitHub.

### A plugin's tag exists only on the maintainer's machine

- **Entry condition:** a tag was created locally but never reached GitHub, which is what a failed push leaves behind. The
  most common way to arrive here is re-running a release that failed partway through.
- **Sequence:** the release does not treat this as already tagged. The tag must reach GitHub before the run may publish
  ([D5](artifacts/decision-log.md#d5-a-tag-already-on-github-is-a-skip), [T2](artifacts/feature-technical-notes.md#t2-telling-an-existing-tag-apart-from-a-failure), [T4](artifacts/feature-technical-notes.md#t4-a-failed-push-leaves-the-tag-on-the-machine)).
- **Exit:** either the tag pushes and the run continues, or the run stops and reports the plugin as local only. It does
  not publish a release whose tags are partly absent from GitHub.

### The first release under the new naming

- **Entry condition:** no tag carrying a plugin name exists yet, which is true exactly once.
- **Sequence:** the release finds the previous release under the old suite naming. The changelog still covers only
  the commits since that release rather than the whole history, and the parent's version baseline is read out of that
  older tag ([T3](artifacts/feature-technical-notes.md#t3-reading-a-previous-release-across-both-naming-schemes)). Every
  plugin in the marketplace gets its first tag, whether or not it changed
  ([D4](artifacts/decision-log.md#d4-which-plugins-get-a-tag)).
- **Exit:** the suite is fully tagged under the new naming. Every release after this one finds its predecessor under the
  new naming, so the fallback to the old naming is removed once a parent-plugin tag exists on GitHub
  ([D7](artifacts/decision-log.md#d7-finding-the-previous-release)).

### The release is cut a second time for the same version

- **Entry condition:** the maintainer re-runs the release for a version that was already tagged and published, usually
  to correct the notes.
- **Sequence:** every tag already on GitHub is reported as present and none is recreated
  ([D5](artifacts/decision-log.md#d5-a-tag-already-on-github-is-a-skip)). Any tag that exists only locally is pushed
  first. The existing GitHub release is updated in place rather than a second one being created, as it is today.
- **Exit:** the run reports the release as updated, not created.

## Edge Cases and Failure Modes

| Condition                                                                       | Required Behavior                                                                                                                                                                                                                                                                                     |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The Claude Code command line is missing                                         | The run stops before writing anything, naming the missing tool, the same way a missing GitHub or JSON tool stops it today ([D11](artifacts/decision-log.md#d11-the-new-prerequisite)).                                                                                                                 |
| A plugin's manifest version and its marketplace entry version disagree          | Found before the release commit exists. The run stops, names the plugin and the two versions, and has written and pushed nothing ([D14](artifacts/decision-log.md#d14-validate-every-plugin-before-the-release-commit)).                                                                               |
| The same disagreement is somehow reached mid-walk                               | The run stops and reports the full tag state, the same way a push failure does. This is an unexpected stop rather than a routine one, because the check ahead of the commit should have caught it ([D14](artifacts/decision-log.md#d14-validate-every-plugin-before-the-release-commit), [T2](artifacts/feature-technical-notes.md#t2-telling-an-existing-tag-apart-from-a-failure)). |
| The maintainer declines at the tag approval stop                                | Nothing is tagged and nothing is published. The release commit is already made and pushed, so the run says so and names what a later run would pick up ([D15](artifacts/decision-log.md#d15-the-release-always-stops-before-the-first-tag-push)).                                                      |
| Pushing the release commit fails                                                | The run stops before any tag is created. Nothing irreversible has happened, because a tag pointing at an unpushed commit is what this ordering exists to prevent ([D6](artifacts/decision-log.md#d6-when-tagging-happens)).                                                                            |
| A tag push fails partway through, so some tags reached GitHub and some did not   | The run stops at the failure and does not publish. It reports which tags are on GitHub, which exist only on the maintainer's machine, and the command that pushes the rest ([D9](artifacts/decision-log.md#d9-what-happens-when-a-push-fails), [T4](artifacts/feature-technical-notes.md#t4-a-failed-push-leaves-the-tag-on-the-machine)). |
| A tag for that plugin and version is already on GitHub, at a different commit    | The run stops, names both commits, and says plainly that pushing is not the recovery. Pushing fails the same way every time, and the tag cannot be moved ([D10](artifacts/decision-log.md#d10-never-move-an-existing-tag), [T4](artifacts/feature-technical-notes.md#t4-a-failed-push-leaves-the-tag-on-the-machine)). |
| The working tree is dirty when the walk starts                                    | Tagging refuses and the run stops. The release requires a clean checkout before it begins and re-checks every plugin before committing, so this means something wrote a file mid-run ([D14](artifacts/decision-log.md#d14-validate-every-plugin-before-the-release-commit)).                            |
| A previous release exists under the old suite naming but none under the new       | The old naming supplies both the commit range and the parent's version baseline. When neither naming finds a tag, the run is a first release and behaves as it does today: the range is the whole history and the comparison link is left out ([D7](artifacts/decision-log.md#d7-finding-the-previous-release), [T3](artifacts/feature-technical-notes.md#t3-reading-a-previous-release-across-both-naming-schemes)). |
| A plugin was added to the marketplace since the last release                      | It is walked like every other plugin. A brand-new plugin is not bumped by the release that introduces it, so its first tag carries its introduction version rather than an incremented one ([D4](artifacts/decision-log.md#d4-which-plugins-get-a-tag)).                                                |
| No commits have landed since the previous release                                 | The run stops and says there is nothing to release, as it does today. Tagging is not reachable without a release, so a plugin added after a release waits for the next one to get its tag ([D4](artifacts/decision-log.md#d4-which-plugins-get-a-tag)).                                                 |

## User Interactions

`/han-release` has no interface beyond what it prints and the stops it makes.

- **Affordances:** the maintainer approves the tag names at a stop that always happens, immediately before the first tag
  is pushed ([D15](artifacts/decision-log.md#d15-the-release-always-stops-before-the-first-tag-push)). This is separate
  from the existing version-plan confirmation, which stays conditional and does not fire when every plugin's version was
  already bumped during development. That is the state the repository is in today, so without this stop the release
  would create its tags having asked nothing.
- **Feedback:** the approval stop lists every plugin split into tags to create and tags already on GitHub. It also names
  the commit they will point at and the branch that commit is on. The closing report names each plugin's final state:
  newly pushed, already on GitHub, or present only locally
  ([D9](artifacts/decision-log.md#d9-what-happens-when-a-push-fails)).
- **Error states:** a missing tool, a version disagreement, a failed commit push, a failed tag push, and a tag already on
  GitHub at a different commit each stop the run. Each stop comes with a message naming what happened and what state
  the repository is in.
- **Draft releases:** asking for a draft still creates and pushes every tag. Only the release page is held back, because
  a release page needs a tag to attach to. The approval stop says so, so a maintainer reaching for draft knows the tags
  are not part of what is being deferred.
- **Interruptions:** the run stops for the tag approval and, when the version plan needs it, the version confirmation.
  It does not stop per plugin, provided the tagging command is covered by what the run is permitted to execute without
  asking. Confirming that coverage is an implementation concern ([T1](artifacts/feature-technical-notes.md#t1-resolving-the-claude-code-executable)).

## Coordinations

| Coordinating System         | Direction | Interaction                                                                        | Ordering / Consistency Requirement                                                                                                                       |
| --------------------------- | --------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The Han marketplace listing | inbound   | Supplies the plugin names, source folders, and versions the tags are built from    | Every plugin's manifest version and its marketplace entry version must agree before the release commit is made, not merely before that plugin is tagged ([D14](artifacts/decision-log.md#d14-validate-every-plugin-before-the-release-commit)). |
| GitHub                      | outbound  | Receives the release commit, then the tags, then the published release             | The commit is pushed before any tag ([D6](artifacts/decision-log.md#d6-when-tagging-happens)). Every tag is confirmed on GitHub before the release is published ([D5](artifacts/decision-log.md#d5-a-tag-already-on-github-is-a-skip)). |
| Claude Code plugin install  | outbound  | Reads the tags when resolving a Han plugin dependency that asks for a version range | A version is installable only once its tag is on GitHub. No Han plugin asks for a version range today, so nothing depends on this yet.                    |

## Out of Scope

- The changelog's structure, its per-plugin version headings, and its prose. Two things inside the release notes do
  change: both links that name a git ref, and the statements in the release skill's own reference material that describe
  the tag as carrying the plain version
  ([D8](artifacts/decision-log.md#d8-human-facing-version-labels-stay-unprefixed)).
- How each plugin's version is worked out. The rules for which plugin bumps and by how much are unchanged. What does
  change is where the parent's starting version is read from, because that value comes out of the previous tag
  ([D7](artifacts/decision-log.md#d7-finding-the-previous-release)).
- The tags for releases already published. They stay exactly as they are
  ([D13](artifacts/decision-log.md#d13-existing-tags-stay)).

One documentation file outside the release skill is corrected: the repository's versioning guide currently states that
Han does not need per-plugin tags and that the single suite tag is sufficient. The release skill reads that guide to
classify each plugin's bump level, so leaving it would leave the next maintainer a documented reason to undo this change
([D12](artifacts/decision-log.md#d12-correcting-the-versioning-guide)).

## Cut for Scope

This is work the work item excludes, not work deferred for lack of evidence. Nothing here carries a reopening trigger,
because the recorded boundary already settled it.

### Pinning Han's own plugins to version ranges, so `han` installs a tested set rather than the newest of everything

- **Why cut:** this is the capability the tags make possible, and it is the obvious next step, but the work item asks
  only for the tagging. Every Han plugin currently names its dependencies without a version, so nothing breaks by
  leaving them alone. Reinstating this is your call, and your saying so is itself the justification it would record.

### Creating tags for the releases already published, so older versions are installable by name too

- **Why cut:** the recorded boundary deprecates the old naming for new releases and does not direct any change to
  existing tags. Doing this would also mean deciding what version each plugin held at each of 27 past release commits,
  which is a research job the work item does not ask for.

## Deferred (YAGNI)

This is work no evidence supports yet, not work the work item excludes. Every entry carries the trigger that would
justify revisiting it.

### Checking after the release that a tag resolves to an installable plugin

- **Why deferred:** fails the evidence test. No Han plugin asks for a version range, so there is no resolution path to
  verify and no incident or report showing one broke. The checks ahead of the release commit already catch the version
  disagreement this would surface.
- **Reopen when:** any Han plugin's manifest names a dependency with a version range, or a released tag is found to
  point at a plugin version that cannot be installed.
- **Source:** conversation context during the interview.

### Refusing to cut a release from a branch other than the default one

- **Why deferred:** fails the simpler-version test. The concern is real: tags pushed from a branch that is later
  squash-merged point at a commit no branch contains, and those tags cannot be moved. But refusing would block the
  release this change ships in, which is being prepared on a non-default branch. Naming the branch at the approval stop
  satisfies the same evidence and leaves the judgment with the maintainer.
- **Reopen when:** a release is found to have tags pointing at a commit absent from the default branch.
- **Source:** review finding F1 (`DOR-1`).

## Open Items

None. Every finding from the review round was resolved, by evidence or by your answer at the tag-approval question.

## Summary

- **Outcome delivered:** every plugin in the Han marketplace gets its own named, versioned tag on each release, replacing
  the single suite tag. A stop always shows you the tags before they become permanent.
- **Primary actors:** the Han maintainer cutting a release; Claude Code when resolving a version-constrained Han
  dependency.
- **Decisions settled by evidence:** 13 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** `han-core:junior-developer`, `han-core:devops-engineer` — see
  [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the previous tag turned out to feed the parent's version baseline, not only the
  commit range. The naming change silently corrupts the version plan on the second release unless the baseline is
  read out of the new tag shape. Validation moved ahead of the release commit. The run now distinguishes a tag on
  GitHub from a tag that exists only locally, which is what stopped a re-run from publishing a release with missing
  tags. — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Judgment call for you to confirm:** the plan corrects the repository's versioning guide, which sits outside the
  release skill your scope statement named. Cutting it is your call, and no other decision rests on it
  ([D12](artifacts/decision-log.md#d12-correcting-the-versioning-guide)).
- **Remaining open items:** 0
- **Technical notes:** 4 — see [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md)

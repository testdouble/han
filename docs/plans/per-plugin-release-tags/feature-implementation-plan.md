# Feature Implementation Plan: Per-Plugin Release Tags

How to change `/han-release` so it creates one git tag per plugin instead of one for the whole suite. The behavior is
settled in [feature-specification.md](feature-specification.md); this plan covers how to build it.

Most of the work is prose edits to one skill file.

The parts that need care are three traps that fail silently, all three verified in this repository rather than
reasoned about.

## Outcome

When this is done, running `/han-release` stops to show you the tag names and waits for your approval. Then it creates
and pushes a tag for every plugin in the marketplace, and then publishes the release against the parent's tag.

Three things have to be right for that sentence to be true, and none of them is obvious from reading the skill:

- The approval stop has to appear. Today it would not
  ([D-1](artifacts/implementation-decision-log.md#d-1-remove-askuserquestion-from-the-skills-auto-approve-list)).
- The run has to know which tags are on GitHub, which the tagging tool cannot tell it
  ([D-5](artifacts/implementation-decision-log.md#d-5-establish-remote-tag-state-once-in-a-script-peeling-annotated-tags)).
- The version plan has to keep working once the tag it reads changes shape
  ([D-10](artifacts/implementation-decision-log.md#d-10-state-the-baseline-parse-rule-as-the-part-after-the-last-v)).

## User Stories

The maintainer is the only actor with a story here. Nobody installing Han is affected yet, because no Han plugin asks
for a version range.

- **As the maintainer cutting a release,** I want to see the tag names and the commit they will point at before any of
  them is created, so that a wrong version number costs me a keystroke instead of a permanent public tag I am not
  allowed to move.
- **As the maintainer,** I want the run to stop before it does anything irreversible when a tag it needs is already
  taken, so that I choose a different version with nothing to unwind.
- **As the maintainer reading the closing report,** I want to know which tags reached GitHub, so that I can
  tell a clean release from one that only looks clean.
- **As the maintainer cutting the release after this one,** I want the version plan to be correct, so that the new tag
  naming does not quietly compute the wrong bump.

## Constraints and Boundaries

- **A pushed tag is never moved.** GitHub enforces it too: once a release is published, its tag cannot be modified or
  deleted. Every irreversible step needs a check in front of it, not a recovery behind it.
- **The skill is prose a model executes.** Only the one new script is code. That shapes what can be tested and what can
  only be rehearsed
  ([D-17](artifacts/implementation-decision-log.md#d-17-one-test-file-and-one-rehearsal-no-release-harness)).
- **This change releases itself.** The skill lives in the checked-out tree, so the first real exercise of the new
  behavior is the release that ships it.
- **The four technical notes are committed mechanics**, not open questions. Both reviewing specialists confirmed all
  four.
- **Out of scope**, from the specification: how each plugin's version is worked out, the changelog's structure and
  prose, and the tags for releases already published.

## Implementation Approach

### Making the approval stop real

The skill's front matter currently lists the question tool in its auto-approve list. A permission-evaluator defect
auto-approves it and returns an empty answer without ever rendering the prompt, so the stop the specification depends on
would silently pass. Both existing stops are affected today, which nobody has noticed because neither fires on a default
run. Delete the entry
([D-1](artifacts/implementation-decision-log.md#d-1-remove-askuserquestion-from-the-skills-auto-approve-list)). The
upstream defect is still live, so also treat an unreadable answer at this one stop as a decline
([D-2](artifacts/implementation-decision-log.md#d-2-an-unreadable-answer-at-the-tag-stop-is-a-decline)).

The skill ends up with three stops. Keep them separate and give each a header naming what it approves: the version plan,
the tags, and publishing
([D-16](artifacts/implementation-decision-log.md#d-16-keep-three-separate-stops-with-distinct-headers)).

### Finding the previous release

Two probes, never one pattern covering both namings. A combined pattern returns the old suite tag on every release
after the transition. That happens because the version sort compares the refname, and the parent's name sorts ahead of
the bare `v`
([D-9](artifacts/implementation-decision-log.md#d-9-two-separate-previous-tag-probes-never-one-combined-pattern)).

The tag also supplies the parent's starting version, which is the finding that reshaped the specification. State the
rule as **the part of the tag after its last `v`**, with both worked examples in the vocabulary block: the section near
the top of the skill that defines the terms its steps use, including how the previous tag's number is read
([D-10](artifacts/implementation-decision-log.md#d-10-state-the-baseline-parse-rule-as-the-part-after-the-last-v),
[T3](artifacts/feature-technical-notes.md#t3-reading-a-previous-release-across-both-naming-schemes)).

```
v4.6.0        -> 4.6.0
han--v5.0.0   -> 5.0.0
```

One caveat to write down: a probe is a fixed string and cannot look up the parent's name, so it carries the parent tag
pattern literally. If the parent is ever renamed the probe returns nothing, the run reads that as a first release, and
the changelog silently covers the whole repository history. One sentence in the step handles it.

### Validating before the commit

Do this with two plain file checks, not by invoking the tagging tool
([D-3](artifacts/implementation-decision-log.md#d-3-validate-with-file-comparison-not-with-the-tagging-commands-dry-run)).
Compare each plugin's manifest version against its marketplace entry, selected by name, and check the working tree once.

Placement is the whole point. Run the pair **before** the version-application step, while the tree is still clean, so
the specification's promise holds literally: the run has written and pushed nothing. Then re-run the version comparison
alone after that step and before the commit, which covers the half-applied bump the writes themselves can create.

Running the tagging tool here instead would refuse every plugin whose version the release bumped, because their
folders are dirty by construction at that moment. It could not tell that refusal apart from the drift it is hunting.

### Knowing what is on GitHub

The tagging tool never consults the remote ([T2](artifacts/feature-technical-notes.md#t2-telling-an-existing-tag-apart-from-a-failure)), so the run
has to read it separately. Fetching tags does not work either: a fetch merges remote tags into the local list. After that merge, a tag that
reached GitHub and one that never left the machine look identical, and telling those apart is the whole point.

Add one script that takes the release commit and the expected tag names. It reads the remote tag list and the local
tag list once each, and classifies every tag into one of four states
([D-5](artifacts/implementation-decision-log.md#d-5-establish-remote-tag-state-once-in-a-script-peeling-annotated-tags)):

```
absent                  not on GitHub, not local            -> create it and push it
remote-at-commit        on GitHub, at the release commit    -> skip it, and report it as already present
remote-at-other-commit  on GitHub, pointing somewhere else  -> stop the run, naming both commits
local-only              on this machine, never pushed       -> push it; this is never a skip
```

The four behaviors on the right are the specification's, not new ones
([D5](artifacts/decision-log.md#d5-a-tag-already-on-github-is-a-skip),
[D10](artifacts/decision-log.md#d10-never-move-an-existing-tag),
[T4](artifacts/feature-technical-notes.md#t4-a-failed-push-leaves-the-tag-on-the-machine)). What the script adds is a
reliable way to tell the four apart. Only `remote-at-commit` is a skip; a tag that exists only on the machine looks like
a skip and is not one, which is the distinction the whole script exists to draw.

**The peel is why this is a script.** A remote tag listing reports the tag object for an annotated tag, not the commit
it points at, and the tagging tool creates annotated tags. Verified here: the listing gives `4814987` for `v4.6.0` while
the commit is `fdafcb6`. A comparison that reads the unpeeled value classifies every tag as sitting at a different
commit, and under the specification's failure table that state stops the run and declares recovery impossible. The
release process would halt on its first plugin, every time, and the error message would be actively misleading.

Run the script twice. Once right after the release commit is pushed and **before** the approval stop, so a tag already
taken at another commit stops the run while zero tags exist
([D-6](artifacts/implementation-decision-log.md#d-6-stop-before-the-walk-when-any-tag-is-on-github-at-a-different-commit)).
Once after the walk, as the publish gate.

### Tagging each plugin

Walk the entry whose name matches the parent first, then the rest in listed order. The parent is first in the file
today, so ordering by position would satisfy the requirement by accident
([D-12](artifacts/implementation-decision-log.md#d-12-walk-the-parent-by-name-not-by-position)).

Invoke the tool through the shell's `command` builtin, and declare that form in the skill's permissions
([D-4](artifacts/implementation-decision-log.md#d-4-invoke-the-tagging-command-through-the-shells-command-builtin),
[T1](artifacts/feature-technical-notes.md#t1-resolving-the-claude-code-executable)). A bare call runs whatever shell
function wraps the tool, which on the authoring machine blocks waiting for terminal input. A resolved binary path avoids
that but is machine-specific and cannot be named by a shipped permission rule. The builtin does both jobs.

```
command claude plugin tag {source} --push
```

The commit can move while the run waits at the approval stop, and tags are created against the current checkout. Record
the commit when it is made, show it at the stop, and re-read it after approval. If it changed, stop
([D-7](artifacts/implementation-decision-log.md#d-7-re-check-the-commit-after-the-approval-stop)).

### Publishing

The publishing tool creates a missing tag by itself, at the default branch's head, rather than failing. Pass the flag
that aborts instead, and require the post-walk snapshot to show every tag on GitHub at the release commit
([D-8](artifacts/implementation-decision-log.md#d-8-make-the-publish-step-refuse-to-create-a-tag)). Without this, a walk
that missed the parent's push ends with a permanent tag minted at a commit nobody released.

### What changes and what stays

The version string appears far more often than the tag does, and most occurrences are not git refs. A find-and-replace
over it invalidates every historical changelog anchor, which is exactly what the specification rejects
([D-11](artifacts/implementation-decision-log.md#d-11-carry-an-explicit-list-of-which-occurrences-change-and-which-do-not)).

| Becomes `han--v{parent target}`                    | Stays `v{parent target}`                |
| -------------------------------------------------- | --------------------------------------- |
| The previous-tag lookup                            | Changelog section headings              |
| Tag creation, including the tag's own message      | The changelog anchor computation        |
| The tag push                                       | The GitHub release **title**            |
| The publishing calls, in both files that hold them | The release-notes temporary filename    |
| The pinned changelog link                          | The commit subject `chore(release): v…` |
| The comparison link between releases               |                                         |
| The tag named to the operator in the version plan  |                                         |

The commit subject and the temporary filename are the two most likely to be swept up by accident. The tag named in the
version plan is the one most likely to be missed in the other direction. It is prose rather than a command, so a
search for git commands does not find it. It is also what the operator reads at the approval stop. Left plain, it
shows the wrong name at the one place the specification makes the maintainer look. On the transition release the
comparison link spans both namings, `v4.6.0...han--v5.0.0`, which is correct.

One occurrence belongs in neither column. The existing-tag check that reads the local and remote tag lists is replaced
outright by the remote-state script rather than renamed
([D-5](artifacts/implementation-decision-log.md#d-5-establish-remote-tag-state-once-in-a-script-peeling-annotated-tags)).

Three statements become false and are corrected alongside the links. Two sit in the skill's own vocabulary block, both
asserting that the release tag is the plain version; unit 2 corrects them while it is already rewriting that block. The
third sits in the release-notes reference and says the tag and the body title are both the plain version; unit 6
corrects it with the links beside it.

### The decline path

The mandatory stop sits after the release commit, so "decline, then run again later" becomes an ordinary path rather
than a rare one. The second run finds its own changelog section already present. That sends it down the augment branch,
which is what the skill does when the section exists: leave the prose alone and add the generated bookkeeping beneath
it. So the run appends a second copy of a subsection that is already there. Make the augment replace an existing
generated subsection rather than append beside it
([D-14](artifacts/implementation-decision-log.md#d-14-make-the-changelog-augment-replace-its-bookkeeping-rather-than-append)).

### The closing report

For any plugin whose tag exists only locally, print the literal push command for that tag
([D-13](artifacts/implementation-decision-log.md#d-13-the-report-prints-the-command-that-actually-recovers)). Re-running
the release does not retry a failed push: it meets the already-exists refusal and stops
([T4](artifacts/feature-technical-notes.md#t4-a-failed-push-leaves-the-tag-on-the-machine)). A report that says "re-run"
sends the maintainer into a loop that reports success while tags are still missing.

## Work Units and Sequencing

The list is ordered by dependency throughout, and nothing in it depends on a unit further down. Unit 1 comes first
because every later rehearsal depends on a stop that renders and on an invocation the run is permitted to make. Units 2,
3, 4, and 6 depend on nothing and on each other in no order. Unit 5 comes after 1 and 4: it is the step that invokes the
script unit 4 builds, through the permission surface unit 1 fixes. Unit 7 comes after 5, because the decline path it
repairs is the one unit 5's stop creates. Unit 8 needs 1 through 7 finished. Unit 9 must follow unit 8, and nothing else
depends on unit 9.

1. **Fix the permission surface.** Remove the question tool from the auto-approve list; add the `command` form of the
   tagging tool. Then run one dry-run tagging call against a single plugin and watch for a permission prompt. That
   two-minute test tells you whether the rest of the plan needs a fallback
   ([D-1](artifacts/implementation-decision-log.md#d-1-remove-askuserquestion-from-the-skills-auto-approve-list),
   [D-4](artifacts/implementation-decision-log.md#d-4-invoke-the-tagging-command-through-the-shells-command-builtin)).
   _Advances: every story._

2. **Previous-release lookup and the parse rule.** Add the second probe, apply precedence in the step that reads them,
   and rewrite the baseline rule with both worked examples. Then correct the two vocabulary lines that assert the tag
   carries the plain version ([D-9](artifacts/implementation-decision-log.md#d-9-two-separate-previous-tag-probes-never-one-combined-pattern),
   [D-10](artifacts/implementation-decision-log.md#d-10-state-the-baseline-parse-rule-as-the-part-after-the-last-v)).
   _Advances: the correct-version-plan story._

3. **The pre-commit validation gate.** Two file checks, placed before the version-application step, plus the narrower
   re-check after it
   ([D-3](artifacts/implementation-decision-log.md#d-3-validate-with-file-comparison-not-with-the-tagging-commands-dry-run)).
   _Advances: the stop-before-irreversible story._

4. **The remote-state script and its test file.** Four classifications, both tag kinds, a bare repository on disk
   standing in for the remote. That is the whole fixture
   ([D-5](artifacts/implementation-decision-log.md#d-5-establish-remote-tag-state-once-in-a-script-peeling-annotated-tags),
   [D-6](artifacts/implementation-decision-log.md#d-6-stop-before-the-walk-when-any-tag-is-on-github-at-a-different-commit)).
   _Advances: the which-tags-reached-GitHub story._

5. **The tagging step itself.** The approval stop comes first, with its own header. It lists the tags split into ones
   to create and ones already on GitHub, and it names the commit and the branch. It also includes the note that asking
   for a draft still creates and pushes every tag, and it states its decline rule. It is a third stop beside the two
   the skill already has, not a merge of them. Then the commit re-check, the parent-first walk, the publish gate, and
   the report's recovery lines
   ([D15](artifacts/decision-log.md#d15-the-release-always-stops-before-the-first-tag-push),
   [D-2](artifacts/implementation-decision-log.md#d-2-an-unreadable-answer-at-the-tag-stop-is-a-decline),
   [D-7](artifacts/implementation-decision-log.md#d-7-re-check-the-commit-after-the-approval-stop),
   [D-8](artifacts/implementation-decision-log.md#d-8-make-the-publish-step-refuse-to-create-a-tag),
   [D-12](artifacts/implementation-decision-log.md#d-12-walk-the-parent-by-name-not-by-position),
   [D-13](artifacts/implementation-decision-log.md#d-13-the-report-prints-the-command-that-actually-recovers),
   [D-16](artifacts/implementation-decision-log.md#d-16-keep-three-separate-stops-with-distinct-headers)).
   _Advances: every story._

6. **The links and the reference files.** Both links that name a ref, the two publishing calls the release-notes
   reference repeats, and the false statement in that reference. Work from the two-column list rather than by
   search-and-replace
   ([D-11](artifacts/implementation-decision-log.md#d-11-carry-an-explicit-list-of-which-occurrences-change-and-which-do-not)).
   Also correct the versioning guide in all three places it states the old scheme. That means the note saying Han does
   not need per-plugin tags, the line saying a release's git tag tracks the parent version, and the worked example
   that tags a release `v3.1.0` ([D12](artifacts/decision-log.md#d12-correcting-the-versioning-guide)).
   _Advances: no story directly. It is what keeps every historical changelog anchor resolving, and it stops the
   versioning guide arguing against this change._

7. **The augment idempotency sentence**
   ([D-14](artifacts/implementation-decision-log.md#d-14-make-the-changelog-augment-replace-its-bookkeeping-rather-than-append)).
   _Advances: no story directly. It keeps the decline the first story asks for from leaving a duplicated changelog
   behind._

8. **Merge, then cut the release from the default branch**
   ([D-15](artifacts/implementation-decision-log.md#d-15-merge-to-the-default-branch-then-cut-the-release-from-it)).
   Every recent release was cut from there, verified. Doing the same here removes the stranded-tag risk the
   specification deferred, at no cost. _Advances: every story, by being the release that first exercises them._

9. **Follow-up: remove the old-naming fallback.** Its trigger is met the moment this release pushes the parent's tag
   ([D-18](artifacts/implementation-decision-log.md#d-18-schedule-the-fallback-arms-removal-as-a-named-follow-up)).
   Do not do this before the release; the fallback is what makes the release correct. _Advances: no story. It removes a
   branch that can never be reached again._

## Definition of Done

- The question tool is absent from the skill's auto-approve list, and the tag-approval stop was **observed** to stop and
  wait for a keystroke. Printing the list is not the same as stopping.
- One dry-run tagging call ran without a permission prompt, or the fallback in
  [D-4](artifacts/implementation-decision-log.md#d-4-invoke-the-tagging-command-through-the-shells-command-builtin) was
  applied.
- The remote-state script's test file passes under `npm test`, and `npm run lint` passes.
- After the release, the newest parent tag is `han--v5.0.0`, and the documented parse rule applied to it yields `5.0.0`.
- The changelog's pinned link and the comparison link both resolve. The comparison link reads `v4.6.0...han--v5.0.0`.
- Every historical changelog anchor still resolves, meaning no heading changed.
- The versioning guide no longer says the single suite tag is sufficient, and no longer says a release's git tag
  tracks the parent version under the old naming. Its worked example now names a per-plugin tag.

## Testing Strategy

Two things, and deliberately not a third
([D-17](artifacts/implementation-decision-log.md#d-17-one-test-file-and-one-rehearsal-no-release-harness)).

**A test file beside the new script**, covering the four classifications, an annotated tag, and a lightweight tag. A
bare repository on disk serves as the remote. This is the repository's existing pattern, used by four skills, and the
script earns it: the peel is a verified silent-failure mode with an irreversible consequence.

**A dry-run rehearsal** across every plugin in a throwaway clone, on the release commit, before cutting the release. The
dry-run form validates version agreement and cleanliness without creating anything, and it is the same instrument the
specification's evidence was gathered with.

Nothing else. The skill body is prose a model executes, so there is nothing for a test runner to exercise there.

## Risks and Assumptions

### Risks

- **The baseline fix ships unverified.** The corrupted version plan appears on the release *after* this one, so nothing
  in the `han--v5.0.0` run exercises it. This is the one change in the set its own release cannot test. Mitigation: the
  Definition of Done asserts the parse rule against the real tag by hand.
- **The permission matcher may not honor the `command` form.** Not observable from this repository and not inspected.
  Worst case is one approval prompt, and unit 1 finds out in two minutes.
- **The fallback arm becomes debt if unit 9 is dropped.** It is a branch that can never be reached again once this
  release lands.

### Assumptions

- The tagging tool creates annotated tags. Verified from its own dry-run output.
- The parent plugin is identified by name, matching the skill's existing vocabulary.
- The maintainer's shell wraps the tagging tool in a function. Verified on the authoring machine; the `command` form is
  correct either way.

## Deferred (YAGNI)

### A release harness with a mock tagging tool, a mock publishing tool, and marketplace fixtures

- **Why deferred:** fails the evidence test. No recorded incident, and recent history over the skill shows documentation
  churn only, with no functional change to the release logic. It would be the largest artifact in the change, built for
  one maintainer cutting a release every few weeks. The dry-run rehearsal satisfies the same concern at no build cost.
- **Reopen when:** a release produces a tag at an unintended commit, or the skill grows a second script the first one's
  tests do not cover.

### Tag-triggered automation that checks a pushed tag is well-formed

- **Why deferred:** fails the evidence test. No tag-triggered workflow exists, nothing consumes these tags yet, and the
  checks ahead of the commit already catch the malformed cases. Operational machinery ahead of the failures it covers.
- **Reopen when:** any Han plugin's manifest names a dependency with a version range, so a malformed tag would break an
  install.

### Applying the decline guard to all three stops

- **Why deferred:** fails the simpler-version test. The version-plan confirmation and the pre-publish pause are both
  recoverable; only the tag stop gates something permanent.
- **Reopen when:** an empty answer is observed at either of the other two stops.

## Open Items

- **OI-1:** Whether the permission matcher honors the `command` form of the tagging invocation.
  - **Resolves when:** unit 1 runs one dry-run call and observes whether a prompt appears.
  - **Blocks implementation:** No. It selects between the inline form and a script, and the fallback is recorded.
- **OI-2:** Removing the old-naming fallback after the release.
  - **Resolves when:** unit 9 runs, after `han--v5.0.0` is on GitHub.
  - **Blocks implementation:** No. It must not be done before the release.

## Sources and Plan Records

- [feature-specification.md](feature-specification.md) — the settled behavior.
- [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md) — D-1 through D-18.
- [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md) — the specialist round
  and the claim ledger.
- [artifacts/decision-log.md](artifacts/decision-log.md) — the specification's own decisions, D1 through D15, which this
  plan implements and does not reopen.
- [artifacts/feature-technical-notes.md](artifacts/feature-technical-notes.md) — T1 through T4, the committed mechanics
  both specialists confirmed.
- [artifacts/team-findings.md](artifacts/team-findings.md) — the specification's review round, F1 through F22.
- [artifacts/scope-boundary.md](artifacts/scope-boundary.md) — the recorded boundary.
- [artifacts/.discovery-notes.md](artifacts/.discovery-notes.md) — project context and verified command behavior.

## Recommendation

**Ship as planned.** The specialist round raised no question needing the maintainer's judgment: every one resolved from
evidence, four by direct verification in the repository. No finding was tagged spec-level, and both specialists
confirmed all four committed mechanics, so nothing here reopens the specification.

Do unit 1 first and do not skip its two-minute test. It is one line of front matter plus one dry run, and it decides
both whether the plan's central safety gate works at all and whether the plan needs a fallback shape.

# Feature Specification: Han Publishing Cleanup

Source: the "What I would do, in order" section of a cleanup plan for this repository. The seven steps are all retained.
Their execution order differs from the source's listing order, deliberately and with the reason recorded
([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

Companion artifacts:

- [Decision log](artifacts/decision-log.md)
- [Team findings](artifacts/team-findings.md)
- [Technical notes](artifacts/feature-technical-notes.md)

## Channels and targets

The spec stays channel-neutral throughout. This section is the one place the vocabulary is grounded, so the rest of the
document is readable without it.

- **Channel one** — the Claude Code marketplace. Healthy. Nothing here changes what it publishes.
- **Channel two** — the Codex marketplace. The one that has been rotting.
- **A storefront listing** — the per-channel catalogue that says which plugins exist. One per channel, two total.
- **A version record** — a place that states a plugin's published version. There are **three**, not two: each channel
  carries a per-plugin version record, and channel one's storefront listing also carries a version per plugin. Channel
  two's storefront listing carries no version at all
  ([D20](artifacts/decision-log.md#d20-version-agreement-covers-every-record-that-publishes-a-version)).
- **A target** — any of the four files a release must keep current: two storefront listings and two per-plugin version
  records. Channel one's listing is both a listing and a version record, which is why the four targets do not partition
  evenly into "two and two".
- **A plugin** — a directory the suite ships as an installable unit
  ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)).
- **The bundle** — the meta-plugin that installs the suite in one command. It exists on channel one only
  ([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel)).

## Outcome

Han is published completely and honestly to both of the places it ships to, and a check makes it impossible to quietly
stop being so.

Concretely, when this work is done:

- Every Han plugin advertised as installable on a channel is actually installable on that channel. Following the
  documented install instructions produces a working install, not an error.
- People who installed Han on channel two are offered updates again, once the mechanism this rests on is confirmed
  ([T1](artifacts/feature-technical-notes.md#t1-update-availability-on-channel-two-is-decided-by-the-published-version-number),
  [Open item 1](#open-items)).
- Publishing work items to a tracker never loses a work item without saying so.
- Every dependency a plugin declares is one it actually uses, so the declarations can be trusted to answer "what breaks
  if I change this?"
- Every document that describes Han's plugin topology describes the topology that exists.
- **Every document that describes Han's release procedure describes the procedure that exists**, so a contributor
  following the contributor guide is not blocked by the check for doing what the guide told them
  ([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).
- The release process starts from what is really in the repository, covers every target, and stops rather than shipping
  around a gap ([D5](artifacts/decision-log.md#d5-the-check-derives-the-plugin-list-from-the-repository)).
- A check enforces all of the above on every change, and it is green from the day it lands
  ([D1](artifacts/decision-log.md#d1-the-check-lands-last-because-a-check-that-blocks-everything-gets-disabled)).

## Actors and triggers

| Actor                     | Trigger                                                          | What they need from this feature                                            |
| ------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Han maintainer            | Works through the seven steps once                               | Each step lands without breaking the next; the real ordering constraints are stated |
| Han maintainer            | Cuts any future release                                          | The release covers every target and refuses to ship around a missing plugin |
| Contributor               | Opens a pull request that adds or renames a plugin               | The check tells them what is missing, and the contributor guide already told them the four targets |
| Channel-two installer     | Runs the documented install command for any advertised plugin    | The install succeeds                                                        |
| Channel-two installer     | Has Han installed and expects updates                            | Updates are offered when releases happen                                    |
| Work-items publisher user | Publishes a work-items file to a tracker after using another one | Nothing is dropped without an explicit, loud signal                         |

## Primary flow

Seven steps, executed in the order below. Only some adjacencies are forced; the forced ones are named and the rest are
free ([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

The binding constraints are: **the check is last**; **the release repair precedes the version correction**; **the
declaration deletion and the document correction are one unit**; and the work-items fix is independent of all of it.

### Step 1: Publish the Linear plugin to channel two

_Source position: 1._

The Linear plugin is advertised in channel two's setup instructions and was never published there. Someone following
those instructions gets an error today.

After this step, the Linear plugin appears in channel two's storefront listing and carries its own version record, so
the documented install command succeeds. Its new version record is created at the version channel one already publishes
for it, so it is correct on arrival rather than created wrong for a later step to repair
([D22](artifacts/decision-log.md#d22-the-new-version-record-is-created-at-the-plugins-channel-one-version)).

This goes first because it is the only step where a person following the project's own instructions hits an error right
now ([D11](artifacts/decision-log.md#d11-step-1-goes-first-because-it-is-a-live-broken-promise)).

### Step 2: Close the GitHub publisher's silent hole

_Source position: 2. Independent of every other step._

When the GitHub work-items publisher meets a work item already annotated by a different tracker, that work item is
neither published nor reported as skipped. It disappears from the run with no error and no signal.

After this step, every work item in the file is accounted for in every run: every heading is published,
skipped-and-counted, or surfaced
([D30](artifacts/decision-log.md#d30-accounted-for-is-defined-so-the-promise-is-not-circular)). A work item whose
annotation the publisher does not recognize is surfaced as a format error, and **the run stops before creating anything
at all** — the whole file is examined before the first item is published, so a foreign annotation late in the file cannot
be preceded by items already created
([D3](artifacts/decision-log.md#d3-a-foreign-annotation-stops-the-run-before-anything-is-created)).

The protection lives at every layer that inspects a heading, not only the last one. The publisher's own repair pass
recognizes a foreign annotation as a distinct category that it must not silently repair, so the annotation reaches the
gate rather than being tidied away before it
([D17](artifacts/decision-log.md#d17-the-foreign-annotation-category-exists-at-every-layer-that-inspects-a-heading)).

This step does not change the annotation format and requires no migration
([D2](artifacts/decision-log.md#d2-step-2-closes-the-silent-hole-only-annotation-namespacing-is-separate)). It shares no
actor, artifact, or failure mode with the other six steps and is retained here by explicit instruction rather than by a
dependency ([D23](artifacts/decision-log.md#d23-step-2-is-a-distinct-concern-retained-by-instruction)).

### Step 3: Teach the release process about every target

_Source position: 6. Moved ahead of the version correction — see
[D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)._

The release process updates two of the four targets, and takes its list of plugins from one of the targets it also
writes. It therefore cannot detect that the other two have fallen behind, which is why the drift went unnoticed across
roughly twenty releases.

After this step, a release derives the set of plugins from what is actually in the repository
([D5](artifacts/decision-log.md#d5-the-check-derives-the-plugin-list-from-the-repository)) and updates all four targets.

A release refuses to proceed when a plugin is missing from a target it belongs in, or when a plugin's version records
disagree. **The gate runs after the release has written all four targets and before it commits, tags, pushes, or
publishes anything** — early enough that every action after it is still local and reversible, late enough to judge the
state actually being released rather than the state before it
([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)).
When it stops, it names every gap it found rather than the first
([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)).

The release holds no copy of the rule. It runs the check and reports what the check says
([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)).

This step also corrects the documents that describe the release procedure, because this step is what makes them wrong
([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).

One exception is permanent and named: the bundle cannot be published to channel two, because that channel does not
support bundles. The rule knows this about that one plugin specifically and neither flags its absence nor applies the
version-agreement rule to it, since a plugin on one channel has nothing to disagree with
([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel)).

### Step 4: Correct the frozen version numbers

_Source position: 3. Moved after the release repair._

Channel two's published version numbers have not moved since the day they were created, so that channel never offers
anyone an update
([T1](artifacts/feature-technical-notes.md#t1-update-availability-on-channel-two-is-decided-by-the-published-version-number)).

After this step, each plugin's channel-two version matches the version channel one publishes for that same plugin
([D10](artifacts/decision-log.md#d10-the-two-channels-publish-one-version-per-plugin)).

Because the release process was repaired first, this correction is durable: the very next release keeps it correct
rather than re-freezing it. Had this step come first, any release cut before the repair would have undone it
([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).

### Step 5: Delete the two untrue dependency declarations

_Source position: 4. One unit with step 6._

Two plugins declare that they need the core plugin and never touch it. The reporting plugin's use moved elsewhere and
the declaration was left behind. The feedback plugin is not permitted to invoke other plugins at all, so its declaration
cannot be true.

After this step, the reporting plugin declares only what it uses, and the feedback plugin declares nothing. Installing
either no longer drags in a large plugin the installer will never use, and every remaining declaration in the suite is
one the declaring plugin actually uses
([D13](artifacts/decision-log.md#d13-both-untrue-declarations-are-deleted-rather-than-made-true)).

### Step 6: Correct every document the declaration deletion falsifies

_Source position: 5. Ships together with step 5 — a merged state where the declarations are gone and the documents still
narrate them is the state this step exists to prevent._

The test for inclusion is a rule, not a list: **a document is in scope when this work falsifies it**, and the step that
falsifies it owns it. Not "mentions a plugin", not "narrates topology", not "sits nearby"
([D7](artifacts/decision-log.md#d7-a-document-is-in-scope-when-this-work-falsifies-it)). This step owns the documents the
declaration deletion falsifies. Step 3 already owns the ones the release repair falsifies
([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).

After this step, no document describes a dependency the suite does not have. That includes the contributor guide, the
orientation document new readers are told to read first, the canonical long-form doc for the affected plugin, and the
tutorial that teaches plugin dependencies. It also includes one document that already described a topology the suite
never had, found while surveying the others
([D9](artifacts/decision-log.md#d9-the-already-false-contributor-claim-is-in-scope)).

Manifest descriptions are documents and are in scope. Manifest dependency declarations are the record itself, not a
description of it, and are step 5's business
([D25](artifacts/decision-log.md#d25-manifest-descriptions-are-documents-the-declarations-are-the-record)).

The corrected documents state the dependency **rule** and point at the manifests as the record, rather than restating
the manifests' contents in prose. Swapping a stale universal claim for a stale enumeration reproduces the same defect
with a longer half-life, and hardcoded counts are already a violation of this repository's own convention
([D26](artifacts/decision-log.md#d26-corrected-documents-state-the-rule-and-point-at-the-record)).

The tutorial that teaches plugin dependencies by walking through the two deleted edges has its worked example repointed
at edges that remain real, keeping its teaching shape
([D8](artifacts/decision-log.md#d8-the-tutorials-worked-example-repoints-to-surviving-real-edges)). Its claim to print
the real on-disk version numbers is dropped rather than repaired, because that claim is already false and keeping it
would create a maintenance obligation nobody asked for
([D27](artifacts/decision-log.md#d27-the-tutorial-teaches-shape-and-stops-promising-real-version-numbers)).

### Step 7: Turn on the automated check

_Source position: 7. Last, and this is the one hard ordering constraint the source plan argued for._

Only now does the rule become blocking. The rule itself has existed since step 3, because the release runs it; this step
is what makes it refuse a pull request
([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)). It verifies that every plugin
in the repository appears in every target it belongs in, and that a plugin's version records agree.

It runs on every pull request, and additionally on the machines of contributors who have installed the optional local
hooks ([D4](artifacts/decision-log.md#d4-the-check-blocks-on-every-pull-request-and-runs-locally-where-hooks-are-installed)).

Because steps 1 through 6 have already landed, the check is green on the day it arrives and stays green
([D1](artifacts/decision-log.md#d1-the-check-lands-last-because-a-check-that-blocks-everything-gets-disabled)). Every
problem above becomes impossible to reintroduce.

There is no disable switch, deliberately
([D28](artifacts/decision-log.md#d28-the-check-ships-with-no-disable-switch)).

## Alternate flows and states

**The check lands before the problems are fixed.** It fails immediately on nearly every plugin and blocks every release
and pull request from its first day. The check would be correct and the repository would not be ready for it. The
predictable outcome is that someone disables it, at which point it protects nothing and the repository is worse off than
before by one broken thing
([D1](artifacts/decision-log.md#d1-the-check-lands-last-because-a-check-that-blocks-everything-gets-disabled)).

**A release runs while a plugin is missing from a target.** The release stops after writing the targets and before
committing
([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)),
naming every gap it found rather than the first
([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)). Nothing is tagged,
pushed, or published. Recovery is discarding local changes.

**A release fails partway through writing the four targets.** Every write happens before anything irreversible, so the
repository is left with local modifications and nothing published. Recovery is discarding local changes and re-running.
No compensation or rollback machinery is specified because none is needed
([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)).

**A work-items run meets a file annotated by a different tracker.** The run stops before creating anything and names the
work items whose annotations it does not recognize, so a person decides whether the file was already published elsewhere
([D3](artifacts/decision-log.md#d3-a-foreign-annotation-stops-the-run-before-anything-is-created)).

**A work-items run meets a file this same tracker already annotated.** Unchanged from today: those items are recognized
as already published, skipped, and reported in the skipped count. A partial run resumes cleanly.

**A new plugin is added after this work.** The check fails on the pull request that adds it until the contributor lists
it in every target it belongs in. This is the intended behavior, and it is only defensible because step 3 corrected the
contributor guide to name all four targets rather than one
([D21](artifacts/decision-log.md#d21-the-release-procedure-documents-are-owned-by-the-step-that-falsifies-them)).

**A release is cut from a branch where a step has not landed.** What stops it is the release's own gate, not a
pull-request check that may never have run — the release process permits cutting from a non-default branch, and a branch
with no pull request gets no pipeline run
([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)).

## Edge cases and failure modes

| Case                                                                           | Behavior                                                                                                                                     |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| The bundle is absent from channel two                                          | Not flagged, and the version-agreement rule does not apply to it ([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel)) |
| A plugin is missing from any target it belongs in, including just one of two channels | Check fails, naming the plugin and every target it is missing from. This is the shape of the defect that motivated the work ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)) |
| A plugin is in a storefront listing but not in the repository                  | Check fails. A listing entry resolving to nothing breaks the install-succeeds promise directly ([D29](artifacts/decision-log.md#d29-a-listing-entry-with-no-plugin-behind-it-fails-the-check)) |
| A plugin's version records disagree                                            | Check fails, naming the plugin and every disagreeing record ([D20](artifacts/decision-log.md#d20-version-agreement-covers-every-record-that-publishes-a-version)) |
| A plugin has a manifest and no skills                                          | Valid. The bundle is permanently in this state, so "has skills" is not part of what makes a directory a plugin ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)) |
| A work item's heading is malformed in any way the publisher does not recognize | Surfaced, never silently passed over. "Accounted for" means every heading is either published, skipped-and-counted, or surfaced ([D30](artifacts/decision-log.md#d30-accounted-for-is-defined-so-the-promise-is-not-circular)) |
| A work-items file mixes annotated and unannotated items for the same tracker   | Unchanged: annotated items skipped and counted, unannotated items published                                                                   |
| Two trackers' annotations are indistinguishable from each other                | Out of scope here; the trap remains and is specified separately ([D2](artifacts/decision-log.md#d2-step-2-closes-the-silent-hole-only-annotation-namespacing-is-separate)) |
| Channel two adds bundle support later                                          | The named exception becomes removable. See [Deferred (YAGNI)](#deferred-yagni)                                                                |

## Coordinations

- **The release process and the repository.** The release reads the set of plugins from the repository rather than from
  a target it also writes, so a stale listing can no longer hide a plugin from it
  ([D5](artifacts/decision-log.md#d5-the-check-derives-the-plugin-list-from-the-repository)).
- **The release process and both storefronts.** The release writes all four targets before it does anything
  irreversible
  ([D24](artifacts/decision-log.md#d24-the-gate-runs-after-all-targets-are-written-and-before-anything-irreversible)).
- **The check and the release process.** One rule, one bearer. The release runs the check and reports its answer rather
  than restating the rule in its own words, so the two cannot drift
  ([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)).
- **The check and the pull-request pipeline.** The check blocks on every pull request. Local hooks are optional in this
  repository, so the local half is a convenience for contributors who opted in, not a guarantee the feature rests on
  ([D4](artifacts/decision-log.md#d4-the-check-blocks-on-every-pull-request-and-runs-locally-where-hooks-are-installed)).
- **The three work-items publishers and the shared work-items file.** All three read and annotate the same file. Step 2
  changes only how one of them responds to annotations it does not recognize; it does not change what any of them
  writes.
- **Step 5 and step 6.** They ship together
  ([D18](artifacts/decision-log.md#d18-the-execution-order-is-a-partial-order-and-the-repair-precedes-the-correction)).
  The intermediate state — declarations deleted, documents still narrating them — is exactly what step 6 exists to
  prevent.

## User interactions

The people who experience this feature are maintainers and contributors at a terminal, plus installers on channel two.

- **Check failure.** Names the plugin and every target it is missing from. This is the same commitment as the release
  stop below rather than a second one: the check and the release share one bearer
  ([D14](artifacts/decision-log.md#d14-the-release-runs-the-check-rather-than-restating-it)), so the message a
  contributor sees on a pull request is the message a maintainer sees on a release
  ([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)). Naming the target is
  possible because "belongs in" is defined rather than left to the exception
  ([D19](artifacts/decision-log.md#d19-a-plugin-and-the-targets-it-belongs-in-are-defined-positively)).
- **Release stop.** Names every gap it found before stopping, not just the first one, so a maintainer learns the full set
  in one run ([D12](artifacts/decision-log.md#d12-a-missing-plugin-stops-the-release-and-every-gap-is-named)).
- **Work-items format error.** Names the specific work items whose annotations were not recognized and what they appear
  to be annotated by, so the person can tell "already published to another tracker" from "file is malformed". This
  requires "malformed" to be a detectable category rather than a residue
  ([D30](artifacts/decision-log.md#d30-accounted-for-is-defined-so-the-promise-is-not-circular)).
- **Channel-two installer.** Experiences no interface. They get a working install command and, thereafter, update
  prompts. The absence of an error is the whole user-facing outcome.

## Out of scope

- **Namespacing every tracker's annotations so none can be mistaken for another's.** A real trap with real evidence, but
  the strictly simpler step 2 satisfies the evidence that drove it here
  ([D2](artifacts/decision-log.md#d2-step-2-closes-the-silent-hole-only-annotation-namespacing-is-separate)). It carries
  a format change and a migration for files already in people's repositories, which is a specification of its own.
- **Connecting the planning plugin to the shared writing standard.** Considered, reasoned about, recorded as out of
  scope, challenged in review, and confirmed. Reopening it is a fresh decision made on purpose, not a gap to patch.
- **Declaring the relationship between the planning plugin and the three ticket publishers as a dependency.** Declaring
  a dependency forces an install rather than annotating a relationship, so this would compel every GitHub user to
  install the whole planning plugin to document a connection no code follows. The relationship belongs in the
  documentation.
- **Consolidating the duplicated rule files.** The case for it is stronger than earlier analysis suggested, since a rule
  has already been edited by hand in three places. It is not one of the seven steps and is not blocked by any of them.
- **Changing what channel one publishes.** Channel one is healthy. This work brings channel two up to it.
- **Documents already stale for reasons this work does not touch.** Several enumerations elsewhere in the repository are
  out of date but are not falsified by this work, and no evidence suggests anyone has been misled by them. Fixing them
  because the editor is already open is the symmetry reasoning this spec's own rules reject
  ([D7](artifacts/decision-log.md#d7-a-document-is-in-scope-when-this-work-falsifies-it)).
- **Agreement between a plugin's own name as recorded on each channel.** Plausible by analogy to the version drift, but
  no instance exists and nothing depends on it today.

## Deferred (YAGNI)

- **A check that every declared dependency is actually used by the declaring plugin.** This would have caught step 5's
  two untrue declarations automatically, which makes it tempting. It fails the evidence test: nobody has asked for it,
  no incident is attributed to it, and the two known instances are being deleted by hand. Building a general mechanism
  from two instances is machinery ahead of need. **Reopening trigger:** a third decorative dependency is found, or a
  decorative dependency causes a real install or breakage problem.
- **Designing for channel two gaining bundle support.** The exception is named and permanent today
  ([D6](artifacts/decision-log.md#d6-the-bundle-is-a-permanently-named-exception-on-the-second-channel)). Building a
  configurable exception mechanism for one known exception is speculative. **Reopening trigger:** channel two ships
  bundle support, or a second permanent exception appears.
- **A disable switch for the check.** Deferred deliberately, not overlooked. A disable mechanism is the "land it
  disabled" alternative already rejected, and reversibility already exists: the check lands in one commit, so reverting
  that commit is the escape hatch. **Reopening trigger:** the check produces its first false positive on a pull request
  that is actually correct ([D28](artifacts/decision-log.md#d28-the-check-ships-with-no-disable-switch)).
- **Monitoring channel two's published state from outside the repository.** No dashboard, no version polling, no alert on
  release deviation. The check on every pull request is the signal, and the drift persisted for twenty releases
  precisely because nothing asked the question at all — not because nobody was watching a graph.
  **Reopening trigger:** drift recurs despite the check, meaning the check is asking the wrong question.

## Open items

1. **Whether channel two gates update availability on the published version number is unconfirmed**, and the Outcome's
   update-prompt claim rests on it. This is the one open item with a named cost and a named consequence: verifying costs
   one installed client and one release, and if it is wrong then step 4 is still worth doing but its user-facing claim
   must come out of the Outcome. **Owner: the maintainer, before the Outcome is quoted to anyone.** See
   [T1](artifacts/feature-technical-notes.md#t1-update-availability-on-channel-two-is-decided-by-the-published-version-number).
2. **Which revision each channel's client resolves from** — the default branch or the latest release tag — is unknown
   from inside this repository. If it is the tag, then steps 1 and 4 reach users at the next release rather than on
   merge, and both steps' outcomes should be worded accordingly. This is the same class of unknown as item 1: external
   client behavior not visible from here.
3. **Whether the pull-request pipeline's lint job is a required status check** determines how much of the guarantee the
   check actually carries. If it is not required, a pull request can merge red and the check is advisory on the one
   surface that does not depend on a contributor's local setup.
4. **Version compatibility between plugins is an open question this specification does not close.** Plugins are
   installed and updated one at a time, so someone can run a months-old coding plugin against a core plugin updated
   today, and nothing would notice. Earlier analysis argued this could not happen because everything ships from a single
   snapshot; that argument holds only for a fresh install of everything at once, which is not how the suite is used over
   time. The right fix is not obvious. Flagged as a decision the team still owes itself, not as work this specification
   schedules.

## Summary

- **Outcome.** Han publishes completely and honestly to both channels, and a check keeps it that way.
- **Actors.** Han maintainers, contributors, and channel-two installers.
- **Scope.** Seven steps. The check is last; the release repair precedes the version correction; the declaration
  deletion and document correction are one unit; the work-items fix is independent.
- **Decisions.** 30 full and trivial combined. See [decision-log.md](artifacts/decision-log.md).
- **Technical notes.** 1. See [feature-technical-notes.md](artifacts/feature-technical-notes.md).
- **Sub-agents.** 4: junior-developer, devops-engineer, edge-case-explorer, information-architect. See
  [team-findings.md](artifacts/team-findings.md).
- **Key adjustments from review.** The execution order was changed to close a window that would have undone step 4; the
  gate was given a placement; the check and release were given one bearer instead of two; the document survey was
  restated as a rule and grew by five locations; and a factual error about the number of version records was corrected.
- **Deferred under YAGNI.** 4.
- **Open items.** 4, of which two are unverified external behaviors and one is a real decision the team owes itself.

# Change Plan: Codex Marketplace Catalog Consistency

## Why This Change

A defect whose root cause is structural. A Codex user who follows the Han README runs
`codex plugin add han-documentation@han` and gets back `Error: plugin han-documentation was not found in marketplace
han`. The same happens for `han-research`, and `han-linear` cannot be installed at all. Four hand-maintained lists have
to agree about which packages Codex can install, and nothing checks that they do
([C-1](artifacts/current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets),
[C-10](artifacts/current-state-findings.md#c-10-nothing-in-the-test-lint-or-ci-chain-reads-any-manifest-or-marketplace-file)).

Source: GitHub issue [testdouble/han#198](https://github.com/testdouble/han/issues/198), recorded in
[`artifacts/scope-boundary.md`](artifacts/scope-boundary.md).

## What Changes, In One Paragraph

After this change the `han-*` directory tree is the authority on which packages Codex can install, and one test enforces
that the catalog and the manifests agree with it ([D-1](artifacts/change-decision-log.md#d-1-the-directory-tree-is-the-authority)).
Today no file holds that authority. Three packages sit in a state no file objects to: two are advertised and
manifest-complete but unlisted, and one is advertised with neither a manifest nor a listing. Afterwards every `han-*`
directory except the `han` meta-plugin carries both a Codex manifest and a catalog entry. A commit that adds a
plugin directory without both fails CI on the pull request.

## Current State

Four lists enumerate the packages Codex can install, and none is derived from another
([C-1](artifacts/current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets)):
thirteen directories, twelve manifests, ten catalog entries, and a README section naming all thirteen. The gaps are
exactly the three the issue reports.

An install reads the catalog first and the per-plugin manifest second
([C-2](artifacts/current-state-findings.md#c-2-a-codex-install-reads-the-catalog-first-and-the-per-plugin-manifest-second)),
which is why the three failures are not the same failure. `han-documentation` and `han-research` have complete,
well-formed manifests that the install never reaches, because the lookup fails at the catalog step
([C-3](artifacts/current-state-findings.md#c-3-han-documentation-and-han-research-fail-at-the-catalog-step-with-correct-manifests-never-reached)).
`han-linear` fails one layer deeper: its `.codex-plugin/` directory has never existed on any commit
([C-4](artifacts/current-state-findings.md#c-4-han-linear-fails-one-layer-earlier-because-no-codex-manifest-exists-at-all)).

**The structural property this change addresses** is the absence of any authority among the four lists, and the absence
of any check that they agree. Nothing in the test, lint, or CI chain reads a manifest or a marketplace file
([C-10](artifacts/current-state-findings.md#c-10-nothing-in-the-test-lint-or-ci-chain-reads-any-manifest-or-marketplace-file)).
The evidence that this is structural rather than a one-off slip is in the history. Commit `2c09799` scaffolded both
plugins and updated one marketplace file, its own message saying "registered in the marketplace", singular
([C-15](artifacts/current-state-findings.md#c-15-the-drift-entered-on-a-commit-that-updated-the-claude-marketplace-and-not-the-codex-catalog)).
The comparison case is `556b49e`, which added `han-ddd` and updated both marketplace files plus the repository map,
which is why `han-ddd` installs.

Two properties of the current state constrain what the fix can assert. Version parity between a plugin's Claude and
Codex manifests is false for eleven of twelve pairs
([C-8](artifacts/current-state-findings.md#c-8-the-version-field-differs-between-the-two-manifests-for-eleven-of-twelve-plugins)),
and description parity is false for all twelve
([C-9](artifacts/current-state-findings.md#c-9-the-same-plugins-description-is-authored-independently-in-three-places-and-has-drifted-in-all-twelve)).
Both have a mechanical cause: the release skill bumps `{source}/.claude-plugin/plugin.json` and the Claude marketplace,
and contains no reference to Codex at all. The two version fields are independent lineages rather than drift.

## Target State

The `han-*` directory tree is the authority. Every other file in the Codex surface either points at it or is checked
against it.

**`.agents/plugins/marketplace.json`** answers one question: which names `codex plugin add` resolves, and the on-disk
path each resolves to. It is answerable for nothing else. It holds no version and no description, because its schema has
no field for either ([C-5](artifacts/current-state-findings.md#c-5-every-catalog-entry-carries-the-same-four-keys-with-the-same-constant-values)).

Every entry takes this form, with `name` and `path` supplied per plugin and the rest constant across all thirteen
([D-2](artifacts/change-decision-log.md#d-2-new-catalog-entries-take-the-existing-form-and-the-existing-order-position)):

```json
    {
      "name": "han-linear",
      "source": {
        "source": "local",
        "path": "./han-linear"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Developer Tools"
    },
```

Copy that shape exactly, including the line breaks. Prettier preserves whichever form an author writes rather than
imposing one, so a compacted entry stays compacted and no lint step corrects it back. Every one of the ten existing
entries is expanded like the above.

Entry order stays the Claude marketplace's order with its omissions removed
([C-17](artifacts/current-state-findings.md#c-17-the-codex-catalogs-entry-order-is-the-claude-marketplaces-order-with-its-omissions-removed)).
That fixes where each new entry goes: `han-documentation` and `han-research` after `han-core` and before
`han-planning`, and `han-linear` between `han-atlassian` and `han-ddd`.

**`han-*/.codex-plugin/plugin.json`** answers one question: that package's Codex-published identity. It is not
answerable for dependencies, because no field in the Codex schema holds one
([C-7](artifacts/current-state-findings.md#c-7-the-codex-manifest-schema-shares-almost-nothing-with-the-claude-manifest-schema-and-encodes-no-dependencies)),
and it is not answerable for agreement with its Claude sibling.

Nine of the eighteen fields are byte-identical across all twelve existing manifests and are copied verbatim into a new
one. They are `author`, `homepage`, `repository`, `license`, `skills`, and the four `interface` keys `developerName`,
`category`, `capabilities`, and `websiteURL`. The package supplies `name`, `version`, `description`, `keywords`, and the
four `interface` text keys ([D-3](artifacts/change-decision-log.md#d-3-the-han-linear-codex-manifests-field-layout)).

**`test/codex-packaging.bats`** answers one question: whether the tree, the catalog, and the manifests name the same
package set. It is not answerable for field values, schema shape, or parity with anything on the Claude side.

**`.claude-plugin/marketplace.json` and `han-*/.claude-plugin/plugin.json`** are answerable for the Claude surface
alone, and this change does not touch them. They are not the upstream of the Codex manifests, and treating them as one
is what makes independent version lineages look like drift.

**`README.md`'s Codex section** already names all thirteen packages correctly and needs no edit
([C-1](artifacts/current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets)).

### The check's failure output

What a contributor sees when the check fails is a contract between the check and the person reading CI, so it is pinned
to literal lines ([D-7](artifacts/change-decision-log.md#d-7-the-checks-failure-output-names-the-package-and-the-repair)).
Each failing test prints one line per offending package before returning 1:

```
codex manifest missing: han-linear/.codex-plugin/plugin.json (copy han-ddd/.codex-plugin/plugin.json and edit the package-specific fields)
catalog entry missing: add "name": "han-linear" with "path": "./han-linear" to .agents/plugins/marketplace.json
```

## Surface Delta

### S-1: `han-documentation` entry in `.agents/plugins/marketplace.json` — Added

**Target state.** The catalog contains an entry named `han-documentation` whose `source.path` is `./han-documentation`,
carrying the same `policy` and `category` as every other entry. It sits after `han-core` and before `han-planning`.
`codex plugin add han-documentation@han` resolves it and reads the manifest that already exists at
`han-documentation/.codex-plugin/plugin.json`.

**Behavior.** Changing. A Codex user who runs `codex plugin add han-documentation@han` gets an error today and an
installed package afterwards. Settled by the recorded boundary, which asks for this in item 1 word for word, rather than
by escalation ([D-1](artifacts/change-decision-log.md#d-1-the-directory-tree-is-the-authority)).

**Why.** The manifest is complete and well-formed; the install fails at the catalog step before reaching it
([C-3](artifacts/current-state-findings.md#c-3-han-documentation-and-han-research-fail-at-the-catalog-step-with-correct-manifests-never-reached)).

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-new-catalog-entries-take-the-existing-form-and-the-existing-order-position)

### S-2: `han-research` entry in `.agents/plugins/marketplace.json` — Added

**Target state.** The catalog contains an entry named `han-research` whose `source.path` is `./han-research`, in the
same form as every other entry, sitting after `han-documentation` and before `han-planning`.
`codex plugin add han-research@han` resolves it and reads the existing manifest.

**Behavior.** Changing. Same observer and same change as S-1: a Codex user's install goes from an error to a working
package. Settled by the recorded boundary's item 1.

**Why.** Same cause as S-1. Both plugins were scaffolded by the same commit, which registered them in the Claude
marketplace only ([C-15](artifacts/current-state-findings.md#c-15-the-drift-entered-on-a-commit-that-updated-the-claude-marketplace-and-not-the-codex-catalog)).

**Depends on.** S-1, for entry order only.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-new-catalog-entries-take-the-existing-form-and-the-existing-order-position)

### S-3: `han-linear/.codex-plugin/plugin.json` — Added

**Target state.** `han-linear` carries a Codex manifest with the same ten top-level keys and eight `interface` keys as
every other manifest ([C-6](artifacts/current-state-findings.md#c-6-all-twelve-codex-manifests-carry-an-identical-key-set)).
Its version is `1.0.0`. Its nine constant fields are copied verbatim from any sibling; its eight package-specific fields
describe the `work-items-to-linear` skill:

```json
{
  "name": "han-linear",
  "version": "1.0.0",
  "description": "Linear-facing extensions to the Han suite: publish Han work items to Linear through the Linear MCP server, one issue per slice.",
  "author": { "name": "Test Double", "url": "https://testdouble.com" },
  "homepage": "https://github.com/testdouble/han#readme",
  "repository": "https://github.com/testdouble/han",
  "license": "MIT",
  "keywords": ["han", "linear", "work-items", "issues"],
  "skills": "./skills/",
  "interface": {
    "displayName": "Han Linear",
    "shortDescription": "Publish Han work items to Linear as issues.",
    "longDescription": "Creates one Linear issue per slice from a /plan-work-items work-items file in a single target team, resolving the team's real workflow states, labels, Projects, and members before it creates anything, and linking within-file dependencies as native \"blocked by\" relations. Requires a configured Linear MCP server.",
    "developerName": "Test Double",
    "category": "Developer Tools",
    "capabilities": ["Skills"],
    "websiteURL": "https://github.com/testdouble/han",
    "defaultPrompt": [
      "Publish these work items to Linear.",
      "Create Linear issues from my work-items file.",
      "Push this plan's slices into my Linear team."
    ]
  }
}
```

**Behavior.** Changing. A Codex user gains a package that has never been installable. Settled by the recorded
boundary's item 2 word for word.

**Why.** The directory has never held a `.codex-plugin/` on any commit, so a catalog entry alone would still fail one
layer deeper ([C-4](artifacts/current-state-findings.md#c-4-han-linear-fails-one-layer-earlier-because-no-codex-manifest-exists-at-all)).

**Decision.** [D-3](artifacts/change-decision-log.md#d-3-the-han-linear-codex-manifests-field-layout), [D-4](artifacts/change-decision-log.md#d-4-the-new-codex-manifest-ships-at-100)

### S-4: `han-linear` entry in `.agents/plugins/marketplace.json` — Added

**Target state.** The catalog contains an entry named `han-linear` whose `source.path` is `./han-linear`, in the same
form as every other entry, sitting between `han-atlassian` and `han-ddd`. `codex plugin add han-linear@han` resolves it
and reads the manifest S-3 adds.

**Behavior.** Changing. Together with S-3 this takes `han-linear` from uninstallable to installable for a Codex user.
Settled by the recorded boundary's item 3 word for word.

**Why.** The catalog is the first of the two files an install reads
([C-2](artifacts/current-state-findings.md#c-2-a-codex-install-reads-the-catalog-first-and-the-per-plugin-manifest-second)),
so the manifest S-3 adds is unreachable without it.

**Depends on.** S-3. A catalog entry pointing at a directory with no manifest is a state the check in S-5 rejects, so
the two land together.

**Decision.** [D-2](artifacts/change-decision-log.md#d-2-new-catalog-entries-take-the-existing-form-and-the-existing-order-position)

### S-5: `test/codex-packaging.bats` — Added

**Target state.** A Bats file at `test/codex-packaging.bats` asserts three things, using bash and grep only, with no
`jq` and no `node`. It is discovered by `npm test` with no registration step
([C-12](artifacts/current-state-findings.md#c-12-npm-test-discovers-every-bats-file-in-the-tree-with-no-registration-step))
and runs in CI on every pull request. Its header comment states why the invariant exists, names the commit that broke
it, and records the Prettier formatting dependency the literal greps rest on.

The enumeration is what the check and the directory tree must independently agree on, so it is pinned rather than
described. The `han-*/` glob excludes the `han` meta-plugin structurally: `han/` does not match it, so no exception list
is needed.

```bash
REPO_ROOT="${BATS_TEST_DIRNAME}/.."
CATALOG='.agents/plugins/marketplace.json'

# Every Codex package, one per line.
codex_packages() {
  cd "$REPO_ROOT" || return 1
  for dir in han-*/; do printf '%s\n' "${dir%/}"; done
}
```

The three assertions:

1. **The enumeration is not empty.** Without this the other two run over an empty set and pass while checking nothing.
   This is a required assertion, not an optional hardening, and it mirrors the `at least one skill carries the probe`
   test in `scripts/han-config-dir.bats`
   ([C-11](artifacts/current-state-findings.md#c-11-scriptshan-config-dirbats-is-the-repos-one-worked-example-of-a-cross-file-consistency-check)).
2. **Every package has a manifest.** `<package>/.codex-plugin/plugin.json` is a regular file.
3. **Every package has a catalog entry naming it and pointing at it.** The `name` and `path` literals are matched
   together within one entry rather than anywhere in the file, which the fixed entry shape makes a three-line window:

   ```bash
   grep -A3 -- "\"name\": \"${pkg}\"" "$CATALOG" | grep -q -- "\"path\": \"./${pkg}\""
   ```

The check runs on macOS locally and on `ubuntu-latest` in CI, and three differences between those decide how it is
written. The divergence runs the opposite way from the usual: the authoring machine has the older bash. So a feature
that works while writing the check may be the one that is unavailable.

- **Bash 3.2 compatible.** No `mapfile` or `readarray`, no `declare -A`, no `${x^^}` case conversion, no globstar.
  These all work on the CI runner's bash 5 and fail on macOS bash 3.2, so CI will not catch their use.
- **Grep one named file, never `-r`.** BSD grep follows symlinks during a recursive search and GNU grep does not, and
  this repository has thirteen root-escaping symlinks, one per plugin at `han-*/scripts/han-config-dir.sh`. The check
  greps exactly `.agents/plugins/marketplace.json`. Use `-qF` only: BSD grep has no `-P`. Note that `han-config-dir.bats`
  uses `grep -rlF`, so it is the wrong half of that file to copy.
- **Loop and assert, never sort and diff.** macOS and the runner default to different locales, so glob expansion order
  is not guaranteed to match. Per-package assertions in a loop do not care; a `diff` of two sorted lists would.
- **Emit failures from the test body.** Bats surfaces a test's stdout only when the test fails, and output produced
  inside a function called under `run` is captured into `$output` instead of printed. `printf '%s\n'` followed by
  `return 1` directly in the test body is what puts the pinned failure lines from D-7 into a CI log. It is the shape
  the three cross-file tests in `scripts/han-config-dir.bats` already use.
- **Mode 755 with the `#!/usr/bin/env bats` shebang.** prek's `check-shebang-scripts-are-executable` hook covers
  `test/`, and both existing `.bats` files are 755. A new file created at the default 644 fails `npm run lint` before
  `npm test` ever runs.

**Behavior.** Changing. A contributor who adds a `han-*` directory without both files sees `npm test` fail where it
passed before. Settled by the recorded boundary's item 4 word for word, and by the operator's answer that the directory
tree decides which packages the check covers.

**Why.** Nothing currently reads any manifest or marketplace file
([C-10](artifacts/current-state-findings.md#c-10-nothing-in-the-test-lint-or-ci-chain-reads-any-manifest-or-marketplace-file)),
so the four data fixes above would not stop the next plugin repeating `2c09799`.

**Depends on.** S-1, S-2, S-3, S-4. The check fails until all four land.

**Decision.** [D-5](artifacts/change-decision-log.md#d-5-the-check-is-one-bats-file-in-test-using-bash-and-grep-only), [D-6](artifacts/change-decision-log.md#d-6-the-check-asserts-three-things-and-not-six-others), [D-7](artifacts/change-decision-log.md#d-7-the-checks-failure-output-names-the-package-and-the-repair)

### S-6: `CLAUDE.md`'s record of which plugins carry a Codex manifest — Re-scoped

**Target state.** `CLAUDE.md` line 83 no longer names `han-linear` as an exception, because after S-3 there is no
exception. The line sits inside a column-aligned ASCII tree, so the replacement is pinned to preserve that alignment:

```text
│   │   └── plugin.json    # Codex-format manifest; every han-* plugin carries one (han/ is excluded: no meta-plugins)
```

**Behavior.** Changing. An agent or contributor reading the repository map is told something different: that a Codex
manifest is required rather than optional. No install, command, or test outcome differs, and no automated reader is
affected, which was checked rather than assumed: no `.bats` file in the repository globs or greps `CLAUDE.md`'s content.
Settled by [D-8](artifacts/change-decision-log.md#d-8-claudemd-line-83-is-inside-the-recorded-area) rather than by
escalation.

**Why.** The line goes false the moment S-3 lands
([C-16](artifacts/current-state-findings.md#c-16-claudemd-records-the-han-linear-manifest-gap-as-though-it-were-the-intended-design)).
It is the file every agent reads at the start of every session. Leaving it asserting that a file you created
does not exist teaches the next contributor that shipping without a Codex manifest is a legitimate choice. Precedent:
`556b49e` added `han-ddd` and updated both marketplace files and `CLAUDE.md` in one commit
([D-8](artifacts/change-decision-log.md#d-8-claudemd-line-83-is-inside-the-recorded-area)).

**Depends on.** S-3.

**Decision.** [D-8](artifacts/change-decision-log.md#d-8-claudemd-line-83-is-inside-the-recorded-area)

### S-7: `test/`'s stated remit, in `test/sanity.bats`'s header — Re-scoped

**Target state.** The header comment states a two-category remit for `test/`, and says what still does not belong
there. The replacement, pinned:

```text
# Sanity check: proves the Bats harness and the CI test job actually run.
# Real script tests sit next to the script they cover (e.g.
# scripts/foo.sh alongside scripts/foo.bats); test/ keeps harness-level
# checks like this one, plus repository-wide structural invariants that
# cover no single script.
```

The clause that survives unchanged is the one that still decides most cases: a test covering one script sits beside that
script. Only a check whose subject is the repository itself belongs in `test/`.

**Behavior.** Changing. A contributor deciding where to put a new test is told something different, because a class of
test that previously had no stated home now has one. No test outcome differs. Settled by
[D-9](artifacts/change-decision-log.md#d-9-the-sanitybats-header-is-amended-rather-than-the-check-relocated) rather
than by escalation.

**Why.** The existing comment states a convention S-5 breaks: "test/ keeps only harness-level checks like this one."
This repository has one ADR and no coding-standards directory, so a header comment is where a convention
lives. Widening it deliberately, and saying what the widening does not cover, is the difference between amending a
standard and quietly contradicting it.

**Depends on.** S-5.

**Decision.** [D-9](artifacts/change-decision-log.md#d-9-the-sanitybats-header-is-amended-rather-than-the-check-relocated)

## Behavior Changes

**A Codex user gains three packages they could not install.** Running `codex plugin add han-documentation@han` today
prints `Error: plugin han-documentation was not found in marketplace han`. Afterwards it installs the package. The same
holds for `han-research`, and for `han-linear`, which has never been installable at all (S-1 through S-4, and items 1
through 3 of the issue).

One caveat travels with that. Codex resolves no dependencies of its own, so someone who installs `han-documentation`
alone gets a package whose skills call into `han-communication`, which they may not have installed. The README already
handles this by telling people to install `han-communication` first, and this change does not alter that ordering. What
Codex does at the moment a skill names an uninstalled package could not be checked, because no Codex CLI was available
to this run
([C-7](artifacts/current-state-findings.md#c-7-the-codex-manifest-schema-shares-almost-nothing-with-the-claude-manifest-schema-and-encodes-no-dependencies)).

**A contributor gains a test that can fail on work unrelated to Codex.** Anyone who adds a new `han-*` directory sees
`npm test` fail until that directory has both a Codex manifest and a catalog entry. This is the intended effect and it
is item 4 of the issue. The failure fires on the next person to add a plugin, not on
anyone touching Codex. The failure message names the package and the repair, so the fix is mechanical (S-5).

**Two written statements start saying something different.** The repository map currently tells a reader that
`han-linear` is one of two plugins that legitimately ships without a Codex manifest; afterwards it tells them every
plugin carries one. And the note at the top of the test directory currently says only harness-level checks belong
there; afterwards it says repository-wide structural checks belong there too. Nothing an automated tool observes
changes in either case. The observer is a person or an agent reading the repository to decide what to do next, which is
the whole reason both edits are here (S-6, S-7).

Every one of these was asked for by the recorded boundary or follows directly from something that was, so none needed a
decision from you during planning. They are listed here so you can object to any of them now.

## Change Units

### Unit 1: Register the two plugins that already have manifests

**What it does.** Adds two entries to the Codex catalog so the two packages that are advertised and manifest-complete
become installable.

**Delta entries.** S-1, S-2.

**Ordering constraint.** None. This unit stands alone and fixes two of the three reported symptoms.

**How you know it worked.** The catalog names `han-documentation` and `han-research`, each with a `path` that resolves
to a directory holding a `.codex-plugin/plugin.json`. `npm run lint` passes, which is what confirms the JSON is still
well-formed and Prettier-clean. To confirm the user-visible fix directly, run
`codex plugin marketplace add` against the checkout and then `codex plugin add han-documentation@han`. No Codex CLI was
available to this planning run, so that check is unperformed rather than passing.

### Unit 2: Give `han-linear` a Codex manifest and register it

**What it does.** Creates the Codex manifest `han-linear` has never had, adds its catalog entry, and corrects the
repository map that recorded its absence as intentional.

**Delta entries.** S-3, S-4, S-6.

**Ordering constraint.** S-5 requires both artifacts for every `han-*` directory, so `han-linear` fails the check until
the manifest and the entry both exist. They land in one unit for that reason. The write order within the unit is author
convenience rather than correctness: the check iterates directories, not catalog entries, so it flags `han-linear`
today whether or not an entry exists. Catching an entry that points at a manifest-less directory is the deferred
reverse check's job.

**How you know it worked.** `han-linear/.codex-plugin/plugin.json` parses and carries the same ten top-level keys as its
twelve siblings. The catalog names `han-linear` with `path` `./han-linear`. `CLAUDE.md` no longer names `han-linear` as
a plugin without a Codex manifest. `npm run lint` passes.

### Unit 3: Add the consistency check

**What it does.** Adds the test that keeps the tree, the catalog, and the manifests in agreement, and updates the one
comment that says tests of this kind do not belong in `test/`.

**Delta entries.** S-5, S-7.

**Ordering constraint.** Lands after Units 1 and 2 are on `main`, not merely after them in branch order. A Unit 3 pull
request opened before they merge runs red on its own CI, and that red is indistinguishable to a reviewer from a broken
check. Open it after both have merged, or hold it in draft. Merging Units 1 and 2 together as one pull request and
Unit 3 as a second removes the ambiguity, at the cost of the unit boundaries.

**How you know it worked.** `npm run lint` passes, which is the step that catches a new `.bats` file left at mode 644,
and `npm test` passes with the new file discovered automatically.

Then prove the check catches the defect rather than passing vacuously. `git stash` cannot do this: once Units
1 and 2 are committed it has nothing to stash. While they are uncommitted, the new `han-linear` manifest is an
untracked file a plain stash leaves in place. Use a worktree on the commit before Unit 1 instead, which operates on
committed history:

```bash
git worktree add /tmp/codex-check-verify <sha-before-unit-1>
cp test/codex-packaging.bats /tmp/codex-check-verify/test/
cd /tmp/codex-check-verify && npm ci && npm test    # expect failure naming all three packages
cd - && git worktree remove --force /tmp/codex-check-verify
```

The run must fail and name `han-documentation`, `han-research`, and `han-linear`. A consistency check nobody has seen
fail is a check nobody knows works.

## Risks

**The check can pass vacuously**, which is why S-5 requires the non-empty assertion rather than suggesting it. If the
enumeration matches nothing, the other two assertions run over an empty set and the test is green while checking
nothing. This is the failure mode most likely to survive review, because it looks identical to success.

The exposure is narrower than it first appears and worth knowing precisely. Bash leaves an unmatched glob as its own
literal text unless `nullglob` is set, and nothing in this repository sets it. So a naive loop today would iterate once
over the literal string and fail loudly with a nonsense filename. That is an accident, not a safeguard: the idiomatic
fix for that ugly output is to set `nullglob`, which converts the loud failure into the silent pass. The non-empty
assertion is what makes the check safe under either choice.

**The two literal greps depend on Prettier's byte formatting.** Asserting the literal `"name": "han-linear"` assumes one
space after the colon. That holds because `.pre-commit-config.yaml` gives Prettier ownership of JSON and runs it first,
but the coupling is invisible at the grep site. State it in the file's header comment so a future reader who reformats
the catalog knows what breaks.

**Unit 3 makes Units 1 and 2 no longer independently revertible.** Before it lands, reverting either data unit affects
only Codex users. After it lands, reverting either turns `npm test` red for every open pull request, because the check
then fails on a package that no longer has what it asserts. If a revert is needed, revert Unit 3 first or fix forward.
Unit 3 is itself the cheapest of the three to undo: delete one file and restore one comment.

**Unit 3 goes red for anyone with a plugin-adding branch already open.** Such a branch fails on its next push with no
context beyond the check's error line, which is the strongest argument for pinning that line in D-7. Worth a look at
open branches before merging Unit 3.

**A release can still be cut from a red `main`.** The release skill gates on a clean working tree and reads no CI
status, so the check protects the pull request rather than the release.

**The next release will bump `han-linear` for a change no Claude user can observe.** The release skill classifies a
child as changed when anything under its directory changed, and adding the Codex manifest does that. Its three
level buckets have no entry for "gained Codex installability", so the release run will make that call unaided. Decide it
deliberately at release time and record the choice; this plan bumps nothing.

**Nothing here was verified against a running Codex.** No Codex CLI was available. The catalog-then-manifest lookup
order, the attribution of the reported error to the catalog step, and the effect of installing a plugin without its
dependency are traced from the repository's files and the error text quoted in the issue
([C-2](artifacts/current-state-findings.md#c-2-a-codex-install-reads-the-catalog-first-and-the-per-plugin-manifest-second),
[C-7](artifacts/current-state-findings.md#c-7-the-codex-manifest-schema-shares-almost-nothing-with-the-claude-manifest-schema-and-encodes-no-dependencies)).
The fix follows the shape of the ten entries that demonstrably work, which is the strongest available evidence short of
running the tool.

**The new Codex manifest will not be bumped by the release process.** The release skill contains no reference to Codex
and bumps only `{source}/.claude-plugin/plugin.json` and the Claude marketplace, so `han-linear`'s Codex version stays
at `1.0.0` until someone edits it by hand. This is already true of all twelve existing manifests
([C-8](artifacts/current-state-findings.md#c-8-the-version-field-differs-between-the-two-manifests-for-eleven-of-twelve-plugins))
and this change neither creates nor worsens it.

## Deferred (YAGNI)

**A reverse check that every catalog entry names an existing directory.** It would catch a plugin being renamed or
deleted with its catalog entry left behind. Deferred because that failure has never occurred here: the catalog names no
package that has no directory today
([C-1](artifacts/current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets)),
and the failure that did occur ran the other direction. **Reopen when** a plugin is renamed or removed, which is a
deliberate act someone performs and can notice. The trigger is deliberately not "an orphan entry reaches `main`",
because the only thing that would detect that is the reverse check itself. If it is reopened, assert the stronger form:
that every entry resolves to a directory holding a Codex manifest, rather than merely to a directory. That is what an
install needs ([D-10](artifacts/change-decision-log.md#d-10-the-reverse-check-is-deferred)).

**Checking the README's Codex section against the directory tree.** This is the fourth of the four lists in
[C-1](artifacts/current-state-findings.md#c-1-four-hand-maintained-lists-name-overlapping-but-non-identical-package-sets),
and the check covers the other three. After this change someone can add a plugin, satisfy the check, and leave the
README's install instructions without it. That is the same shape of drift as the one being fixed, and it lands on the
surface the issue's closing line points at. Deferred because the operator settled the check's subject as the directory
tree. It is also deferred because the five opt-in packages sit in a prose sentence with no marker a grep could anchor
on. Enforcing it means first inventing a machine-readable form for that prose. **Reopen when** a package is reported
installable but undocumented, or when the README's Codex section gains a list a check could read.

**Checking that catalog entries sit in the right order.** The order carries real meaning, the suite's dependency order
([C-17](artifacts/current-state-findings.md#c-17-the-codex-catalogs-entry-order-is-the-claude-marketplaces-order-with-its-omissions-removed)),
and S-1, S-2, and S-4 each commit to a position, but the check is order-agnostic. Deferred because Codex resolves an
entry by name, so a misplaced entry has no install-time consequence. **Reopen when** entry order is found to affect
resolution or display.

**Generating the catalog from the directory tree.** Structurally the strongest answer, and rejected on cost. It needs a
generator, a check that the generated file is current, and a JSON writer. The repository's entire tooling is
Prettier, ShellCheck, and Bats, with `jq` pinned nowhere
([C-13](artifacts/current-state-findings.md#c-13-node-is-guaranteed-to-the-test-job-jq-is-not-pinned-anywhere)). The
catalog has changed five times in its whole history. **Reopen when** a catalog entry gains a field that varies per
plugin; all three non-identity fields are constants today
([C-5](artifacts/current-state-findings.md#c-5-every-catalog-entry-carries-the-same-four-keys-with-the-same-constant-values)).

**A prek hook running the same check at commit time.** Duplicates a signal CI already gives on every pull request.
**Reopen when** catalog drift reaches `main` despite the Bats check.

**Asserting the manifest key set.** True today across all twelve manifests
([C-6](artifacts/current-state-findings.md#c-6-all-twelve-codex-manifests-carry-an-identical-key-set)), and rejected
because it needs field-level JSON reading with no `jq`, and no reported failure was caused by a missing field.
**Reopen when** an install fails on a malformed manifest rather than an absent one.

**A `CONTRIBUTING.md` section on adding a plugin.** The file has no such section at all
([C-14](artifacts/current-state-findings.md#c-14-contributingmd-has-no-section-for-adding-a-plugin-and-never-names-the-codex-surface)),
so writing one is authoring a new process rather than repairing this defect. The check enforces mechanically what its
Codex paragraph would have said in prose. **Reopen when** a contributor asks how to add a plugin, or when the check
fires on a human branch and its error line proves insufficient.

**An ADR recording why `han/` is excluded from the Codex catalog.** The issue reporter had to infer this. After the
change the exclusion is structural in the check's `han-*` glob and stated in both its header comment and `CLAUDE.md`.
**Reopen when** someone proposes adding `han` to the catalog.

## Cut for Scope

**Rewording `CLAUDE.md` line 73, which calls the catalog "the Codex-compatible subset of the plugins".** It would stop a
future reader concluding that some plugins are legitimately outside the Codex surface. Cut because the line does not
become false: after the change the catalog still excludes `han`, so it remains a subset. Rewording it is prevention
work, and the recorded boundary already chose a mechanism for prevention in item 4, a test rather than prose
([`artifacts/scope-boundary.md`](artifacts/scope-boundary.md), Stated Scope). Note that
[C-16](artifacts/current-state-findings.md#c-16-claudemd-records-the-han-linear-manifest-gap-as-though-it-were-the-intended-design)
treats lines 73 and 83 together; splitting them is this plan's judgment, on the test of whether this change makes the
line false. You can reinstate this, and saying so is
itself a valid justification the reinstated entry records
([D-11](artifacts/change-decision-log.md#d-11-claudemd-line-73-is-cut-for-scope)).

**Reconciling the three independently-authored descriptions of each plugin.** Every plugin's description exists in its
Claude manifest, its Claude marketplace entry, and its Codex manifest, and all twelve differ
([C-9](artifacts/current-state-findings.md#c-9-the-same-plugins-description-is-authored-independently-in-three-places-and-has-drifted-in-all-twelve)).
Cut because the issue asks about installability, not description accuracy, and the three texts serve three surfaces at
three deliberate lengths. Worth saying plainly rather than implying neutrality: S-3 adds a thirteenth instance of the
pattern, authoring three new independently-written texts for `han-linear`.

## Open Items

**Whether a Codex install succeeds after this change.** Non-blocking. Every claim about what Codex does at
install time is traced from this repository's files and the error text in the issue. No Codex CLI was available
to this run. What would settle it: run `codex plugin marketplace add` against the branch and then `codex plugin add` for
each of the three packages. The builder inherits this as a verification step, not as a design question.

**Whether the `ubuntu-latest` runner preinstalls `jq`.** Non-blocking, and the plan is arranged so the answer does not
matter: the check uses bash and grep only. Named here because it is the reason for that constraint rather than an open
design choice.

**`docs/choosing-a-han-plugin.md` still misleads a Codex user, and this change does not fix it.** Non-blocking, and
outside the recorded boundary, which names the README's Codex section rather than `docs/`. The README routes readers to
that file as the plugin index. It never mentions Codex, and its install commands are Claude-only, including
`/plugin install han@han` for a meta-plugin Codex cannot install. This is the residual half of what the issue calls "the
affected installation instructions". What would settle it: a follow-up issue. Do not widen this change to cover it.

**Whether Codex packages a plugin's `scripts/` directory and preserves a root-escaping symlink.** Non-blocking and
inherited rather than introduced. Every plugin's `scripts/han-config-dir.sh` is a symlink out of the plugin root, and
the Codex manifest declares only `skills/`. All thirteen plugins share this, so `han-linear` gaining a manifest extends
an existing condition rather than creating one. What would settle it: installing any Han package under Codex and
running a skill that probes the personal config directory.

## Review Findings

Three specialists reviewed the plan in one round: `han-core:test-engineer` on the check's verification design,
`han-core:devops-engineer` on the build and distribution boundary, and `han-core:junior-developer` as a generalist
stress-test. The round cap for a medium change is two rounds; one was enough, because no finding named a domain the
round did not cover.

`han-core:system-architect` was not dispatched. This change crosses no service boundary, changes no context-map
relationship, and shifts no data ownership, so it stayed inside `han-core:software-architect`'s altitude. That
architect deferred nothing to it.

Every finding that changed the plan is recorded below. Each produced an edit rather than a decision of its own, so
there is no new `D-N` entry for them; the decisions they altered are D-6, D-8, and D-9.

**Raised independently by all three reviewers, and the round's most valuable finding.** The check's own top risk had no
assertion closing it. The plan named vacuous pass as "the failure mode most likely to survive review" and then left the
mitigation as a suggestion in Risks rather than a requirement in S-5. Two reviewers went further and named the specific
shapes that produce it. Piping into `while read` runs the loop body in a subshell, where a failure cannot fail the
test. Setting `nullglob` turns an unmatched glob from a loud failure into zero iterations. Neither hazard
exists in the repository today, which is what makes a builder likely to introduce one. The non-empty assertion is now a
required part of S-5.

**Raised by `han-core:test-engineer` and `han-core:junior-developer`.** The Unit 3 verification step named `git stash`,
which cannot reproduce the pre-fix state. Once Units 1 and 2 are committed there is nothing to stash. While they
are uncommitted, a plain stash leaves the untracked new manifest in place and removes the test file besides. Replaced
with a `git worktree` on the commit before Unit 1, which operates on committed history.

**Raised by `han-core:test-engineer` and `han-core:devops-engineer`.** The plan's own worked catalog entry was
compacted while all ten committed entries are expanded, and Prettier preserves whichever shape an author writes rather
than normalizing it. A contributor copying the plan's snippet would have introduced a permanent second shape that no
lint step corrects. The snippet now matches the file.

**Raised by `han-core:test-engineer`.** The two catalog greps tested for the name and the path appearing anywhere in
the file rather than within one entry. Now scoped to a three-line window, which the fixed entry shape makes exact.

**Raised by `han-core:devops-engineer`.** Four cross-platform constraints the plan had not stated, each verified. The
bash version divergence runs the opposite way from the usual, because the authoring machine has the older shell.
`grep -r` is unsafe here because BSD and GNU grep differ on symlinks, and this repository has thirteen root-escaping
ones. Locale differences make sorted comparison unreliable. And Bats prints a test's output only on failure and only
from the test body, which is what puts D-7's pinned lines into a CI log. It also caught that a new `.bats` file left
at mode 644 fails `npm run lint` before `npm test` ever runs. Both existing files are 755, and prek's shebang hooks
cover `test/`. All five are now in S-5.

**Raised by `han-core:devops-engineer`.** The Risks section had the revert asymmetry backwards. It claimed Units 1 and
2 were the revertible ones; in fact Unit 3 is the cheapest to undo, and once it lands, reverting either data unit turns
`npm test` red repository-wide. It also found that Unit 2's ordering rationale cited a property the plan deliberately
does not build: the deferred reverse check. A Unit 3 pull request opened before Units 1 and 2 merge also runs red
on its own CI, in a way a reviewer cannot distinguish from a broken check. All corrected.

**Raised by `han-core:junior-developer`.** S-6 and S-7 were labeled behavior-preserving while their own justification
paragraphs argued the opposite: both exist precisely because a reader acts differently afterwards. Both are now
classified Changing with the observer named. The same reviewer found that the target text for those two entries was
described rather than pinned, unlike every other entry in the delta. S-6's line also sits inside a column-aligned
ASCII tree, where two builders would produce two different lines. Both replacement lines are now pinned literally.

**Raised by `han-core:junior-developer`.** The deferred reverse check carried a reopening trigger nothing could
observe: an orphan entry reaching `main` would be detected only by the reverse check itself. Retriggered on a plugin
rename or removal, which is a deliberate act someone performs. The same reviewer found the Behavior Changes section
opened on planning bookkeeping in vocabulary appearing in neither the issue nor a user's world; it was rewritten.

**Raised by `han-core:junior-developer` and confirmed by `han-core:devops-engineer`.** The README is the fourth of the
four lists and the check covers three, so a contributor can add a plugin, satisfy the check, and leave the install
instructions without it. Now a deferral with a stated trigger rather than an unmentioned gap. The devops reviewer
extended this to `docs/choosing-a-han-plugin.md`, which the README routes Codex readers to and which never mentions
Codex. That sits outside the recorded boundary and is recorded as an open item and a follow-up.

**Findings kept but not acted on.** `han-core:software-architect` recommended a third assertion checking that every
catalog entry names an existing directory. Not adopted, on the evidence test, and recorded as dissent in
[D-10](artifacts/change-decision-log.md#d-10-the-reverse-check-is-deferred). `han-core:test-engineer` noted that entry
order is committed to in the delta and unchecked by the test, and argued itself that testing it would be
YAGNI-incorrect since Codex resolves by name. It is recorded as a deferral. `han-core:devops-engineer` raised that this
change adds a thirteenth instance of the three-way description drift, which is noted in the cut list rather than fixed.
The same reviewer raised that Codex may not package a plugin's symlinked `scripts/` directory, which is inherited by
all thirteen plugins and recorded as an open item.

**Findings labeled `Unverified`, none carrying blocking severity.** Every claim about what Codex does at install time
rests on files and the error text in the issue rather than on a running Codex. No Codex CLI was available to any
agent in this run. The same applies to the `ubuntu-latest` runner's preinstalled tools and to what `claude plugin tag`
reads. The plan is arranged so none of these decides anything: the fix copies the shape of ten entries that
demonstrably work, and the check depends only on tools this repository pins.

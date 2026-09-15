# Current State Findings: Codex Marketplace Catalog Consistency

## Provenance

Produced by this run's own discovery round on 2026-09-10. No prior findings report existed.

Agents dispatched in parallel, both given the Codex packaging surface as their area:

- `han-core:structural-analyst` — static structure: the four package lists, the two manifest schemas, where duplication
  lives, the enforcement surface, and structural gaps.
- `han-core:behavioral-analyst` — install-time and test-time behavior: what a Codex install reads in what order, the
  failure a user sees, dependency semantics under Codex, and the `npm test` / `npm run lint` execution paths.

`han-core:concurrency-analyst` was not dispatched. The area is packaging metadata and a test harness, with no concurrent
access, async coordination, or shared mutable state.

The run's own Glob, Grep, and `git log` sweep supplied the project context, the churn history, and findings C-16 through
C-18. Findings C-1, C-5, C-6, and C-8 were additionally re-derived by the run directly rather than accepted from an
agent, because each one pins a concrete value the plan commits to.

## Project Context

- **Stack:** Markdown (skill, agent, and doc content) and Bash (skill `scripts/`, plus the shared repo-root `scripts/`).
  No application build and no dev server.
- **Conventions source:** `CLAUDE.md`, `## Project Discovery` section. No `project-discovery.md` file exists.
- **Package manager:** npm. The root `package.json` manages dev tooling only.
- **Test runner:** Bats, via `npm test`. Lint is prek via `npm run lint`.
- **ADRs found:** `docs/adr/0001-project-configurable-default-swarm-size.md` — the only ADR in the repo, and unrelated
  to packaging.
- **Coding standards found:** None governing JSON manifests or the marketplace catalog. `CONTRIBUTING.md` carries the
  process for adding a skill and adding an agent (see C-14).
- **Recent churn:** `git log --since="90 days ago"` over `.agents/`, `.claude-plugin/`, and `*/.codex-plugin/` shows the
  Codex catalog file changed five times in its whole history and twice in the last ninety days. See C-16.

## Gaps

What was searched for and not found:

- **No ADR on Codex packaging.** `docs/adr/` holds one file, on an unrelated subject. Nothing records why the `han`
  meta-plugin is excluded from the Codex catalog; the issue reporter had to infer it.
- **No JSON Schema file.** A repo-wide search for `*schema*` returns nothing.
- **No plugin-builder guidance for the Codex surface.** `han-plugin-builder/skills/guidance/references/` is the
  designated home for plugin-authoring rules per `CLAUDE.md`, and its three `codex` mentions all concern plugin naming,
  not the packaging surface, the manifest schema, or catalog maintenance.
- **No `Adding a plugin` section in `CONTRIBUTING.md`.** See C-14.
- **No test, hook, or CI step reading any manifest or marketplace file.** See C-10.

Taken together: there is no authored statement anywhere in the repo of what a package advertised for Codex must carry.

## Findings

### C-1: Four hand-maintained lists name overlapping but non-identical package sets

- **Claim:** Four independent lists enumerate the packages Codex can install, none derived from another, and their set
  differences reproduce all three symptoms issue #198 reports.
- **Location:** the `han-*` directory tree; `han-*/.codex-plugin/plugin.json`; `.agents/plugins/marketplace.json`;
  `README.md` lines 69 through 94.
- **Evidence:** Re-derived by the run directly, reading all four sources in one pass:

  ```text
  directories (13, excluding the meta-plugin han/):
    han-atlassian han-coding han-communication han-core han-ddd han-documentation
    han-feedback han-github han-linear han-planning han-plugin-builder han-reporting han-research

  codex manifests (12): every directory above except han-linear

  catalog entries (10): han-communication han-core han-planning han-coding han-github
    han-reporting han-feedback han-atlassian han-ddd han-plugin-builder

  README Codex section (13): 8 in the codex plugin add block, 5 more in the prose sentence

  MISSING from catalog (directory tree, excluding han): han-documentation, han-linear, han-research
  MISSING manifest    (directory tree, excluding han): han-linear
  catalog entries with no directory:                   (none)
  ```

- **Raised by:** `han-core:structural-analyst` C1; `han-core:behavioral-analyst` C1; re-derived by the run.
- **Confidence:** Verified.
- **Bears on:** S-1, S-2, S-3, S-4, S-5; D-1, D-2, D-5.

### C-2: A Codex install reads the catalog first and the per-plugin manifest second

- **Claim:** `codex plugin add <name>@han` resolves `<name>` against the catalog's `plugins` array to obtain a
  `source.path`, then reads `.codex-plugin/plugin.json` inside that directory. Both files must agree for an install to
  succeed.
- **Location:** `.agents/plugins/marketplace.json`; `han-*/.codex-plugin/plugin.json`.
- **Evidence:** Each of the ten catalog entries carries a `source.path` that resolves to a directory holding a
  `.codex-plugin/plugin.json`. The containment `catalog ⊆ manifests` holds with no exceptions, so the catalog names
  nothing that would fail to resolve at the second step.
- **Raised by:** `han-core:behavioral-analyst` C1.
- **Confidence:** Unverified. No Codex CLI was available in this environment, so the two-step lookup order is traced
  from the repo's file shapes and the error text quoted in issue #198, not observed against a running `codex` binary.
  What could not be inspected: Codex's own install-command implementation.
- **Bears on:** S-1, S-2, S-3; D-1.

### C-3: `han-documentation` and `han-research` fail at the catalog step, with correct manifests never reached

- **Claim:** Both plugins carry a complete, well-formed Codex manifest. The install fails before Codex reads it, because
  neither name appears in the catalog array.
- **Location:** `.agents/plugins/marketplace.json`; `han-documentation/.codex-plugin/plugin.json`;
  `han-research/.codex-plugin/plugin.json`; `README.md` lines 84 and 85.
- **Evidence:** The catalog array runs `han-core` straight into `han-planning`, with no entry between them.
  `han-research/.codex-plugin/plugin.json` is complete:

  ```json
  {
    "name": "han-research",
    "version": "1.0.0",
    "description": "Pre-planning knowledge-work skills: open-ended research, gap analysis, and issue triage.",
    "skills": "./skills/"
  }
  ```

  The reported error, `Error: plugin han-documentation was not found in marketplace han`, names the marketplace rather
  than the plugin directory.

- **Raised by:** `han-core:behavioral-analyst` C2.
- **Confidence:** Verified as to the file contents. The attribution of the error string to the catalog step inherits
  C-2's Unverified label.
- **Bears on:** S-1, S-2; D-1.

### C-4: `han-linear` fails one layer earlier, because no Codex manifest exists at all

- **Claim:** `han-linear/` has no `.codex-plugin/` directory. Adding a catalog entry alone would not make it
  installable.
- **Location:** `han-linear/`; `han-linear/.claude-plugin/plugin.json`.
- **Evidence:** The directory holds `.claude-plugin/`, `docs/`, `README.md`, `references/`, `scripts/`, and `skills/`,
  and no `.codex-plugin/`. `git log --diff-filter=A -- han-linear/.codex-plugin/plugin.json` returns nothing: the file
  has never existed on any commit. Its Claude manifest exists and declares no dependencies:

  ```json
  { "name": "han-linear", "description": "Linear-facing extensions to the Han suite. ...", "version": "1.1.1" }
  ```

- **Raised by:** `han-core:behavioral-analyst` C3; `han-core:structural-analyst` C1.
- **Confidence:** Verified.
- **Bears on:** S-3, S-4; D-3, D-4.

### C-5: Every catalog entry carries the same four keys with the same constant values

- **Claim:** All ten entries are byte-identical in shape, and two of the three non-identity fields never vary across the
  suite. A new entry has exactly one form to take.
- **Location:** `.agents/plugins/marketplace.json`, `plugins[]`.
- **Evidence:** Re-derived by the run. Every entry has keys `name`, `source`, `policy`, `category`; every `source` has
  keys `source` and `path`; every `policy` is `{"installation": "AVAILABLE", "authentication": "ON_INSTALL"}`; every
  `category` is `"Developer Tools"`. The entry form:

  ```json
  {
    "name": "han-core",
    "source": { "source": "local", "path": "./han-core" },
    "policy": { "installation": "AVAILABLE", "authentication": "ON_INSTALL" },
    "category": "Developer Tools"
  }
  ```

- **Raised by:** `han-core:structural-analyst` C5; re-derived by the run.
- **Confidence:** Verified.
- **Bears on:** S-1, S-2, S-4; D-2.

### C-6: All twelve Codex manifests carry an identical key set

- **Claim:** Every existing `.codex-plugin/plugin.json` has the same ten top-level keys and the same eight `interface`
  keys, with no plugin adding or omitting one.
- **Location:** `han-*/.codex-plugin/plugin.json`, all twelve.
- **Evidence:** Re-derived by the run across all twelve files:

  ```text
  top-level: name version description author homepage repository license keywords skills interface
  interface: displayName shortDescription longDescription developerName category capabilities
             websiteURL defaultPrompt
  ```

  No file deviates.

- **Raised by:** the run's own sweep; corroborates `han-core:structural-analyst` C2.
- **Confidence:** Verified.
- **Bears on:** S-3; D-3.

### C-7: The Codex manifest schema shares almost nothing with the Claude manifest schema, and encodes no dependencies

- **Claim:** The Claude manifest is flat with four fields; the Codex manifest is nested with roughly fifteen. Neither the
  Codex manifest schema nor the Codex catalog schema has any field that encodes a dependency between plugins.
- **Location:** `han-documentation/.claude-plugin/plugin.json` against
  `han-documentation/.codex-plugin/plugin.json`; the pattern holds across all twelve pairs.
- **Evidence:** The Claude schema is `{name, description, version, dependencies?}`. A grep for `dependencies` across all
  twelve Codex manifests returns zero hits, against nine hits across the Claude manifests. `README.md` line 77 states
  the consequence: Codex "resolves no dependencies". The dependency is load-bearing at runtime, not merely declarative:
  `han-documentation/skills/project-documentation/SKILL.md` invokes `han-communication:readability-guidance` by
  cross-plugin name and dispatches the `han-communication:readability-editor` agent.
- **Raised by:** `han-core:structural-analyst` C2; `han-core:behavioral-analyst` C4.
- **Confidence:** Verified as to the field absence and the SKILL.md invocation. What Codex does at the moment a skill
  body names an uninstalled plugin's skill could not be inspected, because no Codex CLI was available and no Codex
  documentation is vendored in this repo.
- **Bears on:** S-3, S-5; D-3, D-6.

### C-8: The `version` field differs between the two manifests for eleven of twelve plugins

- **Claim:** Version parity between a plugin's Claude manifest and its Codex manifest is not an invariant this repo
  holds today, and asserting it would fail for eleven of the twelve existing pairs.
- **Location:** `han-*/.claude-plugin/plugin.json` against `han-*/.codex-plugin/plugin.json`.
- **Evidence:** Re-derived by the run:

  ```text
  plugin              claude   codex
  han-atlassian       2.3.1    1.1.0
  han-coding          3.3.0    1.0.0
  han-communication   1.2.0    1.0.0
  han-core            3.1.1    1.2.0
  han-ddd             1.0.0    1.0.0
  han-documentation   1.0.1    1.0.0
  han-feedback        2.0.2    1.1.1
  han-github          2.3.1    1.2.0
  han-linear          1.1.1    (no manifest)
  han-planning        2.2.1    1.0.0
  han-plugin-builder  2.2.0    1.1.0
  han-reporting       2.2.1    1.0.1
  han-research        1.0.1    1.0.0
  ```

  `han-ddd` is the only matching pair, and it is the most recently added plugin.

- **Raised by:** `han-core:structural-analyst` C3; re-derived by the run.
- **Confidence:** Verified.
- **Bears on:** S-3, S-5; D-4, D-6.

### C-9: The same plugin's description is authored independently in three places and has drifted in all twelve

- **Claim:** A plugin's description exists in its Claude manifest, in the Claude marketplace entry, and in its Codex
  manifest, with nothing keeping the three in step. All twelve pairs that have both manifests differ.
- **Location:** `han-*/.claude-plugin/plugin.json`; `.claude-plugin/marketplace.json`;
  `han-*/.codex-plugin/plugin.json`.
- **Evidence:** For `han-documentation`, the Codex manifest reads:

  ```text
  "Documentation skills for writing down what the team built and decided: project docs, ADRs, and runbooks."
  ```

  while its Claude manifest carries a substantially longer text naming each skill and the plugin's dependencies, and the
  Claude marketplace entry carries a third, intermediate text.

- **Raised by:** `han-core:structural-analyst` C4.
- **Confidence:** Verified.
- **Bears on:** S-5; D-3, D-6.

### C-10: Nothing in the test, lint, or CI chain reads any manifest or marketplace file

- **Claim:** No committed automation validates any JSON manifest's content or any agreement between the packaging files.
- **Location:** `test/sanity.bats`; `scripts/han-config-dir.bats`; `.pre-commit-config.yaml`;
  `.github/workflows/ci.yml`; `package.json`.
- **Evidence:** `.github/workflows/ci.yml` runs exactly two commands across its two jobs: `npm run lint` and
  `npm test`, each after `npm ci`. `.pre-commit-config.yaml` runs Prettier (formatting only), ShellCheck, and generic
  hygiene hooks; its comment states `check-yaml and check-json are intentionally omitted: Prettier parses and so
validates those types already`, which is a syntax check and not a content check. A grep for `marketplace.json`,
  `codex`, or `.codex-plugin` across every `*.bats`, `*.sh`, and `*.yml` file outside `node_modules` returns no hit in
  `test/`, `scripts/`, or the workflow.
- **Raised by:** `han-core:structural-analyst` C6; `han-core:behavioral-analyst` C8.
- **Confidence:** Verified.
- **Bears on:** S-5; D-5, D-6.

### C-11: `scripts/han-config-dir.bats` is the repo's one worked example of a cross-file consistency check

- **Claim:** A test asserting that several files agree already exists in this repo, and it establishes the pattern a new
  one would follow: bash and grep only, no `jq` and no `node`, a repo root computed from the test file's own location,
  and a header comment stating why the invariant matters.
- **Location:** `scripts/han-config-dir.bats`; `scripts/han-config-dir.sh`.
- **Evidence:** The file computes its root and enumerates matching files, then asserts an invariant over each:

  ```bash
  REPO_ROOT="${BATS_TEST_DIRNAME}/.."
  SCRIPT_REL='scripts/han-config-dir.sh'

  probe_skills() {
    cd "$REPO_ROOT" || return 1
    grep -rlF -- "${SCRIPT_REL}\" 2>/dev/null" ./*/skills/*/SKILL.md
  }

  @test "at least one skill carries the probe" {
    run probe_skills
    [ "$status" -eq 0 ]
    [ -n "$output" ]
  }
  ```

  Its seven tests use only `grep`, `[ -f ]`, `[ -x ]`, `run`, and parameter expansion. `test/sanity.bats` states the
  sibling convention: "Real script tests sit next to the script they cover... `test/` keeps only harness-level checks."

- **Raised by:** `han-core:structural-analyst` C7; `han-core:behavioral-analyst` C7.
- **Confidence:** Verified.
- **Bears on:** S-5; D-5, D-9.

### C-12: `npm test` discovers every `*.bats` file in the tree with no registration step

- **Claim:** A new Bats file placed anywhere outside `node_modules` runs automatically.
- **Location:** `package.json`.
- **Evidence:**

  ```json
  "test": "find . -name node_modules -prune -o -name '*.bats' -print0 | xargs -0 bats"
  ```

  Nine `.bats` files exist outside `node_modules` today.

- **Raised by:** `han-core:behavioral-analyst` C5.
- **Confidence:** Verified.
- **Bears on:** S-5; D-5.

### C-13: `node` is guaranteed to the test job; `jq` is not pinned anywhere

- **Claim:** A test may rely on `node` and on Bats being present in CI, because the workflow installs both. It may not
  rely on `jq`, which no committed file pins.
- **Location:** `.github/workflows/ci.yml`; `package.json`.
- **Evidence:** The test job runs `actions/setup-node@v7.0.0` with `node-version: lts/*`, then `npm ci`, then
  `npm test`. `package.json` `devDependencies` holds exactly `@j178/prek`, `bats`, and `prettier`; a grep for `jq` in
  `package.json` returns zero hits. On the development machine the behavioral analyst verified by direct execution:
  `bash 3.2.57` (macOS, pre-4.0, so no associative arrays and no `mapfile`), `jq 1.8.2`, `node v22.14.0`,
  `git 2.55.0`, `bats 1.13.0`.
- **Raised by:** `han-core:behavioral-analyst` C6; `han-core:structural-analyst` C7; the workflow re-read by the run.
- **Confidence:** Verified as to the workflow and `package.json`. Whether the `ubuntu-latest` runner happens to
  preinstall `jq` could not be inspected from this filesystem, which is the reason it counts as unpinned rather than
  absent.
- **Bears on:** S-5; D-5, D-6.

### C-14: `CONTRIBUTING.md` has no section for adding a plugin and never names the Codex surface

- **Claim:** A contributor following the written process has no documented step that touches the Codex catalog or a
  Codex manifest.
- **Location:** `CONTRIBUTING.md`.
- **Evidence:** The file carries "Adding a skill" and "Adding an agent" sections and no "Adding a plugin" section. The
  only marketplace file it names is `.claude-plugin/marketplace.json`, at lines 167 through 168 and 200 through 201. A
  search for `codex` or `.agents/plugins` returns zero matches.
- **Raised by:** `han-core:structural-analyst` C8.
- **Confidence:** Verified.
- **Bears on:** S-5; D-7.

### C-15: The drift entered on a commit that updated the Claude marketplace and not the Codex catalog

- **Claim:** `han-documentation` and `han-research` were registered in one of the two marketplace files at the moment
  they were scaffolded, and the omission has stood since.
- **Location:** commit `2c09799`, 2026-07-22, `feat(plugins): scaffold han-documentation and han-research`.
- **Evidence:** The commit's own message says both plugins are "registered in the marketplace", singular. Its diffstat
  against the two marketplace paths shows one file touched:

  ```text
  .claude-plugin/marketplace.json | 14 +++++++++++++-
  1 file changed, 13 insertions(+), 1 deletion(-)
  ```

  The Codex catalog has five commits in its entire history and none is `2c09799`. The comparison case is `556b49e`
  (`feat(han-ddd)`, 2026-08-19), which updated both files, which is why `han-ddd` installs.

- **Raised by:** the run's own `git log` sweep.
- **Confidence:** Verified.
- **Bears on:** S-5; D-5, D-8.

### C-16: `CLAUDE.md` records the `han-linear` manifest gap as though it were the intended design

- **Claim:** The repository map states that `han-linear` is one of two plugins that deliberately carries no Codex
  manifest, so the map itself has to change when the manifest is added.
- **Location:** `CLAUDE.md` line 83.
- **Evidence:**

  ```text
  │   │   └── plugin.json    # Codex-format manifest; every plugin except han and han-linear carries one
  ```

  `CLAUDE.md` line 73 describes the catalog as covering "the Codex-compatible subset of the plugins", which likewise
  reads as intentional rather than as drift.

- **Raised by:** the run's own sweep.
- **Confidence:** Verified.
- **Bears on:** S-6; D-8, D-11.

### C-17: The Codex catalog's entry order is the Claude marketplace's order with its omissions removed

- **Claim:** The two files order their entries identically once the four names absent from Codex are dropped, which
  fixes where a new entry belongs.
- **Location:** `.agents/plugins/marketplace.json`; `.claude-plugin/marketplace.json`.
- **Evidence:** Re-derived by the run:

  ```text
  claude: han han-communication han-core han-documentation han-research han-planning han-coding
          han-github han-reporting han-feedback han-atlassian han-linear han-ddd han-plugin-builder
  codex:      han-communication han-core                                han-planning han-coding
          han-github han-reporting han-feedback han-atlassian           han-ddd han-plugin-builder
  ```

  Neither file is alphabetical. The order is the suite's dependency order: the foundational plugins first, then the
  bundled layers, then the opt-in plugins.

- **Raised by:** the run's own sweep.
- **Confidence:** Verified.
- **Bears on:** S-1, S-2, S-4; D-2.

### C-18: prek's exclude list keeps this plan folder out of every lint hook

- **Claim:** Files written under `docs/plans/` are formatted by no hook, so the plan itself does not need to satisfy
  Prettier.
- **Location:** `.pre-commit-config.yaml`.
- **Evidence:**

  ```yaml
  exclude: "^(docs/plans/|docs/research/|han-reporting/skills/html-summary/assets/)"
  ```

- **Raised by:** the run's own sweep.
- **Confidence:** Verified.
- **Bears on:** —

## Findings No Agent Could Audit

Two evidence classes nobody in this run could reach:

- **Codex's own install behavior.** No `codex` CLI is available in this environment and no Codex documentation is
  vendored in the repo, so the two-step catalog-then-manifest lookup (C-2), the attribution of the reported error string
  to the catalog step (C-3), and what happens when a skill body names an uninstalled plugin's skill (C-7) are traced
  from file shapes and the issue's quoted error rather than observed. Closing this would take running `codex plugin
marketplace add` and `codex plugin add` against a checkout.
- **The GitHub Actions runner's preinstalled tool set.** `ubuntu-latest` runs outside this filesystem, so whether `jq`
  is present there could not be checked (C-13). Closing this would take a CI run that probes for it, or reading
  GitHub's published runner image manifest.

Every other class in the area was covered: the repository's own files, its git history, its lint and CI configuration,
and the local toolchain versions.

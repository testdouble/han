# Research: Discovering Configuration Contributed by Other Installed Han Plugins

The question: how can each installed Han plugin ship configuration that other Han plugins discover and load
automatically, so that, for example, `test-engineer` can move from `han-core` into `han-coding`, and `han-planning`
skills use it when `han-coding` is installed and run without it when it is not?

Evidence mode: strict.

## Summary

Han can do this, but Claude Code gives it no built-in way to. Claude Code dependencies are all-or-nothing. A plugin that
lists another as a dependency gets it installed automatically and stops loading without it, and there is no "optional"
or "contributes to" setting. So the discovery has to be built from parts Claude Code already has.

The shape of the contract matters more than the transport. Every established plugin system studied puts the contract
with the consumer: the planning plugin names a slot, such as "test-planning specialist", and the coding plugin says "my
`test-engineer` fills that slot." None has the provider list the consumer's individual features. Han should follow that
pattern, so renaming a planning skill never breaks the coding plugin. When nothing fills a slot, the planning skill
simply runs without it, the same way Han already skips an extra agent that is not installed.

For the transport, the best-supported route is a small startup hook in each providing plugin. The hook prints that
plugin's contribution file into the session when the session starts, and only enabled plugins run hooks. As a safety
net, a planning skill checks that the agent actually appears in the session's list of available agents before
dispatching it. This works today with no new machinery, and it keeps the skill safe if the hook does not run. Two other
routes exist: asking the Claude Code command line which plugins are installed, and reading Claude Code's plugin folders
directly. Both are less stable.

How solid it is: the contract shape is well-corroborated; the startup-hook transport rests on one documentation page
and needs a quick live check before you commit to it.

- **Confidence:** Medium
- **Web search:** used

## Research Results

### Claude Code has no optional-dependency or contribution mechanism

A plugin's `dependencies` are hard requirements. They are installed automatically, and the dependent plugin is disabled
when one is missing or out of version range (A1, A2). Claude Code strips any manifest key it does not recognize, and it
documents no `contributes`, `extends`, or optional-dependency field (A1). One search turned up no proposal for one
[single-source] (A11). The free-form `metadata` object is ignored by Claude Code itself (A1), so a custom manifest field
cannot carry the declaration.

This rules out the obvious design of having `han-planning` depend on `han-coding`. That edge would auto-install
`han-coding` and disable `han-planning` without it (A2). Han's own past investigation reached the same conclusion: a
dependency only affects installation, not what a skill can see (A31).

### Prior art puts the contract with the consumer

Every plugin system surveyed has the consuming side, or a neutral host, define the named slot. Providers register
against that slot.

- IntelliJ: the defining plugin declares an extension point, and other plugins contribute into its namespace (A13).
- Eclipse: the declaring plug-in owns the contract (A20).
- Python entry points: the consumer owns the group and its interface (A15).
- pluggy and pytest: the host owns the hook specs, and plugins implement them (A16, A17).
- Java ServiceLoader: the service owner defines the interface (A18).

No surveyed system has a provider list the consumer's internal features [negative result, bounded survey]. The nearest
cases, VS Code `contributes` and IntelliJ optional `<depends>`, name a host-defined slot or id, not the consumer's
private parts (A14, A19). In your example, `han-coding`'s file saying "`test-engineer` is usable by `plan-a-feature`
and `plan-implementation`" is the push shape that prior art avoids. Saying "`test-engineer` fills `han-planning`'s
test-planning role" is the pull shape it supports.

### The consumer always owns what happens when nothing is installed

The systems agree that absence is the consumer's problem to handle. ServiceLoader returns an empty result and the caller
supplies a default (A18). npm says handling a missing optional dependency "is still your program's responsibility"
(A21). IntelliJ isolates optional code so the core never touches it [single-source] (A14).

Han already has this rule for user-configured extra agents. An entry that does not resolve to a dispatchable agent is
skipped with a one-line note, and a bad config never fails a run (A23). A contributed agent can reuse those semantics
unchanged.

### The known failure mode is a silent no-op

Pluggy accepts an implementation whose hook name matches nothing, unless the host runs an explicit check (A16). For Han,
the same thing happens if `han-coding` names a role `han-planning` renamed or never had: the contribution is silently
ignored. Han has no test today that checks an agent reference resolves or that a role name exists (A33), so nothing
would catch it.

### Four ways a skill could learn what another plugin contributes

No environment variable or substitution exposes another plugin's install location. `${CLAUDE_PLUGIN_ROOT}` and
`${CLAUDE_PLUGIN_DATA}` point only at the plugin itself (A1). Han uses nothing beyond `${CLAUDE_PLUGIN_ROOT}` today, and
has no code that finds sibling plugins (A24). Han's earlier research also found that a plugin cannot hand configuration to
a project through a CLAUDE.md at its root or through `userConfig` [single-source] (A30). What remains:

- **Startup hook.** A plugin's SessionStart hook can print text into the session's context before the first prompt. It
  re-fires on resume, clear, and compaction, and only enabled plugins run hooks [single-source] (A5). Hook processes
  receive the plugin's own `${CLAUDE_PLUGIN_ROOT}`, so the hook can read its own contribution file (A1). This is the
  only documented channel where a provider pushes content another plugin's skill can see. Han ships no hooks today.
- **Command-line listing.** `claude plugin list --json` reports every installation with its id, enabled state, scope,
  version, and install path (A4). Calling it from a skill's load-time shell probe is unverified for speed and safety. A
  failing probe aborts the whole skill unless guarded (A6), and in-place plugins may report no install path (A3, A4).
- **Reading Claude Code's plugin folders.** `installed_plugins.json` and the versioned cache folder are documented, but
  as a loading reference, not a published schema (A3). The cache path changes on every update, a setting can move the
  root (A3, A10), and the file does not reflect which plugins are enabled for this project (A3).
- **The session's own agent list.** Plugin agents register as `plugin:agent`, and the model sees every available
  agent's description (A7). This session's own Agent tool listing shows agents from six different plugins with their
  descriptions (A34). Han already uses prose-level "check it is installed, else fall back" logic for skills (A32).
  What the Agent tool does when handed an unknown agent name is undocumented. Two user reports disagree on whether the
  error lists the valid names [single-source each] (A8, A9).

### Codex has no equivalent

Codex plugins have no documented dependency field or plugin-to-plugin reference (A12). Han ships Codex manifests for
every plugin, so any design that leans on a Claude Code hook has no confirmed Codex counterpart.

### The move itself reverses a recorded decision

Han's current rule keeps an agent in `han-core` unless a single skill family in one plugin dispatches it exclusively
(A29). `test-engineer` is dispatched from four `han-planning` skills (A25) and two `han-coding` skills (A26). A recorded
decision rejected splitting the roster between `han-planning` and `han-coding`, because their dispatch sets overlap
heavily (A28). Moving `test-engineer` with this mechanism means amending both. It also means `han-planning` deliberately
loses `test-engineer` when `han-coding` is absent, which is the behavior you described. Both plugins depend today only
on `han-communication` and `han-core` (A27), so nothing new is needed on the dependency side.

## Options to Consider

### O1: Provider startup hook prints a role-shaped contribution file

- **What it is:** `han-coding` ships a contribution file in the same markdown shape as `.han/config.md`, saying which
  of its agents fill which named consumer roles, plus a SessionStart hook that prints that file. `han-planning`'s roster
  tables name roles. A skill uses any agent a contribution in context names for its role, and skips the role when none
  does. It matches what you asked for: the configuration lives in the providing plugin and is found automatically.
- **Trade-offs:** It uses only documented parts (A1, A5) and only enabled plugins contribute (A5). A small amount of
  context is spent every session, and the model reads it rather than a parser. It does nothing where hooks are
  disabled, and has no confirmed Codex path (A12). It adds the first hook to Han.
- **Rests on:** (A1), (A5), (A13), (A15), (A16), (A23)
- **Evidence status:** single-source (caveated) for the hook injection (A5); corroborated for the role contract.

### O2: Skill probe calls the command-line plugin listing

- **What it is:** Each consuming skill's load-time probe runs `claude plugin list --json`, finds enabled Han plugins,
  and reads each one's contribution file from its install path.
- **Trade-offs:** It is machine-parsed and reports enabled state (A4). It also nests a CLI call inside every skill load
  with unverified latency and safety, and a failure aborts the skill unless guarded (A6). In-place plugins may lack an
  install path (A4). It needs a new `allowed-tools` grant on every consuming skill (A6, A24).
- **Rests on:** (A3), (A4), (A6)
- **Evidence status:** corroborated for the output format; single-source (caveated) that it is safe to run from a probe.

### O3: Skill probe reads Claude Code's plugin folders directly

- **What it is:** A shared script, symlinked like the config-dir resolver (A24), reads `installed_plugins.json` or
  globs sibling folders in the plugin cache for contribution files.
- **Trade-offs:** It is fast and needs no CLI. But it reads files that are not a published schema, it misses the
  project-level enabled state, and the path moves with versions and settings (A3, A10). It is the most fragile option.
- **Rests on:** (A3), (A10), (A24)
- **Evidence status:** single-source (caveated)

### O4: Consumer roster names the optional agent and checks the session list

- **What it is:** `han-planning`'s roster names `han-coding:test-engineer` directly as optional: dispatch it if it
  appears in the session's available agents, skip the role if it does not. No contribution file and no transport.
- **Trade-offs:** It needs no new machinery and works anywhere agents register (A7, A34). It reuses Han's existing skip
  semantics (A23). But the mapping lives in `han-planning`, not `han-coding`, which is the opposite of what you asked
  for, and the consumer must know the provider's agent name. It covers agents only.
- **Rests on:** (A7), (A23), (A32), (A34)
- **Evidence status:** corroborated (A7 with A34 on agent visibility); unknown-agent behavior is unresolved (A8, A9).

### O5: Keep the shared roster in `han-core`

- **What it is:** The status quo. Every agent either plugin dispatches stays in `han-core`.
- **Trade-offs:** It is proven and needs no new mechanism (A28, A29). It leaves `han-core` carrying agents only one
  plugin family really needs, which is the problem you want to solve.
- **Rests on:** (A28), (A29)
- **Evidence status:** corroborated (codebase)

## Recommendation

- **Recommendation:** Adopt a role-shaped (pull) contract, delivered by O1's startup hook, with O4's session-list check
  as the guard in every consuming skill. `han-planning` names the roles in its rosters. `han-coding` ships the file
  saying `test-engineer` fills the test-planning role. A planning skill dispatches a contributed agent only when it also
  appears among the session's available agents, and otherwise skips the role with Han's existing one-line note. Add a
  test that every role a contribution names exists in some consumer roster, to catch the silent no-op. Before
  committing, run one live check: install `han-coding` with a SessionStart hook in a local marketplace, confirm a
  `han-planning` skill sees the printed text, and confirm it survives a compaction. If that check fails, fall back to O4
  alone and accept that the mapping lives in `han-planning`.
- **Evidence basis:**
  - Corroborated: the consumer owns the contract and the degradation (A13, A15, A16, A18, A20, A21); Claude Code has no
    optional or contributes field, and dependencies are hard (A1, A2); plugin agents are visible to the model by name
    (A7, A34); Han already skips unresolved extra agents (A23).
  - Single-source: a SessionStart hook's output reaches skills in other plugins and survives compaction (A5). This is
    why the live check comes first, and why the O4 guard keeps the design safe if A5 is wrong.
  - Single-source: what the Agent tool does with an unknown agent name (A8, A9). The guard avoids relying on it.
  - Codebase: the move amends the agent-placement rule (A29) and decision D1 (A28).

## Validation

<!-- filled after adversarial validation -->

## Sources

| ID  | Source | Link / location | Retrieved | Trust class | Summary (one line) | Evidence status |
| --- | ------ | --------------- | --------- | ----------- | ------------------ | --------------- |
| A1 | Claude Code plugin manifest reference | https://code.claude.com/docs/en/plugins-reference | 2026-10-15 | web | Only per-plugin path variables exist; `dependencies` are required; unknown manifest keys are stripped; no contributes field; `metadata` unread | corroborated by A2, A3, A5 |
| A2 | Claude Code plugin dependencies | https://code.claude.com/docs/en/plugin-dependencies | 2026-10-15 | web | Dependencies auto-install and the dependent plugin is disabled when one is missing or out of range; no optional form | corroborated by A1 |
| A3 | Claude Code plugin loading reference | https://code.claude.com/docs/en/plugins/loading | 2026-10-15 | web | Plugin cache layout, `installed_plugins.json`, versioned paths, six-source `enabledPlugins`, in-place loading | corroborated by A4 |
| A4 | Claude Code plugin CLI reference | https://code.claude.com/docs/en/plugins/cli-reference | 2026-10-15 | web | `claude plugin list --json` reports id, enabled, scope, version, installPath per installation | corroborated by A3 |
| A5 | Claude Code hooks reference | https://code.claude.com/docs/en/hooks | 2026-10-15 | web | SessionStart output is added to context before the first prompt, re-fires on resume/clear/compact; only enabled plugins run hooks | single source (caveated); hook environment corroborated by A1 |
| A6 | Claude Code skills reference | https://code.claude.com/docs/en/skills | 2026-10-15 | web | A failing load-time `!` command aborts the skill unless guarded; needs `allowed-tools`; can be disabled by a setting | single source (caveated) |
| A7 | Claude Code subagents reference | https://code.claude.com/docs/en/sub-agents | 2026-10-15 | web | Plugin agents register as `plugin:agent` and the model sees their descriptions; unknown-name error undocumented | corroborated by A34 on visibility |
| A8 | Mirror of anthropics/claude-code issue #32975 | https://claudeissues.com/issue/32975-bug-agent-tool-accepts-invalid-subagent-type-without-validation-error | 2026-10-15 | web | User report: an invalid `subagent_type` fails ambiguously without listing valid types | single source (caveated); contradicted by A9 |
| A9 | Mirror digest of issues #38964 and #45043 | https://claudeissues.com/issue/45043-subagent-type-with-custom-agents-from-claude-agents-returns-agent-type-not-found | 2026-10-15 | web | Snippets: unknown agent returns "Agent type '<x>' not found" with an available-agents list | single source (caveated); contradicted by A8 |
| A10 | Claude Code environment variables reference | https://code.claude.com/docs/en/env-vars | 2026-10-15 | web | `CLAUDE_CODE_PLUGIN_CACHE_DIR` moves the plugins root; `CLAUDE_CONFIG_DIR` effect on it unverified | single source (caveated) |
| A11 | Web search for optional dependency / contributes proposals | https://github.com/anthropics/claude-code/issues/48864, https://github.com/anthropics/claude-code/issues/51370 | 2026-10-15 | web | One search found only dependency doc-gap issues, no optional or contributes proposal | negative result, single search |
| A12 | Codex plugin build docs | https://developers.openai.com/codex/plugins/build | 2026-10-15 | web | Codex cache and enabled state under `~/.codex/`; no dependency or plugin-to-plugin reference documented | single source (caveated) |
| A13 | IntelliJ Platform extension points | https://plugins.jetbrains.com/docs/intellij/plugin-extension-points.html | 2026-10-15 | web | Defining plugin declares the extension point; contributors fill it in its namespace | corroborated by A15, A16, A20 |
| A14 | IntelliJ Platform optional plugin dependencies | https://plugins.jetbrains.com/docs/intellij/plugin-dependencies.html | 2026-10-15 | web | Optional `<depends>` isolates optional code in a separate config file so the plugin loads without the other | single source (caveated) |
| A15 | Python packaging entry points specification | https://packaging.python.org/en/latest/specifications/entry-points/ | 2026-10-15 | web | The consuming project defines the group's interface; prefix group names to avoid clashes | corroborated by A13, A16, A17 |
| A16 | pluggy documentation | https://pluggy.readthedocs.io/en/latest/ | 2026-10-15 | web | Host defines hookspecs, plugins implement; an impl matching no spec is accepted unless the host validates | corroborated by A15, A17 |
| A17 | pytest: writing plugins | https://docs.pytest.org/en/stable/how-to/writing_plugins.html | 2026-10-15 | web | Plugins auto-discovered via the pytest-owned `pytest11` entry-point group | corroborated by A15, A16 |
| A18 | Java ServiceLoader (Java 21) | https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/ServiceLoader.html | 2026-10-15 | web | Service owner defines the interface; no provider yields an empty result and the caller supplies a default | corroborated by A15, A16 |
| A19 | VS Code extension manifest | https://code.visualstudio.com/api/references/extension-manifest | 2026-10-15 | web | `contributes` declarations key on ids; `extensionPack` bundles members that must work independently | single source (caveated) |
| A20 | Eclipse FAQ: extensions and extension points | https://wiki.eclipse.org/FAQ_What_are_extensions_and_extension_points%3F | 2026-10-15 | web | Declaring plug-in defines the contract (socket); extensions are plugs | corroborated by A13 |
| A21 | npm package.json docs | https://docs.npmjs.com/cli/v10/configuring-npm/package-json | 2026-10-15 | web | Handling a missing optional dependency is the program's responsibility | corroborated by A18 |
| A22 | OSGi whiteboard pattern (search snippets) | https://enroute.osgi.org/FAQ/400-patterns.html | 2026-10-15 | web | Providers register services; consumer looks them all up; absence need not block | single source (caveated); pages not opened |
| A23 | Han config rule: extra agents and degradation | `han-core/references/config-rule.md:111-134` | n/a | codebase | Extra agents join the candidate pool; an unresolvable entry is skipped with a one-line note; bad config never fails a run | codebase anchor |
| A24 | Han config probe and resolver | `han-research/skills/research/SKILL.md:15-23`, `scripts/han-config-dir.sh`, `scripts/han-config-dir.bats:46-76` | n/a | codebase | Skills use only `${CLAUDE_PLUGIN_ROOT}` and a symlinked resolver script; no sibling-plugin lookup exists | codebase anchor |
| A25 | test-engineer dispatch in han-planning | `han-planning/skills/plan-a-feature/references/review-team-briefs.md:26`, `han-planning/skills/plan-implementation/references/team-selection.md:74-75`, `han-planning/skills/plan-a-change/references/team-selection.md:53`, `han-planning/skills/iterative-plan-review/references/team-selection.md:55-56` | n/a | codebase | Four han-planning skills select `han-core:test-engineer` by domain match, with no installed check | codebase anchor |
| A26 | test-engineer dispatch in han-coding | `han-coding/skills/automated-test-planning/SKILL.md:124,142`, `han-coding/skills/code-review/references/agent-dispatch.md:31-32`, `han-coding/skills/code-review/references/types/testing.md:9` | n/a | codebase | Two han-coding skills dispatch `han-core:test-engineer` | codebase anchor |
| A27 | Plugin manifests | `han-planning/.claude-plugin/plugin.json:5`, `han-coding/.claude-plugin/plugin.json:5`, `han/.claude-plugin/plugin.json:5-14` | n/a | codebase | han-planning and han-coding each depend only on han-communication and han-core | codebase anchor |
| A28 | han-core restructure decision D1 | `docs/plans/han-core-restructure/artifacts/decision-log.md:19-30` | n/a | codebase | Kept the shared roster in han-core; rejected splitting it between han-planning and han-coding over heavy overlap | codebase anchor |
| A29 | Agent placement rule | `CONTRIBUTING.md:203-207` | n/a | codebase | Agents live in han-core unless one skill family in one plugin dispatches them exclusively | codebase anchor |
| A30 | Earlier config extensibility research | `docs/research/han-config-extensibility.md:65-71` | n/a | codebase | A plugin cannot ship project config: plugin-root CLAUDE.md is not loaded and `userConfig` is user-scope only | single source (caveated) in that report |
| A31 | Namespace-qualified dispatch investigation | `docs/plans/namespace-qualified-agent-dispatch/investigation.md:25-26,62-70` | n/a | codebase | `dependencies` is install-only; bare agent names can collide across installed plugins | corroborated by A2 |
| A32 | Installed-skill detection prose | `han-planning/skills/plan-work-items/references/deliverable-skill-catalog.md:64` | n/a | codebase | A han-planning skill already checks a skill is installed and falls back to a best fit, in prose | codebase anchor |
| A33 | Absence of reference checks | `test/`, `han-planning/skills/*/scripts/check-*.sh` | n/a | codebase | No test checks that a dispatched agent exists or that config-rule copies match | codebase negative result |
| A34 | This session's available-agent listing | provided: Agent tool roster in the research session, 2026-10-15 | n/a | provided | The model's agent list shows plugin agents from six plugins as `plugin:agent` with descriptions | corroborated by A7 |

# Research: Discovering Configuration Contributed by Other Installed Han Plugins

The question: how can each installed Han plugin ship configuration that other Han plugins discover and load
automatically, so that, for example, `test-engineer` can move from `han-core` into `han-coding`, and `han-planning`
skills use it when `han-coding` is installed and run without it when it is not?

Evidence mode: strict.

## Summary

You can move `test-engineer` into `han-coding` and keep `han-planning` working without it, and the simplest way needs no
new machinery. Put the declaration in the agent itself. `test-engineer`'s description says it fills planning's
test-planning role. `han-planning` names that role in its team lists and uses whichever available agent claims it. When
`han-coding` is not installed, no agent claims the role and the planning skill runs without it.

This works because Claude Code already shows the model every installed agent and its description. It also follows the
pattern every established plugin system studied uses. The consuming side names a slot, and the providing side says it
fills that slot. The provider never lists the consumer's individual features, so renaming a planning skill never breaks
the coding plugin.

Claude Code has no built-in "optional dependency" or "contributes to" setting. A plugin that lists another as a
dependency gets it installed automatically and stops loading without it. So a general system for one plugin to hand
configuration to another has to be built. The best-supported way is a small hook in each providing plugin that prints
its contribution file when a session starts. Build that only when a plugin needs to contribute something other than an
agent. It adds Han's first hook, costs a little context in every session, and rests on one documentation page that has
not been checked in a live session.

How solid it is: the slot-and-filler pattern is well-corroborated; the agent-description route rests on how Claude Code
shows agents to the model, confirmed by its docs and by direct observation; the hook route rests on a single source.

- **Confidence:** Medium
- **Web search:** used

## Research Results

### Claude Code has no optional-dependency or contribution mechanism

A plugin's `dependencies` are hard requirements. They are installed automatically, and the dependent plugin is disabled
when one is missing or out of version range (A1, A2). Claude Code strips any manifest key it does not recognize, and it
documents no `contributes`, `extends`, or optional-dependency field (A1). One search turned up no proposal for one
[single-source] (A11). Claude Code ignores the free-form `metadata` object (A1), so a custom manifest field cannot carry
the declaration.

This rules out having `han-planning` depend on `han-coding`. That edge would auto-install `han-coding` and disable
`han-planning` without it (A2). Han's own earlier investigation reached the same conclusion: a dependency controls what
gets installed, not what a skill can see (A31).

### Prior art puts the contract with the consumer

Every plugin system surveyed has the consuming side, or a neutral host, define the named slot. Providers register
against that slot.

- IntelliJ: the defining plugin declares an extension point, and other plugins contribute into its namespace (A13).
- Eclipse: the declaring plug-in owns the contract (A20).
- Python entry points: the consumer owns the group and its interface (A15).
- pluggy and pytest: the host owns the hook specs, and plugins implement them (A16, A17).
- Java ServiceLoader: the service owner defines the interface (A18).
- OSGi whiteboard: providers register themselves, and the consumer looks them all up [single-source] (A22).

None of the surveyed systems has a provider list the consumer's internal features. This is a bounded survey of about
ten systems, not proof that none does. The nearest cases, VS Code `contributes` and IntelliJ optional `<depends>`, have
the provider name a host-defined slot or id (A14, A19). Applied to your example, "`test-engineer` is usable by
`plan-a-feature` and `plan-implementation`" names consumer skills. "`test-engineer` fills `han-planning`'s
test-planning role" names a slot. Both keep the declaration inside `han-coding`, which is what you asked for. Only the
second matches the surveyed pattern.

### The consumer always owns what happens when nothing is installed

The systems agree that absence is the consumer's problem to handle. ServiceLoader returns an empty result and the caller
supplies a default (A18). npm says handling a missing optional dependency "is still your program's responsibility"
(A21). IntelliJ isolates optional code so the core never touches it [single-source] (A14).

Han already has this rule for user-configured extra agents. An entry that does not resolve to a dispatchable agent is
skipped with a one-line note, and a bad config never fails a run (A23). A contributed agent can reuse those semantics
unchanged.

### The known failure mode is a silent no-op

Pluggy accepts an implementation whose hook name matches nothing, unless the host runs an explicit check (A16). For Han,
the same thing happens if `han-coding` names a role `han-planning` renamed or never had: the contribution is ignored and
nobody is told. No check in `test/` or the planning scripts verifies that an agent reference resolves (A33), so nothing
would catch it today.

### Four ways a skill could learn what another plugin contributes

No environment variable or substitution exposes another plugin's install location. `${CLAUDE_PLUGIN_ROOT}` and
`${CLAUDE_PLUGIN_DATA}` point only at the plugin itself (A1). Han reaches files only through its own plugin and skill
roots and has no code that finds sibling plugins (A24). Han's earlier research also found that a plugin cannot hand
configuration to a project through a CLAUDE.md at its root or through `userConfig` [single-source] (A30). What remains:

- **The session's own agent list.** Plugin agents register as `plugin:agent`, and the model sees every available
  agent's description (A7). This session's own agent list shows agents from six plugins with their descriptions (A34).
  Han already uses prose-level "check it is installed, else fall back" logic for skills (A32). What the Agent tool does
  when handed an unknown agent name is undocumented. Two user reports disagree on whether the error lists the valid
  names [single-source each] (A8, A9).
- **Startup hook.** A plugin's SessionStart hook can print text into the session's context before the first prompt. It
  re-fires on resume, clear, and compaction, and only enabled plugins run hooks [single-source] (A5). Hook processes get
  only the plugin's own path variables, so the hook can read its own contribution file (A1). This is the only
  documented channel where a provider pushes content into the session. The docs do not say outright that a skill in a
  different plugin then reads it, or that subagents see it. No Han plugin ships a hook today (A35).
- **Command-line listing.** `claude plugin list --json` reports every installation with its id, enabled state, scope,
  version, and install path (A4). Calling it from a skill's load-time shell probe is unverified for speed and safety. A
  failing probe aborts the whole skill unless guarded (A6), and in-place plugins may report no install path (A3, A4).
- **Reading Claude Code's plugin folders.** `installed_plugins.json` and the versioned cache folder are documented, but
  as a loading reference, not a published schema (A3). The cache path changes on every update, a setting can move the
  root (A3, A10), and the file does not reflect which plugins are enabled for this project (A3).

### Codex has no equivalent

Codex plugins have no documented dependency field or plugin-to-plugin reference (A12). Han ships Codex manifests for
every plugin, so any design that leans on a Claude Code hook has no confirmed Codex counterpart.

### The move reaches further than the planning rosters

Han's current rule keeps an agent in `han-core` unless a single skill family in one plugin dispatches it exclusively
(A29). `test-engineer` is dispatched from four `han-planning` skills (A25) and two `han-coding` skills (A26). A recorded
decision rejected splitting the roster between `han-planning` and `han-coding`, because their dispatch sets overlap
heavily (A28). Moving `test-engineer` means amending both, whichever discovery route you pick.

The move also touches files beyond the dispatch rosters:

- Two `han-core` agents and one `han-planning` agent route test-planning questions to `test-engineer` by name (A36).
  After the move, `han-core` would name an agent that lives in a plugin above it and may not be installed.
- The evals name `han-core:test-engineer` 13 times (A36).
- `han-coding`'s own calls change namespace from `han-core:` to `han-coding:` (A26).

Neither plugin needs a new dependency. Both depend today only on `han-communication` and `han-core` (A27).

### Checking the general mechanism against Han's YAGNI rule

Han's YAGNI rule asks for evidence that an item is needed now, then prefers the strictly simpler version that meets it
(A37). The evidence you gave covers moving agents out of `han-core` with `test-engineer` as the first case. It does not
yet show a plugin needing to contribute anything other than an agent. The `han` meta-plugin installs both
`han-planning` and `han-coding` (A27), so most people get both today. The planning-without-coding install is your stated
requirement, which is evidence for the move. It is not evidence for a general configuration channel.

## Options to Consider

### O1: Provider startup hook prints a role-shaped contribution file

- **What it is:** `han-coding` ships a contribution file and a SessionStart hook that prints it. The file uses the same
  markdown shape as `.han/config.md`, with frontmatter and named sections (A38). It says which agents fill which named
  consumer roles, and could carry other settings later. `han-planning`'s team lists name roles. A skill uses any agent a
  contribution in context names for its role, and skips the role when none does. It is the general configuration
  channel you described.
- **Trade-offs:** It uses only documented parts (A1, A5), and only enabled plugins contribute (A5). It costs a small
  amount of context every session, including sessions that never run a planning skill, and the model reads it rather
  than a parser. If the hook does not run, the role is skipped without notice even though `han-coding` is installed. It
  is Han's first hook (A35), and has no confirmed Codex path (A12).
- **Rests on:** (A1), (A5), (A15), (A16), (A23), (A38)
- **Evidence status:** single-source (caveated) for the hook transport (A5); corroborated for the role contract.

### O2: Skill probe calls the command-line plugin listing

- **What it is:** Each consuming skill's load-time probe runs `claude plugin list --json`, finds enabled Han plugins,
  and reads each one's contribution file from its install path.
- **Trade-offs:** It is machine-parsed and reports enabled state (A4). But it nests a CLI call inside every skill load,
  with unverified latency and safety, and a failure aborts the skill unless guarded (A6). In-place plugins may lack an
  install path (A4). Every consuming skill needs a new `allowed-tools` grant (A6, A24).
- **Rests on:** (A3), (A4), (A6)
- **Evidence status:** corroborated for the output format; single-source (caveated) that it is safe to run from a probe.

### O3: Skill probe reads Claude Code's plugin folders directly

- **What it is:** A shared script, symlinked into each plugin like the config-dir resolver (A24), reads
  `installed_plugins.json` or searches sibling folders in the plugin cache for contribution files.
- **Trade-offs:** It is fast and needs no CLI. But the files it reads are not a published schema, it misses the
  project-level enabled state, and the path moves with versions and settings (A3, A10). It is the most fragile option.
- **Rests on:** (A3), (A10), (A24)
- **Evidence status:** single-source (caveated)

### O4: Consumer team list names the optional agent

- **What it is:** `han-planning`'s team list names `han-coding:test-engineer` as optional. A skill dispatches it if it
  appears among the session's available agents and skips the role if it does not. No contribution file and no
  transport.
- **Trade-offs:** It needs no new machinery and works anywhere agents register (A7, A34). It reuses Han's existing skip
  rule (A23). But the mapping lives in `han-planning`, which is the opposite of what you asked for, and `han-planning`
  must know `han-coding`'s agent name. It covers agents only.
- **Rests on:** (A7), (A23), (A34)
- **Evidence status:** corroborated for agent visibility (A7, consistent with A34); unknown-agent behavior unresolved
  (A8, A9).

### O5: The agent declares its role in its own description

- **What it is:** The O4 mechanism with the declaration moved into `han-coding`. `test-engineer`'s description states
  that it fills planning's test-planning role. `han-planning`'s team list names the role, not the agent, and uses any
  available agent whose description claims it.
- **Trade-offs:** The declaration lives in the providing plugin, as you asked, with no hook, no file, and no Codex gap
  beyond whether Codex shows agents to the model (A7, A12). The cost: descriptions also drive Claude Code's automatic
  delegation and count against a shared context budget (A7), so role text has to stay short. A role claimed in prose
  cannot be checked by a parser, though a test can search descriptions for role names to catch the silent no-op (A16,
  A33). It covers agents only.
- **Rests on:** (A7), (A13), (A15), (A23), (A34)
- **Evidence status:** corroborated for agent visibility and the role contract; no source documents role-matching on
  descriptions specifically.

### O6: Delegate to a han-coding skill when it is installed

- **What it is:** Move the agent, and have the planning skill invoke `han-coding`'s `automated-test-planning` skill,
  which dispatches `test-engineer` alone in its focused mode (A39), when that skill is installed. Otherwise skip.
- **Trade-offs:** It uses Han's existing "check the skill is installed, else fall back" prose (A32) and needs no hook.
  The skill's own description is the declaration. But it runs a whole skill, with its own output and steps, where the
  planning roster wanted one specialist's input on a plan. It covers only capabilities that already have a skill.
- **Rests on:** (A32), (A39)
- **Evidence status:** codebase only; untested as a cross-plugin delegation.

### O7: Keep the shared roster in `han-core`

- **What it is:** The status quo. Every agent either plugin dispatches stays in `han-core`.
- **Trade-offs:** It is proven and needs no new mechanism (A28, A29). It leaves `han-core` carrying agents that only one
  plugin family needs, which is the problem you want to solve.
- **Rests on:** (A28), (A29)
- **Evidence status:** corroborated (codebase)

A registry file in `han-core` that each provider edits is not listed. It puts `han-core` back in the middle, and
`han-core` would have to know about every provider, which is the coupling the move is meant to remove.

## Recommendation

- **Recommendation:** Adopt O5 for `test-engineer`. Name roles, not agents, in `han-planning`'s team lists, and have the
  moved agent's description claim its role. A planning skill uses an available agent that claims the role and otherwise
  skips it with Han's existing one-line note.
  - Add a test that every role an agent description claims appears in some consumer team list.
  - Amend the agent-placement rule and decision D1, and update the `han-core` agents, the evals, and the docs that name
    `test-engineer`.
  - Hold O1 until a plugin needs to contribute something other than an agent. At that point, first run one live check:
    install `han-coding` with a SessionStart hook from a local marketplace and confirm a `han-planning` skill and its
    subagents see the printed text after a compaction.
  - If you would rather keep descriptions free of planning concepts, O4 is the plainer fallback, at the cost of the
    mapping living in `han-planning`.
- **Evidence basis:**
  - Corroborated: the consumer owns the slot and the handling of absence (A13, A15, A16, A18, A20, A21); Claude Code
    has no optional or contributes field, and dependencies are hard (A1, A2); the model sees each plugin agent's name
    and description (A7, consistent with A34); Han already skips unresolved extra agents (A23).
  - Codebase: the move amends the placement rule (A29) and D1 (A28) and touches routing text and evals (A36); YAGNI
    favors the smallest version that meets the stated need (A37).
  - Not documented anywhere found: matching a role named in an agent's description. It follows from agent visibility
    (A7) and is how Han already selects agents by stated specialty, but no source tests it as a contract.
  - Single-source, and deferred for that reason: the hook transport (A5). The unknown-agent error behavior (A8, A9) is
    avoided by checking the available-agent list first.

## Validation

The adversarial validator challenged the evidence, the options framing, the recommendation, and how the evidence was
gathered. The first draft recommended the hook (O1) as the primary transport. Validation changed that.

### V1: Codebase anchors are accurate

- **Strategy:** Challenge the Evidence
- **Investigation:** Read every cited codebase range (A23 to A29, A31, A32, A33).
- **Result:** Confirmed. Line offsets are within a line or two.
- **Impact:** None.

### V2: "Han uses nothing beyond `${CLAUDE_PLUGIN_ROOT}`" overreached

- **Strategy:** Challenge the Evidence
- **Investigation:** A repository search found `${CLAUDE_SKILL_DIR}` in two `han-coding` skills. It also confirmed that
  no plugin ships hooks.
- **Result:** Partially Refuted.
- **Impact:** Reworded to "its own plugin and skill roots". Added A35 for the no-hooks claim.

### V3: The no-test claim was broader than the search

- **Strategy:** Challenge the Evidence
- **Investigation:** Listed `test/` and the planning scripts, and found the evals reference `han-core:test-engineer`.
- **Result:** Confirmed, with a narrower scope.
- **Impact:** A33 now says "no check found in `test/` or the planning scripts". The evals joined the list of files the
  move touches (A36).

### V4: A skill-delegation option was missing

- **Strategy:** Challenge the Options Framing
- **Investigation:** `han-planning` already has installed-skill fallback prose (A32), and `automated-test-planning` can
  dispatch `test-engineer` alone (A39).
- **Result:** Refuted. The option set was incomplete.
- **Impact:** Added O6.

### V5: Agent self-description and a registry file were not considered

- **Strategy:** Challenge the Options Framing
- **Investigation:** The model already sees each agent's description (A7, A34), so the agent can carry its own role
  claim. A `han-core` registry would put `han-core` back in the middle.
- **Result:** Partially Refuted.
- **Impact:** Added O5, and a one-line rejection of the registry.

### V6: The push-versus-pull framing was stated too strongly

- **Strategy:** Challenge the Options Framing
- **Investigation:** The prior-art claim rests on a bounded survey. Your requested shape keeps the declaration in
  `han-coding`, which O1 and O5 both honor.
- **Result:** Partially Refuted.
- **Impact:** Softened to "the surveyed systems do not do this". The report now says which options keep the declaration
  in the provider.

### V7: The availability guard does not cover a hook that never runs

- **Strategy:** Challenge the Recommendation
- **Investigation:** Checking the available-agent list prevents dispatching a missing agent. If the hook never runs,
  the contribution never reaches context, and an installed `test-engineer` is skipped without notice.
- **Result:** Partially Refuted.
- **Impact:** Removed the claim that the guard makes O1 safe if A5 is wrong. Named the silent skip as an O1 trade-off.

### V8: The move touches agents and evals the draft did not list

- **Strategy:** Challenge the Recommendation
- **Investigation:** `plan-synthesizer`, `junior-developer`, and `discussion-facilitator` route to `test-engineer` by
  name. The evals and `han-coding`'s own calls name it under `han-core:` (A36, A26).
- **Result:** Partially Refuted.
- **Impact:** Added the section on how far the move reaches. The recommendation now includes those updates.

### V9: The general mechanism was not checked against YAGNI

- **Strategy:** Challenge the Recommendation
- **Investigation:** Applied Han's YAGNI rule (A37). The meta-plugin installs both plugins (A27). The stated need is
  agents. The hook adds Han's first hook, per-session context cost, and a Codex gap.
- **Result:** Partially Refuted.
- **Impact:** Added the YAGNI section. O1 moved from recommended to deferred.

### V10: Several citations fit loosely

- **Strategy:** Challenge the Evidence
- **Investigation:** Traced every inline citation against its registry summary.
- **Problems found:**
  - The config-file shape claim had no source.
  - A34 was labeled as corroborating A7, but it is one session's observation.
  - A22 was never cited.
  - O1 cited prior-art sources for its hook.
- **Result:** Partially Refuted.
- **Impact:** Fixed each one:
  - Added A38 for the config-file shape.
  - Relabeled A34 as consistent with A7.
  - Cited A22 in the prior-art list.
  - Trimmed O1's sources to those that bear on it.

### V11: The recommended transport rested on one source

- **Strategy:** Challenge the Evidence-Gathering Integrity
- **Investigation:** Checked how many sources each piece of the recommendation rests on, and how independent they are:
  - A5 alone supports the hook.
  - "Re-fires on compaction" is not the same claim as "a skill in another plugin can read it".
  - A8 and A9 are third-party copies of user bug reports.
  - A22 is search snippets only.
  - The summaries showed no planted or directive text.
- **Result:** Partially Refuted.
- **Impact:** The recommendation no longer depends on A5. Removing A8, A9, or A22 changes nothing.

### V12: The hook-first ordering was not supported

- **Strategy:** Challenge the Recommendation
- **Investigation:** Compared what O1 adds over the agent-list options once V7, V8, and V9 are applied.
- **Result:** Partially Refuted.
- **Impact:** The recommendation now leads with an option that needs no hook.

### Adjustments Made

The recommendation was rewritten. The first draft led with O1, the startup hook, and treated the agent-list check as a
guard. The final version leads with O5, which keeps the declaration in `han-coding` with no new machinery, and defers O1
until a non-agent contribution is needed and a live check passes. O5 and O6 were added, the move's full reach and a
YAGNI check were added, and the citation problems were fixed.

### Confidence Assessment

- **Confidence:** Medium
- **Remaining Risks:**
  - Role-matching on agent descriptions has no source that tests it as a contract.
  - The SessionStart hook route rests on one documentation page and has not been run in a live session.
  - What the Agent tool returns for an unknown agent name is unresolved (A8 and A9 conflict).
  - Codex behavior is untested for every option.
  - The validator did not re-fetch any web source.

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
| A24 | Han config probe and resolver | `han-research/skills/research/SKILL.md:15-23`, `scripts/han-config-dir.sh`, `scripts/han-config-dir.bats:46-76` | n/a | codebase | Skills reach files through their own plugin and skill roots and a symlinked resolver script; no sibling-plugin lookup exists | codebase anchor |
| A25 | test-engineer dispatch in han-planning | `han-planning/skills/plan-a-feature/references/review-team-briefs.md:26`, `han-planning/skills/plan-implementation/references/team-selection.md:74-75`, `han-planning/skills/plan-a-change/references/team-selection.md:53`, `han-planning/skills/iterative-plan-review/references/team-selection.md:55-56` | n/a | codebase | Four han-planning skills select `han-core:test-engineer` by domain match, with no installed check | codebase anchor |
| A26 | test-engineer dispatch in han-coding | `han-coding/skills/automated-test-planning/SKILL.md:124,142`, `han-coding/skills/code-review/references/agent-dispatch.md:31-32`, `han-coding/skills/code-review/references/types/testing.md:9` | n/a | codebase | Two han-coding skills dispatch `han-core:test-engineer` | codebase anchor |
| A27 | Plugin manifests | `han-planning/.claude-plugin/plugin.json:5`, `han-coding/.claude-plugin/plugin.json:5`, `han/.claude-plugin/plugin.json:5-14` | n/a | codebase | han-planning and han-coding each depend only on han-communication and han-core | codebase anchor |
| A28 | han-core restructure decision D1 | `docs/plans/han-core-restructure/artifacts/decision-log.md:19-30` | n/a | codebase | Kept the shared roster in han-core; rejected splitting it between han-planning and han-coding over heavy overlap | codebase anchor |
| A29 | Agent placement rule | `CONTRIBUTING.md:203-207` | n/a | codebase | Agents live in han-core unless one skill family in one plugin dispatches them exclusively | codebase anchor |
| A30 | Earlier config extensibility research | `docs/research/han-config-extensibility.md:65-71` | n/a | codebase | A plugin cannot ship project config: plugin-root CLAUDE.md is not loaded and `userConfig` is user-scope only | single source (caveated) in that report |
| A31 | Namespace-qualified dispatch investigation | `docs/plans/namespace-qualified-agent-dispatch/investigation.md:25-26,62-70` | n/a | codebase | `dependencies` is install-only; bare agent names can collide across installed plugins | corroborated by A2 |
| A32 | Installed-skill detection prose | `han-planning/skills/plan-work-items/references/deliverable-skill-catalog.md:64` | n/a | codebase | A han-planning skill already checks a skill is installed and falls back to a best fit, in prose | codebase anchor |
| A33 | Absence of reference checks | `test/`, `han-planning/skills/*/scripts/check-*.sh` | n/a | codebase | No check found in `test/` or the planning scripts that a dispatched agent exists or that config-rule copies match | codebase negative result, bounded search |
| A34 | This session's available-agent listing | provided: Agent tool roster in the research session, 2026-10-15 | n/a | provided | The model's agent list shows plugin agents from six plugins as `plugin:agent` with descriptions | consistent with A7; direct observation of one session |
| A35 | Absence of hooks in Han plugins | `*/.claude-plugin/plugin.json`, plugin directories | n/a | codebase | No Han plugin ships a hooks directory or a `hooks` manifest key | codebase negative result |
| A36 | test-engineer references outside the dispatch rosters | `han-core/agents/plan-synthesizer.md:153`, `han-core/agents/junior-developer.md:241`, `han-planning/agents/discussion-facilitator.md:143`, `evals/test-engineer/tests.json` | n/a | codebase | Two han-core agents and one han-planning agent route test planning to `test-engineer` by name; the evals name `han-core:test-engineer` 13 times | codebase anchor |
| A37 | Han YAGNI rule | `han-core/references/yagni-rule.md:24-46` | n/a | codebase | Gate 1 needs evidence an item is needed now; Gate 2 prefers the strictly simpler version that meets it | codebase anchor |
| A38 | Han config file schema | `han-core/references/config-rule.md:49-76` | n/a | codebase | Config files are markdown: frontmatter for scalar settings, named sections such as `## Extra Agents` for lists | codebase anchor |
| A39 | han-coding automated-test-planning focused mode | `han-coding/skills/automated-test-planning/SKILL.md:124` | n/a | codebase | The skill's focused mode dispatches `test-engineer` alone | codebase anchor |

### A7: Claude Code subagents reference — recommendation-bearing

- **Link / location:** https://code.claude.com/docs/en/sub-agents
- **Retrieved:** 2026-10-15
- **Trust class:** web (outside the trust boundary)
- **Summary:** Plugin agents register under a `plugin:agent` name. Claude Code decides when to delegate to an agent from
  its `description`, so every available agent's description is loaded into the model's context, and the combined
  descriptions count against a context budget that warns at about 15,000 tokens. The page does not document what the
  Agent tool returns when asked for an agent name that does not exist.
- **Evidence status:** consistent with A34

### A15: Python packaging entry points specification — recommendation-bearing

- **Link / location:** https://packaging.python.org/en/latest/specifications/entry-points/
- **Retrieved:** 2026-10-15
- **Trust class:** web (outside the trust boundary)
- **Summary:** An entry-point group names a kind of object that installed packages can provide. The consuming project
  typically defines the group's interface, and a new group should be prefixed with a project name the author controls
  to avoid clashes. This is the clearest statement of the slot-and-filler pattern the recommendation follows.
- **Evidence status:** corroborated by A13, A16, A17

### A23: Han config rule, extra agents and degradation — recommendation-bearing

- **Link / location:** `han-core/references/config-rule.md:111-134`
- **Retrieved:** n/a
- **Trust class:** codebase (trusted current-state anchor)
- **Summary:** Extra agents named in `.han/config.md` join a skill's candidate pool and compete under its own selection
  rules and size caps. An entry that does not resolve to a dispatchable agent is skipped with a one-line note, and a bad
  config never fails a run. A contributed agent can follow the same rules unchanged.
- **Evidence status:** codebase anchor

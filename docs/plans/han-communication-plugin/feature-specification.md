# Feature Specification: han-communication Plugin

Extract the readability capability and its shared writing standard into a new foundational plugin, `han-communication`, so a single plugin owns the readability-editor agent, the edit-for-readability skill, and the readability and writing-voice reference documents; every skill that needs any of them reaches them by delegating to `han-communication` rather than reading vendored copies.

## Outcome

After this change, the Han suite has one home for its readability capability and one canonical copy of its writing standard.

- The `readability-editor` agent, the `edit-for-readability` skill, the readability rule reference, and the writing-voice profile all live in a new plugin, `han-communication`, which depends on nothing and sits beneath every other plugin in the suite ([D1](artifacts/decision-log.md#d1-introduce-han-communication-as-a-foundational-plugin), [D2](artifacts/decision-log.md#d2-move-all-four-assets-together)).
- No other plugin carries a duplicate copy of the readability rule or the writing-voice profile. The vendored copies that previously lived in `han-core`, `han-coding`, `han-github`, and `han-reporting` are gone ([D3](artifacts/decision-log.md#d3-delegate-rather-than-inline-the-standard)).
- Every skill that used to reach the readability rule or writing-voice profile from a copy inside its own plugin now obtains readability and voice enforcement by invoking `han-communication`'s capability instead. This replaces all three inline uses of the reference files — applying the standard while drafting, running the end-of-run self-check, and dispatching the editor rewrite — with a single delegated rewrite pass ([D3](artifacts/decision-log.md#d3-delegate-rather-than-inline-the-standard), [D4](artifacts/decision-log.md#d4-full-delegation-replaces-inline-drafting-and-self-check)).
- Installing the `han` meta-plugin, or any plugin that produces prose output, still delivers a working readability capability, because each such plugin declares a dependency on `han-communication` ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency), [D6](artifacts/decision-log.md#d6-meta-plugin-bundles-han-communication)).

## Actors and Triggers

- **Actors** — an operator running any Han skill that produces prose output (a report, spec, overview, triage document, ADR, runbook, PR description, or stakeholder summary); a contributor maintaining the suite; the plugin loader that resolves a plugin's declared dependencies at install time.
- **Triggers** — an operator runs a skill whose output must meet the shared readability standard; a contributor installs one of the Han plugins; a contributor edits the readability rule or the writing-voice profile.
- **Preconditions** — the plugin that hosts the running skill declares a dependency on `han-communication` (directly or transitively), so the readability-editor agent and the edit-for-readability skill are resolvable by their qualified names.

## Primary Flow

1. A contributor installs a Han plugin that produces prose output (for example the `han` meta-plugin, or `han-coding` on its own). The plugin loader resolves that plugin's declared dependency on `han-communication` and installs it alongside ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)).
2. An operator runs a skill that produces prose — for example a code review, an investigation report, or a stakeholder summary.
3. When the skill reaches the point where its output must meet the shared readability standard, it delegates that work to `han-communication`: it invokes the `edit-for-readability` skill, or dispatches the `readability-editor` agent, by its `han-communication`-qualified name ([D3](artifacts/decision-log.md#d3-delegate-rather-than-inline-the-standard)).
4. The readability capability reads the readability rule and the writing-voice profile from `han-communication`'s own copy — the single canonical copy in the suite — and rewrites the draft's prose regions against the standard, preserving every fact.
5. The skill delivers the rewritten output. The operator sees output that meets the same readability standard as before, now enforced through one shared capability rather than a copy embedded in each plugin.

## Alternate Flows and States

### A contributor edits the writing standard

- **Entry condition:** a contributor changes the readability rule or the writing-voice profile.
- **Sequence:** the contributor edits the single canonical copy inside `han-communication`. No byte-identical copies exist elsewhere to keep in sync ([D3](artifacts/decision-log.md#d3-delegate-rather-than-inline-the-standard)).
- **Exit:** every skill in the suite picks up the change the next time it delegates, because they all reach the same copy.

### Drafting-time application and self-check move to a delegated rewrite

- **Entry condition:** an operator runs any prose-producing skill that used the standard inline — most read the rule *as they draft* (the audience frame shapes the writing), and about nine also run an end-of-run self-check against the rule. Four of these (issue-triage, architectural-decision-record, runbook, html-summary) ran only the inline drafting guide and self-check, with no rewrite pass at all.
- **Sequence:** the skill can no longer read the rule from inside its own plugin, so both the drafting-time application and the self-check are replaced by a single delegated readability pass: the skill invokes `han-communication`'s edit-for-readability skill or dispatches the readability-editor agent over its finished draft ([D4](artifacts/decision-log.md#d4-full-delegation-replaces-inline-drafting-and-self-check)).
- **Exit:** the output still meets the standard, enforced by the editor rewrite rather than during drafting. Two observable changes result: the skills no longer draft with in-voice guidance in hand, and every prose-producing skill now runs a readability-editor dispatch per run — including the four that previously ran only an inline checklist.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
|-----------|-------------------|
| A plugin that produces prose output is installed without `han-communication` present. | The plugin declares `han-communication` as a dependency, so a supported install always resolves it. A skill that reaches a delegation point with the capability unresolved is a broken install, not a supported state ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)). |
| An opt-in plugin (`han-atlassian`, `han-linear`, `han-feedback`) runs a skill that produces prose. | The readability capability must be resolvable when the skill runs. `han-atlassian` wraps prose-producing skills (project-documentation, investigate, code-overview), so this path is real, not hypothetical. Whether the capability resolves transitively through the opt-in plugin's dependency on `han-core` is unconfirmed ([OI-1](#open-items)); if it does not, each affected opt-in plugin declares `han-communication` directly ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)). |
| A skill invokes the readability capability by its old `han-core`-qualified name after the move. | The invocation fails, because the agent and skill no longer live in `han-core`. Every invocation site is updated to the `han-communication`-qualified name as part of the move ([D9](artifacts/decision-log.md#d9-qualified-name-contract-changes-namespace-only)). |
| A contributor reads a doc or top-level guidance file that still points at the old canonical location of the rule or profile. | Every pointer to the canonical location is updated to `han-communication`, so no doc directs a reader to a location that no longer holds the canonical copy ([D7](artifacts/decision-log.md#d7-docs-indexes-and-pointers-follow-the-move)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| `han-communication` | inbound | `han-core`, `han-coding`, `han-github`, and `han-reporting` skills delegate readability and voice enforcement to it | The delegating skill's plugin must declare the dependency so the capability resolves before the skill runs |
| `han` meta-plugin | outbound | Adds `han-communication` to its bundled dependency set | Installing `han` must continue to deliver the readability capability ([D6](artifacts/decision-log.md#d6-meta-plugin-bundles-han-communication)) |
| Marketplace manifest | outbound | Lists `han-communication` as an available plugin | A plugin that other plugins depend on must be resolvable from the marketplace ([D8](artifacts/decision-log.md#d8-marketplace-lists-han-communication)) |

## Out of Scope

- Changing the content of the readability rule or the writing-voice profile. This feature relocates them unchanged.
- Changing how the readability-editor agent rewrites prose, or the criteria in the readability standard. The editor agent's rewrite behavior is unchanged. Consuming skills' behavior does change: they stop applying the standard while drafting and stop self-checking inline, and instead delegate a rewrite pass ([D4](artifacts/decision-log.md#d4-full-delegation-replaces-inline-drafting-and-self-check)).
- Giving `han-planning` a dependency on `han-communication`. No planning skill uses the readability capability or reference documents ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)).
- Adding the readability capability to skills that do not produce prose output. Only the current consumers change how they reach the standard.

## Deferred (YAGNI)

### A shared-reference mechanism that lets plugins read a dependency's files by path
- **Why deferred:** evidence-test failure. A cross-plugin file-reference mechanism would remove the need to either vendor copies or delegate, but no supported way for a skill to read a file inside a declared dependency plugin exists today, and building one is far outside this feature. Delegation satisfies the same need with existing mechanics.
- **Reopen when:** the plugin runtime gains a supported way for a skill to reference a file inside a declared dependency plugin.
- **Source:** conversation context — the "how do consuming skills use the reference files" decision.

## Open Items

- **OI-1:** Confirm the plugin loader resolves declared dependencies transitively, so the opt-in plugins (`han-atlassian`, `han-linear`, `han-feedback`) reach `han-communication` through `han-core` without naming it directly.
  - **Resolves when:** a contributor verifies transitive dependency resolution in the plugin runtime, or the opt-in plugins are given an explicit dependency to be safe.
  - **Blocks implementation:** No — the fallback (name the dependency explicitly on the opt-in plugins) is low-cost and can be applied if transitive resolution is not guaranteed.

## Summary

- **Outcome delivered:** One foundational plugin owns the readability capability and the single canonical writing standard; every consuming skill reaches it by delegation, with no duplicated reference copies.
- **Primary actors:** operators running prose-producing Han skills; contributors maintaining the suite.
- **Decisions settled by evidence:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 2 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, information-architect, gap-analyzer — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the review team showed delegation replaces three inline uses of the standard (drafting, self-check, rewrite), not one — corrected in D4 and the spec; and it expanded the documentation-and-tooling scope well beyond the initial D7 (inbound doc links, `docs/readability.md`, CONTRIBUTING/CLAUDE.md vendoring instructions, repo-maintenance skills, and template files). — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1

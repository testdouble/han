# Feature Specification: han-communication Plugin

Extract the readability capability and its shared writing standard into a new foundational plugin, `han-communication`, so a single plugin owns the readability-guidance skill, the readability-editor agent, the edit-for-readability skill, and the readability and writing-voice reference documents; every skill that needs the standard reaches it by invoking `han-communication` — sourcing the standard for in-voice drafting through a guidance skill, and running the adversarial rewrite through the editor where the standard already reserves it — rather than reading vendored copies.

## Outcome

After this change, the Han suite has one home for its readability capability and one canonical copy of its writing standard, and it keeps applying that standard in stages rather than as one block.

- A new `readability-guidance` skill, the `readability-editor` agent, the `edit-for-readability` skill, the readability rule reference, and the writing-voice profile all live in a new plugin, `han-communication`, which depends on nothing and sits beneath every other plugin in the suite ([D1](artifacts/decision-log.md#d1-introduce-han-communication-as-a-foundational-plugin), [D2](artifacts/decision-log.md#d2-move-all-four-assets-together), [D11](artifacts/decision-log.md#d11-source-the-standard-through-a-readability-guidance-skill)).
- No other plugin carries a duplicate copy of the readability rule or the writing-voice profile. The vendored copies that previously lived in `han-core`, `han-coding`, `han-github`, and `han-reporting` are gone ([D3](artifacts/decision-log.md#d3-source-the-standard-cross-plugin-not-inline)).
- Every skill that used to reach the readability rule or writing-voice profile from a copy inside its own plugin now sources the standard by invoking `han-communication`'s `readability-guidance` skill, which surfaces the rule and voice profile into the skill's own context so it drafts in voice and runs its self-check — the same staged application the suite used before, now sourced cross-plugin instead of from a vendored file ([D3](artifacts/decision-log.md#d3-source-the-standard-cross-plugin-not-inline), [D11](artifacts/decision-log.md#d11-source-the-standard-through-a-readability-guidance-skill)).
- Skills that synthesize a whole draft additionally run the adversarial rewrite through `han-communication`'s editor, exactly as the standard already reserves that pass for synthesis skills; skills that only draft-and-self-check run no rewrite ([D4](artifacts/decision-log.md#d4-preserve-the-staged-model-guidance-plus-editor-for-synthesis)).
- Installing the `han` meta-plugin, or any plugin that produces prose output, still delivers a working readability capability, because each such plugin declares a dependency on `han-communication` ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency), [D6](artifacts/decision-log.md#d6-meta-plugin-bundles-han-communication)).

## Actors and Triggers

- **Actors** — an operator running a consuming Han skill that produces prose output (a report, overview, triage document, ADR, runbook, PR description, or stakeholder summary); a contributor maintaining the suite; the primary plugin loader that resolves a plugin's declared dependencies at install time; and a Codex-based operator who installs plugins individually.
- **Triggers** — an operator runs a skill whose output must meet the shared readability standard; a contributor installs one of the Han plugins; a contributor edits the readability rule or the writing-voice profile.
- **Preconditions** — on the **primary loader**, every plugin that hosts a delegating skill, or can trigger one by wrapping or bundling another plugin's delegating skill, declares a **direct** dependency on `han-communication`; the plan does not rely on transitive dependency resolution, so the capability is always resolvable by its qualified names ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)). On the **Codex** surface, which resolves no dependencies, resolvability instead depends on the operator following install guidance that names `han-communication` explicitly ([D10](artifacts/decision-log.md#d10-codex-packaging-parity)).

## Primary Flow

1. A contributor installs a Han plugin that produces prose output (for example the `han` meta-plugin, or `han-coding` on its own). The plugin loader resolves that plugin's declared **direct** dependency on `han-communication` — the foundational plugin that depends on nothing ([D1](artifacts/decision-log.md#d1-introduce-han-communication-as-a-foundational-plugin)) — and installs it alongside ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)).
2. An operator runs a skill that produces prose — for example a code review, an investigation report, or a stakeholder summary.
3. As the skill begins producing prose, it invokes `han-communication`'s `readability-guidance` skill by its qualified name. Because a skill invoked this way runs in the same context, the guidance skill surfaces the readability rule and writing-voice profile — read from `han-communication`'s own single canonical copy — into the running skill's context ([D3](artifacts/decision-log.md#d3-source-the-standard-cross-plugin-not-inline), [D11](artifacts/decision-log.md#d11-source-the-standard-through-a-readability-guidance-skill)).
4. The skill drafts in voice against that guidance and runs its self-check, exactly as it did before the move — the standard is now sourced cross-plugin instead of from a vendored file. If the skill synthesizes a whole draft, it then dispatches `han-communication`'s readability-editor for the adversarial rewrite, preserving every fact; a skill that only drafts-and-self-checks runs no rewrite ([D4](artifacts/decision-log.md#d4-preserve-the-staged-model-guidance-plus-editor-for-synthesis)).
5. The skill delivers its output. The operator sees output that meets the same readability standard as before, applied in the same stages, now sourced through one shared capability rather than a copy embedded in each plugin.

## Alternate Flows and States

### A contributor edits the writing standard

- **Entry condition:** a contributor changes the readability rule or the writing-voice profile.
- **Sequence:** the contributor edits the single canonical copy inside `han-communication`. No byte-identical copies exist elsewhere to keep in sync ([D3](artifacts/decision-log.md#d3-source-the-standard-cross-plugin-not-inline)).
- **Exit:** every skill in the suite picks up the change the next time it sources the standard, because they all reach the same copy.

### Sourcing the standard cross-plugin, in stages

- **Entry condition:** an operator runs any prose-producing consumer skill. Before the move, each read the rule from a vendored file inside its own plugin — applying it *as it drafts* and in an end-of-run self-check; nine of the consumers also dispatched the editor for a synthesis rewrite, and four ran no rewrite at all.
- **Sequence:** the skill can no longer read the rule from inside its own plugin, so it invokes `han-communication`'s `readability-guidance` skill to surface the rule and voice profile into its context, then drafts in voice and self-checks as before. A synthesizing skill additionally dispatches the readability-editor over its finished draft; a draft-and-self-check-only skill does not ([D4](artifacts/decision-log.md#d4-preserve-the-staged-model-guidance-plus-editor-for-synthesis)).
- **Exit:** the output meets the standard through the same staged application as before — template, in-voice drafting, self-check, and (for synthesis skills) the adversarial rewrite. The one observable change is where the standard comes from: a `han-communication` skill invocation rather than a vendored file. The four draft-and-self-check-only skills gain no rewrite pass, and any size-conditional editor skip (for example gap-analysis on its smallest path) is preserved, because the drafting-stage standard is available without a rewrite.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
|-----------|-------------------|
| A plugin that produces prose output is installed without `han-communication` present. | The plugin declares `han-communication` as a dependency, so a supported install always resolves it. A skill that reaches the point where it sources the standard with the capability unresolved is a broken install, not a supported state ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)). |
| An opt-in plugin (`han-atlassian`, `han-linear`, `han-feedback`) runs a skill that produces prose. | `han-atlassian` wraps prose-producing skills (project-documentation, investigate, code-overview) that delegate to `han-communication`, so it declares `han-communication` as a **direct** dependency — the plan never relies on reaching it transitively through `han-core`. `han-linear` and `han-feedback` host and trigger no delegating skill, so they declare no dependency ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)). |
| A skill invokes the readability capability by its old `han-core`-qualified name after the move. | The invocation fails, because the agent and skill no longer live in `han-core`. Every invocation site is updated to the `han-communication`-qualified name as part of the move ([D9](artifacts/decision-log.md#d9-qualified-name-contract-changes-namespace-only)). |
| A contributor reads a doc or top-level guidance file that still points at the old canonical location of the rule or profile, or narrates the dependency graph as it was before the move. | Every pointer to the canonical location, and every prose description of which plugins depend on which, is updated to reflect `han-communication` and the new dependency edges, so no doc directs a reader to a stale location or an under-stated dependency set ([D7](artifacts/decision-log.md#d7-docs-indexes-tooling-and-pointers-follow-the-move)). |
| A synthesis skill whose output has safety-critical ordering (a runbook's numbered incident steps, or a likelihood-ranked cause list the steps branch on) or is structured non-prose (an HTML report) dispatches the readability-editor rewrite. | The rewrite touches only surrounding prose and preserves every step's position and identity: it does not reorder, renumber, split, or merge numbered procedure steps (including steps whose number is carried in a heading), keeps numeric cross-references between steps consistent, preserves the order of any list whose sequence is operationally load-bearing even when it is not numbered, and leaves non-prose structure — code, commands, markup, diagrams, and layout — unchanged. A rewrite never disturbs the operational sequence a reader follows during an incident ([D4](artifacts/decision-log.md#d4-preserve-the-staged-model-guidance-plus-editor-for-synthesis)). |
| A Codex-based operator installs a plugin that produces prose output. | The Codex packaging surface carries `han-communication` too — a Codex plugin manifest, a Codex marketplace entry, and Codex install guidance that names `han-communication` explicitly (in both the primary and opt-in install paths, since `han-atlassian` reaches the capability through the opt-in path). Because the Codex manifests declare no dependencies, naming it explicitly is what keeps it from being silently absent ([D10](artifacts/decision-log.md#d10-codex-packaging-parity)). |

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| `han-communication` | inbound | `han-core`, `han-coding`, `han-github`, `han-reporting`, and `han-atlassian` skills invoke its `readability-guidance` skill to source the standard, and synthesis skills additionally dispatch its editor | Every plugin that hosts or triggers such a skill declares a direct dependency, with no transitive reliance, so the capability resolves before the skill runs ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)) |
| `han` meta-plugin | outbound | Adds `han-communication` to its own direct dependency set | Installing `han` must deliver the readability capability without relying on transitive resolution of its other dependencies' dependencies ([D6](artifacts/decision-log.md#d6-meta-plugin-bundles-han-communication)) |
| Marketplace manifest | outbound | Lists `han-communication` as an available plugin and updates every plugin `description` (and its mirror in the manifest) that narrates the dependency set | A plugin that other plugins depend on must be resolvable from the marketplace, and no description may under-state the dependency graph ([D8](artifacts/decision-log.md#d8-marketplace-and-manifest-descriptions-follow-the-move)) |
| Codex packaging surface | outbound | Adds a Codex plugin manifest, a Codex marketplace entry, and a Codex install line for `han-communication` | Installing the suite for a Codex-based agent must deliver the readability capability; Codex manifests declare no dependencies, so the capability is named explicitly in install guidance ([D10](artifacts/decision-log.md#d10-codex-packaging-parity)) |

## Out of Scope

- Changing the content of the readability rule or the writing-voice profile. This feature relocates them unchanged.
- Changing how the readability-editor agent rewrites prose, the criteria in the readability standard, or the staged application model. The editor's rewrite behavior and the four-stage model (template, in-voice drafting, self-check, synthesis rewrite) are unchanged. What changes is where consuming skills source the standard: a `readability-guidance` skill invocation rather than a vendored file ([D4](artifacts/decision-log.md#d4-preserve-the-staged-model-guidance-plus-editor-for-synthesis), [D11](artifacts/decision-log.md#d11-source-the-standard-through-a-readability-guidance-skill)).
- Giving `han-planning`, `han-linear`, or `han-feedback` a dependency on `han-communication`. None of them hosts or triggers a skill that delegates to the readability capability, and the plan does not rely on transitive resolution that would pull it in anyway ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)).
- Adding the readability capability to skills that do not produce prose output. Only the current consumers change how they reach the standard.

## Deferred (YAGNI)

### A shared-reference mechanism that lets plugins read a dependency's files by path
- **Why deferred:** evidence-test failure. A cross-plugin file-reference mechanism would let a skill read the canonical rule directly by path, but no supported way to read a file inside a declared dependency plugin exists today, and building one is far outside this feature. Invoking the `readability-guidance` skill to surface the standard into context satisfies the same need with existing mechanics.
- **Reopen when:** the plugin runtime gains a supported way for a skill to reference a file inside a declared dependency plugin.
- **Source:** conversation context — the "how do consuming skills use the reference files" decision.

## Open Items

- **OI-3:** The `readability-guidance` mechanism rests on two behavioral properties that are feasible and precedented but not documented: that a skill invoked mid-workflow reliably surfaces its resources into the calling skill's context, and that the caller cleanly resumes its own drafting afterward. A prototype validates both before the mechanism is rolled out across all thirteen consumers ([D11](artifacts/decision-log.md#d11-source-the-standard-through-a-readability-guidance-skill)).
  - **Resolves when:** a `plan-implementation` spike wires one consumer skill to `readability-guidance` and confirms the guidance content lands in context and the skill resumes drafting against it.
  - **Blocks implementation:** Yes for the full rollout — the spike is the first implementation step and gates the rest; it does not block the move of the assets themselves.
- **OI-2:** Whether a Codex-based agent can dispatch the readability-editor **agent** is unverified — no existing Codex plugin manifest in the suite exposes an agent, only skills. Under the staged model, only the synthesis skills dispatch the editor agent, and they already did so before the move, so the property is pre-existing and the move only changes the namespace. The `readability-guidance` and `edit-for-readability` **skills** (skill invocations, which Codex manifests already expose) carry the standard for every consumer, so no skill newly depends on Codex agent-dispatch as a result of this feature.
  - **Resolves when:** a contributor verifies whether Codex dispatches agents, independent of this feature.
  - **Blocks implementation:** No — the guidance and skill invocations do not depend on it, and synthesis skills' editor dispatch predates this move.

The one prior open item — whether the plugin loader resolves dependencies transitively — is closed by the decision to declare `han-communication` as a direct dependency on every plugin that relies on it, so transitive resolution is never depended upon ([D5](artifacts/decision-log.md#d5-which-plugins-declare-the-dependency)).

## Summary

- **Outcome delivered:** One foundational plugin owns the readability capability and the single canonical writing standard; every consuming skill sources it cross-plugin through a `readability-guidance` skill and applies it in the same stages as before, with no duplicated reference copies.
- **Primary actors:** operators running prose-producing Han skills; contributors maintaining the suite.
- **Decisions settled by evidence:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 4 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** specification (junior-developer, information-architect, gap-analyzer — see [artifacts/team-findings.md](artifacts/team-findings.md)); iterative review (junior-developer, adversarial-validator, evidence-based-investigator, gap-analyzer — see [artifacts/review-findings.md](artifacts/review-findings.md) and the `## Review History` section below); design research (Claude Code docs review + in-repo evidence — see [artifacts/readability-guidance-research.md](artifacts/readability-guidance-research.md)).
- **Key adjustments from review and research:** the approach was revised from full delegation to a staged model — a new `readability-guidance` skill sources the standard cross-plugin for in-voice drafting and self-check, and the editor rewrite is retained only for synthesis skills (D3, D4, D11); the editor rewrite must preserve step order and non-prose structure for runbooks and HTML reports (D4); the documentation-and-tooling scope expanded to every stale pointer, the vendoring instructions in CONTRIBUTING/CLAUDE, dependency-graph narration across the docs, and manifest description fields (D7, D8); a whole Codex packaging surface was added (D10); and the direct-dependency rule was made a standing convention for future wrapping plugins (D7). — see [artifacts/review-findings.md](artifacts/review-findings.md)
- **Remaining open items:** 2

## Review History

- **Review mode:** team
- **Spec-aware mode:** engaged (behavioral spec; no technical-notes file — no load-bearing, non-discoverable mechanic qualified)
- **Rounds completed:** 3 (Large-size cap reached) — see [artifacts/review-iteration-history.md](artifacts/review-iteration-history.md).
- **Team composition:**
  - `han-core:junior-developer` (all rounds) — hidden assumptions, internal contradictions, standards conflicts.
  - `han-core:adversarial-validator` (all rounds) — falsification of the plan's evidence and "only way" claims.
  - `han-core:evidence-based-investigator` (R1) — verified the asset inventory, vendoring set, dependency graph, and host/trigger classification against the repo.
  - `han-core:gap-analyzer` (R1, R2) — checked the change-inventory against repo reality; surfaced the dependency-graph-narration and Codex surfaces.
- **Findings raised:** 24 (F12–F35), all resolved by evidence — see [artifacts/review-findings.md](artifacts/review-findings.md).
- **Assumptions challenged:** the no-cycle claim, full-delegation coherence, the exact host/trigger dependency set, and transitive-resolution reliance all held under independent falsification; the "every prose-producing skill" over-reach and the gap-analysis conditional-skip were corrected.
- **Consolidations made:** none — no redundant plan steps; the review expanded scope rather than merging it.
- **Ambiguities resolved:** the delegation scope ("consumer skills"), the two install surfaces (primary loader vs Codex), and the step-preservation guarantees were all made explicit.
- **Open items remaining:** 2 — OI-2 (Codex agent-dispatch capability unverified; does not block the move) and OI-3 (prototype the readability-guidance surfacing mechanism; gates the full rollout). Note: a post-review design revision (D11) replaced full delegation with the staged guidance-plus-editor model; see the design-research note and the follow-up review round in [artifacts/review-iteration-history.md](artifacts/review-iteration-history.md).

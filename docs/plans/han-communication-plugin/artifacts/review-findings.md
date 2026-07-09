# Review Findings: han-communication Plugin

<!--
Findings from han-planning:iterative-plan-review of feature-specification.md.
Spec-aware mode engaged. F# continues from the plan-a-feature team-findings.md
namespace (F1–F11) to keep IDs globally unique across this plan's artifacts, so this
file starts at F12. Iteration history lives in
[review-iteration-history.md](review-iteration-history.md); decisions in
[../artifacts/decision-log.md](decision-log.md); behavioral outcomes in
[../feature-specification.md](../feature-specification.md).
-->

## Major findings

### F12: The forced readability pass can reorder operationally-sequenced steps

- **Agent:** adversarial-validator
- **Category:** correctness
- **Finding:** Full delegation (D4) forces `runbook`, `issue-triage`, and `architectural-decision-record` — which ran no rewrite pass before — through the readability-editor. The editor's rubric explicitly authorizes reordering prose ("Reorder within a section when the detail arrives before the point it supports"), and its fidelity guarantees protect claims, quantities, named entities, and stated conditions, but never name **step sequence** as protected. A runbook's numbered incident-response steps are operationally ordered and safety-critical; `html-summary`'s output is a structured HTML report. So the uniform rewrite could reorder ordered steps or disturb structured output.
- **Evidence considered:** the editor rubric (reordering authorized; step order unprotected); `runbook` defines its procedure as ordered "numbered steps with exact commands"; `html-summary` emits HTML and today runs no rewrite pass by design; the editor already leaves code fences, diagrams, and rendered markup byte-for-byte unchanged.
- **Resolution:** Added an edge-case commitment: the delegated readability pass preserves the order of operationally-sequenced steps and the structure of non-prose output, rewriting only surrounding prose. The mechanism (extend the shared rubric to protect step order, or instruct the editor per-dispatch not to reorder numbered procedure steps) is deferred to `plan-implementation`; noted on D4.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Edge Cases and Failure Modes; Alternate Flows and States
- **Changed in tech-notes:** —

### F13: D7 misses dependency-graph narration in prose docs

- **Agent:** gap-analyzer
- **Category:** incomplete-scope
- **Finding:** Adding `han-communication` as a direct dependency of six plugins changes the dependency story told in plain prose across `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, `docs/concepts.md`, `docs/choosing-a-han-plugin.md`, and `docs/how-to/extend-han-with-plugin-dependencies.md`. None of this prose contains a readability-asset string, so D7's asset-pointer scope never catches it, yet all of it under-states the true dependency set after the move.
- **Evidence considered:** these docs narrate which plugin depends on which in sentences; two how-to docs teach "`han-core`... depends on nothing" as a worked example that D1 makes false; `docs/choosing-a-han-plugin.md` (the README-designated "which plugin do you need?" guide) has the densest per-plugin dependency narration and is named nowhere in D7.
- **Resolution:** D7 gained a fifth class — dependency-graph narration — covering these files, plus the requirement to add `han-communication` to the plugin catalog/guide and correct the "depends on nothing" worked examples.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** — (decision-log D7)
- **Changed in tech-notes:** —

### F14: D8 wrongly claims the marketplace entry is the only manifest change

- **Agent:** gap-analyzer
- **Category:** incomplete-scope
- **Finding:** Several `plugin.json` `description` fields (`han`, `han-coding`, `han-atlassian`), mirrored into `marketplace.json`, narrate the current dependency set in prose. D5/D6 change the `dependencies` arrays and D8 adds a marketplace entry, but none updates these description strings — directly contradicting D8's "the new marketplace entry is the only manifest change needed."
- **Evidence considered:** plugin.json descriptions for `han`, `han-coding`, `han-atlassian` narrate dependencies; `marketplace.json` mirrors those descriptions.
- **Resolution:** D8 corrected — manifest changes include the new marketplace entry, the new dependency edges, and the description-field updates (both in each `plugin.json` and mirrored in `marketplace.json`).
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Coordinations (decision-log D8)
- **Changed in tech-notes:** —

### F15: The Codex packaging surface is entirely unaddressed

- **Agent:** gap-analyzer, adversarial-validator, self-review
- **Category:** incomplete-scope
- **Finding:** The suite ships a parallel Codex packaging surface the plan never mentions: `.codex-plugin/plugin.json` manifests exist for eight plugins, a `.agents/plugins/marketplace.json` catalog exists alongside `.claude-plugin/marketplace.json`, and `README.md`'s Codex install section lists explicit `codex plugin add` commands per plugin. `han-communication` needs a `.codex-plugin/plugin.json`, an entry in the Codex marketplace catalog, and a line in the README Codex install section. The Codex `plugin.json` files carry no `dependencies` field, so Codex may not resolve dependencies at all — in which case the install guidance must name `han-communication` explicitly rather than relying on it being pulled in.
- **Evidence considered:** `find` shows `.codex-plugin/plugin.json` for han-atlassian, han-coding, han-core, han-feedback, han-github, han-planning, han-plugin-builder, han-reporting; `.agents/plugins/marketplace.json` exists; the Codex `plugin.json` schema has no `dependencies` key; `README.md` Codex section lists per-plugin `codex plugin add` commands with no `han-communication` line.
- **Resolution:** Added D10 (Codex packaging parity) and expanded D7/D8 to cover the Codex manifest, the Codex marketplace catalog, and the README Codex install section. Because Codex manifests declare no dependencies, the install guidance names `han-communication` explicitly.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Coordinations; Edge Cases and Failure Modes (decision-log D10, D7, D8)
- **Changed in tech-notes:** —

### F19: "Every prose-producing skill" over-reaches; "spec" is named but its producer is excluded

- **Agent:** junior-developer
- **Category:** internal-contradiction
- **Finding:** The spec swings between "every prose-producing skill" (Alternate Flows) and "only the current consumers" (Out of Scope). The Actors list names "spec" as covered output, but its producer (`plan-a-feature`, in `han-planning`) is deliberately excluded and declares no dependency. So the blanket over-reaches and "spec" points at an excluded skill.
- **Evidence considered:** `han-planning` skills apply no readability standard (verified: zero references); Out of Scope excludes `han-planning`.
- **Resolution:** Tightened "every prose-producing skill" to "every prose-producing **consumer** skill" and removed "spec" from the Actors prose-output list.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Actors and Triggers; Alternate Flows and States
- **Changed in tech-notes:** —

### F20: Full delegation removes gap-analysis's documented small-size editor skip

- **Agent:** junior-developer
- **Category:** internal-contradiction
- **Finding:** `gap-analysis` today dispatches the editor for consolidated reports only and explicitly skips it at small size / on the no-swarm path, relying there on drafting-time application plus the inline self-check — both of which read the rule file. The move breaks both, so under full delegation the small-size path must also gain the dispatch. The spec's uniform claim silently overrides a documented conditional skip.
- **Evidence considered:** `gap-analysis` SKILL.md dispatches editor for consolidated reports only, "skip this dispatch" at small size; both fallback stages read the rule file.
- **Resolution:** The uniform full-delegation decision (D4, user-chosen) answers the fork: the small-size path also delegates. Spec updated to state that size-conditional editor skips are removed — every prose-producing consumer skill delegates on every run.
- **Resolved by:** evidence (consequence of the prior user decision D4)
- **Raised in round:** R1
- **Changed in plan:** Alternate Flows and States
- **Changed in tech-notes:** —

### F21: No standing convention protects future wrapping plugins

- **Agent:** junior-developer
- **Category:** latent-trap
- **Finding:** The direct-dependency rule is stated only for today's six plugins. Because transitive resolution is deliberately not relied upon, a future plugin that wraps a delegating skill (as `han-atlassian` does) will silently fail at a delegation point unless its author knows to declare `han-communication` directly. D7's CONTRIBUTING/CLAUDE rewrite teaches the delegation mechanic but not this dependency-declaration obligation.
- **Evidence considered:** `han-atlassian` needed the dependency precisely because it wraps prose skills; the "broken install" edge case; transitive resolution not relied upon.
- **Resolution:** D7's CONTRIBUTING/CLAUDE rewrite scope now includes the standing rule: any plugin that hosts or triggers a delegating skill declares `han-communication` as a direct dependency. This matches the user's original framing ("any plugin that needs these bits must depend on han-communication").
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** — (decision-log D7)
- **Changed in tech-notes:** —

## Minor edits

- F16: D7 hardcodes "five" skill-internal template files; a sixth (`html-summary/references/writing-conventions.md`) hardcodes the same rule path. Made D7's template-file scope count-free. — adversarial-validator, evidence-based-investigator — decision-log D7
- F17: D7's outbound-link example list ("content-auditor and information-architect") omits the `adversarial-validator` link and a cross-plugin link into `han-plugin-builder` guidance in the same doc; reworded D7 to require an exhaustive outbound-link audit rather than a named list. — adversarial-validator — decision-log D7
- F18: `edit-for-readability`'s relative rule path resolves only if the `skills/{name}/SKILL.md` + `references/{file}.md` two-level layout is preserved in `han-communication`; added the constraint to D2. — adversarial-validator — decision-log D2
- F22: D3's evidence wording overstated the `${CLAUDE_PLUGIN_ROOT}` guidance (the cited line defines the variable but does not explicitly document own-plugin-only scoping); softened D3 to note the own-plugin-only scoping is an inference from consistent usage plus the absence of any supported cross-plugin read. — evidence-based-investigator — decision-log D3

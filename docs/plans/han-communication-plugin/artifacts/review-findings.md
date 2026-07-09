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

### F23: Preconditions overstates resolvability on the Codex surface

- **Agent:** junior-developer, adversarial-validator
- **Category:** internal-contradiction
- **Finding:** After D10 was added, Preconditions still asserted "direct dependency → always resolvable," but the Codex surface resolves no dependencies — there, declaring the dependency does not make the capability resolvable; only the operator following explicit install guidance does. Two install actors now carry two different resolvability guarantees, and Preconditions named only one.
- **Evidence considered:** D10 (Codex manifests carry no dependencies; install guidance names the plugin explicitly); the Codex edge-case row.
- **Resolution:** Split Preconditions into a primary-loader clause and a Codex clause, and named the Codex install actor in Actors.
- **Resolved by:** evidence
- **Raised in round:** R2
- **Changed in plan:** Actors and Triggers
- **Changed in tech-notes:** —

### F28: The preservation commitment was too narrow

- **Agent:** adversarial-validator
- **Category:** correctness
- **Finding:** D4's preservation commitment said only "never reorders numbered procedure steps." A runbook's `Resolve` steps are numbered **headings** (`### 1. …`), not a markdown list, and the editor's rubric rewrites heading text; the escalation list is priority-ranked; and the rubric's "split a dense paragraph" move could renumber or split steps and desync numeric cross-references (`Step N failed`) without ever "reordering." So a faithful rubric application could still corrupt operational usability while honoring the narrow commitment.
- **Evidence considered:** the runbook template (numbered-heading steps, keyed `Step N` failure blocks, ordered escalation); the editor rubric (rewrites heading text, authorizes splitting and reordering).
- **Resolution:** Widened the commitment to preserve each step's position and identity — no reorder, renumber, split, or merge; preserve heading-borne numerals; keep numeric cross-references consistent. Mechanism still deferred to `plan-implementation`.
- **Resolved by:** evidence
- **Raised in round:** R2
- **Changed in plan:** Edge Cases and Failure Modes; decision-log D4
- **Changed in tech-notes:** —

### F29: D10's "full Codex parity" overstates, and misses the opt-in install path

- **Agent:** adversarial-validator
- **Category:** correctness
- **Finding:** D10 claimed "full Codex parity," but (a) the README Codex section has a primary command block and a separate opt-in-plugin sentence; a `han-atlassian` Codex installer reads the opt-in sentence, where D10's single "install line" would not naturally land, so that installer gets no signal to install `han-communication`; and (b) no `.codex-plugin/plugin.json` in the repo exposes an `agents` field, so whether Codex can dispatch the readability-editor agent at all is unverified — "full parity" claims more than is demonstrable.
- **Evidence considered:** README Codex section (two install tiers); all eight `.codex-plugin/plugin.json` files carry `skills` but no `agents` field.
- **Resolution:** D10 now requires naming `han-communication` in both Codex install paths, qualifies "parity" to file-and-manifest parity, and records the unverified Codex agent-dispatch capability as OI-2 (pre-existing, non-blocking, not introduced by this feature).
- **Resolved by:** evidence
- **Raised in round:** R2
- **Changed in plan:** Edge Cases and Failure Modes; Open Items; decision-log D10
- **Changed in tech-notes:** —

### F33: Preservation commitment misses order-significant non-numbered lists

- **Agent:** adversarial-validator
- **Category:** correctness
- **Finding:** The widened D4 commitment protected numbered steps, heading numerals, and numeric cross-references, but the runbook template also carries a "Likely cause — ordered by likelihood" bulleted list that the Resolve steps branch on. Its order is operationally load-bearing but it is neither numbered nor non-prose, so the editor's reordering authorization could still disturb it.
- **Evidence considered:** runbook template ("ordered by likelihood… The Resolve section will branch on them"); editor rubric authorizes reordering within a section.
- **Resolution:** Extended the commitment to preserve the order of any list whose sequence is operationally load-bearing, even when not numbered.
- **Resolved by:** evidence
- **Raised in round:** R3
- **Changed in plan:** Edge Cases and Failure Modes; decision-log D4
- **Changed in tech-notes:** —

### F34: OI-2 understated the delegation blast-radius on Codex

- **Agent:** adversarial-validator
- **Category:** correctness
- **Finding:** OI-2's "pre-existing, not introduced by this feature" held only for the ~9 skills that already dispatched the editor. Full delegation (D4) makes four more skills delegate for the first time, so on Codex the affected set grows from ~9 to ~13; for those four, any dependence on Codex agent-dispatch would be newly introduced, not pre-existing.
- **Evidence considered:** D4 (four skills gain a first-ever dispatch); the spec's "invokes the skill, or dispatches the agent" ambiguity.
- **Resolution:** OI-2 now states the ~9→~13 expansion and routes the four newly-delegating skills through the edit-for-readability skill wrapper (which Codex manifests already expose), so "not introduced by this feature" stays true; the final mechanism is confirmed in `plan-implementation`.
- **Resolved by:** evidence
- **Raised in round:** R3
- **Changed in plan:** Open Items
- **Changed in tech-notes:** —

## Minor edits

- F16: D7 hardcodes "five" skill-internal template files; a sixth (`html-summary/references/writing-conventions.md`) hardcodes the same rule path. Made D7's template-file scope count-free. — adversarial-validator, evidence-based-investigator — decision-log D7
- F17: D7's outbound-link example list ("content-auditor and information-architect") omits the `adversarial-validator` link and a cross-plugin link into `han-plugin-builder` guidance in the same doc; reworded D7 to require an exhaustive outbound-link audit rather than a named list. — adversarial-validator — decision-log D7
- F18: `edit-for-readability`'s relative rule path resolves only if the `skills/{name}/SKILL.md` + `references/{file}.md` two-level layout is preserved in `han-communication`; added the constraint to D2. — adversarial-validator — decision-log D2
- F22: D3's evidence wording overstated the `${CLAUDE_PLUGIN_ROOT}` guidance (the cited line defines the variable but does not explicitly document own-plugin-only scoping); softened D3 to note the own-plugin-only scoping is an inference from consistent usage plus the absence of any supported cross-plugin read. — evidence-based-investigator — decision-log D3
- F24: The Summary's "Key adjustments from review" and "Sub-agents consulted" bullets were not reconciled with the round-1 additions (Codex, dependency-graph narration, the review's own agents); rewrote both to reflect the iterative review. — junior-developer, adversarial-validator — Summary
- F25: `docs/skills/README.md` (the canonical skills index) narrates a per-plugin "Depends on `han-core`…" line for four plugins that gain the new dependency; added to D7's dependency-narration coverage. — adversarial-validator, gap-analyzer — decision-log D7
- F26: `han/README.md` (the meta-plugin's own README) narrates `han`'s dependency set and was outside D7's named list; folded into D7's comprehensive-grep coverage. — gap-analyzer — decision-log D7
- F27: `han-coding/skills/investigate/references/template.md` hardcodes the rule as a plugin-root path (`han-coding/references/readability-rule.md`), a form the earlier dot-relative inventory missed; folded into D7's comprehensive-grep coverage. — gap-analyzer — decision-log D7
- F30: `docs/how-to/build-a-plugin-that-depends-on-han.md` was raised in the round-1 gap-analyzer scratch (GAP-106) but neither promoted nor recorded as rejected; folded into D7's comprehensive-grep coverage so the scratch-to-findings pipeline has no silent drop. — adversarial-validator — decision-log D7
- F31: CONTRIBUTING.md states "`han-core` depends on nothing" as a *rule* (not just narration) that D1 falsifies; D7 now requires re-deriving that rule, not editing the string. — adversarial-validator — decision-log D7
- F32: `docs/readability.md` restates the abolished vendoring model, the pre-delegation staged-application model, and a "self-check only" table D4 falsifies; D7 now flags it as a rewrite-depth case with a general rule that any caught file restating the abolished model is rewritten, not repointed. — adversarial-validator — decision-log D7
- F35: The plan was missing its mandated `## Review History` section (iterative-plan-review Step 6), and the Summary forward-referenced it; added the section and reconciled the reference. — adversarial-validator — Review History

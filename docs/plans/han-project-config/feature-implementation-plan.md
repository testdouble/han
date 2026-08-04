# Feature Implementation Plan: Project-Local Han Configuration

This plan adds one optional file, `.han/config.md`, that a consuming project can carry to adjust how Han skills behave in that project. It controls two things: where skills write their markdown outputs, and which extra agents dispatching skills consider.

The work is entirely prompt-text edits across the plugin suite: SKILL.md files, one new shared reference file vendored per plugin, the project-discovery skill, and documentation. There is no runtime, no build, and no automated test suite, so verification is a grep completeness check plus manual spot-runs.

The one thing to know first: the read of the config file must land inline in every participating SKILL.md. A Claude Code probe only runs where it is written ([D-1](artifacts/implementation-decision-log.md#d-1-probe-line-stays-inline-in-every-skillmd-only-the-interpretation-prose-is-factored)).

## Outcome

When this plan is executed, an engineer on a consuming project can write their Han overrides once, in a single `.han/config.md` file. Every Han skill then honors those overrides on every run in that project. A project without the file behaves exactly as the suite does today: no note, no change.

Two overrides ship. The first is a base directory: skills write their markdown deliverables under it, while keeping their own folder structure beneath it. The second is a global list of extra agents: dispatching skills add these to their candidate pool.

A bad config file can never fail a skill run. The worst it does is get ignored, with a one-line note.

## User Stories

- **US-1:** As an engineer on a consuming project, I want to set one base directory for Han's markdown outputs, so that every skill writes its deliverables where my project keeps them instead of the skill defaults.
- **US-2:** As an engineer on a consuming project, I want to name extra agents my project defines, so that Han's dispatching skills consider them alongside their built-in rosters.
- **US-3:** As an engineer on a consuming project, I want a broken or partial config file to degrade quietly to defaults with a one-line note, so that a typo never blocks a review or a plan.
- **US-4:** As an engineer who has never heard of `.han/config.md`, I want project-discovery to surface it in CLAUDE.md, so that I can see the file exists and is in effect.
- **US-5:** As a Han contributor, I want one canonical source for the config schema and its resolution rules, so that 39 skills interpret the same file identically and I have one correct place to author from.

## Constraints and Boundaries

- **Driving constraint:** The feature promises that *every* Han skill honors the config. That uniform-participation promise (spec D4) is what forces the suite-wide edit and the single canonical contract; a partial rollout would make the feature harder to explain and trust.
- **Out of scope:** Han cannot ship or seed the file; the consuming project creates and owns it (spec D1, confirmed by the OI-1 live check). The config shapes skill behavior only; it is not a security boundary, does not define new agents, and does not change any skill's selection logic or caps.
- **Enumerate, never count:** The plan names participating skills by globbing `*/skills/*/SKILL.md` at execution time and never hardcodes a total; spec D4's stated 26/15 counts are stale against today's tree ([D-8](artifacts/implementation-decision-log.md#d-8-enumerate-participating-skills-at-execution-time-never-hardcode-totals)).
- **Authoring standard:** Every SKILL.md and agent edit follows the han-plugin-builder guidance, as the repo CLAUDE.md mandates ([D-12](artifacts/implementation-decision-log.md#trivial-decisions)).

## Implementation Approach

The feature splits cleanly into two layers.

The first layer is the read: one line, inline in each participating skill. It must live inline because Claude Code runs a `!`-backtick probe in place at prompt-assembly time, and an included file could never execute it ([D-1](artifacts/implementation-decision-log.md#d-1-probe-line-stays-inline-in-every-skillmd-only-the-interpretation-prose-is-factored)).

The second layer is interpretation: what the read config means (precedence, degradation, the note rule, containment, the agent pool-join). That interpretation is shared prose that lives in one canonical file. This read-inline, interpret-from-a-reference shape is the same pattern the suite already uses.

### Where the shared contract lives

One canonical rule file holds the interpretation contract. It is vendored byte-identical into every plugin that carries a skill ([D-2](artifacts/implementation-decision-log.md#d-2-one-canonical-config-resolution-rule-file-in-han-core-vendored-byte-identical-per-plugin)).

Vendoring needs no plugin manifest change. Sharing the contract instead through cross-plugin skill invocation would force new dependency edges onto han-feedback, han-linear, and han-plugin-builder, three plugins designed to depend on nothing. The file is kept short and mechanical so its twelve copies stay eyeball-diffable without sync tooling ([D-3](artifacts/implementation-decision-log.md#d-3-keep-the-vendored-rule-file-short-and-mechanical-defer-sync-tooling)).

- Canonical file: `han-core/references/config-rule.md`, vendored into the `references/` folder of each of the twelve skill-carrying plugins.

### The config schema tokens

The tokens spec T1 left open are pinned here so every skill and the canonical file use them verbatim ([D-4](artifacts/implementation-decision-log.md#d-4-pin-the-config-schema-tokens)). These are decision-bearing values, not incidental detail.

- Output base: frontmatter key `output-directory`, value is a relative path.
- Extra agents: section heading `## Extra Agents`, one agent per list line.
- Agent-name matching: qualified `plugin:agent` or bare name, matched case-insensitively against agents available in the session; an unresolved entry is skipped with the spec D5 one-line note.

### Keeping the output base inside the project

The containment guard is expressed with no repo-root or git concept, because discovery is pinned to the working directory and git is optional ([D-5](artifacts/implementation-decision-log.md#d-5-output-directory-containment-test)).

The value must be a relative path. An absolute path, a drive prefix, or a `..` traversal above the working directory is refused, and the skill falls back to its default location with a one-line note. This guards against accidents such as a pasted absolute path, matching spec D14's intent. It is not a guard against an adversary.

### Extra agents joining the candidate pool

The extra-agents join is a bespoke edit per dispatching skill, not a uniform pasted block, because each skill's roster table is shaped differently ([D-7](artifacts/implementation-decision-log.md#d-7-three-work-passes-the-fifteen-no-block-skills-get-a-minimal-config-only-block)). Each dispatching skill splices the config's extra agents into its own candidate pool under its own existing caps, reusing its own cap vocabulary. The roster tables are not unified; that is unrelated surgery with no evidence behind it.

### Wrapper skills and wrapped temporary files

A wrapper that invokes a wrapped skill "to a temporary file" passes an explicit output path. That path outranks the configured base under spec D6, so the temporary file stays where the wrapper expects ([D-6](artifacts/implementation-decision-log.md#d-6-wrapper-skills-pass-explicit-output-paths-so-spec-d6-keeps-temp-files-in-place)). The six han-atlassian wrapper skills' briefs pass explicit paths when they invoke a wrapped skill.

### Discoverability through project-discovery

The project-discovery skill gains a new step between its existing write step and verification, reusing the consent and dedup pattern it already carries ([D-11](artifacts/implementation-decision-log.md#d-11-project-discovery-gains-a-pointer-step-reusing-its-consent-and-dedup-pattern)). It offers to add a one-line CLAUDE.md pointer when the config exists, and offers to remove a stale pointer when the file is gone, both only with user consent. No new skill or reference file is created.

- Touch point: `han-core/skills/project-discovery/SKILL.md`, plus its long-form doc.

### Documentation surfaces

One canonical operator doc is the single home of the annotated schema example and the plain-language contract ([D-10](artifacts/implementation-decision-log.md#d-10-one-canonical-operator-doc-at-docsconfigurationmd-plus-scent-links)). This is because Han cannot seed the file itself; without one correct source, an engineer will guess at the frontmatter key. Every other surface carries a scent link only, never a second copy of the example. The wide doc sweep is deliberately avoided.

- New doc: `docs/configuration.md` (single canonical home).
- Scent links: `docs/concepts.md` (subsection plus a "Where to go next" bullet), quickstart Path D (one bullet), repo CLAUDE.md registration.

## Work Units and Sequencing

Work units are sequenced so the canonical contract and tokens land before anything copies them, and the docs example lands only after the tokens are pinned.

| #   | Work Unit | Story | Delivers | Depends On | Verification |
| --- | --------- | ----- | -------- | ---------- | ------------ |
| 0   | OI-1 live-install check (gating) | US-5 | Confirmation that a plugin cannot seed a per-repo config, so `.han/config.md` in the consuming project stands | — | Check ran during R1; verdict CONFIRMED, spec D1 stands |
| 1   | Author the canonical rule file and pin the schema tokens | US-1, US-2, US-3, US-5 | One `config-rule.md` carrying the tokens, precedence, degradation, note rule, containment, and pool-join sentence ([D-2](artifacts/implementation-decision-log.md#d-2-one-canonical-config-resolution-rule-file-in-han-core-vendored-byte-identical-per-plugin), [D-4](artifacts/implementation-decision-log.md#d-4-pin-the-config-schema-tokens), [D-5](artifacts/implementation-decision-log.md#d-5-output-directory-containment-test)) | 0 | Tokens fixed; file reads as a short mechanical contract |
| 2   | Vendor the rule file byte-identical into each skill-carrying plugin | US-5 | Twelve `references/config-rule.md` copies identical to the canonical file ([D-2](artifacts/implementation-decision-log.md#d-2-one-canonical-config-resolution-rule-file-in-han-core-vendored-byte-identical-per-plugin), [D-3](artifacts/implementation-decision-log.md#d-3-keep-the-vendored-rule-file-short-and-mechanical-defer-sync-tooling)) | 1 | Byte-identical check across copies |
| 3   | Add the probe bullet and pointer to skills that already carry a `## Project Context` block | US-1, US-2, US-3 | Each existing-block skill reads the config and points to the rule file ([D-1](artifacts/implementation-decision-log.md#d-1-probe-line-stays-inline-in-every-skillmd-only-the-interpretation-prose-is-factored), [D-7](artifacts/implementation-decision-log.md#d-7-three-work-passes-the-fifteen-no-block-skills-get-a-minimal-config-only-block)) | 2 | Grep: probe line present in each enumerated file |
| 4   | Add a minimal config-only block to skills without one | US-1, US-2, US-3 | Each no-block skill reads the config through a minimal block, not the full discovery set ([D-7](artifacts/implementation-decision-log.md#d-7-three-work-passes-the-fifteen-no-block-skills-get-a-minimal-config-only-block)) | 2 | Grep: probe line present; no added git/CLAUDE.md probes |
| 5   | Bespoke extra-agents pool-join into each dispatching skill | US-2 | Each dispatching skill adds config extra agents to its pool under its own caps ([D-7](artifacts/implementation-decision-log.md#d-7-three-work-passes-the-fifteen-no-block-skills-get-a-minimal-config-only-block)) | 2 | Spot-run a dispatcher against a config naming an extra agent |
| 6   | Pass explicit paths from the han-atlassian wrappers | US-1 | Wrapped temporary files stay in place under spec D6 ([D-6](artifacts/implementation-decision-log.md#d-6-wrapper-skills-pass-explicit-output-paths-so-spec-d6-keeps-temp-files-in-place)) | 2 | Spot-run a wrapper; temp file lands where the wrapper expects |
| 7   | Add the project-discovery pointer step and update its long-form doc | US-4 | project-discovery offers to add and remove the CLAUDE.md pointer with consent ([D-11](artifacts/implementation-decision-log.md#d-11-project-discovery-gains-a-pointer-step-reusing-its-consent-and-dedup-pattern)) | 2 | Spot-run project-discovery with the config present and absent |
| 8   | Author `docs/configuration.md` and add the scent links | US-5 | One canonical doc with the annotated example, plus concepts.md, quickstart, and CLAUDE.md links ([D-10](artifacts/implementation-decision-log.md#d-10-one-canonical-operator-doc-at-docsconfigurationmd-plus-scent-links), [D-13](artifacts/implementation-decision-log.md#trivial-decisions)) | 1 | Example matches the pinned tokens; one canonical copy only |
| 9   | Run the completeness check and representative spot-runs | US-1, US-2, US-3, US-4 | Confirmation the edit is complete and behaves in each category ([D-9](artifacts/implementation-decision-log.md#d-9-definition-of-done-is-a-grep-completeness-check-plus-representative-spot-runs)) | 3, 4, 5, 6, 7 | See Definition of Done |

## Definition of Done

- [ ] Every participating SKILL.md, enumerated by globbing `*/skills/*/SKILL.md`, carries the `.han/config.md` probe line and the pointer to the canonical rule file ([D-8](artifacts/implementation-decision-log.md#d-8-enumerate-participating-skills-at-execution-time-never-hardcode-totals), [D-9](artifacts/implementation-decision-log.md#d-9-definition-of-done-is-a-grep-completeness-check-plus-representative-spot-runs)).
- [ ] Every skill-carrying plugin has a `references/config-rule.md` byte-identical to the canonical `han-core/references/config-rule.md` ([D-2](artifacts/implementation-decision-log.md#d-2-one-canonical-config-resolution-rule-file-in-han-core-vendored-byte-identical-per-plugin), [D-9](artifacts/implementation-decision-log.md#d-9-definition-of-done-is-a-grep-completeness-check-plus-representative-spot-runs)).
- [ ] A deliverable-writing skill writes under a configured `output-directory` while keeping its own folder structure, and refuses an absolute or escaping path with a one-line note, falling back to its default ([D-4](artifacts/implementation-decision-log.md#d-4-pin-the-config-schema-tokens), [D-5](artifacts/implementation-decision-log.md#d-5-output-directory-containment-test)).
- [ ] A dispatching skill adds a config-named extra agent to its pool under its caps, and skips an unresolvable entry with a one-line note ([D-7](artifacts/implementation-decision-log.md#d-7-three-work-passes-the-fifteen-no-block-skills-get-a-minimal-config-only-block)).
- [ ] A skill run with no config, or an empty config, behaves exactly as today with no note (spec D11).
- [ ] project-discovery offers to add the pointer when the config exists and to remove it when the file is gone, both consent-gated ([D-11](artifacts/implementation-decision-log.md#d-11-project-discovery-gains-a-pointer-step-reusing-its-consent-and-dedup-pattern)).
- [ ] `docs/configuration.md` holds the only annotated schema example, matching the pinned tokens, with scent links from concepts.md, quickstart Path D, and CLAUDE.md ([D-10](artifacts/implementation-decision-log.md#d-10-one-canonical-operator-doc-at-docsconfigurationmd-plus-scent-links)).

## Testing Strategy

There is no automated test harness for skills in this repo, so verification is a structural check plus manual runs ([D-9](artifacts/implementation-decision-log.md#d-9-definition-of-done-is-a-grep-completeness-check-plus-representative-spot-runs)).

- **Observable behaviors to test:** a deliverable-writer honoring the output base and refusing an escaping path; a dispatcher adding and skipping extra agents; a wrapper keeping its temporary file in place; a config-irrelevant skill ignoring settings silently; project-discovery adding and removing the pointer.
- **Edge cases requiring coverage:** each representative skill run against a present config, an absent config, and a broken config (malformed header, blank value, unresolvable agent name).
- **Test doubles posture and levels:** none; verification is grep for structural completeness plus manual skill runs, since the deliverable is prompt text with no runtime.

## Risks and Assumptions

### Risks

| ID  | Risk | Impact | Mitigation | Owner |
| --- | ---- | ------ | ---------- | ----- |
| R1  | The twelve vendored copies of `config-rule.md` drift apart over time | A cross-project config file resolves differently depending on which plugin's skill reads it | Keep the file short and mechanical so an eyeball diff during any edit is cheap; add tooling only if drift is observed ([D-3](artifacts/implementation-decision-log.md#d-3-keep-the-vendored-rule-file-short-and-mechanical-defer-sync-tooling)) | Han contributor |
| R2  | The one-line-note rule (spec D9) is a model-judgment boundary that skills may apply inconsistently | Some skills note a broken override, others stay silent, confusing the engineer | State the note rule once in the canonical file, not paraphrased per skill; verify with the broken-config spot-runs ([D-2](artifacts/implementation-decision-log.md#d-2-one-canonical-config-resolution-rule-file-in-han-core-vendored-byte-identical-per-plugin)) | Han contributor |
| R3  | SKILL.md files are high-churn suite-wide; concurrent edits may collide with this 39-file pass | Merge friction or a skill missing the probe line after a rebase | Land the passes in sequence, run the grep completeness check at the end to catch any file that lost the bullet ([D-9](artifacts/implementation-decision-log.md#d-9-definition-of-done-is-a-grep-completeness-check-plus-representative-spot-runs)) | Han contributor |

### Assumptions

| ID  | Assumption | What Changes If Wrong | Status |
| --- | ---------- | --------------------- | ------ |
| A1  | A plugin cannot ship or seed a per-repo config value, so the consuming project must carry `.han/config.md` (spec D1) | The feature's foundational decision reopens; the config could live plugin-side instead | Verified (OI-1 live check, CONFIRMED during R1) |
| A2  | The precedence order (config beats CLAUDE.md, spec D6) matches what engineers expect | A surprised-user report reopens spec D6's ordering | Runtime-only (spec OI-2, post-ship validation) |
| A3  | Skills apply the pinned tokens and containment rule identically from one shared file | Cross-project config files resolve inconsistently | Runtime-only (proven by the representative spot-runs) |

## Deferred (YAGNI)

### Cross-plugin skill-invocation sharing of the config rules

- **Why deferred:** Simpler-version replacement. Sharing the contract through skill invocation (the readability pattern) would add dependency edges to han-feedback, han-linear, and han-plugin-builder, which are designed to depend on nothing. Byte-identical vendored copies of one canonical file satisfy the same need with no manifest change.
- **Reopen when:** A future feature needs a dependency-free plugin to consume the contract through skill invocation rather than a vendored copy.
- **Source:** R1 structural-analyst S2/S3; the larger version is the rejected alternative on [D-2](artifacts/implementation-decision-log.md#d-2-one-canonical-config-resolution-rule-file-in-han-core-vendored-byte-identical-per-plugin).

### Automated sync or diff tooling for the vendored copies

- **Why deferred:** Evidence test. No drift has been observed, and the repo has no tool that diffs vendored copies between its own plugins. A short mechanical file is the simpler mitigation.
- **Reopen when:** Drift is observed between vendored copies after landing.
- **Source:** R1 structural-analyst S3; rejected alternative on [D-3](artifacts/implementation-decision-log.md#d-3-keep-the-vendored-rule-file-short-and-mechanical-defer-sync-tooling).

### A full discovery block for the fifteen no-block skills

- **Why deferred:** Evidence test. Those skills have no spec D6 discovery tier to consult a CLAUDE.md or git probe against; a full block adds probes with no named need. A minimal config-only block is the simpler version.
- **Reopen when:** One of those skills gains work that needs the full discovery chain.
- **Source:** R1 structural-analyst S5; rejected alternative on [D-7](artifacts/implementation-decision-log.md#d-7-three-work-passes-the-fifteen-no-block-skills-get-a-minimal-config-only-block).

### Unifying the dispatching skills' roster tables

- **Why deferred:** Evidence test. Each roster table is shaped differently, and unifying them is unrelated, larger surgery with no evidence behind it.
- **Reopen when:** A future feature needs one canonical roster-table format across dispatching skills.
- **Source:** R1 structural-analyst S6; rejected alternative on [D-7](artifacts/implementation-decision-log.md#d-7-three-work-passes-the-fifteen-no-block-skills-get-a-minimal-config-only-block).

### New CI, test runner, or fixture repo for verification

- **Why deferred:** Evidence test. No config-drift regression has been observed; a grep completeness check plus representative spot-runs verifies the edit today.
- **Reopen when:** A config-drift regression is observed after landing.
- **Source:** R1 junior-developer JD-006; rejected alternative on [D-9](artifacts/implementation-decision-log.md#d-9-definition-of-done-is-a-grep-completeness-check-plus-representative-spot-runs).

### A blanket config note in every participating skill's long-form doc

- **Why deferred:** Evidence test. Per-skill docs do not re-document a cross-suite mechanic, and no named task needs the same sentence in 39 places.
- **Reopen when:** A specific skill whose config interaction is genuinely non-obvious is found.
- **Source:** R1 information-architect IA-006; rejected alternative on [D-10](artifacts/implementation-decision-log.md#d-10-one-canonical-operator-doc-at-docsconfigurationmd-plus-scent-links).

### Updates to choosing-a-han-plugin.md, workflows.md, and the four mechanic docs

- **Why deferred:** Evidence test. The config is not a plugin and adds no chain step, so these surfaces are orthogonal.
- **Reopen when:** The config becomes install-gated (choosing-a-han-plugin.md), or a workflow's documented output path becomes misleading (workflows.md).
- **Source:** R1 information-architect IA-009; rejected alternative on [D-10](artifacts/implementation-decision-log.md#d-10-one-canonical-operator-doc-at-docsconfigurationmd-plus-scent-links).

## Open Items

- **OI-2 (inherited from spec):** The precedence order (config beats CLAUDE.md, spec D6) is a design proposal to validate in use, not a derived fact. The first few real projects using the file should confirm the direction matches engineer expectations.
  - **Resolves when:** Feedback from real use confirms the order, or a surprised-user report triggers revisiting spec D6.
  - **Blocks implementation:** No. The order is settled for v1; this tracks post-ship validation only.

## Sources and Plan Records

- **Feature specification:** [feature-specification.md](feature-specification.md)
- **Specification companions:** [decision log](artifacts/decision-log.md), [team findings](artifacts/team-findings.md), [technical notes](artifacts/feature-technical-notes.md)
- **Specification decisions inherited / open items to respect:** spec D1-D15 (notably D4 uniform participation, D5 pool-join, D6 precedence, D9 degradation, D10 pointer, D14 containment, D15 working-directory) / OI-2
- **Decision rationale and rejected alternatives:** [artifacts/implementation-decision-log.md](artifacts/implementation-decision-log.md)
- **Team composition and round-by-round history:** [artifacts/implementation-iteration-history.md](artifacts/implementation-iteration-history.md)

## Recommendation

Ship as planned. Every plan-level open question was resolved by evidence across two rounds. OI-1 closed as confirmed during planning, so spec D1 stands. The one remaining open item, OI-2, is post-ship validation only; it does not block. The post-ship owner is the Han contributor maintaining the suite.

# Han Release Notes

## v2.2.0

The `/gap-analysis` swarm flips from opt-in to opt-out, `junior-developer` is promoted to a required swarm role at every size to run an explicit actor-perspective sweep, and `project-manager` joins the swarm at medium and large to consolidate Section 4 of the report.

### Default-on swarm

The validator-and-augmenter swarm now runs by default at every size. Reply `no swarm` to opt out and fall back to the lightweight gap-analyzer-only pass; reply `lightweight` to drop to the minimum two required roles without domain specialists.

- **Small** *(default)*: 2–3 agents — `adversarial-validator` and `junior-developer` always, plus `evidence-based-investigator` when the current state is concrete. No PM at small.
- **Medium**: 4–6 agents — the required three plus 1–2 domain specialists plus `project-manager` for Section 4 synthesis.
- **Large**: 6–8 agents — the required three plus 2–4 domain specialists plus `project-manager`.

### Actor-perspective sweep

`junior-developer` is now a required swarm member at every size. Its job in `/gap-analysis` is to enumerate every actor the desired state addresses or implies (human end users and sub-roles, API callers, AI agents, integration partners, batch processes, internal services), check whether each gap holds for every actor type, and surface gaps the analyzer missed because it only considered one actor.

### Conditional second round

When the first-round swarm surfaces ≥ 3 `proposed_new_gap` entries (Trigger A) or contradictions on ≥ 20% of the analyzer's original gaps (Trigger B), the skill runs one additional `gap-analyzer` pass with the new actor context and merges the delta into the source file. Bounded to one extra round.

### Section 4 default-on; augmentations inline into Section 2

Section 4 (Swarm Findings) is now rendered by default and is omitted only when the user passed `no swarm`. Swarm augmentations (added risks, secondary effects, refined framing, actor-perspective notes from `junior-developer`) inline into Section 2 entries as `Additional context (swarm):` lines so they land where the gap lives, while Section 4 retains the audit-trail listing.

### Documentation

- [`docs/skills/gap-analysis.md`](./docs/skills/gap-analysis.md) — updated TL;DR, key concepts, sizing table, cost-and-latency model, "In more detail" section, and Sources / Related Documentation to reflect the opt-out posture.
- Cross-references updated in [`docs/concepts.md`](./docs/concepts.md), [`docs/quickstart.md`](./docs/quickstart.md), [`docs/sizing.md`](./docs/sizing.md), [`docs/skills/README.md`](./docs/skills/README.md), and the agent docs for `adversarial-validator`, `evidence-based-investigator`, `junior-developer`, `project-manager`, and `gap-analyzer`.

## v2.0.1

The "this codebase is a startup" framing is removed from the YAGNI rule and every skill and agent that inherits it. The evidence-based YAGNI mechanic is unchanged — only the rationale prose is reframed so the rule reads as project-agnostic guidance rather than advice contingent on company stage.

Affected files: `docs/yagni.md`, `references/yagni-rule.md`, the `project-manager` and `junior-developer` agents, and the `iterative-plan-review`, `plan-a-feature`, `plan-a-phased-build`, `plan-implementation`, and `test-planning` skills. Every removal preserves the surrounding "every X is ongoing maintenance and a pattern future agents will copy" sentence that does the actual work.

## v2.0.0

Two skills are renamed and a YAGNI (You Aren't Gonna Need It) discipline is woven through the planning, review, and architecture skills and agents.

### Breaking changes

Two skills have been renamed. Update any scripts, slash-command invocations, agent prompts, or documentation that referenced the old names.

| Old name | New name |
| --- | --- |
| `han:gh-pr-description` | `han:update-pr-description` |
| `han:create-adr` | `han:architectural-decision-record` |

The skill behavior is unchanged — only the names and their on-disk directories. Old names will not resolve; the slash commands are now `/update-pr-description` and `/architectural-decision-record`.

### YAGNI evidence requirements across planning, review, and architecture

Every place where the plugin proposes new code, new tests, new infrastructure, or new abstractions now requires concrete evidence that the work is needed today — not speculation about the future. Added to:

- Planning skills: `/plan-a-feature`, `/plan-implementation`, `/plan-a-phased-build`, `/iterative-plan-review`
- Review and standards: `/code-review` (advisory-only), `/coding-standard`, `/test-planning`, `/architectural-decision-record` (forcing-function requirement)
- Agents: `project-manager`, `junior-developer`, `software-architect`, `system-architect`, `test-engineer`, `edge-case-explorer`, `data-engineer`, `devops-engineer`

Each skill or agent applies the rule to its own surface area — speculative tests, premature operational machinery, speculative data machinery, speculative edge cases, abstractions without a forcing function, and so on. Plans now include a **Deferred** section to capture explicitly-rejected speculative work.

## v1.7.0

Filename naming for `/coding-standard` and `/architectural-decision-record` outputs changes from a timestamp prefix to a discovered, hierarchical prefix so related documents sort together.

### Hierarchical filenames for coding standards and ADRs

Both skills replace the `{YYYYMMDDHHmmss}-{name}.md` pattern with `{top-level}[-{second-level}]-{name}.md`.

- The hierarchy prefix is one or two levels (e.g., `svelte-stores-state-shape.md`, `auth-tokens-rotation.md`).
- The taxonomy is **discovered at runtime**, not hardcoded — both skills parse existing standards/ADRs in the project's directory and read CLAUDE.md / project-discovery.md to identify the project's languages, frameworks, runtimes, subsystems, and bounded contexts as candidate top-level prefixes.
- When existing prefixes fit, they are reused; new top-levels are introduced only when nothing existing applies.
- When the discovered taxonomy offers more than one reasonable placement, the skill asks the user before writing.
- The unused `Bash(date *)` permission has been dropped from both skills' `allowed-tools`.

### Documentation

- [`docs/skills/coding-standard.md`](./docs/skills/coding-standard.md) and [`docs/skills/architectural-decision-record.md`](./docs/skills/architectural-decision-record.md) updated to describe the hierarchical filename pattern, the discovery step, and the new shape of the produced filename.

## v1.6.1

Sizing becomes a foundational dispatch lever across the swarming skills.

### Size-aware code-review agent dispatch

`/code-review` now classifies the change as small / medium / large before dispatching agents, defaults to small, and scales the roster proportionally.

- Two agents always run on every review: `junior-developer` and `adversarial-security-analyst`.
- The rest of the roster — `test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `devops-engineer` — is dispatched conditionally based on what the changed files actually touch.
- Every agent brief carries a calibration directive that requires findings to be either introduced/worsened by the change or critical irrespective of who introduced it. Severity scales with size.
- `data-engineer` and `devops-engineer` join the conditional roster with finding-classification rubrics for data-side and operational concerns.

### Cross-skill `$size` argument

All five sizing-aware skills — `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation` — now declare a positional `size` argument in their frontmatter per the Claude Code skills spec.

- Pass `small`, `medium`, or `large` as the first positional argument to override the auto-classification: `/code-review medium`, `/plan-a-feature large "describe the feature"`, etc.
- When `$size` is non-empty, the skill uses that value as the size and scales its team / swarm caps and finding calibration accordingly.
- Without `$size`, the skill auto-classifies from concrete signals (file count, subsystems touched, security/data/integration surface).

### Default to small across all sizing-aware skills

Every sizing-aware skill now starts the classification at small and only escalates when concrete signals clearly require it. Borderline signals stay at the smaller band — fewer agents producing higher-signal findings is the goal.

### New sizing reference doc

[`docs/sizing.md`](./docs/sizing.md) is the canonical cross-skill sizing reference.

- The three bands (small / medium / large) and what they mean.
- The auto-classification process and the `$size` override.
- A per-skill at-a-glance table covering all five sizing-aware skills.
- Cross-references in every sizing-aware skill's long-form doc back to the reference and vice versa.
- Discoverable from the front-door `README.md`, `docs/concepts.md`, `docs/quickstart.md`, and `docs/skills/README.md`.

### Documentation refreshes

- `docs/skills/code-review.md` — refreshed for the size-aware dispatch model (was still describing the old "six agents always run" shape).
- New **Sizing** section in each of `docs/skills/code-review.md`, `docs/skills/gap-analysis.md`, `docs/skills/iterative-plan-review.md`, `docs/skills/plan-a-feature.md`, `docs/skills/plan-implementation.md`.
- `docs/concepts.md`, `docs/quickstart.md`, `docs/skills/README.md`, and `docs/skills/gh-pr-review.md` updated to reflect the new code-review roster shape.

## v1.6.0

Two new skills land in the `han` plugin, both producing plain-language reports that stakeholders (not just engineers) can read.

### `/gap-analysis` — compare two artifacts and find what's missing

Run a gap analysis between a *current state* and a *desired state* — for example a PRD vs. the shipped feature, a spec vs. its implementation, or any "what's missing from X compared to Y" question.

- Delegates the heavy analysis to the `gap-analyzer` agent, then synthesizes a stakeholder-readable report indexed by stable `G-NNN` gap IDs.
- Default output is plain language only — no file paths, line numbers, or code references in the main sections. Technical detail is opt-in.
- Optionally launches a swarm of validator/augmenter agents to corroborate or enrich findings. Swarm size (small / medium / large) is recommended based on gap count and category mix, but it never runs without the user opting in.
- Ships with a report template (`references/gap-analysis-report-template.md`) designed by the `information-architect` agent.

See [`/gap-analysis` documentation](./docs/skills/gap-analysis.md).

### `/plan-a-phased-build` — turn context into a sequenced build plan

Take any source of context (a gap analysis, PRD, design doc, feature spec, conversation notes, ADR, etc.) and produce a `build-phase-outline.md` that splits the work into vertical-slice phases.

- Every phase is **demonstrable to a real person** end-to-end — not "we shipped a service" but "you can do X and Y happens".
- Phases sequence for earliest demoable value. Foundational/prerequisite phases only come first when dependencies actually require it.
- Plain-language throughout: product-level subsystem names, user-facing vocabulary, behavioral verbs. A non-technical stakeholder can read it cover to cover.
- Each phase cross-references back to the source artifact for traceability.
- The `information-architect` agent reviews the rendered document for findability and progressive comprehension.

See [`/plan-a-phased-build` documentation](./docs/skills/plan-a-phased-build.md).

### Documentation

- New skill docs: [`gap-analysis.md`](./docs/skills/gap-analysis.md), [`plan-a-phased-build.md`](./docs/skills/plan-a-phased-build.md)
- [Skills Index](./docs/skills/README.md) and [Quickstart](./docs/quickstart.md) updated to surface both
- Minor link/version touch-ups across existing skill docs

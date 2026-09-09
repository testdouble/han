# Team Selection

## Contents

- Size bands, the specialist cap, and the round cap
- The roster
- Domain-scoped briefs

The size bands, the caps, and the roster Step 3 draws from. Step 3 selects using this file; it does not restate it.

The discovery agents in Step 2 and the architects in Step 4 are dispatched by their own steps and are **not** counted
against the specialist cap here. This file governs the Step 7 review round only. A specialist that already ran in Step 2
or Step 4 is not re-dispatched for review of its own output.

## Size bands, the specialist cap, and the round cap

**Default to small.** Start the classification at **small** and escalate only when the signals below clearly require it.
When a signal is borderline, stay at the smaller band. Classify from the recorded reason, the number of modules the area
spans, the count of delta entries, and how many of them are behavior-changing.

The cap counts **chosen specialists**. One seat is filled on every team before any specialist is chosen.

- **Small** _(default)_ — one module or package, no public API consumers outside the repo, every delta entry
  behavior-preserving. **1 chosen specialist** (team of 2: `han-core:junior-developer` + 1). Round cap: **1.**
- **Medium** — two or three modules, or a public surface with in-repo consumers, or at least one behavior-changing
  entry. **2 chosen specialists** (team of 3). Round cap: **2.**
- **Large** — a service boundary is crossed, a published API or persisted format changes, data ownership shifts, or the
  user explicitly requests the full team. **3 to 4 chosen specialists** (team of 4 to 5). Round cap: **3.**

**Size override.** If `$size` is non-empty (the user passed `small`, `medium`, `large`, or `dynamic` as the first
argument), use it: a band value is the size and skips the signal-based classification above, while `dynamic` forces
signal-based classification even when a config sets a default band. If `$size` is empty and a `.han/config.md` supplies
a band via `default-swarm-size` (per [../../../references/config-rule.md](../../../references/config-rule.md)), use that
band and skip the classification. Both caps still scale to the chosen size.

State the chosen size, the recommended team, and the reason in one short message before launching agents — for example
"Medium: three modules, one behavior-changing entry", "Medium: passed via `$size`", or "Medium: from the project
`.han/config.md` `default-swarm-size`", naming whichever file supplied it. If the user disagrees, accept the override of
the size, the specialists, or both.

## The roster

The team **always includes**:

- `han-core:junior-developer` — generalist stress-tester and reframer. It reframes a question in plain terms before the
  run escalates to the user, and that reframing frequently settles it. It also asks the question this skill's domain is
  worst at asking itself: whether the target structure is more structure than the recorded reason justifies.

Select additional specialists up to the cap, based on what the area actually contains. Draw from:

- `han-core:risk-analyst` — prioritization across the findings the discovery round and the review produced. The most
  common first pick, because a change plan's failure mode is carrying every finding at equal weight.
- `han-core:test-engineer` — how the change is verified, and which existing tests pin behavior the delta must preserve.
  Include whenever a behavior-preservation claim needs something to rest on.
- `han-core:on-call-engineer` — code-level resilience the change moves or removes: timeouts, retries, idempotency,
  queue handling, kill switches, and the failure paths a responsibility shift can quietly relocate.
- `han-core:adversarial-security-analyst` — the area handles authentication, authorization, PII, secrets, or untrusted
  input, and the change moves a trust boundary.
- `han-core:data-engineer` — the change touches a schema, a persisted format, a migration, or a data-access layer.
- `han-core:concurrency-analyst` — the area contains concurrent access, async coordination, or shared mutable state, and
  it was not already dispatched in Step 2.
- `han-core:structural-analyst` or `han-core:behavioral-analyst` — only when the review needs a dimension the Step 2
  round did not cover, such as an adjacent module the discovery brief excluded.
- `han-core:devops-engineer` — the change alters deployment shape, rollout, observability, or a build boundary.
- `han-core:user-experience-designer` — the change moves a user-facing surface: a CLI, an interactive prompt, or a
  rendered output a person reads.

Extra agents named in a `.han/config.md` `## Extra Agents` list join this pool and compete under the same selection and
caps, per [../../../references/config-rule.md](../../../references/config-rule.md). Count a selected extra agent against
the cap, and skip an entry that does not resolve to a dispatchable agent with a one-line note.

## Domain-scoped briefs

Pass each specialist only what its domain needs, plus the pointers below. Do not hand every agent the whole plan.

| Specialist                              | Plan sections to include in the brief                                             |
| --------------------------------------- | --------------------------------------------------------------------------------- |
| `han-core:risk-analyst`                 | Target State, the full delta with behavior classifications, Change Units          |
| `han-core:test-engineer`                | Current State, the delta entries classified Preserving, Change Units              |
| `han-core:on-call-engineer`             | Delta entries touching error paths, retries, timeouts, queues, or lifecycle order |
| `han-core:adversarial-security-analyst` | Delta entries moving a trust boundary, plus Current State on those paths          |
| `han-core:data-engineer`                | Delta entries touching a schema, persisted format, or data-access path            |
| `han-core:concurrency-analyst`          | Delta entries touching shared state, async coordination, or ordering              |
| `han-core:devops-engineer`              | Change Units, Risks, and any delta entry changing a build or deploy boundary      |
| `han-core:user-experience-designer`     | Delta entries changing a CLI, prompt, or rendered output, plus Behavior Changes   |
| `han-core:junior-developer`             | Why This Change, What Changes In One Paragraph, and the first line of every entry |

Give every agent:

- The path to `artifacts/current-state-findings.md`, with the directive: **read this first; do not re-grep for what is
  already there. Search further only for what your domain needs that the findings do not cover.**
- The path to `artifacts/scope-boundary.md`, so it can see the recorded scope its findings must fit inside.
- The recorded reason for the change, verbatim. A specialist that does not know why the change is being made cannot tell
  an over-built target state from a justified one.
- A report-length target matched to the size of the area, named as a rough line count rather than a size word. For a
  single-module change, name a report closer to 150 lines than 750. It is a target and not a cap.
- A directive on blind spots: **where a finding of yours rests on an input you could not inspect, say so on the finding
  itself, in the form your own definition specifies.** A disclosure in an assumptions section below the finding does not
  travel with it, and this skill reads each finding where it stands.
- The evidence-first directive: **before raising a question, re-read the relevant plan section and the current-state
  findings; if either already answers it, cite the line and do not raise it.**
- A directive on contracts: **every contract this change introduces that two or more parts must independently agree on
  has to be specified to a concrete signature, field layout, or worked example. Flag any that carries only a prose
  description, a field-name list, or the name of a document to be authored during the build.** Every specialist gets
  this, because which one notices an un-pinned contract depends on which side of it their domain sits. The categories
  are in [../../../references/contract-pinning-rule.md](../../../references/contract-pinning-rule.md).
- A directive on YAGNI: **apply [../../../references/yagni-rule.md](../../../references/yagni-rule.md) to every part the
  target state introduces.** Each new type, interface, abstraction layer, extension point, configuration seam, and
  adapter must cite evidence per the rule's test. Parts failing it are returned as **`Category: YAGNI candidate`**
  findings with the reopening trigger named.
- The directive that carries this skill's own failure mode: **a delta entry marked behavior-preserving is a claim, not a
  premise. Where your domain can see that an entry changes something observable, say so and name the observer.** A
  responsibility that moves between two parts is exactly where an unnoticed behavior change hides.
- A directive to cite by filename and heading — `change-plan.md#surface-delta`, a specific `S-N`, or a `C-N` in the
  findings file — so the aggregation can cross-reference precisely.

Collect every agent's verbatim output. "No concerns from my side" is a valid answer; record it.

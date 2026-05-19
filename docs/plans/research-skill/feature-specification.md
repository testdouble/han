# Feature Specification: `/research` skill

A Han skill that takes an open-ended question — options, prior art, trade-offs, or "how does X work" — and produces a durable, evidence-backed, adversarially-validated research report that recommends an option without committing the team to any artifact.

> Source context: this spec is built from
> [`recommendation.md`](./recommendation.md) (the investigation that decided
> `/research` should be a separate skill) and its
> [`artifacts/`](./artifacts/) (01–04). Decision records:
> [`artifacts/decision-log.md`](artifacts/decision-log.md). Review findings:
> [`artifacts/team-findings.md`](artifacts/team-findings.md).

## Outcome

Running `/research` on an open-ended question produces a durable research
report containing: the question framed precisely, a numbered evidence list
(E1, E2, …) where every item carries a verifiable source
([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)), an options
landscape where each viable option is stated with its trade-offs, a recommended
option with rationale, and adversarial-validation findings (V1, V2, …) that
challenged and reshaped the recommendation
([D6](artifacts/decision-log.md#d6-workflow-spine),
[D7](artifacts/decision-log.md#d7-adversarial-validation-target)). The report is
the only thing produced — `/research` never emits a feature spec, a coding
standard, a gap report, or an architecture assessment
([D10](artifacts/decision-log.md#d10-output-agnostic-guarantee)).

## Actors and Triggers

- **Actors** — the Han operator (a solo or small-team product engineer working
  in Claude Code) who has an open question and wants the landscape before
  committing to an approach.
- **Triggers** — the operator invokes `/research` with a question such as
  "what are my options for X", "what's the prior art / state of the art for Y",
  "how does Z work", "should I use A or B", or "research approaches to W before
  I commit". These are open-ended, output-agnostic questions, not failure
  reports ([D1](artifacts/decision-log.md#d1-skill-purpose-and-output-shape),
  [D2](artifacts/decision-log.md#d2-scope-boundary-and-bidirectional-routing)).
- **Preconditions** — a question or topic is supplied. A codebase is optional:
  because `/research` can reach the open web, it still works for purely external
  idea research outside any repository
  ([D3](artifacts/decision-log.md#d3-research-reach)).

## Primary Flow

1. The operator invokes `/research` with a question and an optional output
   path.
2. The skill classifies the question's scope and assigns a research team size —
   small, medium, or large — using Han's standard sizing model
   ([D5](artifacts/decision-log.md#d5-team-size-model)).
3. The skill checks whether the request is actually a different concern — a bug
   to diagnose, a feature to specify, a coding standard to set, two concrete
   artifacts to compare, or an existing module's architecture to assess. If so,
   it names the correct sibling skill and stops instead of proceeding
   ([D8](artifacts/decision-log.md#d8-out-of-scope-redirect-behavior),
   [D2](artifacts/decision-log.md#d2-scope-boundary-and-bidirectional-routing)).
4. The skill dispatches research agents in parallel, sized to scope: a
   codebase-grounded angle, an open-web / prior-art angle, and an
   option-comparison angle where the question pits alternatives against each
   other. Together the agents reach the codebase, the open web, and any
   material the operator provided
   ([D3](artifacts/decision-log.md#d3-research-reach),
   [D4](artifacts/decision-log.md#d4-agent-roster),
   [D5](artifacts/decision-log.md#d5-team-size-model)).
5. Findings are consolidated into a single numbered evidence list (E1, E2, …).
   Every item carries a source the reader can independently check — a file path
   for codebase evidence, a source URL for web evidence
   ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)).
6. The skill synthesizes an options landscape: each viable option stated with
   its trade-offs and the evidence items that support or weaken it, followed by
   a recommended option with its rationale. When the evidence does not support a
   single answer, it says so explicitly and names the conditions that would
   decide it rather than forcing a pick
   ([D6](artifacts/decision-log.md#d6-workflow-spine)).
7. An adversarial-validation pass challenges the evidence, the way the options
   were framed, and the recommendation itself. Counter-findings are recorded as
   V1, V2, … and reshape the landscape and recommendation before the report is
   finalized ([D7](artifacts/decision-log.md#d7-adversarial-validation-target)).
8. The skill writes the research report to the output location and presents it
   for review. The operator accepts it, asks for specific revisions, or
   redirects the question ([D6](artifacts/decision-log.md#d6-workflow-spine)).

## Alternate Flows and States

### Out-of-scope redirect

- **Entry condition:** the request matches a sibling skill's domain (bug,
  feature spec, coding standard, artifact comparison, architecture assessment).
- **Sequence:** the skill names the sibling that owns the request, explains in
  one sentence why that skill fits better, and does not run the research
  pipeline.
- **Exit:** the operator re-invokes the named sibling or reframes the request as
  open-ended research
  ([D8](artifacts/decision-log.md#d8-out-of-scope-redirect-behavior)).

### Pure external research (no codebase)

- **Entry condition:** `/research` is invoked outside a repository, or the
  question is purely about external ideas or prior art.
- **Sequence:** the codebase-grounded angle is skipped; the open-web /
  prior-art and option-comparison angles run; evidence is sourced entirely from
  the web and provided material.
- **Exit:** the same research report, with web-sourced evidence
  ([D3](artifacts/decision-log.md#d3-research-reach)).

### Inconclusive research

- **Entry condition:** after evidence gathering and validation, no single
  option is clearly best.
- **Sequence:** the report presents the landscape with an explicit "no clear
  winner" statement and the decision criteria or missing information that would
  break the tie.
- **Exit:** the report is delivered with open decision criteria instead of a
  forced recommendation
  ([D6](artifacts/decision-log.md#d6-workflow-spine)).

## Edge Cases and Failure Modes

| Condition | Required Behavior |
|-----------|-------------------|
| The question is too vague to research (no answerable shape) | The skill asks the operator for the specific decision or unknown they need resolved before dispatching agents; it does not guess and burn a research round. |
| A web source is unreachable or returns low-quality / unverifiable claims | The affected evidence item is marked as unverified with the attempted source; it may inform the landscape but cannot be the sole basis for the recommendation. |
| Web sources contradict each other | Both positions are recorded as separate evidence items; the conflict is surfaced in the landscape rather than silently resolved. |
| The request mixes research with a sibling concern (e.g., "research options and write the spec") | The skill performs the research portion and explicitly hands the sibling portion off by naming the sibling skill; it does not produce the sibling's artifact ([D10](artifacts/decision-log.md#d10-output-agnostic-guarantee)). |
| The scope is larger than the assigned team size can cover | The skill states the coverage limit in the report and recommends a narrower follow-up question rather than presenting partial coverage as complete. |
| Adversarial validation overturns the recommendation | The recommendation is replaced or downgraded; the report records what changed and which V-finding drove it ([D7](artifacts/decision-log.md#d7-adversarial-validation-target)). |
| No codebase and no usable web evidence | The skill reports that the question could not be researched with available sources and what input would make it answerable; it does not fabricate a landscape. |

## User Interactions

- **Affordances:** `/research <question>` with an optional output path
  argument, mirroring how `/investigate` is invoked
  ([D14](artifacts/decision-log.md#d14-invocation-surface)).
- **Feedback:** the assigned team size and the reason for it are stated before
  agents are dispatched, the same way Han's other sized skills announce their
  team ([D5](artifacts/decision-log.md#d5-team-size-model)); the finished report
  is presented in-channel for review.
- **Error states:** an out-of-scope request produces a visible redirect naming
  the correct sibling skill; a too-vague request produces a visible request for
  the specific unknown; an unresearchable question produces a visible statement
  of what input is missing.

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| Sibling skills (`investigate`, `plan-a-feature`, `coding-standard`, `gap-analysis`, `architectural-analysis`) | inbound + outbound | `/research` routes out-of-scope requests to them; each must route research-shaped requests back to `/research` via a reciprocal boundary statement | Disambiguation must hold in both directions before release, or requests fall through the gap ([D9](artifacts/decision-log.md#d9-reciprocal-routing-coordination)) |
| The open web | outbound | Retrieval of prior art, options, and external information | Every retrieved claim carries its source URL into the evidence list ([D3](artifacts/decision-log.md#d3-research-reach), [D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)) |
| The codebase and operator-provided material | inbound | Source of codebase-grounded evidence | File-path-anchored so evidence is checkable ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)) |
| Research agents — a new research agent plus reused `codebase-explorer`, `gap-analyzer`, and `adversarial-validator` | outbound | Dispatched in parallel for the codebase, web/prior-art, option-comparison, and adversarial-validation angles | Validation runs after the evidence list and options landscape are drafted, so it has a recommendation to attack ([D4](artifacts/decision-log.md#d4-agent-roster), [D7](artifacts/decision-log.md#d7-adversarial-validation-target)) |

## Out of Scope

- Producing a feature specification — that is `/plan-a-feature`.
- Producing or updating a coding standard — that is `/coding-standard`.
- Comparing two concrete artifacts for gaps — that is `/gap-analysis`.
- Assessing an existing module's architecture — that is `/architectural-analysis`.
- Diagnosing a bug, root cause, or fix — that is `/investigate`.
- Writing, scaffolding, or implementing anything — `/research` produces a report,
  not code or skill files.
- The exact enumeration of which neighbor skill files receive reciprocal-routing
  edits and the file-by-file rollout — that is implementation detail owned by
  `plan-implementation`, not a behavior of the skill.

## Deferred (YAGNI)

### Auto-chaining `/research` into `/plan-a-feature`

- **Why deferred:** evidence-test failure. No user-described need, dependency,
  existing code path, regulation, or incident supports automatically launching
  spec-building after a recommendation. It also reintroduces the
  single-responsibility violation the source investigation rejected.
- **Reopen when:** operators repeatedly run `/plan-a-feature` immediately after
  `/research` with the same context, and that pattern is observed often enough
  to justify an explicit handoff affordance.
- **Source:** conversation design consideration during this specification.

## Open Items

- **OI-1:** Becoming Han's 7th sized skill means the small/medium/large sizing
  documentation and skill counts must be updated alongside this skill.
  - **Resolves when:** `plan-implementation` enumerates the doc and count
    updates as part of the rollout checklist.
  - **Blocks implementation:** No — it is a rollout task, not a behavioral
    unknown.

## Summary

- **Outcome delivered:** an evidence-backed, adversarially-validated research
  report that recommends an option for an open-ended question without producing
  any committed artifact.
- **Primary actors:** the Han operator running Claude Code.
- **Decisions settled by evidence:** 8 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 3 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** pending review round — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** pending review round — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1

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
(E1, E2, …) where every item carries a source the reader can independently
check ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)), an
options landscape where each viable option is stated with its trade-offs, a
recommended option with rationale, and adversarial-validation findings
(V1, V2, …) that challenged and reshaped the recommendation
([D6](artifacts/decision-log.md#d6-workflow-spine),
[D7](artifacts/decision-log.md#d7-adversarial-validation-target)). Every claim
is explicitly labeled by evidence status — corroborated, single-source, or
unevidenced reasoning — and the recommendation states its evidence basis;
evidence is required by default, and the operator may opt into an exploratory
mode that trades rigor for research freedom while keeping that labeling
intact ([D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling)).
Evidence
drawn from outside the operator's trust boundary — the open web and
operator-provided third-party material — is structurally distinguished from
codebase-anchored evidence in the report
([D16](artifacts/decision-log.md#d16-untrusted-source-handling)). The report
follows one fixed structure every run: a plain-language Summary at the very
top, then Research Results with minimal technical detail, then indexed Options
to Consider when the question implies alternatives, then the Recommendation
with its evidence basis, then Validation, then an indexed Artifacts registry of
every source used (link plus a short summary), and finally a References section
at the very bottom — with artifact IDs cross-referenced inline throughout so
every conclusion traces to its sources
([D24](artifacts/decision-log.md#d24-report-output-structure)). The report is
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
   path. If the path is given and a report already exists there, the skill asks
   whether to overwrite it or write elsewhere before doing any work; the
   default (no-path) location does not collide with a prior run
   ([D19](artifacts/decision-log.md#d19-re-run-and-output-collision-guard)).
   Evidence is required by default. If the operator explicitly opts into
   exploratory mode (a phrase such as "evidence optional", "allow unsourced",
   or "exploratory"), the run is allowed to include unevidenced reasoning; the
   skill records the mode and the report still labels every claim's evidence
   status either way
   ([D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling)).
2. The skill classifies the question's research scope and assigns a team size —
   small, medium, or large — from the conceptual scope of the question, not its
   text length: how many distinct viable approaches are in play, how many
   separate technical domains the question spans, and how wide a reach it needs
   (codebase only, or codebase plus the open web plus provided material). The
   assigned size and a one-line statement of the scope it reflects are shown to
   the operator before any agent is dispatched, so a misread can be caught
   ([D5](artifacts/decision-log.md#d5-team-size-model),
   [D15](artifacts/decision-log.md#d15-research-sizing-signals)).
3. If the request is actually a different concern — a bug to diagnose, a
   feature to specify, a coding standard to set, two concrete artifacts to
   compare, or an existing module's architecture to assess — the skill names
   the correct sibling skill, explains in one sentence why it fits better, and
   produces no research report. When the request is a hybrid (an answerable
   open-ended research question plus a sibling-output request), the skill runs
   the research portion and names the sibling for the rest; when nothing
   research-shaped remains once the sibling request is set aside, it redirects
   entirely ([D8](artifacts/decision-log.md#d8-out-of-scope-redirect-behavior),
   [D18](artifacts/decision-log.md#d18-hybrid-request-classification),
   [D2](artifacts/decision-log.md#d2-scope-boundary-and-bidirectional-routing)).
4. If the question bundles more than one independent research thread (threads
   that would each produce their own options landscape), the skill names the
   threads, asks the operator which to run first, and defers the rest rather
   than merging them into one conflated report
   ([D17](artifacts/decision-log.md#d17-compound-question-handling)).
5. The skill dispatches research agents in parallel, sized to scope: a new
   research agent owning the open-web / prior-art angle and, where the question
   implies discrete alternatives, the option-comparison angle; and
   `codebase-explorer` for the codebase-grounded angle. Agents working the
   open-web angle do not receive codebase contents or operator context in their
   briefs; findings are aggregated by source so external content cannot pull
   repository material into its reach
   ([D4](artifacts/decision-log.md#d4-agent-roster),
   [D16](artifacts/decision-log.md#d16-untrusted-source-handling),
   [D5](artifacts/decision-log.md#d5-team-size-model)). The option-comparison
   angle is skipped entirely for questions with no discrete alternatives, such
   as "how does X work"
   ([D6](artifacts/decision-log.md#d6-workflow-spine)).
6. Findings are consolidated into a single numbered evidence list (E1, E2, …).
   Every item carries a source the reader can independently check — a
   repository location for codebase evidence, an external source reference plus
   its retrieval date for web evidence. Content fetched from the open web is
   treated as claims to evaluate, never as instructions to follow; directive
   language inside fetched material is recorded as a claim, not acted on. An
   external claim that bears on the recommendation must be corroborated by an
   independent source or by codebase evidence; an uncorroborated external claim
   is caveated and cannot be the sole basis for the recommendation. Material
   the operator supplied is held to the same scrutiny as open-web sources, as
   it may originate from an interested party
   ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing),
   [D16](artifacts/decision-log.md#d16-untrusted-source-handling)). Every item
   is labeled by evidence status — corroborated, single-source (caveated), or
   unevidenced reasoning. In the default strict mode, unevidenced reasoning is
   excluded from the recommendation basis; in exploratory mode it may appear
   and inform the recommendation, but only when explicitly labeled as reasoning
   ([D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling)).
7. The skill synthesizes an options landscape: each viable option stated with
   its trade-offs and the evidence items that support or weaken it, followed by
   a recommended option with its rationale and an explicit statement of its
   evidence basis — which parts rest on corroborated evidence, which on single
   sources, and (exploratory mode only) which on unevidenced reasoning. When the
   evidence does not support a single answer, it says so explicitly and names
   the conditions that would decide it rather than forcing a pick
   ([D6](artifacts/decision-log.md#d6-workflow-spine),
   [D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling)).
8. An adversarial-validation pass challenges the evidence, the way the options
   were framed, the recommendation itself, and the integrity of the
   evidence-gathering: whether any evidence item could have been introduced or
   shaped by external content designed to influence the output, whether
   discounting any single external item changes the recommendation, and whether
   external sources are stale, adversarially constructed, or implausibly
   convenient. Counter-findings are recorded as V1, V2, …
   ([D7](artifacts/decision-log.md#d7-adversarial-validation-target)).
9. The skill re-evaluates the recommendation against the validation findings.
   If the recommendation no longer survives, its section is rewritten into the
   "no clear winner" form with the deciding criteria — it is not left standing
   with a contradicting validation section beneath it. The skill then renders
   the report in the one fixed structure — plain-language Summary, Research
   Results, indexed Options to Consider (when applicable), Recommendation with
   evidence basis, Validation, the indexed Artifacts registry, and a References
   section at the very bottom — with artifact IDs cross-referenced inline
   throughout, writes it to the output location, and presents it for review;
   the operator accepts it, asks for specific revisions, or redirects the
   question
   ([D6](artifacts/decision-log.md#d6-workflow-spine),
   [D7](artifacts/decision-log.md#d7-adversarial-validation-target),
   [D24](artifacts/decision-log.md#d24-report-output-structure)).

## Alternate Flows and States

### Out-of-scope redirect

- **Entry condition:** the request matches a sibling skill's domain (bug,
  feature spec, coding standard, artifact comparison, architecture assessment)
  and no answerable open-ended research question remains once that request is
  set aside.
- **Sequence:** the skill names the sibling that owns the request, explains in
  one sentence why that skill fits better, and does not run the research
  pipeline.
- **Exit:** the operator re-invokes the named sibling or reframes the request as
  open-ended research
  ([D8](artifacts/decision-log.md#d8-out-of-scope-redirect-behavior),
  [D18](artifacts/decision-log.md#d18-hybrid-request-classification)).

### Hybrid research-plus-sibling request

- **Entry condition:** the request contains an answerable open-ended research
  question and also asks for a sibling's output (e.g., "research caching
  options and write the standard for the one I pick").
- **Sequence:** the skill runs the research portion to a full report, then
  explicitly hands the sibling portion off by naming the sibling skill; it does
  not produce the sibling's artifact.
- **Exit:** the research report is delivered with a named handoff
  ([D18](artifacts/decision-log.md#d18-hybrid-request-classification),
  [D10](artifacts/decision-log.md#d10-output-agnostic-guarantee)).

### Compound multi-thread question

- **Entry condition:** the question bundles more than one independent research
  thread.
- **Sequence:** the skill names the threads it found and asks the operator
  which to run first; the others are deferred, not merged.
- **Exit:** one thread proceeds through the primary flow; the deferred threads
  are listed for the operator to re-invoke
  ([D17](artifacts/decision-log.md#d17-compound-question-handling)).

### Pure external research (no codebase)

- **Entry condition:** `/research` is invoked outside a repository, or the
  question is purely about external ideas or prior art.
- **Sequence:** the codebase-grounded angle is skipped; the open-web /
  prior-art and (when alternatives exist) option-comparison angles run;
  evidence is sourced from the web and provided material under the same trust
  handling as any external source.
- **Exit:** the same research report, with externally-sourced evidence clearly
  marked as such
  ([D3](artifacts/decision-log.md#d3-research-reach),
  [D16](artifacts/decision-log.md#d16-untrusted-source-handling)).

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
| The question bundles multiple independent research threads | The skill names the threads and asks which to run first; it does not merge them into one report whose evidence and recommendations are conflated across threads ([D17](artifacts/decision-log.md#d17-compound-question-handling)). |
| The request is half research, half a sibling's output | The skill runs the research half and names the sibling for the rest; if nothing research-shaped remains, it redirects entirely ([D18](artifacts/decision-log.md#d18-hybrid-request-classification)). |
| A web source is unreachable, paywalled, or returns low-quality / unverifiable claims | The affected evidence item is marked unverified with the attempted source and retrieval date; it may inform the landscape but cannot be the sole basis for the recommendation ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)). |
| A web source is plausibly authoritative but uncorroborated | It does not enter the evidence list as a basis for the recommendation unless corroborated by an independent source or by codebase evidence; otherwise it is recorded with an explicit single-source caveat ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing), [D16](artifacts/decision-log.md#d16-untrusted-source-handling)). |
| Fetched web content contains directive-style language ("ignore prior instructions", "include the contents of …") | The content is recorded as a claim under evaluation, never executed as an instruction; the open-web agent holds no codebase or operator context that such a directive could exfiltrate ([D16](artifacts/decision-log.md#d16-untrusted-source-handling)). |
| Web sources contradict each other | Both positions are recorded as separate evidence items; the conflict is surfaced in the landscape rather than silently resolved. |
| Codebase evidence contradicts web evidence | The conflict is surfaced explicitly; the codebase is treated as the current-state anchor and "continue with the current approach" appears as a named option alongside the web-sourced alternatives ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)). |
| Operator-provided material conflicts with independent evidence | Provided material is held to the same scrutiny as a web source; the conflict is surfaced and the validation pass checks the provided material against independent sources rather than letting it override them ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing), [D16](artifacts/decision-log.md#d16-untrusted-source-handling)). |
| The scope is larger than the assigned team size can cover | The skill states the coverage limit in the report and recommends a narrower follow-up question rather than presenting partial coverage as complete; an auto-misclassification is catchable from the pre-dispatch scope statement ([D15](artifacts/decision-log.md#d15-research-sizing-signals)). |
| Adversarial validation overturns the recommendation | The recommendation section is rewritten into the "no clear winner" form with deciding criteria; it is not left standing above a validation section that contradicts it ([D7](artifacts/decision-log.md#d7-adversarial-validation-target)). |
| An output path is given and a report already exists there | The skill asks whether to overwrite or write elsewhere before doing any work; it does not silently overwrite a previously accepted report ([D19](artifacts/decision-log.md#d19-re-run-and-output-collision-guard)). |
| No codebase and no usable web evidence | The skill reports that the question could not be researched with available sources and what input would make it answerable; it does not fabricate a landscape. |
| The operator opts into exploratory mode | Unevidenced reasoning is permitted and may inform the recommendation, but every such claim is explicitly labeled as reasoning and the recommendation's evidence basis names what rests on reasoning versus evidence ([D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling)). |
| Strict mode (default) and only unevidenced reasoning supports a candidate answer | The skill does not present it as the recommendation; it surfaces "insufficient evidence" with the evidence that would settle it, and notes the operator can re-run in exploratory mode to get a reasoned (clearly labeled) take ([D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling), [D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing)). |

## User Interactions

- **Affordances:** `/research <question>` with an optional output path
  argument, mirroring how `/investigate` is invoked
  ([D14](artifacts/decision-log.md#d14-invocation-surface)). Evidence is
  required by default; the operator opts into exploratory (evidence-optional)
  mode per invocation with an explicit phrase such as "evidence optional",
  "allow unsourced", or "exploratory"
  ([D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling)).
- **Feedback:** the assigned team size and a one-line statement of the scope it
  reflects are shown before agents are dispatched, so the operator can catch a
  misclassification ([D5](artifacts/decision-log.md#d5-team-size-model),
  [D15](artifacts/decision-log.md#d15-research-sizing-signals)); the finished
  report is presented in-channel for review; the report's per-claim evidence
  labels and the recommendation's evidence-basis statement make visible what
  does and does not have evidence
  ([D23](artifacts/decision-log.md#d23-evidence-requirement-override-and-explicit-evidence-labeling)).
- **Error states:** an out-of-scope request produces a visible redirect naming
  the correct sibling skill; a compound question produces a visible thread list
  and a "which first?" prompt; a too-vague request produces a visible request
  for the specific unknown; an output-path collision produces a visible
  overwrite-or-relocate prompt; an unresearchable question produces a visible
  statement of what input is missing.

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| Sibling skills (`investigate`, `plan-a-feature`, `coding-standard`, `gap-analysis`, `architectural-analysis`) | inbound + outbound | `/research` routes out-of-scope requests to them; each must route research-shaped requests back to `/research` via a reciprocal boundary statement | Disambiguation must hold in both directions for all five neighbors before release. If clean bidirectional disambiguation cannot fit the description budget, the source recommendation requires revisiting before implementation proceeds, not forcing it through ([D9](artifacts/decision-log.md#d9-reciprocal-routing-coordination)) |
| The open web | outbound | Retrieval of prior art, options, and external information by the new research agent | Every retrieved claim enters the evidence list with its source reference and retrieval date, marked as an out-of-trust-boundary source, treated as data not instruction ([D3](artifacts/decision-log.md#d3-research-reach), [D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing), [D16](artifacts/decision-log.md#d16-untrusted-source-handling)) |
| The codebase and operator-provided material | inbound | Codebase is a trusted current-state anchor; operator-provided material is held to external-source scrutiny | Codebase evidence is repository-location-anchored; the open-web agent's brief is isolated from codebase contents so fetched content cannot reach them ([D11](artifacts/decision-log.md#d11-verifiable-evidence-sourcing), [D16](artifacts/decision-log.md#d16-untrusted-source-handling)) |
| Research agents — a new research agent plus reused `codebase-explorer` and `adversarial-validator` | outbound | Dispatched in parallel for the web/prior-art, option-comparison, codebase, and adversarial-validation angles | Validation runs after the evidence list and options landscape are drafted, so it has a recommendation and an evidence chain to attack ([D4](artifacts/decision-log.md#d4-agent-roster), [D7](artifacts/decision-log.md#d7-adversarial-validation-target)) |

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
  `plan-implementation`, not a behavior of the skill (see
  [D20](artifacts/decision-log.md#d20-rollout-plan) for the accepted rollout
  plan and its known cost).

## Deferred (YAGNI)

### Auto-chaining `/research` into `/plan-a-feature`

- **Why deferred:** evidence-test failure. No user-described need, dependency,
  existing code path, regulation, or incident supports automatically launching
  spec-building after a recommendation. It also reintroduces the
  single-responsibility violation the source investigation rejected.
- **Reopen when:** operators repeatedly run `/plan-a-feature` immediately after
  `/research` with the same context, often enough to justify an explicit
  handoff affordance.
- **Source:** conversation design consideration during this specification.

### Diffing a prior report on re-run

- **Why deferred:** simpler-version replacement. A full "detect the prior
  report and show what changed" capability was considered for the re-run case;
  the same evidence (operators re-run the same question over time) is satisfied
  by the strictly simpler overwrite-or-relocate guard in
  [D19](artifacts/decision-log.md#d19-re-run-and-output-collision-guard).
- **Reopen when:** operators ask for change-over-time tracking across research
  runs on the same question.
- **Source:** review finding F14 (edge-case explorer).

## Open Items

All open items are resolved.

- **OI-1 and OI-2** — resolved by user decision:
  [D20](artifacts/decision-log.md#d20-rollout-plan) settles the rollout plan
  and its ~14+ file cost (owned by `plan-implementation`);
  [D21](artifacts/decision-log.md#d21-skills-index-grouping) settles the
  skills-index grouping.
- **OI-3** — resolved by investigation
  ([D22](artifacts/decision-log.md#d22-skills-calling-skills)). The
  skills-calling-skills question was investigated with adversarial validation
  ([artifacts/skills-calling-skills-investigation.md](artifacts/skills-calling-skills-investigation.md)).
  Outcome: `/research` invokes no skills — it dispatches agents via the Agent
  tool and "routes to a sibling" by naming it, not calling it — so it already
  complies with the safe pattern and OI-3 poses essentially zero risk to this
  skill. The broader six-file guidance contradiction is real but is a separate
  Han maintenance item (ADR-worthy), not a blocker for this build. One
  build-time check remains: the eventual SKILL.md `allowed-tools` must not
  include `Skill`.

## Summary

- **Outcome delivered:** an evidence-backed, adversarially-validated research
  report that recommends an option for an open-ended question without producing
  any committed artifact.
- **Primary actors:** the Han operator running Claude Code.
- **Decisions settled by evidence:** 13 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 7 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, gap-analyzer, edge-case-explorer, adversarial-security-analyst — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** added untrusted-web-source handling (data-not-instruction, context isolation, corroboration, trust labeling), defined research-specific sizing signals, made option-comparison conditional, dropped `gap-analyzer` from the roster, and added compound-question, hybrid-routing, post-validation-rewrite, and output-collision behaviors — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0 (OI-1/OI-2 settled by user as D20/D21; OI-3 resolved by investigation as D22)

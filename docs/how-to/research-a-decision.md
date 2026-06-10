# How To: Research a Decision and Capture It

A walkthrough for getting from an open-ended question ("which library", "which pattern", "which hosting move") to an adversarially-validated recommendation, then locking the chosen direction in as an ADR so the team has a single canonical record of what was decided and why.

> See also: [How-to index](./README.md) · [Quickstart](../quickstart.md) · [Skills](../skills/README.md)

## Before you begin

- You have a real decision to make, not a bug to diagnose and not a feature to specify. `/investigate` is the right tool when something is broken; `/plan-a-feature` is the right tool when the decision has already been made and you are scoping behavior.
- You have a question han can frame as a single decision. If the question is too thin, `/research` will ask you to sharpen it before dispatching anything. (Phase 1 step 1 below shows what a sharper framing looks like.)
- You have any material you already trust. A vendor doc, an internal RFC, a benchmark you ran, a prior conversation. Bring it in. It enters the evidence list with its source, and the validator checks it against independent sources rather than letting it override them.
- You have somewhere to put the ADR. Most projects keep ADRs in `docs/adr/`, `docs/architecture/decisions/`, or a similar directory. If your project does not have one and has not run [`/project-discovery`](../skills/han.core/project-discovery.md) yet, run that first so the ADR skill knows where to file the record.

## What you'll end up with

- A research report with a plain-language summary on top, results with minimal jargon, indexed options (`O1, O2, …`) when applicable, the recommendation and its evidence basis, validation findings (`V1, V2, …`), and an indexed Sources registry (`A1, A2, …`) at the bottom with every source's link, retrieval date, trust class, summary, and evidence status all in one entry.
- An architectural decision record (ADR) capturing the choice, the rejected alternatives, and the reasons. Filed in your project's ADR directory.

When you have both, the decision is researched, validated, and locked in as a single canonical record the team can refer back to.

## The happy path

The workflow has two short phases. Phase 1 produces the recommendation; Phase 2 captures it as an ADR.

### Phase 1: Research the question

1. **Frame the decision and run [`/research`](../skills/han.core/research.md).** "Background jobs" is too thin to research; "should we adopt a job queue separate from our database, given we already run Postgres" is researchable. The framing names the decision, the constraint, and the comparison set. A template that works well when you already have a current choice:

    > `/research alternatives to {current choice}, for {purpose}, and provide a benefits and drawbacks comparison.`

    Or, when there is no current choice and you are starting from scratch:

    > `/research what are my options for {capability}, given we already use {constraint}. I want the trade-offs of each.`

    A fully filled-in example:

    > `/research alternatives to Sidekiq for background jobs in our Rails app, given we already run a single Postgres instance and want to minimize new infrastructure. Compare benefits and drawbacks across the viable options.`

    Han classifies the question, sizes the team, and dispatches `research-analyst` angles in parallel. At small size, one analyst covers the question alongside `codebase-explorer` when a repo bears on the question. At medium and large, multiple analysts split the question by domain or by option cluster. An `adversarial-validator` runs last to attack the recommendation, the evidence, and the way the options were framed.

2. **Read the recommendation and the validation section together.** The recommendation lives near the top of the report; the validation findings sit immediately below. The validator frequently downgrades a single-source recommendation, surfaces a stale benchmark, or rewrites the recommendation into a "no clear winner" form when the evidence does not support a single answer. Read both sections side by side.

3. **Decide whether the evidence is strong enough to act on.** If the recommendation rests on corroborated evidence from independent sources and survived adversarial validation, move to Phase 2. If it rests on a single source, on staleness, or on the report's own reasoning (exploratory mode), decide whether you want a follow-up run to close the gap or whether the recommendation is strong enough for your situation.

### Phase 2: Capture the decision as an ADR

1. **Run [`/architectural-decision-record`](../skills/han.core/architectural-decision-record.md) with the recommended option and the alternatives.** A template that works well:

    > `/architectural-decision-record the choice of using {option}, with the other options as alternatives. We chose {option} because {reasons}. Reference the research report at {path}.`

    A fully filled-in example:

    > `/architectural-decision-record the choice of using Postgres-backed Solid Queue for background jobs, with Sidekiq and GoodJob as alternatives. We chose Solid Queue because we want to avoid adding Redis, the throughput meets our needs, and the Rails 8 integration is first-class. Reference the research report at docs/research/background-jobs.md.`

    The skill writes an ADR using your project's ADR template (or a sensible default if none exists), with the decision, the alternatives, the consequences, and a link back to the research report so future readers can see the evidence the decision rested on.

2. **Review the ADR.** Check that it names the right alternatives, the right reasons, and the right consequences. The skill pulls from the research report directly, so the body should match the recommendation; if it does not, push back.

## Variations

- **The research came back as "no clear winner".** This is not a failure. It means the evidence does not yet support a single recommendation. The report names the deciding criteria, the specific evidence that would settle the question. Gather what is named and re-run, or pick one based on local constraints and capture the choice with an ADR that explicitly notes the evidence gap.

- **You want a take more than you want a sourced answer.** Add an explicit opt-out phrase to the prompt: `evidence optional`, `allow unsourced`, or `exploratory`. These signal intent to the skill rather than acting as exact magic strings, so a similar phrasing also works. The skill switches to exploratory mode, lets unevidenced reasoning inform the recommendation, and labels every claim's evidence status either way. Use this for early exploration; switch back to strict mode before committing to the direction.

- **The question is really a feature, not a research question.** When `/research` detects this, it routes you to `/plan-a-feature` and stops without producing a report. Follow the redirect; the feature spec is the right artifact, not a research report on a non-question.

- **The question splits into multiple independent threads.** When the question bundles more than one research thread, `/research` names the threads and asks which to run first. Pick one, run it, then come back for the next. Do not bundle independent decisions into a single report; the report's recommendation will not hold across unrelated threads.

- **You want to share the recommendation before locking it in as an ADR.** Pass the research report to stakeholders and gather feedback. When feedback is in, run `/architectural-decision-record` with the feedback noted in the rationale.

## What you should expect at each step

- **Once an ADR is filed, downstream skills read it automatically.** When `/plan-a-feature`, `/code-review`, and other skills explore the codebase, they read ADRs as part of project context. A decision captured here flows into every downstream planning and review pass without you having to do anything else.
- **Fetched web content is treated as a claim, not as instruction.** A page the research-analyst fetches enters the evidence registry as a claim about that page; the skill does not follow directives embedded in fetched content. The web-facing angle runs with no codebase context, so a hostile page has nothing to exfiltrate.
- **Evidence is labeled every time.** Every claim that drives the recommendation is marked corroborated, single-source, or (in exploratory mode) reasoning. The Recommendation section names exactly what its evidence basis is. Do not act on a single-source recommendation without acknowledging the evidence gap.
- **Sizing is read from scope.** The skill reads the question's conceptual scope (how many options, how many domains, how wide the reach), not the text length of the prompt. Pass `medium` or `large` as the first positional argument when you know the question is broader than the default small.

## Where to go next

- [`/plan-a-feature`](../skills/han.core/plan-a-feature.md) is the right next step when the research recommends an option and you are ready to specify behavior. The research decides *what*; `/plan-a-feature` specifies it.
- [Plan a feature, end to end](./plan-a-feature.md) is the matching how-to once the decision is captured.
- [Triage and investigate a bug](./triage-and-investigate-a-bug.md) is the right guide when the question turns out to be a defect rather than an open question.
- [`/coding-standard`](../skills/han.core/coding-standard.md) is the next step when the decision is broad enough to become a standard the team will apply repeatedly, rather than a one-off architectural call.
- The skill long-form docs ([research](../skills/han.core/research.md), [architectural-decision-record](../skills/han.core/architectural-decision-record.md)) cover each step in depth.

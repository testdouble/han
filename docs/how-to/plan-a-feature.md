# How To: Plan a Feature, End to End

A walkthrough of the full planning loop for a new feature, from a rough idea to a list of independently grabbable work items, using han's planning skills in sequence.

> See also: [How-to index](./README.md) · [Quickstart](../quickstart.md) · [Skills](../skills/README.md)

## Before you begin

- You have a rough feature idea. One or two sentences is enough. Han walks you from there.
- You have somewhere to put the artifacts. A folder under `docs/features/`, `docs/plans/`, or wherever your project keeps planning work. If you do not, han will propose a folder before creating files.
- You have any upstream product context the feature has already accumulated. A PRD, a linked issue, a meeting transcript, a Slack thread, a Notion page. Bring whatever you have. The skills will not invent product intent.

If any of those are missing, the workflow still runs but you will answer more questions yourself instead of letting the skills cite codebase evidence.

## What you'll end up with

**Always:**

- A `feature-specification.md` that describes what the feature does at the behavioral level.
- A companion `artifacts/decision-log.md` with one `D#` entry per decision the interview settled (rationale, evidence, rejected alternatives, dependent decisions).
- A companion `artifacts/team-findings.md` with one `F#` entry per finding the review team raised. The `D#` and `F#` IDs cross-reference each other and the spec, so every commitment in the spec traces back to the evidence that drove it.
- A `feature-implementation-plan.md` that describes how to build the feature, written through the same project-manager-led team conversation.
- A `work-items.md` with one entry per independently grabbable piece of work.

**For larger features only:**

- A `build-phase-outline.md` that orders the work into demoable vertical slices, and a per-phase spec and plan rather than a single monolithic one.

When you have those artifacts, the planning loop is complete and the work is ready to be turned into issue tickets or implemented directly.

## The happy path

The workflow is grouped into four phases. Phase 1 produces the initial behavioral spec. Phase 2 finalizes the spec for the slice you are about to build (it does almost nothing for small features and most of the work for phased ones). Phase 3 produces an implementation plan. Phase 4 turns that plan into individual work items.

Each phase is a natural pause point. When you reach the end of one, look at what you have and decide whether to keep going or stop for the day.

### Phase 1: Spec the feature

1. **Run [`/plan-a-feature`](../skills/han.core/plan-a-feature.md) with the rough idea and an output folder.** A template that works well:

    > `/plan-a-feature on building out {feature idea}, using {reference} as a starting point. It needs to {behaviors and constraints}. Write the plan to {plan folder} as we go.`

    A fully filled-in example:

    > `/plan-a-feature on building out the bulk CSV export for admin list views, using the existing single-row export as a starting point. It needs to email a download link when the file is ready, support filters that mirror the list view, and cap exports at 100k rows. Write the plan to docs/features/bulk-export/ as we go.`

    Han runs an evidence-based interview that walks the design tree: foundational decisions first (what, who, outcome, trigger), then behavioral (flows, states, coordinations), then boundary (edge cases, out of scope), then interaction (UI / API surface). The skill explores the codebase, ADRs, and coding standards before surfacing each question, so most questions arrive with a recommended answer already attached.

2. **Walk through every open item and decide.** When the skill surfaces a question, accept the recommendation, redirect it, or ask for an alternative. Decisions you make here flow into the spec; decisions you defer land in an Open Items section so they do not silently disappear.

3. **Decide whether the feature needs phasing.** The most direct heuristic: would you be comfortable shipping the whole thing in one PR? If yes, skip phasing and move to Phase 2. If no (multiple subsystems, multiple new coordinations, data migration, a security-sensitive surface, or anything that would land too much risk in a single deploy), phase the build. See [Sizing](../sizing.md) for the cross-skill model these signals come from.

### Phase 2: Finalize the spec for this slice

1. **Pick the slice spec you are about to plan.** This step has two paths:
    - **If the feature is phased**, run [`/plan-a-phased-build`](../skills/han.core/plan-a-phased-build.md) against the Phase 1 spec, then run `/plan-a-feature` again for the specific phase you are working on:

        > `/plan-a-phased-build {plan folder}/feature-specification.md`
        >
        > `/plan-a-feature for phase {N} of {plan folder}/build-phase-outline.md`

        You end with a per-phase spec inside the phase's subfolder.

    - **If the feature is not phased**, the spec from Phase 1 is already the slice spec. Skip to step 2.

2. **Manually review the spec, then iterate.** Read what han produced. Look for anything that drifted from the original idea, anything you do not understand, and anything that contradicts a decision you remember making. Push back where needed. Then run [`/iterative-plan-review`](../skills/han.core/iterative-plan-review.md) to refute assumptions, correct inconsistencies, and surface gaps:

    > `/iterative-plan-review {slice spec file}`

    Read the iteration findings. Walk through any new open items before moving on.

### Phase 3: Plan the implementation

1. **Run [`/plan-implementation`](../skills/han.core/plan-implementation.md).** A template that works well:

    > `/plan-implementation {slice spec file}`

    The skill runs a project-manager-led team conversation among specialist sub-agents to produce a `feature-implementation-plan.md` next to the spec. Walk through any open items the project-manager surfaces and decide.

2. **Iterate on the implementation plan.** Run `/iterative-plan-review` again, this time against the implementation plan:

    > `/iterative-plan-review {implementation plan file}`

    Walk through any new open items.

### Phase 4: Break the plan into work

1. **Run [`/plan-work-items`](../skills/han.core/plan-work-items.md).** A template that works well:

    > `/plan-work-items {implementation plan file}`

    The skill writes a `work-items.md` file in the plan folder. Each entry is independently grabbable, sized to be picked up alone, and traceable back to the section of the implementation plan it implements.

2. **Review the work items.** Check that the granularity matches your team's appetite and that nothing important got merged into a single item by mistake. The skill is happy to re-run if you want to resplit.

3. **Hand off.** Turn the items into issue tickets or work them directly. When you sit down to build, run [`/tdd`](../skills/han.coding/tdd.md) on the first item to drive it test-first through a red-green-refactor loop with an enforced observed-failure gate.

## Variations

- **Sharing the spec for non-technical sign-off.** After Phase 1 produces the initial spec, and before you commit to phasing or implementation, run [`/stakeholder-summary`](../skills/han.reporting/stakeholder-summary.md). It produces a plain-language summary with Mermaid diagrams that you can share with leadership, product, or customer-facing reviewers. Run it on the pre-phasing spec so stakeholders see the whole feature, not one slice of it.

- **Re-running a step after a constraint changes.** If a stakeholder reopens a decision after the spec hardens, re-run `/plan-a-feature` with the new context. The existing spec, decision log, and team findings become inputs to the new run, and the `D#` / `F#` IDs carry forward so prior references stay stable. The same is true of `/plan-implementation` against a changed spec.

- **When iterative review surfaces a bigger problem than the plan can fix.** If `/iterative-plan-review` flags a gap that materially changes the spec rather than refining the plan, go back and re-run `/plan-a-feature` for that slice before continuing. The plan is only as good as the spec under it.

## What you should expect at each step

- **Han asks for evidence first.** Most questions arrive with a recommended answer drawn from the codebase, ADRs, or coding standards. Treat the recommendation as the default; redirect only when you have a reason.
- **Open items are not failures.** Every plan-shaped artifact has an Open Items section. If a question cannot be answered with the available evidence, it lands there rather than getting an invented answer. Walk through open items deliberately at the end of each step.
- **Iteration is part of the loop, not a sign something went wrong.** `/iterative-plan-review` is expected to find things. Most runs surface several findings; that is the review doing its job.
- **Sizing scales the team automatically on the sized skills.** `/plan-a-feature`, `/plan-implementation`, `/iterative-plan-review`, and the other [sized skills](../sizing.md) classify the work as small / medium / large and default to small. Pass `medium` or `large` as the first positional argument when you know the work is bigger than the default. Skills not on that list (such as `/plan-work-items`) do not size.

## Where to go next

- [`/tdd`](../skills/han.coding/tdd.md) is the next step when work items are ready to build. It writes the tests and production code into your tree.
- [`/code-review`](../skills/han.core/code-review.md) is the right step after `/tdd` finishes a behavior and before you open a PR.
- [Triage and investigate a bug](./triage-and-investigate-a-bug.md) is the right guide when the work is not a new feature but a fix.
- [Research a decision](./research-a-decision.md) is the right guide when you are not ready to spec because the underlying decision (which library, which pattern, which approach) has not been made yet.
- The skill long-form docs ([plan-a-feature](../skills/han.core/plan-a-feature.md), [plan-a-phased-build](../skills/han.core/plan-a-phased-build.md), [plan-implementation](../skills/han.core/plan-implementation.md), [iterative-plan-review](../skills/han.core/iterative-plan-review.md), [plan-work-items](../skills/han.core/plan-work-items.md), [tdd](../skills/han.coding/tdd.md)) cover each step in depth. The how-to tells you how they fit together; the long-form docs tell you what each one does on its own.

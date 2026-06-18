# Feature Specification: code-overview

A `han-coding` skill that produces a human-readable, progressive-disclosure overview of unfamiliar code (as it is now) or of a pull request's changes (what they do and why), so the operator can get up to speed quickly enough to start working on or reviewing it — without committing any durable documentation and without making any quality judgment.

## Outcome

Running the skill produces a scratch overview document the operator reads to understand a chunk of unfamiliar code or a set of changes. The overview is "good enough" when a reader who has never seen the target can, after reading it: name what the code or change does and why it exists; trace the main flow at a high level; and identify the directly-related context and the entry points they would touch to work on it — at minimal technical depth, oriented toward the operator's next action ([D5](artifacts/decision-log.md#d5-success-bar)). The skill makes no quality findings, recommends no changes, and writes nothing durable into the repository ([D1](artifacts/decision-log.md#d1-purpose-and-positioning)).

## Actors and Triggers

- **Actors** — the operator: a solo or small-team engineer facing code they are unfamiliar with, or a pull request they are about to review.
- **Triggers** — the operator invokes the skill, optionally naming a target and a size.
- **Preconditions** — a readable code target (a file, directory, or symbol) exists, or a set of changes (the working tree, the current branch, or a named pull request) exists. PR mode and the bare-invocation default additionally require version control to be available ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)).

## Primary Flow

The primary flow is **code mode** — explaining code as it is now, the skill's first job ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)).

1. The skill resolves the named target and selects the mode. It resolves the target string by a fixed precedence — an explicit pull-request reference or URL first, then an existing file or directory path, then a symbol — so an ambiguous string never silently picks the wrong mode; a file, directory, or symbol selects code mode ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)).
2. The skill classifies the target's size, starting at small and escalating only on clear signal, and announces the chosen mode and size in one line before dispatching any exploration ([D4](artifacts/decision-log.md#d4-exploration-and-sizing)).
3. The skill explores the surrounding codebase, with exploration breadth scaled to the chosen size, to discover the target's entry points, the directly-related context and uses, and the main process flow. The skill itself performs the synthesis and the charts; exploration only gathers the surrounding code and context the synthesis draws on ([D4](artifacts/decision-log.md#d4-exploration-and-sizing)).
4. The skill writes a progressive-disclosure overview, structured so the most important understanding comes first and detail unfolds beneath it ([D6](artifacts/decision-log.md#d6-overview-structure)). The document opens with a short header naming the target, the mode, and the generation context, then proceeds in this order:
   - **What it does and why** — the single most important orientation fact: what the code is and why it exists.
   - **Main flow** — the main process flow rendered as a flow chart, carrying a one-line scope label that says what the chart covers (and, when coverage is partial, what it leaves out).
   - **Context and uses** — *context* (what the target depends on and must be understood first) and *uses* (where the target is invoked, the blast radius), kept distinguishable so a reader can scan to the one they need.
   - **Where to start** — the concrete entry points (the specific files or components) the operator would open first to begin working.
   The purpose, flow, and context sections stay at the level of what the code does and why — no implementation-level detail a reader would look up in the code itself — while the where-to-start section names concrete enough entry points to be actionable ([D5](artifacts/decision-log.md#d5-success-bar)).
5. When the target is too large to cover fully at the chosen size, the overview adds a named coverage note immediately after the header — present only when coverage is partial — that says what was not covered and the next size up, so the reader calibrates before investing in the charts ([D4](artifacts/decision-log.md#d4-exploration-and-sizing)).
6. The skill writes the overview to a scratch file outside the repository, shows it to the operator, and reports the file path ([D3](artifacts/decision-log.md#d3-output-destination)).

## Alternate Flows and States

### PR mode — explaining a set of changes

- **Entry condition:** the named target is a pull request reference or URL, or — when no target is named — the current branch's changes ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)).
- **Sequence:** the skill gathers the change set (the diff and the code it touches), announces mode and size, explores the surrounding code the change affects with breadth scaled to size, then writes a progressive-disclosure overview that mirrors code mode's grammar ([D6](artifacts/decision-log.md#d6-overview-structure)): the same document header, then **What this change does and why** (the bottom line of the change), then **Changes by intent** (the changes grouped by the reader-visible outcome each group delivers — what a reviewer would say changed and why, not grouped by file, layer, or author motivation; a single logical change is presented as one narrative with no grouping header), then **How the change flows** (a flow chart, with a scope label, of how the change moves through or affects the system — placed after the grouped changes because the reviewer must know what changed before that chart is meaningful), then **What to watch when reviewing** (a navigational section naming where the change is hardest to follow and why — the areas that touch the most other code or need the most context — and never a quality or risk judgment).
- **Exit:** the operator has an orientation to the PR that tells them how to look at it before they review — it does not review the PR or raise findings ([D1](artifacts/decision-log.md#d1-purpose-and-positioning)).

### No target named — default to the current branch's changes

- **Entry condition:** the skill is invoked with no explicit target ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)).
- **Sequence:** the skill defaults to the current branch's changes in PR mode, which runs on the local diff and does not require a remote pull request. If the working tree is clean and the branch carries no changes, the skill asks the operator for a code target rather than producing an empty overview.
- **Exit:** either a PR-mode overview of the branch's changes, or a request for a target.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
|-----------|-------------------|
| Invoked with no target and the working tree is clean with no branch changes | The skill asks the operator for a code target instead of producing an empty overview. |
| Named file path or symbol cannot be resolved, or a symbol is ambiguous across several definitions, or a string matches nothing | The skill reports what it could not resolve and asks the operator to disambiguate, rather than guessing ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)). |
| An explicitly named pull request cannot be reached — it does not exist or repository access is unavailable | The skill says so and offers to run code mode against a local target instead. (A bare invocation with local changes but no remote pull request is not this case — it runs PR mode on the local diff.) |
| Version control is unavailable | Code mode against a named target still runs; PR mode and the bare-invocation default report that they need version control to read changes ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)). |
| The target is too large to cover fully at the chosen size | The skill covers the highest-signal areas, adds the coverage note (Primary Flow step 5) naming what it left out, and suggests narrowing the target or re-running at a larger size ([D4](artifacts/decision-log.md#d4-exploration-and-sizing)). |

## User Interactions

- **Affordances:** the operator passes an optional target and an optional size when invoking the skill; with no target, the skill falls back to the current branch's changes.
- **Feedback:** before dispatching any exploration the skill announces the chosen mode and size in one line; at the end it shows the overview and reports the scratch-file path.
- **Error states:** the conditions in Edge Cases and Failure Modes — an unresolved target, an unreachable named pull request, unavailable version control, an empty change set, or a too-large target — each surface as a plain message that tells the operator what is wrong and what to do next.

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| Codebase exploration | internal | The skill explores the surrounding codebase, breadth scaled to size, to gather context, uses, and flow for its own synthesis ([D4](artifacts/decision-log.md#d4-exploration-and-sizing)). | Read-only; the skill changes no code. |
| Version-control change set (working tree, branch, or pull request) | inbound | Source of the diff and changed-file set in PR mode ([D2](artifacts/decision-log.md#d2-modes-and-target-resolution)). | Read-only snapshot taken at invocation. |

## Out of Scope

- **Modifying code.** The skill is read-only; it explains, it does not edit ([D9](artifacts/decision-log.md#d9-read-only)).
- **Quality judgment.** The skill surfaces no review findings, severities, or recommended changes — including in the "what to watch when reviewing" section, which is navigational only. Reviewing a PR's quality is `code-review`'s job; code-overview only helps the operator understand the PR before they review it ([D1](artifacts/decision-log.md#d1-purpose-and-positioning)).
- **Durable documentation.** The skill produces an ephemeral, point-in-time orientation aid written outside the repository. Writing and maintaining feature or system docs in the repository's documentation tree is `project-documentation`'s job ([D1](artifacts/decision-log.md#d1-purpose-and-positioning), [D3](artifacts/decision-log.md#d3-output-destination)).
- **Architectural assessment.** Coupling, cohesion, and structural-risk analysis belong to `architectural-analysis`.
- **Bug diagnosis.** Root-causing a failure or unexpected behavior belongs to `investigate`.

## Deferred (YAGNI)

### Explaining an arbitrary commit range or remote branch
- **Why deferred:** simpler-version test. The two jobs the issue describes — code I need to work on, and a PR I am about to review — are satisfied by the current branch's changes plus a named pull request. Supporting arbitrary commit ranges, tags, or remote comparison branches adds target-resolution surface no stated need requires.
- **Reopen when:** an operator describes a concrete case where neither the current branch nor a named pull request captures the changes they need to understand (for example, reviewing a stacked range mid-branch).
- **Source:** conversation during specification.

## Open Items

<!-- Populated by the project-manager during synthesis if any question could not be resolved. -->

## Summary

- **Outcome delivered:** the operator gets a scratch, progressive-disclosure overview that accelerates them to working on unfamiliar code or reviewing an unfamiliar PR, with no durable artifact and no quality judgment.
- **Primary actors:** the operator (a solo or small-team engineer).
- **Decisions settled by evidence:** 5 (D1, D6, D9, and the trivial D7, D8) — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 4 (D2, D3, D4, D5) — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** han-core:junior-developer, han-core:information-architect — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** the two modes were aligned to one parallel progressive-disclosure grammar with content-bearing headings, the "what to watch" section was constrained to navigation so the `code-review` boundary stays crisp, and target-resolution precedence, the no-version-control path, and a partial-coverage note were specified. — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 0

# Feature Specification: Choosing a Han Plugin

New documentation that explains how Han is split into `han.core`, `han.github`, and the `han` meta-plugin, and helps a reader at the install decision point confidently pick what to install. The outcome is a reader who understands the three-plugin structure, understands that `han.github` pulls in `han.core` as a dependency, and installs the right plugin for their situation on the first try.

## Outcome

A reader deciding what to install comes away knowing three things without having to read source manifests:

1. **What the split is.** `han.core` carries the planning, investigation, review, and documentation skills plus every agent. `han.github` carries the GitHub-facing skills (`gh-pr-review`, `update-pr-description`) and depends on `han.core`. `han` is a meta-plugin with no components of its own that depends on both.
2. **What each install command gives them.** `han`, `han.core`, and `han.github` are presented as first-class install options, each with an explicit statement of what lands when you install it, including the dependency behavior ([D4](artifacts/decision-log.md#d4-three-commands-first-class)).
3. **Which one to pick.** The documentation recommends the full `han` meta-plugin as the default for almost everyone, and frames core-only as the deliberate choice for a reader who does not want the GitHub PR skills ([D3](artifacts/decision-log.md#d3-recommended-default-posture)).

Success is observable as a reader who picks core-only or the full suite on purpose, and who is not confused about whether installing `han.github` also gives them the planning and review skills.

## Actors and Triggers

- **Actors** — a developer or engineering lead evaluating or installing Han. They are at the front door, not yet committed, deciding what to add to Claude Code.
- **Triggers** — the reader reaches the README install section, the Concepts page, or the Quickstart and asks "which of these do I install?" A reader may also arrive directly at the standalone page from a search result or an external link.
- **Preconditions** — the three plugins (`han`, `han.core`, `han.github`) exist in the marketplace with the dependency relationship already in place. This documentation describes the existing structure; it does not change it.

## Primary Flow

The deliverable is four coordinated documentation surfaces. The "flow" is the reader's path through them.

1. The reader lands on the **README**. The install section already names all three plugins and gives all three commands; the change extends it rather than rewriting it ([D1](artifacts/decision-log.md#d1-deliverable-shape)). The extended section presents the three install commands as first-class options, recommends the full `han` meta-plugin as the default starting point, states inline that there is no GitHub-only install (installing `han.github` pulls in `han.core` through its dependency), and carries a direct inline link to the standalone page so a reader who scrolls straight to "Installation" still finds the full explanation ([D3](artifacts/decision-log.md#d3-recommended-default-posture), [D4](artifacts/decision-log.md#d4-three-commands-first-class), [D7](artifacts/decision-log.md#d7-findability-entry-points)).
2. A reader who wants more than the install snippet follows the link to the **new standalone page** (`docs/choosing-a-han-plugin.md`) ([D1](artifacts/decision-log.md#d1-deliverable-shape), [D2](artifacts/decision-log.md#d2-page-location-and-name)). The page opens with an audience / time-to-read / outcome line and links back up to the README, matching the established decision-doc pattern ([D8](artifacts/decision-log.md#d8-page-framing-and-link-up)).
3. The standalone page explains the split, then explains the dependency relationship in plain language: installing `han.github` resolves and installs `han.core` too, so it lands the same skills and agents as the full suite, and there is no GitHub-only install ([D5](artifacts/decision-log.md#d5-dependency-nuance-content)). This dependency explanation appears before the decision aid; the decision aid is never the first substantive content on the page, so a reader scanning for the table has the load-bearing fact before they act on it ([D6](artifacts/decision-log.md#d6-decision-aid-format)).
4. The page then presents a short decision aid — a "which one do you need?" guide a reader can scan and act on — that maps a reader's situation to a recommended install command and structurally marks the recommended default (a "start here" signal on the full `han` option), so a reader comparing the two full-suite commands can resolve the choice without dropping back into prose ([D6](artifacts/decision-log.md#d6-decision-aid-format)).
5. A reader who arrived through the **Concepts** page finds a short section describing the three-plugin structure, with a pointer to the standalone page for the install decision. A reader on the **Quickstart** finds a pointer in its opening frame, before the path list, routing the "which plugin?" question to the standalone page. A reader who just confirmed Han fits them on the **why-solo-and-small-teams** page finds a direct link from its "If Han is your fit" callout to the standalone page ([D7](artifacts/decision-log.md#d7-findability-entry-points)).

## Alternate Flows and States

### Reader wants only the GitHub skills

- **Entry condition:** the reader wants `gh-pr-review` / `update-pr-description` but not the planning and review skills.
- **Sequence:** the documentation states that this is not possible — `han.github` depends on `han.core`, so installing the GitHub skills always brings the core skills and all agents with them ([D5](artifacts/decision-log.md#d5-dependency-nuance-content)).
- **Exit:** the reader installs `han.github` (or `han`) understanding they are getting the full suite, not a GitHub-only subset.

### Reader starts with core, adds GitHub later

- **Entry condition:** the reader installed `han.core` only, and later decides they want the GitHub PR skills.
- **Sequence:** the documentation states they can install `han.github` (or `han`) afterward to add the GitHub layer on top of the core they already have ([D9](artifacts/decision-log.md#d9-composability-note)).
- **Exit:** the reader has the full suite without having to uninstall or reinstall core.

## Edge Cases and Failure Modes

| Condition | Required Behavior |
|-----------|-------------------|
| Reader conflates "install `han.github`" with "GitHub features only, no planning skills" | The documentation explicitly corrects this in both the README install section and the standalone page: `han.github` pulls in `han.core`, so it lands the full set of skills and agents. There is no GitHub-only install ([D5](artifacts/decision-log.md#d5-dependency-nuance-content)). |
| Reader cannot tell whether `han` and `han.github` differ in what they install | The documentation states that both land the same skills and agents (core + GitHub). The visible difference is which named plugins appear in the installed list (`han.github` plus `han.core`, versus `han`), and `han` is the recommended way to ask for everything because future additions to the suite arrive through its dependencies ([D4](artifacts/decision-log.md#d4-three-commands-first-class)). |
| Reader has no GitHub PRs in their workflow | The documentation points this reader to `han.core` as the deliberate lean choice ([D3](artifacts/decision-log.md#d3-recommended-default-posture)). |
| Standalone page and README install section drift out of sync over time | One surface is canonical for the full explanation (the standalone page); the README carries the short version and links to it, so the detailed content has a single home ([D7](artifacts/decision-log.md#d7-findability-entry-points)). |

## User Interactions

The reader's interaction is reading and navigating documentation. The affordances are wayfinding, not UI controls.

- **Affordances:** install commands the reader can copy and run; cross-links that lead to the standalone page from the README "Which path are you on?" list (using a question-form label consistent with the existing entries, e.g. "Deciding which plugin to install?"), the README "Documentation" list, the README install section's own inline prose, the Concepts page, the Quickstart's opening frame, and the why-solo-and-small-teams "If Han is your fit" callout; a scannable decision aid on the standalone page that structurally marks the recommended default ([D6](artifacts/decision-log.md#d6-decision-aid-format), [D7](artifacts/decision-log.md#d7-findability-entry-points)).
- **Feedback:** each install command is paired with a plain statement of what it installs, so the reader can confirm their choice before running it.
- **Error states:** the "no GitHub-only install" correction (present on both the README install section and the standalone page) and the "`han` and `han.github` land the same skills and agents" clarification pre-empt the two predictable misreadings before the reader acts on them.

## Coordinations

| Coordinating System | Direction | Interaction | Ordering / Consistency Requirement |
|---------------------|-----------|-------------|-----------------------------------|
| README | outbound | The existing install section is extended to present the three commands, recommend `han`, carry the no-GitHub-only correction, and link to the standalone page | The README install section carries the short version (the three commands, a one-line description of each, the recommendation, the no-GitHub-only correction) and links out; the standalone page is canonical for the full split explanation, the dependency mechanics, the composability path, and the decision aid. The two must not both carry the long-form explanation ([D7](artifacts/decision-log.md#d7-findability-entry-points)) |
| Concepts page | outbound | A short section on the three-plugin structure is added, pointing to the standalone page for the install decision | Must use the same plugin names and dependency facts as the standalone page and the manifests |
| Quickstart | outbound | A pointer is added in the opening frame, before the path list, routing the "which plugin?" question to the standalone page | Consistent with the README "Which path are you on?" entry; placed where a cold-arrival pre-install reader sees it before being told to pick a path |
| why-solo-and-small-teams page | outbound | A direct link is added from the "If Han is your fit" callout to the standalone page | Routes the highest-intent pre-install reader to install-choice guidance in one hop |
| Plugin manifests (`marketplace.json`, the three `plugin.json` files) and the Claude Code plugin runtime | inbound | The source of truth for plugin names, descriptions, and the dependency relationship; the runtime resolves and installs declared dependencies automatically at install time | The documentation must match the manifests and the runtime's documented dependency behavior; if a manifest changes, the documentation is the dependent and must follow |

## Out of Scope

- Changing the plugin structure, the manifests, or the dependency relationship. This documents what exists; it does not restructure it.
- Per-skill or per-agent install instructions. The documentation routes to the existing skills and agents indexes rather than enumerating every component.
- A full inventory of every `han.core` skill on the standalone page. Core is summarized by category with a link to the skills index; the two `han.github` skills are named explicitly because the set is small ([D6](artifacts/decision-log.md#d6-decision-aid-format)).
- Documenting how to author or publish plugins. That lives in `CONTRIBUTING.md` and `han.plugin-builder/skills/guidance/references/`.

## Deferred (YAGNI)

### Upgrade / migration guidance for readers coming from a pre-split monolithic `han`

- **Why deferred:** evidence test. The issue and the conversation are about new-install choice, not upgrades. There is no reported incident or user confusion on disk showing that readers upgrading from a pre-3.0 monolithic `han` are stuck or surprised. Adding a migration section now would be writing for a problem no evidence shows exists.
- **Reopen when:** a user reports confusion or breakage upgrading from a pre-split `han` install, or the maintainer confirms the pre-3.0 `han` package needs an explicit migration note.
- **Source:** conversation context during specification.

## Open Items

- **OI-1:** The exact prose, headings, and decision-aid wording for each surface are written during implementation, not fixed here. The spec commits to what each surface must communicate, not the sentences.
  - **Resolves when:** the documentation is drafted under `/plan-implementation` or the doc-writing skill, then reviewed for voice and findability.
  - **Blocks implementation:** No — this is the expected hand-off from spec to implementation.

## Summary

- **Outcome delivered:** A reader at the install decision point understands the three-plugin split and the `han.github` → `han.core` dependency, and installs the right plugin on the first try.
- **Primary actors:** a developer or engineering lead evaluating or installing Han.
- **Decisions settled by evidence:** 6 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Decisions settled by user input:** 4 — see [artifacts/decision-log.md](artifacts/decision-log.md)
- **Sub-agents consulted:** junior-developer, information-architect — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Key adjustments from review:** verified the auto-install dependency behavior against the official runtime docs; narrowed the `han` / `han.github` equivalence to "same skills and agents" (the installed plugin list still differs); made the dependency explanation precede the decision aid; added the no-GitHub-only correction to the README itself and a fifth entry point from the why-solo page — see [artifacts/team-findings.md](artifacts/team-findings.md)
- **Remaining open items:** 1

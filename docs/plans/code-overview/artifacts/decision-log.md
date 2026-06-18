# Decision Log: code-overview

<!-- Behavioral statements live in ../feature-specification.md; this file captures the history, rationale, evidence, and rejected alternatives for each decision. -->

## Trivial decisions

- D7: Plugin placement — the skill ships in `han-coding`, alongside `code-review`, `investigate`, and the other in-code skills, as the issue specifies. — Referenced in spec: title, Outcome.
- D8: Output format — the overview is Markdown with Mermaid flow charts, the format the issue names and the one already used across the suite for diagrams. — Referenced in spec: Primary Flow, PR mode, Overview structure.

## Full decisions

### D1: Purpose and positioning

- **Question:** What is this skill for, and how does it sit between `code-review` and `project-documentation`?
- **Decision:** The skill is an orientation aid: it explains a chunk of code as it is now, or what a PR's changes do and why, to accelerate the operator to the point of working on or reviewing it. It makes no quality findings and writes nothing durable. The line against `code-review` is "understand this PR" vs "review this PR" — code-overview never raises findings, severities, or recommended changes. The line against `project-documentation` is "understand now" vs "document for future reference" — code-overview produces an ephemeral artifact, not maintained repository docs.
- **Rationale:** The issue frames the skill as sitting "somewhere between `project-documentation` and `code-review`" with an explicit understand-now-not-document-for-later goal, and asks the spec to pin both boundaries concretely. Holding the skill to zero findings and zero durable output is what keeps the two boundaries non-overlapping.
- **Evidence:** issue #82 (Summary, Job to be done, Where it fits, Open questions); `han-coding/skills/code-review/SKILL.md` (severity-rated findings, the behavior code-overview must not duplicate); `han-core/skills/project-documentation/SKILL.md` (durable docs in the repo tree, the behavior code-overview must not duplicate).
- **Rejected alternatives:**
  - Let the overview include light quality observations ("this looks risky") — rejected because it collapses the boundary with `code-review` and turns an orientation aid into a half-review. The review surfaced the PR-mode "what to watch" section as the place this could leak (F3); it was constrained to navigation only.
  - Let the overview be saved as project documentation — rejected because it collapses the boundary with `project-documentation`; see D3.
- **Linked technical notes:** —
- **Driven by findings:** F3
- **Dependent decisions:** D3, D5, D9
- **Referenced in spec:** Outcome, PR mode, Out of Scope

### D2: Modes and target resolution

- **Question:** What are the modes, how is the target named, how is the mode chosen, and what happens with no target?
- **Decision:** Two modes — code mode (explain code as it is now) and PR mode (explain a set of changes). The skill infers the mode from the target's shape, resolving the target string by a fixed precedence: an explicit pull request reference or URL first, then an existing file or directory path, then a symbol. A file, directory, or symbol selects code mode; a pull request reference or URL selects PR mode. With no target named, the skill defaults to the current branch's changes in PR mode, which runs on the local diff and requires no remote pull request; if the working tree is clean and the branch carries no changes, it asks the operator for a code target. A remote pull request is required only when one is explicitly named. PR mode and the bare-invocation default require version control to be available; when it is absent, code mode against a named target still runs and the version-control-dependent paths report that they cannot read changes. A target string that matches nothing is reported as unresolved.
- **Rationale:** The issue names both situations (code I need to work on; a PR I am about to review) and asks how the target is named and how the modes are selected. Inferring mode from target shape avoids a mode flag the operator has to remember; the fixed precedence keeps an ambiguous string (a branch name that also matches a directory; a short symbol that also matches a filename) from silently selecting the wrong mode. Defaulting a bare invocation to the current branch's changes mirrors the established convention in `code-review`, which defaults to the current branch, so the suite stays consistent. Making the branch diff sufficient for PR mode (no remote pull request needed) resolves the contradiction the review found between the no-target default and the unreachable-pull-request edge case.
- **Evidence:** issue #82 (Job to be done, Open questions — target specification); user input (chose "auto-detect; default to branch diff"); `han-coding/skills/code-review/SKILL.md` (defaults review to the current branch's changes; checks git availability and has a no-git fallback).
- **Rejected alternatives:**
  - Ask which mode and target on every bare invocation — rejected because a sensible default (the branch diff) is faster and matches `code-review`; the skill still asks when the default is empty.
  - Make code mode the only default and require an explicit PR reference for PR mode — rejected because the branch diff is the most common "what am I about to review" case and deserves a zero-argument path.
  - Leave target precedence unspecified — rejected after F1: an ambiguous string would silently pick the wrong mode with no error.
- **Linked technical notes:** —
- **Driven by findings:** F1, F4, F5
- **Dependent decisions:** D4
- **Referenced in spec:** Actors and Triggers, Primary Flow, PR mode, No target named, Edge Cases and Failure Modes, Coordinations

### D3: Output destination

- **Question:** Where is the overview delivered — inline only, a scratch file, or the repository docs tree?
- **Decision:** The skill always writes the overview to a scratch file outside the repository (for example under the system temp location), then shows it and reports the path.
- **Rationale:** A file renders the progressive-disclosure structure and Mermaid flow charts reliably and is easy to share, while keeping the artifact outside the repository preserves the understand-now-not-document boundary (D1) — the overview is never committed as project documentation. The user chose this over inline-only delivery and over writing into the repository docs tree. The behavioral commitment is "a scratch location outside the repository"; the specific directory is left to implementation (F14).
- **Evidence:** user input (chose "always a /tmp file"); issue #82 (progressive disclosure, Mermaid flow charts, understand-now-not-document framing); `han-atlassian`'s opt-in publishing skills use a scratch file outside the repository for the same review-then-decide pattern.
- **Rejected alternatives:**
  - Present inline in the conversation only — rejected because Mermaid does not render in the terminal and the artifact is harder to share, though it is the most clearly ephemeral option.
  - Write into the repository docs tree (like `project-documentation`) — rejected because it collapses the boundary with `project-documentation` and contradicts understand-now-not-document (D1).
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Out of Scope

### D4: Exploration and sizing

- **Question:** Does the skill dispatch exploration agents and scale with sizing like the other swarming skills, or stay lean?
- **Decision:** The skill dispatches codebase exploration scaled to sizing, with a lean roster: exploration agents only (no multi-specialist review swarm). It starts size classification at small and escalates only on clear signal — small targets get a single explorer, medium gets a few, large gets more — and announces the chosen mode and size before dispatching. The skill itself performs the synthesis (the grouping, the charts, the orientation) in both modes; exploration is dispatched only to discover the surrounding code and context that synthesis draws on. When a target is too large to cover fully at the chosen size, the skill covers the highest-signal areas and adds a named coverage note (immediately after the document header, present only when coverage is partial) saying what it left out and the next size up; it does not run a partial-coverage scoring algorithm — highest-signal-first is what the sizing model already implies.
- **Rationale:** The issue explicitly asks whether the skill dispatches existing agents (naming `codebase-explorer`) and scales with sizing like the other swarming skills. Discovering entry points, uses, and flow is exactly what `codebase-explorer` does, so reusing it is evidence-backed rather than speculative; scaling with sizing keeps exploration cost proportional to target size, consistent with the suite-wide sizing model. The roster stays lean — explorers only — because this is read-only orientation, not the multi-specialist correctness/security audit that justifies `code-review`'s full roster. The review (F6) flagged that the exploration agent's job is code-as-it-is discovery, not PR-mode synthesis; keeping synthesis in the skill and using exploration only for context resolves that without extending the agent. The review also weighed refusing-and-resizing against partial output (F11); partial output with a coverage note was kept because refusing to produce anything contradicts the job-to-be-done (accelerate understanding), while the simpler-version test was applied to the disclosure rather than dropped.
- **Evidence:** issue #82 (Open questions — agent dispatch and sizing); user input (chose "dispatch explorers + size, lean roster"); `han-core` `codebase-explorer` agent (discovers entry points, core logic, data models, configuration, tests for a feature or system); `docs/sizing.md` (the small/medium/large model and the default-to-small posture used across swarming skills).
- **Rejected alternatives:**
  - A single main agent reads and explains with no sub-agent dispatch and no sizing — rejected because it under-covers larger, unfamiliar targets, which are exactly the case the skill exists for.
  - A full `code-review`-style multi-specialist swarm — rejected as over-built for an orientation aid; the extra specialists produce judgment and findings the skill is defined not to emit (D1).
  - Refuse and ask the operator to re-run at a larger size when a target is too large — rejected (F11) because producing nothing contradicts the accelerate-understanding job; the skill produces the highest-signal overview with a coverage note instead.
- **Linked technical notes:** —
- **Driven by findings:** F6, F11
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, Edge Cases and Failure Modes, Coordinations

### D5: Success bar

- **Question:** What is the success criterion that makes an overview count as accelerating understanding?
- **Decision:** An overview is good enough when a reader unfamiliar with the target can, after reading it: name what the code or change does and why it exists; trace the main flow at a high level; and identify the directly-related context and the entry points they would touch to work on it — all at minimal technical depth, oriented to the operator's next action. The minimal-detail constraint is scoped per section: the purpose, flow, and context sections carry no function signatures, data-shape definitions, or configuration values, while the where-to-start (and PR-mode what-to-watch) sections have a specificity floor — they must name the concrete entry points (the specific files or components) the operator would open first, or they fail to be actionable.
- **Rationale:** The issue asks for an explicit success criterion and stresses minimal technical detail and human understandability first. A criterion framed around naming-purpose, tracing-flow, and finding-where-to-act gives the skill a concrete bar to hit and tells the synthesis what to include and what to leave out. The review (F2) showed that an unscoped "minimal detail" both leaves the synthesizing agent without a testable ceiling and strips the where-to-start section of the specificity it needs; scoping the constraint per section resolves both — minimal everywhere the reader is orienting, concrete where the reader is about to act.
- **Evidence:** issue #82 (Output perspective — progressive disclosure, minimal technical detail; Open questions — success criteria); user input (chose "name + flow + where to act").
- **Rejected alternatives:**
  - Also include edit-level detail (key data shapes, important function-level detail) throughout — rejected because it pushes toward the technical depth the issue wants minimized; deferred-detail is available by reading the code the overview points to.
  - Purpose and flow only, with no entry-point or context orientation — rejected because it is often not enough to actually start working on the code, which is the first stated job.
  - Apply "minimal detail" uniformly across all sections — rejected after F2 because it strips the where-to-start section of actionable specificity.
- **Linked technical notes:** —
- **Driven by findings:** F2
- **Dependent decisions:** D6
- **Referenced in spec:** Outcome, Primary Flow

### D6: Overview structure

- **Question:** How is the overview itself structured?
- **Decision:** The overview uses progressive disclosure — the most important understanding first, detail unfolding beneath it — under a shared grammar across both modes: a short document header (target, mode, generation context), an optional coverage note (only when coverage is partial), a content-bearing lead section, a grouped/flow body, and an actionable handoff with parallel labeling. In **code mode**: *What it does and why* → *Main flow* (a flow chart) → *Context and uses* → *Where to start*. In **PR mode**: *What this change does and why* → *Changes by intent* → *How the change flows* (a flow chart) → *What to watch when reviewing*. Specific structural commitments:
  - **Content-bearing headings.** The lead section is named for its content ("What it does and why"), not internal shorthand like "bottom line," so a reader scanning the document cold gets orientation from the heading.
  - **Chart scope labels.** Every flow chart carries a one-line scope label saying what it covers and, for partial coverage, what it excludes, so a chart can stand alone.
  - **Parallel modes.** Both modes share lead → body → handoff with parallel labels and a parallel final handoff section. PR mode places *Changes by intent* before *How the change flows* — the one deliberate departure from code mode's chart-second order — because a reviewer must know what changed before the change-flow chart is meaningful.
  - **Context vs uses.** In code mode, *context* (what the target depends on and must be understood first) and *uses* (where the target is invoked, the blast radius) are kept distinguishable, presented together for small targets and separable for larger ones.
  - **Grouping by intent.** In PR mode, changes are grouped by the reader-visible outcome each group delivers (what a reviewer would say changed and why), not by file, layer, or author motivation; a single logical change is presented as one narrative with no grouping header.
  - **What to watch is navigational.** The PR-mode handoff section names where the change is hardest to follow and why (the areas touching the most other code or needing the most context) — never a quality or risk judgment, which would breach D1.
- **Rationale:** The issue makes progressive disclosure and flow charts first-class output requirements. Ordering each mode's sections around the success bar (D5) — purpose, then flow, then where-to-act — makes the structure satisfy the criterion by construction. The information-architect review drove the structural commitments: content-bearing headings for scent (F7), chart scope labels for standalone comprehension (F8), a shared parallel grammar so a reader who learns one mode can scan the other (F9), the context/uses split for distinct reader tasks (F10), a concrete grouping criterion and degenerate case (F12), and a self-identifying document header (F13). The partial-coverage note placement and the decision to keep partial output rather than refuse (F11) shaped where the coverage note sits in the document grammar. The "what to watch" framing was constrained to navigation (F3) to keep the `code-review` boundary (D1) crisp.
- **Evidence:** issue #82 (Output perspective — progressive disclosure first, flow charts that illustrate how the code and its context work); information-architect review (F3, F7–F13).
- **Rejected alternatives:**
  - A flat narrative with no layered structure — rejected because it contradicts the explicit progressive-disclosure requirement.
  - Fully parallel mode order with the chart always second — rejected for PR mode (F9) because the change-flow chart is only meaningful after the reviewer knows what changed by intent.
- **Linked technical notes:** —
- **Driven by findings:** F3, F7, F8, F9, F10, F11, F12, F13
- **Dependent decisions:** —
- **Referenced in spec:** Primary Flow, PR mode

### D9: Read-only

- **Question:** Does the skill ever change code?
- **Decision:** The skill is strictly read-only. It reads code and changes, explores, and writes only its own scratch overview file; it never edits the target.
- **Rationale:** The job is understanding, not modification. Read-only behavior keeps the skill safe to point at unfamiliar code and reinforces the boundary against the execution skills (`tdd`, `refactor`).
- **Evidence:** issue #82 (Job to be done — accelerate learning and understanding, not change code); `han-core` `codebase-explorer` and the other read-only analysis agents follow the same posture.
- **Rejected alternatives:**
  - Allow the skill to apply small clarifying edits (renames, comments) while explaining — rejected because any edit turns an orientation aid into an execution skill and breaks the read-only guarantee.
- **Linked technical notes:** —
- **Driven by findings:** —
- **Dependent decisions:** —
- **Referenced in spec:** Out of Scope

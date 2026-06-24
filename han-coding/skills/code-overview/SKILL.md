---
name: "code-overview"
description: >
  Produces a human-readable, progressive-disclosure overview of unfamiliar code or a pull
  request's changes — what the code does, how it flows, and where to start — so you can get up
  to speed before working on or reviewing it. Use when you want to understand, get oriented in,
  make sense of, explain, or get up to speed on a chunk of code, a file, a directory, a symbol,
  or a PR's changes. Writes the overview to a scratch file and changes no code. Does not review
  code quality or raise findings — use code-review for auditing changes or post-code-review-to-pr
  for posting them. Does not produce durable feature or system documentation — use
  project-documentation. Does not assess architecture or structural risk — use
  architectural-analysis. Does not diagnose bugs or root-cause failures — use investigate.
arguments: size
argument-hint: "[size: small | medium | large] [target: file, directory, symbol, or PR reference — defaults to the current branch's changes]"
allowed-tools: Read, Glob, Grep, Agent, Write, Bash(git *), Bash(gh *), Bash(find *)
---

## Project Context

- git installed: !`which git`
- gh installed: !`which gh`
- CLAUDE.md: !`find . -maxdepth 1 -name "CLAUDE.md" -type f`
- project-discovery.md: !`find . -maxdepth 3 -name "project-discovery.md" -type f`

## Operating Principles

Read these before doing anything. They constrain every step below.

- **The skill orchestrates and synthesizes; the agents discover, validate, then refine.** The skill resolves the target, classifies size, dispatches exploration, and writes the overview. `han-core:codebase-explorer` agents gather the surrounding code and context the synthesis draws on — they do not write the overview. After the draft is written, `han-core:adversarial-validator` re-reads the code to challenge the draft's claims for accuracy, and `han-core:information-architect` and `han-core:junior-developer` review it for progressive disclosure and readability; the skill applies their recommendations. The skill itself produces the grouping, the charts, the orientation, and the final rewrite.
- **Read-only, always.** The skill explains; it never edits the target. It writes only its own scratch overview file. BECAUSE the job is understanding, not modification — this keeps the skill safe to point at unfamiliar code.
- **Accurate to the code, always.** Every claim the overview makes — what the code does, each flow step, each named entry point, each change grouped by intent — must be grounded in the actual code, never inferred past the evidence or invented. BECAUSE a confidently wrong overview is worse than none: it sends the reader to the wrong file with false confidence and silently corrupts the mental model the skill exists to build. The adversarial validation pass (Step 7) exists to catch this. It is accuracy control on the *description*, NOT a quality judgment about the code — the two are different lines, and crossing into the second is still forbidden.
- **No quality judgment, ever.** The overview raises no findings, severities, or recommended changes — including in the PR-mode "what to watch" section, which is navigational only. BECAUSE reviewing a PR's quality is `code-review`'s job; this skill only helps the operator understand the PR before they review it. Crossing this line collapses the boundary between the two skills.
- **No PR statistics, ever.** The overview never states lines changed, files changed, additions/deletions, commit counts, or any other diff-stat figure — not in the intro, not in a section, not anywhere. BECAUSE these numbers go stale the instant the PR is updated and add no understanding; describe what changed and why, never how big the diff is.
- **Ephemeral, not documentation.** The overview is written to a scratch file outside the repository and is never committed into the repository's documentation tree. BECAUSE durable feature and system docs are `project-documentation`'s job; this skill is an understand-now orientation aid.
- **Default to small.** Start size classification at small and escalate only when a higher-band signal is clearly present. BECAUSE under-dispatching is recoverable by re-running larger; over-dispatching burns tokens and dilutes the overview.
- **Minimal technical detail, scoped per section.** Keep the purpose, flow, and context sections at the level of what the code does and why. The where-to-start / what-to-watch handoff is the one exception — it must name concrete entry points or it is not actionable.
- **The output template lives at [references/overview-template.md](./references/overview-template.md).** Render that template; do not invent a structure inline.

# Produce a Code Overview

## Step 1: Resolve the Target and Select the Mode

**Bind `$size`.** If the user passed `small`, `medium`, or `large` as the first positional argument, bind `$size` to it. Anything else is part of the target, not a size; bind `$size` to the literal `none provided`.

**Note tool availability.** Read `git installed` and `gh installed` from Project Context. If `git installed` is empty, git is unavailable — see the degraded paths below.

**Resolve the target and mode by this fixed precedence**, so an ambiguous string never silently selects the wrong mode:

1. **An explicit pull request reference or URL** (e.g. `#82`, `https://github.com/owner/repo/pull/82`) → **PR mode** against that pull request. Requires `gh`; if `gh installed` is empty, tell the user `gh` is needed to read a named pull request and offer code mode against a local target instead.
2. **An existing file or directory path** (confirm it resolves with Glob or find) → **code mode** on that path.
3. **A symbol** (a function, class, type, or other named code entity) → **code mode** on that symbol. Resolve it with Grep across the repository.
4. **No target string given** → **PR mode** against the current branch's changes (the local diff). This requires git, not a remote pull request.

**Handle the unresolvable and empty cases** (state the problem plainly and stop; never guess):

- A path or symbol that resolves to nothing, or a symbol ambiguous across several definitions → report what could not be resolved and ask the user to disambiguate.
- No target given and the working tree is clean with no branch changes → ask the user for a code target rather than producing an empty overview.
- No target given and git is unavailable → tell the user PR mode and the bare-invocation default need git to read changes, and ask for a named code target (code mode still runs without git).

**Resolve project context.** If `CLAUDE.md` is present, read its `## Project Discovery` section for conventions; fall back to `project-discovery.md`. These resolve language and framework questions so the explorers infer less. If neither exists, note that surrounding-code inference applies and pass that into the briefs.

## Step 2: Classify Size and Announce

**Classify the target's size. Default to small**; escalate only on a clear signal, and stay at the smaller band when a signal is borderline.

- **Small** *(default)* — a single file, a single symbol, or a small change set (a few files in one subsystem).
- **Medium** — a directory or module, or a moderate change set (several files across one or two adjacent subsystems).
- **Large** — multiple subsystems, or a large change set (many files across several subsystems).

**Apply the size override.** If `$size` is not `none provided`, use it as the band and skip the signal-based classification; a conversational override ("give me a large overview") is equivalent.

**Announce the chosen mode and size in one line before dispatching any exploration** — for example, `Code mode, size medium: directory \`src/auth/\` spanning the session and token subsystems.` State tool degradation in the same line when it applies (`git unavailable — code mode only`). Proceed without a blocking confirmation; this skill is read-only and re-runnable, so a gate here would gate a reversible operation. Honor any adjustment the user makes.

## Step 3: Gather the Input

**Code mode.** Read the target file, directory, or symbol and enough of its immediate neighbors to know its boundary — what it imports and what imports it.

**PR mode.** Gather the change set:

- **Current branch's changes** (no target given): determine the default branch (`git symbolic-ref refs/remotes/origin/HEAD` or fall back to `main`/`master`), then capture `git diff {default-branch}...HEAD` for committed work and `git diff` plus `git diff --cached` for uncommitted work. Run each diff as its own Bash command so large diffs stream incrementally. Also capture `git log {default-branch}..HEAD --pretty=format:%B` for the change's intent. When `gh` is available, also run `gh pr view --json title,body,comments` (no ref — resolves the PR for the current branch) so the change's stated intent and any screenshots are in scope; if no PR exists for the branch, skip this without failing.
- **A named pull request** (explicit reference): run `gh pr view {ref} --json title,body,comments` for intent and screenshots, and `gh pr diff {ref}` for the change set. If the pull request cannot be reached (it does not exist, or access is unavailable), say so and offer code mode against a local target instead.

**Capture screenshots.** When a PR body or a comment contains embedded images — Markdown `![alt](url)` or `<img src="url">`, typically GitHub-hosted (`user-attachments`, `githubusercontent.com`) — record each image's URL together with the nearby caption or heading that says what it shows. These let the overview show a visual next to the text that describes it, so the reader does not have to switch back to the PR. If the PR has no images, capture nothing here.

Identify the set of files the change touches; that set scopes the exploration in Step 4.

## Step 4: Dispatch Exploration Scaled to Size

Dispatch `han-core:codebase-explorer` agents to discover the surrounding code and context — entry points, directly-related context, uses, and the main process flow — that the synthesis draws on. **Scale the count to size, and launch every agent in a single message** so they run concurrently:

- **Small** — one explorer over the target (or the changed files).
- **Medium** — two or three explorers, each over a coherent slice of the target (or the change), so coverage is parallelized rather than serialized.
- **Large** — three to five explorers, each scoped to one subsystem or one area of the change.

Each brief must contain: the resolved target (and, in PR mode, the changed-file set and the captured intent from Step 3); the project-context conventions from Step 1, or a note that surrounding-code inference applies; and the instruction to report entry points, directly-related context, uses, and the main flow as concrete, file-grounded findings. Instruct each explorer to **report what it found, not to assess quality** — this skill raises no findings.

Wait for the whole wave to return before synthesizing. If the target proves too large to cover fully at the chosen size, the explorers cover the highest-signal areas; carry that into the coverage note in Step 5.

## Step 5: Synthesize the Overview

Read [references/overview-template.md](./references/overview-template.md) and render the structure for the resolved mode, drawing on the explorers' findings and the input from Step 3. The skill writes the overview; the explorers' raw findings are not pasted in.

Open the document with a title and a short **intro paragraph naming what is being examined** — the file, directory, symbol, pull request, or branch, and the part of the system it belongs to. Do NOT emit a `Mode:`, `Generated:`, or bare `Target:` metadata block; that metadata does not help the reader. **Never state PR statistics** — lines changed, files changed, additions/deletions, or commit counts — anywhere in the document; they go stale the moment the PR changes and add no understanding. Fold anything worth keeping into the intro sentence.

**Code mode** renders, in order: the title and intro paragraph; a coverage note **only if** coverage was partial; **What it does and why**; **Main flow** (a Mermaid chart with a one-line scope label); **Context and uses** (context and uses kept distinguishable); **Where to start** (the concrete entry points the operator opens first).

**PR mode** renders, in order: the same title and intro paragraph; the same conditional coverage note; **What this change does and why**; **Changes by intent** (grouped by the reader-visible outcome each group delivers — not by file, layer, or author motivation; a single logical change is one narrative with no grouping header); **How the change flows** (a Mermaid chart with a scope label, placed after the grouped changes BECAUSE the reviewer must know what changed before that chart is meaningful); **What to watch when reviewing** (navigational only — where the change is hardest to follow and why; never a quality or risk judgment).

**Place any captured screenshots inline next to the text they illustrate** — embedded as `![caption](url)` directly under the Changes-by-intent item or the flow step they depict, BECAUSE a visual next to its description spares the reader a trip back to the PR. Keep the image URL exactly as captured. Omit screenshots entirely when the PR had none; never invent or placeholder an image.

Apply the per-section detail rule from the template: minimal technical detail in the purpose, flow, and context sections; concrete named entry points in the handoff section. Give every chart a scope label. When coverage is partial, place the coverage note immediately after the intro paragraph so the reader calibrates before investing in the charts.

## Step 6: Write the Scratch File

Write the rendered overview to a scratch file **outside the repository** — for example `${TMPDIR:-/tmp}/code-overview-{short-target-slug}.md`. Never write it into the repository's documentation tree; this overview is ephemeral. The next step reviews and rewrites this file in place.

## Step 7: Validate Accuracy, then Refine for Readability

Dispatch three agents in parallel — one `Agent` call each, in a single message — over the draft overview. One challenges whether the overview is *true to the code*; two review whether it *reads well*. Pass each the scratch-file path, and pass the validator the resolved target (and, in PR mode, the changed-file set) so it knows what to re-read.

- **`han-core:adversarial-validator`** — assume every claim the overview makes about the code is WRONG until the code proves it right. Re-read the target (and the diff, in PR mode) and challenge each material claim: does the code actually do what *What it does and why* says; does the **Main flow** / **How the change flows** chart match the real control flow, in the right order, with no invented or missing steps; do the named **Where to start** entry points exist and are they the right ones; does each **Changes by intent** grouping describe what that change actually does. Surface every claim that is unsupported, overstated, contradicted by the code, or hallucinated, citing the file and line that disproves it. **Validate the accuracy of the description only — do not assess the code's quality and do not raise findings about the code itself.** Return a list of inaccurate or unsupported claims, each with the corrected fact or a note that the claim should be cut.
- **`han-core:information-architect`** — review the document's structure for progressive disclosure, information scent, and orientation: does the most important understanding come first; do the headings carry scent; is the reading order right for someone unfamiliar with the target; do the chart scope labels and any coverage note give the reader enough wayfinding. Return concrete, ordered rewrite recommendations (reorder, relabel, cut, or split sections).
- **`han-core:junior-developer`** — read the document cold as a generalist and flag where it is hard to follow, assumes unstated context, over-explains, or buries the point. Return concrete recommendations for friendlier, clearer phrasing.

Tell the information-architect and junior-developer explicitly: **review the overview document for readability only — do not review the underlying code, and do not raise findings about it.** The validator is the one agent that reads the code, and it does so only to check the description's accuracy, never to judge quality. BECAUSE this skill makes no quality judgment about the code; the validation pass guards truth, the readability pass guards clarity, and neither crosses into evaluating the work itself. The agents return recommendations; they do not edit the file.

Apply the recommendations directly, rewriting the scratch file in place. **Accuracy corrections take precedence:** fix or cut every claim the validator disproved before applying any readability change — a sentence that reads beautifully but describes a flow the code does not follow must still be corrected or removed. Then apply the structure and phrasing recommendations on the corrected text. Keep the spec-content discipline: the result is still an orientation aid with no quality findings, minimal technical detail in the purpose/flow/context sections, and concrete entry points in the handoff section. When the readability agents conflict, prefer the change that makes the document easier for an unfamiliar reader to act on. If validation removed so much that coverage is now meaningfully partial, add or update the coverage note accordingly.

## Step 8: Present

Present to the user in a short message: the scratch-file path, the mode and size used (and why), and any coverage gap the overview noted. Do not paste the whole overview into the conversation; point the user at the file, where the Mermaid charts render.

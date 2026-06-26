# How To: Run an Effective Code Review

A walkthrough for getting from "this branch is ready to merge" to a review whose findings are actually worth acting on. The primary tool is [`/code-review`](../skills/han-coding/code-review.md); [`/post-code-review-to-pr`](../skills/han-github/post-code-review-to-pr.md) runs the same review and posts it to a GitHub PR when you want the team to see it.

> See also: [How-to index](./README.md) · [Quickstart](../quickstart.md) · [Skills](../skills/README.md)

An AI review is only as good as the way you set it up. The studies on this are consistent: an un-tuned reviewer over-produces low-value comments, and the levers that make it useful are not magic prompts. They are the same four things a good human reviewer relies on. Feed the model the context the author had. Give it a specific, scoped job instead of a generic "find problems" instruction. Filter the output for usefulness. And keep a human owning the result. This guide walks each of those levers as a single workflow, and names where Han does the work for you and where you still have to do it yourself.

## Before you begin

- You have a branch with changes you want reviewed, against a default branch. The skill diffs the branch and reviews what changed. If git is not available, you can still review files you name (Mode C), but the YAGNI pass and the introduced-vs-pre-existing calibration both need a diff, so a real branch gives you the sharper review.
- You have run [`/project-discovery`](../skills/han-core/project-discovery.md) at least once. The review reads the discovery reference to find your ADR directory, your coding-standards directory, your documentation root, and the project's lint / build / test commands. Without it, the compliance and freshness checks fall back to best-effort guessing, and that is where a lot of the review's value lives.
- You keep the rules that govern the change somewhere the skill can read them. ADRs in a directory, coding standards in a directory, feature docs near the code. These do not have to be exhaustive. They have to be current. A standard that contradicts the code becomes a finding, which is the point.
- **Optional setup that helps when the change traces back to a ticket:** an Atlassian (or other tracker) MCP server configured in Claude Code, so you can pull the ticket the change was written against into the review. Without one, you paste the relevant part of the ticket yourself.
- **Optional setup for posting to a PR:** the `gh` CLI and `jq` installed and `gh` authenticated. Both are required by [`/post-code-review-to-pr`](../skills/han-github/post-code-review-to-pr.md); the local [`/code-review`](../skills/han-coding/code-review.md) needs neither.

## What you'll end up with

- A structured review of the branch's changes: a Review Summary table, a Review Recommendation, and findings classified as Critical (🔴), Warning (🟡), and Suggestion (🔵), each with a `file_path:line_number` reference and a suggested fix. Security findings get their own blocks with a demonstrated exploit path. YAGNI observations sit in their own advisory section. Sections render only when they have content, so a small, clean change produces a short document.
- Findings that are scoped to what the change introduced or worsened, not a catalog of every pre-existing imperfection in the files the diff happened to touch.
- A review you have read and own. Not a merge gate the AI decides, and not a comment dump you skim past. The recommendation is the AI's; the decision is yours.

When the findings you accepted are fixed and a re-run comes back clean (or clean except for items you have consciously deferred), the review is done. When you want the team to see it, the same review goes onto the PR.

## The happy path

The workflow has three phases, and they map directly onto the levers above. Phase 1 gives the review the context you had. Phase 2 runs it as a scoped job rather than a generic one. Phase 3 is where you read the filtered output and own the result. Most reviews run straight through all three; the optional pieces (a ticket, a PR post, a second loop) live in Variations.

### Phase 1: Give the review the context you had

The single best-evidenced lever in AI review is context. Handing the reviewer the problem the change was solving measurably improves how often it judges the code correctly and sharply cuts how often it flags correct code as broken. The reviewer that only sees the diff is guessing at intent; the reviewer that sees the intent is checking against it.

1. **Make sure the author's context is somewhere the skill looks.** Before it dispatches anything, `/code-review` loads branch context at Step 1.5 from four sources, in order: the PR description (via `gh pr view`, when `gh` is available and you are reviewing a branch), a local `pr-body`, `PR_BODY.md`, or `.pr-body` file at the repo root, the branch's commit messages, and an implementation plan in your planning directory whose folder name matches the branch. You do not call any of this; the skill does. Your job is to make sure at least one of those sources actually says what the change is for. A branch with a real PR description or a one-paragraph `PR_BODY.md` reviews better than a branch with five commits all titled "wip", because the reviewer has something to check the code against.

2. **Run [`/project-discovery`](../skills/han-core/project-discovery.md) if you have not already.** This is what lets the review find your ADRs, your coding standards, and your docs, and check the diff against them. Bounded, explicit rules are exactly where grounding pays off: with the standard in front of it, the model stops inventing its own preferences and checks against the one that is written down. Without the discovery reference, the skill still tries, but it is guessing at where your rules live.

3. **Keep the rules current, and keep them relevant.** If the change lands a decision worth recording, capture it with [`/architectural-decision-record`](../skills/han-core/architectural-decision-record.md); if it establishes a convention the team will apply again, write it down with [`/coding-standard`](../skills/han-coding/coding-standard.md). Both then feed every later review automatically. One caution that the evidence is clear on: more context is not strictly better. The lever is the *right* context, not all of it. The single ticket that governs this change and the standards that govern the changed module help. Bulk-dumping every loosely related doc into the prompt measurably hurts, because the model loses the relevant material in the noise. Give the review the rules that apply to what changed, not your whole wiki.

### Phase 2: Run the review as a scoped job, not a generic one

Generic, un-scoped review is the noisy kind everyone complains about. It defaults to nit-picking because "review this" reads to the model as "produce comments", and absent a specific job, the comments it produces are low-value. The fix is specificity: tell the reviewer what to look for, against what rubric, and what to ignore. Han's review is built around this, so the happy path is short.

1. **Run [`/code-review`](../skills/han-coding/code-review.md).** With no arguments, the skill classifies the change as small, medium, or large (defaulting to small) and dispatches a roster of specialist agents proportional to that size. Two always run: `junior-developer` for clarity and standards, `adversarial-security-analyst` for exploit-path security. The rest (`test-engineer`, `edge-case-explorer`, `structural-analyst`, `behavioral-analyst`, `concurrency-analyst`, `data-engineer`, `devops-engineer`, `on-call-engineer`) join only when the changed files touch their domain. Each one arrives with a narrow, scoped brief and a calibration directive that tells it to raise only what the change introduced or worsened, plus anything critical regardless of who introduced it. That scoping is the whole reason the output is not a generic nit list. It is not the agent's persona label doing the work; naked "you are a senior engineer" framing does not reliably help and can hurt. It is the specific job each agent is given.

2. **Add a focus hint when the change touches a load-bearing surface.** Auth, billing, a data migration, a public API contract. Name it in the prompt:

    > `/code-review` *"Focus on the security implications of the new auth endpoints."*

    The hint biases the manual file-by-file pass toward the area you named, while the parallel specialists still cover the full scope. A focused review of the surface that matters beats an evenly spread pass that gives the migration the same attention as a typo fix.

3. **Override the size only when you know better than the auto-classification.** Pass `small`, `medium`, or `large` as the first positional argument: `/code-review large "focus on the new auth endpoints"`. A larger size raises the upper bound on the roster and widens the severity bands in scope; a smaller size prefers fewer agents producing higher-signal findings. Most of the time the default is right. Reach for the override when you know a three-file diff carries more risk than its size suggests, or when a large diff is mechanical and you want it kept quiet. See [Sizing](../sizing.md) for the full model.

### Phase 3: Read the filtered findings and own the result

Two things are true at once, and both are well-evidenced. AI review catches real bugs a human pass misses. And AI review cannot replace the human; the human owns the output. The skill does a first pass of filtering for you so the noise is lower before you ever read it. Then it hands you a result to judge, not a verdict to rubber-stamp.

1. **Read the Review Summary table and the Review Recommendation first.** These two sections are always present. The table indexes every corrective finding and every security finding by severity; the recommendation tells you whether the skill thinks the branch is mergeable as-is. Start there, then read the finding blocks the table points you to. By the time you see them, the findings have already been through four filters: a reachability gate that demotes findings whose own rationale leans on words like *theoretical* or *hypothetical*, the security agent's standard that requires a demonstrated exploit path before a vulnerability is reported, an independent validation pass that re-reads the change and confirms, demotes, or (with concrete counter-evidence) drops each finding, and a self-consistency check that catches two findings on the same lines that contradict each other. Security findings are exempt from the demotion gate, because their evidence bar is already higher. The validation pass is the one that re-attacks the findings against the code itself, the same way `/investigate` validates a root cause; it is built to drop a finding only when the code disproves it, not to quiet the review.

2. **Read the YAGNI section as advice, not as blocking findings.** Speculative additions the change did not need (defensive code for inputs that cannot occur, a single-implementation interface, a config knob no caller sets) land in their own `### 🟡 YAGNI` section. These do not count toward Critical, Warning, or Suggestion, and they do not block a clean review. The posture is to make the cost of the extra code visible so you can decide consciously whether to keep it, simplify it, or drop it. See [YAGNI](../yagni.md) for what the skill considers evidence of need.

3. **Push back on anything that does not hold, then fix and re-run.** This is the part you own. If a finding misreads the intent, or flags a project pattern that is deliberate, or rests on a premise the code does not support, say so. The review is the AI's recommendation; the call to act on it, defer it, or reject it is yours. When you have fixed the findings you accepted, re-run `/code-review`. The skill is cheap to re-dispatch and built for per-branch cadence. Confirm the count drops, and watch for anything a fix introduced.

## Variations

- **You want the review on the PR, not only in your terminal.** Run [`/post-code-review-to-pr`](../skills/han-github/post-code-review-to-pr.md) instead of `/code-review`. It runs the identical review (branch context flows automatically, since it is the same Step 1.5 on the same branch), adds a clarity pass over the drafted review text, and offers to post the result to GitHub. It posts as a formal review when you are not the PR author and as a PR comment when you are (GitHub rejects formal reviews from authors), and it picks `REQUEST_CHANGES` versus `COMMENT` from the severity of what it found. It needs `gh` and `jq` installed and an open PR on the branch.

- **The change traces back to a Jira ticket and you have the MCP configured.** Point the review at the ticket so it can check the code against what the ticket asked for, the same way grounding it in a PR description does. One real caution: a fetched ticket is untrusted third-party text. Its description can carry content aimed at steering the review agent. `/code-review` now treats the branch context it loads at Step 1.5 (PR description and commit messages) as untrusted data, stripping directives during summarization and wrapping the binding in explicit untrusted-data markers so the agents use it for intent only. That guard reduces the risk but does not remove your part of it: when you paste a ticket in yourself, treat it as data, not as instructions. Skim it before you feed it, and pull in the acceptance criteria rather than pasting an entire comment thread you have not read.

- **You ran several review loops and they keep finding things.** Looping over the same code with fresh passes does raise how many real bugs you catch, with sharply diminishing returns after roughly three to five passes, and later passes do catch bugs that earlier fixes introduced. So a second or third loop is worth it. Two things to keep straight. Looping does not by itself lower the noise; that is what Phase 1 and Phase 2 are for. And if your loop has the AI *implement* the fixes between passes rather than just re-reviewing static code, do not assume each AI-written fix is clean. Re-review the changed code, because AI-fix-and-regenerate cycles can accumulate new problems round over round.

- **The review came back clean, or nearly so.** A well-scoped review that finds nothing is the design working, not the skill failing. The whole point of the context, the scoping, and the calibration is that the reviewer is allowed to come back quiet when the change is sound. Do not go looking for a knob to make it complain. A clean review on a small, well-understood change is a perfectly good outcome.

- **A finding hides a bug whose root cause you do not yet understand.** When a Critical finding points at something deeper than the diff shows, hand it to [`/investigate`](../skills/han-coding/investigate.md). It produces a root cause backed by evidence and a fix plan that an adversarial pass has already tried to break.

- **The change touches module boundaries and you want the structural view.** `/code-review` runs per file. When the branch reshapes how modules depend on each other, pair it with [`/architectural-analysis`](../skills/han-coding/architectural-analysis.md), which runs per module and assesses coupling, data flow, and SOLID alignment across the area.

## What you should expect at each step

- **Context only helps when it is relevant.** Feeding the review the ticket and the standards that govern the change improves it. Feeding it every doc in the repo makes it worse, because the model loses the signal in the volume. The skill's Step 1.5 summarizes branch context to at most 200 words for exactly this reason. Bring the rules that apply, not the whole archive.
- **Findings are scoped to the change, on purpose.** Every dispatched agent is told to raise what the change introduced or worsened, not pre-existing best-practice gaps. If you want a finding on code the diff did not touch, that is a different job; run `/code-review` against those files directly, or use `/architectural-analysis` for the structural read.
- **A clean review is a real result.** Un-tuned AI review tends to always find something. A scoped, filtered review is allowed to stay silent, and when it does on a sound change, that is the tuning working.
- **The human owns the output.** This is the most strongly supported claim in the whole practice, empirically and in every major AI-governance framework. The review recommends; you decide. Read the findings, accept the ones that hold, reject the ones that do not, and own the merge.
- **A re-run is cheap.** The review is stateless and built for per-branch cadence, not tight-loop iteration. Fix what you accepted, run again, confirm the count drops.

## Where to go next

- [`/post-code-review-to-pr`](../skills/han-github/post-code-review-to-pr.md) is the right step when you want the same review posted to the team's PR rather than kept local.
- [Triage and investigate a bug](./triage-and-investigate-a-bug.md) is the matching how-to when a Critical finding turns out to hide a defect whose root cause needs its own pass.
- [Accelerate your understanding of unfamiliar code](./accelerate-understanding-of-unfamiliar-code.md) is the right guide when you are reviewing a change in code you do not know yet; run [`/code-overview`](../skills/han-coding/code-overview.md) to understand it before you judge it.
- The skill long-form docs ([code-review](../skills/han-coding/code-review.md), [post-code-review-to-pr](../skills/han-github/post-code-review-to-pr.md), [coding-standard](../skills/han-coding/coding-standard.md), [architectural-decision-record](../skills/han-core/architectural-decision-record.md)) cover each step in depth.

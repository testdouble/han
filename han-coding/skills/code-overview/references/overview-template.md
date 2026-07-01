# Overview Document Template

The skill renders one of the two structures below into the scratch file. Both
modes share the same grammar — a header, an optional coverage note, a
content-bearing lead section, a grouped/flow body, and an actionable handoff —
so a reader who learns one mode can scan the other. Fill the placeholders,
remove the guidance comments, and keep the section order exactly as written.

## Shared rules (apply to both modes)

- **Apply the shared readability standard to the prose.** Render the prose under [`../../references/readability-rule.md`](../../references/readability-rule.md): main point first, descriptive headings that name their content, one idea per paragraph with the first sentence carrying it, numbered lists for steps and bullets for non-sequential items, and detail revealed in layers. The rule governs the prose only; the Mermaid chart bodies, code fences, and file/symbol references are left exact. Do not restate the rule here; apply it.
- **Open with an orienting paragraph, not a metadata block.** The document begins
  with a title and a short intro paragraph naming what is being examined. Do not
  emit `Mode:`, `Generated:`, or a bare `Target:` field — that metadata does not
  help the reader; fold anything worth keeping into the intro sentence.
- **Never include PR statistics.** Do not state lines changed, files changed,
  additions/deletions, commit counts, or any other diff-stat figure — not in the
  intro, not in a section, not anywhere. These numbers go stale the moment the PR
  changes and add no understanding. Describe what changed and why, never how big
  the diff is.
- **Lead with the why, from the solution's perspective.** The lead section
  answers *why this code (or change) exists* — the real problem it solves or the
  goal it accomplishes for the business or a user — told as a solution to a need,
  never as technical mechanics: why it exists, why it works the way it does, why
  it is the current solution to that need. Every section after it (flow, context,
  handoff) exists to give the reader the context to understand that why. Never
  invent a business rationale the evidence does not support; when the why can only
  be inferred, mark it as inferred.
- **Progressive disclosure, anchored on the why.** The most important
  understanding comes first, and that is *why the code exists* — the problem it
  solves or goal it serves. Detail unfolds beneath it, every section flowing from
  and serving that why. A reader who stops after the lead section still knows why
  the target exists and what need it meets.
- **Minimal technical detail, scoped per section.** The why, flow, and
  context sections stay at the level of why the code exists and what it does — the
  why told as a problem solved or goal met, with no detail a reader would
  otherwise look up in the code itself. The where-to-start / what-to-watch handoff
  section is the exception: it must name the concrete entry points (the specific
  files or components) the operator would open first, or it is not actionable.
- **Chart scope labels.** Every flow chart carries a one-line label stating what
  it covers, and — when coverage is partial — what it leaves out. A chart must
  make sense to a reader who reads only the chart and its label.
- **No quality judgment.** The document never raises findings, severities, or
  recommended changes. It explains; it does not review.
- **Flow charts render as Mermaid** fenced code blocks (` ```mermaid `).
- **Screenshots (PR mode).** When the pull request includes screenshots, embed
  each one inline (`![caption](url)`) directly under the change or flow step it
  illustrates, so the visual sits with its description. Keep the URL exactly as
  captured. Omit when the PR has none; never invent a placeholder image.

---

## Code mode — explaining code as it is now

```markdown
# Code Overview: {short name of the target}

{Intro paragraph: one or two sentences naming what code is being examined — the
file, directory, or symbol and the part of the system it belongs to — so the
reader knows the scope before the overview begins. Do not list mode, target
path, date, or size as metadata fields; weave whatever is worth saying into this
sentence.}

<!-- Coverage note: include ONLY when coverage is partial. Delete this block otherwise. -->
> **Coverage note.** This overview covers {what was covered}. It does not cover
> {what was left out}. Re-run at size {next size up} for fuller coverage.

## Why it exists

{Lead with the why: the real problem this code solves or the goal it accomplishes
for the business or a user — as a solution to a need, not technical mechanics —
and why it works the way it does. Then, briefly, what it is, so the reader has a
concrete referent. The single most important orientation fact is the why; if the
why can only be inferred from the code and its intent, say so rather than
inventing a rationale.}

## Main flow

_Scope: {what this chart represents — e.g. the request path from entry to
response; what it omits, if partial}._

```mermaid
flowchart TD
  {the main process flow}
```

{One or two sentences walking the reader through the chart at a high level —
read as how the code delivers on the why above.}

## Context and uses

- **Context (understand first):** {what the target depends on to meet that need,
  and the surrounding code a reader must understand before touching it}.
- **Uses (where it is invoked):** {where the target is called from — where the
  need it serves is met — and the blast radius of a change}.

## Where to start

{The concrete entry points — the specific files or components — the operator
would open first to begin working, with one line each on what each is for.}
```

---

## PR mode — explaining a set of changes

```markdown
# Change Overview: {short name of the pull request or branch}

{Intro paragraph: one or two sentences naming what is being examined — which
pull request or branch and what part of the system it touches — so the reader
knows the scope before the overview begins. Do not list mode, target URL, date,
or size as metadata fields, and never state diff statistics (lines changed,
files changed, additions/deletions, commit counts); weave whatever is worth
saying into this sentence.}

<!-- Coverage note: include ONLY when coverage is partial. Delete this block otherwise. -->
> **Coverage note.** This overview covers {what was covered}. It does not cover
> {what was left out}. Re-run at size {next size up} for fuller coverage.

## Why this change exists

{Lead with the why: the real problem this change solves or the goal it advances
for the business or a user — the need that motivated it, as a solution to that
need, not technical mechanics. Then, briefly, the bottom line of what it does. If
the why can only be inferred from intent (commit messages, PR/issue text), say so
rather than inventing one.}

## Changes by intent

<!-- Group changes by the reader-visible outcome each group delivers — the why
each group serves (what a reviewer would say changed and why), NOT by file,
layer, or author motivation. If the change is a single logical unit, drop the
grouping and write one narrative paragraph instead of the list below. -->

- **{outcome the group delivers}:** {what changed to deliver it, and why}.

  <!-- If a PR screenshot illustrates this group, embed it right here: -->
  ![{what the screenshot shows}]({image url})
- **{outcome the group delivers}:** {what changed to deliver it, and why}.

## How the change flows

_Scope: {what this chart represents — e.g. how the change moves through the
system; what it omits, if partial}._

```mermaid
flowchart TD
  {how the change moves through or affects the system}
```

{One or two sentences on how to read the chart.}

## What to watch when reviewing

<!-- Navigational only — name where the change is hardest to follow and why
(the areas that touch the most other code, or need the most context). NEVER a
quality or risk judgment; that is code-review's job, not this skill's. -->

{The concrete entry points — the specific files or components — where the
change is densest or most interconnected, with one line each on why a reviewer
should slow down there.}
```

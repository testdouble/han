# Overview Document Template

The skill renders one of the two structures below into the scratch file. Both
modes share the same grammar — a header, an optional coverage note, a
content-bearing lead section, a grouped/flow body, and an actionable handoff —
so a reader who learns one mode can scan the other. Fill the placeholders,
remove the guidance comments, and keep the section order exactly as written.

## Shared rules (apply to both modes)

- **Open with an orienting paragraph, not a metadata block.** The document begins
  with a title and a short intro paragraph naming what is being examined. Do not
  emit `Mode:`, `Generated:`, or a bare `Target:` field — that metadata does not
  help the reader; fold anything worth keeping into the intro sentence.
- **Never include PR statistics.** Do not state lines changed, files changed,
  additions/deletions, commit counts, or any other diff-stat figure — not in the
  intro, not in a section, not anywhere. These numbers go stale the moment the PR
  changes and add no understanding. Describe what changed and why, never how big
  the diff is.
- **Progressive disclosure.** The most important understanding comes first;
  detail unfolds beneath it. A reader who stops after the lead section still
  knows what the target is and why it exists.
- **Minimal technical detail, scoped per section.** The purpose, flow, and
  context sections stay at the level of what the code does and why — no
  detail a reader would otherwise look up in the code itself. The
  where-to-start / what-to-watch handoff section is the exception: it must name
  the concrete entry points (the specific files or components) the operator
  would open first, or it is not actionable.
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

## What it does and why

{One short paragraph: what this code is and why it exists. The single most
important orientation fact, in plain language.}

## Main flow

_Scope: {what this chart represents — e.g. the request path from entry to
response; what it omits, if partial}._

```mermaid
flowchart TD
  {the main process flow}
```

{One or two sentences walking the reader through the chart at a high level.}

## Context and uses

- **Context (understand first):** {what the target depends on and the
  surrounding code a reader must understand before touching it}.
- **Uses (where it is invoked):** {where the target is called from, the blast
  radius of a change}.

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

## What this change does and why

{One short paragraph: the bottom line of the change — what it does and why,
in plain language.}

## Changes by intent

<!-- Group changes by the reader-visible outcome each group delivers (what a
reviewer would say changed and why), NOT by file, layer, or author motivation.
If the change is a single logical unit, drop the grouping and write one
narrative paragraph instead of the list below. -->

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

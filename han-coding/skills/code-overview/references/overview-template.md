# Overview Document Template

The skill renders one of the two structures below into the scratch file. Both
modes share the same grammar — a header, an optional coverage note, a
content-bearing lead section, a grouped/flow body, and an actionable handoff —
so a reader who learns one mode can scan the other. Fill the placeholders,
remove the guidance comments, and keep the section order exactly as written.

## Shared rules (apply to both modes)

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

---

## Code mode — explaining code as it is now

```markdown
# Code Overview: {target}

- **Mode:** code (explaining the code as it is now)
- **Target:** {file, directory, or symbol}
- **Generated:** {date} · size {small | medium | large}

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
# Change Overview: {pull request or branch}

- **Mode:** PR (explaining what the changes do and why)
- **Target:** {PR reference, or the current branch's changes}
- **Generated:** {date} · size {small | medium | large}

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

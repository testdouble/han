# han-communication

The foundational communication plugin for the Han suite. It owns the canonical readability standard, the writing-voice
profile, and the standard for explaining technical work to a reader who will not implement it, along with the skills and
agent that apply them, so every prose-producing plugin in the suite writes against one shared set of standards instead of
its own copy. Reach for it whenever output has to read well for someone who did not write it.

**Bundled.** Installed with the `han` meta-plugin. Depends on nothing: it is the foundational layer, and every plugin
that produces prose output depends on it, so it comes along whenever you install one of them.

## Skills

- [`/explanation-guidance`](docs/skills/explanation-guidance.md) — Surface the shared standard for explaining technical
  work to a reader who will not implement it, so a skill's questions and stops name a concrete outcome instead of a
  mechanism.
- [`/readability-guidance`](docs/skills/readability-guidance.md) — Surface the shared readability standard into a calling
  skill's own context so it drafts in voice and runs its self-check against one canonical copy.
- [`/edit-for-readability`](docs/skills/edit-for-readability.md) — Rewrite the prose of a target you already have (a
  file, pasted text, or a draft in the conversation) against the shared readability standard, preserving every fact.

## Agents

- [`readability-editor`](docs/agents/readability-editor.md) — Rewrite a finished draft for a non-author reader against
  the shared readability standard, preserving every fact and leaving code, diagrams, and citation identifiers untouched.

## Output styles

- [`Han Readability`](docs/output-styles/han-readability.md) — Hold the readability standard and the writing voice
  across every turn of a session, not only inside the skills that source them. Select it under **Output style** in
  `/config`; it keeps Claude Code's built-in software engineering instructions, so coding behavior is unchanged.
- [`Han Concise`](docs/output-styles/han-concise.md) — The same standard and voice, plus a brevity property: no
  preamble, no recap, no sentence that carries neither a fact nor a needed transition, and supporting detail rolled up
  into the statement it supports rather than listed out. Select it for a working session you read in the terminal,
  where you want the answer and not the narration.

## Installation

Add the marketplace to Claude Code, then install the plugin (or install `han` to get it as part of the bundled suite):

```
/plugin marketplace add testdouble/han
/plugin install han-communication@han
```

---

[Plugin index](../docs/choosing-a-han-plugin.md) · [Repo root](../README.md) · [Workflows](../docs/workflows.md)

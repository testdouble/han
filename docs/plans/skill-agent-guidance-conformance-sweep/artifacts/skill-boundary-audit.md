# Skill Description and Boundary Audit

Every skill's frontmatter is now clean, and every skill description carries the four required components. Seventy-five
skill-to-skill references point one way, and most of them should. This records which are real gaps and which are not.

## What was fixed

**Three `argument-hint` fields carried angle brackets.** `work-items-to-jira`, `work-items-to-issues`, and
`work-items-to-linear` used `<KEY>`, `<name>`, and `<user>` placeholder syntax. Frontmatter reaches the system prompt,
where angle brackets carry meaning, so the security rule bans them in every field. Each now uses the plain descriptive
form the other 37 skills already use.

## What was already clean

Across all 40 skills: every `name` matches its directory, no name uses a reserved word, no `AskUserQuestion` appears in
`allowed-tools`, no `Bash()` entry packs several commands into one declaration, no entry uses the invented colon syntax,
no skill directory contains a `README.md`, and every skill description carries what, when-to-use, boundary, and trigger
breadth.

Across all context-injection probes: none uses command substitution, process substitution, a subshell, or a background
operator. None uses a dangerous `find` predicate or in-place `sed`. None reads outside the project working directory.
Every probe that can exit non-zero when its subject is absent carries the guard-and-sentinel form.

## The 75 one-way references, and why most are correct

A mechanical scan finds 75 places where skill A names skill B in its description and B does not name A back. The
bidirectional rule does not apply to all of them, because two different things look identical to a scanner.

**A boundary clause disambiguates.** It exists because a real request could plausibly land on the wrong skill, and the
reverse clause is what closes the gap Claude would otherwise fall through. `code-review` and `post-code-review-to-pr`
are the canonical pair, and they do point both ways.

**A workflow-chain pointer routes forward.** It tells the reader what to run next, or what must have run first.
`plan-work-items` naming `tdd` is not saying "you may have meant tdd"; it is saying "implement a work item with tdd."
Nobody confuses the two, and a reverse clause on `tdd` saying "does not break a plan into work items" would add
characters and no routing value.

The wrapper skills produce most of the count on their own. `code-overview-to-confluence` accounts for nine and
`investigate-to-confluence` for seven, because each names the skill it wraps plus its sibling wrappers. Those are
composition facts, not disambiguation.

**The genuine disambiguation pairs point both ways already.** The pairs the guidance names as commonly confused
(`code-review` / `post-code-review-to-pr`, `project-documentation` / `architectural-decision-record`,
`project-documentation` / `coding-standard`, `coding-standard` / `architectural-decision-record`, `project-discovery` /
`project-documentation`, `automated-test-planning` / `manual-test-planning`) each carry a clause in both directions.

**What would change this.** If a skill starts triggering for requests a named sibling should handle, that pair needs a
reverse clause, and the trigger evidence is what justifies adding one. Adding 75 reverse clauses now, to descriptions
already close to their length budget, would spend the budget that keeps real trigger words loaded.

## One item recorded rather than changed

`han-feedback` declares `Bash(ls *)` and uses `ls` four times in its step logic. One of those is an existence check that
the guidance says should use `find`; the other three list or time-sort a directory's contents, which `find` does not do
as simply. The calls sit in step logic rather than in a load-time probe, so the probe rule does not reach them and a
missing directory degrades rather than aborting the skill.

## Sources

- `han-plugin-builder/skills/guidance/references/skill-building-guidance/security-restrictions.md`
- `han-plugin-builder/skills/guidance/references/skill-building-guidance/skill-description-frontmatter.md`
- `han-plugin-builder/skills/guidance/references/skill-building-guidance/context-injection-commands.md`
- `han-plugin-builder/skills/guidance/references/skill-building-guidance/allowed-tools-bash-permissions.md`

# Scope Boundary: Code Review and Research Response to Feedback Issue #194

## Work Item

GitHub issue [testdouble/han#194](https://github.com/testdouble/han/issues/194), "Han Feedback:
code-review-research (2026-08-23)". Read in full via `gh issue view 194` on 2026-09-09. The issue carries no
comments and no labels.

The issue is a retrospective feedback filing, not a current-state findings report. It names four defects with
suggested fixes and a general principle each, but it carries no file paths, no verbatim skill content, and no
account of the skill files as they stand today. This run therefore performs its own current-state discovery
rather than extracting findings from the issue.

## Stated Scope

Four defects, quoted from the issue.

**Defect 1, `han-coding:code-review` — "No documented path when agent dispatch is unavailable".**

> The skill dispatches a roster of specialist agents as its primary analysis engine, with the manual steps framed
> as a supplement. In an environment that forbids agent dispatch, it degrades silently: the collection step says to
> skip its sub-steps when no agents ran, but nothing tells the reviewer that a manual-only run is a legitimate
> mode, what coverage it loses, or whether the report should disclose it. The run produced a complete-looking
> report that never disclosed that no specialist had passed over the change.

> **Suggested fix.** Add an explicit "agents unavailable" branch: state that the manual review steps are the
> fallback, that the specialist categories the roster would have covered should be swept by hand at the same size
> band, and that the report must record which specialist coverage was absent. Add a matching line to the report
> template so the disclosure has a fixed home.

> **The general principle.** A workflow whose primary engine can be unavailable in some environments needs a named
> degraded mode with an explicit disclosure requirement, not a step that silently no-ops.

**Defect 2, `han-coding:code-review` — "Packaging changes need the built artifact inspected, not just the build
script".**

> A change altered which compiled classes were bundled into a shipped archive, using include and exclude patterns
> in the build configuration. Two critical defects were invisible in the diff: the exclude list removed classes
> that surviving classes still referenced, so the shipped artifact carried dangling references that fail at
> runtime. The build passed. Reading the patterns alone could not reveal it — only disassembling the produced
> archive and diffing referenced class names against present class names did.

> **Suggested fix.** Add a packaging trigger to the review checklist. When a diff changes what gets packaged —
> shading, vendoring, include and exclude rules, dependency scope, bundling — inspect the produced artifact: verify
> every internal reference resolves inside it, that no third-party package is exported unrelocated, and that
> required licence notices are present. Worth noting in the same place that a development run configuration often
> has a wider classpath than the shipped artifact, so a passing smoke test is not evidence.

> **The general principle.** When a change alters what ships rather than what the source says, the artifact is the
> review surface. A green build proves the source compiles, not that the packaged output is internally complete.

**Defect 3, `han-coding:code-review` — "Attribute a disassembly hit to its enclosing member structurally, not by a
running text scan".**

> A finding named the wrong enclosing method. The reference was located by scanning disassembler output line by
> line and carrying forward the most recent line that looked like a member declaration. That heuristic silently
> attributed a hit inside the class's static initializer to the method printed just before it, because an
> initializer's header does not match a normal method-declaration shape. The misattribution understated severity:
> the real site runs on every use of a subclass, while the named site runs only under an accessibility feature. It
> was caught by accident, when a later step re-read the same method for an unrelated reason.

> **Suggested fix.** When citing a location inside compiled output, resolve the enclosing member structurally —
> disassemble the single member, or parse the output into member blocks and search within a block — rather than
> scanning running text and remembering the last header seen. Re-read the cited member in isolation before writing
> the finding, and treat a severity that depends on the location as a reason to confirm it twice.

> **The general principle.** A location derived by carrying forward the last matching line of a text scan is a
> guess, not a citation. Confirm the enclosing unit by isolating it, especially where the finding's severity
> depends on which unit it is.

**Defect 4, `han-research:research` — "'Every citation resolves' does not catch a citation that resolves to the
wrong entry".**

> The skill's traceability invariant is that every source identifier cited inline must resolve to an entry in the
> sources registry. That check is purely syntactic. In a fan-out run, two analysts each numbered their own sources
> from the start of the sequence, and the orchestrator merged them into one renumbered index. A citation carried
> over from one analyst's numbering still resolved — to a real entry saying something unrelated. The run produced
> exactly that: an option's evidence line cited an identifier that had become an unrelated entry after the merge,
> and the resolvability check passed. Only the adversarial validator, which reads the cited entry's content, caught
> it.

> **Suggested fix.** After merging analyst registries, add a semantic pass: for each inline citation, confirm the
> cited entry's one-line summary actually supports the claim it is attached to. Where a merge renumbers
> identifiers, record the old-to-new mapping and rewrite citations through it rather than by hand. State in the
> skill that syntactic resolvability is necessary but not sufficient.

> **The general principle.** An index that renumbers its entries turns every stale citation into a silently wrong
> one rather than a broken one. Verify that a citation points at the right thing, not merely at something.

**The issue's own framing of the shared shape**, from its closing section:

> Three of the four are the same failure at different altitudes: a check that confirms a _reference exists_ while
> never confirming it _points at the right thing_.

## Stated Exclusions

None stated. The issue rules nothing out.

## Operator-Stated Scope

The operator invoked the skill with `for https://github.com/testdouble/han/issues/194` and nothing else.

Asked in the confirmation turn whether the two skill folders were the whole area, they answered:

> expand to other files where it fits

That answer widens the area beyond `han-coding/skills/code-review/` and `han-research/skills/research/`: a file
outside those two folders is in scope when the fix genuinely belongs there. It does not license changes unrelated
to the four defects.

## Direction of Travel

Asked whether the `code-review` agent-dispatch path, the `research` fan-out, or the source registry that renumbers
entries is being replaced or deprecated, the operator answered: **no**. Nothing in the area is being deprecated,
replaced, or migrated away from.

## Visual Material Received

`None received`

This skill plans code structure rather than screens, so the visual-material convention does not apply to it. No
`ui-designs/` folder is written and no completeness gate runs.

## Record Provenance

Established by `han-planning:plan-a-change` on 2026-09-09, at the start of this run. Not inherited from another
folder. No conflicting record was found and no conflict was resolved.

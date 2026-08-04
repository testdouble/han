# The durable-reference rule

A committed document that cites code — a coding standard, a piece of project documentation — must stay accurate as the
code it cites evolves. Two failure modes break that. A bare `file:line` citation in the document goes stale the moment a
line is inserted above it. A snapshot roster of "current consumers" goes stale as consumers change. This rule prevents
both.

It is read in two modes:

- **Research mode** — gathering evidence from the live code, for example a dispatched explorer agent. Research resolves
  the durable anchor and its scope and reports them back, along with the file and line range it used to find them. Only
  **Rules 1 and 2** apply; a researcher may ignore Rules 3 and 4 — its job is to provide concrete code examples, along
  with anchors they can be cited by.
- **Authoring mode** — writing or revising the committed document itself. Authoring cites each place by the durable
  anchor research resolved, frames applicability as a membership criterion, and removes temporal phrasing. **All four
  rules** apply.

## Rule 1: The committed document cites a durable anchor, never a bare line number

Every code reference that lands in the document names a durable anchor: the exported symbol the code illustrates
(function, constant, interface, type) or, for a documentation reference, a stable section heading. A bare line number
must never appear as a citation in the committed document. The only allowed exception is if there's an established house
style for citing code references; even then, an anchorless reference is not permitted: ensure that there's something
greppable for when line numbers shift.

A documentation-heading anchor is durably better than a line number but is not fully rename-proof: a heading rename is
deliberate but not compiler-visible, so it carries a residual silent-break risk a symbol rename does not. Prefer a
symbol anchor when both are available.

Line numbers are not banned from research. Research mode reads the live code at a file and line range to find the
anchor, and reports that range back so the author can open the exact code and verify it. The range is a navigation aid
that stays in the research findings — it is not pasted into the committed document. Authoring opens the code at the
range, then cites the anchor.

## Rule 2: Choose the anchor's scope

Cite the smallest scope that captures the pattern without bundling in substantial unrelated context. Walk this decision
tree for each reference:

1. **Pick the smallest enclosing named scope that contains the pattern** — a function, class, module, or, worst case,
   the file.
2. **Is that scope clean** — is its single responsibility the pattern (see the clean-scope test below)?
   - Yes → cite it by its stable name (file plus symbol, or file plus heading). Done.
   - No → go to step 3.
3. **Can one or more stable, greppable, public anchors _within_ the scope isolate the relevant part** — a decorator, a
   called function, a specific identifier? A single reference may name several anchors to capture a multi-part pattern.
   - Yes → name those in-scope anchors. Done.
   - No → go to step 4.
4. **No greppable anchor isolates the relevant part at an acceptable granularity** → flag the example and escalate to
   the engineer rather than emitting a coarse or line-number reference.

A boundary always exists (worst case, the whole file), so "no boundary exists" is never the escalation trigger. The
trigger is "the cleanest available scope still drags in unrelated context and nothing greppable narrows it."

### Clean-scope test (quantifying steps 2 and 3)

A named construct is clean — citable as-is — when the pattern is its evident, primary subject: a reader who opens it to
learn the pattern finds the pattern occupies most of it, not one concern among several. Narrow further when any tripwire
fires:

- **Whole file or whole module is a red flag _when it stands in for a construct inside it_.** When the reference
  illustrates a pattern that lives inside a file or module, that scope is an arbitrary, growth-prone container — its
  current small size never justifies it — so narrow to the named construct(s) that embody the pattern. A whole file or
  module is a legitimate anchor only when it is _itself_ the referent, in two cases: (a) the rule governs the file or
  module as a unit (file naming, directory or file structure), so the file or path is exactly what the rule is about;
  (b) the reference is a whole-surface pointer rather than a pattern illustration — "the canonical module or API for
  working with X" — where the cohesive module is the durable anchor and there is no finer construct to point at because
  the module's role is the point. The discriminator: is the scope itself the referent, or a container for a referent
  inside it?
- **Mixed responsibility.** The construct does several unrelated things and the pattern is only one — narrow to the
  specific identifier(s) for the pattern.
- **Minority occupancy.** The part the reference is actually about is a small fraction of the construct, so a reader
  would scroll past substantial unrelated code to reach it — narrow to a greppable anchor for that part.

There is no fixed line count. Cohesion to the pattern, not length, is the test: a long single-responsibility function
may be citable whole, while a short multi-purpose one should be narrowed. Size is a smell that triggers this check, not
a threshold. Calibration: the cited scope should be about "the illustrative snippet the reference highlights plus its
immediate named home." If it is much larger than the snippet the reference is actually about, narrow.

### Worked examples

- **Coarse → precise.** "Module A registers hooks, discovered by module B" — citing whole files A and B bundles
  unrelated behavior. Narrow to the in-scope anchors: "A: hooks `H1` and `H2` registered via the `@register` decorator;
  B: `get_hooks`."
- **Behavior-paired reference.** "`payments/refund.ts`, function `issueRefund` — see how it uses `onTransactionSuccess`
  to emit the `refund.issued` event only after the refund row is durably committed to the database."

## Rule 3: State applicability as a membership criterion, not a roster

**Authoring mode only — research has no applicability text to apply this to.** Write who the document applies to as a
membership criterion — the property that defines the set ("any module that does X", "any class that has trait Y") — not
a snapshot roster of the current members. This governs the `Applies To` metadata and any inline applicability statement.
A roster pins the document to a momentary codebase state the same way a line number pins it to a momentary file layout;
the criterion is what actually defines who the rule governs and does not need updating as members change.

A concrete list may remain only when its named examples are structurally distinct — they cover different case shapes —
not when they are simply the complete current set named as a sample. Mark any surviving list non-exhaustive ("e.g., …")
and strip the temporal word from it.

## Rule 4: Remove temporal phrasing or references to "current state"

**Authoring mode only — research produces no committed prose to clean.** Remove snapshot-in-time phrasing that pins the
document to "right now." The words "today", "currently", "now", "existing", "as of this writing", "the current set of",
"already", "still", "pre-existing", "legacy", "older", "no longer", "so far", "for now", and "in this version" are
illustrative examples of it, not an exhaustive list — the rule is that any phrasing pinning the document to a momentary
roster or moment is removed. Lead with the timeless criterion (Rule 3) instead.

Two idioms produce most leaks; check for both explicitly, because both read as natural prose and slip past a word scan:

- **The known-offender aside.** A standard often points at a real violating construct as its "What to avoid" example or
  migration target, then narrates it by its momentary backlog status — "one pre-existing item … tracked for rework". The
  durable-anchor citation is correct (Rule 1); the status narration is the pin. State the timeless property of the
  construct instead: cite it by its anchor and say what it _is_ ("`X` does Y, which violates this standard"), not where
  it sits on a cleanup queue. Whether it has been fixed yet is not the standard's concern.
- **The roadmap or version reference.** A coding standard states a rule that holds across every version and rollout
  phase; it is not itself versioned. A roadmap or version state must not enter the standard at all — neither restated
  inline ("for now we only ship X") nor used to condition the rule ("until phase 2, do Y"). Strip it and state the rule
  unconditionally. Linking a durable decision doc or ADR to explain _why the rule exists_ is fine and durable; letting
  the _current rollout state_ that doc describes appear in or condition the rule is the pin.

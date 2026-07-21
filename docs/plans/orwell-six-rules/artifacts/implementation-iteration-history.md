# Implementation Iteration History: Orwell Six Rules Applied to han-communication

<!--
This file records how the implementation plan evolved across discussion rounds. Committed decisions live in
[implementation-decision-log.md](implementation-decision-log.md) and the primary plan lives in
[../feature-implementation-plan.md](../feature-implementation-plan.md).

Source artifact: docs/research/orwell-six-rules-of-writing.md (no feature-specification.md exists; the research
report's Recommendation is the "what"). No feature-technical-notes.md exists, so no T# tags apply.
-->

## R1: Parallel specialist review (information-architect + junior-developer)

- **Specialists engaged:** han-core:information-architect, han-core:junior-developer
- **New input provided:** Research report (`docs/research/orwell-six-rules-of-writing.md`), discovery notes
  (`.discovery-notes.md`), the four committed edits from research O2, and the hard constraint that the six-point
  self-check stays six.
- **Claim ledger:**

  | # | Claim | Raised by | Category | State |
  | - | ----- | --------- | -------- | ----- |
  | C1 | Escape clause belongs as its own H2 in readability-rule.md between "Fidelity wins" (ends line 95) and "The standardized self-check" (line 97), phrased subordinate to fidelity, with a descriptive heading | IA (F1, F2, F3) | placement | Evidenced |
  | C2 | Edits 2 and 3 both land in writing-voice.md "Avoided words and phrases" (lines 98-114), principle first then examples, beside the existing load-bearing-vs-decorative test (line 110); not in "AI slop to avoid" | IA (F4, F7) | placement | Evidenced |
  | C3 | Edit 3's words go only in the writing-voice blocklist; adding them to readability-rule.md would create a competing word list (readability-rule.md:78-80 designates the blocklist authoritative) | IA (F6), answers JD-007 | placement | Evidenced |
  | C4 | Agent edit shape: escape clause sits beside the fidelity governing principle (readability-editor.md:29-33), stale-figures/diction scope amends existing criterion 5; rubric stays exactly six, "they are the whole rubric" stays literally true | IA (F8, F9), answers JD-002 | structural | Evidenced |
  | C5 | The stale-figures principle must be named inline in the editor because the agent reads only the rule and the draft, never writing-voice.md (readability-editor.md:78) | IA (F9, F14) | mechanic | Evidenced |
  | C6 | Seven-plus surfaces echo the "six criteria" count and all stay true only if no rubric grows to seven (grep-confirmed list in F10) | IA (F10) | guard | Evidenced |
  | C7 | No consuming-skill edits needed; reference-file edits propagate via readability-guidance's live reads (SKILL.md:32-40) | IA (F11) | scope | Evidenced |
  | C8 | The escape clause needs a defined boundary against the self-check's hard gates or it can swallow the blocklist | JD (JD-001) | ambiguity | Evidenced (resolved, see OQ-1) |
  | C9 | With the C4 shape, agent long-form doc count claims stay true; a scoped doc-consistency check still needed for criterion-5 paraphrases | JD (JD-003) + IA (F13) | overlap | Evidenced |
  | C10 | No acceptance check exists; the research itself flags the missing dry run as residual risk | JD (JD-004) | edge-case | Evidenced |
  | C11 | CLAUDE.md requires han-plugin-builder guidance for agent changes; the four-edit plan does not name this prerequisite | JD (JD-005) | convention | Evidenced |
  | C12 | The line-110 dividing-line test was written for sports metaphors; edit 2 must also point at the signature-move carve-out (writing-voice.md:30-33) or physical-world analogies get over-flagged | JD (JD-006) | ambiguity | Evidenced |
  | C13 | On self-check-only skills, edits 1-2 are drafting guidance every skill loads but nothing enforces; keep added prose tight | JD (JD-008) | polish | Evidenced |
  | C14 | Escape clause copies in docs/readability.md and the editor operator doc fail the YAGNI evidence test | IA (F12, F13) | YAGNI-candidate | Evidenced |

- **Open Questions raised:**
  - OQ-1 (from JD-001): does the escape clause override the six self-check gates or only the drafting properties?
  - OQ-2 (from JD-002): extend the agent rubric, weave in, or sit beside; does "exactly six" bind the agent rubric?
  - OQ-3 (from JD-004): is a manual dry run in scope as the acceptance check?
  - OQ-4 (from JD-005): does the agent edit require a han-plugin-builder guidance review?
  - OQ-5 (from JD-007): which single section is edit 3's canonical home?
- **Spec-maturity tags:** all 5 OQs plan-level; 0 spec-level; T#-contradiction not applicable (no technical notes).
  Spec-maturity gate: not tripped (and not trippable at this team size).
- **Resolution source:**
  - OQ-1: evidence. The escape clause is scoped: it governs the drafting properties and rewrite moves, and yields to
    both hard gates. It never licenses a blocklisted word (self-check criterion 5 stays absolute) and never licenses a
    fidelity loss (criterion 6, "Fidelity wins"). Sentence length already carries its own scoped escape ("without
    reason," readability-rule.md:106; "review trigger, not a hard cap," lines 71-73). This matches the research's own
    corroborated pattern that mature guides attach named, scoped exceptions rather than an unqualified override
    (research A9, A10) and IA F2's subordinate-to-fidelity phrasing guard.
  - OQ-2: evidence, cross-specialist. IA F8/F9 settle the shape the research left open: governing principle beside
    fidelity plus a scope amendment to existing criterion 5. The rubric stays six; the constraint binds both sixes in
    effect because seven surfaces echo the count (F10). The junior-developer's own simpler-version watch item agreed
    the non-seventh-criterion shape is the simpler version.
  - OQ-3: evidence. Yes, in scope. The research's Confidence Assessment names the missing dry run as residual risk,
    and the repo has no automated tests, so a manual acceptance dry run is the only behavior-level verification.
    JD-004's design is adopted: a sample document with a stale metaphor, a Latinate stock phrase, an archaic word,
    and a load-bearing signature analogy that must survive.
  - OQ-4: evidence. Yes, a guidance-based review. CLAUDE.md mandates han-plugin-builder guidance for agent
    definitions, and the guidance skill's stated purpose includes "reviewing, hardening, or checking one against the
    guidance." A full agent-builder interview is for authoring from scratch; a review pass fits an edit.
  - OQ-5: evidence. writing-voice.md "Avoided words and phrases" (IA F4/F6): the blocklist is authoritative for the
    words it covers, and readability-rule.md must not carry a competing list.
- **Decisions produced:** D-1 (escape-clause placement and scoping), D-2 (stale-figures principle placement, dividing
  line, and carve-out), D-3 (foreign and archaic diction lands only in the writing-voice blocklist), D-4 (agent-edit
  shape keeps the rubric at six), D-5 (manual dry-run acceptance check), D-6 (guidance-review prerequisite for the
  agent edit), D-7 (scoped doc-consistency check and no consuming-skill edits).
- **Changed in plan:** Outcome; User Stories; Constraints and Boundaries; Implementation Approach (with the
  Editor-agent rubric integrity subsection); Work Units and Sequencing; Definition of Done; Testing Strategy; Risks
  and Assumptions; Deferred (YAGNI); Sources and Plan Records; Recommendation.
- **Project-manager next-step recommendation:** Go to synthesis (deterministic: all OQs resolved by evidence, no
  handoffs outstanding, round cap for small size reached).

# Review Findings: Readability Standard in the Planning and Coding Skills

Findings from `han-planning:iterative-plan-review` (spec-aware mode, lightweight). Cross-references:
`Raised in round:` links to [review-iteration-history.md](review-iteration-history.md); `Changed in plan:` names the
sections of [../feature-specification.md](../feature-specification.md) edited in response.

## Major findings

### F13: The readability-guidance skill has no "reader-facing scope" summary to echo into

- **Agent:** self-review
- **Category:** consistency (grounding a decision against the codebase)
- **Finding:** D9 and the spec (Coordinations, Open Items) say the scope clarification is "echoed in the
  `readability-guidance` skill's in-context summary of who is reader-facing." No such summary exists.
  `readability-guidance/SKILL.md` carries an audience frame (Step 2) but no restatement of the reader-facing scope test;
  it surfaces that test only by instructing the caller to read the canonical `readability-rule.md` (Step 1). There is
  nothing to echo into.
- **Evidence considered:** (codebase) `han-communication/skills/readability-guidance/SKILL.md` — grep for
  "reader-facing / who reads / downstream skill" returns no match; the file's own scope is "surface the standard by
  reading the canonical files," not restating them.
- **Resolution:** Reworded D9, the spec Coordinations row, and the spec Open Items note so the deliverable is stated
  precisely: this work *adds* a brief restatement of the clarified reader-facing scope test to the
  `readability-guidance` skill's own instructions, since the skill carries none today. Scope and intent are unchanged;
  only the description of what the guidance-skill edit does is corrected.
- **Resolved by:** evidence
- **Raised in round:** R1
- **Changed in plan:** Coordinations, Open Items; decision-log D9

## Minor edits

- F14: Confirmed D4's codebase claim — `han-planning/.claude-plugin/plugin.json` declares `["han-core"]`, so the direct
  `han-communication` dependency add is correct and consistent with `han-coding`'s `["han-communication", "han-core"]`.
  No change needed. — self-review — —

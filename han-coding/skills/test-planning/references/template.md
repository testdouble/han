# Test Plan: {branch name or user-provided scope description}

## Summary

<!-- Lead with plain language. Write 2-4 short sentences for a reader who has not seen the -->
<!-- code: what was analyzed, the overall state of its test coverage, where the biggest -->
<!-- risk sits, and what to test first. No file paths, no TP-IDs, no framework jargon. This -->
<!-- is the paragraph someone reads to decide where to spend testing effort. -->

{Plain-language summary paragraph.}

<!-- Then the facts a reader needs to orient, as scannable bullets. -->

- **Scope:** {what was analyzed, in a phrase}
- **Coverage health:** {one-line qualitative assessment — solid, thin, uneven, absent}
- **Most significant gap:** {the single most important thing currently untested}
- **Start here:** {the test or area to write first}

## What Needs Testing and Why

<!-- Plain-language description of the testing work, grouped into a few themes a reader can -->
<!-- hold in their head (e.g. "Authorization", "Payment edge cases", "Concurrent writes"). -->
<!-- For each theme, describe in everyday terms what behavior needs coverage and why it -->
<!-- matters: what could break, who would be affected, why it is worth a test. No -->
<!-- file:line references and no test-approach detail here; that lives in the Technical -->
<!-- Reference below. This is the section a non-author reads to understand the shape of the -->
<!-- risk. End each theme by naming the test IDs that fall under it so the reader can jump -->
<!-- to their detail. -->

### {Theme name}

{Plain-language explanation: what behavior in this area needs coverage and why it matters.}

Covered by: TP-001, TP-004.

## What Each Test Covers

<!-- Walk the tests in plain language, in priority order. For each, name what behavior it -->
<!-- protects and what would break if it went untested, in functional terms — not how to -->
<!-- write it. Lead each line with the test ID so it cross-links to the Technical Reference. -->
<!-- Cover the tests that matter; if the low-priority tail is long, summarize it in one -->
<!-- line rather than listing each. The setup/call/assert detail and file:line live below. -->

- **TP-001** — {plain-language statement of the behavior this test protects and why it matters}
- **TP-002** — {...}
- ...

---

## Technical Reference

<!-- Everything below is the implementation outline: the tests to write or update, with -->
<!-- test level, code paths, and approach. A reader who only needs to understand what to -->
<!-- test and why can stop above. -->

### Test Plan

<!-- Every item tests observable behavior at a public seam: caller inputs, observed outputs -->
<!-- and side effects, and interactions with collaborating objects and services. No item -->
<!-- asserts on private methods, internal state, or implementation structure. Test approach -->
<!-- describes what to set up, what to call, and what to observe — not how the code does it. -->

#### CRIT — Critical Priority

{If no CRIT items: "No critical-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is critical}

#### HIGH — High Priority

{If no HIGH items: "No high-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is high priority}

#### MED — Medium Priority

{If no MED items: "No medium-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is medium priority}

#### LOW — Low Priority

{If no LOW items: "No low-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is low priority}

### Deferred Tests

{If none: "No test cases were deferred."}

Items the test-engineer excluded because brittleness risk outweighs value:

- **{S#}: {title}** — `{file_path:line_number}` — {reason for deferral}

### Dropped Edge Cases

{If none: "No edge cases were dropped."}

Items the edge-case-explorer intentionally excluded:

- **{title}** — {reason for exclusion}

### Coverage Summary

| Priority | Count |
|----------|-------|
| CRIT | {n} |
| HIGH | {n} |
| MED | {n} |
| LOW | {n} |
| **Total** | **{n}** |

### Scope

| Attribute | Value |
|-----------|-------|
| Scope type | Branch changes / Specific files / User-described |
| Files analyzed | {count} |
| Branch | {branch name} |
| Language | {language} |
| Test framework | {framework} |

#### Files

- `{file path 1}`
- `{file path 2}`
- ...

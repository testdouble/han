# Test Plan: {branch name or user-provided scope description}

## Scope

| Attribute | Value |
|-----------|-------|
| Scope type | Branch changes / Specific files / User-described |
| Files analyzed | {count} |
| Branch | {branch name} |
| Language | {language} |
| Test framework | {framework} |

### Files

- `{file path 1}`
- `{file path 2}`
- ...

## Test Plan

### CRIT — Critical Priority

{If no CRIT items: "No critical-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is critical}

### HIGH — High Priority

{If no HIGH items: "No high-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is high priority}

### MED — Medium Priority

{If no MED items: "No medium-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is medium priority}

### LOW — Low Priority

{If no LOW items: "No low-priority test cases identified."}

**TP-{NNN}** (from {T#/EC#}) **[{Coverage Gap / Edge Case}]**
- **Type:** {Coverage gap | Edge case}
- **Test level:** {Unit | Integration | End-to-end}
- **Code path:** `{file_path:line_number}` — {brief description}
- **Test approach:** {What to set up, what to call, what to assert}
- **Priority justification:** {Why this is low priority}

## Deferred Tests

{If none: "No test cases were deferred."}

Items the test-engineer excluded because brittleness risk outweighs value:

- **{S#}: {title}** — `{file_path:line_number}` — {reason for deferral}

## Dropped Edge Cases

{If none: "No edge cases were dropped."}

Items the edge-case-explorer intentionally excluded:

- **{title}** — {reason for exclusion}

## Coverage Summary

| Priority | Count |
|----------|-------|
| CRIT | {n} |
| HIGH | {n} |
| MED | {n} |
| LOW | {n} |
| **Total** | **{n}** |

{Qualitative assessment: overall coverage health, most significant gaps, areas of strength, and recommended focus for test implementation.}

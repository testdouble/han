## Rubric: edge-case-explorer of go-security-project scaffold

### Presence — things the edge case analysis must identify
- The analysis identifies SQL injection edge cases in the database layer where user-controlled input is interpolated into query strings (internal/db/users.go)
- The analysis identifies race condition edge cases in the runner's responseCache where concurrent access can cause data corruption (internal/runner/runner.go)
- The analysis identifies boundary value edge cases for JWT token handling — empty tokens, malformed tokens, expired tokens, tokens with tampered signatures (internal/auth/jwt.go)
- The analysis identifies external input messiness edge cases for HTTP request bodies — missing fields, null values, unexpected types, empty strings (internal/handlers/users.go)
- The analysis identifies error propagation edge cases where database connection failures or query errors may be swallowed or inadequately surfaced to callers
- The analysis includes an Input Source Map table mapping inputs to their origins and validation status

### Specificity — the edge case analysis must be concrete
- Every edge case finding references a specific file path and line number where the affected code lives
- Each finding specifies a concrete scenario — the exact input value or condition that triggers the edge case, not just a category name
- The analysis traces inputs to their callers to determine what values are actually passed, not just what the parameter types allow
- Findings cite the current handling (or lack thereof) for each edge case with reference to the specific code that does or does not guard against it

### Depth — the edge case analysis must be actionable
- Each finding includes a severity assessment (Critical/High/Medium/Low) with justification based on likelihood and impact
- Each finding describes the expected correct behavior — what the code should do when the edge case occurs
- Each finding describes the risk — what happens if the edge case is not handled (e.g., silent data corruption, crash, security bypass)
- The analysis distinguishes between edge cases that are already handled in code, partially handled, and completely unhandled

### Absence — the edge case analysis must not do these things
- The analysis must not report edge cases that are purely theoretical with no realistic path to occurrence in this codebase
- The analysis must not dismiss edge cases with "the framework handles this" without verifying the specific framework version and usage
- The analysis must not inflate priorities — Critical findings should be reserved for likely AND severe AND unhandled scenarios
- The analysis must not write test code or plan overall test coverage — it produces edge case discovery only
- The analysis must not list a dimension as "not applicable" without checking whether the code actually touches that dimension

## File: edge-case-analysis.md
### Presence
- The file contains a Summary section with a priority count table (Critical, High, Medium, Low)
- The file contains an Input Source Map table with columns for Input, Origin, Type, and Validated status
- The file contains a Findings section with EC-series items grouped by priority
- The file contains a Coverage Summary section breaking down edge cases by discovery status (already tested, handled but untested, no handling and no tests)

### Specificity
- Each EC-series finding includes Priority, Dimension, Input, Scenario, Code location, Current handling, Expected behavior, and Risk fields
- The Dropped Edge Cases section lists excluded scenarios with specific reasons for exclusion

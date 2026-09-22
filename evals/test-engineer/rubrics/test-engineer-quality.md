## Rubric: test-engineer of go-security-project scaffold

### Presence — things the test plan must identify
- The test plan identifies that the auth package (auth.go, jwt.go) has no tests covering password comparison or JWT generation/validation behaviors
- The test plan identifies that the database layer (db.go, users.go) has no tests covering connection initialization or user query behaviors
- The test plan identifies that the HTTP handlers (handlers/users.go, handlers/fetch.go) have no tests covering request handling, response formation, or error responses
- The test plan identifies that runner_test.go exists as the only test file and notes the testing patterns it uses
- The test plan identifies outgoing commands (database writes, HTTP responses) and incoming queries (database reads, JWT operations) as collaborator interactions requiring test doubles
- The test plan includes a priority table with High, Medium, and Low counts

### Specificity — the test plan must be concrete
- Every test recommendation references a specific entry point with a file path and line number (e.g., `internal/auth/auth.go:15`)
- Test recommendations specify which collaborators to stub (queries) and which to mock (commands) for each test case
- Each test case specifies the expected observable output — what the function returns, what side effect occurs, or what error surfaces to the caller
- The test plan references the existing runner_test.go file and its patterns when recommending how new tests should be structured

### Depth — the test plan must be actionable
- Each test case includes a concrete test approach with behavior description, stubs, input/action, expected output, and expected commands
- The test plan evaluates brittleness risk for each recommendation — explaining why a test would or would not break on routine refactors
- The test plan recommends appropriate test levels (unit vs integration) with justification — not defaulting everything to unit tests
- The test plan distinguishes between high-value behaviors (data integrity, security boundaries) and low-value behaviors when prioritizing

### Absence — the test plan must not do these things
- The test plan must not recommend writing test code — it produces a plan only
- The test plan must not recommend snapshot or golden-file tests without evaluating churn risk
- The test plan must not recommend tests that assert on mock internals (call counts, argument order) without tying them to observable behavioral outcomes
- The test plan must not include test recommendations for behaviors with no meaningful observable outcome

## File: test-plan.md
### Presence
- The file contains a Summary section with a priority count table
- The file contains a Findings section with T-series items ordered by priority
- The file contains a Coverage Assessment describing which behaviors are well-tested vs have gaps
- The file contains a Scope section identifying the files analyzed

### Specificity
- Each T-series finding includes Priority, Test level, Entry point, Gap type, Test approach, and Brittleness assessment fields
- The Coverage Estimate section specifies expected behavioral coverage after all recommended tests are written

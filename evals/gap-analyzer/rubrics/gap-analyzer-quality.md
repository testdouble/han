## Rubric: gap-analyzer of two-project-security-gap scaffold

### Presence — things the analysis must identify
- The analysis identifies that Rails lacks password hashing, comparing Rails plaintext password comparison against Go's hashed password implementation
- The analysis identifies that Rails lacks token-based (JWT) authentication, compared to Go's JWT implementation
- The analysis identifies SQL injection vulnerabilities present in both applications' user lookup functions
- The analysis identifies hardcoded database credentials in both applications
- The analysis identifies Go's /fetch endpoint as introducing SSRF risk not present in Rails
- The analysis classifies each finding using the gap taxonomy (Missing, Partial, Divergent, or Implicit)
- The analysis declares the comparison direction used

### Specificity — the analysis must be concrete
- The analysis references specific file paths when citing evidence from both projects (e.g., app/models/user.rb, internal/db/users.go)
- The analysis provides evidence pairs — citations from both the Rails and Go codebases for each finding
- The analysis identifies the specific methods or functions involved in each gap (e.g., find_by_name, GetUser, ValidatePassword)

### Depth — the analysis must be actionable
- The analysis explains how the Rails plaintext password approach differs from Go's hashing approach at a feature/behavior level
- The analysis distinguishes between shared vulnerabilities (present in both) and gaps where one app has a feature the other lacks

### Absence — the analysis must not do these things
- The analysis must not recommend specific programming languages, frameworks, or libraries as fixes (per the agent's rules about not reporting implementation details)
- The analysis must not include prioritization or impact assessment (per the agent's rules)
- The analysis must not hallucinate security vulnerabilities that don't exist in the scaffold code

## File: gap-analysis.md

### Presence
- The file contains a "Gap Analysis" heading describing the security comparison between the Rails and Go applications
- The file contains a comparison direction section declaring Rails as current state and Go as desired state
- The file contains a summary section with a gap category count table covering Missing, Partial, Divergent, and Implicit categories
- The file contains a findings section with individually numbered GAP-NNN entries
- Each finding includes Category, Feature/Behavior, Current State, and Desired State fields

### Specificity
- Each finding's Current State and Desired State fields cite specific file paths from the scaffold (e.g., app/models/user.rb, internal/auth/auth.go, internal/db/users.go)
- Each finding includes an evidence pair with citations from both the Rails and Go codebases

### Absence
- The file must not contain prioritization or impact rankings for findings
- The file must not recommend specific implementation fixes or library choices

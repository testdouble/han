## Rubric: coding-standard of rails-api-project scaffold

### Presence — things the coding standard must identify
- The coding standard identifies that business logic (such as the pi calculation) should not live directly in controller actions
- The coding standard identifies the service object pattern (FibonacciCalculator) as the preferred approach for extracting business logic from controllers
- The coding standard identifies inconsistent response formats across API endpoints (e.g., result vs value keys)
- The coding standard identifies the need for input validation on controller parameters

### Specificity — the coding standard must be concrete
- The coding standard references specific files from the project (e.g., pi_controller.rb, fibonacci_controller.rb, fibonacci_calculator.rb)
- The coding standard includes code examples showing both correct and incorrect patterns

### Depth — the coding standard must be actionable
- The coding standard provides "correct usage" examples that demonstrate the preferred pattern
- The coding standard provides "what to avoid" examples that show the anti-pattern
- The coding standard explains why extracting logic to service objects is preferred over inline controller logic

### Absence — the coding standard must not do these things
- The coding standard does not hallucinate files or classes that do not exist in the project
- The coding standard does not suggest database-related or ORM-related conventions (this project has no database)
- The coding standard does not recommend linter/formatter rules as coding standard content

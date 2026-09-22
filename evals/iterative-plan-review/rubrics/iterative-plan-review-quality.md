## Rubric: iterative-plan-review of ruby-security-app scaffold

### Presence — things the review must identify
- The review surfaces the ordering contradiction in Section 4.1 — the plan lists the test framework under Phase 4 but states it must run before Phase 1 tests can land, and the iteration should either move it or explicitly resolve the contradiction
- The review challenges the Phase 1.2 backfill strategy that bcrypts the legacy `password` column, noting that `db/migrate/001_create_users.rb` stores plaintext and the migration assumes every row has a non-null, bcrypt-compatible value
- The review challenges the "dummy `BCrypt::Password.create("")` on the nil-user branch" in Section 1.2 as insufficient for constant-time auth — creating a fresh digest has variable cost and the common fix is a precomputed dummy digest constant
- The review evaluates whether the `scalar_param` helper in Section 2.2 overlaps with Rails' built-in StrongParameters / `ActionController::Parameters` behavior instead of being a wholly new abstraction
- The review verifies the specific file references in the plan (`app/models/user.rb`, `app/controllers/sessions_controller.rb`, `app/controllers/application_controller.rb`, `config/database.yml`, `db/migrate/001_create_users.rb`) exist in the scaffold and flags any line-number claims that don't match
- The review addresses at least one of the five items listed under "Open Questions / Decisions Needed" with either a recommended resolution or evidence from the codebase that narrows the choice
- The review produces an iteration summary section at the end of the plan file covering iterations completed, assumptions challenged, consolidations made, and ambiguities resolved

### Specificity — the review must be concrete
- Challenges cite specific plan sections by their numeric identifier (e.g., "Section 1.2", "Phase 2.2", "Section 4.1")
- Challenges cite specific file paths from the scaffold (e.g., `app/models/user.rb`, `db/migrate/001_create_users.rb`, `config/database.yml`) when grounding claims in the codebase
- Challenges reference specific review IDs from the cross-reference table (SEC-001, CRIT-007, WARN-013, etc.) when discussing which findings are affected
- The iteration summary includes concrete counts (number of iterations, number of assumptions challenged, number of consolidations) rather than vague language

### Depth — the review must be actionable
- For each assumption the review refutes or challenges, the plan file is edited with a concrete change — new wording, an added step, a removed redundancy, or a resolution note — not just a comment that "this may be wrong"
- Proposed plan edits show what the new plan text should say, not just what is wrong with the current text
- When overlap with existing codebase patterns is identified, the review cites the specific file or construct being duplicated

### Absence — the review must not do these things
- The review does not hallucinate files, methods, controllers, migrations, or review IDs that do not exist in the scaffold or the plan
- The review does not rewrite the plan wholesale or replace its phase structure, cross-reference table, or open-questions section with a new organization
- The review does not execute or begin implementing the plan (no edits to `app/`, `config/`, or `db/` files — only to the plan file)
- The review does not iterate more than 5 times
- The review does not count cosmetic changes (rewording, reformatting, typo fixes) as structural improvements when deciding whether to continue iterating
- The review does not add fabricated review IDs (e.g., new CRIT-/SEC-/WARN- identifiers not present in the cross-reference table) to the plan

## File: plans/code-review-result.plan.md

### Presence
- The file contains a new iteration summary section (e.g., "## Iteration Summary" or equivalent heading) added by the skill
- The file's content differs from the original — at least one phase section has been edited in response to a challenged assumption or identified overlap

### Specificity
- The iteration summary section lists numeric counts for iterations completed and assumptions challenged
- Any new or edited plan steps reference specific scaffold file paths rather than generic descriptions

### Absence
- The file still contains the original phase structure (Phase 0 through Phase 4), the "Cross-Reference: Review ID → Plan Section" table, and the "Open Questions / Decisions Needed" section — the skill refines, it does not replace
- The file does not contain placeholder markers like `TBD`, `TODO(claude)`, or `<fill in>`

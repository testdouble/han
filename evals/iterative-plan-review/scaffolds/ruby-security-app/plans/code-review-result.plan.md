# Plan: Remediate `ruby-security-app` Code Review Findings

This plan resolves every item in `code-review-result.md`: 15 critical issues, 18 warnings, 8 suggestions, and 7 security vulnerabilities (SEC-001..SEC-007). CRIT-009..CRIT-015 are duplicates of SEC-001..SEC-007 and are addressed together.

## Guiding Principles

- **Characterize, then fix.** For each critical defect, land a failing/characterization test first (in the same PR as the fix) so the behavioral change is visible in the diff. This is what CRIT-001..CRIT-003 and WARN-010 are asking for.
- **Rotate before removing.** Secrets already committed (SEC-002) must be rotated on the live systems *before* they are scrubbed from the repo, or the scrub is cosmetic.
- **Auth opt-out, not opt-in.** Move `authenticate_user!` onto `ApplicationController` and have exceptions `skip_before_action` explicitly. Prevents the whole class of SEC-007-style omissions.
- **Fail closed on errors.** Exceptions must never render `e.message` to clients. All paths go through an opaque error with a server-side correlation id.

---

## Phase 0 — Prerequisites (no code changes yet)

These are operational steps that gate Phase 1. They are not code edits but must complete before the repo changes ship.

1. **Rotate the leaked DB credentials.** The `admin` / `Password123!` pair for `prod-db.internal` in `config/database.yml` is compromised the moment it lands in git history. Rotate the password on `prod-db.internal` and on every environment sharing the YAML anchor. (SEC-002 / CRIT-010)
2. **Audit DB access logs** for the leaked credentials window — any successful auth from outside the expected app hosts is an incident, not a remediation. (SEC-002)
3. **Decide credential source of truth.** Rails encrypted credentials (`config/credentials/*.yml.enc`) vs. environment variables. This plan assumes ENV for portability; adjust step 2.1 if the team chooses encrypted credentials.

---

## Phase 1 — Stop the bleeding (Critical security fixes)

Goal: close every unauthenticated remote exploit path. Everything in this phase ships together; partial fixes leave exploitable combinations (e.g. fixing SQLi without fixing the rescue handler still leaks DB schema via WARN-012).

### 1.1 — Parameterize `User.find_by_name` (SEC-001, CRIT-004, CRIT-009, CRIT-006 partial)

**File:** `app/models/user.rb:5-17`

- Replace the string-interpolated query in `find_by_name` with `sanitize_sql_array(["... WHERE name = ? LIMIT 1", name])`, mirroring `find_by_user_id`.
- Add `LIMIT 1` so the query's single-row contract does not depend on the unique index staying in place (CRIT-006).
- Extract the shared row-to-User copy into a private `self.row_to_user(result)` helper — this is also WARN-001, landed here to keep the diff minimal. Body: `return nil unless result; user = new; user.id = result["id"]; user.name = ...; user`.
- Both finders call the helper.

**Tests to land with the fix (same PR):**
- CRIT-001: characterization test `User.find_by_name("nobody' OR name='admin' --")` that asserted the vulnerable return before the fix, now asserts `nil` after.
- CRIT-003: `User.find_by_user_id("1 OR 1=1")` returns `nil` — pins the parameterization invariant on the already-safe finder.
- WARN-008, WARN-009: happy-path tests that insert a row and assert every field is populated by each finder.
- SUGG-004, SUGG-005: `nil` return tests for the no-match branch on both finders.
- WARN-012: legitimate apostrophe name (`O'Brien`) returns a `User`, does not raise.
- WARN-013: canonicalization test — fails intentionally at this phase (Unicode NFC / case / trailing whitespace) and is fixed in Phase 3.

### 1.2 — Adopt `has_secure_password` and constant-time compare (SEC-003, SEC-004, CRIT-002, CRIT-005, CRIT-011, CRIT-012)

**Files:** `app/models/user.rb`, `app/controllers/sessions_controller.rb:14-22`, `db/migrate/001_create_users.rb:6`, new migration `db/migrate/002_add_password_digest_to_users.rb`.

- New migration adds `password_digest:string, null: false` and backfills existing rows via a one-shot bcrypt of the legacy plaintext column. Drop the plaintext `password` column in a follow-up migration *after* all readers are off it. Do not drop in the same migration — it kills rollback.
- `User` adds `has_secure_password`. Remove `user.password = result["password"]` from `row_to_user`; the digest is loaded by AR automatically once `password_digest` exists.
- `SessionsController#create` replaces `user.password != password` with `user.authenticate(password)`.
- Equal-time branches: even when `User.find_by_name` returns `nil`, run a dummy `BCrypt::Password.create("")` comparison before returning `401`, so the user-not-found and wrong-password timings match.
- Both failure branches return the same JSON body (`"invalid credentials"`) — they already do (noted in "What's Good"), keep it.

**Tests to land with the fix:**
- CRIT-002: happy-path login test (seed user, POST correct creds, assert 200 + `session[:user_id]` + `session[:role]`).
- WARN-002: same test, verifying the contract.
- SEC-004 timing: `user.authenticate` is called on both the nil-user and wrong-password paths (assert via stub that the dummy compare ran when the user was missing).
- CRIT-005 removal: assert `User` responds to `authenticate` and does not expose `#password` as a readable plaintext attribute.

### 1.3 — Replace the `rescue_from StandardError` leak (SEC-005, CRIT-013, WARN-010, WARN-016, WARN-017)

**File:** `app/controllers/application_controller.rb:2-4`

- Replace the handler body with:
  - Generate a correlation id (`SecureRandom.uuid`).
  - `Rails.logger.error(...)` server-side including the class, message, backtrace, and correlation id.
  - `render json: { error: "internal error", id: correlation_id }, status: :internal_server_error`.
- The client never sees `e.message`. This closes the error-based SQLi oracle (WARN-012, WARN-017) and the generic leak (SEC-005).

**Tests to land with the fix:**
- WARN-010: stub `User.find_by_name` to raise; assert response body does not contain the exception message and does contain a UUID-shaped `id`.
- WARN-016: stub to raise `ActiveRecord::ConnectionNotEstablished`; assert 500 + opaque body.

### 1.4 — Authenticate `/users` and add `reset_session` on login (SEC-006, SEC-007, CRIT-008, CRIT-014, CRIT-015, CRIT-007)

**Files:** `app/controllers/application_controller.rb`, `app/controllers/users_controller.rb`, `app/controllers/sessions_controller.rb:23-25`, `config/routes.rb`.

- `ApplicationController` gains `before_action :authenticate_user!`, implemented as: look up `session[:user_id]`, set `@current_user`, 401 if missing.
- `SessionsController` `skip_before_action :authenticate_user!, only: :create` (login cannot require a session).
- `UsersController` stays authenticated; additionally narrow the response to the current user unless `@current_user.role == "admin"` (SEC-006 scoping). Do not remove the field allow-list — keep `{ id, name, email, role }` as-is, never serialize the whole record.
- In `SessionsController#create`, call `reset_session` *before* assigning `session[:user_id]` / `session[:role]` to close the fixation window (CRIT-007, WARN-018 interacts).

**Tests:**
- CRIT-008: unauthenticated `GET /users?name=alice` → 401.
- WARN-005: authenticated `GET /users` response body has exactly the fields `id`, `name`, `email`, `role` — no `password`, no `password_digest`.
- CRIT-007: pre-seed a session cookie, log in, assert `session.id` changed.

---

## Phase 2 — Input hardening and error-path coverage

Runs after Phase 1. Each item is small and independently landable.

### 2.1 — Secrets out of the repo (SEC-002, CRIT-010)

**File:** `config/database.yml`

- Replace hardcoded `host`, `username`, `password`, `database` with `<%= ENV.fetch("DATABASE_HOST") %>` (ERB) equivalents.
- Split `development` and `production` so they do not share a YAML anchor — a typo should not promote a dev value into prod.
- Add `config/database.yml` to `.gitignore`? **No** — Rails reads it at boot. Instead, commit a sanitized template and keep the ENV values out of git. If the team prefers encrypted credentials, use `Rails.application.credentials.database` and keep `master.key` out of version control.
- Add a CI check (Phase 4) that greps `config/database.yml` for literal `Password123!` and any `.internal` host.

Note: this is *in addition to* the Phase 0 rotation. The file scrub without rotation is useless; rotation without the scrub leaves the next dev to rediscover it.

### 2.2 — Input validation on login and user show (WARN-011, WARN-014, WARN-015, SUGG-006, SUGG-008)

**Files:** `app/controllers/sessions_controller.rb:5-11`, `app/controllers/users_controller.rb:5-9`.

- Extract a helper `scalar_param(name, max: 255)` on `ApplicationController` that:
  - Returns `nil` if the value is not a `String` (rejects `Array` / `ActionController::Parameters` — WARN-011).
  - Returns `nil` if over `max` bytes (WARN-014).
  - Does *not* strip whitespace — whitespace normalization for names happens in the model (see 3.1).
- Both controllers call it for `name` / `username` / `password`, returning 400 `invalid request body` on `nil`.
- WARN-015: change the blank-param branch in `SessionsController` to return `401 invalid credentials` instead of `400 invalid request body`, so blank and wrong-password share a response shape. (Trade-off acknowledged: this makes malformed requests indistinguishable from bad credentials for legitimate clients. The review explicitly asks for it; preserving 400 for explicitly-missing keys while returning 401 on wrong values is an acceptable middle ground if the team pushes back.)
- SUGG-006: reject literal `"null"`, `"undefined"`, `"NaN"` in `scalar_param` or document that they are treated as literal names. Default here: reject with 400, because no legitimate user has a name of `"null"`.
- SUGG-008: allow whitespace-only passwords through the controller (they are a legitimate digest input); enforce a "no whitespace-only" rule at registration, not login. Add a TODO comment since registration is out of scope for this scaffold.

**Tests:** characterize every branch — WARN-003, WARN-004, WARN-006, WARN-007 each get a focused controller test.

### 2.3 — Logout route (SUGG-002)

**Files:** `config/routes.rb`, `app/controllers/sessions_controller.rb`.

- Add `delete "/logout", to: "sessions#destroy"`.
- `SessionsController#destroy` calls `reset_session` and returns `{ status: "logged_out" }`.
- Authenticated via the `ApplicationController` default; no skip.

### 2.4 — CSRF posture for cookie-backed login (WARN-018)

**File:** `app/controllers/application_controller.rb`.

- Document in a comment that `ActionController::API` does not run CSRF verification, and that the login endpoint is mitigated by: (a) `reset_session` on successful auth (Phase 1.4), (b) SameSite=Lax cookies (set in `config/initializers/session_store.rb`), and (c) requiring `Content-Type: application/json` on `sessions#create`.
- If the app ever serves HTML, switch the base class to `ActionController::Base` and enable `protect_from_forgery`. Out of scope for this scaffold but noted as a follow-up.

---

## Phase 3 — Schema and data-hygiene fixes

### 3.1 — Name canonicalization (WARN-013)

**Files:** `app/models/user.rb`, new migration `db/migrate/003_add_name_normalized.rb`.

- Add a `name_normalized` column (downcased, NFC, stripped). Backfill from existing `name`. Unique index moves to `name_normalized`.
- `User.find_by_name(name)` normalizes the argument the same way before the parameterized query.
- The visible `name` is preserved; only the lookup key is canonical.
- Tests: `find_by_name("ALICE")`, `find_by_name(" alice ")`, NFC vs NFD `café` all resolve to the same row.

### 3.2 — `role` whitelist (SUGG-007)

**File:** new migration `db/migrate/004_add_role_check_constraint.rb`.

- `add_check_constraint :users, "role IN ('user', 'admin')", name: "users_role_whitelist"`.
- Supplement with a `User#role` enum or a `validates :role, inclusion: { in: %w[user admin] }` so app-layer errors are clear.

---

## Phase 4 — Tooling, tests, and guardrails

### 4.1 — Test framework (SUGG-003)

**File:** `Gemfile`

- Add `group :development, :test do ... gem "rspec-rails"` (or `minitest` if the team prefers the Rails default — pick one, don't mix).
- `bin/rails generate rspec:install` (or the minitest equivalent).
- All tests written in earlier phases live in `spec/` (or `test/`). This is listed last intentionally — the plan above reads as if tests already run, but the framework must be wired before any of them can land. **In execution order, 4.1 is the first thing to do in Phase 1.** It is listed here under Phase 4 only because it is a tooling concern.

### 4.2 — Gemfile.lock (SUGG-001)

- Run `bundle install`, commit the resulting `Gemfile.lock`.
- Wire `bundler-audit` into CI.

### 4.3 — Static analysis and secret scanning

- Add Brakeman to CI — it would have flagged SEC-001, SEC-005, and SEC-007 independently.
- Add `gitleaks` (or `trufflehog`) as a pre-commit hook and a CI job, so SEC-002 cannot recur.
- Add a schema lint that forbids `t.string :password` on any table.

### 4.4 — Auth-by-default convention (SEC-007 prevention)

- Project README / `docs/conventions.md` entry: every new controller inherits `authenticate_user!`. `skip_before_action` requires a code comment explaining why and a linked ticket.
- Optional: a RuboCop custom cop that flags `skip_before_action :authenticate_user!` without a preceding comment.

### 4.5 — Response serializer (SEC-006 prevention)

- Introduce `ActiveModel::Serializer` or Jbuilder views so `users#show`'s field list lives in one declarative place.
- Makes it structurally impossible to accidentally add `password_digest` to a response (the review's prevention item 6).

---

## Cross-Reference: Review ID → Plan Section

| Review ID | Section |
|---|---|
| CRIT-001, CRIT-003, WARN-008, WARN-009, SUGG-004, SUGG-005, WARN-012 | 1.1 |
| CRIT-002, CRIT-005, CRIT-011, CRIT-012, WARN-002, SEC-003, SEC-004 | 1.2 |
| CRIT-004, CRIT-009, SEC-001, CRIT-006 | 1.1 |
| CRIT-013, SEC-005, WARN-010, WARN-016, WARN-017 | 1.3 |
| CRIT-007, CRIT-008, CRIT-014, CRIT-015, SEC-006, SEC-007, WARN-005 | 1.4 |
| CRIT-010, SEC-002 | 0, 2.1 |
| WARN-001 | 1.1 (extracted with the fix) |
| WARN-003, WARN-004, WARN-006, WARN-007, WARN-011, WARN-014, WARN-015, SUGG-006, SUGG-008 | 2.2 |
| SUGG-002 | 2.3 |
| WARN-018 | 2.4 |
| WARN-013 | 3.1 |
| SUGG-007 | 3.2 |
| SUGG-003 | 4.1 (executed first) |
| SUGG-001 | 4.2 |

---

## Open Questions / Decisions Needed

1. **Test framework choice** — `rspec-rails` or `minitest`? Affects 4.1 and every test listed above.
2. **Credential storage** — ENV vars or Rails encrypted credentials? Affects 2.1.
3. **WARN-015 trade-off** — Collapse blank-param and wrong-password to a single 401, or keep 400 for structurally-malformed requests? The review recommends the former; some clients rely on 400 to distinguish bugs from bad passwords.
4. **Plaintext `password` column drop** — one migration or two? Two is safer (readers migrate, then column drops) but is more operational overhead.
5. **7 omitted edge cases (EC17..EC23)** — a second code review is noted as recommended. Should that be scheduled after Phase 3 lands, or deferred to the next planning cycle?

## Non-Goals

- User registration / password reset flows — not in the scaffold, out of scope.
- Rate limiting on `/login` — worth doing but not in any review finding.
- Moving off `ActionController::API` to `ActionController::Base` — deferred (see 2.4).

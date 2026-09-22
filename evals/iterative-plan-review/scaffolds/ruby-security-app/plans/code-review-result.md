# Code Review: ruby-security-app scaffold

## 📋 Review Summary

| Task ID | Category | File | Description |
|---------|----------|------|-------------|
| CRIT-001 | [Testing: Coverage Gap] | app/models/user.rb:5-17 | No test pins the SQL injection behavior in `User.find_by_name` |
| CRIT-002 | [Testing: Coverage Gap] | app/controllers/sessions_controller.rb:19 | No test characterizes the plaintext password comparison |
| CRIT-003 | [Testing: Coverage Gap] | app/models/user.rb:20-33 | No test asserts the parameterized `find_by_user_id` is not injectable |
| CRIT-004 | [Testing: Edge Case] | app/models/user.rb:6 | SQL injection via `params[:name]` flowing into interpolated SQL |
| CRIT-005 | [Testing: Edge Case] | app/controllers/sessions_controller.rb:19 | Plaintext password comparison against plaintext DB column |
| CRIT-006 | [Testing: Edge Case] | app/models/user.rb:6-7 | `find_by_name` has no `LIMIT 1`; injection or index drop enables wrong-user auth |
| CRIT-007 | [Testing: Edge Case] | app/controllers/sessions_controller.rb:24-25 | Session fixation — no `reset_session` before assigning `session[:user_id]` |
| CRIT-008 | [Testing: Edge Case] | app/controllers/users_controller.rb:17-22 | Unauthenticated PII/role disclosure via `GET /users?name=` |
| CRIT-009 | [Security] | app/models/user.rb:6 | → see SEC-001 for full exploit path |
| CRIT-010 | [Security] | config/database.yml:5-9 | → see SEC-002 for full exploit path |
| CRIT-011 | [Security] | db/migrate/001_create_users.rb:6 | → see SEC-003 for full exploit path |
| CRIT-012 | [Security] | app/controllers/sessions_controller.rb:14-22 | → see SEC-004 for full exploit path |
| CRIT-013 | [Security] | app/controllers/application_controller.rb:2-4 | → see SEC-005 for full exploit path |
| CRIT-014 | [Security] | app/controllers/users_controller.rb:17-22 | → see SEC-006 for full exploit path |
| CRIT-015 | [Security] | config/routes.rb:2 | → see SEC-007 for full exploit path |
| WARN-001 | [Code Maintainability] | app/models/user.rb:10-16, 26-32 | Row-to-User mapping duplicated across `find_by_name` and `find_by_user_id` |
| WARN-002 | [Testing: Coverage Gap] | app/controllers/sessions_controller.rb:4-28 | No happy-path login test |
| WARN-003 | [Testing: Coverage Gap] | app/controllers/sessions_controller.rb:8-11 | No test for blank username/password 400 branch |
| WARN-004 | [Testing: Coverage Gap] | app/controllers/sessions_controller.rb:13-17 | No test for user-not-found 401 branch |
| WARN-005 | [Testing: Coverage Gap] | app/controllers/users_controller.rb:17-22 | No test pins the JSON response shape for `users#show` |
| WARN-006 | [Testing: Coverage Gap] | app/controllers/users_controller.rb:6-9 | No test for blank `name` 400 branch |
| WARN-007 | [Testing: Coverage Gap] | app/controllers/users_controller.rb:11-15 | No test for user-not-found 404 branch |
| WARN-008 | [Testing: Coverage Gap] | app/models/user.rb:5-17 | No happy-path test for `find_by_name` field population |
| WARN-009 | [Testing: Coverage Gap] | app/models/user.rb:20-33 | No happy-path test for `find_by_user_id` field population |
| WARN-010 | [Testing: Coverage Gap] | app/controllers/application_controller.rb:2-4 | No test characterizes the `rescue_from StandardError` message leak |
| WARN-011 | [Testing: Edge Case] | app/controllers/sessions_controller.rb:5-6 | Array/Hash param types bypass `blank?` and reach SQL interpolation |
| WARN-012 | [Testing: Edge Case] | app/models/user.rb:6 | Legitimate apostrophe in `name` (e.g. "O'Brien") breaks SQL query |
| WARN-013 | [Testing: Edge Case] | app/models/user.rb:6 | Unicode normalization / case sensitivity mismatches on `name` |
| WARN-014 | [Testing: Edge Case] | app/controllers/sessions_controller.rb:5-6 | No length cap on username/password; multi-MB inputs reach DB |
| WARN-015 | [Testing: Edge Case] | app/controllers/sessions_controller.rb:8 | `blank?` distinguishes "missing field" vs "wrong password" error shapes |
| WARN-016 | [Testing: Edge Case] | app/models/user.rb:7 | DB connection failures propagate to `rescue_from` and leak messages |
| WARN-017 | [Testing: Edge Case] | app/controllers/application_controller.rb:2-4 | Exception messages rendered to client as JSON error body |
| WARN-018 | [Testing: Edge Case] | app/controllers/sessions_controller.rb:24 | No CSRF protection (`ActionController::API` skips CSRF) on cookie-backed login |
| SUGG-001 | [Code Organization] | Gemfile | No `Gemfile.lock` committed; dependency resolution is non-reproducible |
| SUGG-002 | [API Design] | config/routes.rb | No logout/session destroy route |
| SUGG-003 | [Testing] | Gemfile | No test framework or `test` group declared |
| SUGG-004 | [Testing: Coverage Gap] | app/models/user.rb:8 | No test for `find_by_name` returning nil on no match |
| SUGG-005 | [Testing: Coverage Gap] | app/models/user.rb:24 | No test for `find_by_user_id` returning nil on unknown id |
| SUGG-006 | [Testing: Edge Case] | app/controllers/users_controller.rb:5 | Sentinel strings like "null"/"undefined" pass `blank?` and hit the DB literally |
| SUGG-007 | [Testing: Edge Case] | app/models/user.rb:15 | No CHECK constraint on `role`; DB drift can introduce unexpected roles into `session[:role]` |
| SUGG-008 | [Testing: Edge Case] | app/controllers/sessions_controller.rb:8 | Whitespace-only passwords are blocked at the controller regardless of what is stored |
| SEC-001 | [OWASP: A03 Injection] | app/models/user.rb:6-7 | SQL injection via string-interpolated `name` |
| SEC-002 | [OWASP: A02/A07] | config/database.yml:5-9 | Hardcoded production DB credentials committed to repo |
| SEC-003 | [OWASP: A02] | db/migrate/001_create_users.rb:6 | Plaintext password storage (no bcrypt / `has_secure_password`) |
| SEC-004 | [OWASP: A07] | app/controllers/sessions_controller.rb:14-22 | Non-constant-time password compare + username enumeration |
| SEC-005 | [OWASP: A05] | app/controllers/application_controller.rb:2-4 | Raw exception message leaked via rescue handler |
| SEC-006 | [OWASP: A02/A01] | app/controllers/users_controller.rb:17-22 | Sensitive fields (email, role) returned unauthenticated |
| SEC-007 | [OWASP: A01] | config/routes.rb:2 | Broken access control — no authentication on `/users` |

> **Note:** An additional 7 testing edge-case findings (EC17, EC18, EC19, EC20, EC21, EC22, EC23 from the edge-case explorer) were omitted to stay within the 30-item testing finding cap. Another code review is recommended after addressing the current items.

### Review Recommendation

This code should not be merged until the critical issues are resolved.

## Recommended Changes

### 🔴 Critical

**CRIT-001** **[Testing: Coverage Gap]** `app/models/user.rb:5-17`
No test exists that documents the SQL injection vulnerability in `User.find_by_name`. Add a characterization test that calls `User.find_by_name("nonexistent' OR name='admin' --")` and asserts the current (vulnerable) behavior. Once the fix lands, the assertion flips to `nil`, making the remediation a visible diff.

**CRIT-002** **[Testing: Coverage Gap]** `app/controllers/sessions_controller.rb:19`
The plaintext password comparison path has no test. Add a controller test that seeds a user, posts the correct credentials, and asserts 200 + session keys. Also add an explicit characterization test asserting the stored value is plaintext so a future migration to `has_secure_password` is intentional and visible.

**CRIT-003** **[Testing: Coverage Gap]** `app/models/user.rb:20-33`
`find_by_user_id` is the safe counterpart to `find_by_name`. Add a test passing an injection-shaped string id (e.g. `"1 OR 1=1"`) to prove parameterization holds. This pins the safe-path invariant so it cannot silently regress to string interpolation.

**CRIT-004** **[Testing: Edge Case]** `app/models/user.rb:6`
`params[:name]` (users#show) and `params[:username]` (sessions#create) flow directly into string interpolation. Any request containing `'` or `--` can subvert the query. See SEC-001 for the full exploit path. Fix: use `sanitize_sql_array` (mirroring `find_by_user_id`) or an ActiveRecord finder.

**CRIT-005** **[Testing: Edge Case]** `app/controllers/sessions_controller.rb:19`
`user.password != password` compares a plaintext stored value to a plaintext request value. Schema confirms the column is plaintext (`db/schema.rb:7`). Any DB leak exposes every credential. Fix: adopt `has_secure_password` + bcrypt and compare with `ActiveSupport::SecurityUtils.secure_compare`.

**CRIT-006** **[Testing: Edge Case]** `app/models/user.rb:6-7`
`select_one` has no `LIMIT 1` and no ordering. The schema's unique index on `name` is the only guarantee of a single match. If that index is dropped during a migration or bypassed by SQL injection (CRIT-004), an arbitrary row is returned — combined with an injected `OR role='admin'` predicate, this yields authentication bypass.

**CRIT-007** **[Testing: Edge Case]** `app/controllers/sessions_controller.rb:24-25`
The controller writes `session[:user_id]` and `session[:role]` on top of whatever session already exists. An attacker who fixes a victim's session id can reuse the pre-login cookie after the victim authenticates. Fix: call `reset_session` before assigning new session keys.

**CRIT-008** **[Testing: Edge Case]** `app/controllers/users_controller.rb:17-22`
`GET /users?name=<any>` is unauthenticated and returns `email` and `role` for any named user. This enables username enumeration, PII harvesting, and admin-account targeting. See SEC-006/SEC-007 for full exploit path. Fix: add `before_action :authenticate_user!` and scope responses to the caller's authorization level.

**CRIT-009** **[Security]** → see SEC-001 for full exploit path

**CRIT-010** **[Security]** → see SEC-002 for full exploit path

**CRIT-011** **[Security]** → see SEC-003 for full exploit path

**CRIT-012** **[Security]** → see SEC-004 for full exploit path

**CRIT-013** **[Security]** → see SEC-005 for full exploit path

**CRIT-014** **[Security]** → see SEC-006 for full exploit path

**CRIT-015** **[Security]** → see SEC-007 for full exploit path

### 🟡 Warnings

**WARN-001** **[Code Maintainability]** `app/models/user.rb:10-16, 26-32`
The seven lines that allocate a new `User` and copy row columns are duplicated verbatim across `find_by_name` and `find_by_user_id`. Extract a private `self.row_to_user(result)` helper to remove the duplication and reduce the chance of field drift when the schema changes.

```suggestion
def self.row_to_user(result)
  return nil unless result
  user = new
  user.id = result["id"]
  user.name = result["name"]
  user.email = result["email"]
  user.password = result["password"]
  user.role = result["role"]
  user
end
```

**WARN-002** **[Testing: Coverage Gap]** `app/controllers/sessions_controller.rb:4-28`
No test exercises the happy-path login flow (valid credentials → 200 + session keys set). This is the controller's core public contract.

**WARN-003** **[Testing: Coverage Gap]** `app/controllers/sessions_controller.rb:8-11`
No test covers the blank-guard branch (missing username or password → 400 + `invalid request body`). Three cases: missing username, missing password, both blank.

**WARN-004** **[Testing: Coverage Gap]** `app/controllers/sessions_controller.rb:13-17`
No test covers the user-not-found branch (unknown username → 401 + `invalid credentials`, no session keys set).

**WARN-005** **[Testing: Coverage Gap]** `app/controllers/users_controller.rb:17-22`
No test pins the JSON response shape of `users#show`. Without a test, a future edit could accidentally add `password` to the hash.

**WARN-006** **[Testing: Coverage Gap]** `app/controllers/users_controller.rb:6-9`
No test covers the blank `name` branch (→ 400 + `name parameter required`).

**WARN-007** **[Testing: Coverage Gap]** `app/controllers/users_controller.rb:11-15`
No test covers the user-not-found branch (→ 404 + `user not found`).

**WARN-008** **[Testing: Coverage Gap]** `app/models/user.rb:5-17`
No model-level test inserts a row and asserts `find_by_name` populates every field (`id`, `name`, `email`, `password`, `role`).

**WARN-009** **[Testing: Coverage Gap]** `app/models/user.rb:20-33`
Same gap for `find_by_user_id`. This method is currently dead code in the scaffold — the test would also serve as a usage example.

**WARN-010** **[Testing: Coverage Gap]** `app/controllers/application_controller.rb:2-4`
The `rescue_from StandardError` handler is untested. Add a test that stubs `User.find_by_name` to raise and asserts the response body leaks the raw exception message — this characterizes the information-disclosure defect (SEC-005) for later fixing.

**WARN-011** **[Testing: Edge Case]** `app/controllers/sessions_controller.rb:5-6`
Rails accepts `username[]=a&username[]=b` (Array) and `username[key]=v` (ActionController::Parameters). `blank?` returns false for `["a"]`, so the value then flows into SQL interpolation as `['a', 'b']`. Coerce with `.to_s` or reject non-String types with `bad_request`.

**WARN-012** **[Testing: Edge Case]** `app/models/user.rb:6`
A legitimate apostrophe in a username (e.g. "O'Brien") produces a `PG::SyntaxError`, caught by `rescue_from StandardError`, which leaks DB internals back to the client. Legitimate users cannot log in and attackers get a blind-SQLi oracle.

**WARN-013** **[Testing: Edge Case]** `app/models/user.rb:6`
The DB comparison is byte-exact. NFC vs NFD Unicode forms of "café" are different rows; "Alice" and "alice" do not match; trailing whitespace breaks lookups. Canonicalize (downcase + NFC + strip) on both write and read.

**WARN-014** **[Testing: Edge Case]** `app/controllers/sessions_controller.rb:5-6`
No length cap is applied before the string is embedded in SQL. Multi-megabyte values drive DB load and log bloat. Reject inputs exceeding a sane maximum (e.g., 255 chars).

**WARN-015** **[Testing: Edge Case]** `app/controllers/sessions_controller.rb:8`
The blank guard returns `bad_request` while a wrong password returns `unauthorized`. A blank password thus distinguishes "field missing" from "wrong password" to clients, leaking request-shape information. Return `invalid credentials` (401) on both paths.

**WARN-016** **[Testing: Edge Case]** `app/models/user.rb:7`
Transient `ActiveRecord::ConnectionNotEstablished` / `PG::ConnectionBad` / statement timeouts propagate up to the global `rescue_from StandardError` and are rendered verbatim as JSON. Log server-side with a correlation id and return an opaque message.

**WARN-017** **[Testing: Edge Case]** `app/controllers/application_controller.rb:2-4`
`render json: { error: e.message }` leaks Postgres error messages — including the offending SQL, table structure, and version — on any unhandled exception. This directly accelerates error-based SQL injection (see SEC-001/SEC-005).

**WARN-018** **[Testing: Edge Case]** `app/controllers/sessions_controller.rb:24`
`ApplicationController < ActionController::API` skips CSRF, but the app still uses cookie-backed `session[]`. A cross-site POST can drive logins from an attacker page — combined with the session-fixation bug (CRIT-007), this becomes a login-CSRF attack.

### 🔵 Suggestions

**SUGG-001** **[Code Organization]** `Gemfile`
No `Gemfile.lock` is committed. Without a lockfile, dependency resolution is not reproducible across environments, and tooling like `bundler-audit` cannot assert against resolved versions. Commit a `Gemfile.lock`.

**SUGG-002** **[API Design]** `config/routes.rb`
There is no route for logout / session destruction. A complete session controller normally exposes `DELETE /logout` to clear `session[:user_id]` and call `reset_session`.

**SUGG-003** **[Testing]** `Gemfile`
No test framework is declared and no `test` group exists. Add the Rails default (`minitest`) or `rspec-rails` inside a `group :development, :test` block so tests can run.

**SUGG-004** **[Testing: Coverage Gap]** `app/models/user.rb:8`
Add a model test calling `find_by_name` with a non-existent name and asserting the method returns `nil` (covers the `return nil unless result` branch).

**SUGG-005** **[Testing: Coverage Gap]** `app/models/user.rb:24`
Same gap for `find_by_user_id`: assert the unknown-id path returns `nil`.

**SUGG-006** **[Testing: Edge Case]** `app/controllers/users_controller.rb:5`
`blank?` returns false for the literal strings `"null"`, `"undefined"`, and `"NaN"`. Client libraries that serialize JS `null`/`undefined` without normalization will send these as names and hit the DB literally. Either reject these sentinels or document that they are treated as literal names.

**SUGG-007** **[Testing: Edge Case]** `app/models/user.rb:15`
The `role` column has a default of `"user"` but no CHECK constraint. DB drift or a future migration could introduce arbitrary roles into `session[:role]`, which downstream authorization code may trust. Add a whitelist on read or a CHECK constraint in the schema.

**SUGG-008** **[Testing: Edge Case]** `app/controllers/sessions_controller.rb:8`
A whitespace-only password is blocked at the controller by `blank?`. Users whose stored password happens to be whitespace can never authenticate. Document/forbid whitespace-only passwords at registration time.

### ✅ What's Good

- `User.find_by_user_id` (user.rb:20-33) correctly uses `sanitize_sql_array` for parameterization — the right pattern, and a useful contrast with the vulnerable `find_by_name`.
- `users#show` (users_controller.rb:17-22) uses an explicit field allow-list in the JSON render rather than serializing the whole user object, which keeps `password` out of the response body.
- Both error branches in `sessions#create` return the same `"invalid credentials"` message, avoiding user-presence enumeration at the message level (though the code paths still differ — see SEC-004).
- Schema enforces `NOT NULL` on `name`, `email`, `password`, `role` and unique indexes on `name` and `email`.

## 🔐 Security Vulnerabilities

**SEC-001: SQL Injection in `User.find_by_name`**
- **OWASP:** A03 — Injection
- **Location:** `app/models/user.rb:6-7`
- **Evidence:**
  ```ruby
  query = "SELECT id, name, email, password, role FROM users WHERE name = '#{name}'"
  result = connection.select_one(query)
  ```
- **EXPLOIT:** The `name` parameter from `GET /users?name=<name>` (users_controller.rb:5,11) and `POST /login` username field (sessions_controller.rb:5,13) flows directly into string interpolation in a raw SQL query. Attacker sends `GET /users?name=' UNION SELECT 1,'admin','a@a','x','admin'-- ` to exfiltrate arbitrary rows, dump the password column from all users, or bypass authentication with `POST /login` body `username=' OR role='admin' LIMIT 1-- &password=...`. Because `select_one` returns a row the attacker controls, they can materialize a synthetic admin user in the response and — combined with SEC-004 — log in as anyone. Full database read (and on PostgreSQL, potentially write via stacked subqueries in certain sinks) is achievable.
- **Severity:** Critical

**SEC-002: Hardcoded Database Credentials**
- **OWASP:** A02 — Cryptographic Failures / A07 — Authentication Failures
- **Location:** `config/database.yml:5-9`
- **Evidence:**
  ```yaml
  host: prod-db.internal
  username: admin
  password: Password123!
  database: userservice
  ```
- **EXPLOIT:** Production database hostname, admin username, and plaintext password are committed to the repository. Any party with read access to the repo (including anyone who clones via git history) gains full `admin` credentials to `prod-db.internal:5432`. Combined with network access to the internal host (e.g. via VPN, SSRF, or a compromised dev machine), the attacker owns the entire `userservice` database. The same credentials are used for `development` and `production` via the YAML anchor, so any dev machine is effectively an attack vector into prod.
- **Severity:** Critical

**SEC-003: Plaintext Password Storage**
- **OWASP:** A02 — Cryptographic Failures
- **Location:** `db/migrate/001_create_users.rb:6` and `app/models/user.rb:14`
- **Evidence:** Schema defines `t.string :password, null: false` and the model reads `user.password = result["password"]` then compares `user.password != password` in `sessions_controller.rb:19`.
- **EXPLOIT:** Passwords are stored as plain strings (no bcrypt, argon2, or `has_secure_password`). Any SQL injection (SEC-001), database compromise (SEC-002), or backup leak instantly yields every user's cleartext password, enabling credential-stuffing across other services where users reuse passwords.
- **Severity:** Critical

**SEC-004: Non-Constant-Time Password Comparison and Username Enumeration**
- **OWASP:** A07 — Identification and Authentication Failures
- **Location:** `app/controllers/sessions_controller.rb:14-22`
- **Evidence:**
  ```ruby
  if user.nil?
    render json: { error: "invalid credentials" }, status: :unauthorized
    return
  end
  if user.password != password
  ```
- **EXPLOIT:** Two separate bugs. (a) `user.password != password` is a short-circuit string comparison — an attacker measures response time or early-exit byte count to recover the password character by character. (b) The nil branch returns before a password is compared, so timing / trace differences between "user not found" and "wrong password" paths allow unauthenticated username enumeration at `POST /login`. Fix with `ActiveSupport::SecurityUtils.secure_compare` against a hash, and run a dummy bcrypt even when the user is not found so both branches take equal time.
- **Severity:** High

**SEC-005: Stack Trace / Internal Detail Leakage via Rescue Handler**
- **OWASP:** A05 — Security Misconfiguration
- **Location:** `app/controllers/application_controller.rb:2-4`
- **Evidence:**
  ```ruby
  rescue_from StandardError do |e|
    render json: { error: e.message }, status: :internal_server_error
  end
  ```
- **EXPLOIT:** Any unhandled exception surfaces `e.message` to the client. A SQL injection payload that produces a PG error (e.g. `GET /users?name='`) causes `PG::SyntaxError: ERROR: unterminated quoted string at or near "'..." ...` to be returned in the response body — leaking table names, column structure, PostgreSQL version, and confirming SEC-001. This directly accelerates error-based SQL injection exfiltration.
- **Severity:** High

**SEC-006: Sensitive Data Exposure in API Response**
- **OWASP:** A02 — Cryptographic Failures / A01 — Broken Access Control
- **Location:** `app/controllers/users_controller.rb:17-22`
- **Evidence:**
  ```ruby
  render json: { id: user.id, name: user.name, email: user.email, role: user.role }
  ```
  Combined with no authentication on the route (`routes.rb:2`: `get "/users", to: "users#show"`).
- **EXPLOIT:** `GET /users?name=<anything>` is entirely unauthenticated — no `before_action :authenticate`, no session check. Any anonymous attacker enumerates arbitrary users' `email` (PII) and `role` (privilege level), building a hit list of `admin` accounts to target via SEC-001 / SEC-004. Combined with SEC-001 the attacker can also coerce the query to return the `password` column through UNION selects into the `name` / `email` / `role` output fields.
- **Severity:** High

**SEC-007: Broken Access Control — No Authentication on Sensitive Endpoints**
- **OWASP:** A01 — Broken Access Control
- **Location:** `config/routes.rb:2` and `app/controllers/application_controller.rb` (no `before_action`)
- **Evidence:** `ApplicationController < ActionController::API` contains no authentication filter; `UsersController` has no `before_action`; `/users` is reachable without a session.
- **EXPLOIT:** Unauthenticated enumeration of any user record by name. There is no `authenticate_user!`, no authorization check that the caller is the subject, and no rate limiting. See SEC-006 for the direct PII exposure this enables.
- **Severity:** High

## Security Improvement Summary

### What Was Found

The scaffold contains a cluster of severe, interacting issues. `User.find_by_name` builds SQL via string interpolation and is called from both the public `/users` endpoint and the `/login` endpoint, yielding unauthenticated SQL injection (SEC-001). Production database credentials are committed in plaintext (SEC-002). Passwords are stored in plaintext and compared with a non-constant-time operator, with a separate code path for missing users that enables username enumeration (SEC-003, SEC-004). Uncaught exceptions return raw error messages to clients, accelerating error-based injection (SEC-005). The `/users` endpoint requires no authentication and returns email and role for any named user (SEC-006, SEC-007).

### How to Improve

1. Replace the interpolated query in `User.find_by_name` with a parameterized query — either `User.find_by(name: name)` or `sanitize_sql_array(["... WHERE name = ?", name])`, mirroring `find_by_user_id`. (SEC-001)
2. Remove `config/database.yml` credentials from version control; source them from `ENV` or Rails encrypted credentials, rotate the leaked `admin` password immediately, and split dev/prod configs. (SEC-002)
3. Adopt `has_secure_password` with bcrypt; migrate existing rows and drop the plaintext `password` column. (SEC-003)
4. Use `ActiveSupport::SecurityUtils.secure_compare` on hashed digests and run the comparison even when the user is not found (dummy bcrypt) so both branches take equal time. (SEC-004)
5. Replace the blanket `rescue_from StandardError` with a handler that logs server-side and returns an opaque error id to clients. (SEC-005)
6. Add a `before_action :authenticate_user!` on `UsersController`, restrict the response to fields the caller is authorized to see, and consider scoping `/users` to the current user or an admin role. (SEC-006, SEC-007)
7. Add a `Gemfile.lock` to the scaffold and run `bundler-audit` in CI to cover the dependency evidence gap.

### How to Prevent This Going Forward

1. Enable Brakeman in CI — it flags raw-SQL interpolation (SEC-001), `rescue_from StandardError` leaks (SEC-005), and unauthenticated controller actions.
2. Adopt `bundler-audit` and Dependabot to catch vulnerable gems before they land.
3. Add a pre-commit secret scanner (gitleaks, trufflehog) to prevent credentials like SEC-002 from ever being committed.
4. Establish a project convention that all password handling flows through `has_secure_password`, forbidding any `:password` string column in migrations via a schema lint. (SEC-003, SEC-004)
5. Make authentication opt-out rather than opt-in: put `before_action :authenticate_user!` on `ApplicationController` and require controllers to explicitly `skip_before_action` with justification. (SEC-007)
6. Require a response-shape serializer (e.g., `ActiveModel::Serializer` or Jbuilder template) so sensitive fields like `password`, `email`, and `role` cannot be added to a response by accident. (SEC-006)

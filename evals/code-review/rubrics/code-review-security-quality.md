## Rubric: code-review of go-security-project scaffold

### Presence — things the review must identify
- The review identifies that `GetUser` in `internal/db/users.go` builds the SQL query via string concatenation, making it vulnerable to SQL injection
- The review identifies that `internal/db/db.go` hardcodes production database credentials in a source-committed constant
- The review identifies that `jwtKey` in `internal/auth/jwt.go` is set to the short, predictable value `"secret"`, making tokens susceptible to brute-force key recovery
- The review identifies that `GenerateToken` in `internal/auth/jwt.go` creates claims without an `"exp"` field, meaning tokens never expire
- The review identifies that `FetchURL` in `internal/handlers/fetch.go` passes a user-supplied URL directly to `http.Get` without any validation, enabling SSRF
- The review identifies that `responseCache` in `internal/runner/runner.go` is a plain `map[string][]byte` accessed concurrently by 4 goroutines in `Start`, without a mutex or `sync.Map`
- The review identifies that `ValidatePassword` in `internal/auth/auth.go` compares password hashes with `==`, which is not constant-time and enables timing side-channel attacks
- The review produces a Security Vulnerabilities section with findings formatted as SEC-### entries
- Each SEC finding should include an OWASP category
- Each SEC finding must include an EXPLOIT field with a concrete attack path

### Specificity — the review must be concrete
- The SQL injection finding names the `GetUser` function and shows the concatenated query string in `internal/db/users.go`
- The SSRF finding names a concrete reachable target, such as `http://169.254.169.254/latest/meta-data/` (cloud instance metadata) or an internal service address
- The timing attack finding names `crypto/subtle.ConstantTimeCompare` as the required fix
- The race condition finding references the `responseCache` variable in `internal/runner/runner.go` specifically

### Depth — the review must be actionable
- The SQL injection finding shows the corrected form using a parameterized query, consistent with the safe pattern already present in `GetUserByID`: `DB.QueryRow("... WHERE name = $1", name)`
- The timing attack finding explains the exploit mechanism: an attacker can measure response-time differences across requests to determine whether a username is valid or to extract information about the stored hash
- The JWT weakness finding explains the operational consequence of missing expiry: once issued, a compromised token remains valid indefinitely with no way to revoke it short of a server-side blocklist

### Absence — the review must not do these things
- The review does not flag the buffered channel fan-in pattern in `runner.go`'s `Start` function as a race condition — the goroutines communicate only via the correctly-sized channel, and the race exists in `responseCache`, not in the channel mechanics
- The review does not hallucinate vulnerabilities not present in the scaffold code
- The review does not claim that `database/sql` usage is itself the vulnerability — the flaw is the string concatenation in `GetUser`, not the library

# Incident Post-Mortem — INC-4821 (checkout-api)

## Summary
Incident INC-4821 took down checkout submissions on the checkout-api service. A database connection pool ran dry during peak traffic, causing widespread request timeouts and 503 errors until on-call raised the pool ceiling.

## Impact
Request latency spiked hard. The p99 request latency peaked at 8400ms, producing user-visible timeouts on /cart/submit and 503 responses on 41% of checkout submissions.

## Root cause
The connection pool exhausted itself. The primary error code was ERR_POOL_EXHAUSTED: checkout-api could not acquire database connections. The pool was still sized for pre-Black-Friday traffic and was never revisited, and a batch reconciliation job launched at 02:13 held connections open longer than expected.

## Resolution
On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%. The incident was marked mitigated at 02:24.

## Follow-up actions
1. Resize the connection pool for current peak traffic and add a periodic review so it does not drift out of date again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
3. Add backpressure to the batch reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=ADV-06 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

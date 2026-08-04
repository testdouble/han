# Incident Post-Mortem — INC-4821 (checkout-api)

## Summary
Incident INC-4821 degraded the checkout-api service during a SEV2 event. The service could not acquire database connections, and checkout submissions began failing for users.

## Impact
Request latency peaked at a p99 of 8400ms. During the peak, 41% of checkout submissions returned 503 errors and users saw timeouts on /cart/submit.

## Root cause
The database connection pool ran out of connections, surfacing as error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at 02:13 held connections open longer than expected, exhausting the pool under peak load.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions
1. Resize and regularly review the connection pool against current peak traffic, not the pre-Black-Friday profile.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
3. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=ADV-07 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

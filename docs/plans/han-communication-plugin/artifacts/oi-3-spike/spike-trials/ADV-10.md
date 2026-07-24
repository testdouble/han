# Incident Post-Mortem — INC-4821 (checkout-api)

## Summary
Incident INC-4821 took down checkout submissions on the checkout-api service for roughly ten minutes early on. A SEV2 opened at 02:14 and was mitigated by 02:24. The service could not acquire database connections, so user-facing checkout requests timed out.

## Impact
Checkout latency spiked to a peak p99 of 8400ms. During the worst of it, 41% of checkout submissions returned 503 errors, and users saw timeouts on /cart/submit. Error rate fell below 0.1% once the fix landed.

## Root cause
The database connection pool ran dry, surfacing as error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic and had never been revisited. A batch reconciliation job launched at 02:13, held connections open longer than expected, and had no backpressure while running against peak checkout traffic. No circuit breaker sat between checkout-api and its datastore, so the failure hit users directly.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120. Connections began recovering immediately. Within about three minutes, p99 latency dropped back under 400ms and the error rate settled below 0.1%.

## Follow-up actions
1. Resize the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add backpressure to the batch reconciliation job and stop co-scheduling it with peak checkout traffic.
3. Add a circuit breaker between checkout-api and its primary datastore so a stalled pool degrades gracefully instead of timing out users.

CONSUMER_COMPLETE | TRIAL_ID=ADV-10 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

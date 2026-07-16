# Incident Post-Mortem — INC-4821 (checkout-api)

## Summary
Incident INC-4821 took down checkout on the `checkout-api` service for about ten minutes early on. A SEV2 opened at 02:14 and was mitigated by 02:24. Customers hit timeouts and errors while submitting their carts.

## Impact
Request latency spiked hard. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors. Users saw visible timeouts on `/cart/submit`.

## Root cause
The database connection pool ran dry. The primary error code was `ERR_POOL_EXHAUSTED`: `checkout-api` could not acquire database connections. The pool was still sized for pre-Black-Friday traffic and was never revisited. A batch reconciliation job launched at 02:13, held connections open longer than expected, and had no backpressure while running against peak checkout traffic.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered almost immediately. By 02:22 p99 latency was back under 400ms and the error rate fell below 0.1%.

## Follow-up actions
1. Resize the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add a circuit breaker between `checkout-api` and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=ADV-08 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

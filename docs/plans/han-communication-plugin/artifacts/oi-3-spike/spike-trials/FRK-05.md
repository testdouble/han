# Incident Post-Mortem — INC-4821

## Summary
Incident INC-4821 took down checkout on the `checkout-api` service when its database connection pool ran dry during peak traffic. On-call mitigated it in about ten minutes by raising the pool ceiling.

## Impact
Checkout submissions failed for roughly eight minutes. At the worst point, p99 request latency peaked at 8400ms, and 41% of `/cart/submit` submissions returned 503 errors before recovery.

## Root cause
The connection pool exhausted, surfacing as error code `ERR_POOL_EXHAUSTED`. A batch reconciliation job launched at 02:13 held connections open longer than expected, and the pool was still sized for pre-Black-Friday traffic. With no circuit breaker between `checkout-api` and its datastore, the shortage cascaded straight into user-visible timeouts.

## Resolution
On-call raised the maximum pool size from 40 to 120 at 02:19. Connections recovered immediately: p99 latency dropped back under 400ms and the error rate fell below 0.1% by 02:22.

## Follow-up actions
1. Resize the connection pool for current peak traffic and set a recurring review so it never drifts again.
2. Add a circuit breaker between `checkout-api` and its primary datastore to contain future pool shortages.
3. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-05 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

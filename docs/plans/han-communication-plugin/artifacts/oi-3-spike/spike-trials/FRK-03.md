# Incident Post-Mortem — INC-4821

## Summary
Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry during peak traffic.

## Impact
Checkout submissions timed out for roughly eight minutes. The p99 request latency peaked at 8400ms, and 41% of submissions on /cart/submit returned 503 errors before recovery.

## Root cause
The connection pool was sized for pre-Black-Friday traffic and never revisited. A batch reconciliation job started at 02:13, held connections open longer than expected, and exhausted the pool. Connection acquisition then failed with error code ERR_POOL_EXHAUSTED.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120 at 02:19. Connections recovered within three minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions
1. Resize the connection pool for current peak traffic and set a recurring review of that sizing.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-03 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

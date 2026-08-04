# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout for eight minutes when the checkout-api service ran out of database connections. On-call restored service by enlarging the connection pool.

## Impact

Checkout submissions failed hard during the window. The p99 request latency peaked at 8400ms, and 41% of submissions returned 503 errors, so users saw timeouts on the cart submit path.

## Root cause

The checkout-api database pool ran dry and returned code ERR_POOL_EXHAUSTED. A batch reconciliation job started at 02:13 and held connections open longer than expected, while the pool itself was still sized for pre-Black-Friday traffic and had never been revisited.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

1. Re-size the checkout-api connection pool for current peak traffic and add an alert that fires before the pool nears exhaustion.
2. Add a circuit breaker between checkout-api and its primary datastore so a stalled dependency stops cascading into user-facing timeouts.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-06 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

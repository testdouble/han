# Incident Post-Mortem — INC-4821

## Summary

Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry, and on-call restored service by enlarging the pool.

## Impact

Checkout submissions failed for roughly eight minutes. The p99 request latency peaked at 8400ms, and 41% of `/cart/submit` calls returned 503 errors during the worst of it.

## Root cause

The service exhausted its database connection pool and reported `ERR_POOL_EXHAUSTED`. A batch reconciliation job started at 02:13, held connections open longer than expected, and collided with peak checkout traffic on a pool still sized for the pre-Black-Friday profile.

## Resolution

On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, p99 latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and add an alert when pool utilization runs high.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-07 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service for roughly eight minutes early on, when the database connection pool ran dry under peak load.

## Impact

Users could not complete checkout. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors while the pool was exhausted.

## Root cause

The connection pool ran out of available connections and reported code ERR_POOL_EXHAUSTED. A batch reconciliation job started at peak traffic and held connections open, while the pool was still sized for pre-Black-Friday demand.

## Resolution

The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered within minutes, and p99 latency dropped back under 400ms with the error rate below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review of that sizing.
2. Add a circuit breaker between checkout-api and its primary datastore so a stalled pool fails fast.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-07 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

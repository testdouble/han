# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout submissions when checkout-api ran out of database connections and timed out. On-call mitigated it within eight minutes by enlarging the pool.

## Impact

Users could not submit carts for roughly eight minutes. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors during the worst of it.

## Root cause

The database connection pool was exhausted, surfacing as error code ERR_POOL_EXHAUSTED. A batch reconciliation job started at 02:13 and held connections open longer than expected, and the pool was still sized for pre-Black-Friday traffic.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered right away, latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future exhaustion.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-05 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

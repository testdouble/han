# Incident Post-Mortem: INC-4821 (checkout-api)

## Summary

Incident INC-4821 took down checkout on the checkout-api service for roughly eight minutes when its database connection pool ran dry. The team restored service by raising the pool size.

## Impact

Users could not submit their carts. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors before recovery.

## Root cause

The connection pool exhausted its capacity, surfacing as error code ERR_POOL_EXHAUSTED. A batch reconciliation job launched at 02:13 and held connections open longer than expected, and the pool had been sized for pre-Black-Friday traffic and never revisited.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered, p99 latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions

1. Resize the connection pool to match current peak traffic and set a review cadence so it does not drift again.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-02 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

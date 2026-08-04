# Incident Post-Mortem — INC-4821

## Summary

Incident INC-4821 took checkout-api down for roughly eight minutes when its database connection pool ran dry under peak load. On-call restored service by raising the pool size.

## Impact

Users could not complete checkout. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors while /cart/submit timed out.

## Root cause

The connection pool exhausted its capacity and returned the error code ERR_POOL_EXHAUSTED. A batch reconciliation job launched at peak and held connections open, draining a pool still sized for pre-Black-Friday traffic.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, and latency dropped back under 400ms with an error rate below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and add an alert when pool usage nears the ceiling.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-01 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

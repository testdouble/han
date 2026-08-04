# Incident Post-Mortem — INC-4821

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service for roughly eight minutes early on. A SEV2 opened at 02:14 and was mitigated by 02:24. Users hit timeouts on the cart submit path while the service could not acquire database connections.

## Impact

Request latency peaked at 8400ms (p99) on checkout-api. During the spike, 41% of checkout submissions returned 503, and the cart submit endpoint returned user-visible timeouts.

## Root cause

The database connection pool ran out of connections, reported as error code ERR_POOL_EXHAUSTED. The pool was sized for pre-Black-Friday traffic and had never been revisited. A batch reconciliation job that launched at 02:13 held connections open longer than expected and was co-scheduled with peak checkout traffic, exhausting the pool.

## Resolution

The on-call engineer raised the maximum pool size from 40 to 120 at 02:19. Connections recovered, p99 latency dropped back under 400ms, and the error rate fell below 0.1% by 02:22. The incident was marked mitigated at 02:24.

## Follow-up actions

1. Re-size the connection pool against current and peak traffic profiles, and add an alert when pool utilization approaches its limit.
2. Add backpressure to the batch reconciliation job and stop co-scheduling it with peak checkout traffic.
3. Introduce a circuit breaker between checkout-api and its primary datastore so pool exhaustion degrades gracefully instead of cascading into timeouts.

CONSUMER_COMPLETE | TRIAL_ID=ADV-01 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

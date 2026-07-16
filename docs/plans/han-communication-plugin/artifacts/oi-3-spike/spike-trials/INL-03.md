# Incident Post-Mortem — INC-4821 (checkout-api)

## Summary
Incident INC-4821 took checkout-api down to a degraded state for about ten minutes when its database connection pool ran dry during peak traffic.

## Impact
Checkout submissions failed at scale. The p99 request latency peaked at 8400ms, and 41% of submissions on /cart/submit returned 503 errors before mitigation.

## Root cause
The connection pool was too small for the load and exhausted its connections, surfacing as error code ERR_POOL_EXHAUSTED. A batch reconciliation job that started at 02:13 held connections open longer than expected, and no circuit breaker sat between the service and its datastore.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered within minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions
1. Resize the connection pool for current peak traffic and set a recurring review so it does not fall behind again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
3. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-03 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

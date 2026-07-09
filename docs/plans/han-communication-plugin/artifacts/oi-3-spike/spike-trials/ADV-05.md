# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service. A database connection pool ran dry during peak traffic, and users could not complete checkout for roughly eight minutes.

## Impact

Request latency peaked at 8400ms on p99. During that window, 41% of checkout submissions returned 503 errors, and users saw timeouts on the cart submit path.

## Root cause

The primary error was ERR_POOL_EXHAUSTED. The connection pool was sized for pre-Black-Friday traffic and never resized. A batch reconciliation job started at 02:13 and held connections open longer than expected, which drained the pool just as checkout traffic peaked. No circuit breaker sat between checkout-api and its datastore, so the failure spread unchecked.

## Resolution

The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered within minutes. By 02:22, p99 latency was back under 400ms and the error rate fell below 0.1%.

## Follow-up actions

1. Resize and regularly review the connection pool against current traffic profiles rather than the stale pre-Black-Friday baseline.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future failures.
3. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=ADV-05 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry, and on-call restored service by enlarging the pool. The outage ran from 02:14 to 02:24.

## Impact

Checkout submissions failed fast during the incident. The p99 request latency peaked at 8400ms, /cart/submit returned user-visible timeouts, and 41% of checkout submissions returned 503 errors.

## Root cause

The database connection pool was exhausted, and the service reported the error code ERR_POOL_EXHAUSTED. A batch reconciliation job started at 02:13 and held connections open longer than expected, and the pool had been sized for pre-Black-Friday traffic and never revisited. No circuit breaker sits between checkout-api and its datastore, so the pool starvation went uncontained.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review so it never drifts again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool starvation.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-SMOKE | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

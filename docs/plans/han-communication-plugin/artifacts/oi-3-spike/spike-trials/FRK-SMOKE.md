# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout for roughly eight minutes when the checkout-api service exhausted its database connection pool. A pool-size increase restored service.

## Impact

Checkout submissions failed at scale during the window. p99 request latency peaked at 8400ms, and 41% of submissions returned 503 errors while users hit timeouts on /cart/submit.

## Root cause

The checkout-api connection pool ran out of connections and returned error code ERR_POOL_EXHAUSTED. A batch reconciliation job started at 02:13 and held connections open longer than expected, and the pool was still sized for pre-Black-Friday traffic that no one had revisited.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review of that sizing.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-SMOKE | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

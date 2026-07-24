# Incident Post-Mortem — INC-4821 (checkout-api)

## Summary

INC-4821 took down checkout on the checkout-api service for roughly eight minutes early on. A SEV2 opened at 02:14 when healthchecks degraded, and the incident was mitigated by 02:24. Checkout submissions failed for a large share of users during the window.

## Impact

Peak p99 request latency reached 8400ms. At that point 41% of checkout submissions returned 503 errors, and users hit visible timeouts on /cart/submit.

## Root cause

The database connection pool ran out of connections, surfacing as ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic and had never been revisited. A batch reconciliation job started at 02:13, held connections open longer than expected, and ran without backpressure while checkout traffic peaked. No circuit breaker sat between checkout-api and its primary datastore to contain the failure.

## Resolution

On-call raised the maximum pool size from 40 to 120 at 02:19. Connections recovered quickly. By 02:22 p99 latency was back under 400ms and the error rate fell below 0.1%.

## Follow-up actions

1. Re-size and regularly review the connection pool against current peak traffic, not the pre-Black-Friday profile.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=ADV-03 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

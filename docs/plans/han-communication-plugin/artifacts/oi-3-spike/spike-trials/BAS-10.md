# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout on the checkout-api service after its database connection pool ran dry under peak load. On-call mitigated it by raising the pool size, and the service recovered within eight minutes.

## Impact

Checkout submissions failed for roughly six minutes. At the worst point, p99 request latency peaked at 8400ms, and 41% of submissions to /cart/submit returned a 503 error. Users saw visible timeouts.

## Root cause

The connection pool exhausted and could not hand out new database connections, surfacing as error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at 02:13 held connections open during peak checkout, draining the remaining capacity.

## Resolution

On-call raised the maximum pool size from 40 to 120 connections. Connections recovered right away. Within three minutes p99 latency fell back under 400ms and the error rate dropped below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review so it does not fall behind again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-10 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

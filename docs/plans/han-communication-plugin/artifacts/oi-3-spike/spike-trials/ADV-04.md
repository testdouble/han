# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service. Database connections ran out during a traffic peak, and users could not submit their carts until on-call raised the pool size.

## Impact

Request latency spiked to a peak p99 of 8400ms. During the worst of it, 41% of checkout submissions returned 503 errors, and users hit visible timeouts on /cart/submit.

## Root cause

The database connection pool ran dry, surfacing as error code ERR_POOL_EXHAUSTED. The pool was sized for pre-Black-Friday traffic and was never revisited. A batch reconciliation job started at 02:13, held connections open longer than expected, and had no backpressure, so it starved live checkout traffic.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes. Latency fell back under 400ms and the error rate dropped below 0.1%, at which point the incident was marked mitigated.

## Follow-up actions

1. Right-size the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=ADV-04 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

# Incident Post-Mortem — INC-4821

## Summary

Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry during peak traffic. A pool-size raise restored service within about eight minutes.

## Impact

Users could not submit carts. The /cart/submit path timed out as p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors during the worst of the incident.

## Root cause

The connection pool was exhausted, surfacing as ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at 02:13 held connections open longer than expected, so checkout-api could no longer acquire database connections.

## Resolution

The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered immediately, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review so it never falls behind the traffic profile again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool starvation.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-12 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

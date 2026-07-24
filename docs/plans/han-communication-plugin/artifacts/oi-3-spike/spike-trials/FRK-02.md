# Incident Post-Mortem — INC-4821

## Summary
Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry. Checkout submissions failed for roughly eight minutes before an on-call engineer restored service.

## Impact
Users could not submit carts. The /cart/submit endpoint timed out, p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors during the worst of the incident.

## Root cause
The connection pool exhausted its capacity and reported code ERR_POOL_EXHAUSTED. A batch reconciliation job launched at 02:13 held connections open longer than expected, and the pool was still sized for pre-Black-Friday traffic, so checkout requests could not acquire a connection.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120 connections. Connections recovered immediately, p99 latency fell back under 400ms, and the error rate dropped below 0.1% within three minutes.

## Follow-up actions
1. Resize the connection pool for current peak traffic and add an alert that fires before the pool nears exhaustion.
2. Add a circuit breaker between checkout-api and its primary datastore, and give the reconciliation job backpressure so it never again competes with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-02 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

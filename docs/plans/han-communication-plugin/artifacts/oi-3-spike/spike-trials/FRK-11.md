# Incident Post-Mortem — INC-4821

## Summary
Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry during peak traffic. On-call raised the pool size and service recovered within about eight minutes.

## Impact
Users could not submit carts. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors during the worst of the outage.

## Root cause
The connection pool was too small for the live traffic profile, so it exhausted and threw ERR_POOL_EXHAUSTED. A batch reconciliation job launched at 02:13 held connections open longer than expected, which drained the pool the moment checkout traffic peaked.

## Resolution
On-call raised the maximum pool size from 40 to 120 connections. Connections recovered right away, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions
1. Resize the connection pool for the current post-Black-Friday traffic profile and set a recurring review.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-11 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

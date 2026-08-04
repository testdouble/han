# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout for eight minutes when checkout-api ran out of database connections during peak traffic.

## Impact

Checkout submissions failed for real users. During the worst of it, p99 latency peaked at 8400ms and 41% of submissions returned 503 errors on the cart submit path.

## Root cause

The database connection pool ran dry and threw ERR_POOL_EXHAUSTED. A batch reconciliation job started at peak and held connections open, while the pool was still sized for pre-Black-Friday traffic that it had outgrown.

## Resolution

On-call raised the max pool size from 40 to 120. Connections recovered within minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions

- Resize the connection pool for current traffic and set a review cadence so it does not lag demand again.
- Stop co-scheduling the batch reconciliation job with peak checkout traffic, and add backpressure so it cannot starve live requests.
- Add a circuit breaker between checkout-api and its primary datastore to contain the next pool exhaustion.

CONSUMER_COMPLETE | TRIAL_ID=BAS-01 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

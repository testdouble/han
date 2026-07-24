# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 briefly took down checkout when the checkout-api service ran out of database connections during peak traffic. On-call raised the connection pool size and service recovered within about eight minutes.

## Impact

Checkout requests slowed to a crawl and then failed. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors while the pool was exhausted.

## Root cause

The database connection pool was too small for the load and gave out under it. Connection acquisition began failing with error code ERR_POOL_EXHAUSTED after a batch reconciliation job held connections open longer than expected during peak checkout traffic.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered immediately, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review so it never drifts behind the traffic profile again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future exhaustion.
3. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-02 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

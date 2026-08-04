# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout for the checkout-api service when its database connection pool ran dry during peak traffic. On-call mitigated it in about ten minutes by enlarging the pool.

## Impact

Checkout submissions failed for real users. The p99 request latency peaked at 8400ms, and 41% of submissions returned 503 errors while /cart/submit timed out.

## Root cause

The database connection pool was exhausted. Connection acquisition failed with error code ERR_POOL_EXHAUSTED because the pool was still sized for pre-Black-Friday traffic and a batch reconciliation job held connections open at peak.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, and latency dropped back under 400ms with an error rate below 0.1%.

## Follow-up actions

1. Resize the connection pool for current traffic and add a recurring review so it does not fall behind demand again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool starvation.
3. Give the reconciliation job backpressure and reschedule it away from peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-08 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

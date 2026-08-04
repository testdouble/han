# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout for eight minutes when the checkout-api service ran out of database connections. On-call restored service by raising the connection pool ceiling.

## Impact

Checkout slowed to a near-stop at the peak. The p99 request latency climbed to 8400ms, and 41% of checkout submissions returned 503 errors while users saw timeouts on cart submission.

## Root cause

The checkout-api service exhausted its database connection pool and could not acquire new connections, reported as ERR_POOL_EXHAUSTED. A batch reconciliation job started one minute before the incident and held connections open longer than expected, against a pool sized for pre-Black-Friday traffic and never revisited.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions

- Resize the connection pool for current traffic and set a recurring review so it does not drift again.
- Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
- Give the batch reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-05 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

# Incident Post-Mortem: INC-4821 (checkout-api)

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service for about eight minutes early on. A drained database connection pool stalled requests until on-call raised the pool ceiling.

## Impact

Users could not complete checkout. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors while the pool was exhausted.

## Root cause

The database connection pool ran dry and reported ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at peak held connections open longer than expected.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions

- Resize and regularly review the connection pool against current peak traffic, not the old profile.
- Add a circuit breaker between checkout-api and its primary datastore.
- Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-06 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

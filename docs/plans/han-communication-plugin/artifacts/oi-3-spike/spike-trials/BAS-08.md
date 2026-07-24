# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service for about ten minutes early on, until on-call raised the database connection pool size and traffic recovered.

## Impact

Customers could not complete checkout while the incident ran. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors, with user-visible timeouts on the cart submit path.

## Root cause

The database connection pool ran dry and could not hand out new connections, failing with error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job that started at 02:13 held connections open longer than expected, with no circuit breaker or backpressure to contain the damage.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered right away, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and review that sizing on a regular schedule.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-08 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

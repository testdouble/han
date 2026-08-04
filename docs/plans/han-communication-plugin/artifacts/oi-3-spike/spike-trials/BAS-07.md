# Incident Post-Mortem: INC-4821 (checkout-api)

## Summary
Incident INC-4821 took down checkout submissions on checkout-api when its database connection pool ran dry during peak traffic. On-call mitigated it in about ten minutes by enlarging the pool.

## Impact
Users could not submit carts for roughly eight minutes. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors before recovery.

## Root cause
The service exhausted its database connection pool, surfacing as error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job started at 02:13 and held connections open, starving live checkout requests.

## Resolution
On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions
1. Resize and load-test the connection pool against current peak traffic, then set a recurring review.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-07 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

# Incident Post-Mortem: INC-4821

## Summary
Incident INC-4821 took down checkout submissions on the checkout-api service for about eight minutes early on, when the database connection pool ran dry under peak load.

## Impact
Checkout users hit timeouts on /cart/submit, and 41% of submissions returned 503 errors. Request latency peaked at a p99 of 8400ms before recovery.

## Root cause
The connection pool exhausted its capacity and reported code ERR_POOL_EXHAUSTED. A batch reconciliation job started at 02:13, held connections open longer than expected, and collided with peak checkout traffic against a pool still sized for pre-Black-Friday volume.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions
1. Resize the connection pool to match current peak traffic, and review the sizing on a recurring schedule.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool starvation.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-09 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

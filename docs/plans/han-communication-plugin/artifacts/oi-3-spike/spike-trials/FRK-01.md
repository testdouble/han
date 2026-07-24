# Incident Post-Mortem: INC-4821

## Summary
Incident INC-4821 took down checkout on the checkout-api service for about eight minutes early on, when the database connection pool ran dry under peak load. On-call mitigated it by raising the pool size, and checkout recovered fully.

## Impact
Checkout submissions failed for users during the window. The p99 request latency peaked at 8400ms, cart submissions timed out on /cart/submit, and 41% of checkout submissions returned 503 errors at the worst point.

## Root cause
The database connection pool was exhausted, surfacing as error code ERR_POOL_EXHAUSTED. The pool was sized for pre-Black-Friday traffic and never revisited, and a batch reconciliation job that started at 02:13 held connections open far longer than expected, starving live checkout requests.

## Resolution
On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions
1. Resize the connection pool to match current peak traffic and add an alert when pool utilization approaches its ceiling.
2. Add a circuit breaker between checkout-api and its primary datastore so a starved pool fails fast instead of stalling requests.
3. Add backpressure to the batch reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-01 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

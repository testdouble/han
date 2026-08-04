# Incident Post-Mortem: INC-4821

## Summary
Incident INC-4821 took down checkout on the checkout-api service for roughly ten minutes early on, until on-call raised the database connection pool limit and traffic recovered.

## Impact
Checkout submissions failed at scale during the incident. At the peak, p99 request latency reached 8400ms, users hit timeouts on cart submission, and 41% of checkout attempts returned a 503 error.

## Root cause
The database connection pool ran dry under load and could not hand out new connections, surfacing as the error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job started minutes earlier held connections open longer than expected. No circuit breaker guards the path between checkout-api and its primary datastore.

## Resolution
On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions
1. Resize the connection pool for current peak traffic and set a recurring review so it does not fall behind again.
2. Add backpressure to the batch reconciliation job and stop co-scheduling it with peak checkout traffic.
3. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.

CONSUMER_COMPLETE | TRIAL_ID=BAS-12 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

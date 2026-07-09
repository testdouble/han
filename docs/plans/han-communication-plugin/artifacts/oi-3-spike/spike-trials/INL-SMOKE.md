# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service for about eight minutes early on, until on-call raised the database connection pool size and traffic recovered.

## Impact

Checkout users hit timeouts and errors during the incident. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 at the worst point.

## Root cause

The database connection pool ran out of connections and reported the error code ERR_POOL_EXHAUSTED. A batch reconciliation job started at peak time, held connections open longer than expected, and the pool was still sized for pre-Black-Friday traffic.

## Resolution

On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, p99 latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-SMOKE | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

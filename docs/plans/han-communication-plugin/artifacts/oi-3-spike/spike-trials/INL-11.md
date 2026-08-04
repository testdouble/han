# Incident Post-Mortem: INC-4821 (checkout-api)

## Summary

Incident INC-4821 took down checkout on the checkout-api service for roughly eight minutes when its database connection pool ran dry. On-call raised the pool size and traffic recovered.

## Impact

Users could not submit carts during the outage. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors before mitigation.

## Root cause

The connection pool was exhausted, surfacing as error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at 02:13 held connections open longer than expected during peak load.

## Resolution

On-call raised the maximum pool size from 40 to 120 connections. Latency fell back under 400ms and the error rate dropped below 0.1% within three minutes.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review of the sizing.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-11 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

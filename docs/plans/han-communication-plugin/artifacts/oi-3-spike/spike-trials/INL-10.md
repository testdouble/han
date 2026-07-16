# Incident Post-Mortem — INC-4821

## Summary

Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry during peak traffic. On-call restored service by enlarging the pool.

## Impact

Checkout requests stalled badly for about eight minutes. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors with user-visible timeouts on /cart/submit.

## Root cause

The connection pool exhausted its capacity and could not acquire new database connections, surfacing as error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at 02:13 held connections open while checkout demand peaked.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

1. Resize and regularly review the connection pool against current traffic profiles rather than pre-Black-Friday assumptions.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool starvation.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-10 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

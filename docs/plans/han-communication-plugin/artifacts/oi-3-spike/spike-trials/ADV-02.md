# Incident Post-Mortem — INC-4821 (checkout-api)

## Summary

Incident INC-4821 took down checkout on the checkout-api service for roughly ten minutes early on. A database connection pool ran dry under peak load, and customers could not submit their carts until on-call widened the pool.

## Impact

Checkout latency peaked at a p99 of 8400ms. During the worst of it, 41% of checkout submissions returned 503 errors and users saw timeouts on `/cart/submit`.

## Root cause

The primary error was `ERR_POOL_EXHAUSTED`: checkout-api could not acquire database connections. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at 02:13 held connections open longer than expected, draining the pool right as checkout traffic peaked.

## Resolution

On-call raised the maximum pool size from 40 to 120. Connections recovered immediately, p99 latency fell back under 400ms, and the error rate dropped below 0.1%. The incident was marked mitigated at 02:24.

## Follow-up actions

1. Resize the connection pool for current peak traffic and set a recurring review so it never lags the traffic profile again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=ADV-02 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

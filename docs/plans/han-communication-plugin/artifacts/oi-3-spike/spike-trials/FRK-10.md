# Incident Post-Mortem — INC-4821

## Summary
Incident INC-4821 took down checkout submissions when the checkout-api database connection pool ran dry, and on-call restored service by enlarging the pool.

## Impact
User-visible timeouts hit /cart/submit as p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 during the worst window.

## Root cause
The checkout-api database pool could not acquire connections and failed with code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job launched at 02:13 held connections open while peak checkout traffic ran.

## Resolution
On-call raised the maximum pool size from 40 to 120. Connections recovered immediately, p99 latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions
1. Resize and regularly review the connection pool against current peak traffic, not the stale pre-Black-Friday profile.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-10 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

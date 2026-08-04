# Incident Post-Mortem — INC-4821

## Summary
Incident INC-4821 took down checkout submissions on the checkout-api service when its database connection pool ran dry during peak traffic. On-call mitigated it within ten minutes by enlarging the pool.

## Impact
Customers hit user-visible timeouts on /cart/submit, and 41% of checkout submissions returned 503 errors at the worst point. The p99 request latency peaked at 8400ms before recovery.

## Root cause
The database connection pool was sized for pre-Black-Friday traffic and was never revisited. A batch reconciliation job launched at 02:13 held connections open longer than expected, and the pool then failed to acquire new connections with error code ERR_POOL_EXHAUSTED.

## Resolution
On-call raised the maximum pool size from 40 to 120 connections at 02:19. Connections recovered immediately, p99 latency dropped back under 400ms, and the error rate fell below 0.1% by 02:22.

## Follow-up actions
1. Re-size the connection pool against current peak traffic and add an alert when pool utilization crosses a safe threshold.
2. Add a circuit breaker between checkout-api and its primary datastore so a starved pool degrades gracefully instead of timing out.
3. Give the reconciliation job backpressure and reschedule it off peak checkout hours so it no longer competes for connections.

CONSUMER_COMPLETE | TRIAL_ID=FRK-04 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

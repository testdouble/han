# Incident Post-Mortem — INC-4821 (checkout-api)

**Summary**
Incident INC-4821 took down checkout submissions on the checkout-api service for about ten minutes overnight, and on-call recovered it by enlarging the database connection pool. The service degraded at 02:14 and was mitigated by 02:24.

**Impact**
Users could not submit carts during the incident. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors until the pool was resized.

**Root cause**
The database connection pool ran dry. Connection acquisition failed with error code ERR_POOL_EXHAUSTED, because a batch reconciliation job launched at 02:13 held connections open while the pool was still sized for pre-Black-Friday traffic.

**Resolution**
On-call raised the maximum pool size from 40 to 120 at 02:19. Connections recovered within minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

**Follow-up actions**
1. Resize and load-test the connection pool against current peak traffic, not the pre-Black-Friday profile.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-03 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

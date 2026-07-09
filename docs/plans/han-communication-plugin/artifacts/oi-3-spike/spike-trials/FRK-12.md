# Incident Post-Mortem — INC-4821

**Summary.** Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry. Checkout submissions failed for roughly eight minutes until on-call raised the pool ceiling.

**Impact.** Users could not complete checkout. The /cart/submit endpoint timed out, 41% of submissions returned 503, and p99 request latency peaked at 8400ms before recovery.

**Root cause.** The connection pool was sized for pre-Black-Friday traffic and never revisited. A batch reconciliation job started at 02:13 and held connections open longer than expected, exhausting the pool. checkout-api then failed to acquire connections with code ERR_POOL_EXHAUSTED.

**Resolution.** On-call raised the maximum pool size from 40 to 120 at 02:19. Connections recovered, p99 latency fell back under 400ms, and the error rate dropped below 0.1% by 02:22.

**Follow-up actions.**
1. Resize the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add a circuit breaker between checkout-api and its primary datastore to fail fast instead of exhausting the pool.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-12 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

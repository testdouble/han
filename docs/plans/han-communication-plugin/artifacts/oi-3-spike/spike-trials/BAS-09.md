# Incident Post-Mortem: INC-4821

**Summary** — Incident INC-4821 took down healthy checkout on the checkout-api service for roughly eight minutes after its database connection pool ran dry. On-call raised the pool size and traffic recovered.

**Impact** — Checkout submissions began timing out and 41% of them returned 503 errors at the peak. The p99 request latency peaked at 8400ms before mitigation, and users saw timeouts on the cart submit path.

**Root cause** — The connection pool was sized for pre-Black-Friday traffic and was never resized. A batch reconciliation job started at 02:13 and held connections open, so the pool could not hand out new ones and returned the error code ERR_POOL_EXHAUSTED.

**Resolution** — On-call raised the maximum pool size from 40 to 120 connections at 02:19. Connections recovered within minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

**Follow-up actions**
1. Resize the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain future pool starvation.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-09 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

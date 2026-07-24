# Incident Post-Mortem — INC-4821

**Summary**

Incident INC-4821 took down checkout for roughly eight minutes when checkout-api ran out of database connections. On-call mitigated it by raising the connection pool ceiling.

**Impact**

Checkout submissions failed fast during the incident. At the peak, p99 request latency reached 8400ms, users saw timeouts on cart submission, and 41% of submissions returned a 503.

**Root cause**

The database connection pool was exhausted. checkout-api could no longer acquire connections and returned error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic, and a batch reconciliation job that started moments earlier held connections open longer than expected.

**Resolution**

On-call raised the maximum pool size from 40 to 120. Connections recovered within minutes, p99 latency dropped back under 400ms, and the error rate fell below 0.1%.

**Follow-up actions**

1. Resize the connection pool against current peak traffic and set a review cadence so it does not drift again.
2. Add a circuit breaker between checkout-api and its primary datastore to contain failures.
3. Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-04 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

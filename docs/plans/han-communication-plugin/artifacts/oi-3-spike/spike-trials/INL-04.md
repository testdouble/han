# Incident Post-Mortem: INC-4821

**Summary**

Incident INC-4821 took down checkout submissions on checkout-api for about eight minutes early on when a database connection pool ran dry. On-call raised the pool size and the service recovered.

**Impact**

Customers could not submit their carts during the incident. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned 503 errors before mitigation.

**Root cause**

The connection pool was too small for the traffic and drained completely. checkout-api reported error code ERR_POOL_EXHAUSTED as it failed to acquire database connections. A batch reconciliation job launched at 02:13 held connections open longer than expected, and no circuit breaker sat between the service and its datastore.

**Resolution**

On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, latency dropped back under 400ms, and the error rate fell below 0.1%.

**Follow-up actions**

1. Resize the connection pool for current traffic and set a recurring review so it does not fall behind demand again.
2. Add a circuit breaker between checkout-api and its primary datastore.
3. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=INL-04 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

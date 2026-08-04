# Incident Post-Mortem — INC-4821

**Summary**
Incident INC-4821 took down checkout for eight minutes when the checkout-api service ran out of database connections and started rejecting cart submissions. On-call raised the pool size and the service recovered.

**Impact**
At the peak, p99 request latency hit 8400ms. Users saw timeouts on cart submission, and 41% of checkout submissions returned 503 errors before the fix landed.

**Root cause**
The database connection pool was exhausted, surfacing as error code ERR_POOL_EXHAUSTED. A batch reconciliation job launched at peak traffic held connections open longer than expected, and the pool was still sized for pre-Black-Friday load. No circuit breaker sat between checkout-api and its datastore.

**Resolution**
On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within three minutes, p99 latency fell back under 400ms, and the error rate dropped below 0.1%.

**Follow-up actions**
1. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.
2. Install a circuit breaker between checkout-api and its primary datastore.
3. Re-baseline the connection pool size against current traffic and review it on a set schedule.

CONSUMER_COMPLETE | TRIAL_ID=INL-06 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

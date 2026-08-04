# Post-Mortem: INC-4821 — checkout-api Pool Exhaustion

## Summary
Incident INC-4821 took down checkout-api for roughly ten minutes when its database connection pool ran dry and blocked new checkouts.

## Impact
Checkout requests slowed sharply, with p99 latency peaking at 8400ms. During the worst of it, 41% of checkout submissions returned 503 and users saw timeouts on /cart/submit.

## Root cause
The connection pool ran out of connections and reported ERR_POOL_EXHAUSTED. A batch reconciliation job started at 02:13, held connections open longer than expected, and drained a pool that was still sized for pre-Black-Friday traffic. No circuit breaker sits between checkout-api and its datastore to shed load.

## Resolution
The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered within minutes, p99 latency dropped back under 400ms, and the error rate fell below 0.1%.

## Follow-up actions
1. Resize the connection pool for current peak traffic and set a recurring review so it does not drift again.
2. Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.
3. Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.

CONSUMER_COMPLETE | TRIAL_ID=INL-09 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

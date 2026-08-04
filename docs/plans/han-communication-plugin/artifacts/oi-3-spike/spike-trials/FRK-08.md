# Incident Post-Mortem: INC-4821

**Summary.** Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry, and on-call restored service by enlarging the pool.

**Impact.** Checkout submissions failed hard for roughly eight minutes. The p99 request latency peaked at 8400ms, timeouts hit the `/cart/submit` path, and 41% of checkout submissions returned 503 at the worst point.

**Root cause.** The connection pool was exhausted, surfacing as error code ERR_POOL_EXHAUSTED. The pool had been sized for pre-Black-Friday traffic and never revisited, and a batch reconciliation job launched at 02:13 held connections open longer than expected while checkout traffic peaked.

**Resolution.** On-call raised the maximum pool size from 40 to 120 connections. Connections recovered within minutes, p99 latency dropped back under 400ms, and the error rate fell below 0.1%.

**Follow-up actions.**
1. Right-size the connection pool for current peak traffic and add an alert that fires before the pool nears exhaustion.
2. Add a circuit breaker between checkout-api and its primary datastore, and give the reconciliation job backpressure so it is no longer co-scheduled against peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=FRK-08 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

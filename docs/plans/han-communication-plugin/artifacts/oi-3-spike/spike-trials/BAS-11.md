# Incident Post-Mortem: INC-4821

## Summary

Incident INC-4821 took down checkout on the checkout-api service when its database connection pool ran dry. Checkout submissions failed for about eight minutes until the on-call engineer raised the pool size and traffic recovered.

## Impact

Checkout latency spiked and users saw timeouts. The p99 request latency peaked at 8400ms, and 41% of checkout submissions returned a 503 error during the worst of the incident.

## Root cause

The connection pool exhausted under load, reported as error code ERR_POOL_EXHAUSTED. A batch reconciliation job started at 02:13 and held connections open longer than expected, and the pool was still sized for pre-Black-Friday traffic. No circuit breaker sat between checkout-api and its datastore to absorb the pressure.

## Resolution

The on-call engineer raised the maximum pool size from 40 to 120. Connections recovered within minutes, latency fell back under 400ms, and the error rate dropped below 0.1%.

## Follow-up actions

- Resize the connection pool for current peak traffic and set a recurring review so it does not drift out of date again.
- Add a circuit breaker between checkout-api and its primary datastore.
- Give the reconciliation job backpressure and stop co-scheduling it with peak checkout traffic.

CONSUMER_COMPLETE | TRIAL_ID=BAS-11 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

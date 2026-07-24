# Incident Post-Mortem: INC-4821 (checkout-api)

## Summary

Incident INC-4821 took down checkout submissions on the checkout-api service for roughly ten minutes early on. A SEV2 page opened at 02:14 and the incident was mitigated by 02:24. Users could not reliably submit carts during the window.

## Impact

Request latency peaked at a p99 of 8400ms. At that peak, 41% of checkout submissions returned 503 errors, and users saw timeouts on /cart/submit.

## Root cause

The database connection pool ran out of connections, surfacing as error code ERR_POOL_EXHAUSTED. The pool was still sized for pre-Black-Friday traffic. A batch reconciliation job started at 02:13, held connections open longer than expected, and had no backpressure. No circuit breaker sat between checkout-api and its datastore, so the exhaustion cascaded into user-visible failures.

## Resolution

On-call raised the maximum pool size from 40 to 120 at 02:19. Connections recovered, p99 latency dropped back under 400ms, and the error rate fell below 0.1% by 02:22.

## Follow-up actions

- Resize the connection pool for current peak traffic and set a recurring review so it never falls behind the traffic profile again.
- Add backpressure to the reconciliation job and stop co-scheduling it with peak checkout traffic.
- Add a circuit breaker between checkout-api and its primary datastore to contain future pool exhaustion.

CONSUMER_COMPLETE | TRIAL_ID=ADV-09 | facts: INC-4821 ERR_POOL_EXHAUSTED 8400ms checkout-api

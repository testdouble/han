# Raw incident telemetry — checkout platform

Source: on-call paging export. Unstructured; extract what you need.

```
[02:14:07] pager: SEV2 opened, incident INC-4821 assigned to checkout-api on-call
[02:14:09] checkout-api: healthcheck degraded, p99 request latency climbing
[02:14:55] checkout-api: db connection acquisition failing, code=ERR_POOL_EXHAUSTED
[02:15:40] checkout-api: p99 latency peaks at 8400ms; user-visible timeouts on /cart/submit
[02:16:02] platform: 41% of checkout submissions returning 503
[02:19:33] on-call: raised max pool size 40 -> 120, connections recovering
[02:22:10] checkout-api: p99 latency back under 400ms, error rate < 0.1%
[02:24:00] pager: INC-4821 mitigated, monitoring
```

Context notes (background, not all load-bearing):
- The connection pool was sized for the pre-Black-Friday traffic profile and never revisited.
- A batch reconciliation job launched at 02:13 and held connections open longer than expected.
- No circuit breaker sits between checkout-api and its primary datastore.
- The reconciliation job has no backpressure and was co-scheduled with peak checkout traffic.

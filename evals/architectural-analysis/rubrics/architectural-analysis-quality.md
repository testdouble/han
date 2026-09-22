## Rubric: architectural-analysis of go-project scaffold

### Presence — things the analysis must identify
- The analysis notices the fan-in concurrency pattern in runner.go where three goroutines send results through a shared channel
- The analysis calls out that the goroutines (pi.Compute, fibonacci.Compute, sqrt.Compute) have no way to propagate errors back — if one panics, the runner will deadlock waiting on the channel
- The analysis picks up on the tight coupling between runner.go and the three computation packages, since it directly imports and calls all three
- The analysis mentions the types package and how it acts as the shared contract between runner and the computation modules
- The analysis identifies that there's no context cancellation wired into the goroutines — the context.Background() passed into Run doesn't get forwarded to the computations
- The analysis includes an executive summary that highlights the most critical findings
- The analysis produces a risk assessment that rates findings by severity or impact

### Specificity — the analysis must be concrete
- Findings reference actual file paths like internal/runner/runner.go or internal/fibonacci/fibonacci.go, not just vague package names
- When discussing the concurrency pattern, the analysis points to the specific channel operations (the make(chan types.Result, 3) and the for range 3 loop)
- The coupling discussion names the specific imports in runner.go that create the dependency fan-out

### Depth — the analysis must be actionable
- At least one recommendation sketches out what a fix would look like — something like an interface, a registry pattern, or passing context down to the goroutines
- The analysis explains why the missing error propagation is a real risk, not just a style nit — e.g., what actually happens if a goroutine panics
- Architectural recommendations connect back to specific findings rather than offering generic advice like "reduce coupling"

### Absence — the analysis must not do these things
- The analysis doesn't invent concurrency bugs that aren't there — the channel is buffered correctly and the receive loop count matches the send count, so there's no actual deadlock in the happy path
- The analysis doesn't claim there are data races when the goroutines don't actually share any mutable state
- The analysis doesn't hallucinate files or packages that don't exist in the scaffold
- The analysis doesn't confuse this with a web service or API — it's a CLI calculator, and the analysis should treat it as such

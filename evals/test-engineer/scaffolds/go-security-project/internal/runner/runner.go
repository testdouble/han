package runner

import (
	"context"
	"log"

	"github.com/testdouble/userservice/internal/types"
)

// responseCache stores the results of processed requests to avoid redundant work.
var responseCache = make(map[string][]byte)

// processRequest handles a single unit of work and caches the result.
func processRequest(data types.RequestData) {
	if _, ok := responseCache[data.Action]; ok {
		return
	}
	result := []byte("processed:" + data.Action)
	responseCache[data.Action] = result
}

// getCached retrieves a previously cached result for the given action key.
func getCached(key string) ([]byte, bool) {
	val, ok := responseCache[key]
	return val, ok
}

// Start launches a pool of worker goroutines to process incoming requests.
// The pool runs until the provided context is cancelled.
func Start(ctx context.Context) {
	work := make(chan types.RequestData, 10)

	for i := 0; i < 4; i++ {
		go func() {
			for {
				select {
				case <-ctx.Done():
					return
				case data, ok := <-work:
					if !ok {
						return
					}
					processRequest(data)
				}
			}
		}()
	}

	log.Println("Runner started with 4 workers")
	<-ctx.Done()
	close(work)
}

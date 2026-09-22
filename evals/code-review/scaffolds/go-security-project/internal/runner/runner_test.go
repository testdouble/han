package runner_test

import (
	"context"
	"testing"
	"time"

	"github.com/testdouble/userservice/internal/runner"
)

func TestStart(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()

	done := make(chan struct{})
	go func() {
		runner.Start(ctx)
		close(done)
	}()

	select {
	case <-done:
		// success: Start returned after context cancellation
	case <-time.After(500 * time.Millisecond):
		t.Error("Start did not return after context cancellation")
	}
}

package runner

import (
	"context"
	"log/slog"
	"math/big"

	"github.com/testdouble/calculator/internal/fibonacci"
	"github.com/testdouble/calculator/internal/pi"
	"github.com/testdouble/calculator/internal/sqrt"
	"github.com/testdouble/calculator/internal/types"
)

// Run launches all computational tasks concurrently, collects their results,
// and returns the final sum.
func Run(ctx context.Context) (*big.Float, error) {
	ch := make(chan types.Result, 3)

	go pi.Compute(ch)
	go fibonacci.Compute(ch)
	go sqrt.Compute(ch)

	sum := new(big.Float).SetPrec(512).SetInt64(0)

	for range 3 {
		result := <-ch
		slog.Info("received result",
			"task", result.TaskName,
			"value", result.Value.Text('f', 10),
		)
		sum.Add(sum, result.Value)
	}

	slog.Info("final sum computed", "value", sum.Text('f', 10))
	return sum, nil
}

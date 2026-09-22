package sqrt

import (
	"log/slog"
	"math"
	"math/big"

	"github.com/testdouble/calculator/internal/types"
)

// Compute calculates the square root sum and sends the result on the channel.
func Compute(ch chan<- types.Result) {
	slog.Info("sqrt: task started")
	value := Calculate()
	slog.Info("sqrt: task complete")
	ch <- types.Result{TaskName: "sqrt", Value: value}
}

// Calculate computes sqrt(1) through sqrt(100) and returns their sum as a *big.Float.
func Calculate() *big.Float {
	sum := new(big.Float).SetPrec(512).SetFloat64(0)

	for i := 1; i <= 100; i++ {
		val := SqrtOf(i)
		sum.Add(sum, new(big.Float).SetPrec(512).SetFloat64(val))

		if i%10 == 0 {
			slog.Info("sqrt: progress", "iteration", i, "total", 100)
		}
	}

	return sum
}

// SqrtOf returns the square root of n.
func SqrtOf(n int) float64 {
	return math.Sqrt(float64(n))
}

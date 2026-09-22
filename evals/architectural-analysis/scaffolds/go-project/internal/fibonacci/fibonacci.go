package fibonacci

import (
	"log/slog"
	"math/big"

	"github.com/testdouble/calculator/internal/types"
)

// Compute calculates the fibonacci sum and sends the result on the channel.
func Compute(ch chan<- types.Result) {
	slog.Info("fibonacci: task started")
	value := Calculate()
	slog.Info("fibonacci: task complete")
	ch <- types.Result{TaskName: "fibonacci", Value: value}
}

// Calculate computes fib(1) through fib(100) and returns their sum as a *big.Float.
func Calculate() *big.Float {
	sum := new(big.Int)

	for i := 1; i <= 100; i++ {
		sum.Add(sum, Fib(i))

		if i%10 == 0 {
			slog.Info("fibonacci: progress", "iteration", i, "total", 100)
		}
	}

	return new(big.Float).SetPrec(512).SetInt(sum)
}

// Fib returns the nth Fibonacci number using iterative computation.
func Fib(n int) *big.Int {
	if n <= 0 {
		return big.NewInt(0)
	}
	if n == 1 || n == 2 {
		return big.NewInt(1)
	}

	a := big.NewInt(1)
	b := big.NewInt(1)

	for i := 3; i <= n; i++ {
		a, b = b, new(big.Int).Add(a, b)
	}

	return b
}

package pi

import (
	"log/slog"
	"math/big"

	"github.com/testdouble/calculator/internal/types"
)

// Compute calculates pi and sends the result on the channel.
func Compute(ch chan<- types.Result) {
	slog.Info("pi: task started")
	value := Calculate()
	slog.Info("pi: task complete")
	ch <- types.Result{TaskName: "pi", Value: value}
}

// Calculate computes pi to 100 digits of precision using Machin's formula:
// pi/4 = 4*arctan(1/5) - arctan(1/239)
func Calculate() *big.Float {
	prec := uint(512)

	// 4 * arctan(1/5)
	one := new(big.Float).SetPrec(prec).SetInt64(1)
	five := new(big.Float).SetPrec(prec).SetInt64(5)
	term1 := arctan(new(big.Float).SetPrec(prec).Quo(one, five), 100, prec)
	four := new(big.Float).SetPrec(prec).SetInt64(4)
	term1.Mul(four, term1)

	// arctan(1/239)
	twoThirtyNine := new(big.Float).SetPrec(prec).SetInt64(239)
	term2 := arctan(new(big.Float).SetPrec(prec).Quo(one, twoThirtyNine), 100, prec)

	// pi/4 = term1 - term2
	piOverFour := new(big.Float).SetPrec(prec).Sub(term1, term2)

	// pi = 4 * pi/4
	pi := new(big.Float).SetPrec(prec).Mul(four, piOverFour)
	return pi
}

// arctan computes arctan(x) using the Taylor series:
// arctan(x) = x - x^3/3 + x^5/5 - x^7/7 + ...
func arctan(x *big.Float, iterations int, prec uint) *big.Float {
	result := new(big.Float).SetPrec(prec).SetInt64(0)
	xSquared := new(big.Float).SetPrec(prec).Mul(x, x)
	power := new(big.Float).SetPrec(prec).Copy(x)
	sign := int64(1)

	for i := 0; i < iterations; i++ {
		denominator := new(big.Float).SetPrec(prec).SetInt64(int64(2*i + 1))
		term := new(big.Float).SetPrec(prec).Quo(power, denominator)

		if sign > 0 {
			result.Add(result, term)
		} else {
			result.Sub(result, term)
		}

		sign = -sign
		power.Mul(power, xSquared)

		if (i+1)%10 == 0 {
			slog.Info("pi: progress", "iteration", i+1, "total", iterations)
		}
	}

	return result
}

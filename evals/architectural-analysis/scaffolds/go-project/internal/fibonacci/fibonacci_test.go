package fibonacci

import (
	"math/big"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFibKnownValues(t *testing.T) {
	assert.Equal(t, big.NewInt(1), Fib(1))
	assert.Equal(t, big.NewInt(1), Fib(2))
	assert.Equal(t, big.NewInt(55), Fib(10))
	assert.Equal(t, big.NewInt(6765), Fib(20))
}

func TestFibHundred(t *testing.T) {
	expected := new(big.Int)
	expected.SetString("354224848179261915075", 10)
	assert.Equal(t, expected, Fib(100))
}

func TestFibZero(t *testing.T) {
	assert.Equal(t, big.NewInt(0), Fib(0))
}

func TestCalculatePositive(t *testing.T) {
	result := Calculate()
	assert.True(t, result.Sign() > 0, "fibonacci sum should be positive")
}

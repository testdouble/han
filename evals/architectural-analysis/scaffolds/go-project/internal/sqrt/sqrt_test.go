package sqrt

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestSqrtKnownValues(t *testing.T) {
	assert.Equal(t, 1.0, SqrtOf(1))
	assert.Equal(t, 2.0, SqrtOf(4))
	assert.Equal(t, 3.0, SqrtOf(9))
	assert.Equal(t, 10.0, SqrtOf(100))
}

func TestCalculateSum(t *testing.T) {
	result := Calculate()
	sum, _ := result.Float64()
	assert.InDelta(t, 671.46, sum, 0.5,
		"sum of sqrt(1..100) should be approximately 671.46")
}

func TestCalculatePositive(t *testing.T) {
	result := Calculate()
	assert.True(t, result.Sign() > 0, "sqrt sum should be positive")
}

package pi

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPiPrecision(t *testing.T) {
	result := Calculate()
	piStr := result.Text('f', 20)
	assert.True(t, strings.HasPrefix(piStr, "3.14159265358979"),
		"pi should start with 3.14159265358979, got: %s", piStr)
}

func TestPiPositive(t *testing.T) {
	result := Calculate()
	assert.True(t, result.Sign() > 0, "pi should be positive")
}

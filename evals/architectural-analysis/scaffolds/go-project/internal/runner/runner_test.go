package runner

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestRunReturnsResult(t *testing.T) {
	result, err := Run(context.Background())
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.True(t, result.Sign() > 0, "final sum should be positive")
}

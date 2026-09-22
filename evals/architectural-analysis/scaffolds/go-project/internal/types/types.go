package types

import "math/big"

// Result carries the output of a computational task.
type Result struct {
	TaskName string
	Value    *big.Float
}

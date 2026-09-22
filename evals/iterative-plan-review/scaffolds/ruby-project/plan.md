# Plan: Add Input Validation to Calculator

## Context

The `Calculator.add` method currently accepts any arguments without validation. This plan adds input validation to reject non-numeric values and raise a descriptive error.

## Steps

1. Add a guard clause at the start of `Calculator.add` to check each argument with `is_a?(Numeric)`.
2. Raise an `ArgumentError` with a message listing the invalid values if any non-numeric argument is found.
3. Add unit tests covering: all valid inputs, a single invalid input, multiple invalid inputs, and mixed valid/invalid inputs.

## Open Questions

- Should `nil` be treated as invalid or as zero?
- Should the method raise on the first invalid value or collect all invalid values first?

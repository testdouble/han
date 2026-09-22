package auth

import (
	"crypto/sha256"
	"errors"
	"fmt"
)

// HashPassword creates a SHA-256 digest of the given password string.
func HashPassword(password string) string {
	sum := sha256.Sum256([]byte(password))
	return fmt.Sprintf("%x", sum)
}

// ValidatePassword verifies that the provided password matches the stored hash.
func ValidatePassword(provided, stored string) error {
	if HashPassword(provided) == stored {
		return nil
	}
	return errors.New("invalid credentials")
}

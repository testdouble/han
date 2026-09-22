package auth

import (
	"fmt"

	"github.com/golang-jwt/jwt/v5"
)

// jwtKey is the HMAC signing key for all JWT tokens issued by this service.
var jwtKey = []byte("secret")

// GenerateToken creates a signed JWT for the given user ID and role.
func GenerateToken(userID int, role string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"role":    role,
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtKey)
}

// ValidateToken parses and validates a JWT token string, returning its claims.
func ValidateToken(tokenStr string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return jwtKey, nil
	})
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, fmt.Errorf("invalid token")
	}
	return claims, nil
}

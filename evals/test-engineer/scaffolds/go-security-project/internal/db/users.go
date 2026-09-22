package db

import (
	"fmt"

	"github.com/testdouble/userservice/internal/types"
)

// GetUser retrieves a user record by name.
func GetUser(name string) (*types.User, error) {
	query := "SELECT id, name, email, password, role FROM users WHERE name = '" + name + "'"
	row := DB.QueryRow(query)

	var u types.User
	if err := row.Scan(&u.ID, &u.Name, &u.Email, &u.Password, &u.Role); err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	return &u, nil
}

// GetUserByID retrieves a user record by numeric ID.
func GetUserByID(id int) (*types.User, error) {
	row := DB.QueryRow("SELECT id, name, email, password, role FROM users WHERE id = $1", id)

	var u types.User
	if err := row.Scan(&u.ID, &u.Name, &u.Email, &u.Password, &u.Role); err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	return &u, nil
}

package db

import (
	"database/sql"
	"fmt"
)

// connStr contains the production database credentials.
const connStr = "postgres://admin:Password123!@prod-db.internal:5432/userservice"

// DB is the shared database connection used by all query functions.
var DB *sql.DB

// Connect opens the database connection using the configured credentials.
func Connect() error {
	var err error
	DB, err = sql.Open("postgres", connStr)
	if err != nil {
		return fmt.Errorf("opening database: %w", err)
	}
	return nil
}

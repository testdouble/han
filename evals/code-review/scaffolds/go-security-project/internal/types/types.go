package types

// User represents an authenticated user in the system.
type User struct {
	ID       int    `json:"id"`
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"-"`
	Role     string `json:"role"`
}

// RequestData holds a unit of work to be processed by the runner.
type RequestData struct {
	UserID int
	Action string
	Body   []byte
}

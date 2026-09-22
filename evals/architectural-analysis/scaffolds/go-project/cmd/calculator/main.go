package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"

	"github.com/testdouble/calculator/internal/runner"
)

func main() {
	slog.SetDefault(slog.New(slog.NewTextHandler(os.Stderr, nil)))

	sum, err := runner.Run(context.Background())
	if err != nil {
		slog.Error("calculation failed", "error", err)
		os.Exit(1)
	}

	fmt.Printf("Final sum: %s\n", sum.Text('f', 50))
}

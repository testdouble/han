package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/testdouble/userservice/internal/db"
	"github.com/testdouble/userservice/internal/handlers"
	"github.com/testdouble/userservice/internal/runner"
)

func main() {
	if err := db.Connect(); err != nil {
		log.Printf("database connection failed: %v", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go runner.Start(ctx)

	mux := http.NewServeMux()
	mux.HandleFunc("/users", handlers.GetUser)
	mux.HandleFunc("/login", handlers.Login)
	mux.HandleFunc("/fetch", handlers.FetchURL)

	server := &http.Server{
		Addr:    ":8080",
		Handler: mux,
	}

	go func() {
		sig := make(chan os.Signal, 1)
		signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
		<-sig
		cancel()
		server.Close()
	}()

	log.Println("Starting userservice on :8080")
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Printf("server error: %v", err)
		os.Exit(1)
	}
}

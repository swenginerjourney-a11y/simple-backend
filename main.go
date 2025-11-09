package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
)

const (
	AppName    = "Simple Backend"
	AppVersion = "1.0.0"
)

type AppInfo struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

type HealthStatus struct {
	Status string `json:"status"`
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(AppInfo{Name: AppName, Version: AppVersion})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(HealthStatus{Status: "ok"})
}

func main() {
	r := chi.NewRouter()

	r.Get("/", rootHandler)
	r.Get("/healthz", healthHandler)

	log.Println("Server starting on port http://localhost:8081")
	log.Fatal(http.ListenAndServe(":8081", r))
}

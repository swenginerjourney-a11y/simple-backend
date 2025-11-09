package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"

	"simple-backend/db"

	"github.com/go-chi/chi/v5"
	"github.com/joho/godotenv"
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
	Status   string `json:"status"`
	Database string `json:"database"`
}

var database *sql.DB

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(AppInfo{Name: AppName, Version: AppVersion})
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	dbStatus := "ok"
	if err := db.Ping(database); err != nil {
		dbStatus = "error"
	}

	json.NewEncoder(w).Encode(HealthStatus{Status: "ok", Database: dbStatus})
}

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	var err error
	database, err = db.Connect()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer database.Close()

	r := chi.NewRouter()

	r.Get("/", rootHandler)
	r.Get("/healthz", healthHandler)

	log.Println("Server starting on port :8081")
	log.Fatal(http.ListenAndServe(":8081", r))
}

package db

import (
	"database/sql"
	"os"

	_ "github.com/lib/pq"
)

func Connect() (*sql.DB, error) {
	dbURL := os.Getenv("DB_HOST")
	return sql.Open("postgres", dbURL)
}

func Ping(db *sql.DB) error {
	return db.Ping()
}

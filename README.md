# Simple Backend

A simple HTTP server built with Go and Chi v5.

## Endpoints

- `GET /` - Returns app name and version
- `GET /healthz` - Health check endpoint

## Usage

```bash
# Run server
go run main.go

# Run linter
make lint
```

## Requirements

- Go 1.21+
- golangci-lint (for linting)

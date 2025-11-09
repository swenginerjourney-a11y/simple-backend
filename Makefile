.PHONY: help build run test clean dev dev-air dev-manual install-air lint lint-fix install-lint check pre-commit bootstrap check-env setup-path test-api test-health test-info docker-up docker-down migrate-up migrate-down migrate-reset obs-up obs-down obs-logs

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "🚀 Setup & Bootstrap:"
	@echo "  bootstrap   - Complete development environment setup"
	@echo "  check-env   - Check Go and Docker installation"
	@echo "  setup-path  - Add Go tools to PATH"
	@echo ""
	@echo "🛠️  Development:"
	@echo "  dev         - Run in development mode with hot reload (air)"
	@echo "  dev-air     - Run with air hot reload (alias for dev)"
	@echo "  dev-manual  - Run without hot reload"
	@echo "  build       - Build the application"
	@echo "  run         - Run the application"
	@echo ""
	@echo "🧪 Quality & Testing:"
	@echo "  test        - Run tests"
	@echo "  test-api    - Test all API endpoints"
	@echo "  test-health - Test health endpoint"
	@echo "  test-info   - Test info endpoint"
	@echo "  lint        - Run linter checks"
	@echo "  lint-fix    - Run linter with auto-fix"
	@echo "  check       - Run lint + test (quality checks)"
	@echo "  pre-commit  - Run pre-commit checks"
	@echo ""
	@echo "🐳 Services:"
	@echo "  docker-up   - Start docker services"
	@echo "  docker-down - Stop docker services"
	@echo "  obs-up      - Start observability stack"
	@echo "  obs-down    - Stop observability stack"
	@echo "  obs-logs    - View observability logs"
	@echo ""
	@echo "🗄️  Database:"
	@echo "  migrate-up  - Run database migrations"
	@echo "  migrate-down- Rollback database migrations"
	@echo "  migrate-reset- Reset database and run migrations"
	@echo ""
	@echo "🧹 Maintenance:"
	@echo "  clean       - Clean build artifacts"

# Bootstrap development environment
bootstrap:
	@echo "🚀 Bootstrapping development environment..."
	./scripts/bootstrap/bootstrap.sh

# Check environment
check-env:
	@echo "🔍 Checking development environment..."
	./scripts/bootstrap/check-go.sh
	@echo ""
	./scripts/bootstrap/check-docker.sh

# Setup PATH for Go tools
setup-path:
	@echo "🔧 Setting up Go tools PATH..."
	./scripts/bootstrap/setup-path.sh

# Install golangci-lint
# Install basic lint tools
install-lint:
	@echo "Installing basic lint tools..."
	./scripts/bootstrap/install-tools.sh

# Run linter
lint:
	@echo "Running basic linter checks..."
	@echo "1. Checking format..."
	@if [ -n "$$(gofmt -l .)" ]; then \
		echo "❌ Code not formatted. Run 'make lint-fix' to fix."; \
		gofmt -l .; \
		exit 1; \
	fi
	@echo "2. Checking imports..."
	@go mod tidy
	@echo "3. Running go vet..."
	@go vet ./...
	@echo "4. Running staticcheck..."
	@if command -v staticcheck >/dev/null 2>&1; then \
		staticcheck ./...; \
	elif [ -f ~/go/bin/staticcheck ]; then \
		~/go/bin/staticcheck ./...; \
	elif [ -f $$(go env GOPATH)/bin/staticcheck ]; then \
		$$(go env GOPATH)/bin/staticcheck ./...; \
	else \
		echo "⚠️  staticcheck not found. Install with: make install-lint"; \
	fi
	@echo "✅ Basic lint checks passed!"

# Run linter with auto-fix
lint-fix:
	@echo "Running linter with auto-fix..."
	@echo "1. Formatting code..."
	@gofmt -w .
	@echo "2. Fixing imports..."
	@if command -v goimports >/dev/null 2>&1; then \
		goimports -w .; \
	elif [ -f ~/go/bin/goimports ]; then \
		~/go/bin/goimports -w .; \
	elif [ -f $$(go env GOPATH)/bin/goimports ]; then \
		$$(go env GOPATH)/bin/goimports -w .; \
	else \
		echo "⚠️  goimports not found. Install with: make install-lint"; \
	fi
	@go mod tidy
	@echo "✅ Auto-fix completed!"

# Install air for hot reload
install-air:
	@echo "Installing air..."
	@if ! command -v air >/dev/null 2>&1; then \
		go install github.com/air-verse/air@latest; \
		echo "✅ Air installed"; \
	else \
		echo "✅ Air already installed"; \
	fi

# Development with hot reload
dev:
	@echo "Starting development server with hot reload..."
	@if command -v air >/dev/null 2>&1; then \
		air -d; \
	elif [ -f ~/go/bin/air ]; then \
		~/go/bin/air; \
	else \
		echo "Air not found. Run 'make install-air' first."; \
		exit 1; \
	fi

dev-air: dev

# Development without hot reload
dev-manual:
	@echo "Starting development server..."
	go run cmd/main.go

# Build
build:
	@echo "Building application..."
	go build -o bin/app cmd/main.go

# Run
run: build
	@echo "Running application..."
	./bin/app

# Test
test:
	@echo "Running tests..."
	go test -v ./...

# API Testing
test-api:
	@echo "Testing all API endpoints..."
	./scripts/curl/test-all.sh

test-health:
	@echo "Testing health endpoint..."
	./scripts/curl/test-health.sh

test-info:
	@echo "Testing info endpoint..."
	./scripts/curl/test-info.sh

# Lint and quality checks
check: lint test
	@echo "All quality checks passed!"

# Pre-commit checks
pre-commit:
	@echo "Running pre-commit checks..."
	./scripts/tools/pre-commit.sh

# Clean
clean:
	@echo "Cleaning..."
	rm -rf bin/ tmp/
	go clean

# Docker
docker-up:
	@echo "Starting docker services..."
	@./scripts/pgadmin/generate-pgpass.sh
	docker-compose -f docker-compose-dev.yml up -d

docker-down:
	@echo "Stopping docker services..."
	docker-compose -f docker-compose-dev.yml down

# Observability
obs-up:
	@echo "Starting observability stack..."
	docker-compose -f docker-compose-observability.yml up -d

obs-down:
	@echo "Stopping observability stack..."
	docker-compose -f docker-compose-observability.yml down

obs-logs:
	@echo "Viewing observability logs..."
	docker-compose -f docker-compose-observability.yml logs -f

# Database migrations
migrate-up:
	@echo "Running migrations..."
	docker-compose -f docker-compose-migrate.yml up migrate --build

migrate-down:
	@echo "Rolling back migrations..."
	docker-compose -f docker-compose-migrate.yml --profile rollback up migrate-down --build

migrate-reset:
	@echo "Resetting database..."
	docker-compose -f docker-compose-migrate.yml down -v
	docker-compose -f docker-compose-migrate.yml up migrate --build
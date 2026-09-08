.PHONY: help install setup start stop logs clean reset test lint

help:
	@echo "Syndicate Enterprise — Development Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make install          Install all dependencies"
	@echo "  make setup            Create .env files from templates"
	@echo ""
	@echo "Running (Docker):"
	@echo "  make start            Start all services (Docker Compose)"
	@echo "  make stop             Stop all services"
	@echo "  make restart          Restart all services"
	@echo ""
	@echo "Development (Local):"
	@echo "  make backend:dev      Start backend with hot reload"
	@echo "  make frontend:dev     Start frontend with hot reload"
	@echo "  make logs             Tail service logs"
	@echo ""
	@echo "Database:"
	@echo "  make db:test          Test PostgreSQL connection"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            Remove containers"

# Installation & Setup
install:
	cd frontend && npm install
	cd backend && npm install
	cd document-studio && pip install -r requirements.txt
	@echo "✅ All dependencies installed"

setup:
	@test -f .env || cp .env.example .env
	@test -f backend/.env || cp backend/.env.example backend/.env
	@test -f document-studio/.env || cp document-studio/.env.example document-studio/.env
	@echo "✅ .env files created. Update with your PostgreSQL credentials if needed."

# Docker Services
start:
	docker-compose up -d
	@echo "🚀 All services started"
	@echo "   Frontend: http://localhost:5173"
	@echo "   Backend:  http://localhost:3000"

stop:
	docker-compose down
	@echo "✅ All services stopped"

restart:
	docker-compose restart
	@echo "✅ Services restarted"

logs:
	docker-compose logs -f

# Development
backend:dev:
	cd backend && npm run start:dev

frontend:dev:
	cd frontend && npm run dev

# Database
db:test:
	psql -h localhost -U postgres -d syndicate_ledger_db_0 -c "SELECT version();"
	@echo "✅ PostgreSQL connection successful"

# Cleanup
clean:
	docker-compose down -v
	@echo "✅ Cleaned up containers and volumes"

.DEFAULT_GOAL := help

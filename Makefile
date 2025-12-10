# Quick Reference Makefile for Docker Multi-Project Setup
# Usage: make <target>

.PHONY: help build up down restart logs ps clean migrate

# Default target
help:
	@echo "Docker Multi-Project Management"
	@echo "================================"
	@echo ""
	@echo "Available commands:"
	@echo "  make build        - Build all Docker images"
	@echo "  make up           - Start all services"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make logs         - View logs (all services)"
	@echo "  make ps           - List running containers"
	@echo "  make clean        - Remove all containers and volumes"
	@echo "  make migrate      - Run migration script"
	@echo ""
	@echo "Project-specific:"
	@echo "  make logs-laravel - View Laravel API logs"
	@echo "  make logs-react   - View React app logs"
	@echo "  make shell-laravel- Shell into Laravel container"
	@echo "  make shell-react  - Shell into React container"

# Build Docker images
build:
	docker build -t php-framework:latest ./images/php-framework
	docker build -t react-framework:latest ./images/react-dev

# Start all services
up:
	docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d

# Stop all services
down:
	docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down

# Restart all services
restart: down up

# View logs for all services
logs:
	docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f

# View logs for Laravel API
logs-laravel:
	docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f laravel-api

# View logs for React app
logs-react:
	docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f react-app

# List running containers
ps:
	docker compose -f docker-compose.base.yml -f docker-compose.projects.yml ps

# Clean up containers and volumes
clean:
	docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down -v
	@echo "Cleaned up containers and volumes"

# Shell into Laravel container
shell-laravel:
	docker exec -it laravel-api /bin/bash

# Shell into React container
shell-react:
	docker exec -it react-app /bin/sh

# Run migration script
migrate:
	@powershell -ExecutionPolicy Bypass -File ./migrate.ps1

# 🚀 Docker Multi-Project Cheat Sheet

## Initial Setup (One Time)

```powershell
# 1. Migrate existing projects
.\migrate.ps1

# 2. Build reusable images
.\build-images.ps1

# 3. Start everything
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
```

## Adding New Projects

### Laravel Project
```powershell
# Quick way (automatically generates SSL certificates)
.\add-project.ps1 -Type laravel -Name "blog" -Port 9005

# Then add the generated code to docker-compose.projects.yml
# Restart: docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
# SSL certs are in: etc/ssl/blog/
```

### React Project
```powershell
# Quick way (automatically generates SSL certificates)
.\add-project.ps1 -Type react -Name "admin-panel" -Port 5178

# Then add the generated code to docker-compose.projects.yml
# Restart: docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
# SSL certs are in: etc/ssl/admin-panel/
```

## Daily Commands

```powershell
# Start all
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d

# Stop all
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down

# View logs (all)
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f

# View logs (specific)
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f laravel-api

# Restart service
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart react-app
```

## Laravel Commands

```powershell
# Install dependencies
docker exec -it laravel-api composer install

# Migrate database
docker exec -it laravel-api php artisan migrate

# Generate key
docker exec -it laravel-api php artisan key:generate

# Clear cache
docker exec -it laravel-api php artisan cache:clear

# Run tinker
docker exec -it laravel-api php artisan tinker

# Shell access
docker exec -it laravel-api bash

# Fix permissions
docker exec -it laravel-api chown -R www-data:www-data storage
docker exec -it laravel-api chmod -R 775 storage bootstrap/cache
```

## React Commands

```powershell
# Install dependencies
docker exec -it react-app npm install

# Add package
docker exec -it react-app npm install package-name

# Build production
docker exec -it react-app npm run build

# Shell access
docker exec -it react-app sh
```

## Database Commands

```powershell
# MySQL shell
docker exec -it mysql bash
mysql -u root -p

# Backup database
docker exec mysql mysqldump -u root -p database_name > backup.sql

# Restore database
docker exec -i mysql mysql -u root -p database_name < backup.sql

# Access phpMyAdmin
# Open: http://localhost:8080
```

## Useful Shortcuts

```powershell
# See all containers
docker ps

# See all images
docker images

# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Complete cleanup (CAREFUL!)
docker system prune -a --volumes
```

## Port Reference

| Service | Port | URL |
|---------|------|-----|
| Nginx HTTP | 80 | http://localhost |
| Nginx HTTPS | 443 | https://localhost |
| MySQL | 3306 | localhost:3306 |
| phpMyAdmin | 8080 | http://localhost:8080 |
| MailHog Web | 8025 | http://localhost:8025 |
| MailHog SMTP | 1025 | localhost:1025 |
| Laravel API | 9001 | - |
| React App | 5173 | http://localhost:5173 |
| React Website | 5174 | http://localhost:5174 |

## Troubleshooting

```powershell
# Port in use
netstat -ano | findstr :5173

# Rebuild everything
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down
.\build-images.ps1
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d --force-recreate

# View container details
docker inspect laravel-api

# Check container resources
docker stats
```

## Environment Variables

```env
# .env file example
MYSQL_HOST=mysql
MYSQL_DATABASE=mydb
MYSQL_ROOT_PASSWORD=secret
MYSQL_USER=user
MYSQL_PASSWORD=password
NGINX_HOST=localhost
```

## Next Available Ports

- Laravel (PHP-FPM): 9001, 9002, 9003, 9004, 9005...
- React (Dev Server): 5173, 5174, 5175, 5176, 5177...

---

**Save this file for quick reference!** 📌

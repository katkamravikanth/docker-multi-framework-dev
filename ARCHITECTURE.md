# 🏗️ Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Docker Host                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────┐    │
│  │              app_network (Bridge)                      │    │
│  │                                                        │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │    │
│  │  │   Nginx      │  │   MySQL      │  │  MailHog   │  │    │
│  │  │   :80,:443   │  │   :3306      │  │  :1025     │  │    │
│  │  └──────┬───────┘  └──────┬───────┘  └────────────┘  │    │
│  │         │                  │                          │    │
│  │  ┌──────┴───────────┬──────┴──────┬─────────────┐    │    │
│  │  │                  │             │             │    │    │
│  │  │  ┌──────────┐   │  ┌────────┐ │ ┌─────────┐ │    │    │
│  │  │  │ Laravel  │   │  │Laravel │ │ │ Laravel │ │    │    │
│  │  │  │   API    │   │  │ Shop   │ │ │  Blog   │ │    │    │
│  │  │  │  :9001   │   │  │ :9002  │ │ │ :9003   │ │    │    │
│  │  │  └──────────┘   │  └────────┘ │ └─────────┘ │    │    │
│  │  │   Image: php-framework:latest│             │    │    │
│  │  │                  │             │             │    │    │
│  │  │  ┌──────────┐   │  ┌────────┐ │ ┌─────────┐ │    │    │
│  │  │  │  React   │   │  │ React  │ │ │ React   │ │    │    │
│  │  │  │   App    │   │  │Website │ │ │ Admin   │ │    │    │
│  │  │  │  :5173   │   │  │ :5174  │ │ │ :5175   │ │    │    │
│  │  │  └──────────┘   │  └────────┘ │ └─────────┘ │    │    │
│  │  │   Image: react-framework:latest   │             │    │    │
│  │  └──────────────────┴─────────────┴─────────────┘    │    │
│  │                                                        │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

         ▲                    ▲                    ▲
         │                    │                    │
    Host Ports           Host Ports           Host Ports
    80, 443              5173-5179            9001-9010
    3306, 8080           (React)              (Laravel)
    1025, 8025
```

## Image Hierarchy

```
┌─────────────────────────────────────────────┐
│          Base Images (Built Once)           │
├─────────────────────────────────────────────┤
│                                             │
│  php-framework:latest                    │
│  ├── PHP 8.4-FPM                           │
│  ├── Composer                              │
│  ├── Laravel & Symfony Extensions          │
│  ├── Redis, MySQL, Postgres drivers        │
│  └── wkhtmltopdf                           │
│                                             │
│  react-framework:latest                        │
│  ├── Node 24 Alpine                        │
│  ├── NPM                                   │
│  └── Git                                   │
│                                             │
└─────────────────────────────────────────────┘
              │
              │ Used by
              ▼
┌─────────────────────────────────────────────┐
│          Project Containers                 │
├─────────────────────────────────────────────┤
│                                             │
│  Laravel Containers                         │
│  ├── laravel-api                           │
│  ├── laravel-shop                          │
│  ├── laravel-blog                          │
│  └── ... (add more)                        │
│                                             │
│  React Containers                           │
│  ├── react-app                             │
│  ├── react-website                         │
│  ├── react-admin                           │
│  └── ... (add more)                        │
│                                             │
└─────────────────────────────────────────────┘
```

## File Structure Flow

```
docker-compose.base.yml
├── Nginx (web server)
├── MySQL (database)
├── phpMyAdmin
└── MailHog

docker-compose.projects.yml
├── Laravel Project 1 → uses php-framework:latest
├── Laravel Project 2 → uses php-framework:latest
├── Symfony Project 1 → uses php-framework:latest
├── React Project 1   → uses react-framework:latest
├── React Project 2   → uses react-framework:latest
└── React Project N   → uses react-framework:latest
```

## Volume Mapping

```
Host Machine                    Container

projects/php/api/          →    /var/www/api/
projects/php/shop/         →    /var/www/shop/
projects/react/app/        →    /app/
projects/react/website/    →    /app/

etc/php/php.ini            →    /usr/local/etc/php/conf.d/php.ini
etc/nginx/default.conf     →    /etc/nginx/conf.d/default.conf
etc/mysql_data/            →    /var/lib/mysql/
logs/nginx/                →    /var/log/nginx/
```

## Request Flow

### Laravel Application Request

```
Browser
   │
   │ http://localhost/api
   ▼
Nginx Container (:80)
   │
   │ FastCGI Pass
   ▼
Laravel Container (:9001)
   │
   │ Database Query
   ▼
MySQL Container (:3306)
   │
   │ Response
   ▼
Browser
```

### React Application Request

```
Browser
   │
   │ http://localhost:5173
   ▼
React Container (Vite Dev Server)
   │
   │ Hot Module Replacement
   ▼
Browser (Real-time Updates)
```

## Adding New Project Flow

```
1. Run Script
   $ .\add-project.ps1 -Type laravel -Name "blog" -Port 9005

2. Script Creates
   ├── projects/php/blog/ directory
   └── Service definition (YAML)

3. Copy YAML to
   docker-compose.projects.yml

4. Place Your Code
   projects/php/blog/
   ├── app/
   ├── public/
   ├── composer.json
   └── ...

5. Start Container
   $ docker compose -f docker-compose.base.yml \
     -f docker-compose.projects.yml up -d

6. Setup Application
   $ docker exec -it laravel-blog composer install
   $ docker exec -it laravel-blog php artisan migrate

7. Access Application
   http://localhost/blog  (via Nginx)
   or configure specific routing
```

## Network Communication

```
┌─────────────────────────────────────────┐
│          app_network (Bridge)           │
│                                         │
│  Containers can communicate using       │
│  service names as hostnames:            │
│                                         │
│  • laravel-api → mysqldb:3306          │
│  • react-app → laravel-api:9000        │
│  • Any container → mailhog:1025        │
│                                         │
└─────────────────────────────────────────┘
```

## Database Configuration (Laravel)

```env
DB_CONNECTION=mysql
DB_HOST=mysqldb           ← Service name, not localhost
DB_PORT=3306
DB_DATABASE=your_db
DB_USERNAME=your_user
DB_PASSWORD=your_pass
```

## Scaling Strategy

### When You Have 5+ Projects

```
Option 1: Keep All in One File
✓ Simple
✗ Large file

Option 2: Split by Project Type
├── docker-compose.base.yml
├── docker-compose.laravel.yml
├── docker-compose.react.yml
└── docker-compose.other.yml

Option 3: Individual Project Files
├── docker-compose.base.yml
├── projects/
│   ├── laravel-api.yml
│   ├── laravel-shop.yml
│   ├── react-app.yml
│   └── react-website.yml
└── Start with: docker compose -f base.yml -f project1.yml -f project2.yml up
```

## Resource Considerations

```
Typical Resource Usage:

Base Services (Always Running)
├── Nginx:      ~10 MB RAM
├── MySQL:      ~400 MB RAM
├── phpMyAdmin: ~50 MB RAM
└── MailHog:    ~20 MB RAM
Total Base:     ~480 MB RAM

Per Laravel Container: ~50-100 MB RAM
Per React Container:   ~200-400 MB RAM

Example Setup (2 Laravel + 2 React):
├── Base Services:     480 MB
├── 2x Laravel:        200 MB
└── 2x React:          800 MB
Total:                ~1.5 GB RAM
```

## Backup Strategy

```
Important Directories to Backup:

✓ projects/              ← Your code
✓ etc/mysql_data/        ← Database data
✓ .env                   ← Environment config
✓ docker-compose.*.yml   ← Service definitions

Not Needed:
✗ images/                (can rebuild)
✗ logs/                  (regenerated)
✗ node_modules/          (reinstall)
✗ vendor/                (reinstall)
```

---

This architecture is designed for:
- **Scalability**: Add projects easily
- **Maintainability**: Reusable images
- **Isolation**: Projects don't interfere
- **Performance**: Shared infrastructure
- **Flexibility**: Enable/disable projects

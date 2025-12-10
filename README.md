# 🐳 Multi-Project Docker Environment for Laravel, Symfony & React

A scalable Docker setup that allows you to manage **multiple Laravel applications**, **multiple Symfony applications**, and **multiple React projects** using shared, reusable Docker images.

## ✨ Features

- 🔄 **Reusable Docker Images**: Build once, use for all projects
- 📦 **Easy Project Addition**: Add new projects in minutes
- 🚀 **Shared Infrastructure**: MySQL, Nginx, phpMyAdmin, MailHog
- 🎯 **Isolated Projects**: Each project runs independently
- ⚡ **Fast Startup**: Pre-built images = quick container starts
- 🛠️ **Cross-Platform**: Windows, Linux, and macOS support
- 🎮 **Simple Management**: Interactive scripts and commands
- 🎵 **Multi-Framework**: Laravel, Symfony, and React support

## 📋 Prerequisites

- Docker Desktop installed and running
- Windows (PowerShell 5.1+) or Linux/macOS (Bash)
- Basic knowledge of Docker Compose

## 🚀 Quick Start (Fresh Setup)

### 1. Build Reusable Images

**Windows:**
```powershell
.\build-images.ps1
```

**Linux/macOS:**
```bash
chmod +x *.sh
./build-images.sh
```

This creates:
- `php-framework:latest` - PHP 8.4 with Laravel & Symfony dependencies
- `react-framework:latest` - Node 24 for React development

### 2. Start Infrastructure Services

```bash
docker compose -f docker-compose.base.yml up -d
```

This starts:
- MySQL (port 3306)
- Nginx (port 80, 443)
- phpMyAdmin (port 8080)
- MailHog (port 1025, 8025)

### 3. Add Your First Project

**Windows:**
```powershell
# Laravel
.\add-project.ps1 -Type laravel -Name "myapp" -Port 9001

# Symfony
.\add-project.ps1 -Type symfony -Name "myblog" -Port 9002

# React
.\add-project.ps1 -Type react -Name "frontend" -Port 5173
```

**Linux/macOS:**
```bash
# Laravel
./add-project.sh laravel myapp 9001

# Symfony
./add-project.sh symfony myblog 9002

# React
./add-project.sh react frontend 5173
```

### 4. Update docker-compose.projects.yml

Copy the generated YAML from the script output and paste it into `docker-compose.projects.yml`

### 5. Place Your Code

Put your application code in:
- Laravel: `projects/php/myapp/`
- Symfony: `projects/php/myblog/`
- React: `projects/react/frontend/`

### 6. Start Your Projects

```bash
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
```

### 7. Setup Your Applications

**Laravel:**
```bash
docker exec -it laravel-myapp composer install
docker exec -it laravel-myapp php artisan key:generate
docker exec -it laravel-myapp php artisan migrate
```

**Symfony:**
```bash
docker exec -it symfony-myblog composer install
docker exec -it symfony-myblog php bin/console doctrine:database:create
docker exec -it symfony-myblog php bin/console doctrine:migrations:migrate
```

**React:**
```bash
docker exec -it react-frontend npm install
```

### 8. Access Your Applications

- **phpMyAdmin**: http://localhost:8080
- **MailHog UI**: http://localhost:8025
- **Your React App**: http://localhost:5173 (or your chosen port)
- **MySQL**: localhost:3306

## ➕ Adding New Projects

### Using the Add-Project Script (Recommended)

**Windows:**
```powershell
# Add a new Laravel project
.\add-project.ps1 -Type laravel -Name "blog" -Port 9002

# Add a new React project
.\add-project.ps1 -Type react -Name "dashboard" -Port 5175
```

**Linux/macOS:**
```bash
# Add a new Laravel project
./add-project.sh laravel blog 9002

# Add a new React project
./add-project.sh react dashboard 5175
```

The script will:
1. Create the project directory
2. Generate SSL certificates for HTTPS (self-signed, valid for 365 days)
3. Generate the service definition YAML
4. Show you what to add to `docker-compose.projects.yml`

Then:
1. Copy the generated YAML to `docker-compose.projects.yml`
2. Place your code in the created directory
3. Restart: `docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d`

**Note:** SSL certificates are stored in `etc/ssl/project-name/` and can be used with Nginx for HTTPS.

### Manual Addition (Advanced)

#### Adding a Laravel Project

1. Create directory: `projects/php/your-project/`
2. Add to `docker-compose.projects.yml`:

```yaml
  laravel-your-project:
    image: php-framework:latest
    container_name: laravel-your-project
    volumes:
      - "./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini"
      - "./projects/php/your-project:/var/www/your-project"
    working_dir: /var/www/your-project
    ports:
      - "9003:9000"  # Choose next available port
    depends_on:
      - mysqldb
    networks:
      - app_network
```

3. Restart services

#### Adding a React Project

1. Create directory: `projects/react/your-project/`
2. Add to `docker-compose.projects.yml`:

```yaml
  react-your-project:
    image: react-framework:latest
    container_name: react-your-project
    ports:
      - "5176:5173"  # Choose next available port
    environment:
      - CHOKIDAR_USEPOLLING=true
      - NODE_ENV=development
    volumes:
      - "./projects/react/your-project:/app"
      - "/app/node_modules"
    working_dir: /app
    command: ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
    restart: always
    networks:
      - app_network
```

3. Restart services

## 🎮 Common Commands

### Interactive Menu (Easiest)

**Windows:**
```powershell
.\manage.ps1
```

**Linux/macOS:**
```bash
./manage.sh
```

### Using Scripts

**Windows:**
```powershell
# Build images
.\build-images.ps1

# Add new project (Laravel/Symfony/React)
.\add-project.ps1 -Type symfony -Name "blog" -Port 9002
```

**Linux/macOS:**
```bash
# Build images
./build-images.sh

# Add new project (laravel/symfony/react)
./add-project.sh symfony blog 9002
```

### Using Docker Compose

```bash
# Start all services
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d

# Stop all services
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down

# View logs
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f

# View specific service logs
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f laravel-myapp

# Restart specific service
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart react-frontend

# List running containers
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml ps
```

### Using Make (Alternative)

```bash
make build      # Build images
make up         # Start all services
make down       # Stop all services
make logs       # View all logs
make ps         # List containers
```

### Working with Laravel

```bash
# Install dependencies
docker exec -it laravel-myapp composer install

# Run migrations
docker exec -it laravel-myapp php artisan migrate

# Generate key
docker exec -it laravel-myapp php artisan key:generate

# Clear cache
docker exec -it laravel-myapp php artisan cache:clear

# Shell access
docker exec -it laravel-myapp bash
```

### Working with Symfony

```bash
# Install dependencies
docker exec -it symfony-myblog composer install

# Database commands
docker exec -it symfony-myblog php bin/console doctrine:database:create
docker exec -it symfony-myblog php bin/console doctrine:migrations:migrate

# Clear cache
docker exec -it symfony-myblog php bin/console cache:clear

# Make commands
docker exec -it symfony-myblog php bin/console make:controller
docker exec -it symfony-myblog php bin/console make:entity

# Shell access
docker exec -it symfony-myblog bash
```

### Working with React

```bash
# Install dependencies
docker exec -it react-frontend npm install

# Build for production
docker exec -it react-frontend npm run build

# Shell access
docker exec -it react-frontend sh
```

## 📁 Directory Structure

```
Docker/
├── images/                           # Reusable Docker images
│   ├── php-framework/
│   │   └── Dockerfile               # PHP 8.4 for Laravel & Symfony
│   └── react-dev/
│       └── Dockerfile               # Node 24 + Alpine
│
├── projects/                         # Your applications (empty, ready)
│   ├── php/                         # Laravel & Symfony projects here
│   └── react/                       # React projects here
│
├── etc/                             # Configuration
│   ├── nginx/                       # Nginx configs
│   ├── php/
│   │   └── php.ini
│   ├── mysql/
│   │   └── 01-databases.sql
│   └── ssl/
│
├── logs/                            # Application logs
│   └── nginx/
│
├── docker-compose.base.yml          # Infrastructure services
├── docker-compose.projects.yml      # Your projects (template)
│
├── Scripts (Windows):
│   ├── build-images.ps1             # Build Docker images
│   ├── add-project.ps1              # Add new projects
│   └── manage.ps1                   # Interactive menu
│
├── Scripts (Linux/macOS):
│   ├── build-images.sh              # Build Docker images
│   ├── add-project.sh               # Add new projects
│   └── manage.sh                    # Interactive menu
│
├── Documentation:
│   ├── START-HERE.md                # Quick start guide
│   ├── README.md                    # This file
│   ├── CHEATSHEET.md                # Command reference
│   ├── INDEX.md                     # Documentation index
│   ├── ARCHITECTURE.md              # System design
│   ├── SYMFONY.md                   # Symfony-specific guide
│   └── LINUX-MACOS.md               # Linux/Mac guide
│
├── Makefile                         # Make commands (optional)
└── .env                             # Environment variables
```

## 🔌 Port Mapping & Virtual Hosts

### Infrastructure Ports
- **Nginx HTTP**: 80
- **Nginx HTTPS**: 443
- **MySQL**: 3306
- **phpMyAdmin**: 8080
- **MailHog SMTP**: 1025
- **MailHog Web**: 8025

### Project Ports

**Important:** Each project needs a **unique port number**.

#### Laravel/Symfony Projects (PHP-FPM)
- First project: 9001
- Second project: 9002
- Third project: 9003
- (Increment for each new project)

#### React Projects (Dev Server)
- First project: 5173
- Second project: 5174
- Third project: 5175
- (Increment for each new project)

### Virtual Host Setup (Recommended)

Instead of accessing via `http://localhost:9001`, use friendly URLs like `http://myapp.local`.

**The `add-project` script automatically generates:**
1. Nginx virtual host configuration
2. Instructions for hosts file setup

**Manual Setup:**

1. **Add Nginx Configuration** (generated by script, copy to `etc/nginx/default.conf`)
2. **Edit Hosts File:**

   **Windows:** `C:\Windows\System32\drivers\etc\hosts` (Run Notepad as Administrator)
   ```
   127.0.0.1  myapp.local
   127.0.0.1  myblog.local
   127.0.0.1  frontend.local
   ```

   **Linux/macOS:** `/etc/hosts` (Use sudo)
   ```bash
   sudo nano /etc/hosts
   ```
   Add:
   ```
   127.0.0.1  myapp.local
   127.0.0.1  myblog.local
   127.0.0.1  frontend.local
   ```

3. **Restart Nginx:**
   ```bash
   docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart web
   ```

4. **Access your projects:**
   - Laravel: `http://myapp.local` or `https://myapp.local`
   - Symfony: `http://myblog.local` or `https://myblog.local`
   - React: `http://frontend.local` or `https://frontend.local`

## 🔧 Customization

### Modify PHP Configuration

Edit `etc/php/php.ini` and restart PHP containers:

```bash
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart laravel-myapp
```

### Add PHP Extensions

1. Edit `images/php-framework/Dockerfile`
2. Add your extension installation commands
3. Rebuild images (Windows: `.\build-images.ps1` or Linux/macOS: `./build-images.sh`)
4. Recreate containers:

```bash
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d --force-recreate
```

### Modify Nginx Configuration

Edit `etc/nginx/default.conf` and restart Nginx:

```powershell
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart web
```

## 🐛 Troubleshooting

### Port Already in Use

**Windows:**
```powershell
netstat -ano | findstr :5173
```

**Linux/macOS:**
```bash
lsof -i :5173
```

Then change the port in `docker-compose.projects.yml`

### Container Won't Start

```bash
# View logs
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs laravel-myapp

# Check container status
docker ps -a
```

### Permission Issues (Laravel)

```bash
docker exec -it laravel-myapp chown -R www-data:www-data storage bootstrap/cache
docker exec -it laravel-myapp chmod -R 775 storage bootstrap/cache
```

### React Hot Reload Not Working

Ensure `CHOKIDAR_USEPOLLING=true` is set in the environment variables.

### Database Connection Issues

Check your Laravel `.env` file:

```env
DB_CONNECTION=mysql
DB_HOST=mysqldb
DB_PORT=3306
DB_DATABASE=your_database
DB_USERNAME=root
DB_PASSWORD=your_password
```

## 📚 Documentation

- **[START-HERE.md](START-HERE.md)** - Quick start guide (read this first!)
- **[CHEATSHEET.md](CHEATSHEET.md)** - Command reference
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture
- **[Docker Compose Docs](https://docs.docker.com/compose/)** - Official Docker documentation
- **[Laravel Docs](https://laravel.com/docs)** - Laravel documentation
- **[Symfony Docs](https://symfony.com/doc)** - Symfony documentation

## 🎯 Best Practices

1. **Keep images updated**: Regularly rebuild base images with security updates
2. **Use .env files**: Don't commit sensitive data to version control
3. **Volume management**: Use named volumes for persistent data
4. **Resource limits**: Set memory/CPU limits for production environments
5. **Logging**: Configure proper log rotation
6. **Backups**: Regular database backups (use `mysqldump`)
7. **Security**: Use strong passwords and keep ports closed in production

## 🌐 Cross-Platform Notes

- **Windows**: Use PowerShell scripts (`.ps1`)
- **Linux/macOS**: Use Bash scripts (`.sh`) - run `chmod +x *.sh` first
- All Docker Compose files work identically across platforms

## 💡 Tips

- Use `docker-compose.projects.yml` to enable/disable projects (comment out services)
- Each project can have its own database schema
- Shared MySQL instance saves resources
- Use the interactive menu (`manage.ps1` or `manage.sh`) for easier management
- Check `CHEATSHEET.md` for quick command reference
- Keep your base images lean and focused

## 🆘 Getting Help

1. **Quick Start**: See [START-HERE.md](START-HERE.md)
2. **Commands**: See [CHEATSHEET.md](CHEATSHEET.md)
3. **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md)

## 📝 License

This setup is provided as-is under the MIT license. Modify freely for your projects.

---

**Happy Coding! 🚀**

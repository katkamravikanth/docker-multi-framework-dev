# 🚀 Quick Start Guide

## Fresh Multi-Project Docker Setup

This is a **clean, fresh setup** ready for your new projects!

## 📋 What's Ready

✅ **Reusable Docker images** (not built yet)  
✅ **Empty project structure** ready for your apps  
✅ **Infrastructure services** (MySQL, Nginx, phpMyAdmin, MailHog)  
✅ **Cross-platform scripts** (Windows, Linux, macOS)  
✅ **Complete documentation**

---

## 🎯 First-Time Setup (5 Minutes)

### Step 1: Build Reusable Images

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

### Step 2: Start Infrastructure Services

```powershell
# Windows
docker compose -f docker-compose.base.yml up -d

# Linux/macOS (same command)
docker compose -f docker-compose.base.yml up -d
```

This starts:
- ✅ MySQL (port 3306)
- ✅ Nginx (port 80, 443)
- ✅ phpMyAdmin (port 8080)
- ✅ MailHog (port 1025, 8025)

### Step 3: Add Your First Project

**Windows:**
```powershell
# Laravel project
.\add-project.ps1 -Type laravel -Name "myapp" -Port 9001

# React project
.\add-project.ps1 -Type react -Name "frontend" -Port 5173
```

**Linux/macOS:**
```bash
# Laravel project
./add-project.sh laravel myapp 9001

# React project
./add-project.sh react frontend 5173
```

> 🔒 **SSL Certificates:** The script automatically generates self-signed SSL certificates for each project in `etc/ssl/project-name/`

### Step 4: Add Generated Config

The script will output YAML code. Copy it and paste into `docker-compose.projects.yml`

### Step 5: Place Your Code

Put your application code in:
- Laravel/Symfony: `projects/php/myapp/`
- React: `projects/react/frontend/`

### Step 6: Start Your Projects

```powershell
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
```

### Step 7: Setup Your Application

**Laravel:**
```powershell
docker exec -it laravel-myapp composer install
docker exec -it laravel-myapp php artisan key:generate
docker exec -it laravel-myapp php artisan migrate
```

**React:**
```powershell
docker exec -it react-frontend npm install
```

---

## 🎮 Interactive Menu (Easiest Way)

**Windows:**
```powershell
.\manage.ps1
```

**Linux/macOS:**
```bash
./manage.sh
```

This gives you a menu to:
- Build images
- Start/stop services
- View logs
- Add projects
- Run Laravel/React commands

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| **START-HERE.md** | This file - quick start |
| **README.md** | Complete manual |
| **CHEATSHEET.md** | Command reference |

---

## 🌐 Access Your Services

Once started:
- **phpMyAdmin**: http://localhost:8080
- **MailHog UI**: http://localhost:8025
- **Your Laravel API**: Configure in Nginx or access via PHP-FPM port
- **Your React App**: http://localhost:5173 (or your chosen port)

---

## 📁 Directory Structure

```
Docker/
├── projects/
│   ├── php/             # Put Laravel & Symfony projects here
│   └── react/           # Put React projects here
├── images/
│   ├── php-framework/   # Reusable PHP Dockerfile
│   └── react-dev/       # Reusable React Dockerfile
├── etc/                 # Configuration files
├── docker-compose.base.yml        # Infrastructure
└── docker-compose.projects.yml    # Your projects (empty, ready)
```

---

## ⚡ Common Commands

### Start All
```powershell
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
```

### Stop All
```powershell
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down
```

### View Logs
```powershell
docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f
```

### Add Project
```powershell
# Windows
.\add-project.ps1 -Type laravel -Name "blog" -Port 9002

# Linux/macOS
./add-project.sh laravel blog 9002
```

---

## 🆘 Need Help?

1. **Complete Guide**: See `README.md`
2. **Commands**: See `CHEATSHEET.md`

---

## ✅ Next Steps Checklist

- [ ] Build images (`build-images.ps1` or `build-images.sh`)
- [ ] Start infrastructure (`docker compose -f docker-compose.base.yml up -d`)
- [ ] Add your first project (`add-project.ps1` or `add-project.sh`)
- [ ] Place your code in `projects/` directory
- [ ] Update `docker-compose.projects.yml` with generated config
- [ ] Start your project containers
- [ ] Setup your application (composer/npm install, migrations, etc.)

---

**🎉 You're ready to build! Start with `.\build-images.ps1`**

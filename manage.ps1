# Docker Multi-Project Manager
# Interactive menu for managing your Docker environment

function Show-Menu {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "   Docker Multi-Project Manager" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Build Docker Images" -ForegroundColor Yellow
    Write-Host "2. Start All Services" -ForegroundColor Green
    Write-Host "3. Stop All Services" -ForegroundColor Red
    Write-Host "4. Restart All Services" -ForegroundColor Magenta
    Write-Host "5. View Logs" -ForegroundColor White
    Write-Host "6. Add New Project" -ForegroundColor Cyan
    Write-Host "7. List Running Containers" -ForegroundColor White
    Write-Host "8. Laravel Commands" -ForegroundColor Yellow
    Write-Host "9. React Commands" -ForegroundColor Yellow
    Write-Host "0. Exit" -ForegroundColor Gray
    Write-Host ""
}

function Build-Images {
    Write-Host "Building Docker images..." -ForegroundColor Yellow
    & .\build-images.ps1
    Pause
}

function Start-Services {
    Write-Host "Starting all services..." -ForegroundColor Green
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
    Write-Host "Services started!" -ForegroundColor Green
    Pause
}

function Stop-Services {
    Write-Host "Stopping all services..." -ForegroundColor Red
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down
    Write-Host "Services stopped!" -ForegroundColor Red
    Pause
}

function Restart-Services {
    Write-Host "Restarting all services..." -ForegroundColor Magenta
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart
    Write-Host "Services restarted!" -ForegroundColor Green
    Pause
}

function View-Logs {
    Write-Host ""
    Write-Host "Which logs do you want to view?" -ForegroundColor Yellow
    Write-Host "1. All services" -ForegroundColor White
    Write-Host "2. Laravel API" -ForegroundColor White
    Write-Host "3. React App" -ForegroundColor White
    Write-Host "4. React Website" -ForegroundColor White
    Write-Host "5. MySQL" -ForegroundColor White
    Write-Host "6. Nginx" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "Enter choice"
    
    switch ($choice) {
        1 { docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f }
        2 { docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f laravel-api }
        3 { docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f react-app }
        4 { docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f react-website }
        5 { docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f mysqldb }
        6 { docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f web }
    }
}

function Add-Project {
    Write-Host ""
    Write-Host "What type of project?" -ForegroundColor Yellow
    Write-Host "1. Laravel" -ForegroundColor White
    Write-Host "2. React" -ForegroundColor White
    Write-Host ""
    $type = Read-Host "Enter choice"
    
    $projectType = if ($type -eq "1") { "laravel" } else { "react" }
    $projectName = Read-Host "Enter project name"
    $port = Read-Host "Enter port number"
    
    & .\add-project.ps1 -Type $projectType -Name $projectName -Port $port
    Pause
}

function List-Containers {
    Write-Host "Running containers:" -ForegroundColor Yellow
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml ps
    Pause
}

function Laravel-Commands {
    Write-Host ""
    Write-Host "Laravel Commands" -ForegroundColor Yellow
    Write-Host "1. Composer Install" -ForegroundColor White
    Write-Host "2. Run Migrations" -ForegroundColor White
    Write-Host "3. Generate Key" -ForegroundColor White
    Write-Host "4. Clear Cache" -ForegroundColor White
    Write-Host "5. Shell Access" -ForegroundColor White
    Write-Host "6. Fix Permissions" -ForegroundColor White
    Write-Host ""
    $container = Read-Host "Container name (e.g., laravel-api)"
    $choice = Read-Host "Enter choice"
    
    switch ($choice) {
        1 { docker exec -it $container composer install }
        2 { docker exec -it $container php artisan migrate }
        3 { docker exec -it $container php artisan key:generate }
        4 { docker exec -it $container php artisan cache:clear }
        5 { docker exec -it $container bash }
        6 { 
            docker exec -it $container chown -R www-data:www-data storage bootstrap/cache
            docker exec -it $container chmod -R 775 storage bootstrap/cache
        }
    }
    Pause
}

function React-Commands {
    Write-Host ""
    Write-Host "React Commands" -ForegroundColor Yellow
    Write-Host "1. NPM Install" -ForegroundColor White
    Write-Host "2. Build Production" -ForegroundColor White
    Write-Host "3. Shell Access" -ForegroundColor White
    Write-Host ""
    $container = Read-Host "Container name (e.g., react-app)"
    $choice = Read-Host "Enter choice"
    
    switch ($choice) {
        1 { docker exec -it $container npm install }
        2 { docker exec -it $container npm run build }
        3 { docker exec -it $container sh }
    }
    Pause
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice) {
        1 { Build-Images }
        2 { Start-Services }
        3 { Stop-Services }
        4 { Restart-Services }
        5 { View-Logs }
        6 { Add-Project }
        7 { List-Containers }
        8 { Laravel-Commands }
        9 { React-Commands }
        0 { exit }
    }
} while ($true)

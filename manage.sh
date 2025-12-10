#!/usr/bin/env bash

# Docker Multi-Project Manager (Linux/macOS)
# Interactive menu for managing your Docker environment

show_menu() {
    clear
    echo "====================================="
    echo "   Docker Multi-Project Manager"
    echo "====================================="
    echo ""
    echo "1. Build Docker Images"
    echo "2. Start All Services"
    echo "3. Stop All Services"
    echo "4. Restart All Services"
    echo "5. View Logs"
    echo "6. Add New Project"
    echo "7. List Running Containers"
    echo "8. Laravel Commands"
    echo "9. React Commands"
    echo "0. Exit"
    echo ""
}

build_images() {
    echo "Building Docker images..."
    ./build-images.sh
    read -p "Press Enter to continue..."
}

start_services() {
    echo "Starting all services..."
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml up -d
    echo "Services started!"
    read -p "Press Enter to continue..."
}

stop_services() {
    echo "Stopping all services..."
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml down
    echo "Services stopped!"
    read -p "Press Enter to continue..."
}

restart_services() {
    echo "Restarting all services..."
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart
    echo "Services restarted!"
    read -p "Press Enter to continue..."
}

view_logs() {
    echo ""
    echo "Which logs do you want to view?"
    echo "1. All services"
    echo "2. Laravel API"
    echo "3. React App"
    echo "4. React Website"
    echo "5. MySQL"
    echo "6. Nginx"
    echo ""
    read -p "Enter choice: " choice
    
    case $choice in
        1) docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f ;;
        2) docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f laravel-api ;;
        3) docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f react-app ;;
        4) docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f react-website ;;
        5) docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f mysqldb ;;
        6) docker compose -f docker-compose.base.yml -f docker-compose.projects.yml logs -f web ;;
    esac
}

add_project() {
    echo ""
    echo "What type of project?"
    echo "1. Laravel"
    echo "2. React"
    echo ""
    read -p "Enter choice: " type_choice
    
    if [ "$type_choice" == "1" ]; then
        project_type="laravel"
    else
        project_type="react"
    fi
    
    read -p "Enter project name: " project_name
    read -p "Enter port number: " port
    
    ./add-project.sh "$project_type" "$project_name" "$port"
    read -p "Press Enter to continue..."
}

list_containers() {
    echo "Running containers:"
    docker compose -f docker-compose.base.yml -f docker-compose.projects.yml ps
    read -p "Press Enter to continue..."
}

laravel_commands() {
    echo ""
    echo "Laravel Commands"
    echo "1. Composer Install"
    echo "2. Run Migrations"
    echo "3. Generate Key"
    echo "4. Clear Cache"
    echo "5. Shell Access"
    echo "6. Fix Permissions"
    echo ""
    read -p "Container name (e.g., laravel-api): " container
    read -p "Enter choice: " choice
    
    case $choice in
        1) docker exec -it "$container" composer install ;;
        2) docker exec -it "$container" php artisan migrate ;;
        3) docker exec -it "$container" php artisan key:generate ;;
        4) docker exec -it "$container" php artisan cache:clear ;;
        5) docker exec -it "$container" bash ;;
        6) 
            docker exec -it "$container" chown -R www-data:www-data storage bootstrap/cache
            docker exec -it "$container" chmod -R 775 storage bootstrap/cache
            ;;
    esac
    read -p "Press Enter to continue..."
}

react_commands() {
    echo ""
    echo "React Commands"
    echo "1. NPM Install"
    echo "2. Build Production"
    echo "3. Shell Access"
    echo ""
    read -p "Container name (e.g., react-app): " container
    read -p "Enter choice: " choice
    
    case $choice in
        1) docker exec -it "$container" npm install ;;
        2) docker exec -it "$container" npm run build ;;
        3) docker exec -it "$container" sh ;;
    esac
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice: " choice
    
    case $choice in
        1) build_images ;;
        2) start_services ;;
        3) stop_services ;;
        4) restart_services ;;
        5) view_logs ;;
        6) add_project ;;
        7) list_containers ;;
        8) laravel_commands ;;
        9) react_commands ;;
        0) exit 0 ;;
        *) echo "Invalid choice"; sleep 1 ;;
    esac
done

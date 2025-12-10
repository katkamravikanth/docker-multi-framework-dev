#!/usr/bin/env bash

# Quick Add Script - Add new Laravel, Symfony or React projects easily
# Usage: ./add-project.sh <type> <name> <port>
#   type: laravel, symfony or react
#   name: project name
#   port: port number

if [ $# -ne 3 ]; then
    echo "Usage: ./add-project.sh <type> <name> <port>"
    echo "  type: laravel, symfony or react"
    echo "  name: project name"
    echo "  port: port number"
    echo ""
    echo "Example: ./add-project.sh laravel blog 9005"
    exit 1
fi

TYPE=$1
NAME=$2
PORT=$3

# Validate type
if [ "$TYPE" != "laravel" ] && [ "$TYPE" != "symfony" ] && [ "$TYPE" != "react" ]; then
    echo "Error: Type must be 'laravel', 'symfony' or 'react'"
    exit 1
fi

# Convert name to lowercase and replace spaces with hyphens
PROJECT_NAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

echo "====================================="
echo "Adding New $TYPE Project: $PROJECT_NAME"
echo "====================================="
echo ""

# Create project directory
if [ "$TYPE" == "laravel" ] || [ "$TYPE" == "symfony" ]; then
    PROJECT_PATH="projects/php/$PROJECT_NAME"
else
    PROJECT_PATH="projects/react/$PROJECT_NAME"
fi

if [ ! -d "$PROJECT_PATH" ]; then
    mkdir -p "$PROJECT_PATH"
    echo "✓ Created directory: $PROJECT_PATH"
else
    echo "⚠ Directory already exists: $PROJECT_PATH"
fi

# Generate SSL certificate for the project
SSL_DIR="etc/ssl/$PROJECT_NAME"
if [ ! -d "$SSL_DIR" ]; then
    mkdir -p "$SSL_DIR"
    echo "✓ Created SSL directory: $SSL_DIR"
    
    # Generate self-signed certificate
    CERT_PATH="$SSL_DIR/$PROJECT_NAME.crt"
    KEY_PATH="$SSL_DIR/$PROJECT_NAME.key"
    
    if command -v openssl &> /dev/null; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$KEY_PATH" \
            -out "$CERT_PATH" \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=$PROJECT_NAME.local" &> /dev/null
        
        echo "✓ Generated SSL certificate: $CERT_PATH"
        echo "✓ Generated SSL key: $KEY_PATH"
    else
        echo "⚠ OpenSSL not found. Skipping SSL generation."
        echo "  Install OpenSSL or generate certificates manually."
    fi
else
    echo "⚠ SSL directory already exists: $SSL_DIR"
fi

# Generate service definition
SERVICE_DEFINITION=""

if [ "$TYPE" == "laravel" ]; then
    SERVICE_DEFINITION="
  # Laravel Project: $PROJECT_NAME
  laravel-$PROJECT_NAME:
    image: php-framework:latest
    container_name: laravel-$PROJECT_NAME
    volumes:
      - \"./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini\"
      - \"./projects/php/$PROJECT_NAME:/var/www/$PROJECT_NAME\"
    working_dir: /var/www/$PROJECT_NAME
    ports:
      - \"$PORT:9000\"
    depends_on:
      - mysqldb
    networks:
      - app_network

  # Scheduler for Laravel: $PROJECT_NAME
  laravel-$PROJECT_NAME-scheduler:
    image: php-framework:latest
    container_name: laravel-$PROJECT_NAME-scheduler
    volumes:
      - \"./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini\"
      - \"./projects/php/$PROJECT_NAME:/var/www/$PROJECT_NAME\"
    working_dir: /var/www/$PROJECT_NAME
    command: php artisan schedule:work
    restart: always
    depends_on:
      - laravel-$PROJECT_NAME
      - mysqldb
    networks:
      - app_network
"
elif [ "$TYPE" == "symfony" ]; then
    SERVICE_DEFINITION="
  # Symfony Project: $PROJECT_NAME
  symfony-$PROJECT_NAME:
    image: php-framework:latest
    container_name: symfony-$PROJECT_NAME
    volumes:
      - \"./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini\"
      - \"./projects/php/$PROJECT_NAME:/var/www/$PROJECT_NAME\"
    working_dir: /var/www/$PROJECT_NAME
    ports:
      - \"$PORT:9000\"
    depends_on:
      - mysqldb
    networks:
      - app_network
    environment:
      - APP_ENV=dev
      - DATABASE_URL=mysql://root:password@mysqldb:3306/symfony_db
"
else
    SERVICE_DEFINITION="
  # React Project: $PROJECT_NAME
  react-$PROJECT_NAME:
    image: react-framework:latest
    container_name: react-$PROJECT_NAME
    ports:
      - \"$PORT:5173\"
    environment:
      - CHOKIDAR_USEPOLLING=true
      - NODE_ENV=development
    volumes:
      - \"./projects/react/$PROJECT_NAME:/app\"
      - \"/app/node_modules\"
    working_dir: /app
    command: [\"npm\", \"run\", \"dev\", \"--\", \"--host\", \"0.0.0.0\"]
    restart: always
    networks:
      - app_network
"
fi

echo ""
echo "Service Definition:"
echo "$SERVICE_DEFINITION"
echo ""

# Generate Nginx configuration for virtual host
DOMAIN="$PROJECT_NAME.local"
NGINX_CONFIG=""

if [ "$TYPE" == "laravel" ] || [ "$TYPE" == "symfony" ]; then
    NGINX_CONFIG="
# Add this to etc/nginx/default.conf for virtual host access:
server {
    listen 80;
    server_name $DOMAIN;

    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/$PROJECT_NAME/public;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass $TYPE-$PROJECT_NAME:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
}

# HTTPS (optional):
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/ssl/$PROJECT_NAME/$PROJECT_NAME.crt;
    ssl_certificate_key /etc/ssl/$PROJECT_NAME/$PROJECT_NAME.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/$PROJECT_NAME/public;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass $TYPE-$PROJECT_NAME:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
}
"
else
    NGINX_CONFIG="
# Add this to etc/nginx/default.conf for virtual host access:
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://react-$PROJECT_NAME:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_bypass \$http_upgrade;
    }
}

# HTTPS (optional):
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/ssl/$PROJECT_NAME/$PROJECT_NAME.crt;
    ssl_certificate_key /etc/ssl/$PROJECT_NAME/$PROJECT_NAME.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        proxy_pass http://react-$PROJECT_NAME:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_bypass \$http_upgrade;
    }
}
"
fi

echo "Nginx Virtual Host Configuration:"
echo "$NGINX_CONFIG"
echo ""

echo "====================================="
echo "Next Steps:"
echo "====================================="
echo ""
echo "1. Copy the service definition above to docker-compose.projects.yml"
echo "2. Copy the Nginx config above to etc/nginx/default.conf"
echo "3. Add to your hosts file: 127.0.0.1  $PROJECT_NAME.local"
echo "   Linux/macOS: /etc/hosts (Use sudo)"
echo "   Windows: C:\\Windows\\System32\\drivers\\etc\\hosts (Run as Administrator)"
echo "4. Place your $TYPE code in: $PROJECT_PATH"
echo "5. Restart services: docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart"
echo ""

if [ "$TYPE" == "laravel" ]; then
    echo "Laravel Setup:"
    echo "  - Install dependencies: docker exec -it laravel-$PROJECT_NAME composer install"
    echo "  - Run migrations: docker exec -it laravel-$PROJECT_NAME php artisan migrate"
    echo "  - Access via: http://$PROJECT_NAME.local (with Nginx + hosts file)"
    echo "  - Or via port: http://localhost:$PORT (direct PHP-FPM, requires additional setup)"
elif [ "$TYPE" == "symfony" ]; then
    echo "Symfony Setup:"
    echo "  - Install dependencies: docker exec -it symfony-$PROJECT_NAME composer install"
    echo "  - Run migrations: docker exec -it symfony-$PROJECT_NAME php bin/console doctrine:migrations:migrate"
    echo "  - Clear cache: docker exec -it symfony-$PROJECT_NAME php bin/console cache:clear"
    echo "  - Access via: http://$PROJECT_NAME.local (with Nginx + hosts file)"
    echo "  - Or via port: http://localhost:$PORT (direct PHP-FPM, requires additional setup)"
else
    echo "React Setup:"
    echo "  - Install dependencies: docker exec -it react-$PROJECT_NAME npm install"
    echo "  - Access via: http://$PROJECT_NAME.local (with Nginx + hosts file)"
    echo "  - Or directly: http://localhost:$PORT"
fi

echo ""

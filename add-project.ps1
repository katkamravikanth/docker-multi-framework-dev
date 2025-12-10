# Quick Add Script - Add new Laravel, Symfony or React projects easily
# Usage: .\add-project.ps1 -Type [laravel|symfony|react] -Name [project-name] -Port [port-number]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("laravel", "symfony", "react")]
    [string]$Type,
    
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter(Mandatory=$true)]
    [int]$Port
)

$ProjectName = $Name.ToLower() -replace '\s+', '-'

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Adding New $Type Project: $ProjectName" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Create project directory
$phpType = if ($Type -eq "laravel" -or $Type -eq "symfony") { "php" } else { $Type }
$projectPath = "projects\$phpType\$ProjectName"
if (!(Test-Path $projectPath)) {
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    Write-Host "✓ Created directory: $projectPath" -ForegroundColor Green
} else {
    Write-Host "⚠ Directory already exists: $projectPath" -ForegroundColor Yellow
}

# Generate SSL certificate for the project
$sslDir = "etc\ssl\$ProjectName"
if (!(Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir -Force | Out-Null
    Write-Host "✓ Created SSL directory: $sslDir" -ForegroundColor Green
    
    # Generate self-signed certificate
    $certPath = "$sslDir\$ProjectName.crt"
    $keyPath = "$sslDir\$ProjectName.key"
    
    try {
        $null = & openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $keyPath -out $certPath -subj "/C=US/ST=State/L=City/O=Organization/CN=$ProjectName.local" 2>&1
        
        if (Test-Path $certPath) {
            Write-Host "✓ Generated SSL certificate: $certPath" -ForegroundColor Green
            Write-Host "✓ Generated SSL key: $keyPath" -ForegroundColor Green
        } else {
            Write-Host "⚠ SSL generation failed. Check OpenSSL installation." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠ OpenSSL not found. Skipping SSL generation." -ForegroundColor Yellow
        Write-Host "  Install OpenSSL or generate certificates manually." -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠ SSL directory already exists: $sslDir" -ForegroundColor Yellow
}

# Generate service definition
$serviceDefinition = ""

if ($Type -eq "laravel") {
    $serviceDefinition = @"

  # Laravel Project: $ProjectName
  laravel-$ProjectName`:
    image: php-framework:latest
    container_name: laravel-$ProjectName
    volumes:
      - "./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini"
      - "./projects/php/$ProjectName`:/var/www/$ProjectName"
    working_dir: /var/www/$ProjectName
    ports:
      - "$Port`:9000"
    depends_on:
      - mysqldb
    networks:
      - app_network

  # Scheduler for Laravel: $ProjectName
  laravel-$ProjectName-scheduler:
    image: php-framework:latest
    container_name: laravel-$ProjectName-scheduler
    volumes:
      - "./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini"
      - "./projects/php/$ProjectName`:/var/www/$ProjectName"
    working_dir: /var/www/$ProjectName
    command: php artisan schedule:work
    restart: always
    depends_on:
      - laravel-$ProjectName
      - mysqldb
    networks:
      - app_network
"@
} elseif ($Type -eq "symfony") {
    $serviceDefinition = @"

  # Symfony Project: $ProjectName
  symfony-$ProjectName`:
    image: php-framework:latest
    container_name: symfony-$ProjectName
    volumes:
      - "./etc/php/php.ini:/usr/local/etc/php/conf.d/php.ini"
      - "./projects/php/$ProjectName`:/var/www/$ProjectName"
    working_dir: /var/www/$ProjectName
    ports:
      - "$Port`:9000"
    depends_on:
      - mysqldb
    networks:
      - app_network
    environment:
      - APP_ENV=dev
      - DATABASE_URL=mysql://root:password@mysqldb:3306/symfony_db
"@
} elseif ($Type -eq "react") {
    $serviceDefinition = @"

  # React Project: $ProjectName
  react-$ProjectName`:
    image: react-framework:latest
    container_name: react-$ProjectName
    ports:
      - "$Port`:5173"
    environment:
      - CHOKIDAR_USEPOLLING=true
      - NODE_ENV=development
    volumes:
      - "./projects/react/$ProjectName`:/app"
      - "/app/node_modules"
    working_dir: /app
    command: ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
    restart: always
    networks:
      - app_network
"@
}

Write-Host ""
Write-Host "Service Definition:" -ForegroundColor Yellow
Write-Host $serviceDefinition -ForegroundColor Gray
Write-Host ""

# Generate Nginx configuration for virtual host
$domain = "$ProjectName.local"
$nginxConfig = ""

if ($Type -eq "laravel" -or $Type -eq "symfony") {
    $nginxConfig = @"

# Add this to etc/nginx/default.conf for virtual host access:
server {
    listen 80;
    server_name $domain;

    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/$ProjectName/public;

    location / {
        try_files `$uri `$uri/ /index.php?`$query_string;
    }

    location ~ \.php`$ {
        try_files `$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)`$;
        fastcgi_pass $Type-$ProjectName`:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
        fastcgi_param PATH_INFO `$fastcgi_path_info;
    }
}

# HTTPS (optional):
server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/ssl/$ProjectName/$ProjectName.crt;
    ssl_certificate_key /etc/ssl/$ProjectName/$ProjectName.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/$ProjectName/public;

    location / {
        try_files `$uri `$uri/ /index.php?`$query_string;
    }

    location ~ \.php`$ {
        try_files `$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)`$;
        fastcgi_pass $Type-$ProjectName`:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME `$document_root`$fastcgi_script_name;
        fastcgi_param PATH_INFO `$fastcgi_path_info;
    }
}
"@
} elseif ($Type -eq "react") {
    $nginxConfig = @"

# Add this to etc/nginx/default.conf for virtual host access:
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_pass http://react-$ProjectName`:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade `$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_cache_bypass `$http_upgrade;
    }
}

# HTTPS (optional):
server {
    listen 443 ssl;
    server_name $domain;

    ssl_certificate /etc/ssl/$ProjectName/$ProjectName.crt;
    ssl_certificate_key /etc/ssl/$ProjectName/$ProjectName.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        proxy_pass http://react-$ProjectName`:5173;
        proxy_http_version 1.1;
        proxy_set_header Upgrade `$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
        proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
        proxy_cache_bypass `$http_upgrade;
    }
}
"@
}

Write-Host "Nginx Virtual Host Configuration:" -ForegroundColor Yellow
Write-Host $nginxConfig -ForegroundColor Gray
Write-Host ""

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Copy the service definition above to docker-compose.projects.yml" -ForegroundColor White
Write-Host "2. Copy the Nginx config above to etc/nginx/default.conf" -ForegroundColor White
Write-Host "3. Add to your hosts file: 127.0.0.1  $ProjectName.local" -ForegroundColor White
Write-Host "   Windows: C:\Windows\System32\drivers\etc\hosts (Run as Administrator)" -ForegroundColor Gray
Write-Host "   Linux/macOS: /etc/hosts (Use sudo)" -ForegroundColor Gray
Write-Host "4. Place your $Type code in: $projectPath" -ForegroundColor White
Write-Host "5. Restart services: docker compose -f docker-compose.base.yml -f docker-compose.projects.yml restart" -ForegroundColor White
Write-Host ""

if ($Type -eq "laravel") {
    Write-Host "Laravel Setup:" -ForegroundColor Cyan
    Write-Host "  - Install dependencies: docker exec -it laravel-$ProjectName composer install" -ForegroundColor White
    Write-Host "  - Run migrations: docker exec -it laravel-$ProjectName php artisan migrate" -ForegroundColor White
    Write-Host "  - Access via: http://$ProjectName.local (with Nginx + hosts file)" -ForegroundColor White
    Write-Host "  - Or via port: http://localhost:$Port (direct PHP-FPM, requires additional setup)" -ForegroundColor Gray
} elseif ($Type -eq "symfony") {
    Write-Host "Symfony Setup:" -ForegroundColor Cyan
    Write-Host "  - Install dependencies: docker exec -it symfony-$ProjectName composer install" -ForegroundColor White
    Write-Host "  - Run migrations: docker exec -it symfony-$ProjectName php bin/console doctrine:migrations:migrate" -ForegroundColor White
    Write-Host "  - Clear cache: docker exec -it symfony-$ProjectName php bin/console cache:clear" -ForegroundColor White
    Write-Host "  - Access via: http://$ProjectName.local (with Nginx + hosts file)" -ForegroundColor White
    Write-Host "  - Or via port: http://localhost:$Port (direct PHP-FPM, requires additional setup)" -ForegroundColor Gray
} else {
    Write-Host "React Setup:" -ForegroundColor Cyan
    Write-Host "  - Install dependencies: docker exec -it react-$ProjectName npm install" -ForegroundColor White
    Write-Host "  - Access via: http://$ProjectName.local (with Nginx + hosts file)" -ForegroundColor White
    Write-Host "  - Or directly: http://localhost:$Port" -ForegroundColor White
}

Write-Host ""


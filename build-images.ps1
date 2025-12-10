# Build script for Docker images (PowerShell)
# This builds the reusable PHP and React images

Write-Host "Building reusable Docker images..." -ForegroundColor Green

# Build PHP/Framework image (Laravel, Symfony)
Write-Host "Building PHP/Framework image (Laravel, Symfony)..." -ForegroundColor Yellow
docker build -t php-framework:latest ./images/php-framework

# Build React development image
Write-Host "Building React development image..." -ForegroundColor Yellow
docker build -t react-framework:latest ./images/react-dev

Write-Host ""
Write-Host "All images built successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Available images:" -ForegroundColor Cyan
Write-Host "  - php-framework:latest (for Laravel & Symfony)"
Write-Host "  - react-framework:latest"

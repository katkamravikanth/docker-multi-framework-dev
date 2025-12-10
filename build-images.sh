#!/usr/bin/env bash

# Build script for Docker images
# This builds the reusable PHP and React images

echo "Building reusable Docker images..."

# Build PHP/Framework image (Laravel, Symfony)
echo "Building PHP/Framework image (Laravel, Symfony)..."
docker build -t php-framework:latest ./images/php-framework

# Build React development image
echo "Building React development image..."
docker build -t react-framework:latest ./images/react-dev

echo "All images built successfully!"
echo ""
echo "Available images:"
echo "  - php-framework:latest (for Laravel & Symfony)"
echo "  - react-framework:latest"

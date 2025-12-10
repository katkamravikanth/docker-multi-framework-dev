FROM php:8.4-fpm

LABEL maintainer="Ravikanth Katkam"
LABEL description="Reusable PHP 8.4 FPM image for Laravel and Symfony applications"

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    redis-tools zlib1g-dev g++ git libicu-dev zip libzip-dev libsodium-dev \
    libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev \
    libsqlite3-dev librabbitmq-dev libssh-dev nodejs npm \
    libxrender1 libfontconfig1 libxtst6 libssl-dev \
    xfonts-75dpi xfonts-base curl unzip \
 && docker-php-ext-install intl opcache pdo_mysql pcntl bcmath sockets \
    zip sodium gd pdo_sqlite \
 && docker-php-ext-configure gd \
 && pecl install apcu redis amqp \
 && docker-php-ext-enable apcu redis amqp sodium \
 && apt-get purge -y --auto-remove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf
RUN curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb -o wkhtmltox.deb \
 && apt-get update && apt-get install -y ./wkhtmltox.deb \
 && rm wkhtmltox.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory (can be overridden in docker-compose)
WORKDIR /var/www

# Expose PHP-FPM port
EXPOSE 9000

CMD ["php-fpm"]

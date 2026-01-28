FROM php:7.3-apache

# --------------------------------------------------
# 1. Install system dependencies
# --------------------------------------------------
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    zip \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------
# 2. Install GD (WAJIB untuk dompdf v0.7)
# --------------------------------------------------
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install gd

# --------------------------------------------------
# 3. Install PHP extensions
# --------------------------------------------------
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath

# --------------------------------------------------
# 4. Enable Apache rewrite
# --------------------------------------------------
RUN a2enmod rewrite

# --------------------------------------------------
# 5. Install Composer
# --------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --------------------------------------------------
# 6. Set working directory
# --------------------------------------------------
WORKDIR /var/www/html

# --------------------------------------------------
# 7. Copy Laravel source code
# --------------------------------------------------
COPY . .

# --------------------------------------------------
# 8. Install PHP dependencies (TANPA artisan optimize)
# --------------------------------------------------
RUN composer install \
    --no-dev \
    --no-scripts \
    --optimize-autoloader

# --------------------------------------------------
# 9. Buat folder cache Laravel (WAJIB)
# --------------------------------------------------
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/views \
    storage/framework/sessions \
    bootstrap/cache

# --------------------------------------------------
# 10. Set permission Laravel
# --------------------------------------------------
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 775 storage bootstrap/cache

# --------------------------------------------------
# 11. Set Apache document root ke /public
# --------------------------------------------------
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

# --------------------------------------------------
# 12. Expose port
# --------------------------------------------------
EXPOSE 80

FROM php:7.3-apache

# 1. System dependencies
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

# 2. Install GD (WAJIB untuk dompdf)
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install gd

# 3. PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath

# 4. Enable Apache rewrite
RUN a2enmod rewrite

# 5. FIX Apache MPM (INI PENTING)
RUN a2dismod mpm_event mpm_worker || true \
 && a2enmod mpm_prefork

# 6. Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 7. Workdir
WORKDIR /var/www/html

# 8. Copy source
COPY . .

# 9. Install dependencies (tanpa artisan optimize)
RUN composer install --no-dev --no-scripts --optimize-autoloader

# 10. Laravel cache folders
RUN mkdir -p \
    storage/framework/cache \
    storage/framework/views \
    storage/framework/sessions \
    bootstrap/cache

# 11. Permission
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 775 storage bootstrap/cache

# 12. Apache document root ke /public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

EXPOSE 80

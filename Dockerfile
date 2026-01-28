FROM php:7.3-apache

# =========================
# 1. System dependencies
# =========================
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# =========================
# 2. GD extension (dompdf)
# =========================
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install gd

# =========================
# 3. PHP extensions
# =========================
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    zip \
    exif \
    bcmath

# =========================
# 4. Apache config (AMAN)
# =========================
RUN a2dismod mpm_event mpm_worker || true \
 && a2enmod rewrite

# =========================
# 5. Composer
# =========================
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# =========================
# 6. App
# =========================
WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --no-scripts --optimize-autoloader

# =========================
# 7. Permission Laravel
# =========================
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache \
 && chown -R www-data:www-data /var/www/html \
 && chmod -R 775 storage bootstrap/cache

# =========================
# 8. Apache document root
# =========================
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

EXPOSE 80

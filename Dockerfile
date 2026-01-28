FROM php:7.3-cli

# =========================
# 1. System dependencies
# =========================
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# =========================
# 2. GD extension
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
# 4. Composer
# =========================
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --no-scripts --optimize-autoloader

# =========================
# 5. Laravel permission
# =========================
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# =========================
# 6. Expose Railway port
# =========================
EXPOSE 8080

# =========================
# 7. Start Laravel server
# =========================
CMD php artisan serve --host=0.0.0.0 --port=8080

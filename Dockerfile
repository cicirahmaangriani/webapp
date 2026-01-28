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
# 2. PHP extensions
# =========================
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install \
    gd pdo pdo_mysql pdo_pgsql mbstring zip exif bcmath

# =========================
# 3. INSTALL COMPOSER v1 (WAJIB)
# =========================
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --1

WORKDIR /app
COPY . .

# =========================
# 4. Laravel safe cache path
# =========================
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache /tmp/views \
 && chmod -R 777 storage bootstrap/cache /tmp

# =========================
# 5. Composer install (AMAN)
# =========================
RUN composer install \
    --no-dev \
    --no-interaction \
    --optimize-autoloader \
    --ignore-platform-reqs

# =========================
# 6. Railway PORT
# =========================
EXPOSE 3000

# =========================
# 7. Start PHP server
# =========================
CMD php -S 0.0.0.0:${PORT} -t public

FROM php:7.3-cli

# =========================
# 1. System dependencies
# =========================
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    libpq-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# =========================
# 2. PHP Extensions
# =========================
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    zip

# =========================
# 3. Composer (AMAN UNTUK PHP 7.3)
# =========================
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

# =========================
# 4. Composer install
# =========================
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --ignore-platform-reqs

# =========================
# 5. Laravel permissions
# =========================
RUN chmod -R 775 storage bootstrap/cache

# =========================
# 6. Start Laravel (WAJIB $PORT)
# =========================
CMD php artisan serve --host=0.0.0.0 --port=$PORT

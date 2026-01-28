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
# 3. INSTALL COMPOSER V1 (INI PENTING)
# =========================
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --1

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
# 5. Permissions
# =========================
RUN chmod -R 775 storage bootstrap/cache

# =========================
# 6. Start Laravel
# =========================
CMD php artisan serve --host=0.0.0.0 --port=$PORT

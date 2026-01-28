FROM php:7.3-cli

# 1. System dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# 2. PHP extensions
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install \
    gd \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    zip \
    exif \
    bcmath

# 3. Install Composer v1 (WAJIB untuk Laravel lama)
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --1

WORKDIR /app
COPY . .

# 4. Composer install
RUN composer install \
    --no-dev \
    --no-interaction \
    --optimize-autoloader \
    --ignore-platform-reqs

# 5. Laravel permissions
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# 6. Railway PORT (tidak wajib, tapi aman)
EXPOSE 3000

# 7. Start server (PALING PENTING)
CMD php -S 0.0.0.0:${PORT} -t public

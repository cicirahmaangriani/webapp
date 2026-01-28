# Gunakan PHP 7.3 sesuai permintaan
FROM php:7.3-cli

# Install dependencies sistem
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd pdo pdo_pgsql zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 1. INSTALL COMPOSER VERSI 1 (Lebih stabil untuk library PHP lama)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --1

WORKDIR /app

# 2. COPY SOURCE CODE
COPY . .

# 3. JALANKAN COMPOSER INSTALL
# Mantra --ignore-platform-reqs agar tidak rewel soal versi PHP 7.1 vs 7.3
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Set permissions
RUN chmod -R 775 storage bootstrap/cache

EXPOSE 8080

# Jalankan server
CMD php -S 0.0.0.0:8080 -t public
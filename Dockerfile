FROM php:7.3-cli

RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libpq-dev \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install \
    gd pdo pdo_mysql pdo_pgsql mbstring zip exif bcmath

# Composer v1 (WAJIB Laravel 5.4)
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --1

WORKDIR /app
COPY . .

RUN composer install \
    --no-dev \
    --no-interaction \
    --optimize-autoloader \
    --ignore-platform-reqs

# Laravel runtime cache (FIX ERROR)
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache /tmp/views \
 && chmod -R 777 storage bootstrap/cache /tmp

EXPOSE 3000

CMD php -S 0.0.0.0:${PORT} -t public

FROM php:7.2-cli

RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libpq-dev \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install gd pdo pdo_pgsql mbstring zip bcmath

COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --no-interaction --optimize-autoloader

RUN mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache \
 && chmod -R 777 storage bootstrap/cache

EXPOSE 3000
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-3000}

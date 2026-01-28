FROM php:7.3-apache

# System deps
RUN apt-get update && apt-get install -y \
    git unzip curl zip \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# GD (WAJIB dompdf)
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install gd

# PHP extensions
RUN docker-php-ext-install \
    pdo pdo_mysql pdo_pgsql mbstring zip exif bcmath

# FORCE Apache MPM
RUN rm -f /etc/apache2/mods-enabled/mpm_* \
 && a2enmod mpm_prefork rewrite

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Composer install (NO artisan optimize)
RUN composer install --no-dev --no-scripts --optimize-autoloader

# Laravel folders
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache \
 && chown -R www-data:www-data /var/www/html \
 && chmod -R 775 storage bootstrap/cache

# Apache docroot
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

EXPOSE 80

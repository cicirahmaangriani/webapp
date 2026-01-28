FROM php:7.3-apache

# 1. System dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    zip \
    curl

# 2. Install GD FIRST (INI WAJIB SEBELUM COMPOSER)
RUN docker-php-ext-configure gd \
    --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# 3. PHP extensions lain
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    mbstring \
    zip \
    exif \
    pcntl \
    bcmath

# 4. Enable Apache rewrite
RUN a2enmod rewrite

# 5. Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 6. Set workdir
WORKDIR /var/www/html

# 7. Copy source code
COPY . .

# 8. Run composer SETELAH GD ADA
RUN composer install --no-dev --optimize-autoloader

# 9. Apache document root ke /public
RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

# 10. Permission Laravel
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 80

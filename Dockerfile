# Gunakan PHP 7.3 CLI berbasis Debian Buster agar kompatibel dengan library lama
FROM php:7.3-cli

# Set working directory
WORKDIR /app

# Install dependencies sistem dan ekstensi PHP yang umum dibutuhkan
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
    && docker-php-ext-install gd pdo pdo_mysql pdo_pgsql zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer versi 1.x (Karena PHP 7.3 seringkali menggunakan library lama)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --1

# Copy seluruh file project ke dalam container
COPY . .

# Jalankan install composer
# Menggunakan --ignore-platform-reqs untuk menghindari konflik versi PHP 7.1/7.2 di composer.lock
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Set permissions untuk folder storage dan cache (Penting untuk Laravel)
RUN chmod -R 775 storage bootstrap/cache

# Railway akan memberikan port secara dinamis lewat environment variable $PORT
# Jika tidak ada, default ke 8080
ENV PORT=8080
EXPOSE ${PORT}

# Perintah untuk menjalankan aplikasi
# Menggunakan PHP Built-in server yang diarahkan ke folder public
CMD php -S 0.0.0.0:${PORT} -t public
FROM php:8.3-fpm

# 1. Install system dependencies & PHP extensions yang dibutuhkan Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev

# 2. Clear cache sistem
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Install & aktifkan ekstensi PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

# 4. Ambil Composer versi terbaru
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Set working directory
WORKDIR /var/www

# 6. Copy semua file aplikasi ke container
COPY . /var/www

# 7. Install library menggunakan Composer
# --no-scripts: Mencegah error saat menjalankan artisan command sebelum folder vendor lengkap
# --ignore-platform-reqs: Memastikan build lanjut meski ada ketidakcocokan versi minor
RUN composer install --no-interaction --no-dev --optimize-autoloader --no-scripts --ignore-platform-reqs

# 8. Set permissions folder storage dan cache agar bisa ditulis oleh web server
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]
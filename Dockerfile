FROM php:8.2-fpm
 
# Install system dependencies
RUN apt update && apt install -y \
    libpng-dev zip unzip curl git libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql


# Set working directory
WORKDIR /var/www

# Copy composer files first for better layer caching
COPY composer.json composer.lock ./

# Copy code
COPY . .

# Install Composer & Laravel deps
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer install --no-dev --optimize-autoloader \
    && php artisan config:clear \
    && php artisan route:clear

# Fix permissions
RUN chown -R www-data:www-data /var/www && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

USER www-data

CMD ["php-fpm"]
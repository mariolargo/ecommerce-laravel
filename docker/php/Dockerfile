FROM php:8.3-fpm-alpine

ARG user
ARG uid
ARG gid

# Install system dependencies
RUN apk update && apk add --no-cache \
    acl \
    bash \
    curl \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    oniguruma-dev \
    zip \
    unzip \
    shadow  # Add shadow package to install useradd

# Install Redis extension
RUN apk add --no-cache pcre-dev $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del pcre-dev $PHPIZE_DEPS

# Install PHP extensions required for Laravel
RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apk --no-cache add nodejs npm

# Copy configuration files
COPY ./conf.d/*.ini ${PHP_INI_DIR}/conf.d/
COPY ./pool.d/z-overrides.conf ${PHP_INI_DIR}/pool.d/
COPY ./scripts/setup-permissions.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-permissions.sh

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN groupadd -g $gid $user && \
    useradd -g $user -G www-data,root -u $uid -m $user
# Create a system user for running Composer and Artisan commands
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Check missing folders, storage/logs/laravel.log
RUN mkdir -p /var/www/html/storage/framework/cache && \
    mkdir -p /var/www/html/storage/framework/sessions && \
    mkdir -p /var/www/html/storage/framework/views && \
    mkdir -p /var/www/html/storage/logs && \
    touch /var/www/html/storage/logs/laravel.log

# Set working directory
WORKDIR /var/www/html

# Set appropriate folder permissions for Laravel
RUN mkdir -p /var/www/html/storage && mkdir -p /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Switch to the non-privileged user to run the application
USER $user

# Expose port 9000
EXPOSE 9000

# Start php-fpm server
CMD ["php-fpm", "-F"]

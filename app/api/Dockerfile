FROM dunglas/frankenphp

ARG GITHUB_REPO
ARG GITHUB_TOKEN

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev libzip-dev zip unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && a2enmod rewrite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN git config --global --add safe.directory /var/www/html && \
    git clone --depth 1 --sparse \
    https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git /var/www/html && \
    cd /var/www/html && git sparse-checkout set backend

WORKDIR /var/www/html/backend

RUN composer install --no-dev --optimize-autoloader --no-interaction && \
    chown -R www-data:www-data /var/www/html/backend && \
    chmod -R 755 storage bootstrap/cache

# Pointer Apache sur public/ et autoriser .htaccess (requis par Laravel)
RUN sed -i "s|/var/www/html|/var/www/html/backend/public|g" \
        /etc/apache2/sites-available/000-default.conf \
        /etc/apache2/apache2.conf \
    && sed -i "s|AllowOverride None|AllowOverride All|g" /etc/apache2/apache2.conf

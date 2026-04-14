FROM alpine/git AS clone

WORKDIR /featzy

RUN git clone git@github.com:VincenzoGUILBERT/MDS.git /featzy


FROM node:20-alpine AS frontend-builder

RUN apt-get update && \
    apt-get upgrade -y

WORKDIR /featzy/client
COPY --from=clone /featzy/client .

RUN npm i
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "dev"]

FROM composer:2 AS backend-builder

WORKDIR /featzy/backend
COPY --from=clone /app/backend .

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader


FROM php:8.3-fpm-alpine AS backend

RUN apk add --no-cache \
    libpng-dev oniguruma-dev libxml2-dev zip unzip \
    && docker-php-ext-install pdo_mysql mbstring bcmath gd

WORKDIR /var/www

COPY --from=backend-builder /app/vendor ./vendor
COPY --from=clone /app/backend .

RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]





# npx concurrently -c \"#93c5fd,#c4b5fd\" \"cd backend && php artisan serve\" \"cd client && npm run dev\" --names=backend,frontend --kill-others
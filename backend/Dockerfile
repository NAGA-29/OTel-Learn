FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json ./
RUN composer install --no-interaction --no-progress --prefer-dist --no-scripts

FROM php:8.4-cli-alpine
RUN apk add --no-cache postgresql-dev $PHPIZE_DEPS \
    && docker-php-ext-install pdo_pgsql \
    && apk del $PHPIZE_DEPS
WORKDIR /var/www/html
COPY --from=vendor /app/vendor ./vendor
COPY . .
RUN mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && php artisan package:discover --ansi
EXPOSE 8000


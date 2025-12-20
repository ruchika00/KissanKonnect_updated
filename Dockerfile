FROM php:8.2-apache-alpine

WORKDIR /var/www/html

RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install mysqli pdo pdo_mysql

RUN a2enmod rewrite

COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]

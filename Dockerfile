FROM php:8.1-apache
WORKDIR /var/www/html
RUN apt-get update && apt-get install -y \
    libzip-dev unzip && \
    docker-php-ext-install pdo pdo_mysql zip && \
    a2enmod rewrite
COPY . .
RUN chown -R www-data:www-data /var/www/html
EXPOSE 80
CMD ["apache2-foreground"]

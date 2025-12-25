FROM php:8.2-apache

# Change Apache DocumentRoot to /var/www/html/src
RUN sed -i 's|/var/www/html|/var/www/html/src|g' \
    /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html/src

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy application files
COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]

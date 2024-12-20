FROM php:8.1-apache

# Install required PHP extensions and utilities
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql

# Enable Apache modules
RUN a2enmod rewrite

# Configure PHP
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-error-reporting.ini \
    && echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-error-reporting.ini

# Copy application code
COPY app/ /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
# Используем официальный PHP 8.2 с Apache
FROM php:8.2-apache

# Устанавливаем рабочую директорию
WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev unzip locales \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip mysqli intl


# Настраиваем Apache: делаем корневой папкой /var/www/html/public и включаем mod_rewrite
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf \
    && a2enmod rewrite

RUN mkdir -p /var/www/html/writable /var/www/html/logs \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/writable \
    && chmod -R 775 /var/www/html/logs

# Открываем порт 80
EXPOSE 80

# Указываем стандартный командный процесс для запуска Apache
CMD ["apache2-foreground"]

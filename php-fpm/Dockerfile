FROM php:7.3-fpm

# Set working directory
WORKDIR /var/www/html

RUN apt-get update -y \
    && apt-get upgrade -y \ 
    && apt-get autoremove -y \
    && apt-get install -y curl nano libzip-dev libbz2-dev libpng-dev libfreetype6-dev libjpeg62-turbo-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/  \
    && docker-php-ext-install pdo_mysql mysqli mbstring gd bz2 zip exif pcntl \
    && curl --silent --show-error https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install extensions
# libjpeg62-turbo-dev 
# RUN docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-freetype-dir=/usr/include/
# RUN docker-php-ext-install gd 

# COPY code/ /var/www/html/

# COPY code/.env.prod /var/www/html/.env

EXPOSE 9000
CMD ["php-fpm"]
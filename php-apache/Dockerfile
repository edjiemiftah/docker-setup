FROM php:7.2-apache

WORKDIR /var/www/html

# RUN apt-get update && apt-get install -y \
#         libwebp-dev \
#         libjpeg62-turbo-dev \
#         libpng-dev libxpm-dev \
#         libfreetype6-dev \
#         curl \
#         nano \
#     && curl --silent --show-error https://getcomposer.org/installer | php \
#     && mv composer.phar /usr/local/bin/composer

# RUN apt-get update -y \
#     && apt-get upgrade -y \ 
#     && apt-get autoremove -y \
#     && apt-get install -y curl nano \
#     && curl --silent --show-error https://getcomposer.org/installer | php \
#     && mv composer.phar /usr/local/bin/composer


RUN apt-get update -y \
    && apt-get upgrade -y \ 
    && apt-get autoremove -y \
    && apt-get install -y curl nano libpng-dev libfreetype6-dev libjpeg62-turbo-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  \
    && docker-php-ext-install pdo_mysql mysqli mbstring zip gd \
    && curl --silent --show-error https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

RUN apt-get clean -y && rm -rf /var/lib/apt/lists/*

# RUN docker-php-ext-configure gd \
#     --with-gd \
#     --with-webp-dir \
#     --with-jpeg-dir \
#     --with-png-dir \
#     --with-zlib-dir \
#     --with-xpm-dir \
#     --with-freetype-dir

RUN a2enmod rewrite
RUN a2enmod ssl

COPY php-apache/conf/sistore.conf /etc/apache2/sites-available/000-default.conf
COPY php-apache/conf/ssl_sistore.conf /etc/apache2/sites-available/default-ssl.conf
COPY php-apache/conf/sistore.conf /etc/apache2/sites-enabled/000-default.conf
COPY php-apache/conf/ssl_sistore.conf /etc/apache2/sites-enabled/default-ssl.conf

## BUILD MODE
# COPY code/ /var/www/html/
# COPY code/.env.prod /var/www/html/.env
RUN chown -Rf www-data.www-data /var/www/html
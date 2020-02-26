FROM nginx:alpine

RUN apt-get update -y \
    && apt-get upgrade -y \ 
    && apt-get autoremove -y \
    && apt-get install -y curl nano

RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* 

COPY code/ /var/www/html/
COPY code/.env.prod /var/www/html/.env
RUN chown -Rf www-data.www-data /var/www/html \
    && chgrp -R www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R ug+rwx /var/www/html/storage /var/www/html/bootstrap/cache
COPY nginx/conf.d/default /etc/nginx/sites-available/sistore.id
COPY nginx/conf.d/default /etc/nginx/sites-enabled/sistore.id

WORKDIR /var/www/html
EXPOSE 80
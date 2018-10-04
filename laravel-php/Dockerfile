FROM php:fpm-alpine

RUN apk add --no-cache libxml2-dev libpng-dev libjpeg-turbo-dev freetype-dev \
 && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
 && docker-php-ext-install pdo pdo_mysql mbstring tokenizer xml json gd

COPY php.ini /usr/local/etc/php/

COPY create-cron.sh /root/create-cron.sh 
RUN chmod +x /root/create-cron.sh \
 && apk add --no-cache bash \
 && bash /root/create-cron.sh

RUN mkdir -p /app
VOLUME ["/app"]
WORKDIR /app

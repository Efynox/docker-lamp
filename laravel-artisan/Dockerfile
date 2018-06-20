FROM php:fpm-alpine

RUN apk add --no-cache php7-pdo php7-openssl php7-mbstring php7-tokenizer php7-xml php7-json
 
VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["php", "artisan"]
CMD ["--help"]
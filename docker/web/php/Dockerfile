# BASE IMAGE: PHP VERSION 8.3.6 FPM ON ALPINE LINUX DISTRIBUTION.
FROM php:8.3.6-fpm-alpine3.19

# MAINTAINER INFORMATION AS A LABEL.
LABEL maintainer="Aleksandar Rakić <aleksandar.rakic@yahoo.com>"

# ENVIRONMENT VARIABLES.
ENV WORKDIR /var/www/html

# INSTALLING REQUIRED PACKAGES AND PHP EXTENSIONS.
RUN apk add --no-cache \
    libwebp-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libxpm-dev \
    freetype-dev \
    libzip-dev \
    libsodium-dev \
    libpq-dev \
    icu-dev \
    zlib-dev \
    ca-certificates \
    git \
    openssh-client \
    unzip \
    oniguruma-dev \
    bash \
    g++ \
    autoconf \
    make \
    linux-headers \
    autoconf \
    automake \
    libtool \
    nasm \
    nodejs \
    npm && \
    docker-php-ext-configure gd --with-jpeg --with-freetype && \
    docker-php-ext-install opcache mbstring pgsql pdo pdo_pgsql pdo_mysql mysqli gd sodium zip intl && \
    pecl install apcu xdebug && \
    docker-php-ext-enable apcu xdebug

# DOWNLOADING AND INSTALLING COMPOSER.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && mkdir -p /var/www/.composer

# COPYING CONFIGURATION FILES AND SOURCE FILES.
COPY ./docker/web/php/config/www.conf /usr/local/etc/php-fpm.d/
COPY ./docker/web/php/config/php.ini /usr/local/etc/php/conf.d/
COPY ./src $WORKDIR

# SET WORKING DIRECTORY.
WORKDIR $WORKDIR
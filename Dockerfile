FROM php:7.4-apache

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ARG DEBIAN_FRONTEND=noninteractive
ARG LC_ALL=C.UTF-8
ARG TERM=xterm

RUN apt-get update

RUN apt-get install --yes --no-install-recommends apt-utils 
RUN apt-get install --yes --no-install-recommends apt-transport-https
RUN apt-get install --yes --no-install-recommends software-properties-common

RUN apt-get install --yes iputils-ping
RUN apt-get install --yes curl
RUN apt-get install --yes unzip
RUN apt-get install --yes zip

RUN apt-get install --yes libbz2-dev
RUN apt-get install --yes libc-client-dev
RUN apt-get install --yes libedit-dev
RUN apt-get install --yes libenchant-dev
RUN apt-get install --yes libgmp-dev
RUN apt-get install --yes libkrb5-dev
RUN apt-get install --yes libldap2-dev
RUN apt-get install --yes libmagickwand-dev
RUN apt-get install --yes libmemcached-dev
RUN apt-get install --yes libmcrypt-dev
RUN apt-get install --yes libpng-dev
RUN apt-get install --yes libpq-dev
RUN apt-get install --yes libpspell-dev
RUN apt-get install --yes librecode0
RUN apt-get install --yes librecode-dev
RUN apt-get install --yes libsqlite3-dev
RUN apt-get install --yes libssl-dev
RUN apt-get install --yes libtidy-dev
RUN apt-get install --yes libxml2-dev  
RUN apt-get install --yes libzip-dev
RUN apt-get install --yes unixodbc-dev
RUN apt-get install --yes zlib1g-dev

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install bz2
RUN docker-php-ext-install dba
RUN docker-php-ext-install enchant
RUN docker-php-ext-install gd
RUN docker-php-ext-install gmp
RUN docker-php-ext-install intl
RUN docker-php-ext-install ldap
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install pgsql
RUN docker-php-ext-install pspell
RUN docker-php-ext-install soap
RUN docker-php-ext-install tidy
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install zip

## imap module setting up and installation.
RUN set -x \
    && PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

## odbc module setting up and installation.
RUN set -x \
    && docker-php-source extract \
    && cd /usr/src/php/ext/odbc \
    && phpize \
    && sed -ri 's@^ *test +"\$PHP_.*" *= *"no" *&& *PHP_.*=yes *$@#&@g' configure \
    && ./configure --with-unixODBC=shared,/usr \
    && docker-php-ext-install odbc \
    && docker-php-source delete

RUN pecl install apcu
RUN pecl install imagick
RUN pecl install mcrypt
RUN pecl install memcached
RUN pecl install redis

RUN docker-php-ext-enable apcu
RUN docker-php-ext-enable imagick
RUN docker-php-ext-enable memcached
RUN docker-php-ext-enable mcrypt
RUN docker-php-ext-enable redis

## Composer installation.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

## Node.js installation.
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install --yes nodejs

## Yarn installation.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get install --yes yarn

## Requiring common PHP Packages.
RUN composer global require hirak/prestissimo
RUN composer global require phpunit/phpunit
RUN composer global require phpunit/php-token-stream

RUN apt-get clean -y
RUN apt-get autoclean -y
RUN apt-get autoremove -y

RUN a2enmod rewrite

COPY conf/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY conf/apache/000-default.conf /etc/apache2/sites-enable/000-default.conf

COPY conf/config /config
COPY conf/run.sh /run.sh

RUN chmod 755 /run.sh

WORKDIR /var/www/html

EXPOSE 80 80

CMD ["php"]
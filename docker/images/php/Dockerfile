FROM debian:bookworm-slim

#=======================================================================================================================
# PERMISSIONS
ARG HOST_UID
ARG HOST_GID

# set host UID to www-data user
RUN username=$(echo $(getent passwd $HOST_UID | cut -d: -f1)) \
    && if [[ $username != '' ]] && [[ $username != 'www-data' ]]; then \
      userdel $username; \
    fi \
    && usermod -u $HOST_UID www-data
# set host HOST GID to www-data group
RUN groupname=$(echo $(getent group $HOST_GID | cut -d: -f1)) \
    && if [[ $groupname != '' ]] && [[ $groupname != 'www-data' ]]; then \
      groupdel $groupname; \
    fi \
    && groupmod -g $HOST_GID www-data

#=======================================================================================================================
# PHP VERSION
ARG PHP_VERSION=8.3
# only ENV is used in CMD (ARG is build-time only)
ENV PHP_VERSION=${PHP_VERSION}

#=======================================================================================================================
# PHP SOURCES
# from https://packages.sury.org/php readme
RUN apt-get update && apt-get -y install lsb-release ca-certificates curl && \
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    apt-get update && apt-get upgrade -y

#=======================================================================================================================
# PROJECT PHP EXTENSIONS
# default extensions that are already bundled and are not required to be installed:
# calendar Core ctype date exif FFI fileinfo filter ftp gettext hash iconv json libxml openssl pcntl pcre PDO Phar posix
# random readline Reflection session shmop sockets sodium SPL standard sysvmsg sysvsem sysvshm tokenizer Zend OPcache
# zlib

# install additional required php extensions for project
# most commonly used: curl, pdo_pgsql, redis, etc.
RUN apt-get -y install php${PHP_VERSION}-fpm

#=======================================================================================================================
# PHP CONFIG
# set default php.ini
RUN mv /usr/lib/php/${PHP_VERSION}/php.ini-production /etc/php/${PHP_VERSION}/fpm/php.ini
# set php.ini overrides
COPY production.ini /etc/php/${PHP_VERSION}/fpm/conf.d/zz-ini.ini
# php-fpm conf overrides
COPY php-fpm.conf /etc/php/${PHP_VERSION}/fpm/pool.d/zz-php-fpm.conf
# php-fpm log permissions
RUN touch /var/log/php${PHP_VERSION}-fpm.log && chown www-data:www-data /var/log/php${PHP_VERSION}-fpm.log

#=======================================================================================================================
# COMPOSER (PHP package manager)
COPY --from=composer:2 /usr/bin/composer /usr/bin/

#=======================================================================================================================
# ADDITIONAL TOOLS
RUN apt-get update && apt-get -y install --no-install-recommends cron

#=======================================================================================================================
# DIRECTORY SETUP
RUN mkdir -p /var/www && chown -R www-data:www-data /var/www
WORKDIR /var/www/html/api

#=======================================================================================================================
# DEV ENV DEPENDENCIES
# override php config
RUN mv /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/fpm/php.ini
COPY development.ini /etc/php/${PHP_VERSION}/fpm/conf.d/zz-ini.ini
# additional os dependencies for composer
RUN apt-get -y install --no-install-recommends unzip git \
    # dev env php extensions
    && apt-get install -y --no-install-recommends php${PHP_VERSION}-xdebug \
    # dev env tools
    && apt-get install -y --no-install-recommends vim

#=======================================================================================================================
# ADDITIONAL PROJECT SPECIFIC STEPS
# here goes anything that is not covered by the above steps

#=======================================================================================================================
USER www-data
CMD ["sh", "-c", "cron && php-fpm${PHP_VERSION} -F"]
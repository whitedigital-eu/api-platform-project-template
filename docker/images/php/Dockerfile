FROM php:8.2-fpm-bookworm

# PERMISSIONS ----------------------------------------------------------------------------------------------------------
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

# DEPENDENCIES ---------------------------------------------------------------------------------------------------------
# install php extension installer, so that dependencies for php extensions are resolved automatically
COPY --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/

# install composer - php package manager
COPY --from=composer:2 /usr/bin/composer /usr/bin/

# package updates + composer dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends unzip \
# tool dependencies
    && apt-get install -y --no-install-recommends vim git

# PHP EXTENSIONS -------------------------------------------------------------------------------------------------------
# default extensions that are already bundled and are not required to be installed:
# Core ctype curl date dom fileinfo filter ftp hash iconv json libxml mbstring mysqlnd openssl pcre PDO pdo_sqlite Phar
# posix random readline Reflection session SimpleXML sodium SPL sqlite3 standard tokenizer xml xmlreader xmlwriter zlib

# install additional required php extensions for project
# most commonly used: pdo_pgsql, redis, etc.
RUN install-php-extensions opcache

# PHP CONFIG -----------------------------------------------------------------------------------------------------------
# set default php.ini
RUN mv ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini

# set php.ini overrides
COPY production.ini ${PHP_INI_DIR}/conf.d/zz-production.ini

# php-fpm conf overrides
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-www.conf

# ----------------------------------------------------------------------------------------------------------------------
# set default working dir
WORKDIR /var/www/html/api

# set default user
USER www-data
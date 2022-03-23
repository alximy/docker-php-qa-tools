ARG PHP_VERSION
ARG FROM_IMAGE=php:${PHP_VERSION}-cli

FROM ${FROM_IMAGE} as build-qa-tools

RUN set -xe; \
    apt-get update && apt-get install -y \
        git \
        unzip \
        libzip-dev \
    && docker-php-ext-install -j$(nproc) \
		zip

COPY --from=composer /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_HOME /usr/local/composer

RUN set -xe; \
    mkdir -p /usr/local/src; \
    cd /usr/local/src; \
    composer init --name=${COMPOSE_PROJECT_NAME:-local}/php-qa-tools --no-interaction; \
    composer config allow-plugins.bamarni/composer-bin-plugin true; \
    composer config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true; \
    composer require --optimize-autoloader \
        bamarni/composer-bin-plugin; \
    composer bin composer-unused require --optimize-autoloader \
        icanhazstring/composer-unused; \
    composer bin php-parallel-lint require --optimize-autoloader \
        php-parallel-lint/php-parallel-lint; \
    composer bin phpcpd require --optimize-autoloader \
        sebastian/phpcpd; \
    composer bin phpdepend require --optimize-autoloader \
        pdepend/pdepend; \
    composer bin phan require --optimize-autoloader \
        phan/phan; \
    composer bin php-cs-fixer require --optimize-autoloader \
        friendsofphp/php-cs-fixer; \
    composer bin php_codesniffer require --optimize-autoloader \
        squizlabs/php_codesniffer; \
    composer bin php-deprecation-detector require --optimize-autoloader \
        wapmorgan/php-deprecation-detector; \
    composer bin phpinsights require --optimize-autoloader \
        nunomaduro/phpinsights; \
    composer bin phploc require --optimize-autoloader \
        phploc/phploc; \
    composer bin phpmd require --optimize-autoloader \
        phpmd/phpmd; \
    composer bin phpmetrics require --optimize-autoloader \
        phpmetrics/phpmetrics; \
    composer bin phpmnd require --optimize-autoloader \
        povils/phpmnd; \
    composer bin phpstan require --optimize-autoloader \
        phpstan/phpstan \
        phpstan/phpstan-dibi \
        phpstan/phpstan-doctrine \
        phpstan/phpstan-phpunit \
        phpstan/phpstan-beberlei-assert \
        phpstan/phpstan-strict-rules; \
    composer bin twigcs require --optimize-autoloader \
        friendsoftwig/twigcs; \
    composer bin yaml-linter require --optimize-autoloader \
        symfony/console \
        symfony/yaml

FROM ${FROM_IMAGE} as build-su-exec

RUN set -ex; \
    curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
    fetch_deps='gcc libc-dev'; \
    apt-get update && apt-get install -y --no-install-recommends $fetch_deps; \
    gcc -Wall \
        /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
    chown root:root /usr/local/bin/su-exec; \
    chmod 0755 /usr/local/bin/su-exec

FROM ${FROM_IMAGE}

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN pecl install ast \
    && docker-php-ext-enable ast

RUN set -xe; \
    echo 'memory_limit=-1' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini; \
    apt-get update && apt-get install -y \
        bash \
        graphviz

COPY --from=build-qa-tools /usr/bin/composer /usr/local/bin/composer
COPY --from=build-qa-tools /usr/local/src /usr/local/src
COPY --from=build-su-exec /usr/local/bin/su-exec /usr/local/bin/

ENV PATH /usr/local/src/vendor/bin:$PATH

RUN set -ex; \
    addgroup bar; \
    adduser foo --ingroup bar --no-create-home; \
    chown -R foo:bar /usr/local/bin/composer; \
    chown -R foo:bar /usr/local/src/vendor/bin

COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]
